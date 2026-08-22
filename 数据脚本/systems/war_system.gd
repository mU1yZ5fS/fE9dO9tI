class_name WarSystem
extends RefCounted

## 代理战争系统（2026-08 从 GameManager 拆出）。
## 全部 static 函数，通过 GameManager autoload 访问 world 与共用辅助
## （_notify_stats / _mirror_empires_to_data / start_event）。
## 对齐来源：TimeScript.cs 战争块 + WarCatalog / WarActionCatalog 数据。
##
## GameManager 保留同名公开 stub（start_war / can_intervene / intervene_war /
## resolve_war_finished / get_active_wars / get_mil_intervention_display /
## debug_start_war），外部调用点（战争界面 / EventEngine / 事件脚本）零改动。

const W = preload("res://数据脚本/world_state.gd")
const WF = preload("res://数据脚本/factory/world_factory.gd")

## 西班牙 parts 对应的地图地块（与 event_426_spanish_civil_war_vortex.gd / GameManager 迁移一致）。
const SPAIN_BASQUE_REGION_IDS: Array[int] = [625, 626, 2521, 3415]
const SPAIN_CATALONIA_REGION_IDS: Array[int] = [629, 637, 2500, 2501]
const SPAIN_GWCODE := 230

## 跨系统注入（GameManager._ready / new_game / load_game 设置）。
## 过渡方案：先用静态入口替代 GameManager 全局依赖，后续再改构造注入。
static var current_world: WorldState = null
static var _notify_stats_cb: Callable = Callable()
static var _start_event_cb: Callable = Callable()
static var _trigger_ending_cb: Callable = Callable()
static var _is_event_in_progress_cb: Callable = Callable()


# ============================================================================
# 月度/双周循环
# ============================================================================

## 月度：军事介入点积累（TimeScript 月块）
static func monthly_war_points() -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var d := w
	var any_war := false
	for war in w.wars:
		if war != null and war.is_going:
			any_war = true
			break
	# TimeScript.cs:3354-3355：每月无条件 data.mil_intervention += data.budget_diplo / 50（外交预算贡献）。
	if d.size() > W.I_BUDGET_DIPLO:
		@warning_ignore("integer_division")
		d.mil_intervention += d.budget_diplo / 50
	# TimeScript.cs:3697-3699：存在进行中的战争时额外 data.mil_intervention += influencePRC / 12。
	if any_war:
		@warning_ignore("integer_division")
		d.mil_intervention += d.global_influence / 12


## 双周：战争漂移与计时（TimeScript 双周块）
static func fortnight_wars(w: WorldState) -> void:
	if w == null:
		return
	for i in w.wars.size():
		var war: WarData = w.wars[i]
		if war == null or not war.is_going:
			continue
		var def := WarCatalog.get_def(i)
		if def:
			war.infl1 += def.drift_infl1
			war.infl2 += def.drift_infl2
			apply_war_drift_extra(w, war, def)
		war.fortnight_elapsed += 1
		WarQueries.clamp_war_infl(war)


## 双周：战争漂移附加规则（按 WarDef.drift_extra_flag 分派）
static func apply_war_drift_extra(w: WorldState, war: WarData, def: WarDef) -> void:
	var flag := def.drift_extra_flag
	if flag.is_empty():
		return
	match flag:
		"korea_prop_prc":
			war.infl1 += def.drift_extra_infl1
			war.infl2 += def.drift_extra_infl2
		"iran_iraq":
			pass
		"afghanistan":
			if war.ussr_side == GameConstants.WarSide.SIDE2:
				war.infl1 -= 50
				war.infl2 += 50
			if w.size() > W.I_AFGHAN_POLICY:
				var pol: int = w.afghan_policy
				if pol == 1:
					war.infl1 += 4
					war.infl2 -= 4
				elif pol == 3:
					war.infl1 += 6
					war.infl2 -= 6
				elif pol == 2:
					war.infl1 -= 2
					war.infl2 += 2
		"turkey_crisis":
			# TimeScript.cs:7412-7446 战争12双周漂移：
			#   usa_place==0 或 土耳其 isNATO → infl1 += 20 / infl2 -= 20；
			#   否则 → infl1 += 5 / infl2 -= 5。
			# fortnight_wars() 已先加 def.drift_infl1/drift_infl2（+5/-5 基础档），
			# 这里在“美国支持或土耳其北约”档补上 20-5 的差额，得到 +20/-20。
			var turkey := w.get_country_by_legacy_index(84)
			if war.usa_side == GameConstants.WarSide.SIDE1 or (turkey != null and turkey.has_tag("nato")):
				war.infl1 += def.drift_extra_infl1 - def.drift_infl1
				war.infl2 += def.drift_extra_infl2 - def.drift_infl2
		"war40_result563":
			# TimeScript.cs:7540-7572：按 resultOfEvents[563] 0→+10/-10，1/2→+6/-6。
			var r563: int = w.result_of_event_num(563)
			var delta563 := 0
			if r563 == 0:
				delta563 = 10
			elif r563 == 1 or r563 == 2:
				delta563 = 6
			if war.infl1 > 0:
				war.infl1 += delta563
			if war.infl2 < 1000:
				war.infl2 -= delta563
		"war41_result565":
			# TimeScript.cs:7594-7622：按 resultOfEvents[565] 0→+10/-10，1→+6/-6，2→+4/-4。
			var r565: int = w.result_of_event_num(565)
			var delta565 := 0
			if r565 == 0:
				delta565 = 10
			elif r565 == 1:
				delta565 = 6
			elif r565 == 2:
				delta565 = 4
			if war.infl1 > 0:
				war.infl1 += delta565
			if war.infl2 < 1000:
				war.infl2 -= delta565
		_:
			pass


## 旧档兼容：把历史错误写死的 fortnight_max 修正为原版有效超时值。
## 只迁移“旧值 == 已知错误值”的槽位，避免覆盖事件运行时正确写入的 20/24 等值。
## 出处：warinwars.fortnight_max 默认 999 + TickTime 逐场 + TimeScript.WorldWarsDone 硬门槛。
static func migrate_legacy_war_timeouts(w: WorldState) -> void:
	if w == null:
		return
	const OLD_TO_NEW := {
		4: {12: 24},        # Event371 TickTime12，但 WorldWarsDone 硬门槛 24
		8: {48: 20},        # Event367 TickTime(20)
		9: {10: 12},        # Event369 TickTime10，但 WorldWarsDone 硬门槛 12
		15: {4: 16},        # Event588 分支 TickTime4，但 WorldWarsDone 硬门槛 16
		18: {4: 8},         # Event382 分支 TickTime4，但 WorldWarsDone result382==1 门槛 8
		29: {48: 15},       # DiploButtonScript TickTime(15)
		30: {48: -1},       # 无 TickTime → 原版默认 999（无超时）
		31: {48: -1},
		32: {48: -1},
		49: {48: -1},
		68: {48: -1},
		79: {48: -1},
		80: {48: -1},
		81: {48: -1},
		82: {48: -1},
		83: {48: -1},
		84: {48: 4},        # Event667 TickTime(4)
		86: {48: -1},
		87: {48: -1},
	}
	for war_id in OLD_TO_NEW:
		if war_id >= w.wars.size():
			continue
		var war: WarData = w.wars[war_id]
		if war == null:
			continue
		var mapping: Dictionary = OLD_TO_NEW[war_id]
		if mapping.has(war.fortnight_max):
			war.fortnight_max = int(mapping[war.fortnight_max])


## 每日：战争达结算条件 → 记录待结算战争并触发战争结束事件
static func check_war_endings() -> void:
	var w: WorldState = current_world
	if w == null or (_is_event_in_progress_cb.is_valid() and _is_event_in_progress_cb.call()):
		return
	if w.size() <= W.I_WAR_RESOLVE:
		return
	# 旧档可能出现 war_resolve 残留为 0 或已结束的战争 id，导致后续战争永远无法结算；
	# 若指向的战争已不存在/未进行，则视为无待结算，恢复 -1。
	if w.war_resolve >= 0:
		if w.war_resolve >= w.wars.size() or w.wars[w.war_resolve] == null \
				or not w.wars[w.war_resolve].is_going:
			w.war_resolve = -1
		else:
			return
	for i in w.wars.size():
		var war: WarData = w.wars[i]
		if war == null or not war.is_going:
			continue
		var by_time := war.fortnight_max >= 0 and war.fortnight_elapsed >= war.fortnight_max
		# 部分战争有独立阈值，按原版结算分支判定，避免“到数值了却不结算”。
		var by_infl := false
		if i == 4:
			# 黎巴嫩战争：GameState.cs 分支中以色列胜 900（第二次黎巴嫩战争为 700）、以色列败 500。
			if w.event_done_num(371):
				by_infl = war.infl1 >= 700 or war.infl2 >= 500
			else:
				by_infl = war.infl1 >= 900 or war.infl2 >= 500
		elif i == 17:
			# 苏联遗产战争（war17）原版结算阈值是 850（GameState.cs:1005-1042），不是通用 1000。
			by_infl = war.infl1 >= 850 or war.infl2 >= 850
		else:
			by_infl = war.infl1 >= 1000 or war.infl2 >= 1000
		if by_time or by_infl:
			w.war_resolve = i
			if _start_event_cb.is_valid():
				_start_event_cb.call("war_is_over")
			if _notify_stats_cb.is_valid():
				_notify_stats_cb.call()
			return


# ============================================================================
# 查询 API
# ============================================================================

static func get_active_wars() -> Array[WarData]:
	return WarQueries.get_active_wars(current_world)


static func get_mil_intervention_display() -> String:
	return WarQueries.get_mil_intervention_display(current_world)


# ============================================================================
# 开战 / 干预
# ============================================================================

static func start_war(
		war_id: int,
		side1: String = "",
		side2: String = "",
		infl1: int = -1,
		infl2: int = -1,
		usa_side: int = -1,
		ussr_side: int = -1
) -> bool:
	var w: WorldState = current_world
	if w == null or war_id < 0:
		return false
	while w.wars.size() <= war_id:
		w.wars.append(WarData.new())
	var war: WarData = w.wars[war_id]
	if war == null:
		war = WarData.new()
		w.wars[war_id] = war
	var def := WarCatalog.get_def(war_id)
	war.is_going = true
	if def:
		war.name_war = def.name_zh
		war.side1 = side1 if side1 != "" else def.default_side1
		war.side2 = side2 if side2 != "" else def.default_side2
		war.infl1 = infl1 if infl1 >= 0 else def.default_infl1
		war.infl2 = infl2 if infl2 >= 0 else def.default_infl2
		war.usa_side = usa_side if usa_side >= GameConstants.WarSide.SIDE1 else def.default_usa_side
		war.ussr_side = ussr_side if ussr_side >= GameConstants.WarSide.SIDE1 else def.default_ussr_side
		war.fortnight_max = def.fortnight_max
	else:
		war.name_war = "战争 #%d" % war_id
		# 若确实没有 WarDef 且调用方也没给侧名，至少不再显示英文 side1/side2 占位符。
		war.side1 = side1 if side1 != "" else "未知势力（左）"
		war.side2 = side2 if side2 != "" else "未知势力（右）"
		war.infl1 = infl1 if infl1 >= 0 else 500
		war.infl2 = infl2 if infl2 >= 0 else 500
		war.usa_side = usa_side if usa_side >= GameConstants.WarSide.SIDE1 else 0
		war.ussr_side = ussr_side if ussr_side >= GameConstants.WarSide.SIDE1 else 0
	war.fortnight_elapsed = 0
	war.diplo_done = [false, false]
	WarQueries.clamp_war_infl(war)
	if _notify_stats_cb.is_valid():
				_notify_stats_cb.call()
	return true


## 干预动作是否可用（战争界面按钮置灰用）
static func can_intervene(war_id: int, action_id: int) -> bool:
	var w: WorldState = current_world
	if w == null:
		return false
	if war_id < 0 or war_id >= w.wars.size():
		return false
	var war: WarData = w.wars[war_id]
	if war == null or not war.is_going:
		return false
	var d := w
	var china := w.get_country_by_legacy_index(1)
	var china_unstab := china.level_of_instability if china != null else 0
	var side := 1 if action_id <= 3 else 2

	# 战争未结束：双方都在 0<infl<1000
	if side == 1:
		if war.infl1 >= 1000 or war.infl2 <= 0 or war.infl2 >= 1000 or war.infl1 <= 0:
			return false
	else:
		if war.infl2 >= 1000 or war.infl1 <= 0 or war.infl1 >= 1000 or war.infl2 <= 0:
			return false

	# 原版 WarButtonScript.CheckButtonAvailable 的战争编号禁用集：
	# 外交声援（3/7）禁用 16/22/69/70/90 及 69-75 区间；右方（4-7）额外禁用 29，
	# 且 war_state==1 时禁用 1 号战争；0/1/2 没有这些禁用。
	if action_id == 3 or action_id == 7:
		if war_id in [16, 22, 69, 70, 90] or (war_id >= 69 and war_id <= 75):
			return false
		# 外交声援：无资源要求，只要求本场战争尚未用过外交（左右任一用过即不可再用）
		return not (war.diplo_done[0] or war.diplo_done[1])
	elif action_id >= 4:
		if war_id in [16, 22, 69, 70, 90, 29] or (war_id >= 69 and war_id <= 75):
			return false
		if w.war_state == GameConstants.WarState.SINO_SOVIET and war_id == 1:
			return false

	# 非外交动作：data.mil_intervention（军事介入点）须 >= 10*中国不稳定度/10（即 >= level_of_instability），
	# 对齐原版 WarButtonScript.CheckButtonAvailable。
	if d.mil_intervention < china_unstab:
		return false

	# 资源门槛按原版 CheckButtonAvailable（注意 1/4 门槛是 20，但效果扣 30，原版允许负数）
	match action_id:
		0, 5:
			return d.budget + d.reserve >= 20
		1, 4:
			return d.agents >= 20
		2, 6:
			return d.army >= 30
	return false


## 执行干预动作（扣资源 + 改变战争态势/关系）
## 逐项对齐 WarButtonScript.OnMouseDown：成本/关系/科技/事件加成/党内支持消耗。
static func intervene_war(war_id: int, action_id: int) -> bool:
	if not can_intervene(war_id, action_id):
		return false
	var w: WorldState = current_world
	var war: WarData = w.wars[war_id]
	var d := w
	var china := w.get_country_by_legacy_index(1)
	var side := 1 if action_id <= 3 else 2

	# ── 扣资源与基础战争态势 ──
	match action_id:
		0, 5:
			d.budget -= 20
			WarIntervention.apply_human_aid(w, war, side)
			WarIntervention.apply_pmc(w, war, side)
		1, 4:
			d.agents -= 30
			WarIntervention.apply_base(war, side, 30)
			WarIntervention.apply_science24(w, war, side)
			WarIntervention.apply_pmc(w, war, side)
			WarIntervention.apply_event548(w, war, side, 10, 30)
		2, 6:
			d.army -= 30
			d.budget += 3
			WarIntervention.apply_base(war, side, 30 if not WarIntervention.science23(w) else 40)
			WarIntervention.apply_event517(w, war, side)
			WarIntervention.apply_event521(w, war, side)
			WarIntervention.apply_event548_2(w, war, side)
			WarIntervention.apply_pmc(w, war, side)
		3, 7:
			WarIntervention.apply_diplo(w, war, side)
			WarIntervention.apply_event548_diplo(w, war, side)
			war.diplo_done[side - 1] = true
			WarQueries.clamp_war_infl(war)
			w.mirror_empires_to_data()
			if _notify_stats_cb.is_valid():
				_notify_stats_cb.call()
			return true

	# 非外交动作共有的敌对帝国关系惩罚
	WarIntervention.apply_enemy_relation(w, war, side, -5)
	# 非外交动作共有的党内支持消耗与不稳定度增加
	WarIntervention.apply_party_cost(w, d, china)
	WarQueries.clamp_war_infl(war)
	w.mirror_empires_to_data()
	if _notify_stats_cb.is_valid():
				_notify_stats_cb.call()
	return true


# ============================================================================
# 结算
# ============================================================================

## 战争结束事件关闭后执行结算（GameManager.clear_event 调用）
static func resolve_war_finished(war_id: int = -1) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var id := war_id
	if id < 0:
		id = w.war_resolve
	if id >= 0 and id < w.wars.size() and w.wars[id] != null:
		var restarted := apply_war_result(id)
		w.wars[id].is_going = restarted
	w.war_resolve = -10
	# 战争结算后统一应用原版地图合并规则（朝鲜/也门/OAR/文莱/西撒等）
	if MapService.instance != null:
		MapService.instance.sync_map_merges()
	if _notify_stats_cb.is_valid():
				_notify_stats_cb.call()


## 返回 true 表示原战争结算后立即进入第二阶段（阿富汗战争专用）。
static func apply_war_result(war_id: int) -> bool:
	var w: WorldState = current_world
	if w == null or war_id < 0 or war_id >= w.wars.size():
		return false
	var war: WarData = w.wars[war_id]
	if war == null:
		return false
	var d := w
	# 注意：原版 WarResult 不会把军事介入点清零；不要在这里重置 data.mil_intervention。
	# 土耳其危机战争链（Event370 启动 10/11/12）走原版 GameState.cs WarResult
	# 的独立阈值结算：infl1 >= 700 即土耳其方获胜，与通用 infl1>=1000 不同。
	if war_id == 10 or war_id == 11 or war_id == 12:
		_apply_turkey_crisis_war_result(war_id, war, d)
		w.mirror_empires_to_data()
		return false
	# 两伊战争（war3）走原版 GameState.cs:216-470 的伊朗/伊拉克政权结算，
	# 不再落入通用 side1/side2/draw 分支。
	if war_id == 3:
		_apply_iran_iraq_war_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 基础战争 0/1/2/4/6 也按 GameState.cs WarResult 专属分支结算，避免通用分支遗漏细节。
	if war_id == 0:
		_apply_war0_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 1:
		_apply_war1_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 2:
		_apply_war2_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 4:
		_apply_war4_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 6:
		_apply_war6_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 土耳其-希腊/叙利亚方向战争（war8/9）走 GameState.cs:573-650 专属结算。
	if war_id == 8:
		_apply_war8_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 9:
		_apply_war9_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 印度人民战争（war7）走 GameState.cs:505-571 专属结算。
	if war_id == 7:
		_apply_war7_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 乍得战争（war20）走 GameState.cs:1135-1165 专属结算。
	if war_id == 20:
		_apply_war20_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 阿尔巴尼亚-南斯拉夫战争（war18）走 GameState.cs:1040-1062 专属结算。
	if war_id == 18:
		_apply_war18_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 也门统一战争（war21）走 GameState.cs:1167-1218 专属结算。
	if war_id == 21:
		_apply_war21_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 珍宝岛/中苏边境战争（war22）走 GameState.cs:1220-1246 专属结算。
	if war_id == 22:
		_apply_war22_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 埃塞俄比亚方向（war24）走 GameState.cs:1339-1365 专属结算。
	if war_id == 24:
		_apply_war24_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 阿富汗/巴基斯坦方向（war27）走 GameState.cs:1425-1454 专属结算。
	if war_id == 27:
		_apply_war27_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 科威特战争（war28）走 GameState.cs:1456-1531 专属结算。
	if war_id == 28:
		_apply_war28_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 塞浦路斯战争（war14）走 GameState.cs:731-768 专属结算。
	if war_id == 14:
		_apply_war14_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 欧加登战争（war15）走 GameState.cs:768-888 专属结算。
	if war_id == 15:
		_apply_war15_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 朝鲜统一战争（war16）走 GameState.cs:890-1038 专属结算。
	if war_id == 16:
		_apply_war16_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 伊拉克-科威特战争（war29）走 GameState.cs:1532-1610 专属结算。
	if war_id == 29:
		_apply_war29_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 伊朗革命战争（war33）走 GameState.cs:1765-1799 专属结算。
	if war_id == 33:
		_apply_war33_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 马来亚内战（war34）走 GameState.cs:1801-1826 专属结算。
	if war_id == 34:
		_apply_war34_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 印度尼西亚革命（war35）走 GameState.cs:1828-1875 专属结算。
	if war_id == 35:
		_apply_war35_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 阿拉伯半岛革命（war37）走 GameState.cs:1877-1934 专属结算。
	if war_id == 37:
		_apply_war37_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 科威特社会主义革命（war38）走 GameState.cs:1936-1967 专属结算。
	if war_id == 38:
		_apply_war38_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 西撒哈拉战争（war39）走 GameState.cs:1969-2007 专属结算。
	if war_id == 39:
		_apply_war39_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 阿尔及利亚内战（war40）走 GameState.cs:2009-2059 专属结算。
	if war_id == 40:
		_apply_war40_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 日本革命战争（war36）走 GameState.cs:699-730 专属结算。
	if war_id == 36:
		_apply_war36_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 叙利亚战争（war41）走 GameState.cs:2061-2180 专属结算。
	if war_id == 41:
		_apply_war41_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 也门/海湾方向（war44/45/47）走 GameState.cs 专属结算。
	if war_id == 44:
		_apply_war44_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 45:
		_apply_war45_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 47:
		_apply_war47_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 乌干达-坦桑尼亚战争（war53）走 GameState.cs:2791-2812 专属结算。
	if war_id == 53:
		_apply_war53_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 南非内战（war54）走 GameState.cs:2814-2910 专属结算。
	if war_id == 54:
		_apply_war54_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 南非周边系列战争（war55-61）走 GameState.cs 专属结算。
	if war_id == 55:
		_apply_war55_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 56:
		_apply_war56_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 57:
		_apply_war57_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 58:
		_apply_war58_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 59:
		_apply_war59_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 60:
		_apply_war60_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 61:
		_apply_war61_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 苏丹/西非方向（war42/43/46/48~52）走 GameState.cs 专属结算。
	if war_id == 42:
		_apply_war42_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 43:
		_apply_war43_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 46:
		_apply_war46_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 48:
		_apply_war48_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 49:
		_apply_war49_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 50:
		_apply_war50_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 51:
		_apply_war51_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 52:
		_apply_war52_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 62:
		_apply_war62_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 拉美/西非/东欧方向（war64-69、76-89）走 GameState.cs 专属结算。
	if war_id == 64:
		_apply_war64_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 65:
		_apply_war65_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 66:
		_apply_war66_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 67:
		_apply_war67_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 68:
		_apply_war68_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 69:
		_apply_war69_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 76:
		_apply_war76_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 77:
		_apply_war77_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 78:
		_apply_war78_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 79:
		_apply_war79_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 80:
		_apply_war80_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 82:
		_apply_war82_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 83:
		_apply_war83_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 84:
		_apply_war84_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 85:
		_apply_war85_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 86:
		_apply_war86_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 87:
		_apply_war87_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 88:
		_apply_war88_result(war, d)
		w.mirror_empires_to_data()
		return false
	if war_id == 89:
		_apply_war89_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 苏联遗产战争（war17）走 GameState.cs:1005-1042 专属结算。
	if war_id == 17:
		WarSystem._apply_legacy_war_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 第二次喀麦隆战争（war63）走 GameState.cs:3165-3203 专属结算。
	if war_id == 63:
		_apply_cameroon_war_result(war, d)
		w.mirror_empires_to_data()
		return false
	# 5/19/23/25/26/30/31/32 号战争走 GameState.WarResult 的专属阈值结算。
	if _is_achievement_war_result(war_id):
		var achievement_restarted := _apply_achievement_war_result(war_id, war, d)
		w.mirror_empires_to_data()
		return achievement_restarted
	# 珍宝岛/中南半岛/朝鲜/印度/台海/日本方向等战争走 GameState.WarResult 的 950 阈值：
	# infl1>=950 → side1 胜利（胜利特效已按 side1 接入；文案由 event_018 显示层输出）；
	# 否则 → 立即触发失败结局（GameState.cs:3742/3813/3846/3917/3978/4007/4821）。
	if _is_war_result_route(war_id):
		if war.infl1 >= 950:
			apply_war_side1_victory(war_id, war, d)
		else:
			_apply_war_result_defeat(war_id, d)
		w.mirror_empires_to_data()
		return false
	var restarted := false
	if war.infl1 >= 1000:
		restarted = apply_war_side1_victory(war_id, war, d)
	elif war.infl2 >= 1000:
		restarted = apply_war_side2_victory(war_id, war, d)
	else:
		apply_war_draw(war_id, war, d)
	w.mirror_empires_to_data()
	return restarted


