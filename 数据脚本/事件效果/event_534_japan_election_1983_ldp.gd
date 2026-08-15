extends "res://数据脚本/event_script_base.gd"

## 原作 Event534.cs：保革伯仲：第三幕（自民党优势线，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:297-299 ——
##   (event_done[527]||event_done[528]) && !event_done[536] && c44.puppetOf<0
##   && c44.SubGosstroy==6 && (1983.10 或 1984+)。
## 差异：resultOfEvents 缺省按原版 int 默认 0 处理；isSocEU→has_tag("soc_eu")。

const TXT_TITLE := "保革伯仲：第三幕"
const TXT_DESC := "在大平正芳于1980年去世后，中曾根康弘替代过渡的西村英一成为自由民主党新总裁以及日本首相。1983年10月12日，在东京地方法院对洛克希德公司案进行的一审中，前首相田中角荣被判处4年有期徒刑和5亿日元附加费，但田中坚持无罪，提出上诉并拒绝辞去众议院议员职务。议会也因为前首相的刑期而陷入混乱，在野党强力坚持提出并表决建议田中辞去国会职务的决议案，审议陷入僵局。最终众参两院的议长提出了调解方案并获得通过，中曾根内阁决定在重要法案获得通过后解散众议院。11月28日，众议院解散。12月18日，新一轮选举将正式开始。\n自由民主党正在逐步摆脱之前的颓势，但尚未完全恢复元气。在野党也在摩拳擦掌，试图在即将到来的大选中取得成绩。现在是我们该行动的时候了！"
const TXT_OPT0 := "援助自由民主党"
const TXT_OPT0_DIS := "没人对他们有兴趣"
const TXT_OPT1_A := "支援社会民主党"
const TXT_OPT1_B := "支持人民民主联合阵线"
const TXT_OPT1_DIS := "没人对他们有兴趣"
const TXT_OPT2 := "保持观望"
const TXT_R0 := "我们向自由民主党送去大量的援助，同时派出人员在关键选区进行宣传工作。并且采取各种手段挑拨其他在野党基层组织之间的关系，让它们把更多的竞选资源用于彼此争斗上，从而确保执政党候选人能够稳住阵脚。\n最终自由民主党成功赢下超过半数多数的275个席位，确保了执政地位的稳固。其他党情况如下：社会党107席，依旧没能取得更大胜利。公明党53席，民主社会党33席，共产党21席，新自由俱乐部3席，社会民主联合3席、无所属议员16席。\n新政府由中曾根康弘领导，宣布将全面推进新自由主义改革，开始国有公司的部分私有化与拆分，限制工会权利，放松政府管制并更进一步融入全球市场。在外交方面，新政府表示将努力维护中日友好关系并开展全方位经济合作，此外新政府也将保持与美国的沟通，并表示必须全面提防苏联及其他国家可能的间谍活动。"
const TXT_R1_A := "我们向社会民主党送去大量的援助，同时派出大量人员在关键选区进行宣传工作，还集结了一批社会团体为其进行全力应援。而我们在当地的特工也成功制造了多起针对自由民主党候选人集会的骚乱，确保社会民主党能够击败这个庞然大物。
最终社会民主党如选举前许多媒体所猜测的那样取得前所未有的胜利，一举夺得275席，实现了“参政交代”的目标。自由民主党遭遇大败，只获得193席，失去了半数多数并首次成为在野党。其他党情况如下：共产党24席、新自由俱乐部3席、无所属议员16席。
新政府由飞鸟田一雄领导，宣布将进一步完善市场经济体制，保护私营经济发展的同时加强政府管理，保证国家对经济的宏观调控权。对工人和工会的权利问题进行重新修订，扩展社会福利政策。在外交上，新政府表示将努力维护中日友好关系并开展全方位经济合作，并将与美国展开关于《日美安保条约》问题的再谈判。据政府内部人士表示，新政府的谈判目标是促使美军在未来五至十年内逐步分批撤出日本。同时为了避免美国进一步的反应，新政府也将提出一份替代条约方案。"
const TXT_R1_B := "我们向人民民主联合阵线送去大量的资金支持，同时派出大量人员在关键选区进行宣传工作（重点强调阵线理念与苏式发达社会主义的完全不同，以及完全独立于苏联的自主路线）。此外我们在工会干部和进步青年的帮助下，组织了数十万人在全国各地展开大规模集会与游行以声援阵线。此外我们在当地的特工也成功制造了多起针对自由民主党候选人集会的骚乱，确保联合阵线能够击败这个庞然大物。
最终人民民主联合阵线出乎选举前许多媒体所料，取得了前所未有的胜利，一举夺得265席。自由民主党遭遇大败，只获得190席，失去了半数多数并首次成为在野党。其他党情况如下：公明党25席、民主社会党20席、社会民主联合3席、新自由俱乐部2席、无所属议员6席。
新政府由宫本显治领导，宣布将保持对经济进行宏观引导，对大企业实施民主监管制度，对部分产业征收更高税金，维持当前的国有化并重新立法以确保工人和工会权利。在外交上，新政府表示将努力维护中日友好关系并开展全方位经济合作，并将与美国展开关于《日美安保条约》问题的再谈判。据政府内部人士表示，新政府的谈判目标是促使美军在未来五至十年内逐步分批撤出日本。同时为了避免美国进一步的反应，新政府也将提出一份替代条约方案。"
const TXT_R1_SOCEU := "
令世界出乎意料的是，日本向成员国大多为欧洲国家的社会主义联盟提交了申请，而社会主义联盟中央委员会也同意了日本的请求，这究竟意味着社会主义联盟并不把自己局限于欧洲、而是有着更大的“野心”，还是日本仍未放弃脱亚入欧的“愿景”？"
const TXT_R2 := "我们决定按兵不动，静观局势发展。\n最终结果如下：社会党112席、公明党58席、民主社会党38席、共产党26席、新自由俱乐部8席、社会民主联合3席，无所属议员16席。自由民主党依旧未能拿到多数，只有248席，不得不拉拢无所属议员和新自由俱乐部来保证执政地位。\n新政府由中曾根康弘领导，宣布将全面推进新自由主义改革，开始国有公司的大规模私有化与拆分，限制工会权利，放松政府管制并更进一步融入全球市场。在外交方面，新政府全面向美国和北约靠拢，强化日美同盟关系的同时开始尝试加强自身军事力量，并强调必须全面提防苏联及其他国家可能的间谍活动，就像今年年初中曾根在《华盛顿邮报》董事长早餐会上所说的那样，日本列岛将“像不沉的航空母舰一样坚固防御”。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var r529 := int(ws.completed_event_ids.get("event_529", 0))
	var r530 := int(ws.completed_event_ids.get("event_530", 0))
	if r529 == 0 and ws.completed_event_ids.has("event_529"):
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if r530 == 0:
		_enable(opt[1], TXT_OPT1_A)
	elif r530 == 1:
		_enable(opt[1], TXT_OPT1_B)
	else:
		_disable(opt[1], TXT_OPT1_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c44 := ws.get_country_by_legacy_index(44)
	var c21 := ws.get_country_by_legacy_index(21)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if c44 != null:
				c44.government = 3
				c44.sub_government = 5
				c44.set_tag("亲美", false)
				c44.set_tag("亲中", true)
				c44.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, 150)
			_add(W.I_DIPLO, -20)
			ws.influence_prc += 50
			_add_relation(EmpireData.USSR, -150)
			_add_relation(EmpireData.USA, 150)
			_add_power(EmpireData.USA, 30)
			_add_power(EmpireData.USSR, -30)
			context["result_text"] = TXT_R0
		1:
			var r530 := int(ws.completed_event_ids.get("event_530", 0))
			if r530 == 0:
				if c44 != null:
					c44.government = 3
					c44.sub_government = 4
					c44.set_tag("亲美", false)
					c44.set_tag("亲中", true)
					c44.set_tag("对华贸易", true)
				_add(W.I_BUDGET, -100)
				_add(W.I_AGENTS, -100)
				_add(W.I_PARTY_SUPPORT, 150)
				_add(W.I_PEOPLE_SUPPORT, 150)
				_add(W.I_DIPLO, -20)
				ws.influence_prc += 50
				_add_relation(EmpireData.USA, -150)
				_add_power(EmpireData.USA, -30)
				context["result_text"] = TXT_R1_A
			else:
				var text := TXT_R1_B
				if c21 != null and c21.has_tag("soc_eu"):
					text += TXT_R1_SOCEU
					if c44 != null:
						_leave_alliances(c44)
						c44.set_tag("soc_eu", true)
				if c44 != null:
					c44.government = 2
					c44.sub_government = 14
					c44.set_tag("亲美", false)
					c44.set_tag("亲中", true)
					c44.set_tag("对华贸易", true)
				_add(W.I_BUDGET, -200)
				_add(W.I_AGENTS, -200)
				_add(W.I_PARTY_SUPPORT, 150)
				_add(W.I_PEOPLE_SUPPORT, 150)
				_add(W.I_DIPLO, -20)
				ws.influence_prc += 50
				_add_relation(EmpireData.USA, -150)
				_add_power(EmpireData.USA, -30)
				context["result_text"] = text
		2:
			if c44 != null:
				c44.government = 3
				c44.sub_government = 6
				c44.set_tag("亲美", true)
				c44.set_tag("亲中", false)
			_add_power(EmpireData.USA, 50)
			context["result_text"] = TXT_R2
