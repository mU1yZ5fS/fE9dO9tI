extends "res://数据脚本/event_script_base.gd"

## 原作 Event83.cs：斯塔夫罗波尔农学家的问题（1977.7.4 后，中苏关系链开端）。
## 触发：TimeScript.cs:10712（1977.7.4 后，fire_only_once）。
## 效果（Event83.cs ResultsOfEvents）：
##  - result0（泄露情报）：data.party_support+=50 党内支持、data.agents-=50 特工、苏 leaders[3](安德罗波夫).support-=1、data.soviet_successor_route=1
##  - result1（媒体揭露）：苏关系>=500 → 同上（data.budget-=20 预算 而非特工）；否则仅 data.budget-=20
##  - result2（留到将来）：无效果
## 选项条件：
##  - 选项0：特工>=50 且（路线<4 且 一党制<8，或多党联盟支持率>66%）
##  - 选项1：（路线<3 且 一党制<8，或多党联盟支持率>66%）
## 差异：summa_3_2（Awake 执政联盟支持率）→ 本地辅助 _coalition_pct（对齐 EventEngine._coalition_support_percent）
const LDR_ANDROPOV := 3   # 苏 leaders[3] = 尤里·安德罗波夫


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	context["result_title"] = "斯塔夫罗波尔农学家的问题"
	if opt == 0:
		if d.size() > W.I_PARTY_SUPPORT:
			d.party_support += 50
		if d.size() > W.I_AGENTS:
			d.agents -= 50
		_leader_support(-1)
		if d.size() > 149:
			d.soviet_successor_route = 1   # 原 data.soviet_successor_route（中苏关系路线，无端口命名键）
		context["result_text"] = "今天的《人民日报》登载了一篇文章，题为《苏共中央政治局的改革家》，其中费奥多尔·库拉科夫被称为“分权马克思主义者”、“铁托派的共产主义者”、“整个国际共产主义和工人运动的危险敌人”。该文章特别强调的事实是，库拉科夫极有可能在列昂尼德·勃列日涅夫死后领导苏联。与此同时，我们的特工部门披露了库拉科夫在苏共中央委员会中的改革愿望的资料。在1977年7月的中央委员会全体会议上，费奥多尔·库拉科夫被批评并被剥夺了所有职务。他患有急性胃病，导致神经系统衰弱。1977年7月17日晚，他突然死于心脏麻痹。如此，我们大大削弱了苏共内的改革派…"
	elif opt == 1:
		var ussr: EmpireData = ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
		if ussr != null and ussr.relations >= 500:
			if d.size() > W.I_PARTY_SUPPORT:
				d.party_support += 50
			if d.size() > W.I_BUDGET:
				d.budget -= 20
			_leader_support(-1)
			if d.size() > 149:
				d.soviet_successor_route = 1
			context["result_text"] = "我们组织了一场大规模的运动，在媒体上诋毁库拉科夫。他被冠以“腐败分子、官僚主义者、铁托主义者、野心家、机会主义者、苏共和中国共产党最大的敌人、披着羊皮的狼”等称号。主席同志在一次讲话中曾简短地提到，”如果费多尔·库拉科夫这样的人成为苏联的领导人，我们最好什么都不跟他谈，因为他们反对我们、反对中国共产党、反对中国人民。”这引起了苏共中央委员会对他的强烈怀疑，库拉科夫被召到党监察委员会与其负责人阿尔维德·佩尔谢会谈。他与大权在握的克格勃主席尤里·安德罗波夫联手，成功破坏了政治局关于任命摩尔多瓦共产党中央委员会第一书记的决定——事实上，他光荣地被流亡海外。库拉科夫的支持者已开始从高级职位上撤下，转到较低的职位上去。所以，他不再是我们事业的阻碍……"
		else:
			if d.size() > W.I_BUDGET:
				d.budget -= 20
			context["result_text"] = "我们组织了一场大规模的在媒体上诋毁库拉科夫的运动。他被冠以“腐败分子、官僚主义者、铁托主义者、野心家、机会主义者、苏共和中国共产党最大的敌人、披着羊皮的狼”等称号。主席同志在一次讲话中曾简短地提到，”如果费多尔·库拉科夫这样的人成为苏联的领导人，我们最好什么都不跟他谈，因为他们反对我们、反对中国共产党、反对中国人民。”库拉科夫知道这件事后，没有像我们计划的那样失去理智，他在苏共中央全会上发表了精彩的演讲，指责中国“诽谤列宁主义的中央委员会，意图建立毛派的霸权，妄想分裂苏联共产党，从而制造另一个毛派的“伪党”，又在苏联暗中进行反革命行动，最终占领西伯利亚和远东”。凭借他的简陋的谎言，他能够糊弄包括勃列日涅夫在内的大多数政治局成员，并粉饰他自己。"
	elif opt == 2:
		context["result_text"] = "什么也没发生。库拉科夫继续担任这一职务，晋升到由他在斯塔夫罗波尔地区的盟友米哈伊尔·戈尔巴乔夫领导的具有改革思想的党内高层成员。"
	else:
		context["result_text"] = ""


## 苏 leaders[3]（安德罗波夫）support -1（Event83.cs result 0/1 共同效果）
func _leader_support(_unused: int) -> void:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		var ussr: EmpireData = ws.empires[EmpireData.USSR]
		if LDR_ANDROPOV < ussr.leaders.size() and ussr.leaders[LDR_ANDROPOV] != null:
			ussr.leaders[LDR_ANDROPOV].support -= 1
