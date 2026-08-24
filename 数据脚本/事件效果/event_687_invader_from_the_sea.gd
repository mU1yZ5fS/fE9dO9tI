extends "res://数据脚本/event_script_base.gd"

## 原作 Event687.cs：侵略者自海上来（单选项）。 ## 触发：ReqEventsDLC02.cs:217-219 —— ev543 && r543==1 && modifies[63].active ##   && (data.war_support<450 (data.war_support<600 && data.thought_freedom>=600)) → trigger_script evaluate。 ## 差异：data.war_support→I_WAR_SUPPORT、data.thought_freedom→I_THOUGHT_FREEDOM；{0}{1}→leader.name_display。

const TXT_R0_FMT := "event.script.event_687_invader_from_the_sea.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	var leader := "华国锋"
	if ws.leader != null and ws.leader.name_display != "":
		leader = ws.leader.name_display
	context["result_text"] = tr(TXT_R0_FMT).replace("{0}{1}", leader)
	_add(W.I_PARTY_SUPPORT, 200)
	_add(W.I_PEOPLE_SUPPORT, -200)
	_add(W.I_THOUGHT_FREEDOM, -300)
	_add(W.I_WAR_SUPPORT, 100)


func evaluate(world: WorldState) -> bool:
	if world == null or not world.event_done_num(543):
		return false
	if world.result_of_event_num(543) != 1:
		return false
	if not (world.modifiers.size() > 63 and world.modifiers[63] != null \
			and world.modifiers[63].is_active):
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() <= W.I_WAR_SUPPORT:
		return false
	if d.war_support < 450:
		return true
	return d.war_support < 600 and d.size() > W.I_THOUGHT_FREEDOM \
		and d.thought_freedom >= 600



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_687_invader_from_the_sea.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_687",
	"num": 687,
	"priority": 68700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_687_invader_from_the_sea.gd",
	"trigger_script": "res://数据脚本/事件效果/event_687_invader_from_the_sea.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
