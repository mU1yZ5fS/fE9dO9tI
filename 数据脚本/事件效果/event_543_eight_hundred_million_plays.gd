extends "res://数据脚本/event_script_base.gd"

## 原作 Event543.cs：八亿人民几部戏？（文艺路线，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:212-214 ——
##   event_done[668] && resultOfEvents[668]<=1 && 年>=1983。
## 差异：描述/选项按 resultOfEvents[668] 与 modifies[3] 动态改写；
##   old_modify_desc[3] → ModifierCatalog.get_def(3)；modifies[63] 激活。

const TXT_DESC_0 := "event.script.eight_hundred_million_plays.txt_desc_0"
const TXT_DESC_1 := "event.script.eight_hundred_million_plays.txt_desc_1"
const TXT_OPT0_A := "event.script.event_543_eight_hundred_million_plays.c0"
const TXT_OPT0_B := "event.script.event_543_eight_hundred_million_plays.c1"
const TXT_OPT1_A := "event.script.event_543_eight_hundred_million_plays.c2"
const TXT_OPT1 := "event.script.event_543_eight_hundred_million_plays.c3"
const TXT_R0 := "event.script.event_543_eight_hundred_million_plays.c4"
const TXT_R1 := "event.script.event_543_eight_hundred_million_plays.c5"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var r668 := int(ws.completed_event_ids.get("event_668", 0))
	var opt := event_def.options
	if r668 == 0 and ws.modifiers[3].is_active:
		event_def.description = tr(TXT_DESC_0)
		if opt.size() >= 2:
			_enable(opt[0], tr(TXT_OPT0_A))
			_disable(opt[1], tr(TXT_OPT1_A))
	else:
		event_def.description = tr(TXT_DESC_1)
		if opt.size() >= 2:
			_disable(opt[0], tr(TXT_OPT0_B))
			_enable(opt[1], tr(TXT_OPT1))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -300)
			_add(W.I_PEOPLE_SUPPORT, 200)
			_add(W.I_THOUGHT_FREEDOM, 300)
			_add(W.I_BUDGET, -20)
			if d.press_policy < 18:
				_add(W.I_PRESS_POLICY, 1)
			_set_mod3("收入+0.6，特工网络+0.2，军队力量+0.5\n如果毛主席已逝世：人民支持度+0.5，思想自由化+1，生活水平-0.5，与美国关系-0.5\n全新的高潮：党内团结度+1，人民支持度+1，思想自由化+1，极左力量+2")
			context["result_text"] = _fmt(tr(TXT_R0))
		1:
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, 300)
			_add(W.I_BUDGET, -50)
			ws.modifiers[63].is_active = true
			context["result_text"] = _fmt(tr(TXT_R1))


func _fmt(s: String) -> String:
	var n := _leader_name()
	# CSV 迁移后模板为 {0}{1}；兼容旧的 01 字面占位
	return s.replace("{0}{1}", n).replace("01", n)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _set_mod3(effect: String) -> void:
	var def := ModifierCatalog.get_def(3)
	if def != null:
		def.effect_zh = effect



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_543_eight_hundred_million_plays.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_543",
	"num": 543,
	"priority": 54300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_543_eight_hundred_million_plays.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_668"}, {"t": "ANY", "c": [{"t": "PREV_EVENT_RESULT_IS", "ref": "event_668"}, {"t": "PREV_EVENT_RESULT_IS", "v": 1, "ref": "event_668"}]}, {"t": "DATE_AFTER", "key": "1983.1.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
