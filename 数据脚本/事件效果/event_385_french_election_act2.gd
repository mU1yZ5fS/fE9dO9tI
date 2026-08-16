extends "res://数据脚本/event_script_base.gd"

## 原作 Event385.cs：法国选举-第二幕（两选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - press[4]/res1/res2 为原版实例状态，端口无跨实例持久化：
##    prepare/execute 各自按世界状态重算 press；随机票数用 randi_range 复现；
##  - 原版 TextOfEvents 会改写 new_events_text[958]，端口只在 prepare 动态处理；
##  - 原版 modifies[56].active=false 与 modifies[42-45] 覆盖逐项移植。

const TXT_TITLE := "法国选举-第二幕"
const TXT_DESC_FMT := "在法国的首轮总统选举结束后，两位竞选人得以进入次轮选举。其中{1}以{3}%的得票率领先对手{2}。然而，他们当中的每个人都有各种各样的黑材料。如果能够灵活运用它们，我们足以在第二轮选举内起到四两拨千斤的效果。"
const TXT_OPT0_FMT := "我们得教教法国选民该支持谁......开闸，放吉斯卡尔·德斯坦的黑材料！（需要10.0百万{0}与5.0点{1}）"
const TXT_OPT1_FMT := "我们得教教法国选民该支持谁......开闸，放密特朗的黑材料！（需要需要10.0百万{0}与5.0点{1}）"
const TXT_OPT2_FMT := "我们得教教法国选民该支持谁......开闸，放马歇的黑材料！（需要需要10.0百万{0}与5.0点{1}）"
const TXT_OPT3_FMT := "我们得教教法国选民该支持谁......开闸，放希拉克的黑材料！（需要需要10.0百万{0}与5.0点{1}）"
const TXT_OPT_IGNORE := "谁将赢得最后的胜利？"
const TXT_LABEL_BUDGET := "预算"
const TXT_LABEL_AGENTS := "特工网络"
const TXT_LABEL_ARMY := "军事实力"
const TXT_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_952 := "“训练有素的苏共党棍”"
const TXT_953 := "“保皇雅各宾派”"
const TXT_954 := "“有种族歧视特色的共产党人”"
const TXT_955 := "“窃国大盗”"
const TXT_956 := "现任总统瓦莱里·吉斯卡尔·德斯坦"
const TXT_957 := "社会党人弗朗索瓦·密特朗"
const TXT_958 := "共产党人乔治·马歇"
const TXT_959 := "戴高乐主义者雅克·希拉克"
const TXT_965 := "纪录片指出，他收到了来自莫斯科的间接支持。苏联官方报纸的某位供稿人，是如此评价目前进行的如火如荼的法国选举的：“比起弗朗西斯·密特朗和雅克·希拉克这两个丑角，德斯坦显然是‘相对可取’的选择”。因此，《真理报》向亲苏的法国共产主义者展示了他们应选择支持谁。这就是明目张胆地“为弱势且无能的法国总统拉票贿选”。"
const TXT_966 := "纪录片指控他曾为贝当政府工作，并支持镇压阿尔及利亚人民起义，同时又对1968年的五月风暴运动张开怀抱。"
const TXT_967 := "纪录片指控他参与了多次有争议的反移民运动，并拆毁了用于安置马里工人的移民住宅。一些法国知识分子谴责这位共产党领导人的种族主义情绪。"
const TXT_968 := "纪录片指控他在就任政府首脑期间深陷腐败，并与多次挪用预算的丑闻有关。"
const TXT_969 := "勃列日涅夫的密友"
const TXT_970 := "前法西斯分子"
const TXT_971 := "种族主义者"
const TXT_972 := "窃国大盗"
const TXT_973 := "被控与苏联领导人列昂尼德·勃列日涅夫间关系过于密切的瓦莱里·吉斯卡尔·德斯坦"
const TXT_974 := "曾为贝当维希政权效力的弗朗索瓦·密特朗"
const TXT_975 := "被控有可疑言行的乔治·马歇"
const TXT_976 := "已陷入数起腐败丑闻的雅克·希拉克"
const TXT_977 := "瓦莱里·吉斯卡尔·德斯坦"
const TXT_978 := "弗朗索瓦·密特朗"
const TXT_979 := "乔治·马歇"
const TXT_980 := "雅克·希拉克"
const TXT_1039 := "瓦莱里·吉斯卡尔·德斯坦总统承诺将继续实行先前任期内的自由主义政策——包括实现国内政策与经济领域的进一步自由化，奉行亲欧外交政策并实现法国重回北约，同时支持与苏联间发展友好关系。总统上任之初便选择解散议会，并呼吁重新举行议会选举。预计民主派将在议会内取得大胜。"
const TXT_1040 := "弗朗索瓦·密特朗总统承诺将实行社会主义政策——包括实现大型企业的国有化，国家权力的分权化，缩短工作日，降低退休年龄并拓展社会福利。总统上任之初便选择解散议会，并呼吁重新举行议会选举。预计左派将在议会内取得大胜。"
const TXT_1041 := "乔治·马歇总统承诺将实行欧洲共产主义政策——包括实现大型企业的国有化，国家权力的分权化，缩短工作日，降低退休年龄并拓展社会福利。总统上任之初便选择解散议会，并呼吁重新举行议会选举。预计左派将在议会内取得大胜。"

