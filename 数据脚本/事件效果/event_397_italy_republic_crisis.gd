extends "res://数据脚本/event_script_base.gd"

## 原作 Event397.cs：意大利共和国的危机（三选项）。
## 触发：全目录无 this_num_event=397 / Reset(397)，链外 REST 段无自动触发；trigger_conditions=[]。
## 差异：选项显隐 prepare 动态改写；resultOfEvents 缺省按 0 处理；new_events_text 索引照 Events_text_en。

const TXT_TITLE := [
	"意大利共和国的危机",
]

const TXT_DESC := [
	"前总理阿尔多·莫罗被刺杀后，意大利警方对国内激进派发起了扫荡行动，但调查的最终结果令人始料不及。警方发现，意大利的主要政党与黑手党之间达成了一系列前所未有的腐败交易。作为对竞选资金的回报，天主教民主党与意大利社会党共同构成的政府自觉扮演起黑手党的利益说客，并纵容腐败与非法交易。丑闻导致了不计其数的检查：不少政治家、当地议会代表与企业家纷纷落马，并因此遭遇刑事指控。现存的政党制度已经受到了威胁。天主教民主党与意大利社会党的领导人纷纷被捕，上述政党也宣告自我解散，其成员则纷纷逃蹿到尚未卷入腐败丑闻的现存政党内——即意大利共产党与意大利社会运动等。因此，意大利的政治光谱被极端撕裂。同时，该国对选举制度进行了改革——比例代表制取代了原先的多数代表制。在这种情况下，介于意大利即将提前举行议会选举，我们可以选择将其中一派势力推上前台。",
]

const TXT_OPT0 := [
	"支持左派（需要10.0百万预算与10.0点特工网络）",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......",
]

const TXT_OPT1 := [
	"支持右派（需要10.0百万预算与10.0点特工网络）",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......",
]

const TXT_OPT2 := [
	"不闻不问",
]

