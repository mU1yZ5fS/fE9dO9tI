extends "res://数据脚本/event_script_base.gd"

## 原作 Event701.cs：大白色北方（加拿大布局，五选项）。
## 触发：ReqEventsDLC02.cs:1561-1563 —— DATE_AFTER 1979.5.22 → trigger_script evaluate。
## 差异：Torg→对华贸易、proprc→亲中；c137=加拿大。

const TXT_OPT0_DIS := "event.script.event_701_great_white_north.c0"
const TXT_OPT1_DIS := "event.script.event_701_great_white_north.c1"
const TXT_OPT2_DIS := "event.script.event_701_great_white_north.c2"
const TXT_OPT3_DIS := "event.script.event_701_great_white_north.c3"
const TXT_R0_OK := "event.script.event_701_great_white_north.c4"
const TXT_R0_FAIL := "event.script.event_701_great_white_north.c5"
const TXT_R1 := "event.script.event_701_great_white_north.c6"
const TXT_R2 := "event.script.event_701_great_white_north.c7"
const TXT_R3 := "event.script.event_701_great_white_north.c8"
const TXT_R4 := "event.script.event_701_great_white_north.c9"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 5:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var opt := event_def.options
	if line > 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line <= 2 and ws.influence_prc >= 300:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line <= 2 and ws.influence_prc >= 300:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	var albania := ws.get_country_by_legacy_index(20)
	if line < 2 and ws.influence_prc >= 500 and albania != null and albania.has_tag("亲中"):
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if _res(W.I_DIPLO) < 500 or (ws.get_country_by_legacy_index(1) != null \
					and ws.get_country_by_legacy_index(1).government >= 2):
				context["result_text"] = tr(TXT_R0_OK)
				var canada := ws.get_country_by_legacy_index(137)
				if canada != null:
					canada.set_tag("对华贸易", true)
				_add(W.I_DIPLO, -10)
				_add(W.I_BUDGET, 30)
			else:
				context["result_text"] = tr(TXT_R0_FAIL)
				_add(W.I_PARTY_SUPPORT, -20)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -200)
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -150)
		3:
			context["result_text"] = tr(TXT_R3)
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -20)
		4:
			context["result_text"] = tr(TXT_R4)


func evaluate(world: WorldState) -> bool:
	return world != null and world.date != null and world.date.to_int() >= 19790522



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_701_great_white_north.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_701",
	"num": 701,
	"priority": 70100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_701_great_white_north.gd",
	"trigger_script": "res://数据脚本/事件效果/event_701_great_white_north.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
