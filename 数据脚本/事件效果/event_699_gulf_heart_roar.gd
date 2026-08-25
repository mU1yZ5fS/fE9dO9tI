extends "res://数据脚本/event_script_base.gd"

## 原作 Event699.cs：海湾之心的怒吼（沙特东部省什叶派起义，三选项）。
## 触发：ReqEventsDLC02.cs:1339-1341 —— ev698 && DATE_AFTER 1979.11.26 && c8.SubGosstroy!=13
##   → trigger_script evaluate。
## 差异：result0 的 load_scene_after_click+number_event=700 → EventEngine.enqueue_chain(["event_700"])。

const TXT_OPT0_DIS := "event.script.event_699_gulf_heart_roar.c0"
const TXT_OPT1_DIS := "event.script.event_699_gulf_heart_roar.c1"
const TXT_R0 := "event.script.event_699_gulf_heart_roar.c2"
const TXT_R1 := "event.script.event_699_gulf_heart_roar.c3"
const TXT_R2 := "event.script.event_699_gulf_heart_roar.c4"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if ws.result_of_event_num(698) == 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if (_res(W.I_POLITICAL_LINE) > 2 or _res(W.I_DIPLO) < 800) \
			and ws.result_of_event_num(698) != 0:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -70)
			_add_relation(EmpireData.USA, -100)
			EventEngine.enqueue_chain(["event_700"])
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_ARMY, -50)
			_add(W.I_AGENTS, -50)
			_add_relation(EmpireData.USA, 100)
			var saudi := ws.get_country_by_legacy_index(101)
			if saudi != null:
				saudi.set_tag("对华贸易", true)
			ws.oil_prod += 100.0
			_add(W.I_BUDGET, 100)
		2:
			context["result_text"] = tr(TXT_R2)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19791126:
		return false
	if not world.event_done_num(698):
		return false
	var c8 := world.get_country_by_legacy_index(8)
	return c8 == null or c8.sub_government != GameConstants.SubGovernment.NEOPATRIARCHAL



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_699_gulf_heart_roar.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_699",
	"num": 699,
	"priority": 69900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_699_gulf_heart_roar.gd",
	"trigger_script": "res://数据脚本/事件效果/event_699_gulf_heart_roar.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
