extends "res://数据脚本/event_script_base.gd"

const S_14 := "event.script.event_481_italy_rusty_horseshoe.c0"
const S_15 := "event.script.event_481_italy_rusty_horseshoe.c1"
const S_48 := "event.script.event_481_italy_rusty_horseshoe.c2"
const S_53 := "event.script.event_481_italy_rusty_horseshoe.c3"
const S_57 := "event.script.event_481_italy_rusty_horseshoe.c4"
const S_62 := "event.script.event_481_italy_rusty_horseshoe.c5"
const S_66 := "event.script.event_481_italy_rusty_horseshoe.c6"
const S_71 := "event.script.event_481_italy_rusty_horseshoe.c7"
const S_73 := "event.script.event_481_italy_rusty_horseshoe.c8"
const S_78 := "event.script.event_481_italy_rusty_horseshoe.c9"
const S_81 := "event.script.event_481_italy_rusty_horseshoe.c10"
const S_91 := "event.script.event_481_italy_rusty_horseshoe.c11"
const S_105 := "event.script.event_481_italy_rusty_horseshoe.c12"
const S_116 := "event.script.event_481_italy_rusty_horseshoe.c13"
const S_123 := "event.script.event_481_italy_rusty_horseshoe.c14"
const S_141 := "event.script.event_481_italy_rusty_horseshoe.c15"
const S_148 := "event.script.event_481_italy_rusty_horseshoe.c16"
const S_151 := "event.script.event_481_italy_rusty_horseshoe.c17"
const S_162 := "event.script.event_481_italy_rusty_horseshoe.c18"


## 原作 Event481.cs：锈迹斑斑的马蹄铁（四选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1234-1236 —— c85.SubGosstroy==10。
## 差异：
##  - resultOfEvents[395] 缺省按原版 int 默认 0 处理；
##  - JoinAllOurAlliances(true)→_join_our_alliances；LeaveAlliances→_leave_alliances；
##  - prosov→亲苏、proprc→亲中、Vyshi→亲美、Torg→对华贸易。

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var num := 0
	for idx in [92, 85, 86, 87, 17, 21]:
		var c := world.get_country_by_legacy_index(idx)
		if c != null and world.is_socialism(c, true):
			num += 1
	var c1 := world.get_country_by_legacy_index(1)
	var red := c1 != null and c1.has_tag("rim") \
			and _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION) and _mod_active(world, GameConstants.Modifier.MAOIST_BULWARK) \
			and world.is_socialism(c1, true) \
			and int(world.completed_event_ids.get("event_395", 0)) == 1 \
			and _dval(world, 134) >= 300 and num >= 2
	if red:
		_enable(opt[0], tr(S_48))
	else:
		_disable(opt[0], tr(S_53))
	if int(world.completed_event_ids.get("event_395", 0)) == 0:
		_enable(opt[1], tr(S_57))
		_enable(opt[2], tr(S_66))
	else:
		_disable(opt[1], tr(S_62))
		_disable(opt[2], tr(S_71))
	_enable(opt[3], tr(S_73))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
			_add(W.I_ARMY, -200)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -300)
			_add_relation(EmpireData.USSR, -100)
			if italy != null:
				italy.government = GameConstants.Government.AUTHORITARIAN
				italy.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				_leave_alliances(italy)
				italy.name = tr(S_91)
				if d.ideology > 3 or d.party_system > 7 or d.econ_system > 13 \
						or d.religion_policy > 28 or d.political_display > 40 or d.econ_display > 36:
					_leave_alliances(italy)
				else:
					_join_our_alliances(italy)
					italy.set_tag("亲中", true)
					italy.set_tag("对华贸易", true)
			context["result_text"] = tr(S_81)
		1:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -50)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -300)
			_add_relation(EmpireData.USSR, -250)
			if italy != null:
				italy.government = GameConstants.Government.AUTHORITARIAN
				italy.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				_leave_alliances(italy)
				italy.set_tag("对华贸易", true)
				italy.name = tr(S_116)
				_join_our_alliances(italy)
				italy.set_tag("亲中", true)
				italy.set_tag("对华贸易", true)
			context["result_text"] = tr(S_105)
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -50)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -300)
			_add_relation(EmpireData.USSR, -250)
			if italy != null:
				italy.government = GameConstants.Government.AUTHORITARIAN
				italy.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
				italy.set_tag("对华贸易", true)
				_join_our_alliances(italy)
				italy.set_tag("亲中", true)
				italy.set_tag("对华贸易", true)
			context["result_text"] = tr(S_123)
		3:
			var c51 := ws.get_country_by_legacy_index(51)
			var c21 := ws.get_country_by_legacy_index(21)
			var c15 := ws.get_country_by_legacy_index(15)
			var ussr := ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
			if (c51 == null or not c51.has_tag("nato")) and ussr != null \
					and ussr.current_leader != 6 and ussr.current_leader != 7 \
					and ((c21 != null and c21.has_tag("sev")) or (c15 != null and c15.has_tag("sev"))):
				if italy != null:
					italy.government = GameConstants.Government.SOCIALIST
					italy.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					_leave_alliances(italy)
					italy.set_tag("亲苏", true)
					italy.set_tag("对华贸易", false)
					italy.name = tr(S_148)
				_add_power(EmpireData.USSR, 50)
				context["result_text"] = tr(S_141)
			else:
				if italy != null:
					italy.government = GameConstants.Government.AUTHORITARIAN
					italy.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					_leave_alliances(italy)
					italy.set_tag("亲美", true)
					var c0 := ws.get_country_by_legacy_index(0)
					if c0 != null and c0.has_tag("nato"):
						italy.set_tag("nato", true)
					italy.set_tag("对华贸易", false)
					italy.name = tr(S_162)
				_add_power(EmpireData.USA, 50)
				context["result_text"] = tr(S_151)


func _dval(world: WorldState, idx: int) -> int:
	if world == null or world.size() <= idx:
		return 0
	return world.get_data_by_index(idx)


func _mod_active(world: WorldState, idx: int) -> bool:
	return world != null and idx >= 0 and idx < world.modifiers.size() \
			and world.modifiers[idx] != null and world.modifiers[idx].is_active






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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_481_italy_rusty_horseshoe.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_481",
	"num": 481,
	"priority": 48100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_481_italy_rusty_horseshoe.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 10, "target": "85"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