const TXT_958_YUG := "共产党人罗兰·勒罗伊"
const TXT_OPT2_YUG := "我们得教教法国选民该支持谁......开闸，放勒罗伊的黑材料！（需要需要10.0百万{0}与5.0点{1}）"
const TXT_954_YUG := "“支持集中营的共产主义暴君”"
const TXT_967_YUG := "纪录片指控他从1974年开始负责《人道报》，参与了当年反对索尔仁尼琴的大规模运动。一些法国知识分子谴责这位共产党领导人有“极权主义的倾向”。"
const TXT_971_YUG := "极权主义者"
const TXT_975_YUG := "被控有可疑言行的罗兰·勒罗伊"
const TXT_979_YUG := "罗兰·勒罗伊"
const TXT_1041_YUG := "罗兰·勒罗伊总统承诺将分阶段实施社会主义改革，第一个阶段包括实现大型企业的国有化，鼓励建立合作社，强化工会作用，改革选举制度，缩短工作日，降低退休年龄并拓展社会福利。总统上任之初便选择解散议会，并呼吁重新举行议会选举。预计左派将在议会内取得大胜。"
const TXT_R_FMT := "法国国家电视频道“法国电视二台”（FranceDeux）播放了一段名为{1}的纪录片，从而揭了{2}这位总统候选人的老底。{3}\n这部电影最后以一句不寻常的短语结束——“宁要{4}，不要{5}！”。前者最可能指代的是{6}，而后者显然是{7}。对此，遭攻击的总统候选人亲自称这纪录片不过是“廉价的政治偷袭”，并呼吁选民“不要屈服于此类挑衅”。\n选举结果表明，有51%的选民选择支持{8}，因此，他成功当选法国新任总统！\n{9}"
const TXT_R_NO_FMT := "选举结果表明，有51%的选民选择支持{1}，因此，他成功当选法国新任总统！\n{2}"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	ws = world
	var press := _compute_press(world)
	var _france := world.get_country_by_legacy_index(21)
	var infl_ch := _infl_ch(world, press)
	if world.get_flag("YugAgree"):
		# 原版改写 new_events_text[958]；端口在 prepare 动态选用文本。
		pass
	event_def.description = _desc_text(world, press, infl_ch)
	var opt := event_def.options
	_prepare_opt385(opt[0], world, press)
	_enable(opt[1], TXT_OPT_IGNORE)


