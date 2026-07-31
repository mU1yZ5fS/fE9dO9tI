extends Control

## 概览主逻辑：六 Tab BBCode + 激活修正列表。只读 WorldState。

const W = preload("res://数据脚本/world_state.gd")
const MODIFIER_ITEM := preload("res://场景/概览界面/修正模板.tscn")

const PANEL_KEYS: Array[String] = ["交易", "影响", "领土", "形势", "凝聚力", "盟友"]

## 领导人英文名→中文显示（数据层存英文名 world_factory.gd:1002/1008；继任未移植时回退原名）
const 领导人中文名 := {
	"Leonid Brezhnev": "列昂尼德·勃列日涅夫",
	"Gerald Ford": "杰拉尔德·福特",
}

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


## 读帝国现任领导人姓名（原版 now_leader 索引 leaders[]）。越界/空则回退占位。
func _leader_name(empire: EmpireData, fallback: String) -> String:
	if empire == null:
		return fallback
	var idx: int = empire.current_leader
	if idx < 0 or idx >= empire.leaders.size():
		return fallback
	var leader: EmpireLeader = empire.leaders[idx]
	if leader == null or leader.leader_name == "":
		return fallback
	return 领导人中文名.get(leader.leader_name, leader.leader_name)


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
	# 三档标签对齐 modify_choose.cs；每两周效果对齐结算 _fortnight_trade_balance(game_manager.gd:2577-2582)
	if partners <= 4:
		var step := 5 - partners  # 结算：自由化/特工 -= -5+partners（即 +（5-partners））
		s += "孤立主义\n"
		s += "自由化思潮（每两周）：+%s\n" % _f1(float(step) / 10.0)
		s += "特工网络（每两周）：+%s\n" % _f1(float(step) / 10.0)
	elif partners > 12:
		var step := partners - 12
		s += "积极参与全球化\n"
		s += "自由化思潮（每两周）：+%s\n" % _f1(float(step) / 10.0)
		s += "特工网络（每两周）：-%s\n" % _f1(float(step) / 10.0)
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
	var ussr: EmpireData = w.empires[1] if w.empires.size() > 1 else null
	s += "%s\n" % _leader_name(ussr, "列昂尼德·勃列日涅夫")
	# 仅移植勃列日涅夫(current_leader==0)效果文案（modify_choose.cs:156-158）；
	# 其余 8 位继任分支依赖未移植的继任系统，暂不列出（见记忆 faction-dynamic-options-blocked）
	if ussr == null or ussr.current_leader == 0:
		s += "提升苏联的非洲干涉行动花费\n若中苏关系尚未解冻：\n与美国的关系 +0.5；凝聚力 -0.2\n"
	s += "\n"
	s += _h("军备竞赛")
	s += "我们不参与军备竞赛"
	return s


func _build_territory(w: WorldState) -> String:
	## 港澳/新疆/西藏 接 data[65/66/67]（modify_choose.cs 文案）。
	## 蒙古无 data 索引（由国家状态推导）、藏南/台湾涉未移植决议，暂留默认句。
	var d := w.数值表
	var s := _h("中国大陆")
	s += "%s\n" % _tibet_text(d[W.I_TIBET_POLICY] if d.size() > W.I_TIBET_POLICY else 0)
	s += "%s\n" % _xinjiang_text(d[W.I_XINJIANG_POLICY] if d.size() > W.I_XINJIANG_POLICY else 0)
	s += "%s\n" % _hk_macau_text(d[W.I_HK_MACAU_STATUS] if d.size() > W.I_HK_MACAU_STATUS else 0)
	s += "蒙古是亲苏的独立主权国家\n\n"
	s += _h("台湾地区")
	s += "中华民国-国民党统治\n（威权主义，少数国家承认）\n台湾岛屿：\n在国民党控制下\n\n"
	s += _h("藏南地区")
	s += "被印度实际控制，并未被我方承认"
	return s


## data[65] 港澳回归状态 → 文案（modify_choose.cs:791-805）
func _hk_macau_text(v: int) -> String:
	if v == 1:
		return "港澳是中国的特别行政区"
	elif v >= 2:
		return "港澳是中国领土不可分割的一部分"
	return "港澳地区被外国势力控制"


## data[66] 新疆文化政策状态 → 文案（modify_choose.cs:776-789）
func _xinjiang_text(v: int) -> String:
	if v == 1:
		return "新疆-苏联傀儡"
	elif v >= 2:
		return "维吾尔斯坦伊斯兰共和国-独立主权"
	return "新疆是中国领土不可分割的一部分"


## data[67] 西藏文化政策状态 → 文案（modify_choose.cs:764-774）
func _tibet_text(v: int) -> String:
	if v == 1:
		return "西藏共和国-独立主权"
	elif v >= 2:
		return "西藏共和国-独立主权；神权政治"
	return "西藏是中国领土不可分割的一部分"


