extends Control
## 政治界面主脚本。对应原版 Politic_Manager + Button_Pol_Script。
## 数据源: GameManager.world (WorldState)

const W = preload("res://数据脚本/world_state.gd")
const 外交场景 := "uid://vq6jexkk5tru"
const LEADER_SELECT := -150  ## 原版 selected_politic == 150
const LEADER_POS := -2       ## 与 WorldFactory.LEADER_POSITION_SENTINEL 一致

# ── 职位名称 ──
const POSITION_NAMES: Array[String] = [
	"总理", "军委主席", "外交部长",
	"首都主管", "北方主管", "西方主管", "南方主管", "东方主管",
]

# ── 影响力等级 ──
const POWER_LABELS := [
	[250, "不知名"],
	[500, "小有名气"],
	[700, "有影响力"],
	[99999, "非常有影响力"],
]

# ── 操作消耗（对齐原版 Button_Pol_Script.Repaint/OnMouseDown）──
# 支持: budget>=1 agents>=5；打压: budget>=1 agents>=20；调查 agents>=20；监视 agents>=30
const COST_SUPPORT_BUDGET := 1
const COST_SUPPORT_AGENTS := 5
const COST_SUPPRESS_BUDGET := 1
const COST_SUPPRESS_AGENTS := 20
const COST_INVESTIGATE_AGENTS := 20
const COST_SURVEIL_AGENTS := 30

var _world: WorldState
var _cards: Array = []
var _sorted_indices: Array[int] = []
## -1 未选；LEADER_SELECT 实权领袖；>=0 politicians 索引
var _selected_pol_index: int = -1
var _hover_target: int = -1

# ── 左栏节点 ──
@onready var _left_name: Label = $左栏_当前选中政治家姓名
@onready var _left_faction: Label = $左栏_当前选中政治家派系
@onready var _left_trait1: Label = $左栏_当前选中政治家特质1
@onready var _left_trait2: Label = $左栏_当前选中政治家特质2
@onready var _left_status: Label = $左栏_当前选中政治家状态

# ── 职位标签 ──
@onready var _pos_premier: Label = $国务院总理
@onready var _pos_cmc: Label = $中央军委主席
@onready var _pos_foreign: Label = $外交部长
@onready var _pos_capital: Label = $首都主管
@onready var _pos_north: Label = $北方主管
@onready var _pos_west: Label = $西方主管
@onready var _pos_south: Label = $南方主管
@onready var _pos_east: Label = $东方主管

# ── 实权领袖 ──
@onready var _leader_portrait: TextureRect = $实权领袖肖像
@onready var _leader_bg: TextureRect = $实权领袖背景

# ── 右栏 ──
@onready var _budget_label: Label = $右栏数据/预算
@onready var _agents_label: Label = $右栏数据/特工网络

# ── 操作按钮 ──
@onready var _btn_support: Button = $支持
@onready var _btn_suppress: Button = $打压
@onready var _btn_assassinate: Button = $送去再教育
@onready var _btn_investigate: Button = $开始调查
@onready var _btn_surveil: Button = $监视
@onready var _btn_auto_support: Button = $自动支持
@onready var _btn_auto_suppress: Button = $自动打压
@onready var _btn_faction_leader: Button = $指定为派系负责人

@onready var _btn_pos_premier: Button = $调往国务院
@onready var _btn_pos_cmc: Button = $调往中央军委
@onready var _btn_pos_foreign: Button = $调往外交部
@onready var _btn_pos_capital: Button = $调往首都
@onready var _btn_pos_north: Button = $调往北方
@onready var _btn_pos_west: Button = $调往西方
@onready var _btn_pos_south: Button = $调往南方
@onready var _btn_pos_east: Button = $调往东方

@onready var _btn_return: TextureButton = $返回外交界面


func _ready() -> void:
	_world = GameManager.world
	if _world == null:
		push_error("政治界面: GameManager.world 为空")
		return

	_collect_cards()
	_connect_buttons()
	_setup_leader_click()
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
		_refresh_left_panel()
		_update_button_states()


# ============================================================================
# 初始化
# ============================================================================

func _collect_cards() -> void:
	for i in range(1, 19):
		var card_node = get_node_or_null("政治家%d" % i)
		if card_node:
			_cards.append(card_node)
			card_node.card_hovered.connect(_on_card_hovered)
			card_node.card_unhovered.connect(_on_card_unhovered)
			card_node.card_clicked.connect(_on_card_clicked)


