extends "res://数据脚本/event_script_base.gd"

## 原作 Event325.cs：高铁？（3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:559-562 —— 日>=23 月>=6 年>=1982。
## 差异：选项显隐 prepare 动态改写；modifies[35].active→_set_mod_active(35,true)；文本来自 Events_text_en 索引 223-232。

const TXT_OPT1_DIS := "event.script.event_325_high_speed_rail.c0"
const TXT_OPT2_DIS := "event.script.event_325_high_speed_rail.c1"
const TXT_R0 := "event.script.event_325_high_speed_rail.c2"
const TXT_R1 := "event.script.event_325_high_speed_rail.c3"
const TXT_R2 := "event.script.event_325_high_speed_rail.c4"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	if data.size() <= W.I_RESERVE:
		return
	var opt := event_def.options
	var br := data.budget + data.reserve
	_enable(opt[0], event_def.options[0].text)
	if br >= 40 and data.industry > 60:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if br >= 110 and data.industry > 80:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -150)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -30)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_INFLUENCE, 5)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_INFLUENCE, 5)
			_add(W.I_BUDGET, -100)
			_set_mod_active(35, true)
			context["result_text"] = tr(TXT_R2)

	


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_325_high_speed_rail.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_325",
	"num": 325,
	"priority": 32500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_325_high_speed_rail.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1982.6.23"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
