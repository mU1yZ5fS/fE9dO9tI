extends "res://数据脚本/event_script_base.gd"

const S_17 := "event.script.event_476_britain_foot_benne_conspiracy.c0"
const S_18 := "event.script.event_476_britain_foot_benne_conspiracy.c1"
const S_21 := "event.script.event_476_britain_foot_benne_conspiracy.c2"
const S_22 := "event.script.event_476_britain_foot_benne_conspiracy.c3"
const S_45 := "event.script.event_476_britain_foot_benne_conspiracy.c4"
const S_50 := "event.script.event_476_britain_foot_benne_conspiracy.c5"
const S_52 := "event.script.event_476_britain_foot_benne_conspiracy.c6"
const S_54 := "event.script.event_476_britain_foot_benne_conspiracy.c7"
const S_73 := "event.script.event_476_britain_foot_benne_conspiracy.c8"
const S_78 := "event.script.event_476_britain_foot_benne_conspiracy.c9"
const S_83 := "event.script.event_476_britain_foot_benne_conspiracy.c10"
const S_88 := "event.script.event_476_britain_foot_benne_conspiracy.c11"
const S_93 := "event.script.event_476_britain_foot_benne_conspiracy.c12"
const S_98 := "event.script.event_476_britain_foot_benne_conspiracy.c13"
const S_100 := "event.script.event_476_britain_foot_benne_conspiracy.c14"
const S_103 := "event.script.event_476_britain_foot_benne_conspiracy.c15"
const S_107 := "event.script.event_476_britain_foot_benne_conspiracy.c16"
const S_114 := "event.script.event_476_britain_foot_benne_conspiracy.c17"
const S_117_0 := "event.script.event_476_britain_foot_benne_conspiracy.c18"
const S_117_1 := "event.script.event_476_britain_foot_benne_conspiracy.c19"
const S_174_0 := "event.script.event_476_britain_foot_benne_conspiracy.c20"
const S_174_1 := "event.script.event_476_britain_foot_benne_conspiracy.c21"
const S_214_0 := "event.script.event_476_britain_foot_benne_conspiracy.c22"
const S_214_1 := "event.script.event_476_britain_foot_benne_conspiracy.c23"
const S_214_2 := "event.script.event_476_britain_foot_benne_conspiracy.c24"
const S_261 := "event.script.event_476_britain_foot_benne_conspiracy.c25"
const S_272_0 := "event.script.event_476_britain_foot_benne_conspiracy.c26"
const S_272_1 := "event.script.event_476_britain_foot_benne_conspiracy.c27"
const S_315 := "event.script.event_476_britain_foot_benne_conspiracy.c28"
const S_360 := "event.script.event_476_britain_foot_benne_conspiracy.c29"
const S_368 := "event.script.event_476_britain_foot_benne_conspiracy.c30"
const S_382 := "event.script.event_476_britain_foot_benne_conspiracy.c31"
const S_403 := "event.script.event_476_britain_foot_benne_conspiracy.c32"


## 原作 Event476.cs：富特-本恩阴谋论？/ 第二次卡布尔街之战（三选项）。 ## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1449-1451 —— ##   (data.britain_political_route==6 c92.SubGosstroy==18) && 日期>=1984.11.1。data.britain_political_route 无常量，走 trigger_script。 ## 差异： ##  - 标题/描述/选项显隐按 c92.sub 动态改写；load_scene_after_click → data.war_resolve=86 并 EventEngine.enqueue_chain(["event_018"])； ##  - parts[0]→_part/_set_part；cw→内战中；Vyshi→亲美；Torg→对华贸易；proprc→亲中；prosov→亲苏。


func evaluate(world: WorldState) -> bool:
	if world == null or world.size() <= 147:
		return false
	var c92 := world.get_country_by_legacy_index(92)
	if c92 == null:
		return false
	if not (world.britain_political_route == 6 or c92.sub_government == GameConstants.SubGovernment.TROTSKYIST):
		return false
	return (world.date.year >= 1984 and world.date.month >= 11) or world.date.year >= 1985


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var uk := world.get_country_by_legacy_index(92)
	var opt := event_def.options
	if uk != null and uk.sub_government == GameConstants.SubGovernment.TROTSKYIST:
		event_def.title = tr(S_21)
		event_def.description = tr(S_22)
		if not _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION) and _dval(world, W.I_POLITICAL_LINE) <= 2:
			_enable(opt[0], tr(S_45))
		else:
			_disable(opt[0], tr(S_50))
		_enable(opt[1], tr(S_52))
		_disable(opt[2], tr(S_54))
	else:
		event_def.title = tr(S_17)
		event_def.description = tr(S_18)
		var c21 := world.get_country_by_legacy_index(21)
		var num := 0
		for idx in [85, 86, 87]:
			var c := world.get_country_by_legacy_index(idx)
			if c != null and world.is_socialism(c, true):
				num += 1
		var ok := c21 != null and c21.has_tag("econ") and world.is_socialism(c21, true) \
				and num >= 2 and world.influence_prc >= 600 \
				and _dval(world, W.I_BUDGET) + _dval(world, W.I_RESERVE) >= 50 \
				and _dval(world, W.I_AGENTS) >= 100
		if ok:
			_enable(opt[0], tr(S_73))
		else:
			var dis := tr(S_98)
			if c21 != null and world.is_socialism(c21, false):
				dis = tr(S_78)
			elif c21 == null or not c21.has_tag("econ"):
				dis = tr(S_83)
			elif _dval(world, W.I_BUDGET) + _dval(world, W.I_RESERVE) < 50:
				dis = tr(S_88)
			elif _dval(world, W.I_AGENTS) < 100:
				dis = tr(S_93)
			_disable(opt[0], dis)
		_enable(opt[1], tr(S_100))
		if _dval(world, W.I_POLITICAL_LINE) <= 1:
			_enable(opt[2], tr(S_103))
		else:
			_disable(opt[2], tr(S_107))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uk := ws.get_country_by_legacy_index(92)
	var opt := int(context.get("option_index", -1))
	if uk != null and uk.sub_government != GameConstants.SubGovernment.TROTSKYIST:
		_execute_conspiracy(uk, opt, context)
	else:
		_execute_cable_street(uk, opt, context)