func _setup_leader_click() -> void:
	# 原版 this_number==150：可点选查看，操作按钮区隐藏
	if _leader_portrait:
		_leader_portrait.mouse_filter = Control.MOUSE_FILTER_STOP
		_leader_portrait.gui_input.connect(_on_leader_gui_input)
	if _leader_bg:
		_leader_bg.mouse_filter = Control.MOUSE_FILTER_STOP
		_leader_bg.gui_input.connect(_on_leader_gui_input)


func _on_leader_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_selected_pol_index = LEADER_SELECT
		_refresh_left_panel()
		_update_button_states()
		accept_event()


func _connect_buttons() -> void:
	_btn_support.pressed.connect(_on_support)
	_btn_suppress.pressed.connect(_on_suppress)
	_btn_assassinate.pressed.connect(_on_assassinate)
	_btn_investigate.pressed.connect(_on_investigate)
	_btn_surveil.pressed.connect(_on_surveil)
	_btn_auto_support.pressed.connect(_on_auto_support)
	_btn_auto_suppress.pressed.connect(_on_auto_suppress)
	_btn_faction_leader.pressed.connect(_on_set_faction_leader)

	_btn_pos_premier.pressed.connect(_on_assign_position.bind(0))
	_btn_pos_cmc.pressed.connect(_on_assign_position.bind(1))
	_btn_pos_foreign.pressed.connect(_on_assign_position.bind(2))
	_btn_pos_capital.pressed.connect(_on_assign_position.bind(3))
	_btn_pos_north.pressed.connect(_on_assign_position.bind(4))
	_btn_pos_west.pressed.connect(_on_assign_position.bind(5))
	_btn_pos_south.pressed.connect(_on_assign_position.bind(6))
	_btn_pos_east.pressed.connect(_on_assign_position.bind(7))

	_btn_return.pressed.connect(_goto_diplomacy)


# ============================================================================
# 全量刷新
# ============================================================================

func _full_refresh() -> void:
	if _world == null:
		return
	_balance_politic()
	_populate_cards()
	_refresh_positions()
	_refresh_leader()
	_refresh_right_panel()
	_refresh_left_panel()
	_update_button_states()
	_repaint_loyalty_bars()


func _balance_politic() -> void:
	_sorted_indices.clear()
	for i in _world.politicians.size():
		_sorted_indices.append(i)
	_sorted_indices.sort_custom(func(a: int, b: int) -> bool:
		return _world.politicians[a].power > _world.politicians[b].power
	)


func _populate_cards() -> void:
	for slot in _cards.size():
		if slot < _sorted_indices.size():
			var pol_idx: int = _sorted_indices[slot]
			var pol: PoliticianData = _world.politicians[pol_idx]
			_cards[slot].visible = true
			_cards[slot].setup(pol, pol_idx)
		else:
			_cards[slot].visible = false


func _refresh_positions() -> void:
	var pos_labels: Array[Label] = [
		_pos_premier, _pos_cmc, _pos_foreign,
		_pos_capital, _pos_north, _pos_west, _pos_south, _pos_east,
	]
	for i in pos_labels.size():
		var holder: int = _world.politics_positions[i] if i < _world.politics_positions.size() else -1
		if holder == LEADER_POS:
			pos_labels[i].text = _world.leader.name_display if _world.leader else "实权领袖"
		elif holder >= 0 and holder < _world.politicians.size():
			pos_labels[i].text = _world.politicians[holder].name_display
		else:
			pos_labels[i].text = "空缺"


func _refresh_leader() -> void:
	if _world.leader and _world.leader.portrait:
		_leader_portrait.texture = _world.leader.portrait
	elif _world.leader_politician_index >= 0 and _world.leader_politician_index < _world.politicians.size():
		var p: PoliticianData = _world.politicians[_world.leader_politician_index]
		if p and p.portrait:
			_leader_portrait.texture = p.portrait


func _refresh_right_panel() -> void:
	_budget_label.text = _world.display_meter(_world.数值表[W.I_BUDGET])
	_agents_label.text = _world.display_meter(_world.数值表[W.I_AGENTS])


