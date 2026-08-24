extends "res://数据脚本/event_script_base.gd"

## 原作 Event677.cs：“暗影五号”爆炸案（北爱尔兰路线，六选项）。
## 触发：ReqEventsDLC02.cs:1456-1459 —— !ev673 && DATE_AFTER 1979.8.27。
## 差异：data.org_strength_1/[163]/[164]/[165]/[166] 无命名常量，按原版 raw index 读写；
##   Torg→对华贸易；{0}{1} 领袖姓名 → ws.leader.name_display。

const TXT_OPT0_DIS := "event.script.event_677_shadow_five.c0"
const TXT_OPT1_DIS := "event.script.event_677_shadow_five.c1"
const TXT_OPT2_DIS := "event.script.event_677_shadow_five.c2"
const TXT_OPT4_DIS := "event.script.event_677_shadow_five.c3"
const TXT_R0 := "event.script.event_677_shadow_five.c4"
const TXT_R1_FMT := "event.script.event_677_shadow_five.c5"
const TXT_R2 := "event.script.event_677_shadow_five.c6"
const TXT_R3 := "event.script.event_677_shadow_five.c7"
const TXT_R4 := "event.script.event_677_shadow_five.c8"
const TXT_R5 := "event.script.event_677_shadow_five.c9"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 6:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var mod6 := ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	var opt := event_def.options
	if line <= 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line <= 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line <= 1 and mod6:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)
	if line <= 1:
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], tr(TXT_OPT4_DIS))
	_enable(opt[5], event_def.options[5].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uk := ws.get_country_by_legacy_index(92)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -30)
			ws.influence_prc += 10
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			_add_power(EmpireData.USSR, 10)
			_add(W.I_DIPLO, 50)
			_add_raw(162, 10)
			if uk != null:
				uk.set_tag("对华贸易", false)
		1:
			context["result_text"] = tr(TXT_R1_FMT).replace("{0}{1}", _leader_name())
			_add(W.I_ARMY, -80)
			_add(W.I_BUDGET, -30)
			ws.influence_prc += 10
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			_add(W.I_DIPLO, 100)
			_add_raw(163, 10)
			if uk != null:
				uk.set_tag("对华贸易", false)
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_ARMY, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -50)
			ws.influence_prc += 15
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_DIPLO, 80)
			_add_raw(164, 10)
			if uk != null:
				uk.set_tag("对华贸易", false)
		3:
			context["result_text"] = tr(TXT_R3)
			_add(W.I_BUDGET, -50)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -150)
			_add_raw(165, 10)
			_add(W.I_DIPLO, 100)
		4:
			context["result_text"] = tr(TXT_R4)
			_add(W.I_ARMY, -100)
			_add(W.I_BUDGET, -100)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
			_add(W.I_DIPLO, 100)
			_add_raw(166, 5)
			if uk != null:
				uk.set_tag("对华贸易", false)
		5:
			context["result_text"] = tr(TXT_R5)


func _add_raw(idx: int, delta: int) -> void:
	while d.size() <= idx:
		d.append(0)
	d.add_data_by_index(idx, delta)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_677_shadow_five.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_677",
	"num": 677,
	"priority": 67700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_677_shadow_five.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.8.27"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
