extends "res://数据脚本/event_script_base.gd"

## 原作 Event553.cs：新意属东非？（意大利-索马里，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1549-1551 ——
##   event_done[434] && IsAuthoritarianism(42) && c42.SubGosstroy==7 && c42.Vyshi
##   && (resultOfEvents[481]==1 || resultOfEvents[481]==2)。
## 差异：描述/选项按 c85.SubGosstroy==22 动态改写。

const TXT_TITLE := "新意属东非？"
const TXT_DESC_22 := "革命民族主义在意大利母国的胜利极大的刺激了西亚德·巴雷少将。在欧加登的灾难性冒险之后，索马里民主共和国进入了灾难性的岁月：经济停滞，内政崩溃而低烈度反叛如波涛般涌起。无意驰援摩加迪沙的美利坚合众国伤透了巴雷的心，而这给了罗马方面一个新的机会。佛朗哥·弗雷达的意大利人民国正式向索马里民主共和国伸出了橄榄枝，包括了改建道路、翻修建筑、大兴基建、提供军事援助与帮助平叛。而索马里承诺将为意大利企业开采当地资源和发展畜牧业提供税收优惠，并提供49年的特许经营权，意大利还获得了摩加迪沙港口的一处土地作为海外保障基地。如今，大批意大利人的投资和意大利军人正开赴索马里，巴雷也在意大利顾问的帮助下改造国家。他颁布了一份新的宪法并修改了索马里革命社会主义党章程。在尊重索马里古老的伊斯兰互助传统和马克思主义的经济原理之外，额外吸纳了意大利革命的先进经验，奉行“3M主义”为指导思想的巴雷主义正在成为显学。联合国与美国对东非的政治变化深感遗憾。"
const TXT_DESC_OTHER := "随着意大利的再法西斯化，他们将目光投向了日益陷入困境的巴雷政权。巴雷政权自欧加登战争失败以后便转向投靠美国，他在国内愈加腐败和专权，巴雷所属部族与他的家族成为了索马里最有权势的集团。这种统治激起了其他部族的反抗。如今，反抗运动已大有夺权之势。在这一背景下，意大利政府决定重返索马里，他们向巴雷伸出了橄榄枝。尽管遭到联合国与美国的抗议，意大利还是与索马里签订了新发展协定：作为交换意大利对当地的二度投资，包括改建道路、翻修建筑、大兴基建、提供军事援助与帮助平叛的筹码；索马里承诺将为意大利企业开采当地资源和发展畜牧业提供税收优惠，并提供49年的特许经营权。如今，大批意大利人的投资和军队正开赴索马里，巴雷也在意大利顾问的帮助下改造国家。"
const TXT_OPT0_22 := "谴责意大利扩张主义"
const TXT_OPT1_22 := "机会难得，我们也该在索马里上敲一笔"
const TXT_OPT0 := "谴责意大利在东非地区的扩张"
const TXT_OPT1 := "向索马里提供援助，以交换关税减免"
const TXT_R0_22 := "我们强烈谴责意大利对非洲的新殖民主义政策，称其是“新意属东非”。然而，我们的批判对意大利人来说不痛不痒，他们仍继续实行其掠夺性政策。人民国和意大利的贸易正在如火如荼的进行着，每月都有着来往那不勒斯和摩加迪沙的远洋轮船。
人民国发言部对我们的指控全盘接受，并说：“有人觉得我们的事情和墨索里尼别无二致，错了，我们做的要远超墨索里尼百倍。”摩加迪沙当局已经接收到了第一批意援武器与相关军事顾问。"
const TXT_R1_22 := "借此机会，我们也像索马里提供了一笔投资，当然比不上意大利人的慷慨解囊。不过巴雷也没法说什么，他非常需要这笔钱。人民国和意大利的贸易正在如火如荼的进行着，每月都有着来往那不勒斯和摩加迪沙的远洋轮船。当被问及此次战略性扩张的目的时，人民国外交部发言人表示无可奉告。"
const TXT_R0 := "我们强烈谴责意大利帝国主义行径与其对非洲的新殖民主义政策，称其是“新意属东非”。然而，我们的批判对意大利人来说不痛不痒，他们仍继续实行其掠夺性政策。据称。摩加迪沙当局已经接收到了第一批意援武器与相关军事顾问。"
const TXT_R1 := "机会难得，我们决定不再袖手旁观。我们决定以意大利人的政策为蓝本，以提供武器与粮食援助，交换索马里当局对我国产品的十年关税减免。索马里毫不犹豫的就接受了我们的提议。与此同时，摩加迪沙当局已经接收到了第一批意援武器与相关军事顾问。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var c85 := world.get_country_by_legacy_index(85)
	var is_22 := c85 != null and c85.sub_government == 22
	event_def.description = TXT_DESC_22 if is_22 else TXT_DESC_OTHER
	if event_def.options.size() < 2:
		return
	var opt := event_def.options
	if is_22:
		_enable(opt[0], TXT_OPT0_22)
		_enable(opt[1], TXT_OPT1_22)
	else:
		_enable(opt[0], TXT_OPT0)
		_enable(opt[1], TXT_OPT1)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c42 := ws.get_country_by_legacy_index(42)
	var c85 := ws.get_country_by_legacy_index(85)
	var is_22 := c85 != null and c85.sub_government == 22
	if c42 != null:
		c42.puppet_of = 85
		c42.sub_government = 22 if is_22 else 9
		c42.set_tag("亲美", false)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, -10)
			_add_relation(EmpireData.USSR, 25)
			_add_relation(EmpireData.USA, 25)
			context["result_text"] = TXT_R0_22 if is_22 else TXT_R0
		1:
			_add(W.I_BUDGET, 5)
			_add_relation(EmpireData.USSR, -25)
			_add_relation(EmpireData.USA, -25)
			if c42 != null:
				c42.set_tag("对华贸易", true)
			context["result_text"] = TXT_R1_22 if is_22 else TXT_R1
