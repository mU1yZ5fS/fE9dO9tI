extends Control

## 概览主逻辑：六 Tab BBCode + 激活修正列表。只读 WorldState。

const W = preload("res://数据脚本/world_state.gd")
const MODIFIER_ITEM := preload("res://场景/概览界面/修正模板.tscn")

const PANEL_KEYS: Array[String] = ["交易", "影响", "领土", "形势", "凝聚力", "盟友"]

var _panels: Dictionary = {}  # key -> RichTextLabel
var _buttons: Dictionary = {}  # key -> Button
var _list: VBoxContainer
var _current: String = "交易"


func _ready() -> void:
	_cache_nodes()
	_ensure_modifier_list()
	for key in PANEL_KEYS:
		var btn: Button = _buttons.get(key)
		if btn and not btn.pressed.is_connected(_on_tab_pressed):
			btn.pressed.connect(_on_tab_pressed.bind(key))
	if GameManager:
		if GameManager.has_signal("stats_changed") and not GameManager.stats_changed.is_connected(_refresh_all):
			GameManager.stats_changed.connect(_refresh_all)
		if not GameManager.date_changed.is_connected(_on_date):
			GameManager.date_changed.connect(_on_date)
		if not GameManager.world_state_loaded.is_connected(_refresh_all):
			GameManager.world_state_loaded.connect(_refresh_all)
	_show_tab("交易")
	_refresh_all()


func _on_date(_d: GameDate) -> void:
	_refresh_all()


func _cache_nodes() -> void:
	_panels = {
		"交易": $交易概览 as RichTextLabel,
		"影响": $影响概览 as RichTextLabel,
		"领土": $领土概览 as RichTextLabel,
		"形势": $形势概览 as RichTextLabel,
		"凝聚力": $凝聚力概览 as RichTextLabel,
		"盟友": $盟友概览 as RichTextLabel,
	}
	_buttons = {
		"交易": $显示交易概览 as Button,
		"影响": $显示影响概览 as Button,
		"领土": $显示领土概览 as Button,
		"形势": $显示形势概览 as Button,
		"凝聚力": $显示凝聚力概览 as Button,
		"盟友": $显示盟友概览 as Button,
	}


func _ensure_modifier_list() -> void:
	var host := $修正显示区域 as Control
	if host == null:
		return
	var scroll := host.get_node_or_null("ScrollContainer") as ScrollContainer
	if scroll == null:
		scroll = ScrollContainer.new()
		scroll.name = "ScrollContainer"
		scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
		scroll.offset_left = 0
		scroll.offset_top = 0
		scroll.offset_right = 0
		scroll.offset_bottom = 0
		host.add_child(scroll)
	_list = scroll.get_node_or_null("修正列表") as VBoxContainer
	if _list == null:
		_list = VBoxContainer.new()
		_list.name = "修正列表"
		_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(_list)


func _on_tab_pressed(key: String) -> void:
	音频总管.play_button_click_sound()
	_show_tab(key)
	_refresh_panel(key)


func _show_tab(key: String) -> void:
	_current = key
	for k in PANEL_KEYS:
		var rtl: RichTextLabel = _panels.get(k)
		if rtl:
			rtl.visible = (k == key)


func _refresh_all() -> void:
	if GameManager == null or GameManager.world == null:
		for k in PANEL_KEYS:
			var rtl: RichTextLabel = _panels.get(k)
			if rtl:
				rtl.text = "尚未开始游戏"
		_clear_modifiers()
		return
	GameManager.world.sync_economy()
	for k in PANEL_KEYS:
		_refresh_panel(k)
	_refresh_modifiers()


func _refresh_panel(key: String) -> void:
	var rtl: RichTextLabel = _panels.get(key)
	if rtl == null:
		return
	var w: WorldState = GameManager.world if GameManager else null
	if w == null:
		rtl.text = "尚未开始游戏"
		return
	match key:
		"交易":
			rtl.text = _build_trade(w)
		"影响":
			rtl.text = _build_influence(w)
		"领土":
			rtl.text = _build_territory(w)
		"形势":
			rtl.text = _build_situation(w)
		"凝聚力":
			rtl.text = _build_cohesion(w)
		"盟友":
			rtl.text = _build_allies(w)


func _h(title: String) -> String:
	return "[color=red][font_size=30]%s[/font_size][/color]\n" % title


func _f1(v: float) -> String:
	return "%.1f" % v


func _build_trade(w: WorldState) -> String:
	var d := w.数值表
	var income: int = d[W.I_INCOME] if d.size() > W.I_INCOME else 0
	var imports: int = d[W.I_IMPORT_NEEDS] if d.size() > W.I_IMPORT_NEEDS else 0
	var partners: int = d[W.I_TRADE_PARTNERS] if d.size() > W.I_TRADE_PARTNERS else 0
	var surplus: int = income - imports
	var s := _h("当前贸易数据")
	s += "出口规模（收入项）：\n%s\n" % _f1(float(income) / 10.0)
	s += "进口需求：\n%s\n\n" % _f1(float(imports) / 10.0)
	s += _h("差额")
	s += "出口 − 进口：\n%s\n" % _f1(float(surplus) / 10.0)
	s += "（双周结算时：顺差加预算/支持，逆差伤预算/支持/生活）\n"
	s += "贸易伙伴数：%d\n\n" % partners
	s += _h("世界市场参与")
	if partners <= 4:
		s += "封闭 / 伙伴偏少"
	elif partners > 12:
		s += "高度参与"
	else:
		s += "平衡主义"
	return s


