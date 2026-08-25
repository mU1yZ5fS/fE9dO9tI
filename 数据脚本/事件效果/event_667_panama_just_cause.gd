extends "res://数据脚本/event_script_base.gd"

const T_667_0 := "event.script.event_667_panama_just_cause.c0"
const T_667_1 := "event.script.panama_just_cause.t_667_1"
const T_667_2 := "event.script.panama_just_cause.t_667_2"
const T_667_3 := "event.script.event_667_panama_just_cause.c1"
const T_667_4 := "event.script.event_667_panama_just_cause.c2"
const T_667_6 := "event.script.event_667_panama_just_cause.c3"
const T_667_7 := "event.script.event_667_panama_just_cause.c4"
const T_667_8 := "event.script.event_667_panama_just_cause.c5"
const T_667_9 := "event.script.event_667_panama_just_cause.c6"
const T_667_10 := "event.script.event_667_panama_just_cause.c7"
const T_667_11 := "event.script.event_667_panama_just_cause.c8"
const T_667_12 := "event.script.event_667_panama_just_cause.c9"
const T_667_13 := "event.script.event_667_panama_just_cause.c10"
const T_667_14 := "event.script.event_667_panama_just_cause.c11"
const T_667_16 := "event.script.event_667_panama_just_cause.c12"
const T_667_17 := "event.script.event_667_panama_just_cause.c13"
const T_667_18 := "event.script.event_667_panama_just_cause.c14"
const T_667_19 := "event.script.event_667_panama_just_cause.c15"
const T_667_20 := "event.script.event_667_panama_just_cause.c16"
const T_667_21 := "event.script.event_667_panama_just_cause.c17"
const T_667_22 := "event.script.event_667_panama_just_cause.c18"
const T_667_23 := "event.script.event_667_panama_just_cause.c19"
const T_667_24 := "event.script.event_667_panama_just_cause.c20"


## 原作 Event667.cs：“正义事业”行动（巴拿马，两选项）。 ## 触发：TimeScript.cs:11135-11140 —— 年>=1985 && (美国 now_leader==0 ==2) && !巴拿马 isSEV。 ## 差异： ##  - 描述按 resultOfEvents[665]==0 动态二选一。 ##  - 结果里 proprc 计数 138..149 + 152；num2 看古巴(138) SubGosstroy==10。 ##  - 死代码 result_num==5 跳过。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	event_def.title = tr(T_667_0)
	var r665 := int(world.completed_event_ids.get("event_665", 0))
	event_def.description = tr(T_667_1) if r665 == 0 else tr(T_667_2)
	var opt := event_def.options
	_enable(opt[0], tr(T_667_3))
	_enable(opt[1], tr(T_667_4))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var panama := ws.get_country_by_legacy_index(141)
	_set_part(panama, 0, true)
	var num := 0
	for i in range(138, 150):
		var c := ws.get_country_by_legacy_index(i)
		if c != null and c.has_tag("亲中"):
			num += 1
	var c152 := ws.get_country_by_legacy_index(152)
	if c152 != null and c152.has_tag("亲中"):
		num += 1
	var r665 := int(ws.completed_event_ids.get("event_665", 0))
	var opt := int(context.get("option_index", -1))
	if r665 == 0:
		if opt == 0:
			_add_relation(EmpireData.USA, -100)
			_start_war(84, tr(T_667_9), tr(T_667_10), 150 + num * 20, 850 - num * 20, 1, 0, tr(T_667_8))
			context["result_text"] = tr(T_667_7)
		elif opt == 1:
			_start_war(84, tr(T_667_13), tr(T_667_14), 50 + num * 20, 950 - num * 20, 1, 0, tr(T_667_12))
			context["result_text"] = tr(T_667_11)
	else:
		var num2 := 0
		var cuba := ws.get_country_by_legacy_index(138)
		if cuba != null and cuba.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
			num2 = 100
		if opt == 0:
			if panama != null:
				panama.government = GameConstants.Government.AUTHORITARIAN
				panama.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				panama.set_tag("对华贸易", true)
				panama.set_tag("亲中", true)
			_start_war(84, tr(T_667_19), tr(T_667_20), 150 + num * 20 + num2, 850 - num * 20 - num2, 1, 0, tr(T_667_18), 4)
			var text := tr(T_667_16)
			if cuba != null and cuba.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
				text = text.replace("{1}", tr(T_667_17))
			else:
				text = text.replace("{1}", "")
			context["result_text"] = text
		elif opt == 1:
			if panama != null:
				panama.government = GameConstants.Government.AUTHORITARIAN
				panama.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				panama.set_tag("对华贸易", true)
				panama.set_tag("亲中", true)
			_start_war(84, tr(T_667_23), tr(T_667_24), 50 + num * 20 + num2, 950 - num * 20 - num2, 1, 0, tr(T_667_22), 4)
			context["result_text"] = tr(T_667_21)



func _set_part(country: CountryData, index: int, value: bool) -> void:
	if country == null:
		return
	while country.parts.size() <= index:
		country.parts.append(false)
	country.parts[index] = value


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, war_name: String, fortnight: int = -1) -> void:
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		if fortnight >= 0:
			ws.wars[war_id].fortnight_max = fortnight



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_667_panama_just_cause.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_667",
	"num": 667,
	"priority": 66700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_667_panama_just_cause.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1985.1.1"}, {"t": "ANY", "c": [{"t": "EMPIRE_LEADER_IS", "key": "0"}, {"t": "EMPIRE_LEADER_IS", "key": "0", "v": 2}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "sev", "target": "141"}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
