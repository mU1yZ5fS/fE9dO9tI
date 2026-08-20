extends Control
## 政治界面主脚本。
## 对齐原版 Politic_Manager.cs + Button_Pol_Script.cs 的中文语言分支（language==0）。
## 改版保留：中文真实姓名 + 真实照片；其余文案/颜色/数值/按钮逻辑逐字对齐。
## 数据源: GameManager.world (WorldState)

const W = preload("res://数据脚本/world_state.gd")
const 外交场景 := "uid://vq6jexkk5tru"
const LEADER_SELECT := -150  ## 原版 selected_politic == 150
const LEADER_POS := -2       ## 原版 politics_dolshnost 值 150（Godot 哨兵）

# ── 左栏职位 / 主管文案（Politic_Manager.cs:81-115）──
const POSITION_NAMES: Array[String] = [
	"国务院总理", "中央军委主席", "外交部长",
	"京 畿", "华 北", "华 西", "华 南", "华 东",
]

# ── 派系领袖标题与颜色（Politic_Manager.cs:61-80，颜色按 faction_leader 槽 0..4）──
const FACTION_LEADER_TITLES: Array[String] = [
	"极 左 派 领 袖", "保 守 派 领 袖", "温 和 派 领 袖",
	"改 革 派 领 袖", "自 由 派 领 袖",
]
const FACTION_LEADER_COLORS: Array[String] = [
	"red", "purple", "fuchsia", "green", "aqua",
]

# ── 影响力档位（Politic_Manager.cs:136-151）──
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

# ── 左栏节点（原版 name_pol / traits[4] / t_zagovor）──
@onready var _left_name: Label = $左栏_当前选中政治家姓名
@onready var _left_trait0: Label = $左栏_当前选中政治家派系  # 显示 traits[0]，见 _refresh_traits
@onready var _left_trait1: Label = $左栏_当前选中政治家特质1
@onready var _left_trait2: Label = $左栏_当前选中政治家特质2
@onready var _left_trait3: Label = get_node_or_null("左栏_当前选中政治家特质3") as Label
@onready var _left_status: RichTextLabel = $左栏_当前选中政治家状态

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
var _leader_no_portrait_label: Label

# ── 右栏 ──
@onready var _budget_label: Label = $右栏数据/预算
@onready var _agents_label: Label = $右栏数据/特工网络

# ── 操作按钮（编号对齐原版 Button_Pol_Script.num）──
@onready var _btn_support: Button = $支持                      # num0
@onready var _btn_suppress: Button = $打压                    # num1
@onready var _btn_assassinate: Button = $送去再教育            # num2
@onready var _btn_investigate: Button = $开始调查              # num3
@onready var _btn_surveil: Button = $监视                      # num4
@onready var _btn_auto_support: Button = $自动支持              # num15
@onready var _btn_auto_suppress: Button = $自动打压             # num16
@onready var _btn_faction_leader: Button = $指定为派系负责人     # num14
@onready var _btn_pos_premier: Button = $调往国务院            # num7
@onready var _btn_pos_cmc: Button = $调往中央军委               # num5
@onready var _btn_pos_foreign: Button = $调往外交部             # num6
@onready var _btn_pos_capital: Button = $调往首都               # num8
@onready var _btn_pos_north: Button = $调往北方                 # num9
@onready var _btn_pos_west: Button = $调往西方                  # num11
@onready var _btn_pos_south: Button = $调往南方                 # num10
@onready var _btn_pos_east: Button = $调往东方                  # num12
## 领袖专属按钮（原版 button_lead_obj 内的 num13）
@onready var _btn_leader_cmc: Button = get_node_or_null("任命领袖军委") as Button

@onready var _btn_return: TextureButton = $返回外交界面

var _action_buttons: Array[Button] = []


