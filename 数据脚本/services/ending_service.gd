class_name EndingService
extends RefCounted

## 原版 in1992_script.cs：1986 终局「功成身退」判定与世界收尾。
## 两个入口共用本服务，保证判定完全一致：
##   - 1986-01-01 十字路口事件的右选项（TimeScript.cs:683 Reborn → in1992_script 右按钮）；
##   - ESC 菜单「结束」按钮（CascadScrupt.cs:28-35 PostExit，游戏年份>=1986 时显示）。

const W = preload("res://数据脚本/world_state.gd")


## 判定（顺序同 in1992_script.cs:37-76）：
##   war63 进行中                → {"mode":"war"}（先弹战争结束事件18）
##   resultOfEvents[581]==2      → {"mode":"ending","id":13}
##   人民支持不足                → {"mode":"ending","id":1}
##   党内支持不足                → {"mode":"ending","id":2}
##   体制组合(9/15/19+mod5+寡头) → {"mode":"ending","id":9}
##   否则                        → {"mode":"ending","id":0}（GoodEnd，先做世界收尾）
static func judge(w: WorldState, ee: Node = null) -> Dictionary:
	if w == null:
		return {"mode": "none"}
	if _war_going(w, 63):
		return {"mode": "war"}
	if ee != null and ee.result_of_event_by_number(581) == 2:
		return {"mode": "ending", "id": 13}
	if w.people_support < 300 or (w.people_support < 500 and w.difficulty == 4):
		return {"mode": "ending", "id": 1}
	if w.party_support < 300 or (w.party_support < 500 and w.difficulty == 4):
		return {"mode": "ending", "id": 2}
	if w.party_system == 9 and w.econ_system == 15 and w.press_policy == 19 \
			and _modifier_active(w, 5) and w.oligarch >= 100:
		return {"mode": "ending", "id": 9}
	return {"mode": "ending", "id": 0}


## 事件路径（1986 十字路口右选项）：结果页确认后进结局；war 情形走战争结束事件链。
static func end_after_1986_via_event(w: WorldState, gm: Object = null, ee: Node = null) -> void:
	if w == null:
		return
	var j := judge(w, ee)
	match String(j.get("mode", "")):
		"war":
			if w.size() > W.I_WAR_RESOLVE:
				w.war_resolve = 63
			if ee != null:
				ee.enqueue_chain(["war_is_over"])
		"ending":
			var id := int(j.get("id", 0))
			if id == 0:
				apply_farewell_updates(w)
			if gm != null and gm.has_method("queue_ending_after_event"):
				gm.queue_ending_after_event(id)


## 菜单路径（ESC 菜单「结束」，原版 CascadScrupt.cs PostExit → in1992_script 右按钮）：
## 原版直接 LoadScene("Ending")，这里即时切换到结局；war 情形入事件链。
static func end_after_1986_via_menu(w: WorldState, gm: Object = null, ee: Node = null) -> void:
	if w == null:
		return
	var j := judge(w, ee)
	match String(j.get("mode", "")):
		"war":
			if w.size() > W.I_WAR_RESOLVE:
				w.war_resolve = 63
			if ee != null:
				ee.enqueue_chain(["war_is_over"])
		"ending":
			var id := int(j.get("id", 0))
			if id == 0:
				apply_farewell_updates(w)
			if gm != null and gm.has_method("trigger_ending"):
				gm.trigger_ending(id)


## 原版 in1992_script.cs:79-137 世界收尾（仅 GoodEnd 路线执行）。
static func apply_farewell_updates(w: WorldState) -> void:
	if w == null:
		return
	var c61 := _country(w, 61)
	var c51 := _country(w, 51)
	var c1 := _country(w, 1)
	var c4 := _country(w, 4)
	var ussr: EmpireData = w.empires[1] if w.empires.size() > 1 else null
	var usa: EmpireData = w.empires[0] if w.empires.size() > 0 else null
	# in1992_script.cs:79-82
	if c61 != null and c51 != null and c61.sub_government != GameConstants.SubGovernment.LEFT_RADICAL and c51.has_tag("nato"):
		if usa != null:
			usa.power = clampi(usa.power + 5, 0, 1000)
	# :83-86
	if c1 != null and c51 != null and (c1.government == GameConstants.Government.SOCIALIST or c1.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
		c51.development = 0
	# :87-97
	if c1 != null and c51 != null and c1.government == GameConstants.Government.LIBERAL and (ussr == null or ussr.current_leader != 6):
		if ussr != null and usa != null and ussr.relations >= usa.relations:
			c51.set_tag("对华贸易", false)
		else:
			w.set_flag("relres", false)
	# :98-101
	if w.tibet_policy > 0:
		w.arunachal_status = 0
	# :102-106
	if w.ind_opp:
		if ussr != null:
			ussr.current_leader = 6
		w.set_flag("relres", false)
	if ussr == null:
		return
	# :107-113
	if ussr.current_leader == 3:
		ussr.power = clampi(ussr.power + 50, 0, 1000)
	elif ussr.current_leader == 5:
		ussr.power = clampi(ussr.power - 50, 0, 1000)
	elif ussr.current_leader == 6:
		if w.xinjiang_policy == 1:
			w.xinjiang_policy = 2
	elif ussr.current_leader == 4:
		# :114-121
		var relres: bool = w.get_flag("relres")
		var c4_prosov: bool = c4 != null and c4.has_tag("亲苏")
		if (relres and w.econ_system == 11) or (c4 != null and c4.government == GameConstants.Government.SOCIALIST and c4_prosov):
			ussr.power = clampi(ussr.power + 100, 0, 1000)
		else:
			ussr.power = clampi(ussr.power + 50, 0, 1000)


static func _war_going(w: WorldState, idx: int) -> bool:
	if w == null or idx < 0 or idx >= w.wars.size():
		return false
	var war: WarData = w.wars[idx]
	return war != null and war.is_going


static func _modifier_active(w: WorldState, idx: int) -> bool:
	if w == null or idx < 0 or idx >= w.modifiers.size():
		return false
	return w.modifiers[idx] != null and w.modifiers[idx].is_active


static func _country(w: WorldState, idx: int) -> CountryData:
	if w == null:
		return null
	return w.get_country_by_legacy_index(idx)
