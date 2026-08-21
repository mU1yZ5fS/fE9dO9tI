extends "res://数据脚本/event_script_base.gd"

## 原作事件 71–73：纳萨尔派终局、人民党危机与两伊战争爆发。
## 来源：TimeScript.cs:3972-3995，doneventscript.cs:1767-1823，
##       Results_text.cs:5413-5428,6168-6241。



## 事件 71–73 逐字中文文案。
## 来源：Event71.cs / Event72.cs / Event73.cs。

const TXT_71_TITLE := "东方红…"
const TXT_71_DESC := "多亏了我们的支持，在印度东部的毛派反政府武装，即纳萨尔派分子，在东部各州获得了相当大的影响力和一些公众支持。他们控制着大片地区，他们不断的攻击已经成为令东部各州和印度中央政府头疼的问题。一些印度政客已经在考虑与他们谈判，我们可以利用这一点使印度东部的地方政府接纳纳萨尔派，并在谈判中进行调停，这将大大增加我们对印度的影响力，并在印度东部实行相对坚定的左翼政策。这是以纳萨尔派和印度当局能开始与我们谈判为前提的。是的，保持印度东部的不稳定状况可以给我们一个有相对机动余地的机会，而不是和现在一样的未来……然而，部分将领和党员已经制定了一个行动计划，他们提出利用该形势，向伪阿鲁纳恰尔邦（即我国藏南地区）境内派兵，我们假装“保护平民，恢复秩序”，然后就可以毫无问题地将之收回中国。但这将意味着与印度爆发新的边境战争…"
const TXT_71_OPT0 := "让他们继续进行游击战，这对我们来说已经足够了"
const TXT_71_OPT1 := "以停止敌对行动换取纳萨尔派进入地方政府"
const TXT_71_OPT1_DIS := "他们不会和我们谈判"
const TXT_71_OPT2 := "准备好战争，派遣部队"
const TXT_71_OPT2_DIS := "我们现在不是为了发动战争而加强联系！"
const TXT_71_R0 := "一切都没有改变，纳萨尔派分子继续他们的攻击，印度政府正以不同的成功试图遏制他们。但是谁知道呢，也许有一天他们会对我们有用，因为他们也在我们宣称的领土上活动……"
const TXT_71_R1 := "经过长期的争论和犹豫，印度政府仍然同意通过我们的调解与纳萨尔派进行谈判。在谈判取得成果后，他们非常困难地实现了向和平斗争的过渡，以换取地方政府和自治机关的席位（在少数地区甚至获得了多数席位），并承认他们是合法的政治力量。当然，一些士兵和团体已经称之为背叛，但我们对这些恐怖分子有何关心？我们在印度东部的影响力已大大增强。"
const TXT_71_R2 := "解放军部队很快就攻破了第一个印度边境部队的防御工事，但后来他们依靠了上次边界战争以来组织良好的印度防御工事。看来这场战争会比我们想象的更持久、更血腥……与此同时，全世界都在侧视我们，要求我们立即坐在谈判桌旁。"