func _ready() -> void:
	_world = GameManager.world
	if _world == null:
		push_error("政治界面: GameManager.world 为空")
		return

	_action_buttons = [
		_btn_support, _btn_suppress, _btn_assassinate, _btn_investigate, _btn_surveil,
		_btn_auto_support, _btn_auto_suppress, _btn_faction_leader,
		_btn_pos_premier, _btn_pos_cmc, _btn_pos_foreign,
		_btn_pos_capital, _btn_pos_north, _btn_pos_west, _btn_pos_south, _btn_pos_east,
	]
	_collect_cards()
	_connect_buttons()
	_setup_leader_click()
	# 实权领袖无真实肖像时显示“无肖像”文字
	_leader_no_portrait_label = Label.new()
	_leader_no_portrait_label.text = "无肖像"
	_leader_no_portrait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_leader_no_portrait_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_leader_no_portrait_label.add_theme_font_size_override("font_size", 22)
	_leader_no_portrait_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4, 1))
	_leader_no_portrait_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_leader_no_portrait_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_leader_portrait.add_child(_leader_no_portrait_label)
	GameManager.stats_changed.connect(_on_stats_changed)
	_full_refresh()


func _exit_tree() -> void:
	if GameManager and GameManager.stats_changed.is_connected(_on_stats_changed):
		GameManager.stats_changed.disconnect(_on_stats_changed)


func _input(event: InputEvent) -> void:
	# 原版 Politic_Manager.Update：Esc → Diplomacy
	if event.is_action_pressed("ui_cancel"):
		_goto_diplomacy()


func _gui_input(event: InputEvent) -> void:
	# 原版 Politics_Hide_Script.OnMouseDown：点空白 → Politic_Selected(200)
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
	# 原版 Politic_Script.this_number==150：可点选查看，按钮区切换为 button_lead_obj
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

	if _btn_leader_cmc:
		_btn_leader_cmc.pressed.connect(_on_assign_leader_cmc)

	_btn_return.pressed.connect(_goto_diplomacy)


# ============================================================================
# 全量刷新（原版 Politic_Manager.RepaintData + ResetPolitics + RepaintAll）
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
	# 原版 GameState.BalancePolitic：18 人按 power 降序填 first(3)/second(4)/third(5)/forth(6)
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
	# 原版 Politic_Show_Data.Repaint：data[num]/10f，一位小数（{0:F1}）
	_budget_label.text = _world.display_meter(_world.数值表[W.I_BUDGET])
	_agents_label.text = _world.display_meter(_world.数值表[W.I_AGENTS])


# ============================================================================
# 左栏 — 逐字对齐 Politic_Manager.Politic_Selected（中文分支）
# ============================================================================

func _refresh_left_panel() -> void:
	if _selected_pol_index == LEADER_SELECT:
		_refresh_left_for_leader()
		return
	if _selected_pol_index < 0 or _selected_pol_index >= _world.politicians.size():
		_left_name.text = ""
		_refresh_traits(null)
		_left_status.text = ""
		return

	var pol: PoliticianData = _world.politicians[_selected_pol_index]
	# 改版保留中文姓名（原版为 first_names + " " + second_names + " (age)"）
	_left_name.text = "%s（%d岁）" % [pol.name_display, pol.age]
	_refresh_traits(pol)

	var sb := ""
	# 派系领袖标题（Politic_Manager.cs:61-80）
	var lead_slot := _faction_leader_slot_of(_selected_pol_index)
	if lead_slot >= 0 and lead_slot < FACTION_LEADER_TITLES.size():
		sb += "[color=%s]%s[/color]|" % [FACTION_LEADER_COLORS[lead_slot], FACTION_LEADER_TITLES[lead_slot]]

	# 职务 / 主管（Politic_Manager.cs:81-115）
	sb += "职 务 ："
	for i in 3:
		if _world.politics_positions[i] == _selected_pol_index:
			sb += "[color=orange] %s[/color]；" % POSITION_NAMES[i]
	sb += "|主 管 ："
	for i in range(3, 8):
		if _world.politics_positions[i] == _selected_pol_index:
			sb += "[color=yellow] %s [/color]；" % POSITION_NAMES[i]
	sb += "|"

	# 调查 / 监视（Politic_Manager.cs:116-133）
	if pol.is_under_investigation:
		sb += "距 纪 律 审 查 结 束 ：[color=green]%d[/color] 个 月" % clampi(7 - pol.investigator_index, 0, 7)
	else:
		sb += "尚 未 被 纪 律 审 查"
	sb += "|"
	if pol.is_under_surveillance:
		var rate: float = GameManager.change_of_killing(_selected_pol_index)
		sb += "已 处 于 监 察 调 查 ：[color=green]%d[/color] 个 月|留 置 后 的 影 响 ：%s%%" % [
			pol.days_surveillance, rate * 100.0
		]
	else:
		sb += "尚 未 被 监 察 调 查 |留 置 后 的 影 响 未 知"
	sb += "|"

	# 影响力（Politic_Manager.cs:134-151）
	@warning_ignore("integer_division")
	sb += "影 响 力 ：%d.%d |" % [pol.power / 10, absi(pol.power % 10)]
	for threshold in POWER_LABELS:
		if pol.power <= threshold[0]:
			sb += "[color=%s]%s[/color]" % [threshold[2], threshold[1]]
			break
	sb += "|"

	# 暗杀未遂 / 阴谋（Politic_Manager.cs:153-166，注意原版无换行拼接）
	if pol.you_fall:
		sb += "[color=red]不 成 功 的 暗 杀 尝 试[/color]"
	if pol.is_under_surveillance:
		if pol.is_conspiracy:
			sb += "[color=red]处 于 阴 谋 的 威 胁 下[/color]"
		if _is_plotting_against_you(pol):
			sb += "|[color=green]正 在 阴 谋 反 对 你 ！[/color]"

	_left_status.text = _wrap_text(sb, 30)


