extends "res://数据脚本/event_script_base.gd"

## 原作 Event559.cs：摩洛哥的柏林墙（西撒哈拉，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:397-399 —— (1980.8.15 或 1980.9 或 1981+)。
## 差异：描述/结果由 prepare/execute 动态拼领袖姓名；cw→内战中。

const TXT_DESC_A := "同志，是时候谈谈我们远处的国家摩洛哥了。作为最早的和我们建交的非洲国家之一，在某些时候我们也不得不为此蒙羞。这个国家积极充当美国帝国主义的马前卒，在非洲挫败各个人民民主政权。阿尔及利亚和贝宁与几内亚都有过摩洛哥王国卫队的身影。而该国虽是非洲国家，却是其中少见的“次帝国主义”。根据《马德里协定》，西班牙从西属撒哈拉撤军后，冲突升级。从1975年开始，西撒人阵在阿尔及利亚的支持下和摩洛哥展开了漫长的游击战争。1976年2月，西撒人阵宣布成立撒哈拉阿拉伯民主共和国，该国尚未得到我国的承认。1977年毛里塔尼亚单方面和西撒人阵结束战争并承认其独立之后，摩洛哥成为了西撒人阵最主要的敌对力量。\n为了打击反政府武装，摩洛哥政府特别拨款开始修建一堵绰号“沙墙”的准军事设施。其配备有瞭望塔，炮兵雷达，狙击手和地雷阵。“沙墙”是一堵2米高的墙，牢牢占据着制高点。每5公里分别有大型、小型和中型基地，每个站点大约有35-40名士兵，距离也有10名士兵。每个主要哨所后面约4公里有一个快速反应哨站，驻有机动部队用以围剿反抗军。一系列重叠的固定雷达和移动雷达也放置在整个护堤上。据估计，雷达的射程在西撒人阵控制的领土上有60至80公里，通常用于对检测到的西撒人阵部队进行炮击。而一期工程将包括“有用的三角地”，即西撒哈拉首府阿尤恩，斯马拉和布克拉的人口密集区与盐酸矿区。\n据信，西撒人阵将对该工程展开一场突袭，但我们可以火上浇油，为西撒哈拉人民的武装斗争送上来自东方的支持。但也许和摩洛哥人打好关系更重要？"
const TXT_DESC_B := "同志，我们的方针告诉了我们该支持谁，但这样真的值得吗？"
const TXT_OPT0_DIS := "绝不给非法政府站台！"
const TXT_R0_A := "我国的外交态度一转过去的妥协态度。我们不仅公开承认了阿拉伯撒哈拉民主共和国，还驱逐了两位摩洛哥外交大使，并在北京开设了阿拉伯撒哈拉民主共和国代办处。“这是必要的一步，中华人民共和国仍然像过去一样为全世界渴望得到自由，独立和民主的人民提供坚实的护盾。”《人民日报》的社论如是说到。西撒人阵总书记穆罕默德·阿卜杜勒·阿齐兹派代表向"
const TXT_R0_B := "同志表示了感谢，并在流亡政府的驻地以"
const TXT_R0_C := "同志的名字命名了一座新学校。摩洛哥王室对我们“承认伪政府”的举动感到不解与愤怒，他们驱赶了我们的三名大使馆秘书，我们与摩洛哥的关系显著降温了。
我们为西撒人阵提供了一笔丰厚的军事援助。在西撒人阵的特别会议上，马克思列宁主义的原则被正式接纳，而其中也包括我们共和国的缔造者毛泽东主席的游击作战理论。一批军火通过阿尔及利亚人的手送往了廷杜夫，而这些武器将会用来打击邪恶的内殖民主义者。很快，城墙的修建工作因为持续不断的武装骚扰而被迫延期。"
const TXT_R1 := "我们在《人民日报》上提及了摩洛哥所建设的城墙，并把它与我国历史上知名的长城所媲美。“摩洛哥人民开创性的将防御工事与生产相结合，一手拿枪一手拿稿。为保护祖国的和平稳定作出了突出贡献”。摩洛哥国王哈桑二世拍来了表示赞同的电报，称"
const TXT_R1_TAIL := "同志是当代非洲国家的领军人，而摩洛哥将坚定的和中华人民共和国站在一起，反抗殖民主义者。我们提出派遣一支工兵代表团前去学习先进经验，得到了摩洛哥方面的赞同。而阿尔及利亚非常反感这一举措，他们宣布驱逐我们大使馆的一名三等秘书。
西撒人阵如期举行了针对城墙的袭击，但城墙仍然在有条不紊的建设中，而这何时会是个头呢？"
const TXT_R2 := "我们没有表态，他们也不需要我们的表态。城墙依然在有条不紊的建设中，何时会是个头呢？"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var n := _leader_name()
	event_def.description = n + TXT_DESC_A + n + TXT_DESC_B
	if event_def.options.size() < 3:
		return
	if d.political_line <= 1:
		_enable(event_def.options[0], event_def.options[0].text)
	else:
		_disable(event_def.options[0], TXT_OPT0_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c18 := ws.get_country_by_legacy_index(18)
	var c54 := ws.get_country_by_legacy_index(54)
	var n := _leader_name()
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if c18 != null:
				c18.内战中 = true
			if c54 != null:
				c54.set_tag("对华贸易", false)
			_add_relation(EmpireData.USSR, 50)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_ARMY, -50)
			context["result_text"] = TXT_R0_A + n + TXT_R0_B + n + TXT_R0_C
		1:
			if c54 != null:
				c54.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 50)
			_add(W.I_DIPLO, 50)
			context["result_text"] = TXT_R1 + n + TXT_R1_TAIL
		2:
			context["result_text"] = TXT_R2


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
