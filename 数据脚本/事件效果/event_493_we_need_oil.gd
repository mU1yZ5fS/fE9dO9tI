extends "res://数据脚本/event_script_base.gd"

## 原作 Event493.cs：我们需要石油？（石油会战，五选项）。 ## 触发：ReqEventForDLC02.cs:1529-1531 —— ##   ((年>=1978 月>=10 日>=8) (年>=1978 月>=11) 年>=1979)。 ## 差异： ##  - data.budget+data.reserve → 预算+外汇（W.I_BUDGET + W.I_RESERVE）； ##  - data.loan 国债 → W.I_LOAN；OilProd 已建模（ws.oil_prod）按分支 +500/600/400/1000/400； ##  - result2 标题切换 → context["result_title"]。

const TXT_TITLE := "event.script.event_493_we_need_oil.c0"
const TXT_TITLE_DAQING := "event.script.event_493_we_need_oil.c1"


const TXT_OPT0_DIS := "event.script.event_493_we_need_oil.c2"
const TXT_OPT2_DIS_POOR := "event.script.event_493_we_need_oil.c3"
const TXT_OPT2_DIS_FAITH := "event.script.event_493_we_need_oil.c4"
const TXT_OPT3_DIS := "event.script.event_493_we_need_oil.c5"

const TXT_R0 := "event.script.event_493_we_need_oil.c6"

const TXT_R1_BEST := "event.script.event_493_we_need_oil.c7"

const TXT_R1_OK := "event.script.event_493_we_need_oil.c8"

const TXT_R2 := "event.script.event_493_we_need_oil.c9"

const TXT_R3 := "event.script.event_493_we_need_oil.c10"

const TXT_R4 := "event.script.event_493_we_need_oil.c11"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var budget := world.budget if world.size() > W.I_BUDGET else 0
	var reserve := world.reserve if world.size() > W.I_RESERVE else 0
	var money := budget + reserve
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var ussr_rel := 0
	var usa_rel := 0
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null:
		ussr_rel = world.empires[EmpireData.USSR].relations
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null:
		usa_rel = world.empires[EmpireData.USA].relations
	var opt := event_def.options
	if money >= 80:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	_enable(opt[1], event_def.options[1].text)
	if money >= 50 and mod3:
		_enable(opt[2], event_def.options[2].text)
	elif money < 50:
		_disable(opt[2], tr(TXT_OPT2_DIS_POOR))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS_FAITH))
	if ussr_rel >= 500 or usa_rel >= 500:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	context["result_title"] = tr(TXT_TITLE)
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -80)
			ws.oil_prod += 500.0  # Event493.cs result0
			context["result_text"] = tr(TXT_R0)
		1:
			var people := d.people_support if d.size() > W.I_PEOPLE_SUPPORT else 0
			var living := d.living_standard if d.size() > W.I_LIVING else 0
			var mod3 := ws.modifiers.size() > 3 and ws.modifiers[3] != null and ws.modifiers[3].is_active
			if (people >= 700 and living >= 600) or (people >= 500 and living >= 400 and mod3):
				_add(W.I_BUDGET, -5)
				_add(W.I_LIVING, -60)
				ws.oil_prod += 600.0  # Event493.cs result1 大庆超额300%
				context["result_text"] = tr(TXT_R1_BEST)
			else:
				_add(W.I_BUDGET, -5)
				_add(W.I_LIVING, -50)
				ws.oil_prod += 400.0  # Event493.cs result1 大庆超额143%
				context["result_text"] = tr(TXT_R1_OK)
		2:
			context["result_title"] = tr(TXT_TITLE_DAQING)
			_add(W.I_BUDGET, -50)
			_add(W.I_LIVING, -50)
			ws.oil_prod += 1000.0  # Event493.cs result2 大庆超额400%
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_LOAN, 50)
			if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null \
					and ws.empires[EmpireData.USA].relations >= 500:
				_add_relation(EmpireData.USA, -50)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
					and ws.empires[EmpireData.USSR].relations >= 500:
				_add_relation(EmpireData.USSR, -50)
			ws.oil_prod += 400.0  # Event493.cs result3
			context["result_text"] = tr(TXT_R3)
		4:
			context["result_text"] = tr(TXT_R4)






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_493_we_need_oil.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_493",
	"num": 493,
	"priority": 49300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_493_we_need_oil.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.10.8"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