const TXT_72_TITLE := "拯救落水者"
const TXT_72_DESC := "在1977年赢得印度大选后，印度人民党，实际上是从社会主义者到民族自由主义者的多个政党的联盟，面临着许多困难。最初，他们为了把英迪拉·甘地和国大党从权力中除名而团结起来，现在，在掌权之后，人民党受到了内部阴谋的困扰，这实际上使它的工作陷入瘫痪。以这种速度，甘地将不可避免地赢得即将在1980年1月举行的选举，这就结束了人民党在改善我们与印度关系方面取得的成功。如果我们帮助反对党并对其施加影响，那么我们可以帮助它巩固和保住权力…"
const TXT_72_OPT0 := "祝你好运，心情愉快"
const TXT_72_OPT1 := "支持人民党左翼（需要6特工网络，10百万预算）"
const TXT_72_OPT1_DIS := "人民党不会听我们的"
const TXT_72_OPT2 := "支持人民党右翼（需要6特工网络，10百万预算）"
const TXT_72_OPT2_DIS := "人民党不会听我们的"
const TXT_72_R0_LEFT := "人民党在印度人民中广受欢迎，对此，所有分析人士都预测他们未来前途无量：人民党将取代国大党，成为制霸印度政坛十余年的主要政党。但由于内部争论和阴谋的压力，人民党总理莫拉尔吉·德赛不得不辞去总理职务。联盟本身也分崩离析，该国也由此产生了大片政治真空。接替他的查兰·辛格可能会坚持到1980年的选举，此后，囊括国大党、左派人民党与印度共产党的联盟预计将赢得大选，而甘地将再度掌权。"
const TXT_72_R0_OTHER := "最后，在内部争论和阴谋的压力下，人民党总理莫拉尔吉·德赛辞去总理职务。接替他的查兰·辛格可能会坚持到1980年的选举，此后甘地将再次取代他。"
const TXT_72_R1 := "我们决定支持人民党内部的左翼，为此，我们的外交官先是说服了党首莫拉尔吉·德赛禁止双重党籍的必要性。德赛很快决定废除双重党籍的同时开除来自主要是联合社会党的成员。然而，我们的特工积极做出了行动以支持这个反国大党大帐篷下的左翼成员，德赛在党大会上遭到指控而被罢免，从而事实上支持左翼派系的夺取。新的领导人乔治.费尔南德斯统合了除了纳萨尔派以外的左翼和令人惊讶的相当一大部分自由派，推行人民党创始人JP纳拉扬的“全面革命”-发展生产力与社会革命政策，看起来将能赢得下一场选举。"
const TXT_72_R2 := "我们决定支持人民党内部的右翼，为此，我们的外交官先是说服了党首莫拉尔吉.德赛禁止双重党籍的必要性。德赛很快决定废除双重党籍的同时开除来自主要是联合社会党的成员。我们的特工积极做出了行动以支持这个反国大党大帐篷下的右翼民族主义者和自由主义者，以维持德赛总理政府的稳定。在乔治.费尔南德斯因为与CIA合作的丑闻暴露后，人民党左派被彻底摧毁。人民党很快开始大规模私有化政策以及进行削减多余的公共支出改革，并且通过社会保守主义和印度民族主义吸引“藏红花”票仓群，看起来将能赢得下一场选举。"

