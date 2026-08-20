extends "res://数据脚本/event_script_base.gd"

## 原作 Event578.cs：萨帕塔的孩子们……（墨西哥恰帕斯，四选项）。
## 触发：ReqEventForDLC02.cs:799-802 —— (日>=17 且 月>=11 且 年>=1983) || (月>=12 且 年>=1983) || 年>=1984
##   → DATE_AFTER 1983.11.17。
## 差异：
##  - 选项显隐 prepare 动态改写；proprc/prosov → 亲中/亲苏；influencePRC → ws.influence_prc；
##  - resultOfEvents[577] 缺省按原版 int 默认 0；cw → 内战中；stab → country.stab；
##  - parts[1] 写前 resize；AmericanSupportAttacker.SovietSupportDefender → usa_side=0/ussr_side=1；
##  - TickTime(24) → fortnight_max=24。



const TXT_OPT0_DIS := "我们鞭长莫及啊……"
const TXT_OPT1_DIS_WHY := "为什么墨西哥不能直接走上社会主义的康庄大道？"
const TXT_OPT1_DIS_INDIAN := "没有必要支持一群流氓一样的印第安人"
const TXT_OPT2_DIS := "这未免太残酷了"

const TXT_R0 := "借助EZLN的老相识，新崛起的人民革命军迅速和EZLN搭上了关系，游击活动开始变得更加广泛和激进，随着墨西哥经济的进一步下行，当地工人以及贫困农民很快加入了人民革命军的左翼地下小组。得益于我国慷慨的援助，有组织的游击队迅速发展壮大并和来自城市的工人和原住民以外的地方贫农结成同盟。很快，从原住民地区开始蔓延的游击活动超出了当地警察和安全部队所能控制的界限，甚至发生了效法70年代穷人党游击队的绑架活动——人民革命军大规模地绑架墨西哥政治家和地方公务员，开展一系列旨在摧毁墨西哥政府行政能力的行动。墨西哥政府从全国调集了数万名士兵进驻恰帕斯州并展开大规模的“清乡活动”，然而人民革命军不会屈服，决定给来犯之敌迎头痛击！"
const TXT_R1_A := "很快，人民日报刊登了一批揭露恰帕斯州原住民和其他边缘群体受到迫害的证据。我国的外交部和联合国发言人也开始指责墨西哥政府在恰帕斯地区的“殖民主义”。墨西哥政府没有料到这些事情居然遭到了中国如此严厉的指责。很快。墨西哥统一社会党和左翼游击队开始声援当地居民并展开游击活动。这使得墨西哥陆军和联邦安全局力量在当地迅速增长……地区主教萨缪尔·加西亚也对当地日益增长的暴力冲突感到忧虑。"
const TXT_R1_B := "很快，人民日报刊登了一批揭露恰帕斯州原住民和其他边缘群体受到迫害的证据。我国的外交部和联合国发言人也开始指责墨西哥政府在恰帕斯地区的“殖民主义”。墨西哥政府没有料到这些事情居然会遭到中国如此严厉的指责。现在，国际组织开始呼吁改善墨西哥恰帕斯州原住民和处境以及保护当地特色文化。借此，拉坎顿丛林地区得到了关注。虽然墨西哥政府没有进一步行动，但对当地左派活动家的迫害被停止了。不过，这真的有意义吗？"
const TXT_R2 := "在MSS的积极协调下，我们设法获取了一些EZLN成员的名单和他们目前的所处地址。很快，借助我们与CIA的关系，我们将名单交给了墨西哥政府。我们给予了墨西哥一笔军事和情报援助以支持他们打击全国上下的各种左翼反对派，同时，借助我们与右翼的良好关系，我们得以与恰帕斯州的民团开展合作，一同开展剿匪行动。于是，EZLN许多高级成员被联邦法警逮捕和秘密处决……其中就包括所谓的副司令马科斯。现在，拉坎顿地区的原住民运动衰弱了。我们也得以和墨西哥政府以及一些强烈反共的墨西哥政党搭上更好的关系。"
const TXT_R3 := "很快，土地的进一步兼并和贫困化席卷了拉坎顿地区，现在，墨西哥政府既无能力也无意愿干涉当地的土地分配。土著居民的生存权仍然受到威胁……新自由主义经济政策仍然对这些第三世界国家的基层居民构成威胁……"

const WAR45_NAME := "墨西哥起义"
const WAR45_SIDE1 := "墨西哥军方"
const WAR45_SIDE2 := "人民革命军"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var c149 := world.get_country_by_legacy_index(149)
	var r577 := int(world.completed_event_ids.get("event_577", 0))
	var opt := event_def.options
	if line == 0 and c149 != null and (c149.has_tag("亲中") or c149.has_tag("亲苏")) \
			and r577 == 0 and world.influence_prc >= 800:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line >= 1 and line <= 3 and world.influence_prc >= 500:
		_enable(opt[1], event_def.options[1].text)
	elif line == 0:
		_disable(opt[1], TXT_OPT1_DIS_WHY)
	else:
		_disable(opt[1], TXT_OPT1_DIS_INDIAN)
	if data.size() > W.I_WAR_SUPPORT and data[W.I_WAR_SUPPORT] >= 700:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c140 := ws.get_country_by_legacy_index(140)
	if c140 != null:
		c140.government = GameConstants.Government.LIBERAL
		c140.sub_government = GameConstants.SubGovernment.NEOLIBERAL
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var num := 0
			if c140 != null and c140.stab == 1:
				num = 100
			GameManager.start_war(45, WAR45_SIDE1, WAR45_SIDE2, 800 - num, 200 + num, 0, 1)
			if ws.wars.size() > 45 and ws.wars[45] != null:
				ws.wars[45].name_war = WAR45_NAME
				ws.wars[45].fortnight_max = 24
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -80)
			_add(W.I_ARMY, -80)
			_add_relation(EmpireData.USA, -200)
			if c140 != null:
				c140.government = GameConstants.Government.AUTHORITARIAN
				c140.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_set_part(c140, 1, true)
			context["result_text"] = TXT_R0
		1:
			var r577 := int(ws.completed_event_ids.get("event_577", 0))
			if r577 == 1 and c140 != null and c140.内战中 and c140.stab == 1:
				context["result_text"] = TXT_R1_A
			else:
				if c140 != null:
					c140.内战中 = false
				context["result_text"] = TXT_R1_B
			_add(W.I_BUDGET, -50)
		2:
			_add(W.I_AGENTS, -30)
			if c140 != null:
				c140.set_tag("对华贸易", true)
			context["result_text"] = TXT_R2
		3:
			context["result_text"] = TXT_R3


func _set_part(c: CountryData, i: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= i:
		c.parts.append(false)
	c.parts[i] = value
