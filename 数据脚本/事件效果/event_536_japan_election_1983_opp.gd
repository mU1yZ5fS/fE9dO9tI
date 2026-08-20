extends "res://数据脚本/event_script_base.gd"

## 原作 Event536.cs：保革伯仲：第三幕（革新政权线，3选项，选项0原版销毁）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:302-304 ——
##   (event_done[527]||event_done[528]) && !event_done[534] && c44.puppetOf<0
##   && c44.SubGosstroy==8 && (1983.10 或 1984+)。
## 差异：resultOfEvents 缺省按原版 int 默认 0 处理；选项0按死代码实现分支。

const TXT_OPT1_A := "支持社会革新党"
const TXT_OPT1_B := "在日本人民民主联合阵线的旗帜下支援社会党和共产党联盟"
const TXT_OPT1_DIS := "没人对他们有兴趣"
const TXT_R0 := "我们向自由民主党送去大量的援助，同时派出人员在关键选区进行宣传工作。并且采取各种手段挑拨其他在野党基层组织之间的关系，让它们把更多的竞选资源用于彼此争斗上，从而确保执政党候选人能够稳住阵脚。\n最终自由民主党成功赢下超过半数多数的275个席位，确保了执政地位的稳固。其他党情况如下：社会党107席，依旧没能取得更大胜利。公明党53席，民主社会党33席，共产党21席，新自由俱乐部3席，社会民主联合3席、无所属议员16席。\n新政府由中曾根康弘领导，宣布将全面推进新自由主义改革，开始国有公司的部分私有化与拆分，限制工会权利，放松政府管制并更进一步融入全球市场。在外交方面，新政府表示将努力维护中日友好关系并开展全方位经济合作，此外新政府也将保持与美国的沟通，并表示必须全面提防苏联及其他国家可能的间谍活动。"
const TXT_R1_A := "我们向社会革新党送去大量的资金支持，同时派出大量人员在关键选区进行宣传工作。社会革新党自己也组织了大批基层活动家，在中央委员的带领下亲赴各个市区散发传单，与市民交流并解答他们的问题（一些地区的委员甚至直接在选区内临时租屋，在选举结束之前一直住在这里以确保每天都能第一时间与市民沟通）。此外我们在当地的特工也成功制造了多起针对自由民主党候选人集会的骚乱，确保社会革新党能够击败这个庞然大物。
最终社会革新党如选举前许多媒体所猜测的那样，取得了前所未有的胜利，一举夺得275席。自由民主党遭遇大败，只获得193席。其他党情况如下：共产党24席、新自由俱乐部3席、无所属议员16席。
新政府由飞鸟田一雄领导，宣布将保持对经济的宏观引导，引入干预性产业政策并全面开展企业民主化，维系当前的国有化并对其他关键领域也开始国有化尝试（或者按照纲领文件来说，“成为社会所有”），进一步确保工人和工会权利并加强政府对它们的影响，对农民采取进一步的保护性措施。在外交上，新政府表示将努力维护中日友好关系并开展全方位经济合作，也将改善与其他社会主义政党和政权的关系，并将与美国展开关于《日美安保条约》问题的再谈判。据政府内部人士表示，新政府的谈判目标是促使美军在未来五至十年内逐步分批撤出日本。同时为了避免美国进一步的反应，新政府也将提出一份替代条约方案。"
const TXT_R1_B := "出乎预料的是，社会党并未再与公明党和民主社会党组成联盟参选，而是与共产党合作，宣布结成日本人民民主联合阵线参与选举工作。而我们也向其送去大量的资金支持，并派出大量人员在关键选区进行宣传工作（重点强调阵线理念与苏式发达社会主义的完全不同，以及完全独立于苏联的自主路线）。此外在工会干部的帮助下，我们迅速组织了上百万人在全国各地展开大规模集会与游行以声援阵线。日本共产主义抵抗者同盟也成功号召了一批高校学生与农民展开行动。东京大学、京都大学等学校再次爆发斗争，扰乱了执政党在多个关键选区的原定计划。最后，我们在当地的特工也成功制造了多起针对自由民主党候选人集会的骚乱，确保联合阵线能够击败这个庞然大物。
最终人民民主联合阵线取得了前所未有的胜利，一举夺得265席。自由民主党遭遇大败，只获得190席。其他党情况如下：公明党25席、民主社会党20席、社会民主联合3席、新自由俱乐部2席、无所属议员6席。
新政府由向坂逸郎领导，宣布将以科学社会主义为核心，对经济进行全面引导和干预，实施大规模企业民主化，维持并迅速开展新一轮国有化浪潮，设立国家计划委员会以为计划经济的实施做准备。在外交上，新政府表示将努力维护中日友好关系并开展全方位经济合作，同时与苏联和社会主义阵营展开合作，并将就完全废除《日美安保条约》问题与美国展开谈判。据政府内部人士表示，新政府的谈判目标是促使美军在未来五年内逐步分批撤出日本并确保日本摆脱美国的影响。"
const TXT_R2 := "我们决定按兵不动，静观局势发展。\n最终结果如下：社会党112席、公明党58席、民主社会党38席、共产党26席、新自由俱乐部8席、社会民主联合3席，无所属议员16席。自由民主党依旧未能拿到多数，只有248席，不得不拉拢无所属议员和新自由俱乐部来保证执政地位。\n新政府由中曾根康弘领导，宣布将全面推进新自由主义改革，开始国有公司的大规模私有化与拆分，限制工会权利，放松政府管制并更进一步融入全球市场。在外交方面，新政府全面向美国和北约靠拢，强化日美同盟关系的同时开始尝试加强自身军事力量，并强调必须全面提防苏联及其他国家可能的间谍活动，就像今年年初中曾根在《华盛顿邮报》董事长早餐会上所说的那样，日本列岛将“像不沉的航空母舰一样坚固防御”。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_disable(opt[0], event_def.options[0].text)
	var r531 := int(ws.completed_event_ids.get("event_531", 0))
	var r523 := int(ws.completed_event_ids.get("event_523", 0))
	var c44 := world.get_country_by_legacy_index(44)
	if r531 == 0:
		_enable(opt[1], TXT_OPT1_A)
	elif r531 == 1 and r523 == 0 and c44 != null and c44.prc_power >= 100:
		_enable(opt[1], TXT_OPT1_B)
	else:
		_disable(opt[1], TXT_OPT1_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c44 := ws.get_country_by_legacy_index(44)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if c44 != null:
				c44.government = GameConstants.Government.LIBERAL
				c44.sub_government = GameConstants.SubGovernment.MODERATE
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
			var r531 := int(ws.completed_event_ids.get("event_531", 0))
			if r531 == 0:
				if c44 != null:
					c44.government = GameConstants.Government.REFORMIST
					c44.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					c44.set_tag("亲美", false)
					c44.set_tag("亲中", true)
					c44.set_tag("对华贸易", true)
				_add(W.I_BUDGET, -150)
				_add(W.I_AGENTS, -150)
				_add(W.I_PARTY_SUPPORT, 150)
				_add(W.I_PEOPLE_SUPPORT, 150)
				_add(W.I_DIPLO, -20)
				ws.influence_prc += 50
				_add_relation(EmpireData.USA, -150)
				_add_power(EmpireData.USA, -30)
				context["result_text"] = TXT_R1_A
			else:
				if c44 != null:
					c44.government = GameConstants.Government.SOCIALIST
					c44.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
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
				_add_power(EmpireData.USA, -50)
				context["result_text"] = TXT_R1_B
		2:
			if c44 != null:
				c44.government = GameConstants.Government.LIBERAL
				c44.sub_government = GameConstants.SubGovernment.LIBERAL
				c44.set_tag("亲美", true)
				c44.set_tag("亲中", false)
			_add_power(EmpireData.USA, 30)
			context["result_text"] = TXT_R2
