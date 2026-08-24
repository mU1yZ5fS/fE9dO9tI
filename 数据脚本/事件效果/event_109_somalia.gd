extends "res://数据脚本/event_script_base.gd"

## 原作 Event109.cs：索马里的黄金时代（巴雷政变风波，三选项）。 ## 触发：TimeScript.cs:10959-10965 —— ##   !c42.parts[0] && !c42.parts[2]（端口建模说明→恒真）&& !wars[15].is_going ##   && ((日>=9 且 月>=4 且 年>=1978) (月>=5 且 年>=1978) 年>=1979)。 ## 差异：选项0/1 按 agents/influence 动态显隐；<color> 标签去除； ##   EstablishGovernment(ProChina) → set_tag("亲中", true)。

const TXT_R0 := "event.script.event_109_somalia.c0"

const TXT_R1 := "event.script.event_109_somalia.c1"

const TXT_R2 := "event.script.event_109_somalia.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var agents := data.agents if data.size() > W.I_AGENTS else 0
	var opt := event_def.options
	if agents >= 50 and world.influence_prc >= 200:
		_enable(opt[0], "尽全力支持他们的政变")
	else:
		_disable(opt[0], "我们不能帮助索马里")
	if agents >= 80 and world.influence_prc >= 200:
		_enable(opt[1], "通过给苏联泼脏水，换取巴雷的谅解")
	else:
		_disable(opt[1], "我们可没有余力关注这件事")
	_enable(opt[2], "什么都不做")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var somalia := ws.get_country_by_legacy_index(42)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			_add(W.I_BUDGET, -80)
			_add_power(EmpireData.USSR, 5)
			ws.influence_prc += 5
			_add(W.I_DIPLO, -10)
			_add_relation(EmpireData.USSR, 50)
			_add_relation(EmpireData.USA, -50)
			if somalia != null:
				somalia.set_tag("亲中", true)
				somalia.set_tag("亲苏", false)
				somalia.set_tag("对华贸易", true)
				somalia.government = GameConstants.Government.SOCIALIST
				somalia.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			_add(W.I_BUDGET, -50)
			_add_relation(EmpireData.USSR, -70)
			_add_relation(EmpireData.USA, -70)
			ws.influence_prc += 20
			_add(W.I_DIPLO, 30)
			if somalia != null:
				somalia.set_tag("亲中", true)
				somalia.set_tag("亲苏", false)
				somalia.set_tag("对华贸易", true)
				somalia.government = GameConstants.Government.AUTHORITARIAN
				somalia.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_109_somalia.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_109",
	"num": 109,
	"priority": 10900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_109_somalia.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1978.4.9"}, {"t": "NOT", "c": [{"t": "WAR_ACTIVE", "v": 15}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
