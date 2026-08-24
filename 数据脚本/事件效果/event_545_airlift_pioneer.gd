extends "res://数据脚本/event_script_base.gd"

## 原作 Event545.cs：空运先锋（运输机发展，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:227-229 ——
##   science[24] && 工业>=1050 && science[16] && 年>=1983。
## 差异：old_modify_desc[50] → ModifierCatalog.get_def(50)。

const TXT_R0 := "event.script.event_545_airlift_pioneer.c0"
const TXT_R1 := "event.script.event_545_airlift_pioneer.c1"
const TXT_R2 := "event.script.event_545_airlift_pioneer.c2"
const TXT_R3 := "event.script.event_545_airlift_pioneer.c3"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_DIPLO, -50)
			_add(W.I_BUDGET, -100)
			_set_mod50("军用运输机：", "军力+1.0，支援战争消耗的干涉点数-0.2")
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, 150)
			_add(W.I_DIPLO, 30)
			_add(W.I_BUDGET, -150)
			_set_mod50("民用运输机：", "生活水平+1.0，人民支持度+1.0，思想自由化-0.5")
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_PARTY_SUPPORT, 250)
			_add(W.I_PEOPLE_SUPPORT, 250)
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -250)
			_set_mod50("军用与民用运输机：", "军力+2.0，生活水平+1.5，人民支持度+2.0，思想自由化-1.0，支援战争消耗的干涉点数-0.5")
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)


func _set_mod50(title: String, effect: String) -> void:
	var def := ModifierCatalog.get_def(50)
	if def != null:
		def.name_zh = title
		def.effect_zh = effect



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_545_airlift_pioneer.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_545",
	"num": 545,
	"priority": 54500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_545_airlift_pioneer.gd",
	"trigger": [{"t": "TECH_UNLOCKED", "v": 24}, {"t": "RESOURCE_AT_LEAST", "key": "industry", "v": 1050}, {"t": "TECH_UNLOCKED", "v": 16}, {"t": "DATE_AFTER", "key": "1983.1.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
