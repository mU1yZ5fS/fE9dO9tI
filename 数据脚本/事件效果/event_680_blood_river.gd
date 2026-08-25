extends "res://数据脚本/event_script_base.gd"

## 原作 Event680.cs：血河奔流（喀麦隆反对派支援，手动事件，三选项）。
## 触发：DiploButtonScript.cs:1032 入口（selected_country==66）——科技《情报部门新装备》、
##   社会主义或改良主义、影响力>=300、未支持过（或上次选了“再想想”）。
## 入口扣费（data.agents-100 特工、data.army-100 军力）在 外交互动_批4.gd:715-717 完成。
## 差异：原版 option1 禁用分支误写 button[0]/button_text[0]（Unity bug），按语义禁用 option1；
##   result2 的 event_done[680]=false → context["skip_mark_done"]=true。

const TXT_OPT0_DIS := "event.script.event_680_blood_river.c0"
const TXT_OPT1_DIS := "event.script.event_680_blood_river.c1"
const TXT_R0 := "event.script.event_680_blood_river.c2"
const TXT_R1 := "event.script.event_680_blood_river.c3"
const TXT_R2 := "event.script.event_680_blood_river.c4"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var china := ws.get_country_by_legacy_index(1)
	var mod6 := ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	var opt := event_def.options
	if _res(W.I_POLITICAL_LINE) <= 1 and mod6 and ws.is_socialism(china, true) \
			and ws.influence_prc >= 500:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if _res(W.I_POLITICAL_LINE) <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			var cameroon := ws.get_country_by_legacy_index(66)
			if cameroon != null:
				cameroon.level_of_instability = 10
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_BUDGET, -75)
			_add(W.I_AGENTS, -75)
			_add(W.I_ARMY, -75)
		2:
			context["result_text"] = tr(TXT_R2)
			# 原版 event_done[680]=false：允许外交按钮再次触发。
			context["skip_mark_done"] = true



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_680_blood_river.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_680",
	"num": 680,
	"priority": 68000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_680_blood_river.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
