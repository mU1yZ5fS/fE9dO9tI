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
const WF = preload("res://数据脚本/world_factory.gd")


# ============================================================================
# 月度/双周循环
# ============================================================================

## 月度：军事介入点积累（TimeScript 月块）
static func monthly_war_points() -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	var d := w.数值表
	@warning_ignore("integer_division")
	d[W.I_MIL_INTERVENTION] += d[W.I_PROJECTION] / 50
	var any_war := false
	for war in w.wars:
		if war != null and war.is_going:
			any_war = true
			break
	if any_war:
		@warning_ignore("integer_division")
		d[W.I_MIL_INTERVENTION] += d[W.I_INFLUENCE] / 12


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
		clamp_war_infl(war)


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
			if war.ussr_side == 1:
				war.infl1 -= 50
				war.infl2 += 50
			if w.数值表.size() > W.I_AFGHAN_POLICY:
				var pol: int = w.数值表[W.I_AFGHAN_POLICY]
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
			if war.usa_side == 0 or (turkey != null and turkey.has_tag("nato")):
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


## 每日：战争达结算条件 → 记录待结算战争并触发战争结束事件
static func check_war_endings() -> void:
	var w: WorldState = GameManager.world
	if w == null or GameManager.current_event_id != "":
		return
	if w.数值表.size() <= W.I_WAR_RESOLVE:
		return
	if w.数值表[W.I_WAR_RESOLVE] >= 0:
		return
	for i in w.wars.size():
		var war: WarData = w.wars[i]
		if war == null or not war.is_going:
			continue
		var by_time := war.fortnight_max >= 0 and war.fortnight_elapsed >= war.fortnight_max
		var by_infl := war.infl1 >= 1000 or war.infl2 >= 1000
		if by_time or by_infl:
			w.数值表[W.I_WAR_RESOLVE] = i
			GameManager.start_event("war_is_over")
			GameManager._notify_stats()
			return


# ============================================================================
# 查询 API
# ============================================================================

static func get_active_wars() -> Array[WarData]:
	var out: Array[WarData] = []
	var w: WorldState = GameManager.world
	if w == null:
		return out
	for war in w.wars:
		if war != null and war.is_going:
			out.append(war)
	return out


static func get_mil_intervention_display() -> String:
	var w: WorldState = GameManager.world
	if w == null:
		return "0.0"
	return "%.1f" % (float(w.数值表[W.I_MIL_INTERVENTION]) / 10.0)


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
	var w: WorldState = GameManager.world
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
		war.usa_side = usa_side if usa_side >= 0 else def.default_usa_side
		war.ussr_side = ussr_side if ussr_side >= 0 else def.default_ussr_side
		war.fortnight_max = def.fortnight_max
	else:
		war.name_war = "战争 #%d" % war_id
		war.side1 = side1 if side1 != "" else "side1"
		war.side2 = side2 if side2 != "" else "side2"
		war.infl1 = infl1 if infl1 >= 0 else 500
		war.infl2 = infl2 if infl2 >= 0 else 500
		war.usa_side = usa_side if usa_side >= 0 else 0
		war.ussr_side = ussr_side if ussr_side >= 0 else 0
	war.fortnight_elapsed = 0
	war.diplo_done = [false, false]
	clamp_war_infl(war)
	GameManager._notify_stats()
	return true


## 干预动作是否可用（战争界面按钮置灰用）
static func can_intervene(war_id: int, action_id: int) -> bool:
	var w: WorldState = GameManager.world
	if w == null:
		return false
	if war_id < 0 or war_id >= w.wars.size():
		return false
	var war: WarData = w.wars[war_id]
	if war == null or not war.is_going:
		return false
	var d := w.数值表
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
		if w.war_state == 1 and war_id == 1:
			return false

	# 非外交动作：data[0]（军事介入点）须 >= 10*中国不稳定度/10（即 >= level_of_instability）
	if d[W.I_MIL_INTERVENTION] < china_unstab:
		return false

	# 资源门槛按原版 CheckButtonAvailable（注意 1/4 门槛是 20，但效果扣 30，原版允许负数）
	match action_id:
		0, 5:
			return d[W.I_BUDGET] + d[W.I_RESERVE] >= 20
		1, 4:
			return d[W.I_AGENTS] >= 20
		2, 6:
			return d[W.I_ARMY] >= 30
	return false


## 执行干预动作（扣资源 + 改变战争态势/关系）
## 逐项对齐 WarButtonScript.OnMouseDown：成本/关系/科技/事件加成/党内支持消耗。
static func intervene_war(war_id: int, action_id: int) -> bool:
	if not can_intervene(war_id, action_id):
		return false
	var w: WorldState = GameManager.world
	var war: WarData = w.wars[war_id]
	var d := w.数值表
	var china := w.get_country_by_legacy_index(1)
	var side := 1 if action_id <= 3 else 2

	# ── 扣资源与基础战争态势 ──
	match action_id:
		0, 5:
			d[W.I_BUDGET] -= 20
			_war_apply_human_aid(war, side)
			_war_apply_pmc(war, side)
		1, 4:
			d[W.I_AGENTS] -= 30
			_war_apply_base(war, side, 30)
			_war_apply_science24(war, side)
			_war_apply_pmc(war, side)
			_war_apply_event548(war, side, 10, 30)
		2, 6:
			d[W.I_ARMY] -= 30
			d[W.I_BUDGET] += 3
			_war_apply_base(war, side, 30 if not _war_science23(w) else 40)
			_war_apply_event517(war, side)
			_war_apply_event521(war, side)
			_war_apply_event548_2(war, side)
			_war_apply_pmc(war, side)
		3, 7:
			_war_apply_diplo(war, side)
			_war_apply_event548_diplo(war, side)
			war.diplo_done[side - 1] = true
			clamp_war_infl(war)
			GameManager._mirror_empires_to_data(w)
			GameManager._notify_stats()
			return true

	# 非外交动作共有的敌对帝国关系惩罚
	_war_apply_enemy_relation(war, side, -5)
	# 非外交动作共有的党内支持消耗与不稳定度增加
	_war_apply_party_cost(w, d, china)
	clamp_war_infl(war)
	GameManager._mirror_empires_to_data(w)
	GameManager._notify_stats()
	return true


