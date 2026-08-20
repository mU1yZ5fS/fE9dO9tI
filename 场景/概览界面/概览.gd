extends Control

## 概览主逻辑：六 Tab BBCode + 激活修正列表。只读 WorldState。
## 文案逐字对齐原作 modify_choose.cs 简体分支（language==0，1-980 行）；
## 人工字距空格不复制（本项目 UI 规范为无字距中文，见 概览.tscn 既有写法）。
## ChinesePage 0/1 由左/右方向键切换（modify_choose.cs Update 1838-1857 行）。

const W = preload("res://数据脚本/world_state.gd")
const MODIFIER_ITEM := preload("res://场景/概览界面/修正模板.tscn")

const PANEL_KEYS: Array[String] = ["交易", "影响", "领土", "形势", "凝聚力", "盟友"]

## 领导人英文名→中文显示（数据层存英文名 world_factory.gd:1002/1008；继任移植说明时回退原名）
const 领导人中文名 := {
	"Leonid Brezhnev": "列昂尼德·勃列日涅夫",
	"Gerald Ford": "杰拉尔德·福特",
	"Ronald Reagan": "罗纳德·里根",
	"Jimmy Carter": "吉米·卡特",
	"George Bush": "乔治·布什",
	"Walter Mondale": "沃尔特·蒙代尔",
	"Michael Dukakis": "迈克尔·杜卡基斯",
	"Ron Paul": "罗纳德·欧内斯特·保罗",
	"Ross Perot": "罗斯·佩罗",
	"Bernie Sanders": "伯尼·桑德斯",
	"Vladimir Shcherbitsky": "弗拉基米尔·谢尔比茨基",
	"Konstantin Chernenko": "康斯坦丁·契尔年科",
	"Yuri Andropov": "尤里·安德罗波夫",
	"Grigory Romanov": "格里戈里·罗曼诺夫",
	"Viktor Grishin": "维克托·格里申",
	"Mikhail Gorbachev": "米哈伊尔·戈尔巴乔夫",
	"Alexander Yakovlev": "亚历山大·雅科夫列夫",
	"Yegor Ligachev": "叶戈尔·利加乔夫",
}

## 苏联领导人按 modify_choose.cs:154-212 的 now_leader 显示索引直译。
## 注意不能读 ussr.leaders[idx].leader_name：world_factory.gd:1136-1148 的数组
## 顺序沿用 GameStartScript.cs:963-970（1=谢尔比茨基、3=安德罗波夫），与 modify_choose
## 的显示索引（1=安德罗波夫、3=谢尔比茨基）不一致，故此处以显示索引为权威。
const 苏联领导人名 := {
	0: "列昂尼德·勃列日涅夫",
	1: "尤里·安德罗波夫",
	2: "康斯坦丁·契尔年科",
	3: "弗拉基米尔·谢尔比茨基",
	4: "格里戈里·罗曼诺夫",
	5: "维克托·格里申",
	6: "米哈伊尔·戈尔巴乔夫",
	7: "亚历山大·雅科夫列夫",
	8: "叶戈尔·利加乔夫",
}

## 盟友页候选原版序号集合（modify_choose.cs:882-883 中文分支）。
const 盟友候选 := [19, 48, 50, 96, 49, 47, 46, 11, 22, 23, 34, 33, 32, 97, 43, 31, 12, 8]

## 原版事件编号 → EventEngine 的 event_id（事件资源 source_event_number 追溯）。
## 446-449/460-461 事件链正在按此约定移植，500 为手动事件。
const 事件ID映射 := {
	42: "iranian_revolution",
	58: "iranian_revolution_endgame",
	94: "taiwan_pressure_path",
	95: "taiwan_pressure_step_1",
	96: "taiwan_pressure_step_2",
	116: "two_chinas",
	370: "event_370",
	372: "event_372",
	374: "event_374",
	375: "event_375",
	388: "event_388",
	446: "event_446",
	447: "event_447",
	448: "event_448",
	449: "event_449",
	460: "formosa_winter",
	461: "formosa_spring",
	500: "african_union",
}

