extends "res://数据脚本/event_script_base.gd"

## 原作事件 71–73：纳萨尔派终局、人民党危机与两伊战争爆发。
## 来源：TimeScript.cs:3972-3995，doneventscript.cs:1767-1823，
##       Results_text.cs:5413-5428,6168-6241。



## 事件 71–73 逐字中文文案。
## 来源：Event71.cs / Event72.cs / Event73.cs。

const TXT_71_TITLE := "event.script.event_071_073_india_and_iran_war.c0"
const TXT_71_DESC := "event.script.event_071_073_india_and_iran_war.c1"
const TXT_71_OPT0 := "event.script.event_071_073_india_and_iran_war.c2"
const TXT_71_OPT1 := "event.script.event_071_073_india_and_iran_war.c3"
const TXT_71_OPT1_DIS := "event.script.event_071_073_india_and_iran_war.c4"
const TXT_71_OPT2 := "event.script.event_071_073_india_and_iran_war.c5"
const TXT_71_OPT2_DIS := "event.script.event_071_073_india_and_iran_war.c6"
const TXT_71_R0 := "event.script.event_071_073_india_and_iran_war.c7"
const TXT_71_R1 := "event.script.event_071_073_india_and_iran_war.c8"
const TXT_71_R2 := "event.script.event_071_073_india_and_iran_war.c9"

const TXT_72_TITLE := "event.script.event_071_073_india_and_iran_war.c10"
const TXT_72_DESC := "event.script.event_071_073_india_and_iran_war.c11"
const TXT_72_OPT0 := "event.script.event_071_073_india_and_iran_war.c12"
const TXT_72_OPT1 := "event.script.event_071_073_india_and_iran_war.c13"
const TXT_72_OPT1_DIS := "event.script.event_071_073_india_and_iran_war.c14"
const TXT_72_OPT2 := "event.script.event_071_073_india_and_iran_war.c15"
const TXT_72_OPT2_DIS := "event.script.event_071_073_india_and_iran_war.c16"
const TXT_72_R0_LEFT := "event.script.event_071_073_india_and_iran_war.c17"
const TXT_72_R0_OTHER := "event.script.event_071_073_india_and_iran_war.c18"
const TXT_72_R1 := "event.script.event_071_073_india_and_iran_war.c19"
const TXT_72_R2 := "event.script.event_071_073_india_and_iran_war.c20"

const TXT_73_TITLE := "event.script.event_071_073_india_and_iran_war.c21"
const TXT_73_DESC_ALT := "event.script.event_071_073_india_and_iran_war.c22"
const TXT_73_DESC := "event.script.event_071_073_india_and_iran_war.c23"
const TXT_73_OPT0 := "event.script.event_071_073_india_and_iran_war.c24"
const TXT_73_OPT1_HIDDEN := "event.script.event_071_073_india_and_iran_war.c25"
const TXT_73_OPT2_HIDDEN := "event.script.event_071_073_india_and_iran_war.c26"
const TXT_73_OPT3_HIDDEN := "event.script.event_071_073_india_and_iran_war.c27"
const TXT_73_R0 := "event.script.event_071_073_india_and_iran_war.c28"
const TXT_73_WAR := "event.script.event_071_073_india_and_iran_war.c29"
const TXT_73_SIDE1 := "event.script.event_071_073_india_and_iran_war.c30"
const TXT_73_SIDE2 := "event.script.event_071_073_india_and_iran_war.c31"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"naxalite_endgame": _event_71(option_index, context)
		"janata_crisis": _event_72(option_index, context)
		"iran_iraq_war": _event_73(context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_71(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			ws.set_flag("cb_india", true)
			context["result_text"] = tr(TXT_71_R0)
		1:
			_add_data({W.I_PARTY_SUPPORT: 80, W.I_INFLUENCE: 10, W.I_DIPLO: -10})
			_add_empire_relation(EmpireData.USSR, 50)
			context["result_text"] = tr(TXT_71_R1)
		2:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_DIPLO: 50,
				W.I_INDIA_WAR_PRESSURE: 200})
			_add_empire_relation(EmpireData.USA, -150)
			_add_empire_relation(EmpireData.USSR, -250)
			ws.war_state = GameConstants.WarState.INDIA
			context["result_text"] = tr(TXT_71_R2)


func _event_72(option_index: int, context: Dictionary) -> void:
	var india := ws.get_country_by_legacy_index(19)
	match option_index:
		0:
			ws.global_influence -= 10
			if india != null:
				india.set_tag("对华贸易", false)
				india.set_tag("亲苏", true)
			if int(ws.india_election) == 1:
				context["result_text"] = tr(TXT_72_R0_LEFT)
			else:
				context["result_text"] = tr(TXT_72_R0_OTHER)
		1:
			_add_data({W.I_PARTY_SUPPORT: 80, W.I_AGENTS: -60, W.I_BUDGET: -100})
			_add_empire_relation(EmpireData.USA, -80)
			if india != null:
				india.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			context["result_text"] = tr(TXT_72_R1)
		2:
			_add_data({W.I_PARTY_SUPPORT: 80, W.I_AGENTS: -60, W.I_BUDGET: -100})
			_add_empire_relation(EmpireData.USA, -80)
			_add_empire_power(EmpireData.USA, 20)
			if india != null:
				india.government = GameConstants.Government.LIBERAL
				india.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			context["result_text"] = tr(TXT_72_R2)


func _event_73(context: Dictionary) -> void:
	# Event73.cs TextOfEvents 中 Gosstroy==1 分支随后被无条件覆盖，原版即死代码；本版只采用第二段描述。
	# 原版销毁按钮1-3的文案保留在常量 TXT_73_OPT1_HIDDEN / TXT_73_OPT2_HIDDEN / TXT_73_OPT3_HIDDEN 中以备溯源。
	game.start_war(3, "Iraq", "Iran", 500, 500, 0, 0)
	context["result_text"] = tr(TXT_73_R0)


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.size():
			ws.add_data_by_index(index, int(changes[raw_index]))


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.usa_relations = ws.empires[EmpireData.USA].relations
		ws.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.ussr_relations = ws.empires[EmpireData.USSR].relations
		ws.soviet_influence = ws.empires[EmpireData.USSR].power
