extends "res://数据脚本/event_script_base.gd"

## 原作 Event405.cs：英国大选-1979（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1271 —— DATE_AFTER 1979.5.1。
## 差异：modifies[57].active→ws.modifiers[57].is_active。

const TXT_TITLE := [
	"英国大选-1979",
]

const TXT_DESC := [
	"1973年的石油危机严重影响了西欧经济，并为英国30年以来的经济繁荣踩下了刹车。工党政府试图通过继续实行凯恩斯主义改革以稳定局势。然而，这些措施只是小修小补，未能解决英国经济的结构性问题——该国产业在引用最新技术成果上滞后，相当数量的国有企业盈利能力不足。危机在“不满之冬”到达顶峰：英国工会在事件期间向政府施压，以切断国内交通物流与关键社会设施的形式，要求其抬高劳动者工资。该问题进一步激化了一系列的“分离主义”议题（例如苏格兰石油与北爱尔兰的相关议程）与该国加入欧洲共同体的系列矛盾。数月前，议会提出了对政府的不信任案，并最终导致内阁垮台。英国将举行新一届选举。在英国现行的政党制度中，下述三党最受欢迎：保守党承诺将结束工会的胡作非为、在对国内通货膨胀消肿的同时恢复经济增长、工党则倡导实现普遍就业与进步的社会改革、其次则是呼吁修订税收与经济政策的自由党。但谁将赢得接下来的选举呢？",
]

const TXT_OPT0 := [
	"谁将得胜？",
]

const TXT_R := [
	"选举结果如下：保守党获得1370万张（43.9%）选票，在下议院获得339席，以43席的优势获得了绝对多数。1150万名选民则投票给工党，让该党拿下了36.9%的选票，使他们在下议院内获得269席。自由党则获得11席。因此，保守党足以无视其他政党的立场，在议会内随心所欲地推行本党的政策。对于联合王国来说，该国第一次迎来了由女性主导的政府。保守党人玛格丽特·撒切尔领导的当局将实行反通货膨胀、发展私营企业、减税以及对部分国有企业实行再私有化（包括出售一部分有关北海石油公司的国有股票）的一系列政策。打击犯罪与限制工会权利也被作为国内政策的优先。此外，政府还计划通过削减国家开支、住房建设与医疗帮张服务以节约预算。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1188 := "event.script.event_405_uk_election_1979.c0"
const TXT_IDX_1189 := "event.script.event_405_uk_election_1979.c1"
const TXT_IDX_1154 := "event.script.event_405_uk_election_1979.c2"
const TXT_IDX_1190 := "event.script.event_405_uk_election_1979.c3"

## 原文字符串附录（供自检）

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uk := ws.get_country_by_legacy_index(92)
	if uk != null:
		uk.sub_government = GameConstants.SubGovernment.NEOLIBERAL
	_add_power(EmpireData.USA, 10)
	if 57 < ws.modifiers.size() and ws.modifiers[57] != null:
		ws.modifiers[57].is_active = true
	context["result_text"] = TXT_R[0]



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_405_uk_election_1979.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_405",
	"num": 405,
	"priority": 40500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_405_uk_election_1979.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.5.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