var _panels: Dictionary = {}  # key -> RichTextLabel
var _buttons: Dictionary = {}  # key -> Button
var _list: VBoxContainer
var _current: String = "交易"
## 0=原版中文主页；1=ChinesePage==1（影响页显示苏美资金、盟友页显示非洲联盟）
var _chinese_page: int = 0


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


## 原版 modify_choose.cs:1838-1857：LeftArrow→ChinesePage=0，RightArrow→ChinesePage=1，
## 然后按当前选中页重绘。Godot 4.7 InputEventKey.keycode 用法见 gdd_0959_InputEventKey.md。
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_LEFT and _chinese_page != 0:
			_chinese_page = 0
			_refresh_panel(_current)
		elif event.keycode == KEY_RIGHT and _chinese_page != 1:
			_chinese_page = 1
			_refresh_panel(_current)


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


## 内部 ×10 整数 → 原版 "X.Y" 显示（modify_choose 的 /10 + abs(%10) 组合）。
## GDScript int/int 为整数除法（gdd_0304_GDScript_reference.md:226），与 C# 截断一致。
func _iv(v: int) -> String:
	@warning_ignore("integer_division")
	return "%d.%d" % [v / 10, absi(v % 10)]


## 带正负号的 "±X.Y"（原版 modify_choose 人口五效应写法）
func _signed_iv(v: int) -> String:
	var sign_char := "-" if v < 0 else "+"
	return "%s%s" % [sign_char, _iv(absi(v))]


## data_old 语义的人口增量显示（原版 modify_choose.cs:445-455）
func _delta_iv(v: int) -> String:
	return _signed_iv(v)


func _dv(d: WorldState, idx: int, fallback: int = 0) -> int:
	return d.get_data_by_index(idx) if d.size() > idx else fallback


## 原版 gameState.ImportChange（GameState.cs:11-16）。公式实现已上收 WorldState.import_change()。
func _import_change(w: WorldState) -> int:
	return w.import_change()


## 事件完成：优先 EventEngine 的 completed_event_ids（event_engine.gd:246-279），
## 移植说明数字事件按项目惯例回退 global_flags 的 event_done_XXX（国家面板.gd:983 同例）。
func _evt_done(w: WorldState, id) -> bool:
	var event_id: String = 事件ID映射.get(id, str(id))
	if w.completed_event_ids.has(event_id):
		return true
	return w.get_flag("event_done_%s" % str(id))


## 事件结果：completed_event_ids 值为选项号；移植说明数字事件读 global_flags 的 result_XXX。
func _evt_result(w: WorldState, id) -> int:
	var event_id: String = 事件ID映射.get(id, str(id))
	if w.completed_event_ids.has(event_id):
		return int(w.completed_event_ids[event_id])
	return int(w.global_flags.get("result_%s" % str(id), -1))


func _decision_done(w: WorldState, idx: int) -> bool:
	return w.decisions != null and idx >= 0 and idx < w.decisions.completed.size() \
		and w.decisions.completed[idx]


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


# ============================================================================
# 交易页 — modify_choose.cs:16-132（中文分支）
# ============================================================================

