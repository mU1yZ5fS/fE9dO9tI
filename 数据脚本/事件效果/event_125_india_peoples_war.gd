extends "res://数据脚本/event_script_base.gd"

## 原作 Event125.cs：不下地是学不会走路的（3 选项）。
## 触发：由 Decision(GlobalScript.cs:34) 手动触发（印度人民战争），原版无自动条件；
## 故 trigger_conditions 为空，本脚本按原版复刻选项显隐与结果效果。

const TXT_OPT1_DIS := "纳萨尔派不会听我们的"
const TXT_OPT2_DIS := "中国在经互会中、军事实力大于25、世界影响力大于35"
const TXT_R0 := "联合阵线因该国困难的政治经济形势而闻名遐迩，在我们的支持下，联合阵线与许多工会结成了联盟，组织了多次罢工，政府因此辞职。在由此产生的权力真空中，联合阵线的武装力量与普通工人一起控制了各城市的行政中心，宣布以联合阵线联盟为基础，组建一个临时政府，并在奥姆普拉卡西·马尔霍特拉将军、阿伦·斯里达尔·维迪亚、斯里尼瓦沙·库玛拉赞·辛格·克里希纳斯瓦米·桑搭吉等将军的支持下，将整个军队拉拢到了他们这边。在军队的支持下，他们开始对异议人士进行迫害，取缔了各反对党，并为社会主义改革做准备。然而，改革还没来得及开始，纳萨尔派地下组织就因这事实上的政变而联合起来，宣布新政府是修正主义的篡权者，是苏中两国的修正主义者的提线木偶，背叛了毛泽东主席的事业，纳萨尔派开始对新政府进行游击战争。右翼叛乱分子也加入了游击队的行列，为了共同的事业，他们与纳萨尔派达成了不可言说的协议。我们需要拯救印度！"
const TXT_R1 := "纳萨尔派因该国困难的政治经济形势而闻名遐迩，背靠我国支持且完成内部整合团结的他们看到了扫除印度一切旧势力的机遇：很快，印共（毛）便在数个农村地区起事并夺取了政权，此后又迅速效法我国30年代的经验组织革命根据地，优势地区组织对攻，劣势地区则游击袭扰。从纸面上看，计划是成功的：联合起来的纳萨尔派在印度许多省份发动了起义，他们依靠农民和落后的遥远部落，宣布夺取了这些地区的政权，对此，政府试图以军队的自行镇压来应对。纳萨尔派计划对军队开展宣传，并将广大农民部落群众送入城市，但他们失算了：在某地，群众取得了成功，打败了士兵，而在某地，军队镇压了叛军。出于遏制叛乱的需要，全国人民大会党、人民党与印度共产党已临时组建联合政府，并开始在各自选区与国防系统中动员力量平叛。一场声势浩大的内战在印度各地爆发了。我们已无处可退了！"
const TXT_R2 := "共产主义者们因该国困难的政治经济形势而在整个印度闻名遐迩，在中国的调解与苏联的肯定下，他们联合起来，组成了一个新的救国阵线。当然，最激进的纳萨尔派人士把我们打成了共产主义事业的叛徒，但这些小团体并不能发挥什么特别作用，联合阵线组织起了不满者，掀起了大规模罢工，政府与各地方统治者因此统统辞职，选举也重新开始。事实上，完全控制了大多数投票站，承诺给穆斯林以自治和权利，并对反对党进行大屠杀而不受惩罚，因为军队拒绝镇压这种大规模的抗议活动，阵线在选举中获得了成功，获得了约40%的议会席位。随后，救国阵线与国大党（社会主义派），即以前的国大党（组织派），一个从国大党主流中分离出来的社会主义政党，以及左翼的小党派结成联盟，形成一个稳定的联盟，以通过法律和修改宪法。这要归功于救国阵线的进步的“城市社会主义，农村资本主义”，旨在使国家向社会主义过渡的印度版新经济政策。"
const TXT_WAR_NAME := "印度内战"
const TXT_WAR_SIDE1_0 := "联合阵线"
const TXT_WAR_SIDE2_0 := "纳萨尔派"
const TXT_WAR_SIDE1_1 := "三党联合政府"
const TXT_WAR_SIDE2_1 := "印共（毛）"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if int(world.completed_event_ids.get("event_466", 0)) == 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if world.数值表[W.I_ARMY] >= 250 and (world.数值表[W.I_INFLUENCE] >= 350 or world.influence_prc >= 350) and china != null and china.has_tag("sev"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


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








func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int, active: bool) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1

func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var india := ws.get_country_by_legacy_index(19)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if india != null:
				india.special_ending = 0
				india.set_tag("亲中", false)
				india.set_tag("亲苏", false)
				india.set_tag("亲美", false)
				india.set_tag("对华贸易", false)
			_set_war_7(TXT_WAR_NAME, TXT_WAR_SIDE1_0, TXT_WAR_SIDE2_0, 1, 0)
			context["result_text"] = TXT_R0
		1:
			if india != null:
				india.special_ending = 1
				india.set_tag("亲中", false)
				india.set_tag("亲苏", false)
				india.set_tag("亲美", false)
				india.set_tag("对华贸易", false)
			_set_war_7(TXT_WAR_NAME, TXT_WAR_SIDE1_1, TXT_WAR_SIDE2_1, 0, 0)
			context["result_text"] = TXT_R1
		2:
			ws.influence_prc += 30
			_add_power(EmpireData.USSR, 30)
			if india != null:
				india.government = 1
				india.sub_government = 1
				india.special_ending = 2
				india.set_tag("亲中", false)
				india.set_tag("亲苏", false)
				india.set_tag("亲美", false)
				_join_alliances(india)
			context["result_text"] = TXT_R2

func _set_war_7(war_name: String, side1: String, side2: String, usa_side: int, ussr_side: int) -> void:
	while ws.wars.size() <= 7:
		ws.wars.append(WarData.new())
	var war := ws.wars[7]
	if war == null:
		ws.wars[7] = WarData.new()
		war = ws.wars[7]
	war.name_war = war_name
	war.is_going = true
	war.side1 = side1
	war.side2 = side2
	war.usa_side = usa_side
	war.ussr_side = ussr_side
	war.infl1 = 400
	war.infl2 = 600