func _prepare_opt385(opt: EventOption, world: WorldState, press: Array) -> void:
	var _france := world.get_country_by_legacy_index(21)
	var infl_ch := _infl_ch(world, press)
	var fmt_text: String
	if infl_ch == 0:
		fmt_text = TXT_OPT0_FMT
	elif infl_ch == 1:
		fmt_text = TXT_OPT1_FMT
	elif infl_ch == 2:
		fmt_text = TXT_OPT2_YUG if world.get_flag("YugAgree") else TXT_OPT2_FMT
	else:
		fmt_text = TXT_OPT3_FMT
	if _d(W.I_AGENTS) >= 100 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 50:
		_enable(opt, fmt_text.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 50:
		_disable(opt, TXT_DIS_BUDGET.format([10]))
	else:
		_disable(opt, TXT_DIS_AGENTS.format([5]))


func _desc_text(world: WorldState, press: Array, infl_ch: int) -> String:
	var _france := world.get_country_by_legacy_index(21)
	var infl_nato := _infl_nato(world, press)
	var res1: int = randi_range(28, 34)
	var res2: int = randi_range(20, 26)
	var cand_ch := _cand_name(infl_ch)
	var cand_nato := _cand_name(infl_nato)
	return TXT_DESC_FMT.format(["\n", cand_ch, cand_nato, res1, res2])


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	ws.modifiers[56].is_active = false
	var france := ws.get_country_by_legacy_index(21)
	var press := _compute_press(ws)
	var infl_ch := _infl_ch(ws, press)
	var infl_nato := _infl_nato(ws, press)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		# 原版：按 inflNATO 给 press 加 2
		if infl_nato == 0:
			press[1] += 2
		elif infl_nato == 1:
			press[3] += 2
		elif infl_nato == 2:
			press[0] += 2
		else:
			press[2] += 2
		var num := _winner(press)
		_add(W.I_AGENTS, -100)
		_add(W.I_BUDGET, -50)
		# 原版 data[131] = num
		d[131] = num  # 原版 data[131]
		var _cand_ch := _cand_name(infl_ch)
		var _cand_nato := _cand_name(infl_nato)
		var winner_name := _cand_name(num)
		var winner_promise := _promise(num)
		context["result_text"] = TXT_R_FMT.format([
			"\n",
			_black_material(infl_ch), _black_target(infl_ch),
			_black_detail(infl_ch),
			_black_epithet(infl_nato), _black_epithet(infl_ch),
			_black_target2(infl_nato), _black_target2(infl_ch),
			winner_name, winner_promise])
		if num == 0:
			if france != null:
				france.set_tag("亲美", true)
			_add_power(EmpireData.USA, 50)
			d[131] = 0  # 原版 data[131]
			Achievements.set_achievement(115)  # 原作 Event385.cs:410-413 iron_and_blood → achievements.Set(115)
			var portugal := ws.get_country_by_legacy_index(87)
			if portugal != null:
				portugal.special += 10
		elif num == 1:
			if france != null:
				france.sub_government = 4
			ws.modifiers[42].is_active = false
			ws.modifiers[43].is_active = true
			d[131] = 1  # 原版 data[131]
			var portugal2 := ws.get_country_by_legacy_index(87)
			if portugal2 != null:
				portugal2.special += 5
		elif num == 2:
			if france != null:
				if not ws.get_flag("YugAgree"):
					france.sub_government = 14
					france.government = 2
				else:
					france.sub_government = 3
					france.government = 2
			ws.modifiers[42].is_active = false
			ws.modifiers[44].is_active = true
			d[131] = 2  # 原版 data[131]
			var portugal3 := ws.get_country_by_legacy_index(87)
			if portugal3 != null:
				portugal3.special -= 10
		else:
			if france != null:
				france.sub_government = 5
			ws.modifiers[42].is_active = false
			ws.modifiers[45].is_active = true
			d[131] = 3  # 原版 data[131]
			var portugal4 := ws.get_country_by_legacy_index(87)
			if portugal4 != null:
				portugal4.special -= 10
	else:
		var cand_ch := _cand_name(infl_ch)
		context["result_text"] = TXT_R_NO_FMT.format(["\n", cand_ch, _promise(infl_ch)])
		d[131] = infl_ch  # 原版 data[131]
		if infl_ch == 0:
			if france != null:
				france.set_tag("亲美", true)
			_add_power(EmpireData.USA, 50)
			Achievements.set_achievement(115)  # 原作 Event385.cs:457-460 achievements.Set(115)
			d[131] = 0  # 原版 data[131]
		elif infl_ch == 1:
			if france != null:
				france.sub_government = 4
			ws.modifiers[42].is_active = false
			ws.modifiers[43].is_active = true
			d[131] = 1  # 原版 data[131]
		elif infl_ch == 2:
			if france != null:
				if not ws.get_flag("YugAgree"):
					france.sub_government = 14
					france.government = 2
				else:
					france.sub_government = 3
					france.government = 2
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null 					and ws.empires[EmpireData.USSR].leaders.size() > 6:
				ws.empires[EmpireData.USSR].leaders[6].support += 1
			ws.modifiers[42].is_active = false
			ws.modifiers[44].is_active = true
			d[131] = 2  # 原版 data[131]
		else:
			if france != null:
				france.sub_government = 5
			ws.modifiers[42].is_active = false
			ws.modifiers[45].is_active = true
			d[131] = 3  # 原版 data[131]


func _compute_press(world: WorldState) -> Array:
	var press: Array = [0, 0, 0, 0]
	var _france := world.get_country_by_legacy_index(21)
	var poland := world.get_country_by_legacy_index(2)
	var hungary := world.get_country_by_legacy_index(4)
	var _ussr := world.get_country_by_legacy_index(7)
	var china := world.get_country_by_legacy_index(1)
	var usa := world.get_country_by_legacy_index(51)
	var iran := world.get_country_by_legacy_index(8)
	var afghan := world.get_country_by_legacy_index(12)
	var yemen := world.get_country_by_legacy_index(24)
	var ethiopia := world.get_country_by_legacy_index(41)
	var spain := world.get_country_by_legacy_index(86)
	var portugal := world.get_country_by_legacy_index(87)
	var nkorea := world.get_country_by_legacy_index(10)
	var italy := world.get_country_by_legacy_index(85)
	# press[0]（马歇）
	if int(world.completed_event_ids.get("event_384", 0)) == 1:
		press[0] += 2
	if _d(W.I_AFGHAN_PARCHAM) > _d(W.I_AFGHAN_KHALQ):
		press[0] += 2
	if int(world.completed_event_ids.get("event_049", 0)) == 1:
		press[0] += 1
	if int(world.completed_event_ids.get("event_050", 0)) == 3:
		press[0] -= 1
	if poland != null and poland.puppet_of == 7:
		press[0] -= 1
	if hungary != null and hungary.government == 1:
		press[0] += 1
	if ethiopia != null and ethiopia.government == 2:
		press[0] += 1
	if iran != null and iran.government == 1:
		press[0] += 1
	if china != null and china.has_tag("ovd"):
		press[0] += 1
	if china != null and china.has_tag("sev"):
		press[0] += 1
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null 			and world.empires[EmpireData.USSR].power > world.empires[EmpireData.USA].power:
		press[0] += 1
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null 			and world.empires[EmpireData.USSR].power > _d(W.I_INFLUENCE):
		press[0] += 1
	if _mod_active(16):
		press[0] += 1
	# press[1]（德斯坦）
	if int(world.completed_event_ids.get("event_384", 0)) == 2:
		press[1] += 2
	if _d(132) == 2:  # 原版 data[132]
		press[1] += 1
	if usa != null and usa.development > 0:
		press[1] += 1
	if china != null and china.has_tag("seato"):
		press[1] += 1
	if china != null and china.has_tag("asean"):
		press[1] += 1
	if int(world.completed_event_ids.get("event_050", 0)) == 4 or int(world.completed_event_ids.get("event_052", 0)) == 2:
		press[1] += 1
	if china != null and china.has_tag("okb"):
		press[1] += 1
	if iran != null and iran.government == 3:
		press[1] += 1
	if afghan != null and not afghan.has_tag("亲中") and afghan.government == 0:
		press[1] += 1
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null 			and world.empires[EmpireData.USA].power > world.empires[EmpireData.USSR].power:
		press[1] += 1
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null 			and world.empires[EmpireData.USA].power > _d(W.I_INFLUENCE):
		press[1] += 1
	if _mod_active(17):
		press[1] += 1
	if int(world.completed_event_ids.get("event_046", 0)) == 2:
		press[1] -= 1
	# press[2]（希拉克）
	if world.influence_prc > world.empires[EmpireData.USA].power and world.influence_prc > world.empires[EmpireData.USSR].power:
		press[2] += 1
	if int(world.completed_event_ids.get("event_384", 0)) == 3:
		press[2] += 2
	if italy != null and italy.内战中:
		press[2] += 1
	if iran != null and iran.has_tag("亲美") and iran.government == 0:
		press[2] += 1
	if _mod_active(3):
		press[2] += 1
	if portugal != null and portugal.sub_government == 5:
		press[2] += 1
	if spain != null and spain.government == 2:
		press[2] += 1
	if nkorea != null and nkorea.has_tag("亲中"):
		press[2] += 1
	if yemen != null and yemen.has_tag("亲中"):
		press[2] += 1
	if world.empires[EmpireData.USA].relations < 500:
		press[2] += 1
	if china != null and (china.has_tag("sev") or china.has_tag("asean")):
		press[2] -= 2
	# press[3]（密特朗）
	if hungary != null and hungary.government == 2:
		press[3] += 1
	if int(world.completed_event_ids.get("event_384", 0)) == 0 and world.completed_event_ids.has("event_384"):
		press[3] += 2
	if iran != null and iran.sub_government == 20:
		press[3] += 1
	if china != null and not china.has_tag("okb") and not china.has_tag("ovd") and not china.has_tag("seato"):
		press[3] += 1
	var war5 := world.wars[5] if world.wars.size() > 5 else null
	if war5 != null and war5.is_going:
		press[3] += 1
	if usa != null and usa.sub_government == 12:
		press[3] += 1
	if italy != null and italy.sub_government == 6:
		press[3] += 1
	if portugal != null and portugal.sub_government == 6:
		press[3] += 1
	if spain != null and spain.sub_government == 6:
		press[3] += 1
	if world.is_socialism(china, false) and _d(W.I_PARTY_SYSTEM) >= 30:
		press[3] += 1
	var war3 := world.wars[3] if world.wars.size() > 3 else null
	if war3 != null and war3.is_going:
		press[3] += 1
	if china != null and china.government == 2:
		press[3] += 1
	return press


func _infl_ch(_world: WorldState, press: Array) -> int:
	if press[0] >= press[1] and press[0] >= press[2] and press[0] >= press[3]:
		return 2
	elif press[1] >= press[0] and press[1] >= press[2] and press[1] >= press[3]:
		return 0
	elif press[2] >= press[0] and press[2] >= press[1] and press[2] >= press[3]:
		return 3
	return 1


func _infl_nato(world: WorldState, press: Array) -> int:
	var infl_ch := _infl_ch(world, press)
	if infl_ch == 0:
		if press[0] >= press[2] and press[0] >= press[3]:
			return 2
		elif press[2] >= press[3] and press[2] >= press[0]:
			return 3
		return 1
	elif infl_ch == 1:
		if press[0] >= press[2] and press[0] >= press[1]:
			return 2
		elif press[2] >= press[1] and press[2] >= press[0]:
			return 3
		return 0
	elif infl_ch == 2:
		if press[2] >= press[1] and press[2] >= press[3]:
			return 3
		elif press[3] >= press[1] and press[3] >= press[2]:
			return 1
		return 0
	if press[0] >= press[1] and press[0] >= press[2]:
		return 2
	elif press[3] >= press[1] and press[3] >= press[0]:
		return 1
	return 0


func _winner(press: Array) -> int:
	if press[0] >= press[1] and press[0] >= press[2] and press[0] >= press[3]:
		return 2
	elif press[1] >= press[0] and press[1] >= press[2] and press[1] >= press[3]:
		return 0
	elif press[2] >= press[0] and press[2] >= press[1] and press[2] >= press[3]:
		return 3
	return 1


func _cand_name(idx: int) -> String:
	if idx == 0: return TXT_956
	elif idx == 1: return TXT_957
	elif idx == 2: return TXT_958_YUG if (ws != null and ws.get_flag("YugAgree")) else TXT_958
	return TXT_959


func _promise(idx: int) -> String:
	if idx == 0: return TXT_1039
	elif idx == 1: return TXT_1040
	elif idx == 2: return TXT_1041_YUG if (ws != null and ws.get_flag("YugAgree")) else TXT_1041
	return TXT_1040


func _black_material(idx: int) -> String:
	if idx == 0: return TXT_952
	elif idx == 1: return TXT_953
	elif idx == 2: return TXT_954_YUG if (ws != null and ws.get_flag("YugAgree")) else TXT_954
	return TXT_955


func _black_target(idx: int) -> String:
	if idx == 0: return TXT_977
	elif idx == 1: return TXT_978
	elif idx == 2: return TXT_979_YUG if (ws != null and ws.get_flag("YugAgree")) else TXT_979
	return TXT_980


func _black_detail(idx: int) -> String:
	if idx == 0: return TXT_965
	elif idx == 1: return TXT_966
	elif idx == 2: return TXT_967_YUG if (ws != null and ws.get_flag("YugAgree")) else TXT_967
	return TXT_968


func _black_epithet(idx: int) -> String:
	if idx == 0: return TXT_969
	elif idx == 1: return TXT_970
	elif idx == 2: return TXT_971_YUG if (ws != null and ws.get_flag("YugAgree")) else TXT_971
	return TXT_972


func _black_target2(idx: int) -> String:
	if idx == 0: return TXT_973
	elif idx == 1: return TXT_974
	elif idx == 2: return TXT_975_YUG if (ws != null and ws.get_flag("YugAgree")) else TXT_975
	return TXT_976


func _mod_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _d(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n
