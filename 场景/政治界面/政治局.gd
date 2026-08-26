extends Control
## 政治局界面（适配用户重构版布局）。
## 左栏=修改前原版结构；纸面常驻名牌：职位中央/职位部门/职位地方；
## 名录 3 行×6 列；操作入口=轻量人物小窗。行为公式见 docs/政治局重构/01_行为冻结清单.md。

const 外交场景 := "uid://vq6jexkk5tru"
const CARD_SCENE := preload("res://场景/政治界面/政治家卡片.tscn")
const LEADER_SELECT := -150  ## 原版 selected_politic == 150
const LEADER_POS := -2       ## 实权领袖兼任哨兵

# ── 左栏职位 / 主管文案（Politic_Manager.cs:81-115）──
const POSITION_NAMES: Array[String] = [
	"国务院总理", "中央军委主席", "外交部长",
	"京 畿", "华 北", "华 西", "华 南", "华 东",
]

# ── 派系领袖标题与颜色（Politic_Manager.cs:61-80）──
const FACTION_LEADER_TITLES: Array[String] = [
	"极 左 派 领 袖", "保 守 派 领 袖", "温 和 派 领 袖",
	"改 革 派 领 袖", "自 由 派 领 袖",
]
const FACTION_LEADER_COLORS: Array[String] = [
	"red", "purple", "fuchsia", "green", "aqua",
]

## 影响力档位（Politic_Manager.cs:136-151）
const POWER_LABELS := [
	[250, "无 影 响 力", "green"],
	[500, "弱 影 响 力", "pink"],
	[700, "略 有 影 响", "yellow"],
	[99999, "强 影 响 力", "red"],
]

var _world: WorldState
var _cards: Array = []
var _sorted_indices: Array[int] = []
## -1 未选；LEADER_SELECT 实权领袖；>=0 politicians 索引
var _selected_pol_index: int = -1
var _hover_target: int = -1

@onready var _card_rows: Array = [
	$纸面区/页签_名录/行1,
	$纸面区/页签_名录/行2,
	$纸面区/页签_名录/行3,
]
const CARDS_PER_ROW := 6

# ── 黑栏区（修改前左栏结构 + 预算/特工） ──
@onready var _dossier_name: Label = $黑栏区/信息列/姓名行/姓名
@onready var _dossier_party: Label = $黑栏区/信息列/派系行/值
@onready var _dossier_trait1: Label = $黑栏区/信息列/特质行1/值
@onready var _dossier_trait2: Label = $黑栏区/信息列/特质行2/值
@onready var _dossier_trait3: Label = $黑栏区/信息列/特质行3/值
@onready var _dossier_status: RichTextLabel = $黑栏区/左栏_当前选中政治家状态
@onready var _budget_label: Label = $黑栏区/预算格/数值
@onready var _agents_label: Label = $黑栏区/特工格/数值

# ── 纸面常驻名牌 ──
@onready var _pos_labels: Array = [
	$纸面区/职位中央/国务院总理, $纸面区/职位中央/中央军委主席, $纸面区/职位中央/外交部长,
	$纸面区/职位地方/首都主管, $纸面区/职位地方/北方主管, $纸面区/职位地方/西方主管,
	$纸面区/职位地方/南方主管, $纸面区/职位地方/东方主管,
]

# ── 领袖 / 小窗 / 返回 ──
@onready var _leader_frame: TextureRect = $纸面区/实权领袖框
@onready var _leader_portrait: TextureRect = $纸面区/实权领袖框/肖像
@onready var _window = $人物小窗
@onready var _btn_return: TextureButton = $返回外交界面

var _leader_no_portrait_label: Label


