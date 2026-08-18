extends "res://数据脚本/event_script_base.gd"

## 原作 Event881.cs：罗得西亚永不灭亡？（津巴布韦1980大选，单选项四结果分支）。
## 触发：TimeScript.cs:10731-10737 ——
##   ((日>=18 且 月>=4 且 年>=1980) || (月>=5 且 年>=1980) || 年>=1981)。
## 差异：
##  - 非洲国家集合计数逐项移植；resultOf[609] 用 completed_event_ids（缺省-1）；
##    resultOf[88]==0 → num3=114514 大数分支保留。
##  - load_scene_after_click → 882 链：Godot 用 EventEngine.enqueue_chain(["event_882"])
##    （882 尚移植说明时入队后自动跳过，链式语义保留）。
##  - <color> 标签去除。

const TXT_UANC := "顺应时代的浪潮，联合非洲民族委员会设法在大选中取得了略微的优势，以38票的相对多数和津民盟-爱国阵线的温和派组成了联合政府。罗得西亚阵线党取得了全部的20个“白名单”南罗得西亚正式从英国独立，末代总督索姆斯勋爵在告别了索尔兹伯里（现在更名为哈拉雷）后踏上了归国的飞机。而穆佐雷瓦成为该国第一任首相，西索尔成为了该国第一任总统。该国宣布建立一个类似西方的多党制共和国。并开始着手建立和周围国家的关系，白人地主的财产仍然得到了保留，他们也欢迎外国企业来津巴布韦投资。"

const TXT_ZAPU := "出乎意料的是，恩科莫的ZAPU和津巴布韦民主党的联盟击败了诸多竞争对手，以及其死对头所带领的津民盟-爱国阵线，取得了43票的惊人成绩。津民盟-爱国阵线方面怒不可遏，该党的发言人谴责ZAPU在选举中舞弊，称他“收了英国和南非的贿赂”。但在联合国和英国的监察部队中并没有展现出任何作弊的现象。很快，世界上另一段的超级大国苏联宣布承认南罗得西亚的政权更迭和选举结果。也是世界上第一批承认该国的国家之一。罗得西亚阵线党取得了全部的20个“白名单”南罗得西亚正式从英国独立，末代总督索姆斯勋爵在告别了索尔兹伯里（现在更名为哈拉雷）后踏上了归国的飞机。恩科莫宣布将ZAPU宣布改组为津巴布韦人民革命党，正式接纳了马克思-列宁主义和反帝国主义。该国试着在可以接纳的范围内借鉴苏联的经验，展开缓慢的土地改革。但是大量跨国公司被公有化或者被赎买。许多前地主越过国境线逃亡南非寻求庇护。而合并两支游击队的行为看起来是如此的缓慢，部分前ZANLA（津巴布韦非洲民族解放军）成员甚至和部落民兵勾结在一起，展开了又一场叛乱。而古巴志愿者也已经出现在布拉韦约等地协助平叛。"

const TXT_ZANUPF := "毫不客气的说，这一结果是肯定的。津民盟-爱国阵线在漫长的祖国解放战争中立下的赫赫战功几乎让其锁定了领导地位，但没人想象的到这一切来的如此之快。80个共同席位中的57个，使其在100名成员的众议院中占多数。约书亚·恩科莫的津巴布韦非洲人民联盟作为爱国阵线参加选举，赢得了80个共同席位中的20个，其余3个席位将转给则属于阿贝尔·穆佐雷瓦的非洲联合全国委员会。伊恩·史密斯的罗得西亚阵线赢得了所有20个白名单席位，其大多数候选人无异议参选。\n由于我们提供的安保人员，约书亚·通戈加拉，津民盟-爱国阵线的武装组织ZANLA的最高指挥官同志，穆加贝最有力的竞争对手得以在一场针对他的政治暗杀中存活下来。这为他赢得了足够的人气，在津民盟第6届全国代表大会上，他得以当选为总书记，身兼新政府总理一职。穆加贝则成为了他忠实的战友，也就是新政权的总统。该国宣称为建立一个“科学社会主义的泛非共和国”而奋斗。他们也正式把马克思列宁主义和毛泽东思想作为写入了党章，称其为“适用于津巴布韦革命经验的宝贵财富”。津巴布韦进入的是“民族民主革命”，因此应该在打击封建大地主和原部落酋长的前提下，稳扎稳打的在津巴布韦建设社会主义，尤其要注重处理土地和白人的关系。一场稳定的土地改革正在进行中，大多数外资企业则被国有化或被联合经营。赞比亚与坦桑尼亚为该国提供了一笔援助，社会主义的理想在非洲大陆又一次得到了实现。"

