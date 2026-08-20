extends "res://数据脚本/event_script_base.gd"

## 原作 Event610.cs：沙巴战争（扎伊尔/安哥拉干预，四选项）。
## 触发：ReqEventForDLC02.cs:899-901 —— DATE_AFTER 1977.3.8；fire_only_once 承担 !event_done[610]。
## 差异：names1+names2→_foreign_minister_name()；AmericanSupportAttacker→usa_side = GameConstants.WarSide.SIDE1；TickTime(9/6)→fortnight_max。

const TXT_OPT0_DIS_A := "他？他杀死了卢蒙巴！"
const TXT_OPT0_DIS_B := "我看不出来他和法西斯的区别"
const TXT_OPT1_DIS := "和那个邪恶帝国沆瀣一气，你疯了！"
const TXT_OPT2_DIS := "愿每个卢蒙巴都遇上自己的蒙博托"
const TXT_R0_A := "我们坚定的支持扎伊尔人民反抗苏联社会帝国主义的斗争，除了增加了一批在扎伊尔的军事教官，并提供了价值200万人民币的军火外，"
const TXT_R0_B := "和迟浩田副参谋长前去金沙萨访问了扎伊尔总统。在我们的官方报纸上也发表了支持扎伊尔的声明。蒙博托总统感谢了我们的支持，并大力扩大了和我们的多方合作。我们的社会学家也得以更深入的了解神秘的刚果与“真实性运动”的真谛。\n清晨，FNLC的士兵们骑着自行车越过安哥拉-扎伊尔边境，发动了三管齐下的攻击。\n蒙博托了谴责入侵，并在3月10日表示，基森奇，迪洛洛和卡潘加被“古巴雇佣军”“轰炸”。他指责古巴政府参与其中，并请求西方列强提供援助。美国大使馆证实了这些城镇已被占领，并宣布卡潘加的八名美国传教士被软禁。\n扎伊尔武装部队FAZ的行动基本上无效。第一个接触的部队，即开曼尼奥拉师第11旅，接受了新训练，在遇到FNLC部队后不久就分崩离析了。然而，FNLC所希望的民众起义也没有实现。尽管大多数居民更喜欢FNLC部队而不是政府军队，人们普遍害怕即将来到的暴力，选择呆在家里。一场战争就这样爆发了。"
const TXT_WAR0_NAME := "沙巴战争"
const TXT_WAR0_SIDE1 := "扎伊尔"
const TXT_WAR0_SIDE2 := "刚果民族解放阵线"
const TXT_R1 := "出于对蒙博托政权的担忧，与和苏联修复关系的务实需求，我们决定支持安哥拉人民和刚果民族解放阵线的举动。在刚果（布）的牵线下，中华人民共和国出乎意料的承认了安哥拉人民共和国，并撤回了驻扎在扎伊尔的外派人员。群众依依不舍的看着中国同志们的离开，更有甚者打出了“蒙博托就是个白痴”“我们想念中国战友”这样的标语。很快，古巴与中国士兵出现在了革命者们的队伍中，大量的军火也被运往安哥拉，由他们转赠给解放阵线的士兵们。\n清晨，FNLC的士兵们骑着二八大杠自行车越过安哥拉-扎伊尔边境，发动了三管齐下的攻击。\n蒙博托了谴责入侵，并在3月10日表示，基森奇，迪洛洛和卡潘加被“古巴与中国雇佣军”“轰炸”。他指责古巴政府参与其中，并请求西方列强提供援助。美国大使馆证实了这些城镇已被占领，并宣布卡潘加的八名美国传教士被软禁。\n扎伊尔武装部队FAZ的行动基本上无效。第一个接触的部队，即开曼尼奥拉师第11旅，接受了新训练，但在遇到FNLC部队后不久就分崩离析了。然而，FNLC所希望的民众起义也没有实现。尽管大多数城镇居民更喜欢FNLC部队而不是政府的军队，人们普遍害怕即将来到的暴力，选择呆在家里。一场战争就这样爆发了。"
const TXT_WAR1_NAME := "沙巴战争"
const TXT_WAR1_SIDE1 := "扎伊尔"
const TXT_WAR1_SIDE2 := "刚果民族解放阵线"
const TXT_R2 := "出乎所有人的意料，我们既不支持扎伊尔朋友，更不支持安哥拉人，而是把目光投向坦桑尼亚。在坦国总统朱利叶斯·尼雷尔的调解下。卢蒙巴主义统一党和刚果人民革命党，刚果（金）马克思主义革命党和安德烈·基萨斯的全国民主抵抗委员会等组织在达累斯萨拉姆签署了《达累斯萨拉姆宣言》。正式宣布多个组织合并为刚果人民革命组织。该组织宣布拥护马克思列宁主义，并认可毛泽东和卢蒙巴的思想。短期目标是建立稳定的解放区和新村，长期与终极目标将会是彻底推翻蒙博托政权。刚果领导人恩古瓦比也宣布公开支持刚果人民革命组织，金沙萨和布拉柴维尔的气氛正在变得微妙……\n清晨，FNLC的士兵们骑着自行车越过安哥拉-扎伊尔边境，发动了三管齐下的攻击。\n蒙博托了谴责入侵，并在3月10日表示，基森奇，迪洛洛和卡潘加被“叛匪轰炸”。他指责古巴政府参与其中，并请求西方列强提供援助。美国大使馆证实了这些城镇已被占领，并宣布卡潘加的八名美国传教士被软禁。\n扎伊尔武装部队FAZ的行动基本上无效。第一个接触的部队，即开曼尼奥拉师第11旅，接受了新训练，但在遇到FNLC部队后不久就分崩离析了。然而，FNLC所希望的民众起义也没有实现。尽管大多数城镇居民更喜欢FNLC部队而不是政府的军队，人们普遍害怕即将来到的暴力，选择呆在家里。一场战争就这样爆发了。"
const TXT_WAR2_NAME := "沙巴战争"
const TXT_WAR2_SIDE1 := "扎伊尔"
const TXT_WAR2_SIDE2 := "刚果民族解放阵线"
const TXT_R3 := "清晨，FNLC的士兵们骑着自行车越过安哥拉-扎伊尔边境，发动了三管齐下的攻击。\n蒙博托了谴责入侵，并在3月10日表示，基森奇，迪洛洛和卡潘加被“古巴雇佣军”“轰炸”。他指责古巴政府参与其中，并请求西方列强提供援助。美国大使馆证实了这些城镇已被占领，并宣布卡潘加的八名美国传教士被软禁。\n扎伊尔武装部队FAZ的行动基本上无效。第一个接触的部队，即开曼尼奥拉师第11旅，接受了新训练，在遇到FNLC部队后不久就分崩离析了。然而，FNLC所希望的民众起义也没有实现。尽管大多数居民更喜欢FNLC部队而不是政府军队，人们普遍害怕即将来到的暴力，选择呆在家里。一场战争就这样爆发了。"
const TXT_WAR3_NAME := "沙巴战争"
const TXT_WAR3_SIDE1 := "扎伊尔"
const TXT_WAR3_SIDE2 := "刚果民族解放阵线"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line != 0 and line != 4:
		_enable(opt[0], event_def.options[0].text)
	elif line == 0:
		_disable(opt[0], TXT_OPT0_DIS_A)
	else:
		_disable(opt[0], TXT_OPT0_DIS_B)
	if line < 3 and line > 0 and world.empires.size() > EmpireData.USSR \
			and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations > 500:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line < 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var zaire := _country(117)
	var angola := _country(123)
	var opt := int(context.get("option_index", -1))
	if zaire != null:
		_set_part(zaire, 0, true)
	var num := 0
	if opt != 3:
		num = 100
	match opt:
		0:
			context["result_text"] = TXT_R0_A + _foreign_minister_name() + TXT_R0_B
			if zaire != null:
				_leave_alliances(zaire)
				zaire.set_tag("亲中", true)
				zaire.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, -50)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 10)
			ws.influence_prc += 10
			_add(W.I_THOUGHT_FREEDOM, -20)
			_add(W.I_ARMY, -50)
			_add(W.I_BUDGET, -20)
			_start_war(60, TXT_WAR0_NAME, TXT_WAR0_SIDE1, TXT_WAR0_SIDE2, 600 + num, 400 - num, 0, 1, 9)
		1:
			context["result_text"] = TXT_R1
			if zaire != null:
				zaire.set_tag("对华贸易", false)
			_add_relation(EmpireData.USSR, 50)
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USSR, 10)
			if angola != null:
				angola.set_tag("对华贸易", true)
			_start_war(60, TXT_WAR1_NAME, TXT_WAR1_SIDE1, TXT_WAR1_SIDE2, 600 - num, 400 + num, 0, 1, 9)
			_add(W.I_BUDGET, -20)
		2:
			context["result_text"] = TXT_R2
			if zaire != null:
				zaire.set_tag("对华贸易", false)
			_add_relation(EmpireData.USSR, -100)
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 20
			_add(W.I_ARMY, -50)
			_add(W.I_BUDGET, -50)
			_start_war(60, TXT_WAR2_NAME, TXT_WAR2_SIDE1, TXT_WAR2_SIDE2, 600 - num, 400 + num, 0, 1, 9)
		3:
			context["result_text"] = TXT_R3
			_start_war(60, TXT_WAR3_NAME, TXT_WAR3_SIDE1, TXT_WAR3_SIDE2, 600 - num, 400 + num, 0, 1, 6)






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

func _foreign_minister_name() -> String:
	if ws != null and ws.politics_positions.size() > 2:
		var idx: int = ws.politics_positions[2]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
				and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return "黄华"

func _war_going(war_id: int) -> bool:
	var war := _get_war(war_id)
	return war != null and war.is_going

func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)

func _establish_prosoviet(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲苏", true)
	c.set_tag("亲中", false)
	c.set_tag("亲美", false)

func _start_war(war_id: int, war_name: String, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, tick_time: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	var war := _get_war(war_id)
	if war != null:
		war.name_war = war_name
		war.fortnight_max = tick_time

func _free_puppets(overlord: int) -> void:
	if ws == null:
		return
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			c.puppet_of = GameConstants.LegacySlot.NONE


