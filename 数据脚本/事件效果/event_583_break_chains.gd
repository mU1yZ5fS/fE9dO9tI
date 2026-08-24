extends "res://数据脚本/event_script_base.gd"

## 原作 Event583.cs：从今打碎暴虐的锁链（中非科林巴，四选项）。 ## 触发：ReqEventForDLC02.cs:824-827 —— c65.puppetOf==21 ##   && ((日>=3 且 月>=3 且 年>=1982) (月>=4 且 年>=1982) 年>=1983)。 ##   .tres = ALL(DATE_AFTER 1982.3.3, COUNTRY_FIELD_EQUALS target=65 key=puppet_of value=21)。 ## 差异： ##  - 描述按 resultOfEvents[582] 动态拼接（缺省按原版 int 默认 0）； ##  - science[24] → ws.techs.unlocked[24]；Torg → 对华贸易；proprc → 亲中；puppetOf → puppet_of。


const TXT_DESC_A := "event.script.event_583_break_chains.c0"
const TXT_DESC_WEAK := "event.script.event_583_break_chains.c1"
const TXT_DESC_STRONG := "event.script.event_583_break_chains.c2"
const TXT_DESC_TAIL := "event.script.event_583_break_chains.c3"

const TXT_OPT0_DIS := "event.script.event_583_break_chains.c4"
const TXT_OPT1_DIS := "event.script.event_583_break_chains.c5"
const TXT_OPT2_DIS := "event.script.event_583_break_chains.c6"

const TXT_R0 := "event.script.event_583_break_chains.c7"
const TXT_R1 := "event.script.event_583_break_chains.c8"
const TXT_R2 := "event.script.event_583_break_chains.c9"
const TXT_R3 := "event.script.event_583_break_chains.c10"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var r582 := int(world.completed_event_ids.get("event_582", 0))
	var desc := tr(TXT_DESC_A)
	if r582 != 1:
		desc += tr(TXT_DESC_WEAK)
	else:
		desc += tr(TXT_DESC_STRONG)
	desc += tr(TXT_DESC_TAIL)
	event_def.description = desc
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var c53 := world.get_country_by_legacy_index(53)
	var c52 := world.get_country_by_legacy_index(52)
	var opt := event_def.options
	if line <= 2 and world.influence_prc >= 500 and _tech(24) and c53 != null and c53.has_tag("对华贸易"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line <= 1 and world.influence_prc >= 500 and r582 == 1 and world.is_socialism(c52, true):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line > 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c65 := ws.get_country_by_legacy_index(65)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			if c65 != null:
				c65.government = GameConstants.Government.REFORMIST
				c65.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				_leave_alliances(c65)
				c65.set_tag("亲中", true)
				c65.set_tag("对华贸易", true)
			ws.influence_prc += 40
			_add(W.I_DIPLO, 15)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			if c65 != null:
				c65.government = GameConstants.Government.SOCIALIST
				c65.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c65)
				c65.set_tag("亲中", true)
				c65.set_tag("对华贸易", true)
				c65.chinese_name = "中非人民共和国"
			ws.influence_prc += 40
			_add(W.I_DIPLO, 15)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_AGENTS, -50)
			if c65 != null:
				c65.government = GameConstants.Government.AUTHORITARIAN
				c65.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(c65)
				c65.set_tag("对华贸易", true)
				c65.puppet_of = GameConstants.LegacySlot.FRANCE
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)


func _tech(idx: int) -> bool:
	return ws.techs != null and ws.techs.unlocked.size() > idx and ws.techs.unlocked[idx]



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_583_break_chains.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_583",
	"num": 583,
	"priority": 58300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_583_break_chains.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1982.3.3"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "puppet_of", "v": 21, "target": "65"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