# ============================================================================
# 战争支援辅助（原版 WarButtonScript.OnMouseDown 逐段）
# ============================================================================

## 基础增援：side 方 +delta，对方 -delta
static func _war_apply_base(war: WarData, side: int, delta: int) -> void:
	if side == 1:
		war.infl1 += delta
		war.infl2 -= delta
	else:
		war.infl2 += delta
		war.infl1 -= delta


## 人力增援（0/5）：无事件548时基础 +20/-20；事件548 result1 +30/-30、result2 +50/-50，
## result0 时无额外变化（原版 if/else if 链）。
static func _war_apply_human_aid(war: WarData, side: int) -> void:
	var w := GameManager.world
	if not w.event_done_num(548):
		_war_apply_base(war, side, 20)
		return
	var r := w.result_of_event_num(548)
	if r == 1:
		_war_apply_base(war, side, 30)
	elif r == 2:
		_war_apply_base(war, side, 50)


## 事件548：result 1 → +30/-30，result 2 → +50/-50（用于 0/5）
static func _war_apply_event548(war: WarData, side: int, delta_r1: int, delta_r2: int) -> void:
	if not GameManager.world.event_done_num(548):
		return
	var r := GameManager.world.result_of_event_num(548)
	if r == 1:
		_war_apply_base(war, side, delta_r1)
	elif r == 2:
		_war_apply_base(war, side, delta_r2)


## 事件548：仅 result 2 时 +20/-20（用于 2/6）
static func _war_apply_event548_2(war: WarData, side: int) -> void:
	if GameManager.world.event_done_num(548) and GameManager.world.result_of_event_num(548) == 2:
		_war_apply_base(war, side, 20)


## 事件548：外交声援 result 1 → +110/-110，result 2 → +140/-140
static func _war_apply_event548_diplo(war: WarData, side: int) -> void:
	# 原版：事件548未完成 → +80/-80；已完成且 result1/2 → +110/-110、+140/-140；
	# 已完成但 result0 → 不加（if/else if 链）。
	if not GameManager.world.event_done_num(548):
		_war_apply_base(war, side, 80)
		return
	var r := GameManager.world.result_of_event_num(548)
	if r == 1:
		_war_apply_base(war, side, 110)
	elif r == 2:
		_war_apply_base(war, side, 140)


## 科技24（专家）：+10/-10
static func _war_apply_science24(war: WarData, side: int) -> void:
	var w := GameManager.world
	if w != null and w.techs != null and w.techs.unlocked.size() > 24 and w.techs.unlocked[24]:
		_war_apply_base(war, side, 10)


## 科技23（武器）：true 时基础增援用 40，否则 30
static func _war_science23(w: WorldState) -> bool:
	return w != null and w.techs != null and w.techs.unlocked.size() > 23 and w.techs.unlocked[23]


## 事件517：result 0/1 → +10/-10，result 2 → +20/-20
static func _war_apply_event517(war: WarData, side: int) -> void:
	var w := GameManager.world
	if not w.event_done_num(517):
		return
	var r := w.result_of_event_num(517)
	if r == 0 or r == 1:
		_war_apply_base(war, side, 10)
	elif r == 2:
		_war_apply_base(war, side, 20)


## 事件521：result 1 → +10/-10，result 2 → +20/-20
static func _war_apply_event521(war: WarData, side: int) -> void:
	var w := GameManager.world
	if not w.event_done_num(521):
		return
	var r := w.result_of_event_num(521)
	if r == 1:
		_war_apply_base(war, side, 10)
	elif r == 2:
		_war_apply_base(war, side, 20)


## PMC > 0：+20/-20
static func _war_apply_pmc(war: WarData, side: int) -> void:
	if GameManager.world != null and GameManager.world.pmc > 0:
		_war_apply_base(war, side, 20)


## 非外交动作：对敌方阵营帝国关系 -5（side1 的敌人在 usa_place==1/ussr_place==1）
static func _war_apply_enemy_relation(war: WarData, side: int, delta: int) -> void:
	var w := GameManager.world
	if side == 1:
		if war.usa_side == 1 and w.empires.size() > 0:
			w.empires[0].relations += delta
		if war.ussr_side == 1 and w.empires.size() > 1:
			w.empires[1].relations += delta
	else:
		if war.usa_side == 0 and w.empires.size() > 0:
			w.empires[0].relations += delta
		if war.ussr_side == 0 and w.empires.size() > 1:
			w.empires[1].relations += delta


## 外交声援：友方阵营帝国关系 +30
static func _war_apply_diplo(war: WarData, side: int) -> void:
	var w := GameManager.world
	if side == 1:
		if war.usa_side == 0 and w.empires.size() > 0:
			w.empires[0].relations += 30
		if war.ussr_side == 0 and w.empires.size() > 1:
			w.empires[1].relations += 30
	else:
		if war.usa_side == 1 and w.empires.size() > 0:
			w.empires[0].relations += 30
		if war.ussr_side == 1 and w.empires.size() > 1:
			w.empires[1].relations += 30


