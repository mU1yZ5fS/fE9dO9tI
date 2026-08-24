extends "res://数据脚本/event_script_base.gd"

## 原作 Event403.cs：军委独裁政权的危机（五选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1261 —— 复杂条件用 evaluate（parts 无 ExprNode 字段）。
## 差异：ingamewars[24..26]→ws.wars；SovietSupportAttacker.AmericanSupportDefender→usa_side = GameConstants.WarSide.SIDE2,ussr_side = GameConstants.WarSide.SIDE1；TickTime→fortnight_max。

const TXT_TITLE := [
	"军委独裁政权的危机",
]

const TXT_DESC := [
	"当君主制于1974年被推翻后，埃塞俄比亚的政局便落入了临时军政委员会（也被称为军委【Derg】）之手。很快，该国权力便集中于门格斯图·海尔·马里亚姆一人之手。而他对自己的政敌毫不留情。新政权立刻开始以苏联为模板实行一边倒政策。然而，这些政策并不能实现该国的迅速现代化——农业集体化引发了灾难性的饥荒，数以万计的人沦为牺牲品。肆虐的饥荒让这个刚过完十周年纪念日的政权更是显得荒诞。因此，军委成了靠苏联与社会主义阵营这片天吃饭的诡异存在。自欧加登战争后，埃塞俄比亚就变成了苏联在东非与红海的扩张的马前卒。然而，最令人印象深刻的还要数这个自诩以马克思主义立国的政府，竟撞上了一群社会主义反对派：如国内政党埃塞俄比亚人民共和党，以及依托民族分离地区而诞生的大量左翼民族主义政党（在厄立特里亚和提格雷境内，相关组织活动最为活跃）右翼的势力也相当显著，其领头羊当属埃塞俄比亚民主联盟。然而，埃塞俄比亚的反对派内也极度分裂，并相互交火（尤其是区域反对派）。而政府至少在目前还能“妥善处置”这些“叛匪”。但现在，随着军委政权逐渐露出其独裁本质，反对派之间也许能就此达成共识。",
]

const TXT_OPT0 := [
	"推动反对派实现大联合并支持埃塞俄比亚反对派（需要15.0百万预算与35.0点军事实力）",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"中国的国际影响力应高于{0}......",
	"军事实力必须高于{0}点......",
]

const TXT_OPT1 := [
	"支持分离主义势力（需要15.0百万预算与25.0点军事实力）",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"中国的国际影响力应高于{0}......",
	"军事实力必须高于{0}点......",
]

const TXT_OPT2 := [
	"援助门格斯图政权，但要求他驱逐苏联基地（需要25.0百万预算）",
	"可不能在前脚与苏联和好后，后脚就捅刀子......",
	"谢尔比茨基不会允许我们如此肆意妄为！",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"中国的国际影响力应高于{0}......",
	"军事实力必须高于{0}点......",
]

const TXT_OPT3 := [
	"为难民送去人道主义援助",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
]

const TXT_OPT4 := [
	"不闻不问",
]

