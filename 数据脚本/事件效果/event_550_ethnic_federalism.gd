extends "res://数据脚本/event_script_base.gd"

## 原作 Event550.cs：朝花夕拾（民族区域自治改革，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:52-54 —— data[18] != 20。
## 差异：描述由 prepare 动态拼领袖姓名。

const TXT_DESC := "同志，您真的下定决心？要扭转我国的现行民族政策与区域自治这一基本政治制度了吗？倘若如此，那么我们便必须妥善解决自建国以来的一系列历史问题——首先便是对联邦内主体与少数民族权力机构的职能规定：众所周知，权力并不会因调整而消失；中国古代便用一系列鲜活案例教育了我们：地方分权常成为次一级行政单位集权与割据的起点。对省一级单位的放松将为试图培育独立王国的野心家和腐败分子提供钻营机会，并更可能形成依托地域的政治派系。在此背景下，尤其得留意觊觎我国西部的分离主义势力，天知道他们会不会利用我们适当分权的局面借机渗透，与那些试图利用分权框架的狂人们勾结。\n其次则是堪比民族识别本身的老大难。众所周知，中国不仅是一个多民族国家。同时还是一个民族间发展极不均衡的国家：即便将汉族排除在外，单独考察少数民族的情况。我们也会发现，除却维、藏、蒙、壮数个规模显著、且已形成固定活动空间、文化体系与社会认同的民族外；我国的绝大多数少数民族甚至无法被认定为是斯大林经典概念中的“民族”——没有党与国家积极奉行保护与扶持少数民族文化发展的政策，为其创制语言、整理历史的工作，他们兴许只能被称为“部落”，迄今仍处于“建设为民族的初级阶段”；其体量也同既存的主要民族间差距悬殊：即便经历了数次民族识别整理，这些民族也还是太过迷你（例如万人不到的云南独龙族、只有一千人的东北鄂伦春族）。他们要么以一省小聚落的形式存在，要么则分散于东部城市中，以外来人口与小社区的形式生活。后者在文化风俗方面更是与汉族毫无差别——也就意味着，若简单照搬“民族自决”原则，按聚居地与民族身份划定疆界治理；我们必然得彻底修改既有行政版图，并引入新的民族政策。当然，公务员可不会高兴。\n国家已对此提出了不同方案，不过结论都大同小异：要么摸着美洲诸国建设印第安人保留地与州政府的模式过河，用强调地方分权的方式暂时统摄民族问题；要么则效法苏联建立起体系化的民族权力机构，向加盟共和国看齐；总之都是用不同的分权方案推翻重来。又或者，我们为什么一定要拘泥于建立联邦或更分权形式中国的幻想，不试着将“联邦”给中国化呢？我们现行的《区域自治法》便是最好的修改蓝本。当然，最省事的方法还是直接否决一切改变，回到50年代既定的好制度上……总之，在这问题上可马虎不得……"
const TXT_OPT0_DIS := "美帝国主义的种族隔离政策不准通过！"
const TXT_OPT1_DIS := "照抄苏联模式是走不远的，得脚踏实地！"
const TXT_OPT2_DIS_FAR := "开弓没有回头路，我们已经走得太远！此时对选择撤退就是政治自杀！"
const TXT_OPT2_DIS_LIE := "我们怎么能欺骗人民呢！"
const TXT_OPT3_DIS := "过去的制度已经不适应新时代所需了！"
const TXT_R0 := "最终，全国人大批准了有关改革我国民族区域自治制度与地方管理制度的提案。相关的修宪计划也已转至全国各处开始筹备。预计在来年一月，我们将彻底废除《中华人民共和国民族区域自治法》，并以《中华人民共和国联邦组织章程》取而代之：国内省级政府已向美国州政府组织架构开始转型，在遵守《中华人民共和国》宪法的基础上，其在区域内的治权、财权与司法权均受保障，并享有自主定立区域法规、实现政治任命与批准财政预算的能力；对于少数民族则依托其聚居区建立自治区，以国家预算为保障尽可能建立自给自足的经济结构与普通话-民族语言双语教学体系，保证其在区块内既能保存现有文化的自由，又能稳健实现中国化。此后，我国的全国人民代表大会也将为新变化做出调整，由一院制转化为两院制；人民政协也将吸纳来自地方的新一批代表以扩容……当然，我们绝对会让新制度同中国国情相适应：至少，我们绝不会实现党组织与军队架构的联邦化……可如此巨大的变化还是揭开了变革的盖子。日后我们将见识到财政与职能分权所造成的影响，并要尤其留意可能依托地方自治产生的利益集团与经济上的马太效应，国家宏观调控的削弱很可能导致某种类似美国般区域对立、分化的局面出现。尤其是发达地区的省份……"
const TXT_R1 := "最终，全国人大批准了有关改革我国民族区域自治制度与地方管理制度的提案。相关的修宪计划也已转至全国各处开始筹备。预计在来年一月，我们将彻底废除《中华人民共和国民族区域自治法》，并以《中华人民共和国联盟条约》取而代之：我们不仅将国内省级政府改组为联邦的基本单位，并在其遵守《中华人民共和国》宪法的基础上，充分保障其治权、财权与司法权，将自主定立区域法规、实现政治任命与批准财政预算的能力赋予其手；同时还根据目前现有的少数民族聚居区，参考其规模分设大型加盟共和国与小型自治共和国，以国家预算为支持，效法苏联早期政策培养在地民族干部，发挥区域分工优势，充分保障民族事务自理自治。对外则以全国人大与国务院共同作为中国对外的代表机关，以中华人民共和国作为唯一主权实体，行使外交、管理法制与协调全国范围经济事宜。此后，我国的全国人民代表大会也将为新变化做出调整，由一院制转化为两院制；人民政协也将吸纳来自地方的新一批代表以扩容……当然，我们绝对会让新制度同中国国情相适应：至少，我们绝不会实现党组织与军队架构的联邦化……可如此巨大的变化还是揭开了变革的盖子：现在我们不仅要关注因分割职能而可能崛起的地方利益集团与经济马太效应，加大对地方与民族区域的支持；更要留意其他的潜在威胁：各地的民间政治活动越加活跃，海外反对派们也得寸进尺，甚至已开始要求基于区域与民族界限建立所谓的“省级独立共产党”或“民族共产党”，试图在此基础上继续深入“联邦化”……"
const TXT_R2 := "最终，全国人大批准了有关改革我国民族区域自治制度与地方管理制度的提案。相关的修宪计划也已转至全国各处开始筹备。预计在来年一月，我们将彻底废除《中华人民共和国民族区域自治法》，并以《中华人民共和国组织条例》取而代之——至少在表面上如此。实践中的所谓《组织条例》则基本上可被视为《民族区域自治法》的全国拓展版：各项自治权益切实存在，甚至还从司法、财政、社会福利等角度实现了扩容；但我们依旧没有丢掉“对上级单位负责”、“遵循民主集中制”、“协商决定事务”等关键概念。因此，这只是对50年代既有方针的小修小补。和先前制度的区别似乎也只在于让汉族也有了自己的“自治区”，并为民族文化的新发展开辟了道路——至少，我国的民族格局多少用比较另类的方式实现了平等。不过，再小的改变也是改变……而这一制度的灵活性本身便意味着它能向各种方向转型……等着瞧罢……"
const TXT_R3 := "最终，有关改革我国民族区域自治制度与地方管理制度的提案被全国人大所否决。相关的修宪计划也胎死腹中——人民更倾向于将此事看作是场闹剧，并为此编出了不少政治笑话。这显然打击了我们在其面前的公信力。更何况，我们先前尝试改革行政体制的声势可是实实在在的：多少已经打开了潘多拉魔盒，让问题已经成为了问题。海外的分离主义走卒及其幕后总后台已拿起我国先前的口风借题发挥，为反华宣传加入更多猛料……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	event_def.description = _leader_name() + TXT_DESC
	if event_def.options.size() < 4:
		return
	var opt := event_def.options
	var line := d[W.I_POLITICAL_LINE]
	if line >= 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line != 2 and line != 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line < 4 and d[W.I_TERRITORY] == 21:
		_enable(opt[2], event_def.options[2].text)
	elif d[W.I_TERRITORY] != 21:
		_disable(opt[2], TXT_OPT2_DIS_FAR)
	else:
		_disable(opt[2], TXT_OPT2_DIS_LIE)
	if line < 4:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -80)
			_add(W.I_INDUSTRY, -150)
			_add(W.I_AGRICULTURE, -150)
			_add(W.I_SERVICES, -150)
			_add(W.I_CORRUPTION, 30)
			_add(W.I_LIVING, -100)
			_add(W.I_PARTY_SUPPORT, 20)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 150)
			_add_relation(EmpireData.USA, 200)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_DIPLO, -30)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -150)
			_add(W.I_INDUSTRY, -250)
			_add(W.I_AGRICULTURE, -250)
			_add(W.I_SERVICES, -250)
			_add(W.I_CORRUPTION, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 250)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, 250)
			_add(W.I_DIPLO, 10)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 60)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			_add(W.I_MANPOWER, 150)
			_add(W.I_DIPLO, 20)
			ws.influence_prc += 5
			context["result_text"] = TXT_R2
		3:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, -20)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_set_data(W.I_TERRITORY, 20)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_WAR_SUPPORT, 400)
			_add(W.I_MANPOWER, -100)
			_add(W.I_DIPLO, 100)
			ws.influence_prc -= 5
			context["result_text"] = TXT_R3


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
