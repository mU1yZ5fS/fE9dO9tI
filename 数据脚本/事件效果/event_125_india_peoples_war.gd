extends "res://数据脚本/event_script_base.gd"

## 原作 Event125.cs：不下地是学不会走路的（3 选项）。
## 触发：由 Decision(GlobalScript.cs:34) 手动触发（印度人民战争），原版无自动条件；
## 故 trigger_conditions 为空，本脚本按原版复刻选项显隐与结果效果。

const TXT_OPT1_DIS := "event.script.event_125_india_peoples_war.c0"
const TXT_OPT2_DIS := "event.script.event_125_india_peoples_war.c1"
const TXT_R0 := "event.script.event_125_india_peoples_war.c2"
const TXT_R1 := "event.script.event_125_india_peoples_war.c3"
const TXT_R2 := "event.script.event_125_india_peoples_war.c4"
const TXT_WAR_NAME := "event.script.event_125_india_peoples_war.c5"
const TXT_WAR_SIDE1_0 := "event.script.event_125_india_peoples_war.c6"
const TXT_WAR_SIDE2_0 := "event.script.event_125_india_peoples_war.c7"
const TXT_WAR_SIDE1_1 := "event.script.event_125_india_peoples_war.c8"
const TXT_WAR_SIDE2_1 := "event.script.event_125_india_peoples_war.c9"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if int(world.completed_event_ids.get("event_466", 0)) == 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if world.army >= 250 and (world.global_influence >= 350 or world.influence_prc >= 350) and china != null and china.has_tag("sev"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))




func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int, active: bool) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active



func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var india := ws.get_country_by_legacy_index(19)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if india != null:
				india.special_ending = 0
				india.set_tag("亲中", false)
				india.set_tag("亲苏", false)
				india.set_tag("亲美", false)
				india.set_tag("对华贸易", false)
			_set_war_7(tr(TXT_WAR_NAME), tr(TXT_WAR_SIDE1_0), tr(TXT_WAR_SIDE2_0), 1, 0)
			context["result_text"] = tr(TXT_R0)
		1:
			if india != null:
				india.special_ending = 1
				india.set_tag("亲中", false)
				india.set_tag("亲苏", false)
				india.set_tag("亲美", false)
				india.set_tag("对华贸易", false)
			_set_war_7(tr(TXT_WAR_NAME), tr(TXT_WAR_SIDE1_1), tr(TXT_WAR_SIDE2_1), 0, 0)
			context["result_text"] = tr(TXT_R1)
		2:
			ws.influence_prc += 30
			_add_power(EmpireData.USSR, 30)
			if india != null:
				india.government = GameConstants.Government.SOCIALIST
				india.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				india.special_ending = 2
				india.set_tag("亲中", false)
				india.set_tag("亲苏", false)
				india.set_tag("亲美", false)
				_join_alliances(india)
			context["result_text"] = tr(TXT_R2)

func _set_war_7(war_name: String, side1: String, side2: String, usa_side: int, ussr_side: int) -> void:
	while ws.wars.size() <= 7:
		ws.wars.append(WarData.new())
	var war := ws.wars[7]
	if war == null:
		ws.wars[7] = WarData.new()
		war = ws.wars[7]
	war.name_war = war_name
	war.is_going = true
	war.side1 = side1
	war.side2 = side2
	war.usa_side = usa_side
	war.ussr_side = ussr_side
	war.infl1 = 400
	war.infl2 = 600




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_125_india_peoples_war.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_125",
	"num": 125,
	"priority": 12500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_125_india_peoples_war.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
