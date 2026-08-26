extends "res://数据脚本/event_script_base.gd"

## 原作 Event438.cs：脆弱的革命（2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:37-40 —— modifies[3] 且 modifies[6]，且（意识形态>=4 或 经济体制>=14 或 舆论政策>=19 或 宗教>26 或 政党制度>=8），且（!event_444 或 resultOfEvents[444]!=0），且 !event_503（.tres ExprNode 表达）。
## 差异：描述由 prepare 按 data.party_system/[16]/[17]/[50] 动态拼接；politic.traits[0]→trait_personality；
##   loyality→loyalty；modifies[3]→ws.modifiers[3].is_active。


const TXT_DESC_BASE := "event.script.event_438_fragile_revolution.c0"
const TXT_DESC_PARTY := "event.script.event_438_fragile_revolution.c1"
const TXT_DESC_ECON := "event.script.event_438_fragile_revolution.c2"
const TXT_DESC_SPEECH := "event.script.event_438_fragile_revolution.c3"
const TXT_DESC_RELIGION := "event.script.event_438_fragile_revolution.c4"
const TXT_DESC_TAIL := "event.script.event_438_fragile_revolution.c5"


const TXT_R0 := "event.script.event_438_fragile_revolution.c6"
const TXT_R1 := "event.script.event_438_fragile_revolution.c7"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null:
		return
	var data := world
	var desc := tr(TXT_DESC_BASE)
	if data.size() > W.I_PARTY_SYSTEM and data.party_system >= GameConstants.PartySystem.PEOPLE_DEMOCRACY:
		desc += tr(TXT_DESC_PARTY)
	if data.size() > W.I_ECON_SYSTEM and data.econ_system >= 14:
		desc += tr(TXT_DESC_ECON)
	if data.size() > W.I_PRESS_POLICY and data.press_policy >= 19:
		desc += tr(TXT_DESC_SPEECH)
	if data.size() > W.I_RELIGION and data.religion_policy >= 27:
		desc += tr(TXT_DESC_RELIGION)
	desc += tr(TXT_DESC_TAIL)
	event_def.description = desc
	if event_def.options.size() >= 2:
		_enable(event_def.options[0], event_def.options[0].text)
		_enable(event_def.options[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if ws.modifiers.size() > 3 and ws.modifiers[3] != null:
				ws.modifiers[3].is_active = false
			_add(W.I_THOUGHT_FREEDOM, 200)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_DIPLO, -10)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 100
				elif p.trait_personality > GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty += 100
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_THOUGHT_FREEDOM, 150)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_DIPLO, 10)
			var num := 0
			if d.party_system >= GameConstants.PartySystem.PEOPLE_DEMOCRACY:
				d.party_system = GameConstants.PartySystem.NEW_DEMOCRACY
				num += 1
			if d.econ_system >= 14:
				d.econ_system = 13
				num += 1
			if d.press_policy >= 19:
				d.press_policy = 18
				num += 1
			if d.religion_policy >= 27:
				d.religion_policy = 26
				num += 1
			if d.ideology >= 4:
				d.ideology = 3
			_add(W.I_BUDGET, -num * 10)
			context["result_text"] = tr(TXT_R1)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_438_fragile_revolution.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_438",
	"nodesc": true,
	"num": 438,
	"priority": 43800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_438_fragile_revolution.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "MODIFIER_ACTIVE", "key": "3"}, {"t": "MODIFIER_ACTIVE", "key": "6"}, {"t": "ANY", "c": [{"t": "RESOURCE_AT_LEAST", "key": "ideology", "v": 4}, {"t": "RESOURCE_AT_LEAST", "key": "economy_system", "v": 14}, {"t": "RESOURCE_AT_LEAST", "key": "speech_policy", "v": 19}, {"t": "RESOURCE_AT_LEAST", "key": "religion_policy", "v": 27}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}, {"t": "ANY", "c": [{"t": "PREV_EVENT_NOT_DONE", "ref": "event_444"}, {"t": "NOT", "c": [{"t": "PREV_EVENT_RESULT_IS", "ref": "event_444"}]}]}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_503"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