func _build_trade(w: WorldState) -> String:
	var d := w
	var export_v := _dv(d, W.I_INCOME)
	var import_v := _dv(d, W.I_IMPORT_NEEDS)
	var partners := _dv(d, W.I_TRADE_PARTNERS)
	# 石油危机修正（modifies[12]）：显示出口减 15%，差额用 num=23-23/6（modify_choose.cs:23-30）
	var num := export_v
	var s := _h("当前数据相对于1976年的百分比")
	if _modifier_is_active(w, 12):
		@warning_ignore("integer_division")
		s += "出口规模：\n%d%% (-15%%)\n" % (export_v / 5)
		@warning_ignore("integer_division")
		num = export_v - export_v / 6
	else:
		@warning_ignore("integer_division")
		s += "出口规模：\n%d%%\n" % (export_v / 5)
	@warning_ignore("integer_division")
	s += "进口需求：\n%d%% (%d)\n\n" % [import_v / 5, _import_change(w) / 5]

	s += _h("差额")
	var diff := num - import_v
	@warning_ignore("integer_division")
	s += "相对于1975年的百分比：\n%d%%\n" % (diff / 5)
	if diff > 0:
		# 贸易利润：diff/100.diff/10%10；人民支持：diff/150.diff/15%10（modify_choose.cs:52-70）
		@warning_ignore("integer_division")
		s += "贸易利润\n每两周：+%s\n" % _iv(diff / 10)
		@warning_ignore("integer_division")
		s += "人民支持度\n每两周：+%s\n" % _iv(diff / 15)
	else:
		# 逆差另加生活水平：diff/200.diff/20%10（modify_choose.cs:74-92）
		var mag := -diff
		@warning_ignore("integer_division")
		s += "贸易利润\n每两周：-%s\n" % _iv(mag / 10)
		@warning_ignore("integer_division")
		s += "人民支持度\n每两周：-%s\n" % _iv(mag / 15)
		@warning_ignore("integer_division")
		s += "生活水平\n每两周：-%s\n" % _iv(mag / 20)

	s += "\n" + _h("世界市场参与")
	if partners <= 10:
		# 原版文案带「-」号：(-9+partners)/10 与 abs((-9+partners)%10)（modify_choose.cs:94-114）
		var step := -9 + partners
		s += "孤立主义\n"
		s += "自由化思潮（每两周）：-%s\n" % _iv(absi(step))
		s += "特工网络（每两周）：-%s\n" % _iv(absi(step))
	elif partners > 18:
		# 中文分支全球化只有自由化思潮一行（modify_choose.cs:116-127）
		s += "积极参与全球化\n"
		s += "自由化思潮（每两周）：+%s\n" % _iv(partners - 18)
	else:
		s += "平衡主义"
	return s


# ============================================================================
# 影响页 — modify_choose.cs:136-336（中文分支；ChinesePage==1 为苏美资金页）
# ============================================================================

func _build_influence(w: WorldState) -> String:
	if _chinese_page == 1:
		return _build_influence_funds(w)
	var ussr: EmpireData = w.empires[1] if w.empires.size() > 1 else null
	var usa: EmpireData = w.empires[0] if w.empires.size() > 0 else null
	var s := _h("全球影响")
	if ussr != null:
		s += "[color=darkred][font_size=25]苏联的世界影响力:[/font_size][/color]\n%s\n" % _iv(ussr.power)
	if usa != null:
		s += "[color=darkblue][font_size=25]美国的世界影响力:[/font_size][/color]\n%s\n" % _iv(usa.power)
	s += "影响美苏在非洲的争夺结果\n\n"

	s += _h("苏联领导人")
	var u_idx: int = ussr.current_leader if ussr != null else 0
	# 索引 7 且 gkchp 时原版只显示「国家紧急状态委员会」（modify_choose.cs:202-205）
	if u_idx == 7 and w.get_flag("is_gkchp"):
		s += "国家紧急状态委员会\n"
	else:
		s += "%s\n" % 苏联领导人名.get(u_idx, "未知领导人")
	# 苏联 9 分支效果文案（modify_choose.cs:154-212 逐字）
	match u_idx:
		0:
			s += "提升苏联的非洲干涉行动花费\n若中苏关系尚未解冻：\n与美国的关系 +0.5；凝聚力 -0.2\n"
		1:
			s += "若中苏关系尚未解冻：\n与美国的关系 +0.5\n若已恢复关系：\n加强改革派的权力\n"
		2:
			s += "与苏联的关系 +0.5\n若中苏关系解冻：\n加强温和派的权力\n"
		3:
			s += "若中苏关系尚未解冻：\n与美国的关系 +0.5；凝聚力 -0.2\n若已恢复关系：\n与苏联的关系 +0.5\n"
		4:
			s += "若中苏关系尚未解冻：\n特工网络 -0.5\n若已恢复关系：\n与苏联的关系 +0.5；特工网络 +0.5\n"
		5:
			s += "与苏联的关系 +0.5\n若中苏关系解冻：\n加强改革派的权力\n"
		6:
			s += "减少苏联的非洲干涉行动花费\n与苏联的关系 +0.5；自由化思潮 +0.5\n加强自由派的权力\n"
		8:
			s += "减少苏联的非洲干涉行动花费\n与苏联的关系 +0.5；自由化思潮 +0.5\n"

	s += "\n" + _h("军备竞赛")
	s += _arms_race_text(w, ussr, usa)
	return s


