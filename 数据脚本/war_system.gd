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


# ============================================================================
# 月度/双周循环
# ============================================================================

## 月度：军事介入点积累（TimeScript 月块）
static func monthly_war_points() -> void:
	var w := GameManager.world
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
		_:
			pass


## 每日：战争达结算条件 → 记录待结算战争并触发战争结束事件
static func check_war_endings() -> void:
	var w := GameManager.world
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
	var w := GameManager.world
	if w == null:
		return out
	for war in w.wars:
		if war != null and war.is_going:
			out.append(war)
	return out


static func get_mil_intervention_display() -> String:
	var w := GameManager.world
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
	var w := GameManager.world
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
	var w := GameManager.world
	if w == null:
		return false
	if war_id < 0 or war_id >= w.wars.size():
		return false
	var war: WarData = w.wars[war_id]
	if war == null or not war.is_going:
		return false
	var act := WarActionCatalog.get_action(action_id)
	if act.is_empty():
		return false
	var d := w.数值表
	var side: int = int(act["side"])
	if side == 1:
		if war.infl1 >= 1000 or war.infl2 <= 0:
			return false
	else:
		if war.infl2 >= 1000 or war.infl1 <= 0:
			return false
	if bool(act["diplo"]):
		return not (war.diplo_done[0] or war.diplo_done[1])
	if d[W.I_MIL_INTERVENTION] < int(act["interv"]):
		return false
	if d[W.I_BUDGET] < int(act["budget"]):
		return false
	if d[W.I_AGENTS] < int(act["agents"]):
		return false
	if d[W.I_ARMY] < int(act["army"]):
		return false
	return true


## 执行干预动作（扣资源 + 改变战争态势/关系）
static func intervene_war(war_id: int, action_id: int) -> bool:
	if not can_intervene(war_id, action_id):
		return false
	var w := GameManager.world
	var war: WarData = w.wars[war_id]
	var act := WarActionCatalog.get_action(action_id)
	var d := w.数值表
	var side: int = int(act["side"])
	d[W.I_BUDGET] -= int(act["budget"])
	d[W.I_AGENTS] -= int(act["agents"])
	d[W.I_ARMY] -= int(act["army"])
	if not bool(act["diplo"]):
		d[W.I_MIL_INTERVENTION] -= int(act["interv"])
	if side == 1:
		war.infl1 += int(act["d_self"])
		war.infl2 += int(act["d_other"])
	else:
		war.infl2 += int(act["d_self"])
		war.infl1 += int(act["d_other"])
	if bool(act["diplo"]):
		var di: int = int(act["diplo_i"])
		if di >= 0 and di < war.diplo_done.size():
			war.diplo_done[di] = true
		var rf: int = int(act["rel_friend"])
		if rf != 0:
			if war.usa_side == side - 1 and w.empires.size() > 0:
				w.empires[0].relations += rf
			if war.ussr_side == side - 1 and w.empires.size() > 1:
				w.empires[1].relations += rf
	else:
		var re: int = int(act["rel_enemy"])
		if re != 0:
			var enemy_place := 1 if side == 1 else 0
			if war.usa_side == enemy_place and w.empires.size() > 0:
				w.empires[0].relations += re
			if war.ussr_side == enemy_place and w.empires.size() > 1:
				w.empires[1].relations += re
	clamp_war_infl(war)
	GameManager._mirror_empires_to_data(w)
	GameManager._notify_stats()
	return true


# ============================================================================
# 结算
# ============================================================================

## 战争结束事件关闭后执行结算（GameManager.clear_event 调用）
static func resolve_war_finished(war_id: int = -1) -> void:
	var w := GameManager.world
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
	var w := GameManager.world
	if w == null or war_id < 0 or war_id >= w.wars.size():
		return false
	var war: WarData = w.wars[war_id]
	if war == null:
		return false
	var d := w.数值表
	d[W.I_MIL_INTERVENTION] = 0
	var restarted := false
	if war.infl1 >= 1000:
		restarted = apply_war_side1_victory(war_id, war, d)
	elif war.infl2 >= 1000:
		restarted = apply_war_side2_victory(war_id, war, d)
	else:
		apply_war_draw(war_id, war, d)
	GameManager._mirror_empires_to_data(w)
	return restarted


static func apply_war_side1_victory(war_id: int, war: WarData, d: Array[int]) -> bool:
	var w := GameManager.world
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
	return false


static func apply_war_side2_victory(war_id: int, war: WarData, d: Array[int]) -> bool:
	var w := GameManager.world
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
	var w := GameManager.world
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
	var w := GameManager.world
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
	var w := GameManager.world
	if empire_index >= 0 and empire_index < w.empires.size() and w.empires[empire_index] != null:
		w.empires[empire_index].power += delta