## 事件545 分档的党内支持（军事介入点 data[0]）消耗；结束后中国不稳定度 +8。
static func _war_apply_party_cost(w: WorldState, d: Array[int], china: CountryData) -> void:
	if china == null:
		return
	var unstab := china.level_of_instability
	var mult := 10
	if w.event_done_num(545):
		var r := w.result_of_event_num(545)
		if r == 0:
			mult = 8
		elif r == 2:
			mult = 5
	@warning_ignore("integer_division")
	var cost := mult * unstab / 10
	if d.size() > W.I_MIL_INTERVENTION:
		d[W.I_MIL_INTERVENTION] -= cost
	china.level_of_instability += 8


# ============================================================================
# 结算
# ============================================================================

## 战争结束事件关闭后执行结算（GameManager.clear_event 调用）
static func resolve_war_finished(war_id: int = -1) -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	var id := war_id
	if id < 0:
		id = w.数值表[W.I_WAR_RESOLVE]
	if id >= 0 and id < w.wars.size() and w.wars[id] != null:
		var restarted := apply_war_result(id)
		w.wars[id].is_going = restarted
	w.数值表[W.I_WAR_RESOLVE] = -10
	GameManager._notify_stats()


## 返回 true 表示原战争结算后立即进入第二阶段（阿富汗战争专用）。
static func apply_war_result(war_id: int) -> bool:
	var w: WorldState = GameManager.world
	if w == null or war_id < 0 or war_id >= w.wars.size():
		return false
	var war: WarData = w.wars[war_id]
	if war == null:
		return false
	var d := w.数值表
	d[W.I_MIL_INTERVENTION] = 0
	# 土耳其危机战争链（Event370 启动 10/11/12）走原版 GameState.cs WarResult
	# 的独立阈值结算：infl1 >= 700 即土耳其方获胜，与通用 infl1>=1000 不同。
	if war_id == 10 or war_id == 11 or war_id == 12:
		_apply_turkey_crisis_war_result(war_id, war, d)
		GameManager._mirror_empires_to_data(w)
		return false
	# 两伊战争（war3）走原版 GameState.cs:216-470 的伊朗/伊拉克政权结算，
	# 不再落入通用 side1/side2/draw 分支。
	if war_id == 3:
		_apply_iran_iraq_war_result(war, d)
		GameManager._mirror_empires_to_data(w)
		return false
	# 5/19/23/25/26/30/31/32 号战争走 GameState.WarResult 的专属阈值结算。
	if _is_achievement_war_result(war_id):
		var achievement_restarted := _apply_achievement_war_result(war_id, war, d)
		GameManager._mirror_empires_to_data(w)
		return achievement_restarted
	# 珍宝岛/中南半岛/朝鲜/印度/台海/日本方向等战争走 GameState.WarResult 的 950 阈值：
	# infl1>=950 → side1 胜利（胜利特效暂按通用 side1 处理，待补）；
	# 否则 → 立即触发失败结局（GameState.cs:3742/3813/3846/3917/3978/4007/4821）。
	if _is_war_result_route(war_id):
		if war.infl1 >= 950:
			apply_war_side1_victory(war_id, war, d)
		else:
			_apply_war_result_defeat(war_id, d)
		GameManager._mirror_empires_to_data(w)
		return false
	var restarted := false
	if war.infl1 >= 1000:
		restarted = apply_war_side1_victory(war_id, war, d)
	elif war.infl2 >= 1000:
		restarted = apply_war_side2_victory(war_id, war, d)
	else:
		apply_war_draw(war_id, war, d)
	GameManager._mirror_empires_to_data(w)
	return restarted


## WarResult 专属阈值战争（GameState.cs 各 data[82]==N 分支，含绑定成就）。
static func _is_achievement_war_result(war_id: int) -> bool:
	return war_id == 5 or war_id == 19 or war_id == 23 or war_id == 25 \
		or war_id == 26 or war_id == 30 or war_id == 31 or war_id == 32


static func _wc(w: WorldState, idx: int) -> CountryData:
	return w.get_country_by_legacy_index(idx)


static func _dval(d: Array, idx: int) -> int:
	return d[idx] if d.size() > idx else 0


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


static func _apply_achievement_war_result(war_id: int, war: WarData, d: Array[int]) -> bool:
	var w: WorldState = GameManager.world
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
static func _war5_result(w: WorldState, war: WarData, d: Array[int]) -> bool:
	var afg := _wc(w, 12)
	if war.infl1 >= 900:
		if war.ussr_side == 0:
			add_empire_power(EmpireData.USSR, 50)
		elif war.ussr_side == -1:
			if afg != null:
				afg.government = 1
				afg.sub_government = 1
				afg.set_tag("亲苏", false)
				afg.set_tag("亲中", true)
				afg.set_tag("对华贸易", true)
				afg.prc_power = 1000
			if d.size() > W.I_INFLUENCE:
				d[W.I_INFLUENCE] += 100
		elif war.ussr_side == 1:
			if afg != null:
				afg.government = 1
				afg.sub_government = 17
				afg.set_tag("亲苏", false)
				afg.set_tag("亲中", true)
				afg.set_tag("对华贸易", true)
				afg.prc_power = 1000
			if d.size() > W.I_INFLUENCE:
				d[W.I_INFLUENCE] += 100
			# GameState.cs:446-448
			Achievements.set_achievement(54)
	elif war.ussr_side == 1:
		# 第二阶段重启（GameState.cs:452-477）
		war.name_war = "阿 富 汗 内 战"
		war.is_going = true
		war.side1 = "阿 富 汗 民 主 共 和 国"
		war.side2 = "圣 战 者"
		war.ussr_side = 0
		war.usa_side = 1
		war.infl1 = 650
		war.infl2 = 350
		var c31 := _wc(w, 31)
		if c31 != null and c31.has_tag("亲美"):
			war.infl1 -= 100
			war.infl2 += 100
		var c8 := _wc(w, 8)
		if c8 != null and c8.government == 0:
			war.infl1 -= 50
			war.infl2 += 50
		if d.size() > 107 and d[107] == 9:
			war.infl1 += 25
			war.infl2 -= 25
		clamp_war_infl(war)
		return true
	else:
		if afg != null:
			afg.government = 0
			afg.sub_government = 13
			afg.set_tag("亲苏", false)
			afg.set_tag("亲中", false)
			afg.set_tag("对华贸易", false)
		add_empire_power(EmpireData.USSR, -30)
	return false