# ============================================================================
# 左栏 — 选中政治家 / 实权领袖详情
# ============================================================================

func _refresh_left_panel() -> void:
	if _selected_pol_index == LEADER_SELECT:
		_refresh_left_for_leader()
		return
	if _selected_pol_index < 0 or _selected_pol_index >= _world.politicians.size():
		_left_name.text = ""
		_left_faction.text = ""
		_left_trait1.text = ""
		_left_trait2.text = ""
		_left_status.text = "未选中任何政治家"
		return

	var pol: PoliticianData = _world.politicians[_selected_pol_index]
	_left_name.text = "%s（%d岁）" % [pol.name_display, pol.age]
	_left_faction.text = pol.ideology_label()
	_left_trait1.text = pol.alignment_label()
	_left_trait2.text = WorldFactory.TRAIT_LABELS_ZH.get(pol.trait_special, "未知")

	var lines: Array[String] = []
	var held_positions: Array[String] = []
	for i in _world.politics_positions.size():
		if _world.politics_positions[i] == _selected_pol_index:
			held_positions.append(POSITION_NAMES[i])
	if held_positions.size() > 0:
		lines.append("职务: %s" % "；".join(held_positions))
	else:
		lines.append("职务: 无")

	if pol.is_under_investigation:
		lines.append("正在接受纪律审查（进度 %d/7）" % clampi(pol.investigator_index, 0, 7))
	else:
		lines.append("尚未被纪律审查")
	if pol.is_under_surveillance:
		var remain_m: int = maxi(0, 7 - pol.days_surveillance)
		lines.append("正在被监察调查（剩余 %d 月）" % remain_m)
	else:
		lines.append("尚未被监察调查")

	if pol.is_under_surveillance and pol.is_conspiracy:
		lines.append("阴谋: 已发现参与阴谋!")
	elif pol.is_under_surveillance:
		lines.append("留置后的影响力未知")

	lines.append("影响力: %d" % pol.power)
	for threshold in POWER_LABELS:
		if pol.power <= threshold[0]:
			lines.append(threshold[1])
			break

	lines.append("忠诚度: %s" % _world.display_meter(pol.loyalty))
	_left_status.text = "\n".join(lines)


func _refresh_left_for_leader() -> void:
	var leader: PoliticianData = _world.leader
	if leader == null:
		_left_status.text = "实权领袖数据缺失"
		return
	_left_name.text = "%s（%d岁）" % [leader.name_display, leader.age]
	_left_faction.text = leader.ideology_label()
	_left_trait1.text = leader.alignment_label()
	_left_trait2.text = WorldFactory.TRAIT_LABELS_ZH.get(leader.trait_special, "未知")

	var lines: Array[String] = ["职务: 实权领袖"]
	for i in _world.politics_positions.size():
		if _world.politics_positions[i] == LEADER_POS:
			lines.append("兼任: %s" % POSITION_NAMES[i])
	_left_status.text = "\n".join(lines)


# ============================================================================
# 操作按钮状态 — 对齐原版 Button_Pol_Script.Repaint
# 原版未选中时按钮区隐藏；我们用 disabled 表达同样的「开局/不可用」
# ============================================================================

