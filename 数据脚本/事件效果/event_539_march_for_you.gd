extends "res://数据脚本/event_script_base.gd"

## 原作 Event539.cs：献给你的进行曲（韩国光州后续，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:312-314 —— 复杂条件见 evaluate()。
## 差异：south_korea_gwangju_rebellion→ws.get_flag("south_korea_gwangju_rebellion")；ingamewars[0]→ws.wars[0]；
##   parts[0]→CountryData.parts[0]；IsSocialism 谓词对应关系见 evaluate。

const TXT_OPT0_DIS := "event.script.event_539_march_for_you.c0"
const TXT_R0 := "event.script.event_539_march_for_you.c1"
const TXT_R1 := "event.script.event_539_march_for_you.c2"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if world.wars.size() <= 0 or world.wars[0] == null or world.wars[0].is_going:
		return false
	var c46 := world.get_country_by_legacy_index(46)
	var c10 := world.get_country_by_legacy_index(10)
	var c44 := world.get_country_by_legacy_index(44)
	var c38 := world.get_country_by_legacy_index(38)
	if c46 == null or c10 == null or c44 == null or c38 == null:
		return false
	if c46.parts.size() > 0 and c46.parts[0]:
		return false
	if c10.parts.size() > 0 and c10.parts[0]:
		return false
	if c46.sub_government != GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		return false
	if c10.puppet_of >= 0:
		return false
	if not (c10.government == GameConstants.Government.SOCIALIST or c10.sub_government == GameConstants.SubGovernment.LEFT_RADICAL or c10.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST):
		return false
	if not (c44.government == GameConstants.Government.SOCIALIST or c44.government == GameConstants.Government.REFORMIST):
		return false
	if not (c38.government == GameConstants.Government.SOCIALIST or c38.government == GameConstants.Government.REFORMIST or world.decisions.completed[7]):
		return false
	var y := world.year
	var mo := world.month
	var day := world.day
	if (y >= 1985 and mo >= 5 and day >= 23) or (y >= 1985 and mo >= 6) or y >= 1986:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var r474 := int(ws.completed_event_ids.get("event_474", 0))
	if ws.get_flag("south_korea_gwangju_rebellion") and r474 == 0 and ws.completed_event_ids.has("event_474"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c46 := ws.get_country_by_legacy_index(46)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -150)
			if c46 != null:
				c46.government = GameConstants.Government.SOCIALIST
				c46.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c46)
				c46.set_tag("亲中", true)
				c46.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -200)
			_add_power(EmpireData.USA, -50)
			ws.influence_prc += 50
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_539_march_for_you.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_539",
	"num": 539,
	"priority": 53900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_539_march_for_you.gd",
	"trigger_script": "res://数据脚本/事件效果/event_539_march_for_you.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