func _refresh_traits(pol: PoliticianData) -> void:
	# 原版 traits[0..3] 四行（Politic_Script.cs:58-61）。
	# 项目字段映射：trait_personality=traits[0]、trait_alignment=traits[1]、
	# trait_special=traits[2]、trait_background=traits[3]。
	# 显示顺序按用户确认：T1=派系、T2=traits[3] 出身、T3=traits[1] 性格、T4=traits[2] 特殊。
	if pol == null:
		_left_trait0.text = ""
		_left_trait1.text = ""
		_left_trait2.text = ""
		if _left_trait3:
			_left_trait3.text = ""
		return
	_left_trait0.text = WorldFactory.PARTY_LABELS_ZH.get(pol.party_index(), "未知")
	_left_trait1.text = pol.background_label()
	_left_trait2.text = WorldFactory.TRAIT_LABELS_ZH.get(pol.trait_alignment, "未知")
	if _left_trait3:
		_left_trait3.text = WorldFactory.TRAIT_LABELS_ZH.get(pol.trait_special, "未知")


## 原版 Politic_Manager.cs:157-166 的中文阴谋判定（仅在监视中评估）。
func _is_plotting_against_you(pol: PoliticianData) -> bool:
	if pol.is_under_investigation:
		return false
	if pol.trait_special == 17 or pol.trait_special == 19:
		return false
	if pol.loyalty < 450 and (pol.trait_special == 16 or pol.trait_special == 35):
		return true
	if pol.you_fall:
		return true
	if pol.loyalty < 300 and pol.trait_special != 9 and pol.trait_special != 37:
		return true
	if pol.loyalty < 150 and (pol.trait_special == 9 or pol.trait_special == 37):
		return true
	if pol.trait_background == 28 and pol.loyalty < 2000:
		return true
	return false


## 原版 Politic_Manager.Text(text, col) 换行算法（Politic_Manager.cs:455-503）。
## 原版输入是 TextMesh 的 <color=...>；Godot 用 BBCode [color=...]，
## 为保持换行计数一致，先把四种会参与短码计数的颜色换成与原版相同的短码。
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
	return out


func _refresh_left_for_leader() -> void:
	var leader: PoliticianData = _world.leader
	if leader == null:
		_left_status.text = "实权领袖数据缺失"
		return
	_left_name.text = "%s（%d岁）" % [leader.name_display, leader.age]
	_refresh_traits(leader)

	# 原版 Politic_Manager.cs:285-377 领袖分支（中文）
	var sb := " 国 家 主 席"
	sb += "|职 务 ："
	for i in 3:
		if _world.politics_positions[i] == LEADER_POS:
			sb += "[color=orange] %s[/color]；" % POSITION_NAMES[i]
	sb += "|主 管 ："
	for i in range(3, 8):
		if _world.politics_positions[i] == LEADER_POS:
			sb += "[color=yellow] %s [/color]；" % POSITION_NAMES[i]
	_left_status.text = _wrap_text(sb, 30)


# ============================================================================
# 操作按钮状态 — 逐字对齐 Button_Pol_Script.Repaint 的 enabled 公式
# 原版未选中/选领袖时隐藏 buttons_obj；选领袖时显示 button_lead_obj
# ============================================================================

