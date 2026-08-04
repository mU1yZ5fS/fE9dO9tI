extends CanvasLayer

## 国家面板 — 点选地球上某国后显示，展示国家属性 + 可执行的外交互动。
## 节点结构（来自 外交.tscn 中 国家面板 子树）：
##   国家面板 (CanvasLayer, 本脚本, visible=false)
##     背景 (TextureRect)
##     关闭 (TextureButton)
##     当前选中国家名称 (Label)
##     国家属性背景 (TextureRect)
##     政府类型 (TextureRect)
##     军事联盟 (TextureRect)
##     经济联盟 (TextureRect)
##     在某国影响下 (TextureRect)
##     互动按钮 / 互动按钮2 / 互动按钮3 / 互动按钮4 (Button)
##     执行当前互动按钮所需条件及检查 (Label)

# ── 图标资源 ──

const W = preload("res://数据脚本/world_state.gd")

const GOV_ICONS := {
	0: preload("res://资产/UI/外交/政府类型_激进左翼.png"),
	1: preload("res://资产/UI/外交/政府类型_苏式社会主义.png"),
	2: preload("res://资产/UI/外交/政府类型_国控社会主义.png"),
	3: preload("res://资产/UI/外交/政府类型_社会民主主义.png"),
	4: preload("res://资产/UI/外交/政府类型_自由主义.png"),
}

const MIL_ALLIANCE_ICONS := {
	"ovd": preload("res://资产/UI/外交/军事联盟_华沙条约.png"),
	"nato": preload("res://资产/UI/外交/军事联盟_北约.png"),
}
const MIL_ALLIANCE_NAMES := {
	"ovd": "华沙条约", "nato": "北约", "okb": "OKB 军事联盟",
	"seato": "东南亚条约", "sento": "中央条约",
}

const ECON_ALLIANCE_ICONS := {
	"sev": preload("res://资产/UI/外交/经济联盟_经互会.png"),
}
const ECON_ALLIANCE_NAMES := {
	"sev": "经互会", "econ": "双边经济协定", "asean": "东盟",
	"eu": "欧共体", "soc_eu": "社会主义欧盟", "oil": "石油联盟",
}

const INFLUENCE_ICONS := {
	0: preload("res://资产/UI/外交/在某国影响下_美国.png"),
	1: preload("res://资产/UI/外交/在某国影响下_苏联.png"),
	2: preload("res://资产/UI/外交/在某国影响下_中国.png"),
}
const INFLUENCE_NAMES := {0: "美国", 1: "苏联", 2: "中国"}


# ── 外交互动定义 ──
# 每个互动：{id, text, conditions: [{desc, check: Callable}], effects: Callable}
# conditions 中每项 check 返回 true 表示满足

# ── 外交互动编号目录（移植自 DiploButtonScript）──
# 每个编号对应原版 this_type：Show()=条件, OnMouseDown()=效果。
# caption 来自 CountryScript.Show 的标签；opis 来自 DiploButtonScript.this_opis。
const DIPLO_BTN_TRADE9 := 9
const DIPLO_BTN_TRADE24 := 24
const DIPLO_BTN_ECON10 := 10
const DIPLO_BTN_MIL19 := 19
const DIPLO_BTN_MAOIST1 := 1
const DIPLO_BTN_RIM5000 := 5000
const DIPLO_BTN_AU5001 := 5001

var _current_country: CountryData
var _current_actions: Array[Dictionary] = []
var _buttons: Array[Button] = []


func _ready() -> void:
	visible = false
	_buttons = []
	for btn_name in ["互动按钮", "互动按钮2", "互动按钮3", "互动按钮4"]:
		var btn := find_child(btn_name, true, false)
		if btn is Button:
			_buttons.append(btn)

	# 关闭按钮
	var close_btn := find_child("关闭", true, false)
	if close_btn is TextureButton:
		close_btn.pressed.connect(_close)

	# 连接按钮点击
	for i in _buttons.size():
		_buttons[i].pressed.connect(_on_action_pressed.bind(i))
		_buttons[i].mouse_entered.connect(_on_action_hover.bind(i))
		_buttons[i].mouse_exited.connect(_on_action_unhover)

	# 连接地球选择信号
	var earth := get_parent().get_node_or_null("地球")
	if earth and earth.has_signal("country_selected"):
		earth.country_selected.connect(_on_country_selected)


func _on_country_selected(gwcode: int, country_name: String) -> void:
	if gwcode <= 0 or GameManager.world == null:
		_close()
		return

	var w := GameManager.world

	# 不为自己打开面板
	if gwcode == w.player_country_gwcode:
		_close()
		return

	var country := w.get_country_by_gwcode(gwcode)

	# 即使 WorldState 中无此国家数据，只要地图有名字也显示基本面板
	if country == null:
		_current_country = null
		_show_basic_panel(country_name)
		return

	_current_country = country
	_refresh(country, country_name)
	visible = true


func _close() -> void:
	visible = false
	_current_country = null


## 无 CountryData 时显示只有名字的基本面板
func _show_basic_panel(display_name: String) -> void:
	var name_label := find_child("当前选中国家名称", true, false) as Label
	if name_label:
		name_label.text = display_name if display_name != "" else "未知国家"
	for node_name in ["政府类型", "军事联盟", "经济联盟", "在某国影响下"]:
		var icon := find_child(node_name, true, false) as TextureRect
		if icon:
			icon.visible = false
	_current_actions.clear()
	for btn in _buttons:
		btn.visible = false
	_clear_condition_text()
	visible = true


# ── 刷新面板全部内容 ──

func _refresh(country: CountryData, display_name: String) -> void:
	# 国家名称（优先用 display_name 参数，回退到动态国名）
	var name_label := find_child("当前选中国家名称", true, false) as Label
	if name_label:
		name_label.text = country.display_name() if display_name == "" else display_name

	_refresh_icons(country)
	_refresh_actions(country)
	_clear_condition_text()


# ── 图标显示 ──

func _refresh_icons(country: CountryData) -> void:
	var gov_icon := find_child("政府类型", true, false) as TextureRect
	var mil_icon := find_child("军事联盟", true, false) as TextureRect
	var econ_icon := find_child("经济联盟", true, false) as TextureRect
	var inf_icon := find_child("在某国影响下", true, false) as TextureRect

	# 政府类型 + 意识形态
	if gov_icon:
		var tex: Texture2D = GOV_ICONS.get(country.government)
		if tex:
			gov_icon.texture = tex
			var gov_label: String = CountryData.GOV_NAME.get(country.government, "")
			var ideo_label: String = country.ideology_name()
			gov_icon.tooltip_text = "%s\n%s" % [gov_label, ideo_label]
			gov_icon.visible = true
		else:
			gov_icon.visible = false

	# 军事联盟
	if mil_icon:
		var found := false
		for tag in MIL_ALLIANCE_ICONS:
			if country.has_tag(tag):
				mil_icon.texture = MIL_ALLIANCE_ICONS[tag]
				mil_icon.tooltip_text = MIL_ALLIANCE_NAMES.get(tag, tag)
				mil_icon.visible = true
				found = true
				break
		if not found:
			for tag in MIL_ALLIANCE_NAMES:
				if country.has_tag(tag):
					mil_icon.tooltip_text = MIL_ALLIANCE_NAMES[tag]
					mil_icon.visible = true
					found = true
					break
		if not found:
			mil_icon.visible = false

	# 经济联盟
	if econ_icon:
		var found := false
		for tag in ECON_ALLIANCE_ICONS:
			if country.has_tag(tag):
				econ_icon.texture = ECON_ALLIANCE_ICONS[tag]
				econ_icon.tooltip_text = ECON_ALLIANCE_NAMES.get(tag, tag)
				econ_icon.visible = true
				found = true
				break
		if not found:
			for tag in ECON_ALLIANCE_NAMES:
				if country.has_tag(tag):
					econ_icon.tooltip_text = ECON_ALLIANCE_NAMES[tag]
					econ_icon.visible = true
					found = true
					break
		if not found:
			econ_icon.visible = false

	# 在某国影响下
	if inf_icon:
		var sphere := country.in_sphere_of_influence()
		var tex: Texture2D = INFLUENCE_ICONS.get(sphere)
		if tex:
			inf_icon.texture = tex
			inf_icon.tooltip_text = "在%s影响下" % INFLUENCE_NAMES.get(sphere, "")
			inf_icon.visible = true
		else:
			inf_icon.visible = false


# ── 互动按钮 ──

func _refresh_actions(country: CountryData) -> void:
	_current_actions = _build_actions_v2(country)

	for i in _buttons.size():
		if i < _current_actions.size():
			_buttons[i].text = _current_actions[i].text
			_buttons[i].visible = true
		else:
			_buttons[i].visible = false


func _on_action_pressed(index: int) -> void:
	if index >= _current_actions.size():
		return
	var action: Dictionary = _current_actions[index]
	var conditions: Array = action.get("conditions", [])
	for cond in conditions:
		if cond.has("check") and not cond.check.call():
			return
	if action.has("effect"):
		action.effect.call()
		# 外交互动可能直接改写 empires[].relations，立即钳制到合法区间
		if GameManager.world:
			GameManager.world.clamp_empire_relations()
	# 剧情外交操作会立即切入事件场景，不能再刷新即将离树的国家面板。
	if GameManager.current_event_id != "":
		return
	_refresh(_current_country, "")
	# 重新用国名刷新（名称保持不变）
	var name_label := find_child("当前选中国家名称", true, false) as Label
	if name_label and _current_country:
		_refresh(_current_country, name_label.text)


func _on_action_hover(index: int) -> void:
	if index >= _current_actions.size():
		return
	var action: Dictionary = _current_actions[index]
	var conditions: Array = action.get("conditions", [])
	var lines: PackedStringArray = []
	for cond in conditions:
		var met: bool = cond.check.call() if cond.has("check") else true
		lines.append("%s  [%s]" % [cond.get("desc", ""), "满足" if met else "未满足"])
	if action.has("effect_desc"):
		lines.append("\n效果：%s" % action.effect_desc)
	var label := find_child("执行当前互动按钮所需条件及检查", true, false) as Label
	if label:
		label.text = "\n".join(lines)


func _on_action_unhover() -> void:
	_clear_condition_text()


func _clear_condition_text() -> void:
	var label := find_child("执行当前互动按钮所需条件及检查", true, false) as Label
	if label:
		label.text = ""


# ============================================================================
# 外交互动构建 — 根据目标国家动态生成可用互动列表
# 移植自原版 CountryScript.ChineseButtons() + DiploButtonScript.ChineseInfo()
# ============================================================================

