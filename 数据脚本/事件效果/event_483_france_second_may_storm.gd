extends "res://数据脚本/event_script_base.gd"

const S_14 := "event.script.event_483_france_second_may_storm.c0"
const S_17 := "event.script.event_483_france_second_may_storm.c1"
const S_21 := "event.script.event_483_france_second_may_storm.c2"
const S_25 := "event.script.event_483_france_second_may_storm.c3"
const S_29 := "event.script.event_483_france_second_may_storm.c4"
const S_31 := "event.script.event_483_france_second_may_storm.c5"
const S_37 := "event.script.event_483_france_second_may_storm.c6"
const S_38 := "event.script.event_483_france_second_may_storm.c7"
const S_39 := "event.script.event_483_france_second_may_storm.c8"
const S_40 := "event.script.event_483_france_second_may_storm.c9"
const S_43 := "event.script.event_483_france_second_may_storm.c10"
const S_47 := "event.script.event_483_france_second_may_storm.c11"
const S_52 := "event.script.event_483_france_second_may_storm.c12"
const S_147 := "event.script.event_483_france_second_may_storm.c13"
const S_151 := "event.script.event_483_france_second_may_storm.c14"
const S_157 := "event.script.event_483_france_second_may_storm.c15"
const S_165 := "event.script.event_483_france_second_may_storm.c16"
const S_179 := "event.script.event_483_france_second_may_storm.c17"
const S_198 := "event.script.event_483_france_second_may_storm.c18"
const S_211 := "event.script.event_483_france_second_may_storm.c19"
const S_224 := "event.script.event_483_france_second_may_storm.c20"


## 原作 Event483.cs：第二次五月风暴（五选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1494-1496 ——
##   c21.Gosstroy==3 且 c85/c86/c87/c92/c45.Gosstroy!=3 且 年>=1984 且 月==5。
##   月相等 ExprNode 无法表达，走 trigger_script。
## 差异：
##  - modifies[42..45].active → ws.modifiers[i].is_active；
##  - EstablishGovernment(ProAmerican) → 仅清亲中/亲苏、置亲美（不动 government/sub）；
##  - LeaveAlliances / JoinAllOurAlliances 按项目惯例映射；puppetOf→puppet_of；econ→has_tag("econ")。