## ChinesePage==1：苏美资金页（modify_choose.cs:315-336）
func _build_influence_funds(w: WorldState) -> String:
	var ussr: EmpireData = w.empires[1] if w.empires.size() > 1 else null
	var usa: EmpireData = w.empires[0] if w.empires.size() > 0 else null
	var s := _h("苏美资金")
	var tech22 := w.techs != null and w.techs.unlocked.size() > 22 and w.techs.unlocked[22]
	var u_power := ussr.power if ussr != null else 0
	var a_power := usa.power if usa != null else 0
	if tech22 and w.influence_prc >= a_power + u_power and ussr != null and usa != null:
		s += "苏联的储备资金：\n%s\n" % _iv(ussr.money)
		s += "美国的储备资金：\n%s\n" % _iv(usa.money)
	else:
		s += "我们的特工部门还无法获取这些信息"
	return s


## 军备竞赛三态（modify_choose.cs:213-312 中文分支）
func _arms_race_text(w: WorldState, ussr: EmpireData, usa: EmpireData) -> String:
	var pc := w.get_player_country()
	var army := _dv(w, W.I_ARMY)
	if pc != null and pc.has_tag("okb") and ussr != null and usa != null:
		var sov_power := ussr.power
		var us_power := usa.power
		# 每个进行中战争使美苏力量各减 1/9（modify_choose.cs:216-222）
		for war in w.wars:
			if war != null and war.is_going:
				@warning_ignore("integer_division")
				sov_power -= sov_power / 9
				@warning_ignore("integer_division")
				us_power -= us_power / 9
		var loan := _dv(w, W.I_LOAN)
		if loan > 7:
			@warning_ignore("integer_division")
			us_power += loan / 7
		if ussr.current_leader == 0:
			sov_power += 20
		var s := "[color=red]与苏联的力量对比：[/color]%s\n" % _iv(army - sov_power)
		if army > sov_power:
			s += "非洲盟国政权稳定度：+2.5\n盟国政权稳定度：+1.0\n"
		elif army < sov_power and w.influence_prc > 0:
			@warning_ignore("integer_division")
			s += "盟国政权稳定度：-%s\n" % _iv(-(army - sov_power) / 20)
		s += "[color=blue]与美国的力量对比：[/color]%s\n" % _iv(army - us_power)
		if army > us_power:
			s += "非洲盟国政权稳定度：+2.5\n盟国政权稳定度：+1.0\n"
		elif army < us_power and w.influence_prc > 0:
			@warning_ignore("integer_division")
			s += "盟国政权稳定度：-%s\n" % _iv(-(army - us_power) / 20)
		return s
	var yugo := w.get_country_by_legacy_index(15)
	if yugo != null and yugo.内战中:
		var s := "[color=red]不结盟运动成员国[/color]\n"
		s += "与苏联的关系（每两周）：+0.5（至多70）\n"
		s += "与美国的关系（每两周）：+0.5（至多70）\n"
		s += "预算支出（每两周）：-0.2\n"
		var dip := _dv(w, W.I_DIPLO)
		if dip > 600:
			s += "国际威望（每两周）：-0.2\n"
		elif dip < 400:
			s += "国际威望（每两周）：+0.2\n"
		return s
	return "我们不参与军备竞赛"


# ============================================================================
# 领土页 — modify_choose.cs:757-865（中文分支）
# ============================================================================

func _build_territory(w: WorldState) -> String:
	var d := w
	var s := _h("中华本部")
	s += "%s\n" % _tibet_text(_dv(d, W.I_TIBET_POLICY))
	s += "%s\n" % _xinjiang_text(_dv(d, W.I_XINJIANG_POLICY))
	s += "%s\n" % _hk_macau_text(_dv(d, W.I_HK_MACAU_STATUS))
	s += _mongolia_text(w)

	s += "\n" + _h("台湾地区")
	s += _taiwan_text(w, d)
	s += "\n" + _h("藏南地区")
	s += _arunachal_text(_dv(d, W.I_ARUNACHAL_STATUS))
	return s


