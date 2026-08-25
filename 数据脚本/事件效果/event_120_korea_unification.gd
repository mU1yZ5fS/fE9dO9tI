extends "res://数据脚本/event_script_base.gd"

## 原作 Event120.cs：韩朝统一，不再分离（朝鲜半岛统一后领导人选择，4/6 选项动态）。
## 触发：全目录 grep 仅见 GlobalScript.cs:20 决策 StartEvent(120)，原版无自动条件
##   （决策/其他事件链手动触发），故 trigger_conditions=[]。
## 差异：
##  - allcountries[10].parts[0] 动态分支（6/4 选项）由 prepare 改写文本与 enable_condition；
##  - numberOfSpecialEnding→CountryData.special_ending；cw→内战中；
##  - JoinAllOurAlliances(true)/JoinOurEconomicAlliance(true) 按玩家联盟标签近似映射；
##  - 原版按钮销毁（parts[0] 分支隐藏 opt4/opt5）以置空文本+禁用来近似。

const TXT_DESC_SIX := "event.script.event_120_korea_unification.c0"
const TXT_DESC_UNIFIED := "event.script.event_120_korea_unification.c1"
const TXT_OPT1 := "event.script.event_120_korea_unification.c2"
const TXT_OPT2 := "event.script.event_120_korea_unification.c3"
const TXT_OPT3 := "event.script.event_120_korea_unification.c4"
const TXT_OPT4 := "event.script.event_120_korea_unification.c5"
const TXT_OPT5 := "event.script.event_120_korea_unification.c6"
const TXT_OPT6 := "event.script.event_120_korea_unification.c7"
const TXT_OPT7 := "event.script.event_120_korea_unification.c8"
const TXT_OPT8 := "event.script.event_120_korea_unification.c9"
const TXT_OPT9 := "event.script.event_120_korea_unification.c10"
const TXT_OPT10 := "event.script.event_120_korea_unification.c11"
const TXT_OPT11 := "event.script.event_120_korea_unification.c12"
const TXT_R0 := "event.script.event_120_korea_unification.c13"
const TXT_R1 := "event.script.event_120_korea_unification.c14"
const TXT_R2 := "event.script.event_120_korea_unification.c15"
const TXT_R3 := "event.script.event_120_korea_unification.c16"
const TXT_R4 := "event.script.event_120_korea_unification.c17"
const TXT_R5 := "event.script.event_120_korea_unification.c18"
const TXT_P0_OPT0 := "event.script.event_120_korea_unification.c19"
const TXT_P0_OPT1 := "event.script.event_120_korea_unification.c20"
const TXT_P0_OPT2 := "event.script.event_120_korea_unification.c21"
const TXT_P0_OPT3 := "event.script.event_120_korea_unification.c22"
const TXT_P0_OPT1_DIS := "event.script.event_120_korea_unification.c23"
const TXT_P0_OPT3_DIS := "event.script.event_120_korea_unification.c24"
const TXT_DEAD_EXIT := "event.script.event_120_korea_unification.c25"
const TXT_P0_R0 := "event.script.event_120_korea_unification.c26"
const TXT_P0_R1 := "event.script.event_120_korea_unification.c27"
const TXT_P0_R2 := "event.script.event_120_korea_unification.c28"
const TXT_P0_R3 := "event.script.event_120_korea_unification.c29"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 6:
		return
	var korea := world.get_country_by_legacy_index(10)
	var parts0 := korea != null and korea.parts.size() > 0 and korea.parts[0]
	var opt := event_def.options
	if parts0:
		event_def.description = tr(TXT_DESC_UNIFIED)
		_enable(opt[0], tr(TXT_P0_OPT0))
		if _res_at_least(world, W.I_AGENTS, 250) and _res_sum_at_least(world, W.I_BUDGET, W.I_RESERVE, 250):
			_enable(opt[1], tr(TXT_P0_OPT1))
		else:
			_disable(opt[1], tr(TXT_P0_OPT1_DIS).format([25]))
		_enable(opt[2], tr(TXT_P0_OPT2))
		if _res_at_least(world, W.I_AGENTS, 50) and not _mod_active(world, GameConstants.Modifier.MAOIST_BULWARK) and not _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION):
			_enable(opt[3], tr(TXT_P0_OPT3))
		else:
			_disable(opt[3], tr(TXT_P0_OPT3_DIS).format([5]))
		_disable(opt[4], "")
		_disable(opt[5], "")
	else:
		event_def.description = tr(TXT_DESC_SIX)
		if not _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION) and _data_value(world, W.I_POLITICAL_LINE) != 0:
			_enable(opt[0], event_def.options[0].text)
		else:
			_disable(opt[0], tr(TXT_OPT1))
		if not _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION) and _data_value(world, W.I_POLITICAL_LINE) > 1:
			_enable(opt[1], tr(TXT_OPT1))
		else:
			_disable(opt[1], tr(TXT_OPT3))
		if not _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION) and _data_value(world, W.I_POLITICAL_LINE) < 3:
			_enable(opt[2], tr(TXT_OPT2))
		else:
			_disable(opt[2], tr(TXT_OPT5))
		if _data_value(world, W.I_POLITICAL_LINE) < 2:
			_enable(opt[3], tr(TXT_OPT3))
		else:
			_disable(opt[3], tr(TXT_OPT7))
		if _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION) and _data_value(world, W.I_POLITICAL_LINE) < 3:
			_enable(opt[4], tr(TXT_OPT4))
		else:
			_disable(opt[4], tr(TXT_OPT9))
		if not _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION) and _data_value(world, W.I_POLITICAL_LINE) > 1:
			_enable(opt[5], tr(TXT_OPT5))
		else:
			_disable(opt[5], tr(TXT_OPT11))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var korea := ws.get_country_by_legacy_index(10)
	var parts0 := korea != null and korea.parts.size() > 0 and korea.parts[0]
	var opt := int(context.get("option_index", -1))
	if parts0:
		match opt:
			0:
				context["result_text"] = tr(TXT_P0_R0)
				_set_special(korea, 0)
			1:
				context["result_text"] = tr(TXT_P0_R1)
				_add(W.I_AGENTS, -250)
				_add(W.I_BUDGET, -250)
				_add(W.I_INFLUENCE, 5)
				_set_special(korea, 1)
				_join_our_alliances(korea)
			2:
				context["result_text"] = tr(TXT_P0_R2)
				_add(W.I_DIPLO, 50)
				_set_special(korea, 2)
			3:
				context["result_text"] = tr(TXT_P0_R3)
				_add(W.I_DIPLO, -50)
				_add(W.I_AGENTS, -50)
				_set_special(korea, 3)
				_join_economic_alliance(korea)
	else:
		_add(W.I_AGENTS, -100)
		_add(W.I_BUDGET, -100)
		ws.influence_prc += 10
		if korea != null:
			_set_parts0(korea)
			korea.special_ending = opt
			_join_our_alliances(korea)
			korea.内战中 = true
		match opt:
			0:
				context["result_text"] = tr(TXT_R0)
				if korea != null:
					korea.government = GameConstants.Government.REFORMIST
					korea.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
			1:
				context["result_text"] = tr(TXT_R1)
				if korea != null:
					korea.government = GameConstants.Government.REFORMIST
					korea.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			2:
				context["result_text"] = tr(TXT_R2)
				if korea != null:
					korea.government = GameConstants.Government.AUTHORITARIAN
					korea.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			3:
				context["result_text"] = tr(TXT_R3)
				if korea != null:
					korea.government = GameConstants.Government.SOCIALIST
					korea.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			4:
				context["result_text"] = tr(TXT_R4)
				if korea != null:
					korea.government = GameConstants.Government.SOCIALIST
					korea.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
			5:
				context["result_text"] = tr(TXT_R5)
				if korea != null:
					korea.government = GameConstants.Government.REFORMIST
					korea.sub_government = GameConstants.SubGovernment.TITOIST


