extends "res://数据脚本/event_script_base.gd"

## 原作 Event442.cs：黑色九月所带来的（4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:527-530 —— Israellost 且（伊拉克/叙利亚 各满足 严格社会主义 或 SubGosstroy==10 或 Gosstroy==2）且 年>=1983（trigger_script 表达）。
## 差异：Israellost 同时认 israellost / israel_lost_lebanon_war 两个旗标；Gosstroy/SubGosstroy→government/sub_government；
##   Torg→对华贸易、proprc→亲中；选项显隐 prepare 动态改写。



const TXT_OPT0_DIS := "event.script.event_442_black_september.c0"
const TXT_OPT1_DIS_0 := "event.script.event_442_black_september.c1"
const TXT_OPT1_DIS_ELSE := "event.script.event_442_black_september.c2"
const TXT_OPT2_DIS := "event.script.event_442_black_september.c3"

const TXT_R0 := "event.script.event_442_black_september.c4"
const TXT_R1 := "event.script.event_442_black_september.c5"
const TXT_R2 := "event.script.event_442_black_september.c6"
const TXT_R3 := "event.script.event_442_black_september.c7"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world
	if data.size() <= W.I_YEAR:
		return false
	if data.year < 1983:
		return false
	if not (world.get_flag("israellost") or world.get_flag("israel_lost_lebanon_war")):
		return false
	var iraq := world.get_country_by_legacy_index(14)
	var syria := world.get_country_by_legacy_index(35)
	if iraq == null or syria == null:
		return false
	var iraq_ok := world.is_socialism(iraq, true) or iraq.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or iraq.government == GameConstants.Government.REFORMIST
	var syria_ok := world.is_socialism(syria, true) or syria.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or syria.government == GameConstants.Government.REFORMIST
	return iraq_ok and syria_ok


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var iraq := world.get_country_by_legacy_index(14)
	var syria := world.get_country_by_legacy_index(35)
	var ethiopia := world.get_country_by_legacy_index(41)
	var opt := event_def.options
	if data.political_line >= 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if data.political_line >= 1 and data.political_line < 3 \
			and ((iraq != null and iraq.government == GameConstants.Government.REFORMIST) or (syria != null and syria.government == GameConstants.Government.REFORMIST)):
		_enable(opt[1], event_def.options[1].text)
	elif data.political_line == 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_0))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_ELSE))
	if data.political_line < 2 \
			and (world.is_socialism(iraq, true) or world.is_socialism(syria, true) or world.is_socialism(ethiopia, true)):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var jordan := ws.get_country_by_legacy_index(104)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -30)
			if jordan != null:
				jordan.government = GameConstants.Government.LIBERAL
				jordan.sub_government = GameConstants.SubGovernment.MODERATE
				jordan.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -150)
			_add_power(EmpireData.USA, -5)
			ws.influence_prc += 10
			context["result_text"] = tr(TXT_R0)
		1:
			if jordan != null:
				jordan.government = GameConstants.Government.REFORMIST
				jordan.sub_government = GameConstants.SubGovernment.PRAGMATIST
				jordan.set_tag("对华贸易", true)
			ws.influence_prc += 20
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -50)
			if jordan != null:
				jordan.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, -5)
			context["result_text"] = tr(TXT_R1)
		2:
			if jordan != null:
				jordan.government = GameConstants.Government.SOCIALIST
				if _modifier_active(6):
					jordan.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				else:
					jordan.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				jordan.set_tag("对华贸易", true)
				jordan.set_tag("亲中", true)
			ws.influence_prc += 25
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -50)
			_add_relation(EmpireData.USA, -150)
			_add_power(EmpireData.USA, -20)
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)




func _disable_blank(opt: EventOption) -> void:
	opt.disabled_text = ""
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n








func _modifier_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active


func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_442_black_september.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_442",
	"num": 442,
	"priority": 44200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_442_black_september.gd",
	"trigger_script": "res://数据脚本/事件效果/event_442_black_september.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