## GameState.cs:1062-1134 —— 阿尔巴尼亚-希腊战争。
static func _war19_result(w: WorldState, war: WarData, d: Array[int]) -> void:
	var alb := _wc(w, 20)
	var greece := _wc(w, 45)
	if war.infl1 >= 900:
		if alb != null and alb.has_tag("亲中") and d.size() > W.I_INFLUENCE:
			d[W.I_INFLUENCE] -= 100
		if alb != null:
			if alb.parts.size() > 1:
				alb.parts[1] = true
			if alb.parts.size() > 0:
				alb.parts[0] = false
			alb.leave_alliances()
			alb.set_tag("亲中", false)
			alb.set_tag("对华贸易", false)
			alb.name = "大 阿 尔 巴 尼 亚"
			alb.government = 0
			alb.sub_government = 10
		if greece != null:
			greece.set_tag("对华贸易", false)
			greece.government = 0
			greece.sub_government = 7
			var usa := _wc(w, 51)
			if usa != null and usa.has_tag("nato"):
				greece.set_tag("nato", true)
		# GameState.cs:1078-1081
		Achievements.set_achievement(133)
	elif war.infl2 >= 700:
		if alb != null:
			alb.leave_alliances()
			alb.set_tag("亲中", false)
			alb.set_tag("对华贸易", false)
			alb.government = 0
			alb.sub_government = 10
		var c51 := _wc(w, 51)
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
static func _war23_result(w: WorldState, war: WarData, d: Array[int]) -> void:
	var italy := _wc(w, 85)
	var c87 := _wc(w, 87)
	if not w.event_done_num(556):
		if war.infl1 >= 900:
			if d.size() > W.I_INFLUENCE:
				d[W.I_INFLUENCE] += 50
			add_empire_power(EmpireData.USA, -50)
			if italy != null:
				italy.name = "意 大 利 人 民 国"
			# GameState.cs:1259-1262
			Achievements.set_achievement(123)
			if c87 != null:
				c87.special -= 20
			if italy != null:
				italy.leave_alliances()
				italy.establish_government(2)
				italy.set_tag("对华贸易", true)
				italy.government = 0
				italy.sub_government = 10
		else:
			add_empire_power(EmpireData.USA, 50)
			if d.size() > W.I_INFLUENCE:
				d[W.I_INFLUENCE] -= 50
			if italy != null:
				italy.government = 0
				italy.sub_government = 20
			if d.size() > 134:
				d[134] = 0
			if italy != null:
				italy.内战中 = false
				italy.政变中 = false
	elif war.infl1 >= 900:
		if d.size() > W.I_INFLUENCE:
			d[W.I_INFLUENCE] += 50
		add_empire_power(EmpireData.USA, -50)
		_add_empire_rel(w, 0, -250)
		_add_empire_rel(w, 1, -50)
		if c87 != null:
			c87.special -= 20
		if italy != null:
			italy.leave_alliances()
			italy.establish_government(2)
			italy.set_tag("对华贸易", true)
			if d.size() > 184 and d[184] == 1:
				italy.government = 0
				italy.sub_government = 0
				italy.name = "意 大 利 苏 维 埃 联 邦"
			elif d.size() > 184 and d[184] == 2:
				italy.government = 1
				italy.sub_government = 2
				italy.name = "意 大 利 苏 维 埃 共 和 国"
			else:
				italy.government = 1
				italy.sub_government = 17
				italy.name = "意 大 利 社 会 主 义 共 和 国"
	else:
		add_empire_power(EmpireData.USA, 20)
		if d.size() > W.I_INFLUENCE:
			d[W.I_INFLUENCE] -= 15
		_add_empire_rel(w, 0, -150)
		if italy != null:
			italy.government = 0
			italy.sub_government = 20
			italy.leave_alliances()
			italy.set_tag("亲美", true)
		var c0 := _wc(w, 0)
		if c0 != null and italy != null:
			if c0.has_tag("eu"):
				italy.set_tag("eu", true)
			if c0.has_tag("nato"):
				italy.set_tag("nato", true)
		if d.size() > 134:
			d[134] = 0
		if italy != null:
			italy.内战中 = false
			italy.政变中 = false


