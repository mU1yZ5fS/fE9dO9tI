extends "res://数据脚本/event_script_base.gd"

## 原作 Event587.cs：提格拉钦（埃塞俄比亚德尔格内斗，四选项）。
## 触发：TimeScript.cs:10887-10893 —— 日>=3 且 月>=2 且 年>=1977
##   （或月>=3 年>=1977 / 年>=1978）。
## 差异：
##  - 选项按 data[56]（政治路线）动态显隐；<color> 标签去除（既有约定）；
##  - LeaveAlliances() → 清全部联盟/倾向标签 + puppet_of=-1；
##    EstablishGovernment(ProChina) → 亲中 true、亲苏/亲美 false；
##    c41.name = "埃塞俄比亚民主联邦共和国" → chinese_name（既有约定）。

const TXT_TITLE := "提格拉钦"

const TXT_DESC := "主席同志，是时候谈谈非洲（过去）最古老的君主制国家埃塞俄比亚了。自1974年的军事政变以来，该国经历着意识形态上的巨大变化。从资本主义的支持者到激进共产主义分子，所有人都希望得到临时军事行政委员会，也就是德尔格的青睐。除了平庸无力的“埃塞俄比亚第一”这样的爱国口号外，军委选择的是社会主义者，他们积极和全埃塞俄比亚社会主义运动和埃塞俄比亚人民革命党展开合作。其中，全埃社运支持临时军委，他们由苏联留学生和工人构成。而埃塞俄比亚人民革命党义正严辞的反对临时军委的长期存在，呼吁快速建立一个先锋党，他们支持毛泽东主席的理论，也支持阿尔巴尼亚的反修正主义思想。\n在1975年9月11日，临时军委正式宣布将走“埃塞俄比亚特色的共产主义道路”。他们公开支持，鼓励各个社会主义和共产主义政党加入群众组织临时办公室。以特法里·本蒂准将为首的温和派临时军委成员甚至准备和埃人革党达成协议，组建一个统一的社会主义的先锋党，用来加速解散临时军委。而这一决定遭到了实权人物门格斯图·海尔·马里亚姆的抵制，绰号“红色尼格斯”的他，曾亲手处死了第一任临时军委主席阿曼·迈克尔·安多姆，而他并不介意再次扫清一位敌人。他在担任副主席的时候，便公开拉偏架打击埃人革党。纵使门格斯图本人也不反对组建一支革命的先锋党，但门格斯图眼里容不得沙子，为此他大力支持由自己领导的“革命火焰”组织。双方的关系已经恶化到了极点。特法里·本蒂多次在会议上指控门格斯图滥杀无辜，而门格斯图则以“潜在的帝国主义者”为理由攻击特法里·本蒂，并派遣军事警察抓捕埃人革党成员。\n主席同志，尽管有些泥菩萨过河，但我们至少该表个态，对吧？"

const TXT_OPT0 := "帮本蒂一把"
const TXT_OPT0_DIS := "他们不愿意听我们的话"
const TXT_OPT1 := "门格斯图，非洲的列宁！"
const TXT_OPT1_DIS := "支持他？这是给我们的敌人递子弹！"
const TXT_OPT2 := "游击战士会把他们双双埋葬！"
const TXT_OPT2_DIS := "对别国内政的干涉太夸张了"
const TXT_OPT3 := "让苏联人自个头疼去吧！"

const TXT_R0 := "我们在人民日报上发表了这样一片文章：《警惕伪装成社会主义的法西斯主义者》，其中提到了埃塞俄比亚的现状。虚假的公有制政策，极力打击真正的左翼政党，并和帝国主义者沆瀣一气。同时我们向特法里·本蒂提供了来自我们的帮助，在1977年2月3日的中央例会上，门格斯图向军委主席本蒂准将汇报工作，在一旁旁听的提格雷代表突然抄起板凳扔向门格斯图，这是行动开始的记号。突然间把脸涂成黑色的中国特工和埃塞俄比亚人民解放军战士从会场后方杀出，在激烈的交火中，门格斯图身中十七枪身亡。随后，特法里·本蒂在电视上发表了特别报告，揭露了门格斯图的不雅往事：在美国留学时花天酒地，在革命时主张美国介入；出卖了埃塞主权；接纳了苏联的政治献金，却仅仅是为了孩子能上莫斯科大学。综上所述，他以反革命罪缺席判处门格斯图死刑（尽管他已经被击毙了）。\n随后，他在电视讲话中宣读了惊人的信息，他宣布临时军事委员会已经圆满完成了民族民主革命的阶段性目标，临时军委将自行解散。并会组建埃塞俄比亚社会主义革命党-马克思列宁主义，一个由埃人革党和左翼军人，贫下中农和势力更小的左翼政党组成的新党。在第一届全埃塞工农兵代表大会上，他被选举为名誉主席和总统，而贝尔哈纳·梅斯克尔·雷达则当选为新任党主席。该党秉持着坚实的毛主义原则，并加速深化土地革命运动，同时积极和厄立特里亚就自治问题达成协议。他们也和我们加大了互动。"

