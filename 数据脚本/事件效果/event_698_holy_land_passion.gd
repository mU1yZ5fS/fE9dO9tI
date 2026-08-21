extends "res://数据脚本/event_script_base.gd"

## 原作 Event698.cs：圣地受难日（麦加大清真寺遇袭，三选项）。
## 触发：ReqEventsDLC02.cs:1334-1336 —— DATE_AFTER 1979.11.20 && c8.SubGosstroy!=13
##   → trigger_script evaluate（原版省略月份日条件等价于 1979.11.20 起）。

const TXT_OPT0_DIS := "我们不会掺和一群反动派的内斗"
const TXT_OPT1_DIS := "我们不会掺和一群反动派的内斗"
const TXT_R0 := "虽然这些极端分子并非善类，但他们能够搅乱中东最大反动堡垒的局势，这对我们而言就足够了。因此，我们的情报机构通过特殊渠道，向“萨拉菲正义组织”提供了王室高层人员及国王本人的具体位置信息，并指明了安保最薄弱的时间段。这群意图颠覆政权的武装分子心领神会，趁沙特政权将绝大部分注意力集中在圣地事件之际，集结了未参与禁寺袭击的剩余成员，利用我们提供的武器与情报，策划并发动了对王室成员的直接袭击。以迅雷不及之势成功绑架了国王兼首相哈立德，以及财政部长穆罕默德凯尔、内政部长纳夫亲王等一系列高级王室成员。\n不过，实际掌权者法赫德王储成功躲过了袭击，并迅速组织起临时替代政府，以维持全国事务的运转。即使如此，囚禁着国家最高权力象征的武装分子，似乎已能看到胜利的曙光。沙特王朝的统治似乎来到了生死存亡的转折点，稍有疏忽，根基不稳的法赫德政权就会轰然崩塌。\n与此同时，在巴基斯坦、利比亚以及其他政治伊斯兰日益壮大的地区，不少情绪激动的信徒也袭击了美国使馆。这引起了美国政府的高度警惕，并进一步加深了对伊朗的敌视。美方开始正视“革命伊斯兰”的输出活动，并着手实施高强度打压。显然，转向政治行动主义的现代伊斯兰主义已不再仅仅是伊朗一国的转型倾向——它即将向整个中东传递一种新时代来临的信号……"
const TXT_R1 := "即便沙特王室腐败无能，但其统治肯定比极端分子更加有利于我方。更重要的是，若现代经济的命脉之一——石油被偏执的宗教激进势力所掌控，所带来的政治波浪将绝不仅是轻微涟漪。因此，我国特勤人员秘密前往沙特，向沙特军事领导人及哈立德国王表明了支援意愿。在法国狙击手、沙特特种部队与我方情报人员的协同配合下，恐怖分子被逐个清除，且行动过程中最大限度地减少了平民伤亡。经此事后，由法赫德王储主导的沙特内阁进一步强化了伊斯兰主义与国家政治的融合，将国内乌理玛集团牢牢掌控在己方手中，并将那些过于活跃的圣战分子转送至阿富汗与巴勒斯坦等地，以消解潜在隐患。此外，哈立德国王与法赫德王储对我国在此次事件中提供的“反恐协助”深表感谢。尽管当前的冷战大气候暂时限制了他们与我国展开更深层次的交流，但国王许诺将在适当时机向这个他“向来关注的东方大国”提出一系列互惠互利的合作倡议。\n与此同时，在巴基斯坦、利比亚以及其他政治伊斯兰日益壮大的地区，不少情绪激动的信徒也袭击了美国使馆。这引起了美国政府的高度警惕，并进一步加深了对伊朗的敌视。美方开始正视“革命伊斯兰”的输出活动，并着手实施高强度打压。显然，转向政治行动主义的现代伊斯兰主义已不再仅仅是伊朗一国的转型倾向——它即将向整个中东传递一种新时代来临的信号……"
const TXT_R2 := "为寻求协助镇压伊赫万组织的反攻行动，沙特方面向法国提出紧急援助请求，法国随即派遣国家宪兵干预组（GIGN）顾问部队前往支援。在法国特工向沙特军队提供了一种可削弱攻击性、阻碍呼吸的特种催泪瓦斯后，沙特军队向麦加大清真寺内部施放瓦斯并强行突入。经过两周激战，沙特方面成功控制了该地点。围困事件共造成270人死亡，另有68人随后被处决。\n在收复麦加大清真寺的行动中，沙特军队击毙了自封“救世主”的卡赫塔尼。朱海曼及另外68名武装分子被生擒，随后被沙特当局判处死刑，并在沙特多个城市公开斩首示众。\n伊赫万组织对麦加大清真寺的围困事件，正值邻国伊朗爆发伊斯兰革命之际，此举进一步引发了整个穆斯林世界的动荡。伊朗宗教领袖鲁霍拉·霍梅尼在广播中宣称，麦加大清真寺遇袭事件系美国与以色列策划，导致多个穆斯林占多数的国家爆发大规模反美骚乱。\n事件发生后，沙特国王哈立德·本·阿卜杜勒-阿齐兹在全国范围内推行更为严苛的伊斯兰法律体系，并在随后十年间赋予乌莱玛（伊斯兰宗教学者阶层）更大权力。与此同时，沙特伊斯兰宗教警察的权力也进一步强化。\n假装虔信的瓦哈比主义和基要主义的萨拉菲主义到底哪个好？现在是真理标准大讨论时间，但批判的武器不能代替武器的批判……"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if _res(W.I_POLITICAL_LINE) != 0:
		_enable(opt[0], event_def.options[0].text)
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -70)
			_add_relation(EmpireData.USA, -100)
		1:
			context["result_text"] = TXT_R1
			_add(W.I_ARMY, -50)
			_add(W.I_AGENTS, -50)
			_add_relation(EmpireData.USA, 100)
			var saudi := ws.get_country_by_legacy_index(101)
			if saudi != null:
				saudi.set_tag("对华贸易", true)
			ws.oil_prod += 100.0
			_add(W.I_BUDGET, 100)
		2:
			context["result_text"] = TXT_R2


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19791120:
		return false
	var c8 := world.get_country_by_legacy_index(8)
	return c8 == null or c8.sub_government != GameConstants.SubGovernment.NEOPATRIARCHAL
