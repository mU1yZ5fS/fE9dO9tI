extends "res://数据脚本/event_script_base.gd"

## 原作 Event648.cs：代号太白（金星探测，三选项）。 ## 触发：ReqEventsDLC02.cs:102-104 —— y>=1983 && ((r361!=2 && ev361) r362==1) && science[16] ##   复合条件 → trigger_script evaluate。 ## 差异：原版选项1置 resultOfEvents[648]=2 → Godot context["result_index_override"]=2。

const TXT_OPT0_DIS := "event.script.event_648_taibai.c0"
const TXT_R0 := "event.script.event_648_taibai.c1"
const TXT_R1 := "event.script.event_648_taibai.c2"
const TXT_R1_FAIL := "event.script.event_648_taibai.c3"
const TXT_R2 := "event.script.event_648_taibai.c4"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var ussr_rel := ws.empires[EmpireData.USSR].relations if ws.empires.size() > EmpireData.USSR \
		and ws.empires[EmpireData.USSR] != null else 0
	var opt := event_def.options
	if ussr_rel >= 500:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	_enable(opt[1], event_def.options[1].text)
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 200)
			_add(W.I_AGENTS, -100)
			_add(W.I_INDUSTRY, -300)
			_add(W.I_BUDGET, -160)
		1:
			var text := tr(TXT_R1)
			if _res(W.I_INDUSTRY) < 1200:
				text += tr(TXT_R1_FAIL)
				_add(W.I_BUDGET, -100)
				_add(W.I_PEOPLE_SUPPORT, -300)
				_add(W.I_PARTY_SUPPORT, -200)
			context["result_text"] = text
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 200)
			_add(W.I_AGENTS, -100)
			_add(W.I_INDUSTRY, -200)
			_add(W.I_BUDGET, -80)
			# 原版 :61 resultOfEvents[648]=2 context["result_index_override"] = 2 2: context["result_text"] = tr(TXT_R2)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.year < 1983:
		return false
	if not _tech_on(world, 16):
		return false
	var r361 := int(world.completed_event_ids.get("event_361", 0))
	var r362 := int(world.completed_event_ids.get("event_362", 0))
	return (world.completed_event_ids.has("event_361") and r361 != 2) or r362 == 1


func _tech_on(world: WorldState, idx: int) -> bool:
	return world.techs != null and idx >= 0 and idx < world.techs.unlocked.size() and world.techs.unlocked[idx]



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_648_taibai.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_648",
	"num": 648,
	"priority": 64800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_648_taibai.gd",
	"trigger_script": "res://数据脚本/事件效果/event_648_taibai.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
