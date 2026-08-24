extends "res://数据脚本/event_script_base.gd"

## 原作 Event445.cs：老挝的命运（2选项）。
## 触发：无自动触发点（trigger_conditions=[]）。DiploButtonScript.cs:9260-9264 this_type==35 手动 number_event=445。
## 差异：stab→stab（CountryData.stab）；isSEV→sev、prosov→亲苏、proprc→亲中；prcpower→prc_power。




const TXT_R0 := "event.script.event_445_laos_fate.c0"
const TXT_R1 := "event.script.event_445_laos_fate.c1"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var china := ws.get_country_by_legacy_index(1)
	var laos := ws.get_country_by_legacy_index(22)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			ws.influence_prc += 10
			_add(W.I_AGENTS, -30)
			if laos != null:
				laos.stab = 1
				laos.puppet_of = GameConstants.LegacySlot.NONE
				laos.set_tag("sev", false)
				laos.set_tag("亲苏", false)
				laos.set_tag("亲中", true)
				if china != null:
					laos.government = china.government
					laos.sub_government = china.sub_government
				laos.prc_power = 1000
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)




func _disable_blank(opt: EventOption) -> void:
	opt.disabled_text = ""
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n








func _modifier_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active


func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_445_laos_fate.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_445",
	"num": 445,
	"priority": 44500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_445_laos_fate.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
