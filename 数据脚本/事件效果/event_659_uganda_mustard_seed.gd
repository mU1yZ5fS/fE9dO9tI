extends "res://数据脚本/event_script_base.gd"

const T_659_0 := "event.script.event_659_uganda_mustard_seed.c0"
const T_659_1 := "event.script.event_659_uganda_mustard_seed.c1"
const T_659_2 := "event.script.event_659_uganda_mustard_seed.c2"
const T_659_3 := "event.script.event_659_uganda_mustard_seed.c3"
const T_659_4 := "event.script.event_659_uganda_mustard_seed.c4"
const T_659_5 := "event.script.event_659_uganda_mustard_seed.c5"
const T_659_6 := "event.script.event_659_uganda_mustard_seed.c6"
const T_659_7 := "event.script.event_659_uganda_mustard_seed.c7"
const T_659_8 := "event.script.event_659_uganda_mustard_seed.c8"
const T_659_9 := "event.script.event_659_uganda_mustard_seed.c9"
const T_659_10 := "event.script.event_659_uganda_mustard_seed.c10"
const T_659_12 := "event.script.event_659_uganda_mustard_seed.c11"
const T_659_13 := "event.script.event_659_uganda_mustard_seed.c12"
const T_659_14 := "event.script.event_659_uganda_mustard_seed.c13"
const T_659_15 := "event.script.event_659_uganda_mustard_seed.c14"
const T_659_16 := "event.script.event_659_uganda_mustard_seed.c15"
const T_659_17 := "event.script.event_659_uganda_mustard_seed.c16"


## 原作 Event659.cs：播撒芥菜籽（乌干达，五选项）。 ## 触发：TimeScript.cs:11093-11098 —— (日>=20 且 月>=2 且 年>=1981) (月>=3 且 年>=1981) 年>=1982。 ## 差异： ##  - ResultsOfEvents 顶部公共效果（乌干达政体/影响力赋值）全部移植。 ##  - 死代码 result_num==5 跳过。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	var zaire := world.get_country_by_legacy_index(117)
	var opt := event_def.options
	event_def.title = tr(T_659_0)
	event_def.description = tr(T_659_1)
	_enable(opt[0], tr(T_659_2))
	if line <= 3:
		_enable(opt[1], tr(T_659_3))
	else:
		_disable(opt[1], tr(T_659_4))
	if line <= 3:
		_enable(opt[2], tr(T_659_5))
	else:
		_disable(opt[2], tr(T_659_6))
	if zaire != null and zaire.has_tag("对华贸易"):
		_enable(opt[3], tr(T_659_7))
	else:
		_disable(opt[3], tr(T_659_8))
	if line >= 3:
		_enable(opt[4], tr(T_659_9))
	else:
		_disable(opt[4], tr(T_659_10))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uganda := ws.get_country_by_legacy_index(118)
	if uganda != null:
		uganda.influence_nato = 800
		uganda.influence_china = 50
		uganda.prc_influence = 100
		uganda.sov_influence = 50
		uganda.government = GameConstants.Government.AUTHORITARIAN
		uganda.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(T_659_13)
		1:
			if uganda != null:
				uganda.set_tag("对华贸易", true)
			context["result_text"] = tr(T_659_14)
		2:
			context["result_text"] = tr(T_659_15)
		3:
			context["result_text"] = tr(T_659_16)
		4:
			context["result_text"] = tr(T_659_17)






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_659_uganda_mustard_seed.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_659",
	"num": 659,
	"priority": 65900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_659_uganda_mustard_seed.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1981.2.20"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