## WarResult 专属阈值战争（GameState.cs 各 data.war_resolve==N 分支，含绑定成就）。
static func _is_achievement_war_result(war_id: int) -> bool:
	return war_id == 5 or war_id == 19 or war_id == 23 or war_id == 25 \
		or war_id == 26 or war_id == 30 or war_id == 31 or war_id == 32



static func _dval(d: WorldState, idx: int) -> int:
	return d.get_data_by_index(idx) if d.size() > idx else 0


static func _emp_power_val(w: WorldState, idx: int) -> int:
	if w.empires.size() > idx and w.empires[idx] != null:
		return w.empires[idx].power
	return 0


static func _war_at(w: WorldState, war_id: int) -> WarData:
	if war_id < 0 or war_id >= w.wars.size():
		return null
	return w.wars[war_id]


static func _war_going(w: WorldState, idx: int) -> bool:
	if idx < 0 or idx >= w.wars.size():
		return false
	var war: WarData = w.wars[idx]
	return war != null and war.is_going


static func _war_going_set(w: WorldState, idx: int, value: bool) -> void:
	if idx >= 0 and idx < w.wars.size() and w.wars[idx] != null:
		w.wars[idx].is_going = value


static func _add_empire_rel(w: WorldState, idx: int, delta: int) -> void:
	if w.empires.size() > idx and w.empires[idx] != null:
		w.empires[idx].relations += delta


static func _apply_achievement_war_result(war_id: int, war: WarData, d: WorldState) -> bool:
	var w: WorldState = current_world
	match war_id:
		5:
			return _war5_result(w, war, d)
		19:
			_war19_result(w, war, d)
		23:
			_war23_result(w, war, d)
		25:
			_war25_result(w, d)
		26:
			_war26_result(w, d)
		30:
			return _war30_result(w, war, d)
		31:
			_war31_result(w, d)
		32:
			_war32_result(w, d)
	return false


## GameState.cs:416-489 —— 阿富汗战争。
static func _war5_result(w: WorldState, war: WarData, d: WorldState) -> bool:
	var afg := WarQueries.wc(w, 12)
	if war.infl1 >= 900:
		if war.ussr_side == GameConstants.WarSide.SIDE1:
			add_empire_power(EmpireData.USSR, 50)
		elif war.ussr_side == GameConstants.WarSide.NONE:
			if afg != null:
				afg.government = GameConstants.Government.SOCIALIST
				afg.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				afg.set_tag("亲苏", false)
				afg.set_tag("亲中", true)
				afg.set_tag("对华贸易", true)
				afg.prc_power = 1000
			if d.size() > W.I_INFLUENCE:
				d.global_influence += 100
		elif war.ussr_side == GameConstants.WarSide.SIDE2:
			if afg != null:
				afg.government = GameConstants.Government.SOCIALIST
				afg.sub_government = GameConstants.SubGovernment.MAOIST
				afg.set_tag("亲苏", false)
				afg.set_tag("亲中", true)
				afg.set_tag("对华贸易", true)
				afg.prc_power = 1000
			if d.size() > W.I_INFLUENCE:
				d.global_influence += 100
			# GameState.cs:446-448
			Achievements.set_achievement(54)
	elif war.ussr_side == GameConstants.WarSide.SIDE2:
		# 第二阶段重启（GameState.cs:452-477）
		war.name_war = "阿 富 汗 内 战"
		war.is_going = true
		war.side1 = "阿 富 汗 民 主 共 和 国"
		war.side2 = "圣 战 者"
		war.ussr_side = GameConstants.WarSide.SIDE1
		war.usa_side = GameConstants.WarSide.SIDE2
		war.infl1 = 650
		war.infl2 = 350
		var c31 := WarQueries.wc(w, 31)
		if c31 != null and c31.has_tag("亲美"):
			war.infl1 -= 100
			war.infl2 += 100
		var c8 := WarQueries.wc(w, 8)
		if c8 != null and c8.government == GameConstants.Government.AUTHORITARIAN:
			war.infl1 -= 50
			war.infl2 += 50
		if d.size() > 107 and d.afghan_war_path == 9:
			war.infl1 += 25
			war.infl2 -= 25
		WarQueries.clamp_war_infl(war)
		return true
	else:
		if afg != null:
			afg.government = GameConstants.Government.AUTHORITARIAN
			afg.sub_government = GameConstants.SubGovernment.NEOPATRIARCHAL
			afg.set_tag("亲苏", false)
			afg.set_tag("亲中", false)
			afg.set_tag("对华贸易", false)
		add_empire_power(EmpireData.USSR, -30)
	return false


## GameState.cs:1062-1134 —— 阿尔巴尼亚-希腊战争。
static func _war19_result(w: WorldState, war: WarData, d: WorldState) -> void:
	var alb := WarQueries.wc(w, 20)
	var greece := WarQueries.wc(w, 45)
	if war.infl1 >= 900:
		if alb != null and alb.has_tag("亲中") and d.size() > W.I_INFLUENCE:
			d.global_influence -= 100
		if alb != null:
			if alb.parts.size() < 2:
				alb.parts.resize(2)
			alb.parts[0] = false
			alb.parts[1] = true
			alb.leave_alliances()
			alb.set_tag("亲中", false)
			alb.set_tag("对华贸易", false)
			alb.name = "大 阿 尔 巴 尼 亚"
			alb.chinese_name = "大 阿 尔 巴 尼 亚"
			alb.government = GameConstants.Government.AUTHORITARIAN
			alb.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
		if greece != null:
			greece.set_tag("对华贸易", false)
			greece.government = GameConstants.Government.AUTHORITARIAN
			greece.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			var usa := WarQueries.wc(w, 51)
			if usa != null and usa.has_tag("nato"):
				greece.set_tag("nato", true)
		# GameState.cs:1078-1081
		Achievements.set_achievement(133)
	elif war.infl2 >= 700:
		if alb != null:
			alb.leave_alliances()
			alb.set_tag("亲中", false)
			alb.set_tag("对华贸易", false)
			alb.government = GameConstants.Government.AUTHORITARIAN
			alb.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
		var c51 := WarQueries.wc(w, 51)
		var ussr := _emp_power_val(w, 1)
		if c51 != null and c51.has_tag("nato"):
			if greece != null:
				greece.set_tag("nato", true)
				greece.government = 5
		elif ussr > _dval(d, W.I_INFLUENCE):
			if greece != null:
				greece.set_tag("ovd", true)
				greece.government = 5
		else:
			if greece != null:
				greece.set_tag("okb", true)
				greece.government = 5


## GameState.cs:1247-1338 —— 意大利激进派起义。
static func _war23_result(w: WorldState, war: WarData, d: WorldState) -> void:
	var italy := WarQueries.wc(w, 85)
	var c87 := WarQueries.wc(w, 87)
	if not w.event_done_num(556):
		if war.infl1 >= 900:
			if d.size() > W.I_INFLUENCE:
				d.global_influence += 50
			add_empire_power(EmpireData.USA, -50)
			if italy != null:
				italy.name = "意 大 利 人 民 国"
				italy.chinese_name = "意 大 利 人 民 国"
			# GameState.cs:1259-1262
			Achievements.set_achievement(123)
			if c87 != null:
				c87.special -= 20
			if italy != null:
				italy.leave_alliances()
				italy.establish_government(2)
				italy.set_tag("对华贸易", true)
				italy.government = GameConstants.Government.AUTHORITARIAN
				italy.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
		else:
			add_empire_power(EmpireData.USA, 50)
			if d.size() > W.I_INFLUENCE:
				d.global_influence -= 50
			if italy != null:
				italy.government = GameConstants.Government.AUTHORITARIAN
				italy.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			if d.size() > 134:
				d.italian_radical_left_power = 0
			if italy != null:
				italy.内战中 = false
				italy.政变中 = false
	elif war.infl1 >= 900:
		if d.size() > W.I_INFLUENCE:
			d.global_influence += 50
		add_empire_power(EmpireData.USA, -50)
		_add_empire_rel(w, 0, -250)
		_add_empire_rel(w, 1, -50)
		if c87 != null:
			c87.special -= 20
		if italy != null:
			italy.leave_alliances()
			italy.establish_government(2)
			italy.set_tag("对华贸易", true)
			if d.size() > 184 and d.italy_hot_autumn_route == 1:
				italy.government = GameConstants.Government.AUTHORITARIAN
				italy.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				italy.name = "意 大 利 苏 维 埃 联 邦"
				italy.chinese_name = "意 大 利 苏 维 埃 联 邦"
			elif d.size() > 184 and d.italy_hot_autumn_route == 2:
				italy.government = GameConstants.Government.SOCIALIST
				italy.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				italy.name = "意 大 利 苏 维 埃 共 和 国"
				italy.chinese_name = "意 大 利 苏 维 埃 共 和 国"
			else:
				italy.government = GameConstants.Government.SOCIALIST
				italy.sub_government = GameConstants.SubGovernment.MAOIST
				italy.name = "意 大 利 社 会 主 义 共 和 国"
				italy.chinese_name = "意 大 利 社 会 主 义 共 和 国"
	else:
		add_empire_power(EmpireData.USA, 20)
		if d.size() > W.I_INFLUENCE:
			d.global_influence -= 15
		_add_empire_rel(w, 0, -150)
		if italy != null:
			italy.government = GameConstants.Government.AUTHORITARIAN
			italy.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			italy.leave_alliances()
			italy.set_tag("亲美", true)
		var c0 := WarQueries.wc(w, 0)
		if c0 != null and italy != null:
			if c0.has_tag("eu"):
				italy.set_tag("eu", true)
			if c0.has_tag("nato"):
				italy.set_tag("nato", true)
		if d.size() > 134:
			d.italian_radical_left_power = 0
		if italy != null:
			italy.内战中 = false
			italy.政变中 = false


## GameState.cs:1362-1387 —— 埃塞俄比亚方向。
static func _war25_result(w: WorldState, d: WorldState) -> void:
	if d.size() <= W.I_WAR_RESOLVE:
		return
	var war := _war_at(w, d.war_resolve)
	if war != null and war.infl2 >= 900:
		# 原版条件：99.parts[0] && 42.parts[0]
		var c99c := w.get_country_by_legacy_index(99)
		var c42 := w.get_country_by_legacy_index(42)
		if c99c != null and c42 != null and c99c.parts.size() > 0 and c99c.parts[0] \
				and c42.parts.size() > 0 and c42.parts[0]:
			Achievements.set_achievement(143)
		var c100 := w.get_country_by_legacy_index(100)
		if c100 != null:
			c100.establish_government(2)
			c100.set_tag("对华贸易", true)
			c100.special = 1
			c100.government = GameConstants.Government.REFORMIST
			c100.sub_government = GameConstants.SubGovernment.PRAGMATIST
			c100.social_stability = 1000
			c100.influence_china = 500
			c100.influence_nato = 500
		if d.size() > W.I_INFLUENCE:
			d.global_influence += 5
		add_empire_power(EmpireData.USSR, -5)
	else:
		var c100 := w.get_country_by_legacy_index(100)
		if c100 != null and c100.parts.size() > 0:
			c100.parts[0] = false


## GameState.cs:1388-1424 —— 索马里方向。
static func _war26_result(w: WorldState, d: WorldState) -> void:
	if d.size() <= W.I_WAR_RESOLVE:
		return
	var war := _war_at(w, d.war_resolve)
	if war != null and war.infl2 >= 900:
		var c100 := w.get_country_by_legacy_index(100)
		var c42 := w.get_country_by_legacy_index(42)
		if c100 != null and c42 != null and c100.parts.size() > 0 and c100.parts[0] \
				and c42.parts.size() > 0 and c42.parts[0]:
			Achievements.set_achievement(143)
		var c99 := w.get_country_by_legacy_index(99)
		if c99 != null:
			c99.set_tag("对华贸易", true)
			c99.special = 1
			c99.government = GameConstants.Government.REFORMIST
			c99.sub_government = GameConstants.SubGovernment.PRAGMATIST
			if not w.event_done_num(434):
				c99.influence_china = 500
				c99.social_stability = 1000
				c99.influence_nato = 500
				c99.establish_government(2)
			if not w.event_done_num(434) \
					or (w.event_done_num(434) and w.result_of_event_num(434) >= 2):
				if d.size() > W.I_INFLUENCE:
					d.global_influence += 15
		add_empire_power(EmpireData.USSR, -15)
	else:
		var c99 := w.get_country_by_legacy_index(99)
		if c99 != null:
			if c99.parts.size() > 0:
				c99.parts[0] = false
			c99.puppet_of = GameConstants.LegacySlot.NONE
		if w.event_done_num(434) and w.result_of_event_num(434) == 1:
			var c41 := w.get_country_by_legacy_index(41)
			if c41 != null:
				c41.set_tag("对华贸易", true)


## 西班牙分离主义地块回落：parts 清 false 时把对应省归还西班牙(230)。
## 对应 MapChangesScript.ShowParts 关闭 country_basks.png / katalonia.png 覆盖层。
static func _revert_spain_parts_map(w: WorldState, revert_basque: bool, revert_catalonia: bool) -> void:
	if w == null:
		return
	var spain := w.get_country_by_legacy_index(86)
	var spain_gw := SPAIN_GWCODE
	if spain != null and spain.gwcode > 0:
		spain_gw = spain.gwcode
	if revert_basque and MapService.instance != null:
		MapService.instance.set_region_owner(SPAIN_BASQUE_REGION_IDS, spain_gw)
	if revert_catalonia and MapService.instance != null:
		MapService.instance.set_region_owner(SPAIN_CATALONIA_REGION_IDS, spain_gw)


## GameState.cs:1627-1730 —— 西班牙内战。
static func _war30_result(w: WorldState, war: WarData, _d: WorldState) -> bool:
	var spain := WarQueries.wc(w, 86)
	if war.infl1 >= 800:
		_war_going_set(w, 31, false)
		_war_going_set(w, 32, false)
		if w.result_of_event_num(426) == 3 and spain != null:
			spain.government = GameConstants.Government.SOCIALIST
			spain.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			spain.leave_alliances()
			spain.set_tag("亲中", true)
			spain.set_tag("对华贸易", true)
			spain.name = "西 班 牙 联 邦"
			spain.chinese_name = "西 班 牙 联 邦"
		elif w.result_of_event_num(426) == 4 and spain != null:
			spain.government = GameConstants.Government.REFORMIST
			spain.sub_government = GameConstants.SubGovernment.TITOIST
			spain.leave_alliances()
			spain.name = "西 班 牙 人 民 联 合 王 国"
			spain.chinese_name = "西 班 牙 人 民 联 合 王 国"
		elif spain != null:
			spain.name = "西 班 牙 共 和 国"
			spain.chinese_name = "西 班 牙 共 和 国"
	elif war.infl2 >= 800:
		if w.result_of_event_num(426) == 4:
			# 第二阶段重启（GameState.cs:1665-1677）
			war.name_war = "西 班 牙 内 战 第 二 阶 段"
			war.is_going = true
			war.ussr_side = GameConstants.WarSide.NONE
			war.usa_side = GameConstants.WarSide.NONE
			war.infl1 = 300
			war.infl2 = 700
			WarQueries.clamp_war_infl(war)
			return true
		else:
			Achievements.set_achievement(151)
			_war_going_set(w, 31, false)
			_war_going_set(w, 32, false)
			if spain != null:
				if spain.parts.size() > 0:
					spain.parts[0] = false
				if spain.parts.size() > 1:
					spain.parts[1] = false
				_revert_spain_parts_map(w, true, true)
				spain.name = "长 枪 党 西 班 牙"
				spain.chinese_name = "长 枪 党 西 班 牙"
				spain.government = GameConstants.Government.AUTHORITARIAN
				spain.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
	else:
		if spain != null:
			spain.government = GameConstants.Government.REFORMIST
			spain.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
	return false


## GameState.cs:1731-1747。
static func _war31_result(w: WorldState, d: WorldState) -> void:
	if d.size() <= W.I_WAR_RESOLVE:
		return
	var war := _war_at(w, d.war_resolve)
	var spain := w.get_country_by_legacy_index(86)
	if war != null and war.infl1 >= 900:
		if spain != null and spain.parts.size() > 1 and spain.parts[1] \
				and not _war_going(w, 32):
			Achievements.set_achievement(151)
	else:
		if spain != null and spain.parts.size() > 0:
			spain.parts[0] = false
			_revert_spain_parts_map(w, true, false)
		var c109 := w.get_country_by_legacy_index(109)
		if c109 != null:
			c109.set_tag("对华贸易", false)


## GameState.cs:1748-1764。
static func _war32_result(w: WorldState, d: WorldState) -> void:
	if d.size() <= W.I_WAR_RESOLVE:
		return
	var war := _war_at(w, d.war_resolve)
	var spain := w.get_country_by_legacy_index(86)
	if war != null and war.infl1 >= 900:
		if spain != null and spain.parts.size() > 0 and spain.parts[0] \
				and not _war_going(w, 31):
			Achievements.set_achievement(151)
	else:
		if spain != null and spain.parts.size() > 1:
			spain.parts[1] = false
			_revert_spain_parts_map(w, false, true)
		var c110 := w.get_country_by_legacy_index(110)
		if c110 != null:
			c110.set_tag("对华贸易", false)


## 苏联遗产战争（war17）结算：GameState.cs:1005-1042。
static func _apply_legacy_war_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	if war.infl1 >= 850:
		add_empire_power(EmpireData.USSR, -100)
		add_empire_power(EmpireData.USA, -100)
		d.global_influence += 150
		var yugo := w.get_country_by_legacy_index(15)
		if yugo != null:
			yugo.set_tag("对华贸易", true)
	else:
		for c in w.countries:
			if c != null and c.has_tag("ovd"):
				c.set_tag("ovd", false)
				c.set_tag("亲中", false)
				c.set_tag("亲苏", true)
				c.set_tag("亲美", false)
				c.set_tag("nato", true)
				c.set_tag("sev", true)
				d.global_influence -= 200
				c.set_tag("对华贸易", false)
				var ussr := w.get_country_by_legacy_index(7)
				if ussr != null:
					c.government = ussr.government
					c.sub_government = ussr.sub_government
		var czech := w.get_country_by_legacy_index(3)
		if czech != null:
			if czech.parts.size() > 0:
				czech.parts[0] = false
			czech.name = "捷克"
			czech.chinese_name = "捷克"
		for p in w.politicians:
			if p != null:
				p.loyalty -= 400


## 第二次喀麦隆战争（war63）结算：GameState.cs:3165-3203。
static func _apply_cameroon_war_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var cameroon := w.get_country_by_legacy_index(66)
	if cameroon != null and cameroon.parts.size() > 0:
		cameroon.parts[0] = false
	if war.infl2 >= 900:
		if cameroon != null:
			cameroon.government = GameConstants.Government.SOCIALIST
			cameroon.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
			_leave_alliances(cameroon)
			cameroon.set_tag("对华贸易", true)
			cameroon.set_tag("亲中", true)
			cameroon.name = "喀麦隆人民共和国"
			cameroon.chinese_name = "喀麦隆人民共和国"
		d.global_influence += 20
		w.oil_prod += 100.0
	elif war.infl2 >= 700:
		# 原版 GameState.cs:3195-3203：infl2>=700 且法国为社会主义时，
		# 马蒂普叛变夺权、喀人盟合法化、国家民主化（gov=2/sub=8）。
		# （旧版条件误写成“法国非社会主义”，已按原版反转。）
		var france := w.get_country_by_legacy_index(21)
		if france != null and w.is_socialism(france, false):
			if cameroon != null:
				cameroon.government = GameConstants.Government.REFORMIST
				cameroon.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
	else:
		if cameroon != null:
			cameroon.government = GameConstants.Government.AUTHORITARIAN
			cameroon.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		d.global_influence -= 20