func _build_influence(w: WorldState) -> String:
	var d := w.数值表
	var su: int = d[W.I_SOVIET_INFLUENCE] if d.size() > W.I_SOVIET_INFLUENCE else 0
	var us: int = d[W.I_USA_INFLUENCE] if d.size() > W.I_USA_INFLUENCE else 0
	var s := _h("全球影响")
	s += "[color=darkred][font_size=25]苏联的世界影响力:[/font_size][/color]\n%s\n" % _f1(float(su) / 10.0)
	s += "[color=darkblue][font_size=25]美国的世界影响力:[/font_size][/color]\n%s\n" % _f1(float(us) / 10.0)
	s += "影响美苏在第三世界的争夺结果\n\n"
	s += _h("苏联领导人")
	s += "列昂尼德·勃列日涅夫\n（领导人字段尚未接入数值表，显示开局默认）\n\n"
	s += _h("军备竞赛")
	s += "我们不参与军备竞赛"
	return s


func _build_territory(_w: WorldState) -> String:
	# data[62–67] 未移植：开局默认句
	var s := _h("中国大陆")
	s += "西藏是中国领土不可分割的一部分\n"
	s += "新疆是中国领土不可分割的一部分\n"
	s += "港澳地区被外国势力控制\n"
	s += "蒙古是亲苏的独立主权国家\n\n"
	s += _h("台湾地区")
	s += "中华民国-国民党统治\n（威权主义，少数国家承认）\n台湾岛屿：\n在国民党控制下\n\n"
	s += _h("藏南地区")
	s += "被印度实际控制，并未被我方承认"
	return s


func _build_situation(_w: WorldState) -> String:
	var s := _h("伊朗")
	s += "沙阿政权依然巩固\n\n"
	s += _h("阿富汗")
	s += "毛主义者力量：3.0\n人民派力量：0.2\n旗帜派力量：0.4\n（形势字段尚未接入，显示开局占位）\n\n"
	s += _h("美国总统")
	s += "杰拉尔德·福特"
	return s


func _build_cohesion(w: WorldState) -> String:
	var d := w.数值表
	var religion: int = d[W.I_RELIGION] if d.size() > W.I_RELIGION else 24
	var unity_raw: int = d[W.I_MANPOWER] if d.size() > W.I_MANPOWER else 0
	var pop: int = d[W.I_POPULATION] if d.size() > W.I_POPULATION else 0
	var worldview := _religion_label(religion)
	var s := _h("世界观瞻")
	s += "现状：\n%s（政策值 %d）\n\n" % [worldview, religion]
	s += "国家凝聚力（兵源/团结代理）：\n%s / 100.0\n\n" % _f1(float(unity_raw) / 10.0)
	s += _h("特殊影响")
	s += "无\n\n"
	s += _h("人口")
	s += "%s 百万\n" % _f1(float(pop) / 10.0)
	return s


func _religion_label(v: int) -> String:
	match v:
		24:
			return "反传统取向"
		25:
			return "支持无神论宣传"
		26:
			return "宗教活动受监督"
		27:
			return "政教分离"
		28:
			return "依靠传统"
		29:
			return "政教协定"
		_:
			return "多元一体理念"


func _build_allies(w: WorldState) -> String:
	## 仅正式对华军事同盟（okb）。亲中/对华贸易是倾向或贸易，不是联盟。
	## 开局 COUNTRY_ROWS 中 okb 全为 0 → 应显示「不属于任何联盟」。
	var names: Array[String] = []
	var pc := w.get_player_country()
	for c in w.countries:
		if c == null or c == pc:
			continue
		if not c.has_tag("okb"):
			continue
		var n: String = c.chinese_name if c.chinese_name != "" else c.name
		if n != "" and n not in names:
			names.append(n)
	var s := _h("中国人民的老朋友")
	if names.is_empty():
		s += "我们不属于任何联盟\n"
	else:
		for n in names:
			s += "· %s\n" % n
	return s


func _clear_modifiers() -> void:
	if _list == null:
		return
	while _list.get_child_count() > 0:
		var child := _list.get_child(0)
		_list.remove_child(child)
		child.free()


func _refresh_modifiers() -> void:
	_ensure_modifier_list()
	_clear_modifiers()
	var w: WorldState = GameManager.world
	if w == null or _list == null:
		return
	var any := false
	for slot in w.modifiers:
		if slot == null or not slot.is_active:
			continue
		any = true
		var id: int = slot.id
		var item := MODIFIER_ITEM.instantiate()
		_list.add_child(item)
		if item.has_method("setup"):
			item.setup(
				id,
				ModifierCatalog.name_zh(id),
				ModifierCatalog.effect_zh(id, w),
				ModifierCatalog.icon(id)
			)
	if not any:
		var empty := Label.new()
		empty.text = "当前无激活修正"
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_list.add_child(empty)
