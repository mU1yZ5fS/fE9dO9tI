extends "res://数据脚本/event_script_base.gd"

## 原作 Event554.cs：埃及法老的终结（萨达特遇刺，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1554-1556 ——
##   event_done[37] && IsAuthoritarianism(30) && c30.Vyshi && (1981.10.6 或 1982+)。
## 差异：isSEV/isASEAN→has_tag；spec→special；Vyshi→亲美。

const TXT_OPT0_DIS := "event.script.event_554_egypt_pharaoh_end.c0"
const TXT_OPT1_DIS := "event.script.event_554_egypt_pharaoh_end.c1"
const TXT_OPT2_DIS := "event.script.event_554_egypt_pharaoh_end.c2"
const TXT_R0 := "event.script.event_554_egypt_pharaoh_end.c3"
const TXT_R1_A := "event.script.event_554_egypt_pharaoh_end.c4"
const TXT_R1_B := "event.script.event_554_egypt_pharaoh_end.c5"
const TXT_R2 := "event.script.event_554_egypt_pharaoh_end.c6"
const TXT_R3 := "event.script.event_554_egypt_pharaoh_end.c7"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var c8 := world.get_country_by_legacy_index(8)
	var r37 := int(ws.completed_event_ids.get("egyptian_unrest", 0))
	if ws.influence_prc >= 500 and d.war_support >= 600 and not ws.modifiers[3].is_active 			and c8 != null and c8.sub_government != GameConstants.SubGovernment.NEOPATRIARCHAL:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if (d.political_line < 2 and r37 == 2) or (d.political_line > 2 and r37 == 3):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if d.political_line > 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c1 := ws.get_country_by_legacy_index(1)
	var c30 := ws.get_country_by_legacy_index(30)
	var c51 := ws.get_country_by_legacy_index(51)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if c30 != null:
				c30.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				c30.government = GameConstants.Government.AUTHORITARIAN
				_leave_alliances(c30)
				c30.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 150)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			context["result_text"] = tr(TXT_R0)
		1:
			var r37 := int(ws.completed_event_ids.get("egyptian_unrest", 0))
			if r37 == 2:
				_add(W.I_BUDGET, -150)
				_add(W.I_AGENTS, -150)
				_add(W.I_ARMY, -150)
				if c30 != null:
					c30.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					c30.government = GameConstants.Government.SOCIALIST
					_leave_alliances(c30)
					c30.set_tag("亲中", true)
					c30.set_tag("对华贸易", true)
					if c1 != null and c1.has_tag("sev"):
						_leave_alliances(c30)
						c30.set_tag("sev", true)
						c30.set_tag("亲苏", true)
					if c1 != null and c1.has_tag("sev"):
						_add_relation(EmpireData.USSR, 50)
				_add(W.I_PARTY_SUPPORT, 100)
				_add(W.I_PEOPLE_SUPPORT, 150)
				ws.influence_prc += 25
				_add_relation(EmpireData.USSR, 150)
				_add_relation(EmpireData.USA, -250)
				_add(W.I_DIPLO, 50)
				context["result_text"] = tr(TXT_R1_A)
			else:
				_add(W.I_BUDGET, -150)
				_add(W.I_AGENTS, -150)
				_add(W.I_ARMY, -150)
				if c30 != null:
					c30.government = GameConstants.Government.LIBERAL
					c30.sub_government = GameConstants.SubGovernment.LIBERAL
					c30.set_tag("对华贸易", true)
					_leave_alliances(c30)
					c30.set_tag("亲中", true)
					if c1 != null and c1.has_tag("asean"):
						_leave_alliances(c30)
						if c51 != null and c51.内战中:
							c30.set_tag("asean", true)
							c30.set_tag("seato", true)
						else:
							c30.set_tag("sento", true)
						_add_relation(EmpireData.USA, 50)
						c30.set_tag("亲美", true)
				_add(W.I_PARTY_SUPPORT, 100)
				_add(W.I_PEOPLE_SUPPORT, 150)
				ws.influence_prc += 25
				_add_relation(EmpireData.USSR, -250)
				_add_relation(EmpireData.USA, 150)
				_add(W.I_DIPLO, -50)
				context["result_text"] = tr(TXT_R1_B)
		2:
			if c30 != null:
				c30.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				c30.government = GameConstants.Government.AUTHORITARIAN
				_leave_alliances(c30)
				c30.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_DIPLO, 50)
			context["result_text"] = tr(TXT_R2)
		3:
			if c30 != null:
				c30.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				c30.government = GameConstants.Government.AUTHORITARIAN
				_leave_alliances(c30)
				c30.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R3)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_554_egypt_pharaoh_end.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_554",
	"num": 554,
	"priority": 55400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_554_egypt_pharaoh_end.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "egyptian_unrest"}, {"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "government", "target": "30"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "target": "30"}]}, {"t": "COUNTRY_HAS_TAG", "key": "亲美", "target": "30"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1981.10.6"}, {"t": "DATE_AFTER", "key": "1981.11.1"}, {"t": "DATE_AFTER", "key": "1982.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
