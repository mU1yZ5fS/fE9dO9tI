extends "res://数据脚本/event_script_base.gd"

## 原作 Event450.cs：永恒之光（伊朗反神权武装，三选项）。
## 触发：ReqEventForDLC02.cs:372-374 —— event_done[447] && !event_done[448] && !iranrev
##   && ingamewars[3].is_going && DATE_AFTER 1982.5.1；fire_only_once 承担 !event_done[450]。
## 差异：iranrev→global_flags；战争3为既有两伊战争；结果0按 SubGosstroy 动态插入领袖名。

const TXT_DESC_NCRI := "event.script.event_450_eternal_light.c0"
const TXT_DESC_BAZARGAN := "event.script.event_450_eternal_light.c1"
const TXT_DESC_HAVARI := "event.script.event_450_eternal_light.c2"
const TXT_OPT0_DIS := "event.script.event_450_eternal_light.c3"
const TXT_OPT1_DIS_A := "event.script.event_450_eternal_light.c4"
const TXT_OPT1_DIS_B := "event.script.event_450_eternal_light.c5"
const TXT_R0_NAME_NCRI := "event.script.event_450_eternal_light.c6"
const TXT_R0_NAME_BAZARGAN := "event.script.event_450_eternal_light.c7"
const TXT_R0_NAME_OTHER := "event.script.event_450_eternal_light.c8"
const TXT_R0_FMT := "event.script.event_450_eternal_light.c9"
const TXT_R1_FMT := "event.script.event_450_eternal_light.c10"
const TXT_ARG_NCRI := "event.script.event_450_eternal_light.c11"
const TXT_ARG_OTHER := "event.script.event_450_eternal_light.c12"
const TXT_R2 := "event.script.event_450_eternal_light.c13"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	var iran := world.get_country_by_legacy_index(14)
	if event_def == null or iran == null or event_def.options.size() < 3:
		return
	var line56 := 0
	if world.size() > W.I_POLITICAL_LINE:
		line56 = world.political_line
	var opt := event_def.options
	if line56 <= 1 and iran.has_tag("亲中"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	var pak := world.get_country_by_legacy_index(31)
	var china := world.get_country_by_legacy_index(1)
	if line56 < 1 and pak != null and pak.has_tag("亲中") and iran.has_tag("亲中") and china != null and china.has_tag("okb"):
		_enable(opt[1], event_def.options[1].text)
	elif line56 > 1:
		_disable(opt[1], tr(TXT_OPT1_DIS_A))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_B))
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var iran := _country(14)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var leader := tr(TXT_R0_NAME_OTHER)
			if iran != null and iran.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
				leader = tr(TXT_R0_NAME_NCRI)
			elif iran != null and iran.sub_government == GameConstants.SubGovernment.MARXIST_LENINIST:
				leader = tr(TXT_R0_NAME_BAZARGAN)
			context["result_text"] = tr(TXT_R0_FMT).format([leader])
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -50)
			_add(W.I_ARMY, -100)
			_add(W.I_DIPLO, 50)
			_add_relation(EmpireData.USA, -150)
			ws.set_flag("iranrev", true)
		1:
			var arg := tr(TXT_ARG_OTHER)
			if iran != null and iran.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
				arg = tr(TXT_ARG_NCRI)
			context["result_text"] = tr(TXT_R1_FMT).format([arg, arg])
			_add(W.I_ARMY, -200)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -200)
			_add(W.I_DIPLO, 80)
			ws.influence_prc += 80
			_add_relation(EmpireData.USA, -300)
			var war := _get_war(3)
			if war != null:
				war.infl1 += 300
				war.infl2 -= 300
		2:
			context["result_text"] = tr(TXT_R2)




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)


func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)


func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_450_eternal_light.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_450",
	"num": 450,
	"priority": 45000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_450_eternal_light.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_447"}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_448"}, {"t": "NOT_HAS_FLAG", "key": "iranrev"}, {"t": "WAR_ACTIVE", "v": 3}, {"t": "DATE_AFTER", "key": "1982.5.1"}, {"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "event_447"}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_448"}, {"t": "NOT_HAS_FLAG", "key": "iranrev"}, {"t": "WAR_ACTIVE", "v": 3}, {"t": "DATE_AFTER", "key": "1982.5.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
