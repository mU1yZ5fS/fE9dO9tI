extends "res://数据脚本/event_script_base.gd"

const T_499_0 := "event.script.event_499_sudan_may_revolution.c0"
const T_499_1 := "event.script.event_499_sudan_may_revolution.c1"
const T_499_2 := "event.script.event_499_sudan_may_revolution.c2"
const T_499_3 := "event.script.event_499_sudan_may_revolution.c3"
const T_499_4 := "event.script.event_499_sudan_may_revolution.c4"
const T_499_5 := "event.script.event_499_sudan_may_revolution.c5"
const T_499_6 := "event.script.event_499_sudan_may_revolution.c6"
const T_499_7 := "event.script.event_499_sudan_may_revolution.c7"
const T_499_8 := "event.script.event_499_sudan_may_revolution.c8"
const T_499_9 := "event.script.event_499_sudan_may_revolution.c9"
const T_499_10 := "event.script.event_499_sudan_may_revolution.c10"
const T_499_11 := "event.script.event_499_sudan_may_revolution.c11"
const T_499_12 := "event.script.event_499_sudan_may_revolution.c12"
const T_499_13 := "event.script.event_499_sudan_may_revolution.c13"
const T_499_14 := "event.script.event_499_sudan_may_revolution.c14"
const T_499_15 := "event.script.event_499_sudan_may_revolution.c15"
const T_499_16 := "event.script.event_499_sudan_may_revolution.c16"
const T_499_17 := "event.script.event_499_sudan_may_revolution.c17"
const T_499_18 := "event.script.event_499_sudan_may_revolution.c18"
const T_499_19 := "event.script.event_499_sudan_may_revolution.c19"
const T_499_20 := "event.script.event_499_sudan_may_revolution.c20"
const T_499_21 := "event.script.event_499_sudan_may_revolution.c21"
const T_499_22 := "event.script.event_499_sudan_may_revolution.c22"
const T_499_23 := "event.script.event_499_sudan_may_revolution.c23"
const T_499_24 := "event.script.event_499_sudan_may_revolution.c24"
const T_499_25 := "event.script.event_499_sudan_may_revolution.c25"
const T_499_26 := "event.script.event_499_sudan_may_revolution.c26"
const T_499_27 := "event.script.event_499_sudan_may_revolution.c27"
const T_499_28 := "event.script.event_499_sudan_may_revolution.c28"
const T_499_29 := "event.script.event_499_sudan_may_revolution.c29"
const T_499_30 := "event.script.event_499_sudan_may_revolution.c30"
const T_499_31 := "event.script.event_499_sudan_may_revolution.c31"
const T_499_32 := "event.script.event_499_sudan_may_revolution.c32"


## 原作 Event499.cs：五月革命是谁人的火焰？（苏丹，五选项）。 ## 触发：TimeScript.cs:11149-11154 —— (日>=1 且 月>=9 且 年>=1983) (月>=10 且 年>=1983) 年>=1984。 ## 差异： ##  - resultOfEvents 缺省按原版 int 默认 0。 ##  - 原版 OAR bool → ws.get_flag("oar")。 ##  - LeaveAlliances() 按 event_496 完整标签清单；JoinAllOurAlliances(true) 按 event_650 注释逻辑 ##    （flag 组 id 跳过军事联盟，只按中国 econ/sev 加入经济联盟）。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	event_def.title = tr(T_499_0)
	event_def.description = tr(T_499_1)
	var ethiopia := world.get_country_by_legacy_index(41)
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	if line < 3:
		_enable(opt[0], tr(T_499_2))
	else:
		_disable(opt[0], tr(T_499_3))
	if line > 0 and line < 4:
		_enable(opt[1], tr(T_499_4))
	elif line == 0:
		_disable(opt[1], tr(T_499_5))
	else:
		_disable(opt[1], tr(T_499_6))
	if line < 2 and ethiopia != null and ethiopia.has_tag("对华贸易"):
		_enable(opt[2], tr(T_499_7))
	else:
		_disable(opt[2], tr(T_499_8))
	_enable(opt[3], tr(T_499_9))
	if china != null and china.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_enable(opt[4], tr(T_499_10))
	else:
		_disable(opt[4], tr(T_499_11))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var sudan := ws.get_country_by_legacy_index(53)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -80)
			if sudan != null:
				sudan.government = GameConstants.Government.REFORMIST
				sudan.sub_government = GameConstants.SubGovernment.PRAGMATIST
				sudan.set_tag("对华贸易", true)
				sudan.set_tag("亲中", true)
			ws.influence_prc += 10
			context["result_text"] = tr(T_499_13)
		1:
			_result1(sudan, context)
		2:
			_result2(sudan, context)
		3:
			_result3(sudan, context)
		4:
			_result4(sudan, context)