func _set_special(c: CountryData, value: int) -> void:
	if c != null:
		c.special_ending = value


func _set_parts0(c: CountryData) -> void:
	if c == null:
		return
	if c.parts.size() == 0:
		c.parts.resize(1)
	c.parts[0] = true


## JoinAllOurAlliances(true)：复制玩家主要联盟标签（同 Event713 约定）。
func _join_our_alliances(c: CountryData) -> void:
	if c == null:
		return
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


## JoinOurEconomicAlliance(true)：仅经济联盟（同 Event650 约定）。
func _join_economic_alliance(c: CountryData) -> void:
	if c == null:
		return
	var player := ws.get_country_by_legacy_index(1)
	if player == null:
		return
	if player.has_tag("econ"):
		c.set_tag("econ", true)
	elif player.has_tag("sev"):
		c.set_tag("sev", true)


func _res_at_least(world: WorldState, index: int, threshold: int) -> bool:
	return world.size() > index and world.get_data_by_index(index) >= threshold


func _res_sum_at_least(world: WorldState, a: int, b: int, threshold: int) -> bool:
	var sum := 0
	if world.size() > a:
		sum += world.get_data_by_index(a)
	if world.size() > b:
		sum += world.get_data_by_index(b)
	return sum >= threshold


func _data_value(world: WorldState, index: int) -> int:
	if world.size() > index:
		return world.get_data_by_index(index)
	return 0


func _mod_active(world: WorldState, index: int) -> bool:
	return world.modifiers.size() > index and world.modifiers[index] != null and world.modifiers[index].is_active






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_120_korea_unification.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_120",
	"nodesc": true,
	"num": 120,
	"priority": 12000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_120_korea_unification.gd",
	"options": [{"disabled": true, "cond": {"t": "ALL", "c": [{"t": "MODIFIER_INACTIVE", "key": "3"}, {"t": "RESOURCE_NOT_EQUALS", "key": "political_line"}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "MODIFIER_INACTIVE", "key": "3"}, {"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 2}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "MODIFIER_INACTIVE", "key": "3"}, {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "MODIFIER_ACTIVE", "key": "3"}, {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "MODIFIER_INACTIVE", "key": "3"}, {"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 2}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
