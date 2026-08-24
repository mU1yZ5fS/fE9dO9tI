extends "res://数据脚本/event_script_base.gd"

const S_14 := "event.script.event_485_germany_german_spring.c0"
const S_15 := "event.script.event_485_germany_german_spring.c1"
const S_23 := "event.script.event_485_germany_german_spring.c2"
const S_28 := "event.script.event_485_germany_german_spring.c3"
const S_32 := "event.script.event_485_germany_german_spring.c4"
const S_37 := "event.script.event_485_germany_german_spring.c5"
const S_41 := "event.script.event_485_germany_german_spring.c6"
const S_46 := "event.script.event_485_germany_german_spring.c7"
const S_48 := "event.script.event_485_germany_german_spring.c8"
const S_53 := "event.script.event_485_germany_german_spring.c9"
const S_56_0 := "event.script.event_485_germany_german_spring.c10"
const S_56_1 := "event.script.event_485_germany_german_spring.c11"
const S_59 := "event.script.event_485_germany_german_spring.c12"
const S_71 := "event.script.event_485_germany_german_spring.c13"
const S_78 := "event.script.event_485_germany_german_spring.c14"
const S_88 := "event.script.event_485_germany_german_spring.c15"
const S_103 := "event.script.event_485_germany_german_spring.c16"
const S_113 := "event.script.event_485_germany_german_spring.c17"
const S_134 := "event.script.event_485_germany_german_spring.c18"


## 原作 Event485.cs：日耳曼之春（四选项）。
## 触发：无自动触发点——原版由 DiploButtonScript.cs:10928（this_type==138）手动
##   number_event=485 进入；Godot 侧 trigger_conditions=[]。
## 差异：
##  - resultOfEvents[486]/[487] 缺省按原版 int 默认 0 处理；
##  - names1/names2 姓名拼接→ws.leader.name_display；
##  - isFXSEU→fxseu、isNAZIMAO→nazimao、Torg→对华贸易、proprc→亲中、cw→内战中；
##  - JoinAllOurAlliances→_join_our_alliances。

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	if int(world.completed_event_ids.get("event_486", 0)) == 0 \
			and _mod_active(world, GameConstants.Modifier.MAOIST_BULWARK) and world.ideology < 3:
		_enable(opt[0], tr(S_23))
	else:
		_disable(opt[0], tr(S_28))
	if int(world.completed_event_ids.get("event_487", 0)) == 1:
		_enable(opt[1], tr(S_32))
	else:
		_disable(opt[1], tr(S_37))
	if int(world.completed_event_ids.get("event_487", 0)) == 2:
		_enable(opt[2], tr(S_41))
	else:
		_disable(opt[2], tr(S_46))
	_enable(opt[3], tr(S_48))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c17 := ws.get_country_by_legacy_index(17)
	var c21 := ws.get_country_by_legacy_index(21)
	var c1 := ws.get_country_by_legacy_index(1)
	var c0 := ws.get_country_by_legacy_index(0)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := tr(S_56_0) + _leader_name() + tr(S_56_1)
			if c0 != null and not c0.has_tag("nato") and not c0.has_tag("eu"):
				text += tr(S_59)
			_add(W.I_BUDGET, -200)
			_add(W.I_ARMY, -200)
			_add(W.I_AGENTS, -200)
			if c17 != null:
				c17.government = GameConstants.Government.SOCIALIST
				c17.sub_government = GameConstants.SubGovernment.MAOIST
				_leave_alliances(c17)
				c17.set_tag("对华贸易", true)
				c17.set_tag("亲中", true)
				_join_our_alliances(c17)
				c17.内战中 = false
				c17.name = tr(S_71)
			_add_power(EmpireData.USA, -50)
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 80
			context["result_text"] = text
		1:
			var text := tr(S_78)
			_add(W.I_BUDGET, -200)
			_add(W.I_ARMY, -200)
			_add(W.I_AGENTS, -200)
			if c17 != null:
				c17.government = GameConstants.Government.AUTHORITARIAN
				c17.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				_leave_alliances(c17)
				c17.内战中 = false
				if c21 != null and c21.has_tag("fxseu"):
					text += tr(S_88)
					c17.set_tag("fxseu", true)
				elif c1 != null and ws.is_authoritarian(c1) and d.econ_system >= 13:
					c17.set_tag("对华贸易", true)
					c17.set_tag("亲中", true)
					_join_our_alliances(c17)
			_add_power(EmpireData.USA, -50)
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 80
			context["result_text"] = text
		2:
			var text := tr(S_103)
			_add(W.I_BUDGET, -200)
			_add(W.I_ARMY, -200)
			_add(W.I_AGENTS, -200)
			if c17 != null:
				c17.government = GameConstants.Government.AUTHORITARIAN
				c17.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
				_leave_alliances(c17)
				c17.内战中 = false
				if c21 != null and c21.has_tag("nazimao"):
					text += tr(S_113)
					c17.set_tag("nazimao", true)
					if c1 != null and c1.has_tag("nazimao"):
						c17.set_tag("对华贸易", true)
						c17.set_tag("亲中", true)
						_join_our_alliances(c17)
				else:
					c17.set_tag("对华贸易", true)
					c17.set_tag("亲中", true)
					_join_our_alliances(c17)
			_add_power(EmpireData.USA, -50)
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 80
			context["result_text"] = text
		3:
			context["result_text"] = tr(S_134)


func _mod_active(world: WorldState, idx: int) -> bool:
	return world != null and idx >= 0 and idx < world.modifiers.size() \
			and world.modifiers[idx] != null and world.modifiers[idx].is_active


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"






func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_485_germany_german_spring.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_485",
	"num": 485,
	"priority": 48500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_485_germany_german_spring.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