const TXT_MODERATE := "毫不客气的说，这一结果是肯定的。津民盟-爱国阵线在漫长的祖国解放战争中立下的赫赫战功几乎让其锁定了领导地位，但没人想象的到这一切来的如此之快。80个共同席位中的57个，使其在100名成员的众议院中占多数。约书亚·恩科莫的津巴布韦非洲人民联盟作为爱国阵线参加选举，赢得了80个共同席位中的20个，其余3个席位将转给则属于阿贝尔·穆佐雷瓦的非洲联合全国委员会。伊恩·史密斯的罗得西亚阵线赢得了所有20个白名单席位，其大多数候选人无异议参选。由于选举的结果，罗伯特·穆加贝于1980年4月11日成为津巴布韦独立后的第一任总理。该国宣称为建立一个“民族主义的，社会主义的泛非共和国”而奋斗。他们也正式把津巴布韦化的马克思主义作为其意识形态写入了党章。同时宣传自己进入的是“民族民主革命”。他们同时保证了不会针对前白人时期的暴政展开无底线报复，许诺十年内不干涉白人地主的权力，他们可以自由选择离开津巴布韦或者留下来。总体来说，津巴布韦进入了新的时代。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var num := 0
	var num2 := 0
	for c in ws.countries:
		if c == null:
			continue
		var i := c.原版序号
		var in_set := (i >= 52 and i <= 68) or (i >= 106 and i <= 108) \
			or (i >= 112 and i <= 133) or i == 13 or i == 18 or i == 40 \
			or i == 41 or i == 42 or i == 99 or i == 100
		if not in_set or i == 128:
			continue
		if c.has_tag("亲苏"):
			num2 += 1
		if c.government == 3:
			num += 1
	if ws.completed_event_ids.get("event_609", -1) == 1:
		num2 += 1
	var num3 := 0
	if ws.completed_event_ids.get("event_088", -1) == 0:
		num3 = 114514
	var zimbabwe := ws.get_country_by_legacy_index(127)
	var mozambique := ws.get_country_by_legacy_index(126)
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	if ws.completed_event_ids.get("event_088", -1) == 1 or (num >= 6 and num > num2 and num > num3):
		if zimbabwe != null:
			zimbabwe.name = "津巴布韦共和国"
			zimbabwe.chinese_name = "津巴布韦共和国"
			zimbabwe.government = 3
			zimbabwe.sub_government = 5
		if mozambique != null:
			mozambique.level_of_instability -= 50
		context["result_text"] = TXT_UANC
	elif num2 >= 6 and num2 > num3 and num2 > num:
		if zimbabwe != null:
			zimbabwe.name = "津巴布韦人民共和国"
			zimbabwe.chinese_name = "津巴布韦人民共和国"
			zimbabwe.government = 2
			zimbabwe.sub_government = 3
			zimbabwe.set_tag("亲苏", true)
		if mozambique != null:
			mozambique.level_of_instability += 30
		context["result_text"] = TXT_ZAPU
	elif num3 != 0:
		if zimbabwe != null:
			zimbabwe.name = "津巴布韦民主人民共和国"
			zimbabwe.chinese_name = "津巴布韦民主人民共和国"
			zimbabwe.government = 1
			zimbabwe.sub_government = 17
			zimbabwe.set_tag("亲中", true)
			zimbabwe.set_tag("对华贸易", true)
			_join_our_alliances(zimbabwe)
			zimbabwe.social_stability = 1000
		if mozambique != null:
			mozambique.level_of_instability += 50
		context["result_text"] = TXT_ZANUPF
	else:
		if zimbabwe != null:
			zimbabwe.government = 2
			zimbabwe.sub_government = 15
			zimbabwe.set_tag("亲中", true)
			zimbabwe.set_tag("对华贸易", true)
			zimbabwe.name = "津巴布韦共和国"
			zimbabwe.chinese_name = "津巴布韦共和国"
		if mozambique != null:
			mozambique.level_of_instability += 30
		context["result_text"] = TXT_MODERATE
	# 原版 load_scene_after_click → number_event=882：链式触发
	if zimbabwe != null and zimbabwe.sub_government != 5:
		var c131 := ws.get_country_by_legacy_index(131)
		if c131 != null and c131.sub_government == 9 \
				and not (ws.wars.size() > 54 and ws.wars[54] != null and ws.wars[54].is_going):
			EventEngine.enqueue_chain(["event_882"])


## Country.cs:42-86 JoinAllOurAlliances 核心联盟跟随逻辑。
func _join_our_alliances(c: CountryData) -> void:
	var player := ws.get_country_by_legacy_index(1)
	if player == null:
		return
	if player.has_tag("okb"):
		c.set_tag("okb", true)
	elif player.has_tag("ovd"):
		c.set_tag("ovd", true)
	elif player.has_tag("seato"):
		c.set_tag("seato", true)
	if player.has_tag("econ"):
		c.set_tag("econ", true)
	elif player.has_tag("sev"):
		c.set_tag("sev", true)
	elif player.has_tag("asean"):
		c.set_tag("asean", true)
