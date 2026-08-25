extends "res://数据脚本/event_script_base.gd"

## 原作 Event93.cs：民主的故乡——第一幕（希腊大选，三选项）。
## 触发：TimeScript.cs:10766-10772 —— (月>=11 且 年>=1977 或 年>=1978)。
## 差异：选项0/1 原版按 data.agents>=40 销毁按钮，prepare 动态改写。

const TXT_R0 := "event.script.event_093_greece_elections.c0"

const TXT_R1 := "event.script.event_093_greece_elections.c1"

const TXT_R2 := "event.script.event_093_greece_elections.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var agents := data.agents if data.size() > W.I_AGENTS else 0
	var opt := event_def.options
	if agents >= 40:
		_enable(opt[0], "帮助组建左翼联盟")
	else:
		_disable(opt[0], "我们没有足够的力量")
	if agents >= 40:
		_enable(opt[1], "支持新民主党")
	else:
		_disable(opt[1], "我们没有足够的力量")
	_enable(opt[2], "保持距离")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var greece := ws.get_country_by_legacy_index(45)
	var cyprus := ws.get_country_by_legacy_index(87)
	var cyprus2 := ws.get_country_by_legacy_index(94)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, 10)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, 50)
			if greece != null:
				greece.government = GameConstants.Government.REFORMIST
				greece.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				greece.set_tag("亲美", false)
				greece.set_tag("nato", false)
				if cyprus2 == null or not cyprus2.内战中:
					greece.set_tag("对华贸易", true)
				greece.内战中 = true
			if cyprus != null:
				cyprus.special -= 5
			_add_power(EmpireData.USA, -50)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_DIPLO, -10)
			_add_relation(EmpireData.USA, 80)
			_add_power(EmpireData.USA, 20)
			if cyprus != null:
				cyprus.special += 5
			context["result_text"] = tr(TXT_R1)
		2:
			_add_power(EmpireData.USA, 20)
			context["result_text"] = tr(TXT_R2)






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_093_greece_elections.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_093",
	"num": 93,
	"priority": 9300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_093_greece_elections.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1977.11.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
