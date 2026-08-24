extends "res://数据脚本/event_script_base.gd"

## 原作 Event434.cs：小罗马（厄立特里亚-意大利，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1544-1546 ——
##   战争26进行中且 fortnight_go>=12，且 resultOfEvents[481] 为 1 或 2（trigger_script 表达）。
## 差异：文本取自 Events_text_en.txt:1636-1643；Gosstroy/SubGosstroy→government/sub_government；
##   puppetOf→puppet_of（原版序号 85=意大利，99=厄立特里亚）；Torg→对华贸易。




const TXT_R0 := "event.script.event_434_little_rome.c0"
const TXT_R1 := "event.script.event_434_little_rome.c1"
const TXT_R2 := "event.script.event_434_little_rome.c2"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if world.wars.size() <= 26 or world.wars[26] == null:
		return false
	var war := world.wars[26]
	if not war.is_going or war.fortnight_elapsed < 12:
		return false
	var r481 := int(world.completed_event_ids.get("event_481", 0))
	return r481 == 1 or r481 == 2


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var eritrea := ws.get_country_by_legacy_index(99)
	var italy := ws.get_country_by_legacy_index(85)
	if eritrea != null:
		eritrea.puppet_of = GameConstants.LegacySlot.SPAIN
		if italy != null and italy.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
			eritrea.government = 22
			eritrea.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
	var war: WarData = null
	if ws.wars.size() > 26:
		war = ws.wars[26]
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, -10)
			_add_relation(EmpireData.USSR, 25)
			if war != null:
				war.infl2 += 75
				war.infl1 -= 75
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -10)
			_add(W.I_ARMY, -25)
			_add_relation(EmpireData.USSR, 50)
			if war != null:
				war.infl2 += 25
				war.infl1 -= 25
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, 5)
			_add_relation(EmpireData.USSR, -25)
			if eritrea != null:
				eritrea.set_tag("对华贸易", true)
			if war != null:
				war.infl2 += 80
				war.infl1 -= 80
			context["result_text"] = tr(TXT_R2)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_434_little_rome.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_434",
	"num": 434,
	"priority": 43400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_434_little_rome.gd",
	"trigger_script": "res://数据脚本/事件效果/event_434_little_rome.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
