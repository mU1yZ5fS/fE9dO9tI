extends GameUIBase

## 派系界面逻辑。
## 左栏: 6 大政策类别 + 5 个派系支持/禁止
## 中栏: 政体 + 路线 + 饼图 + 生育政策
## 右栏: 政策选项面板 + 条件说明 + 政策介绍

const W = preload("res://数据脚本/world_state.gd")

const 派系颜色 := [
	Color(0.72, 0.0, 0.0),
	Color(0.60, 0.0, 0.72),
	Color(1.0, 0.46, 0.75),
	Color(0.0, 0.54, 0.10),
	Color(0.28, 0.56, 0.89),
	Color(0.55, 0.55, 0.55),
]

const 派系列表 := ["极左派", "保守派", "温和派", "改革派", "自由派"]
const 政体名 := {0: "威权体制", 1: "社会主义", 2: "改良主义", 3: "自由民主"}
const 路线名 := {0: "毛主义路线", 1: "保守路线", 2: "温和路线", 3: "改革路线", 4: "自由路线"}

const 政策类别 := {
	"经济类型": {
		"idx": W.I_ECON_SYSTEM, "panel": "右栏经济类型",
		"options": {10: "中央计划经济", 11: "中式计划经济", 12: "国家资本主义",
					13: "国控资本主义", 14: "市场经济", 15: "自由市场"},
		"descriptions": {
			10: "苏联式中央计划经济。国家完全控制生产与分配。\n工业+2 农业-1 思想自由-2",
			11: "带有中国特色的计划经济。允许有限的地方自主权。\n工业+1 农业+1",
			12: "国家主导的资本主义体制。国企掌控命脉产业。\n工业+2 预算+1 腐败+1",
			13: "国家监管下的资本运行。鸟笼经济思想。\n工业+1 预算+1 生活水平+1",
			14: "混合所有制经济。市场与计划并存。\n生活水平+2 工业+1 腐败+1",
			15: "最小政府干预。完全自由化的市场经济。\n生活水平+3 腐败+2 党内支持-2",
		},
	},
	"党政": {
		"idx": W.I_PARTY_SYSTEM, "panel": "右栏党政",
		"options": {6: "无产阶级专政", 7: "人民民主专政", 8: "联合政府",
					9: "西式民主", 5: "公社"},
		"descriptions": {
			5: "公社制度。激进的基层民主。\n民众支持+2 党内支持-3 生活水平-2",
			6: "无产阶级专政。党的绝对领导。\n党内支持+2 思想自由-2",
			7: "人民民主专政。统一战线框架下的多党合作。\n党内支持+1 民众支持+1",
			8: "联合政府。多党制下的有限民主。\n民众支持+2 思想自由+1 党内支持-1",
			9: "西式多党民主。自由选举与权力交替。\n民众支持+3 思想自由+2 党内支持-3",
		},
	},
	"人权": {
		"idx": W.I_PRESS_POLICY, "panel": "右栏人权",
		"options": {16: "舆论一律", 17: "纪律约束", 18: "自然限制", 19: "多元自由"},
		"descriptions": {
			16: "严格的新闻与舆论管控。所有媒体服从党的指挥。\n党内支持+1 思想自由-3 特工网络+1",
			17: "党纪约束。维持基本纪律但允许内部讨论。\n党内支持+1 思想自由-1",
			18: "自然过渡。逐步放宽管制。\n思想自由+1 民众支持+1",
			19: "多元自由。允许不同声音。\n思想自由+3 民众支持+2 党内支持-2",
		},
	},
	"国家体制": {
		"idx": W.I_TERRITORY, "panel": "右栏国家体制",
		"options": {20: "单一制", 21: "联邦制", 22: "邦联制", 23: "区域自治"},
		"descriptions": {
			20: "中央集权的单一制国家。地方服从中央。\n党内支持+1 民众支持-1",
			21: "联邦制。各省拥有较大自主权。\n民众支持+1 国际声望+1",
			22: "松散邦联。各组成单位高度独立。\n民众支持+2 党内支持-1",
			23: "民族区域高度自治联盟。\n民众支持+2 党内支持-3 军力-1",
		},
	},
	"传统与宗教": {
		"idx": W.I_RELIGION, "panel": "右栏传统与宗教",
		"options": {24: "文化革命", 25: "国家无神论", 26: "宗教管制",
					27: "世俗化", 28: "尊崇传统", 29: "政教协定"},
		"descriptions": {
			24: "打击传统主义。消灭一切旧文化。\n党内支持+1 民众支持-3 思想自由-3",
			25: "支持无神论。宗教活动受到严格限制。\n党内支持+1 思想自由-1",
			26: "宗教监管。允许宗教存在但受国家监管。\n民众支持+1",
			27: "世俗国家。政教分离。\n思想自由+1 民众支持+1",
			28: "依赖传统。恢复儒学等传统文化。\n民众支持+2 国际声望+1",
			29: "政教协议。与宗教团体达成合作。\n民众支持+2 思想自由+1 党内支持-1",
		},
	},
	"军事力量": {
		"idx": W.I_MIL_DOCTRINE, "panel": "右栏军事力量",
		"options": {30: "全民皆兵", 31: "积极建军", 32: "国防建设", 33: "职业化军队"},
		"descriptions": {
			30: "全面军事化。最大化动员人口。\n兵力最多 预算消耗高",
			31: "建设军力。扩大常备军规模。\n兵力较多 预算消耗中",
			32: "防御军。以守为主。\n兵力适中 预算消耗低",
			33: "合同制军队。职业化精兵路线。\n兵力较少 战斗力高",
		},
	},
}

