extends "res://数据脚本/event_script_base.gd"

## 原作 Event593.cs：打倒暴君才有自由和平（多哥革命，单选项）。
## 触发：DiploButtonScript.cs:11720 —— number_event = 593（外交按钮手动触发），无自动触发。
## 差异：
##  - event_done[500] → ws.completed_event_ids.has("event_500")；
##  - name → chinese_name；EstablishGovernment(ProChina) → 亲中 true、亲苏/亲美 false；
##  - Torg → 对华贸易；soc_stab → social_stability；
##  - JoinAllOurAlliances(true) → 基类 _join_alliances。




const TXT_R0_A := "event.script.event_593_down_with_tyrant.c0"
const TXT_R0_DONE := "event.script.event_593_down_with_tyrant.c1"
const TXT_R0_NOT := "event.script.event_593_down_with_tyrant.c2"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c108 := ws.get_country_by_legacy_index(108)
	var text := tr(TXT_R0_A)
	if ws.completed_event_ids.has("event_500"):
		text += tr(TXT_R0_DONE)
	else:
		text += tr(TXT_R0_NOT)
	_add(W.I_BUDGET, -80)
	_add(W.I_AGENTS, -80)
	if c108 != null:
		c108.government = GameConstants.Government.SOCIALIST
		c108.sub_government = GameConstants.SubGovernment.MAOIST
		c108.chinese_name = "多哥人民共和国"
		_leave_alliances(c108)
		_establish_prochina(c108)
		c108.set_tag("对华贸易", true)
		c108.social_stability = 1000
		_join_alliances(c108)
	context["result_text"] = text


func _establish_prochina(c: CountryData) -> void:
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_593_down_with_tyrant.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_593",
	"num": 593,
	"priority": 59300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_593_down_with_tyrant.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
