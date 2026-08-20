extends "res://数据脚本/event_script_base.gd"

## 原作 Event632.cs：牙买加，我们热爱的家乡（牙买加1980大选，三选项）。
## 触发：ReqEventsDLC02.cs:971-974 —— c152.SubGosstroy!=13 且 DATE_AFTER 1980.10.30
##   （原 (1980&&m>=10&&d>=30)||(1980&&m>=11)||y>=1981）。
## 差异：原版按 data[56]/resultOfEvents[631] Destroy(button[i])；Godot _disable 同义。
##   Vyshi→亲美、Torg/proprc→标签、now_leader→empires[0].current_leader。

const TXT_OPT0_DIS := "我们在当地没有如此巨大的影响力？"
const TXT_OPT1_DIS := "我们在当地没有如此巨大的影响力"
const TXT_R0_OK := "由于在两年前的“一份爱，一份和平”演唱会之前牙买加工党帮派的举动导致牙买加工党的名声下跌，于此同时，牙买加警方得到情报并开始突袭蒂沃利花园（金斯顿的一个街区，贩毒和帮派活动的活跃地），抓捕到了部分“未能逃走”的帮派成员并找到了工党参与贩毒、圈养黑帮、串通cia的证据。曼利在得知消息后当天便宣布进入紧急状态，数百人（包括牙买加工党的部分重要成员）被指控试图推翻政府并被关进大牢。1980年选举结果自然是人民民族党继续执政，牙买加与美国的关系进一步恶化并变得更加亲近苏联，格林纳达，古巴和中国，本就是人民民族党亲密战友的亲古巴共产主义政党牙买加工人党获得了更多的部门任职。为表达对我们的感激，牙买加开始在北京设立大使馆，并与我们进行密切的经贸往来。在我们的援助下，曼利的民主社会主义延续了下来，帮派分子和毒品贸易被大量打击。牙买加于1981年进行宪法改革并成为共和制国家。"
const TXT_R0_FAIL := "由于在两年前的“一份爱，一份和平”演唱会之前牙买加工党帮派的刺杀举动导致牙买加工党的名声下跌，于此同时，牙买加警方得到情报并开始突袭蒂沃利花园（金斯顿的一个街区，贩毒和帮派活动的活跃地），抓捕到了部分“未能逃走”的帮派成员并找到了工党参与贩毒、圈养黑帮、串通cia的证据。曼利在得知消息后当天便宣布进入紧急状态，但此时，听命于工党和cia的帮派showerposse开始进行暴动，连同被cia收买的部分军队攻打总理府。最后曼利被迫接受投降并被关入大牢之中，人民民族党的政治盟友，亲古巴的工人党则被查禁，人民民族党高层在未经审判的情况下大量被捕，showerposse的头目莱斯特·科克加入工党并成为新政府的总理。新政府开始对过去八年人民民族党的政策进行逆转：大量实行私有化：断绝与苏联、中国、古巴和格林纳达等国的关系；与美国进行深度合作，尤其是和cia进行合作，帮派和毒品在牙买加进一步泛滥了起来。"
const TXT_R1 := "两年前的“一份爱，一份和平”演唱会之前人民民族党帮派的刺杀举动导致人民民族党的名声下跌。而在大选开始之前据称是人民民族党的帮派成员开始威胁必须投票给人民民族党。这些举动自然导致人民民族党在选举中大败，获得了35.1%的支持率，仅获得60个议会席位中的5个，而工党则获得63.6%的支持率并斩获剩下55个议会席位，工党领袖爱德华·西加成为了牙买加总理。新政府开始扭转曼利的政策，将行业私有化并寻求与美国和我们建立更紧密的关系。（如果美国总统为里根则显示：西加是次年年初访问新当选的美国总统罗纳德·里根的首批外国政府首脑之一，并且是由里根赞助的加勒比盆地倡议的倡议者之一。）（如果美国总统为卡特则显示：西加是次年年初访问新当选的美国总统吉米·卡特的首批外国政府首脑之一）他推迟了与古巴断绝外交关系的承诺，直到一年后他指责古巴政府为牙买加罪犯提供庇护。"
const TXT_R2_A := "在此次选举中，工党大获全胜并得到了58.8%的支持率和60个议会席位中的51个，而人民民族党则仅获得41%的支持率和9个议会席位，工党领袖爱德华·西加成为了牙买加总理。新政府开始扭转曼利的政策，将行业私有化并寻求与美国建立更紧密的关系。"
const TXT_R2_REAGAN := "西加是次年年初访问新当选的美国总统罗纳德·里根的首批外国政府首脑之一，并且是由里根赞助的加勒比盆地倡议的倡议者之一。"
const TXT_R2_CARTER := "西加是次年年初访问新当选的美国总统吉米·卡特的首批外国政府首脑之一"
const TXT_R2_TAIL := "他推迟了与古巴断绝外交关系的承诺，直到一年后他指责古巴政府为牙买加罪犯提供庇护。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var r631 := int(ws.completed_event_ids.get("event_631", 0))
	var opt := event_def.options
	if line < 3 and r631 == 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line > 1 and r631 == 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var jamaica := ws.get_country_by_legacy_index(152)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var usa_power := ws.empires[0].power if ws.empires.size() > 0 and ws.empires[0] != null else 0
			var usa_rel := ws.empires[0].relations if ws.empires.size() > 0 and ws.empires[0] != null else 0
			if ws.influence_prc > usa_power or usa_rel >= 500:
				context["result_text"] = TXT_R0_OK
				if jamaica != null:
					jamaica.government = GameConstants.Government.REFORMIST
					jamaica.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					_leave_alliances(jamaica)
					jamaica.set_tag("对华贸易", true)
					jamaica.set_tag("亲中", true)
				ws.influence_prc += 10
				_add_power(EmpireData.USA, -20)
				_add_relation(EmpireData.USA, -50)
			else:
				context["result_text"] = TXT_R0_FAIL
				if jamaica != null:
					jamaica.government = GameConstants.Government.AUTHORITARIAN
					jamaica.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
					_leave_alliances(jamaica)
					jamaica.set_tag("亲美", true)
				_add_power(EmpireData.USA, 20)
				_add_relation(EmpireData.USA, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
		1:
			context["result_text"] = TXT_R1
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			if jamaica != null:
				jamaica.government = GameConstants.Government.LIBERAL
				jamaica.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				_leave_alliances(jamaica)
				jamaica.set_tag("亲美", true)
				jamaica.set_tag("对华贸易", true)
			_add_power(EmpireData.USA, 20)
			_add_relation(EmpireData.USA, 50)
		2:
			var leader := ws.empires[0].current_leader if ws.empires.size() > 0 and ws.empires[0] != null else 0
			context["result_text"] = TXT_R2_A + (TXT_R2_REAGAN if leader == 0 else TXT_R2_CARTER) + TXT_R2_TAIL
			_add(W.I_BUDGET, -20)
			if jamaica != null:
				jamaica.government = GameConstants.Government.LIBERAL
				jamaica.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				_leave_alliances(jamaica)
				jamaica.set_tag("亲美", true)
			_add_power(EmpireData.USA, 20)
