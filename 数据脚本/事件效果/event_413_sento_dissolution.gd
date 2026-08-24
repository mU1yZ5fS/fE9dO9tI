extends "res://数据脚本/event_script_base.gd"

## 原作 Event413.cs：中央条约组织的解散（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1311 —— ExprNode 组合。
## 差异：描述动态由 prepare 按 isSENTO 选择。

const TXT_TITLE := [
	"中央条约组织的解散",
]

const TXT_DESC := [
	"中央条约组织是20世纪50年代，由英国、美国与土耳其牵头组建的中东反苏政治军事联盟。尽管伊拉克在50年代末期离开了该组织，且该组织的支柱之一大英帝国已经崩溃。但中央条约组织依然继续存在了一段时间。{1}",
	"然而巴基斯坦与伊朗的离开，为该组织钉上了棺材板的钉子。",
	"然而巴基斯坦的离开，为该组织钉上了棺材板的钉子。",
	"然而伊朗的离开，为该组织钉上了棺材板的钉子。",
]

const TXT_OPT0 := [
	"好的......",
]

const TXT_R := [
	"今天，由于中央条约组织的绝大多数成员都已离开了该组织。中央条约组织的常设部长理事会决定自我解散。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1280 := "event.script.event_413_sento_dissolution.c0"
const TXT_IDX_1281 := "event.script.event_413_sento_dissolution.c1"
const TXT_IDX_1282 := "event.script.event_413_sento_dissolution.c2"
const TXT_IDX_1283 := "event.script.event_413_sento_dissolution.c3"
const TXT_IDX_1284 := "event.script.event_413_sento_dissolution.c4"
const TXT_IDX_1285 := "event.script.event_413_sento_dissolution.c5"
const TXT_IDX_1286 := "event.script.event_413_sento_dissolution.c6"

## 原文字符串附录（供自检）

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if world.completed_event_ids.has("event_413"):
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() <= W.I_YEAR:
		return false
	if not ((d.year >= 1979 and d.month >= 4) or d.year >= 1980):
		return false
	var c51 := world.get_country_by_legacy_index(51)
	var c31 := world.get_country_by_legacy_index(31)
	var c8 := world.get_country_by_legacy_index(8)
	if c51 != null and c51.内战中:
		return false
	if c31 != null and c31.has_tag("sento") and c8 != null and c8.has_tag("sento"):
		return false
	return true

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var c31 := world.get_country_by_legacy_index(31)
	var c8 := world.get_country_by_legacy_index(8)
	var num := 0
	if c31 != null and not c31.has_tag("sento") and c8 != null and not c8.has_tag("sento"):
		num = 0
	elif c31 != null and not c31.has_tag("sento"):
		num = 1
	else:
		num = 2
	event_def.description = _fmt(TXT_DESC[0], ["\n", TXT_DESC[num + 1]])

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_add_power(EmpireData.USA, -30)
	_add_power(EmpireData.USSR, 10)
	_add(143, -5)
	var c8 := ws.get_country_by_legacy_index(8)
	var c31 := ws.get_country_by_legacy_index(31)
	if c8 != null:
		c8.set_tag("sento", false)
	if c31 != null:
		c31.set_tag("sento", false)
	context["result_text"] = TXT_R[0]



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_413_sento_dissolution.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_413",
	"num": 413,
	"priority": 41300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_413_sento_dissolution.gd",
	"trigger_script": "res://数据脚本/事件效果/event_413_sento_dissolution.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
