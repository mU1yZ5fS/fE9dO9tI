extends "res://数据脚本/event_script_base.gd"

## 原作 Event557.cs：和平长入社会主义：第二幕（意大利贝林格，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1174-1176 —— 复杂条件见 evaluate()。
## 差异：data.get_data_by_index(175-182) raw index；inflCh→influence_china；isSEV→has_tag。

const TXT_OPT0_DIS_TAO := "event.script.event_557_peaceful_transition_socialism_2.c0"
const TXT_OPT0_DIS_CN := "event.script.event_557_peaceful_transition_socialism_2.c1"
const TXT_OPT0_DIS_FAR := "event.script.event_557_peaceful_transition_socialism_2.c2"
const TXT_OPT1_DIS_REV := "event.script.event_557_peaceful_transition_socialism_2.c3"
const TXT_OPT1_DIS_NO := "event.script.event_557_peaceful_transition_socialism_2.c4"
const TXT_OPT2_DIS_REV := "event.script.event_557_peaceful_transition_socialism_2.c5"
const TXT_OPT2_DIS_GUA := "event.script.event_557_peaceful_transition_socialism_2.c6"
const TXT_OPT2_DIS_GHOST := "event.script.event_557_peaceful_transition_socialism_2.c7"
const TXT_R0_COUP := "event.script.event_557_peaceful_transition_socialism_2.c8"
const TXT_R0_OK := "event.script.event_557_peaceful_transition_socialism_2.c9"
const TXT_R1 := "event.script.event_557_peaceful_transition_socialism_2.c10"
const TXT_R1_COUP := "event.script.event_557_peaceful_transition_socialism_2.c11"
const TXT_R1_OK := "event.script.event_557_peaceful_transition_socialism_2.c12"
const TXT_R2 := "event.script.event_557_peaceful_transition_socialism_2.c13"
const TXT_R3 := "event.script.event_557_peaceful_transition_socialism_2.c14"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var dd := world
	if dd.size() <= 177:
		return false
	var c85 := world.get_country_by_legacy_index(85)
	if c85 == null:
		return false
	var r393 := int(world.completed_event_ids.get("event_393", 0))
	if not (r393 > 0 or world.completed_event_ids.has("event_392")):
		return false
	if c85.influence_china <= 0:
		return false
	if c85.sub_government == GameConstants.SubGovernment.LEFT_CONSERVATIVE:
		return false
	var r293 := int(world.completed_event_ids.get("event_293", 0))
	if r293 < 0 or r293 > 2:
		return false
	if not (dd.italy_power_176 > dd.italy_power_175 and dd.italy_power_176 > dd.italy_power_177):
		return false
	if world.completed_event_ids.has("event_556") or world.completed_event_ids.has("event_396") or world.completed_event_ids.has("event_401"):
		return false
	if c85.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN:
		return false
	var y := dd.year
	var mo := dd.month
	var day := dd.day
	if (y >= 1982 and mo >= 1 and day > 19) or (y >= 1982 and mo >= 1) or y >= 1983:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var c1 := world.get_country_by_legacy_index(1)
	var c15 := world.get_country_by_legacy_index(15)
	var c45 := world.get_country_by_legacy_index(45)
	var c51 := world.get_country_by_legacy_index(51)
	var line := d.political_line
	if line != 0 and line != 4 and not ws.modifiers[3].is_active and c45 != null and c45.government == GameConstants.Government.REFORMIST 			and c45 != null and not c45.内战中 and c15 != null and c15.government == GameConstants.Government.REFORMIST 			and ws.influence_prc >= 400 and not is_auth(c1) and not ws.is_socialism(c1, true) 			and (c15 != null and (c15.内战中 or c1 != null and c1.has_tag("econ"))) and c15 != null and c15.sub_government == GameConstants.SubGovernment.TITOIST:
		_enable(opt[0], event_def.options[0].text)
	elif line == 0 or line == 4 or ws.modifiers[3].is_active:
		_disable(opt[0], tr(TXT_OPT0_DIS_TAO))
	elif is_auth(c1) or ws.is_socialism(c1, true):
		_disable(opt[0], tr(TXT_OPT0_DIS_CN))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS_FAR))
	var r293 := int(ws.completed_event_ids.get("event_293", 0))
	if line < 3 and not ws.modifiers[3].is_active and c1 != null and c1.has_tag("sev") 			and ws.get_flag("relres") and r293 == 2:
		_enable(opt[1], event_def.options[1].text)
	elif line >= 3 or ws.modifiers[3].is_active or not ws.get_flag("relres"):
		_disable(opt[1], tr(TXT_OPT1_DIS_REV))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_NO))
	if line > 2 and c1 != null and c1.sub_government == GameConstants.SubGovernment.SOCIAL_DEMOCRAT and d.italy_power_181 >= d.italy_power_178 and d.italy_power_181 >= d.italy_power_179 			and d.italy_power_181 >= d.italy_power_180 and c51 != null and c51.has_tag("对华贸易") and ws.modifiers[43].is_active:
		_enable(opt[2], event_def.options[2].text)
	elif line <= 2 or (c1 != null and c1.sub_government != GameConstants.SubGovernment.SOCIAL_DEMOCRAT):
		_disable(opt[2], tr(TXT_OPT2_DIS_REV))
	elif (c51 == null or not c51.has_tag("对华贸易")) or not ws.modifiers[43].is_active:
		_disable(opt[2], tr(TXT_OPT2_DIS_GUA))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS_GHOST))


