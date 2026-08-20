extends GameUIBase

## 派系界面逻辑。
## 左栏: 6 大政策类别 + 5 个派系支持/禁止
## 中栏: 政体 + 路线 + 饼图 + 生育政策
## 右栏: 政策选项面板 + 条件说明 + 政策介绍

const W = preload("res://数据脚本/world_state.gd")

# 饼图/派系标签色，逐值对齐原版 Politic.unity Crushko._Col
const 派系颜色: Array[Color] = [
	Color(0.725, 0.008, 0.008),
	Color(0.588, 0.102, 0.984),
	Color(0.980, 0.337, 0.325),
	Color(0.0, 0.659, 0.043),
	Color(0.0, 0.502, 0.737),
	Color(0.368, 0.368, 0.368),
]

const 派系列表 := ["极左派", "保守派", "温和派", "改革派", "自由派"]

# num=this_number（原版 Doctrine_script 分支键）；slots=.tscn 面板内按钮节点名（场景顺序，
# 作定位槽用，文案由 _build_options 运行时覆盖）；政策介绍文案由 _policy_intro 按原版 fake_text 提供。
const 政策类别 := {
	"经济类型": {
		"idx": W.I_ECON_SYSTEM, "num": 16, "panel": "右栏经济类型",
		"slots": ["中央计划经济", "中式计划经济", "国家资本主义", "国控资本主义", "市场经济", "自由市场"],
	},
	"党政": {
		"idx": W.I_PARTY_SYSTEM, "num": 15, "panel": "右栏党政",
		"slots": ["无产阶级专政", "人民民主专政", "联合政府", "西式民主"],
	},
	"人权": {
		"idx": W.I_PRESS_POLICY, "num": 17, "panel": "右栏人权",
		"slots": ["舆论一律", "纪律约束", "自然限制", "多元自由"],
	},
	"国家体制": {
		"idx": W.I_TERRITORY, "num": 18, "panel": "右栏国家体制",
		"slots": ["单一制", "区域自治", "联邦制", "邦联制"],
	},
	"传统与宗教": {
		"idx": W.I_RELIGION, "num": 50, "panel": "右栏传统与宗教",
		"slots": ["文化革命", "国家无神论", "宗教管制", "世俗化", "尊崇传统", "政教协定"],
	},
	"军事力量": {
		"idx": W.I_MIL_DOCTRINE, "num": 51, "panel": "右栏军事力量",
		"slots": ["全民皆兵", "积极建军", "国防建设", "职业化军队"],
	},
}

const 生育政策名 := ["一胎制", "二胎制", "无限制"]

var _当前类别: String = ""


func _ready() -> void:
	if not GameManager:
		return
	# 标题 hover 文案对齐原版 Politic.unity OkoshkoScript.text_en（政体“国家体制”、路线“党的路线”、军力“军事力量”）
	for pair in [["政体类型", "国家体制"], ["政治路线类型", "党的路线"], ["军队力量", "军事力量"], ["军队力量背景图", "军事力量"]]:
		var tip_node := _find(pair[0])
		if tip_node is Control:
			tip_node.tooltip_text = pair[1]
	GameManager.world_state_loaded.connect(_refresh)
	GameManager.date_changed.connect(func(_d): _refresh())
	if not GameManager.stats_changed.is_connected(_refresh):
		GameManager.stats_changed.connect(_refresh)
	_ensure_pie_chart()
	for cat_name in 政策类别:
		var btn := _find(cat_name + "切换")
		if btn is Button:
			btn.pressed.connect(_on_policy_tab.bind(cat_name))
	# 选项按钮按 slot 位置接线（id/文案运行时由 _build_options 决定，点击/悬停时按位置解析）
	for cat_name in 政策类别:
		var slots: Array = 政策类别[cat_name]["slots"]
		for slot_idx in slots.size():
			var btn := _find(slots[slot_idx])
			if btn is Button:
				btn.pressed.connect(_on_policy_slot.bind(cat_name, slot_idx))
				btn.mouse_entered.connect(_on_policy_slot_hover.bind(cat_name, slot_idx))
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
	# 原版 Politic.unity 按钮：演讲(speechscript)、选举(ElectScript)、经济/军事同盟(ElectScript is_alliance)
	var elect_btn := _find("选举")
	if elect_btn is Button:
		elect_btn.pressed.connect(_on_manual_election)
	var speech_btn := _find("演讲")
	if speech_btn is Button:
		speech_btn.pressed.connect(_on_manual_speech)
	for pair in [["经济同盟", "economic_union"], ["军事同盟", "military_alliance"]]:
		var alliance_btn := _find(pair[0])
		if alliance_btn is Button:
			alliance_btn.pressed.connect(_on_alliance_event.bind(pair[1]))
	if GameManager.world != null:
		_refresh()


