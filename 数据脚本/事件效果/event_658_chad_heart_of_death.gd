extends "res://数据脚本/event_script_base.gd"

const T_658_0 := "event.script.event_658_chad_heart_of_death.c0"
const T_658_1 := "event.script.event_658_chad_heart_of_death.c1"
const T_658_2 := "event.script.event_658_chad_heart_of_death.c2"
const T_658_3 := "event.script.event_658_chad_heart_of_death.c3"
const T_658_4 := "event.script.event_658_chad_heart_of_death.c4"
const T_658_5 := "event.script.event_658_chad_heart_of_death.c5"
const T_658_6 := "event.script.event_658_chad_heart_of_death.c6"
const T_658_7 := "event.script.event_658_chad_heart_of_death.c7"
const T_658_8 := "event.script.event_658_chad_heart_of_death.c8"
const T_658_9 := "event.script.event_658_chad_heart_of_death.c9"
const T_658_10 := "event.script.event_658_chad_heart_of_death.c10"
const T_658_11 := "event.script.event_658_chad_heart_of_death.c11"
const T_658_12 := "event.script.event_658_chad_heart_of_death.c12"
const T_658_14 := "event.script.event_658_chad_heart_of_death.c13"
const T_658_15 := "event.script.event_658_chad_heart_of_death.c14"
const T_658_16 := "event.script.event_658_chad_heart_of_death.c15"
const T_658_17 := "event.script.event_658_chad_heart_of_death.c16"
const T_658_18 := "event.script.event_658_chad_heart_of_death.c17"
const T_658_19 := "event.script.event_658_chad_heart_of_death.c18"
const T_658_20 := "event.script.event_658_chad_heart_of_death.c19"
const T_658_21 := "event.script.event_658_chad_heart_of_death.c20"
const T_658_22 := "event.script.event_658_chad_heart_of_death.c21"
const T_658_23 := "event.script.event_658_chad_heart_of_death.c22"


## 原作 Event658.cs：非洲死亡之心（乍得内战，四选项）。 ## 触发：TimeScript.cs:11086-11091 —— (日>=29 且 月>=10 且 年>=1981) (月>=11 且 年>=1981) 年>=1982。 ## 差异： ##  - 描述后缀与 opt1/opt2 文案按 resultOfEvents[512] / [561] 动态选择（缺省按原版 int 默认 0）。 ##  - OilProd += 100f 已建模（ws.oil_prod）。 ##  - War 80：AmericanSupportDefender.SovietSupportAttacker → usa_side = GameConstants.WarSide.SIDE2 / ussr_side = GameConstants.WarSide.SIDE1。 ##  - 死代码 result_num==5（button_text[5] 测试分支）跳过。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	var r512 := int(world.completed_event_ids.get("event_512", 0))
	var r561 := int(world.completed_event_ids.get("event_561", 0))
	event_def.title = tr(T_658_0)
	var desc := tr(T_658_1)
	if r512 != 2 and r561 != 1:
		desc = desc.replace("{0}", tr(T_658_2))
	else:
		desc = desc.replace("{0}", tr(T_658_3))
	event_def.description = desc
	var libya := world.get_country_by_legacy_index(13)
	var france := world.get_country_by_legacy_index(21)
	var usa_rel := 0
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null:
		usa_rel = world.empires[EmpireData.USA].relations
	var opt := event_def.options
	if line <= 2 and libya != null and libya.government != GameConstants.Government.LIBERAL:
		_enable(opt[0], tr(T_658_4))
	else:
		_disable(opt[0], tr(T_658_5))
	if line >= 3 and ((france != null and france.has_tag("对华贸易")) or usa_rel >= 500):
		if r512 != 2 and r561 != 1:
			_enable(opt[1], tr(T_658_6))
		else:
			_enable(opt[1], tr(T_658_7))
	else:
		_disable(opt[1], tr(T_658_8))
	if line <= 1 and libya != null and libya.has_tag("对华贸易") and r512 != 2:
		_enable(opt[2], tr(T_658_9))
	else:
		if r512 != 2 and r561 != 1:
			_disable(opt[2], tr(T_658_10))
		else:
			_disable(opt[2], tr(T_658_11))
	_enable(opt[3], tr(T_658_12))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var chad := ws.get_country_by_legacy_index(57)
	_set_part(chad, 0, true)
	game.start_war(80, tr(T_658_16), tr(T_658_17), 500, 500, 1, 0)
	if ws.wars.size() > 80 and ws.wars[80] != null:
		ws.wars[80].name_war = tr(T_658_15)
	var r512 := int(ws.completed_event_ids.get("event_512", 0))
	var r561 := int(ws.completed_event_ids.get("event_561", 0))
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := tr(T_658_18)
			if r512 != 2 and r561 != 1:
				text += tr(T_658_19)
			text += tr(T_658_20)
			_war_add(80, 50, -50)
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -150)
			_add(W.I_ARMY, -150)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, 50)
			ws.oil_prod += 100.0  # Event658.cs OilProd
			context["result_text"] = text
		1:
			_war_add(80, -50, 50)
			_add(W.I_DIPLO, -50)
			_add(W.I_BUDGET, -150)
			_add(W.I_ARMY, -150)
			_add_relation(EmpireData.USA, -50)
			context["result_text"] = tr(T_658_21)
		2:
			_war_add(80, 50, -50)
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -150)
			_add(W.I_ARMY, -150)
			_add_relation(EmpireData.USSR, 50)
			ws.oil_prod += 100.0  # Event658.cs OilProd
			context["result_text"] = tr(T_658_22)
		3:
			context["result_text"] = tr(T_658_23)




func _war_add(war_id: int, d1: int, d2: int) -> void:
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].infl1 += d1
		ws.wars[war_id].infl2 += d2


func _set_part(country: CountryData, index: int, value: bool) -> void:
	if country == null:
		return
	while country.parts.size() <= index:
		country.parts.append(false)
	country.parts[index] = value



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_658_chad_heart_of_death.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_658",
	"num": 658,
	"priority": 65800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_658_chad_heart_of_death.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1981.10.29"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