## GameState.cs:1362-1387 —— 埃塞俄比亚方向。
static func _war25_result(w: WorldState, d: Array[int]) -> void:
	if d.size() <= W.I_WAR_RESOLVE:
		return
	var war := _war_at(w, d[W.I_WAR_RESOLVE])
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
			c100.government = 2
			c100.sub_government = 15
			c100.social_stability = 1000
			c100.influence_china = 500
			c100.influence_nato = 500
		if d.size() > W.I_INFLUENCE:
			d[W.I_INFLUENCE] += 5
		add_empire_power(EmpireData.USSR, -5)
	else:
		var c100 := w.get_country_by_legacy_index(100)
		if c100 != null and c100.parts.size() > 0:
			c100.parts[0] = false


## GameState.cs:1388-1424 —— 索马里方向。
static func _war26_result(w: WorldState, d: Array[int]) -> void:
	if d.size() <= W.I_WAR_RESOLVE:
		return
	var war := _war_at(w, d[W.I_WAR_RESOLVE])
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
			c99.government = 2
			c99.sub_government = 15
			if not w.event_done_num(434):
				c99.influence_china = 500
				c99.social_stability = 1000
				c99.influence_nato = 500
				c99.establish_government(2)
			if not w.event_done_num(434) \
					or (w.event_done_num(434) and w.result_of_event_num(434) >= 2):
				if d.size() > W.I_INFLUENCE:
					d[W.I_INFLUENCE] += 15
		add_empire_power(EmpireData.USSR, -15)
	else:
		var c99 := w.get_country_by_legacy_index(99)
		if c99 != null:
			if c99.parts.size() > 0:
				c99.parts[0] = false
			c99.puppet_of = -1
		if w.event_done_num(434) and w.result_of_event_num(434) == 1:
			var c41 := w.get_country_by_legacy_index(41)
			if c41 != null:
				c41.set_tag("对华贸易", true)


## GameState.cs:1627-1730 —— 西班牙内战。
static func _war30_result(w: WorldState, war: WarData, _d: Array[int]) -> bool:
	var spain := _wc(w, 86)
	if war.infl1 >= 800:
		_war_going_set(w, 31, false)
		_war_going_set(w, 32, false)
		if w.result_of_event_num(426) == 3 and spain != null:
			spain.government = 1
			spain.sub_government = 1
			spain.leave_alliances()
			spain.set_tag("亲中", true)
			spain.set_tag("对华贸易", true)
			spain.name = "西 班 牙 联 邦"
		elif w.result_of_event_num(426) == 4 and spain != null:
			spain.government = 2
			spain.sub_government = 11
			spain.leave_alliances()
			spain.name = "西 班 牙 人 民 联 合 王 国"
		elif spain != null:
			spain.name = "西 班 牙 共 和 国"
	elif war.infl2 >= 800:
		if w.result_of_event_num(426) == 4:
			# 第二阶段重启（GameState.cs:1665-1677）
			war.name_war = "西 班 牙 内 战 第 二 阶 段"
			war.is_going = true
			war.ussr_side = -1
			war.usa_side = -1
			war.infl1 = 300
			war.infl2 = 700
			clamp_war_infl(war)
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
				spain.name = "长 枪 党 西 班 牙"
				spain.government = 0
				spain.sub_government = 7
	else:
		if spain != null:
			spain.government = 2
			spain.sub_government = 14
	return false


## GameState.cs:1731-1747。
static func _war31_result(w: WorldState, d: Array[int]) -> void:
	if d.size() <= W.I_WAR_RESOLVE:
		return
	var war := _war_at(w, d[W.I_WAR_RESOLVE])
	var spain := w.get_country_by_legacy_index(86)
	if war != null and war.infl1 >= 900:
		if spain != null and spain.parts.size() > 1 and spain.parts[1] \
				and not _war_going(w, 32):
			Achievements.set_achievement(151)
	else:
		if spain != null and spain.parts.size() > 0:
			spain.parts[0] = false
		var c109 := w.get_country_by_legacy_index(109)
		if c109 != null:
			c109.set_tag("对华贸易", false)


## GameState.cs:1748-1764。
static func _war32_result(w: WorldState, d: Array[int]) -> void:
	if d.size() <= W.I_WAR_RESOLVE:
		return
	var war := _war_at(w, d[W.I_WAR_RESOLVE])
	var spain := w.get_country_by_legacy_index(86)
	if war != null and war.infl1 >= 900:
		if spain != null and spain.parts.size() > 0 and spain.parts[0] \
				and not _war_going(w, 31):
			Achievements.set_achievement(151)
	else:
		if spain != null and spain.parts.size() > 1:
			spain.parts[1] = false
		var c110 := w.get_country_by_legacy_index(110)
		if c110 != null:
			c110.set_tag("对华贸易", false)


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


static func _apply_war_result_defeat(war_id: int, d: Array[int]) -> void:
	# 原版失败分支统一前置效果（GameState.cs 各 else 分支）：
	# data[1]=0; data[3]=0; influencePRC -= 200; 然后直接 LoadScene("Ending")。
	if d.size() > W.I_PARTY_SUPPORT:
		d[W.I_PARTY_SUPPORT] = 0
	if d.size() > W.I_PEOPLE_SUPPORT:
		d[W.I_PEOPLE_SUPPORT] = 0
	if d.size() > W.I_INFLUENCE:
		d[W.I_INFLUENCE] -= 200
	var ending := _war_result_defeat_ending(war_id)
	if ending >= 0:
		GameManager.trigger_ending(ending)


## 珍宝岛/中南半岛/朝鲜/印度/台海/日本方向胜利特效（GameState.WarResult 胜利分支，
## 不含 text 文案；ILoveSuckCocks 地图刷新按项目惯例近似省略）。
static func _route_victory_effects(w: WorldState, war_id: int, d: Array[int]) -> void:
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