func _update_button_states() -> void:
	var selecting_leader := _selected_pol_index == LEADER_SELECT
	var has_pol := _selected_pol_index >= 0 and _selected_pol_index < _world.politicians.size()
	var has_sel := has_pol  # 领袖不开放操作按钮（原版 buttons_obj.SetActive(false)）
	var d := _world.数值表
	var pol: PoliticianData = _get_selected_pol() if has_pol else null
	var tier := _get_tier(_selected_pol_index) if has_pol else 99
	# 原版：data[38]!=100 时不可对 politics[0]（毛泽东）执行负向操作
	var mao_alive_protect := has_pol and _selected_pol_index == 0 and d[W.I_STABILITY] != 100
	var investigating := pol != null and pol.is_under_investigation
	var surveilling := pol != null and pol.is_under_surveillance
	var budget_ok_support := d[W.I_BUDGET] >= COST_SUPPORT_BUDGET and d[W.I_AGENTS] >= COST_SUPPORT_AGENTS
	var budget_ok_suppress := d[W.I_BUDGET] >= COST_SUPPRESS_BUDGET and d[W.I_AGENTS] >= COST_SUPPRESS_AGENTS

	# 全关（未选 / 领袖）
	if not has_sel:
		_set_all_action_buttons(true)
		# 领袖选中时明确禁用操作
		if selecting_leader:
			pass
		return

	# num0 支持
	_btn_support.disabled = not budget_ok_support or investigating
	# num1 打压：tier<=3 或忠诚足够；毛在世保护 politics[0]
	_btn_suppress.disabled = (
		not budget_ok_suppress or investigating or mao_alive_protect
		or not _tier_allows_negative(tier, pol)
	)
	# num2 再教育/暗杀：开局有保护名单 + 资源 + 至少3人忠诚<500
	_btn_assassinate.disabled = not _can_assassinate(pol, tier, mao_alive_protect, investigating)
	# num3 调查
	_btn_investigate.disabled = (
		d[W.I_AGENTS] < COST_INVESTIGATE_AGENTS or investigating or mao_alive_protect
		or not _tier_allows_negative(tier, pol)
	)
	# num4 监视
	_btn_surveil.disabled = (
		d[W.I_AGENTS] < COST_SURVEIL_AGENTS or investigating or surveilling or mao_alive_protect
		or not _tier_allows_negative(tier, pol)
	)
	# num15/16 自动
	_btn_auto_support.disabled = not budget_ok_support and (pol == null or pol.auto_support == 0)
	if pol and pol.auto_support != 0:
		_btn_auto_support.disabled = false
	_btn_auto_suppress.disabled = (
		(not budget_ok_suppress or investigating or mao_alive_protect or not _tier_allows_negative(tier, pol))
		and (pol == null or pol.auto_hound == 0)
	)
	if pol and pol.auto_hound != 0:
		_btn_auto_suppress.disabled = false

	# num14 指定派系负责人：需预算/特工充足、非现任派系领袖、tier<=2、稳定=100
	_btn_faction_leader.disabled = not _can_set_faction_leader(pol, tier)

	# 职位：num7 总理 / num5 军委 / num6 外交 / num8-12 地方
	# 军委需 data[38]==100（毛已故/稳定满）
	_btn_pos_premier.disabled = not _can_assign_central(pol, tier, 0)
	_btn_pos_cmc.disabled = not _can_assign_central(pol, tier, 1) or d[W.I_STABILITY] != 100
	_btn_pos_foreign.disabled = not _can_assign_central(pol, tier, 2)
	_btn_pos_capital.disabled = not _can_assign_regional(pol, tier, 3)
	_btn_pos_north.disabled = not _can_assign_regional(pol, tier, 4)
	_btn_pos_west.disabled = not _can_assign_regional(pol, tier, 5)
	_btn_pos_south.disabled = not _can_assign_regional(pol, tier, 6)
	_btn_pos_east.disabled = not _can_assign_regional(pol, tier, 7)


func _set_all_action_buttons(disabled: bool) -> void:
	for b in [
		_btn_support, _btn_suppress, _btn_assassinate, _btn_investigate, _btn_surveil,
		_btn_auto_support, _btn_auto_suppress, _btn_faction_leader,
		_btn_pos_premier, _btn_pos_cmc, _btn_pos_foreign,
		_btn_pos_capital, _btn_pos_north, _btn_pos_west, _btn_pos_south, _btn_pos_east,
	]:
		b.disabled = disabled


func _tier_allows_negative(tier: int, pol: PoliticianData) -> bool:
	# 原版：num<=3（tier 1-3）允许；tier4 需 loyalty>=700 且规则放宽（我们默认严格）
	if tier <= 3:
		return true
	if pol and pol.loyalty >= 700:
		return true
	return false


func _can_assassinate(pol: PoliticianData, tier: int, mao_protect: bool, investigating: bool) -> bool:
	if pol == null or investigating or mao_protect:
		return false
	if not _tier_allows_negative(tier, pol):
		return false
	var d := _world.数值表
	var cost: int = maxi(10, pol.power / 100)
	if d[W.I_BUDGET] < cost or d[W.I_AGENTS] < cost or d[W.I_ARMY] < cost:
		return false
	# 至少 3 人对目标忠诚 < 500
	var low_count := 0
	for p in _world.politicians:
		if p == null:
			continue
		if _selected_pol_index < p.loyalty_matrix.size() and p.loyalty_matrix[_selected_pol_index] < 500:
			low_count += 1
	if low_count < 3:
		return false
	# 开局保护名单（原版 data[21]<1978 且相关事件未完成时限制）
	if d[21] < 1978 and _is_early_protected(_selected_pol_index):
		return false
	return true


