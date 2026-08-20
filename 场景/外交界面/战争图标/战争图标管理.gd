extends Node3D

## 战争图标管理 v3 —— 语义锚点 + 地图地块质心，槽位按需动态创建。
##
## 流程：
##   war_icon_anchors.json（战争号 → 参战国原版序号）→
##   用 CountryData.gwcode 找到地图国家 → 世界地图渲染.country_centroid() 求质心 →
##   世界地图渲染.latlon_to_sphere_pos() 转球面坐标 →
##   按 anchor pair 分组去重（同地多战争只留一个）→ 按需创建 Sprite3D 槽。
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
		if not GameManager.date_changed.is_connected(_on_date_changed):
			GameManager.date_changed.connect(_on_date_changed)
		if GameManager.has_signal("stats_changed") and not GameManager.stats_changed.is_connected(_refresh):
			GameManager.stats_changed.connect(_refresh)
	var earth := get_parent()
	if earth != null and earth.has_signal("map_data_ready") 			and not earth.map_data_ready.is_connected(_refresh):
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
	# v3：场景不再预置静态槽；仅兼容收集（若未来在编辑器里手摆槽仍可用）。
	_slots.clear()
	for child in get_children():
		if child is Sprite3D and child.has_method("display_entry"):
			var slot: Sprite3D = child
			if not slot.clicked.is_connected(_on_slot_clicked):
				slot.clicked.connect(_on_slot_clicked)
			_slots.append(slot)
	_slots.sort_custom(func(a: Node, b: Node) -> bool: return str(a.name) < str(b.name))


## 按需扩容槽位：entries 超出当前槽数时动态创建（v3 替代场景预置静态槽）。
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


func _build_entries(w: WorldState) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for i in w.wars.size():
		var war: WarData = w.wars[i]
		if war == null or not war.is_going:
			continue
		var entry := _make_entry(w, i, war.name_war, war.side1, war.side2,
				maxi(war.infl1, 0), maxi(war.infl2, 0))
		if not entry.is_empty():
			entries.append(entry)
	# 特殊状态图标（原版 special ogon）。
	if w.get_flag("iranrev"):
		var e := _make_entry(w, -1, "", "", "", 0, 0)
		if not e.is_empty():
			entries.append(e)
	if w.war_state == 2:
		var e := _make_entry(w, -2, "", "", "", 0, 0)
		if not e.is_empty():
			entries.append(e)
	if w.war_state == 1:
		var e := _make_entry(w, -3, "", "", "", 0, 0)
		if not e.is_empty():
			entries.append(e)
	if w.数值表.size() > 37 and w.数值表[37] > 0 and w.数值表[37] < 1000:
		var e := _make_entry(w, -4, "", "", "", 0, 0)
		if not e.is_empty():
			entries.append(e)
	return entries


func _make_entry(w: WorldState, war_id: int, war_name: String,
		side1: String, side2: String, infl1: int, infl2: int) -> Dictionary:
	var key := str(war_id)
	var anchor: Dictionary = _anchors.get(key, {})
	if anchor.is_empty():
		if not _missing_anchor_warned.has(key):
			_missing_anchor_warned[key] = true
			push_warning("战争图标管理: 战争 %s 缺少语义锚点，已跳过显示" % key)
		return {}
	var a_idx := int(anchor.get("a", -1))
	var b_idx := int(anchor.get("b", -1))
	if a_idx < 0:
		return {}
	var a_gw := _resolve_gw(w, a_idx, int(anchor.get("a_gw", 0)))
	var b_gw := _resolve_gw(w, b_idx, int(anchor.get("b_gw", 0))) if b_idx >= 0 else 0
	var a_ll := _map_centroid(a_gw)
	var b_ll := _map_centroid(b_gw) if b_gw > 0 else Vector2(INF, INF)
	var mode := String(anchor.get("mode", "midpoint"))
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
