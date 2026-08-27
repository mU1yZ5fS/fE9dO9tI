extends "res://数据脚本/event_script_base.gd"

## 原作事件 94/95/96/116：台湾路线事件链。
## 来源：
##   Event94.cs（又 一 次 天 安 门 事 件 ？ ！）
##   Event95.cs（中 国 共 产 党 的 新 开 始）
##   Event96.cs（改 革 ！ 民 主 ！ 开 放 ！）
##   Event116.cs（两 个 中 国）
##   TimeScript.cs:10789/10796/10803/10950 触发条件
##   events[0].activeSelf UI 互斥在 Godot 由 EventEngine.check_and_fire() 单事件进行中保证，不写入 .tres。
##
## 字段映射说明：
##   data.afghan_war_path 在本链中语义是「台湾路线标志」（Unity 复用阿富汗战争路线槽位），
##   因此这里直接读写 ws.afghan_war_path，不依赖 WorldState.I_AFGHAN_WAR_PATH 的误导性常量名；
##   .tres 触发条件则使用 world_state 已登记的同槽键 "afghan_war_path"。
##   data.taiwan_status→W.I_TAIWAN_STATUS；data.get_data_by_index(4/3/8/1/6/21)→W.I_THOUGHT_FREEDOM/
##   W.I_PEOPLE_SUPPORT/W.I_BUDGET/W.I_PARTY_SUPPORT/W.I_DIPLO/W.I_YEAR。
##   allcountries[38]→ws.get_country_by_legacy_index(38)（台湾）；
##   Gosstroy/SubGosstroy→government/sub_government；
##   proprc→set_tag("亲中")；Torg→set_tag("对华贸易")。
##
## 中文重写：2026-08 批次8，四件套文案已按原版 Event94/95/96/116.cs 逐字重写
## （去空格、||→\n、剥 color；94 描述/结果文本动态拼接自由派领袖姓名）。
##
## 已知取舍：
##   - Unity 的 doctr[] 是显示文案表；Godot 的政体/政策名由 派系界面 按数据索引实时
##     生成，因此 Event95 的 doctr 赋值不移植，只改数据索引。
##   - Unity 的 LeaderAsset/MoneyLevel/ServeRMB 在 Godot 无对应字段，跳过并注释。
##   - Event96 的 data.press_policy++：官方版 DLL 反编译证实为 ref 真实写入（<19 守卫），已恢复。
##   - Event116 的 ILoveSuckCocks 是刷新中国地图 parts 的辅助方法，这里按主要分支近似移植。

