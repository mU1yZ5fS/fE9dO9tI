extends "res://数据脚本/event_script_base.gd"

## 原作 Event486.cs：德意志之秋（西德红军旅/K小组，三选项）。 ## 触发：ReqEventForDLC02.cs:1499-1501 —— ##   ((年>=1977 月>=10 日>=17) (年>=1977 月>=11) 年>=1978)。 ## 差异： ##  - data.political_line 政治路线 → W.I_POLITICAL_LINE；proprc/Torg/econ/okb → set_tag； ##  - result1 的 data.albania_break==0 分支按原版 int 默认 0 处理。



const TXT_OPT0_DIS_NOPRO := "event.script.event_486_german_autumn.c0"
const TXT_OPT0_DIS_LINE := "event.script.event_486_german_autumn.c1"
const TXT_OPT1_DIS := "event.script.event_486_german_autumn.c2"

const TXT_R0 := "event.script.event_486_german_autumn.c3"

const TXT_R1 := "event.script.event_486_german_autumn.c4"

const TXT_R2 := "event.script.event_486_german_autumn.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var line := world.political_line if world.size() > W.I_POLITICAL_LINE else 1
	var albania := world.get_country_by_legacy_index(20)
	var albania_pro := albania != null and albania.has_tag("亲中")
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var opt := event_def.options
	if line <= 1 and albania_pro:
		_enable(opt[0], event_def.options[0].text)
	elif not albania_pro:
		_disable(opt[0], tr(TXT_OPT0_DIS_NOPRO))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS_LINE))
	if line > 2 and not mod3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var west_germany := ws.get_country_by_legacy_index(17)
	var albania := ws.get_country_by_legacy_index(20)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -50)
			ws.influence_prc += 10
			_add_relation(EmpireData.USA, -80)
			_add_power(EmpireData.USA, -20)
			_add_power(EmpireData.USSR, 50)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -30)
			ws.influence_prc += 5
			_add_power(EmpireData.USA, 50)
			_add_power(EmpireData.USSR, -20)
			ws.influence_prc -= 20
			if west_germany != null:
				west_germany.set_tag("对华贸易", true)
			# data.albania_break：原版中阿决裂状态（无常量），raw index + 注释。
			if d.size() > 60 and d.albania_break == 0:
				if albania != null:
					albania.set_tag("亲中", false)
					albania.set_tag("econ", false)
					albania.set_tag("对华贸易", false)
					albania.set_tag("okb", false)
			_add_relation(EmpireData.USA, 50)
			_add(W.I_BUDGET, 50)
			_add(W.I_SCIENCE, 200)
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_486_german_autumn.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_486",
	"num": 486,
	"priority": 48600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_486_german_autumn.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1977.10.17"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