## data.tibet_policy 西藏文化政策状态 → 文案（modify_choose.cs:764-774）
func _tibet_text(v: int) -> String:
	if v == 1:
		return "西藏共和国-独立主权"
	elif v == 2:
		return "西藏共和国-独立主权；神权政治"
	return "西藏是中国领土不可分割的一部分"


## data.xinjiang_policy 新疆文化政策状态 → 文案（modify_choose.cs:776-789）
func _xinjiang_text(v: int) -> String:
	if v == 1:
		return "新疆-苏联傀儡"
	elif v == 2:
		return "维吾尔斯坦伊斯兰共和国-独立主权"
	return "新疆是中国领土不可分割的一部分"


## data.hk_macau_status 港澳回归状态 → 文案（modify_choose.cs:791-805）
func _hk_macau_text(v: int) -> String:
	if v == 1:
		return "港澳是中国的特别行政区"
	elif v == 2:
		return "港澳是中国领土不可分割的一部分"
	return "港澳地区被外国势力控制"


## 蒙古四分支（modify_choose.cs:806-830）。
## proprc→亲中；puppetOf→puppet_of（原版序号 1=中国）；IndOpp/is_gkchp 用 global_flags。
func _mongolia_text(w: WorldState) -> String:
	var ussr := w.get_country_by_legacy_index(7)
	if ussr != null and ussr.parts.size() > 2 \
			and (ussr.parts[1] or ussr.parts[2]):
		return "蒙古是苏联的加盟共和国"
	var mongolia := w.get_country_by_legacy_index(9)
	var proprc: bool = mongolia != null and mongolia.has_tag("亲中")
	var puppet_china: bool = mongolia != null and mongolia.puppet_of == GameConstants.LegacySlot.CHINA
	if mongolia != null and not _decision_done(w, 19) \
			and not w.get_flag("IndOpp") and not w.get_flag("is_gkchp"):
		if proprc and puppet_china:
			return "蒙古是亲华的“独立主权”国家"
		if not proprc:
			return "蒙古是亲苏的独立主权国家"
		return "蒙古是亲华的独立主权国家"
	return "蒙古是中国领土不可分割的一部分"


## 台湾主状态 + 台海岛屿（modify_choose.cs:831-852）
func _taiwan_text(w: WorldState, d: WorldState) -> String:
	var status := _dv(d, W.I_TAIWAN_STATUS)
	var islands := _dv(d, W.I_TAIWAN_ISLANDS)
	var ev461 := w.get_flag("event_done_461")
	var s := ""
	if status == 2 or _decision_done(w, 6) or _decision_done(w, 7) or ev461:
		s = "台湾省-中国省级特别行政区\n"
	elif status <= 0:
		s = "中华民国-国民党统治\n（威权主义，少数国家承认）\n"
	elif status == 1:
		s = "台湾国-独立主权\n（自由主义，国际广泛承认）\n"
	if islands <= 0 and not ev461:
		s += "台海岛屿\n在国民党控制下\n"
	elif islands == 1 or ev461:
		s += "台海岛屿\n在解放军控制下\n"
	return s


## data.arunachal_status 藏南状态 → 文案（modify_choose.cs:853-864）
func _arunachal_text(v: int) -> String:
	if v == 1:
		return "被印度实际控制，我方承认其主权"
	if v == 2 or v == 3:
		return "我们已重建实际控制并确认当地主权"
	return "被印度实际控制，并未被我方承认"


# ============================================================================
# 形势页 — modify_choose.cs:571-756（中文分支）
# ============================================================================

func _build_situation(w: WorldState) -> String:
	var d := w
	var s := _h("伊朗")
	s += _iran_text(w, d)
	s += "\n\n" + _h("阿富汗")
	s += "毛主义者力量：%s\n人民派力量：%s\n旗帜派力量：%s\n\n" % [
		_iv(_dv(d, W.I_AFGHAN_OPPOSITION)),
		_iv(_dv(d, W.I_AFGHAN_KHALQ)),
		_iv(_dv(d, W.I_AFGHAN_PARCHAM)),
	]
	s += _h("美国总统")
	s += _usa_president_text(w)
	return s