func _update_button_states() -> void:
	if _world == null:
		return
	var selecting_leader := _selected_pol_index == LEADER_SELECT
	var has_pol := _selected_pol_index >= 0 and _selected_pol_index < _world.politicians.size()
	var pol: PoliticianData = _get_selected_pol() if has_pol else null

	if selecting_leader:
		_set_action_buttons_visible(false)
		if _btn_leader_cmc:
			_btn_leader_cmc.visible = true
			_btn_leader_cmc.disabled = not _can_assign_leader_cmc()
	elif has_pol:
		_set_action_buttons_visible(true)
		if _btn_leader_cmc:
			_btn_leader_cmc.visible = false
		_update_politician_button_states(pol)
	else:
		_set_action_buttons_visible(false)
		if _btn_leader_cmc:
			_btn_leader_cmc.visible = false

	_apply_disabled_tint()
	_refresh_button_tooltips()


func _update_politician_button_states(pol: PoliticianData) -> void:
	var d := _world.数值表
	var idx := _selected_pol_index
	var tier := _get_tier(idx)
	var investigating := pol.is_under_investigation
	var surveilling := pol.is_under_surveillance
	# 原版 data[38]!=100 && selected==0：毛在世保护 politics[0]
	var mao_protected: bool = GameManager.is_mao_protected(idx)
	var money1 := _money_ok(1)
	var money20 := _money_ok(20)
	var money100 := _money_ok(100)

	# num0 支持（Button_Pol_Script.cs:534）
	_btn_support.disabled = not (money1 and d[W.I_AGENTS] >= 5 and not investigating)
	# num1 打压（Button_Pol_Script.cs:537）
	_btn_suppress.disabled = not (
		money1 and d[W.I_AGENTS] >= 20 and not investigating
		and _tier_allows_negative(tier, pol) and not mao_protected
	)
	# num2 再教育/暗杀（Button_Pol_Script.cs:540）
	_btn_assassinate.disabled = not (
		money20 and not investigating and d[W.I_AGENTS] >= 60
		and _tier_allows_negative(tier, pol)
		and _assassinate_historic_allowed(idx)
		and not mao_protected
		and _assassinate_modifier_allowed(idx)
	)
	# num3 调查（Button_Pol_Script.cs:543）
	_btn_investigate.disabled = not (
		d[W.I_AGENTS] >= 20 and not investigating
		and _tier_allows_negative(tier, pol) and not mao_protected
	)
	# num4 监视（Button_Pol_Script.cs:546）
	_btn_surveil.disabled = not (
		d[W.I_AGENTS] >= 30 and not investigating and not surveilling
		and _tier_allows_negative(tier, pol) and not mao_protected
	)
	# num15 自动支持（Button_Pol_Script.cs:579）
	_btn_auto_support.disabled = not (
		pol.auto_support == 10 or (money1 and d[W.I_AGENTS] >= 5 and not investigating)
	)
	# num16 自动打压（Button_Pol_Script.cs:583）
	_btn_auto_suppress.disabled = not (
		pol.auto_hound == 10 or (
			money1 and d[W.I_AGENTS] >= 20 and not investigating
			and _tier_allows_negative(tier, pol) and not mao_protected
		)
	)
	# num14 指定派系负责人（Button_Pol_Script.cs:576）
	_btn_faction_leader.disabled = not (
		money100 and d[W.I_AGENTS] >= 100
		and _faction_leader_slot_of(idx) < 0  # 原版：非现任任一派系领袖
		and not investigating and tier <= 2 and GameManager.is_mao_dead()
	)
	# num7 总理 / num5 军委 / num6 外交（Button_Pol_Script.cs:548-555）
	_btn_pos_premier.disabled = not _central_slot_allowed(pol, tier, 0)
	_btn_pos_cmc.disabled = not _central_slot_allowed(pol, tier, 1) or not GameManager.is_mao_dead()
	_btn_pos_foreign.disabled = not _central_slot_allowed(pol, tier, 2)
	# num8-12 地方（Button_Pol_Script.cs:557-571）
	_btn_pos_capital.disabled = not _regional_slot_allowed(pol, tier, 3)
	_btn_pos_north.disabled = not _regional_slot_allowed(pol, tier, 4)
	_btn_pos_west.disabled = not _regional_slot_allowed(pol, tier, 5)
	_btn_pos_south.disabled = not _regional_slot_allowed(pol, tier, 6)
	_btn_pos_east.disabled = not _regional_slot_allowed(pol, tier, 7)

	# 原版 num15/16 文字颜色 = new Color(0.04f, autosupport/autohound, 0f)
	_btn_auto_support.add_theme_color_override("font_color", Color(0.04, float(pol.auto_support), 0.0))
	_btn_auto_suppress.add_theme_color_override("font_color", Color(0.04, float(pol.auto_hound), 0.0))


