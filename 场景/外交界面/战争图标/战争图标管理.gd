extends Node3D

## 战争图标管理 v4 —— 语义锚点 + 地图地块质心，槽位按需动态创建。
##
## 流程：
##   war_icon_anchors.json（战争号/特殊号 → 一个或多个参战国原版序号）→
##   用 CountryData.gwcode 找到地图国家 → 世界地图渲染.country_centroid() 求质心 →
##   世界地图渲染.latlon_to_sphere_pos() 转球面坐标 →
##   按 anchor pair 分组去重（同地多战争只留一个）→ 按需创建 Sprite3D 槽。
##
## 与 v3 的差异：
##   - 同一场战争可以有多个语义锚点（例如日本方向在“日本 + 朝韩边界”都显示；
##     沙特半岛解放战争在周围一圈国家都显示）。
##   - 支持“非战争面板”的冲突状态图标：安哥拉内战、莫桑比克内战、缅甸内战等，
##     不再只依赖 WarData.is_going。
##
## UI 联动：
##   槽的 Area3D 发送 clicked，本管理器转成带完整战争信息的信号，
##   由 外交.gd 高亮参战国（不切场景、不显示文本 tooltip）。

signal war_icon_clicked(info: Dictionary)

const ANCHORS_PATH := "res://资产/地图/war_icon_anchors.json"
const ICON_SCRIPT := preload("res://场景/外交界面/战争图标/战争图标.gd")
const ICON_TEX := preload("res://资产/UI/外交/战争图标.png")
const W = preload("res://数据脚本/world_state.gd")

const ICON_PIXEL_SIZE := 0.000375

var _anchors: Dictionary = {}
var _slots: Array[Node] = []
var _last_entries: Array[Dictionary] = []
var _info_by_war: Dictionary = {}
var _missing_anchor_warned: Dictionary = {}


func _ready() -> void:
	_load_anchors()
	_collect_slots()
	if GameManager:
		if not GameManager.world_state_loaded.is_connected(_refresh):
			GameManager.world_state_loaded.connect(_refresh)
		# 每一日 tick 都会同时发出 stats_changed，因此不需要再单独监听 date_changed，
		# 否则最高速度下战争图标会每 tick 重复刷新两次。
		if GameManager.has_signal("stats_changed") and not GameManager.stats_changed.is_connected(_refresh):
			GameManager.stats_changed.connect(_refresh)
	var earth := get_parent()
	if earth != null and earth.has_signal("map_data_ready") and not earth.map_data_ready.is_connected(_refresh):
		earth.map_data_ready.connect(_refresh)
	# 父节点 地球 的地图数据可能在 _ready 内异步/稍后就绪；下一帧再刷一次。
	call_deferred("_refresh")


func _on_date_changed(_date: GameDate) -> void:
	# 领土归属/战争状态可能随日期变化；刷新很轻量。
	_refresh()


