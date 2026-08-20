extends "res://数据脚本/event_script_base.gd"

## 原作 Event575.cs：伦敦桥倒下了（澳大利亚共和，二选项）。
## 触发：ReqEventForDLC02.cs:789-792 —— c92.Gosstroy==1 || (c92.Gosstroy==2 && c92.isSocEU)。
## 差异：
##  - 描述按 c92 政体/标签与 c135 子政体动态拼接；resultOfEvents[573]==1 追加提问；
##  - Vyshi → 亲美；isSocEU → soc_eu；Torg → 对华贸易；cw → 内战中；
##  - 选项1 非欧社联分支 load_scene_after_click+number_event=576 → EventEngine.enqueue_chain(["event_576"])。


const TXT_DESC_BASE := "主席同志！重大消息，是澳大利亚方面的。\n"
const TXT_DESC_HARD := "英国工党“硬左派”废除君主制并转向联邦共和的政治改革已导致维系英联邦的旧政治关系名存实亡，并顺势激起了澳大利亚人的反君主情绪：既然英国已经给女王分配了公民身份，那澳大利亚也应该效法母国“先进经验”。对温莎王朝和与之有关的澳洲一切建制的落井下石就此开始。"
const TXT_DESC_SOFT := "英国工党“软左派”为加入欧洲社会主义联盟而实行的配套改革政治改革已导致维系英联邦的旧政治关系名存实亡，并顺势激起了澳大利亚人的反君主情绪：既然英国已经将女王掏空为政治木偶，那澳大利亚也应该效法母国“先进经验”。对温莎王朝和与之有关的澳洲一切建制的落井下石就此开始。"
const TXT_DESC_TROT := "英国托洛茨基主义者改革上议院与打击贵族的政治改革已导致维系英联邦的旧政治关系名存实亡，并顺势激起了澳大利亚人的反君主情绪：既然英国已经将女王掏空为政治木偶，那澳大利亚也应该效法母国“先进经验”。对温莎王朝和与之有关的澳洲一切建制的落井下石就此开始。"
const TXT_DESC_HAWKE := "当然，相应措施也不可避免地导致了恐赤情绪的进一步激化——甚至影响了自由党-乡村党联合的政治路线。为稳定社会秩序，澳大利亚总理鲍勃·霍克立即准备三步走：首先是宣布澳大利亚成为共和国，其次是建立临时政府修宪并迅速举行大选。本次选举可被视为澳大利亚的第二次开国，显然将为该国的政治发展定调……"
const TXT_DESC_FRASER := "当然，相应措施也不可避免地导致了恐赤情绪的进一步激化——甚至影响了自由党-乡村党联合的政治路线。为稳定社会秩序，澳大利亚总理马尔科姆·弗雷泽立即准备三步走：首先是宣布澳大利亚成为共和国，其次是建立临时政府修宪并迅速举行大选。本次选举可被视为澳大利亚的第二次开国，显然将为该国的政治发展定调……"
const TXT_DESC_ASK := "我们要帮一把我们的工党同志，彻底决定这个新生共和国的命运吗？"

const TXT_OPT0_DIS := "我们无从下手……"

const TXT_R0 := "得到我国帮助的工党很快便以绝对多数制霸选举，并代表大多数选民拥抱了澳大利亚的完全转型：澳大利亚将在沿用代议制民主的框架下拥抱全新的原住民-多元文化认同，并以斯堪的纳维亚社会主义为蓝本建设服务大众的经济。前进吧，公平的澳大利亚！"
const TXT_R0_EU := "|新生的澳大利亚共和国并没有忘记与英国的纽带，同样决定和欧社联合作。"
const TXT_R1_NORMAL := "英帝国的坠落与恐赤情绪最终导致了意想不到的黑马夺魁：昆士兰的“乡巴佬独裁者”，以操纵选票而臭名昭著的约·比耶克·彼德森成为了自由党-乡村党联合提名的候选人。他很快便将自己的“昆士兰经验”推广至全国，最终如愿当选共和国第一任总理！不过，彼德森的“含金量”有目共睹：光是想到他在选区将屈居第三的乡村党打造为州内铁桶的经历，就足以激起范围波及全澳的大规模抗议。看来澳大利亚注定成为“不自由民主政权”。"
const TXT_R1_EU := "纠结的亲英情绪最终又一次帮助了工党。也就在欧洲民主左翼取得大胜的背景下，新一场选举以工党取得微弱多数，并同获得空前票数的澳大利亚共产党等左翼势力结盟告终。他们代表大多数选民拥抱了澳大利亚的完全转型：澳大利亚将在沿用代议制民主的框架下拥抱全新的原住民-多元文化认同，并以斯堪的纳维亚社会主义为蓝本建设服务大众的经济。前进吧，公平的澳大利亚！而新生的澳大利亚共和国也清楚投桃报李的道理，在左翼联合政府形成次日便向欧洲社会主义联盟递交了入盟申请。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var c92 := world.get_country_by_legacy_index(92)
	var c135 := world.get_country_by_legacy_index(135)
	var r573 := int(world.completed_event_ids.get("event_573", 0))
	var desc := TXT_DESC_BASE
	if c92 != null and (c92.government == 2 or c92.government == 1) and c92.sub_government != 18 \
			and not c92.has_tag("soc_eu") and not c92.has_tag("nato"):
		desc += TXT_DESC_HARD
	elif c92 != null and c92.government == 2 and c92.has_tag("soc_eu"):
		desc += TXT_DESC_SOFT
	else:
		desc += TXT_DESC_TROT
	if c135 != null and c135.sub_government == 4:
		desc += TXT_DESC_HAWKE
	else:
		desc += TXT_DESC_FRASER
	if r573 == 1:
		desc += TXT_DESC_ASK
	event_def.description = desc
	var opt := event_def.options
	if r573 == 1 and c135 != null and not c135.has_tag("亲美"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c135 := ws.get_country_by_legacy_index(135)
	var c136 := ws.get_country_by_legacy_index(136)
	var c85 := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			if c135 != null:
				_leave_alliances(c135)
				c135.government = 2
				c135.sub_government = 3
				c135.set_tag("对华贸易", true)
				c135.set_tag("亲中", true)
			_add_relation(EmpireData.USA, -200)
			_add_power(EmpireData.USA, -50)
			if c85 != null and c85.has_tag("soc_eu"):
				var text := TXT_R0 + TXT_R0_EU
				if c135 != null:
					c135.set_tag("soc_eu", true)
				if c136 != null:
					_leave_alliances(c136)
					c136.government = 2
					c136.sub_government = 3
					c136.内战中 = true
					c136.set_tag("对华贸易", true)
					c136.set_tag("soc_eu", true)
				context["result_text"] = text
			else:
				context["result_text"] = TXT_R0
		1:
			if c135 != null:
				c135.set_tag("亲美", false)
				c135.government = 2
			if c85 != null and c85.has_tag("soc_eu"):
				if c135 != null:
					c135.sub_government = 14
					c135.set_tag("soc_eu", true)
				if c136 != null:
					_leave_alliances(c136)
					c136.government = 2
					c136.内战中 = true
					c136.sub_government = 3
					c136.set_tag("soc_eu", true)
				context["result_text"] = TXT_R1_EU
			else:
				if c135 != null:
					c135.sub_government = 8
				EventEngine.enqueue_chain(["event_576"])
				context["result_text"] = TXT_R1_NORMAL