## [已弃用 2026-07-27] 手写近似互动，被 _build_actions_v2（编号目录驱动）取代。
## 保留供后续批次比对，勿在生产路径调用。
func _build_actions(country: CountryData) -> Array[Dictionary]:
	var w := GameManager.world
	if w == null:
		return []
	var d := w.数值表
	var actions: Array[Dictionary] = []
	var player := w.get_player_country()
	if player == null:
		return []
	# DiploButtonScript 的 27–32 号剧情操作必须排在普通互动前，避免四按钮截断。
	actions.append_array(_build_story_actions(country, w, d))

	var is_pro_china := country.has_tag("亲中")
	var is_pro_soviet := country.has_tag("亲苏") or country.has_tag("苏联盟友")
	var is_pro_usa := country.has_tag("亲美") or country.has_tag("美国盟友")
	var has_trade := country.has_tag("对华贸易")
	var in_sev := country.has_tag("sev")
	var in_ovd := country.has_tag("ovd")
	var in_nato := country.has_tag("nato")
	var in_okb := country.has_tag("okb")
	var in_econ := country.has_tag("econ")
	var player_in_sev := player.has_tag("sev")
	var _player_in_okb := player.has_tag("okb")

	# ── 超级大国特殊处理 ──

	# 苏联 (gwcode ~365, 原版序号=7)
	if country.原版序号 == 7:
		var restore_text := "延长友好条约" if _is_early_soviet_reconciliation(w) else "恢复中苏友好关系"
		actions.append(_make_action(restore_text, [
			_cond("不早于 1979 年", func(): return w.date != null and w.date.year >= 1979),
			_cond("党内支持与通信结构达到当前阶段门槛", func(): return _meets_soviet_reconciliation_threshold(w, d)),
			_cond("未挑起对越战争", func(): return w.get_flag("vietnam_peace")),
			_cond("对苏关系 ≥ 70", func(): return w.empires[1].relations >= 700 if w.empires.size() > 1 else false),
			_cond("尚未恢复关系", func(): return not w.get_flag("relres")),
		], "对苏关系 +5、对美关系 -5，解锁中苏和解事件分支",
		func():
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].relations += 50
				d[W.I_USSR_RELATIONS] = w.empires[EmpireData.USSR].relations
			if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
				w.empires[EmpireData.USA].relations -= 50
				d[W.I_USA_RELATIONS] = w.empires[EmpireData.USA].relations
			w.set_flag("relres", true)
			country.stability = 1
		))
		actions.append(_make_action("改善关系", [
			_cond("预算 ≥ 50", func(): return d[8] >= 50),
			_cond("国际声望 ≥ 30", func(): return d[6] >= 300),
		], "对苏关系 +10，预算 -50",
		func():
			if w.empires.size() > 1:
				w.empires[1].relations += 100
			d[8] -= 50
		))
		if not player_in_sev:
			actions.append(_make_action("申请经济合作", [
				_cond("对苏关系 ≥ 40", func(): return w.empires[1].relations >= 400 if w.empires.size() > 1 else false),
				_cond("预算 ≥ 100", func(): return d[8] >= 100),
			], "加入经互会",
			func():
				player.set_tag("sev", true)
				d[8] -= 100
			))
		if in_ovd and not player.has_tag("ovd"):
			actions.append(_make_action("华沙条约", [
				_cond("在经互会中", func(): return player_in_sev),
				_cond("对苏关系 ≥ 60", func(): return w.empires[1].relations >= 600 if w.empires.size() > 1 else false),
			], "加入华沙条约组织",
			func():
				player.set_tag("ovd", true)
			))
		actions.append(_make_action("请求技术转让", [
			_cond("对苏关系 ≥ 50", func(): return w.empires[1].relations >= 500 if w.empires.size() > 1 else false),
			_cond("科研 ≥ 20", func(): return d[11] >= 20),
		], "科研 +30，对苏关系 -5",
		func():
			d[11] += 30
			if w.empires.size() > 1:
				w.empires[1].relations -= 50
		))
		return actions

	# 美国 (gwcode ~2, 原版序号=51)
	if country.原版序号 == 51:
		actions.append(_make_action("发展关系", [
			_cond("预算 ≥ 50", func(): return d[8] >= 50),
			_cond("国际声望 ≥ 30", func(): return d[6] >= 300),
		], "对美关系 +10，预算 -50",
		func():
			if w.empires.size() > 0:
				w.empires[0].relations += 100
			d[8] -= 50
		))
		actions.append(_make_action("引进投资", [
			_cond("对美关系 ≥ 30", func(): return w.empires[0].relations >= 300 if w.empires.size() > 0 else false),
			_cond("经济体制 ≥ 国家资本主义", func(): return d[16] >= 12),
		], "预算 +80, 工业 +5, 对美关系 -3",
		func():
			d[8] += 80; d[12] += 5
			if w.empires.size() > 0:
				w.empires[0].relations -= 30
		))
		actions.append(_make_action("请求技术转让", [
			_cond("对美关系 ≥ 50", func(): return w.empires[0].relations >= 500 if w.empires.size() > 0 else false),
		], "科研 +30，对美关系 -5",
		func():
			d[11] += 30
			if w.empires.size() > 0:
				w.empires[0].relations -= 50
		))
		return actions

	# ── 一般国家 ──

	# 贸易
	if not has_trade:
		actions.append(_make_action("发展贸易", [
			_cond("预算 ≥ 30", func(): return d[8] >= 30),
			_cond("国际声望 ≥ 20", func(): return d[6] >= 200),
		], "建立对华贸易关系，预算 -30",
		func():
			country.set_tag("对华贸易", true)
			d[8] -= 30
		))
	else:
		# 已有贸易 → 经济联盟
		if not in_econ and not in_sev:
			actions.append(_make_action("经济联盟", [
				_cond("有对华贸易", func(): return has_trade),
				_cond("预算 ≥ 50", func(): return d[8] >= 50),
				_cond("目标国亲中", func(): return is_pro_china),
			], "纳入经济联盟，预算 -50",
			func():
				country.set_tag("econ", true)
				d[8] -= 50
			))

	# 军事联盟（需先有经济联盟）
	if (in_econ or in_sev) and not in_okb and is_pro_china:
		actions.append(_make_action("军事同盟", [
			_cond("目标国在经济联盟中", func(): return in_econ or in_sev),
			_cond("军力 ≥ 50", func(): return d[22] >= 50),
			_cond("国际声望 ≥ 40", func(): return d[6] >= 400),
		], "纳入军事联盟",
		func():
			country.set_tag("okb", true)
		))

	# 输出革命 / 煽动不安（针对非亲中国家）
	if not is_pro_china and not in_nato:
		if is_pro_soviet or is_pro_usa:
			actions.append(_make_action("煽动革命", [
				_cond("特工 ≥ 50", func(): return d[9] >= 50),
				_cond("预算 ≥ 40", func(): return d[8] >= 40),
			], "降低目标国稳定性，特工 -20，预算 -40",
			func():
				country.stability = maxi(0, country.stability - 15)
				d[9] -= 20; d[8] -= 40
			))
		else:
			actions.append(_make_action("争取影响", [
				_cond("预算 ≥ 30", func(): return d[8] >= 30),
				_cond("国际声望 ≥ 20", func(): return d[6] >= 200),
			], "增加中国在该国的影响力，预算 -30",
			func():
				country.prc_power += 10
				d[8] -= 30
			))

	# 援助亲中国家
	if is_pro_china:
		actions.append(_make_action("经济援助", [
			_cond("预算 ≥ 50", func(): return d[8] >= 50),
		], "提升目标国发展度与稳定性，预算 -50",
		func():
			country.development += 5
			country.stability = mini(100, country.stability + 10)
			d[8] -= 50
		))

	# 军事援助（亲中 + 在联盟中）
	if is_pro_china and (in_okb or in_econ):
		actions.append(_make_action("军事援助", [
			_cond("军力 ≥ 30", func(): return d[22] >= 30),
			_cond("预算 ≥ 40", func(): return d[8] >= 40),
		], "提升目标国军事实力，军力 -5，预算 -40",
		func():
			country.prc_power += 15
			d[22] -= 5; d[8] -= 40
		))

	# 确保最多返回4个
	if actions.size() > 4:
		actions.resize(4)
	return actions


## DiploButtonScript.cs:94-137：1979 年一季度沿用“延长条约”门槛，4 月起提高门槛。
func _is_early_soviet_reconciliation(w: WorldState) -> bool:
	return w.date != null and w.date.year == 1979 and w.date.month < 4


func _meets_soviet_reconciliation_threshold(w: WorldState, d: Array[int]) -> bool:
	if w.date == null or w.date.year < 1979 or w.leader == null:
		return false
	if _is_early_soviet_reconciliation(w):
		var special_leader := (
			w.leader.trait_personality == 0
			and w.leader.trait_alignment == 4
			and w.leader.trait_special == 8
		)
		if special_leader:
			return d[W.I_PARTY_SUPPORT] >= 900 and d[W.I_COMMUNICATIONS] >= 100
		return d[W.I_PARTY_SUPPORT] >= 700 and d[W.I_COMMUNICATIONS] >= 200
	return d[W.I_PARTY_SUPPORT] >= 900 and d[W.I_COMMUNICATIONS] >= 300


## 原作不是按时间自动扫描，而是玩家在指定国家面板点击后立即付费并进入事件。
func _build_story_actions(country: CountryData, w: WorldState, d: Array[int]) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	match country.原版序号:
		92, 87:  # 英国/葡萄牙：原 CountryScript 以欧洲特殊槽 0 展示该按钮
			actions.append(_make_action("谈判港澳回归", [
				_cond("特工网络 ≥ 20", func(): return d[W.I_AGENTS] >= 20),
				_cond("不早于 1980 年", func(): return w.date != null and w.date.year >= 1980),
				_cond("国际声望 < 700", func(): return d[W.I_DIPLO] < 700),
				_cond("尚未谈判", func(): return d[W.I_HK_MACAU_STATUS] == 0 and not w.get_flag("hk_macau_negotiated")),
			], "特工 -20，预算 -20；进入港澳安排事件",
			func():
				d[W.I_AGENTS] -= 20
				d[W.I_BUDGET] -= 20
				country.development = 1
				w.set_flag("hk_macau_negotiated", true)
				GameManager.start_event("hong_kong_macau")
			))
		9:  # 蒙古
			actions.append(_make_action("煽动温和改革抗议", [
				_cond("特工网络 ≥ 100", func(): return d[W.I_AGENTS] >= 100),
				_cond("预算 ≥ 50", func(): return d[W.I_BUDGET] >= 50),
				_cond("勃列日涅夫已经去世", func(): return d[W.I_SOVIET_SUCCESSION] > 0 or w.get_flag("brezhnev_dead")),
				_cond("尚未煽动", func(): return country.stability == 0),
			], "特工 -100，预算 -50，对苏关系 -100；进入蒙古改革事件",
			func():
				d[W.I_AGENTS] -= 100
				d[W.I_BUDGET] -= 50
				_add_story_relation(w, EmpireData.USSR, -100)
				country.stability = 1
				GameManager.start_event("mongolia_reform")
			))
		10:  # 朝鲜
			actions.append(_make_action("对朝鲜实施制裁", [
				_cond("尚未实施制裁", func(): return country.stability == 0),
				_cond("国际声望 < 500", func(): return d[W.I_DIPLO] < 500),
			], "进入对朝鲜施压事件",
			func():
				country.stability = 1
				GameManager.start_event("pressure_north_korea")
			))
		37:  # 以色列
			actions.append(_make_action("调停巴勒斯坦地位", [
				_cond("以色列在黎巴嫩战争中失败", func(): return w.get_flag("israel_lost_lebanon_war")),
				_cond("尚未谈判", func(): return country.development == 0),
			], "进入巴以安排事件",
			func():
				country.development = 1
				GameManager.start_event("palestine_settlement")
			))
		46:  # 韩国
			actions.append(_make_action("施加经济与政治压力", [
				_cond("越南、泰国、菲律宾与我国处于同一经济联盟",
					func(): return _countries_share_economic_union(w, [11, 34, 47])),
				_cond("特工网络 ≥ 40", func(): return d[W.I_AGENTS] >= 40),
				_cond("曾支援光州起义", func(): return w.get_flag("south_korea_gwangju_rebellion")),
				_cond("未处于朝鲜战争且尚未施压", func(): return not _war_active(w, 0) and country.stability == 0),
			], "特工 -40，对美关系 -100；进入韩国选举事件",
			func():
				d[W.I_AGENTS] -= 40
				_add_story_relation(w, EmpireData.USA, -100)
				country.stability = 1
				GameManager.start_event("south_korea_election")
			))
		50:  # 印度尼西亚
			actions.append(_make_action("制裁右翼独裁政权", [
				_cond("越南、泰国、马来西亚与我国处于同一经济联盟",
					func(): return _countries_share_economic_union(w, [11, 34, 49])),
				_cond("预算 ≥ 40", func(): return d[W.I_BUDGET] >= 40),
				_cond("尚未施压", func(): return country.stability == 0),
			], "预算 -40，对美关系 -50；进入印尼政权更替事件",
			func():
				d[W.I_BUDGET] -= 40
				_add_story_relation(w, EmpireData.USA, -50)
				country.stability = 1
				GameManager.start_event("indonesia_after_suharto")
			))
		19:  # 印度：逐月扶植东部纳萨尔派，累计触发原作 71 号事件
			actions.append(_make_action("支援印度东部毛派武装", [
				_cond("国际声望 > 790", func(): return d[W.I_DIPLO] > 790),
				_cond("特工网络 ≥ 30", func(): return d[W.I_AGENTS] >= 30),
				_cond("军力 ≥ 30", func(): return d[W.I_ARMY] >= 30),
				_cond("尚未与印度建立贸易关系", func(): return not country.has_tag("对华贸易")),
				_cond("本月尚未支援", func(): return country.stability == 0),
			], "纳萨尔派力量 +100、对苏关系 -50、军力 -30、特工 -30",
			func():
				d[W.I_NAXALITE_POWER] += 100
				d[W.I_ARMY] -= 30
				d[W.I_AGENTS] -= 30
				_add_story_relation(w, EmpireData.USSR, -50)
				country.stability = 1
			))
	return actions