## 战争 7 号结算：GameState.cs:505-571。
static func _apply_war7_result(war: WarData, _d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var india := w.get_country_by_legacy_index(19)
	var res125 := w.result_of_event_num(125)
	if war.infl1 >= 900:
		if res125 == 0:
			if india != null:
				_join_all_our_alliances(w, india)
				india.set_tag("亲中", true)
				india.government = GameConstants.Government.SOCIALIST
				india.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				india.social_stability = 1000
				india.set_tag("对华贸易", true)
		elif res125 == 1:
			if india != null:
				india.set_tag("sev", false)
				india.set_tag("ovd", false)
				india.set_tag("okb", false)
				india.set_tag("econ", false)
				india.set_tag("亲中", false)
				india.government = GameConstants.Government.REFORMIST
				india.sub_government = GameConstants.SubGovernment.PRAGMATIST
				india.set_tag("对华贸易", false)
				india.set_tag("亲苏", true)
	elif res125 == 1:
		if india != null:
			_leave_alliances(india)
			_join_all_our_alliances(w, india)
			india.set_tag("亲中", true)
			india.government = GameConstants.Government.SOCIALIST
			india.sub_government = GameConstants.SubGovernment.MAOIST
			india.set_tag("对华贸易", true)
			india.social_stability = 1000
		for c in w.countries:
			if c != null and c.puppet_of == 19:
				c.puppet_of = GameConstants.LegacySlot.NONE
	elif res125 == 0:
		if india != null:
			india.set_tag("sev", false)
			india.set_tag("ovd", false)
			india.set_tag("okb", false)
			india.set_tag("econ", false)
			india.set_tag("亲中", false)
			india.government = GameConstants.Government.AUTHORITARIAN
			india.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
			india.set_tag("对华贸易", false)
			india.set_tag("亲美", true)
		for c in w.countries:
			if c != null and c.puppet_of == 19:
				c.puppet_of = GameConstants.LegacySlot.NONE


## 战争 28 号结算：GameState.cs:1456-1531。
static func _apply_war28_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var kuwait := w.get_country_by_legacy_index(36)
	var iraq := w.get_country_by_legacy_index(14)
	var egypt := w.get_country_by_legacy_index(30)
	if not w.event_done_num(571):
		if war.infl1 >= 800:
			if iraq != null and w.is_socialism(iraq, true):
				if kuwait != null:
					kuwait.government = GameConstants.Government.SOCIALIST
					kuwait.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					_leave_alliances(kuwait)
					kuwait.set_tag("oil", false)
					_join_all_our_alliances(w, kuwait)
					if iraq.has_tag("oar"):
						kuwait.set_tag("oar", true)
					kuwait.name = "科威特社会主义共和国"
					kuwait.chinese_name = "科威特社会主义共和国"
					kuwait.set_tag("对华贸易", true)
					kuwait.set_tag("亲中", true)
				if iraq.parts.size() <= 5:
					iraq.parts.resize(6)
				iraq.parts[5] = true
			else:
				if iraq != null:
					if iraq.parts.size() > 4 and iraq.parts[4]:
						iraq.parts[4] = false
						if iraq.parts.size() <= 6:
							iraq.parts.resize(7)
						iraq.parts[6] = true
					else:
						if iraq.parts.size() <= 5:
							iraq.parts.resize(6)
						iraq.parts[5] = true
				if kuwait != null:
					kuwait.set_tag("对华贸易", false)
					_leave_alliances(kuwait)
					kuwait.set_tag("oil", false)
				add_empire_power(EmpireData.USA, -20)
				d.oil_price += 5
		elif iraq != null and w.is_socialism(iraq, true):
			if kuwait != null:
				kuwait.set_tag("对华贸易", false)
				kuwait.内战中 = true
			if iraq != null:
				iraq.development = 1
		else:
			if kuwait != null:
				kuwait.set_tag("对华贸易", false)
				kuwait.内战中 = true
			if iraq != null:
				iraq.development = 1
	elif war.infl1 >= 950:
		if kuwait != null:
			kuwait.set_tag("对华贸易", false)
			_leave_alliances(kuwait)
			if egypt != null:
				kuwait.government = egypt.government
				kuwait.sub_government = egypt.sub_government
			kuwait.puppet_of = 30
			kuwait.set_tag("oil", false)
		if egypt != null:
			egypt.set_tag("亲中", true)
	else:
		if kuwait != null:
			kuwait.set_tag("对华贸易", false)
			kuwait.set_tag("亲中", false)
		if egypt != null:
			egypt.set_tag("亲中", false)


## 战争 24 号结算：GameState.cs:1339-1365。
static func _apply_war24_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var ethiopia := w.get_country_by_legacy_index(41)
	if war.infl2 >= 900:
		if ethiopia != null:
			ethiopia.set_tag("亲中", true)
			ethiopia.set_tag("亲苏", false)
			ethiopia.set_tag("亲美", false)
			ethiopia.set_tag("对华贸易", true)
			ethiopia.government = GameConstants.Government.REFORMIST
			ethiopia.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			ethiopia.influence_china = 500
			ethiopia.influence_nato = 500
			ethiopia.chinese_name = "埃塞俄比亚人民民主共和国"
			ethiopia.social_stability = 1000
		d.global_influence += 15
		add_empire_power(EmpireData.USSR, -15)
	else:
		d.global_influence -= 15
		add_empire_power(EmpireData.USSR, 30)


## 战争 27 号结算：GameState.cs:1425-1454。
static func _apply_war27_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var afghan := w.get_country_by_legacy_index(22)
	var china := w.get_country_by_legacy_index(1)
	var usa := w.get_country_by_legacy_index(51)
	if war.infl1 >= 500:
		add_empire_power(EmpireData.USSR, 50)
		if afghan != null:
			afghan.set_tag("sev", true)
		add_empire_power(EmpireData.USA, -10)
		d.global_influence -= 10
	else:
		if afghan != null:
			afghan.set_tag("对华贸易", true)
		add_empire_power(EmpireData.USA, -30)
		if w.influence_prc >= (w.empires[EmpireData.USA].power if w.empires.size() > EmpireData.USA else 0):
			d.global_influence += 30
			if afghan != null:
				afghan.set_tag("亲中", true)
				afghan.set_tag("亲苏", false)
				afghan.set_tag("亲美", false)
				if china != null:
					afghan.government = china.government
					afghan.sub_government = china.sub_government
		else:
			add_empire_power(EmpireData.USA, 30)
			if afghan != null:
				afghan.set_tag("亲中", false)
				afghan.set_tag("亲苏", false)
				afghan.set_tag("亲美", true)
				if usa != null:
					afghan.government = usa.government
					afghan.sub_government = usa.sub_government


## 战争 21 号结算：GameState.cs:1167-1218。
static func _apply_war21_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c24 := w.get_country_by_legacy_index(24)
	var c25 := w.get_country_by_legacy_index(25)
	if war.infl1 >= 900:
		if c25 != null and c25.has_tag("亲美"):
			if c25.parts.size() <= 0:
				c25.parts.resize(1)
			c25.parts[0] = true
			c25.name = "也门共和国"
			c25.chinese_name = "也门共和国"
			c25.set_tag("对华贸易", true)
			if c24 != null:
				c24.set_tag("亲苏", false)
			add_empire_power(EmpireData.USSR, -25)
			add_empire_power(EmpireData.USA, 25)
		elif c25 != null and c25.has_tag("亲中"):
			if c25.parts.size() <= 0:
				c25.parts.resize(1)
			c25.parts[0] = true
			c25.name = "也门共和国"
			c25.chinese_name = "也门共和国"
			c25.set_tag("对华贸易", true)
			if c24 != null:
				c24.set_tag("亲苏", false)
			add_empire_power(EmpireData.USSR, -25)
			d.global_influence += 25
	elif war.infl2 >= 900:
		if c24 != null and c24.has_tag("亲苏"):
			if c24.parts.size() <= 0:
				c24.parts.resize(1)
			c24.parts[0] = true
			c24.name = "也门共和国"
			c24.chinese_name = "也门共和国"
			c24.set_tag("对华贸易", true)
			if c25 != null:
				c25.set_tag("亲美", false)
			add_empire_power(EmpireData.USA, -25)
			add_empire_power(EmpireData.USSR, 25)
		elif c24 != null and c24.has_tag("亲中"):
			if c24.parts.size() <= 0:
				c24.parts.resize(1)
			c24.parts[0] = true
			c24.name = "也门共和国"
			c24.chinese_name = "也门共和国"
			c24.set_tag("对华贸易", true)
			if c25 != null:
				c25.set_tag("亲美", false)
			add_empire_power(EmpireData.USA, -25)
			d.global_influence += 25


## 战争 22 号结算：GameState.cs:1220-1246。
static func _apply_war22_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	if war.infl1 >= 900:
		d.soviet_reorganization_war_state = 1
		if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
			w.empires[EmpireData.USSR].relations = 0
		add_empire_power(EmpireData.USSR, -100)
		d.global_influence += 100
		d.people_support += 150
	else:
		d.soviet_reorganization_war_state = 3
		add_empire_power(EmpireData.USSR, 100)
		if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
			w.empires[EmpireData.USSR].relations = 0
		d.people_support -= 600
		d.thought_freedom += 900
		d.global_influence -= 100


## 战争 18 号结算：GameState.cs:1040-1062。
static func _apply_war18_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var albania := w.get_country_by_legacy_index(20)
	var yugoslavia := w.get_country_by_legacy_index(15)
	if war.infl1 >= 900:
		d.global_influence += 50
		if albania != null and albania.parts.size() <= 0:
			albania.parts.resize(1)
		if albania != null:
			albania.parts[0] = true
		if yugoslavia != null:
			yugoslavia.set_tag("亲美", true)
			yugoslavia.set_tag("eu", true)
			yugoslavia.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
	else:
		if albania != null and yugoslavia != null:
			albania.sub_government = yugoslavia.sub_government
			albania.government = GameConstants.Government.REFORMIST
			_leave_alliances(albania)
			albania.puppet_of = 15
			albania.set_tag("亲中", false)
		d.global_influence -= 50


## 战争 14 号结算：GameState.cs:731-768。
static func _apply_war14_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var cyprus := w.get_country_by_legacy_index(94)
	var turkey := w.get_country_by_legacy_index(84)
	if war.infl1 >= 700:
		if cyprus != null:
			_leave_alliances(cyprus)
			cyprus.name = "塞浦路斯（受监护）"
			cyprus.chinese_name = "塞浦路斯（受监护）"
			cyprus.government = GameConstants.Government.LIBERAL
			cyprus.sub_government = GameConstants.SubGovernment.MODERATE
			cyprus.puppet_of = 84
		var iraq := w.get_country_by_legacy_index(14)
		var iran := w.get_country_by_legacy_index(8)
		var syria := w.get_country_by_legacy_index(35)
		if iraq != null and iraq.puppet_of == 84 and iran != null and iran.puppet_of == 84 \
				and syria != null and syria.puppet_of == 84 and d.turkish_route_result == 100:
			if turkey != null:
				if turkey.parts.size() <= 5:
					turkey.parts.resize(6)
				turkey.parts[5] = true
				turkey.name = "大土耳其"
				turkey.chinese_name = "大土耳其"
	elif war.infl2 >= 500:
		d.cyprus_greek_victory_flag = 1
		d.turkish_route_result = 100
		if cyprus != null:
			if cyprus.parts.size() <= 0:
				cyprus.parts.resize(1)
			cyprus.parts[0] = true
			if cyprus.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST:
				cyprus.government = GameConstants.Government.AUTHORITARIAN
				cyprus.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST


## 战争 15 号结算：GameState.cs:768-888。
static func _apply_war15_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var ethiopia := w.get_country_by_legacy_index(41)
	var somalia := w.get_country_by_legacy_index(42)
	if not w.event_done_num(588):
		if ethiopia != null and ethiopia.government == GameConstants.Government.SOCIALIST:
			if war.infl1 >= 850:
				_set_pro_china(ethiopia)
				_set_pro_soviet(somalia)
				if somalia != null:
					somalia.government = GameConstants.Government.AUTHORITARIAN
					somalia.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
					if somalia.parts.size() <= 0:
						somalia.parts.resize(1)
					somalia.parts[0] = true
				add_empire_power(EmpireData.USSR, 20)
			else:
				_set_pro_china(ethiopia)
				_set_pro_soviet(somalia)
				if somalia != null:
					somalia.government = GameConstants.Government.AUTHORITARIAN
					somalia.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				d.global_influence += 10
		elif ethiopia != null and ethiopia.has_tag("亲中"):
			if war.infl1 >= 850:
				_set_pro_china(ethiopia)
				_set_pro_soviet(somalia)
				if somalia != null:
					somalia.government = GameConstants.Government.AUTHORITARIAN
					somalia.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
					if somalia.parts.size() <= 0:
						somalia.parts.resize(1)
					somalia.parts[0] = true
				add_empire_power(EmpireData.USSR, 20)
			else:
				_set_pro_china(ethiopia)
				_set_pro_soviet(somalia)
				if somalia != null:
					somalia.government = GameConstants.Government.AUTHORITARIAN
					somalia.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				d.global_influence += 10
		elif war.infl1 >= 850:
			_set_pro_china(somalia)
			if somalia != null:
				somalia.set_tag("对华贸易", true)
				if somalia.parts.size() <= 0:
					somalia.parts.resize(1)
				somalia.parts[0] = true
			d.global_influence += 10
		else:
			if somalia != null:
				somalia.government = GameConstants.Government.AUTHORITARIAN
				somalia.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			add_empire_power(EmpireData.USSR, 20)
	elif war.infl1 >= 900:
		if somalia != null and not somalia.has_tag("亲中") and ethiopia != null and ethiopia.has_tag("亲苏"):
			_set_pro_china(somalia)
			somalia.set_tag("对华贸易", true)
			d.global_influence += 10
		if somalia != null:
			if somalia.parts.size() > 1 and somalia.parts[1]:
				somalia.parts[1] = false
				if somalia.parts.size() <= 2:
					somalia.parts.resize(3)
				somalia.parts[2] = true
			else:
				if somalia.parts.size() <= 0:
					somalia.parts.resize(1)
				somalia.parts[0] = true
	elif war.infl2 >= 900:
		if somalia != null:
			if somalia.parts.size() > 1 and (somalia.parts[1] or (somalia.parts.size() > 2 and somalia.parts[2])):
				somalia.parts[1] = false
				if somalia.parts.size() > 2:
					somalia.parts[2] = false
		if ethiopia != null:
			if ethiopia.parts.size() <= 1:
				ethiopia.parts.resize(2)
			ethiopia.parts[1] = true
			ethiopia.set_tag("对华贸易", true)
		add_empire_power(EmpireData.USSR, 20)
	else:
		if somalia != null and not somalia.has_tag("亲美") and not somalia.has_tag("亲苏"):
			_set_pro_american(somalia)
			somalia.government = GameConstants.Government.AUTHORITARIAN
			somalia.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			add_empire_power(EmpireData.USA, 20)


## 战争 16 号结算：GameState.cs:890-1038。
static func _apply_war16_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var north := w.get_country_by_legacy_index(10)
	var china := w.get_country_by_legacy_index(1)
	if war.infl1 >= 950:
		d.somalia_china_route = 1
		add_empire_power(EmpireData.USSR, -50)
		d.global_influence += 50
		if north != null:
			if china != null:
				north.government = china.government
				north.sub_government = china.sub_government
			_join_all_our_alliances(w, north)
			_set_pro_china(north)
			north.puppet_of = GameConstants.LegacySlot.CHINA
			north.set_tag("对华贸易", true)
			north.name = "朝鲜民主主义人民共和国"
			north.chinese_name = "朝鲜民主主义人民共和国"
			if north.sub_government == GameConstants.SubGovernment.TROTSKYIST:
				if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
					w.empires[EmpireData.USSR].relations = clampi(w.empires[EmpireData.USSR].relations + 120, 0, 1000)
				if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
					w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations - 120, 0, 1000)
		add_empire_power(EmpireData.USSR, 70)
		d.budget -= 500
		d.army -= 500
		d.global_influence -= 100
	else:
		add_empire_power(EmpireData.USSR, 70)
		d.budget -= 500
		d.army -= 500
		d.global_influence -= 100
		for p in w.politicians:
			if p != null:
				p.loyalty -= 750


## 战争 29 号结算：GameState.cs:1532-1610。
static func _apply_war29_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var kuwait := w.get_country_by_legacy_index(36)
	var iraq := w.get_country_by_legacy_index(14)
	var china := w.get_country_by_legacy_index(1)
	var usa := w.get_country_by_legacy_index(51)
	var ussr := w.get_country_by_legacy_index(7)
	if kuwait != null:
		kuwait.内战中 = false
	if war.infl1 >= 900:
		if iraq != null:
			_leave_alliances(iraq)
			iraq.development = 1
			if china != null and china.has_tag("ovd"):
				if w.influence_prc >= (w.empires[EmpireData.USSR].power if w.empires.size() > EmpireData.USSR else 0):
					_set_pro_china(iraq)
					_join_all_our_alliances(w, iraq)
					if china != null:
						iraq.government = china.government
						iraq.sub_government = china.sub_government
					iraq.puppet_of = GameConstants.LegacySlot.CHINA
					iraq.set_tag("对华贸易", true)
					d.global_influence += 50
					iraq.social_stability = 1000
				else:
					_set_pro_soviet(iraq)
					_join_all_our_alliances(w, iraq)
					if ussr != null:
						iraq.government = ussr.government
						iraq.sub_government = ussr.sub_government
					iraq.puppet_of = 7
					iraq.set_tag("对华贸易", true)
					add_empire_power(EmpireData.USSR, 50)
			elif china != null and china.has_tag("seato"):
				if w.influence_prc >= (w.empires[EmpireData.USA].power if w.empires.size() > EmpireData.USA else 0):
					_set_pro_china(iraq)
					_join_all_our_alliances(w, iraq)
					if china != null:
						iraq.government = china.government
						iraq.sub_government = china.sub_government
					iraq.puppet_of = GameConstants.LegacySlot.CHINA
					iraq.set_tag("对华贸易", true)
					d.global_influence += 50
					iraq.social_stability = 1000
				else:
					_set_pro_american(iraq)
					_join_all_our_alliances(w, iraq)
					if usa != null:
						iraq.government = usa.government
						iraq.sub_government = usa.sub_government
					iraq.puppet_of = 51
					iraq.set_tag("对华贸易", true)
					add_empire_power(EmpireData.USA, 50)
			else:
				_set_pro_china(iraq)
				_join_all_our_alliances(w, iraq)
				if china != null:
					iraq.government = china.government
					iraq.sub_government = china.sub_government
				iraq.puppet_of = GameConstants.LegacySlot.CHINA
				iraq.set_tag("对华贸易", true)
				d.global_influence += 50
				iraq.social_stability = 1000
	elif war.infl2 >= 500:
		d.global_influence -= 50
	else:
		d.global_influence -= 30


## 战争 33 号结算：GameState.cs:1765-1799。
static func _apply_war33_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var iran := w.get_country_by_legacy_index(8)
	var iraq := w.get_country_by_legacy_index(14)
	if war.infl1 >= 900:
		d.global_influence += 50
		w.set_flag("iranrev", false)
		if iran != null:
			_leave_alliances(iran)
			iran.government = GameConstants.Government.SOCIALIST
			iran.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
			iran.name = "伊朗人民民主共和国"
			iran.chinese_name = "伊朗人民民主共和国"
			iran.set_tag("对华贸易", true)
			iran.set_tag("亲中", true)
			iran.prc_power = 1000
		if iraq != null and iraq.puppet_of == 8:
			iraq.puppet_of = GameConstants.LegacySlot.NONE
			if iran != null:
				iraq.government = iran.government
				iraq.sub_government = iran.sub_government
		# GameState.cs:1779-1782：战争33胜利时把战争3影响力钳到伊朗方胜利。
		if w.wars.size() > 3 and w.wars[3] != null and w.wars[3].is_going:
			w.wars[3].infl1 = 1000
			w.wars[3].infl2 = 0
	else:
		w.set_flag("iranrev", false)
		if iran != null:
			iran.government = GameConstants.Government.AUTHORITARIAN
			iran.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			_leave_alliances(iran)
			iran.set_tag("对华贸易", false)


## 战争 34 号结算：GameState.cs:1801-1826。
static func _apply_war34_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var malaya := w.get_country_by_legacy_index(49)
	var c111 := w.get_country_by_legacy_index(111)
	if war.infl1 >= 850:
		d.global_influence += 50
		if malaya != null:
			malaya.government = GameConstants.Government.SOCIALIST
			malaya.sub_government = GameConstants.SubGovernment.MAOIST
			malaya.set_tag("对华贸易", true)
			malaya.set_tag("亲美", false)
			malaya.set_tag("asean", false)
			malaya.set_tag("seato", false)
			malaya.set_tag("亲中", true)
			if malaya.parts.size() <= 0:
				malaya.parts.resize(1)
			malaya.parts[0] = true
			_join_all_our_alliances(w, malaya)
			malaya.social_stability = 1000
			malaya.prc_power = 1000
		if c111 != null:
			_leave_alliances(c111)
			# 文莱（legacy 111）“和平接管”：并入马来西亚（49），地图地块（835）归马来西亚（820）。
			c111.puppet_of = 49
			c111.government = malaya.government if malaya != null else c111.government
			c111.sub_government = malaya.sub_government if malaya != null else c111.sub_government
		# 新加坡（地图 gwcode 830）与文莱（835）地块并入马来西亚（820）：
		# 对应原版结算文案“推翻李光耀反动政权 / 文莱‘和平’接管 / 成立马来亚-北加里曼丹人民联邦共和国”。
		if GameManager != null:
			GameManager.set_map_region_owner([587, 1221, 1222, 1223, 2908, 2909, 2910, 2911, 2912], 820)
		elif MapService.instance != null:
			MapService.instance.set_region_owner([587, 1221, 1222, 1223, 2908, 2909, 2910, 2911, 2912], 820)
	else:
		if malaya != null:
			malaya.government = GameConstants.Government.AUTHORITARIAN
			malaya.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			malaya.set_tag("对华贸易", false)


## 战争 35 号结算：GameState.cs:1828-1875。
static func _apply_war35_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var indo := w.get_country_by_legacy_index(50)
	# 东帝汶在地图上是独立 gwcode 860（原版 allcountries[128]，但本项目 128 是纳米比亚）。
	# 印尼革命结算时创建/补建东帝汶国家实体，并把东帝汶地块从印尼(850)划走。
	const EAST_TIMOR_REGIONS: Array[int] = [583, 584, 585, 2958, 2959, 2960, 2961, 2962, 2963, 2964, 2965, 3318, 3319]
	if war.infl1 >= 850:
		add_empire_power(EmpireData.USA, -50)
		d.global_influence += 40
		d.diplomatic_reputation += 20
		if indo != null:
			indo.set_tag("亲美", false)
			indo.set_tag("asean", false)
			_leave_alliances(indo)
			indo.government = GameConstants.Government.SOCIALIST
			indo.sub_government = GameConstants.SubGovernment.MAOIST
			indo.set_tag("对华贸易", true)
			indo.set_tag("亲中", true)
			_join_all_our_alliances(w, indo)
			if indo.parts.size() <= 0:
				indo.parts.resize(1)
			indo.parts[0] = true
			indo.social_stability = 1000
			indo.prc_power = 1000
		var et := _ensure_east_timor(w)
		if et != null:
			et.set_tag("对华贸易", true)
			et.set_tag("亲中", true)
			et.government = GameConstants.Government.SOCIALIST
			et.sub_government = GameConstants.SubGovernment.MAOIST
			et.social_stability = 1000
			_join_all_our_alliances(w, et)
		_transfer_east_timor_regions(EAST_TIMOR_REGIONS)
	else:
		if indo != null:
			indo.government = GameConstants.Government.AUTHORITARIAN
			indo.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			indo.set_tag("对华贸易", false)
			if indo.parts.size() <= 0:
				indo.parts.resize(1)
			indo.parts[0] = true
		var et2 := _ensure_east_timor(w)
		if et2 != null:
			et2.government = GameConstants.Government.SOCIALIST
			et2.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
			et2.social_stability = 1000
		_transfer_east_timor_regions(EAST_TIMOR_REGIONS)


static func _ensure_east_timor(w: WorldState) -> CountryData:
	var et := w.get_country_by_gwcode(860)
	if et != null:
		return et
	et = CountryData.new()
	et.gwcode = 860
	et.原版序号 = 169
	et.slot = w.countries.size()
	et.chinese_name = "东帝汶"
	et.name = "East Timor"
	et.government = GameConstants.Government.SOCIALIST
	et.sub_government = GameConstants.SubGovernment.MAOIST
	w.countries.append(et)
	w.rebuild_gwcode_index()
	return et


static func _transfer_east_timor_regions(region_ids: Array[int]) -> void:
	if GameManager != null:
		GameManager.set_map_region_owner(region_ids, 860)
	elif MapService.instance != null:
		MapService.instance.set_region_owner(region_ids, 860)


## 战争 37 号结算：GameState.cs:1877-1934。
static func _apply_war37_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c24 := w.get_country_by_legacy_index(24)
	var c101 := w.get_country_by_legacy_index(101)
	if war.infl2 >= 900:
		add_empire_power(EmpireData.USA, -50)
		d.global_influence += 40
		d.diplomatic_reputation += 20
		if c24 != null and c24.parts.size() > 0 and c24.parts[0] and c24.has_tag("亲中"):
			if c101 != null:
				c101.government = GameConstants.Government.SOCIALIST
				c101.sub_government = GameConstants.SubGovernment.MAOIST
				_leave_alliances(c101)
				_join_all_our_alliances(w, c101)
				c101.set_tag("oil", false)
				c101.set_tag("oar", true)
				c101.set_tag("对华贸易", true)
				c101.set_tag("亲中", true)
				c101.name = "阿拉伯半岛人民民主共和国"
				c101.chinese_name = "阿拉伯半岛人民民主共和国"
		elif c24 != null and c24.parts.size() > 0 and c24.parts[0] and c24.has_tag("亲苏"):
			if c101 != null:
				c101.government = GameConstants.Government.SOCIALIST
				c101.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				c101.set_tag("对华贸易", true)
				c101.set_tag("亲苏", true)
				c101.name = "阿拉伯半岛民主共和国"
				c101.chinese_name = "阿拉伯半岛民主共和国"
		else:
			if c101 != null:
				c101.government = GameConstants.Government.REFORMIST
				c101.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
				_leave_alliances(c101)
				c101.set_tag("oil", false)
				_join_all_our_alliances(w, c101)
				c101.set_tag("oar", true)
				c101.set_tag("对华贸易", true)
				c101.set_tag("亲中", true)
				c101.name = "阿拉伯半岛共和国"
				c101.chinese_name = "阿拉伯半岛共和国"
	else:
		d.global_influence -= 40
		if c101 != null:
			_leave_alliances(c101)


## 战争 38 号结算：GameState.cs:1936-1967。
static func _apply_war38_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var kuwait := w.get_country_by_legacy_index(36)
	var iraq := w.get_country_by_legacy_index(14)
	if war.infl1 >= 950:
		add_empire_power(EmpireData.USA, -50)
		d.global_influence += 40
		d.diplomatic_reputation += 20
		if kuwait != null:
			kuwait.government = GameConstants.Government.SOCIALIST
			kuwait.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			_leave_alliances(kuwait)
			kuwait.set_tag("oil", false)
			_join_all_our_alliances(w, kuwait)
			kuwait.set_tag("oar", true)
			kuwait.name = "科威特社会主义共和国"
			kuwait.chinese_name = "科威特社会主义共和国"
			kuwait.set_tag("对华贸易", true)
			kuwait.set_tag("亲中", true)
		if iraq != null:
			if iraq.parts.size() <= 5:
				iraq.parts.resize(6)
			iraq.parts[5] = true
	else:
		d.global_influence -= 20
		if kuwait != null:
			_leave_alliances(kuwait)