func _ready() -> void:
	_world = GameManager.world
	if _world == null:
		push_error("政治局: GameManager.world 为空")
		return
	UISettings.apply_font_scale(self, GameManager.ui_font_scale)

	_leader_no_portrait_label = Label.new()
	_leader_no_portrait_label.text = "无肖像"
	_leader_no_portrait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_leader_no_portrait_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_leader_no_portrait_label.add_theme_font_size_override("font_size", 20)
	_leader_no_portrait_label.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35, 1))
	_leader_no_portrait_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_leader_no_portrait_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_leader_portrait.add_child(_leader_no_portrait_label)

	_leader_frame.mouse_filter = Control.MOUSE_FILTER_STOP

	_window.connect("action_pressed", _on_window_action)
	_window.connect("appoint_requested", _on_assign_position)
	_btn_return.pressed.connect(_goto_diplomacy)

	GameManager.stats_changed.connect(_on_stats_changed)
	_full_refresh()


func _exit_tree() -> void:
	if GameManager and GameManager.stats_changed.is_connected(_on_stats_changed):
		GameManager.stats_changed.disconnect(_on_stats_changed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_goto_diplomacy()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_selected_pol_index = -1
		if _window.is_open():
			_window.close()
		_refresh_dossier()


# ============================================================================
# 全量刷新
# ============================================================================

func _full_refresh() -> void:
	if _world == null:
		return
	_balance_politic()
	_rebuild_roster()
	_refresh_positions()
	_refresh_leader()
	_refresh_right_panel()
	_refresh_dossier()
	_apply_card_selection()
	_repaint_loyalty_bars()


func _balance_politic() -> void:
	_sorted_indices.clear()
	for i in _world.politicians.size():
		_sorted_indices.append(i)
	_sorted_indices.sort_custom(func(a: int, b: int) -> bool:
		return _world.politicians[a].power > _world.politicians[b].power
	)


func _rebuild_roster() -> void:
	for card in _cards:
		card.queue_free()
	_cards.clear()
	for slot in _sorted_indices.size():
		var pol_idx: int = _sorted_indices[slot]
		var card = CARD_SCENE.instantiate()
		@warning_ignore("integer_division")
		var row: HBoxContainer = _card_rows[mini(slot / CARDS_PER_ROW, _card_rows.size() - 1)]
		row.add_child(card)
		card.setup(_world.politicians[pol_idx], pol_idx)
		card.connect("card_hovered", _on_card_hovered)
		card.connect("card_unhovered", _on_card_unhovered)
		card.connect("card_clicked", _on_card_clicked)
		_cards.append(card)


func _apply_card_selection() -> void:
	for card in _cards:
		if card.has_method("set_selected"):
			card.set_selected(card.get_pol_index() == _selected_pol_index)


func _refresh_positions() -> void:
	for i in _pos_labels.size():
		var holder: int = _world.politics_positions[i] if i < _world.politics_positions.size() else -1
		if holder == LEADER_POS:
			_pos_labels[i].text = _world.leader.name_display if _world.leader else "实权领袖"
		elif holder >= 0 and holder < _world.politicians.size():
			_pos_labels[i].text = _world.politicians[holder].name_display
		else:
			_pos_labels[i].text = "空缺"


func _refresh_leader() -> void:
	var has_portrait := false
	if _world.leader and _world.leader.has_real_portrait():
		_leader_portrait.texture = _world.leader.portrait
		has_portrait = true
	elif _world.leader_politician_index >= 0 and _world.leader_politician_index < _world.politicians.size():
		var p: PoliticianData = _world.politicians[_world.leader_politician_index]
		if p and p.has_real_portrait():
			_leader_portrait.texture = p.portrait
			has_portrait = true
	if not has_portrait:
		_leader_portrait.texture = null
	if _leader_no_portrait_label:
		_leader_no_portrait_label.visible = not has_portrait


func _refresh_right_panel() -> void:
	_budget_label.text = _world.display_meter(_world.budget)
	_agents_label.text = _world.display_meter(_world.agents)


# ============================================================================
# 黑栏区卷宗（悬停实时预览；格式对齐原版 Politic_Selected 中文分支）
# ============================================================================

func _refresh_dossier(hover_idx: int = -1) -> void:
	var idx: int = _selected_pol_index if hover_idx < 0 else hover_idx
	if idx == LEADER_SELECT:
		_refresh_dossier_for_leader()
		return
	if idx < 0 or idx >= _world.politicians.size():
		_dossier_name.text = ""
		_set_traits(null)
		_dossier_status.text = ""
		return

	var pol: PoliticianData = _world.politicians[idx]
	_dossier_name.text = "%s（%d岁）" % [pol.name_display, pol.age]
	_set_traits(pol)

	@warning_ignore("integer_division")
	var sb := ""
	var lead_slot := _faction_leader_slot_of(idx)
	if lead_slot >= 0 and lead_slot < FACTION_LEADER_TITLES.size():
		sb += "[color=%s]%s[/color]|" % [FACTION_LEADER_COLORS[lead_slot], FACTION_LEADER_TITLES[lead_slot]]
	sb += "职 务 ："
	for i in 3:
		if _world.politics_positions[i] == idx:
			sb += "[color=orange] %s[/color]；" % POSITION_NAMES[i]
	sb += "|主 管 ："
	for i in range(3, 8):
		if _world.politics_positions[i] == idx:
			sb += "[color=yellow] %s [/color]；" % POSITION_NAMES[i]
	sb += "|"
	if pol.is_under_investigation:
		sb += "距 纪 律 审 查 结 束 ：[color=green]%d[/color] 个 月" % clampi(7 - pol.investigator_index, 0, 7)
	else:
		sb += "尚 未 被 纪 律 审 查"
	sb += "|"
	if pol.is_under_surveillance:
		var rate: float = GameManager.change_of_killing(idx)
		sb += "已 处 于 监 察 调 查 ：[color=green]%d[/color] 个 月|留 置 后 的 影 响 ：%s%%" % [
			pol.days_surveillance, rate * 100.0
		]
	else:
		sb += "尚 未 被 监 察 调 查 |留 置 后 的 影 响 未 知"
	sb += "|"
	@warning_ignore("integer_division")
	sb += "影 响 力 ：%d.%d |" % [pol.power / 10, absi(pol.power % 10)]
	for threshold in POWER_LABELS:
		if pol.power <= threshold[0]:
			sb += "[color=%s]%s[/color]" % [threshold[2], threshold[1]]
			break
	sb += "|"
	if pol.you_fall:
		sb += "[color=red]不 成 功 的 暗 杀 尝 试[/color]"
	if pol.is_under_surveillance:
		if pol.is_conspiracy:
			sb += "[color=red]处 于 阴 谋 的 威 胁 下[/color]"
		if _is_plotting_against_you(pol):
			sb += "|[color=green]正 在 阴 谋 反 对 你 ！[/color]"

	_dossier_status.text = _wrap_text(sb, 30)


func _set_traits(pol: PoliticianData) -> void:
	if pol == null:
		_dossier_party.text = ""
		_dossier_trait1.text = ""
		_dossier_trait2.text = ""
		_dossier_trait3.text = ""
		return
	_dossier_party.text = WorldFactory.PARTY_LABELS_ZH.get(pol.party_index(), "未知")
	_dossier_trait1.text = pol.background_label()
	_dossier_trait2.text = WorldFactory.TRAIT_LABELS_ZH.get(pol.trait_alignment, "未知")
	_dossier_trait3.text = WorldFactory.TRAIT_LABELS_ZH.get(pol.trait_special, "未知")


func _is_plotting_against_you(pol: PoliticianData) -> bool:
	if pol.is_under_investigation:
		return false
	if pol.trait_special == GameConstants.PoliticianSpecial.SHY or pol.trait_special == GameConstants.PoliticianSpecial.SICKLY:
		return false
	if pol.loyalty < 450 and (pol.trait_special == GameConstants.PoliticianSpecial.ADVISER or pol.trait_special == GameConstants.PoliticianSpecial.OPPORTUNIST):
		return true
	if pol.you_fall:
		return true
	if pol.loyalty < 300 and pol.trait_special != GameConstants.PoliticianSpecial.PEACE and pol.trait_special != GameConstants.PoliticianSpecial.AFFABLE:
		return true
	if pol.loyalty < 150 and (pol.trait_special == GameConstants.PoliticianSpecial.PEACE or pol.trait_special == GameConstants.PoliticianSpecial.AFFABLE):
		return true
	if pol.trait_background == GameConstants.PoliticianBackground.AMBITIOUS and pol.loyalty < 2000:
		return true
	return false


func _refresh_dossier_for_leader() -> void:
	var leader: PoliticianData = _world.leader
	if leader == null:
		_dossier_status.text = "实权领袖数据缺失"
		return
	_dossier_name.text = "%s（%d岁）" % [leader.name_display, leader.age]
	_set_traits(leader)
	var sb := " %s" % PolityProfile.leader_title(_world)
	sb += "|职 务 ："
	for i in 3:
		if _world.politics_positions[i] == LEADER_POS:
			sb += "[color=orange] %s[/color]；" % POSITION_NAMES[i]
	sb += "|主 管 ："
	for i in range(3, 8):
		if _world.politics_positions[i] == LEADER_POS:
			sb += "[color=yellow] %s [/color]；" % POSITION_NAMES[i]
	_dossier_status.text = _wrap_text(sb, 30)


func _wrap_text(text: String, col: int = 30) -> String:
	var t := text
	t = t.replace("[color=green]", "<g>")
	t = t.replace("[color=red]", "<r>")
	t = t.replace("[color=yellow]", "<y>")
	t = t.replace("[color=brown]", "<p>")
	t = t.replace("[/color]", "<c>")
	var out := ""
	var num := 0
	for i in t.length():
		var ch: String = t[i]
		if ch == "|":
			num = 0
			out += "\n"
		elif num >= col:
			if ch == " ":
				num = 0
				out += "\n"
			else:
				out += ch
				var j := out.length() - 1
				while j >= 0:
					if out[j] == " ":
						out = out.substr(0, j) + "\n" + out.substr(j + 1)
						num = out.length() - 1 - j
						break
					j -= 1
		else:
			out += ch
			num += 1
	out = out.replace("<g>", "[color=green]")
	out = out.replace("<r>", "[color=red]")
	out = out.replace("<y>", "[color=yellow]")
	out = out.replace("<p>", "[color=brown]")
	out = out.replace("<c>", "[/color]")
	return BbcTooltip.darken_bright_colors(out)


# ============================================================================
# 卡片信号（悬停=黑栏区实时预览）
# ============================================================================

func _on_card_hovered(pol_index: int) -> void:
	_hover_target = pol_index
	_refresh_dossier(pol_index)
	_repaint_loyalty_bars()


func _on_card_unhovered() -> void:
	_hover_target = -1
	_refresh_dossier()
	_repaint_loyalty_bars()


func _repaint_loyalty_bars() -> void:
	for card in _cards:
		card.update_loyalty_bar(_hover_target)


func _on_card_clicked(pol_index: int) -> void:
	_selected_pol_index = pol_index
	_refresh_dossier()
	_apply_card_selection()
	_open_window()


func _on_leader_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_leader()
		accept_event()


func _select_leader() -> void:
	_selected_pol_index = LEADER_SELECT
	_refresh_dossier()
	_apply_card_selection()
	_open_window()


# ============================================================================
# 人物小窗数据注入（资格公式逐字来自冻结清单 §2）
# ============================================================================

func _open_window() -> void:
	var info := {}
	var posts: Array = []
	var actions := {}
	if _selected_pol_index == LEADER_SELECT:
		var leader: PoliticianData = _world.leader
		info = {
			"name": leader.name_display if leader else "实权领袖",
			"sub": PolityProfile.leader_title(_world),
			"traits": _traits_line(leader),
			"portrait": _leader_portrait.texture,
		}
		actions["faction_leader"] = {"visible": false}
		actions["leader_cmc"] = {
			"visible": true,
			"disabled": not _can_assign_leader_cmc(),
			"tip": (" 已 任 命" if _world.politics_positions[7] == LEADER_POS else " 是 ，当 然 可 以"),
		}
	else:
		var pol := _get_selected_pol()
		if pol == null:
			return
		var rank := _rank_of(_selected_pol_index)
		info = {
			"name": "%s（%d岁）" % [pol.name_display, pol.age],
			"sub": "影响力排名第 %d 位 · 第 %d 档" % [rank, _get_tier(_selected_pol_index)],
			"traits": _traits_line(pol),
			"portrait": pol.portrait,
		}
		posts = _build_appointment_rows(pol)
		actions = _build_action_states(pol)
	_window.open(info, posts, actions)


func _traits_line(pol: PoliticianData) -> String:
	if pol == null:
		return ""
	return "%s · %s · %s · %s" % [
		WorldFactory.PARTY_LABELS_ZH.get(pol.party_index(), "未知"),
		pol.background_label(),
		WorldFactory.TRAIT_LABELS_ZH.get(pol.trait_alignment, "未知"),
		WorldFactory.TRAIT_LABELS_ZH.get(pol.trait_special, "未知"),
	]


func _rank_of(pol_index: int) -> int:
	for slot in _sorted_indices.size():
		if _sorted_indices[slot] == pol_index:
			return slot + 1
	return -1


func _build_appointment_rows(pol: PoliticianData) -> Array:
	var rows: Array = []
	var idx := _selected_pol_index
	var tier := _get_tier(idx)
	for pos in PositionCatalog.appointment_order():
		var allowed := _slot_allowed(pol, tier, pos)
		var tip := _position_tip(pol, pos)
		if pos == 1 and not GameManager.is_mao_dead():
			allowed = false
			tip = " 伟 大 的 舵 手 万 岁 ！"
		# 任命预览（纯查询：数字来自目录惩罚表与意向职位规则）
		var pen: Array = PositionCatalog.def(pos).get("penalty", [150, -1, 250])
		var gain: int = int(pen[2]) + (250 if pol.wanted_position == pos else 0)
		var prev_txt := "无前任"
		var prev_holder: int = _world.politics_positions[pos] if pos < _world.politics_positions.size() else -1
		if prev_holder >= 0 and prev_holder < _world.politicians.size() and prev_holder != idx:
			var pp: PoliticianData = _world.politicians[prev_holder]
			var extra: int = 400 if pp != null and pp.wanted_position == pos else 0
			var mat_txt := "" if int(pen[1]) < 0 else "（矩阵 -%d）" % (int(pen[1]) + extra)
			prev_txt = "前任忠诚 -%d %s" % [int(pen[0]) + extra, mat_txt]
		tip += "\n预测：本人忠诚 +%d ｜ %s" % [gain, prev_txt]
		rows.append({
			"id": pos,
			"text": "%s%s" % [PolityProfile.post_display_name(_world, pos), "（现任）" if _world.politics_positions[pos] == idx else ""],
			"disabled": not allowed,
			"tip": tip,
		})
	return rows


## 统一任职资格（目录驱动）：非调查中 ∧ 未任该职 ∧（档位达标 ∨ 忠诚≥700∧gamerule5==1 ∨ gamerule5==2）
func _slot_allowed(pol: PoliticianData, tier: int, pos: int) -> bool:
	if pol == null or pol.is_under_investigation:
		return false
	if _world.politics_positions[pos] == _selected_pol_index:
		return false
	var min_tier: int = PositionCatalog.def(pos).get("min_tier", 3)
	if tier <= min_tier:
		return true
	if pol.loyalty >= 700 and _game_rule(5) == 1:
		return true
	return _game_rule(5) == 2


func _position_tip(pol: PoliticianData, pos: int) -> String:
	if pol.is_under_investigation:
		return " 正 被 纪 律 审 查"
	if _world.politics_positions[pos] == _selected_pol_index:
		return " 已 任 命"
	return " 足 够 显 赫 的\n 政 治 地 位"


func _build_action_states(pol: PoliticianData) -> Dictionary:
	var d := _world
	var idx := _selected_pol_index
	var tier := _get_tier(idx)
	var investigating := pol.is_under_investigation
	var surveilling := pol.is_under_surveillance
	var mao_protected: bool = GameManager.is_mao_protected(idx)
	var money1 := _money_ok(1)
	var money20 := _money_ok(20)
	var money100 := _money_ok(100)

	var support_tip := " 花 费 1 资 金 与\n0.5 特 工 网 络"
	if _leader_property(3):
		support_tip = " 免 费"
	var suppress_tip := " 花 费 1 资 金 与\n2 特 工 网 络"
	if mao_protected:
		suppress_tip = " 伟 大 的 舵 手 万 岁 ！"
	elif investigating:
		suppress_tip = " 正 被 纪 律 审 查"
	var kill_tip := " 花 费 2 资 金 与\n6 特 工 网 络"
	if mao_protected:
		kill_tip = " 伟 大 的 舵 手 万 岁 ！"
	elif not _assassinate_historic_allowed(idx):
		kill_tip = " 等 待 事 件"
	elif investigating:
		kill_tip = " 正 被 纪 律 审 查"
	var inv_cost := int(20 * PolityProfile.action_cost_multiplier(_world, "investigate"))
	var srv_cost := int(30 * PolityProfile.action_cost_multiplier(_world, "surveil"))
	var invest_tip := " 花 费 %d 特 工 网 络" % roundi(inv_cost / 10.0)
	if mao_protected:
		invest_tip = " 伟 大 的 舵 手 万 岁 ！"
	elif investigating:
		invest_tip = " 正 被 纪 律 审 查"
	elif _leader_property(1):
		invest_tip = " 可 免 费 调 查"
	var surveil_tip := " 花 费 %d 特 工 网 络" % roundi(srv_cost / 10.0)
	if mao_protected:
		surveil_tip = " 伟 大 的 舵 手 万 岁 ！"
	elif investigating:
		surveil_tip = " 正 被 纪 律 审 查"
	elif surveilling:
		surveil_tip = " 正 被 监 察 调 查"
	elif _leader_property(1):
		surveil_tip = " 可 免 费 监 视"
	var faction_tip := " 花 费 10 资 金 与\n10 特 工 网 络"
	if not GameManager.is_mao_dead():
		faction_tip = " 伟 大 的 舵 手 万 岁 ！"
	elif investigating:
		faction_tip = " 正 被 纪 律 审 查"
	elif _faction_leader_slot_of(idx) >= 0:
		faction_tip = " 已 任 命"

	return {
		"support": {"visible": true, "disabled": not (money1 and d.agents >= 5 and not investigating), "tip": support_tip},
		"suppress": {"visible": true, "disabled": not (money1 and d.agents >= 20 and not investigating and _tier_allows_negative(tier, pol) and not mao_protected), "tip": suppress_tip},
		"investigate": {"visible": true, "disabled": not (d.agents >= inv_cost and not investigating and _tier_allows_negative(tier, pol) and not mao_protected), "tip": invest_tip},
		"surveil": {"visible": true, "disabled": not (d.agents >= srv_cost and not investigating and not surveilling and _tier_allows_negative(tier, pol) and not mao_protected), "tip": surveil_tip},
		"auto_support": {"visible": true, "disabled": not (pol.auto_support == 10 or (money1 and d.agents >= 5 and not investigating)), "tip": support_tip},
		"auto_hound": {"visible": true, "disabled": not (pol.auto_hound == 10 or (money1 and d.agents >= 20 and not investigating and _tier_allows_negative(tier, pol) and not mao_protected)), "tip": suppress_tip},
		"reeducate": {"visible": true, "disabled": not (money20 and not investigating and d.agents >= 60 and _assassinate_historic_allowed(idx) and not mao_protected and _assassinate_modifier_allowed(idx)), "tip": kill_tip,
			"text": ("弹　劾" if d.party_system > GameConstants.PartySystem.NEW_DEMOCRACY else "送去再教育")},
		"faction_leader": {
			"visible": true,
			"disabled": not (money100 and d.agents >= 100 and _faction_leader_slot_of(idx) < 0 and not investigating and tier <= 2 and GameManager.is_mao_dead()),
			"tip": faction_tip,
		},
	}


func _on_window_action(action_id: String) -> void:
	match action_id:
		"support": _on_support()
		"suppress": _on_suppress()
		"investigate": _on_investigate()
		"surveil": _on_surveil()
		"auto_support": _on_auto_support()
		"auto_hound": _on_auto_suppress()
		"reeducate": _on_assassinate()
		"faction_leader": _on_set_faction_leader()
		"leader_cmc": _on_assign_leader_cmc()


# ============================================================================
# 操作回调（逐字移植 Button_Pol_Script.OnMouseDown）
# ============================================================================
@warning_ignore_start("integer_division")

func _on_support() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	GameManager.add_party_support(-20)
	var year: int = _world.year
	if not _leader_property(3):
		GameManager.add_budget(-1)
		GameManager.add_agents(-5)
	GameManager.add_politician_power(pol, (year - 1976) * 5)
	GameManager.add_politician_loyalty(pol, 50)
	GameManager.add_politician_power(pol, absi(pol.power / 10))
	_after_operation()


func _on_suppress() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	if GameManager.is_mao_protected(_selected_pol_index):
		return
	GameManager.add_budget(-1)
	GameManager.add_party_support(-20)
	GameManager.add_agents(-20)
	GameManager.add_politician_loyalty(pol, -50)
	var year: int = _world.year
	GameManager.add_politician_power(pol, -((year - 1976) * 5))
	GameManager.add_politician_power(pol, -absi(pol.power / 10))
	_after_operation()


func _on_assassinate() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	if GameManager.is_mao_protected(_selected_pol_index):
		return
	var idx := _selected_pol_index
	if pol.is_under_investigation:
		GameManager.add_agents(-60)
	else:
		GameManager.add_agents(-100)
	GameManager.add_budget(-20)
	GameManager.add_thought_freedom(100)

	var success_rate: float = GameManager.change_of_killing(idx)
	var roll: float = _world.ensure_rng().randf()
	if roll <= success_rate:
		if _faction_leader_slot_of(idx) >= 0:
			_apply_trait_loyalty(pol, -300)
		else:
			_apply_trait_loyalty(pol, -5)
		if _world.size() > 110:
			GameManager.add_political_repression_count(1)
		if _world.size() > 110 and _world.political_repression_count >= 44:
			Achievements.set_achievement(24)
		if _world.politics_positions[0] == idx:
			GameManager.set_politician_killed_flag(0)
		if _world.politics_positions[1] == idx:
			GameManager.set_politician_killed_flag(1)
		if _world.politics_positions[2] == idx:
			GameManager.set_politician_killed_flag(2)
		GameManager.kill_politician(idx)
	else:
		for p in _world.politicians:
			if p == null:
				continue
			GameManager.add_politician_loyalty(p, -100)
		GameManager.add_politician_loyalty(pol, -400)
		GameManager.set_politician_you_fall(pol, true)
	_after_operation()


func _on_investigate() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	if GameManager.is_mao_protected(_selected_pol_index):
		return
	GameManager.set_politician_investigation(pol, true)
	GameManager.set_politician_investigator(pol, 0)
	if not _leader_property(1):
		GameManager.add_agents(-int(20 * PolityProfile.action_cost_multiplier(_world, "investigate")))
	if _faction_leader_slot_of(_selected_pol_index) >= 0:
		_apply_trait_loyalty(pol, -1000)
	else:
		_apply_trait_loyalty(pol, -100)
	GameManager.add_politician_loyalty(pol, -2000)
	_after_operation()


func _on_surveil() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	if GameManager.is_mao_protected(_selected_pol_index):
		return
	GameManager.set_politician_surveillance(pol, true)
	GameManager.set_politician_surveillance_days(pol, 0)
	if not _leader_property(1):
		GameManager.add_agents(-int(30 * PolityProfile.action_cost_multiplier(_world, "surveil")))
	_after_operation()


func _on_auto_support() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	GameManager.toggle_politician_auto_support(pol)
	_after_operation()


func _on_auto_suppress() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	if GameManager.is_mao_protected(_selected_pol_index):
		return
	GameManager.toggle_politician_auto_hound(pol)
	_after_operation()


func _on_assign_leader_cmc() -> void:
	if _selected_pol_index != LEADER_SELECT:
		return
	GameManager.assign_leader_cmc()
	_after_operation()


func _on_set_faction_leader() -> void:
	var pol := _get_selected_pol()
	if pol == null or _selected_pol_index < 0:
		return
	if not GameManager.set_faction_leader_politician(_selected_pol_index):
		return
	# 冻结清单 §13-1 修复：补扣门槛费（内部 100/100，tooltip 显示"10资金/10特工"）
	GameManager.add_budget(-100)
	GameManager.add_agents(-100)
	_after_operation()


func _on_assign_position(position_id: int) -> void:
	if _selected_pol_index < 0:
		return
	if not GameManager.assign_politician_position(_selected_pol_index, position_id):
		return
	_after_operation()


# ============================================================================
# 辅助（与旧版一致）
# ============================================================================

func _faction_leader_slot_of(pol_index: int) -> int:
	for fi in _world.factions.size():
		if _world.factions[fi].leader_index == pol_index:
			return fi
	return -1


func _apply_trait_loyalty(pol: PoliticianData, delta: int) -> void:
	for p in _world.politicians:
		if p != null and p.trait_personality == pol.trait_personality:
			GameManager.add_politician_loyalty(p, delta)


func _after_operation() -> void:
	# 原版 ResetPolitics：操作后取消选中（含小窗）
	_selected_pol_index = -1
	if _window.is_open():
		_window.close()
	_full_refresh()
	GameManager.stats_changed.emit()


func _on_stats_changed() -> void:
	if _world == null:
		return
	_full_refresh()
	if _window and _window.is_open():
		if _selected_pol_index >= 0 or _selected_pol_index == LEADER_SELECT:
			_open_window()
		else:
			_window.close()


func _goto_diplomacy() -> void:
	get_tree().change_scene_to_file(外交场景)


func _get_selected_pol() -> PoliticianData:
	if _selected_pol_index >= 0 and _selected_pol_index < _world.politicians.size():
		return _world.politicians[_selected_pol_index]
	return null


func _get_tier(pol_index: int) -> int:
	for slot in _sorted_indices.size():
		if _sorted_indices[slot] == pol_index:
			if slot < 3:
				return 1
			if slot < 7:
				return 2
			if slot < 12:
				return 3
			return 4
	return 1


func _tier_allows_negative(tier: int, pol: PoliticianData) -> bool:
	if tier <= 3:
		return true
	if pol and pol.loyalty >= 700 and _game_rule(5) == 1:
		return true
	return _game_rule(5) == 2


func _assassinate_historic_allowed(idx: int) -> bool:
	var d := _world
	var ev25 := _world.completed_event_ids.has("gang_of_four")
	var ev26 := _world.completed_event_ids.has("weak_alliance")
	var basic := idx > 5 and idx != 7 and (idx < 11 or idx > 15) and idx != 17
	var e25a := ev25 and d.gang_of_four_path != 3 and (idx < 12 or idx > 15)
	var e26a := ev26 and ((_world.leader != null and _world.leader.name_first != 0) or idx == 1)
	var year_ok := d.year >= 1978
	var e25b := ev25 and d.gang_of_four_path == 3 and (idx < 1 or idx > 4)
	return basic or e25a or e26a or year_ok or e25b


func _assassinate_modifier_allowed(idx: int) -> bool:
	var mod3: bool = GameManager._mod_active(_world, GameConstants.Modifier.CULTURAL_REVOLUTION)
	var ev80 := _world.completed_event_ids.has("event_080")
	return (idx > 4 or not mod3 or ev80) and (idx > 4 or idx == 2 or not mod3 or not ev80)


func _can_assign_leader_cmc() -> bool:
	return GameManager.is_mao_dead() and _world.politics_positions[1] != LEADER_POS


func _money_ok(amount: int) -> bool:
	return _world.budget + _world.reserve >= amount


func _game_rule(idx: int) -> int:
	return PoliticianSystem._game_rule(_world, idx)


func _leader_property(idx: int) -> bool:
	return _world.get_flag("leader_property_%d" % idx)