func _load_anchors() -> void:
	if not FileAccess.file_exists(ANCHORS_PATH):
		push_error("战争图标管理: 找不到锚点文件 %s" % ANCHORS_PATH)
		return
	var text := FileAccess.get_file_as_string(ANCHORS_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		_anchors = parsed
	else:
		push_error("战争图标管理: 锚点 JSON 解析失败 %s" % ANCHORS_PATH)


func _collect_slots() -> void:
	# v3/v4：场景不再预置静态槽；仅兼容收集（若未来在编辑器里手摆槽仍可用）。
	_slots.clear()
	for child in get_children():
		if child is Sprite3D and child.has_method("display_entry"):
			var slot: Sprite3D = child
			if not slot.clicked.is_connected(_on_slot_clicked):
				slot.clicked.connect(_on_slot_clicked)
			_slots.append(slot)
	_slots.sort_custom(func(a: Node, b: Node) -> bool: return str(a.name) < str(b.name))


## 按需扩容槽位：entries 超出当前槽数时动态创建（v3/v4 替代场景预置静态槽）。
func _ensure_slots(count: int) -> void:
	var i := _slots.size()
	while _slots.size() < count:
		var slot := Sprite3D.new()
		slot.name = "war_icon_dyn_%d" % i
		slot.texture = ICON_TEX
		slot.pixel_size = ICON_PIXEL_SIZE
		slot.set_script(ICON_SCRIPT)
		add_child(slot)
		# set_script 后 add_child 触发 _ready（建命中区）；再连信号
		if not slot.clicked.is_connected(_on_slot_clicked):
			slot.clicked.connect(_on_slot_clicked)
		_slots.append(slot)
		i += 1


# ── 刷新 ──

func _refresh() -> void:
	var w: WorldState = WarSystem.current_world
	if w == null:
		for slot in _slots:
			if slot is Sprite3D:
				slot.display_entry({})
		_last_entries.clear()
		_info_by_war.clear()
		return
	var entries := _build_entries(w)
	var visible_entries := _aggregate_by_group(entries)
	_assign_slots(visible_entries)


## 取某个 key 的全部锚点定义；兼容旧格式“单对象”和新格式“对象数组”。
func _anchor_list(key: String) -> Array:
	var v = _anchors.get(key)
	if v is Array:
		return v
	if v is Dictionary and not v.is_empty():
		return [v]
	return []


func _build_entries(w: WorldState) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	# 战争面板里进行中的代理战争。
	for i in w.wars.size():
		var war: WarData = w.wars[i]
		if war == null or not war.is_going:
			continue
		for e in _make_entries(w, str(i), i, war.name_war, war.side1, war.side2,
				maxi(war.infl1, 0), maxi(war.infl2, 0)):
			entries.append(e)
	# 特殊状态图标（原版 special ogon）。
	if w.get_flag("iranrev"):
		for e in _make_entries(w, "-1", -1, "", "", "", 0, 0):
			entries.append(e)
	if w.war_state == GameConstants.WarState.INDIA:
		for e in _make_entries(w, "-2", -2, "", "", "", 0, 0):
			entries.append(e)
	if w.war_state == GameConstants.WarState.SINO_SOVIET:
		for e in _make_entries(w, "-3", -3, "", "", "", 0, 0):
			entries.append(e)
	if w.size() > 37 and w.philippines_maoist_power > 0 and w.philippines_maoist_power < 1000:
		for e in _make_entries(w, "-4", -4, "", "", "", 0, 0):
			entries.append(e)
	# 不在战争面板里的“内战/革命冲突”状态图标。
	if _angola_civil_active(w):
		var a_infl := _infl_of(w, 68, 1)
		var b_infl := _infl_of(w, 68, 2)
		for e in _make_entries(w, "68", 68, "安哥拉内战", "", "", a_infl, b_infl):
			entries.append(e)
	if _mozambique_civil_active(w):
		for e in _make_entries(w, "-7", -7, "莫桑比克内战", "", "", 0, 0):
			entries.append(e)
	if _burma_civil_active(w):
		var burma_war_id := 82
		if w.war_going(83):
			burma_war_id = 83
		var b1_infl := _infl_of(w, burma_war_id, 1)
		var b2_infl := _infl_of(w, burma_war_id, 2)
		var burma_name := "第二次缅甸内战" if burma_war_id == 83 else "缅甸内战"
		for e in _make_entries(w, str(burma_war_id), burma_war_id, burma_name, "", "", b1_infl, b2_infl):
			entries.append(e)
	return entries


# ── 非面板冲突状态判定 ──

func _infl_of(w: WorldState, war_id: int, side: int) -> int:
	var war := w.get_war(war_id)
	if war == null:
		return 0
	return war.infl1 if side == 1 else war.infl2


## 安哥拉内战：原版 68 号战争未必在当前端口被 TimeScript 自动拉起，
## 但事件 638 选完派系、或国家进入内战/力量介入后，地图上就应显示图标。
func _angola_civil_active(w: WorldState) -> bool:
	if w.war_going(68):
		return true
	var c := w.get_country_by_legacy_index(123)
	if c == null:
		return false
	if c.内战中:
		return true
	if w.event_done_num(638):
		# 安哥拉内战需要至少两方力量仍在介入（原版自动开战条件：一方>=900 且另两方>0）。
		var active_sides := 0
		if c.prc_power > 0:
			active_sides += 1
		if c.sov_power > 0:
			active_sides += 1
		if c.usa_power > 0:
			active_sides += 1
		return active_sides >= 2
	return false


## 莫桑比克内战：原版以 country.parts[0] / level_of_unstab 表达，不在 WarData 面板中。
func _mozambique_civil_active(w: WorldState) -> bool:
	var c := w.get_country_by_legacy_index(126)
	if c == null:
		return false
	# 莫桑比克内战以 parts[0] 作为活跃状态；event_625 的 prepare 会清掉 parts[0]，
	# 因此战争一结算图标即消失，不再因 level_of_instability 残留而继续显示。
	return c.parts.size() > 0 and c.parts[0]


## 缅甸内战：外交互动会将缅甸置为“内战中”，随后事件 663/664 才正式打开 82/83 战争。
func _burma_civil_active(w: WorldState) -> bool:
	# 缅甸内战图标只在实际上有 82/83 号战争进行时显示，
	# 外交互动只把缅甸置为“内战中”的铺垫阶段不显示，战争结束后也随 is_going 消失。
	return w.war_going(82) or w.war_going(83)


# ── 单条锚点生成 ──

func _make_entries(w: WorldState, key: String, war_id: int, war_name: String,
		side1: String, side2: String, infl1: int, infl2: int) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for anchor in _anchor_list(key):
		if not _anchor_condition_ok(w, anchor):
			continue
		var e := _make_entry_from_anchor(w, key, war_id, war_name, side1, side2, infl1, infl2, anchor)
		if not e.is_empty():
			out.append(e)
	if out.is_empty() and _anchor_list(key).is_empty():
		if not _missing_anchor_warned.has(key):
			_missing_anchor_warned[key] = true
			push_warning("战争图标管理: 战争 %s 缺少语义锚点，已跳过显示" % key)
	return out


func _make_entry_from_anchor(w: WorldState, key: String, war_id: int, war_name: String,
		side1: String, side2: String, infl1: int, infl2: int, anchor: Dictionary) -> Dictionary:
	var a_idx := int(anchor.get("a", -1))
	var b_idx := int(anchor.get("b", -1))
	if a_idx < 0:
		return {}
	var mode := String(anchor.get("mode", "midpoint"))
	# region 模式：a 为地图 region_id，直接取该地块中心（藏南/北爱尔兰等热点战争图标）。
	if mode == "region":
		var region_ll := _map_region_latlon(a_idx)
		if region_ll.x == INF or region_ll.y == INF:
			if GameManager != null and GameManager.is_map_data_preloaded:
				if not _missing_anchor_warned.has(key):
					_missing_anchor_warned[key] = true
					push_warning("战争图标管理: 战争 %s 缺少地块 %d 经纬度，已跳过显示" % [key, a_idx])
			return {}
		var priority_r := int(anchor.get("priority", 0))
		if priority_r <= 0:
			priority_r = maxi(infl1, infl2)
		return {
			"war_id": war_id,
			"name": war_name,
			"side1": side1,
			"side2": side2,
			"infl1": infl1,
			"infl2": infl2,
			"a_gw": 0,
			"b_gw": 0,
			"priority": priority_r,
			"group": _group_key(0, 0, war_id),
			"sphere_pos": _map_sphere_pos(region_ll),
		}
	var a_gw := _resolve_gw(w, a_idx, int(anchor.get("a_gw", 0)))
	var b_gw := _resolve_gw(w, b_idx, int(anchor.get("b_gw", 0))) if b_idx >= 0 else 0
	var a_ll := _map_centroid(a_gw)
	var b_ll := _map_centroid(b_gw) if b_gw > 0 else Vector2(INF, INF)
	var ll := _pick_ll(mode, a_ll, b_ll)
	if ll.x == INF or ll.y == INF:
		# 地图数据未就绪时静默跳过，避免 _ready 阶段误报；就绪后仍缺才警告。
		if GameManager != null and GameManager.is_map_data_preloaded:
			if not _missing_anchor_warned.has(key):
				_missing_anchor_warned[key] = true
				push_warning("战争图标管理: 战争 %s 参战国缺少地图地块，已跳过显示" % key)
		return {}
	var priority := int(anchor.get("priority", 0))
	if priority <= 0:
		priority = maxi(infl1, infl2)
	return {
		"war_id": war_id,
		"name": war_name,
		"side1": side1,
		"side2": side2,
		"infl1": infl1,
		"infl2": infl2,
		"a_gw": a_gw,
		"b_gw": b_gw,
		"priority": priority,
		"group": _group_key(a_gw, b_gw, war_id),
		"sphere_pos": _map_sphere_pos(ll),
	}


## 锚点级条件：目前用于“落日起战时朝鲜尚未统一才在朝韩边界显示”。
func _anchor_condition_ok(w: WorldState, anchor: Dictionary) -> bool:
	var when := String(anchor.get("when", ""))
	if when == "":
		return true
	match when:
		"korea_not_unified":
			var korea := w.get_country_by_legacy_index(10)
			if korea == null:
				return true
			return korea.parts.size() <= 0 or not korea.parts[0]
	return true


func _resolve_gw(w: WorldState, legacy_idx: int, override_gw: int) -> int:
	if override_gw > 0 and override_gw < 9000:
		return override_gw
	var c := w.get_country_by_legacy_index(legacy_idx)
	if c == null:
		return 0
	var gw := int(c.gwcode)
	if gw <= 0 or gw >= 9000:
		return 0
	return gw


func _map_centroid(gwcode: int) -> Vector2:
	if gwcode <= 0:
		return Vector2(INF, INF)
	var earth := get_parent()
	if earth != null and earth.has_method("country_centroid"):
		return earth.country_centroid(gwcode)
	return Vector2(INF, INF)


## 地块中心经纬度（region 锚点模式用；世界地图渲染提供 region_latlon）。
func _map_region_latlon(region_id: int) -> Vector2:
	var earth := get_parent()
	if earth != null and earth.has_method("region_latlon"):
		return earth.region_latlon(region_id)
	return Vector2(INF, INF)


func _map_sphere_pos(ll: Vector2) -> Vector3:
	var earth := get_parent()
	if earth != null and earth.has_method("latlon_to_sphere_pos"):
		return earth.latlon_to_sphere_pos(ll.x, ll.y, 0.501)
	# 兜底：与 世界地图渲染.region_id_at_3d 严格互逆的球面公式。
	var u := (ll.y + 180.0) / 360.0
	var v := (90.0 - ll.x) / 180.0
	var theta := (1.0 - v) * PI
	var phi := u * TAU
	return Vector3(
		sin(phi) * sin(theta),
		-cos(theta),
		cos(phi) * sin(theta)
	) * 0.501


func _pick_ll(mode: String, a_ll: Vector2, b_ll: Vector2) -> Vector2:
	match mode:
		"a":
			return a_ll
		"b":
			return b_ll
		"country":
			return a_ll
		_:
			if a_ll.x != INF and b_ll.x != INF:
				return (a_ll + b_ll) * 0.5
			return a_ll if a_ll.x != INF else b_ll


## 同参战国对 = 同组；内战国 = 该国独组；都没有地块 = 战争号兜底。
func _group_key(a_gw: int, b_gw: int, war_id: int) -> String:
	if a_gw > 0 and b_gw > 0 and a_gw != b_gw:
		var low := mini(a_gw, b_gw)
		var high := maxi(a_gw, b_gw)
		return "pair:%d:%d" % [low, high]
	if a_gw > 0:
		return "country:%d" % a_gw
	return "war:%d" % war_id


## 同一组只保留 priority 最高的一场战争（同 priority 时保留 war_id 小者）。
func _aggregate_by_group(entries: Array[Dictionary]) -> Array[Dictionary]:
	var by_group: Dictionary = {}
	for e in entries:
		var g: String = e["group"]
		if not by_group.has(g):
			by_group[g] = e
			continue
		var old: Dictionary = by_group[g]
		if int(e["priority"]) > int(old["priority"]) \
				or (int(e["priority"]) == int(old["priority"]) and int(e["war_id"]) < int(old["war_id"])):
			by_group[g] = e
	var out: Array[Dictionary] = []
	for k in by_group:
		out.append(by_group[k])
	out.sort_custom(_sort_entries)
	return out


func _sort_entries(a: Dictionary, b: Dictionary) -> bool:
	var pa := int(a.get("priority", 0))
	var pb := int(b.get("priority", 0))
	if pa != pb:
		return pa > pb
	var wa := int(a.get("war_id", 9999))
	var wb := int(b.get("war_id", 9999))
	if wa != wb:
		return wa < wb
	return String(a.get("group", "")) < String(b.get("group", ""))


func _assign_slots(entries: Array[Dictionary]) -> void:
	_last_entries = entries
	_info_by_war.clear()
	_ensure_slots(entries.size())
	for i in _slots.size():
		var slot: Sprite3D = _slots[i]
		if i < entries.size():
			var info: Dictionary = entries[i]
			slot.display_entry(info)
			_info_by_war[int(info.get("war_id", -999))] = info
		else:
			slot.display_entry({})


# ── 槽信号转发 ──

func _on_slot_clicked(war_id: int) -> void:
	if _info_by_war.has(war_id):
		war_icon_clicked.emit(_info_by_war[war_id])
