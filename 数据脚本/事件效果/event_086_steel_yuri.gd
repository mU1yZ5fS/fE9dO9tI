extends "res://数据脚本/event_script_base.gd"

## 原作 Event86.cs："钢铁尤里"的终结（1979.7 后 且 苏 now_leader==0 且 result[85]==0 或 data.soviet_successor_route==3）。
## 触发：TimeScript.cs:10705。效果（Event86.cs ResultsOfEvents）：
##  - result0（推波助澜）：data.agents-=100、data.budget-=50、leaders[3](安德罗波夫).support=-100、leaders[1](谢尔比茨基).support+=10、data.party_support+=100
##  - result1（揭露材料）：苏关系>=400 → data.budget-=70、leaders[3].support=-100、leaders[1].support+=10；否则 data.budget-=70、leaders[3].support+=2
##  - result2（留到将来）：leaders[3].support+=2
## 选项条件：特工>=100 且（路线<3 且一党制<8，或多党联盟>66%）
const LDR_ANDROPOV := 3       # 苏 leaders[3] = 尤里·安德罗波夫
const LDR_SHCHERBITSKY := 1   # 苏 leaders[1] = 弗拉基米尔·谢尔比茨基


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var ussr: EmpireData = ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
	context["result_title"] = "“钢铁尤里”的终结"
	if opt == 0:
		if d.size() > W.I_AGENTS:
			d.agents -= 100
		if d.size() > W.I_BUDGET:
			d.budget -= 50
		_leader_support(LDR_ANDROPOV, -100)
		_leader_support(LDR_SHCHERBITSKY, 10)
		if d.size() > W.I_PARTY_SUPPORT:
			d.party_support += 100
		context["result_text"] = "在勃列日涅夫前往维也纳会谈时，长期饱受肾病折磨的尤里·安德罗波夫的病情恶化，前往克里米亚接受治疗。然而，这是一次单程的旅行——在克里米亚，他感冒了，最后病倒了——他得了蜂窝织炎，身体健康状况急剧恶化。虽然手术很成功，但是术后伤口没有愈合。他的身体非常虚弱，无法抵抗病毒的侵入。安德罗波夫陷入昏迷，然后就再也没有醒过来。1979年7月9日，苏联克格勃主席逝世。知情人士说：“安德罗波夫没有必要去谢尔比茨基的农场。他也有他的骄傲和他的克格勃。”新的克格勃领导人是塞米恩·茨维贡，他发起了大规模的“办公室清洗”，大量来自乌克兰苏维埃社会主义共和国的克格勃工作人员取代了安德罗波夫的亲信。这增强了弗拉基米尔·谢尔比茨基的影响力，他如今已成为列昂尼德·勃列日涅夫事实上唯一的继承人。对我们来说挺好的……"
	elif opt == 1:
		if d.size() > W.I_BUDGET:
			d.budget -= 70
		if ussr != null and ussr.relations >= 400:
			_leader_support(LDR_ANDROPOV, -100)
			_leader_support(LDR_SHCHERBITSKY, 10)
			context["result_text"] = "当维也纳传来了勃列日涅夫抵达奥地利首都的消息时，苏联克格勃第八最高委员会第一副主席塞米恩·茨维贡将军下令切断了政府的通讯，从而使勃列日涅夫完全隔绝了来自苏联的信息。与此同时，在克格勃内的反对派的帮助下，米哈伊尔·苏斯洛夫和弗拉基米尔·谢尔比茨基迅速召开了紧急中央委员会全体会议，尤里·安德罗波夫被指控“将克格勃改造成私人商店，准备发动反政府政变，与中央情报局和以色列特勤处进行沟通，诽谤费奥多尔·库拉科夫和彼得·马谢罗夫”等等。我们发表了有关安德罗波夫的“揭发材料”，火上浇油，迅速地给予了全会的信息支持。克格勃领导人哑口无言，他试图抵抗，但在弗拉基米尔·谢尔比茨基发表了直接指控安德罗波夫准备谋杀勃列日涅夫的讲话后，他意识到自己已经失败了。全会通过了关于撤销安德罗波夫所有职务的决定，将他驱逐出党并逮捕他。苏联克格勃新任主席是乌克兰克格勃主席维塔利·费多丘克。费多丘克开始大规模清洗安德罗波夫的亲信，并将他们替换为来自乌克兰共和国中央委员会的可靠人员。也许我们在苏联最危险的敌人现在已经被完全消灭了…"
		else:
			_leader_support(LDR_ANDROPOV, 2)
			context["result_text"] = "当维也纳传来了勃列日涅夫抵达奥地利首都的消息时，苏联克格勃第八最高委员会第一副主席塞米恩·茨维贡将军下令切断了政府的通讯，从而使勃列日涅夫完全隔绝了来自苏联的信息。与此同时，在克格勃内的反对派的帮助下，米哈伊尔·苏斯洛夫和弗拉基米尔·谢尔比茨基迅速召开了紧急中央委员会全体会议，尤里·安德罗波夫被指控“将克格勃改造成私人商店，准备发动反政府政变，与中央情报局和以色列特勤处进行沟通，诽谤费奥多尔·库拉科夫和彼得·马谢罗夫”等等。我们发表了有关安德罗波夫的“揭露材料”，火上浇油，迅速地给予了全会信息支持。然而，安德罗波夫保持了冷静，并依靠他在苏共中央委员会内的支持者和忠诚的克格勃官员，宣布苏斯洛夫和谢尔比茨基为“第二个反党团体”，把全会变成了他们的法庭。结果是苏斯洛夫和谢尔比茨基被排除在苏共之外，也促使了安德罗波夫的崛起，安德罗波夫成为苏共的第二书记和列昂尼德·勃列日涅夫的实际继任者，勃列日涅夫得到了一切全会中的信息，并支持他的做法。"
	elif opt == 2:
		_leader_support(LDR_ANDROPOV, 2)
		context["result_text"] = "什么也没发生。尤里·安德罗波夫逐渐清除了克格勃内的反对派，加强了对苏共中央委员会的影响力，成为勃列日涅夫的实际接班人，推动了叶戈尔·利加乔夫、米哈伊尔·戈尔巴乔夫和弗拉基米尔·多尔吉赫等改革派党员的晋升。"
	else:
		context["result_text"] = ""


## 苏领导人 support 调整（越界安全）
func _leader_support(idx: int, delta: int) -> void:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		var ussr: EmpireData = ws.empires[EmpireData.USSR]
		if idx >= 0 and idx < ussr.leaders.size() and ussr.leaders[idx] != null:
			ussr.leaders[idx].support += delta
