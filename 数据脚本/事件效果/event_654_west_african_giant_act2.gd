extends "res://数据脚本/event_script_base.gd"

## 原作 Event654.cs：西非巨人——第二幕（尼日利亚1983大选，分支选项 4/6）。
## 触发：TimeScript.cs 11049-11053 —— (月>=8 且 年>=1983 或 年>=1984)。
## 差异：
##  - TextOfEvents 按 c60.sub_government==12/4 动态拼接；string.Format 的 {1} 用 GDScript format 保留原格式串。
##  - VariantsOfEvents 按 c60.sub_government==12 分支为 4 选项，否则 6 选项；prepare 用静态缓存安全恢复 6 选项数组。
##  - 选项显隐 prepare 动态改写（data56 / modifies[3] / data31 / resultOfEvents[653] / num 社会主义+改良+左翼民族主义计数）。
##  - OilProd += 100f：项目未建模，跳过（modifier_catalog.gd:1037）。
##  - 死代码 result 5 测试分支在 sub12 分支无效果；sub12 的 result 3 与 else 的 result 5 为纯文本选项，已复刻。

static var _saved_full_options: Array[EventOption] = []

const TXT_TITLE := "西非巨人——第二幕"
const TXT_DESC_INTRO := "尼日利亚第二共和国的第二次大选即将开始，这届选举的局势同上次大选截然不同——"
const TXT_DESC_SUB12 := "尼日利亚各方面相比上次大选都有所退行。同许多当代非洲国家类似，尼日利亚政府广泛干预社会经济，官员徇私舞弊，导致腐败泛滥。沙加里政府治理无能，经济措施失当，政府制订依赖石油税收的投资计划（尽管取得了一定成果），因石油价格下跌，导致了财政的紧张，并引发了外汇危机和经济滞涨。沙加里不得不实施受国际货币基金组织支持的经济自由化计划，却引发民众贫困及不满，失业现象大幅增加。除了经济萧条，尼日利亚工业、农业也得到了衰退，国家变得更加依赖进口了。在这种情况下，国民党政治家却趁机捞取利益，甚至想利用权力推迟大选，增加政府的任期时间。\n在选举上，尼日利亚国民党和尼日利亚人民党的执政联盟早已破裂，主要反对党尼日利亚统一党正在尝试推进同尼日利亚人民党、人民救国党和大尼日利亚人民党部分成员一起建立一个进步党团联盟，共同对抗保守派。而掌权的国民党也正打算使用一些“非正常”方式来赢得大选……"
const TXT_DESC_SUB4 := "阿沃罗沃政府在上台后尝试推进社会福利建设，推广免费教育和免费医疗，以及投资开展农村发展计划并加强基础设施建设，但这些计划依赖石油税收，因石油价格下跌，导致了财政的紧张，并引发了外汇危机和经济滞涨，使得福利主义改革计划无法完全落实。阿沃罗沃不得不实施受国际货币基金组织支持的经济自由化计划，却引发民众贫困及不满，失业现象大幅增加。阿沃罗沃尝试通过修改宪法来恢复第一共和国的更分权的大区模式和其打压北方、强化约鲁巴部族政治地位的企图最终使得进步派联盟最终走向了破裂。\n在选举上，由于进步派力量的执政地位，尼日利亚人民党和人民救国党的力量都得到了增强，他们决定单独参加大选；另一方面，阿沃罗沃的失败进步改革也强化了民间对反对党尼日利亚国民党的呼声。"
const TXT_DESC_MID_FMT := "在国内矛盾的背景下，反建制力量也得以壮大。扬塔特斯尼组织吸引了大批不满现状的年轻人和失业者，力量不断增强，导致尼日利亚国内的宗教关系紧张。1980年，扬塔特斯尼在卡诺发起了一场暴动，最终导致军队介入，这便是扬塔特斯尼叛乱的开端。{1}虽然马尔瓦在暴动被镇压后不久去世，但他的亲密弟子穆萨·阿里·苏莱曼成为了继任者。在1982年，迈杜古里和卡杜纳等地也爆发了扬塔特斯尼的追随者制造的骚乱。\n也许，现在是我们插手的时候了？"
const TXT_DESC_MID_COND := "事后，沙加里政府宣布驱逐尼日利亚的西非移民（因为扬塔特斯尼中有来自尼日尔和喀麦隆等地的人），这遭到了国际社会的广泛谴责。"