const COST_BUDGET_MULT := 50
const COST_PARTY_MULT := 300
const DEDUCT_BUDGET := 50
const DEDUCT_LIVING := 50
const DEDUCT_PARTY := 30

const 生育政策名 := ["一胎制", "二胎制", "无限制"]

var _当前类别: String = ""


func _ready() -> void:
	if not GameManager:
		return
	GameManager.world_state_loaded.connect(_refresh)
	GameManager.date_changed.connect(func(_d): _refresh())
	_ensure_pie_chart()
	for cat_name in 政策类别:
		var btn := _find(cat_name + "切换")
		if btn is Button:
			btn.pressed.connect(_on_policy_tab.bind(cat_name))
	for cat_name in 政策类别:
		var cat: Dictionary = 政策类别[cat_name]
		var opts: Dictionary = cat["options"]
		for val in opts:
			var opt_name: String = opts[val]
			var btn := _find(opt_name)
			if btn is Button:
				btn.pressed.connect(_on_policy_selected.bind(cat_name, int(val)))
				btn.mouse_entered.connect(_on_policy_hover.bind(cat_name, int(val)))
	for i in 派系列表.size():
		var sup := _find("支持" + 派系列表[i])
		var ban := _find("禁止" + 派系列表[i])
		if sup is TextureButton:
			sup.toggled.connect(_on_faction_support.bind(i, true))
		if ban is TextureButton:
			ban.toggled.connect(_on_faction_support.bind(i, false))
	for policy_name in 生育政策名:
		var btn := _find(policy_name)
		if btn is Button:
			btn.pressed.connect(_on_birth_policy.bind(生育政策名.find(policy_name)))
	var expand_btn := _find("右栏政策介绍展开")
	var collapse_btn := _find("右栏政策介绍收回")
	if expand_btn is TextureButton:
		expand_btn.pressed.connect(func(): _set_visible("右栏政策介绍", true))
	if collapse_btn is TextureButton:
		collapse_btn.pressed.connect(func(): _set_visible("右栏政策介绍", false))
	if GameManager.world != null:
		_refresh()


func _refresh() -> void:
	var w := GameManager.world
	if w == null:
		return
	_label("军队力量", "%d" % w.数值表[W.I_ARMY])
	var pc := w.get_player_country()
	_label("政体类型", 政体名.get(pc.government, "未知") if pc else "")
	_label("政治路线类型", 路线名.get(w.数值表[W.I_POLITICAL_LINE], "未知"))
	for cat_name in 政策类别:
		var cat: Dictionary = 政策类别[cat_name]
		var current_val: int = _raw(w, int(cat["idx"]))
		var opts: Dictionary = cat["options"]
		_label(cat_name + "显示", opts.get(current_val, "未知"))
	for i in mini(派系列表.size(), w.factions.size()):
		var f: FactionData = w.factions[i]
		var sup := _find("支持" + 派系列表[i]) as TextureButton
		var ban := _find("禁止" + 派系列表[i]) as TextureButton
		if sup: sup.set_pressed_no_signal(f.is_ally)
		if ban: ban.set_pressed_no_signal(not f.is_enabled)
	var birth_val: int = _raw(w, W.I_BIRTH_POLICY)
	for i in 生育政策名.size():
		var btn := _find(生育政策名[i]) as Button
		if btn: btn.set_pressed_no_signal(i == birth_val)
	var pie := _find("派系饼图") as Control
	if pie:
		for child in pie.get_children():
			if child is Control:
				child.queue_redraw()
		pie.queue_redraw()
	if _当前类别 != "":
		_refresh_policy_panel(_当前类别)


# ── 饼图（使用 _draw 避免每帧重建节点） ──

## 场景中的「派系饼图」是空 Control，需挂上可绘制的 PieChart 子节点
func _ensure_pie_chart() -> void:
	var host := _find("派系饼图") as Control
	if host == null:
		return
	for child in host.get_children():
		if child is PieChart:
			return
	var chart := PieChart.new()
	chart.name = "Chart"
	chart.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	chart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(chart)


