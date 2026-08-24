extends "res://数据脚本/event_script_base.gd"

## 原作 Event630.cs：新喀里多尼亚起义（单选项，按 event_done[483] 双文案双效果）。
## 触发：
##   - 自动：ReqEventsDLC02.cs:961-963 —— event_done[483] && c21.SubGosstroy!=19（.tres ExprNode）
##   - 手动：DiploButtonScript.cs:12139（1046，前置已扣 data.army/data.agents 各 100）
## 差异：原版 TextOfEvents/ResultsOfEvents 按 !event_done[483] 走“风暴”线，
##   483 已完成走“只消轻轻扇动翅膀”线；Godot prepare/execute 同判定。
##   Vyshi→亲美、proprc→亲中、Torg→对华贸易、puppetOf→puppet_of、name→chinese_name。

const TXT_TITLE_STORM := "event.script.event_630_new_caledonia_uprising.c0"
const TXT_DESC_STORM := "event.script.event_630_new_caledonia_uprising.c1"
const TXT_OPT_STORM := "event.script.event_630_new_caledonia_uprising.c2"
const TXT_R_STORM_OK := "event.script.event_630_new_caledonia_uprising.c3"
const TXT_R_STORM_FAIL := "event.script.event_630_new_caledonia_uprising.c4"

const TXT_TITLE_WINGS := "event.script.event_630_new_caledonia_uprising.c5"
const TXT_DESC_WINGS := "event.script.event_630_new_caledonia_uprising.c6"
const TXT_OPT_WINGS := "event.script.event_630_new_caledonia_uprising.c7"
const TXT_R_WINGS_BASE := "event.script.event_630_new_caledonia_uprising.c8"
const TXT_R_WINGS_SOC_TAIL := "event.script.event_630_new_caledonia_uprising.c9"
const TXT_R_WINGS_FR22 := "event.script.event_630_new_caledonia_uprising.c10"
const TXT_R_WINGS_FR_AUTH := "event.script.event_630_new_caledonia_uprising.c11"
const TXT_R_WINGS_AUS := "event.script.event_630_new_caledonia_uprising.c12"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.is_empty():
		return
	if ws.completed_event_ids.has("event_483"):
		event_def.title = tr(TXT_TITLE_WINGS)
		event_def.description = tr(TXT_DESC_WINGS)
		_enable(event_def.options[0], tr(TXT_OPT_WINGS))
	else:
		event_def.title = tr(TXT_TITLE_STORM)
		event_def.description = tr(TXT_DESC_STORM)
		_enable(event_def.options[0], tr(TXT_OPT_STORM))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var new_caledonia := ws.get_country_by_legacy_index(154)
	var france := ws.get_country_by_legacy_index(21)
	var australia := ws.get_country_by_legacy_index(135)
	if ws.completed_event_ids.has("event_483"):
		# 原版 :66-115：法国危机后路线分支
		var text := tr(TXT_R_WINGS_BASE)
		if ws.is_socialism(france, true):
			text += tr(TXT_R_WINGS_SOC_TAIL)
			if new_caledonia != null:
				new_caledonia.government = GameConstants.Government.SOCIALIST
				new_caledonia.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(new_caledonia)
				new_caledonia.chinese_name = "卡纳克人民共和国"
				new_caledonia.set_tag("亲中", true)
				new_caledonia.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add_power(EmpireData.USA, -10)
			_add_relation(EmpireData.USA, -70)
		elif france != null and france.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
			text = tr(TXT_R_WINGS_FR22)
			if new_caledonia != null:
				new_caledonia.government = GameConstants.Government.AUTHORITARIAN
				new_caledonia.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
				_leave_alliances(new_caledonia)
				new_caledonia.puppet_of = GameConstants.LegacySlot.FRANCE
				new_caledonia.chinese_name = "卡纳克人民国"
			_add_power(EmpireData.USA, 10)
		elif ws.is_authoritarian(france):
			text = tr(TXT_R_WINGS_FR_AUTH)
			if new_caledonia != null:
				new_caledonia.government = GameConstants.Government.REFORMIST
				new_caledonia.sub_government = GameConstants.SubGovernment.PRAGMATIST
				_leave_alliances(new_caledonia)
				new_caledonia.chinese_name = "卡纳克共和国"
			_add_power(EmpireData.USA, -10)
		if ws.is_authoritarian(australia):
			text = tr(TXT_R_WINGS_AUS)
			if new_caledonia != null:
				new_caledonia.government = GameConstants.Government.AUTHORITARIAN
				new_caledonia.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(new_caledonia)
				new_caledonia.puppet_of = GameConstants.LegacySlot.AUSTRALIA
				new_caledonia.chinese_name = "“卡纳克共和国”"
			_add_power(EmpireData.USA, 10)
		context["result_text"] = text
		return
	# 原版 :37-64：483 未完成的武装支援线
	if australia != null and australia.government != GameConstants.Government.AUTHORITARIAN:
		context["result_text"] = tr(TXT_R_STORM_OK)
		if new_caledonia != null:
			new_caledonia.government = GameConstants.Government.SOCIALIST
			new_caledonia.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			_leave_alliances(new_caledonia)
			new_caledonia.chinese_name = "卡纳克人民共和国"
			new_caledonia.set_tag("亲中", true)
			new_caledonia.set_tag("对华贸易", true)
		ws.influence_prc += 10
		_add_power(EmpireData.USA, -10)
		_add_relation(EmpireData.USA, -70)
		return
	context["result_text"] = tr(TXT_R_STORM_FAIL)
	if new_caledonia != null:
		new_caledonia.government = GameConstants.Government.AUTHORITARIAN
		new_caledonia.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		_leave_alliances(new_caledonia)
		new_caledonia.puppet_of = GameConstants.LegacySlot.AUSTRALIA
		new_caledonia.chinese_name = "卡纳克共和国"
	_add_power(EmpireData.USA, 10)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_630_new_caledonia_uprising.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_630",
	"nodesc": true,
	"num": 630,
	"priority": 63000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_630_new_caledonia_uprising.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "event_483"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "v": 19, "target": "21"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
