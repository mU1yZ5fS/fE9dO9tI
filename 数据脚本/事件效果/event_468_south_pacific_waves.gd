extends "res://数据脚本/event_script_base.gd"

## 原作 Event468.cs：南太平洋海涛翻腾（马来亚内战二选项）。
## 触发：ReqEventForDLC02.cs:427-429 —— allcountries[34].cw && DATE_AFTER 1981.2.1；
##   fire_only_once 承担 !event_done[468]。
## 差异：usa_place=1→usa_side = GameConstants.WarSide.SIDE2；开战按项目约定 game.start_war(34,...) 后覆盖
##   name_war/fortnight_max（TickTime 20）；button_text[5]/result_num==5 死代码跳过。

const TXT_OPT0_DIS := "event.script.event_468_south_pacific_waves.c0"
const TXT_R0 := "event.script.event_468_south_pacific_waves.c1"
const TXT_WAR_NAME := "event.script.event_468_south_pacific_waves.c2"
const TXT_WAR_SIDE1 := "event.script.event_468_south_pacific_waves.c3"
const TXT_WAR_SIDE2 := "event.script.event_468_south_pacific_waves.c4"
const TXT_R1_BASE := "event.script.event_468_south_pacific_waves.c5"
const TXT_R1_ASEAN := "event.script.event_468_south_pacific_waves.c6"
const TXT_R1_TAIL := "event.script.event_468_south_pacific_waves.c7"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 2:
		return
	var done467 := world.completed_event_ids.has("event_467")
	var res467 := int(world.completed_event_ids.get("event_467", 0))
	var opt := event_def.options
	if done467 and res467 == 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	_enable(opt[1], event_def.options[1].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var malaysia := _country(49)
	var thai := _country(34)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if malaysia != null:
				malaysia.government = GameConstants.Government.AUTHORITARIAN
				malaysia.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			game.start_war(34, tr(TXT_WAR_SIDE1), tr(TXT_WAR_SIDE2), 300, 700, 1)
			var war := _get_war(34)
			if war != null:
				war.name_war = tr(TXT_WAR_NAME)
				war.fortnight_max = 20
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -100)
			_add_relation(EmpireData.USA, -300)
			ws.influence_prc += 20
		1:
			var text := tr(TXT_R1_BASE)
			var asean := _country(51)
			if asean != null and asean.has_tag("对华贸易"):
				text += tr(TXT_R1_ASEAN)
			text += tr(TXT_R1_TAIL)
			context["result_text"] = text
			_add_relation(EmpireData.USA, 150)
			if thai != null:
				thai.set_tag("对华贸易", false)
				if thai.has_tag("okb"):
					thai.set_tag("亲中", false)
				if thai.has_tag("econ") and not thai.has_tag("okb"):
					thai.set_tag("econ", false)
					thai.set_tag("sev", true)
					thai.set_tag("亲中", false)
					_add_power(EmpireData.USSR, 50)
			_tag(49, "对华贸易", true)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_468_south_pacific_waves.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_468",
	"num": 468,
	"priority": 46800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_468_south_pacific_waves.gd",
	"trigger": [{"t": "COUNTRY_FIELD_EQUALS", "key": "cw", "v": 1, "target": "34"}, {"t": "DATE_AFTER", "key": "1981.2.1"}, {"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "cw", "v": 1, "target": "34"}, {"t": "DATE_AFTER", "key": "1981.2.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
