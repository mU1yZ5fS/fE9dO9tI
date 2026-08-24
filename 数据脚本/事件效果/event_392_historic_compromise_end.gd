extends "res://数据脚本/event_script_base.gd"

## 原作 Event392.cs：“历史性妥协”的终结？（莫罗绑架案，五选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - 按 resultOfEvents[391] 分流左翼/右翼文本；
##  - VasilyisGay → ws.set_flag("VasilyisGay", true)；
##  - data.italian_radical_left_power/data.italy_power_172/data.italy_power_175/data.italy_power_176/data.italy_power_177 为原版 raw index。

const TXT_DESC_FMT := "event.script.event_392_historic_compromise_end.c0"
const TXT_1072 := "event.script.historic_compromise_end.txt_1072"
const TXT_1073 := "event.script.historic_compromise_end.txt_1073"
const TXT_OPT1_LEFT := "event.script.historic_compromise_end.txt_opt1_left"
const TXT_OPT1_RIGHT := "event.script.historic_compromise_end.txt_opt1_right"
const TXT_DIS1 := "event.script.event_392_historic_compromise_end.c1"
const TXT_DIS4 := "event.script.event_392_historic_compromise_end.c2"
const TXT_R0_HEAD := "event.script.event_392_historic_compromise_end.c3"
const TXT_R0_LEFT := "event.script.event_392_historic_compromise_end.c4"
const TXT_R0_RIGHT := "event.script.event_392_historic_compromise_end.c5"
const TXT_R1_LEFT := "event.script.event_392_historic_compromise_end.c6"
const TXT_R1_RIGHT := "event.script.event_392_historic_compromise_end.c7"
const TXT_R2_HEAD := "event.script.event_392_historic_compromise_end.c8"
const TXT_R2_LEFT := "event.script.event_392_historic_compromise_end.c9"
const TXT_R2_RIGHT := "event.script.event_392_historic_compromise_end.c10"
const TXT_R3_HEAD := "event.script.event_392_historic_compromise_end.c11"
const TXT_R3_LEFT := "event.script.event_392_historic_compromise_end.c12"
const TXT_R3_RIGHT := "event.script.event_392_historic_compromise_end.c13"
const TXT_R4 := "event.script.event_392_historic_compromise_end.c14"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var r391 := int(world.completed_event_ids.get("event_391", 0))
	var kidnapper: String = tr(TXT_1072) if (r391 == 0 or r391 == 4 or r391 == 2) else tr(TXT_1073)
	event_def.description = tr(TXT_DESC_FMT).format(["\n", kidnapper])
	var italy := world.get_country_by_legacy_index(85)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if (r391 == 1 or r391 == 0 or r391 == 2) and _d(134) < 75 and italy != null and italy.level_of_development > 40:  # 原版 data.italian_radical_left_power
		var txt: String = tr(TXT_OPT1_LEFT) if (r391 == 0 or r391 == 4 or r391 == 2) else tr(TXT_OPT1_RIGHT)
		_enable(opt[1], txt)
	else:
		_disable(opt[1], tr(TXT_DIS1))
	_enable(opt[2], event_def.options[2].text)
	_enable(opt[3], event_def.options[3].text)
	if (r391 == 1 or r391 == 0 or r391 == 2) and _d(W.I_DIPLO) >= 900 and _d(134) >= 75 			and italy != null and italy.level_of_development <= 40:  # 原版 data.italian_radical_left_power
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], tr(TXT_DIS4))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var r391 := int(ws.completed_event_ids.get("event_391", 0))
	var left: bool = (r391 == 0 or r391 == 4 or r391 == 2)
	var italy := ws.get_country_by_legacy_index(85)
	var portugal := ws.get_country_by_legacy_index(87)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var txt := tr(TXT_R0_HEAD)
			if left:
				txt += tr(TXT_R0_LEFT)
				_add(172, -2)  # 原版 data.italy_power_172
				_add(176, -2)  # 原版 data.italy_power_176
				if italy != null and italy.内战中:
					_add(134, -20)  # 原版 data.italian_radical_left_power
			else:
				txt += tr(TXT_R0_RIGHT)
				_add(175, -2)  # 原版 data.italy_power_175
				_add(177, -1)  # 原版 data.italy_power_177
			if portugal != null:
				portugal.special -= 5
			context["result_text"] = txt
		1:
			if left:
				context["result_text"] = tr(TXT_R1_LEFT)
			else:
				context["result_text"] = tr(TXT_R1_RIGHT)
			_add(W.I_AGENTS, -90)
			ws.set_flag("VasilyisGay", true)
			if portugal != null:
				portugal.special += 5
			_add_relation(EmpireData.USSR, 80)
			_add_relation(EmpireData.USA, 80)
		2:
			var txt2 := tr(TXT_R2_HEAD)
			if left:
				txt2 += tr(TXT_R2_LEFT)
				_add(172, -2)  # 原版 data.italy_power_172
				_add(176, -2)  # 原版 data.italy_power_176
				if italy != null and italy.内战中:
					_add(134, -20)  # 原版 data.italian_radical_left_power
			else:
				txt2 += tr(TXT_R2_RIGHT)
				_add(175, -2)  # 原版 data.italy_power_175
				_add(177, -1)  # 原版 data.italy_power_177
			_add(W.I_DIPLO, 10)
			if portugal != null:
				portugal.special -= 5
			_add_relation(EmpireData.USA, -150)
			_add_power(EmpireData.USA, -15)
			_add_relation(EmpireData.USSR, 50)
			context["result_text"] = txt2
		3:
			var txt3 := tr(TXT_R3_HEAD)
			if left:
				txt3 += tr(TXT_R3_LEFT)
				_add(172, -2)  # 原版 data.italy_power_172
				_add(176, -2)  # 原版 data.italy_power_176
				if int(ws.completed_event_ids.get("event_291", 0)) != 4:
					_add(134, -20)  # 原版 data.italian_radical_left_power
			else:
				txt3 += tr(TXT_R3_RIGHT)
				_add(175, -2)  # 原版 data.italy_power_175
				_add(177, -1)  # 原版 data.italy_power_177
			_add_relation(EmpireData.USSR, -150)
			_add_power(EmpireData.USSR, -15)
			_add_relation(EmpireData.USA, 50)
			if portugal != null:
				portugal.special -= 5
			context["result_text"] = txt3
		_:
			context["result_text"] = tr(TXT_R4)
			_add(134, 20)  # 原版 data.italian_radical_left_power
			if italy != null:
				italy.level_of_development -= 10
			_add(W.I_ARMY, -50)
			_add(W.I_AGENTS, -100)
			if italy != null:
				italy.government = GameConstants.Government.AUTHORITARIAN
				italy.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			if portugal != null:
				portugal.special -= 15




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0










# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_392_historic_compromise_end.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_392",
	"num": 392,
	"priority": 39200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_392_historic_compromise_end.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
