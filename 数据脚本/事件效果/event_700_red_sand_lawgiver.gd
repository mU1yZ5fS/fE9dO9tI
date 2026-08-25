extends "res://数据脚本/event_script_base.gd"

## 原作 Event700.cs：红沙的立法者（沙特改革尾声，三选项，仅由 Event699 结果链触发）。
## 触发：Event699.cs:71 load_scene_after_click + number_event=700 → Godot enqueue_chain 入队。
## 差异：LeaveAlliances→_leave_alliances；Torg→对华贸易、proprc→亲中；OilProd→ws.oil_prod。

const TXT_OPT0_DIS := "event.script.event_700_red_sand_lawgiver.c0"
const TXT_OPT1_DIS := "event.script.event_700_red_sand_lawgiver.c1"
const TXT_R0 := "event.script.event_700_red_sand_lawgiver.c2"
const TXT_R1 := "event.script.event_700_red_sand_lawgiver.c3"
const TXT_R2 := "event.script.event_700_red_sand_lawgiver.c4"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var opt := event_def.options
	if line >= 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var saudi := ws.get_country_by_legacy_index(101)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if saudi != null:
				_leave_alliances(saudi)
				saudi.government = GameConstants.Government.LIBERAL
				saudi.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				saudi.set_tag("对华贸易", true)
				saudi.set_tag("亲中", true)
			ws.oil_prod += 100.0
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if saudi != null:
				_leave_alliances(saudi)
				saudi.government = GameConstants.Government.REFORMIST
				saudi.sub_government = GameConstants.SubGovernment.PRAGMATIST
				saudi.set_tag("对华贸易", true)
				saudi.set_tag("亲中", true)
			ws.oil_prod += 100.0
		2:
			context["result_text"] = tr(TXT_R2)
			if saudi != null:
				_leave_alliances(saudi)
				saudi.government = GameConstants.Government.AUTHORITARIAN
				saudi.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				saudi.set_tag("对华贸易", true)




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_700_red_sand_lawgiver.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_700",
	"num": 700,
	"priority": 70000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_700_red_sand_lawgiver.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
