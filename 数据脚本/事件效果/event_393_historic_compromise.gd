extends "res://数据脚本/event_script_base.gd"

## 原作 Event393.cs：历史性妥协（意大利“民族团结”政府，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - SOV_PRC_PartiesConnection → I_COMMUNICATIONS（见 event_435 约定）；
##  - 原版 iron_and_blood 成就 Set(121) 已接 Achievements。

const TXT_DIS1A := "event.script.event_393_historic_compromise.c0"
const TXT_DIS1B := "event.script.event_393_historic_compromise.c1"
const TXT_DIS2 := "event.script.event_393_historic_compromise.c2"
const TXT_R0 := "event.script.event_393_historic_compromise.c3"
const TXT_R1 := "event.script.event_393_historic_compromise.c4"
const TXT_R2 := "event.script.event_393_historic_compromise.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if _d(W.I_POLITICAL_LINE) >= 2 and _d(W.I_POLITICAL_LINE) <= 3 and world.influence_prc >= 250 			and _d(W.I_COMMUNICATIONS) >= 100:
		_enable(opt[1], event_def.options[1].text)
	elif world.influence_prc < 250 or _d(W.I_COMMUNICATIONS) < 100:
		_disable(opt[1], tr(TXT_DIS1A))
	else:
		_disable(opt[1], tr(TXT_DIS1B))
	var italy := world.get_country_by_legacy_index(85)
	if _d(W.I_POLITICAL_LINE) <= 2 and italy != null and (italy.内战中 or italy.政变中):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_DIS2))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	# 原作 Event393.cs:54：ResultsOfEvents 开头 iron_and_blood → achievements.Set(121)
	Achievements.set_achievement(121)
	var italy := ws.get_country_by_legacy_index(85)
	var portugal := ws.get_country_by_legacy_index(87)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add_power(EmpireData.USA, -15)
			_add_power(EmpireData.USSR, -15)
			if portugal != null:
				portugal.special += 10
			if italy != null:
				italy.sub_government = GameConstants.SubGovernment.LIBERAL
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -50)
			_add(175, -1)  # 原版 data.italy_power_175
			_add(176, 1)   # 原版 data.italy_power_176
			_add_power(EmpireData.USA, -15)
			_add_power(EmpireData.USSR, -15)
			if portugal != null:
				portugal.special += 10
			if italy != null:
				italy.sub_government = GameConstants.SubGovernment.LIBERAL
		_:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_BUDGET, -60)
			_add(W.I_AGENTS, -60)
			_add(173, 1)   # 原版 data.italy_power_173
			_add(175, -1)  # 原版 data.italy_power_175
			_add(176, -1)  # 原版 data.italy_power_176
			if italy != null:
				italy.level_of_development -= 5
			_add_power(EmpireData.USA, -15)
			_add_power(EmpireData.USSR, -15)
			if portugal != null:
				portugal.special += 10
			if italy != null:
				italy.sub_government = GameConstants.SubGovernment.LIBERAL




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0








# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_393_historic_compromise.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_393",
	"num": 393,
	"priority": 39300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_393_historic_compromise.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