## 战争 39 号结算：GameState.cs:1969-2007。
static func _apply_war39_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var morocco := w.get_country_by_legacy_index(54)
	var polisario := w.get_country_by_legacy_index(18)
	if war.infl2 >= 900:
		add_empire_power(EmpireData.USA, -50)
		if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
			w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations - 150, 0, 1000)
		if morocco != null and morocco.parts.size() > 0:
			morocco.parts[0] = false
		if polisario != null:
			polisario.special = 0
			polisario.set_tag("对华贸易", true)
			if not polisario.内战中:
				polisario.government = GameConstants.Government.REFORMIST
				polisario.sub_government = GameConstants.SubGovernment.PRAGMATIST
				d.global_influence += 5
				if war.ussr_side == GameConstants.WarSide.SIDE2:
					polisario.set_tag("亲苏", true)
					add_empire_power(EmpireData.USSR, 15)
			else:
				polisario.government = GameConstants.Government.SOCIALIST
				polisario.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				polisario.set_tag("亲中", true)
				d.global_influence += 20
		# 西撒哈拉独立：把整个西撒地块划给波利萨里奥
		if polisario != null:
			if GameManager != null:
				GameManager.set_map_region_owner([54, 55, 56, 57], polisario.gwcode)
			elif MapService.instance != null:
				MapService.instance.set_region_owner([54, 55, 56, 57], polisario.gwcode)
	else:
		add_empire_power(EmpireData.USA, 50)
		d.global_influence -= 20
		# 摩洛哥获胜：西撒全部归摩洛哥
		if morocco != null:
			if GameManager != null:
				GameManager.set_map_region_owner([54, 55, 56, 57], morocco.gwcode)
			elif MapService.instance != null:
				MapService.instance.set_region_owner([54, 55, 56, 57], morocco.gwcode)


## 战争 40 号结算：GameState.cs:2009-2059。
static func _apply_war40_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var algeria := w.get_country_by_legacy_index(40)
	if war.infl2 >= 900:
		var res563 := w.result_of_event_num(563)
		if res563 == 0:
			if algeria != null:
				algeria.government = GameConstants.Government.AUTHORITARIAN
				algeria.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				algeria.set_tag("对华贸易", true)
				algeria.set_tag("亲苏", false)
			d.global_influence += 5
			add_empire_power(EmpireData.USA, -20)
			if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
				w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations - 150, 0, 1000)
			add_empire_power(EmpireData.USSR, -20)
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].relations = clampi(w.empires[EmpireData.USSR].relations - 150, 0, 1000)
		elif res563 == 1:
			if algeria != null:
				algeria.government = GameConstants.Government.LIBERAL
				algeria.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				algeria.set_tag("对华贸易", true)
				algeria.set_tag("亲苏", false)
			d.global_influence += 20
			add_empire_power(EmpireData.USSR, -50)
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].relations = clampi(w.empires[EmpireData.USSR].relations - 150, 0, 1000)
			add_empire_power(EmpireData.USA, 30)
			if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
				w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations + 150, 0, 1000)
		else:
			if algeria != null:
				algeria.government = GameConstants.Government.SOCIALIST
				algeria.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				algeria.set_tag("对华贸易", true)
				algeria.set_tag("亲苏", false)
				algeria.set_tag("亲中", true)
			d.global_influence += 20
			add_empire_power(EmpireData.USA, -50)
			if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
				w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations - 150, 0, 1000)
			add_empire_power(EmpireData.USSR, 20)
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].relations = clampi(w.empires[EmpireData.USSR].relations + 100, 0, 1000)
	else:
		add_empire_power(EmpireData.USA, 50)
		d.global_influence -= 20


## 战争 36 号结算：GameState.cs:699-730。
static func _apply_war36_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var japan := w.get_country_by_legacy_index(44)
	if war.infl2 >= 1000:
		if japan != null:
			japan.government = GameConstants.Government.SOCIALIST
			japan.sub_government = GameConstants.SubGovernment.MAOIST
			_leave_alliances(japan)
			_join_all_our_alliances(w, japan)
			japan.set_tag("亲中", true)
			japan.name = "日本社会主义人民共和国"
			japan.chinese_name = "日本社会主义人民共和国"
			japan.set_tag("对华贸易", true)
		d.global_influence += 100
		if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
			w.empires[EmpireData.USA].relations = 0
		add_empire_power(EmpireData.USA, -100)
	else:
		if japan != null:
			japan.government = GameConstants.Government.AUTHORITARIAN
			japan.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			_leave_alliances(japan)
			japan.set_tag("对华贸易", false)
			japan.set_tag("nato", true)
			japan.set_tag("亲美", true)
		d.global_influence -= 100
		if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
			w.empires[EmpireData.USA].relations = 0
		add_empire_power(EmpireData.USA, 100)


## 战争 41 号结算：GameState.cs:2061-2180。
static func _apply_war41_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var syria := w.get_country_by_legacy_index(35)
	var iraq := w.get_country_by_legacy_index(14)
	var usa := w.get_country_by_legacy_index(51)
	var china := w.get_country_by_legacy_index(1)
	var c31 := w.get_country_by_legacy_index(31)
	var res565 := w.result_of_event_num(565)
	if war.infl2 >= 900:
		if res565 == 0:
			if syria != null:
				_leave_alliances(syria)
				syria.government = GameConstants.Government.AUTHORITARIAN
				syria.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				syria.set_tag("对华贸易", true)
			d.global_influence += 40
			add_empire_power(EmpireData.USA, -20)
			if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
				w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations - 150, 0, 1000)
			add_empire_power(EmpireData.USSR, -50)
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].relations = clampi(w.empires[EmpireData.USSR].relations - 200, 0, 1000)
		elif res565 == 1:
			if syria != null:
				_leave_alliances(syria)
				syria.government = GameConstants.Government.SOCIALIST
				syria.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				syria.set_tag("对华贸易", true)
				syria.set_tag("亲中", true)
			if w.event_done_num(36) and w.result_of_event_num(36) == 2 and iraq != null:
				iraq.prc_power += 10
			d.global_influence += 40
			add_empire_power(EmpireData.USA, -20)
			if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
				w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations - 150, 0, 1000)
			add_empire_power(EmpireData.USSR, -50)
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].relations = clampi(w.empires[EmpireData.USSR].relations - 200, 0, 1000)
		else:
			if syria != null:
				_leave_alliances(syria)
				if usa != null and not usa.内战中 and c31 != null and c31.has_tag("sento"):
					syria.set_tag("sento", true)
				if usa != null and usa.内战中 and china != null and china.has_tag("seato"):
					syria.set_tag("asean", true)
					syria.set_tag("seato", true)
				syria.government = GameConstants.Government.LIBERAL
				syria.sub_government = GameConstants.SubGovernment.LIBERAL
				syria.set_tag("对华贸易", true)
				syria.set_tag("亲美", true)
			d.global_influence += 40
			add_empire_power(EmpireData.USA, 50)
			if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
				w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations + 150, 0, 1000)
			add_empire_power(EmpireData.USSR, -50)
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].relations = clampi(w.empires[EmpireData.USSR].relations - 200, 0, 1000)
	else:
		if syria != null:
			syria.government = GameConstants.Government.AUTHORITARIAN
			syria.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			syria.set_tag("亲苏", true)
		if res565 == 0:
			d.global_influence -= 20
			add_empire_power(EmpireData.USSR, 20)
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].relations = clampi(w.empires[EmpireData.USSR].relations + 100, 0, 1000)
		elif res565 == 1:
			d.global_influence -= 20
			add_empire_power(EmpireData.USSR, 20)
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].relations = clampi(w.empires[EmpireData.USSR].relations + 100, 0, 1000)
		else:
			d.global_influence -= 20
			add_empire_power(EmpireData.USSR, 20)
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].relations = clampi(w.empires[EmpireData.USSR].relations + 100, 0, 1000)


## 战争 44 号结算：GameState.cs:2397-2421。
static func _apply_war44_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c127 := w.get_country_by_legacy_index(127)
	if c127 != null and c127.parts.size() > 0:
		c127.parts[0] = false
	if war.infl2 >= 400:
		add_empire_power(EmpireData.USA, -20)
		d.global_influence += 20
	else:
		d.global_influence -= 40
		if c127 != null:
			_leave_alliances(c127)
			c127.government = GameConstants.Government.AUTHORITARIAN
			c127.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			c127.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA


## 战争 45 号结算：GameState.cs:2456-2515。
static func _apply_war45_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c140 := w.get_country_by_legacy_index(140)
	var c145 := w.get_country_by_legacy_index(145)
	var usa := w.get_country_by_legacy_index(51)
	var c137 := w.get_country_by_legacy_index(137)
	if c140 != null and c140.parts.size() > 1:
		c140.parts[1] = false
	if war.infl2 >= 900:
		add_empire_power(EmpireData.USA, -20)
		if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
			w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations - 150, 0, 1000)
		d.global_influence += 20
		if c145 != null:
			c145.set_tag("对华贸易", true)
			c145.set_tag("亲中", true)
		if c140 != null:
			if c140.parts.size() <= 0:
				c140.parts.resize(1)
			c140.parts[0] = true
		if usa != null:
			usa.set_tag("对华贸易", false)
		if c137 != null:
			c137.set_tag("对华贸易", false)
	else:
		d.global_influence -= 40
		add_empire_power(EmpireData.USA, 20)
		if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
			w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations - 100, 0, 1000)
		if c140 != null:
			c140.set_tag("对华贸易", false)
			c140.government = GameConstants.Government.AUTHORITARIAN
			c140.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN


## 战争 47 号结算：GameState.cs:2517-2543。
static func _apply_war47_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c140 := w.get_country_by_legacy_index(140)
	if c140 != null and c140.parts.size() > 1:
		c140.parts[1] = false
	if war.infl2 >= 900:
		add_empire_power(EmpireData.USA, -100)
		if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
			w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations - 500, 0, 1000)
		d.global_influence += 100
		if c140 != null:
			c140.government = GameConstants.Government.AUTHORITARIAN
			c140.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			_leave_alliances(c140)
			c140.set_tag("亲中", true)
			c140.set_tag("对华贸易", true)
			_join_all_our_alliances(w, c140)
	else:
		d.global_influence -= 40
		add_empire_power(EmpireData.USA, 20)
		if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
			w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations - 100, 0, 1000)
		if c140 != null:
			c140.set_tag("对华贸易", false)
			if c140.parts.size() > 0:
				c140.parts[0] = false


## 战争 53 号结算：GameState.cs:2791-2812。
static func _apply_war53_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c122 := w.get_country_by_legacy_index(122)
	var c118 := w.get_country_by_legacy_index(118)
	if c122 != null and c122.parts.size() > 0:
		c122.parts[0] = false
	if war.infl1 >= 900:
		d.global_influence -= 10
		add_empire_power(EmpireData.USA, 10)
		w.event_done_overrides[659] = 1
		w.event_done_overrides[660] = 1
		if c118 != null:
			c118.set_tag("对华贸易", true)
			c118.usa_influence = 100
	else:
		d.global_influence += 10
		add_empire_power(EmpireData.USA, -10)
		if c118 != null:
			c118.government = GameConstants.Government.REFORMIST
			c118.sub_government = GameConstants.SubGovernment.PRAGMATIST
			c118.set_tag("亲苏", false)


## 战争 54 号结算：GameState.cs:2814-2910。
static func _apply_war54_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var azania := w.get_country_by_legacy_index(131)
	var lesotho := w.get_country_by_legacy_index(132)
	var c126 := w.get_country_by_legacy_index(126)
	var c153 := w.get_country_by_legacy_index(153)
	if azania != null and azania.parts.size() > 0:
		azania.parts[0] = false
	if war.infl1 >= 900:
		d.global_influence += 15
		add_empire_power(EmpireData.USA, -15)
		if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
			w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations - 100, 0, 1000)
		if c153 != null and c153.government == GameConstants.Government.SOCIALIST:
			if azania != null:
				azania.government = GameConstants.Government.AUTHORITARIAN
				azania.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				azania.name = "阿扎尼亚人民共和国"
				azania.chinese_name = "阿扎尼亚人民共和国"
				_leave_alliances(azania)
				azania.set_tag("对华贸易", true)
				_set_pro_china(azania)
			if lesotho != null:
				lesotho.government = GameConstants.Government.AUTHORITARIAN
				lesotho.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				lesotho.name = "莱索托人民共和国"
				lesotho.chinese_name = "莱索托人民共和国"
				_leave_alliances(lesotho)
				lesotho.set_tag("对华贸易", true)
				_set_pro_china(lesotho)
			if c126 != null:
				c126.level_of_instability += 100
			if c153 != null:
				if c153.parts.size() <= 0:
					c153.parts.resize(1)
				c153.parts[0] = true
				c153.government = GameConstants.Government.REFORMIST
				c153.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST if c153.内战中 else 15
				c153.set_tag("对华贸易", true)
				if c153.内战中:
					_set_pro_china(c153)
				else:
					_set_pro_american(c153)
		else:
			if azania != null:
				azania.government = GameConstants.Government.AUTHORITARIAN
				azania.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				azania.name = "阿扎尼亚"
				azania.chinese_name = "阿扎尼亚"
				_leave_alliances(azania)
				azania.set_tag("对华贸易", true)
			if lesotho != null:
				lesotho.government = GameConstants.Government.REFORMIST
				lesotho.sub_government = GameConstants.SubGovernment.PRAGMATIST
				lesotho.name = "莱索托"
				lesotho.chinese_name = "莱索托"
				_leave_alliances(lesotho)
				lesotho.set_tag("对华贸易", true)
				_set_pro_china(lesotho)
			if c126 != null:
				c126.level_of_instability += 50
			if c153 != null:
				if c153.parts.size() <= 0:
					c153.parts.resize(1)
				c153.parts[0] = true
				c153.government = GameConstants.Government.REFORMIST
				c153.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST if c153.内战中 else 15
				c153.set_tag("对华贸易", true)
				if c153.内战中:
					_set_pro_china(c153)
				else:
					_set_pro_american(c153)
	else:
		d.global_influence -= 10
		add_empire_power(EmpireData.USA, 10)
		if azania != null:
			azania.government = GameConstants.Government.AUTHORITARIAN
			azania.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			azania.name = "南非人民邦"
			azania.chinese_name = "南非人民邦"


## 战争 55 号结算：GameState.cs:2912-2942。
static func _apply_war55_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var azania := w.get_country_by_legacy_index(131)
	var lesotho := w.get_country_by_legacy_index(132)
	var c126 := w.get_country_by_legacy_index(126)
	var c153 := w.get_country_by_legacy_index(153)
	if azania != null and azania.parts.size() > 1:
		azania.parts[1] = false
	if war.infl1 >= 900:
		if azania != null:
			azania.government = GameConstants.Government.SOCIALIST
			azania.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			azania.name = "南非"
			azania.chinese_name = "南非"
			_leave_alliances(azania)
			azania.set_tag("对华贸易", true)
			_set_pro_soviet(azania)
		if lesotho != null:
			_leave_alliances(lesotho)
			lesotho.government = GameConstants.Government.REFORMIST
			lesotho.sub_government = GameConstants.SubGovernment.PRAGMATIST
			lesotho.set_tag("对华贸易", true)
			_set_pro_china(lesotho)
		if c126 != null:
			c126.level_of_instability += 50
		if c153 != null:
			if c153.parts.size() <= 0:
				c153.parts.resize(1)
			c153.parts[0] = true
			c153.government = GameConstants.Government.REFORMIST
			c153.sub_government = GameConstants.SubGovernment.PRAGMATIST
	else:
		d.global_influence -= 10
		add_empire_power(EmpireData.USA, 10)
		if azania != null:
			azania.government = GameConstants.Government.AUTHORITARIAN
			azania.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			azania.name = "南非人民邦"
			azania.chinese_name = "南非人民邦"


## 战争 56 号结算：GameState.cs:2944-2961。
static func _apply_war56_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var azania := w.get_country_by_legacy_index(131)
	var angola := w.get_country_by_legacy_index(123)
	if azania != null and azania.parts.size() > 2:
		azania.parts[2] = false
	if war.infl1 >= 900:
		d.global_influence -= 10
		add_empire_power(EmpireData.USA, -10)
		add_empire_power(EmpireData.USSR, -10)
		if angola != null:
			angola.government = GameConstants.Government.AUTHORITARIAN
			angola.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			_leave_alliances(angola)
			angola.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA


## 战争 57 号结算：GameState.cs:2963-2981。
static func _apply_war57_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var azania := w.get_country_by_legacy_index(131)
	var c129 := w.get_country_by_legacy_index(129)
	if azania != null and azania.parts.size() > 3:
		azania.parts[3] = false
	if war.infl1 >= 900:
		d.global_influence -= 10
		add_empire_power(EmpireData.USA, -10)
		add_empire_power(EmpireData.USSR, -10)
		if c129 != null:
			c129.government = GameConstants.Government.AUTHORITARIAN
			c129.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			_leave_alliances(c129)
			c129.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
			c129.name = "斯提拉兰"
			c129.chinese_name = "斯提拉兰"


## 战争 58 号结算：GameState.cs:2983-3006。
static func _apply_war58_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var azania := w.get_country_by_legacy_index(131)
	var c125 := w.get_country_by_legacy_index(125)
	var c126 := w.get_country_by_legacy_index(126)
	if azania != null and azania.parts.size() > 4:
		azania.parts[4] = false
	if war.infl1 >= 900:
		d.global_influence -= 10
		add_empire_power(EmpireData.USA, -10)
		add_empire_power(EmpireData.USSR, -10)
		if c126 != null and c126.parts.size() > 0:
			c126.parts[0] = false
		if c125 != null:
			c125.government = GameConstants.Government.AUTHORITARIAN
			c125.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			_leave_alliances(c125)
			c125.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
		if c126 != null:
			c126.government = GameConstants.Government.AUTHORITARIAN
			c126.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			_leave_alliances(c126)
			c126.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
			c126.name = "莫桑比克国"
			c126.chinese_name = "莫桑比克国"


## 战争 59 号结算：GameState.cs:3008-3026。
static func _apply_war59_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var azania := w.get_country_by_legacy_index(131)
	var c127 := w.get_country_by_legacy_index(127)
	if azania != null and azania.parts.size() > 0:
		azania.parts[0] = false
	if war.infl1 >= 900:
		d.global_influence -= 10
		add_empire_power(EmpireData.USA, -10)
		add_empire_power(EmpireData.USSR, -10)
		if c127 != null:
			c127.government = GameConstants.Government.AUTHORITARIAN
			c127.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			_leave_alliances(c127)
			c127.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
			c127.name = "罗得西亚共和国"
			c127.chinese_name = "罗得西亚共和国"


