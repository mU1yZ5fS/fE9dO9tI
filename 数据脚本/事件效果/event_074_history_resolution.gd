extends "res://数据脚本/event_script_base.gd"

## 原作 Event74.cs：关于建国以来党的若干历史问题的决议（1981.7 后 且 event_done[39] 五中全会后）。
## 触发：TimeScript.cs:10550（1981.7 后 且 event_done[39]）。
## 选项：0/1/2 按 data.mao_history_line（毛历史评价路线）选择对应版本通过；3=重写（需路线<2 一党制<8 或多党联盟>66%）；4=不通过。
## 效果（Event74.cs ResultsOfEvents，2026-08 移植）：
##  - result0：党内+50/民众+80/国际声望-100/改革动量-20/思想自由+50、美苏关系-100、政客（0派+100p+150l；1派-50p-50l；2派-100p-100l；3派-150p-150l）
##  - result1：党内+100/民众+80/改革动量+10/国际声望-50/思想自由-30、影响力-20、政客（0派+100l；1/2派+100p+100l；3派+100l）
##  - result2：党内-150/民众-150/兵源-200/改革动量+40/国际声望+250/思想自由-60、美+100/苏+250、影响力-50、
##           政客（0/1/2派-300l；3派+150l）、load_scene_after_click → number_event=4（触发事件4 党内阴谋）→ 端口 start_event("congress_conspiracy")
##  - result3（重写）：data.political_line<2 → 党内+20/民众+50/改革动量-20/国际声望-60/思想自由+40、data.mao_history_line=0、政客（0派+100p+150l；1派-50p-50l；2派-100p-100l；3派-150p-200l）
##               data.political_line==1||2 → 党内+80/民众+40/改革动量+10/国际声望-50/思想自由-20、data.mao_history_line=1、政客（同 result1）
##               data.political_line>2 → 党内-100/民众-150/兵源-200/改革动量+40/国际声望+200/思想自由-50、影响力-30、data.mao_history_line=2、政客（0/1/2派-300l；3派+150l）
##  - result4（不通过）：无效果
## 差异：party_change 派系缓冲端口无等价 → 跳过；result2 的 load_scene → start_event("congress_conspiracy")
## 索引映射修正（2026-08-04 随批审查）：原版 data.thought_freedom=思想自由→I_THOUGHT_FREEDOM、data.diplomatic_reputation=国际声望→I_DIPLO。
##           原稿 freedom/diplo 两参写反，已按《economy_data.gd 数值表 + TimeScript.cs:46 政治危机公式》修正。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	context["result_title"] = "关于建国以来党的若干历史问题的决议"
	match opt:
		0:
			_add_data(50, 80, 50, -20, -100)
			_rel(-100, -100)
			_politicians({0: [100, 150], 1: [-50, -50], 2: [-100, -100], 3: [-150, -150]})
			context["result_text"] = "1981年6月27日至29日，中国共产党第十一届中央委员会第六次全体会议在北京隆重召开。全会一致通过了《关于建国以来党的若干历史问题的决议》。《决议》立足毛泽东思想与中国社会主义实践，对建国三十二年来党的重大历史事件特别是“文化大革命”作出了正确的总结，实事求是地评价了伟大领袖和导师毛泽东同志在中国革命中的历史地位，充分论述了毛泽东思想作为我们党的指导思想的伟大意义。"
		1:
			_add_data(100, 80, -30, 10, -50)
			ws.influence_prc -= 20
			_politicians({0: [0, 100], 1: [100, 100], 2: [100, 100], 3: [0, 100]})
			context["result_text"] = "1981年6月27日至29日，中国共产党第十一届中央委员会第六次全体会议在北京隆重召开。全会一致通过了《关于建国以来党的若干历史问题的决议》。《决议》运用马克思主义的辩证唯物论和历史唯物论，对建国三十二年来党的重大历史事件特别是“文化大革命”作出了正确的总结，科学地分析了在这些事件中党的指导思想的正确和错误，实事求是地评价了伟大领袖和导师毛泽东同志在中国革命中的历史地位。"
		2:
			_add_data(-150, -150, -60, 40, 250)
			if d.size() > W.I_MANPOWER:
				d.manpower -= 200
			_rel(100, 250)
			ws.influence_prc -= 50
			_politicians({0: [0, -300], 1: [0, -300], 2: [0, -300], 3: [0, 150]})
			# 差异：load_scene_after_click → 原版触发事件4（党内阴谋）
			GameManager.start_event("congress_conspiracy")
			context["result_text"] = "1981年6月27日至29日，中国共产党第十一届中央委员会第六次全体会议在北京隆重召开。然而，我们准备推出的文件却招致了相当争议，最终只能让全会以微弱多数通过。《决议》对建国三十二年来党的重大历史事件特别是“文化大革命”作出了总结，并给予毛泽东同志“人造奶油共产主义者”与“20世纪版秦始皇、李自成与洪秀全”的评价。"
		3:
			var line: int = d.political_line if d.size() > W.I_POLITICAL_LINE else 0
			if line < 2:
				_add_data(20, 50, 40, -20, -60)
				if d.size() > W.I_MAO_HISTORY_LINE:
					d.mao_history_line = 0
				_politicians({0: [100, 150], 1: [-50, -50], 2: [-100, -100], 3: [-150, -200]})
				context["result_text"] = "《决议》最终在委员会特别过问下成了中国版本的《论列宁主义基础》与《联共（布）党史基本教程》：论述毛主席领导下的共产党如何克服各种主观主义、机会主义与投降主义思潮，从胜利走向新胜利的伟大征程。该版本的决议得到了党内多数认可，最终得以颁行。"
			elif line <= 2:
				_add_data(80, 40, -20, 10, -50)
				if d.size() > W.I_MAO_HISTORY_LINE:
					d.mao_history_line = 1
				_politicians({0: [0, 100], 1: [100, 100], 2: [100, 100], 3: [0, 100]})
				context["result_text"] = "《决议》最终在委员会特别过问下将以“纠正一切错误，强调一切正确”，“胜者无需被归咎，败者则一无所有”与“解放思想，实事求是，团结一致向前看”这三项原则为指导重新写史。该版本的决议得到了党内多数认可，最终得以颁行。"
			else:
				_add_data(-100, -150, -50, 40, 200)
				if d.size() > W.I_MANPOWER:
					d.manpower -= 200
				ws.influence_prc -= 30
				if d.size() > W.I_MAO_HISTORY_LINE:
					d.mao_history_line = 2
				_politicians({0: [0, -300], 1: [0, -300], 2: [0, -300], 3: [0, 150]})
				context["result_text"] = "《决议》最终决定从被平反老干部的口供、港台出版物的分析与美苏宣传机构的材料为蓝本呈现那段时期的历史，力求写出类似赫鲁晓夫“秘密报告”那般深刻的文件：彻底熄灭以毛泽东思想为代表的一系列激进主义潮流。该版本的决议得到了党内多数认可，最终得以颁行。"
		_:
			context["result_text"] = "全会决定将《决议》送交委员会重新审定，历史将由后人评说。"


## 通用数值修正（党内/民众/思想自由/改革动量/声望）
func _add_data(party: int, people: int, freedom: int, momentum: int, diplo: int) -> void:
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support += party
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support += people
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += freedom
	if d.size() > W.I_REFORM_MOMENTUM:
		d.reform_momentum += momentum
	if d.size() > W.I_DIPLO:
		d.diplomatic_reputation += diplo


## 帝国关系修正（美/苏）
func _rel(usa_d: int, ussr_d: int) -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.empires[EmpireData.USA].relations = clampi(ws.empires[EmpireData.USA].relations + usa_d, 0, 1000)
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.empires[EmpireData.USSR].relations = clampi(ws.empires[EmpireData.USSR].relations + ussr_d, 0, 1000)


## 政客按性格修正（trait_personality → [power_delta, loyalty_delta]）
func _politicians(changes: Dictionary) -> void:
	for p in ws.politicians:
		if p == null:
			continue
		var ch: Array = changes.get(p.trait_personality, [0, 0])
		p.power += int(ch[0])
		p.loyalty += int(ch[1])
