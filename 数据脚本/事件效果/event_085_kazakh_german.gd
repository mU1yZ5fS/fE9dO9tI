extends "res://数据脚本/event_script_base.gd"

## 原作 Event85.cs：哈萨克斯坦的德意志族自治区（1979.6 后 且 苏 now_leader==0 且 result[84]==0 或 data.soviet_successor_route==2）。
## 触发：TimeScript.cs:10698。效果（Event85.cs ResultsOfEvents）：
##  - result0（煽动）：data.agents-=100、leaders[3](安德罗波夫).support-=1、data.party_support+=50、data.soviet_successor_route=3
##  - result1（预警）：苏关系>=500 → data.agents-=30、leaders[3].support-=1、data.soviet_successor_route=3；否则仅 data.agents-=30
##  - result2（留到将来）：无效果
## 选项条件：特工>=100 且（路线<3 且一党制<8，或多党联盟>66%）；选项1另需 relres 且（路线<4 且一党制<8，或多党联盟>66%）
const LDR_ANDROPOV := 3   # 苏 leaders[3] = 尤里·安德罗波夫


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	context["result_title"] = "哈萨克斯坦的德意志族自治区"
	if opt == 0:
		if d.size() > W.I_AGENTS:
			d.agents -= 100
		_leader_support(-1)
		if d.size() > W.I_PARTY_SUPPORT:
			d.party_support += 50
		if d.size() > 149:
			d.soviet_successor_route = 3
		context["result_text"] = "6月16日，在切利诺格勒，科克切塔夫和卡拉干达，哈萨克人民开始大规模抗议，他们反对给予德意志少数民族自治权。抗议者举着标语，上面写着：“我们的土地对每个人都是统一而不可分裂的！”并高呼口号：“不许在埃雷门托搞德意志族自治区！”。在第一次抗议的三天后，在切利诺格勒郊区，人群再次聚集在周围的街道上，要求当局回答以下问题：“哈萨克人在他们的土地上等待着什么命运？”和“那自治呢？”哈萨克共和国的领导层和执法机构暗中支持示威者，并没有阻止传单的分发，传单呼吁去集体宿舍组织抗议集会。我们利用这一点，公开宣布了这一事实，指责库纳耶夫搞“新法西斯主义”和“违反列宁的民族政策原则”。通过国安部，还整理了大量涉嫌腐败的随行人员的黑材料。12月16日，在只持续了18分钟的哈萨克中央委员会有史以来最短的会议上，金姆哈梅塔·库纳耶夫被撤去哈萨克中央委员会第一书记的职务，并被强迫退休。接替他的是莫斯科派来的格鲁吉亚党的第二书记盖纳季·科尔宾。"
	elif opt == 1:
		var ussr: EmpireData = ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
		if d.size() > W.I_AGENTS:
			d.agents -= 30
		if ussr != null and ussr.relations >= 500:
			_leader_support(-1)
			if d.size() > 149:
				d.soviet_successor_route = 3
			context["result_text"] = "我们紧急向苏共中央委员会提供了将在哈萨克苏维埃社会主义共和国发生的事件的全部信息，指出整个哈萨克党的精英都参与其中。我们的警告得到重视，6月16日，苏联内务部内部部队进入切利诺格勒，科克切塔夫，和卡拉干达，阻止示威发生。库纳耶夫被召到莫斯科，在与阿尔维德·佩尔谢和米哈伊尔·苏斯洛夫谈话后，他写了一份声明，说他因为“健康原因”，将辞去一切职务。"
		else:
			context["result_text"] = "我们紧急向苏共中央委员会提供了将在哈萨克苏维埃社会主义共和国发生的事件的全部信息，指出整个哈萨克党的精英都参与其中。但是，我们的警告被忽视了。6月16日，在切利诺格勒，科克切塔夫和卡拉干达，哈萨克人民开始大规模抗议，他们反对给予德意志少数民族自治权。抗议者举着标语，上面写着：“我们的土地对每个人都是统一而不可分裂的！”并高呼口号：“不许在埃雷门托搞德意志族自治区！”。结果，当局同意了示威者的要求，宣布将哈萨克德意志族自治区的问题从议程中彻底移除出去。"
	elif opt == 2:
		context["result_text"] = "6月16日，在切利诺格勒，科克切塔夫和卡拉干达，哈萨克人民开始大规模抗议，他们反对给予德意志少数民族自治权。抗议者举着标语，上面写着：“我们的土地对每个人都是统一而不可分裂的！”并高呼口号：“不许在埃雷门托搞德意志族自治区！”。结果，当局同意了示威者的要求，宣布将哈萨克德意志族自治区的问题从议程中彻底移除出去。"
	else:
		context["result_text"] = ""


## 苏 leaders[3]（安德罗波夫）support 调整
func _leader_support(delta: int) -> void:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		var ussr: EmpireData = ws.empires[EmpireData.USSR]
		if LDR_ANDROPOV < ussr.leaders.size() and ussr.leaders[LDR_ANDROPOV] != null:
			ussr.leaders[LDR_ANDROPOV].support += delta