func _set_action_buttons_visible(v: bool) -> void:
	for b in _action_buttons:
		b.visible = v


## 原版 Button_Pol_Script.cs:595-600：enabled → white，否则 0.3 灰
func _apply_disabled_tint() -> void:
	for b in _action_buttons:
		b.modulate = Color(1, 1, 1) if not b.disabled else Color(0.3, 0.3, 0.3)
	if _btn_leader_cmc:
		_btn_leader_cmc.modulate = Color(1, 1, 1) if not _btn_leader_cmc.disabled else Color(0.3, 0.3, 0.3)


## 原版层级负向操作放行：num<=3，或 (loyalty>=700 && gamerules[5]==1)，或 gamerules[5]==2
func _tier_allows_negative(tier: int, pol: PoliticianData) -> bool:
	if tier <= 3:
		return true
	if pol and pol.loyalty >= 700 and _game_rule(5) == 1:
		return true
	return _game_rule(5) == 2


func _central_slot_allowed(pol: PoliticianData, tier: int, pos: int) -> bool:
	if pol == null or pol.is_under_investigation:
		return false
	if _world.politics_positions[pos] == _selected_pol_index:
		return false
	if tier <= 2:
		return true
	if pol.loyalty >= 700 and _game_rule(5) == 1:
		return true
	return _game_rule(5) == 2


func _regional_slot_allowed(pol: PoliticianData, tier: int, pos: int) -> bool:
	if pol == null or pol.is_under_investigation:
		return false
	if _world.politics_positions[pos] == _selected_pol_index:
		return false
	if tier <= 3:
		return true
	if pol.loyalty >= 700 and _game_rule(5) == 1:
		return true
	return _game_rule(5) == 2


## 原版 num2 历史人物保护条件（Button_Pol_Script.cs:540 中间大括号）。
## 注意与 TimeScript.cs:331-335 阴谋击杀版不同：这里 || data[21]>=1978 无条件。
func _assassinate_historic_allowed(idx: int) -> bool:
	var d := _world.数值表
	var ev25 := _world.completed_event_ids.has("gang_of_four")
	var ev26 := _world.completed_event_ids.has("weak_alliance")
	var basic := idx > 5 and idx != 7 and (idx < 11 or idx > 15) and idx != 17
	var e25a := ev25 and d[W.I_GANG_OF_FOUR_PATH] != 3 and (idx < 12 or idx > 15)
	var e26a := ev26 and ((_world.leader != null and _world.leader.name_first != 0) or idx == 1)
	var year_ok := d[W.I_YEAR] >= 1978
	var e25b := ev25 and d[W.I_GANG_OF_FOUR_PATH] == 3 and (idx < 1 or idx > 4)
	return basic or e25a or e26a or year_ok or e25b


## 原版 num2 修改器尾部条件（Button_Pol_Script.cs:540 末尾）
func _assassinate_modifier_allowed(idx: int) -> bool:
	var mod3: bool = GameManager._mod_active(_world, 3)
	var ev80 := _world.completed_event_ids.has("event_80")
	return (idx > 4 or not mod3 or ev80) and (idx > 4 or idx == 2 or not mod3 or not ev80)


func _can_assign_leader_cmc() -> bool:
	# 原版 num13（Button_Pol_Script.cs:573）：selected==150 && data[38]==100 && dolshnost[1]!=150
	return GameManager.is_mao_dead() and _world.politics_positions[1] != LEADER_POS


func _money_ok(amount: int) -> bool:
	# 原版统一使用 data[8] + data[36]（预算+外汇储备）判断
	var d := _world.数值表
	return d[W.I_BUDGET] + d[W.I_RESERVE] >= amount


func _game_rule(idx: int) -> int:
	# 复用 PoliticianSystem 的移植说明 gamerules 读取口，避免双份实现
	return PoliticianSystem._game_rule(_world, idx)