const TXT_73_TITLE := "两伊战争"
const TXT_73_DESC_ALT := "伊朗与伊拉克的关系在新的革命之后越来越差。伊朗自视为全体什叶派的庇护者，而伊拉克指责伊朗的神权政府为独裁专横的法西斯主义者。在边境的摩擦迅速升温。近日，伊朗最高领袖霍梅尼在革命之声电台里宣读了《致伊拉克被压迫的人民书》，其中指责伊拉克“背离了真主所指出的真善美的道路”，“为无神论者和异端大开绿灯”，他还呼吁伊拉克的什叶派推翻革命政府。同时伊朗武装力量在边境发动了大规模的突击。出于保卫祖国的迫切需要，伊拉克总理阿齐兹宣布将进行自卫反击作战。并邀请伊朗境内的左翼反抗力量如人民敢死队和人民圣战者来巴格达，就成立人民革命联盟这样一个反对神权政府的左翼统一战线进行磋商。一场战争爆发了。美国出于意识形态需要，不得不陷入两难局面，而苏联选择支持伊拉克。"
const TXT_73_DESC := "伊朗与伊拉克间的关系长期紧张，这主要是由于领土争端。1969年，伊朗根据1937年的协议控制了伊拉克的阿拉伯河，1971年伊朗占领了伊拉克宣称的霍尔木兹海峡内的三个岛屿。然而，伊朗伊斯兰革命胜利后，形势进一步恶化，霍梅尼想把革命传播到整个穆斯林世界，开始积极派遣煽动者和代理人到伊拉克。以及支持伊拉克库尔德人争取独立的斗争。作为对此的回应，同时考虑到伊朗军队因革命和伊斯兰清洗而混乱，萨达姆·侯赛因决定入侵伊朗，以占领石油资源丰富的胡兹斯坦省。9月22日中午左右，伊拉克军队入侵伊朗，遭遇了强烈的抵抗，目前正在伊朗领土内缓慢地进军。"
const TXT_73_OPT0 := "战争即地狱"
const TXT_73_OPT1_HIDDEN := "战争，战争从未改变"
const TXT_73_OPT2_HIDDEN := "战争即和平"
const TXT_73_OPT3_HIDDEN := "如果你想要和平，准备好战争"
const TXT_73_R0 := "战争势头越来越大，伊朗似乎不会轻易放弃。美国和苏联都呼吁和平，但事实上他们都明里暗里地支持伊拉克，因为伊斯兰主义者的伊朗对他们两者都是个麻烦。"
const TXT_73_WAR := "两伊战争"
const TXT_73_SIDE1 := "伊拉克"
const TXT_73_SIDE2 := "伊朗"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"naxalite_endgame": _event_71(option_index, context)
		"janata_crisis": _event_72(option_index, context)
		"iran_iraq_war": _event_73(context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_71(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			ws.set_flag("cb_india", true)
			context["result_text"] = TXT_71_R0
		1:
			_add_data({W.I_PARTY_SUPPORT: 80, W.I_INFLUENCE: 10, W.I_DIPLO: -10})
			_add_empire_relation(EmpireData.USSR, 50)
			context["result_text"] = TXT_71_R1
		2:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_DIPLO: 50,
				W.I_INDIA_WAR_PRESSURE: 200})
			_add_empire_relation(EmpireData.USA, -150)
			_add_empire_relation(EmpireData.USSR, -250)
			ws.war_state = GameConstants.WarState.INDIA
			context["result_text"] = TXT_71_R2


func _event_72(option_index: int, context: Dictionary) -> void:
	var india := ws.get_country_by_legacy_index(19)
	match option_index:
		0:
			ws.global_influence -= 10
			if india != null:
				india.set_tag("对华贸易", false)
				india.set_tag("亲苏", true)
			if int(ws.india_election) == 1:
				context["result_text"] = TXT_72_R0_LEFT
			else:
				context["result_text"] = TXT_72_R0_OTHER
		1:
			_add_data({W.I_PARTY_SUPPORT: 80, W.I_AGENTS: -60, W.I_BUDGET: -100})
			_add_empire_relation(EmpireData.USA, -80)
			if india != null:
				india.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			context["result_text"] = TXT_72_R1
		2:
			_add_data({W.I_PARTY_SUPPORT: 80, W.I_AGENTS: -60, W.I_BUDGET: -100})
			_add_empire_relation(EmpireData.USA, -80)
			_add_empire_power(EmpireData.USA, 20)
			if india != null:
				india.government = GameConstants.Government.LIBERAL
				india.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			context["result_text"] = TXT_72_R2


func _event_73(context: Dictionary) -> void:
	# Event73.cs TextOfEvents 中 Gosstroy==1 分支随后被无条件覆盖，原版即死代码；本版只采用第二段描述。
	# 原版销毁按钮1-3的文案保留在常量 TXT_73_OPT1_HIDDEN / TXT_73_OPT2_HIDDEN / TXT_73_OPT3_HIDDEN 中以备溯源。
	game.start_war(3, "Iraq", "Iran", 500, 500, 0, 0)
	context["result_text"] = TXT_73_R0


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.size():
			ws.add_data_by_index(index, int(changes[raw_index]))


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.usa_relations = ws.empires[EmpireData.USA].relations
		ws.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.ussr_relations = ws.empires[EmpireData.USSR].relations
		ws.soviet_influence = ws.empires[EmpireData.USSR].power