const TXT_R := [
	"根据投票结果显示，意大利共产党拿下了超过半数的议会席位，因此赢下选举。在如此大胜的背景下，由恩里科·贝林格领导的新政府得以建立，并宣布将对意大利现行的经济与军事政治一体化议程进行修订。然而，在意大利共产党内部。该党正因“接待”过多来自意大利社会党与天主教民主党的新人而陷入分裂危机，也许这很快便会对意大利历史上的第一个共产主义政府开一个残酷玩笑。",
	"根据投票结果显示，意大利社会运动拿下了超过半数的议会席位，因此赢下选举。在如此大胜的背景下，由乔治·阿尔米兰特领导的新政府得以建立，并宣布将对意大利现行的经济与军事政治一体化议程进行修订。然而，在意大利社会运动内部。该党正因“接待”过多来自天主教民主党的新人而陷入分裂危机，也许这很快便会对意大利40年来的首个极端民族主义政府开一个残酷玩笑。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1114 := "意大利共和国的危机"
const TXT_IDX_1116 := "前总理阿尔多·莫罗被刺杀后，意大利警方对国内激进派发起了扫荡行动，但调查的最终结果令人始料不及。警方发现，意大利的主要政党与黑手党之间达成了一系列前所未有的腐败交易。作为对竞选资金的回报，天主教民主党与意大利社会党共同构成的政府自觉扮演起黑手党的利益说客，并纵容腐败与非法交易。丑闻导致了不计其数的检查：不少政治家、当地议会代表与企业家纷纷落马，并因此遭遇刑事指控。现存的政党制度已经受到了威胁。天主教民主党与意大利社会党的领导人纷纷被捕，上述政党也宣告自我解散，其成员则纷纷逃蹿到尚未卷入腐败丑闻的现存政党内——即意大利共产党与意大利社会运动等。因此，意大利的政治光谱被极端撕裂。同时，该国对选举制度进行了改革——比例代表制取代了原先的多数代表制。在这种情况下，介于意大利即将提前举行议会选举，我们可以选择将其中一派势力推上前台。"
const TXT_IDX_1117 := "支持左派（需要10.0百万{0}与10.0点{1}）"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_567 := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_IDX_1118 := "支持右派（需要10.0百万{0}与10.0点{1}）"
const TXT_IDX_1102 := "不闻不问"
const TXT_OPT0 := ["支持左派（需要10.0百万预算与10.0点特工网络）", "巧妇难为无米之炊，我们手头得有10百万才能干活......", "巧妇难为无米之炊，我们手头得有10支特工网络才能干活......"]
const TXT_OPT1 := ["支持右派（需要10.0百万预算与10.0点特工网络）", "巧妇难为无米之炊，我们手头得有10百万才能干活......", "巧妇难为无米之炊，我们手头得有10支特工网络才能干活......"]
const TXT_OPT2 := ["不闻不问"]
const TXT_IDX_1119 := "根据投票结果显示，意大利共产党拿下了超过半数的议会席位，因此赢下选举。在如此大胜的背景下，由恩里科·贝林格领导的新政府得以建立，并宣布将对意大利现行的经济与军事政治一体化议程进行修订。然而，在意大利共产党内部。该党正因“接待”过多来自意大利社会党与天主教民主党的新人而陷入分裂危机，也许这很快便会对意大利历史上的第一个共产主义政府开一个残酷玩笑。"
const TXT_IDX_1120 := "根据投票结果显示，意大利社会运动拿下了超过半数的议会席位，因此赢下选举。在如此大胜的背景下，由乔治·阿尔米兰特领导的新政府得以建立，并宣布将对意大利现行的经济与军事政治一体化议程进行修订。然而，在意大利社会运动内部。该党正因“接待”过多来自天主教民主党的新人而陷入分裂危机，也许这很快便会对意大利40年来的首个极端民族主义政府开一个残酷玩笑。"

## 原文字符串附录（供自检）

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var opt := event_def.options
	var budget := data[W.I_BUDGET] if data.size() > W.I_BUDGET else 0
	var reserve := data[W.I_RESERVE] if data.size() > W.I_RESERVE else 0
	var agents := data[W.I_AGENTS] if data.size() > W.I_AGENTS else 0
	if budget + reserve >= 100 and agents >= 100:
		_enable(opt[0], TXT_OPT0[0])
		_enable(opt[1], TXT_OPT1[0])
	else:
		if budget + reserve < 100:
			_disable(opt[0], TXT_OPT0[1])
			_disable(opt[1], TXT_OPT1[1])
		else:
			_disable(opt[0], TXT_OPT0[2])
			_disable(opt[1], TXT_OPT1[2])
	_enable(opt[2], TXT_OPT2[0])

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	var num := 0
	var num2 := 0
	if opt == 0:
		_add(W.I_AGENTS, -100)
		_add(W.I_BUDGET, -100)
		num += 2
	elif opt == 1:
		_add(W.I_AGENTS, -100)
		_add(W.I_BUDGET, -100)
		num2 += 2
	var west_germany := ws.get_country_by_legacy_index(45)
	if west_germany != null and west_germany.government == 2:
		num += 1
	if int(ws.completed_event_ids.get("event_049", 0)) == 1:
		num += 1
	for cid in [21, 86]:
		var c := ws.get_country_by_legacy_index(cid)
		if c != null and c.sub_government == 14:
			num += 1
	if ws.empires.size() > 1 and ws.empires[1] != null and ws.empires[0] != null and ws.empires[1].power > ws.empires[0].power:
		num += 2
	var mongolia := ws.get_country_by_legacy_index(2)
	if mongolia != null and mongolia.puppet_of == 7:
		num -= 1
	if int(ws.completed_event_ids.get("event_046", 0)) == 2:
		num -= 1
	if _raw(131) == 3:
		num2 += 1
	var bulgaria := ws.get_country_by_legacy_index(84)
	if bulgaria != null and bulgaria.sub_government == 9:
		num2 += 2
	elif bulgaria != null and bulgaria.sub_government == 7:
		num2 += 1
	if ws.empires.size() > 1 and ws.influence_prc > ws.empires[0].power + ws.empires[1].power:
		num2 += 1
	for cid in [86, 87]:
		var c := ws.get_country_by_legacy_index(cid)
		if c != null and c.government == 0:
			num2 += 1
	_add_power(EmpireData.USA, -50)
	if italy != null:
		italy.special -= 15
	if num >= num2:
		if italy != null:
			italy.set_tag("nato", false)
			italy.set_tag("eu", false)
			italy.set_tag("亲美", false)
			italy.influence_china = 10
		_add_power(EmpireData.USSR, 30)
		context["result_text"] = TXT_R[0]
	else:
		if italy != null:
			italy.influence_nato = 10
			italy.set_tag("nato", false)
			italy.set_tag("eu", false)
			italy.set_tag("亲美", false)
		context["result_text"] = TXT_R[1]

func _raw(i: int) -> int:
	if d.size() > i:
		return d[i]
	return 0
