extends "res://数据脚本/event_script_base.gd"

## 原作 Event633.cs：永恒的春天（危地马拉内战转折，四选项）。
## 触发：ReqEventsDLC02.cs:976-979 —— IsAuthoritarianism(149) && DATE_AFTER 1982.3.23。
##   IsAuthoritarianism 无单一 ExprNode → trigger_script evaluate。
## 差异：原版按 data[56]/对美关系 Destroy(button[i])；Godot _disable 同义；
##   美国总统 now_leader==0(里根)/否则(卡特) 用 empires[0].current_leader 分支。

const TXT_OPT0_DIS := "我们为什么要支持流匪？"
const TXT_OPT1_DIS := "可他们手上沾满了鲜血！"
const TXT_OPT2_DIS := "为什么要支持这个刽子手？"
const TXT_MASSACRE := "军政府摆出的“民族和解”姿态并没有得到游击队的响应，因此，蒙特将军很快便撕下了面具，放弃了模糊不清的纲领并转而以强硬的反共主义替代。1982年6月9日，里奥斯·蒙特任命自己为国家元首，7月1日，宣布全国戒严，开始“最后的战斗”。五分之三的军队被调往该国西北部镇压叛乱，并成立了由总统任命的特别法庭，该机构有权不经过任何法律手段对“颠覆分子”判处死刑。为了切断在玛雅人聚居区中如鱼得水的游击队的“水源”，在“步枪与豆子”的口号下，军政府制定了通过改善政府提供给玛雅村庄的基础设施和资源来增加军民接触与合作的计划，并在农村中建立了反共民兵“民防巡逻队”，与游击队有联系的村庄则被摧毁，这在短短几个月间便造成了超过一万名玛雅农民的死亡与十余万人的流离失所。"
const TXT_MASSACRE_REAGAN := "军政府的恶劣人权记录与蒙特将军拒绝举行选举导致危地马拉甚至遭到了美国国会的反对，而罗纳德·里根则绕过国会向军政府提供援助，以色列也向危地马拉提供了武器装备与军事训练。"
const TXT_MASSACRE_CARTER := "军政府的恶劣人权记录与蒙特将军拒绝举行选举导致危地马拉甚至遭到了美国国会的反对，因此，吉米·卡特总统被迫停止了向军政府的援助，然而cia仍然通过以色列向危地马拉提供武器装备与军事训练。"
const TXT_R0_END := "不过，这位“玛雅人屠夫”的所作所为是显而易见的结果。而我们则向URNG提供了军事训练与援助，趁机扩大游击队控制区并展开了大规模的宣传工作。就让我们静待游击运动花朵的绽放吧……"
const TXT_R1_BASE := "事实证明，我们做错了。\n尽管URNG内部对军政府疑虑重重，但在我们的大力推动下，还是成功促成了革命者与新政府的和谈。该谈判于伊斯坎丛林中举行。\n而接下来发生的事情很快便给我们上了一课。在谈判中，里奥斯·蒙特将军要求游击队放下一切武装无条件投降，并拒绝URNG提出的“以合法政党形式活动”的要求，而这种要求自然遭到了URNG的激烈反对，于是，和谈破裂。就这样不欢而散后，URNG代表团在归途中遭遇了政府军的袭击，尽管最终还是突破了包围圈，但仍然造成了极其惨重的损失，数名游击队核心人物与中坚干部战死。而蒙特将军则彻底撕下了“民族和解”的面具，放弃了模糊不清的纲领并转而以强硬的反共主义替代。1982年6月9日，里奥斯·蒙特任命自己为国家元首，7月1日，宣布全国戒严，开始“最后的战斗”。五分之三的军队被调往该国西北部镇压叛乱，并成立了由总统任命的特别法庭，该机构有权不经过任何法律手段对“颠覆分子”判处死刑。为了切断在玛雅人聚居区中如鱼得水的游击队的“水源”，在“步枪与豆子”的口号下，军政府制定了通过改善政府提供给玛雅村庄的基础设施和资源来增加军民接触与合作的计划，并在农村中建立了反共民兵“民防巡逻队”，与游击队有联系的村庄则被摧毁，这在短短几个月间便造成了超过一万名玛雅农民的死亡与十余万人的流离失所。"
const TXT_R2_A := "里奥斯·蒙特将军上任第二天，我们便承认了新政府，邀请他对我国进行一次国事访问。而中国的一切无不令将军阁下啧啧称奇，在招待宴席上，蒙特总统高度赞扬了"
const TXT_R2_B := "同志，酒过三巡后，他说出了这样一番话“我看中国搞得不错，利润极大丰富，共产党人基本消灭，对美关系也受重视，如果加上军政府执政，中国简直就是我们理想中的社会”。回国后，蒙特立即宣布同台湾当局断交，承认中华人民共和国为唯一合法政府，并与我国签署了几张合作协议。\n不过，军政府摆出的“民族和解”姿态并没有得到游击队的响应，因此，蒙特将军很快便撕下了面具，放弃了模糊不清的纲领并转而以强硬的反共主义替代。1982年6月9日，里奥斯·蒙特任命自己为国家元首，7月1日，宣布全国戒严，开始“最后的战斗”。五分之三的军队被调往该国西北部镇压叛乱，并成立了由总统任命的特别法庭，该机构有权不经过任何法律手段对“颠覆分子”判处死刑。为了切断在玛雅人聚居区中如鱼得水的游击队的“水源”，在“步枪与豆子”的口号下，军政府制定了通过改善政府提供给玛雅村庄的基础设施和资源来增加军民接触与合作的计划，并在农村中建立了反共民兵“民防巡逻队”，与游击队有联系的村庄则被摧毁，这在短短几个月间便造成了超过一万名玛雅农民的死亡与十余万人的流离失所。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 4:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var usa_rel := ws.empires[0].relations if ws.empires.size() > 0 and ws.empires[0] != null else 0
	var opt := event_def.options
	if line < 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line > 0:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line > 2 and usa_rel >= 500:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var guatemala := ws.get_country_by_legacy_index(149)
	var usa_leader := ws.empires[0].current_leader if ws.empires.size() > 0 and ws.empires[0] != null else 0
	var president_tail := TXT_MASSACRE_REAGAN if usa_leader == 0 else TXT_MASSACRE_CARTER
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_MASSACRE + "\n" + president_tail + "\n" + TXT_R0_END
			if guatemala != null:
				guatemala.level_of_instability += 50
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			ws.influence_prc += 5
			_add_power(EmpireData.USA, -5)
			_add_relation(EmpireData.USA, -50)
		1:
			context["result_text"] = TXT_R1_BASE + "\n" + president_tail
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if guatemala != null:
				guatemala.level_of_instability -= 50
			_add_power(EmpireData.USA, 5)
			ws.influence_prc -= 5
		2:
			context["result_text"] = TXT_R2_A + _leader_name() + TXT_R2_B + "\n" + president_tail
			_add(W.I_BUDGET, -20)
			if guatemala != null:
				guatemala.set_tag("对华贸易", true)
			_add_power(EmpireData.USA, 5)
			_add_relation(EmpireData.USA, 80)
		3:
			context["result_text"] = TXT_MASSACRE + "\n" + president_tail
			_add_power(EmpireData.USA, 5)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19820323:
		return false
	var guatemala := world.get_country_by_legacy_index(149)
	return guatemala != null and world.is_authoritarian(guatemala)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