## 战争 60 号结算：GameState.cs:3028-3055。
static func _apply_war60_result(war: WarData, _d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c117 := w.get_country_by_legacy_index(117)
	var c163 := w.get_country_by_legacy_index(163)
	if c117 != null and c117.parts.size() > 0:
		c117.parts[0] = false
	if war.infl1 >= 900:
		if c117 != null:
			c117.level_of_development = 1
		add_empire_power(EmpireData.USA, 15)
		add_empire_power(EmpireData.USSR, -15)
	elif war.infl2 >= 900:
		add_empire_power(EmpireData.USA, -15)
		add_empire_power(EmpireData.USSR, 15)
		if c163 != null:
			if c163.parts.size() <= 0:
				c163.parts.resize(1)
			c163.parts[0] = true
			c163.government = GameConstants.Government.AUTHORITARIAN
			c163.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			_leave_alliances(c163)
			c163.set_tag("亲苏", true)
			c163.set_tag("对华贸易", true)
	else:
		add_empire_power(EmpireData.USA, -15)
		add_empire_power(EmpireData.USSR, -15)


## 战争 61 号结算：GameState.cs:3057-3114。
static func _apply_war61_result(war: WarData, _d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c117 := w.get_country_by_legacy_index(117)
	var c163 := w.get_country_by_legacy_index(163)
	if c117 != null and c117.parts.size() > 0:
		c117.parts[0] = false
	if c163 == null or not (c163.parts.size() > 0 and c163.parts[0]):
		if war.infl2 >= 850:
			add_empire_power(EmpireData.USA, -15)
			add_empire_power(EmpireData.USSR, 15)
			if c163 != null:
				if c163.parts.size() <= 0:
					c163.parts.resize(1)
				c163.parts[0] = true
				c163.government = GameConstants.Government.AUTHORITARIAN
				c163.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				_leave_alliances(c163)
				c163.set_tag("亲苏", true)
				c163.set_tag("对华贸易", true)
		else:
			add_empire_power(EmpireData.USA, 15)
			add_empire_power(EmpireData.USSR, -15)
	elif war.infl2 >= 800:
		if c163 != null:
			if c163.parts.size() > 0:
				c163.parts[0] = false
		if c117 != null:
			c117.government = GameConstants.Government.AUTHORITARIAN
			c117.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			_leave_alliances(c117)
			c117.set_tag("亲苏", true)
			c117.name = "刚果人民民主共和国"
			c117.chinese_name = "刚果人民民主共和国"
	elif war.infl1 >= 800:
		add_empire_power(EmpireData.USA, -15)
		add_empire_power(EmpireData.USSR, -15)
	else:
		add_empire_power(EmpireData.USA, -15)
		add_empire_power(EmpireData.USSR, -15)


## 战争 0 号结算：GameState.cs:77-120（朝鲜战争）。
static func _apply_war0_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var north := WarQueries.wc(w, 10)
	var south := WarQueries.wc(w, 46)
	var china := WarQueries.wc(w, 1)
	if war.infl1 >= 900:
		if north != null and south != null and north.government == GameConstants.Government.LIBERAL and south.government == GameConstants.Government.AUTHORITARIAN:
			_set_d(d, 157, 1)
		if north != null:
			north.name = "朝鲜民主主义人民共和国"
			north.chinese_name = "朝鲜民主主义人民共和国"
			if north.parts.size() <= 0:
				north.parts.resize(1)
			north.parts[0] = true
			if china != null and china.has_tag("seato"):
				_add_d(d, W.I_INFLUENCE, -10)
				add_empire_power(EmpireData.USA, -10)
				add_empire_power(EmpireData.USSR, 60)
			else:
				_add_d(d, W.I_INFLUENCE, 50)
				add_empire_power(EmpireData.USA, -40)
			_set_d(d, W.I_KOREA_RESULT, 1)
	elif war.infl2 >= 900:
		if south != null:
			south.name = "大韩民国"
			south.chinese_name = "大韩民国"
			if south.parts.size() <= 0:
				south.parts.resize(1)
			south.parts[0] = true
			if china != null and china.has_tag("seato"):
				_add_d(d, W.I_INFLUENCE, 20)
				add_empire_power(EmpireData.USSR, -40)
			else:
				_add_d(d, W.I_INFLUENCE, -20)
				add_empire_power(EmpireData.USSR, -20)
			add_empire_power(EmpireData.USA, 50)
			_set_d(d, W.I_KOREA_RESULT, 2)


## 战争 1 号结算：GameState.cs:120-352（中柬越战争）。
static func _apply_war1_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c11 := WarQueries.wc(w, 11)
	var c22 := WarQueries.wc(w, 22)
	var c23 := WarQueries.wc(w, 23)
	var china := WarQueries.wc(w, 1)
	if war.infl1 >= 900:
		_add_d(d, W.I_INFLUENCE, 20)
		_add_d(d, W.I_PARTY_SUPPORT, 100)
		add_empire_power(EmpireData.USSR, -20)
		if w.result_of_event_num(451) == 1 and c23 != null and c23.parts.size() > 0:
			c23.parts[0] = true
		if w.war_state == GameConstants.WarState.SINO_SOVIET:
			if c11 != null and china != null:
				c11.government = china.government
				c11.sub_government = china.sub_government
				c11.leave_alliances()
				c11.puppet_of = GameConstants.LegacySlot.CHINA
				c11.set_tag("对华贸易", true)
				c11.set_tag("亲苏", false)
				c11.set_tag("亲中", true)
				c11.social_stability = 1000
				match china.sub_government:
					0, 17, 1, 2:
						c11.name = "越南人民共和国"
						c11.chinese_name = "越南人民共和国"
					16:
						c11.name = "越南社会主义共和国"
						c11.chinese_name = "越南社会主义共和国"
					18:
						c11.name = "不可思议的托派越南"
						c11.chinese_name = "不可思议的托派越南"
					13, 9:
						c11.name = "越南民主人民共和国"
					10, 15, 7, 19, 20, 22, 21:
						c11.name = "越南民主主义者人民共和国"
					14, 11, 3, 8:
						c11.name = "越南民主共和国"
					_:
						c11.name = "越南人民共和国"
				c11.chinese_name = c11.name
			if c22 != null and china != null:
				c22.puppet_of = GameConstants.LegacySlot.CHINA
				c22.government = china.government
				c22.sub_government = china.sub_government
				c22.set_tag("亲苏", false)
				c22.set_tag("亲中", true)
				c22.set_tag("sev", false)
			w.war_state = GameConstants.WarState.PEACE
	elif war.infl2 >= 900:
		if c23 != null and c11 != null:
			c23.government = c11.government
			c23.sub_government = c11.sub_government
			c23.puppet_of = 11
			c23.set_tag("亲苏", true)
			c23.set_tag("亲中", false)
			c23.set_tag("对华贸易", false)
			c23.set_tag("econ", false)
			c23.set_tag("okb", false)
		_add_d(d, W.I_INFLUENCE, -30)
		add_empire_power(EmpireData.USSR, 10)
		if w.war_state == GameConstants.WarState.SINO_SOVIET:
			_add_d(d, W.I_INFLUENCE, -20)
			w.war_state = GameConstants.WarState.PEACE


## 战争 2 号结算：GameState.cs:352-388（泰国革命）。
static func _apply_war2_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c34 := WarQueries.wc(w, 34)
	if war.infl1 >= 750:
		if c34 != null:
			c34.set_tag("对华贸易", true)
			c34.government = GameConstants.Government.SOCIALIST
			c34.sub_government = GameConstants.SubGovernment.MAOIST
			c34.leave_asean()
			c34.set_tag("亲中", true)
			c34.set_tag("亲美", false)
			c34.prc_power = 1000
			c34.内战中 = true
		_add_d(d, W.I_INFLUENCE, 20)
		add_empire_power(EmpireData.USA, -20)
	else:
		_add_d(d, W.I_INFLUENCE, -10)


## 战争 4 号结算：GameState.cs:352-489（第五次中东战争）。
static func _apply_war4_result(war: WarData, _d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c14 := WarQueries.wc(w, 14)
	var c37 := WarQueries.wc(w, 37)
	var c93 := WarQueries.wc(w, 93)
	if w.event_done_num(711):
		if war.infl1 >= 900:
			w.set_flag("israellost", true)
			if c14 != null:
				if c14.parts.size() > 8:
					c14.parts[7] = false
					c14.parts[8] = true
				c14.name = "大伊拉克共和国"
				c14.chinese_name = "大伊拉克共和国"
			if c37 != null:
				c37.leave_alliances()
				c37.government = GameConstants.Government.AUTHORITARIAN
				c37.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
				c37.puppet_of = GameConstants.LegacySlot.IRAQ
				c37.set_tag("亲中", true)
				c37.set_tag("对华贸易", true)
				_join_all_our_alliances(w, c37)
	elif not w.event_done_num(371):
		if war.infl1 >= 900:
			add_empire_power(EmpireData.USSR, -10)
			add_empire_power(EmpireData.USA, 20)
			if c93 != null:
				c93.puppet_of = 37
		else:
			add_empire_power(EmpireData.USSR, 10)
			add_empire_power(EmpireData.USA, -20)
			w.set_flag("israellost", true)
	elif war.infl1 >= 700:
		if c93 != null:
			c93.government = GameConstants.Government.AUTHORITARIAN
			c93.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			c93.puppet_of = 37
	elif war.infl2 >= 500:
		add_empire_power(EmpireData.USA, -50)
		w.set_flag("israellost", true)
		if c37 != null:
			c37.government = GameConstants.Government.AUTHORITARIAN
			c37.sub_government = GameConstants.SubGovernment.NEO_FASCIST
	else:
		w.set_flag("israellost", true)
		if c93 != null:
			c93.government = GameConstants.Government.REFORMIST
			c93.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST


## 战争 6 号结算：GameState.cs:490-500（马岛战争）。
static func _apply_war6_result(war: WarData, _d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c71 := WarQueries.wc(w, 71)
	if c71 != null and c71.parts.size() > 0:
		c71.parts[0] = false
	if war.infl1 >= 400:
		w.set_flag("BritLost", true)
		add_empire_power(EmpireData.USA, -20)
		# 阿根廷胜利：福克兰群岛（region 3030）保持归阿根廷（160），
		# 对应原版 parts[0] 的“马岛随阿根廷”语义（原版结算无条件置 false 属笔误）。
		_transfer_falklands(160)
	else:
		add_empire_power(EmpireData.USA, 20)
		# 英国胜利：马岛归还英国（200）。
		_transfer_falklands(200)


## 福克兰群岛（map_regions.json region 3030）归属转移。
static func _transfer_falklands(to_gwcode: int) -> void:
	if GameManager != null:
		GameManager.set_map_region_owner([3030], to_gwcode)
	elif MapService.instance != null:
		MapService.instance.set_region_owner([3030], to_gwcode)


## 战争 42 号结算：GameState.cs:2185-2281。
static func _apply_war42_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c14 := WarQueries.wc(w, 14)
	var c157 := WarQueries.wc(w, 157)
	var china := WarQueries.wc(w, 1)
	if war.infl2 >= 900:
		if c14 != null:
			if c14.有驻军基地:
				c14.government = GameConstants.Government.SOCIALIST
				c14.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				c14.leave_alliances()
				c14.set_tag("对华贸易", true)
				c14.name = "伊拉克社会主义联邦"
				c14.chinese_name = "伊拉克社会主义联邦"
				c14.set_tag("亲中", true)
				c14.puppet_of = GameConstants.LegacySlot.NONE
				_add_d(d, W.I_INFLUENCE, 50)
				add_empire_power(EmpireData.USA, -20)
				_add_empire_rel(w, 0, -150)
				add_empire_power(EmpireData.USSR, -20)
				_add_empire_rel(w, 1, -50)
				w.oil_prod += 100
			else:
				c14.government = GameConstants.Government.SOCIALIST
				c14.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				c14.leave_alliances()
				c14.set_tag("对华贸易", true)
				c14.name = "伊拉克社会主义共和国"
				c14.chinese_name = "伊拉克社会主义共和国"
				if _emp_power_val(w, EmpireData.USSR) >= _dval(d, W.I_INFLUENCE) or (china != null and china.has_tag("sev")):
					c14.set_tag("亲苏", true)
					add_empire_power(EmpireData.USSR, 20)
				c14.puppet_of = GameConstants.LegacySlot.NONE
				add_empire_power(EmpireData.USA, -20)
				_add_empire_rel(w, 0, -150)
		for c in w.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.IRAQ:
				c.puppet_of = GameConstants.LegacySlot.NONE
	else:
		if c157 != null and c157.parts.size() > 0:
			c157.parts[0] = true
		if c157 != null and c157.parts.size() > 1 and c157.parts[1]:
			if c157.government == GameConstants.Government.LIBERAL:
				if c157.parts.size() > 2:
					c157.parts[0] = false
					c157.parts[1] = false
					c157.parts[2] = true
				c157.name = "北叙-北伊联邦"
				c157.chinese_name = "北叙-北伊联邦"
				c157.leave_alliances()
				c157.government = GameConstants.Government.REFORMIST
				c157.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				c157.set_tag("对华贸易", true)
			elif c157.government == GameConstants.Government.SOCIALIST:
				if c157.parts.size() > 2:
					c157.parts[0] = false
					c157.parts[1] = false
					c157.parts[2] = true
				c157.name = "北叙-北伊联邦"
				c157.chinese_name = "北叙-北伊联邦"
				c157.leave_alliances()
				c157.government = GameConstants.Government.SOCIALIST
				c157.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				c157.set_tag("亲中", true)
				c157.set_tag("对华贸易", true)
		elif c157 != null:
			c157.leave_alliances()
			c157.government = GameConstants.Government.SOCIALIST
			c157.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			c157.set_tag("对华贸易", true)
			c157.set_tag("亲中", true)
			c157.name = "伊拉克民主共和国"
			c157.chinese_name = "伊拉克民主共和国"
		if c14 != null:
			c14.government = GameConstants.Government.AUTHORITARIAN
			c14.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			c14.set_tag("对华贸易", false)
		add_empire_power(EmpireData.USA, 50)
		_add_d(d, W.I_INFLUENCE, -20)


## 战争 43 号结算：GameState.cs:2281-2395。
static func _apply_war43_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	if war.infl2 >= 900:
		add_empire_power(EmpireData.USA, -50)
		_add_d(d, W.I_INFLUENCE, 40)
		_add_d(d, W.I_DIPLO, 20)
		for p in w.politicians:
			if p != null and (p.trait_personality < GameConstants.PoliticianPersonality.MODERATE or p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE):
				p.loyalty += 100
		var c102 := WarQueries.wc(w, 102)
		var c103 := WarQueries.wc(w, 103)
		var c105 := WarQueries.wc(w, 105)
		var c24 := WarQueries.wc(w, 24)
		if c105 != null and c105.parts.size() > 0:
			c105.parts[0] = true
		if c24 != null and c24.parts.size() > 0 and c24.parts[0]:
			WarQueries.wc_name(w, 102, "阿拉伯海湾民主人民共和国")
			WarQueries.wc_name(w, 103, "阿拉伯海湾民主人民共和国")
			WarQueries.wc_name(w, 105, "阿拉伯海湾民主人民共和国")
			if c24.has_tag("亲中"):
				for c in [c102, c103, c105]:
					if c != null:
						c.government = GameConstants.Government.SOCIALIST
						c.sub_government = GameConstants.SubGovernment.MAOIST
						c.leave_alliances()
						c.set_tag("oil", false)
						_join_all_our_alliances(w, c)
						c.set_tag("oar", true)
						c.set_tag("对华贸易", true)
						c.set_tag("亲中", true)
			else:
				for c in [c102, c103, c105]:
					if c != null:
						c.government = GameConstants.Government.SOCIALIST
						c.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
						c.leave_alliances()
						c.set_tag("oil", false)
						c.set_tag("对华贸易", true)
						c.set_tag("亲苏", true)
		else:
			WarQueries.wc_name(w, 102, "阿拉伯海湾共和国")
			WarQueries.wc_name(w, 103, "阿拉伯海湾共和国")
			WarQueries.wc_name(w, 105, "阿拉伯海湾共和国")
			for c in [c102, c103, c105]:
				if c != null:
					c.government = GameConstants.Government.REFORMIST
					c.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
					c.leave_alliances()
					c.set_tag("oil", false)
					_join_all_our_alliances(w, c)
					c.set_tag("oar", true)
					c.set_tag("对华贸易", true)
					c.set_tag("亲苏", true)
	else:
		_add_d(d, W.I_INFLUENCE, -40)
		for c in [WarQueries.wc(w, 102), WarQueries.wc(w, 103), WarQueries.wc(w, 105)]:
			if c != null:
				c.leave_alliances()
				c.set_tag("亲美", true)


## 战争 46 号结算：GameState.cs:2456-2530。
static func _apply_war46_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c140 := WarQueries.wc(w, 140)
	var c145 := WarQueries.wc(w, 145)
	if c140 != null and c140.parts.size() > 1:
		c140.parts[1] = false
	if war.infl2 >= 900:
		add_empire_power(EmpireData.USA, -100)
		_add_empire_rel(w, 0, -500)
		_add_d(d, W.I_INFLUENCE, 100)
		if c145 != null:
			c145.leave_alliances()
			c145.set_tag("亲中", true)
		if c140 != null and c140.parts.size() > 0:
			c140.parts[0] = false
		for p in w.politicians:
			if p != null and (p.trait_personality < GameConstants.PoliticianPersonality.MODERATE or p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE):
				p.loyalty += 100
		if c140 != null and c145 != null:
			c140.government = c145.government
			c140.sub_government = c145.sub_government
			c140.leave_alliances()
			c140.set_tag("亲中", true)
			c140.set_tag("对华贸易", true)
			_join_all_our_alliances(w, c140)
			if c145.sub_government == GameConstants.SubGovernment.SOVIET_STYLE:
				c140.set_tag("亲中", false)
				c140.set_tag("亲苏", true)
	else:
		_add_d(d, W.I_INFLUENCE, -40)
		add_empire_power(EmpireData.USA, 20)
		_add_empire_rel(w, 0, -100)
		if c140 != null:
			c140.set_tag("对华贸易", false)
			if c140.parts.size() > 0:
				c140.parts[0] = false
			c140.government = GameConstants.Government.AUTHORITARIAN
			c140.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		if c145 != null:
			c145.leave_alliances()


## 战争 48 号结算：GameState.cs:2545-2633。
static func _apply_war48_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c53 := WarQueries.wc(w, 53)
	var c150 := WarQueries.wc(w, 150)
	var c151 := WarQueries.wc(w, 151)
	if c53 != null and c53.parts.size() > 2:
		c53.parts[2] = false
	if w.result_of_event_num(499) == 2:
		if war.infl2 >= 900:
			add_empire_power(EmpireData.USA, -100)
			_add_empire_rel(w, 0, -150)
			_add_d(d, W.I_INFLUENCE, 100)
			if c53 != null:
				c53.government = GameConstants.Government.SOCIALIST
				c53.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				c53.leave_alliances()
				c53.set_tag("亲中", true)
				c53.set_tag("对华贸易", true)
				c53.name = "苏丹社会主义联邦共和国"
				c53.chinese_name = "苏丹社会主义联邦共和国"
				if c53.parts.size() > 1:
					c53.parts[1] = false
				if c53.parts.size() > 0:
					c53.parts[0] = true
			if c150 != null:
				c150.name = "南苏丹社会主义共和国"
				c150.chinese_name = "南苏丹社会主义共和国"
				c150.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				c150.government = GameConstants.Government.AUTHORITARIAN
				c150.leave_alliances()
				c150.set_tag("亲中", true)
				c150.set_tag("对华贸易", true)
			if c151 != null:
				c151.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				c151.government = 15
		else:
			_add_d(d, W.I_INFLUENCE, -40)
			add_empire_power(EmpireData.USA, 20)
			_add_empire_rel(w, 0, -80)
			if c53 != null:
				c53.name = "苏丹"
				c53.chinese_name = "苏丹"
				c53.set_tag("对华贸易", false)
				c53.set_tag("亲中", false)
				c53.set_tag("亲美", false)
				c53.government = GameConstants.Government.AUTHORITARIAN
				c53.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				if c53.parts.size() > 0:
					c53.parts[0] = true
				if c53.parts.size() > 1:
					c53.parts[1] = true
			if c151 != null:
				c151.sub_government = GameConstants.SubGovernment.PRAGMATIST
				c151.government = GameConstants.Government.REFORMIST
				c151.set_tag("亲中", true)
				c151.set_tag("对华贸易", true)
			if c150 != null:
				c150.name = "南苏丹社会主义共和国"
				c150.chinese_name = "南苏丹社会主义共和国"
				c150.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				c150.leave_alliances()
				c150.set_tag("对华贸易", true)
				c150.set_tag("亲中", true)
	elif war.infl2 >= 900:
		add_empire_power(EmpireData.USA, -100)
		_add_empire_rel(w, 0, -150)
		_add_d(d, W.I_INFLUENCE, 100)
		if c53 != null:
			c53.government = GameConstants.Government.AUTHORITARIAN
			c53.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			c53.leave_alliances()
			c53.set_tag("亲苏", true)
			if _emp_power_val(w, EmpireData.USSR) < _dval(d, W.I_INFLUENCE):
				c53.leave_alliances()
				c53.set_tag("亲中", true)
				c53.set_tag("对华贸易", true)
			c53.name = "苏丹联邦社会主义共和国"
			c53.chinese_name = "苏丹联邦社会主义共和国"
	else:
		_add_d(d, W.I_INFLUENCE, -40)
		add_empire_power(EmpireData.USA, 20)
		_add_empire_rel(w, 0, -80)
		if c53 != null:
			c53.name = "苏丹"
			c53.chinese_name = "苏丹"
			c53.set_tag("对华贸易", false)
			c53.set_tag("亲中", false)
			c53.set_tag("亲美", true)
			c53.government = GameConstants.Government.AUTHORITARIAN
			c53.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN


## 战争 49 号结算：GameState.cs:2633-2658。
static func _apply_war49_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c138 := WarQueries.wc(w, 138)
	if c138 != null and c138.parts.size() > 0:
		c138.parts[0] = false
	if war.infl2 >= 900:
		add_empire_power(EmpireData.USA, -20)
		_add_empire_rel(w, 0, -150)
		_add_d(d, W.I_INFLUENCE, -20)
	else:
		_add_d(d, W.I_INFLUENCE, 20)
		add_empire_power(EmpireData.USA, 20)
		_add_empire_rel(w, 0, 150)
		if c138 != null:
			c138.government = GameConstants.Government.AUTHORITARIAN
			c138.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			c138.leave_alliances()
			c138.establish_government(0)
			c138.puppet_of = 51
			c138.set_tag("对华贸易", true)


## 战争 50 号结算：GameState.cs:2658-2721。
static func _apply_war50_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c119 := WarQueries.wc(w, 119)
	var c42 := WarQueries.wc(w, 42)
	if c119 != null and c119.parts.size() > 0:
		c119.parts[0] = false
	if w.result_of_event_num(594) == 1 or w.result_of_event_num(596) == 1:
		if war.infl1 >= 900:
			add_empire_power(EmpireData.USA, -20)
			_add_empire_rel(w, 0, -150)
			_add_d(d, W.I_INFLUENCE, -20)
			if c42 != null and c42.parts.size() > 1:
				c42.parts[1] = true
		else:
			add_empire_power(EmpireData.USA, 20)
			_add_empire_rel(w, 0, 150)
			add_empire_power(EmpireData.USSR, -20)
			_add_empire_rel(w, 1, -150)
			_add_d(d, W.I_INFLUENCE, 10)
	elif war.infl1 >= 900:
		add_empire_power(EmpireData.USA, -20)
		_add_empire_rel(w, 0, -150)
		add_empire_power(EmpireData.USSR, 20)
		_add_empire_rel(w, 1, 150)
		_add_d(d, W.I_INFLUENCE, 20)
		if c42 != null:
			if c42.parts.size() <= 0 or not c42.parts[0]:
				if c42.parts.size() <= 1:
					c42.parts.resize(2)
				c42.parts[1] = true
			else:
				if c42.parts.size() <= 0:
					c42.parts.resize(1)
				c42.parts[0] = false
				if c42.parts.size() <= 2:
					c42.parts.resize(3)
				c42.parts[2] = true
	else:
		add_empire_power(EmpireData.USSR, -20)
		_add_empire_rel(w, 1, -150)
		_add_d(d, W.I_INFLUENCE, -10)


## 战争 51 号结算：GameState.cs:2721-2761。
static func _apply_war51_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c119 := WarQueries.wc(w, 119)
	if c119 != null and c119.parts.size() > 1:
		c119.parts[1] = false
	if war.infl2 >= 900:
		if c119 != null:
			c119.government = GameConstants.Government.SOCIALIST
			c119.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			c119.name = "肯尼亚联邦共和国"
			c119.chinese_name = "肯尼亚联邦共和国"
			c119.leave_alliances()
			c119.set_tag("对华贸易", true)
			if _emp_power_val(w, EmpireData.USSR) < _dval(d, W.I_INFLUENCE):
				c119.establish_government(2)
			else:
				c119.establish_government(3)
				c119.set_tag("sev", true)
		add_empire_power(EmpireData.USA, -20)
		_add_empire_rel(w, 0, -150)
		_add_d(d, W.I_INFLUENCE, 20)
	else:
		_add_d(d, W.I_INFLUENCE, -20)
		add_empire_power(EmpireData.USA, 20)
		if c119 != null:
			c119.government = GameConstants.Government.AUTHORITARIAN
			c119.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			c119.leave_alliances()
			c119.establish_government(0)


## 战争 52 号结算：GameState.cs:2762-2791。
static func _apply_war52_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c112 := WarQueries.wc(w, 112)
	var c113 := WarQueries.wc(w, 113)
	if c113 != null and c113.parts.size() > 0:
		c113.parts[0] = false
	if war.infl1 >= 900:
		if c113 != null:
			c113.government = GameConstants.Government.SOCIALIST
			c113.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
			c113.name = "冈比亚人民革命共和国"
			c113.chinese_name = "冈比亚人民革命共和国"
			c113.leave_alliances()
			c113.establish_government(2)
			c113.set_tag("对华贸易", true)
		add_empire_power(EmpireData.USA, -20)
		_add_empire_rel(w, 0, -150)
		_add_d(d, W.I_INFLUENCE, 20)
	else:
		_add_d(d, W.I_INFLUENCE, -20)
		add_empire_power(EmpireData.USA, 20)
		if c112 != null:
			if c112.parts.size() <= 1:
				c112.parts.resize(2)
			c112.parts[1] = true
			c112.name = "塞内冈比亚"
			c112.chinese_name = "塞内冈比亚"
		if c113 != null:
			c113.leave_alliances()


## 战争 62 号结算：GameState.cs:3116-3165。
static func _apply_war62_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c117 := WarQueries.wc(w, 117)
	if c117 != null and c117.parts.size() > 1:
		c117.parts[1] = false
	if war.infl1 >= 100:
		if c117 != null:
			c117.government = GameConstants.Government.AUTHORITARIAN
			c117.sub_government = GameConstants.SubGovernment.NEO_FASCIST
		add_empire_power(EmpireData.USA, 30)
		_add_d(d, W.I_INFLUENCE, -30)
	elif w.result_of_event_num(610) == 2:
		if c117 != null:
			c117.government = GameConstants.Government.SOCIALIST
			c117.sub_government = GameConstants.SubGovernment.MAOIST
			c117.leave_alliances()
			c117.set_tag("对华贸易", true)
			c117.set_tag("亲中", true)
			c117.name = "刚果民主人民共和国"
			c117.chinese_name = "刚果民主人民共和国"
			c117.level_of_development = 0
		add_empire_power(EmpireData.USA, -15)
		add_empire_power(EmpireData.USSR, -15)
		_add_d(d, W.I_INFLUENCE, 30)
		for c in w.countries:
			if c != null and c.puppet_of == 117:
				c.puppet_of = GameConstants.LegacySlot.NONE
	else:
		if c117 != null:
			c117.government = GameConstants.Government.REFORMIST
			c117.sub_government = GameConstants.SubGovernment.PRAGMATIST
			c117.leave_alliances()
			c117.set_tag("对华贸易", true)
			c117.set_tag("亲中", true)
			c117.name = "刚果民主共和国"
			c117.chinese_name = "刚果民主共和国"
			c117.level_of_development = 0
		add_empire_power(EmpireData.USA, -15)
		add_empire_power(EmpireData.USSR, -15)
		_add_d(d, W.I_INFLUENCE, 30)
		for c in w.countries:
			if c != null and c.puppet_of == 117:
				c.puppet_of = GameConstants.LegacySlot.NONE


## 战争 64 号结算：GameState.cs:3199-3252。
static func _apply_war64_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c149 := WarQueries.wc(w, 149)
	if c149 != null and c149.parts.size() > 1:
		c149.parts[1] = false
	if war.infl2 >= 900:
		if c149 != null:
			c149.level_of_instability += 300
		var china := WarQueries.wc(w, 1)
		if w.result_of_event_num(633) != 1 and w.modifier_active(6) and w.modifier_active(3):
			if c149 != null:
				c149.government = GameConstants.Government.SOCIALIST
				c149.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				c149.leave_alliances()
				c149.set_tag("对华贸易", true)
				c149.set_tag("亲中", true)
			_add_d(d, W.I_INFLUENCE, 25)
			add_empire_power(EmpireData.USA, -25)
			_add_empire_rel(w, 0, -100)
		elif (w.result_of_event_num(633) == 1 and w.modifier_active(6) and w.modifier_active(3)) or (china != null and china.has_tag("sev")):
			if c149 != null:
				c149.government = GameConstants.Government.SOCIALIST
				c149.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				c149.leave_alliances()
				c149.set_tag("亲苏", true)
			add_empire_power(EmpireData.USSR, 25)
			add_empire_power(EmpireData.USA, -25)
			_add_empire_rel(w, 0, -100)
		else:
			if c149 != null:
				c149.government = GameConstants.Government.REFORMIST
				c149.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				c149.leave_alliances()
				c149.set_tag("亲中", true)
			_add_d(d, W.I_INFLUENCE, 25)
			add_empire_power(EmpireData.USA, -25)
			_add_empire_rel(w, 0, -100)
	else:
		if c149 != null:
			c149.level_of_instability -= 300
			c149.government = GameConstants.Government.AUTHORITARIAN
			c149.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			c149.leave_alliances()
			c149.set_tag("亲美", true)
		_add_d(d, W.I_INFLUENCE, -20)
		add_empire_power(EmpireData.USA, 25)


## 战争 65 号结算：GameState.cs:3252-3271。
static func _apply_war65_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c149 := WarQueries.wc(w, 149)
	if c149 != null and c149.parts.size() > 2:
		c149.parts[2] = false
	if war.infl1 >= 900:
		if c149 != null and c149.parts.size() > 0:
			c149.parts[0] = true
		_add_d(d, W.I_INFLUENCE, 20)
		add_empire_power(EmpireData.USA, -20)
		_add_empire_rel(w, 0, -50)
	else:
		if c149 != null:
			c149.level_of_instability -= 50
		_add_d(d, W.I_INFLUENCE, -20)
		add_empire_power(EmpireData.USA, 20)


## 战争 66 号结算：GameState.cs:3271-3329。
static func _apply_war66_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c149 := WarQueries.wc(w, 149)
	if c149 != null and c149.parts.size() > 2:
		c149.parts[2] = false
	if war.infl1 >= 900:
		if c149 != null and not w.is_authoritarian(c149):
			if c149.parts.size() > 0:
				c149.parts[0] = true
			_add_d(d, W.I_INFLUENCE, 20)
			add_empire_power(EmpireData.USA, -20)
			_add_empire_rel(w, 0, -50)
		elif c149 != null:
			if c149.parts.size() > 0:
				c149.parts[0] = true
			c149.level_of_instability -= 50
			add_empire_power(EmpireData.USA, 20)
	elif c149 != null and not w.is_authoritarian(c149):
		c149.level_of_instability -= 50
		_add_d(d, W.I_INFLUENCE, -20)
		add_empire_power(EmpireData.USA, 20)
	elif c149 != null:
		c149.government = GameConstants.Government.LIBERAL
		c149.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		add_empire_power(EmpireData.USA, -20)


## 战争 67 号结算：GameState.cs:3329-3344。
static func _apply_war67_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c147 := WarQueries.wc(w, 147)
	if c147 != null and c147.parts.size() > 0:
		c147.parts[0] = false
	if war.infl1 >= 700:
		if c147 != null:
			c147.government = GameConstants.Government.AUTHORITARIAN
			c147.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			c147.leave_alliances()
			c147.set_tag("亲美", true)
			c147.level_of_instability -= 300
		add_empire_power(EmpireData.USA, 20)
		_add_d(d, W.I_INFLUENCE, -50)
	else:
		add_empire_power(EmpireData.USA, -20)
		_add_d(d, W.I_INFLUENCE, 20)
		if c147 != null:
			c147.level_of_instability += 300


## 战争 68 号结算：GameState.cs:3344-3648（安哥拉内战多阵营）。
static func _apply_war68_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c123 := WarQueries.wc(w, 123)
	var c131 := WarQueries.wc(w, 131)
	var c117 := WarQueries.wc(w, 117)
	if c123 == null:
		return
	if c123.parts.size() > 0:
		c123.parts[0] = false
	c123.内战中 = true
	if c123.prc_power == 1000 and c123.usa_power == 0 and c123.sov_power == 0:
		if war.infl1 >= 850:
			c123.prc_power = 0
			c123.usa_power = 0
			c123.sov_power = 0
			if c123.has_tag("亲苏"):
				c123.government = GameConstants.Government.SOCIALIST
				c123.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				c123.leave_alliances()
				c123.set_tag("亲苏", true)
				add_empire_power(EmpireData.USSR, 20)
				_add_d(d, W.I_INFLUENCE, 10)
			elif c123.sub_government == GameConstants.SubGovernment.MAOIST:
				c123.government = GameConstants.Government.SOCIALIST
				c123.sub_government = GameConstants.SubGovernment.MAOIST
				c123.leave_alliances()
				c123.set_tag("亲中", true)
				_add_d(d, W.I_INFLUENCE, 30)
			else:
				c123.government = GameConstants.Government.SOCIALIST
				c123.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				c123.leave_alliances()
				c123.set_tag("亲中", true)
				_add_d(d, W.I_INFLUENCE, 30)
			if w.result_of_event_num(638) == 0:
				c123.set_tag("对华贸易", true)
		else:
			c123.prc_power = 0
			c123.usa_power = 1000
			c123.sov_power = 1000
			war.is_going = true
			war.name_war = "安哥拉内战"
			war.side1 = "安解阵"
			war.side2 = "安盟"
			war.infl1 = 600
			war.infl2 = 400
			war.usa_side = GameConstants.WarSide.SIDE2
			war.ussr_side = GameConstants.WarSide.SIDE2
			if c123.parts.size() > 0:
				c123.parts[0] = true
			c123.内战中 = false
			c123.leave_alliances()
			if w.result_of_event_num(638) == 1:
				c123.government = GameConstants.Government.AUTHORITARIAN
				c123.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			elif w.result_of_event_num(638) == 2:
				c123.government = GameConstants.Government.REFORMIST
				c123.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
			else:
				c123.government = GameConstants.Government.AUTHORITARIAN
				c123.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				if c131 != null and w.is_authoritarian(c131):
					c123.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
				else:
					c123.set_tag("亲美", true)
	elif c123.sov_power == 1000 and c123.usa_power == 0 and c123.prc_power == 0:
		if war.infl1 >= 850:
			c123.prc_power = 0
			c123.usa_power = 0
			c123.sov_power = 0
			c123.name = "安哥拉人民民主共和国"
			c123.chinese_name = "安哥拉人民民主共和国"
			if w.result_of_event_num(638) == 1:
				c123.government = GameConstants.Government.AUTHORITARIAN
				c123.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				c123.leave_alliances()
				c123.set_tag("亲中", true)
				c123.set_tag("对华贸易", true)
				add_empire_power(EmpireData.USA, 20)
				_add_d(d, W.I_INFLUENCE, 10)
			else:
				c123.government = GameConstants.Government.AUTHORITARIAN
				c123.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				c123.leave_alliances()
				c123.set_tag("亲美", true)
				if c131 != null and w.is_authoritarian(c131):
					c123.leave_alliances()
					c123.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
					add_empire_power(EmpireData.USA, 20)
					_add_d(d, W.I_INFLUENCE, 10)
		else:
			c123.prc_power = 0
			c123.usa_power = 0
			c123.sov_power = 0
			if c123.has_tag("亲苏"):
				c123.government = GameConstants.Government.SOCIALIST
				c123.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				c123.leave_alliances()
				c123.set_tag("亲苏", true)
				add_empire_power(EmpireData.USSR, 20)
				_add_d(d, W.I_INFLUENCE, 10)
			elif c123.sub_government == GameConstants.SubGovernment.MAOIST:
				c123.government = GameConstants.Government.SOCIALIST
				c123.sub_government = GameConstants.SubGovernment.MAOIST
				c123.leave_alliances()
				c123.set_tag("亲中", true)
				_add_d(d, W.I_INFLUENCE, 30)
			else:
				c123.government = GameConstants.Government.SOCIALIST
				c123.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				c123.leave_alliances()
				c123.set_tag("亲中", true)
				_add_d(d, W.I_INFLUENCE, 30)
			if w.result_of_event_num(638) == 0:
				c123.set_tag("对华贸易", true)
	elif c123.usa_power == 1000 and c123.sov_power == 0 and c123.prc_power == 0:
		if war.infl1 >= 850:
			c123.prc_power = 0
			c123.usa_power = 0
			c123.sov_power = 0
			c123.name = "安哥拉共和国"
			c123.chinese_name = "安哥拉共和国"
			c123.government = GameConstants.Government.REFORMIST
			c123.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
			c123.leave_alliances()
			if c117 != null and ((w.is_authoritarian(c117) and c117.sub_government != GameConstants.SubGovernment.LEFT_NATIONALIST) or c117.sub_government == GameConstants.SubGovernment.LEFT_CONSERVATIVE):
				c123.puppet_of = 117
			if w.result_of_event_num(638) == 2:
				if c117 != null and (not w.is_authoritarian(c117) or c117.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST) and c117.sub_government != GameConstants.SubGovernment.LEFT_CONSERVATIVE:
					c123.set_tag("亲中", true)
				c123.set_tag("对华贸易", true)
			add_empire_power(EmpireData.USA, 20)
			_add_d(d, W.I_INFLUENCE, 10)
		else:
			c123.prc_power = 1000
			c123.usa_power = 0
			c123.sov_power = 1000
			war.is_going = true
			war.name_war = "安哥拉内战"
			war.side1 = "安人运"
			war.side2 = "安盟"
			war.infl1 = 600
			war.infl2 = 400
			war.usa_side = GameConstants.WarSide.SIDE2
			war.ussr_side = GameConstants.WarSide.SIDE2
			if c123.parts.size() > 0:
				c123.parts[0] = true
			c123.内战中 = false
	elif c123.usa_power == 1000 and c123.sov_power == 1000 and c123.prc_power == 0:
		if war.infl1 >= 850:
			c123.prc_power = 0
			c123.usa_power = 0
			c123.sov_power = 0
			c123.name = "安哥拉共和国"
			c123.chinese_name = "安哥拉共和国"
			c123.government = GameConstants.Government.REFORMIST
			c123.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
			c123.leave_alliances()
			if c117 != null and ((w.is_authoritarian(c117) and c117.sub_government != GameConstants.SubGovernment.LEFT_NATIONALIST) or c117.sub_government == GameConstants.SubGovernment.LEFT_CONSERVATIVE):
				c123.puppet_of = 117
			if w.result_of_event_num(638) == 2:
				if c117 != null and (not w.is_authoritarian(c117) or c117.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST) and c117.sub_government != GameConstants.SubGovernment.LEFT_CONSERVATIVE:
					c123.set_tag("亲中", true)
				c123.set_tag("对华贸易", true)
			add_empire_power(EmpireData.USA, 20)
			_add_d(d, W.I_INFLUENCE, 10)
		else:
			c123.name = "安哥拉人民民主共和国"
			c123.chinese_name = "安哥拉人民民主共和国"
			c123.prc_power = 0
			c123.usa_power = 0
			c123.sov_power = 0
			if w.result_of_event_num(638) == 1:
				c123.government = GameConstants.Government.AUTHORITARIAN
				c123.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				c123.leave_alliances()
				c123.set_tag("亲中", true)
				add_empire_power(EmpireData.USA, 20)
				_add_d(d, W.I_INFLUENCE, 10)
				c123.set_tag("对华贸易", true)
			else:
				c123.government = GameConstants.Government.AUTHORITARIAN
				c123.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				c123.leave_alliances()
				c123.set_tag("亲美", true)
				if c131 != null and w.is_authoritarian(c131):
					c123.leave_alliances()
					c123.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
					add_empire_power(EmpireData.USA, 20)
					_add_d(d, W.I_INFLUENCE, 10)
	elif c123.usa_power == 0 and c123.sov_power == 1000 and c123.prc_power == 1000:
		if war.infl1 >= 850:
			c123.name = "安哥拉"
			c123.chinese_name = "安哥拉"
			c123.prc_power = 0
			c123.usa_power = 0
			c123.sov_power = 0
			if c123.has_tag("亲苏"):
				c123.government = GameConstants.Government.SOCIALIST
				c123.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				c123.leave_alliances()
				c123.set_tag("亲苏", true)
				add_empire_power(EmpireData.USSR, 20)
				_add_d(d, W.I_INFLUENCE, 10)
			elif c123.sub_government == GameConstants.SubGovernment.MAOIST:
				c123.government = GameConstants.Government.SOCIALIST
				c123.sub_government = GameConstants.SubGovernment.MAOIST
				c123.leave_alliances()
				c123.set_tag("亲中", true)
				_add_d(d, W.I_INFLUENCE, 30)
			else:
				c123.government = GameConstants.Government.SOCIALIST
				c123.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				c123.leave_alliances()
				c123.set_tag("亲中", true)
				_add_d(d, W.I_INFLUENCE, 30)
			if w.result_of_event_num(638) == 0:
				c123.set_tag("对华贸易", true)
		else:
			c123.name = "安哥拉人民民主共和国"
			c123.chinese_name = "安哥拉人民民主共和国"
			c123.prc_power = 0
			c123.usa_power = 0
			c123.sov_power = 0
			if w.result_of_event_num(638) == 1:
				c123.government = GameConstants.Government.AUTHORITARIAN
				c123.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				c123.leave_alliances()
				c123.set_tag("亲中", true)
				add_empire_power(EmpireData.USA, 20)
				_add_d(d, W.I_INFLUENCE, 10)
				c123.set_tag("对华贸易", true)
			else:
				c123.government = GameConstants.Government.AUTHORITARIAN
				c123.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				c123.leave_alliances()
				c123.set_tag("亲美", true)
				if c131 != null and w.is_authoritarian(c131):
					c123.leave_alliances()
					c123.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
					add_empire_power(EmpireData.USA, 20)
					_add_d(d, W.I_INFLUENCE, 10)


## 战争 69 号结算：GameState.cs:3648-3676。
static func _apply_war69_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c9 := WarQueries.wc(w, 9)
	var china := WarQueries.wc(w, 1)
	if war.infl1 >= 950:
		if c9 != null:
			c9.leave_alliances()
			if china != null:
				c9.government = china.government
				c9.sub_government = china.sub_government
			c9.puppet_of = GameConstants.LegacySlot.CHINA
			c9.set_tag("亲中", true)
			c9.set_tag("对华贸易", true)
			_join_all_our_alliances(w, c9)
			c9.name = "蒙古占领区"
			c9.chinese_name = "蒙古占领区"
			d.mongolia_china_route = 1
		_add_d(d, W.I_PARTY_SUPPORT, 300)
		_add_d(d, W.I_PEOPLE_SUPPORT, 300)
		_add_d(d, W.I_THOUGHT_FREEDOM, -300)
		add_empire_power(EmpireData.USSR, -100)
		_add_empire_rel(w, 1, -1000)
		_add_d(d, W.I_INFLUENCE, 100)
	else:
		_add_d(d, W.I_PARTY_SUPPORT, -1000)
		_add_d(d, W.I_PEOPLE_SUPPORT, -1000)
		_add_d(d, W.I_INFLUENCE, -200)


## 战争 76 号结算：GameState.cs:4011-4078。
static func _apply_war76_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c2 := WarQueries.wc(w, 2)
	var c3 := WarQueries.wc(w, 3)
	var c4 := WarQueries.wc(w, 4)
	var c5 := WarQueries.wc(w, 5)
	var c6 := WarQueries.wc(w, 6)
	var c16 := WarQueries.wc(w, 16)
	var c17 := WarQueries.wc(w, 17)
	if war.infl1 >= 950:
		if c5 != null and c5.parts.size() > 0:
			c5.parts[0] = true
		if c4 != null:
			c4.leave_alliances()
			c4.set_tag("亲中", true)
			_join_all_our_alliances(w, c4)
			c4.set_tag("对华贸易", true)
			c4.government = GameConstants.Government.AUTHORITARIAN
			c4.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
		for c in w.countries:
			if c == null:
				continue
			var legacy := c.原版序号
			if (c.has_tag("ovd") or c.has_tag("sev")) and legacy != 7:
				c.set_tag("亲苏", false)
			if c.has_tag("sev"):
				c.set_tag("sev", false)
			if c.has_tag("ovd"):
				c.set_tag("ovd", false)
		for c in [c2, c3, c6]:
			if c != null:
				c.government = GameConstants.Government.REFORMIST
				c.sub_government = GameConstants.SubGovernment.PRAGMATIST
				c.set_tag("对华贸易", true)
		_add_d(d, W.I_PARTY_SUPPORT, 500)
		_add_d(d, W.I_PEOPLE_SUPPORT, 500)
		_add_d(d, W.I_THOUGHT_FREEDOM, -500)
		add_empire_power(EmpireData.USSR, -150)
		_add_empire_rel(w, 1, -750)
		add_empire_power(EmpireData.USA, -50)
		_add_empire_rel(w, 0, -200)
		_add_d(d, W.I_INFLUENCE, 100)
		if c16 != null and c17 != null and (c16.parts.size() <= 0 or not c16.parts[0]) and c17.development <= 0:
			if c17.parts.size() <= 0:
				c17.parts.resize(1)
			c17.parts[0] = true
			c17.development = 2
			c16.leave_alliances()
	else:
		if c4 != null and c4.parts.size() > 0:
			c4.parts[0] = true
		_add_d(d, W.I_PARTY_SUPPORT, -300)
		_add_d(d, W.I_PEOPLE_SUPPORT, -300)
		_add_d(d, W.I_THOUGHT_FREEDOM, 300)
		if c5 != null:
			c5.government = GameConstants.Government.SOCIALIST
			c5.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
			c5.leave_alliances()
			c5.set_tag("sev", true)
			c5.set_tag("ovd", true)
			c5.set_tag("亲苏", true)
		_add_d(d, W.I_INFLUENCE, -200)


## 战争 77 号结算：GameState.cs:4078-4101。
static func _apply_war77_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c107 := WarQueries.wc(w, 107)
	if c107 != null and c107.parts.size() > 0:
		c107.parts[0] = false
	if war.infl1 >= 700:
		if c107 != null:
			c107.government = GameConstants.Government.LIBERAL
			c107.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			if _dval(d, W.I_INFLUENCE) >= _emp_power_val(w, EmpireData.USA):
				c107.set_tag("亲中", true)
			else:
				c107.set_tag("亲美", true)
	else:
		if c107 != null:
			c107.set_tag("亲苏", true)


## 战争 78 号结算：GameState.cs:4101-4135。
static func _apply_war78_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c107 := WarQueries.wc(w, 107)
	var c13 := WarQueries.wc(w, 13)
	if c107 != null and c107.parts.size() > 0:
		c107.parts[0] = false
	if war.infl1 >= 700:
		if c107 == null:
			return
		if c107.内战中:
			c107.government = GameConstants.Government.SOCIALIST
			c107.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
			c107.leave_alliances()
			c107.set_tag("对华贸易", true)
			c107.set_tag("亲中", true)
			_add_d(d, W.I_INFLUENCE, 10)
		else:
			c107.government = GameConstants.Government.AUTHORITARIAN
			c107.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			c107.leave_alliances()
			c107.set_tag("对华贸易", true)
			c107.set_tag("亲中", true)
			if c13 != null and c13.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
				c107.puppet_of = 13


## 战争 79 号结算：GameState.cs:4135-4212。
static func _apply_war79_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c60 := WarQueries.wc(w, 60)
	var c164 := WarQueries.wc(w, 164)
	var c165 := WarQueries.wc(w, 165)
	if c60 != null and c60.parts.size() > 0:
		c60.parts[0] = false
	if c60 != null and c60.内战中:
		if war.infl1 >= 1000:
			c60.government = GameConstants.Government.AUTHORITARIAN
			c60.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			c60.leave_alliances()
			c60.set_tag("对华贸易", true)
			c60.set_tag("亲中", true)
			c60.name = "索科托伊斯兰国"
			c60.chinese_name = "索科托伊斯兰国"
			_add_d(d, W.I_INFLUENCE, 20)
		else:
			c60.government = GameConstants.Government.AUTHORITARIAN
			c60.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			c60.leave_alliances()
			c60.name = "尼日利亚"
			c60.chinese_name = "尼日利亚"
			if c164 != null:
				c164.name = "索科托伊斯兰国"
				c164.chinese_name = "索科托伊斯兰国"
				if c164.parts.size() <= 0:
					c164.parts.resize(1)
				c164.parts[0] = true
				c164.government = GameConstants.Government.AUTHORITARIAN
				c164.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				c164.leave_alliances()
				c164.set_tag("对华贸易", true)
				c164.set_tag("亲中", true)
			_add_d(d, W.I_INFLUENCE, 20)
	elif war.infl1 >= 1000:
		if c60 != null:
			c60.government = GameConstants.Government.SOCIALIST
			c60.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
			c60.leave_alliances()
			c60.set_tag("对华贸易", true)
			c60.set_tag("亲中", true)
			c60.name = "尼日利亚人民联邦共和国"
			c60.chinese_name = "尼日利亚人民联邦共和国"
		_add_d(d, W.I_INFLUENCE, 20)
	else:
		var c66 := WarQueries.wc(w, 66)
		if c60 != null:
			if c66 != null and w.is_socialism(c66, true):
				c60.government = GameConstants.Government.AUTHORITARIAN
				c60.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				c60.leave_alliances()
				c60.set_tag("对华贸易", true)
				c60.set_tag("亲中", true)
			else:
				c60.government = GameConstants.Government.AUTHORITARIAN
				c60.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				c60.leave_alliances()
				c60.puppet_of = GameConstants.LegacySlot.FRANCE
			c60.name = "比夫拉"
			c60.chinese_name = "比夫拉"
		if c164 != null:
			c164.name = "豪萨兰"
			c164.chinese_name = "豪萨兰"
			if c164.parts.size() <= 0:
				c164.parts.resize(1)
			c164.parts[0] = true
			c164.government = GameConstants.Government.AUTHORITARIAN
			c164.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			c164.leave_alliances()
			c164.set_tag("亲美", true)
		if c165 != null:
			c165.name = "约鲁巴兰"
			c165.chinese_name = "约鲁巴兰"
			if c165.parts.size() <= 0:
				c165.parts.resize(1)
			c165.parts[0] = true
			c165.government = GameConstants.Government.LIBERAL
			c165.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			c165.leave_alliances()
		_add_d(d, W.I_INFLUENCE, 20)


## 战争 80 号结算：GameState.cs:4212-4279。
static func _apply_war80_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c13 := WarQueries.wc(w, 13)
	var c21 := WarQueries.wc(w, 21)
	var c30 := WarQueries.wc(w, 30)
	var c57 := WarQueries.wc(w, 57)
	if c57 != null and c57.parts.size() > 0:
		c57.parts[0] = false
	if war.infl1 >= 1000:
		if c57 == null:
			return
		if w.result_of_event_num(658) == 2:
			c57.government = GameConstants.Government.AUTHORITARIAN
			c57.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			c57.leave_alliances()
			c57.puppet_of = 13
			c57.set_tag("对华贸易", true)
			if c13 != null:
				c13.name = "阿拉伯利比亚乍得人民社会主义民众国"
				c13.chinese_name = "阿拉伯利比亚乍得人民社会主义民众国"
			_add_d(d, W.I_INFLUENCE, 10)
			if c30 != null and c30.puppet_of != 13 and c13 != null and c13.parts.size() <= 1:
				c13.parts.resize(2)
			if c30 != null and c30.puppet_of != 13 and c13 != null:
				c13.parts[1] = true
		elif c57.puppet_of == 13:
			c57.government = GameConstants.Government.AUTHORITARIAN
			c57.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			c57.leave_alliances()
			c57.puppet_of = 13
			c57.set_tag("对华贸易", true)
			c57.name = "乍得人民社会主义民众国"
			c57.chinese_name = "乍得人民社会主义民众国"
			_add_d(d, W.I_INFLUENCE, 10)
		else:
			c57.government = GameConstants.Government.AUTHORITARIAN
			c57.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			c57.leave_alliances()
			c57.set_tag("对华贸易", true)
			if _emp_power_val(w, EmpireData.USSR) > _dval(d, W.I_INFLUENCE):
				c57.set_tag("亲苏", true)
			else:
				c57.set_tag("亲中", true)
			c57.name = "乍得民主共和国"
			c57.chinese_name = "乍得民主共和国"
			_add_d(d, W.I_INFLUENCE, 10)
	else:
		if c57 != null:
			c57.government = GameConstants.Government.AUTHORITARIAN
			c57.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			c57.leave_alliances()
			if c21 != null and w.is_socialism(c21, false):
				c57.puppet_of = GameConstants.LegacySlot.FRANCE
			else:
				c57.set_tag("亲美", true)


## 战争 82 号结算：GameState.cs:4279-4326。
static func _apply_war82_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c33 := WarQueries.wc(w, 33)
	if c33 != null and c33.parts.size() > 0:
		c33.parts[0] = false
	if war.infl1 >= 1000:
		_add_d(d, W.I_INFLUENCE, -20)
	elif w.result_of_event_num(662) == 2:
		if c33 != null:
			if c33.parts.size() <= 1:
				c33.parts.resize(2)
			c33.parts[1] = true
			c33.government = GameConstants.Government.REFORMIST
			c33.sub_government = GameConstants.SubGovernment.TITOIST
			c33.leave_alliances()
			c33.set_tag("对华贸易", true)
		_add_d(d, W.I_INFLUENCE, 15)
	elif w.result_of_event_num(662) == 4:
		if c33 != null:
			c33.government = GameConstants.Government.SOCIALIST
			c33.sub_government = GameConstants.SubGovernment.TROTSKYIST
			c33.leave_alliances()
			c33.set_tag("对华贸易", true)
			c33.set_tag("亲中", true)
		_add_d(d, W.I_PARTY_SUPPORT, 100)
		_add_d(d, W.I_PEOPLE_SUPPORT, 50)
		_add_empire_rel(w, 0, -100)
		_add_empire_rel(w, 1, -100)
		_add_d(d, W.I_INFLUENCE, 20)
	else:
		if c33 != null:
			c33.government = GameConstants.Government.SOCIALIST
			c33.sub_government = GameConstants.SubGovernment.MAOIST
			c33.leave_alliances()
			c33.set_tag("对华贸易", true)
			c33.set_tag("亲中", true)
		_add_d(d, W.I_PARTY_SUPPORT, 100)
		_add_d(d, W.I_PEOPLE_SUPPORT, 50)
		_add_empire_rel(w, 0, -100)
		_add_empire_rel(w, 1, -100)
		_add_d(d, W.I_INFLUENCE, 30)


## 战争 83 号结算：GameState.cs:4326-4354。
static func _apply_war83_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c33 := WarQueries.wc(w, 33)
	if c33 != null and c33.parts.size() > 0:
		c33.parts[0] = false
	if war.infl1 >= 1000:
		if c33 != null:
			if c33.parts.size() > 1:
				c33.parts[1] = false
			c33.government = GameConstants.Government.AUTHORITARIAN
			c33.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			c33.leave_alliances()
			if w.result_of_event_num(664) == 2:
				c33.set_tag("对华贸易", true)
				c33.set_tag("亲中", true)
				_add_d(d, W.I_INFLUENCE, 10)
	else:
		if c33 != null:
			if c33.parts.size() <= 1:
				c33.parts.resize(2)
			c33.parts[1] = true
			c33.government = GameConstants.Government.LIBERAL
			c33.sub_government = GameConstants.SubGovernment.LIBERAL
			c33.leave_alliances()
			c33.set_tag("亲美", true)
		_add_d(d, W.I_INFLUENCE, -10)


## 战争 84 号结算：GameState.cs:4354-4401。
static func _apply_war84_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c141 := WarQueries.wc(w, 141)
	if c141 != null and c141.parts.size() > 0:
		c141.parts[0] = false
	if war.infl2 >= 1000:
		if c141 != null:
			c141.government = GameConstants.Government.AUTHORITARIAN
			c141.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN if w.result_of_event_num(665) == 0 else 13
			c141.leave_alliances()
			c141.set_tag("亲美", true)
			if c141.parts.size() <= 1:
				c141.parts.resize(2)
			c141.parts[1] = true
		add_empire_power(EmpireData.USA, 10)
	elif w.result_of_event_num(665) == 0:
		if c141 != null:
			c141.government = GameConstants.Government.SOCIALIST
			c141.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			c141.leave_alliances()
			c141.set_tag("亲中", true)
			c141.set_tag("对华贸易", true)
		_add_d(d, W.I_INFLUENCE, 10)
		add_empire_power(EmpireData.USA, -10)
	else:
		if c141 != null:
			c141.leave_alliances()
			c141.set_tag("亲中", true)
			c141.set_tag("对华贸易", true)
		_add_d(d, W.I_INFLUENCE, 10)
		add_empire_power(EmpireData.USA, -10)


## 战争 85 号结算：GameState.cs:4401-4512。
static func _apply_war85_result(war: WarData, _d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c1 := WarQueries.wc(w, 1)
	var c20 := WarQueries.wc(w, 20)
	var c21 := WarQueries.wc(w, 21)
	var c58 := WarQueries.wc(w, 58)
	var c61 := WarQueries.wc(w, 61)
	if c58 != null and c58.parts.size() > 0:
		c58.parts[0] = false
	if war.infl2 >= 900:
		if c58 == null:
			return
		var fallback_democratic := false
		if (c1 != null and w.is_socialism(c1, false)) or not w.modifier_active(6) or (c20 != null and not c20.has_tag("亲中")):
			fallback_democratic = true
		elif w.result_of_event_num(672) == 0:
			if w.result_of_event_num(458) == 2:
				c58.set_tag("对华贸易", true)
				if (c61 != null and c61.has_tag("亲苏")) or (c1 != null and c1.has_tag("sev")):
					c58.government = GameConstants.Government.SOCIALIST
					c58.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					c58.leave_alliances()
					c58.set_tag("亲苏", true)
					c58.set_tag("对华贸易", true)
					c58.name = "马里民主共和国"
					c58.chinese_name = "马里民主共和国"
					add_empire_power(EmpireData.USA, 10)
				else:
					c58.government = GameConstants.Government.SOCIALIST
					c58.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
					c58.leave_alliances()
					c58.set_tag("对华贸易", true)
					c58.set_tag("亲中", true)
					c58.name = "马里人民共和国"
					c58.chinese_name = "马里人民共和国"
					add_empire_power(EmpireData.USA, 10)
			else:
				fallback_democratic = true
		else:
			fallback_democratic = true
		if fallback_democratic:
			if _emp_power_val(w, EmpireData.USA) > _emp_power_val(w, EmpireData.USSR):
				c58.government = GameConstants.Government.LIBERAL
				c58.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				c58.leave_alliances()
				add_empire_power(EmpireData.USA, 10)
			else:
				c58.government = GameConstants.Government.REFORMIST
				c58.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				c58.leave_alliances()
				add_empire_power(EmpireData.USSR, 10)
	elif war.infl1 >= 900:
		if c61 != null:
			c61.government = GameConstants.Government.AUTHORITARIAN
			c61.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			c61.leave_alliances()
			if c21 != null and not w.is_socialism(c21, true):
				c61.puppet_of = GameConstants.LegacySlot.FRANCE
			if w.result_of_event_num(672) == 1:
				c61.set_tag("对华贸易", true)


## 战争 86 号结算：GameState.cs:4512-4592。
static func _apply_war86_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c29 := WarQueries.wc(w, 29)
	var c92 := WarQueries.wc(w, 92)
	var c166 := WarQueries.wc(w, 166)
	if c29 != null and c29.parts.size() > 1:
		c29.parts[1] = false
	if (_dval(d, 147) == 6 or _dval(d, 147) == 8) and _dval(d, 166) < 100:
		_add_d(d, W.I_INFLUENCE, 30)
		add_empire_power(EmpireData.USSR, 50)
		if c92 != null and c92.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST:
			if _dval(d, 165) > _dval(d, 162) and _dval(d, 165) > _dval(d, 163) \
					and _dval(d, 165) > _dval(d, 164) and _dval(d, 165) > _dval(d, 166):
				if c29 != null:
					c29.government = GameConstants.Government.AUTHORITARIAN
					c29.sub_government = GameConstants.SubGovernment.NEO_FASCIST
					if c29.parts.size() <= 0:
						c29.parts.resize(1)
					c29.parts[0] = true
					c29.leave_alliances()
					c29.set_tag("对华贸易", true)
					c29.内战中 = true
					c29.set_tag("亲美", true)
			elif c29 != null:
				c29.government = GameConstants.Government.REFORMIST
				c29.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				if c29.parts.size() <= 0:
					c29.parts.resize(1)
				c29.parts[0] = true
				c29.leave_alliances()
				c29.set_tag("对华贸易", true)
				c29.内战中 = true
	elif war.infl2 >= 900:
		_add_d(d, W.I_INFLUENCE, -50)
		add_empire_power(EmpireData.USSR, -50)
	elif war.infl1 >= 900:
		if _dval(d, 166) < 100:
			if c166 != null:
				if c166.parts.size() <= 0:
					c166.parts.resize(1)
				c166.parts[0] = true
				c166.set_tag("亲中", true)
				c166.set_tag("对华贸易", true)
				c166.name = "爱尔兰社会主义共和国"
				c166.chinese_name = "爱尔兰社会主义共和国"
				if _dval(d, 162) >= 100:
					c166.government = GameConstants.Government.SOCIALIST
					c166.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				else:
					_set_d(d, 167, 6)
					if _dval(d, 163) >= 100:
						c166.government = GameConstants.Government.SOCIALIST
						c166.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
					elif _dval(d, 164) >= 100:
						c166.government = GameConstants.Government.SOCIALIST
						c166.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
					else:
						# 三个组织强度都未达标时，不能再保留 112-168 默认的
						# 0/13（威权/新父权主义），否则会出现“爱尔兰社会主义共和国=新父权主义”。
						c166.government = GameConstants.Government.SOCIALIST
						c166.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			_add_d(d, W.I_INFLUENCE, 30)
			_add_empire_rel(w, 0, -50)
		else:
			_set_d(d, 167, 6)
			if c166 != null:
				if c166.parts.size() <= 0:
					c166.parts.resize(1)
				c166.parts[0] = true
				c166.name = "阿尔斯特民主共和国"
				c166.chinese_name = "阿尔斯特民主共和国"
				c166.government = GameConstants.Government.SOCIALIST
				c166.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				c166.set_tag("对华贸易", true)
		# 北爱尔兰一方获胜：把北爱 26 区从英国划给独立的北爱尔兰实体。
		if c166 != null and c166.gwcode > 0:
			if GameManager != null:
				GameManager.set_map_region_owner(MapService.NORTHERN_IRELAND_REGIONS, c166.gwcode)
			elif MapService.instance != null:
				MapService.instance.set_region_owner(MapService.NORTHERN_IRELAND_REGIONS, c166.gwcode)


## 战争 87 号结算：GameState.cs:4592-4640。
static func _apply_war87_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c21 := WarQueries.wc(w, 21)
	var c29 := WarQueries.wc(w, 29)
	var c166 := WarQueries.wc(w, 166)
	if c166 != null:
		if c166.parts.size() > 1:
			c166.parts[1] = false
		if c166.parts.size() > 0:
			c166.parts[0] = false
	if war.infl2 >= 900:
		_add_d(d, W.I_INFLUENCE, -100)
		add_empire_power(EmpireData.USSR, -100)
		add_empire_power(EmpireData.USA, 100)
		if c29 != null and c29.parts.size() > 0:
			c29.parts[0] = true
		_set_d(d, 169, 1)
	elif war.infl1 >= 900:
		if _dval(d, 166) < 100:
			if c29 != null and c166 != null:
				if c29.parts.size() <= 0:
					c29.parts.resize(1)
				c29.parts[0] = true
				c29.name = c166.name
				c29.chinese_name = c166.chinese_name
				c29.government = c166.government
				c29.sub_government = c166.sub_government
				c29.leave_alliances()
				if c21 != null and c21.has_tag("soc_eu") and c29.sub_government == GameConstants.SubGovernment.EUROCOMMUNIST:
					c29.set_tag("soc_eu", true)
				c29.set_tag("亲中", true)
				c29.set_tag("对华贸易", true)
				c29.内战中 = true
			_add_d(d, W.I_INFLUENCE, 30)
			_add_empire_rel(w, 0, -50)
		else:
			_set_d(d, 167, 6)
			if c29 != null:
				if c29.parts.size() <= 0:
					c29.parts.resize(1)
				c29.parts[0] = true
				c29.name = "爱尔兰民主共和国"
				c29.chinese_name = "爱尔兰民主共和国"
				c29.leave_alliances()
				c29.government = GameConstants.Government.AUTHORITARIAN
				c29.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				c29.set_tag("亲中", true)
				c29.set_tag("对华贸易", true)
				c29.内战中 = true


## 战争 88 号结算：GameState.cs:4640-4689。
static func _apply_war88_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c8 := WarQueries.wc(w, 8)
	var c14 := WarQueries.wc(w, 14)
	var c36 := WarQueries.wc(w, 36)
	if war.infl1 >= 1000:
		for c in w.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.IRAQ:
				c.puppet_of = GameConstants.LegacySlot.NONE
		if w.wars.size() > 3 and w.wars[3] != null and w.wars[3].is_going:
			w.wars[3].infl1 = 0
			w.wars[3].infl2 = 1000
		if w.event_done_num(36) and w.result_of_event_num(36) == 3:
			if c14 != null and c14.puppet_of < 0:
				c14.leave_alliances()
				c14.government = GameConstants.Government.LIBERAL
				c14.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				c14.name = "伊拉克伊斯兰共和国"
				c14.chinese_name = "伊拉克伊斯兰共和国"
				c14.set_tag("亲中", true)
				c14.set_tag("对华贸易", true)
				_add_d(d, W.I_INFLUENCE, 20)
				w.oil_prod += 100
		else:
			if c14 != null and c14.puppet_of < 0:
				c14.leave_alliances()
				c14.government = GameConstants.Government.AUTHORITARIAN
				c14.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				c14.name = "伊拉克伊斯兰共和国"
				c14.chinese_name = "伊拉克伊斯兰共和国"
	else:
		if c14 != null:
			c14.leave_alliances()
			c14.government = GameConstants.Government.AUTHORITARIAN
			c14.sub_government = GameConstants.SubGovernment.NEOPATRIARCHAL
			if c14.parts.size() > 7:
				c14.parts[4] = false
				c14.parts[5] = false
				c14.parts[6] = false
				c14.parts[7] = false
		if c36 != null:
			c36.leave_alliances()
			c36.government = GameConstants.Government.AUTHORITARIAN
			c36.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		if c8 != null:
			c8.prc_power = 0
		for c in w.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.IRAQ:
				c.puppet_of = GameConstants.LegacySlot.NONE


## 战争 89 号结算：GameState.cs:4689-4747。
static func _apply_war89_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var c8 := WarQueries.wc(w, 8)
	var c14 := WarQueries.wc(w, 14)
	var c35 := WarQueries.wc(w, 35)
	var c36 := WarQueries.wc(w, 36)
	if c35 != null and c35.parts.size() > 1:
		c35.parts[1] = false
	if war.infl2 >= 1000:
		if c35 != null:
			c35.leave_alliances()
			c35.puppet_of = GameConstants.LegacySlot.IRAQ
			c35.government = GameConstants.Government.AUTHORITARIAN
			c35.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
			c35.set_tag("对华贸易", true)
			_join_all_our_alliances(w, c35)
		_add_d(d, W.I_INFLUENCE, 50)
		_add_d(d, 143, -2)
		for idx in [24, 25, 103, 104, 105]:
			var c := WarQueries.wc(w, idx)
			if c != null and w.is_authoritarian(c):
				c.leave_alliances()
				c.puppet_of = GameConstants.LegacySlot.IRAQ
				c.government = GameConstants.Government.AUTHORITARIAN
				c.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
				c.set_tag("亲中", true)
				c.set_tag("对华贸易", true)
				_join_all_our_alliances(w, c)
	else:
		if c14 != null:
			c14.leave_alliances()
			c14.government = GameConstants.Government.AUTHORITARIAN
			c14.sub_government = GameConstants.SubGovernment.NEOPATRIARCHAL
			if c14.parts.size() > 7:
				c14.parts[4] = false
				c14.parts[5] = false
				c14.parts[6] = false
				c14.parts[7] = false
		if c36 != null:
			c36.leave_alliances()
			c36.government = GameConstants.Government.AUTHORITARIAN
			c36.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		if c8 != null:
			c8.prc_power = 0
		for c in w.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.IRAQ:
				c.puppet_of = GameConstants.LegacySlot.NONE


## 战争 20 号结算：GameState.cs:1135-1165。
static func _apply_war20_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var chad := w.get_country_by_legacy_index(57)
	var libya := w.get_country_by_legacy_index(13)
	if w.result_of_event_num(512) == 2:
		d.soviet_eastern_europe_intervention = 2
		if chad != null:
			chad.government = GameConstants.Government.AUTHORITARIAN
			chad.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			chad.set_tag("亲美", true)
		d.oil_price -= 3
	elif war.infl1 >= 900:
		if libya != null:
			libya.government = GameConstants.Government.AUTHORITARIAN
			libya.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			if libya.parts.size() <= 0:
				libya.parts.resize(1)
			libya.parts[0] = true
		if chad != null:
			chad.government = GameConstants.Government.AUTHORITARIAN
			chad.puppet_of = 13
			chad.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
		d.soviet_eastern_europe_intervention = 1
	elif war.infl2 >= 600:
		d.soviet_eastern_europe_intervention = 2
		if chad != null:
			chad.government = GameConstants.Government.AUTHORITARIAN
			chad.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			chad.set_tag("亲美", true)
		d.oil_price -= 3


## 战争 8 号结算：GameState.cs:573-600。
static func _apply_war8_result(war: WarData, _d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var turkey := w.get_country_by_legacy_index(84)
	var portugal := w.get_country_by_legacy_index(87)
	if war.infl1 >= 500:
		return
	if war.infl2 >= 800:
		if turkey != null:
			turkey.government = GameConstants.Government.REFORMIST
			turkey.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			turkey.set_tag("亲美", false)
			turkey.set_tag("nato", false)
			turkey.内战中 = true
		add_empire_power(EmpireData.USA, -50)
		if portugal != null:
			portugal.special -= 10
	else:
		if turkey != null:
			turkey.government = GameConstants.Government.REFORMIST
			turkey.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
			turkey.set_tag("亲美", false)
			turkey.set_tag("nato", false)
		add_empire_power(EmpireData.USA, -30)
		if portugal != null:
			portugal.special -= 5


## 战争 9 号结算：GameState.cs:603-645。
static func _apply_war9_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	var turkey := w.get_country_by_legacy_index(84)
	var kurdistan := w.get_country_by_legacy_index(95)
	if war.infl1 >= 600:
		return
	if war.infl2 >= 800:
		add_empire_power(EmpireData.USA, -50)
		if turkey != null:
			turkey.government = GameConstants.Government.LIBERAL
			turkey.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			if turkey.parts.size() <= 0:
				turkey.parts.resize(1)
			turkey.parts[0] = true
		d.global_influence += 30
		# 原版把 allcountries[95]（库尔德斯坦）设为社会主义/国控社会主义并亲中。
		if kurdistan != null:
			kurdistan.government = GameConstants.Government.SOCIALIST
			kurdistan.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			kurdistan.set_tag("亲中", true)
			kurdistan.set_tag("亲苏", false)
			kurdistan.set_tag("亲美", false)
			kurdistan.puppet_of = GameConstants.LegacySlot.NONE
			if kurdistan.chinese_name == "":
				kurdistan.chinese_name = "库尔德斯坦"
		# 项目用 157（库尔德斯坦二号）承载库尔德地区的地图实体；激活 parts[0]，
		# 由 map_service 的 PART_MERGE_RULES 把库尔德聚居区划给该实体，不再“打赢无变化”。
		_activate_kurdistan_map(w, GameConstants.Government.SOCIALIST, GameConstants.SubGovernment.STATE_SOCIALIST)
		var kurd_map := w.get_country_by_legacy_index(157)
		if kurd_map != null:
			kurd_map.set_tag("亲中", true)
			kurd_map.set_tag("亲苏", false)
			kurd_map.set_tag("亲美", false)
	else:
		if turkey != null:
			turkey.government = GameConstants.Government.LIBERAL
			turkey.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT


## 激活 157 号库尔德地图实体（等价 Event372 的 _activate_kurdistan()）。
static func _activate_kurdistan_map(w: WorldState, gov: int, sub_gov: int) -> void:
	var c := w.get_country_by_legacy_index(157)
	if c == null:
		return
	if c.parts.size() <= 0:
		c.parts.resize(1)
	c.parts[0] = true
	c.name = "库尔德斯坦共和国"
	c.chinese_name = "库尔德斯坦共和国"
	_leave_alliances(c)
	c.government = gov
	c.sub_government = sub_gov
	c.puppet_of = GameConstants.LegacySlot.NONE
	if MapService.instance != null:
		MapService.instance.sync_map_merges()


## WarResult 950 阈值战争集合：{war_id: 失败结局编号}。
## 出处 GameState.cs:3676(70→12)、3746(71→11)、3817(72→12)、3850(73→11)、
## 3921(74→3)、3982(75→11)、4747(90→11)。
static func _is_war_result_route(war_id: int) -> bool:
	return war_id == 70 or war_id == 71 or war_id == 72 or war_id == 73 \
		or war_id == 74 or war_id == 75 or war_id == 90


static func _war_result_defeat_ending(war_id: int) -> int:
	match war_id:
		70: return 12
		71: return 11
		72: return 12
		73: return 11
		74: return 3
		75: return 11
		90: return 11
	return -1


static func _apply_war_result_defeat(war_id: int, d: WorldState) -> void:
	# 原版失败分支统一前置效果（GameState.cs 各 else 分支）：
	# data.party_support=0; data.people_support=0; influencePRC -= 200; 然后直接 LoadScene("Ending")。
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support = 0
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support = 0
	if d.size() > W.I_INFLUENCE:
		d.global_influence -= 200
	var ending := _war_result_defeat_ending(war_id)
	if ending >= 0 and _trigger_ending_cb.is_valid():
		_trigger_ending_cb.call(ending)


## 珍宝岛/中南半岛/朝鲜/印度/台海/日本方向胜利特效（GameState.WarResult 胜利分支；
## 文案由 event_018 显示层输出；ILoveSuckCocks 地图刷新按项目惯例近似省略）。
static func _route_victory_effects(w: WorldState, war_id: int, d: WorldState) -> void:
	if war_id == 70:
		_war70_victory(w, d)
	elif war_id == 71:
		_war71_victory(w, d)
	elif war_id == 72:
		_war72_victory(w, d)
	elif war_id == 73:
		_war73_victory(w, d)
	elif war_id == 74:
		_war74_victory(w, d)
	elif war_id == 75:
		_war75_victory(w, d)
	elif war_id == 90:
		_war90_victory(w, d)


static func _war70_victory(w: WorldState, d: WorldState) -> void:
	if not w.event_done_num(642):
		w.set_flag("is_gkchp", true)
		var c7 := WarQueries.wc(w, 7)
		if c7 != null:
			c7.government = GameConstants.Government.AUTHORITARIAN
			c7.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			c7.leave_eu()
			c7.leave_nato()
		for c in w.countries:
			if c != null and c.has_tag("亲苏"):
				c.leave_eu()
				c.leave_nato()
		_add_d(d, W.I_PARTY_SUPPORT, 500)
		_add_d(d, W.I_PEOPLE_SUPPORT, 500)
		_add_d(d, W.I_THOUGHT_FREEDOM, -500)
		_add_d(d, W.I_POPULATION, 180)
		add_empire_power(EmpireData.USSR, -500)
		_add_empire_rel(w, 1, -1000)
		add_empire_power(EmpireData.USA, -250)
		_set_empire_rel(w, 0, 0)
		_add_d(d, W.I_INFLUENCE, 250)
	else:
		w.ind_opp = true
		w.set_flag("relres", false)
		var c9 := WarQueries.wc(w, 9)
		if c9 != null:
			c9.leave_alliances()
		var c7 := WarQueries.wc(w, 7)
		if c7 != null:
			c7.government = GameConstants.Government.REFORMIST
			c7.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
		if w.empires.size() > 1 and w.empires[1] != null:
			w.empires[1].current_leader = 6
		_set_d(d, 130, 1)
		_add_d(d, W.I_PARTY_SUPPORT, 500)
		_add_d(d, W.I_PEOPLE_SUPPORT, 500)
		_add_d(d, W.I_THOUGHT_FREEDOM, -500)
		_add_d(d, W.I_POPULATION, 180)
		add_empire_power(EmpireData.USSR, -500)
		_add_empire_rel(w, 1, -1000)
		_add_empire_rel(w, 0, -300)
		_add_d(d, W.I_INFLUENCE, 250)
		_set_decision(w, 37, true)

	# 雪耻之战胜利：外东北/外西北原清朝版图地块归中国。
	if GameManager != null:
		GameManager.set_map_region_owner(MapService.QING_LOST_TERRITORY_REGIONS, 710)
	elif MapService.instance != null:
		MapService.instance.set_region_owner(MapService.QING_LOST_TERRITORY_REGIONS, 710)


static func _war71_victory(w: WorldState, d: WorldState) -> void:
	var c33 := WarQueries.wc(w, 33)
	if c33 != null:
		if c33.parts.size() > 0:
			c33.parts[0] = false
		if c33.parts.size() > 1:
			c33.parts[1] = false
	var c23 := WarQueries.wc(w, 23)
	if c23 != null and c23.parts.size() > 0:
		c23.parts[0] = true
	_war_going_set(w, 82, false)
	var c11 := WarQueries.wc(w, 11)
	if c11 != null and c11.parts.size() > 0:
		c11.parts[0] = false
	_puppet_to_china(w, 11, "交 趾", [])
	_puppet_to_china(w, 22, "老 挝", [])
	_puppet_to_china(w, 23, "柬 埔 寨", [])
	_puppet_to_china(w, 33, "", [])
	_puppet_to_china(w, 34, "暹 罗", [])
	_war_victory_common(w, d)
	_set_decision(w, 37, false)


static func _war72_victory(w: WorldState, d: WorldState) -> void:
	_puppet_to_china(w, 10, "", [])
	_war_victory_common(w, d)
	_set_decision(w, 37, false)


static func _war73_victory(w: WorldState, d: WorldState) -> void:
	_puppet_to_china(w, 47, "吕 宋 （ 军 管 区 ）", [])
	_puppet_to_china(w, 49, "南 洋 特 别 行 政 区 （ 军 管 区 ）", [0])
	_puppet_to_china(w, 50, "三 佛 齐 （ 军 管 区 ）", [0])
	# 原 128 是纳米比亚，不是东帝汶；东帝汶无独立实体，移除误操作，避免把纳米比亚变成东帝汶。
	_puppet_to_china(w, 134, "昆 仑 （ 军 管 区 ）", [0])
	_war_victory_common(w, d)
	_set_decision(w, 37, false)


static func _war74_victory(w: WorldState, d: WorldState) -> void:
	for idx in [19, 31, 32, 43, 171, 172, 173]:
		var c := WarQueries.wc(w, idx)
		if c != null and c.parts.size() > 0:
			c.parts[0] = true
	var c19 := WarQueries.wc(w, 19)
	if c19 != null:
		c19.name = "前 印 度 斯 坦 地 区"
		c19.chinese_name = "前 印 度 斯 坦 地 区"
	var c43 := WarQueries.wc(w, 43)
	if c43 != null:
		c43.name = "大 尼 泊 尔"
		c43.chinese_name = "大 尼 泊 尔"
	WarQueries.wc_name(w, 97, "布 鲁 克 巴 （ 军 管 区 ）")
	WarQueries.wc_name(w, 171, "哲 孟 雄 （ 军 管 区 ）")
	WarQueries.wc_name(w, 172, "底 马 撒 （ 军 管 区 ）")
	WarQueries.wc_name(w, 173, "翠 蓝 屿 （ 军 管 区 ）")
	for idx in [19, 31, 32, 43, 96, 97, 171, 172, 173]:
		_puppet_to_china(w, idx, "", [])
	_war_victory_common(w, d)
	_set_decision(w, 37, false)


static func _war75_victory(w: WorldState, d: WorldState) -> void:
	_set_d(d, W.I_TAIWAN_STATUS, 2)
	_set_decision(w, 7, true)
	# 原版 CountryScript.cs:4881：completedDecisions[7] 成立后台湾地图对象(38)重绘为中国(1)。
	# Godot 无 parts 覆盖层，等价实现为台湾全部地块 713 → 710（含金马澎）。
	if MapService.instance != null:
		MapService.instance.transfer_owner(713, 710)
	_war_victory_common(w, d)


static func _war90_victory(w: WorldState, d: WorldState) -> void:
	var japan := WarQueries.wc(w, 44)
	if japan != null:
		if japan.has_tag("亲美"):
			add_empire_power(EmpireData.USA, -250)
			_add_empire_rel(w, 0, -1000)
			_add_empire_rel(w, 1, -200)
		elif japan.has_tag("亲苏"):
			add_empire_power(EmpireData.USSR, -250)
			_add_empire_rel(w, 1, -1000)
			_add_empire_rel(w, 0, -200)
		else:
			add_empire_power(EmpireData.USSR, -100)
			add_empire_power(EmpireData.USA, -100)
			_add_empire_rel(w, 1, -600)
			_add_empire_rel(w, 0, -600)
	var c10 := WarQueries.wc(w, 10)
	if c10 != null and c10.parts.size() > 0 and not c10.parts[0]:
		c10.parts[0] = true
	_puppet_to_china(w, 44, "日 本 人 民 国", [])
	_puppet_to_china(w, 169, "阿 依 努 乌 塔 里", [0])
	_puppet_to_china(w, 170, "琉 球 共 和 国", [0])
	_war_going_set(w, 0, false)
	_add_d(d, W.I_PARTY_SUPPORT, 500)
	_add_d(d, W.I_PEOPLE_SUPPORT, 500)
	_add_d(d, W.I_THOUGHT_FREEDOM, -500)
	_add_d(d, W.I_INFLUENCE, 250)
	_set_decision(w, 37, false)


## 71-74 胜利共用数值块（GameState.cs 各胜利分支尾部）。
static func _war_victory_common(w: WorldState, d: WorldState) -> void:
	_add_d(d, W.I_PARTY_SUPPORT, 500)
	_add_d(d, W.I_PEOPLE_SUPPORT, 500)
	_add_d(d, W.I_THOUGHT_FREEDOM, -500)
	_add_d(d, W.I_POPULATION, 18)
	add_empire_power(EmpireData.USSR, -150)
	_add_empire_rel(w, 1, -750)
	add_empire_power(EmpireData.USA, -50)
	_add_empire_rel(w, 0, -500)
	_add_d(d, W.I_INFLUENCE, 250)


## 设为中华势力圈：gov=0/sub=19、退盟、对华贸易、亲中、入我方联盟、puppetOf=1。
static func _puppet_to_china(w: WorldState, idx: int, new_name: String, parts_set: Array) -> void:
	var c := WarQueries.wc(w, idx)
	if c == null:
		return
	c.government = GameConstants.Government.AUTHORITARIAN
	c.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
	c.leave_alliances()
	c.set_tag("对华贸易", true)
	c.establish_government(2)
	_join_all_our_alliances(w, c)
	c.puppet_of = GameConstants.LegacySlot.CHINA
	if new_name != "":
		c.name = new_name
	for part in parts_set:
		var pi := int(part)
		if pi >= 0 and pi < c.parts.size():
			c.parts[pi] = true



static func _join_all_our_alliances(w: WorldState, c: CountryData) -> void:
	var china := WarQueries.wc(w, 1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)


static func _add_d(d: WorldState, idx: int, delta: int) -> void:
	if d.size() > idx:
		d.add_data_by_index(idx, delta)


static func _set_d(d: WorldState, idx: int, value: int) -> void:
	if d.size() > idx:
		d.set_data_by_index(idx, value)


static func _set_empire_rel(w: WorldState, idx: int, value: int) -> void:
	if w.empires.size() > idx and w.empires[idx] != null:
		w.empires[idx].relations = value


static func _set_decision(w: WorldState, idx: int, value: bool) -> void:
	if w.decisions != null and w.decisions.completed.size() > idx:
		w.decisions.completed[idx] = value


static func apply_war_side1_victory(war_id: int, war: WarData, d: WorldState) -> bool:
	var w: WorldState = current_world
	match war_id:
		0:
			var north := w.get_country_by_legacy_index(10)
			var south := w.get_country_by_legacy_index(46)
			if north != null and south != null:
				south.government = north.government
			d.global_influence += 50
			add_empire_power(EmpireData.USA, -40)
			d.korea_result = 1
		1:
			d.global_influence += 20
			d.party_support += 100
			add_empire_power(EmpireData.USSR, -20)
		2:
			var thailand := w.get_country_by_legacy_index(34)
			if thailand != null:
				thailand.government = GameConstants.Government.SOCIALIST
				thailand.set_tag("亲中", true)
				thailand.set_tag("亲美", false)
			d.global_influence += 20
			add_empire_power(EmpireData.USA, -20)
		3:
			add_empire_power(EmpireData.USSR, 10)
		4:
			add_empire_power(EmpireData.USSR, -10)
			add_empire_power(EmpireData.USA, 20)
		5:
			if war.ussr_side == GameConstants.WarSide.SIDE1:
				add_empire_power(EmpireData.USSR, 50)
			else:
				var afghanistan := w.get_country_by_legacy_index(12)
				if afghanistan != null:
					afghanistan.government = GameConstants.Government.SOCIALIST
					afghanistan.set_tag("亲苏", false)
					afghanistan.set_tag("亲中", true)
					afghanistan.set_tag("对华贸易", true)
				d.global_influence += 100
		6:
			w.set_flag("BritLost", true)
			add_empire_power(EmpireData.USA, -20)
		70, 71, 72, 73, 74, 75, 90:
			_route_victory_effects(w, war_id, d)
	return false


static func apply_war_side2_victory(war_id: int, war: WarData, d: WorldState) -> bool:
	var w: WorldState = current_world
	match war_id:
		0:
			var north := w.get_country_by_legacy_index(10)
			var south := w.get_country_by_legacy_index(46)
			if north != null and south != null:
				north.government = south.government
			d.global_influence -= 20
			add_empire_power(EmpireData.USSR, -20)
			add_empire_power(EmpireData.USA, 50)
			d.korea_result = 2
		1:
			var kampuchea := w.get_country_by_legacy_index(23)
			if kampuchea != null:
				kampuchea.government = GameConstants.Government.SOCIALIST
				kampuchea.set_tag("亲苏", true)
				kampuchea.set_tag("econ", false)
				kampuchea.set_tag("okb", false)
				kampuchea.set_tag("亲中", false)
				kampuchea.set_tag("对华贸易", false)
			d.global_influence -= 30
			add_empire_power(EmpireData.USSR, 10)
		2:
			d.global_influence -= 10
		3:
			var iraq := w.get_country_by_legacy_index(14)
			if iraq != null:
				iraq.government = GameConstants.Government.AUTHORITARIAN
				iraq.set_tag("对华贸易", false)
				iraq.set_tag("亲苏", false)
		4:
			add_empire_power(EmpireData.USSR, 10)
			add_empire_power(EmpireData.USA, -20)
			w.set_flag("israel_lost_lebanon_war", true)
		5:
			if war.ussr_side == GameConstants.WarSide.SIDE1:
				var afghanistan := w.get_country_by_legacy_index(12)
				if afghanistan != null:
					afghanistan.government = GameConstants.Government.AUTHORITARIAN
					afghanistan.set_tag("亲苏", false)
					afghanistan.set_tag("亲中", false)
					afghanistan.set_tag("对华贸易", false)
				add_empire_power(EmpireData.USSR, -30)
			else:
				restart_afghan_war(war, d)
				return true
		6:
			add_empire_power(EmpireData.USA, 20)
		42:
			# GameState.cs:2188-2210：伊拉克爱国同盟获胜且中国驻军基地存在 → 伊拉克社会主义联邦。
			var iraq42 := w.get_country_by_legacy_index(14)
			if iraq42 != null and iraq42.有驻军基地:
				iraq42.government = GameConstants.Government.SOCIALIST
				iraq42.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				_leave_alliances(iraq42)
				iraq42.set_tag("对华贸易", true)
				iraq42.set_tag("亲中", true)
				iraq42.puppet_of = GameConstants.LegacySlot.NONE
				iraq42.chinese_name = "伊拉克社会主义联邦"
				d.global_influence += 50
				add_empire_power(EmpireData.USA, -20)
				if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
					w.empires[EmpireData.USA].relations = clampi(w.empires[EmpireData.USA].relations - 150, 0, 1000)
				add_empire_power(EmpireData.USSR, -20)
				if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
					w.empires[EmpireData.USSR].relations = clampi(w.empires[EmpireData.USSR].relations - 50, 0, 1000)
				w.oil_prod += 100.0
	return false


static func apply_war_draw(war_id: int, war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	match war_id:
		2:
			d.global_influence -= 10
		4:
			add_empire_power(EmpireData.USSR, 10)
			add_empire_power(EmpireData.USA, -20)
			w.set_flag("israel_lost_lebanon_war", true)
		6:
			if war.infl1 >= 400:
				w.set_flag("BritLost", true)
				add_empire_power(EmpireData.USA, -20)
			else:
				add_empire_power(EmpireData.USA, 20)


static func restart_afghan_war(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	war.name_war = "Afghan war"
	war.side1 = "DRA"
	war.side2 = "Mujahideen"
	war.ussr_side = GameConstants.WarSide.SIDE1
	war.usa_side = GameConstants.WarSide.SIDE2
	war.infl1 = 650
	war.infl2 = 350
	war.fortnight_elapsed = 0
	var pakistan := w.get_country_by_legacy_index(31)
	if pakistan != null and pakistan.has_tag("亲美"):
		war.infl1 -= 100
		war.infl2 += 100
	var iran := w.get_country_by_legacy_index(8)
	if iran != null and iran.government == GameConstants.Government.AUTHORITARIAN:
		war.infl1 -= 50
		war.infl2 += 50
	if d.afghan_war_path == 9:
		war.infl1 += 25
		war.infl2 -= 25


# ============================================================================
# 土耳其危机战争结算（GameState.cs:630-695，Event370 启动的 10/11/12 号战争）
# ============================================================================

## GameState.cs:630-695 WarResult 的 10/11/12 分支：
##   war10 叙利亚、war11 伊拉克、war12 伊朗；infl1>=700 → 土耳其傀儡化，
##   否则 data.turkish_pan_turkic_chain++（后续 Event372/外交入口 94 的状态链）。
static func _apply_turkey_crisis_war_result(war_id: int, war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null:
		return
	if war.infl1 >= 700:
		match war_id:
			10:
				# GameState.cs:631-641：叙利亚
				var syria := w.get_country_by_legacy_index(35)
				var turkey10 := w.get_country_by_legacy_index(84)
				if syria != null:
					syria.government = GameConstants.Government.AUTHORITARIAN
					syria.sub_government = GameConstants.SubGovernment.NEO_FASCIST
					_leave_alliances(syria)
					syria.puppet_of = 84
				if turkey10 != null and turkey10.has_tag("亲美"):
					if syria != null:
						_set_pro_american(syria)
			11:
				# GameState.cs:651-674：伊拉克
				var iraq := w.get_country_by_legacy_index(14)
				if iraq != null:
					iraq.government = GameConstants.Government.AUTHORITARIAN
					iraq.sub_government = GameConstants.SubGovernment.NEO_FASCIST
					if d.size() > 117:
						d.iraq_development_sentinel = 0
					_leave_alliances(iraq)
					iraq.puppet_of = 84
					iraq.name = "Iraq"
					if iraq.has_tag("亲美"):
						_set_pro_american(iraq)
			12:
				# GameState.cs:676-695：伊朗
				var iran := w.get_country_by_legacy_index(8)
				if iran != null:
					iran.government = GameConstants.Government.AUTHORITARIAN
					if d.size() > 117:
						d.iraq_development_sentinel = 0
					iran.sub_government = GameConstants.SubGovernment.NEO_FASCIST
					_leave_alliances(iran)
					iran.puppet_of = 84
					if iran.has_tag("亲美"):
						_set_pro_american(iran)
	else:
		# GameState.cs:640 / 674 / 694：土耳其方影响力不足 → data.turkish_pan_turkic_chain++
		if d.size() > 124:
			d.turkish_pan_turkic_chain += 1


## 两伊战争结算（GameState.cs:216-470 的 data.war_resolve==3 分支）。
## 只移植国家政权/势力/附庸状态与全局数值效果；长文本不移植。
static func _apply_iran_iraq_war_result(war: WarData, d: WorldState) -> void:
	var w: WorldState = current_world
	if w == null or war == null:
		return
	var iran := w.get_country_by_legacy_index(8)
	var iraq := w.get_country_by_legacy_index(14)
	if iraq != null and (iraq.sub_government == GameConstants.SubGovernment.SOCIAL_DEMOCRAT or iraq.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN) \
			and iraq.puppet_of < 0:
		# GameState.cs:218-221：伊拉克新政府提出停战，无状态变化。
		return
	if war.infl1 >= 900:
		# GameState.cs:223-305：伊朗方/伊拉克方胜利的政权分支。
		if iran != null and w.is_socialism(iran, true):
			iran.prc_power = 1000
			iran.social_stability = 1000
		elif iraq != null and iraq.sub_government == GameConstants.SubGovernment.MARXIST_LENINIST:
			# GameState.cs:239-262
			if iran != null:
				iran.government = GameConstants.Government.SOCIALIST
				iran.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				iran.chinese_name = "伊朗人民民主共和国"
				_leave_alliances(iran)
				iran.set_tag("对华贸易", true)
				iran.set_tag("亲中", true)
				iran.prc_power = 1000
				iran.social_stability = 1000
			w.set_flag("iranrev", false)
			_stop_war_33()
			# GameState.cs:257-262：伊拉克原为伊朗附庸 → 随伊朗新政体解放并同步政体。
			if iraq != null and iran != null and iraq.puppet_of == 8:
				iraq.puppet_of = GameConstants.LegacySlot.NONE
				iraq.government = iran.government
				iraq.sub_government = iran.sub_government
		elif iraq != null and iraq.sub_government == GameConstants.SubGovernment.SOVIET_STYLE:
			# GameState.cs:264-281
			if iran != null:
				iran.government = GameConstants.Government.SOCIALIST
				iran.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				iran.chinese_name = "伊朗人民共和国"
				iran.prc_power = 1000
				iran.social_stability = 1000
				_leave_alliances(iran)
				iran.set_tag("对华贸易", true)
				iran.set_tag("亲苏", true)
			w.set_flag("iranrev", false)
			# GameState.cs:276-281：伊拉克原为伊朗附庸 → 随伊朗新政体解放并同步政体。
			if iraq != null and iran != null and iraq.puppet_of == 8:
				iraq.puppet_of = GameConstants.LegacySlot.NONE
				iraq.government = iran.government
				iraq.sub_government = iran.sub_government
		else:
			# GameState.cs:271-305：伊拉克仆从国伊朗。
			add_empire_power(EmpireData.USSR, 10)
			if iraq != null:
				if iraq.parts.size() > 5 and iraq.parts[5]:
					iraq.parts[5] = false
					if iraq.parts.size() <= 6:
						iraq.parts.resize(7)
					iraq.parts[6] = true
				else:
					if iraq.parts.size() <= 4:
						iraq.parts.resize(5)
					iraq.parts[4] = true
			if iran != null:
				iran.government = GameConstants.Government.AUTHORITARIAN
				iran.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				iran.set_tag("对华贸易", true)
				_leave_alliances(iran)
				iran.puppet_of = GameConstants.LegacySlot.IRAQ
				iran.chinese_name = "伊朗民主伊斯兰共和国"
				iran.prc_power = 1000
				iran.social_stability = 1000
			w.set_flag("iranrev", false)
		return
	# GameState.cs:307-470：infl1<900。
	if iran != null and w.is_socialism(iran, true):
		iran.prc_power = 1000
		iran.social_stability = 1000
	elif iraq != null and w.is_socialism(iraq, true):
		# GameState.cs:365-387：伊拉克伊斯兰共和国（伊朗傀儡）。
		iraq.government = GameConstants.Government.AUTHORITARIAN
		iraq.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
		iraq.set_tag("对华贸易", false)
		_leave_alliances(iraq)
		iraq.puppet_of = 8
		iraq.chinese_name = "伊拉克"
		w.oil_prod += 100.0  # GameState.cs:4669：伊拉克油田权益
		if d.size() > 117:
			d.iraq_development_sentinel = 9
	else:
		# GameState.cs:388-400：伊拉克世俗伊朗傀儡。
		if iraq != null:
			iraq.government = GameConstants.Government.AUTHORITARIAN
			iraq.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			iraq.set_tag("对华贸易", false)
			iraq.set_tag("亲苏", false)
			_leave_alliances(iraq)
			iraq.puppet_of = 8
			iraq.chinese_name = "伊拉克"
		if d.size() > 117:
			d.iraq_development_sentinel = 9
		if w.wars.size() > 88 and w.wars[88] != null and w.wars[88].is_going:
			w.wars[88].infl1 = 1000
			w.wars[88].infl2 = 0
			w.wars[88].is_going = false


## 停掉战争 33（伊朗革命战争），结果记伊朗方胜利（GameState.cs:250-254）。
static func _stop_war_33() -> void:
	var w: WorldState = current_world
	if w == null or w.wars.size() <= 33 or w.wars[33] == null:
		return
	if w.wars[33].is_going:
		w.wars[33].is_going = false
		w.wars[33].infl1 = 1000
		w.wars[33].infl2 = 0


## Country.LeaveAlliances()（Country.cs:89-115）→ WorldFactory.START_CLEAR_TAGS
static func _leave_alliances(country: CountryData) -> void:
	if country == null:
		return
	for t in WF.START_CLEAR_TAGS:
		country.tags.erase(t)
	country.puppet_of = GameConstants.LegacySlot.NONE


## Country.EstablishGovernment(Government.ProAmerican)（Country.cs:11-15）：
## 仅清亲中/亲苏、置亲美，不动 Gosstroy/SubGosstroy。
static func _set_pro_american(country: CountryData) -> void:
	if country == null:
		return
	country.set_tag("亲中", false)
	country.set_tag("亲苏", false)
	country.set_tag("亲美", true)


static func _set_pro_china(country: CountryData) -> void:
	if country == null:
		return
	country.set_tag("亲中", true)
	country.set_tag("亲苏", false)
	country.set_tag("亲美", false)


static func _set_pro_soviet(country: CountryData) -> void:
	if country == null:
		return
	country.set_tag("亲中", false)
	country.set_tag("亲苏", true)
	country.set_tag("亲美", false)


# ============================================================================
# 内部辅助
# ============================================================================


static func add_empire_power(empire_index: int, delta: int) -> void:
	var w: WorldState = current_world
	if empire_index >= 0 and empire_index < w.empires.size() and w.empires[empire_index] != null:
		w.empires[empire_index].power = clampi(w.empires[empire_index].power + delta, 0, 1000)