func _countries_share_economic_union(w: WorldState, legacy_indices: Array[int]) -> bool:
	var all_econ := true
	var all_sev := true
	for legacy_index in legacy_indices:
		var target := w.get_country_by_legacy_index(legacy_index)
		if target == null:
			return false
		all_econ = all_econ and target.has_tag("econ")
		all_sev = all_sev and target.has_tag("sev")
	return all_econ or all_sev


func _war_active(w: WorldState, war_index: int) -> bool:
	return war_index >= 0 and war_index < w.wars.size() and w.wars[war_index] != null and w.wars[war_index].is_going


func _add_story_relation(w: WorldState, empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < w.empires.size():
		w.empires[empire_index].relations += delta


# ============================================================================
# 编号 9 · 发展贸易（深化经贸关系）
# DiploButtonScript Show L252-342 / OnMouseDown L8835
# ============================================================================
func _def_9(w: WorldState, d: Array[int], country: CountryData) -> Dictionary:
	var opis := "深化经贸关系"
	if country.原版序号 == 104:
		opis = "建立正式外交关系并深化经贸关系"
	var conds: Array = []
	# 条件1：声誉档（按目标国政体分档）— LeaderProperty[2] 未移植默认 false
	conds.append(_cond(_diplo_rep_desc(w, country), func(): return _diplo_rep_check(w, d, country)))
	# 条件2：尚未深化经贸（战乱国 34/109/110 的内战分支未移植 → 只做通用项）
	conds.append(_cond("尚未深化经贸关系", func(): return not country.has_tag("对华贸易")))
	# 条件3：工业档
	conds.append(_cond(_diplo_industry_desc(country), func(): return _diplo_industry_check(d, country)))
	# 按国专属分支未移植（首批略）：108法属附庸声誉档改写(DBS L288)、
	# 苏联入NATO时的第4条件(L328)、魁北克167不亲美第4条件(L335)。均属按国专属，后续批次。
	return {
		"caption": "发展贸易", "opis": opis, "conditions": conds, "dormant": false,
		"effect": func(): country.set_tag("对华贸易", true),
	}


## 声誉档描述（DBS Show L252-... 的 uslovie[0] 分档）
func _diplo_rep_desc(w: WorldState, country: CountryData) -> String:
	# LeaderProperty[2] 未移植默认 false → 跳过首档
	if w.is_authoritarian(country):
		return "外交声誉在 39 到 80 之间"
	if w.is_socialism(country, true):
		return "外交声誉高于 69"
	if country.government == 2:
		return "外交声誉在 39 到 85 之间"
	return "外交声誉低于 50"


func _diplo_rep_check(w: WorldState, d: Array[int], country: CountryData) -> bool:
	if w.is_authoritarian(country):
		return d[W.I_DIPLO] > 390 and d[W.I_DIPLO] < 800
	if w.is_socialism(country, true):
		return d[W.I_DIPLO] > 690
	if country.government == 2:
		return d[W.I_DIPLO] > 390 and d[W.I_DIPLO] < 850
	return d[W.I_DIPLO] < 500


## 工业档（编号9 的 uslovie[2]，DBS L...）
## 注：原版工业档还有"欧美列强集合→700"分支，属超级大国上下文，首批略。
func _diplo_industry_desc(country: CountryData) -> String:
	if country.has_tag("亲中"):
		return "工业不低于 30"
	return "工业不低于 50"


func _diplo_industry_check(d: Array[int], country: CountryData) -> bool:
	if country.has_tag("亲中"):
		return d[W.I_INDUSTRY] >= 300
	return d[W.I_INDUSTRY] >= 500


# ============================================================================
# 编号 24 · 发展贸易（变体）
# DiploButtonScript Show L778-837 / OnMouseDown L9039
# ============================================================================
func _def_24(w: WorldState, d: Array[int], country: CountryData) -> Dictionary:
	var conds: Array = []
	conds.append(_cond(_diplo_rep_desc(w, country), func(): return _diplo_rep_check(w, d, country)))
	conds.append(_cond("尚未深化经贸关系", func(): return not country.has_tag("对华贸易")))
	conds.append(_cond("工业不低于 70", func(): return d[W.I_INDUSTRY] >= 700))
	# uslovie[3] 未移植（按国专属，首批略）：原版在按钮条件层 DBS L816-836 有
	# 伊朗14 puppetOf!=8、东欧2-6·16 中国已入经互会 或 该国!prosov 的对苏排他，后续批次。
	return {
		"caption": "发展贸易", "opis": "深化经贸关系", "conditions": conds, "dormant": false,
		"effect": func(): country.set_tag("对华贸易", true),
	}


# ============================================================================
# 编号 10 · 经济合作
# DiploButtonScript Show L343-431 / OnMouseDown L8839-8855
# ============================================================================
func _def_10(w: WorldState, d: Array[int], country: CountryData) -> Dictionary:
	var player := w.get_player_country()
	var conds: Array = []
	# 条件1(uslovie[0])：已深化经贸 或 亲中（原版序号 9蒙古/35/14 有专属改写，未移植，走通用）
	conds.append(_cond("已深化经贸关系或该国持亲中立场",
		func(): return country.has_tag("对华贸易") or country.has_tag("亲中")))
	# 条件2(uslovie[1])：中国已建经合组织(econ) 或 已入经互会(sev)
	conds.append(_cond("中国已建立经合组织，或中国已加入经互会",
		func(): return player != null and (player.has_tag("sev") or player.has_tag("econ"))))
	# 条件3(uslovie[2])：目标国未加入任何经济组织
	conds.append(_cond("该国未加入经合组织",
		func(): return not country.has_tag("sev") and not country.has_tag("econ") and not country.has_tag("asean")))
	# uslovie[3] 未移植（按国专属，首批略）：不受美国(Vyshi/usalliance)、不受苏联(prosov/sovalliance且中国未入sev)、
	# 原版序号29不在北约欧共体、isSocEU、原版序号8的战事/声誉档 第4条件，见 DBS L366-430，后续批次。
	var eff := func():
		if player != null and player.has_tag("sev"):
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].power += 20
			w.influence_prc += 10
			country.set_tag("sev", true)
		else:
			d[W.I_PEOPLE_SUPPORT] += 20
			w.influence_prc += 20
			country.set_tag("econ", true)
			country.social_stability = 1000
			d[W.I_PARTY_SUPPORT] += 30
	return {
		"caption": "经济合作", "opis": "允许该国加入我国经济联盟，建立全面战略合作伙伴关系",
		"conditions": conds, "dormant": false, "effect": eff,
	}


# ============================================================================
# 编号 19 · 军事同盟
# DiploButtonScript Show L636-661 / OnMouseDown L8951-8976
# ============================================================================
func _def_19(w: WorldState, d: Array[int], country: CountryData) -> Dictionary:
	var player := w.get_player_country()
	var conds: Array = []
	# 原版 uslovie 赋值序为 [1],[3],[0],[2]；此处按可读顺序列出，条件为 AND 故顺序不影响判定
	conds.append(_cond("至少 2 军事实力", func(): return d[W.I_ARMY] >= 20))
	conds.append(_cond("外交声誉高于 79", func(): return d[W.I_DIPLO] > 790))
	conds.append(_cond("他们已加入经合组织或经互会",
		func(): return country.has_tag("sev") or country.has_tag("econ")))
	conds.append(_cond("他们未参与军事联盟，且中国已成立集安组织或已加入华约",
		func(): return _mil19_slot_check(w, player, country)))
	var eff := func():
		if player != null and player.has_tag("ovd"):
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].power += 20
			w.influence_prc += 10
			country.set_tag("ovd", true)
			if country.has_tag("亲中"):
				country.prc_influence = 500
			elif country.has_tag("亲苏"):
				country.sov_influence = 500
		else:
			w.influence_prc += 20
			country.set_tag("okb", true)
			if country.social_stability <= 0:
				country.social_stability = 1000
	return {
		"caption": "军事同盟", "opis": "邀请该国参与我国军事联盟，实现合作无上限，保障地区安全稳定",
		"conditions": conds, "dormant": false, "effect": eff,
	}


## 编号19 uslovie[2]：军事联盟排他（忠实 DBS Show L646-660）
## 非 oar 目标 → OVD/okb 排他式；oar 目标 → 仅当 allcountries[30] 为社会主义(Gosstroy==1) 才放行，否则封锁(!oar=false)
func _mil19_slot_check(w: WorldState, player: CountryData, country: CountryData) -> bool:
	if player == null:
		return false
	var via_ovd := not country.has_tag("ovd") and player.has_tag("ovd") and not country.has_tag("seato")
	var via_okb := not country.has_tag("okb") and player.has_tag("okb") and not country.has_tag("ovd") and not country.has_tag("seato")
	var complex := via_ovd or via_okb
	if not country.has_tag("oar"):
		return complex
	var c30 := w.get_country_by_legacy_index(30)
	if c30 != null and c30.government == 1:
		return complex
	return false


# ============================================================================
# 编号 1 · 扶持极左派（支持毛派组织）
# DiploButtonScript Show L54-73 / OnMouseDown L8622-8665
# 西欧 = 原版序号 ∈ {92,21,17}；否则东欧
# ============================================================================
func _def_1(w: WorldState, d: Array[int], country: CountryData) -> Dictionary:
	var player := w.get_player_country()
	var is_west := country.原版序号 == 92 or country.原版序号 == 21 or country.原版序号 == 17
	var conds: Array = []
	# uslovie[0]：特工≥50 且 预算+外汇≥30（DBS L58）
	conds.append(_cond("至少 5 特工网络和 3 百万预算",
		func(): return d[W.I_AGENTS] >= 50 and d[W.I_BUDGET] + d[W.I_RESERVE] >= 30))
	# uslovie[1]：modifies[6].active（DBS L60）
	conds.append(_cond("我们始终坚持伟大的毛泽东思想！",
		func(): return _modifier_active(w, 6)))
	# uslovie[2]：声誉>750（DBS L62）
	conds.append(_cond("外交声誉高于 75", func(): return d[W.I_DIPLO] > 750))
	# uslovie[3]：西欧读 war_active[0]，东欧读 war_active[1]（DBS L64-71，每年一次冷却）
	if is_west:
		conds.append(_cond("西欧：每年一次", func(): return not _war_active_flag(w, 0)))
	else:
		conds.append(_cond("东欧：每年一次", func(): return not _war_active_flag(w, 1)))
	var eff := func():
		if is_west:
			var usa := _empire(w, EmpireData.USA)
			if usa != null:
				var pen := 50
				if usa.current_leader == 3:
					pen = 75
				elif usa.current_leader == 5:
					pen = 100
				usa.power -= pen
				usa.relations -= 200
			_set_war_active(w, 0, true)
			if player != null and player.has_tag("rim"):
				w.influence_prc += 25
		else:
			# 原版怪异逻辑：读 empires[0](美).now_leader 却扣 empires[1](苏).power（忠实保留，八荣八耻①，DBS L8647-8654）
			var usa := _empire(w, EmpireData.USA)
			var ussr := _empire(w, EmpireData.USSR)
			var pen := 50
			if usa != null and usa.current_leader == 5:
				pen = 100
			if ussr != null:
				ussr.power -= pen
				ussr.relations -= 200
			_set_war_active(w, 1, true)
			# completedDecisions[9] 未移植 → influencePRC+=25 增益暂略（DBS L8657-8660）TODO
		d[W.I_AGENTS] -= 50
		d[W.I_BUDGET] -= 30
		d[W.I_ARMY] -= 50
	return {
		"caption": "扶持极左派", "opis": "支持毛派组织",
		"conditions": conds, "dormant": false, "effect": eff,
	}


