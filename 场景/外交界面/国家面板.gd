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
	_current_actions = _build_actions(country)

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


# ── 工具方法 ──

func _make_action(text: String, conditions: Array, effect_desc: String, effect: Callable) -> Dictionary:
	return {"text": text, "conditions": conditions, "effect_desc": effect_desc, "effect": effect}


func _cond(desc: String, check: Callable) -> Dictionary:
	return {"desc": desc, "check": check}