func _leader_property(idx: int) -> bool:
	# 原版 Event712（移植说明）设置 LeaderProperty[0..3]；默认 false。
	return _world.get_flag("leader_property_%d" % idx)


func _get_selected_pol() -> PoliticianData:
	if _selected_pol_index >= 0 and _selected_pol_index < _world.politicians.size():
		return _world.politicians[_selected_pol_index]
	return null


func _get_tier(pol_index: int) -> int:
	# 原版层级：first(3)=1, second(4)=2, third(5)=3, forth(6)=4；
	# Button_Pol_Script.Repaint 里 num 初值 1（找不到时按第一层处理），故回退 1。
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


# ============================================================================
# 按钮悬停提示 — 逐字对齐 Button_Pol_Script.NeedToUpEn（中文文案）
# ============================================================================

func _refresh_button_tooltips() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		# 原版 num13 领袖按钮提示（NeedToUpEn num==13：检查 dolshnost[7]==150）
		if _btn_leader_cmc and _selected_pol_index == LEADER_SELECT:
			_btn_leader_cmc.tooltip_text = (
				" 已 任 命" if _world.politics_positions[7] == LEADER_POS else " 是 ，当 然 可 以"
			)
		return
	var d := _world.数值表
	var idx := _selected_pol_index
	var investigating := pol.is_under_investigation
	var surveilling := pol.is_under_surveillance
	var mao_protected: bool = GameManager.is_mao_protected(idx)

	# num0 / num15 支持
	var support_tip := " 花 费 1 资 金 与\n0.5 特 工 网 络"
	if _leader_property(3):
		support_tip = " 免 费"
	_btn_support.tooltip_text = support_tip
	_btn_auto_support.tooltip_text = support_tip

	# num1 / num16 打压
	var suppress_tip := " 花 费 1 资 金 与\n2 特 工 网 络"
	if mao_protected:
		suppress_tip = " 伟 大 的 舵 手 万 岁 ！"
	elif investigating:
		suppress_tip = " 正 被 纪 律 审 查"
	_btn_suppress.tooltip_text = suppress_tip
	_btn_auto_suppress.tooltip_text = suppress_tip

	# num2 再教育
	var kill_tip := " 花 费 2 资 金 与\n6 特 工 网 络"
	if mao_protected:
		kill_tip = " 伟 大 的 舵 手 万 岁 ！"
	elif not _assassinate_historic_allowed(idx):
		kill_tip = " 等 待 事 件"
	elif idx <= 4 and idx != 2 and GameManager._mod_active(_world, 3) \
			and _world.completed_event_ids.has("event_80"):
		kill_tip = " 我 们 正 走 在 正 确 的 道 路 上 ！"
	elif investigating:
		kill_tip = " 正 被 纪 律 审 查"
	_btn_assassinate.tooltip_text = kill_tip

	# num3 调查
	var invest_tip := " 花 费 2 特 工 网 络"
	if mao_protected:
		invest_tip = " 伟 大 的 舵 手 万 岁 ！"
	elif investigating:
		invest_tip = " 正 被 纪 律 审 查"
	elif _leader_property(2):
		invest_tip = " 可 免 费 调 查"
	_btn_investigate.tooltip_text = invest_tip

	# num4 监视
	var surveil_tip := " 花 费 3 特 工 网 络"
	if mao_protected:
		surveil_tip = " 伟 大 的 舵 手 万 岁 ！"
	elif investigating:
		surveil_tip = " 正 被 纪 律 审 查"
	elif surveilling:
		surveil_tip = " 正 被 监 察 调 查"
	elif _leader_property(1):
		surveil_tip = " 可 免 费 监 视"
	_btn_surveil.tooltip_text = surveil_tip

	# num5 军委（额外要求毛已逝）
	var cmc_tip := _position_tip(pol, 1)
	if not GameManager.is_mao_dead():
		cmc_tip = " 伟 大 的 舵 手 万 岁 ！"
	_btn_pos_cmc.tooltip_text = cmc_tip
	# num6 外交 / num7 总理 / num8-12 地方
	_btn_pos_foreign.tooltip_text = _position_tip(pol, 2)
	_btn_pos_premier.tooltip_text = _position_tip(pol, 0)
	_btn_pos_capital.tooltip_text = _position_tip(pol, 3)
	_btn_pos_north.tooltip_text = _position_tip(pol, 4)
	_btn_pos_west.tooltip_text = _position_tip(pol, 5)
	_btn_pos_south.tooltip_text = _position_tip(pol, 6)
	_btn_pos_east.tooltip_text = _position_tip(pol, 7)

	# num14 派系负责人
	var faction_tip := " 足 够 显 赫 的\n 政 治 地 位"
	if not GameManager.is_mao_dead():
		faction_tip = " 伟 大 的 舵 手 万 岁 ！"
	elif investigating:
		faction_tip = " 正 被 纪 律 审 查"
	elif _faction_leader_slot_of(idx) >= 0:
		faction_tip = " 已 任 命"
	elif not _money_ok(100) or d[W.I_AGENTS] < 100:
		faction_tip = " 花 费 10 资 金 与\n10 特 工 网 络"
	_btn_faction_leader.tooltip_text = faction_tip


