extends "res://数据脚本/event_script_base.gd"

## 原作 Event402.cs：驴象之争-第二幕（一/三选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1251 —— DATE_AFTER 1984.11.1。
## 差异：now_leader→current_leader；completedDecisions[17]→ws.decisions.completed[17]；
##  - iron_and_blood 成就 Set(137) 已接 Achievements；选项显隐 prepare。

const TXT_TITLE := [
	"驴象之争-第二幕",
]

const TXT_DESC := [
	"共和党于1980年遭遇失败后，2位候选人参与了此次总统选举：分别是反共主义战鹰，支持实现经济自由化、扩张性外交政策与国内保守主义的乔治·赫伯特·布什其对手则是吉米·卡特时代的副总统，民主党人沃尔特·蒙代尔。蒙代尔呼吁政治自由，支持暂停核试验与《平等权利修正案》，并呼吁和平，倡导与苏联实现和平共存。",
	"民主党于1980年遭遇惨败后，2位候选人参与了此次总统选举：分别是持有极端反主义与温和保守主义，并热衷于实现经济自由化与扩军的共和党人罗纳德·里根。其对手则是民主党人沃尔特·蒙代尔。蒙代尔呼吁政治自由，支持暂停核试验与《平等权利修正案》。他反对里根的经济政策，并倾向于削减联邦预算赤字。",
]

const TXT_OPT0 := [
	"不介入",
	"谁将得胜？",
]

const TXT_OPT1 := [
	"暗中支持民主党人",
]

const TXT_OPT2 := [
	"暗中支持共和党人",
]

