extends "res://数据脚本/event_script_base.gd"

## 原作 Event386.cs：为了乍得人的乍得（一选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。

const TXT_R0 := "event.script.event_386_chad.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_add(143, 1)  # 原版 data.oil_price
	var chad := ws.get_country_by_legacy_index(57)
	var war80 := ws.wars[80] if ws.wars.size() > 80 else null
	if war80 != null:
		war80.is_going = false
	if chad != null:
		if chad.parts.size() < 1:
			chad.parts.resize(1)
		chad.parts[0] = false
		chad.government = GameConstants.Government.SOCIALIST
		chad.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
		_leave_alliances(chad)
		chad.set_tag("对华贸易", true)
		chad.set_tag("亲中", true)
		_join_alliances(chad)
	context["result_text"] = tr(TXT_R0)



func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_386_chad.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_386",
	"num": 386,
	"priority": 38600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_386_chad.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