## 伊朗 13 个定性分支（modify_choose.cs:577-655 中文分支，按原版 if-else 顺序）
func _iran_text(w: WorldState, d: WorldState) -> String:
	var turkey := w.get_country_by_legacy_index(84)
	var iran := w.get_country_by_legacy_index(8)
	if turkey != null and turkey.parts.size() > 5 and turkey.parts[5]:
		return "大土耳其的一部分"
	if iran != null and iran.puppet_of == 84:
		return "土耳其的傀儡国"
	if not _evt_done(w, 58) and _evt_done(w, 42):
		return "保皇派力量：%s\n革命派力量：%s" % [
			_iv(_dv(d, W.I_IRAN_SHAH_SUPPORT)),
			_iv(_dv(d, W.I_IRAN_LEFT_SUPPORT)),
		]
	if iran != null:
		var sub: int = iran.sub_government
		var gov: int = iran.government
		var proprc: bool = iran.has_tag("亲中")
		if sub == 13:
			return "沙阿政权依旧稳固"
		if sub == 10:
			return "伊朗的革命已经步入了“新纪元”\n领导我们事业的核心力量\n是人民圣战者组织，\n指导我们思想的理论基础\n是拉贾维思想"
		if sub == 19:
			return "伊朗的革命已经步入了“新纪元”\n忠于拉贾维主席，\n忠于拉贾维思想，\n忠于拉贾维主席的革命路线；\n对拉贾维主席要无限热爱、无限敬仰、\n无限崇拜、无限忠诚！"
		if sub == 9:
			return "巴赫拉姆·雅利安纳正在落实波斯民族伟大复兴进程"
		if _evt_done(w, 58) and sub == 8 and not _evt_done(w, 446):
			return "霍梅尼主导的各派革命力量参与的过渡政府"
		if w.wars.size() > 33 and w.wars[33] != null and w.wars[33].is_going:
			return "伊朗正陷入大规模的内战！"
		if _evt_done(w, 446) and (not _evt_done(w, 447) or _evt_result(w, 447) != 0) and sub == 20:
			return "伊斯兰革命正逐步走向体制化"
		if _evt_done(w, 447) and _evt_result(w, 447) == 0 and not _evt_done(w, 448):
			return "小型内战后的伊朗安危未定"
		if sub == 3 and proprc:
			return "伊朗已建成稳定的民主社会主义亲中政权"
		if sub == 3:
			return "伊朗已建成稳定的民主社会主义政权"
		if (sub == 12 or gov == 3) and proprc:
			return "伊朗已建成稳定的自由主义亲中政权"
		if sub == 12 or gov == 3:
			return "伊朗已建成稳定的自由主义政权"
		if gov == 1 and proprc:
			return "伊朗已建成稳定的亲中社会主义政权"
		if gov == 1:
			return "伊朗已建成稳定的社会主义政权"
	return "伊朗情况已经稳定"


## 美国总统姓名 + 八效果分支（modify_choose.cs:676-755 中文分支，形势页唯一出处）
func _usa_president_text(w: WorldState) -> String:
	var usa: EmpireData = w.empires[0] if w.empires.size() > 0 else null
	var year: int = w.date.year if w.date else 1976
	if year < 1977:
		return "杰拉尔德·福特"
	if year < 1981:
		return "吉米·卡特\n与美国的关系：+1.0"
	if usa == null:
		return "杰拉尔德·福特"
	var a_idx: int = usa.current_leader
	var s := _leader_name(usa, "罗纳德·里根")
	match a_idx:
		0:
			s += "\n美国的干涉行动花费：+0.5\n自由化思潮：+0.5"
		1:
			s += "\n与美国的关系：+1.0"
		2:
			s += "\n美国的干涉行动花费：+0.5\n与美国的关系：+0.5\n（若我们未处于非美国的军事联盟）"
		3:
			s += "\n西欧毛派行动效果 ×1.5\n每两月偿还一次贷款\n与美国的关系：+1.0"
		4:
			s += "\n美国储备金 +0.2\n美国国际影响力 -0.2\n苏联国际影响力 +0.1"
		5:
			s += "\n美国国际影响力 -0.4\n苏联国际影响力 +0.2\n中美关系 +0.2\n如果中国为自由主义：关系额外 +0.2\n中国对外干涉效果 ×2"
		6:
			s += "\n美国储备金 +0.1\n与美国关系 -0.1"
		7:
			s += "\n美国储备金 -0.2\n如果中国为改良主义\n中美关系 +0.2\n增强国内改革派 / 自由派势力"
	return s