static func _war70_victory(w: WorldState, d: Array[int]) -> void:
	if not w.event_done_num(642):
		w.set_flag("is_gkchp", true)
		var c7 := _wc(w, 7)
		if c7 != null:
			c7.government = 0
			c7.sub_government = 10
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
		var c9 := _wc(w, 9)
		if c9 != null:
			c9.leave_alliances()
		var c7 := _wc(w, 7)
		if c7 != null:
			c7.government = 2
			c7.sub_government = 21
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


static func _war71_victory(w: WorldState, d: Array[int]) -> void:
	var c33 := _wc(w, 33)
	if c33 != null:
		if c33.parts.size() > 0:
			c33.parts[0] = false
		if c33.parts.size() > 1:
			c33.parts[1] = false
	var c23 := _wc(w, 23)
	if c23 != null and c23.parts.size() > 0:
		c23.parts[0] = true
	_war_going_set(w, 82, false)
	var c11 := _wc(w, 11)
	if c11 != null and c11.parts.size() > 0:
		c11.parts[0] = false
	_puppet_to_china(w, 11, "交 趾", [])
	_puppet_to_china(w, 22, "老 挝", [])
	_puppet_to_china(w, 23, "柬 埔 寨", [])
	_puppet_to_china(w, 33, "", [])
	_puppet_to_china(w, 34, "暹 罗", [])
	_war_victory_common(w, d)
	_set_decision(w, 37, false)


static func _war72_victory(w: WorldState, d: Array[int]) -> void:
	_puppet_to_china(w, 10, "", [])
	_war_victory_common(w, d)
	_set_decision(w, 37, false)


static func _war73_victory(w: WorldState, d: Array[int]) -> void:
	_puppet_to_china(w, 47, "吕 宋 （ 军 管 区 ）", [])
	_puppet_to_china(w, 49, "南 洋 特 别 行 政 区 （ 军 管 区 ）", [0])
	_puppet_to_china(w, 50, "三 佛 齐 （ 军 管 区 ）", [0])
	_puppet_to_china(w, 128, "东 帝 汶 （ 军 管 区 ）", [])
	_puppet_to_china(w, 134, "昆 仑 （ 军 管 区 ）", [0])
	_war_victory_common(w, d)
	_set_decision(w, 37, false)


static func _war74_victory(w: WorldState, d: Array[int]) -> void:
	for idx in [19, 31, 32, 43, 171, 172, 173]:
		var c := _wc(w, idx)
		if c != null and c.parts.size() > 0:
			c.parts[0] = true
	var c19 := _wc(w, 19)
	if c19 != null:
		c19.name = "前 印 度 斯 坦 地 区"
	var c43 := _wc(w, 43)
	if c43 != null:
		c43.name = "大 尼 泊 尔"
	_wc_name(w, 97, "布 鲁 克 巴 （ 军 管 区 ）")
	_wc_name(w, 171, "哲 孟 雄 （ 军 管 区 ）")
	_wc_name(w, 172, "底 马 撒 （ 军 管 区 ）")
	_wc_name(w, 173, "翠 蓝 屿 （ 军 管 区 ）")
	for idx in [19, 31, 32, 43, 96, 97, 171, 172, 173]:
		_puppet_to_china(w, idx, "", [])
	_war_victory_common(w, d)
	_set_decision(w, 37, false)


static func _war75_victory(w: WorldState, d: Array[int]) -> void:
	_set_d(d, W.I_TAIWAN_STATUS, 2)
	_set_decision(w, 7, true)
	_war_victory_common(w, d)


static func _war90_victory(w: WorldState, d: Array[int]) -> void:
	var japan := _wc(w, 44)
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
	var c10 := _wc(w, 10)
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
static func _war_victory_common(w: WorldState, d: Array[int]) -> void:
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
	var c := _wc(w, idx)
	if c == null:
		return
	c.government = 0
	c.sub_government = 19
	c.leave_alliances()
	c.set_tag("对华贸易", true)
	c.establish_government(2)
	_join_all_our_alliances(w, c)
	c.puppet_of = 1
	if new_name != "":
		c.name = new_name
	for part in parts_set:
		var pi := int(part)
		if pi >= 0 and pi < c.parts.size():
			c.parts[pi] = true


static func _wc_name(w: WorldState, idx: int, new_name: String) -> void:
	var c := _wc(w, idx)
	if c != null:
		c.name = new_name


static func _join_all_our_alliances(w: WorldState, c: CountryData) -> void:
	var china := _wc(w, 1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)


static func _add_d(d: Array, idx: int, delta: int) -> void:
	if d.size() > idx:
		d[idx] += delta


static func _set_d(d: Array, idx: int, value: int) -> void:
	if d.size() > idx:
		d[idx] = value


static func _set_empire_rel(w: WorldState, idx: int, value: int) -> void:
	if w.empires.size() > idx and w.empires[idx] != null:
		w.empires[idx].relations = value


static func _set_decision(w: WorldState, idx: int, value: bool) -> void:
	if w.decisions != null and w.decisions.completed.size() > idx:
		w.decisions.completed[idx] = value