# ============================================================================
# 原版逐字中文文案（Event94/95/96/116.cs 去空格、||→\n、剥 color）
# ============================================================================
const TXT94_TITLE := "event.script.event_094_096_116_taiwan_chain.txt94_title"
const TXT94_DESC_1 := "event.script.event_094_096_116_taiwan_chain.txt94_desc_1"
const TXT94_DESC_3 := "event.script.event_094_096_116_taiwan_chain.txt94_desc_3"
const TXT94_OPT_0 := "event.script.event_094_096_116_taiwan_chain.txt94_opt_0"
const TXT94_OPT_1 := "event.script.event_094_096_116_taiwan_chain.txt94_opt_1"
const TXT94_OPT_2 := "event.script.event_094_096_116_taiwan_chain.txt94_opt_2"
const TXT94_OPT_3 := "满足抗议者的要求"
const TXT94_R0_A := "event.script.event_094_096_116_taiwan_chain.txt94_r0_a"
const TXT94_R0_B := "event.script.event_094_096_116_taiwan_chain.txt94_r0_b"
const TXT94_R1_OK := "event.script.event_094_096_116_taiwan_chain.txt94_r1_ok"
const TXT94_R1_FAIL_A := "event.script.event_094_096_116_taiwan_chain.txt94_r1_fail_a"
const TXT94_R1_FAIL_B := "event.script.event_094_096_116_taiwan_chain.txt94_r1_fail_b"
const TXT94_R2_A := "event.script.event_094_096_116_taiwan_chain.txt94_r2_a"
const TXT94_R2_B := "event.script.event_094_096_116_taiwan_chain.txt94_r2_b"
const TXT94_R3 := "event.script.event_094_096_116_taiwan_chain.txt94_r3"
const TXT95_TITLE := "中国共产党的新开始"
const TXT95_DESC_1 := "event.script.event_094_096_116_taiwan_chain.txt95_desc_1"
const TXT95_DESC_3 := "event.script.event_094_096_116_taiwan_chain.txt95_desc_3"
const TXT95_OPT_0 := "event.script.event_094_096_116_taiwan_chain.txt95_opt_0"
const TXT95_OPT_1 := "event.script.event_094_096_116_taiwan_chain.txt95_opt_1"
const TXT95_OPT_2 := "event.script.event_094_096_116_taiwan_chain.txt95_opt_2"
const TXT95_OPT_3 := "event.script.event_094_096_116_taiwan_chain.txt95_opt_3"
const TXT95_R0 := "event.script.event_094_096_116_taiwan_chain.txt95_r0"
const TXT95_R1 := "event.script.event_094_096_116_taiwan_chain.txt95_r1"
const TXT95_R2 := "event.script.event_094_096_116_taiwan_chain.txt95_r2"
const TXT95_R3 := "event.script.event_094_096_116_taiwan_chain.txt95_r3"
const TXT96_TITLE := "改革！民主！开放！"
const TXT96_DESC := "event.script.event_094_096_116_taiwan_chain.txt96_desc"
const TXT96_OPT_0 := "event.script.event_094_096_116_taiwan_chain.txt96_opt_0"
const TXT96_OPT_1 := "event.script.event_094_096_116_taiwan_chain.txt96_opt_1"
const TXT96_OPT_2 := "event.script.event_094_096_116_taiwan_chain.txt96_opt_2"
const TXT96_OPT_3 := "event.script.event_094_096_116_taiwan_chain.txt96_opt_3"
const TXT96_R0 := "event.script.event_094_096_116_taiwan_chain.txt96_r0"
const TXT96_R1 := "event.script.event_094_096_116_taiwan_chain.txt96_r1"
const TXT96_R2 := "event.script.event_094_096_116_taiwan_chain.txt96_r2"
const TXT96_R3 := "event.script.event_094_096_116_taiwan_chain.txt96_r3"
const TXT116_TITLE := "两个中国"
const TXT116_DESC := "event.script.event_094_096_116_taiwan_chain.txt116_desc"
const TXT116_OPT_0 := "保持原样"
const TXT116_OPT_1 := "event.script.event_094_096_116_taiwan_chain.txt116_opt_1"
const TXT116_OPT_1_DISABLED := "event.script.event_094_096_116_taiwan_chain.txt116_opt_1_disabled"
const TXT116_OPT_2 := "event.script.event_094_096_116_taiwan_chain.txt116_opt_2"
const TXT116_R0 := "一切顺其自然。"
const TXT116_R1 := "event.script.event_094_096_116_taiwan_chain.txt116_r1"
const TXT116_R2 := "event.script.event_094_096_116_taiwan_chain.txt116_r2"

# ============================================================================
# prepare — 显示前动态文案（原版 TextOfEvents / VariantsOfEvents）
# ============================================================================

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	match event_def.event_id:
		"event_094":
			_prepare_94(event_def, world)
		"event_095":
			_prepare_95(event_def, world)
		"event_096":
			_prepare_96(event_def)
		"event_116":
			_prepare_116(event_def)


func _prepare_94(event_def: EventDef, world: WorldState) -> void:
	event_def.title = tr(TXT94_TITLE)
	var leader := _liberal_leader_name(world)
	event_def.description = tr(TXT94_DESC_1) + leader + tr(TXT94_DESC_3)
	if event_def.options.size() < 4:
		return
	event_def.options[0].text = tr(TXT94_OPT_0)
	event_def.options[1].text = tr(TXT94_OPT_1)
	event_def.options[2].text = tr(TXT94_OPT_2)
	event_def.options[3].text = TXT94_OPT_3


func _prepare_95(event_def: EventDef, world: WorldState) -> void:
	event_def.title = TXT95_TITLE
	var leader := _current_leader_name(world)
	event_def.description = tr(TXT95_DESC_1) + leader + tr(TXT95_DESC_3)
	if event_def.options.size() < 4:
		return
	event_def.options[0].text = tr(TXT95_OPT_0)
	event_def.options[1].text = tr(TXT95_OPT_1)
	event_def.options[2].text = tr(TXT95_OPT_2)
	event_def.options[3].text = tr(TXT95_OPT_3)