func _empire(w: WorldState, idx: int) -> EmpireData:
	if idx >= 0 and idx < w.empires.size():
		return w.empires[idx]
	return null


func _modifier_active(w: WorldState, mod_id: int) -> bool:
	if mod_id >= 0 and mod_id < w.modifiers.size() and w.modifiers[mod_id] != null:
		return w.modifiers[mod_id].is_active
	return false


func _war_active_flag(w: WorldState, idx: int) -> bool:
	return idx >= 0 and idx < w.war_active.size() and w.war_active[idx]


func _set_war_active(w: WorldState, idx: int, value: bool) -> void:
	if idx >= 0 and idx < w.war_active.size():
		w.war_active[idx] = value


# 编号 5000 革命国际（休眠）：条件 DBS L5520-5538，效果 DBS L12585-12588。
# 休眠守卫 uslovie[0]=event_done[548]，事件未移植→get_flag 默认 false。
func _def_5000(w: WorldState, d: Array[int], country: CountryData) -> Dictionary:
	var player := w.get_player_country()
	var conds: Array = []
	# uslovie[0]：event_done[548]（DBS L5524，事件未移植）
	conds.append(_cond("已建立革命国际", func(): return w.get_flag("event_done_548")))
	# 列表级守卫（CS L550 等）：中国已入革命国际
	conds.append(_cond("中国已加入革命国际", func(): return player != null and player.has_tag("rim")))
	# uslovie[1]：非 gkchp 分支（DBS L5528，权威默认）。
	# TODO：gkchp 分支（DBS L5533 "该国愿意认可我们"，SubGosstroy∈{0,10,17,2}&&!SEV&&!OVD&&proprc）
	#       因 WorldState 未建模 is_gkchp，暂只移植非 gkchp 分支。
	conds.append(_cond("该国已建立革命的政权", func(): return _rim5000_regime_check(w, country)))
	# 列表级守卫（CS L550 等）：目标亲中；134/136 用 okb 变体，批3 各自分支处理
	conds.append(_cond("该国持亲中立场", func(): return country.has_tag("亲中")))
	# uslovie[2]：!isRIM（DBS L5536）
	conds.append(_cond("尚未加入", func(): return not country.has_tag("rim")))
	var eff := func():
		w.influence_prc += 50
		country.set_tag("rim", true)
	return {
		"caption": "革命国际",
		"opis": "邀请该国加入革命国际主义运动，为争得新世界而战！",
		"conditions": conds, "dormant": true, "effect": eff,
	}


# 编号 5000 uslovie[1] 非 gkchp 分支：IsSocialism(true) && SubGosstroy!=16 && !=18
# && !isSEV && !isOVD && !prosov（DBS L5528）。
func _rim5000_regime_check(w: WorldState, country: CountryData) -> bool:
	if country == null:
		return false
	return w.is_socialism(country, true) \
		and country.sub_government != 16 \
		and country.sub_government != 18 \
		and not country.has_tag("sev") \
		and not country.has_tag("ovd") \
		and not country.has_tag("亲苏")


# 编号 5001 非洲联盟（休眠）：条件 DBS L5539-5551，效果 DBS L12590-12593。
# 休眠守卫 uslovie[0]=event_done[500]，事件未移植→get_flag 默认 false。
func _def_5001(w: WorldState, d: Array[int], country: CountryData) -> Dictionary:
	var conds: Array = []
	# uslovie[0]：event_done[500]（DBS L5543，事件未移植）
	conds.append(_cond("非洲联盟已建立", func(): return w.get_flag("event_done_500")))
	# 列表级守卫（CS L2679 等）：目标社会主义 且 亲中
	conds.append(_cond("该国是社会主义政权", func(): return w.is_socialism(country, true)))
	conds.append(_cond("该国持亲中立场", func(): return country.has_tag("亲中")))
	# uslovie[1]：data[22]>=20（DBS L5545）
	conds.append(_cond("至少 2 军事实力", func(): return d[W.I_ARMY] >= 20))
	# uslovie[2]：!isAU（DBS L5547）
	conds.append(_cond("他们未加入非洲联盟", func(): return not country.has_tag("au")))
	# uslovie[3]：data[6]>790（DBS L5549）
	conds.append(_cond("外交声誉高于 79", func(): return d[W.I_DIPLO] > 790))
	var eff := func():
		w.influence_prc += 30
		country.set_tag("au", true)
	return {
		"caption": "非洲联盟",
		"opis": "邀请该国加入非洲联盟，投身于非洲革命与解放的伟大事业中",
		"conditions": conds, "dormant": true, "effect": eff,
	}


# 编号 → 定义分发（返回 {caption, opis, conditions, effect, dormant} 或 {}）。
func _diplo_action_def(编号: int, w: WorldState, d: Array[int], country: CountryData) -> Dictionary:
	match 编号:
		DIPLO_BTN_MAOIST1: return _def_1(w, d, country)
		DIPLO_BTN_TRADE9: return _def_9(w, d, country)
		DIPLO_BTN_ECON10: return _def_10(w, d, country)
		DIPLO_BTN_MIL19: return _def_19(w, d, country)
		DIPLO_BTN_TRADE24: return _def_24(w, d, country)
		DIPLO_BTN_RIM5000: return _def_5000(w, d, country)
		DIPLO_BTN_AU5001: return _def_5001(w, d, country)
	return {}


# ============================================================================
# 列表构建器 —— 按国序号逐国分发（忠实镜像 CountryScript 中文链 L495-3949）
# 结构：块J(隐藏) → match 逐国分支 → 块K(仅发展贸易)
# 已移植分支：2/4/5/6/98、109/110、113/114、122/124、133/135、155/158、167
# 其余分支(批3)未移植 → 走链尾块H(非洲区间) 或 无按钮（原版对无分支国不产按钮）
# ============================================================================
func _build_country_numbers(w: WorldState, country: CountryData) -> Array[int]:
	var player := w.get_player_country()
	if player == null:
		return []
	# 块J (CS L3934)：中国未入革命国际 且 目标已入 → 全部隐藏
	if not player.has_tag("rim") and country.has_tag("rim"):
		return []
	var nums := _chain_numbers(w, country)
	# 块K (CS L3942)：event_done[713] → 仅发展贸易(9)
	if _block_k_ok(w, country):
		return [DIPLO_BTN_TRADE9]
	return _truncate4(nums)