const TXT_OPT0 := "支持沙加里维持权力"
const TXT_OPT0_DIS := "我们不会支持保守派"
const TXT_OPT1 := "我们支持进步派党团联盟的最终实现"
const TXT_OPT1_DIS := "我们没必要把资源浪费在非洲的选举事务上……"
const TXT_OPT2 := "何不支持扬塔特斯尼组织？"
const TXT_OPT2_DIS := "我们不会去找他们！"
const TXT_OPT3 := "非洲的民主和大选本就是儿戏……我不是说过我对这个尼什么不感兴趣了吗？"

const TXT_ELSE0 := "支持国民党"
const TXT_ELSE0_DIS := "我们没必要把资源浪费在非洲的选举事务上……"
const TXT_ELSE1 := "支持统一党"
const TXT_ELSE1_DIS := "我们没必要把资源浪费在非洲的选举事务上……"
const TXT_ELSE2 := "支持人民党"
const TXT_ELSE2_DIS := "他们的力量不够强大"
const TXT_ELSE3 := "支持人民救国党"
const TXT_ELSE3_DIS := "我们没必要把资源浪费在非洲的选举事务上……"
const TXT_ELSE4 := "何不支持扬塔特斯尼组织？"
const TXT_ELSE4_DIS := "我们不会去找他们！"
const TXT_ELSE5 := "非洲的民主和大选本就是儿戏……"