func _refresh() -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	# 原版 Politic.unity "Text (10)" 挂 Show_diplomacy_data_script num=22（guid f4a6debb…），
	# Repaint() 显示 data[22]/10 + "." + data[22]%10（Show_diplomacy_data_script.cs:346-363），
	# 即内部值 ÷10 保留 1 位小数；外交条件 data[22]>=500 即“50 军事实力”。
	_label("军队力量", "%.1f" % (w.数值表[W.I_ARMY] / 10.0))
	# 政体 = doctr[data[14]]（Politic_doctr_script doctr=14，非 party_line）
	_label("政体类型", FactionService.doctr_name(w, _raw(w, W.I_IDEOLOGY)))
	# 党的路线 = doctr[data[52]] + "\n" + doctr[data[54]]（doctr=52, party_line=true）
	_label("政治路线类型", "%s\n%s" % [
		FactionService.doctr_name(w, _raw(w, W.I_ECON_DISPLAY)),
		FactionService.doctr_name(w, _raw(w, W.I_POLITICAL_DISPLAY)),
	])
	# 派系列表标题随政党制度切换（原版 ElectScript.Repaint text_part，逐字含空格）
	var multi: bool = w.数值表[W.I_PARTY_SYSTEM] > 7
	_label("中共党内派系", " 中 共 党 内 派 系" if not multi else " 人 大 党 派 组 织")
	# 顶部按钮可用态：选举=多党制 且 本月尚未选举（原版 is_elect 月块复位）；
	# 同盟按事件自动触发条件；演讲一次性（原版 is_speech 永不复位）。
	# 演讲按钮在 派系.tscn 中 visible=false：开局 speech_done=true 且永不复位，
	# 该入口原版即永久锁定，项目选择直接隐藏；此处仍维护 disabled 兜底。
	var elect_btn := _find("选举") as Button
	if elect_btn:
		elect_btn.disabled = (not multi) or w.get_flag("manual_election_used") or GameManager.current_event_id != ""
	for pair in [["经济同盟", false], ["军事同盟", true]]:
		var alliance_btn := _find(pair[0]) as Button
		if alliance_btn:
			alliance_btn.disabled = not GameManager.can_manual_alliance(pair[1])
	var speech_btn := _find("演讲") as Button
	if speech_btn:
		speech_btn.disabled = w.get_flag("speech_done") or GameManager.current_event_id != ""
	# 满足现状者（I_SATISFIED）仅出现在饼图灰色扇区，不进左侧可互动派系列表
	for cat_name in 政策类别:
		var cat: Dictionary = 政策类别[cat_name]
		var current_val: int = _raw(w, int(cat["idx"]))
		_label(cat_name + "显示", FactionService.doctr_name(w, current_val))
	for i in mini(派系列表.size(), w.factions.size()):
		var f: FactionData = w.factions[i]
		var name_text: String = FactionData.FACTION_NAMES_MULTI[i] if multi else FactionData.FACTION_NAMES[i]
		var name_tip: String = FactionData.FACTION_NAMES_MULTI_TIP[i].replace("|", "\n") if multi else FactionData.FACTION_NAMES[i]
		var name_node := _find(派系列表[i])
		if name_node is Label:
			name_node.text = name_text
			name_node.tooltip_text = name_tip
			# 多党长名逐字含空格，缩一号字避免溢出固定行宽（原版 TextMesh 无裁剪，Godot 需按布局收束）
			name_node.add_theme_font_size_override("font_size", 22 if multi else 30)
		var sup := _find("支持" + 派系列表[i]) as TextureButton
		var ban := _find("禁止" + 派系列表[i]) as TextureButton
		if sup: sup.set_pressed_no_signal(f.is_ally)
		if ban: ban.set_pressed_no_signal(not f.is_enabled)
		# 原版 Party_ally_script.OnMouseEnter 中文 text_en 逐字；Party_zapret 中文恒为场景值“禁止”
		if sup:
			sup.tooltip_text = " 支 持" if not multi else " 同 盟"
		if ban:
			ban.tooltip_text = "禁止"
	var birth_val: int = _raw(w, W.I_BIRTH_POLICY)
	for i in 生育政策名.size():
		var btn := _find(生育政策名[i]) as Button
		# 原版按钮 this_number=1/2/3，UI 槽位 0/1/2 → +1 比较（ChildScript.ChangeColour）
		if btn: btn.set_pressed_no_signal((i + 1) == birth_val)
	var pie := _find("派系饼图") as Control
	if pie:
		pie.tooltip_text = FactionService.leading_tooltip(w)
		for child in pie.get_children():
			if child is Control:
				child.queue_redraw()
		pie.queue_redraw()
	if _当前类别 != "":
		_refresh_policy_panel(_当前类别)