static func apply_war_side1_victory(war_id: int, war: WarData, d: Array[int]) -> bool:
	var w: WorldState = GameManager.world
	match war_id:
		0:
			var north := w.get_country_by_legacy_index(10)
			var south := w.get_country_by_legacy_index(46)
			if north != null and south != null:
				south.government = north.government
			d[W.I_INFLUENCE] += 50
			add_empire_power(EmpireData.USA, -40)
			d[W.I_KOREA_RESULT] = 1
		1:
			d[W.I_INFLUENCE] += 20
			d[W.I_PARTY_SUPPORT] += 100
			add_empire_power(EmpireData.USSR, -20)
		2:
			var thailand := w.get_country_by_legacy_index(34)
			if thailand != null:
				thailand.government = 1
				thailand.set_tag("亲中", true)
				thailand.set_tag("亲美", false)
			d[W.I_INFLUENCE] += 20
			add_empire_power(EmpireData.USA, -20)
		3:
			add_empire_power(EmpireData.USSR, 10)
		4:
			add_empire_power(EmpireData.USSR, -10)
			add_empire_power(EmpireData.USA, 20)
		5:
			if war.ussr_side == 0:
				add_empire_power(EmpireData.USSR, 50)
			else:
				var afghanistan := w.get_country_by_legacy_index(12)
				if afghanistan != null:
					afghanistan.government = 1
					afghanistan.set_tag("亲苏", false)
					afghanistan.set_tag("亲中", true)
					afghanistan.set_tag("对华贸易", true)
				d[W.I_INFLUENCE] += 100
		6:
			w.set_flag("britain_lost_falklands", true)
			add_empire_power(EmpireData.USA, -20)
		70, 71, 72, 73, 74, 75, 90:
			_route_victory_effects(w, war_id, d)
	return false


static func apply_war_side2_victory(war_id: int, war: WarData, d: Array[int]) -> bool:
	var w: WorldState = GameManager.world
	match war_id:
		0:
			var north := w.get_country_by_legacy_index(10)
			var south := w.get_country_by_legacy_index(46)
			if north != null and south != null:
				north.government = south.government
			d[W.I_INFLUENCE] -= 20
			add_empire_power(EmpireData.USSR, -20)
			add_empire_power(EmpireData.USA, 50)
			d[W.I_KOREA_RESULT] = 2
		1:
			var kampuchea := w.get_country_by_legacy_index(23)
			if kampuchea != null:
				kampuchea.government = 1
				kampuchea.set_tag("亲苏", true)
				kampuchea.set_tag("econ", false)
				kampuchea.set_tag("okb", false)
				kampuchea.set_tag("亲中", false)
				kampuchea.set_tag("对华贸易", false)
			d[W.I_INFLUENCE] -= 30
			add_empire_power(EmpireData.USSR, 10)
		2:
			d[W.I_INFLUENCE] -= 10
		3:
			var iraq := w.get_country_by_legacy_index(14)
			if iraq != null:
				iraq.government = 0
				iraq.set_tag("对华贸易", false)
				iraq.set_tag("亲苏", false)
		4:
			add_empire_power(EmpireData.USSR, 10)
			add_empire_power(EmpireData.USA, -20)
			w.set_flag("israel_lost_lebanon_war", true)
		5:
			if war.ussr_side == 0:
				var afghanistan := w.get_country_by_legacy_index(12)
				if afghanistan != null:
					afghanistan.government = 0
					afghanistan.set_tag("亲苏", false)
					afghanistan.set_tag("亲中", false)
					afghanistan.set_tag("对华贸易", false)
				add_empire_power(EmpireData.USSR, -30)
			else:
				restart_afghan_war(war, d)
				return true
		6:
			add_empire_power(EmpireData.USA, 20)
	return false


static func apply_war_draw(war_id: int, war: WarData, d: Array[int]) -> void:
	var w: WorldState = GameManager.world
	match war_id:
		2:
			d[W.I_INFLUENCE] -= 10
		4:
			add_empire_power(EmpireData.USSR, 10)
			add_empire_power(EmpireData.USA, -20)
			w.set_flag("israel_lost_lebanon_war", true)
		6:
			if war.infl1 >= 400:
				w.set_flag("britain_lost_falklands", true)
				add_empire_power(EmpireData.USA, -20)
			else:
				add_empire_power(EmpireData.USA, 20)


static func restart_afghan_war(war: WarData, d: Array[int]) -> void:
	var w: WorldState = GameManager.world
	war.name_war = "Afghan war"
	war.side1 = "DRA"
	war.side2 = "Mujahideen"
	war.ussr_side = 0
	war.usa_side = 1
	war.infl1 = 650
	war.infl2 = 350
	war.fortnight_elapsed = 0
	var pakistan := w.get_country_by_legacy_index(31)
	if pakistan != null and pakistan.has_tag("亲美"):
		war.infl1 -= 100
		war.infl2 += 100
	var iran := w.get_country_by_legacy_index(8)
	if iran != null and iran.government == 0:
		war.infl1 -= 50
		war.infl2 += 50
	if d[W.I_AFGHAN_WAR_PATH] == 9:
		war.infl1 += 25
		war.infl2 -= 25


# ============================================================================
# 土耳其危机战争结算（GameState.cs:630-695，Event370 启动的 10/11/12 号战争）
# ============================================================================