func _position_tip(pol: PoliticianData, pos: int) -> String:
	# 原版 NeedToUpEn num5-12 的公共路径
	if pol.is_under_investigation:
		return " 正 被 纪 律 审 查"
	if _world.politics_positions[pos] == _selected_pol_index:
		return " 已 任 命"
	return " 足 够 显 赫 的\n 政 治 地 位"


# ============================================================================
# 卡片信号 — 忠诚条（原版 Politic_Script.ToDisp / RepaintShkal）
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
# 操作回调 — 逐字移植 Button_Pol_Script.OnMouseDown（Button_Pol_Script.cs:603-985）
# ============================================================================
@warning_ignore_start("integer_division")

func _on_support() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	var d := _world.数值表
	# num0：LeaderProperty[3] 免费（Button_Pol_Script.cs:609-613）
	if not _leader_property(3):
		d[W.I_BUDGET] -= 1
		d[W.I_AGENTS] -= 5
	d[W.I_PARTY_SUPPORT] -= 20
	var year: int = d[W.I_YEAR]
	pol.power += (year - 1976) * 5
	pol.loyalty += 50
	pol.power += absi(pol.power / 10)
	_after_operation()


func _on_suppress() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	if GameManager.is_mao_protected(_selected_pol_index):
		return
	var d := _world.数值表
	# num1（Button_Pol_Script.cs:619-627）
	d[W.I_BUDGET] -= 1
	d[W.I_PARTY_SUPPORT] -= 20
	d[W.I_AGENTS] -= 20
	pol.loyalty -= 50
	var year: int = d[W.I_YEAR]
	pol.power -= (year - 1976) * 5
	pol.power -= absi(pol.power / 10)
	_after_operation()


func _on_assassinate() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	if GameManager.is_mao_protected(_selected_pol_index):
		return
	var d := _world.数值表
	var idx := _selected_pol_index
	# num2 扣费（Button_Pol_Script.cs:654-662）。enabled 保证 !is_sledstvie → 实际恒走 else -100
	if pol.is_under_investigation:
		d[W.I_AGENTS] -= 60
	else:
		d[W.I_AGENTS] -= 100
	d[W.I_BUDGET] -= 20
	# 原版成功与失败分支各 +100，合计恒 +100；提到 roll 前等价（Button_Pol_Script.cs:665/708）
	d[W.I_THOUGHT_FREEDOM] += 100

	var success_rate: float = GameManager.change_of_killing(idx)
	var roll: float = _world.ensure_rng().randf()
	if roll <= success_rate:
		# 原版同 traits[0] 全体（含目标本人）：领袖 -300 / 非领袖 -5（Button_Pol_Script.cs:666-685）
		if _faction_leader_slot_of(idx) >= 0:
			_apply_trait_loyalty(pol, -300)
		else:
			_apply_trait_loyalty(pol, -5)
		if d.size() > 110:
			d[110] += 1
		# 原版 Button_Pol_Script.cs:686-689：iron_and_blood 且 data[110]>=44 → Set(24)。
		if d.size() > 110 and d[110] >= 44:
			Achievements.set_achievement(24)
		# 原版被杀者任中央职时置 data[114/115/116]=9（Button_Pol_Script.cs:691-702）
		if _world.politics_positions[0] == idx:
			d[114] = 9
		if _world.politics_positions[1] == idx:
			d[115] = 9
		if _world.politics_positions[2] == idx:
			d[116] = 9
		GameManager.kill_politician(idx)
	else:
		# 原版失败：全员 -100，目标额外 -400，you_fall=true（Button_Pol_Script.cs:708-716）
		for p in _world.politicians:
			if p == null:
				continue
			p.loyalty -= 100
		pol.loyalty -= 400
		pol.you_fall = true
	_after_operation()


