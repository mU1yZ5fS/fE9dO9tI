extends "res://数据脚本/event_script_base.gd"

## 原作 Event561.cs：不要期待我屈服（突尼斯加夫萨，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:347-349 ——
##   event_done[459] && resultOfEvents[459]>=2 && (1980.1.26 或 1980.2 或 1981+)。

const TXT_OPT0_DIS := "event.script.event_561_do_not_expect_me_to_yield.c0"
const TXT_OPT1_DIS := "event.script.event_561_do_not_expect_me_to_yield.c1"
const TXT_OPT2_DIS := "event.script.event_561_do_not_expect_me_to_yield.c2"
const TXT_R0 := "event.script.event_561_do_not_expect_me_to_yield.c3"
const TXT_R1 := "event.script.event_561_do_not_expect_me_to_yield.c4"
const TXT_R2 := "event.script.event_561_do_not_expect_me_to_yield.c5"
const TXT_R3 := "event.script.event_561_do_not_expect_me_to_yield.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var c40 := world.get_country_by_legacy_index(40)
	var c21 := world.get_country_by_legacy_index(21)
	var c55 := world.get_country_by_legacy_index(55)
	var line := d.political_line
	if line < 2 and c40 != null and c40.sub_government != GameConstants.SubGovernment.MODERATE and not c40.has_tag("亲美"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 0 and c21 != null and c21.has_tag("对华贸易") and c55 != null and c55.puppet_of == GameConstants.LegacySlot.FRANCE:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line > 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c13 := ws.get_country_by_legacy_index(13)
	var c55 := ws.get_country_by_legacy_index(55)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if c55 != null:
				c55.government = GameConstants.Government.AUTHORITARIAN
				c55.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				_leave_alliances(c55)
				c55.puppet_of = 13
				c55.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -20)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_DIPLO, 50)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -100)
			if c13 != null:
				c13.government = GameConstants.Government.AUTHORITARIAN
				c13.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(c13)
				c13.puppet_of = GameConstants.LegacySlot.FRANCE
				c13.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 80)
			_add_power(EmpireData.USA, 20)
			_add(W.I_AGENTS, -50)
			_add(W.I_DIPLO, -10)
			context["result_text"] = tr(TXT_R1)
		2:
			_add_relation(EmpireData.USA, 100)
			_add(W.I_DIPLO, -50)
			if c13 != null:
				c13.set_tag("对华贸易", false)
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_561_do_not_expect_me_to_yield.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_561",
	"num": 561,
	"priority": 56100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_561_do_not_expect_me_to_yield.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_459"}, {"t": "ANY", "c": [{"t": "PREV_EVENT_RESULT_IS", "v": 2, "ref": "event_459"}, {"t": "PREV_EVENT_RESULT_IS", "v": 3, "ref": "event_459"}]}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1980.1.26"}, {"t": "DATE_AFTER", "key": "1980.2.1"}, {"t": "DATE_AFTER", "key": "1981.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
