extends "res://数据脚本/event_script_base.gd"

## 原作 Event440.cs：黎巴嫩，你可还好（4选项）。
## 触发：无自动触发点（trigger_conditions=[]）。DiploButtonScript.cs:11396-11399 this_type==1002 手动 number_event=440；3669 为外交按钮条件引用。
## 差异：选项显隐 prepare 动态改写；result 3 的 event_done[440]=false → completed_event_ids.erase("event_440")
##   （引擎会在选项执行后重新 _mark_done 当前事件，此重置仅作源码等价标记；手动触发走 can_trigger 不受影响）。



const TXT_OPT0_DIS := "event.script.event_440_lebanon_are_you_ok.c0"
const TXT_OPT1_DIS_0 := "event.script.event_440_lebanon_are_you_ok.c1"
const TXT_OPT1_DIS_ELSE := "event.script.event_440_lebanon_are_you_ok.c2"
const TXT_OPT2_DIS := "event.script.event_440_lebanon_are_you_ok.c3"

const TXT_R0 := "event.script.event_440_lebanon_are_you_ok.c4"
const TXT_R1 := "event.script.event_440_lebanon_are_you_ok.c5"
const TXT_R2 := "event.script.event_440_lebanon_are_you_ok.c6"
const TXT_R3 := "event.script.event_440_lebanon_are_you_ok.c7"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var syria := world.get_country_by_legacy_index(35)
	var opt := event_def.options
	if data.palestine_status >= 2 and syria != null and syria.has_tag("亲中"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if data.political_line >= 1 and data.political_line <= 2:
		_enable(opt[1], event_def.options[1].text)
	elif data.political_line == 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_0))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_ELSE))
	if data.political_line <= 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var lebanon := ws.get_country_by_legacy_index(93)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			ws.influence_prc += 20
			_add(W.I_AGENTS, -30)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -100)
			_add_power(EmpireData.USA, 20)
			_add_power(EmpireData.USSR, -20)
			if lebanon != null:
				lebanon.set_tag("对华贸易", true)
				lebanon.government = GameConstants.Government.LIBERAL
				lebanon.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -50)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			_add_power(EmpireData.USA, -20)
			_add_power(EmpireData.USSR, -20)
			if lebanon != null:
				lebanon.set_tag("对华贸易", true)
				lebanon.government = GameConstants.Government.REFORMIST
				lebanon.sub_government = GameConstants.SubGovernment.PRAGMATIST
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_AGENTS, -50)
			ws.influence_prc += 50
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
			_add_power(EmpireData.USA, -50)
			_add_power(EmpireData.USSR, -50)
			if lebanon != null:
				lebanon.set_tag("对华贸易", true)
				lebanon.set_tag("亲中", true)
				lebanon.government = GameConstants.Government.SOCIALIST
				lebanon.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
			context["result_text"] = tr(TXT_R2)
		3:
			ws.completed_event_ids.erase("event_440")
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_440_lebanon_are_you_ok.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_440",
	"num": 440,
	"priority": 44000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_440_lebanon_are_you_ok.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