func evaluate(world: WorldState) -> bool:
	if world == null or world.date.year < 1984 or world.date.month != 5:
		return false
	var c21 := world.get_country_by_legacy_index(21)
	if c21 == null or c21.government != GameConstants.Government.LIBERAL:
		return false
	for idx in [85, 86, 87, 92, 45]:
		var c := world.get_country_by_legacy_index(idx)
		if c != null and c.government == GameConstants.Government.LIBERAL:
			return false
	return true


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var text := ""
	if _mod_active(world, GameConstants.Modifier.FRENCH_PRESIDENT_GISCARD):
		text = tr(S_17)
	elif _mod_active(world, GameConstants.Modifier.FRENCH_PRESIDENT_MITTERRAND):
		text = tr(S_21)
	elif _mod_active(world, GameConstants.Modifier.FRENCH_PRESIDENT_MARCHAIS):
		text = tr(S_25)
	elif _mod_active(world, GameConstants.Modifier.FRENCH_PRESIDENT_CHIRAC):
		text = tr(S_29)
	event_def.description = text + tr(S_31)
	var opt := event_def.options
	_enable(opt[0], tr(S_37))
	_enable(opt[1], tr(S_38))
	_enable(opt[2], tr(S_39))
	_enable(opt[3], tr(S_40))
	var c1 := world.get_country_by_legacy_index(1)
	if c1 != null and c1.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_enable(opt[4], tr(S_43))
	else:
		_disable(opt[4], tr(S_47))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_set_mod_active(42, false)
	_set_mod_active(43, false)
	_set_mod_active(44, false)
	_set_mod_active(45, false)
	var france := ws.get_country_by_legacy_index(21)
	var opt := int(context.get("option_index", -1))
	var num := 0
	var num2 := 0
	var num3 := 0
	if opt == 0:
		num += 1
		_add(W.I_AGENTS, -150)
		_add(W.I_BUDGET, -150)
		_add(W.I_ARMY, -150)
	if opt == 1:
		num2 += 1
		_add(W.I_AGENTS, -150)
		_add(W.I_BUDGET, -150)
		_add(W.I_ARMY, -150)
	if opt == 2:
		num3 += 1
		_add(W.I_AGENTS, -150)
		_add(W.I_BUDGET, -150)
		_add(W.I_ARMY, -150)
	for idx in [86, 87]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null and ws.is_socialism(c, true):
			num += 1
	var c85 := ws.get_country_by_legacy_index(85)
	var c92 := ws.get_country_by_legacy_index(92)
	var c86 := ws.get_country_by_legacy_index(86)
	var c87 := ws.get_country_by_legacy_index(87)
	if (c85 != null and ws.is_socialism(c85, true)) or (c85 != null and c85.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST):
		num += 1
	if c92 != null and ws.is_socialism(c92, true):
		num += 1
	if c92 != null and c92.sub_government == GameConstants.SubGovernment.TROTSKYIST:
		num2 += 2
	if _sub(44) == 18:
		num2 += 2
	if _sub(1) == 18:
		num2 += 2
	if c92 != null and c92.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		num3 += 1
	if c86 != null and c86.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		num3 += 1
	if c86 != null and c86.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		num3 += 1
	if c85 != null and c85.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		num3 += 1
	if c85 != null and c85.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		num3 += 1
	if c87 != null and c87.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		num3 += 1
	if c85 != null and c85.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
		num3 += 3
	var num4 := 0
	for c in ws.countries:
		if c != null and c.原版序号 != 0 and c.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
			num4 += 1
	if num4 >= 7 and opt == 4:
		if france != null:
			france.government = GameConstants.Government.AUTHORITARIAN
			france.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
			_leave_alliances(france)
			france.name = tr(S_151)
			france.set_tag("亲中", true)
			france.set_tag("对华贸易", true)
		var c154 := ws.get_country_by_legacy_index(154)
		if c154 != null:
			c154.government = GameConstants.Government.AUTHORITARIAN
			c154.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
			_leave_alliances(c154)
			c154.name = tr(S_157)
			c154.set_tag("亲中", true)
			c154.puppet_of = GameConstants.LegacySlot.FRANCE
			c154.set_tag("对华贸易", true)
		ws.influence_prc += 50
		context["result_text"] = tr(S_147)
	elif num >= num2 and num >= num3:
		if france != null:
			france.government = GameConstants.Government.SOCIALIST
			france.sub_government = GameConstants.SubGovernment.MAOIST
			_leave_alliances(france)
			if opt == 0:
				france.set_tag("对华贸易", true)
				france.set_tag("亲中", true)
				_join_our_alliances(france)
				ws.influence_prc += 50
		context["result_text"] = tr(S_165)
	elif num2 >= num and num2 >= num3:
		if france != null:
			france.government = GameConstants.Government.SOCIALIST
			france.sub_government = GameConstants.SubGovernment.TROTSKYIST
			_leave_alliances(france)
			if opt == 1:
				france.set_tag("对华贸易", true)
				france.set_tag("亲中", true)
				ws.influence_prc += 50
				if _sub(1) == 18:
					_join_our_alliances(france)
		context["result_text"] = tr(S_179)
	elif (c86 != null and c86.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST) or (c92 != null and c92.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST):
		if c85 != null and c85.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
			if france != null:
				france.government = GameConstants.Government.AUTHORITARIAN
				france.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
				_leave_alliances(france)
				if opt == 2:
					ws.influence_prc += 50
					france.set_tag("对华贸易", true)
					france.set_tag("亲中", true)
			context["result_text"] = tr(S_198)
		else:
			if france != null:
				france.government = GameConstants.Government.AUTHORITARIAN
				france.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
				_leave_alliances(france)
				if opt == 2:
					ws.influence_prc += 50
					france.set_tag("对华贸易", true)
			context["result_text"] = tr(S_211)
	else:
		if france != null:
			france.government = GameConstants.Government.AUTHORITARIAN
			france.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			_leave_alliances(france)
			if opt == 2:
				france.set_tag("对华贸易", true)
				france.set_tag("亲中", true)
				ws.influence_prc += 50
		context["result_text"] = tr(S_224)
	if france == null:
		return
	if france.sub_government != GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST and france.sub_government != GameConstants.SubGovernment.NEO_FASCIST and france.sub_government != GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		for c in ws.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.FRANCE:
				c.puppet_of = GameConstants.LegacySlot.NONE
				_leave_alliances(c)
				c.set_tag("亲中", false)
				c.set_tag("亲苏", false)
				c.set_tag("亲美", true)
		return
	if france.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST and _sub_has_econ(1):
		for c in ws.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.FRANCE:
				c.set_tag("econ", true)


func _sub(idx: int) -> int:
	var c := ws.get_country_by_legacy_index(idx)
	return c.sub_government if c != null else -1


func _sub_has_econ(idx: int) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag("econ")


func _mod_active(world: WorldState, idx: int) -> bool:
	return world != null and idx >= 0 and idx < world.modifiers.size() \
			and world.modifiers[idx] != null and world.modifiers[idx].is_active


func _set_mod_active(idx: int, active: bool) -> void:
	if idx >= 0 and idx < ws.modifiers.size() and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = active






func _join_our_alliances(c: CountryData) -> void:
	var player := ws.get_country_by_legacy_index(1)
	if player == null:
		return
	if player.has_tag("okb"):
		c.set_tag("okb", true)
	elif player.has_tag("ovd"):
		c.set_tag("ovd", true)
	elif player.has_tag("seato"):
		c.set_tag("seato", true)
	if player.has_tag("econ"):
		c.set_tag("econ", true)
	elif player.has_tag("sev"):
		c.set_tag("sev", true)
	elif player.has_tag("asean"):
		c.set_tag("asean", true)






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_483_france_second_may_storm.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_483",
	"num": 483,
	"priority": 48300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_483_france_second_may_storm.gd",
	"trigger_script": "res://数据脚本/事件效果/event_483_france_second_may_storm.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