## GameState.cs:630-695 WarResult 的 10/11/12 分支：
##   war10 叙利亚、war11 伊拉克、war12 伊朗；infl1>=700 → 土耳其傀儡化，
##   否则 data[124]++（后续 Event372/外交入口 94 的状态链）。
static func _apply_turkey_crisis_war_result(war_id: int, war: WarData, d: Array[int]) -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	if war.infl1 >= 700:
		match war_id:
			10:
				# GameState.cs:631-641：叙利亚
				var syria := w.get_country_by_legacy_index(35)
				var turkey10 := w.get_country_by_legacy_index(84)
				if syria != null:
					syria.government = 0
					syria.sub_government = 9
					_leave_alliances(syria)
					syria.puppet_of = 84
				if turkey10 != null and turkey10.has_tag("亲美"):
					if syria != null:
						_set_pro_american(syria)
			11:
				# GameState.cs:651-674：伊拉克
				var iraq := w.get_country_by_legacy_index(14)
				if iraq != null:
					iraq.government = 0
					iraq.sub_government = 9
					if d.size() > 117:
						d[117] = 0
					_leave_alliances(iraq)
					iraq.puppet_of = 84
					iraq.name = "Iraq"
					if iraq.has_tag("亲美"):
						_set_pro_american(iraq)
			12:
				# GameState.cs:676-695：伊朗
				var iran := w.get_country_by_legacy_index(8)
				if iran != null:
					iran.government = 0
					if d.size() > 117:
						d[117] = 0
					iran.sub_government = 9
					_leave_alliances(iran)
					iran.puppet_of = 84
					if iran.has_tag("亲美"):
						_set_pro_american(iran)
	else:
		# GameState.cs:640 / 674 / 694：土耳其方影响力不足 → data[124]++
		if d.size() > 124:
			d[124] += 1


## 两伊战争结算（GameState.cs:216-470 的 data[82]==3 分支）。
## 只移植国家政权/势力/附庸状态与全局数值效果；长文本不移植。
static func _apply_iran_iraq_war_result(war: WarData, d: Array[int]) -> void:
	var w: WorldState = GameManager.world
	if w == null or war == null:
		return
	var iran := w.get_country_by_legacy_index(8)
	var iraq := w.get_country_by_legacy_index(14)
	if iraq != null and (iraq.sub_government == 4 or iraq.sub_government == 20) \
			and iraq.puppet_of < 0:
		# GameState.cs:218-221：伊拉克新政府提出停战，无状态变化。
		return
	if war.infl1 >= 900:
		# GameState.cs:223-305：伊朗方/伊拉克方胜利的政权分支。
		if iran != null and w.is_socialism(iran, true):
			iran.prc_power = 1000
			iran.social_stability = 1000
		elif iraq != null and iraq.sub_government == 2:
			# GameState.cs:239-262
			if iran != null:
				iran.government = 1
				iran.sub_government = 2
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
				iraq.puppet_of = -1
				iraq.government = iran.government
				iraq.sub_government = iran.sub_government
		elif iraq != null and iraq.sub_government == 16:
			# GameState.cs:264-281
			if iran != null:
				iran.government = 1
				iran.sub_government = 16
				iran.chinese_name = "伊朗人民共和国"
				iran.prc_power = 1000
				iran.social_stability = 1000
				_leave_alliances(iran)
				iran.set_tag("对华贸易", true)
				iran.set_tag("亲苏", true)
			w.set_flag("iranrev", false)
			# GameState.cs:276-281：伊拉克原为伊朗附庸 → 随伊朗新政体解放并同步政体。
			if iraq != null and iran != null and iraq.puppet_of == 8:
				iraq.puppet_of = -1
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
				iran.government = 0
				iran.sub_government = 10
				iran.set_tag("对华贸易", true)
				_leave_alliances(iran)
				iran.puppet_of = 14
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
		iraq.government = 0
		iraq.sub_government = 20
		iraq.set_tag("对华贸易", false)
		_leave_alliances(iraq)
		iraq.puppet_of = 8
		iraq.chinese_name = "伊拉克"
		if d.size() > 117:
			d[117] = 9
	else:
		# GameState.cs:388-400：伊拉克世俗伊朗傀儡。
		if iraq != null:
			iraq.government = 0
			iraq.sub_government = 20
			iraq.set_tag("对华贸易", false)
			iraq.set_tag("亲苏", false)
			_leave_alliances(iraq)
			iraq.puppet_of = 8
			iraq.chinese_name = "伊拉克"
		if d.size() > 117:
			d[117] = 9
		if w.wars.size() > 88 and w.wars[88] != null and w.wars[88].is_going:
			w.wars[88].infl1 = 1000
			w.wars[88].infl2 = 0
			w.wars[88].is_going = false


## 停掉战争 33（伊朗革命战争），结果记伊朗方胜利（GameState.cs:250-254）。
static func _stop_war_33() -> void:
	var w: WorldState = GameManager.world
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
	country.puppet_of = -1


## Country.EstablishGovernment(Government.ProAmerican)（Country.cs:11-15）：
## 仅清亲中/亲苏、置亲美，不动 Gosstroy/SubGosstroy。
static func _set_pro_american(country: CountryData) -> void:
	if country == null:
		return
	country.set_tag("亲中", false)
	country.set_tag("亲苏", false)
	country.set_tag("亲美", true)


# ============================================================================
# 内部辅助
# ============================================================================

static func clamp_war_infl(war: WarData) -> void:
	if war.infl1 > 1000 or war.infl2 < 0:
		war.infl1 = 1000
		war.infl2 = 0
	elif war.infl2 > 1000 or war.infl1 < 0:
		war.infl2 = 1000
		war.infl1 = 0
	war.infl1 = clampi(war.infl1, 0, 1000)
	war.infl2 = clampi(war.infl2, 0, 1000)


static func add_empire_power(empire_index: int, delta: int) -> void:
	var w: WorldState = GameManager.world
	if empire_index >= 0 and empire_index < w.empires.size() and w.empires[empire_index] != null:
		w.empires[empire_index].power += delta