class PieChart extends Control:
	func _draw() -> void:
		var w: WorldState = GameManager.world if GameManager else null
		if w == null:
			return
		var slices: Array[Dictionary] = []
		var 派系颜色_ref := [
			Color(0.72, 0.0, 0.0), Color(0.60, 0.0, 0.72),
			Color(1.0, 0.46, 0.75), Color(0.0, 0.54, 0.10),
			Color(0.28, 0.56, 0.89), Color(0.55, 0.55, 0.55),
		]
		for i in mini(5, w.factions.size()):
			var f: FactionData = w.factions[i]
			if not f.is_enabled:
				continue
			var s: int = maxi(f.support, 0)
			if s > 0:
				slices.append({"value": s, "color": 派系颜色_ref[i]})
		var satisfied: int = 0
		if w.数值表.size() > WorldState.I_SATISFIED:
			satisfied = maxi(w.数值表[WorldState.I_SATISFIED], 0)
		if satisfied > 0:
			slices.append({"value": satisfied, "color": 派系颜色_ref[5]})
		var total := 0
		for s in slices:
			total += s.value
		if total <= 0:
			return
		var center := size / 2.0
		var radius := minf(center.x, center.y) * 0.92
		if radius <= 1.0:
			return
		var start_angle := -PI / 2.0
		for s in slices:
			var sweep := float(s.value) / float(total) * TAU
			var pts := PackedVector2Array()
			pts.append(center)
			for seg in 33:
				var angle := start_angle + sweep * float(seg) / 32.0
				pts.append(center + Vector2(cos(angle), sin(angle)) * radius)
			draw_colored_polygon(pts, s.color)
			start_angle += sweep


# ── 政策面板 ──

func _on_policy_tab(cat_name: String) -> void:
	var toggling_off := (_当前类别 == cat_name)
	_当前类别 = "" if toggling_off else cat_name
	for cn in 政策类别:
		var pn: String = 政策类别[cn]["panel"]
		_set_visible(pn, cn == _当前类别)
	_set_visible("右栏条件显示", _当前类别 != "")
	if _当前类别 != "":
		_refresh_policy_panel(_当前类别)
	音频总管.play_button_click_sound()


func _refresh_policy_panel(cat_name: String) -> void:
	var w := GameManager.world
	if w == null:
		return
	var cat: Dictionary = 政策类别[cat_name]
	var cat_idx: int = int(cat["idx"])
	var current_val: int = _raw(w, cat_idx)
	var opts: Dictionary = cat["options"]
	for val in opts:
		var opt_name: String = opts[val]
		var btn := _find(opt_name) as Button
		if btn == null:
			continue
		var target_val: int = int(val)
		var can_select := _can_change_policy(w, current_val, target_val)
		btn.disabled = not can_select
		btn.modulate = Color.WHITE if can_select else Color(0.5, 0.5, 0.5)
		if target_val == current_val:
			btn.modulate = Color(1.0, 1.0, 0.6) if can_select else Color(0.6, 0.6, 0.3)


func _can_change_policy(w: WorldState, current: int, target: int) -> bool:
	if current == target:
		return true
	var diff := absi(target - current)
	var budget_need: int = diff * COST_BUDGET_MULT
	var party_need: int = diff * COST_PARTY_MULT
	var budget_have: int = w.数值表[W.I_BUDGET] + w.数值表[W.I_RESERVE]
	var party_have: int = w.数值表[W.I_PARTY_SUPPORT]
	return budget_have >= budget_need and party_have >= party_need


func _on_policy_selected(cat_name: String, target_val: int) -> void:
	if GameManager.change_policy(int(政策类别[cat_name]["idx"]), target_val):
		_refresh()
		音频总管.play_button_click_sound()


func _on_policy_hover(cat_name: String, target_val: int) -> void:
	var w := GameManager.world
	if w == null:
		return
	var cat: Dictionary = 政策类别[cat_name]
	var cat_idx: int = int(cat["idx"])
	var current_val: int = _raw(w, cat_idx)
	var diff := absi(target_val - current_val)
	var cond_text := ""
	if diff == 0:
		cond_text = "当前政策"
	else:
		var budget_need: int = diff * COST_BUDGET_MULT
		var party_need: int = diff * COST_PARTY_MULT
		var budget_have: int = w.数值表[W.I_BUDGET] + w.数值表[W.I_RESERVE]
		var party_have: int = w.数值表[W.I_PARTY_SUPPORT]
		cond_text = "预算需求：%.1f  [%s]\n" % [float(budget_need) / 10.0, "满足" if budget_have >= budget_need else "未满足"]
		cond_text += "党内支持需求：%.1f  [%s]\n" % [float(party_need) / 10.0, "满足" if party_have >= party_need else "未满足"]
		cond_text += "\n切换消耗：\n预算-%.1f  生活水平-%.1f  党内支持-%.1f" % [
			float(diff * DEDUCT_BUDGET) / 10.0,
			float(diff * DEDUCT_LIVING) / 10.0,
			float(diff * DEDUCT_PARTY) / 10.0,
		]
	_label("右栏条件显示", cond_text)
	var descs: Dictionary = cat.get("descriptions", {})
	_label("右栏政策介绍文案", descs.get(target_val, ""))


# ── 派系支持/禁止 ──

func _on_faction_support(button_pressed: bool, faction_idx: int, is_support: bool) -> void:
	if is_support:
		GameManager.set_faction_ally(faction_idx, button_pressed)
	else:
		GameManager.set_faction_enabled(faction_idx, not button_pressed)
	_refresh()


# ── 生育政策 ──

func _on_birth_policy(policy_idx: int) -> void:
	GameManager.set_birth_policy(policy_idx)
	_refresh()
	音频总管.play_button_click_sound()
