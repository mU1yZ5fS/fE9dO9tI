extends "res://数据脚本/event_script_base.gd"

## 原作 Event425.cs：1979年西班牙选举（二选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1384-1386 —— DATE_AFTER + resultOfEvents[424]==1。
## 差异：Gosstroy→government；SubGosstroy→sub_government。

const TXT_OPT0_EN := "消灭卡里略（需要5.0百万{0}与10.0点{1}）"
const TXT_R0 := "西班牙发生轰动事件。在竞选活动期间，共产党领导人圣地亚哥·卡里略被一名极右翼长枪党人枪杀。袭击者被逮捕，并称“卡里略这小子是被告，当然，不是议会内的被告”。\n公众被这一事件所震惊。国王则称刺杀事件是“对民主的犯罪”，并呼吁其臣民团结起来，对抗极右翼复仇主主义的威胁。\n卡里略的西班牙共产党总书记之位则被格拉纳多斯·伊格莱希亚斯接手，他是卡里略的支持者兼欧洲共产主义派。\n知名地下活动家的死亡在公众情绪内引起了轩然大波：西班牙工人社会党以35%的得票领先；苏亚雷斯领导的中间派遭遇惨败，得票率下滑至28%；西班牙共产党则拿下16%的选票。右翼代表的数量发生了显著下降，其在议会内的空缺为民族自治区的代表所填补。\n尽管存在显著优势，但冈萨雷斯没能成功组建一党政府，不得不与西班牙共产党联合执政。\n军方与右派则将自己在选举内的惨败看作是“祖国的死亡”，控诉苏亚雷斯背叛祖国并勾结莫斯科。"
const TXT_R1 := "由苏亚雷斯拼凑的前政权在册改革派贵族与温和反对派组织——民主中间派联盟再度赢得选举，并在选举中拿下34%的选票；工人社会党则以30%的选票紧随其后；共产党则得票10%，与右翼保守派政党得票一致。国民联盟得以在议会选举内获得一席，并将其领导人布拉斯·皮纳尔推入议会。苏亚雷斯再度领导该国政府。\n这场耻辱性的失败沉重打击了工人社会党。对此，冈萨雷斯将失败原因归咎为具有马克思主义色彩的党纲吓跑了保守派选民。因此，西班牙工人社会党开始在党纲中远离马克思主义意识形态。\n选举本身则是一种征兆——这是西班牙数十年以来，在举行宪法公投后的第二次自由投票。尽管政府已经将投票年限从21岁下调至18岁，但投票率已经下降到了70%。难道说社会已经“厌倦”了不稳定的民主？"
const TXT_IDX_1397 := "1979年西班牙选举"
const TXT_IDX_1398 := "1978年12月6日，西班牙市民以88%的绝对多数，在全民公投中通过了西班牙的新民主宪法。为了庆祝这一胜利，苏亚雷斯宣布关闭制宪会议，并要求在1979年3月举行选举。从而获得进一步改革的信任授权。\n竞选活动再度活跃起来：该国的最大反对党依然是冈萨雷斯领导的西班牙工人社会党。而西班牙共产党方面，尽管卡里略向党员担保说：人们会考虑到该党多年的被迫害经历，从而多多少少会做出些“正确选择”。但根据社会学调查来看，该党的支持率不会超过10%。而该党内也有反对现任总书记行动的情绪——亲苏派谴责他的欧洲共产主义倾向；而欧洲共产主义派则斥责他同君主制合作，并背叛了共和主义理想。在年轻且富有活力的冈萨雷斯冉冉升起的背景下，卡里略就和长枪党人一样，宛如“来自过去的幽灵”。然而，推翻一个老牌共产党人并没有什么大意义。不过，考虑到专业人士也需要自己开路的问题，各类障碍依然可能成为其拦路虎。如果我们想要增强对西班牙共产主义运动的影响力，也许“带走”这个不幸老头是值得的？"
const TXT_IDX_1399 := "消灭卡里略（需要5.0百万{0}与10.0点{1}）"
const TXT_IDX_1380 := "观察局势"
const TXT_IDX_1400 := "西班牙发生轰动事件。在竞选活动期间，共产党领导人圣地亚哥·卡里略被一名极右翼长枪党人枪杀。袭击者被逮捕，并称“卡里略这小子是被告，当然，不是议会内的被告”。\n公众被这一事件所震惊。国王则称刺杀事件是“对民主的犯罪”，并呼吁其臣民团结起来，对抗极右翼复仇主主义的威胁。\n卡里略的西班牙共产党总书记之位则被格拉纳多斯·伊格莱希亚斯接手，他是卡里略的支持者兼欧洲共产主义派。\n知名地下活动家的死亡在公众情绪内引起了轩然大波：西班牙工人社会党以35%的得票领先；苏亚雷斯领导的中间派遭遇惨败，得票率下滑至28%；西班牙共产党则拿下16%的选票。右翼代表的数量发生了显著下降，其在议会内的空缺为民族自治区的代表所填补。\n尽管存在显著优势，但冈萨雷斯没能成功组建一党政府，不得不与西班牙共产党联合执政。\n军方与右派则将自己在选举内的惨败看作是“祖国的死亡”，控诉苏亚雷斯背叛祖国并勾结莫斯科。"
const TXT_IDX_1401 := "由苏亚雷斯拼凑的前政权在册改革派贵族与温和反对派组织——民主中间派联盟再度赢得选举，并在选举中拿下34%的选票；工人社会党则以30%的选票紧随其后；共产党则得票10%，与右翼保守派政党得票一致。国民联盟得以在议会选举内获得一席，并将其领导人布拉斯·皮纳尔推入议会。苏亚雷斯再度领导该国政府。\n这场耻辱性的失败沉重打击了工人社会党。对此，冈萨雷斯将失败原因归咎为具有马克思主义色彩的党纲吓跑了保守派选民。因此，西班牙工人社会党开始在党纲中远离马克思主义意识形态。\n选举本身则是一种征兆——这是西班牙数十年以来，在举行宪法公投后的第二次自由投票。尽管政府已经将投票年限从21岁下调至18岁，但投票率已经下降到了70%。难道说社会已经“厌倦”了不稳定的民主？"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_567 := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_IDX_776 := "军事实力必须高于{0}点......"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"



func _raw(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0






func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s





func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, war_name: String, fortnight: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var budget_reserve := d[W.I_BUDGET] + (d[W.I_RESERVE] if d.size() > W.I_RESERVE else 0)
	var agents := d[W.I_AGENTS] if d.size() > W.I_AGENTS else 0
	if budget_reserve >= 50 and agents >= 100:
		_enable(event_def.options[0], _fmt(TXT_OPT0_EN, [TXT_IDX_592, TXT_IDX_593]))
	elif budget_reserve < 50:
		_disable(event_def.options[0], _fmt(TXT_IDX_566, [5]))
	else:
		_disable(event_def.options[0], _fmt(TXT_IDX_567, [10]))
	_enable(event_def.options[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -100)
		var spain := ws.get_country_by_legacy_index(86)
		if spain != null:
			spain.government = GameConstants.Government.REFORMIST
			spain.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		context["result_text"] = TXT_R0
		return
	context["result_text"] = TXT_R1