const TXT_R := [
	"在我们的支持下，绝大多数的反叛组织决定搁置争议，建立反军委政权的统一战线。他们团结在囊括了民族分离主义势力的埃塞俄比亚人民革命民主阵线下，迅速对政府军发起了攻势。",
	"门格斯图政权完全靠苏联援助吃饭。如果军委唯一的出海口——厄立特里亚决定造反，那苏联就会被赶出东非。出于这一目的，我们决定支持厄立特里亚人民解放阵线与提格雷人民解放阵线。而他们已经做好了战斗准备。",
	"我们决定遵循阿卡姆剃刀原则，并同门格斯图政权达成共识：后者拿马萨瓦的苏联海军基地同我方的军事与经济援助做了交换。在苏联逐步撤资的背景下，门格斯图自愿同我们达成协定，并将所有的苏军赶出了红海。",
	"我们已经为埃塞俄比亚政府送去了人道主义援助，旨在帮助该国对抗饥荒。然而，这将成为一件高尚之举，还是成为对抗现政府反对者的武器？不论如何，至少两大国都赞许我们的和平主义姿态。",
	"为了取得更多的苏联援助，门格斯图别无选择。只能按照苏联的要求，组建以“苏联模式为样板”，打造埃塞俄比亚的马列主义政党——即埃塞俄比亚劳动人民党。但是，该政权的反对派仍在该国边疆区发展壮大。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1158 := "event.script.event_403_derg_crisis.c0"
const TXT_IDX_1159 := "event.script.event_403_derg_crisis.c1"
const TXT_IDX_1160 := "event.script.event_403_derg_crisis.c2"
const TXT_IDX_592 := "event.script.event_403_derg_crisis.c3"
const TXT_IDX_593 := "event.script.event_403_derg_crisis.c4"
const TXT_IDX_594 := "event.script.event_403_derg_crisis.c5"
const TXT_IDX_566 := "event.script.event_403_derg_crisis.c6"
const TXT_IDX_620 := "event.script.event_403_derg_crisis.c7"
const TXT_IDX_776 := "event.script.event_403_derg_crisis.c8"
const TXT_IDX_1161 := "event.script.event_403_derg_crisis.c9"
const TXT_IDX_1162 := "event.script.event_403_derg_crisis.c10"
const TXT_IDX_1164 := "event.script.event_403_derg_crisis.c11"
const TXT_IDX_1165 := "event.script.event_403_derg_crisis.c12"
const TXT_IDX_1185 := "event.script.event_403_derg_crisis.c13"
const TXT_IDX_1163 := "event.script.event_403_derg_crisis.c14"
const TXT_IDX_1166 := "event.script.event_403_derg_crisis.c15"
const TXT_IDX_1170 := "event.script.event_403_derg_crisis.c16"
const TXT_IDX_1171 := "event.script.event_403_derg_crisis.c17"
const TXT_IDX_1172 := "event.script.event_403_derg_crisis.c18"
const TXT_IDX_1167 := "event.script.event_403_derg_crisis.c19"
const TXT_IDX_1176 := "event.script.event_403_derg_crisis.c20"
const TXT_IDX_1174 := "event.script.event_403_derg_crisis.c21"
const TXT_IDX_1177 := "event.script.event_403_derg_crisis.c22"
const TXT_IDX_1175 := "event.script.event_403_derg_crisis.c23"
const TXT_IDX_1168 := "event.script.event_403_derg_crisis.c24"
const TXT_IDX_1186 := "event.script.event_403_derg_crisis.c25"
const TXT_IDX_1169 := "event.script.event_403_derg_crisis.c26"

## 原文字符串附录（供自检）

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() <= W.I_YEAR:
		return false
	if world.completed_event_ids.has("event_403"):
		return false
	if not ((d.year == 1984 and d.month >= 3) or d.year >= 1985):
		return false
	var china := world.get_country_by_legacy_index(1)
	if china != null and china.has_tag("sev"):
		return false
	var ethiopia := world.get_country_by_legacy_index(41)
	if ethiopia == null:
		return false
	if ethiopia.sub_government != GameConstants.SubGovernment.LEFT_NATIONALIST:
		return false
	if not ethiopia.has_tag("亲苏"):
		return false
	if ethiopia.has_part(0) or ethiopia.has_part(1):
		return false
	return true

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var opt := event_def.options
	var budget_reserve := d.budget + (d.reserve if d.size() > W.I_RESERVE else 0)
	var army := d.army if d.size() > W.I_ARMY else 0
	var us := world.get_country_by_legacy_index(51)
	var us_dev := us.development if us != null else 0
	if budget_reserve >= 150 and army >= 150 and (world.influence_prc >= 600 or us_dev > 0):
		_enable(opt[0], TXT_OPT0[0])
	elif budget_reserve < 150:
		_disable(opt[0], _fmt(TXT_OPT0[1], [15]))
	elif world.influence_prc < 600 and us_dev <= 0:
		_disable(opt[0], _fmt(TXT_OPT0[2], [60]))
	else:
		_disable(opt[0], _fmt(TXT_OPT0[3], [35]))
	if budget_reserve >= 150 and army >= 150 and (world.influence_prc >= 200 or us_dev > 0):
		_enable(opt[1], TXT_OPT1[0])
	elif budget_reserve < 150:
		_disable(opt[1], _fmt(TXT_OPT1[1], [15]))
	elif world.influence_prc < 300 and us_dev <= 0:
		_disable(opt[1], _fmt(TXT_OPT1[2], [30]))
	else:
		_disable(opt[1], _fmt(TXT_OPT1[3], [25]))
	var ussr_leader := world.empires.size() > 1 and world.empires[1] != null and world.empires[1].current_leader != 3
	if budget_reserve >= 250 and not world.get_flag("relres") and ussr_leader and world.influence_prc >= 500 and army >= 100:
		_enable(opt[2], TXT_OPT2[0])
	elif world.get_flag("relres"):
		_disable(opt[2], TXT_OPT2[1])
	elif world.empires.size() > 1 and world.empires[1] != null and world.empires[1].current_leader == 3:
		_disable(opt[2], TXT_OPT2[2])
	elif budget_reserve < 250:
		_disable(opt[2], _fmt(TXT_OPT2[3], [25]))
	elif world.influence_prc <= 500:
		_disable(opt[2], _fmt(TXT_OPT2[4], [50]))
	else:
		_disable(opt[2], _fmt(TXT_OPT2[5], [10]))
	if budget_reserve >= 100:
		_enable(opt[3], TXT_OPT3[0])
	else:
		_disable(opt[3], _fmt(TXT_OPT3[1], [10]))
	_enable(opt[4], TXT_OPT4[0])

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var ethiopia := ws.get_country_by_legacy_index(41)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		var num := 0
		var somalia := ws.get_country_by_legacy_index(42)
		if somalia != null and somalia.has_part(0):
			num += 150
		_add(W.I_BUDGET, -150)
		_add(W.I_ARMY, -350)
		_add_relation(EmpireData.USSR, -300)
		_start_war(24, "埃塞俄比亚内战", "军委", "埃革阵", 300 + num, 700 - num, 20)
		context["result_text"] = TXT_R[0]
	elif opt == 1:
		_add(W.I_BUDGET, -150)
		_add(W.I_ARMY, -250)
		_add_relation(EmpireData.USSR, -300)
		for cid in [99, 100]:
			var c := ws.get_country_by_legacy_index(cid)
			if c != null:
				c.set_part(0, true)
		_start_war(25, "提格雷独立战争", "军委", "提革阵", 600, 400, 20)
		_start_war(26, "厄立特里亚独立战争", "军委", "厄革阵", 600, 400, 20)
		context["result_text"] = TXT_R[1]
	elif opt == 2:
		_add(W.I_BUDGET, -250)
		_add_power(EmpireData.USSR, -25)
		_add_relation(EmpireData.USSR, -500)
		_add_relation(EmpireData.USA, -200)
		ws.influence_prc += 10
		if ethiopia != null:
			ethiopia.set_tag("亲苏", false)
			ethiopia.set_tag("亲中", true)
			ethiopia.set_tag("对华贸易", true)
		context["result_text"] = TXT_R[2]
	elif opt == 3:
		_add(W.I_BUDGET, -100)
		_add_relation(EmpireData.USA, 250)
		_add_relation(EmpireData.USSR, 250)
		_add(W.I_PARTY_SUPPORT, -100)
		_add(W.I_DIPLO, -30)
		context["result_text"] = TXT_R[3]
	else:
		context["result_text"] = TXT_R[4]

func _raw(i: int) -> int:
	if d.size() > i:
		return d.get_data_by_index(i)
	return 0

func _start_war(war_id: int, war_name: String, side1: String, side2: String, infl1: int, infl2: int, fortnight: int) -> void:
	game.start_war(war_id, side1, side2, infl1, infl2, 1, 0)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_403_derg_crisis.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_403",
	"num": 403,
	"priority": 40300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_403_derg_crisis.gd",
	"trigger_script": "res://数据脚本/事件效果/event_403_derg_crisis.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