## 派系席位百分比 hover 文案。逐字移植原版 leading_script.cs 中文块。
## 差异：is_konst_max 移植说明 → 多党“法定多数”行缺失（Godot 无该字段），其余逐字。
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
	chart.colors = 派系颜色
	host.add_child(chart)


class PieChart extends Control:
	var colors: Array[Color] = []
	func _draw() -> void:
		var w: WorldState = GameManager.world if GameManager else null
		if w == null:
			return
		var slices: Array[Dictionary] = []
		for i in mini(5, w.factions.size()):
			var f: FactionData = w.factions[i]
			if not f.is_enabled:
				continue
			var s: int = maxi(f.support, 0)
			if s > 0:
				slices.append({"value": s, "color": colors[i]})
		var satisfied: int = 0
		if w.数值表.size() > WorldState.I_SATISFIED:
			satisfied = maxi(w.数值表[WorldState.I_SATISFIED], 0)
		if satisfied > 0:
			slices.append({"value": satisfied, "color": colors[5]})
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
			# 黑色描边：沿扇区轮廓（圆心→弧→圆心）画闭合折线，分隔相邻派系并突出外缘
			var outline := pts.duplicate()
			outline.append(pts[0])
			draw_polyline(outline, Color.BLACK, 2.0, true)
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


func _refresh_policy_panel(cat_name: String) -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	var cat: Dictionary = 政策类别[cat_name]
	var cat_idx: int = int(cat["idx"])
	var current_val: int = _raw(w, cat_idx)
	var slots: Array = cat["slots"]
	# 运行时按状态位生成有序选项，填入位置槽；多余槽隐藏（对齐原版 num+1 个可见）
	var options := FactionService.build_options(w, int(cat["num"]))
	var first_other: int = -1
	for slot_idx in slots.size():
		var btn := _find(slots[slot_idx]) as Button
		if btn == null:
			continue
		if slot_idx >= options.size():
			btn.visible = false
			continue
		btn.visible = true
		var target_val: int = int(options[slot_idx]["id"])
		btn.text = String(options[slot_idx]["text"]).replace("\n", "")
		# 权威 4 条件检查在 GameManager，UI 只读结果（避免与实际切换判定漂移）
		var chk: Dictionary = GameManager.check_policy_change(cat_idx, target_val)
		var can_select: bool = chk["can"]
		btn.disabled = not can_select
		btn.modulate = Color.WHITE if can_select else Color(0.5, 0.5, 0.5)
		if target_val == current_val:
			btn.modulate = Color(1.0, 1.0, 0.6)
		elif first_other < 0:
			first_other = target_val
	# 常驻条件面板：默认对第一个非当前选项显示 4 条件（hover 具体选项时更新）
	if first_other >= 0:
		_label("右栏条件显示", _build_condition_text(cat_idx, first_other))


## slot 位置 → 当前该槽的政策 id（运行时由 _build_options 决定）。-1 = 槽为空。
func _slot_target(w: WorldState, cat_name: String, slot_idx: int) -> int:
	var options := FactionService.build_options(w, int(政策类别[cat_name]["num"]))
	if slot_idx < 0 or slot_idx >= options.size():
		return -1
	return int(options[slot_idx]["id"])