const TXT_R := [
	"选举结果表明，50.2%的选民支持蒙代尔。新任民主党总统承诺将实现预算平衡，增进对穷人的社会救济，并实行和平外交政策。",
	"不出所料，“软弱”的蒙代尔输给了“强硬派”里根，后者的竞选攻势宛如电影一般猛烈。预计国际军备竞赛与冷战紧张程度将加剧，美国也将继续实施经济自由化政策。",
	"选举结果表明，50.1%的选民支持布什。新任共和党总统承诺将实现经济自由化，抑制通货膨胀并解决失业问题，同时遏制共产主义的扩张。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1151 := "驴象之争-第二幕"
const TXT_IDX_1153 := "共和党于1980年遭遇失败后，2位候选人参与了此次总统选举：分别是反共主义战鹰，支持实现经济自由化、扩张性外交政策与国内保守主义的乔治·赫伯特·布什其对手则是吉米·卡特时代的副总统，民主党人沃尔特·蒙代尔。蒙代尔呼吁政治自由，支持暂停核试验与《平等权利修正案》，并呼吁和平，倡导与苏联实现和平共存。"
const TXT_IDX_1152 := "民主党于1980年遭遇惨败后，2位候选人参与了此次总统选举：分别是持有极端反主义与温和保守主义，并热衷于实现经济自由化与扩军的共和党人罗纳德·里根。其对手则是民主党人沃尔特·蒙代尔。蒙代尔呼吁政治自由，支持暂停核试验与《平等权利修正案》。他反对里根的经济政策，并倾向于削减联邦预算赤字。"
const TXT_IDX_1154 := "谁将得胜？"
const TXT_IDX_1157 := "选举结果表明，50.2%的选民支持蒙代尔。新任民主党总统承诺将实现预算平衡，增进对穷人的社会救济，并实行和平外交政策。"
const TXT_IDX_1155 := "不出所料，“软弱”的蒙代尔输给了“强硬派”里根，后者的竞选攻势宛如电影一般猛烈。预计国际军备竞赛与冷战紧张程度将加剧，美国也将继续实施经济自由化政策。"
const TXT_IDX_1156 := "选举结果表明，50.1%的选民支持布什。新任共和党总统承诺将实现经济自由化，抑制通货膨胀并解决失业问题，同时遏制共产主义的扩张。"

## 原文字符串附录（供自检）
## |话又说回来，既然我们已经和美国当地的华人黑帮建立了稳定的合作关系，而中国又已经成为国际舞台上一股举足轻重的力量，那这似乎意味着我们可以尝试对大选进行一些小小的“干涉”？
## 不介入
## 暗中支持民主党人
## 暗中支持共和党人
## Ach(Clone)

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var cond := false
	if world.decisions != null and world.decisions.completed.size() > 17:
		cond = world.decisions.completed[17]
	if cond and world.empires.size() > 0 and world.empires[0] != null and world.empires[0].current_leader == 1 and world.influence_prc >= 500:
		_enable(event_def.options[0], TXT_OPT0[0])
		_enable(event_def.options[1], TXT_OPT1[0])
		_enable(event_def.options[2], TXT_OPT2[0])
		# current_leader==1 = 卡特连任成功；应显示“共和党失败”的 TXT_DESC[0]，
		# 不能与“民主党惨败”的 TXT_DESC[1] 写反。
		if world.empires[0].current_leader == 1:
			event_def.description = TXT_DESC[0]
		else:
			event_def.description = TXT_DESC[1]
	else:
		_enable(event_def.options[0], TXT_OPT0[1])
		_disable(event_def.options[1], "")
		_disable(event_def.options[2], "")
		if world.empires.size() > 0 and world.empires[0] != null and world.empires[0].current_leader == 1:
			event_def.description = TXT_DESC[0]
		else:
			event_def.description = TXT_DESC[1]

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var usa := ws.empires[0] if ws.empires.size() > 0 else null
	var opt := int(context.get("option_index", -1))
	var num := 0
	var num2 := 0
	if usa != null and usa.current_leader == 0:
		num += 7
	if ws.empires.size() > 1 and ws.empires[0] != null and ws.empires[1] != null and ws.empires[0].power > ws.empires[1].power:
		num2 += 1
	else:
		num += 1
	if ws.empires.size() > 0 and ws.empires[0] != null and ws.empires[0].power > ws.influence_prc:
		num2 += 1
	else:
		num += 1
	var china := ws.get_country_by_legacy_index(1)
	if china != null and china.government == GameConstants.Government.LIBERAL:
		num2 += 1
	else:
		num += 1
	for cid in [85, 92, 17, 21, 84]:
		var c := ws.get_country_by_legacy_index(cid)
		if c != null and c.has_tag("nato"):
			num2 += 1
		else:
			num += 1
	if china != null and china.has_tag("sev"):
		num2 -= 1
	else:
		num -= 1
	if china != null and china.has_tag("ovd"):
		num2 -= 1
	else:
		num -= 1
	var c15 := ws.get_country_by_legacy_index(15)
	if c15 != null and c15.内战中:
		num2 += 1
	if ws.empires.size() > 1 and ws.empires[1] != null and ws.empires[1].current_leader == 3:
		num2 += 1
	if china != null and china.has_tag("asean"):
		num2 += 1
	if ws.wars.size() > 5 and ws.wars[5] != null and ws.wars[5].is_going:
		num += 1
	var mongolia := ws.get_country_by_legacy_index(2)
	if mongolia != null and mongolia.puppet_of == 7:
		num += 1
	if china != null and china.has_tag("seato"):
		num2 += 1
	if opt == 1:
		num2 += 1
	elif opt == 2:
		num += 1
	var c7 := ws.get_country_by_legacy_index(7)
	if usa != null and usa.current_leader != 0 and (c7 != null and c7.has_tag("nato") or num <= num2):
		if usa != null:
			usa.current_leader = 3
		_add(143, 3)
		Achievements.set_achievement(137)  # 原作 Event402.cs:175 iron_and_blood → achievements.Set(137)
		context["result_text"] = TXT_R[0]
	else:
		_add(143, -5)
		if usa != null and usa.current_leader == 1:
			usa.current_leader = 2
		var us := ws.get_country_by_legacy_index(51)
		if us != null:
			us.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		if usa != null and usa.current_leader == 0:
			context["result_text"] = TXT_R[1]
		else:
			context["result_text"] = TXT_R[2]

func _raw(i: int) -> int:
	if d.size() > i:
		return d.get_data_by_index(i)
	return 0
