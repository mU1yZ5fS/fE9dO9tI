extends "res://数据脚本/event_script_base.gd"

## 原作 Event698.cs：圣地受难日（麦加大清真寺遇袭，三选项）。
## 触发：ReqEventsDLC02.cs:1334-1336 —— DATE_AFTER 1979.11.20 && c8.SubGosstroy!=13
##   → trigger_script evaluate（原版省略月份日条件等价于 1979.11.20 起）。

const TXT_OPT0_DIS := "event.script.event_698_holy_land_passion.c0"
const TXT_OPT1_DIS := "event.script.event_698_holy_land_passion.c1"
const TXT_R0 := "event.script.event_698_holy_land_passion.c2"
const TXT_R1 := "event.script.event_698_holy_land_passion.c3"
const TXT_R2 := "event.script.event_698_holy_land_passion.c4"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if _res(W.I_POLITICAL_LINE) != 0:
		_enable(opt[0], event_def.options[0].text)
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
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
	if world == null or world.date == null or world.date.to_int() < 19791120:
		return false
	var c8 := world.get_country_by_legacy_index(8)
	return c8 == null or c8.sub_government != GameConstants.SubGovernment.NEOPATRIARCHAL



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_698_holy_land_passion.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_698",
	"num": 698,
	"priority": 69800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_698_holy_land_passion.gd",
	"trigger_script": "res://数据脚本/事件效果/event_698_holy_land_passion.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