func is_auth(c: CountryData) -> bool:
	return c != null and c.government == GameConstants.Government.AUTHORITARIAN and c.sub_government != GameConstants.SubGovernment.LEFT_RADICAL


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c85 := ws.get_country_by_legacy_index(85)
	var c45 := ws.get_country_by_legacy_index(45)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var usa := ws.empires[EmpireData.USA]
			var ussr := ws.empires[EmpireData.USSR]
			if usa.power > ussr.power + ws.influence_prc and usa.current_leader == 0:
				_add(W.I_BUDGET, -60)
				_add_relation(EmpireData.USA, -250)
				_add_power(EmpireData.USA, 10)
				ws.influence_prc -= 5
				_set_data(182, 0)
				if c85 != null:
					c85.government = GameConstants.Government.AUTHORITARIAN
					c85.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					c85.set_tag("亲美", true)
					c85.set_tag("对华贸易", false)
					c85.influence_china = 0
				context["result_text"] = tr(TXT_R0_COUP)
			else:
				if c85 != null:
					_leave_alliances(c85)
					c85.set_tag("soc_eu", true)
					c85.set_tag("对华贸易", true)
				if c45 != null:
					_leave_alliances(c45)
					c45.set_tag("soc_eu", true)
					c45.set_tag("对华贸易", true)
				_add_relation(EmpireData.USSR, -200)
				_add_relation(EmpireData.USA, -200)
				_add(W.I_BUDGET, -60)
				ws.influence_prc += 5
				_add_power(EmpireData.USA, -30)
				d.italy_power_179 += 1
				d.italy_power_180 += 1
				d.short_sword_power += 7
				context["result_text"] = tr(TXT_R0_OK)
		1:
			if c85 != null:
				_leave_alliances(c85)
			var usa := ws.empires[EmpireData.USA]
			var ussr := ws.empires[EmpireData.USSR]
			if usa.power > ussr.power + ws.influence_prc and usa.current_leader == 0:
				_add(W.I_BUDGET, -60)
				_add_relation(EmpireData.USA, -250)
				_add_power(EmpireData.USA, 10)
				ws.influence_prc -= 5
				_set_data(182, 0)
				if c85 != null:
					c85.government = GameConstants.Government.AUTHORITARIAN
					c85.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					c85.set_tag("亲美", true)
					c85.influence_china = 0
				context["result_text"] = tr(TXT_R1_COUP)
			else:
				if c85 != null:
					c85.set_tag("对华贸易", true)
					c85.set_tag("sev", true)
				_add_relation(EmpireData.USSR, 200)
				_add_relation(EmpireData.USA, -200)
				_add(W.I_BUDGET, -50)
				_add(W.I_AGENTS, -50)
				ws.influence_prc += 5
				d.italy_power_180 -= 1
				d.italy_power_178 += 1
				d.short_sword_power += 7
				_add_power(EmpireData.USSR, 20)
				_add_power(EmpireData.USA, -30)
				if ussr.power >= usa.power and c85 != null:
					c85.set_tag("亲苏", true)
				context["result_text"] = tr(TXT_R1) + tr(TXT_R1_OK)
		2:
			_add_relation(EmpireData.USSR, -150)
			_add_relation(EmpireData.USA, 50)
			if c85 != null:
				c85.government = GameConstants.Government.LIBERAL
				c85.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_557_peaceful_transition_socialism_2.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_557",
	"num": 557,
	"priority": 55700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_557_peaceful_transition_socialism_2.gd",
	"trigger_script": "res://数据脚本/事件效果/event_557_peaceful_transition_socialism_2.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
