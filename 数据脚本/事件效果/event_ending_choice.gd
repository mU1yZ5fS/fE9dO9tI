extends "res://数据脚本/event_script_base.gd"

## 1986-01-01 终局抉择（原作 TimeScript.cs:683 Reborn() 显示面板 + in1992_script.cs OnMouseDown）。
## 触发：event_ending_choice.tres 的 DATE_AFTER 1986.1.1（fire_only_once）。
## 左选项 = 继续掌权（原作 Reborn 隐藏面板恢复速度；Godot 返回外交场景自动恢复速度）。
## 右选项 = 功成身退：in1992_script.cs:43-137 逐条复刻。
##   - 63 号战争进行中 → data[82]=63 + 事件18（in1992_script.cs:43-49）
##   - resultOfEvents[581]==2 → 结局13（in1992_script.cs:51-57）
##   - data[3]<300 或 (diff==4 且 <500) → 结局1（:58-64）
##   - data[1]<300 或 (diff==4 且 <500) → 结局2（:65-71）
##   - data[15]==9 && data[16]==15 && data[17]==19 && modifies[5] && data[108]>=100 → 结局9（:72-78）
##   - 否则世界收尾更新 → 结局0（GoodEnd 自动判定）（:79-137）


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = "你决定继续掌权，直至永远。"
		1:
			_right_choice(context)


func _right_choice(context: Dictionary) -> void:
	context["result_text"] = ""
	# 63 号战争进行中 → 先结算战争（in1992_script.cs:43-49）
	if _war_going(63):
		if d.size() > W.I_WAR_RESOLVE:
			d[W.I_WAR_RESOLVE] = 63
		EventEngine.enqueue_chain(["war_is_over"])
		return
	# 事件581 结果2 → 结局13（in1992_script.cs:51-57）
	if EventEngine != null and EventEngine.result_of_event_by_number(581) == 2:
		GameManager.queue_ending_after_event(13)
		return
	# 人民支持不足 → 结局1（in1992_script.cs:58-64）
	if d[W.I_PEOPLE_SUPPORT] < 300 or (d[W.I_PEOPLE_SUPPORT] < 500 and ws.difficulty == 4):
		GameManager.queue_ending_after_event(1)
		return
	# 党内支持不足 → 结局2（in1992_script.cs:65-71）
	if d[W.I_PARTY_SUPPORT] < 300 or (d[W.I_PARTY_SUPPORT] < 500 and ws.difficulty == 4):
		GameManager.queue_ending_after_event(2)
		return
	# 特定体制组合 → 结局9（in1992_script.cs:72-78）
	if d[W.I_PARTY_SYSTEM] == 9 and d[W.I_ECON_SYSTEM] == 15 and d[W.I_PRESS_POLICY] == 19 \
			and _modifier_active(5) and d[W.I_OLIGARCH] >= 100:
		GameManager.queue_ending_after_event(9)
		return
	# 兜底：世界收尾更新后进 GoodEnd（in1992_script.cs:79-137）
	_apply_farewell_updates()
	GameManager.queue_ending_after_event(0)


func _apply_farewell_updates() -> void:
	var c61 := _country(61)
	var c51 := _country(51)
	var c1 := _country(1)
	var c4 := _country(4)
	var ussr: EmpireData = ws.empires[1] if ws.empires.size() > 1 else null
	var usa: EmpireData = ws.empires[0] if ws.empires.size() > 0 else null
	# in1992_script.cs:79-82
	if c61 != null and c51 != null and c61.sub_government != 0 and c51.has_tag("nato"):
		if usa != null:
			usa.power += 5
	# :83-86
	if c1 != null and c51 != null and (c1.government == 1 or c1.sub_government == 0):
		c51.development = 0
	# :87-97
	if c1 != null and c51 != null and c1.government == 3 and (ussr == null or ussr.current_leader != 6):
		if ussr != null and usa != null and ussr.relations >= usa.relations:
			c51.set_tag("对华贸易", false)
		else:
			ws.set_flag("relres", false)
	# :98-101
	if d[W.I_TIBET_POLICY] > 0:
		d[W.I_ARUNACHAL_STATUS] = 0
	# :102-106
	if ws.ind_opp:
		if ussr != null:
			ussr.current_leader = 6
		ws.set_flag("relres", false)
	if ussr == null:
		return
	# :107-113
	if ussr.current_leader == 3:
		ussr.power += 50
	elif ussr.current_leader == 5:
		ussr.power -= 50
	elif ussr.current_leader == 6:
		if d[W.I_XINJIANG_POLICY] == 1:
			d[W.I_XINJIANG_POLICY] = 2
	elif ussr.current_leader == 4:
		# :114-121
		var relres: bool = ws.get_flag("relres")
		var c4_prosov: bool = c4 != null and c4.has_tag("亲苏")
		if (relres and d[W.I_ECON_SYSTEM] == 11) or (c4 != null and c4.government == 1 and c4_prosov):
			ussr.power += 100
		else:
			ussr.power += 50


func _war_going(idx: int) -> bool:
	if ws == null or idx < 0 or idx >= ws.wars.size():
		return false
	var war: WarData = ws.wars[idx]
	return war != null and war.is_going


func _modifier_active(idx: int) -> bool:
	if ws == null or idx < 0 or idx >= ws.modifiers.size():
		return false
	return ws.modifiers[idx] != null and ws.modifiers[idx].is_active


func _country(idx: int) -> CountryData:
	if ws == null:
		return null
	return ws.get_country_by_legacy_index(idx)