func _on_investigate() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	if GameManager.is_mao_protected(_selected_pol_index):
		return
	var d := _world.数值表
	var idx := _selected_pol_index
	# num3（Button_Pol_Script.cs:718-747）：免费判定用 LeaderProperty[1]（原版如此，勿按 tooltip 改）
	pol.is_under_investigation = true
	pol.investigator_index = 0
	if not _leader_property(1):
		d[W.I_AGENTS] -= 20
	if _faction_leader_slot_of(idx) >= 0:
		_apply_trait_loyalty(pol, -1000)
	else:
		_apply_trait_loyalty(pol, -100)
	pol.loyalty -= 2000
	_after_operation()


func _on_surveil() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	if GameManager.is_mao_protected(_selected_pol_index):
		return
	var d := _world.数值表
	# num4（Button_Pol_Script.cs:748-756）
	pol.is_under_surveillance = true
	pol.days_surveillance = 0
	if not _leader_property(1):
		d[W.I_AGENTS] -= 30
	_after_operation()


func _on_auto_support() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	# num15：0 <-> 10（Button_Pol_Script.cs:628-639）
	pol.auto_support = 10 if pol.auto_support == 0 else 0
	_after_operation()


func _on_auto_suppress() -> void:
	var pol := _get_selected_pol()
	if pol == null:
		return
	if GameManager.is_mao_protected(_selected_pol_index):
		return
	# num16：0 <-> 10（Button_Pol_Script.cs:640-651）
	pol.auto_hound = 10 if pol.auto_hound == 0 else 0
	_after_operation()


func _on_assign_leader_cmc() -> void:
	# 原版 num13（Button_Pol_Script.cs:757-772）：领袖本人接任军委。
	# 原版还写 loyality_to_other[150] -= 500，但数组仅 18 格（Politic.cs:25）→ 原版越界；
	# Godot 适配：领袖是独立对象且无矩阵槽，跳过该矩阵惩罚并保留其余数值。
	if _selected_pol_index != LEADER_SELECT:
		return
	var prev: int = _world.politics_positions[1]
	if prev >= 0 and prev < _world.politicians.size():
		_world.politicians[prev].loyalty -= 1000
	_world.politics_positions[1] = LEADER_POS
	for i in range(3, _world.politics_positions.size()):
		if _world.politics_positions[i] == LEADER_POS:
			_world.politics_positions[i] = -1
	_after_operation()


func _on_set_faction_leader() -> void:
	var pol := _get_selected_pol()
	if pol == null or _selected_pol_index < 0:
		return
	# num14 数值在 PoliticianSystem.set_faction_leader_politician（已按 traits[0] 映射对齐）
	if not GameManager.set_faction_leader_politician(_selected_pol_index):
		return
	_after_operation()


func _on_assign_position(position_id: int) -> void:
	if _selected_pol_index < 0:
		return
	# num5-12 数值在 PoliticianSystem.assign_politician_position（已对齐）
	if not GameManager.assign_politician_position(_selected_pol_index, position_id):
		return
	_after_operation()


# ============================================================================
# 辅助
# ============================================================================

## 原版 faction_leader[0..4] 是否包含该政治家
func _faction_leader_slot_of(pol_index: int) -> int:
	for fi in _world.factions.size():
		if _world.factions[fi].leader_index == pol_index:
			return fi
	return -1


## 原版同 traits[0] 遍历（含目标本人）：Button_Pol_Script.cs:668-684 / 728-745
func _apply_trait_loyalty(pol: PoliticianData, delta: int) -> void:
	for p in _world.politicians:
		if p != null and p.trait_personality == pol.trait_personality:
			p.loyalty += delta


## 原版每次按钮点击后：BalancePolitic → ResetPolitics → Politic_Selected(200) → RepaintData
func _after_operation() -> void:
	_selected_pol_index = -1
	_full_refresh()
	GameManager.stats_changed.emit()


func _on_stats_changed() -> void:
	_refresh_right_panel()
	_update_button_states()


func _goto_diplomacy() -> void:
	get_tree().change_scene_to_file(外交场景)