func _build_situation(w: WorldState) -> String:
	## 伊朗/阿富汗各派为连续势力值（modify_choose.cs 按 data/10 显示，无离散档位文案）。
	## 定性局势文案原作挂 allcountries[8].SubGosstroy，Godot 未移植伊朗国家状态 → 暂以势力对比推导。
	var d := w.数值表
	var iran_left: int = d[W.I_IRAN_LEFT_SUPPORT] if d.size() > W.I_IRAN_LEFT_SUPPORT else 0
	var iran_shah: int = d[W.I_IRAN_SHAH_SUPPORT] if d.size() > W.I_IRAN_SHAH_SUPPORT else 0
	var s := _h("伊朗")
	s += "革命派力量：%s\n保皇派力量：%s\n" % [_f1(float(iran_left) / 10.0), _f1(float(iran_shah) / 10.0)]
	# Event58.cs:43 终局判据：革命派>保皇派 → 革命成功，否则沙阿续命
	s += "%s\n\n" % ("革命派势头压过王室" if iran_left > iran_shah else "沙阿政权占据上风")
	s += _h("阿富汗")
	var af_maoist: int = d[W.I_AFGHAN_OPPOSITION] if d.size() > W.I_AFGHAN_OPPOSITION else 0
	var af_khalq: int = d[W.I_AFGHAN_KHALQ] if d.size() > W.I_AFGHAN_KHALQ else 0
	var af_parcham: int = d[W.I_AFGHAN_PARCHAM] if d.size() > W.I_AFGHAN_PARCHAM else 0
	s += "毛主义者力量：%s\n人民派力量：%s\n旗帜派力量：%s\n\n" % [
		_f1(float(af_maoist) / 10.0), _f1(float(af_khalq) / 10.0), _f1(float(af_parcham) / 10.0),
	]
	s += _h("美国总统")
	var usa: EmpireData = w.empires[0] if w.empires.size() > 0 else null
	s += "%s" % _leader_name(usa, "杰拉尔德·福特")
	return s


func _build_cohesion(w: WorldState) -> String:
	## 世界观瞻读 data[31]（原作统一度/世界观；项目常量误名 I_WAR_SUPPORT）。
	## 档位/特殊影响对齐 modify_choose.cs:346-434 与结算 _fortnight_satisfaction_drift(game_manager.gd:2587-2602)。
	## 注：data[31] 周期更新逻辑未移植，运行时近乎恒为初值 500（多元一体档）。
	var d := w.数值表
	var unity_view: int = d[W.I_WAR_SUPPORT] if d.size() > W.I_WAR_SUPPORT else 500
	var unity_raw: int = d[W.I_MANPOWER] if d.size() > W.I_MANPOWER else 0
	var pop: int = d[W.I_POPULATION] if d.size() > W.I_POPULATION else 0
	var s := _h("世界观瞻")
	s += "现状：\n%s\n(%s/100)\n\n" % [_worldview_label(unity_view), _f1(float(unity_view) / 10.0)]
	s += "国家凝聚力（兵源/团结代理）：\n%s / 100.0\n\n" % _f1(float(unity_raw) / 10.0)
	s += _h("特殊影响")
	s += _worldview_effects(unity_view, d)
	s += _h("人口")
	s += "%s 百万\n" % _f1(float(pop) / 10.0)
	s += _population_effects(d, w)
	return s


## data[31] 统一度→世界观档位（modify_choose.cs:346-405）
func _worldview_label(v: int) -> String:
	if v > 700:
		return "完全的统一"
	elif v >= 400:
		return "多元一体理念"
	return "多元文化主义"


## 特殊影响：对齐双周漂移结算 _fortnight_satisfaction_drift(game_manager.gd:2587-2602)
func _worldview_effects(v: int, d: Array[int]) -> String:
	if v > 700:
		@warning_ignore("integer_division")
		var step := (v - 500) / 100  # 与结算 game_manager.gd:2590 整除逐位一致
		var s := "生活水平（每两周）：-%s\n" % _f1(float(step) / 10.0)
		s += "党内支持（每两周）：+%s\n" % _f1(float(step) / 10.0)
		s += "特工网络（每两周）：+%s\n" % _f1(float(step) / 10.0)
		if d.size() > W.I_DIPLO and d[W.I_DIPLO] < 500:
			s += "国际声望：+0.5（若低于 50.0）\n"
		return s + "\n"
	elif v < 400:
		@warning_ignore("integer_division")
		var step := (500 - v) / 100  # 与结算 game_manager.gd:2596 整除逐位一致
		var s := "自由化思潮（每两周）：+%s\n" % _f1(float(step) / 10.0)
		s += "党内支持（每两周）：+%s\n" % _f1(float(step) / 10.0)
		s += "特工网络（每两周）：+%s\n" % _f1(float(step) / 10.0)
		s += "与美/苏关系（每两周）：+%s\n" % _f1(float(step) / 10.0)
		return s + "\n"
	return "无\n\n"