func _execute_conspiracy(uk: CountryData, opt: int, context: Dictionary) -> void:
	var c29 := ws.get_country_by_legacy_index(29)
	var c166 := ws.get_country_by_legacy_index(166)
	if opt == 0:
		var arg := tr(S_117_1) if (not _part(c29, 0) and not _part(c166, 0)) else ""
		var text := tr(S_117_0).replace("{0}", arg)
		uk.government = GameConstants.Government.SOCIALIST
		uk.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		uk.set_tag("对华贸易", true)
		uk.set_tag("亲中", true)
		ws.influence_prc += 50
		_add_relation(EmpireData.USA, -80)
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -100)
		_apply_uk_crisis()
		context["result_text"] = text
	elif opt == 1:
		var num := 0
		for idx in [85, 86, 87]:
			var c := ws.get_country_by_legacy_index(idx)
			if c != null and ws.is_socialism(c, true):
				num += 1
		var c7 := ws.get_country_by_legacy_index(7)
		var c0 := ws.get_country_by_legacy_index(0)
		if _empire_power(EmpireData.USA) <= _empire_power(EmpireData.USSR) \
				and (c7 == null or not c7.has_tag("nato")) and num >= 2:
			var arg := tr(S_174_1) if (not _part(c29, 0) and not _part(c166, 0)) else ""
			var text := tr(S_174_0).replace("{0}", arg)
			uk.government = GameConstants.Government.SOCIALIST
			uk.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			uk.set_tag("亲苏", true)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
				var leaders := ws.empires[EmpireData.USSR].leaders
				if leaders.size() > 4 and leaders[4] != null:
					leaders[4].support += 1
			_add_power(EmpireData.USSR, 50)
			_set_data(147, 8)
			_apply_uk_crisis()
			context["result_text"] = text
		else:
			var arg := tr(S_214_1) if not _part(c29, 0) else tr(S_214_2)
			var text := tr(S_214_0).replace("{0}", arg)
			uk.government = GameConstants.Government.AUTHORITARIAN
			uk.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			uk.set_tag("亲美", true)
			if c0 != null and c0.has_tag("nato"):
				uk.set_tag("nato", true)
			uk.set_tag("对华贸易", false)
			ws.influence_prc += 50
			_add_power(EmpireData.USA, 50)
			_set_data(147, 7)
			context["result_text"] = text
	elif opt == 2:
		var num := 0
		if ws.influence_prc >= _empire_power(EmpireData.USA):
			num += 1
		if _empire_power(EmpireData.USSR) >= _empire_power(EmpireData.USA):
			num += 1
		var c1 := ws.get_country_by_legacy_index(1)
		if c1 != null and c1.has_tag("okb"):
			num += 1
		if ws.is_socialism(ws.get_country_by_legacy_index(21), true):
			num += 2
		if ws.is_socialism(ws.get_country_by_legacy_index(86), true):
			num += 1
		if ws.is_socialism(ws.get_country_by_legacy_index(87), true):
			num += 1
		if ws.is_socialism(ws.get_country_by_legacy_index(17), true):
			num += 2
		if num < 5:
			uk.government = GameConstants.Government.AUTHORITARIAN
			uk.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			uk.set_tag("亲美", false)
			uk.set_tag("nato", false)
			uk.set_tag("eu", false)
			uk.set_tag("对华贸易", false)
			_add_power(EmpireData.USA, 50)
			_set_data(147, 9)
			context["result_text"] = tr(S_261)
		else:
			var arg := tr(S_272_1) if (not _part(c29, 0) and not _part(c166, 0)) else ""
			var text := tr(S_272_0).replace("{0}", arg)
			uk.government = GameConstants.Government.SOCIALIST
			uk.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			uk.set_tag("亲中", true)
			uk.set_tag("对华贸易", true)
			ws.influence_prc += 50
			_add_relation(EmpireData.USA, -80)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -100)
			if _part(c29, 0) or _part(c166, 0) or _war_going(86):
				if _war_going(86) and _raw(166) < 100:
					_enqueue_war_over_86()
				context["result_text"] = text
				return
			if _raw(165) > _raw(162) and _raw(165) > _raw(163) and _raw(165) > _raw(164) and _raw(165) > _raw(166):
				if _raw(165) < 100:
					_set_data(165, 100)
				_apply_ireland_takeover(c29, 0, 9, true)
				context["result_text"] = text
				return
			_apply_ireland_takeover(c29, 2, 3, false)
			context["result_text"] = text
	else:
		context["result_text"] = tr(S_54)


