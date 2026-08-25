extends "res://数据脚本/event_script_base.gd"

## 原作 Event456.cs：高考？高考！（教育路线三选项）。
## 触发：全目录无 this_num_event=456 / StartEvent(456)；仅各系统读 event_done[456]/resultOfEvents[456]
##   做显示分支。按项目约定 trigger_conditions=[]（仅定义，待外部入口接入）。
## 差异：politic.traits[0]→trait_personality；原版随后改写 old_modify_desc[2] 的
##   大段修正描述为显示层文案，按项目约定跳过（display-only）。

const TXT_OPT0_DIS := "event.script.event_456_gaokao_gaokao.c0"
const TXT_OPT1_DIS_A := "event.script.event_456_gaokao_gaokao.c1"
const TXT_OPT1_DIS_B := "event.script.event_456_gaokao_gaokao.c2"
const TXT_OPT2_DIS := "event.script.event_456_gaokao_gaokao.c3"
const TXT_R0 := "event.script.event_456_gaokao_gaokao.c4"
const TXT_R1 := "event.script.event_456_gaokao_gaokao.c5"
const TXT_R2 := "event.script.event_456_gaokao_gaokao.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line56 := d.political_line if d.size() > W.I_POLITICAL_LINE else 0
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var opt := event_def.options
	if not mod3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line56 >= 1 and line56 < 3 and not mod3:
		_enable(opt[1], event_def.options[1].text)
	elif mod3 or line56 == 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_A))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_B))
	if line56 == 0 or mod3:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			for p in ws.politicians:
				if p != null:
					if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
						p.power -= 10
					elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST or p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL:
						p.power += 20
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, 100)
		1:
			context["result_text"] = tr(TXT_R1)
			for p in ws.politicians:
				if p != null:
					if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
						p.power -= 5
					elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
						p.power += 5
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 100)
		2:
			context["result_text"] = tr(TXT_R2)
			for p in ws.politicians:
				if p != null:
					if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
						p.power += 10
					elif p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL or p.trait_personality == 4:
						p.power -= 5
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, 50)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_456_gaokao_gaokao.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_456",
	"num": 456,
	"priority": 45600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_456_gaokao_gaokao.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