## 人口规模对国家数值的效应预览。镜像项目实际结算（非原作显示公式）：
## 经济体制→工业/人民支持（月度 game_manager.gd:1765-1770）；军事学说→预算/军力（双周 game_manager.gd:2512-2538）。
## 仅列项目真实存在的项；原作 modify_choose.cs 的特工项(pop/200)与 econ13 项(9037/3000) 项目未移植，故不显示。
func _population_effects(d: Array[int], w: WorldState) -> String:
	var econ: int = d[W.I_ECON_SYSTEM] if d.size() > W.I_ECON_SYSTEM else 0
	var pop: int = d[W.I_POPULATION] if d.size() > W.I_POPULATION else 0
	var pop_excess: int = pop - 9307  # 与结算 game_manager.gd:2512 同基数
	var s := ""
	# 经济体制→工业/人民支持（月度）
	if econ == 10 or econ == 11:
		s += "工业（每月）：+%s\n" % _p10(pop, 5000)
	elif (econ == 14 or econ == 15) and not _modifier_is_active(w, 13):
		s += "人民支持（每月）：-%s\n" % _p10(pop, 4000)
	# 军事学说→预算/军力（双周，门槛与除数逐位对齐结算）
	match d[W.I_MIL_DOCTRINE] if d.size() > W.I_MIL_DOCTRINE else -1:
		30:
			if pop_excess > 99:
				s += "预算（每两周）：-%s\n" % _p10(pop_excess, 100)
				s += "军事实力（每两周）：+%s\n" % _p10(pop_excess, 100)
		31:
			if pop_excess > 199:
				s += "预算（每两周）：-%s\n" % _p10(pop_excess, 200)
				s += "军事实力（每两周）：+%s\n" % _p10(pop_excess, 200)
		32:
			if pop_excess > 299:
				s += "预算（每两周）：-%s\n" % _p10(pop_excess, 300)
				s += "军事实力（每两周）：+%s\n" % _p10(pop_excess, 300)
		33:
			if pop_excess > 149:
				var living: int = d[W.I_LIVING] if d.size() > W.I_LIVING else 0
				if living < 500:
					s += "预算（每两周）：-%s\n" % _p10(pop_excess, 150)
					s += "军事实力（每两周）：+%s\n" % _p10(pop_excess, 250)
				elif living < 700:
					s += "预算（每两周）：-%s\n" % _p10(pop_excess, 150)
					s += "军事实力（每两周）：+%s\n" % _p10(pop_excess, 300)
				else:
					s += "预算（每两周）：-%s\n" % _p10(pop_excess, 500)
					s += "军事实力（每两周）：+%s\n" % _p10(pop_excess, 500)
	if s == "":
		s = "当前人口规模无显著效应\n"
	return s


## ×10 空间效应值（a/b 的商）→ "X.X" 显示；整除对齐结算逐位一致。符号由调用处文案给定，此处取绝对值。
func _p10(a: int, b: int) -> String:
	@warning_ignore("integer_division")
	var v: int = a / b
	@warning_ignore("integer_division")
	var whole: int = absi(v) / 10
	return "%d.%d" % [whole, absi(v) % 10]


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


func _modifier_is_active(w: WorldState, id: int) -> bool:
	if w == null or id < 0:
		return false
	if id < w.modifiers.size() and w.modifiers[id] != null:
		return w.modifiers[id].is_active
	for slot in w.modifiers:
		if slot != null and slot.id == id:
			return slot.is_active
	return false


func _refresh_modifiers() -> void:
	_ensure_modifier_list()
	_clear_modifiers()
	var w: WorldState = GameManager.world
	if w == null or _list == null:
		return
	# 展示 catalog 中全部定义（激活/未激活两套图）；外加无定义但已激活的槽
	var ids: Array[int] = ModifierCatalog.all_ids()
	var seen: Dictionary = {}
	for id in ids:
		seen[id] = true
	for slot in w.modifiers:
		if slot != null and slot.is_active and not seen.has(slot.id):
			ids.append(slot.id)
			seen[slot.id] = true
	ids.sort()
	if ids.is_empty():
		var empty := Label.new()
		empty.text = "暂无修正定义"
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_list.add_child(empty)
		return
	for id in ids:
		var active := _modifier_is_active(w, id)
		var item := MODIFIER_ITEM.instantiate()
		_list.add_child(item)
		if item.has_method("setup"):
			item.setup(
				id,
				ModifierCatalog.name_zh(id),
				ModifierCatalog.effect_zh(id, w),
				ModifierCatalog.icon(id, active),
				active
			)
