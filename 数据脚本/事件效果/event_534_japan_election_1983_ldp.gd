extends "res://数据脚本/event_script_base.gd"

## 原作 Event534.cs：保革伯仲：第三幕（自民党优势线，3选项）。 ## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:297-299 —— ##   (event_done[527] event_done[528]) && !event_done[536] && c44.puppetOf<0 ##   && c44.SubGosstroy==6 && (1983.10 或 1984+)。 ## 差异：resultOfEvents 缺省按原版 int 默认 0 处理；isSocEU→has_tag("soc_eu")。

const TXT_OPT0_DIS := "event.script.event_534_japan_election_1983_ldp.c0"
const TXT_OPT1_A := "event.script.event_534_japan_election_1983_ldp.c1"
const TXT_OPT1_B := "event.script.event_534_japan_election_1983_ldp.c2"
const TXT_OPT1_DIS := "event.script.event_534_japan_election_1983_ldp.c3"
const TXT_R0 := "event.script.event_534_japan_election_1983_ldp.c4"
const TXT_R1_A := "event.script.japan_election_1983_ldp.txt_r1_a"
const TXT_R1_B := "event.script.japan_election_1983_ldp.txt_r1_b"
const TXT_R1_SOCEU := "event.script.japan_election_1983_ldp.txt_r1_soceu"
const TXT_R2 := "event.script.event_534_japan_election_1983_ldp.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var r529 := int(ws.completed_event_ids.get("event_529", 0))
	var r530 := int(ws.completed_event_ids.get("event_530", 0))
	if r529 == 0 and ws.completed_event_ids.has("event_529"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if r530 == 0:
		_enable(opt[1], tr(TXT_OPT1_A))
	elif r530 == 1:
		_enable(opt[1], tr(TXT_OPT1_B))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c44 := ws.get_country_by_legacy_index(44)
	var c21 := ws.get_country_by_legacy_index(21)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if c44 != null:
				c44.government = GameConstants.Government.LIBERAL
				c44.sub_government = GameConstants.SubGovernment.MODERATE
				c44.set_tag("亲美", false)
				c44.set_tag("亲中", true)
				c44.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, 150)
			_add(W.I_DIPLO, -20)
			ws.influence_prc += 50
			_add_relation(EmpireData.USSR, -150)
			_add_relation(EmpireData.USA, 150)
			_add_power(EmpireData.USA, 30)
			_add_power(EmpireData.USSR, -30)
			context["result_text"] = tr(TXT_R0)
		1:
			var r530 := int(ws.completed_event_ids.get("event_530", 0))
			if r530 == 0:
				if c44 != null:
					c44.government = GameConstants.Government.LIBERAL
					c44.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
					c44.set_tag("亲美", false)
					c44.set_tag("亲中", true)
					c44.set_tag("对华贸易", true)
				_add(W.I_BUDGET, -100)
				_add(W.I_AGENTS, -100)
				_add(W.I_PARTY_SUPPORT, 150)
				_add(W.I_PEOPLE_SUPPORT, 150)
				_add(W.I_DIPLO, -20)
				ws.influence_prc += 50
				_add_relation(EmpireData.USA, -150)
				_add_power(EmpireData.USA, -30)
				context["result_text"] = tr(TXT_R1_A)
			else:
				var text := tr(TXT_R1_B)
				if c21 != null and c21.has_tag("soc_eu"):
					text += tr(TXT_R1_SOCEU)
					if c44 != null:
						_leave_alliances(c44)
						c44.set_tag("soc_eu", true)
				if c44 != null:
					c44.government = GameConstants.Government.REFORMIST
					c44.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
					c44.set_tag("亲美", false)
					c44.set_tag("亲中", true)
					c44.set_tag("对华贸易", true)
				_add(W.I_BUDGET, -200)
				_add(W.I_AGENTS, -200)
				_add(W.I_PARTY_SUPPORT, 150)
				_add(W.I_PEOPLE_SUPPORT, 150)
				_add(W.I_DIPLO, -20)
				ws.influence_prc += 50
				_add_relation(EmpireData.USA, -150)
				_add_power(EmpireData.USA, -30)
				context["result_text"] = text
		2:
			if c44 != null:
				c44.government = GameConstants.Government.LIBERAL
				c44.sub_government = GameConstants.SubGovernment.LIBERAL
				c44.set_tag("亲美", true)
				c44.set_tag("亲中", false)
			_add_power(EmpireData.USA, 50)
			context["result_text"] = tr(TXT_R2)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_534_japan_election_1983_ldp.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_534",
	"num": 534,
	"priority": 53400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_534_japan_election_1983_ldp.gd",
	"trigger": [{"t": "COUNTRY_FIELD_AT_MOST", "key": "puppet_of", "v": -1, "target": "44"}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_536"}, {"t": "ANY", "c": [{"t": "PREV_EVENT_DONE", "ref": "event_527"}, {"t": "PREV_EVENT_DONE", "ref": "event_528"}]}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 6, "target": "44"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1983.10.1"}, {"t": "DATE_AFTER", "key": "1984.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
