extends "res://数据脚本/event_script_base.gd"

## 原作 Event687.cs：侵略者自海上来（单选项）。
## 触发：ReqEventsDLC02.cs:217-219 —— ev543 && r543==1 && modifies[63].active
##   && (data.war_support<450 || (data.war_support<600 && data.thought_freedom>=600)) → trigger_script evaluate。
## 差异：data.war_support→I_WAR_SUPPORT、data.thought_freedom→I_THOUGHT_FREEDOM；{0}{1}→leader.name_display。

const TXT_R0_FMT := "事到如今，党不得不再次挥舞总路线的大棒。\n受到震动的党中央决定坚决采取行动，在全国范围内封杀了《河殇》与其他持类似思想的作品，并开动所有宣传机器开始了全面批判，{0}{1}同志在党建理论研讨班上的讲话中指出：“资产阶级自由化思潮的泛滥，资产阶级的‘民主’、‘自由’、‘人权’口号的蛊惑，利己主义、拜金主义、民族虚无主义和历史虚无主义的滋长，严重侵蚀党的肌体，把党内一些人的思想搞得相当混乱。”……\n在党的及时干涉下，这股带有强烈西化倾向的自由化风潮终于偃旗息鼓，但其依旧对我国的民族精神建设造成了长远且巨大的负面影响，仍有相当多的知识分子群体将其奉若圭臬。幸运的是，也许是由于其自带的逆向民族主义倾向，相当部分普通民众其实并不买他们的账，自由派们一味要求群众反思反省的说教引起了巨大反弹，与其相对的另一群体开始了近乎疯狂的旨在恢复“民族自尊心”寻根运动，他们不厌其烦的用一切历史边角料试图证明中华民族有“例外与于世界”的优越性，部分人甚至去宣讲“世界所有文明皆起源于中国”、“中华民族在生理上优于世界上一切种族”、“近现代的所有科学创造都不过是对我国历史成果的剽窃”等奇谈怪论，只为了去修复这个民族受伤了百余年的民族自尊心.........虽然不想承认，但这些自发的诡异骄傲感确实帮助了我们重新构建意识形态。由此，党提出了“构建中华民族文化自信”的新口号，大量的资金被投入给文宣部门以“发扬优秀传统文化”，在民间我们也给予一些民俗研究社团舆论上的一点小支持，即使他们之中有些人的言论颇为偏激。\n没关系，利用民族主义情绪一直是我党的拿手绝活，只要您稍加引导依旧能化为我等所用……\n对吧？\n[color=red]…………|时间来到21世纪初的互联网年代，某天，网上凭空出现了一个名为“皇汉网”的网络社区，里面一个点赞量颇高的帖子称:“中国共产党是一个由满族人…………”[/color]"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	var leader := "华国锋"
	if ws.leader != null and ws.leader.name_display != "":
		leader = ws.leader.name_display
	context["result_text"] = TXT_R0_FMT.replace("{0}{1}", leader)
	_add(W.I_PARTY_SUPPORT, 200)
	_add(W.I_PEOPLE_SUPPORT, -200)
	_add(W.I_THOUGHT_FREEDOM, -300)
	_add(W.I_WAR_SUPPORT, 100)


func evaluate(world: WorldState) -> bool:
	if world == null or not world.event_done_num(543):
		return false
	if world.result_of_event_num(543) != 1:
		return false
	if not (world.modifiers.size() > 63 and world.modifiers[63] != null \
			and world.modifiers[63].is_active):
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() <= W.I_WAR_SUPPORT:
		return false
	if d.war_support < 450:
		return true
	return d.war_support < 600 and d.size() > W.I_THOUGHT_FREEDOM \
		and d.thought_freedom >= 600