func _is_early_protected(idx: int) -> bool:
	# 原版复杂条件的保守近似：核心历史人物早期不可再教育
	# selected <=5 or ==7 or 11..15 or ==17
	if idx <= 5 or idx == 7 or idx == 17:
		return true
	if idx >= 11 and idx <= 15:
		return true
	return false


func _can_set_faction_leader(pol: PoliticianData, tier: int) -> bool:
	if pol == null:
		return false
	var d := _world.数值表
	if d[W.I_STABILITY] != 100:
		return false
	if d[W.I_BUDGET] < 100 or d[W.I_AGENTS] < 100:
		return false
	if tier > 2:
		return false
	if pol.is_under_investigation:
		return false
	if _is_faction_leader(_selected_pol_index):
		return false
	return true


func _can_assign_central(pol: PoliticianData, tier: int, pos: int) -> bool:
	if pol == null or pol.is_under_investigation:
		return false
	if tier > 2 and not (pol.loyalty >= 700):
		return false
	if _world.politics_positions[pos] == _selected_pol_index:
		return false
	return true


func _can_assign_regional(pol: PoliticianData, tier: int, pos: int) -> bool:
	if pol == null or pol.is_under_investigation:
		return false
	if tier > 3 and not (pol.loyalty >= 700):
		return false
	if _world.politics_positions[pos] == _selected_pol_index:
		return false
	return true


func _get_selected_pol() -> PoliticianData:
	if _selected_pol_index >= 0 and _selected_pol_index < _world.politicians.size():
		return _world.politicians[_selected_pol_index]
	return null


func _get_tier(pol_index: int) -> int:
	# 原版层级：first(3)=1, second(4)=2, third(5)=3, forth(6)=4
	for slot in _sorted_indices.size():
		if _sorted_indices[slot] == pol_index:
			if slot < 3:
				return 1
			if slot < 7:
				return 2
			if slot < 12:
				return 3
			return 4
	return 99


# ============================================================================
# 卡片信号 — 忠诚条
# ============================================================================

func _on_card_hovered(pol_index: int) -> void:
	_hover_target = pol_index
	_repaint_loyalty_bars()


func _on_card_unhovered() -> void:
	_hover_target = -1
	_repaint_loyalty_bars()


func _repaint_loyalty_bars() -> void:
	for card in _cards:
		card.update_loyalty_bar(_hover_target)


func _on_card_clicked(pol_index: int) -> void:
	_selected_pol_index = pol_index
	_refresh_left_panel()
	_update_button_states()


# ============================================================================
# 操作回调 — 移植自原版 Button_Pol_Script.OnMouseDown
# ============================================================================
@warning_ignore_start("integer_division")

func _on_support() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	var d := _world.数值表
	d[W.I_BUDGET] -= COST_SUPPORT_BUDGET
	d[W.I_AGENTS] -= COST_SUPPORT_AGENTS
	# ECO-POL-03 / POL-11：对齐原版扣党支持
	d[W.I_PARTY_SUPPORT] -= 20
	pol.loyalty += 50
	pol.power += absi(pol.power / 10)
	_after_operation()


func _on_suppress() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	var d := _world.数值表
	d[W.I_BUDGET] -= COST_SUPPRESS_BUDGET
	d[W.I_AGENTS] -= COST_SUPPRESS_AGENTS
	d[W.I_PARTY_SUPPORT] -= 20
	pol.loyalty -= 50
	pol.power -= absi(pol.power / 10)
	_after_operation()


func _on_assassinate() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	var d := _world.数值表
	var cost: int = maxi(10, pol.power / 100)
	d[W.I_BUDGET] -= cost
	d[W.I_AGENTS] -= cost
	d[W.I_ARMY] -= cost
	d[W.I_THOUGHT_FREEDOM] += 100

	if _is_faction_leader(_selected_pol_index):
		_apply_faction_loyalty_penalty(_selected_pol_index, -300)
	else:
		_apply_faction_loyalty_penalty(_selected_pol_index, -5)
	GameManager.kill_politician(_selected_pol_index)
	if d.size() > 110:
		d[110] += 1
	_selected_pol_index = -1
	_after_operation()


