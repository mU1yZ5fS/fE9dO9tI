extends "res://数据脚本/event_script_base.gd"

## 原作 Event661.cs：战争结束了（乌干达内战结算，单选项）。 ## 触发：TimeScript.cs:1900-1910（event_done[659] && !war81.is_going && 乌干达 inflNATO>=1000） ##   与 TimeScript.cs:7094-7098（WarCheck(81)：war81.is_going && data.war_resolve<0 && ##   (fortnight_go>=fortnight_max infl1>=1000 infl2>=1000)）。 ##   本项目 war81 未录入 WarCatalog，实际以乌干达 influence_nato 路径为主； ##   trigger_script = 本脚本 evaluate()。 ## 差异： ##  - resultOfEvents[659] 用 completed_event_ids.get("event_659", 0) 对齐原版缺省 0； ##  - event_done[660]→completed_event_ids.has("event_660")； ##  - empires[1].relations=-250→clampi；LeaveAlliances→_leave_alliances； ##  - proprc/Torg/Vyshi→set_tag("亲中"/"对华贸易"/"亲美")；name→chinese_name； ##  - 死代码 result_num==5 跳过。

const TXT_DESC_1 := "event.script.event_661_uganda_war_over.c0"
const TXT_DESC_2 := "event.script.event_661_uganda_war_over.c1"
const TXT_R0 := "event.script.event_661_uganda_war_over.c2"
const TXT_R0_DONE660 := "event.script.event_661_uganda_war_over.c3"
const TXT_R0_PRORPC := "event.script.event_661_uganda_war_over.c4"
const TXT_R0_LIBERAL := "event.script.event_661_uganda_war_over.c5"
const TXT_R0_AMIN := "event.script.event_661_uganda_war_over.c6"
const TXT_R0_FEDERAL_PRE := "event.script.event_661_uganda_war_over.c7"
const TXT_R0_FEDERAL := "event.script.event_661_uganda_war_over.c8"
const TXT_UGANDA_FEDERATION := "event.script.event_661_uganda_war_over.c9"
const TXT_R0_DEMOCRAT := "event.script.event_661_uganda_war_over.c10"
const TXT_R0_ELSE := "event.script.event_661_uganda_war_over.c11"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var war := _get_war(world, 81)
	var war_name := war.name_war if (war != null and war.name_war != "") else "乌干达内战"
	event_def.description = tr(TXT_DESC_1) + war_name + tr(TXT_DESC_2)