# ============================================================================
# 凝聚力页 — modify_choose.cs:338-570（中文分支）
# ============================================================================

func _build_cohesion(w: WorldState) -> String:
	var d := w
	var unity_view := _dv(d, W.I_WAR_SUPPORT, 500)
	var unity_raw := _dv(d, W.I_MANPOWER)
	var pop := _dv(d, W.I_POPULATION)
	var s := _h("世界观瞻")
	s += "现状：\n%s\n(%s/100)\n\n" % [_worldview_label(unity_view), _iv(unity_view)]
	s += "国家凝聚力：\n(%s/100)\n\n" % _iv(unity_raw)
	s += _h("特殊影响")
	s += _worldview_effects_text(unity_view)
	s += _h("人口")
	var pop_delta: int = w.两周变化(W.I_POPULATION)
	s += "%s 百万 (%s)\n" % [_iv(pop), _delta_iv(pop_delta)]
	s += _population_effects_text(d, w)
	return s


## data.war_support 统一度→世界观档位（modify_choose.cs:346-405）
func _worldview_label(v: int) -> String:
	if v > 700:
		return "完全的统一"
	elif v >= 400:
		return "多元一体理念"
	return "多元文化主义"


## 特殊影响文案：按原版 modify_choose.cs:358-433 的显示公式与符号逐字对齐
## （注意：低档特工网络原版显示「-」号，与 TimeScript.cs:4189 结算实际方向相反，照抄 UI）。
func _worldview_effects_text(v: int) -> String:
	if v > 700:
		@warning_ignore("integer_division")
		var step_high := (v - 500) / 100
		var s_high := "自由化思潮（每两周）：-%s\n" % _iv(step_high)
		s_high += "党内团结度（每两周）：+%s\n" % _iv(step_high)
		s_high += "特工网络（每两周）：+%s\n" % _iv(step_high)
		s_high += "国际威望：+0.5\n（如果低于50.0）\n"
		return s_high
	if v >= 400 and v <= 700:
		return "无\n"
	@warning_ignore("integer_division")
	var step := (500 - v) / 100
	var s := "自由化思潮（每两周）：+%s\n" % _iv(step)
	s += "党内团结度（每两周）：+%s\n" % _iv(step)
	s += "特工网络（每两周）：-%s\n" % _iv(step)
	s += "两极大国关系（每两周）：+%s\n" % _iv(step)
	return s