func _execute_cable_street(uk: CountryData, opt: int, context: Dictionary) -> void:
	if opt == 0:
		var num := 0
		if ws.influence_prc >= _empire_power(EmpireData.USA):
			num += 1
		if _empire_power(EmpireData.USSR) >= _empire_power(EmpireData.USA):
			num += 1
		var c1 := ws.get_country_by_legacy_index(1)
		if c1 != null and c1.has_tag("okb"):
			num += 1
		if uk != null and uk.has_tag("okb"):
			num += 1
		for c in ws.countries:
			if c != null and c.sub_government == GameConstants.SubGovernment.TROTSKYIST:
				num += 1
		if ws.is_socialism(ws.get_country_by_legacy_index(21), true):
			num += 2
		if ws.is_socialism(ws.get_country_by_legacy_index(86), true):
			num += 1
		if ws.is_socialism(ws.get_country_by_legacy_index(87), true):
			num += 1
		if ws.is_socialism(ws.get_country_by_legacy_index(17), true):
			num += 2
		if num >= 6:
			ws.influence_prc += 50
			_add_relation(EmpireData.USA, -80)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -100)
			context["result_text"] = tr(S_360)
		else:
			if uk != null:
				uk.government = GameConstants.Government.AUTHORITARIAN
				uk.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				uk.set_tag("亲美", false)
				uk.set_tag("nato", false)
				uk.set_tag("eu", false)
				uk.set_tag("对华贸易", false)
			ws.influence_prc += 50
			_add_power(EmpireData.USA, 50)
			_set_data(147, 9)
			context["result_text"] = tr(S_368)
	elif opt == 1:
		if uk != null:
			uk.government = GameConstants.Government.AUTHORITARIAN
			uk.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			uk.set_tag("亲美", false)
			uk.set_tag("nato", false)
			uk.set_tag("eu", false)
			uk.set_tag("对华贸易", false)
		_add_power(EmpireData.USA, 50)
		_set_data(147, 9)
		context["result_text"] = tr(S_382)
	else:
		context["result_text"] = tr(S_54)


func _apply_uk_crisis() -> void:
	var c29 := ws.get_country_by_legacy_index(29)
	var c166 := ws.get_country_by_legacy_index(166)
	if not _part(c29, 0) and not _part(c166, 0) and not _war_going(86):
		if _raw(165) > _raw(162) and _raw(165) > _raw(163) and _raw(165) > _raw(164) and _raw(165) > _raw(166):
			if _raw(165) < 100:
				_set_data(165, 100)
			_apply_ireland_takeover(c29, 0, 9, true)
		else:
			_apply_ireland_takeover(c29, 2, 3, false)
	elif _war_going(86) and _raw(166) < 100:
		_enqueue_war_over_86()


func _apply_ireland_takeover(c29: CountryData, gov: int, sub: int, vyshi: bool) -> void:
	if c29 == null:
		return
	c29.government = gov
	c29.sub_government = sub
	_set_part(c29, 0, true)
	_leave_alliances(c29)
	c29.set_tag("对华贸易", true)
	c29.内战中 = true
	if vyshi:
		c29.set_tag("亲美", true)


func _enqueue_war_over_86() -> void:
	_set_data(W.I_WAR_RESOLVE, 86)
	var war := _war(86)
	if war != null:
		war.infl1 = 1000
		war.infl2 = 0
	EventEngine.enqueue_chain(["event_018"])


func _war_going(idx: int) -> bool:
	var war := _war(idx)
	return war != null and war.is_going


func _war(idx: int) -> WarData:
	if idx >= 0 and idx < ws.wars.size():
		return ws.wars[idx]
	return null


func _dval(world: WorldState, idx: int) -> int:
	if world == null or world.size() <= idx:
		return 0
	return world.get_data_by_index(idx)


func _mod_active(world: WorldState, idx: int) -> bool:
	return world != null and idx >= 0 and idx < world.modifiers.size() \
			and world.modifiers[idx] != null and world.modifiers[idx].is_active


func _empire_power(idx: int) -> int:
	if ws.empires.size() > idx and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)


func _raw(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0




func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)






func _part(c: CountryData, i: int) -> bool:
	return c != null and c.parts.size() > i and c.parts[i]


func _set_part(c: CountryData, i: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= i:
		c.parts.append(false)
	c.parts[i] = value



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_476_britain_foot_benne_conspiracy.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_476",
	"num": 476,
	"priority": 47600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_476_britain_foot_benne_conspiracy.gd",
	"trigger_script": "res://数据脚本/事件效果/event_476_britain_foot_benne_conspiracy.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
