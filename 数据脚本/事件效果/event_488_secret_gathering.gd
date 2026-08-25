extends "res://数据脚本/event_script_base.gd"

## 原作 Event488.cs：秘密集结（民主德国危机，五选项）。
## 触发：ReqEventForDLC02.cs:1509-1511 —— 复合条件（含 parts[0] 数组）用
##   trigger_script 的 evaluate(world) 表达；fire_only_once 承担 !event_done[488]。
## 差异：
##  - Gosstroy/SubGosstroy → government/sub_government；dev → development；
##  - isSEV/isOVD/prosov/Torg/proprc → has_tag/set_tag；parts[0] 用 _set_part 置位；
##  - modifies[53].active = false → modifiers[53].is_active = false。



const TXT_OPT1_DIS := "event.script.event_488_secret_gathering.c0"
const TXT_OPT2_DIS := "event.script.event_488_secret_gathering.c1"
const TXT_OPT3_DIS := "event.script.event_488_secret_gathering.c2"

const TXT_R0_INTRO := "event.script.event_488_secret_gathering.c3"

const TXT_R0_FULL := "event.script.event_488_secret_gathering.c4"

const TXT_R0_COMPROMISE := "event.script.event_488_secret_gathering.c5"

const TXT_R1 := "event.script.event_488_secret_gathering.c6"

const TXT_R2 := "event.script.event_488_secret_gathering.c7"

const TXT_R3 := "event.script.event_488_secret_gathering.c8"

const TXT_R4_SUPPRESSED := "event.script.event_488_secret_gathering.c9"

const TXT_R4_REVOLT := "event.script.event_488_secret_gathering.c10"

const TXT_R4_EICHBERG := "event.script.event_488_secret_gathering.c11"

const TXT_NAME_EICHBERG := "event.script.event_488_secret_gathering.c12"

const TXT_R4_REMER := "event.script.event_488_secret_gathering.c13"

const TXT_NAME_REMER := "event.script.event_488_secret_gathering.c14"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var west := world.get_country_by_legacy_index(17)
	var east := world.get_country_by_legacy_index(16)
	var poland := world.get_country_by_legacy_index(2)
	var hungary := world.get_country_by_legacy_index(4)
	var romania := world.get_country_by_legacy_index(5)
	if west == null or east == null:
		return false
	if west.government != GameConstants.Government.REFORMIST and not west.has_tag("soc_eu"):
		return false
	if _part_true(west, 0):
		return false
	if _part_true(east, 0):
		return false
	if poland == null or hungary == null or romania == null:
		return false
	if poland.has_tag("亲苏") or hungary.has_tag("亲苏") or romania.has_tag("亲苏"):
		return false
	if world.empires.size() <= EmpireData.USSR or world.empires[EmpireData.USSR] == null:
		return false
	if world.empires[EmpireData.USSR].power > 400:
		return false
	var leader := world.empires[EmpireData.USSR].current_leader
	if leader != 5 and leader != 6 and leader != 8:
		return false
	return world.date.to_int() >= 19850617


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var china := world.get_country_by_legacy_index(1)
	var econ := world.econ_system if world.size() > W.I_ECON_SYSTEM else 11
	var line := world.political_line if world.size() > W.I_POLITICAL_LINE else 1
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if china != null and china.government <= 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if (china != null and (china.government == GameConstants.Government.REFORMIST or china.government == GameConstants.Government.LIBERAL)) or econ >= 13:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if line > 1:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var gdr := ws.get_country_by_legacy_index(16)
	var west := ws.get_country_by_legacy_index(17)
	var ussr_country := ws.get_country_by_legacy_index(7)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var sev_count := 0
			for c in ws.countries:
				if c != null and c.has_tag("sev"):
					sev_count += 1
			var text := tr(TXT_R0_INTRO)
			if sev_count < 5:
				text += tr(TXT_R0_FULL)
				_add(W.I_BUDGET, -200)
				_add(W.I_AGENTS, -50)
				if gdr != null:
					_leave_alliances(gdr)
					gdr.set_tag("亲中", true)
					gdr.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
					_join_alliances(gdr)
					gdr.set_tag("对华贸易", true)
				ws.influence_prc += 50
				_add_power(EmpireData.USSR, -50)
				_add_relation(EmpireData.USSR, -300)
			else:
				text += tr(TXT_R0_COMPROMISE)
				_add(W.I_BUDGET, -100)
				_add(W.I_AGENTS, -50)
				if gdr != null:
					gdr.set_tag("ovd", false)
					gdr.set_tag("亲苏", false)
					gdr.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					gdr.set_tag("对华贸易", true)
				ws.influence_prc += 20
				_add_power(EmpireData.USSR, -20)
				_add_relation(EmpireData.USSR, -200)
			context["result_text"] = text
		1:
			_add(W.I_DIPLO, 100)
			if gdr != null:
				gdr.government = GameConstants.Government.AUTHORITARIAN
				gdr.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				_leave_alliances(gdr)
				gdr.set_tag("亲中", true)
				gdr.set_tag("对华贸易", true)
			_add(W.I_AGENTS, -200)
			_add(W.I_BUDGET, -30)
			ws.influence_prc += 5
			_add_relation(EmpireData.USA, -500)
			_add_relation(EmpireData.USSR, -500)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			if gdr != null:
				gdr.set_tag("亲苏", false)
				gdr.government = GameConstants.Government.REFORMIST
				gdr.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
				gdr.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_BUDGET, -250)
			_add(W.I_AGENTS, -200)
			_add(W.I_ARMY, -100)
			ws.influence_prc += 50
			_add_power(EmpireData.USSR, -50)
			_add_relation(EmpireData.USSR, -400)
			if gdr != null:
				_leave_alliances(gdr)
				gdr.set_tag("亲中", true)
				gdr.government = GameConstants.Government.REFORMIST
				gdr.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
				_join_alliances(gdr)
				gdr.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R3)
		4:
			var ussr := _empire(EmpireData.USSR)
			var ussr_in_ovd := ussr_country != null and ussr_country.has_tag("ovd")
			if ussr != null and ussr.power >= 100 and ussr_in_ovd:
				context["result_text"] = tr(TXT_R4_SUPPRESSED)
			else:
				var text := tr(TXT_R4_REVOLT)
				if gdr != null:
					gdr.内战中 = true
				if west != null and west.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
					text += tr(TXT_R4_EICHBERG)
					if west != null:
						_set_part(west, 0, true)
						west.development = 2
						west.name = tr(TXT_NAME_EICHBERG)
						west.chinese_name = tr(TXT_NAME_EICHBERG)
					if gdr != null:
						_leave_alliances(gdr)
					_set_modifier_active(53, false)
				elif west != null and west.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
					text += tr(TXT_R4_REMER)
					if west != null:
						_set_part(west, 0, true)
						west.development = 2
						west.name = tr(TXT_NAME_REMER)
						west.chinese_name = tr(TXT_NAME_REMER)
					if gdr != null:
						_leave_alliances(gdr)
					_set_modifier_active(53, false)
				context["result_text"] = text


func _part_true(c: CountryData, index: int) -> bool:
	return c != null and c.parts.size() > index and c.parts[index]


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value


func _set_modifier_active(index: int, value: bool) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = value


func _empire(index: int) -> EmpireData:
	if ws.empires.size() > index and ws.empires[index] != null:
		return ws.empires[index]
	return null



func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_488_secret_gathering.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_488",
	"num": 488,
	"priority": 48800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_488_secret_gathering.gd",
	"trigger_script": "res://数据脚本/事件效果/event_488_secret_gathering.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
