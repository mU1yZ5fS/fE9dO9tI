extends "res://数据脚本/event_script_base.gd"

## 原作 Event599.cs：医疗队员到坦桑（坦桑尼亚战后援助，三选项）。
## 触发：ReqEventForDLC02.cs:849-851 —— event_done[598] && !war53.is_going && !c122.econ。
## 差异：描述按 c118.SubGosstroy==15 动态插入维和经费句；EstablishGovernment(ProChina)→亲中 true。

const TXT_DESC_A := "自坦噶尼喀独立以来，坦噶尼喀总统朱利叶斯·尼雷尔便坚持社会主义立场，1964年坦噶尼喀和社会主义革命后的桑给巴尔合并为坦桑尼亚联合共和国，1967年坦桑尼亚总统尼雷尔颁布《阿鲁沙宣言》，坦桑尼亚开始实行乌贾马社会主义，并开始实行乌贾马式合作社，将企业大量收归国有，但由于尼雷尔对于建成乌贾马社会主义的期望过于急切，大量乌贾马村被行政命令建成，加上随之而来的1974-1975年严重干旱灾害，导致农业损失惨重，尼雷尔被迫仅保留小部分乌贾马村，并将之前建立的大量乌贾马村进行“村子化”（即退回初级合作社）。在坦桑尼亚成立之后，坦桑尼亚首先承认我们并与我国持续亲密的关系，我国一直在坦桑尼亚援助建设，建成了包括坦赞铁路等项目。\n在乌坦战争爆发之后，刚从1974-1975年严重干旱灾害中恢复过来的坦桑尼亚经济遭到了毁灭性打击：战争期间政府将大量资金投入于国防之中并暂停其他部门的所有工程，战争导致卡盖拉地区经济损失超一亿美元，而在战争之后，因军队规模的扩大所造成的巨量国防开销"
const TXT_DESC_MID := "和驻扎乌干达的维和经费"
const TXT_DESC_B := "则加大了政府赤字。而在政府内部，腐败现象逐渐普遍。为缓解战后过重的经济负担，坦桑尼亚开始对外寻求经济援助，这其中自然就包括了我们。我们是否应该完全承包下坦桑尼亚的财政赤字？或者如果我们和苏联关系甚好，我们和苏联一起承担坦桑尼亚的财政赤字？亦或者如果我们囊中羞涩，或许只需要帮他们稍微缓解一点经济负担尽一点盟友的责任？"
const TXT_OPT0_DIS := "我们还是囊中羞涩啊"
const TXT_OPT1_DIS := "和苏联一起？你在开什么玩笑？"
const TXT_R0 := "我们决定全部承担坦桑尼亚的全部赤字，为坦桑尼亚提供大量低息甚至无息贷款并在坦桑尼亚再次进行一系列的援建工程，包括不限于援建工厂，修建水利工程等，并派出我们的顾问对坦桑尼亚经济问题进行指导。在我们顾问的指导下，战争期间大量新征召的坦桑尼亚人民国防军士兵分批次进行退役，将退役士兵进行简单的职业技能培训，并将部分回乡士兵组织成当地民兵骨干，坦桑尼亚政府开始进一步清理腐败问题，腐败现象被进一步遏制，人们口中的“奔驰人”（wabenzi）即贪官出现的越来越少，在我们付出了如此多的努力之后，我们仅要求让前乌玛党主席阿卜杜勒拉赫曼·穆罕默德·巴布回归政坛，其不赞成尼雷尔温和的乌贾马式社会主义并因为前桑给巴尔总统阿贝德·阿马尼·卡鲁梅刺杀案而被错捕，坦桑尼亚在我们的帮助下顺利的解决了经济问题，并未因为经济问题而转变乌贾马社会主义的立场和违背《阿鲁沙宣言》，尼雷尔十分感激我们的援建工程，坦桑尼亚俨然成为了中国在非洲建设的榜样。"
const TXT_R1 := "我们决定利用与苏联的良好关系来帮助坦桑尼亚解决经济问题，我们和苏联的低息贷款大量进入坦桑尼亚的同时，苏联也开始投资桑给巴尔的丁香产业，坦桑尼亚人民国防军则在苏联顾问的指导下开始进行改编，乌贾马式合作社得到发展，但是苏联的这些援助并非免费的午餐，作为条件，坦桑尼亚必须加入经互会。尽管坦桑尼亚对我们的好感大于苏联，但是苏联的影响力与日俱增，终有一天会赶超我们的。"
const TXT_R2 := "我们之前援建的已经足够多了，但是看在中坦两国友谊的份上，我们决定提供一定数额的低息贷款以缓解坦桑尼亚的经济问题。尽管如此，坦桑尼亚所面临的财政赤字依旧十分巨大。在拒绝了国际货币基金组织提供的贷款条件之后，坦桑尼亚被迫逐步放宽经济政策……"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 3
	var uganda := world.get_country_by_legacy_index(118)
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	var desc := TXT_DESC_A
	if uganda != null and uganda.sub_government == GameConstants.SubGovernment.PRAGMATIST:
		desc += TXT_DESC_MID
	desc += TXT_DESC_B
	event_def.description = desc
	if line < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line < 3 and (world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations >= 700 or (china != null and china.has_tag("sev"))):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var tanzania := _country(122)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_BUDGET, -80)
			if tanzania != null:
				tanzania.government = GameConstants.Government.SOCIALIST
				tanzania.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(tanzania)
				_establish_prochina(tanzania)
				tanzania.set_tag("对华贸易", true)
				tanzania.social_stability = 1000
			ws.influence_prc += 10
		1:
			context["result_text"] = TXT_R1
			_add(W.I_BUDGET, -40)
			if tanzania != null:
				tanzania.government = GameConstants.Government.SOCIALIST
				tanzania.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(tanzania)
				_establish_prochina(tanzania)
				tanzania.social_stability = 1000
				tanzania.set_tag("对华贸易", true)
				tanzania.set_tag("sev", true)
			ws.influence_prc += 5
			_add_power(EmpireData.USSR, 25)
			_add_relation(EmpireData.USSR, 100)
		2:
			context["result_text"] = TXT_R2
			_add(W.I_BUDGET, -50)
			if tanzania != null:
				tanzania.government = GameConstants.Government.REFORMIST
				tanzania.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				_leave_alliances(tanzania)
				_establish_prochina(tanzania)
				tanzania.social_stability = 1000
				tanzania.set_tag("对华贸易", true)
			ws.influence_prc += 5






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
			c.puppet_of = -1


