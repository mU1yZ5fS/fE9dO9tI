extends "res://数据脚本/event_script_base.gd"

## 原作 Event704.cs：你要负全部责任（加拿大紧急选举，五选项）。
## 触发：DiploButtonScript.cs:12554 type1077 → 外交互动_批5.gd _def_1077 start_event_num(w,704)。
## 差异：Torg→对华贸易、proprc→亲中、Vyshi→亲美；c137=加拿大、c167=魁北克。

const TXT_DESC_A := "虽说特鲁多得以在其任期内对法律与国体问题盖棺定论，并让加拿大成为独立国家；可计划显然跟不上变化：英国废除君主制的既成事实导致法律的修订本身失去了法理前提，使修宪事件几乎成为了笑话。而面对这一局势，特鲁多又不得不听天由命并接纳温莎家族——毕竟，王室的到来比修改国体的草案总是来得更早。这种处处被动的态势最终导致其很快输给了更持大西洋主义的进步保守党，承诺将再度同美国站在一起，最终重整加拿大国威的马尔罗尼。我们也就此找到了绝佳的入局机会：由于东升西落与中国经济圈的崛起，加拿大资产阶级不得不逐步摆脱贸易日趋萎靡的美国，并转向同我们的企业做生意。我们只需稍稍施压，便可动摇该国局势。对此，马尔罗尼政府不得不召开紧急国会选举，并向美国与温莎家族发出合作暗示。显然，这场选举将决定加拿大和英联邦，乃至英帝国最后遗产的日后命运……而美国也绝不会坐以待毙，虽说他们对温莎家族的命运并无多大兴趣，但加拿大本身必须被牢牢掌握在华盛顿的直接控制下。"
const TXT_DESC_B := "在老特鲁多输给了更持大西洋主义的进步保守党，承诺将再度同美国站在一起，最终重整加拿大国威的马尔罗尼后。加拿大的局势仍未出现根本改观。马尔罗尼也没能找到解决加拿大内身份认同难题的办法——他对魁北克分裂主义者的绥靖态度，对“无司法宪法”的不思进取态度，乃至迎接温莎家族的做法只会让自己成为众矢之的。现在，没了唱红脸的特鲁多。我们就此找到了绝佳的入局机会：由于东升西落与中国经济圈的崛起，加拿大资产阶级不得不逐步摆脱贸易日趋萎靡的美国，并转向同我们的企业做生意。我们只需稍稍施压，便可动摇该国局势。对此，马尔罗尼政府不得不召开紧急国会选举，并向美国与温莎家族发出合作暗示。显然，这场选举将决定加拿大和英联邦，乃至英帝国最后遗产的日后命运……而美国也绝不会坐以待毙，虽说他们对温莎家族的命运并无多大兴趣，但加拿大本身必须被牢牢掌握在华盛顿的直接控制下。"
const TXT_OPT0_DIS := "再这样渥太华要叫特鲁多格勒了！"
const TXT_OPT1_DIS := "我们不会去支持他们"
const TXT_OPT2_DIS_A := "支持这种人没有前途"
const TXT_OPT2_DIS_B := "阿尔伯塔没有魁北克孤掌难鸣"
const TXT_OPT3_DIS := "我们不可能在这个地方支持共产党……"
const TXT_R0 := "虽说大力支持自由党的计划看起来匪夷所思，可考虑到他们足够实用主义且经验丰富，并能够在亲近我方的同时对美斡旋，因此，仰仗他们实现加拿大的转变是相当稳健且保险的。当然，我们得花费大力气去重新扶持特鲁多。这意味着得犯违加拿大西部居民的大不韪——因为他们认为特鲁多用牺牲不列颠哥伦比亚和阿尔伯塔的方式来讨好安大略和魁北克，其国家能源计划也被认为伤害了西部利益。除此之外，特鲁多在十月危机期间实施戒严的措施也被魁北克人视作威胁民主，有成为独裁者之嫌。不过，考虑到当前布莱恩·马尔罗尼的萎靡形象，特鲁多一下子便显得“高大伟岸”起来。\n靠打民粹主义牌卷土重来之后，特鲁多一改先前的温和立场，宣布将不再重蹈历史覆辙并迅速通过公投方式建立共和制度。不过，分析人士认为特鲁多的新体制很可能将把加拿大带往威权自由主义方向。内阁内新上马的让·克雷蒂安等强硬派部长也让魁北克人们颇为担忧，为两国间关系蒙上了不详阴影。"
const TXT_R1_LEFT := "得益于我们的提前布局，新民主党的左翼借东风重现了华夫派时代内党中左翼强盛的态势——约翰·罗德里格斯的左翼核心小组和由朱迪·雷比克领导的左翼潮流，在近期做大的“激进党运动”一起在党代会上对立场软弱的党首埃德·博德宾发起逼宫，并完成了改组任务。新民主党左翼得以按照自身意志重塑新一届党内领导集体，旋即推翻党内建制派驱逐华夫派的历史决议，邀请他们重返该党。\n此后，新民主党借和平主义浪潮与该国第一民族对变革的呼吁首次压倒加拿大的政治惯性，彻底革新了加拿大传统两党制度。约翰·罗德里格斯宣布将在不久后发起公投，以此把加拿大改造为共和制政权。显然，这种努力会遭到加美特殊关系与西部省份离心力的挑战。加拿大为此自然需要做出某种妥协。可考虑到美国已不再是往日那个不可一世的超级大国，在此基础上顺水推舟，将加拿大改造为无核化中立政权，并奉行比例代表制度的共和国这点上显然有了更大的可能。与此同时，新政府启动了工业国有化与组织国家经济计划的议程，以此巩固加拿大的独立与中立成果。"
const TXT_R1_PLAIN := "虽说新民主党普遍比起其他欧美中左政党更加右倾，可比起传统建制派，他们是不那么坏的选择。他们由此得到了我们的青睐。此后，新民主党则借和平主义浪潮与该国第一民族对变革的呼吁首次压倒加拿大的政治惯性，彻底革新了加拿大传统两党制度。埃德·博德宾宣布将在不久后发起公投，以此把加拿大改造为共和制政权。显然，这种努力会遭到加美特殊关系与西部省份离心力的挑战。加拿大为此自然需要做出某种妥协。可考虑到美国已不再是往日那个不可一世的超级大国，在此基础上顺水推舟，将加拿大改造为无核化中立政权，并奉行比例代表制度的共和国这点上显然有了更大的可能。"
const TXT_R2 := "考虑到加拿大地区的特殊国情，我们决定采取迂回方式推进其社会变革：即支持信奉“社会信用”理论的曼宁家族候选人普雷斯通·曼宁竞选总统。虽说所谓的“社会信用理论”无非是消费券与产业补贴政策的变种，可总比原汁原味的自由主义或过分的社会主义来的好。因此，囊括社会信用党的“加拿大改革党”集团得以背靠我们的援助迅速崛起，并得到大多数加拿大人的支持——他们早就对建制派们就英国的抱残守缺态度不爽很久了。社会信用理论就此在诞生处站稳脚跟，登上政治舞台。不过考虑到东升西落的大势，即便是固守反共产主义立场的曼宁政权也不得不承认冷战业已结束，需要以基督教文明的站位承认当前的多极化趋势，并对共产主义采取谨慎的防御态度。与此同时，曼宁已开始在联邦层面落实所谓“社会信用理论”：引入最低工资，解体道明和丰业银行，以及就君主制存续举行全民公投。全世界都正关注首个道格拉斯主义政权的事件……"
const TXT_R3 := "既然加拿大政权已无法照旧统治下去，那为何不顺水推舟呢？得到了我们支持的加拿大革命共产党已准备好将这个国家掀个底朝天，并计划在总罢工后迅速接管各地城市建立社会主义共和国——至少理论如此……然而，美国中情局与加拿大安全情报局的动作还是比我们的同志更快一步。他们抢先在国内主要地区引入了戒严与宵禁，并同步发动了加拿大版本的帕尔默搜捕。加拿大革命共产党就此全军覆没，除却潜入地下或流亡北京的少数领导人物外已基本停止活动。而国家紧急状态的设立只是开始：加拿大的民主制度被“暂时冻结”，政党活动遭遇限制，文官政府的权威就此衰退，导致军队在这一过程中被越加委以重任。后者更是激活了美加两国间布局多年的一体化机制暗线——出于替加拿大武装力量与骑警“分忧”的需要，美军已在马尔罗尼总理的号召下坚决保卫“加拿大战时总理”，并把海军陆战队开入了多伦多、渥太华、温哥华等城市。流亡此处的英国右翼反共人士也开始筹建准军事组织作为其“有益补充”，防止其再版英国本土的教训……最后的温莎王朝就此在新大陆上站稳了脚跟。"
const TXT_R4_A := "面对社会困局，马尔罗尼只能越加向老朋友寻求帮助，并尽可能在一切都无可挽回前做出适当改良：加拿大与美国间的关系得以进一步巩固；包括骑警在内的执法部门得到了授权与新款马蹄铁；分权新宪法的起草也已提上日程。上述药方对“最后温莎王国”的效果仍需时间检验，但至少从目前来看。加拿大仍能跌跌撞撞地按照既定路径前行……"
const TXT_R4_B := "加拿大的情况仍在稳中向下：进步保守党政策的朝令夕改，建制派对自治权态度的拿捏不定共同滋养着激进主义者与试图复刻魁北克经验的分离派。而在70年代内集中爆发经济弊病更是持续冲刷加拿大社会秩序的根基。虽说马尔罗尼目前仍能稳定局势，可盖子又能捂多久呢？"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	var quebec := ws.get_country_by_legacy_index(167)
	event_def.description = TXT_DESC_B if quebec != null and quebec.parts.size() > 0 and quebec.parts[0] else TXT_DESC_A
	if event_def.options.size() < 5:
		return
	var china := ws.get_country_by_legacy_index(1)
	var line := _res(W.I_POLITICAL_LINE)
	var opt := event_def.options
	if line >= 2 and quebec != null and quebec.parts.size() > 0 and quebec.parts[0]:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if not ws.is_authoritarian(china):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if ws.is_socialism(china, false) and china != null and china.government != 3 \
			and (quebec == null or quebec.parts.size() == 0 or not quebec.parts[0]):
		_enable(opt[2], event_def.options[2].text)
	elif ws.is_socialism(china, true) or (china != null and china.government == 3):
		_disable(opt[2], TXT_OPT2_DIS_A)
	else:
		_disable(opt[2], TXT_OPT2_DIS_B)
	var albania := ws.get_country_by_legacy_index(20)
	if line == 0 and ws.result_of_event_num(701) == 3 and albania != null and albania.has_tag("亲中"):
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var canada := ws.get_country_by_legacy_index(137)
	var quebec := ws.get_country_by_legacy_index(167)
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_BUDGET, -500)
			_add(W.I_AGENTS, -500)
			if canada != null:
				_leave_alliances(canada)
				canada.government = 0
				canada.sub_government = 20
				canada.set_tag("对华贸易", true)
				canada.set_tag("亲中", true)
			ws.influence_prc += 50
			_add_relation(EmpireData.USA, -100)
		1:
			_add(W.I_BUDGET, -500)
			_add(W.I_AGENTS, -500)
			if canada != null:
				_leave_alliances(canada)
				canada.set_tag("对华贸易", true)
			if ws.result_of_event_num(701) == 2:
				context["result_text"] = TXT_R1_LEFT
				if canada != null:
					canada.government = 2
					canada.sub_government = 3
				ws.influence_prc += 30
				_add_relation(EmpireData.USA, -250)
			else:
				context["result_text"] = TXT_R1_PLAIN
				if canada != null:
					canada.government = 3
					canada.sub_government = 4
				ws.influence_prc += 20
				_add_relation(EmpireData.USA, -150)
		2:
			context["result_text"] = TXT_R2
			_add(W.I_BUDGET, -500)
			_add(W.I_AGENTS, -500)
			if canada != null:
				_leave_alliances(canada)
				canada.government = 2
				canada.sub_government = 8
				canada.set_tag("对华贸易", true)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -100)
		3:
			context["result_text"] = TXT_R3
			_add(W.I_BUDGET, -500)
			_add(W.I_AGENTS, -500)
			_add(W.I_ARMY, -250)
			_add(W.I_PARTY_SUPPORT, -100)
			if canada != null:
				_leave_alliances(canada)
				canada.government = 0
				canada.sub_government = 7
				canada.set_tag("亲美", true)
				canada.set_tag("对华贸易", false)
			ws.influence_prc -= 10
			_add_relation(EmpireData.USA, -400)
		4:
			if quebec == null or quebec.parts.size() == 0 or not quebec.parts[0]:
				context["result_text"] = TXT_R4_A
			else:
				context["result_text"] = TXT_R4_B
