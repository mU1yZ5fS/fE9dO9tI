extends "res://数据脚本/event_script_base.gd"

const T_662_0 := "event.script.event_662_burma_red_moth.c0"
const T_662_1 := "event.script.event_662_burma_red_moth.c1"
const T_662_2 := "event.script.event_662_burma_red_moth.c2"
const T_662_3 := "event.script.event_662_burma_red_moth.c3"
const T_662_4 := "event.script.event_662_burma_red_moth.c4"
const T_662_5 := "event.script.event_662_burma_red_moth.c5"
const T_662_6 := "event.script.event_662_burma_red_moth.c6"
const T_662_7 := "event.script.event_662_burma_red_moth.c7"
const T_662_8 := "event.script.event_662_burma_red_moth.c8"
const T_662_9 := "event.script.event_662_burma_red_moth.c9"
const T_662_10 := "event.script.event_662_burma_red_moth.c10"
const T_662_11 := "event.script.event_662_burma_red_moth.c11"
const T_662_13 := "event.script.event_662_burma_red_moth.c12"
const T_662_14 := "event.script.event_662_burma_red_moth.c13"
const T_662_15 := "event.script.event_662_burma_red_moth.c14"
const T_662_16 := "event.script.event_662_burma_red_moth.c15"
const T_662_17 := "event.script.event_662_burma_red_moth.c16"
const T_662_18 := "event.script.event_662_burma_red_moth.c17"


## 原作 Event662.cs：红飞蛾，打破“四切”（缅甸，五选项）。 ## 触发：TimeScript.cs:11107-11112 —— allcountries[33].inflCh>=70 inflCh<40。 ## 差异： ##  - inflCh → CountryData.influence_china；ExprNode 暂不支持，触发走 trigger_script（本脚本 evaluate）。 ##  - <color=red> 标签剥除。 ##  - 死代码 result_num==5 跳过。

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var burma := world.get_country_by_legacy_index(33)
	if burma == null:
		return false
	return burma.influence_china >= 70 or burma.influence_china < 40


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	event_def.title = tr(T_662_0)
	event_def.description = tr(T_662_1)
	var opt := event_def.options
	var mod6_active := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active
	var mod3_active := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var burma := world.get_country_by_legacy_index(34)
	if mod6_active:
		_enable(opt[0], tr(T_662_2))
	else:
		_disable(opt[0], tr(T_662_3))
	if line > 0 or not mod6_active:
		_enable(opt[1], tr(T_662_4))
	else:
		_disable(opt[1], tr(T_662_5))
	if line > 1:
		_enable(opt[2], tr(T_662_6))
	else:
		_disable(opt[2], tr(T_662_7))
	if mod6_active and world.is_socialism(burma, true) and burma != null and burma.has_tag("亲中"):
		_enable(opt[3], tr(T_662_8))
	else:
		_disable(opt[3], tr(T_662_9))
	if not mod3_active:
		_enable(opt[4], tr(T_662_10))
	else:
		_disable(opt[4], tr(T_662_11))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var burma := ws.get_country_by_legacy_index(33)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if burma != null:
				burma.influence_china -= 30
			context["result_text"] = tr(T_662_14)
		1:
			if burma != null:
				burma.influence_china = 0
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, -40)
			context["result_text"] = tr(T_662_15)
		2:
			if burma != null:
				burma.set_tag("对华贸易", false)
			_add(W.I_AGENTS, -100)
			context["result_text"] = tr(T_662_16)
		3:
			if burma != null:
				burma.set_tag("对华贸易", false)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -200)
			if burma != null:
				burma.influence_china += 10
			context["result_text"] = tr(T_662_17)
		4:
			if burma != null:
				burma.set_tag("对华贸易", false)
			_add(W.I_AGENTS, -200)
			_add(W.I_ARMY, -200)
			context["result_text"] = tr(T_662_18)






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_662_burma_red_moth.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_662",
	"num": 662,
	"priority": 66200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_662_burma_red_moth.gd",
	"trigger_script": "res://数据脚本/事件效果/event_662_burma_red_moth.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
