extends "res://数据脚本/event_script_base.gd"

## 原作 Event552.cs：加速发展战略？（苏联改革，5选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:62-64 —— 复杂条件见 evaluate()。
## 差异：SOV_PRC_PartiesConnection→I_COMMUNICATIONS；relres→ws.set_flag。

const TXT_TITLE := "加速发展战略？"
const TXT_DESC := "即便是在尤里·安德罗波夫的执政期间，就已经有相当数量的经济与社会学家被赋予推进苏联经济改革的“全权许可”。其中的一份关键文件《新西伯利亚宣言》指出：“苏联社会内的生产关系与目前生产力的发展存在显著滞后”。该文件的作者如此定义苏联国民经济内的其中某项关键问题，即“抓行政的手腕将纯粹的经济管理扼地太死，且集权的管理方式压过了分权的政策”。在过去的数十年间，苏联的经济增长率明显放缓，工业发展不均衡的现象也越加严重；由于缺少消费品，工人对劳动生产的结果毫无兴致。最重要的是，即便该国存在巨额投资，但目前投入生产的固定资产仍在迅速老化，可新技术的引进依然滞后。对此，苏联经济学家们确实认为，到了必须做出改变的时刻。为此，他们将在接下来举行的苏共中央四月全会上抛出对应的解决方案，这将成为接下来主导该国经济生活的主旋律。最终，苏共党内批准了所谓“加速发展战略”——其基本构思与华国锋曾筹划的“洋跃进”计划，以及罗马尼亚、波兰等政权70年代推行的“外债社会主义”颇有类似之处：国家将一次性扩大进口与预算支出，为国内制造业企业更新技术与扩大产量拨付巨额款项，从而实现苏联机械工程的跨越发展，相关支出则通过复兴的制造业筹款获利。预计该计划需要在短短五年内完成苏联机械工程的大跃进，以达到世界级水平。新任领导人戈尔巴乔夫则如此形容这一宏大计划：“我们得通过广泛运用科技革命最新成果，让社会主义经济制度契合当今模式，满足当代所需。因此，我们必须实现社会经济领域的显著跃进，除此之外别无他法。其中尤其是要以钢为纲，发展得要机械工程排头带。在接下来的25年内，我们必须得让工业产值增长率增长1.5倍或翻番，中心任务是加紧生产新一代机械设备。以鸟枪换炮的形式实现引进先进技术，显著提高劳动生产率与资本生产率，乃至减少原料浪费等多个目标”；这就事实上向国际社会表明了苏联经济内存在的问题，以及其试图发展外向型经济的渴望。作为世界经济的主要参与者，我们多少可以因势利导，让苏联新任领导人的改革计划成为我国获利的契机：我们既可以向苏方探出呼吁扩大合作的橄榄枝，以引荐技术与输送技术人员的方式深化双方间的经贸往来，并借机将我们的线人以交流名义安插在该国中，为未来的计划做准备；也可以试着在国际社会内造势，呼吁其他国家抵制苏联倡议，以软封锁方式使其经济计划流产，从而给本就疲软的苏联经济踩下刹车；又或者，最好的办法是效法美国与国际货币基金组织的先进经验，实施“援助换改革”的计划……不论如何，决定权在你。"
const TXT_OPT0 := "我们当然会给戈尔巴乔夫先生为苏联经济“踩下油门”的机会……毕竟，中苏友谊万古长青！"
const TXT_OPT0_DIS := "你是在说笑吗，苏联人绝不可能考虑这个提议！"
const TXT_OPT1 := "好机会！我们将同我国合作伙伴一同行动。让苏联经济改革胎死腹中！"
const TXT_OPT1_DIS := "我们拿什么来封锁苏联？那些四处流窜的毛派游击队吗？"
const TXT_OPT2 := "新方针？看来有必要与我们的美国朋友一起讨论对策……"
const TXT_OPT2_DIS := "美国怎么可能与我们步调一致呢！"
const TXT_OPT3 := "我们将开出戈尔巴乔夫绝不会拒绝的提议……清党与腾笼换鸟的时候到了……"
const TXT_OPT3_DIS := "这是对苏联内政的激进干涉！"
const TXT_OPT4 := "静观局势演变"
const TXT_R0 := "今天上午，中国驻苏联大使会见了米哈伊尔·戈尔巴乔夫，并代表我们向苏联提供一份利润颇丰的合资企业经营与技术转让协定；与此同时，中国还将在国际上扮演双方交易间的中间人，为苏联引进技术寻找卖家。戈尔巴乔夫则代表全体苏联人民对我们表示诚挚的感谢，并顺势扩大了与我国的经贸往来。由此在事实上完全结束了中苏对峙的冷淡时期。我国技术人员与线人也得以借由经济交流的名义进入苏联，在当地拓展我国影响力。当然，交流是双向的——苏联改革的新思维也顺着这条人脉渠道自然而然地流入我国，并引起相应的呼应。国际社会已对中国的“新一轮经济扩张”意见纷纷。"
const TXT_R1_A := "同志在政治局内部会议上决定以苏联经济改革问题借题发挥，联合我们的国际盟友一起“落井下石”：经济合作组织成员一致决定抬高经济壁垒，并建立了联合限制苏联产业引进的“上海统筹委员会”。苏联在欧洲的贸易伙伴也积极响应，加入到围堵该国的包围网中。最终导致苏联对外引进技术的声势寥寥，基本找不到可靠卖家……加速发展战略本身就此胎死腹中。苏联领导人不得不寻求其他办法，以重新激活该国经济：目前来看，戈尔巴乔夫集团还是选择了相对成本最低的办法。即恢复安德罗波夫加强劳动纪律，拴紧螺丝的系列政策。相关学者辩称，苏联劳动生产率低下是劳动纪律废弛的客观结果、搞整顿有助于恢复生产、降低机械停机率与次品产出率。旨在为国民经济带来劳动纪律与秩序的运动预计会带来积极结果。预计国民收入将增长3%，而工业产出将提高4%。诚然，某些地区也因此产生了些过激措施（例如在工作日内突击检查电影院与商铺，甚至和简单的聚会不对付；在此期间，所有无批准或无故缺勤的人都会被拘留以“确认成分”）然而，上述行政手段能在多大程度解决该国经济的结构性问题？这一疑问仍悬而未决。"
const TXT_R1_B := "同志在政治局内部会议上决定以苏联经济改革问题借题发挥，联合我们的国际盟友一起“落井下石”：经济合作组织成员一致决定抬高经济壁垒，并建立了联合限制苏联产业引进的“上海统筹委员会”。苏联在欧洲的贸易伙伴也积极响应，加入到围堵该国的包围网中。最终导致苏联对外引进技术的声势寥寥，基本找不到除美国外的可靠卖家……当然，若不是美国开出价码，玩了出熟悉的“援助换改革”。“加速发展战略”或许真将胎死腹中：苏联扩大了企业自治概念的适用范围，稍稍放松了外贸壁垒、为美国消费品与美苏合资企业的经营让路；乃至在外交政策上实行缓和退让。国家计划委员会则开始洗牌，老牌干部拜巴科夫不得不因自己在该战线上的缺乏创举而下马，换上以雷日科夫为代表的改革人士们。保守派已开始借题发挥，批判戈尔巴乔夫放弃社会主义的建设成就。并开始尝试采取反制……"
const TXT_R2 := "我们很快便同华盛顿达成策应，并共同筹备了对苏提供技术出口的的联合法案：美国与中国将联动其国际盟友共同为苏联的“加速发展战略”提供签署技术引进与设备转让的机会，并将派遣工程师协助苏联工人掌握相应设备；当然，所有的这一切都需要相应的筹码：几乎是在戈尔巴乔夫与我们达成协定的同时，他便开始实行套新方针。苏联经济体制也就标榜所谓“新时代的新经济政策”，加速向卡达尔主义与南斯拉夫铁托主义的构型转变：该国各地的企业均建立了工人委员会，并参与到拟定计划的讨论中（即便目前仅行使咨询权），并在同时提供改进生产流程的方法（在此次被赋予全权）。各地董事的财政自主权得到了提升，还在“荣誉墙”与证书之外，引入了对工人的物质激励。即便改革目前规模有限，且一切都在“试验”的框架下束手束脚地开展。对“集体农庄”市场与“合作社”产品销售的控制还是显著削弱，连带着“法萨”（苏联地下市场的一种交易形式，主要转手销售国外商品）都被去罪化。从而丰富了该国自筹资金与繁荣商品市场的方式……以叶戈尔·盖达尔、阿纳托利·丘拜斯为代表的青年经济学家群体开始在苏联政界发光发热，事实上为该国向市场社会主义方向进行改革开了口子——下一步自然便是政治平反与基于活跃社会团体改革苏维埃体制，引入独立候选人与扩大代表性。谁知道未来会如何？当然，一个开放的苏联自然对我们有利。我们的合资企业已开始走入该国境内，赚取宝贵的利润。"
const TXT_R3_A := "今天，"
const TXT_R3_TAIL := "同志召见了苏联驻华大使，并让他转交给米哈伊尔·戈尔巴乔夫一封信。信中提议称，苏联将以近乎免费的价格从中国获得“其所想要的一切”，这甚至足以让苏联将原本应投入至“加速发展战略”技术改进的宝贵预算挪至其他项目，如基于改进劳动纪律的反酗酒运动：中国开出的价码包括但不限于来自北京的巨额投资、稳定的中苏贸易协定、建设中苏合资企业的计划、以及持之以恒的技术转让与专员交流计划。考虑到经济互助委员会的国际分工与一体化方案越来越流于表面，苏联与西方的贸易事实上得看中国脸色，乃至中国经济集团占据全球经济半壁江山，不得不作为最佳合作伙伴的现实。戈尔巴乔夫当然会不择手段抓住这一机会：但要知道，“无价”在中文语境还有“无价之宝”的含义——条件是苏联我们名单上的各类著名异见者完全平反、甚至考虑给他们专设苏联最高苏维埃配额席位；同时，苏联还需在柯西金改革的基础上扩大并进一步落实工人自治权，并在此期间默许工人的夺厂与罢工自由，实现更进一步的政治自由化。
为了稍稍缓和戈尔巴乔夫一党的情绪，我们的情报人员通过抢先得知戈尔巴乔夫改革派集团“大脑”亚历山大·雅科夫列夫的“全盘重组”计划（即主张彻底洗牌苏联政治，在苏联建立类似美国式的管制民主总统制政体，为此，必须选择提拔反建制势力为改革开辟道路），恰如其分地在附加条件中递上了相当合乎其口味的黑名单与在清党计划内合作的橄榄枝：而接下来，负责国防的中央书记格里戈里·罗曼诺夫与莫斯科党委第一书记维克托·格里申是第一批“自愿离职”的，苏共在各加盟共和国的山头也遭清洗。传统保守派遭遇重创：当然，我们的特勤做了两手工作，其中有不少人得以在东欧盟友处安身，给他们留了东山再起的念想——前提是与中国合作。他们空缺的位置则为我们与戈尔巴乔夫集团共同商议的名单所取代：其中则有以拉脱维亚地方党魁鲍里斯·普戈、总参谋长谢尔盖·阿赫罗梅耶夫等国家主义者为代表的社会爱国主义者集团，承担扮演苏共“新一代保守派”的任务；经济与社会事务则落入了忽略意识形态的技术官僚们手中：其中则包括工会领导人根纳季·亚纳耶夫、克格勃主席维克托·切布里科夫与安德罗波夫时期提拔的列昂尼德·阿巴尔金、尼古拉·雷日科夫与弗拉基米尔·多尔吉赫等改革派经济学家。戈尔巴乔夫集团则负责扮演新“三驾马车”的车头，主导该国政治方向。苏联本身的改革在我们的介入下得以“全面加速”：预计社会自由化的进一步开展，独立候选人制度将在苏联最高苏维埃中占有一席之地。"
const TXT_R4 := "“加速发展战略”计划在第十二个五年计划期间，将国民收入增长率提升20-22%，工业产出增长21-24%，农业产值则实现翻倍。目标是让苏联的工业产值在2000年赶上美国。时间会告诉我们这一政策的成功与否……"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var dd := world.数值表
	if dd.size() <= W.I_DAY:
		return false
	if world.empires.size() <= EmpireData.USSR or world.empires[EmpireData.USSR] == null:
		return false
	var ussr := world.empires[EmpireData.USSR]
	if ussr.current_leader != 6 or ussr.power > 100:
		return false
	if world.get_flag("IndOpp"):
		return false
	var y := dd[W.I_YEAR]
	var mo := dd[W.I_MONTH]
	var day := dd[W.I_DAY]
	if (y >= 1985 and mo >= 4 and day >= 1) or (y >= 1985 and mo >= 5) or y >= 1986:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var opt := event_def.options
	var num := _count_proprc([21, 85, 86, 87, 92])
	var num2 := _count_proprc([2, 3, 4, 6, 5])
	var c1 := world.get_country_by_legacy_index(1)
	var c51 := world.get_country_by_legacy_index(51)
	var ussr := ws.empires[EmpireData.USSR]
	var cond_base := ussr != null and ws.influence_prc >= ussr.power and ws.influence_prc >= 750
	if d[W.I_INDUSTRY] >= 1000 and d[W.I_AGRICULTURE] >= 1000 and d[W.I_SERVICES] >= 1000 and cond_base:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if num >= 3 and c1 != null and c1.has_tag("econ") and cond_base:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if c51 != null and c51.has_tag("对华贸易") and c51.development == 1 and d[W.I_POLITICAL_LINE] >= 3:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if num >= 3 and num2 >= 3 and c1 != null and c1.has_tag("econ") and cond_base:
		_enable(opt[3], TXT_OPT3)
	else:
		_disable(opt[3], TXT_OPT3_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c0 := ws.get_country_by_legacy_index(0)
	var c7 := ws.get_country_by_legacy_index(7)
	var ussr := ws.empires[EmpireData.USSR]
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			ws.set_flag("relres", true)
			if c7 != null:
				c7.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, 200)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_COMMUNICATIONS, 250)
			_add(W.I_BUDGET, 150)
			_add(W.I_AGENTS, -150)
			_add(W.I_SCIENCE, -8000)
			_add(W.I_INDUSTRY, -100)
			_add(W.I_SERVICES, -100)
			_add(W.I_THOUGHT_FREEDOM, 50)
			ws.influence_prc += 30
			_add_power(EmpireData.USSR, 50)
			ussr.money -= 150
			if ussr.leaders.size() > 6 and ussr.leaders[6] != null:
				ussr.leaders[6].support += 2
			context["result_text"] = TXT_R0
		1:
			var text := _leader_name() + TXT_R1_A
			if c0 != null and not c0.has_tag("eu") and not c0.has_tag("nato"):
				ws.influence_prc += 20
			else:
				text = _leader_name() + TXT_R1_B
				ws.influence_prc += 10
				_add_power(EmpireData.USA, 30)
			ws.set_flag("relres", false)
			if c7 != null:
				c7.set_tag("对华贸易", false)
				c7.sub_government = 1
			_add(W.I_COMMUNICATIONS, -50)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -100)
			ws.influence_prc += 20
			_add_relation(EmpireData.USSR, -250)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USSR, -200)
			_add_power(EmpireData.USA, 10)
			ussr.money -= 150
			ws.empires[EmpireData.USA].money += 150
			if ussr.leaders.size() > 6 and ussr.leaders[6] != null:
				ussr.leaders[6].support -= 1
			context["result_text"] = text
		2:
			ws.set_flag("relres", true)
			if c7 != null:
				c7.set_tag("对华贸易", true)
				c7.set_tag("亲苏", false)
				c7.government = 2
				c7.sub_government = 15
			_add_relation(EmpireData.USSR, 100)
			_add_relation(EmpireData.USA, 150)
			_add(W.I_COMMUNICATIONS, 250)
			_add(W.I_BUDGET, 50)
			_add(W.I_AGENTS, -150)
			_add(W.I_SCIENCE, -4000)
			_add(W.I_INDUSTRY, -50)
			_add(W.I_SERVICES, -50)
			_add(W.I_THOUGHT_FREEDOM, 100)
			ws.influence_prc += 20
			_add_power(EmpireData.USA, 100)
			ussr.money -= 150
			ws.empires[EmpireData.USA].money += 100
			if ussr.leaders.size() > 6 and ussr.leaders[6] != null:
				ussr.leaders[6].support += 1
			context["result_text"] = TXT_R2
		3:
			ws.set_flag("relres", true)
			if c7 != null:
				c7.set_tag("对华贸易", true)
				c7.set_tag("亲苏", false)
				c7.government = 2
				c7.sub_government = 21
			_add_relation(EmpireData.USSR, 100)
			_add_relation(EmpireData.USA, -250)
			_add(W.I_COMMUNICATIONS, 250)
			_add(W.I_BUDGET, -450)
			_add(W.I_AGENTS, -350)
			_add(W.I_ARMY, -250)
			_add(W.I_SCIENCE, -12000)
			_add(W.I_INDUSTRY, -200)
			_add(W.I_AGRICULTURE, -100)
			_add(W.I_SERVICES, -150)
			_add(W.I_THOUGHT_FREEDOM, 100)
			ws.influence_prc += 100
			ussr.money += 150
			context["result_text"] = TXT_R3_A + _leader_name() + TXT_R3_TAIL
		4:
			ussr.money -= 150
			if ussr.leaders.size() > 6 and ussr.leaders[6] != null:
				ussr.leaders[6].support += 1
			context["result_text"] = TXT_R4


func _count_proprc(indices: Array) -> int:
	var n := 0
	for idx in indices:
		var c := ws.get_country_by_legacy_index(int(idx))
		if c != null and c.has_tag("亲中"):
			n += 1
	return n


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