const TXT_R1 := "我们决定支持埃塞俄比亚的实权人物门格斯图上校。意识到他并不是什么坚定的革命者，而是左右摇摆不定的投机家后，这使得我们更容易接触到他。在数盒高级酒心巧克力，20瓶35年茅台，500w打到他私人账户上的美元，一栋在北戴河的度假别墅和给她女儿（尽管只有三岁）准备的清华大学化学专业入学证书后。门格斯图的态度发生了一百八十度的大回环。他在多个场合公开赞扬中国革命的经验，并把毛泽东思想写进了革命火焰的章程中。\n在1977年2月3日的时候，门格斯图指示自己的亲信丹尼尔·安塞法上尉动手。在会议结束后，许多和特法里·本蒂关系紧密的临时军委成员被逮捕后处决。在亚迪斯亚贝巴的群众大会上，门格斯图绘声绘色的描述了本蒂是如何勾结苏联人和美帝的，谴责他的社会主义思想事实上是修正主义，只会破坏临时军委指出的科学社会主义道路。在演讲的最后，他从挎包里掏出了四瓶红色的液体，他高声喊着“和反革命们破罐子破摔吧！打倒美帝，苏修，厄立特里亚人和埃人革党！”随后把四个玻璃瓶砸碎在地上。当天就有数千名被指控为反革命的平民被当众吊死，或者被“消失”了。这段时间在后来被称为“qey\u00a0shibir”（红色恐怖）\n门格斯图也没有忘记是谁给他提供了最多的好处，他公开驱逐了苏联人，并把我们试做革命的标杆。很难说他做的到底是不是毛泽东主席希望看见的，但我们在非洲之角获得了自己的盟友。巴雷也获得了越来越多的苏联援助，希望这不是针对我们的……"

const TXT_R2 := "在南也门和索马里人的帮助下，我们把大量的旧装甲车，63式步枪，56式半自动步枪和大量老旧装备出售给了反政府游击队。像西索马里解放阵线，提格雷人民解放阵线，厄立特里亚解放阵线，埃塞俄比亚人民革命军等组织也在我们的联合下达成了一致，就推翻军委政权的前提下，多方愿意展开合作。亚的斯亚贝巴要越来越头疼了。\n我们不关心军委双巨头之间脆弱的平衡，而这很快就被打破了。在1977年2月3日的时候，门格斯图指示自己的亲信丹尼尔·安塞法上尉动手。在会议结束后，许多和特法里·本蒂关系紧密的临时军委成员被逮捕后处决。在亚迪斯亚贝巴的群众大会上，门格斯图绘声绘色的描述了本蒂是如何勾结美帝的，谴责他的社会主义思想事实上是修正主义，只会破坏临时军委指出的科学社会主义道路。在演讲的最后，他从挎包里掏出了三瓶红色的液体，他高声喊着“和反革命们破罐子破摔吧！打倒美帝，厄立特里亚人和埃人革党！”随后把三个玻璃瓶砸碎在地上。当天就有数千名被指控为反革命的平民被当众吊死，或者被“消失”了。这段时间在后来被称为“qey\u00a0shibir”（红色恐怖）。"

const TXT_R3 := "我们不关心军委双巨头之间脆弱的平衡，而这很快就被打破了。在1977年2月3日的时候，门格斯图指示自己的亲信丹尼尔·安塞法上尉动手。在会议结束后，许多和特法里·本蒂关系紧密的临时军委成员被逮捕后处决。在亚迪斯亚贝巴的群众大会上，门格斯图绘声绘色的描述了本蒂是如何勾结美帝的，谴责他的社会主义思想事实上是修正主义，只会破坏临时军委指出的科学社会主义道路。在演讲的最后，他从挎包里掏出了三瓶红色的液体，他高声喊着“和反革命们破罐子破摔吧！打倒美帝，厄立特里亚人和埃人革党！”随后把三个玻璃瓶砸碎在地上。当天就有数千名被指控为反革命的平民被当众吊死，或者被“消失”了。这段时间在后来被称为“qey\u00a0shibir”（红色恐怖）。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line <= 2:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line != 0 and line != 4:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line <= 1:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var ethiopia := ws.get_country_by_legacy_index(41)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			if ethiopia != null:
				ethiopia.government = 1
				ethiopia.sub_government = 17
				_leave_alliances(ethiopia)
				ethiopia.set_tag("对华贸易", true)
				ethiopia.chinese_name = "埃塞俄比亚民主联邦共和国"
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -80)
			if ethiopia != null:
				ethiopia.government = 0
				ethiopia.sub_government = 10
				_leave_alliances(ethiopia)
				ethiopia.set_tag("亲中", true)
				ethiopia.set_tag("亲苏", false)
				ethiopia.set_tag("亲美", false)
				ethiopia.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 10
			_add(W.I_DIPLO, 5)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_ARMY, -50)
			if ethiopia != null:
				ethiopia.government = 0
				ethiopia.sub_government = 10
			context["result_text"] = TXT_R2
		3:
			if ethiopia != null:
				ethiopia.government = 0
				ethiopia.sub_government = 10
			context["result_text"] = TXT_R3


## Country.LeaveAlliances() 逐项映射（含原版不常见的联盟标签）。
func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)
