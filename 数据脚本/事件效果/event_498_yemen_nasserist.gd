extends "res://数据脚本/event_script_base.gd"

const T_498_0 := "event.script.event_498_yemen_nasserist.c0"
const T_498_1 := "event.script.event_498_yemen_nasserist.c1"
const T_498_2 := "event.script.event_498_yemen_nasserist.c2"
const T_498_3 := "event.script.event_498_yemen_nasserist.c3"
const T_498_4 := "event.script.event_498_yemen_nasserist.c4"
const T_498_5 := "event.script.event_498_yemen_nasserist.c5"
const T_498_6 := "event.script.event_498_yemen_nasserist.c6"
const T_498_7 := "event.script.event_498_yemen_nasserist.c7"


## 原作 Event498.cs：也门最后的纳赛尔主义者？（北也门，两选项）。 ## 触发：TimeScript.cs:11142-11147 —— (日>=14 且 月>=6 且 年>=1978) (月>=7 且 年>=1978) 年>=1979。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	# 也门已统一时不再触发（双保险：配合 .tres 的 NOT_HAS_FLAG 守卫，防御手动 queue 绕过扫描条件）
	if ws != null and ws.get_flag("yemen_unified"):
		return
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	event_def.title = tr(T_498_0)
	event_def.description = tr(T_498_1)
	var opt := event_def.options
	if line <= 2:
		_enable(opt[0], tr(T_498_2))
	else:
		_disable(opt[0], tr(T_498_3))
	_enable(opt[1], tr(T_498_4))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var north_yemen := ws.get_country_by_legacy_index(25)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -30)
			if north_yemen != null:
				north_yemen.government = GameConstants.Government.REFORMIST
				north_yemen.sub_government = GameConstants.SubGovernment.PRAGMATIST
				north_yemen.set_tag("对华贸易", true)
				north_yemen.set_tag("亲中", true)
			_add_relation(EmpireData.USSR, -50)
			context["result_text"] = tr(T_498_6)
		1:
			if north_yemen != null:
				north_yemen.government = GameConstants.Government.AUTHORITARIAN
				north_yemen.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				north_yemen.set_tag("亲美", true)
			_add_power(EmpireData.USA, 20)
			context["result_text"] = tr(T_498_7)






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_498_yemen_nasserist.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_498",
	"num": 498,
	"priority": 49800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_498_yemen_nasserist.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.6.14"}, {"t": "NOT_HAS_FLAG", "key": "yemen_unified"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
