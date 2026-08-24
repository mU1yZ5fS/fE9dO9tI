extends "res://数据脚本/event_script_base.gd"

## 原作 Event544.cs：和平利剑（核战略，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:222-224 ——
##   science[21] && science[29] && 工业>=1100 && 年>=1984。
## 差异：old_modify_desc[50] → ModifierCatalog.get_def(50)。

const TXT_R0 := "event.script.event_544_sword_of_peace.c0"
const TXT_R1 := "event.script.event_544_sword_of_peace.c1"
const TXT_R2 := "event.script.event_544_sword_of_peace.c2"
const TXT_R3 := "event.script.event_544_sword_of_peace.c3"


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
			_set_mod50("核防御措施：", "军力+0.7，外交声誉-0.5")
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, 150)
			_add(W.I_DIPLO, 30)
			_add(W.I_BUDGET, -150)
			_set_mod50("核威慑措施：", "军力+2.0，美苏关系-0.2")
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_PARTY_SUPPORT, 250)
			_add(W.I_PEOPLE_SUPPORT, 250)
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -250)
			_set_mod50("核防御与核威慑措施：", "军力+4.0，美苏关系-0.4，可禁运美苏")
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)


func _set_mod50(title: String, effect: String) -> void:
	var def := ModifierCatalog.get_def(50)
	if def != null:
		def.name_zh = title
		def.effect_zh = effect



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_544_sword_of_peace.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_544",
	"num": 544,
	"priority": 54400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_544_sword_of_peace.gd",
	"trigger": [{"t": "TECH_UNLOCKED", "v": 21}, {"t": "TECH_UNLOCKED", "v": 29}, {"t": "RESOURCE_AT_LEAST", "key": "industry", "v": 1100}, {"t": "DATE_AFTER", "key": "1984.1.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
