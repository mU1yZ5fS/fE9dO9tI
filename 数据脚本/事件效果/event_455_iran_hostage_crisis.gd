extends "res://数据脚本/event_script_base.gd"

## 原作 Event455.cs：伊朗人质危机（四选项）。
## 触发：ReqEventForDLC02.cs:317-319 —— allcountries[8].SubGosstroy==8
##   && DATE_AFTER 1979.11.4；fire_only_once 承担 !event_done[455]。

const TXT_TITLE := "伊朗人质危机"
const TXT_DESC := "在过去的数十年来，伊朗的沙阿一直是美国在中东坚定的盟友，但是1979年的伊朗革命却打断了这一切，原本美国希望尝试向伊朗新政府建立关系，但是1979年10月，巴列维前往美国治疗淋巴瘤，此事激怒了伊朗的革命者。更加坐实了其“美国人的走狗”这一称号。\n1979年11月4日，大约有500名自称“伊玛目的门徒”的伊朗学生占领了使馆的主体建筑。一部分伊朗人民党党员也宣布支持“杂碎帝国主义余孽”的行为。从而加入了对大使馆的占领。为避免引起更大的纷争，美国海军陆战队卫兵只进行了象征性抵抗，而使馆馆员不得不破坏通讯设备并将敏感的档案文件予以销毁。在90名使馆人员中，有66名被扣，其中有3人是在伊朗外交部所俘。暴乱人群还对外界展示了从使馆获得的密文，其中有些此前已透过美方的碎纸机破坏，后来又由革命军拼接起来。虽然人质的处境还算不错，但他们时常会被蒙上眼睛带到当地人和电视镜头前。\n伊朗政府对此事表默认支持，部分革命卫队甚至加入了抗议群众。美国总统吉米·卡特已宣布对伊朗进行制裁。主席同志，我们怎么办？"
const TXT_OPT0 := "安抚伊朗人，勒令其放人"
const TXT_OPT0_DIS_A := "我们宁愿支持伊朗人也不帮帝国主义者！"
const TXT_OPT0_DIS_B := "我们很想帮助他们，但不至于做这么过分的事！"
const TXT_OPT0_DIS_C := "我们没有余力再帮他们了！"
const TXT_OPT1 := "我们派遣人员去营救"
const TXT_OPT1_DIS_A := "和美国人一起行动，下一步是什么，帮他们镇压革命者吗？"
const TXT_OPT1_DIS_B := "我们没必要这么为美国人卖命"
const TXT_OPT1_DIS_C := "我们没有余力再帮他们了！"
const TXT_OPT2 := "火上浇油，激化时局"
const TXT_OPT2_DIS_A := "你脑子是进水了？帮伊朗做这种事？"
const TXT_OPT2_DIS_C := "我们没有余力再帮他们了！"
const TXT_OPT3 := "让杨基佬自个头疼去吧，我们还有自己的事要搞。"
const TXT_R0 := "在我们外交人员的斡旋下，伊朗方面终于宣布释放人质，美国方面也同意支付一部分赔偿金，并保证在王室康复后将其返还至伊朗，尽管我们知道这不太可能发生。\n这场风波对美国大选造成了一点影响，但是由于伊朗方面和民主党人处理的及时，所以对民主党人的影响并不大，尽管如此，这依然遭到伊朗民间的强烈反对，认为这是一种妥协。而在此之后，由于美国政府并未兑现诺言，伊朗外交人员对于美国的指责也开始多了起来，甚至民间有很多自发的活动，开始针对美国进行恐怖袭击，伊朗和美国的关系也自此降低到了冰点。\n随着巴列维国王的离开，西亚将迎来新的大洗牌……"
const TXT_R1 := "看样子，伊朗人并不打算释放人质，那只能我们亲自出手了，我们开始同五角大楼方面有秘密的来往，进行一次联合人质拯救工作。在双方参谋部意见的交换之下，制定出了一份详细的人质拯救计划，代号“鹰爪行动”\n执行这一方案的美军部队主力是三角洲部队和陆军游骑兵，他们虽然存在着人数不足的问题，但这并不是主要问题，最主要的是，他们并不掌握足够的伊朗情报，这就需要我们的情报人员加大调查了\n看样子，这次计划实施的很成功，我们的特勤成功的从伊朗这里搜集到了足够的情报，也使得最终三角洲部队和陆军游骑兵最终顺利的完成了这次行动。这场顺利的行动保住了吉米·卡特的脸面。但也因这个问题，使得伊朗方面谴责美方侵犯了伊朗的主权，看来这一问题仍然需要等待时间解决。"
const TXT_R2 := "伊朗人是不会放人了，当然，我们也不会在乎这件事。在我们的干涉下，这件事却有了新的进展：我们开始积极地怂恿伊朗人进行撕票行为，并且我们也参与了这场行动，这对于美帝来说，绝对是一场巨大的精神刺激，没有人会愿意受这种屈辱的，即便对方是卡特，美方即刻宣布，要对伊朗进行“无限制制裁”，直到伊朗对此事进行道歉为止。\n对于美国政界来说，这等炸裂的消息就足够轰动全国了，共和党人士常常拿着这个来指责民主党，指责民主党在对外方面不够强硬、不能保护海外侨民利益等等，可以说，就凭这一事，民主党就别想赢下下一届大选了，共和党人士宣称：一旦他们上台，就会对伊朗进行一次惩罚性战争。"
const TXT_R3 := "这一次进展在我们的意料之中，尽管卡特发誓他将保护人质的性命，但是他能做的却很少。1980年2月，伊朗向美国提出了一系列要求作为释放人质的条件，其中包括：遣返被废黜的国王，向伊朗做出一些外交姿态包括为此前美国在伊朗的一系列行为道歉，并保证今后不再干涉伊朗。卡特知道这些要求自己是很难满足伊朗人的，于是开始通过走第三国政府的渠道，公开寻求同伊朗的谈判，同时，他批准了一项代号“鹰爪行动”的跨军种联合秘密救助行动。但是在工作中出现了很多问题，所以这场行动显而易见的失败了……\n虽然谈判还在僵持着，但还是不出意外的出意外了，巴列维国王在埃及逝世，使伊朗失去了强硬态度。最终，人质安全的回到了美国。并解冻了此前所冻结的80亿财产。\n至少大家都没有受到什么损失，对吧？"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line56 := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
	var diplo := d[W.I_DIPLO] if d.size() > W.I_DIPLO else 0
	var budget := d[W.I_BUDGET] if d.size() > W.I_BUDGET else 0
	var reserve := d[W.I_RESERVE] if d.size() > W.I_RESERVE else 0
	var agents := d[W.I_AGENTS] if d.size() > W.I_AGENTS else 0
	var army := d[W.I_ARMY] if d.size() > W.I_ARMY else 0
	var opt := event_def.options
	if ((line56 >= 1 and line56 <= 3) or (diplo >= 700 and diplo <= 900)) and budget + reserve >= 100 and agents >= 100:
		_enable(opt[0], TXT_OPT0)
	elif line56 == 0 or diplo > 900:
		_disable(opt[0], TXT_OPT0_DIS_A)
	elif line56 == 4 or diplo < 700:
		_disable(opt[0], TXT_OPT0_DIS_B)
	else:
		_disable(opt[0], TXT_OPT0_DIS_C)
	if line56 >= 3 and diplo <= 700 and army >= 150 and agents >= 100:
		_enable(opt[1], TXT_OPT1)
	elif line56 == 0 or diplo > 900:
		_disable(opt[1], TXT_OPT1_DIS_A)
	elif line56 < 3 or diplo > 700:
		_disable(opt[1], TXT_OPT1_DIS_B)
	else:
		_disable(opt[1], TXT_OPT1_DIS_C)
	if line56 < 2 and agents >= 100:
		_enable(opt[2], TXT_OPT2)
	elif line56 >= 2:
		_disable(opt[2], TXT_OPT2_DIS_A)
	else:
		_disable(opt[2], TXT_OPT2_DIS_C)
	_enable(opt[3], TXT_OPT3)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			ws.influence_prc += 50
			_add(W.I_DIPLO, -50)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
		1:
			context["result_text"] = TXT_R1
			ws.influence_prc += 80
			_add(W.I_DIPLO, -100)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, -150)
			_add(W.I_ARMY, -150)
			_add(W.I_AGENTS, -100)
		2:
			context["result_text"] = TXT_R2
			ws.influence_prc += 50
			_add(W.I_DIPLO, 100)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_AGENTS, -100)
		3:
			context["result_text"] = TXT_R3



func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta

func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta

func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"

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

