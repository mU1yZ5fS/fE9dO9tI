extends "res://数据脚本/event_script_base.gd"

## 原作 Event562.cs：橄榄之国，永远屹立（突尼斯面包骚乱，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:352-354 ——
##   event_done[459] && resultOfEvents[459]>=3 && event_done[561] && resultOfEvents[561]>=2
##   && (1983.12.29 或 1984+)。

const TXT_OPT0_DIS := "event.script.event_562_land_of_olives.c0"
const TXT_OPT1_DIS := "event.script.event_562_land_of_olives.c1"
const TXT_R0_A := "event.script.event_562_land_of_olives.c2"
const TXT_R0_B := "event.script.event_562_land_of_olives.c3"
const TXT_R1 := "event.script.event_562_land_of_olives.c4"
const TXT_R2 := "event.script.event_562_land_of_olives.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var c40 := world.get_country_by_legacy_index(40)
	var c13 := world.get_country_by_legacy_index(13)
	var line := d.political_line
	if line < 2 and c40 != null and not c40.has_tag("亲美") and c13 != null and not c13.has_tag("亲美"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 2 and c40 != null and c40.has_tag("对华贸易"):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c55 := ws.get_country_by_legacy_index(55)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if ws.modifiers[6].is_active:
				if c55 != null:
					c55.government = GameConstants.Government.SOCIALIST
					c55.sub_government = GameConstants.SubGovernment.MAOIST
					_leave_alliances(c55)
					c55.set_tag("亲中", true)
					c55.set_tag("对华贸易", true)
				context["result_text"] = tr(TXT_R0_A)
			else:
				if c55 != null:
					c55.government = GameConstants.Government.SOCIALIST
					c55.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					_leave_alliances(c55)
					c55.set_tag("亲中", true)
					c55.set_tag("对华贸易", true)
				context["result_text"] = tr(TXT_R0_B)
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -20)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			_add(W.I_DIPLO, 50)
		1:
			_add(W.I_BUDGET, -100)
			if c55 != null:
				c55.government = GameConstants.Government.LIBERAL
				c55.sub_government = GameConstants.SubGovernment.MODERATE
				_leave_alliances(c55)
				c55.set_tag("亲中", true)
				c55.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, -20)
			_add(W.I_AGENTS, -100)
			_add(W.I_DIPLO, -100)
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_562_land_of_olives.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_562",
	"num": 562,
	"priority": 56200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_562_land_of_olives.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_459"}, {"t": "PREV_EVENT_RESULT_IS", "v": 3, "ref": "event_459"}, {"t": "PREV_EVENT_DONE", "ref": "event_561"}, {"t": "ANY", "c": [{"t": "PREV_EVENT_RESULT_IS", "v": 2, "ref": "event_561"}, {"t": "PREV_EVENT_RESULT_IS", "v": 3, "ref": "event_561"}]}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1983.12.29"}, {"t": "DATE_AFTER", "key": "1984.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
