extends "res://数据脚本/event_script_base.gd"

## 原作 Event454.cs：越南的野心（印支联邦成立，三选项）。
## 触发：ReqEventForDLC02.cs:387-389 —— allcountries[23].puppetOf==11 && allcountries[22].puppetOf==11；
##   fire_only_once 承担 !event_done[454]。
## 差异：描述按 resultOfEvents[56] 动态（原事件56在项目 event_id=teach_vietnam_lesson）；
##   name 改 chinese_name；isSEV→set_tag("sev")；Torg→set_tag("对华贸易")。

const TXT_DESC_A := "event.script.event_454_vietnam_ambition.c0"
const TXT_DESC_B := "event.script.event_454_vietnam_ambition.c1"
const TXT_OPT1_DIS_A := "event.script.event_454_vietnam_ambition.c2"
const TXT_OPT1_DIS_B := "event.script.event_454_vietnam_ambition.c3"
const TXT_R0 := "event.script.event_454_vietnam_ambition.c4"
const TXT_NAME_CAMBODIA := "event.script.event_454_vietnam_ambition.c5"
const TXT_NAME_FED := "event.script.event_454_vietnam_ambition.c6"
const TXT_NAME_LAOS := "event.script.event_454_vietnam_ambition.c7"
const TXT_R1 := "event.script.event_454_vietnam_ambition.c8"
const TXT_R2 := "event.script.event_454_vietnam_ambition.c9"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 3:
		return
	var res56 := int(world.completed_event_ids.get("teach_vietnam_lesson", 0))
	if res56 == 1:
		event_def.description = tr(TXT_DESC_A)
	else:
		event_def.description = tr(TXT_DESC_B)
	var line56 := 0
	if world.size() > W.I_POLITICAL_LINE:
		line56 = world.political_line
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if res56 == 0 and line56 >= 2:
		_enable(opt[1], event_def.options[1].text)
	elif res56 == 1:
		_disable(opt[1], tr(TXT_OPT1_DIS_A))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_B))
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_indochina_names()
			_indochina_torg(false, false, false)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_DIPLO, 50)
			_add(W.I_PARTY_SUPPORT, 100)
			ws.influence_prc -= 20
		1:
			context["result_text"] = tr(TXT_R1)
			_indochina_names()
			_indochina_torg(true, false, false)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_DIPLO, -50)
			_add(W.I_PARTY_SUPPORT, -100)
			ws.influence_prc -= 30
		2:
			context["result_text"] = tr(TXT_R2)
			_indochina_names()
			_indochina_torg(false, false, false)
			ws.influence_prc -= 50
	if MapService.instance != null:
		MapService.instance.sync_map_merges()



func _indochina_names() -> void:
	var c11 := _country(11)
	var c22 := _country(22)
	var c23 := _country(23)
	if c11 != null:
		c11.government = GameConstants.Government.AUTHORITARIAN
		c11.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
		c11.name = tr(TXT_NAME_FED)
		c11.chinese_name = tr(TXT_NAME_FED)
		_set_part(c11, 0, true)
		c11.set_tag("sev", true)
	if c22 != null:
		c22.name = tr(TXT_NAME_LAOS)
		c22.chinese_name = tr(TXT_NAME_LAOS)
		c22.set_tag("sev", true)
	if c23 != null:
		c23.name = tr(TXT_NAME_CAMBODIA)
		c23.chinese_name = tr(TXT_NAME_CAMBODIA)
		c23.set_tag("sev", true)


func _indochina_torg(v: bool, l: bool, k: bool) -> void:
	_tag(11, "对华贸易", v)
	_tag(22, "对华贸易", l)
	_tag(23, "对华贸易", k)



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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_454_vietnam_ambition.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_454",
	"num": 454,
	"priority": 45400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_454_vietnam_ambition.gd",
	"trigger": [{"t": "COUNTRY_FIELD_EQUALS", "key": "puppet_of", "v": 11, "target": "23"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "puppet_of", "v": 11, "target": "22"}, {"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "puppet_of", "v": 11, "target": "23"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "puppet_of", "v": 11, "target": "22"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