const TXT_R0_SUB12 := "沙加里领导的国民党在参众两院及总统选举中获胜，沙加里再次当选总统，国民党在各级政府的职位与议院的议席大增。但此次选举充满腐败和不正当交易，激化了政府与其他党派、民众的矛盾，政治危机加剧。与1979年选举相比，1983年选举的不法行为猛增。在选举中，政治对手采用消极的竞选方式，如利用部族、宗教煽动，进行人身攻击甚至谋杀。大选中，政治家威胁操纵选举致社会动荡，还存在贿赂、造假票、恐吓官员、涂改名单等不正当行为，甚至，不需要我们的过多帮助，国民党便轻松赢得了大选。新政府感谢我们的帮助，同我们达成了一些合作协定。尼日利亚国内的混乱和萧条并未结束，也许，不满终会酿成些什么东西……"
const TXT_R1_SUB12 := "经过艰难的谈判和我们的大力投入，尼日利亚统一党、尼日利亚人民党、人民救国党和大尼日利亚人民党组成了进步党团联盟。由于我们的资金输入、特勤对国民党的选举的扰乱和媒体对尼日利亚国民党的选举作弊的行径的大规模曝光，最终，进步党团联盟在参众两院及总统选举中获胜，奥巴费米·阿沃罗沃成为了总统。新政府感谢我们的帮助，同我们达成了一些合作协定。人们正在期待新政府对局势的扭转，但是在混乱和萧条的条件下，新政府真的能做什么吗？"
const TXT_R2_SUB12 := "反西方主义的扬塔特斯尼已经证明了他们的好成绩，让我们来支持他们。大使馆联系到穆萨·阿里·苏莱曼，很快，一批武器和资金便送到了扬塔特斯尼组织手中。\n不出所料，沙加里领导的国民党在参众两院及总统选举中获胜，沙加里再次当选总统，国民党在各级政府的职位与议院的议席大增。但此次选举充满腐败和不正当交易，激化了政府与其他党派、民众的矛盾，政治危机加剧。与1979年选举相比，1983年选举的不法行为猛增。在选举中，政治对手采用消极的竞选方式，如利用部族、宗教煽动，进行人身攻击甚至谋杀。大选中，政治家威胁操纵选举致社会动荡，还存在贿赂、造假票、恐吓官员、涂改名单等不正当行为。尼日利亚国内的混乱和萧条并未结束，也许，不满终会酿成些什么东西……"
const TXT_R3_SUB12 := "不出所料，沙加里领导的国民党在参众两院及总统选举中获胜，沙加里再次当选总统，国民党在各级政府的职位与议院的议席大增。但此次选举充满腐败和不正当交易，激化了政府与其他党派、民众的矛盾，政治危机加剧。与1979年选举相比，1983年选举的不法行为猛增。在选举中，政治对手采用消极的竞选方式，如利用部族、宗教煽动，进行人身攻击甚至谋杀。大选中，政治家威胁操纵选举致社会动荡，还存在贿赂、造假票、恐吓官员、涂改名单等不正当行为。尼日利亚国内的混乱和萧条并未结束，也许，不满终会酿成些什么东西……"
const TXT_R0_ELSE := "得益于统一党的政策失当以及我们的资金输入、特勤对其他政党的选举的扰乱和媒体对其他政党的选举作弊的行径的大规模曝光，最终，国民党在参众两院及总统选举中获胜，并获得了人民党议员的支持，谢胡·沙加里成为了总统。新政府感谢我们的帮助，同我们达成了一些合作协定。人们正在期待保守派新政府对局势的扭转，但是在混乱和萧条的条件下，新政府真的能做什么吗？"
const TXT_R1_ELSE := "我们的竞选资金和特勤被用来帮助统一党的选举。阿沃罗沃领导的统一党在参众两院及总统选举中获胜，阿沃罗沃再次当选总统，统一党在各级政府的职位与议院的议席大增，并获得了其他进步派政党的部分议员的支持。但此次选举充满腐败和不正当交易，激化了政府与其他党派、民众的矛盾，政治危机加剧。与1979年选举相比，1983年选举的不法行为猛增。在选举中，政治对手采用消极的竞选方式，如利用部族、宗教煽动，进行人身攻击甚至谋杀。大选中，政治家威胁操纵选举致社会动荡，还存在贿赂、造假票、恐吓官员、涂改名单等不正当行为。新政府感谢我们的帮助，同我们达成了一些合作协定。尼日利亚国内的混乱和萧条并未结束，也许，不满终会酿成些什么东西……"
const TXT_R2_ELSE := "得益于统一党的政策失当以及我们的资金输入、特勤对其他政党的选举的扰乱和媒体对其他政党的选举作弊的行径的大规模曝光，最终，人民党在参众两院及总统选举中获胜，并获得了进步派议员的支持，纳姆迪·阿齐克韦成为了总统。新政府感谢我们的帮助，同我们达成了一些合作协定。人们正在期待这位独立元勋的新政府对局势的扭转，但是在混乱和萧条的条件下，新政府真的能做什么吗？"
const TXT_R3_ELSE := "得益于西非浓厚的左翼氛围以及我们的资金输入、特勤对其他政党的选举的扰乱和媒体对其他政党的选举作弊的行径的大规模曝光，最终，人民救国党在参众两院及总统选举中获胜，并获得了部分进步政党的支持，哈里法·哈桑·优素福（卡诺已于不久前去世）成为了总统。新政府感谢我们的帮助，同我们达成了一些合作协定。人们正在期待新政府对局势的扭转，但是在混乱和萧条的条件下，新政府真的能做什么吗"
const TXT_R4_ELSE := "我们的大使馆联系到穆罕默德·马尔瓦，表示我们愿意和扬塔特斯尼组织一起打倒邪恶的西方物质主义的入侵。很快，一批武器和资金便送到了扬塔特斯尼组织中。尼日利亚当局谴责我们干涉他国内政，宣布降低与我国的外交关系。\n在7月7日的参议院选举中，尼日利亚国民党赢得了参议院95个席位中的36席，占37.9%。统一党获得了28席，占29.5%。人民党获得了16席，占16.9%。救国党获得了7席，占7.3%。大尼日利亚人民党获得了8席，占8.4%。7月14日的众议院的选举，国民党也占优势，在总数为449个议席中，国民党得了168席，占37.4%。统一党得了111席，占24.7%,居第二位。人民党居第三位，得了79席，占17.5%。居第四位的是救国党，得了49席，占10.9%。居最后一位的是大尼日利亚人民党，获得了48席，占10.69%。最终，沙加里的尼日利亚国民党与阿齐克韦的尼日利亚人民党经过谈判在议会中达成了联盟，获得了多数席位。\n8月16日，尼日利亚举行全民总统大选的投票，共有1684万选民参加了选举。结果，国民党候选人沙加里获得568万张选票，占总数的33.8%，并在19个州中的12个州里得票率超过了25%，从而达到了宪法所规定的当选新总统的票数。10月1日，在尼日利亚庆祝独立和建国19周年的时候，奥巴桑乔军政府在首都拉各斯举行了规模盛大的“还政于民”政权交接仪式，尼日利亚第二共和国成立，沙加里宣誓就任总统。在非洲大陆军人政权盛行，军事政变不断的时候，尼日利亚还政于民的成功，民选的文官新总统的就职，在非洲产生了重大的影响，奥巴桑乔受到非洲和国际社会的高度赞誉。"
const TXT_R5_ELSE := "阿沃罗沃领导的统一党在参众两院及总统选举中获胜，阿沃罗沃再次当选总统，统一党在各级政府的职位与议院的议席大增。但此次选举充满腐败和不正当交易，激化了政府与其他党派、民众的矛盾，政治危机加剧。与1979年选举相比，1983年选举的不法行为猛增。在选举中，政治对手采用消极的竞选方式，如利用部族、宗教煽动，进行人身攻击甚至谋杀。大选中，政治家威胁操纵选举致社会动荡，还存在贿赂、造假票、恐吓官员、涂改名单等不正当行为。尼日利亚国内的混乱和萧条并未结束，也许，不满终会酿成些什么东西……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.is_empty():
		return
	event_def.title = TXT_TITLE
	var nigeria := world.get_country_by_legacy_index(60)
	var is_sub12 := nigeria != null and nigeria.sub_government == 12
	var desc := TXT_DESC_INTRO
	if is_sub12:
		desc += TXT_DESC_SUB12
	elif nigeria != null and nigeria.sub_government == 4:
		desc += TXT_DESC_SUB4
	var mid_cond := TXT_DESC_MID_COND if is_sub12 else ""
	desc += TXT_DESC_MID_FMT.format(["\n", mid_cond])
	event_def.description = desc
	if _saved_full_options.is_empty() and event_def.options.size() >= 6:
		_saved_full_options = event_def.options.duplicate()
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	var war_support := data[W.I_WAR_SUPPORT] if data.size() > W.I_WAR_SUPPORT else 0
	var prev_653 := int(world.completed_event_ids.get("event_653", 0))
	var opt := event_def.options
	if is_sub12:
		if event_def.options.size() > 4:
			event_def.options.resize(4)
		if line >= 2:
			_enable(opt[0], TXT_OPT0)
		else:
			_disable(opt[0], TXT_OPT0_DIS)
		if line <= 2 and line >= 1:
			_enable(opt[1], TXT_OPT1)
		else:
			_disable(opt[1], TXT_OPT1_DIS)
		if line <= 3 and line >= 1 and not _modifier_active(world, 3) and war_support >= 600 and prev_653 != 3:
			_enable(opt[2], TXT_OPT2)
		else:
			_disable(opt[2], TXT_OPT2_DIS)
		_enable(opt[3], TXT_OPT3)
		return
	if event_def.options.size() < 6 and _saved_full_options.size() >= 6:
		event_def.options = _saved_full_options.duplicate()
		opt = event_def.options
	if line >= 2:
		_enable(opt[0], TXT_ELSE0)
	else:
		_disable(opt[0], TXT_ELSE0_DIS)
	if line <= 3 and line >= 1:
		_enable(opt[1], TXT_ELSE1)
	else:
		_disable(opt[1], TXT_ELSE1_DIS)
	if line <= 3 and line >= 1:
		_enable(opt[2], TXT_ELSE2)
	else:
		_disable(opt[2], TXT_ELSE2_DIS)
	var num := _left_count(world)
	if line <= 2 and num > 5:
		_enable(opt[3], TXT_ELSE3)
	else:
		_disable(opt[3], TXT_ELSE3_DIS)
	if line <= 3 and line >= 1 and not _modifier_active(world, 3) and war_support >= 600 and prev_653 != 3:
		_enable(opt[4], TXT_ELSE4)
	else:
		_disable(opt[4], TXT_ELSE4_DIS)
	_enable(opt[5], TXT_ELSE5)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nigeria := ws.get_country_by_legacy_index(60)
	var opt := int(context.get("option_index", -1))
	var is_sub12 := nigeria != null and nigeria.sub_government == 12
	if is_sub12:
		match opt:
			0:
				if nigeria != null:
					_leave_alliances(nigeria)
					nigeria.government = 3
					nigeria.sub_government = 12
					nigeria.set_tag("对华贸易", true)
				_add(W.I_BUDGET, -40)
				_add(W.I_AGENTS, -40)
				# OilProd += 100f：项目未建模，跳过
				context["result_text"] = TXT_R0_SUB12
			1:
				if nigeria != null:
					_leave_alliances(nigeria)
					nigeria.government = 3
					nigeria.sub_government = 4
					nigeria.set_tag("对华贸易", true)
				_add(W.I_BUDGET, -160)
				_add(W.I_AGENTS, -160)
				# OilProd += 100f：项目未建模，跳过
				if nigeria != null:
					nigeria.stab = 1
				context["result_text"] = TXT_R1_SUB12
			2:
				if nigeria != null:
					_leave_alliances(nigeria)
					nigeria.government = 3
					nigeria.sub_government = 12
					nigeria.内战中 = true
					if int(ws.completed_event_ids.get("event_653", 0)) == 2:
						nigeria.prc_power += 20
					else:
						nigeria.prc_power = 20
				_add(W.I_BUDGET, -100)
				_add(W.I_AGENTS, -100)
				_add(W.I_ARMY, -100)
				context["result_text"] = TXT_R2_SUB12
			3:
				context["result_text"] = TXT_R3_SUB12
		return
	match opt:
		0:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = 3
				nigeria.sub_government = 12
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			# OilProd += 100f：项目未建模，跳过
			context["result_text"] = TXT_R0_ELSE
		1:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = 3
				nigeria.sub_government = 4
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			# OilProd += 100f：项目未建模，跳过
			context["result_text"] = TXT_R1_ELSE
		2:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = 2
				nigeria.sub_government = 8
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -160)
			_add(W.I_AGENTS, -160)
			# OilProd += 100f：项目未建模，跳过
			context["result_text"] = TXT_R2_ELSE
		3:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = 2
				nigeria.sub_government = 3
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
			# OilProd += 100f：项目未建模，跳过
			context["result_text"] = TXT_R3_ELSE
		4:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = 3
				nigeria.sub_government = 12
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			if nigeria != null:
				if int(ws.completed_event_ids.get("event_653", 0)) == 2:
					nigeria.prc_power += 20
				else:
					nigeria.prc_power = 20
				nigeria.内战中 = true
			_add(W.I_ARMY, -100)
			context["result_text"] = TXT_R4_ELSE
		5:
			context["result_text"] = TXT_R5_ELSE


func _left_count(world: WorldState) -> int:
	var ids := [59, 112, 113, 114, 68, 107, 67, 64, 63, 62, 108, 61, 56, 58]
	var count := 0
	for id in ids:
		var c := world.get_country_by_legacy_index(id)
		if c == null:
			continue
		if c.government == 2 or world.is_socialism(c, true) or c.sub_government == 10:
			count += 1
	return count


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


func _modifier_active(world: WorldState, index: int) -> bool:
	return world.modifiers.size() > index and world.modifiers[index] != null 			and world.modifiers[index].is_active


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta
