extends "res://数据脚本/event_script_base.gd"

## 原作 Event411.cs：美国对我国内政不满（六选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1301 —— 复杂条件用 evaluate（IsSocialism/IsAuthoritarianism）。
## 差异：politic.traits[0]→trait_personality；data.get_data_by_index(139/140) raw index。

const TXT_TITLE := [
	"美国对我国内政不满",
]

const TXT_DESC := [
	"这天，一家美国电视台对某位中国反对派兼持不同政见者进行了采访，后者指责中国在内政问题上“毫无民主，采取极权手腕，并完全用行政命令手段解决政治问题”。此外，美国还显著降低了中国本年度的“民主自由指数”评级。美国方面的这些反应可被看作是一个信号：显然，美国领导人要求我们调转航向。否则，就得做好应对一切手段的准备。可我们对此该怎么做呢？",
]

const TXT_OPT0 := [
	"我们已经无路可退！",
]

const TXT_OPT1 := [
	"军事实力必须高于{0}点......",
]

const TXT_OPT2 := [
	"",
]

const TXT_OPT3 := [
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
]

const TXT_OPT4 := [
	"中国的国际影响力应高于{0}......",
]

const TXT_R := [
	"对此，美国驻我国大使热烈祝贺我们回归了“民主自由正道”，并成功战胜了“党内试图发动政变，要搞赤色专政的共产党”。",
	"我们决定绕开华盛顿，在太平洋举行单方面军事演习。这让美国白宫大惊失色，他们媒体对中华人民共和国的污蔑也就此打住。但安稳日子将持续多久呢？",
	"今天，我国官方报纸《人民日报》发表了题为《走有中国特色的民主化道路》一文，该文称：早在三国时期，中国便已经有了自己的伏尔泰与民主主义理论。文章以这样一段话总结全文：“今天的中国特色民主主义可谓是我国民族传统、人民智慧与启蒙思想的完美结合。中国就是这样实现全过程民主，实现人民当家作主的！”尽管这篇文章在党内引起了巨大争议，但华盛顿还是停止了对中华人民共和国的污蔑。但安稳日子将持续多久呢？",
	"我们对世界反共主义运动的资助成功堵住了华盛顿的嘴，他们媒体对中华人民共和国的污蔑也就此打住。",
	"美国赞许我们的和平姿态，但我们为此牺牲了些许国际影响力。",
	"我国在华盛顿发展的下线送来最新消息：如果中国方面仍不思悔改，美国将准备与中国断交。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1261 := "event.script.event_411_usa_discontent.c0"
const TXT_IDX_1262 := "event.script.usa_discontent.txt_idx_1262"
const TXT_IDX_1263 := "event.script.event_411_usa_discontent.c1"
const TXT_IDX_592 := "event.script.event_411_usa_discontent.c2"
const TXT_IDX_593 := "event.script.event_411_usa_discontent.c3"
const TXT_IDX_594 := "event.script.event_411_usa_discontent.c4"
const TXT_IDX_1214 := "event.script.event_411_usa_discontent.c5"
const TXT_IDX_1264 := "event.script.event_411_usa_discontent.c6"
const TXT_IDX_776 := "event.script.event_411_usa_discontent.c7"
const TXT_IDX_1265 := "event.script.event_411_usa_discontent.c8"
const TXT_IDX_1266 := "event.script.usa_discontent.txt_idx_1266"
const TXT_IDX_566 := "event.script.event_411_usa_discontent.c9"
const TXT_IDX_1267 := "event.script.usa_discontent.txt_idx_1267"
const TXT_IDX_620 := "event.script.event_411_usa_discontent.c10"
const TXT_IDX_1254 := "event.script.event_411_usa_discontent.c11"
const TXT_IDX_1268 := "event.script.event_411_usa_discontent.c12"
const TXT_IDX_1269 := "event.script.event_411_usa_discontent.c13"
const TXT_IDX_1270 := "event.script.event_411_usa_discontent.c14"
const TXT_IDX_1271 := "event.script.event_411_usa_discontent.c15"
const TXT_IDX_1272 := "event.script.event_411_usa_discontent.c16"
const TXT_IDX_1273 := "event.script.event_411_usa_discontent.c17"

## 原文字符串附录（供自检）
## 我们已经无路可退！

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var china := world.get_country_by_legacy_index(1)
	var c51 := world.get_country_by_legacy_index(51)
	if china == null or c51 == null:
		return false
	if not china.has_tag("asean"):
		return false
	if c51.special > 0:
		return false
	if not (world.is_socialism(china, true) or (world.is_authoritarian(china) and _raw_in(world, 52) == 34)):
		return false
	return true

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 6:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var opt := event_def.options
	var pick := 0 if (randi() % 2 == 0) else 1
	event_def.description = _fmt(tr(TXT_IDX_1262), [tr(TXT_IDX_1266) if pick == 0 else tr(TXT_IDX_1267)])
	if 11 < world.modifiers.size() and world.modifiers[11] != null and world.modifiers[11].is_active:
		_disable(opt[0], tr(TXT_IDX_1263))
	else:
		_enable(opt[0], tr(TXT_IDX_1263))
	if d.army >= 350:
		_enable(opt[1], _fmt(tr(TXT_IDX_1264), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594), tr(TXT_IDX_1214)]))
	else:
		_disable(opt[1], _fmt(tr(TXT_IDX_776), ["35"]))
	_enable(opt[2], _fmt(tr(TXT_IDX_1265), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594), tr(TXT_IDX_1214)]))
	if d.budget + (d.reserve if d.size() > W.I_RESERVE else 0) >= 150:
		_enable(opt[3], _fmt(tr(TXT_IDX_1266), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594), tr(TXT_IDX_1214)]))
	else:
		_disable(opt[3], _fmt(tr(TXT_IDX_566), ["15"]))
	if world.influence_prc >= 50:
		_enable(opt[4], _fmt(tr(TXT_IDX_1267), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594), tr(TXT_IDX_1214)]))
	else:
		_disable(opt[4], _fmt(tr(TXT_IDX_620), ["5"]))
	_enable(opt[5], tr(TXT_IDX_1254))

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c51 := ws.get_country_by_legacy_index(51)
	if opt == 0:
		if _raw(16) < 15:
			_add(16, 1)
		if _raw(17) < 19:
			_add(17, 1)
		if _raw(15) < 9:
			_add(15, 1)
		_add_power(EmpireData.USA, 25)
		_add_relation(EmpireData.USA, 100)
		_loyalty_usa()
		if c51 != null:
			c51.special = 7
		context["result_text"] = TXT_R[0]
	elif opt == 1:
		_add(W.I_ARMY, -350)
		_add_relation(EmpireData.USA, -150)
		_add_power(EmpireData.USA, -30)
		if c51 != null:
			c51.special = 7
		context["result_text"] = TXT_R[1]
	elif opt == 2:
		_add(W.I_PARTY_SUPPORT, -450)
		_add_relation(EmpireData.USA, -300)
		_loyalty_usa()
		if c51 != null:
			c51.special = 7
		context["result_text"] = TXT_R[2]
	elif opt == 3:
		_add(W.I_BUDGET, -150)
		_add_power(EmpireData.USSR, -20)
		_add_power(EmpireData.USA, 20)
		_add_relation(EmpireData.USA, 100)
		if c51 != null:
			c51.special = 7
		context["result_text"] = TXT_R[3]
	elif opt == 4:
		ws.influence_prc -= 50
		_add_power(EmpireData.USA, 50)
		_add_relation(EmpireData.USA, 100)
		if c51 != null:
			c51.special = 7
		context["result_text"] = TXT_R[4]
	else:
		if c51 != null:
			c51.special = 7
		_add(139, 5)
		_add(140, 2)
		context["result_text"] = TXT_R[5]

func _raw(i: int) -> int:
	if d.size() > i:
		return d.get_data_by_index(i)
	return 0

func _raw_in(world: WorldState, i: int) -> int:
	if world.size() > i:
		return world.get_data_by_index(i)
	return 0

func _loyalty_usa() -> void:
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality < GameConstants.PoliticianPersonality.REFORMIST:
			p.loyalty -= 500
		elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
			p.loyalty += 100
		elif p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL:
			p.loyalty += 300



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_411_usa_discontent.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_411",
	"num": 411,
	"priority": 41100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_411_usa_discontent.gd",
	"trigger_script": "res://数据脚本/事件效果/event_411_usa_discontent.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