func _result1(sudan: CountryData, context: Dictionary) -> void:
	if sudan == null:
		return
	var iraq := ws.get_country_by_legacy_index(14)
	var libya := ws.get_country_by_legacy_index(13)
	var egypt := ws.get_country_by_legacy_index(30)
	if sudan.prc_influence == 1 and iraq != null \
			and (iraq.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or iraq.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST or iraq.government == GameConstants.Government.REFORMIST) \
			and not iraq.has_tag("asean") and iraq.puppet_of < 0:
		var text := tr(T_499_14)
		if iraq.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or iraq.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
			text += tr(T_499_15)
		text += tr(T_499_16)
		_add(W.I_AGENTS, -50)
		_add_power(EmpireData.USSR, 50)
		_add_power(EmpireData.USA, -100)
		_add_relation(EmpireData.USA, -100)
		sudan.government = iraq.government
		sudan.sub_government = iraq.sub_government
		_leave_alliances(sudan)
		sudan.set_tag("对华贸易", true)
		sudan.name = tr(T_499_17)
		if iraq.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or iraq.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
			sudan.puppet_of = GameConstants.LegacySlot.IRAQ
		elif (ws.get_flag("oar") and egypt != null and egypt.has_tag("亲苏")) or iraq.has_tag("亲苏"):
			sudan.set_tag("亲苏", true)
		elif (ws.get_flag("oar") and egypt != null and egypt.has_tag("亲中")) or iraq.has_tag("亲中"):
			sudan.set_tag("亲中", true)
		context["result_text"] = text
	elif sudan.prc_influence == 2 and libya != null and libya.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		_add(W.I_AGENTS, -50)
		_add_relation(EmpireData.USA, -100)
		sudan.government = GameConstants.Government.AUTHORITARIAN
		sudan.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
		_leave_alliances(sudan)
		sudan.set_tag("对华贸易", true)
		sudan.puppet_of = 13
		sudan.name = tr(T_499_19)
		context["result_text"] = tr(T_499_18)
	elif d.size() > W.I_WAR_SUPPORT and d.war_support >= 700:
		_add(W.I_AGENTS, -50)
		sudan.government = GameConstants.Government.AUTHORITARIAN
		sudan.sub_government = GameConstants.SubGovernment.NEO_FASCIST
		sudan.set_tag("对华贸易", false)
		sudan.name = tr(T_499_21)
		_leave_alliances(sudan)
		context["result_text"] = tr(T_499_20)
	else:
		_add(W.I_AGENTS, -50)
		if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null \
				and ws.empires[EmpireData.USA].power > ws.influence_prc:
			sudan.government = GameConstants.Government.AUTHORITARIAN
			sudan.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			_leave_alliances(sudan)
			sudan.set_tag("对华贸易", true)
			sudan.set_tag("亲美", true)
		elif ws.is_socialism(ws.get_country_by_legacy_index(1), true) \
				or (ws.get_country_by_legacy_index(1) != null and ws.get_country_by_legacy_index(1).government == GameConstants.Government.REFORMIST) \
				or (ws.get_country_by_legacy_index(1) != null and ws.get_country_by_legacy_index(1).sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST):
			sudan.government = GameConstants.Government.REFORMIST
			sudan.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
			_leave_alliances(sudan)
			sudan.set_tag("对华贸易", true)
			sudan.set_tag("亲中", true)
		elif ws.get_country_by_legacy_index(1) != null and ws.get_country_by_legacy_index(1).government == GameConstants.Government.LIBERAL:
			sudan.government = GameConstants.Government.LIBERAL
			sudan.sub_government = GameConstants.SubGovernment.MODERATE
			_leave_alliances(sudan)
			sudan.set_tag("对华贸易", true)
			sudan.set_tag("亲中", true)
		else:
			sudan.government = GameConstants.Government.AUTHORITARIAN
			sudan.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			_leave_alliances(sudan)
			sudan.set_tag("对华贸易", true)
			sudan.set_tag("亲中", true)
		context["result_text"] = tr(T_499_22)


func _result2(sudan: CountryData, context: Dictionary) -> void:
	_add(W.I_BUDGET, -50)
	_add(W.I_ARMY, -100)
	if sudan != null:
		sudan.government = GameConstants.Government.AUTHORITARIAN
		sudan.sub_government = GameConstants.SubGovernment.NEO_FASCIST
		sudan.set_tag("对华贸易", false)
	_start_war(48, tr(T_499_25), tr(T_499_26), 600, 400, 0, 1, tr(T_499_24), 24)
	_set_part(sudan, 2, true)
	if sudan != null:
		sudan.set_tag("亲美", true)
	_add_power(EmpireData.USA, 20)
	context["result_text"] = tr(T_499_23)


func _result3(sudan: CountryData, context: Dictionary) -> void:
	if sudan != null:
		sudan.government = GameConstants.Government.AUTHORITARIAN
		sudan.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		sudan.set_tag("亲美", true)
	_add_power(EmpireData.USA, 20)
	_start_war(48, tr(T_499_29), tr(T_499_30), 600, 400, 0, 1, tr(T_499_28))
	_set_part(sudan, 2, true)
	context["result_text"] = tr(T_499_27)


func _result4(sudan: CountryData, context: Dictionary) -> void:
	var ethiopia := ws.get_country_by_legacy_index(41)
	if ethiopia != null and ethiopia.sub_government != GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -150)
		if sudan != null:
			sudan.government = GameConstants.Government.AUTHORITARIAN
			sudan.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
			_leave_alliances(sudan)
			sudan.set_tag("对华贸易", true)
			sudan.set_tag("亲中", true)
			_join_alliances(sudan)
		context["result_text"] = tr(T_499_31)
	else:
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -50)
		if sudan != null:
			sudan.government = GameConstants.Government.AUTHORITARIAN
			sudan.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
			_leave_alliances(sudan)
			sudan.set_tag("对华贸易", true)
			sudan.set_tag("亲中", true)
			_join_alliances(sudan)
		context["result_text"] = tr(T_499_32)



func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)




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



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_499_sudan_may_revolution.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_499",
	"num": 499,
	"priority": 49900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_499_sudan_may_revolution.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1983.9.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