## 主链逐国分发（CS 中文链 L497-3929）
func _chain_numbers(w: WorldState, country: CountryData) -> Array[int]:
	var n := country.原版序号
	match n:
		2, 4, 5, 98:
			return _sev_satellite_numbers(w, country)
		6:
			return _six_numbers(w, country)
		109, 110:
			# CS L2664：无条件 9, 10
			return [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
		113:
			# CS L2729：分支头需 africaOff（非洲机制禁用）；未禁用则落入链尾块H
			if not country.禁用非洲机制:
				return _africa_block_numbers(w, country)
			return _au_rim_country_numbers(w, country, false)
		114:
			# CS L2751
			return _au_rim_country_numbers(w, country, false)
		122:
			# CS L2928：puppet<0 → 9 + [Gos∉{0,3}&&ev598&&!war53] 10,5001,5000；else → 9
			return _econ_gate_country_numbers(w, country, "event_done_598")
		124:
			# CS L3000：同上，ev581
			return _econ_gate_country_numbers(w, country, "event_done_581")
		133:
			# CS L3264：9,10 + [亲中] 5001(Gos==1)/5000
			return _x133_numbers(w, country)
		135:
			# CS L3316：9 + [!亲美] 10/19/5000
			return _x135_numbers(w, country)
		155, 158:
			# CS L3584/L3627：puppet<0 → 9+亲中尾；else → 9
			return _au_rim_country_numbers(w, country, true)
		167:
			# CS L3365：!NATO → 9 + [社会主义] 10,5000
			return _x167_numbers(w, country)
		71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83:
			# CS L2136 区间分支：82-88 全未移植 TODO；仅 80 有 revint 变体 5000
			if n == 80 and _revint_sub17_ok(w, country):
				return [DIPLO_BTN_RIM5000]
			return []
		84:
			# CS L2182：整支在 dlc[3] 内，dlc 未建模 → 无按钮 TODO
			return []
		85:
			# CS L2213：整支在 dlc[3] 内（cw/perevorot/ev481/ev398/ev401 均未建模）→ 无按钮 TODO
			return []
		86:
			# CS L2262：整支在 dlc[3] 内 → 无按钮 TODO
			return []
		87:
			# CS L2282：data[65] 未建模 → 按 !=0 走第二分支 TODO；
			# data65==0 的特别军事行动(2/3)未移植；128 未移植
			if country.has_tag("亲美") and country.government == 0:
				return []
			# !ev419 && !ev420（事件未移植→默认 true）→ 128(C)+9 → 只 9
			if not w.get_flag("event_done_419") and not w.get_flag("event_done_420"):
				return [DIPLO_BTN_TRADE9]
			var n87: Array[int] = [DIPLO_BTN_TRADE9]
			# Torg && (soc || (auth && !亲美 && 1.sub∈{7,9})) → 10 + [亲中]19 + [revint]5000
			var p87 := w.get_player_country()
			if country.has_tag("对华贸易") and (w.is_socialism(country, true) \
					or (w.is_authoritarian(country) and not country.has_tag("亲美") \
					and p87 != null and (p87.sub_government == 7 or p87.sub_government == 9))):
				n87.append(DIPLO_BTN_ECON10)
				if country.has_tag("亲中"):
					n87.append(DIPLO_BTN_MIL19)
					if _revint_ok(w, country):
						n87.append(DIPLO_BTN_RIM5000)
			return n87
		92:
			# CS L2325：data[65] 未建模 → 按 !=0 且 !auth 分支 TODO；
			# 2/3/113/1064-1066/10000 未移植
			if w.is_authoritarian(country):
				return []
			var n92: Array[int] = [DIPLO_BTN_TRADE9]
			# soc && Torg && sub!=18 → 10,19 + [revint]5000
			if w.is_socialism(country, true) and country.has_tag("对华贸易") and country.sub_government != 18:
				n92.append(DIPLO_BTN_ECON10)
				n92.append(DIPLO_BTN_MIL19)
				if _revint_ok(w, country):
					n92.append(DIPLO_BTN_RIM5000)
			return n92
		93:
			# CS L2391：整支在 dlc[3] 内（93/1002/1079/67 未移植）→ 无按钮 TODO
			return []
		94:
			# CS L2419：!cw（cw 未建模→视为真 TODO）→ 9；95/1075/1074/53 未移植
			var n94: Array[int] = [DIPLO_BTN_TRADE9]
			# revint && econ && !cw → 5000
			if _revint_ok(w, country) and country.has_tag("econ"):
				n94.append(DIPLO_BTN_RIM5000)
			return n94
		95:
			# CS L2443：整支在 dlc[3] 内（96/53 未移植）→ 无按钮 TODO
			return []
		139, 143, 144, 146, 148:
			# CS L2155 区间分支（145/147 有专属分支除外）：!亲中 → 1036(未移植 TODO)
			if not country.has_tag("亲中"):
				return []
			var n139: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if _revint_ok(w, country):
				n139.append(DIPLO_BTN_RIM5000)
			# TODO：139 的 70 巫术（1.sub==19，CS L2170）
			return n139
		36, 101, 102, 103, 105:
			# CS L2456 组（分支头需 modifies[51].active）
			# 组内 1023/1022/142-146/1079/67 未移植 TODO
			if not _modifier_active(w, 51):
				return []
			var n36: Array[int] = []
			# 101 且 !ev569 && !auth → 9,10（CS L2462）
			if n == 101 and not w.get_flag("event_done_569") and not w.is_authoritarian(country):
				n36.append(DIPLO_BTN_TRADE9)
				n36.append(DIPLO_BTN_ECON10)
			# 组内统一 revint → 5000（CS L2507）
			if _revint_ok(w, country):
				n36.append(DIPLO_BTN_RIM5000)
			return n36
		99:
			# CS L2512：based/ingamewars[26] 未建模 → 首分支恒真 TODO（proprc 分支原版即死分支）
			if country.puppet_of >= 0:
				return []
			var n99: Array[int] = []
			if _soc500_ok(w, country):
				n99.append(DIPLO_BTN_AU5001)
			if _revint_econ_ok(w, country):
				n99.append(DIPLO_BTN_RIM5000)
			return n99
		100:
			# CS L2544：based/ingamewars[25] 未建模 → 恒真 TODO
			# 原版 L2546 检查 99.puppetOf（原版笔误，忠实保留）
			var c99 := w.get_country_by_legacy_index(99)
			if c99 == null or c99.puppet_of >= 0:
				return []
			var n100: Array[int] = []
			if _soc500_ok(w, country):
				n100.append(DIPLO_BTN_AU5001)
			if _revint_econ_ok(w, country):
				n100.append(DIPLO_BTN_RIM5000)
			return n100
		104:
			# CS L2576：分支头需 dlc[3]，dlc 未建模 → 无按钮 TODO
			return []
		106:
			# CS L2600：亲中 → 10, [soc500]5001, 9, [revint-Torg]5000
			if not country.has_tag("亲中"):
				return []
			var n106: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n106.append(DIPLO_BTN_AU5001)
			n106.append(DIPLO_BTN_TRADE9)
			if _revint_torg_ok(w, country):
				n106.append(DIPLO_BTN_RIM5000)
			# TODO：1035 非洲之角 (41.parts&&41.sub==17, CS L2614)
			return n106
		107:
			# CS L2620：亲中 → 10, [soc500]5001, [revint]5000, 9
			if not country.has_tag("亲中"):
				return []  # 1053 革命左翼未移植 TODO
			var n107: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n107.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n107.append(DIPLO_BTN_RIM5000)
			n107.append(DIPLO_BTN_TRADE9)
			return n107
		108:
			# CS L2640：9 + [亲中] 10,5001,5000（1032/70 未移植 TODO）
			var n108: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				_append_au_rim_tail(n108, w, country)
			return n108
		119:
			# CS L2669：分支头需 africaOff；未禁用则落入链尾块H
			if not country.禁用非洲机制:
				return _africa_block_numbers(w, country)
			if country.sub_government == 9:
				return []
			# 1032 协助左派未移植 TODO
			var n119: Array[int] = []
			_append_au_rim_tail(n119, w, country)
			return n119
		123:
			# CS L2954：ev638/1047-1049/142-144/1080/70 未移植 TODO → 仅 9
			return [DIPLO_BTN_TRADE9]
		125:
			# CS L3026：puppet<0 → auth: 9(1032未移植) / !auth: 9,10 + 亲中尾
			if country.puppet_of >= 0:
				return []
			if w.is_authoritarian(country):
				return [DIPLO_BTN_TRADE9]  # 1032 施压未移植 TODO
			var n125: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			_append_rim_tail(n125, w, country)
			return n125
		126:
			# CS L3053：分支头需 ev623（未移植→恒 false）→ 无按钮 TODO
			return []
		127:
			# CS L3084：puppet<0 → 9 + [Gos∉{0,3}] 10 + 亲中尾（70 未移植 TODO）
			if country.puppet_of >= 0:
				return []
			var n127: Array[int] = [DIPLO_BTN_TRADE9]
			if country.government != 0 and country.government != 3:
				n127.append(DIPLO_BTN_ECON10)
				_append_rim_tail(n127, w, country)
			return n127
		129:
			# CS L3110：亲中 → 9,10,5001,5000；!亲中&&puppet<0&&sub!=7 → 9(1043-45未移植)
			if country.has_tag("亲中"):
				var n129: Array[int] = [DIPLO_BTN_TRADE9]
				_append_au_rim_tail(n129, w, country)
				return n129
			if country.puppet_of < 0 and country.sub_government != 7:
				return [DIPLO_BTN_TRADE9]
			return []  # sub==7 的 62-66 未移植 TODO
		130:
			# CS L3150：!cw(未建模→真) → 1038 未移植 TODO；cw 分支的 9,10,5001,5000 待 cw 建模
			return []
		131:
			# CS L3173：57 抗议运动(cw 未建模)未移植 TODO
			if country.sub_government == 9:
				return []
			var n131: Array[int] = []
			if country.sub_government != 7:
				n131.append(DIPLO_BTN_TRADE9)
			# cw 未建模(默认 false) → auth&&sub!=19 分支无输出且跳过 Gos!=3 else-if
			if not (w.is_authoritarian(country) and country.sub_government != 19) and country.government != 3:
				n131.append(DIPLO_BTN_ECON10)
				_append_rim_tail(n131, w, country)
			# TODO：70 博莱斯 (sub==19, CS L3207)
			return n131
		132:
			# CS L3213：9 + [puppet<0] 10 + 亲中尾（1037 未移植 TODO）
			var n132: Array[int] = [DIPLO_BTN_TRADE9]
			if country.puppet_of < 0:
				n132.append(DIPLO_BTN_ECON10)
				_append_rim_tail(n132, w, country)
			return n132
		153:
			# CS L3240：9 + [Gos!=2] 10 + 亲中尾（1039/1040 未移植 TODO）
			var n153: Array[int] = [DIPLO_BTN_TRADE9]
			if country.government != 2:
				n153.append(DIPLO_BTN_ECON10)
				_append_rim_tail(n153, w, country)
			return n153
		115:
			# CS L2773：sub==9 → 9+[亲中]10；sub!=9 → 9+亲中尾（1032/70 未移植 TODO）
			if country.sub_government == 9:
				if not country.has_tag("亲中"):
					return [DIPLO_BTN_TRADE9]
				return [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			var n115: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				_append_au_rim_tail(n115, w, country)
			return n115
		116:
			# CS L2819：9 + [!亲美&&puppet<0&&ev619] 10,5001,5000
			#（10 不受 proprc 门控；1024/1044/1032 未移植 TODO）
			var n116: Array[int] = [DIPLO_BTN_TRADE9]
			if not country.has_tag("亲美") and country.puppet_of < 0 and w.get_flag("event_done_619"):
				n116.append(DIPLO_BTN_ECON10)
				_append_rim_tail(n116, w, country)
			return n116
		117:
			# CS L2847：sub==9&&亲中 → 10,19；sub!=9 → 9+亲中尾（1041/1042/70 未移植 TODO）
			if country.sub_government == 9:
				if country.has_tag("亲中"):
					return [DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
				return []
			var n117: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				_append_au_rim_tail(n117, w, country)
			return n117
		118:
			# CS L2893：!ev659||ev661 → 9,10+亲中尾；否则 1057 未移植 TODO
			if w.get_flag("event_done_659") and not w.get_flag("event_done_661"):
				return []
			if not country.has_tag("亲中") or w.is_authoritarian(country):
				return []
			var n118: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			_append_rim_tail(n118, w, country)
			return n118
		134:
			# CS L3280：依赖 135/50 的政体与立场；1024/1025/1079 未移植 TODO
			var c135 := w.get_country_by_legacy_index(135)
			var c50 := w.get_country_by_legacy_index(50)
			var n134: Array[int] = []
			if c135 != null and (c135.has_tag("亲中") or c135.has_tag("亲苏")):
				n134.append(DIPLO_BTN_TRADE9)
				if country.puppet_of < 0:
					n134.append(DIPLO_BTN_ECON10)
					if c135.has_tag("亲中"):
						n134.append(DIPLO_BTN_MIL19)
						if _revint_okb_ok(w, country):
							n134.append(DIPLO_BTN_RIM5000)
			if c50 != null and w.is_socialism(c50, true) and (c135 == null or not c135.has_tag("亲美")):
				if country.puppet_of < 0:
					n134.append(DIPLO_BTN_ECON10)
					if country.has_tag("亲中"):
						n134.append(DIPLO_BTN_MIL19)
						if _revint_okb_ok(w, country):
							n134.append(DIPLO_BTN_RIM5000)
			return n134
		136:
			# CS L3335：9 + [!51.isNATO&&亲中] 10,19,[revint-okb]5000（1024 未移植 TODO）
			var c51 := w.get_country_by_legacy_index(51)
			var n136: Array[int] = [DIPLO_BTN_TRADE9]
			if c51 != null and not c51.has_tag("nato") and country.has_tag("亲中"):
				n136.append(DIPLO_BTN_ECON10)
				n136.append(DIPLO_BTN_MIL19)
				if _revint_okb_ok(w, country):
					n136.append(DIPLO_BTN_RIM5000)
			return n136
		137:
			# CS L3352：sub!=7 → 9,10（1076/1077 未移植 TODO）
			if country.sub_government == 7:
				return []
			return [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
		138:
			# CS L3380：!7.isNATO && !gkchp(未建模→真) → 亲中: 9,10,[revint]5000 / 否则 9
			# 49/1033/1034 未移植 TODO；cw&&(亲苏||亲美) 全隐藏 cw 未建模
			var c7 := w.get_country_by_legacy_index(7)
			if c7 != null and c7.has_tag("nato"):
				return []
			if country.has_tag("亲中"):
				var n138: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
				if _revint_ok(w, country):
					n138.append(DIPLO_BTN_RIM5000)
				return n138
			return [DIPLO_BTN_TRADE9]
		140:
			# CS L3417：亲中 → 9,10 + [revint]5000（1026/1027 未移植 TODO）
			if not country.has_tag("亲中"):
				return []
			var n140: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if _revint_ok(w, country):
				n140.append(DIPLO_BTN_RIM5000)
			return n140
		141:
			# CS L3434：parts 未建模(→else 分支) → 9,10 + [revint]5000（1062 未移植 TODO）
			var n141: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if _revint_ok(w, country):
				n141.append(DIPLO_BTN_RIM5000)
			return n141
		145:
			# CS L3450：cw 未建模 → !cw 分支(1028-1031) 未移植 TODO；cw 分支 10/5000 待 cw 建模
			return []
		147:
			# CS L3468：level_of_unstab 未建模(视为0) → !soc&&Gos!=2: 9 / 其余: 9+亲中尾
			# 1043/1044 未移植 TODO
			if not w.is_socialism(country, true) and country.government != 2:
				return [DIPLO_BTN_TRADE9]
			var n147: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				n147.append(DIPLO_BTN_ECON10)
				if _revint_ok(w, country):
					n147.append(DIPLO_BTN_RIM5000)
			return n147
		149:
			# CS L3499：同 147；parts/ingamewars[66] 未建模 → 1045 未移植 TODO
			if not w.is_socialism(country, true) and country.government != 2:
				return [DIPLO_BTN_TRADE9]
			var n149: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if _revint_ok(w, country):
				n149.append(DIPLO_BTN_RIM5000)
			return n149
		152:
			# CS L3536：!auth → 9；亲中&&!soc → 1032(未移植 TODO) → 只 9；亲中 → 10,[revint]5000
			# 49 邀请乐队未移植 TODO
			if w.is_authoritarian(country):
				return []
			if country.has_tag("亲中") and not w.is_socialism(country, true):
				return [DIPLO_BTN_TRADE9]
			var n152: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				n152.append(DIPLO_BTN_ECON10)
				if _revint_ok(w, country):
					n152.append(DIPLO_BTN_RIM5000)
			return n152
		154:
			# CS L3556：ev630 未建模(默认false) → 1032/1046 分支未移植 TODO
			if w.get_flag("event_done_630"):
				if country.puppet_of < 0:
					var n154: Array[int] = [DIPLO_BTN_TRADE9]
					if country.has_tag("亲中"):
						n154.append(DIPLO_BTN_ECON10)
						n154.append(DIPLO_BTN_MIL19)
						if _revint_okb_ok(w, country):
							n154.append(DIPLO_BTN_RIM5000)
					return n154  # 49 度假未移植 TODO
			return []
		157:
			# CS L3610：puppet<0 → 9,19 + [revint]5000（53 未移植 TODO）；else → 9
			if country.puppet_of >= 0:
				return [DIPLO_BTN_TRADE9]
			var n157: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_MIL19]
			if _revint_ok(w, country):
				n157.append(DIPLO_BTN_RIM5000)
			return n157
		159:
			# CS L3653：puppet<0 → 9 + [亲中] 10,19,[revint-okb]5000（1045 未移植 TODO）
			if country.puppet_of >= 0:
				return []  # 1043/1044 未移植 TODO
			var n159: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				n159.append(DIPLO_BTN_ECON10)
				n159.append(DIPLO_BTN_MIL19)
				if _revint_okb_ok(w, country):
					n159.append(DIPLO_BTN_RIM5000)
			return n159
		160:
			# CS L3675：亲中 → 10,19,[revint]5000（1050/1051 未移植 TODO）
			if not country.has_tag("亲中"):
				return []
			var n160: Array[int] = [DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			if _revint_ok(w, country):
				n160.append(DIPLO_BTN_RIM5000)
			return n160
		161:
			# CS L3692：同 160（1050/1051 未移植 TODO）
			if not country.has_tag("亲中"):
				return []
			var n161: Array[int] = [DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			if _revint_ok(w, country):
				n161.append(DIPLO_BTN_RIM5000)
			return n161
		29:
			# CS L3767 块B：data169/parts/FXSEU/NAZI 未建模 → 简化；1068 未移植 TODO
			if country.has_tag("soc_eu"):
				return []
			return [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
		166:
			# CS L3809 块C：1067 未移植 TODO
			return []
		12:
			# CS L805：9,19 + [revint]5000（68 未移植 TODO）
			var n12: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_MIL19]
			if _revint_ok(w, country):
				n12.append(DIPLO_BTN_RIM5000)
			return n12
		13:
			# CS L815：soc → 9,10,19 + [revint-okb&&亲中]5000；else 22/23 未移植 TODO
			if not w.is_socialism(country, true):
				return []
			var n13: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			if _revint_okb_ok(w, country) and country.has_tag("亲中"):
				n13.append(DIPLO_BTN_RIM5000)
			return n13
		14:
			# CS L841：133/1078/56/25/70/53/119/120/ev36 未移植 TODO
			# [sub==20&&puppet<0] 24；[亲中] 24,19 + [revint-okb&&puppet<0]5000；else 24,19
			var n14: Array[int] = []
			if country.sub_government == 20 and country.puppet_of < 0:
				n14.append(DIPLO_BTN_TRADE24)
			if country.has_tag("亲中"):
				n14.append(DIPLO_BTN_TRADE24)
				n14.append(DIPLO_BTN_MIL19)
				if _revint_okb_ok(w, country) and country.puppet_of < 0:
					n14.append(DIPLO_BTN_RIM5000)
			else:
				n14.append(DIPLO_BTN_TRADE24)
				n14.append(DIPLO_BTN_MIL19)
			return n14
		15:
			# CS L894：!7.NATO&&!2.okb&&!4.okb&&!5.okb&&!98.okb → 72/73 未移植 TODO
			# else → 10,19 + [revint-!亲苏]5000
			var c2 := w.get_country_by_legacy_index(2)
			var c4b := w.get_country_by_legacy_index(4)
			var c5 := w.get_country_by_legacy_index(5)
			var c98 := w.get_country_by_legacy_index(98)
			var n15: Array[int] = []
			var c7b := w.get_country_by_legacy_index(7)
			if not (c7b != null and c7b.has_tag("nato")) and not (c2 != null and c2.has_tag("okb")) \
					and not (c4b != null and c4b.has_tag("okb")) and not (c5 != null and c5.has_tag("okb")) \
					and not (c98 != null and c98.has_tag("okb")):
				return n15  # 72/73 不结盟运动未移植 TODO
			n15.append(DIPLO_BTN_ECON10)
			n15.append(DIPLO_BTN_MIL19)
			if _revint_noprosov_ok(w, country):
				n15.append(DIPLO_BTN_RIM5000)
			return n15
		16:
			# CS L926：dlc 未建模 → 非 dlc 分支 24（135/116 未移植 TODO）；
			# [proprc&&parts] 分支 parts 未建模 → 不触发 TODO
			return [DIPLO_BTN_TRADE24]
		17:
			# CS L950：parts 未建模(→真) → [!1.isASEAN] 1；116/137/138(dlc) 未移植 TODO
			var p17 := w.get_player_country()
			if p17 != null and not p17.has_tag("asean"):
				return [DIPLO_BTN_MAOIST1]
			return []
		18:
			# CS L986：整支在 dlc[3] 内 → 无按钮 TODO
			return []
		19:
			# CS L1002：ev72/resultOfEvents/completedDecisions[14] 未建模 → 首分支未移植 TODO
			# [亲中] → [!SEV&&!econ] 10 / else 19 + [revint sub17+econ+okb]5000
			if not country.has_tag("亲中"):
				return []
			var p19 := w.get_player_country()
			var n19: Array[int] = []
			if not country.has_tag("sev") and not country.has_tag("econ"):
				n19.append(DIPLO_BTN_ECON10)
			else:
				n19.append(DIPLO_BTN_MIL19)
			if w.get_flag("event_done_548") and p19 != null and p19.has_tag("rim") \
					and country.sub_government == 17 and not country.has_tag("sev") \
					and not country.has_tag("ovd") and country.has_tag("econ") \
					and country.has_tag("okb") and country.has_tag("亲中"):
				n19.append(DIPLO_BTN_RIM5000)
			return n19
		20:
			# CS L1037：parts 未建模(→真) → 19 + [revint]5000（31/32 未移植 TODO）
			var n20: Array[int] = [DIPLO_BTN_MIL19]
			if _revint_ok(w, country):
				n20.append(DIPLO_BTN_RIM5000)
			return n20
		21:
			# CS L1050：ev483 未建模 → else 分支；33/34/1009/1010/107 未移植 TODO
			var p21 := w.get_player_country()
			var n21: Array[int] = [DIPLO_BTN_TRADE24]
			# sub∈{17,22,19} || ((1.sub∈{7,9}) && sub==9) → 10,19
			if country.sub_government == 17 or country.sub_government == 22 or country.sub_government == 19 \
					or (p21 != null and (p21.sub_government == 7 or p21.sub_government == 9) and country.sub_government == 9):
				n21.append(DIPLO_BTN_ECON10)
				n21.append(DIPLO_BTN_MIL19)
				# revint 变体 (L1102): IsSocialism(true) && sub∉{1,18} && !SEV && !OVD && 亲中
				if _revint_core_ok(w, country) and country.sub_government != 1 \
						and country.sub_government != 18 and country.has_tag("亲中"):
					n21.append(DIPLO_BTN_RIM5000)
			return n21
		22:
			# CS L1108：1.isSEV&&puppet==11 → 24,10,19；else !ev454(未建模→真) → [puppet<0] 19 + [revint]5000
			var p22 := w.get_player_country()
			if p22 != null and p22.has_tag("sev") and country.puppet_of == 11:
				return [DIPLO_BTN_TRADE24, DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			# 35/36/126 未移植 TODO
			if country.puppet_of < 0:
				var n22: Array[int] = [DIPLO_BTN_MIL19]
				if _revint_ok(w, country):
					n22.append(DIPLO_BTN_RIM5000)
				return n22
			return []
		23:
			# CS L1137：分支头需 !prosov；24,10,19 + [revint]5000
			if country.has_tag("亲苏"):
				return []
			var n23: Array[int] = [DIPLO_BTN_TRADE24, DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			if _revint_ok(w, country):
				n23.append(DIPLO_BTN_RIM5000)
			return n23
		24, 25:
			# CS L1147：102/121 未移植 TODO；[亲中] 19 + [revint-okb&&亲中]5000（res437 视为 0）
			if not country.has_tag("亲中"):
				return []
			var n24: Array[int] = [DIPLO_BTN_MIL19]
			if _revint_okb_ok(w, country) and country.has_tag("亲中"):
				n24.append(DIPLO_BTN_RIM5000)
			return n24
		26:
			# CS L1175：based 未建模 → 1/123/148/149/53 分支不触发 TODO；
			# 主分支 [revint-okb&&亲中]5000（50 未移植 TODO）
			var n26: Array[int] = []
			if _revint_okb_ok(w, country) and country.has_tag("亲中"):
				n26.append(DIPLO_BTN_RIM5000)
			return n26
		30:
			# CS L1217：38/39 未移植 TODO；[24] + soc → 19 + [revint-okb&&亲中]5000
			var n30: Array[int] = [DIPLO_BTN_TRADE24]
			if w.is_socialism(country, true):
				n30.append(DIPLO_BTN_MIL19)
				if _revint_okb_ok(w, country) and country.has_tag("亲中"):
					n30.append(DIPLO_BTN_RIM5000)
			return n30
		31:
			# CS L1234：40/41 未移植 TODO；[revint]5000
			var n31: Array[int] = []
			if _revint_ok(w, country):
				n31.append(DIPLO_BTN_RIM5000)
			return n31
		32, 42:
			# CS L1243：puppet<0 → 10 + [32]19 + [revint]5000
			if country.puppet_of >= 0:
				return []
			var n32: Array[int] = [DIPLO_BTN_ECON10]
			if n == 32:
				n32.append(DIPLO_BTN_MIL19)
			if _revint_ok(w, country):
				n32.append(DIPLO_BTN_RIM5000)
			return n32
		33:
			# CS L1267：42/1061 未移植 TODO；亲中&&!1.isASEAN → 10,19 + [sub17 变体]5000
			var p33 := w.get_player_country()
			if not country.has_tag("亲中") or (p33 != null and p33.has_tag("asean")):
				return []
			var n33: Array[int] = [DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			if _revint_sub17_ok(w, country):
				n33.append(DIPLO_BTN_RIM5000)
			return n33
		34:
			# CS L1291：43/44 未移植 TODO；9,19 + [revint-okb&&亲中]5000
			var n34: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_MIL19]
			if _revint_okb_ok(w, country) and country.has_tag("亲中"):
				n34.append(DIPLO_BTN_RIM5000)
			return n34
		35:
			# CS L1302：ev564 未建模(→!ev564) → 1016 未移植 TODO
			return []
		37:
			# CS L1327：45/46 未移植 TODO；24,10,19 + [revint-okb&&亲中]5000
			var n37: Array[int] = [DIPLO_BTN_TRADE24, DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			if _revint_okb_ok(w, country) and country.has_tag("亲中"):
				n37.append(DIPLO_BTN_RIM5000)
			return n37
		38:
			# CS L1345：ev461 未建模 → 首分支 48/1005 未移植 TODO；
			# ev461&&亲中 → 10,19（119/120 未移植 TODO）
			if w.get_flag("event_done_461") and country.has_tag("亲中"):
				return [DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			return []
		39:
			# CS L1366：49/148/149/53 全未移植 TODO
			return []
		40:
			# CS L1395：sub==20 → 1019/1020 未移植 TODO；sub==10 → 9,10（ev563 未建模）
			if country.sub_government == 10:
				return [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			return []
		41:
			# CS L1435：ev403 未建模 → proprc 分支；101/110/111/70 未移植 TODO
			# [Gos==1||sub==0] → 10 + 5001(soc500) + [revint-无soc]5000；else → 10
			if not country.has_tag("亲中"):
				return []
			if country.government == 1 or country.sub_government == 0:
				var n41: Array[int] = [DIPLO_BTN_ECON10]
				if _soc500_ok(w, country):
					n41.append(DIPLO_BTN_AU5001)
				if _revint_nosoc_ok(w, country):
					n41.append(DIPLO_BTN_RIM5000)
				return n41
			return [DIPLO_BTN_ECON10]
		43, 96, 97:
			# CS L1476：puppet!=1 → 97/98/99 未移植 TODO；[revint]5000
			if country.puppet_of == 1:
				return []
			var n43: Array[int] = []
			if _revint_ok(w, country):
				n43.append(DIPLO_BTN_RIM5000)
			return n43
		44:
			# CS L1489：1014/51/52/1015/119 未移植 TODO；亲中&&!soc_eu → 19 + [revint-okb&&亲中]5000
			if not country.has_tag("亲中") or country.has_tag("soc_eu"):
				return []
			var n44: Array[int] = [DIPLO_BTN_MIL19]
			if _revint_okb_ok(w, country) and country.has_tag("亲中"):
				n44.append(DIPLO_BTN_RIM5000)
			return n44
		45:
			# CS L1531：!94.cw(未建模→真) 且 (war19||!auth 视为真) → 9；54 未移植 TODO
			# soc → 10 + [亲中] 19 + [revint]5000
			var n45: Array[int] = [DIPLO_BTN_TRADE9]
			if w.is_socialism(country, true):
				n45.append(DIPLO_BTN_ECON10)
				if country.has_tag("亲中"):
					n45.append(DIPLO_BTN_MIL19)
					if _revint_ok(w, country):
						n45.append(DIPLO_BTN_RIM5000)
			return n45
		46:
			# CS L1554：parts/ev31 → 55/1013/122 全未移植 TODO
			return []
		47:
			# CS L1583：!1.isASEAN → 56(未移植 TODO)+[revint]5000；9,19（44 未移植 TODO）
			var p47 := w.get_player_country()
			var n47: Array[int] = []
			if p47 == null or not p47.has_tag("asean"):
				if _revint_ok(w, country):
					n47.append(DIPLO_BTN_RIM5000)
			n47.append(DIPLO_BTN_TRADE9)
			n47.append(DIPLO_BTN_MIL19)
			return n47
		48:
			# CS L1597：9 + [Gos!=3] 10 + [revint]5000
			var n48: Array[int] = [DIPLO_BTN_TRADE9]
			if country.government != 3:
				n48.append(DIPLO_BTN_ECON10)
				if _revint_ok(w, country):
					n48.append(DIPLO_BTN_RIM5000)
			return n48
		52:
			# CS L1609：ev497||sub==0 → 24 + [res497!=2(视为真)] 10 + [亲中] 5001,5000
			if not w.get_flag("event_done_497") and country.sub_government != 0:
				return []
			var n52: Array[int] = [DIPLO_BTN_TRADE24]
			n52.append(DIPLO_BTN_ECON10)
			if country.has_tag("亲中"):
				_append_rim_tail(n52, w, country)
			return n52
		49:
			# CS L1631：24 + soc → 10 + [亲中] 19 + [revint]5000
			var n49: Array[int] = [DIPLO_BTN_TRADE24]
			if w.is_socialism(country, true):
				n49.append(DIPLO_BTN_ECON10)
				if country.has_tag("亲中"):
					n49.append(DIPLO_BTN_MIL19)
					if _revint_ok(w, country):
						n49.append(DIPLO_BTN_RIM5000)
			return n49
		50:
			# CS L1647：sub!=9 → 58(未移植 TODO) + [亲中] 10 + [soc] 19 + [revint-okb&&亲中]5000 + 24
			if country.sub_government == 9:
				return []
			var n50: Array[int] = [DIPLO_BTN_TRADE24]
			if country.has_tag("亲中"):
				n50.append(DIPLO_BTN_ECON10)
				if w.is_socialism(country, true):
					n50.append(DIPLO_BTN_MIL19)
					if _revint_okb_ok(w, country) and country.has_tag("亲中"):
						n50.append(DIPLO_BTN_RIM5000)
			return n50
		128:
			# CS L1667：soc → 10,19 + [revint]5000；24
			var n128: Array[int] = [DIPLO_BTN_TRADE24]
			if w.is_socialism(country, true):
				n128.append(DIPLO_BTN_ECON10)
				n128.append(DIPLO_BTN_MIL19)
				if _revint_ok(w, country):
					n128.append(DIPLO_BTN_RIM5000)
			return n128
		51:
			# CS L1695：!7.NATO && !modifies[49] → 60/34/61/75 全未移植 TODO
			return []
		53:
			# CS L1719：ev499 未建模(→false) → 1058-1060 未移植 TODO
			return []
		54:
			# CS L1778：9 + [auth&&!ev560(未建模→真)] → 1006/1007 未移植 TODO
			# else → 10 + [sub!=11&&Gos!=3] 19 + [revint-okb&&亲中]5000
			if w.is_authoritarian(country):
				return [DIPLO_BTN_TRADE9]
			var n54: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if country.sub_government != 11 and country.government != 3:
				n54.append(DIPLO_BTN_MIL19)
				if _revint_okb_ok(w, country) and country.has_tag("亲中"):
					n54.append(DIPLO_BTN_RIM5000)
			return n54
		55:
			# CS L1803：亲中 → 10,19 + [revint-okb]5000；else Gos==2 → 10（67 未移植 TODO）
			if country.has_tag("亲中"):
				var n55: Array[int] = [DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
				if _revint_okb_ok(w, country):
					n55.append(DIPLO_BTN_RIM5000)
				return n55
			if country.government == 2:
				return [DIPLO_BTN_ECON10]
			return []
		56:
			# CS L1828：亲中 → 10 + 5001(soc500) + [revint]5000；else 1024/1032 未移植 TODO
			if not country.has_tag("亲中"):
				return []
			var n56: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n56.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n56.append(DIPLO_BTN_RIM5000)
			return n56
		57:
			# CS L1852：亲中 → 10 + 5001(soc500) + [revint-puppet<0]5000；else 1056 未移植 TODO
			if not country.has_tag("亲中"):
				return []
			var n57: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n57.append(DIPLO_BTN_AU5001)
			if _revint_puppet_ok(w, country):
				n57.append(DIPLO_BTN_RIM5000)
			return n57
		58:
			# CS L1871：ev458 未建模(→false) → 1003 未移植 TODO；ev458&&亲中 → 10+5001+5000
			if not w.get_flag("event_done_458") or not country.has_tag("亲中"):
				return []
			var n58: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n58.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n58.append(DIPLO_BTN_RIM5000)
			return n58
		59:
			# CS L1897：soc → 9,10 + [亲中] 5001,5000；sub==10||Gos==2 → 9,10；else → 9
			#（1032/1043-1045 未移植 TODO）
			if w.is_socialism(country, true):
				var n59: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
				if country.has_tag("亲中"):
					_append_rim_tail(n59, w, country)
				return n59
			if country.sub_government == 10 or country.government == 2:
				return [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			return [DIPLO_BTN_TRADE9]
		60:
			# CS L1939：9 + 亲中 → 10,5001,5000（1054/1045 未移植 TODO）
			var n60: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				_append_au_rim_tail(n60, w, country)
			return n60
		61:
			# CS L1967：亲中&&puppet<0 → 10 + 5001(soc500) + [revint]5000
			if not country.has_tag("亲中") or country.puppet_of >= 0:
				return []
			var n61: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n61.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n61.append(DIPLO_BTN_RIM5000)
			return n61
		62:
			# CS L1982：亲中 → 10 + 5001(soc500) + [revint]5000
			if not country.has_tag("亲中"):
				return []
			var n62: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n62.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n62.append(DIPLO_BTN_RIM5000)
			return n62
		63:
			# CS L1997：分支头需 africaOff；亲中 → 10 + 5001(soc500) + [revint]5000
			if not country.禁用非洲机制:
				return _africa_block_numbers(w, country)
			if not country.has_tag("亲中"):
				return []
			var n63: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n63.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n63.append(DIPLO_BTN_RIM5000)
			return n63
		64:
			# CS L2012：亲中 → 10 + 5001(soc500) + [revint]5000；else 1032/data16 未移植 TODO
			if not country.has_tag("亲中"):
				return []
			var n64: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n64.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n64.append(DIPLO_BTN_RIM5000)
			return n64
		65:
			# CS L2035：puppet<0 → 9,10 + [亲中] 5001,5000（70 未移植 TODO）
			if country.puppet_of >= 0:
				return []
			var n65: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if country.has_tag("亲中"):
				_append_rim_tail(n65, w, country)
			return n65
		66:
			# CS L2058：ev617 未建模(→!ev617) → 9 + [sub==7] 1032(未移植 TODO)；
			# [亲中||res618==1] → 10 + 5001(soc500) + [revint]5000
			var n66: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				n66.append(DIPLO_BTN_ECON10)
				if _soc500_ok(w, country):
					n66.append(DIPLO_BTN_AU5001)
				if _revint_ok(w, country):
					n66.append(DIPLO_BTN_RIM5000)
			return n66
		68:
			# CS L2089：!亲美 → 9,10 + [亲中] 5001(soc500) + [revint-无proprc]5000；亲美 → 9
			if country.has_tag("亲美"):
				return [DIPLO_BTN_TRADE9]
			var n68: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if country.has_tag("亲中"):
				if _soc500_ok(w, country):
					n68.append(DIPLO_BTN_AU5001)
				if _revint_core_ok(w, country):
					n68.append(DIPLO_BTN_RIM5000)
			return n68
		150, 151:
			# CS L1748/L1763：ev499 未建模(→false) → 10/5001/5000 分支不触发 TODO
			return []
		_:
			# 未移植分支 → 链尾块H（非洲区间）或 无按钮
			var block := _africa_block_numbers(w, country)
			if not block.is_empty():
				return block
			return []


## 经互会卫星 2/4/5/98（CS L524-556/L557-588）
func _sev_satellite_numbers(w: WorldState, country: CountryData) -> Array[int]:
	var player := w.get_player_country()
	var n := country.原版序号
	var c4 := w.get_country_by_legacy_index(4)
	# L528：NATO 分支 → 103-106（未移植 TODO）；ingamewars[17] 未移植 → !war17 视为真
	if (player.has_tag("nato") and country.has_tag("ovd")) or (n != 4 and c4 != null and c4.sub_government == 19):
		return []
	# L535：!中国NATO && !中国SEV && 目标SEV → [1|123] + 24
	if not player.has_tag("sev") and country.has_tag("sev"):
		var nums: Array[int] = []
		if not player.has_tag("asean"):
			nums.append(DIPLO_BTN_MAOIST1)
		# else：123（CS L543，未移植 TODO）
		nums.append(DIPLO_BTN_TRADE24)
		return nums
	# L547 else：24 + [revint]5000
	var nums2: Array[int] = [DIPLO_BTN_TRADE24]
	if _revint_ok(w, country):
		nums2.append(DIPLO_BTN_RIM5000)
	return nums2


## 6（CS L590-623）：同卫星分支；else: 24 + [sub==17] 10,19,[revint6]5000
func _six_numbers(w: WorldState, country: CountryData) -> Array[int]:
	var player := w.get_player_country()
	var c4 := w.get_country_by_legacy_index(4)
	# L592：NATO 分支（注意 6 无 n!=4 豁免）→ 103-106（未移植 TODO）
	if (player.has_tag("nato") and country.has_tag("ovd")) or (c4 != null and c4.sub_government == 19):
		return []
	# L599：!中国SEV && 目标SEV → [1|123] + 24
	if not player.has_tag("sev") and country.has_tag("sev"):
		var nums: Array[int] = []
		if not player.has_tag("asean"):
			nums.append(DIPLO_BTN_MAOIST1)
		nums.append(DIPLO_BTN_TRADE24)
		return nums
	# L611 else：24 + [sub==17] 10,19,[revint6]5000
	var nums2: Array[int] = [DIPLO_BTN_TRADE24]
	if country.sub_government == 17:
		nums2.append(DIPLO_BTN_ECON10)
		nums2.append(DIPLO_BTN_MIL19)
		# L618：sub==17 变体（无 soc/sub 检查）
		if _revint_sub17_ok(w, country):
			nums2.append(DIPLO_BTN_RIM5000)
	return nums2


## 中非通用模板（CS L2731/L2753/L3586/L3629）：puppet<0 → 9 + 亲中尾；puppet 由 trade_if_puppet 决定
func _au_rim_country_numbers(w: WorldState, country: CountryData, trade_if_puppet: bool) -> Array[int]:
	if country.puppet_of >= 0:
		if trade_if_puppet:
			return [DIPLO_BTN_TRADE9]
		return []
	var nums: Array[int] = [DIPLO_BTN_TRADE9]
	_append_au_rim_tail(nums, w, country)
	return nums


## 事件门经济模板（CS L2930-2952/L3002-3024）：puppet<0 → 9 + [Gos∉{0,3}&&ev_flag] 10,5001,5000；else → 9
func _econ_gate_country_numbers(w: WorldState, country: CountryData, ev_flag: String) -> Array[int]:
	if country.puppet_of >= 0:
		return [DIPLO_BTN_TRADE9]
	var nums: Array[int] = [DIPLO_BTN_TRADE9]
	# TODO：ingamewars[53].is_going 未移植 → 视为无战争
	if country.government != 0 and country.government != 3 and w.get_flag(ev_flag):
		nums.append(DIPLO_BTN_ECON10)
		_append_rim_tail(nums, w, country)
	return nums


## 亲中尾段（CS L2734-2746 等）：[亲中] 10 + [soc500] 5001 + [revint] 5000
func _append_au_rim_tail(nums: Array[int], w: WorldState, country: CountryData) -> void:
	if not country.has_tag("亲中"):
		return
	nums.append(DIPLO_BTN_ECON10)
	_append_rim_tail(nums, w, country)


## 联盟尾段（CS L2938-2946 等）：[亲中] 5001(soc500) + 5000(revint)
func _append_rim_tail(nums: Array[int], w: WorldState, country: CountryData) -> void:
	if not country.has_tag("亲中"):
		return
	if _soc500_ok(w, country):
		nums.append(DIPLO_BTN_AU5001)
	if _revint_ok(w, country):
		nums.append(DIPLO_BTN_RIM5000)


## 133（CS L3264）：9,10 + [亲中] ([Gos==1&&ev500]5001 + [revint]5000)
func _x133_numbers(w: WorldState, country: CountryData) -> Array[int]:
	var nums: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
	if not country.has_tag("亲中"):
		return nums
	# TODO：原版 5001 守卫为 Gosstroy==1（非 IsSocialism）；resultOfEvents[500]==0 未移植
	if country.government == 1 and w.get_flag("event_done_500"):
		nums.append(DIPLO_BTN_AU5001)
	if _revint_ok(w, country):
		nums.append(DIPLO_BTN_RIM5000)
	return nums


## 135（CS L3316）：9 + [!亲美] ([亲中||Gos∉{0,3}]10 + [亲中]19 + [revint]5000)
func _x135_numbers(w: WorldState, country: CountryData) -> Array[int]:
	var nums: Array[int] = [DIPLO_BTN_TRADE9]
	if country.has_tag("亲美"):
		return nums
	if country.has_tag("亲中") or (country.government != 3 and country.government != 0):
		nums.append(DIPLO_BTN_ECON10)
	if country.has_tag("亲中"):
		nums.append(DIPLO_BTN_MIL19)
		if _revint_ok(w, country):
			nums.append(DIPLO_BTN_RIM5000)
	return nums


## 167（CS L3365）：!NATO → 9 + [社会主义] 10 + [revint]5000
func _x167_numbers(w: WorldState, country: CountryData) -> Array[int]:
	if country.has_tag("nato"):
		return []
	var nums: Array[int] = [DIPLO_BTN_TRADE9]
	if w.is_socialism(country, true):
		nums.append(DIPLO_BTN_ECON10)
		if _revint_ok(w, country):
			nums.append(DIPLO_BTN_RIM5000)
	return nums


## 链尾块H（CS L3914）：非洲区间+亲中+!africaOff → 10,[soc500]5001,[revint]5000
## TODO：66 资源开发区（CS L3925，data[103] 未移植）
func _africa_block_numbers(w: WorldState, country: CountryData) -> Array[int]:
	var n := country.原版序号
	var in_range := (n > 53 and n < 69) or (n > 105 and n < 109) or (n > 111 and n < 134) or n == 42
	if not in_range or n == 55 or n == 54 or n == 106:
		return []
	if not country.has_tag("亲中") or country.禁用非洲机制:
		return []
	var nums: Array[int] = [DIPLO_BTN_ECON10]
	if _soc500_ok(w, country):
		nums.append(DIPLO_BTN_AU5001)
	if _revint_ok(w, country):
		nums.append(DIPLO_BTN_RIM5000)
	return nums


## revint 列表级守卫（CS L550 等）：ev548 && 中国.isRIM && IsSocialism(true)
## && sub∉{16,18} && !SEV && !OVD && 亲中
## TODO：gkchp 变体 (sub==10&&is_gkchp，is_gkchp 未建模) 未移植
func _revint_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.has_tag("亲中")


## revint 公共部分（CS L550 等）：ev548 && 中国.isRIM && IsSocialism(true)
## && sub∉{16,18} && !SEV && !OVD
## TODO：gkchp 变体 (sub==10&&is_gkchp，is_gkchp 未建模) 未移植
func _revint_core_ok(w: WorldState, country: CountryData) -> bool:
	var player := w.get_player_country()
	if player == null:
		return false
	if not w.get_flag("event_done_548") or not player.has_tag("rim"):
		return false
	if not w.is_socialism(country, true) or country.sub_government == 16 or country.sub_government == 18:
		return false
	if country.has_tag("sev") or country.has_tag("ovd"):
		return false
	return true


## revint econ 变体（CS L2525/L2557）：末尾 econ 而非亲中
func _revint_econ_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.has_tag("econ")


## revint Torg 变体（CS L2610）：末尾 对华贸易 而非亲中
func _revint_torg_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.has_tag("对华贸易")


## revint okb 变体（CS L3292/L3344/L3575）：末尾 okb 而非亲中
func _revint_okb_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.has_tag("okb")


## revint !亲苏 变体（CS L920）：末尾 !prosov 而非亲中
func _revint_noprosov_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and not country.has_tag("亲苏")


## revint 无 IsSocialism 变体（CS L1461）：sub∉{16,18} && !SEV && !OVD && 亲中（无 soc 检查）
func _revint_nosoc_ok(w: WorldState, country: CountryData) -> bool:
	var player := w.get_player_country()
	if player == null:
		return false
	if not w.get_flag("event_done_548") or not player.has_tag("rim"):
		return false
	if country.sub_government == 16 or country.sub_government == 18:
		return false
	if country.has_tag("sev") or country.has_tag("ovd"):
		return false
	return country.has_tag("亲中")


## revint puppet<0 变体（CS L1861）：末尾 puppetOf<0 而非亲中
func _revint_puppet_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.puppet_of < 0


## revint sub==17 变体（CS L618/L2150）：ev548 && 中国.isRIM && sub==17 && !SEV && !OVD && 亲中
func _revint_sub17_ok(w: WorldState, country: CountryData) -> bool:
	var player := w.get_player_country()
	if player == null:
		return false
	return w.get_flag("event_done_548") and player.has_tag("rim") \
		and country.sub_government == 17 \
		and not country.has_tag("sev") and not country.has_tag("ovd") and country.has_tag("亲中")


## AU 列表级守卫（CS L2739 等）：IsSocialism(true) && ev500 && res==0
## TODO：resultOfEvents[500] 未移植，视为 0
func _soc500_ok(w: WorldState, country: CountryData) -> bool:
	return w.is_socialism(country, true) and w.get_flag("event_done_500")


## 块K（CS L3942）：ev713 && n!=1 && puppet<0 && IsSocialism(true) && sub∉{16,18}
## && !亲苏 && !亲美 && !SEV && !OVD && !NATO && !EU && !SEATO && !SENTO
func _block_k_ok(w: WorldState, country: CountryData) -> bool:
	if not w.get_flag("event_done_713") or country.原版序号 == 1:
		return false
	if country.puppet_of >= 0:
		return false
	if not w.is_socialism(country, true) or country.sub_government == 16 or country.sub_government == 18:
		return false
	if country.has_tag("亲苏") or country.has_tag("亲美") or country.has_tag("sev") \
			or country.has_tag("ovd") or country.has_tag("nato") or country.has_tag("eu") \
			or country.has_tag("seato") or country.has_tag("sento"):
		return false
	return true


func _truncate4(nums: Array[int]) -> Array[int]:
	if nums.size() > 4:
		nums.resize(4)
	return nums


# ============================================================================
# 组装当前国家的互动列表（新版：编号目录驱动）
# 结构对齐现有 _current_actions：{text, conditions, effect_desc, effect}
# ============================================================================
func _build_actions_v2(country: CountryData) -> Array[Dictionary]:
	var w := GameManager.world
	if w == null:
		return []
	var d := w.数值表
	var actions: Array[Dictionary] = []

	# 剧情专属操作优先（复用现有实现，不动）
	actions.append_array(_build_story_actions(country, w, d))

	# 通用编号动作
	for 编号 in _build_country_numbers(w, country):
		var def := _diplo_action_def(编号, w, d, country)
		if def.is_empty() or def.get("dormant", false):
			continue  # 休眠编号（5000/5001）过滤，不显示
		actions.append({
			"text": def["caption"],
			"conditions": def["conditions"],
			"effect_desc": def["opis"],
			"effect": def["effect"],
		})

	if actions.size() > 4:
		actions.resize(4)
	return actions


# ── 工具方法 ──

func _make_action(text: String, conditions: Array, effect_desc: String, effect: Callable) -> Dictionary:
	return {"text": text, "conditions": conditions, "effect_desc": effect_desc, "effect": effect}


func _cond(desc: String, check: Callable) -> Dictionary:
	return {"desc": desc, "check": check}