func _on_investigate() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	var d := _world.数值表
	d[W.I_AGENTS] -= COST_INVESTIGATE_AGENTS
	pol.is_under_investigation = true
	pol.investigator_index = 0
	if _is_faction_leader(_selected_pol_index):
		_apply_faction_loyalty_penalty(_selected_pol_index, -1000)
	else:
		_apply_faction_loyalty_penalty(_selected_pol_index, -100)
	pol.loyalty -= 2000
	_after_operation()


func _on_surveil() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	var d := _world.数值表
	d[W.I_AGENTS] -= COST_SURVEIL_AGENTS
	pol.is_under_surveillance = true
	# 原版从 0 起每月 +1，满 7 解除（TimeScript ~2184）
	pol.days_surveillance = 0
	_after_operation()


func _on_auto_support() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	# 原版 0 <-> 10
	pol.auto_support = 10 if pol.auto_support == 0 else 0
	_after_operation()


func _on_auto_suppress() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	pol.auto_hound = 10 if pol.auto_hound == 0 else 0
	_after_operation()


func _on_set_faction_leader() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	# Party 槽：traits[0]==0→0，否则 traits[0]+1（原版跳过「保守」位）
	var faction_id: int = pol.party_index()
	if faction_id >= 0 and faction_id < _world.factions.size():
		var prev: int = _world.factions[faction_id].leader_index
		if prev >= 0 and prev < _world.politicians.size():
			_world.politicians[prev].loyalty -= 1000
			if _selected_pol_index < _world.politicians[prev].loyalty_matrix.size():
				_world.politicians[prev].loyalty_matrix[_selected_pol_index] -= 500
		_world.factions[faction_id].leader_index = _selected_pol_index
		_apply_faction_loyalty_penalty(_selected_pol_index, -100)
		pol.loyalty += 400
	_after_operation()


func _on_assign_position(position_id: int) -> void:
	var pol := _get_selected_pol()
	if pol == null or _selected_pol_index < 0:
		return

	# 地方职位互斥（3-7）；中央职位也清掉地方兼任
	for i in range(3, 8):
		if _world.politics_positions[i] == _selected_pol_index:
			_world.politics_positions[i] = -1
	if position_id == 0:
		for i in range(1, 8):
			if _world.politics_positions[i] == _selected_pol_index:
				_world.politics_positions[i] = -1
	elif position_id == 1 or position_id == 2:
		var other_central := 2 if position_id == 1 else 1
		if _world.politics_positions[other_central] == _selected_pol_index:
			_world.politics_positions[other_central] = -1

	var prev_holder: int = _world.politics_positions[position_id]
	if prev_holder >= 0 and prev_holder < _world.politicians.size():
		var prev_pol: PoliticianData = _world.politicians[prev_holder]
		prev_pol.loyalty -= 1000
		if _selected_pol_index < prev_pol.loyalty_matrix.size():
			prev_pol.loyalty_matrix[_selected_pol_index] = maxi(
				0, prev_pol.loyalty_matrix[_selected_pol_index] - 500
			)

	_world.politics_positions[position_id] = _selected_pol_index
	pol.loyalty += 250
	_after_operation()


# ============================================================================
# 辅助
# ============================================================================

func _is_faction_leader(pol_index: int) -> bool:
	for f in _world.factions:
		if f.leader_index == pol_index:
			return true
	return false


func _apply_faction_loyalty_penalty(pol_index: int, penalty: int) -> void:
	var pol: PoliticianData = _world.politicians[pol_index]
	# 同派系惩罚：按 Party 槽（faction/party_index），与卡片派系一致
	var faction_id: int = pol.party_index()
	for i in _world.politicians.size():
		var other: PoliticianData = _world.politicians[i]
		if other != null and other.party_index() == faction_id and i != pol_index:
			other.loyalty += penalty


func _after_operation() -> void:
	_full_refresh()
	GameManager.stats_changed.emit()


func _on_stats_changed() -> void:
	_refresh_right_panel()
	_update_button_states()


func _goto_diplomacy() -> void:
	音频总管.play_button_click_sound()
	get_tree().change_scene_to_file(外交场景)
