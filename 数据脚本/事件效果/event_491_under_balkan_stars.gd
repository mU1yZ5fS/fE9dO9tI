extends "res://数据脚本/event_script_base.gd"

## 原作 Event491.cs：在巴尔干的繁星下（保加利亚佩塔尔事件，二选项）。 ## 触发：ReqEventForDLC02.cs:1519-1521 —— ##   c6.SubGosstroy==16 && ((年>=1982 月>=11 日>=17) (年>=1982 月>=12) 年>=1983)。 ## 差异：cw → 内战中。




const TXT_R0 := "event.script.event_491_under_balkan_stars.c0"

const TXT_R1 := "event.script.event_491_under_balkan_stars.c1"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var bulgaria := ws.get_country_by_legacy_index(6)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			if bulgaria != null:
				bulgaria.内战中 = true
			_add_relation(EmpireData.USSR, -50)
			ws.influence_prc += 5
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)





# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_491_under_balkan_stars.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_491",
	"num": 491,
	"priority": 49100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_491_under_balkan_stars.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 16, "target": "6"}, {"t": "DATE_AFTER", "key": "1982.11.17"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