## 复杂触发钩子（EventDef.trigger_script 调用）。
func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var war81 := _get_war(world, 81)
	var uganda := world.get_country_by_legacy_index(118)
	# TimeScript.cs:1900-1910：乌干达北约影响>=1000 提前触发（原版同时写 data.war_resolve=81）
	if world.completed_event_ids.has("event_659") and (war81 == null or not war81.is_going) and uganda != null and uganda.influence_nato >= 1000:
		return true
	# TimeScript.cs:7094-7098 / GameState.WarCheck(81)
	if war81 != null and war81.is_going and world.size() > W.I_WAR_RESOLVE and world.war_resolve < 0:
		if war81.fortnight_elapsed >= war81.fortnight_max or war81.infl1 >= 1000 or war81.infl2 >= 1000:
			return true
	return false


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uganda := ws.get_country_by_legacy_index(118)
	var war81 := _get_war(ws, 81)
	# 原版 ResultsOfEvents 顶部公共效果
	if war81 != null:
		war81.is_going = false
	if uganda != null:
		_set_parts0(uganda, false)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		if war81 != null and war81.infl2 >= 900:
			if not ws.completed_event_ids.has("event_660"):
				context["result_text"] = tr(TXT_R0)
				if ws.completed_event_ids.get("event_659", 0) == 1 and uganda != null:
					uganda.set_tag("亲中", true)
			else:
				context["result_text"] = tr(TXT_R0_DONE660)
				if uganda != null:
					uganda.government = GameConstants.Government.AUTHORITARIAN
					uganda.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
					_leave_alliances(uganda)
					uganda.set_tag("亲美", true)
		elif ws.completed_event_ids.get("event_659", 0) == 2:
			if uganda != null:
				_leave_alliances(uganda)
				uganda.set_tag("亲中", true)
				uganda.set_tag("对华贸易", true)
			if _mod_active(ws, GameConstants.Modifier.MAOIST_BULWARK):
				context["result_text"] = tr(TXT_R0_PRORPC)
				if uganda != null:
					uganda.government = GameConstants.Government.SOCIALIST
					uganda.sub_government = GameConstants.SubGovernment.MAOIST
			else:
				context["result_text"] = tr(TXT_R0_LIBERAL)
				if uganda != null:
					uganda.government = GameConstants.Government.REFORMIST
					uganda.sub_government = GameConstants.SubGovernment.PRAGMATIST
		elif ws.completed_event_ids.get("event_659", 0) == 3:
			context["result_text"] = tr(TXT_R0_AMIN)
			if uganda != null:
				_leave_alliances(uganda)
				uganda.puppet_of = 117
				uganda.set_tag("对华贸易", true)
				uganda.government = GameConstants.Government.AUTHORITARIAN
				uganda.sub_government = GameConstants.SubGovernment.NEO_FASCIST
		elif ws.completed_event_ids.get("event_659", 0) == 4:
			var num := 0
			num += _count_liberal_or_auth(127)
			num += _count_liberal_or_auth(126)
			num += _count_liberal_or_auth(123)
			num += _count_liberal_or_auth(122)
			num += _count_liberal_or_auth(124)
			var text := tr(TXT_R0_FEDERAL_PRE)
			if num >= 2:
				text += tr(TXT_R0_FEDERAL)
				if uganda != null:
					_leave_alliances(uganda)
					uganda.set_tag("亲美", true)
					uganda.set_tag("对华贸易", true)
					uganda.government = GameConstants.Government.LIBERAL
					uganda.sub_government = GameConstants.SubGovernment.NEOLIBERAL
					uganda.chinese_name = tr(TXT_UGANDA_FEDERATION)
			else:
				text += tr(TXT_R0_DEMOCRAT)
				if uganda != null:
					_leave_alliances(uganda)
					uganda.set_tag("对华贸易", true)
					uganda.government = GameConstants.Government.LIBERAL
					uganda.sub_government = GameConstants.SubGovernment.MODERATE
			context["result_text"] = text
		else:
			context["result_text"] = tr(TXT_R0_ELSE)
			if uganda != null:
				uganda.government = GameConstants.Government.REFORMIST
				uganda.sub_government = GameConstants.SubGovernment.PRAGMATIST


func _get_war(world: WorldState, war_id: int) -> WarData:
	if world == null or war_id < 0 or war_id >= world.wars.size():
		return null
	return world.wars[war_id]


func _count_liberal_or_auth(legacy_index: int) -> int:
	var c := ws.get_country_by_legacy_index(legacy_index)
	if c == null:
		return 0
	return 1 if (c.government == GameConstants.Government.LIBERAL or ws.is_authoritarian(c)) else 0


func _set_parts0(c: CountryData, value: bool) -> void:
	if c == null:
		return
	if c.parts.size() == 0:
		c.parts.resize(1)
	c.parts[0] = value


## Country.LeaveAlliances() 逐项映射（同 Event713 约定）。

func _mod_active(world: WorldState, index: int) -> bool:
	return world.modifiers.size() > index and world.modifiers[index] != null and world.modifiers[index].is_active



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_661_uganda_war_over.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_661",
	"nodesc": true,
	"num": 661,
	"priority": 66100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_661_uganda_war_over.gd",
	"trigger_script": "res://数据脚本/事件效果/event_661_uganda_war_over.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