func _prepare_96(event_def: EventDef) -> void:
	event_def.title = TXT96_TITLE
	event_def.description = tr(TXT96_DESC)
	if event_def.options.size() < 4:
		return
	event_def.options[0].text = tr(TXT96_OPT_0)
	event_def.options[1].text = tr(TXT96_OPT_1)
	event_def.options[2].text = tr(TXT96_OPT_2)
	event_def.options[3].text = tr(TXT96_OPT_3)


func _prepare_116(event_def: EventDef) -> void:
	event_def.title = TXT116_TITLE
	event_def.description = tr(TXT116_DESC)
	if event_def.options.size() < 3:
		return
	event_def.options[0].text = TXT116_OPT_0
	event_def.options[1].text = tr(TXT116_OPT_1)
	event_def.options[1].disabled_text = tr(TXT116_OPT_1_DISABLED)
	event_def.options[2].text = tr(TXT116_OPT_2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"event_094":
			_event_94(option_index, context)
		"event_095":
			_event_95(option_index, context)
		"event_096":
			_event_96(option_index, context)
		"event_116":
			_event_116(option_index, context)
	_sync_empire_mirrors()


# ============================================================================
# Event94 — 又一次天安门事件？！
# ============================================================================

func _event_94(option_index: int, context: Dictionary) -> void:
	# TextOfEvents 的自由派领袖兜底（Event94.cs:28-38）：faction_leader[4]==200
	# 时选 power 最高的 traits[0]==3 政客。Godot 用 faction.leader_index=-1/-2 表示空缺，
	# _liberal_leader_index() 在无效时执行同一兜底。
	match option_index:
		0:
			_event_94_result_0(context)
		1:
			_event_94_result_1(context)
		2:
			_event_94_result_2(context)
		3:
			_event_94_result_3(context)


func _event_94_result_0(context: Dictionary) -> void:
	# Event94.cs:64-78
	var leader := _liberal_leader_name()
	context["result_text"] = tr(TXT94_R0_A) + leader + tr(TXT94_R0_B)
	_add_empire_relation(EmpireData.USA, -150)
	_add_data({W.I_MANPOWER: -150, W.I_PEOPLE_SUPPORT: -100,
		W.I_THOUGHT_FREEDOM: -250, W.I_DIPLO: 80})


func _event_94_result_1(context: Dictionary) -> void:
	# Event94.cs:80-185
	if d.people_support >= 600 and d.thought_freedom < 500:
		# 成功劝说（Event94.cs:82-88）
		context["result_text"] = tr(TXT94_R1_OK)
		_add_data({W.I_THOUGHT_FREEDOM: 250, W.I_PEOPLE_SUPPORT: -100,
			W.I_MANPOWER: -250})
	else:
		# 劝说失败，自由派接权并开启台湾路线（Event94.cs:89-184）
		var leader := _liberal_leader_name()
		context["result_text"] = tr(TXT94_R1_FAIL_A) + leader + tr(TXT94_R1_FAIL_B)
		_add_data({W.I_PEOPLE_SUPPORT: 90, W.I_DIPLO: -50,
			W.I_MANPOWER: -350, W.I_THOUGHT_FREEDOM: 100})
		# data.afghan_war_path 在本链中为台湾路线标志（双用途槽位，勿依赖 I_AFGHAN_WAR_PATH 常量名）
		ws.afghan_war_path = 1
		_swap_leader_with_liberal()
		# LeaderAsset=0 / MoneyLevel=0 / ServeRMB=false 在 Godot 无对应字段，跳过。
		_set_modifier_active(65, false)


func _event_94_result_2(context: Dictionary) -> void:
	# Event94.cs:186-280
	var leader := _liberal_leader_name()
	context["result_text"] = tr(TXT94_R2_A) + leader + tr(TXT94_R2_B)
	_add_data({W.I_PEOPLE_SUPPORT: 90, W.I_DIPLO: -50,
		W.I_MANPOWER: -350, W.I_THOUGHT_FREEDOM: 100})
	ws.afghan_war_path = 1
	# LeaderAsset=0 / MoneyLevel=0 / ServeRMB=false 在 Godot 无对应字段，跳过。
	_swap_leader_with_liberal()


func _event_94_result_3(context: Dictionary) -> void:
	# Event94.cs:281-351
	context["result_text"] = _liberal_leader_name() + tr(TXT94_R3)
	d.thought_freedom = 1000
	_swap_leader_with_liberal()
	d.party_support = 0
	d.people_support = 0
	# LeaderAsset=0 / MoneyLevel=0 / ServeRMB=false 在 Godot 无对应字段，跳过。
	# 原版 data.ending_route=1 → load_scene_after_click → SceneManager.LoadScene("Ending")
	# 项目语义映射：结局 5（人民的选择）。见 event_001/event_005 同类迁移。
	d.ending_route = 5
	game.queue_ending_after_event(5)


## 当前国家领袖显示名（Event95 描述插姓名时兜底；94 成功后领袖已换为自由派）。
func _current_leader_name(p_ws: WorldState = null) -> String:
	var world := p_ws if p_ws != null else ws
	if world != null and world.leader != null and world.leader.name_display != "":
		return world.leader.name_display
	return "自由派领袖"


## 自由派领袖显示名（Event94 描述/结果文本插姓名）。
func _liberal_leader_name(p_ws: WorldState = null) -> String:
	var world := p_ws if p_ws != null else ws
	var idx := _liberal_leader_index(world)
	if idx >= 0 and world != null and world.politicians.size() > idx \
			and world.politicians[idx] != null and world.politicians[idx].name_display != "":
		return world.politicians[idx].name_display
	return "自由派领袖"


## Event94.cs:28-38 的自由派领袖兜底：faction_leader[4]==200 时选 power 最高的 traits[0]==3 政客。
func _liberal_leader_index(p_ws: WorldState = null) -> int:
	var world := p_ws if p_ws != null else ws
	if world == null:
		return -1
	if world.factions.size() > FactionData.LIBERAL and world.factions[FactionData.LIBERAL] != null:
		var current := world.factions[FactionData.LIBERAL].leader_index
		if current >= 0 and current < world.politicians.size() and world.politicians[current] != null:
			return current
	var best := -1
	var best_power := -1000000000
	for i in world.politicians.size():
		var p := world.politicians[i]
		if p != null and p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL and p.power > best_power:
			best = i
			best_power = p.power
	return best


func _swap_leader_with_liberal() -> void:
	var liberal_idx := _liberal_leader_index()
	if liberal_idx < 0:
		return
	_swap_leader_with_politician(liberal_idx)
	PoliticianSystem.sync_in_power_flags(ws)


# ============================================================================
# Event95 — 中国共产党的新开始
# ============================================================================

func _event_95(option_index: int, context: Dictionary) -> void:
	# Event95.cs:51 先停用 modifies[6]，随后 :52 立即判断 active——恒为 false，
	# 所以 :53-65 的 if 分支是死代码，永远走 :66-79 的 else。doctr 是显示文案表，
	# Godot 的政体/政策名由 派系界面 按数据索引实时生成，故这里只改数据索引。
	_set_modifier_active(6, false)
	_set_modifier_active(3, false)
	match option_index:
		0:
			_event_95_result_0(context)
		1:
			_event_95_result_1(context)
		2:
			_event_95_result_2(context)
		3:
			_event_95_result_3(context)


func _event_95_result_0(context: Dictionary) -> void:
	# Event95.cs:82-114（欧洲共产主义）
	context["result_text"] = tr(TXT95_R0)
	_add_data({W.I_PARTY_SUPPORT: -150, W.I_PEOPLE_SUPPORT: 50,
		W.I_MANPOWER: -50, W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: -30})
	d.ideology = 3
	d.econ_system = 13
	d.party_system = GameConstants.PartySystem.PEOPLE_DEMOCRACY
	d.press_policy = 18
	if d.diplomatic_reputation > 699:
		d.diplomatic_reputation = 699
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		china.government = GameConstants.Government.REFORMIST
		china.sub_government = _chinese_sub_government_after_95_option0(china)
	_change_loyalty_by_personality({0: -400, 3: 300})


func _event_95_result_1(context: Dictionary) -> void:
	# Event95.cs:115-180（陈独秀式社会民主主义）
	context["result_text"] = tr(TXT95_R1)
	_add_data({W.I_PARTY_SUPPORT: -300, W.I_PEOPLE_SUPPORT: 80,
		W.I_MANPOWER: -50, W.I_THOUGHT_FREEDOM: 50, W.I_DIPLO: -50})
	# Event95.cs:123-130 经济体制钳制：>=13 → 13；<12 → 12；12 保持。
	if d.econ_system >= 13:
		d.econ_system = 13
	if d.econ_system < 12:
		d.econ_system = 12
	if d.diplomatic_reputation < 500:
		d.diplomatic_reputation = 700
	if d.ideology < 4:
		# Event95.cs:135-159
		d.party_system = GameConstants.PartySystem.CONSOCIATIONALISM
		if d.press_policy < 19:
			d.press_policy = 19
		if d.religion_policy < 26:
			d.religion_policy = 26
		elif d.religion_policy > 27:
			d.religion_policy = 27
		if d.territory_policy < 23:
			d.territory_policy += 1
		if d.military_doctrine < 33:
			d.military_doctrine += 1
		d.ideology = 4
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		china.government = GameConstants.Government.LIBERAL
		china.sub_government = _chinese_sub_government_after_95_option1(china)
	_change_loyalty_by_personality({0: -500, 1: -300, 3: 500})


func _event_95_result_2(context: Dictionary) -> void:
	# Event95.cs:181-210（孙中山式左翼民族主义）
	context["result_text"] = tr(TXT95_R2)
	_add_data({W.I_PARTY_SUPPORT: -250, W.I_PEOPLE_SUPPORT: 50,
		W.I_THOUGHT_FREEDOM: -80, W.I_DIPLO: -10})
	_change_loyalty_by_personality({0: -400, 1: -100, 2: 100, 3: 400})


func _event_95_result_3(context: Dictionary) -> void:
	# Event95.cs:211-216（拒绝退党要求）
	context["result_text"] = tr(TXT95_R3)
	_add_data({W.I_THOUGHT_FREEDOM: 500, W.I_PEOPLE_SUPPORT: -500})


## 在 Event95 option0 设定数据后调用 ChineseSubGosstroy（Gosstroy==2）。
## 移植 GameState.cs:4934-5070 中与该状态相关的分支；其余移植说明分支在 Godot 中恒不命中。
func _chinese_sub_government_after_95_option0(china: CountryData) -> int:
	# Unity 此时 data.ideology=3, data.econ_system=13, data.diplomatic_reputation<=699, data.party_system=8, data.press_policy=18。
	if d.ideology >= 2 and d.econ_system >= 13 and d.diplomatic_reputation <= 700 \
			and d.party_system >= GameConstants.PartySystem.PEOPLE_DEMOCRACY and d.press_policy >= 18 \
			and not china.has_tag("ovd"):
		return 14  # 欧洲共产主义
	if d.ideology <= 3 and d.econ_system >= 12 and d.econ_system <= 13 \
			and d.diplomatic_reputation >= 300 and d.territory_policy > 21 and d.war_support >= 700:
		return 11  # 铁托主义
	if d.ideology <= 3 and d.econ_system <= 14 and d.diplomatic_reputation >= 500 \
			and d.econ_system > 11 and d.war_support >= 400:
		return 8  # 左倾保守主义
	if d.ideology <= 3 and d.econ_system <= 13 and d.press_policy > 17:
		return 3  # 民主社会主义
	return 15  # 政治实用主义


## 在 Event95 option1 设定数据后调用 ChineseSubGosstroy（Gosstroy==3）。
## 移植 GameState.cs:4934-5070 中 Gosstroy==3 分支。
func _chinese_sub_government_after_95_option1(_china: CountryData) -> int:
	if d.econ_system <= 13 and d.diplomatic_reputation >= 500:
		return 4  # 社会民主主义
	if (d.party_system <= GameConstants.PartySystem.PEOPLE_DEMOCRACY and d.press_policy <= 18) or d.war_support >= 700:
		return 12  # 新自由主义
	if d.econ_system > 13 and d.diplomatic_reputation < 700:
		return 6  # 自由主义
	return 5  # 温和主义


# ============================================================================
# Event96 — 改革！民主！开放！
# ============================================================================

func _event_96(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_event_96_result_0(context)
		1:
			_event_96_result_1(context)
		2:
			_event_96_result_2(context)
		3:
			_event_96_result_3(context)


func _event_96_result_0(context: Dictionary) -> void:
	# Event96.cs:44-61
	context["result_text"] = tr(TXT96_R0)
	d.party_system = GameConstants.PartySystem.PEOPLE_DEMOCRACY
	d.religion_policy = 27
	_add_data({W.I_MANPOWER: -80})
	# 官方版 DLL 反编译（tmp_Event96.cs case 0）证实 data[17](press_policy)++ 为 ref 真实
	# 写入且带 data[17]<19 守卫；旧转储 ptr 模式系反编译伪影，已恢复。
	if d.press_policy < 19:
		d.press_policy += 1
	_add_data({W.I_DIPLO: -10, W.I_PEOPLE_SUPPORT: 30, W.I_THOUGHT_FREEDOM: 80})


func _event_96_result_1(context: Dictionary) -> void:
	# Event96.cs:62-71
	context["result_text"] = tr(TXT96_R1)
	d.party_system = GameConstants.PartySystem.CONSOCIATIONALISM
	_add_data({W.I_PEOPLE_SUPPORT: 50, W.I_MANPOWER: -50})
	d.religion_policy = 27
	_add_data({W.I_THOUGHT_FREEDOM: 80, W.I_DIPLO: -20})


func _event_96_result_2(context: Dictionary) -> void:
	# Event96.cs:72-88
	context["result_text"] = tr(TXT96_R2)
	d.party_system = GameConstants.PartySystem.CONSOCIATIONALISM
	_add_data({W.I_PEOPLE_SUPPORT: 50, W.I_MANPOWER: -70})
	# 官方版 DLL 反编译（tmp_Event96.cs case 2）证实 data[17]++ 为 ref 真实写入（<19 守卫）。
	if d.press_policy < 19:
		d.press_policy += 1
	_add_data({W.I_THOUGHT_FREEDOM: 50, W.I_DIPLO: -20})


func _event_96_result_3(context: Dictionary) -> void:
	# Event96.cs:89-106
	context["result_text"] = tr(TXT96_R3)
	d.party_system = GameConstants.PartySystem.CONSOCIATIONALISM
	_add_data({W.I_PEOPLE_SUPPORT: 80, W.I_MANPOWER: -120})
	# 官方版 DLL 反编译（tmp_Event96.cs case 3）证实 data[17]++ 为 ref 真实写入（<19 守卫）。
	if d.press_policy < 19:
		d.press_policy += 1
	_add_data({W.I_THOUGHT_FREEDOM: 120, W.I_DIPLO: -40})
	d.religion_policy = 27


# ============================================================================
# Event116 — 两个中国
# ============================================================================

func _event_116(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			# Event116.cs:51-54（无效果）
			context["result_text"] = TXT116_R0
		1:
			_event_116_result_1(context)
		2:
			_event_116_result_2(context)


func _event_116_result_1(context: Dictionary) -> void:
	# Event116.cs:55-66（统一路线）
	context["result_text"] = tr(TXT116_R1)
	_add_empire_relation(EmpireData.USA, -70)
	_add_data({W.I_THOUGHT_FREEDOM: 80, W.I_PEOPLE_SUPPORT: 120})
	var taiwan := ws.get_country_by_legacy_index(38)
	if taiwan != null:
		taiwan.set_tag("亲中", true)  # 原版 proprc = true
		taiwan.government = GameConstants.Government.LIBERAL         # 原版 Gosstroy = 3
		taiwan.sub_government = GameConstants.SubGovernment.MODERATE     # 原版 SubGosstroy = 5
	d.taiwan_status = 2
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		_china_map_parts(china)  # 原版 allcountries[1].ILoveSuckCocks() 近似


func _event_116_result_2(context: Dictionary) -> void:
	# Event116.cs:67-79（两个中国路线）
	context["result_text"] = tr(TXT116_R2)
	_add_data({W.I_BUDGET: 70})
	_add_empire_relation(EmpireData.USA, 100)
	_add_data({W.I_PEOPLE_SUPPORT: -80, W.I_THOUGHT_FREEDOM: 50,
		W.I_PARTY_SUPPORT: -100})
	var taiwan := ws.get_country_by_legacy_index(38)
	if taiwan != null:
		taiwan.set_tag("对华贸易", true)  # 原版 Torg = true
		taiwan.government = GameConstants.Government.LIBERAL            # 原版 Gosstroy = 3
		taiwan.sub_government = GameConstants.SubGovernment.MODERATE        # 原版 SubGosstroy = 5
	d.taiwan_status = 1


## Event116.cs:65 allcountries[1].ILoveSuckCocks()。
## Country.cs:286-420 依据 IndOpp/GKChP/藏南/台湾地位等刷新中国地图 parts。
## Godot 移植说明 IndOpp/is_gkchp 字段，这里用 global_flags 同名键近似；其余按原版分支。
func _china_map_parts(china: CountryData) -> void:
	if china.parts.size() < 16:
		china.parts.resize(16)
	var d62 := d.arunachal_status if d.size() > W.I_ARUNACHAL_STATUS else 0
	var d64 := d.taiwan_status if d.size() > W.I_TAIWAN_STATUS else 0
	var d130 := d.mongolia_china_route if d.size() > 130 else 0
	var dec7 := false
	if ws.decisions != null and ws.decisions.completed.size() > 7:
		dec7 = ws.decisions.completed[7]
	var c19 := ws.get_country_by_legacy_index(19)
	var c33 := ws.get_country_by_legacy_index(33)

	if ws.get_flag("IndOpp"):
		_clear_china_parts(china, true)
		china.parts[15] = true
	elif c19 != null and c19.puppet_of == GameConstants.LegacySlot.CHINA and c19.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST \
			and c33 != null and c33.puppet_of == GameConstants.LegacySlot.CHINA and c33.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_clear_china_parts(china, true)
		china.parts[14] = true
	elif c33 != null and c33.puppet_of == GameConstants.LegacySlot.CHINA and c33.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_clear_china_parts(china, true)
		china.parts[13] = true
	elif c19 != null and c19.puppet_of == GameConstants.LegacySlot.CHINA and c19.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_clear_china_parts(china, true)
		china.parts[12] = true
	elif ws.get_flag("is_gkchp"):
		_clear_china_parts(china, true)
		china.parts[11] = true
	elif d130 == 1 and d62 >= 2 and (d64 == 2 or dec7):
		_clear_china_parts(china, false)
		china.parts[0] = true
	elif d130 == 1 and (d62 == 2 or d62 == 3):
		_clear_china_parts(china, false)
		china.parts[2] = true
	elif d62 >= 2 and (d64 == 2 or dec7):
		_clear_china_parts(china, false)
		china.parts[6] = true
	elif d130 == 1 and (d64 == 2 or dec7):
		_clear_china_parts(china, false)
		china.parts[3] = true
	elif d130 == 1:
		_clear_china_parts(china, false)
		china.parts[4] = true
	elif d64 == 2 or dec7:
		_clear_china_parts(china, false)
		china.parts[5] = true
	elif d62 >= 2:
		_clear_china_parts(china, false)
		china.parts[1] = true
	else:
		_clear_china_parts(china, false)
		china.parts[10] = true


func _clear_china_parts(china: CountryData, clear_all: bool) -> void:
	for i in china.parts.size():
		if clear_all or i < 7 or i > 9:
			china.parts[i] = false


# ============================================================================
# 通用辅助
# ============================================================================

func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < d.size():
			d.add_data_by_index(index, int(changes[raw_index]))


func _set_modifier_active(modifier_index: int, active: bool) -> void:
	if modifier_index >= 0 and modifier_index < ws.modifiers.size() \
			and ws.modifiers[modifier_index] != null:
		ws.modifiers[modifier_index].is_active = active


func _change_loyalty_by_personality(changes: Dictionary) -> void:
	for politician in ws.politicians:
		if politician != null and changes.has(politician.trait_personality):
			politician.loyalty += int(changes[politician.trait_personality])


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index < 0 or empire_index >= ws.empires.size() or ws.empires[empire_index] == null:
		return
	ws.empires[empire_index].relations = clampi(
		ws.empires[empire_index].relations + delta, 0, 1000)


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		d.usa_relations = ws.empires[EmpireData.USA].relations
		d.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		d.ussr_relations = ws.empires[EmpireData.USSR].relations
		d.soviet_influence = ws.empires[EmpireData.USSR].power
