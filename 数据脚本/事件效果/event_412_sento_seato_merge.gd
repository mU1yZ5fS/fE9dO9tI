extends "res://数据脚本/event_script_base.gd"

## 原作 Event412.cs：中央条约组织与东南亚条约组织？（二选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1306 —— ExprNode 组合（日期+标签）。
## 差异：LeaveSENTO().JoinASEAN() 映射 set_tag；ingamewars 无；蒙古 c9 isOVD。

const TXT_TITLE := [
	"中央条约组织与东南亚条约组织？",
]

const TXT_DESC := [
	"中央条约组织是20世纪50年代，由英国、美国与土耳其牵头组建的中东反苏政治军事联盟。尽管伊拉克在50年代末期离开了该组织，且该组织的支柱之一大英帝国已经崩溃。但中央条约组织的影响力依然存在。现在，既然我们已经加入了《马尼拉条约》，将中央条约组织与东南亚条约组织合二为一便是合乎逻辑的一步。并以此加紧遏制苏联在亚洲的扩张。",
]

const TXT_OPT0 := [
	"将中央条约组织与东南亚条约组织合二为一（需要20.0百万预算与25.0点军事实力）",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"军事实力必须高于{0}点......",
]

const TXT_OPT1 := [
	"推迟这一议题",
]

const TXT_R := [
	"今天，各方在德黑兰签署了将东南亚条约组织与中央条约组织合并为一个集体安全组织的协定：该组织设有一个每年举行会议的部长级理事会，以及名为“专员委员会”的常设理事机构——该组织由任期五年的秘书长领导。尽管该组织在某些方面上的功能与北约重复，但它并没有照抄北约的集体安全条款：对该组织成员国的进攻将不会被看作对本组织集体成员的宣战。苏联回应称新的联盟是“对苏联安全的明显挑衅”与“反共产主义军阀联盟”。也就在同一天，蒙古宣布加入华沙条约组织。两大军事集团边界的紧张局势正在升级。然而，苏联的处境只会比以往更加困难。",
	"我们随时可以再议。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1274 := "event.script.event_412_sento_seato_merge.c0"
const TXT_IDX_1275 := "event.script.event_412_sento_seato_merge.c1"
const TXT_IDX_1276 := "event.script.event_412_sento_seato_merge.c2"
const TXT_IDX_592 := "event.script.event_412_sento_seato_merge.c3"
const TXT_IDX_593 := "event.script.event_412_sento_seato_merge.c4"
const TXT_IDX_594 := "event.script.event_412_sento_seato_merge.c5"
const TXT_IDX_566 := "event.script.event_412_sento_seato_merge.c6"
const TXT_IDX_776 := "event.script.event_412_sento_seato_merge.c7"
const TXT_IDX_1277 := "event.script.event_412_sento_seato_merge.c8"
const TXT_IDX_1278 := "event.script.event_412_sento_seato_merge.c9"
const TXT_IDX_1279 := "event.script.event_412_sento_seato_merge.c10"

## 原文字符串附录（供自检）

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if world.completed_event_ids.has("event_412"):
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() <= W.I_YEAR:
		return false
	if not (d.year >= 1980 and d.month >= 5):
		return false
	var c31 := world.get_country_by_legacy_index(31)
	var c8 := world.get_country_by_legacy_index(8)
	var china := world.get_country_by_legacy_index(1)
	if c31 == null or c8 == null or china == null:
		return false
	if c31.has_tag("asean"):
		return false
	if not c31.has_tag("亲美"):
		return false
	if not c8.has_tag("sento"):
		return false
	return china.has_tag("seato")

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		var c51 := ws.get_country_by_legacy_index(51)
		if c51 != null:
			c51.内战中 = true
		_add(W.I_BUDGET, -200)
		_add(W.I_ARMY, -250)
		for c in ws.countries:
			if c != null and c.has_tag("sento"):
				c.set_tag("sento", false)
				c.set_tag("asean", true)
		ws.influence_prc += 50
		_add_power(EmpireData.USA, 50)
		_add_power(EmpireData.USSR, -50)
		_add_relation(EmpireData.USA, 250)
		_add_relation(EmpireData.USSR, -250)
		var c9 := ws.get_country_by_legacy_index(9)
		if c9 != null:
			c9.set_tag("ovd", true)
		context["result_text"] = TXT_R[0]
	else:
		context["result_text"] = TXT_R[1]



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_412_sento_seato_merge.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_412",
	"num": 412,
	"priority": 41200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_412_sento_seato_merge.gd",
	"trigger_script": "res://数据脚本/事件效果/event_412_sento_seato_merge.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