func _on_policy_slot(cat_name: String, slot_idx: int) -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	var target_val := _slot_target(w, cat_name, slot_idx)
	if target_val < 0:
		return
	if GameManager.change_policy(int(政策类别[cat_name]["idx"]), target_val):
		_refresh()


## 常驻 4 条件文案（原版 uslovie_text[0..3] 逐字，含空格排版）。
## 原版以 If 图标表示满足与否；Godot 用 [满足]/[未满足] 文字替代图标。
## 显示口径同原作：预算 |Δ|×5、党内团结 |Δ|×30（与判定阈值 ×50/×300 不同）。
func _build_condition_text(cat_idx: int, target_val: int) -> String:
	var w: WorldState = GameManager.world
	if w == null:
		return ""
	var current_val: int = _raw(w, cat_idx)
	var diff := absi(target_val - current_val)
	if diff == 0:
		return "当前政策"
	var chk: Dictionary = GameManager.check_policy_change(cat_idx, target_val)
	var t := " 预 算 中 的 资 金 ：%d  [%s]\n\n\n" % [diff * 5, "满足" if chk["budget_ok"] else "未满足"]
	t += " 党 内 团 结 度 高 于 ：%d  [%s]\n\n\n" % [diff * 30, "满足" if chk["party_ok"] else "未满足"]
	t += "%s  [%s]\n\n\n" % [chk["leading_text"], "满足" if chk["leading_ok"] else "未满足"]
	t += "%s  [%s]\n\n" % [_mao_cond_text(w, target_val), "满足" if chk["mao_ok"] else "未满足"]
	return t


## 第4条件文案（原版 Doctrine_button_script.cs:446-461 逐字，含空格）：
## modifies[6]激活且目标∈{9,14,15,22,23,28,29} 或 (19且res[444]≠0) → "毛主席正看着你！"；
## 否则毛已死(data[38]≥100)→"尚未建立"、毛在世→"毛主席已离世，起锚！"。
func _mao_cond_text(w: WorldState, target_val: int) -> String:
	if FactionService.mod_active(w, 6) and (target_val in [9, 14, 15, 22, 23, 28, 29] \
			or (target_val == 19 and FactionService.event_result(w, 444) != 0)):
		return " 毛 主 席 正 看 着 你 ！"
	if GameManager.is_mao_dead():
		return " 尚 未 建 立"
	return " 毛 主 席 已 离 世 ， 起 锚 ！"


func _on_policy_slot_hover(cat_name: String, slot_idx: int) -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	var target_val := _slot_target(w, cat_name, slot_idx)
	if target_val < 0:
		return
	var cat: Dictionary = 政策类别[cat_name]
	var cat_idx: int = int(cat["idx"])
	_label("右栏条件显示", _build_condition_text(cat_idx, target_val))
	_label("右栏政策介绍文案", FactionService.policy_intro(w, target_val))


# ── 派系支持/禁止 ──
# tooltip 对齐原版中文口径（OkoshkoScript text_en）：
#   支持按钮 hover：一党制“ 支 持”，多党制“ 同 盟”（Party_ally_script.cs:130-156）
#   禁止按钮 hover：恒为场景值“禁止”（Party_zapret 只改俄文 text，中文显示 text_en 不变）
func _on_faction_support(button_pressed: bool, faction_idx: int, is_support: bool) -> void:
	if is_support:
		# 原版 Party_ally_script：一党制免费 toggle；多党制由 GameManager 按占比扣费结盟
		GameManager.set_faction_ally(faction_idx, button_pressed)
	else:
		# 原版 Party_zapret：禁止/解禁与费用/转移/强制复位全部在 GameManager
		GameManager.set_faction_enabled(faction_idx, not button_pressed)
	_refresh()


# ── 生育政策 ──

func _on_birth_policy(policy_idx: int) -> void:
	GameManager.set_birth_policy(policy_idx)
	_refresh()


# ── 选举 / 演讲 / 同盟按钮（原版 ElectScript / speechscript）──

func _on_manual_election() -> void:
	if GameManager.manual_election():
		_refresh()


func _on_manual_speech() -> void:
	if GameManager.manual_speech():
		_refresh()


func _on_alliance_event(event_id: String) -> void:
	var is_military: bool = event_id == "military_alliance"
	if not GameManager.can_manual_alliance(is_military):
		return
	GameManager.start_event(event_id)