## 人口五效应（modify_choose.cs:456-569）：工业/人民支持度/特工网络/预算/军事实力。
## 全部照原版 UI 公式显示（含 econ13 与特工网络两项此前漏移植的显示）。
func _population_effects_text(d: WorldState, w: WorldState) -> String:
	var pop := _dv(d, W.I_POPULATION)
	var econ := _dv(d, W.I_ECON_SYSTEM)
	var effects := [0, 0, 0, 0, 0]  # [工业, 人民支持, 特工, 预算, 军力]
	if econ == 10 or econ == 11:
		@warning_ignore("integer_division")
		effects[0] += pop / 5000
	elif econ == 13:
		effects[3] += int(round(float(pop - 9037) / 3000.0 + 1.0))
	elif (econ == 14 or econ == 15) and not _modifier_is_active(w, 13):
		@warning_ignore("integer_division")
		effects[1] -= pop / 4000
		effects[3] += int(round(float(pop - 9037) / (2000.0 if econ == 14 else 1000.0) + 1.0))
	@warning_ignore("integer_division")
	if (pop - 9307) / 200 > 0:
		@warning_ignore("integer_division")
		effects[2] -= (pop - 9307) / 200
	var pop_excess := pop - 9307
	match _dv(d, W.I_MIL_DOCTRINE, -1):
		30:
			if pop_excess > 99:
				@warning_ignore("integer_division")
				effects[3] -= pop_excess / 100
				@warning_ignore("integer_division")
				effects[4] += pop_excess / 100
		31:
			if pop_excess > 199:
				@warning_ignore("integer_division")
				effects[3] -= pop_excess / 200
				@warning_ignore("integer_division")
				effects[4] += pop_excess / 200
		32:
			if pop_excess > 299:
				@warning_ignore("integer_division")
				effects[3] -= pop_excess / 300
				@warning_ignore("integer_division")
				effects[4] += pop_excess / 300
		33:
			if pop_excess > 149:
				var living := _dv(d, W.I_LIVING)
				if living < 500:
					@warning_ignore("integer_division")
					effects[3] -= pop_excess / 150
					@warning_ignore("integer_division")
					effects[4] += pop_excess / 250
				elif living < 700:
					@warning_ignore("integer_division")
					effects[3] -= pop_excess / 150
					@warning_ignore("integer_division")
					effects[4] += pop_excess / 300
				else:
					@warning_ignore("integer_division")
					effects[3] -= pop_excess / 500
					@warning_ignore("integer_division")
					effects[4] += pop_excess / 500
	var s := "工业：%s；预算：%s\n" % [_signed_iv(effects[0]), _signed_iv(effects[3])]
	s += "特工网络：%s；军事实力：%s\n" % [_signed_iv(effects[2]), _signed_iv(effects[4])]
	s += "人民支持度：%s" % _signed_iv(effects[1])
	return s


# ============================================================================
# 盟友页 — modify_choose.cs:866-973（中文分支；ChinesePage==1 为非洲联盟）
# ============================================================================

func _build_allies(w: WorldState) -> String:
	if _chinese_page == 1:
		return _build_african_union(w)
	var pc := w.get_player_country()
	var s := _h("中国人民的老朋友")
	# 只有中国加入经济联盟才显示列表，否则恒为空态（modify_choose.cs:872-931）
	if pc == null or not pc.has_tag("econ"):
		s += "我们不属于任何联盟"
		return s
	s += "[color=red]国家 - 合作程度 - 革命立场是否坚定 - 稳定度[/color]\n"
	for legacy_idx in 盟友候选:
		var c := w.get_country_by_legacy_index(legacy_idx)
		if c == null:
			continue
		var in_econ := c.has_tag("econ")
		var in_okb := c.has_tag("okb")
		var role := ""
		if in_econ and in_okb:
			role = "经济军事一体化"
		elif in_econ:
			role = "经济一体化"
		elif in_okb:
			role = "军事一体化"
		if role == "":
			continue
		var firm := "是" if c.has_tag("亲中") else "否"
		s += "%s - %s - %s - %s\n" % [
			c.display_name(), role, firm, _iv(c.social_stability),
		]
	return s


## ChinesePage==1：非洲联盟页（modify_choose.cs:934-972）。
## 项目惯例：event500 成功用 global_flags.event_done_500（国家面板.gd:983 同源）。
func _build_african_union(w: WorldState) -> String:
	var s := _h("非洲联盟")
	if w.get_flag("event_done_500"):
		s += "[color=red]成员国家[/color]"
		var count := 0
		for c in w.countries:
			if c == null or not c.has_tag("au"):
				continue
			if not w.is_socialism(c, true):
				continue
			if count % 3 == 0:
				s += "\n" + c.display_name()
			else:
				s += "\u00A0" + c.display_name()
			count += 1
		return s
	return s + "非洲联盟尚未建立"


# ============================================================================
# 修正列表（Godot 独有，保留原实现）
# ============================================================================

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
	# 64「最高领导人概况」：改版存在多个数据源尚未统一（faction/traits/LeaderAsset），
	# 主人要求先注释掉，不显示在概览修正列表。
	ids = ids.filter(func(id: int) -> bool: return id != 64)
	# 生效中的修正排在前面；同组按 id 升序，保持目录阅读顺序
	ids.sort_custom(func(a: int, b: int) -> bool:
		var active_a := _modifier_is_active(w, a)
		var active_b := _modifier_is_active(w, b)
		if active_a != active_b:
			return active_a
		return a < b
	)
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
