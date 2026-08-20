extends "res://数据脚本/event_script_base.gd"

## 原作 Event581.cs：铜臭味（赞比亚，四选项）。
## 触发：ReqEventForDLC02.cs:814-817 —— (日>=24 且 月>=10 且 年>=1983) || (月>=11 且 年>=1983) || 年>=1984
##   → DATE_AFTER 1983.10.24。
## 差异：
##  - 选项显隐 prepare 动态改写；resultOfEvents[352]/[361]/[500] 缺省按原版 int 默认 0；
##  - names1+names2 → _leader_name()（同 Event650 约定）；data[12] → W.I_INDUSTRY；
##  - JoinECON → 仅 econ 标签 + social_stability=1000；name → chinese_name；
##  - load_scene_after_click + data[35]=13 → GameManager.queue_ending_after_event(13)。



const TXT_OPT0_DIS := "他是独裁暴君，不是朋友"
const TXT_OPT1_DIS := "不，不能这么做"
const TXT_OPT2_DIS := "等等，谁？"

const TXT_R0_A := "在为这位非洲南端的反帝斗士接风洗尘的招待宴上，"
const TXT_R0_B := "同志发表了“勿忘坦赞铁路精神”的演讲。其中高度赞扬了卡翁达总统为发展赞比亚作出的突出贡献，称联合民族独立党是赞比亚建设的领军人。在演讲的最后，"
const TXT_R0_C := "同志表示了将会为赞比亚提供力所能及的帮助。卡翁达总统激动的握住了"
const TXT_R0_D := "同志的双手，甚至流下了感动的泪水，这一幕被记者敏锐的捕捉到了，这肯定会在明日的报纸上占有一席之地。\n很快，我们的粮食，工程师，赤脚医生和农业队顺着75年完工的坦赞铁路再度来到该国。该国在建设社会主义中有一些急于求成的毛病，而我们将为他们开出一剂药方。联合独立党进行大规模的清党，打贪，批评与自我批评的运动。在新的一版党章中，联合独立党确定了社会主义的方针，对该国循序渐进的社会主义路程确定了新航线。该党在开除了大批右派分子之后，吸纳了一部分社会主义者，作为摆设的贵族院也被撤除，该党改名为联合社会主义独立党。该国新的经济计划以坦桑尼亚的《阿鲁沙宣言》所宣称的社会主义为蓝本，维持高度的国有-公有的同时谨慎打击小资产阶级。但对西方国家所掌握的“命脉”产业如铜矿，粮食和运输等，政府则毫不留情的回收权益。国民高福利的待遇也没有被取消，甚至得以提升，我们和赞比亚的合作为该国创造了更多的就业岗位。他们也将成为中国援助的又一个力证，为我们打下了一口金字招牌。\n赞比亚仍然是我们的老朋友，毕竟我们不是那种用几个臭钱就会抛弃朋友的人。"
const TXT_R1 := "在接待卡翁达总统的时候，我们的特勤人员正在卢萨卡紧锣密鼓的鼓动一次政变。很快，一场政变在南非的支持下发生了。\n趁着卡翁达总统出访我国的机会。曼巴·卢奇本上尉率领着赞比亚军队，南非军人和我们的特工组成的队伍奔向卢萨卡的广播电台和监狱。在极度的混乱中，我们的人找到了弗雷德里克·奇卢巴。同时前往电视台的分队也圆满完成了任务。军政府宣布联合民族独立党的一党专政事实上违反了宪法，并强行解散了国会。随后在一场操控的大选中，奇卢巴的赞比亚自由民主党取得了绝对多数的地位。新政府剥夺了卡翁达的赞比亚公民权，我们也宣布其为“不欢迎的人”，他不得不前往墨西哥避难。\n新政府将大批国营和合营的企业加速私有化，或者变卖给南非和我国的金融寡头。尽管发家于工人运动，新总统却迅速滑向了金融寡头，境外资本的一边，同他们沆瀣一气的镇压工人运动。在政变爆发的第一天早上，无数愤怒的群众走上街头，军政府残酷的镇压了这次暴动，造成了远超卡翁达时期的政治灾难。近100人罹难，数千人受伤。但南非在报纸上宣传赞比亚镇压暴徒的的行为“无比正确”，并提出了驻军的要求。彻底沦为了境外势力，尤其是南非的傀儡的新政府无力拒绝。这真的会为赞比亚带来和平或发展吗？\n现在，我们的手上沾满了铜臭味。"
const TXT_R2 := "我们获得邀请参加一次盛大的赞比亚联合民族独立党代表大会，在无人知晓的情况下，简单的招待宴席变成了一场盛大的狂欢。酒精在肝脏内转化为乙醛乙酸，醉醺醺的众人没有发现他们通过了一项近乎是恶作剧的法案—推举爱德华·恩科洛索为新一届总统。\n恩科洛索曾放出豪言，要赶在美苏之前登上太空。60年代的他曾计划发射一枚火箭，并把两只猫，一位女航天员和一名传教士送上月球。为了训练全国上下挑选出的17名精兵，他利用油桶模拟失重，用秋千模仿在月球上的零重力环境。并计划开设一个在火星上的传教基地。\n从宿醉和狂欢中醒来的赞比亚政客要头疼的不只是酒精，他们的新总统打算在我国的天宫空间站上完成就职仪式！\n在遥远的太空，恩科洛索透过舷窗望向养育他的故乡，等等，地上的是什么？"
const TXT_R3_A := "我们热烈的接待了的卡翁达总统，但对于其提出的援助要求，我们不予评价。"
const TXT_R3_AU := "新生的非洲联盟迅速宣布提供了一笔紧急贷款，用于缓解该国的问题。同时，非洲的政治学者和工程师前往该国进行考察并提供行之有效的方案。该国的问题在非洲同胞的帮助下有所好转。这证明了没有殖民者的阻挠，非洲人自己可以建设非洲——他们自己的非洲。"
const TXT_R3_HARD := "赞比亚不得不宣布进入一段“困难时期”。许多过去的政策如削减补贴，更大幅度的自由化，甚至是紧缩政策和政府裁员。他本人也在党内发动了反腐倡廉打老虎的运动，但只有不到30%的官员不从事商业或土地兼并的生意。看来很长一段时间内，萎靡不振的经济都将威胁该国的正常发展。"
const TXT_R3_SA := "在南非政府的策动下，曼巴·卢奇本上尉率领着赞比亚军队和南非军组成的队伍奔向卢萨卡的广播电台和监狱。在极度的混乱中，政变部队找到了弗雷德里克·奇卢巴。同时前往电视台的分队也圆满完成了任务。军政府宣布联合民族独立党的一党专政事实上违反了宪法，并强行解散了国会。随后在一场操控的大选中，奇卢巴的赞比亚自由民主党取得了绝对多数的地位。新政府剥夺了卡翁达的赞比亚公民权，并宣布其为“不欢迎的人”，他不得不留在我国避难。\n在南非的集体防御方案下，赞比亚新宪法为种族隔离制度摇旗呐喊，并正式恢复了北罗得西亚的旧名。新政府将大批国营和合营的企业加速私有化，或者变卖给南非和我国的金融寡头。尽管发家于工人运动，新总统却迅速滑向了金融寡头，境外资本的一边，同他们沆瀣一气的镇压工人运动。在政变爆发的第一天早上，无数愤怒的群众走上街头，军政府残酷的镇压了这次暴动，造成了远超卡翁达时期甚至是独立前的政治灾难。近100人罹难，数千人受伤。但南非在报纸上宣传该国镇压暴徒的的行为“无比正确”，并提出了驻军的要求。彻底沦为了境外势力，尤其是南非的傀儡的新政府无力拒绝。这真的会为北罗得西亚带来和平或发展吗？"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var c131 := world.get_country_by_legacy_index(131)
	var r352 := int(world.completed_event_ids.get("event_352", 0))
	var r361 := int(world.completed_event_ids.get("event_361", 0))
	var opt := event_def.options
	if line < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line >= 2 and c131 != null and (c131.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN or c131.sub_government == GameConstants.SubGovernment.NEO_FASCIST):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if data.size() > W.I_INDUSTRY and data[W.I_INDUSTRY] >= 1200 and r352 == 2 and r361 >= 0 and r361 <= 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c124 := ws.get_country_by_legacy_index(124)
	var china := ws.get_country_by_legacy_index(1)
	var c131 := ws.get_country_by_legacy_index(131)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var tname := _leader_name()
			var text := TXT_R0_A + tname + TXT_R0_B + tname + TXT_R0_C + tname + TXT_R0_D
			_add(W.I_BUDGET, -50)
			if c124 != null:
				c124.government = GameConstants.Government.SOCIALIST
				c124.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c124)
				c124.set_tag("亲中", true)
				c124.set_tag("对华贸易", true)
			if china != null and china.has_tag("econ") and c124 != null:
				c124.set_tag("econ", true)
				c124.social_stability = 1000
			ws.influence_prc += 20
			_add(W.I_DIPLO, 20)
			context["result_text"] = text
		1:
			if c124 != null:
				c124.government = GameConstants.Government.AUTHORITARIAN
				c124.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(c124)
				c124.set_tag("对华贸易", true)
				c124.puppet_of = 131
			_add(W.I_BUDGET, 100)
			_add(W.I_AGENTS, -50)
			context["result_text"] = TXT_R1
		2:
			if c124 != null:
				c124.government = GameConstants.Government.AUTHORITARIAN
				c124.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				_leave_alliances(c124)
				c124.set_tag("对华贸易", true)
			GameManager.queue_ending_after_event(13)
			_add(W.I_BUDGET, 100)
			_add(W.I_AGENTS, -50)
			context["result_text"] = TXT_R2
		3:
			var text := TXT_R3_A
			var r500 := int(ws.completed_event_ids.get("event_500", 0))
			if r500 == 0:
				text += TXT_R3_AU
				if c124 != null:
					c124.government = GameConstants.Government.REFORMIST
					c124.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					_leave_alliances(c124)
					c124.set_tag("对华贸易", true)
					c124.set_tag("okb", true)
				context["result_text"] = text
			else:
				text += TXT_R3_HARD
				if c131 != null and c131.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
					text += TXT_R3_SA
					if c124 != null:
						c124.government = GameConstants.Government.AUTHORITARIAN
						c124.sub_government = GameConstants.SubGovernment.NEO_FASCIST
						_leave_alliances(c124)
						c124.chinese_name = "北罗得西亚"
						c124.puppet_of = 131
				context["result_text"] = text


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
