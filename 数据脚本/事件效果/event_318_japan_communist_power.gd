extends "res://数据脚本/event_script_base.gd"

## 原作 Event318.cs：我们的势力会在日本掌权吗？（3选项）。
## 触发：全目录搜索无 this_num_event = 318 / Reset(318) / StartEvent(318)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：选项显隐 prepare 动态改写；Gosstroy/SubGosstroy→government/sub_government；name→chinese_name；proprc/Vyshi→亲中/亲美标签。

const TXT_NAME_EMPIRE := "event.script.event_318_japan_communist_power.c0"
const TXT_NAME_RED := "event.script.event_318_japan_communist_power.c1"
const TXT_OPT1_DIS := "event.script.event_318_japan_communist_power.c2"
const TXT_OPT2_DIS := "event.script.event_318_japan_communist_power.c3"
const TXT_R0 := "event.script.event_318_japan_communist_power.c4"
const TXT_R1 := "event.script.event_318_japan_communist_power.c5"
const TXT_R2 := "event.script.event_318_japan_communist_power.c6"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	if data.size() <= W.I_RELIGION:
		return
	var opt := event_def.options
	var japan := world.get_country_by_legacy_index(44)
	_enable(opt[0], event_def.options[0].text)
	if japan != null and japan.government < 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if data.war_support >= 700 or (data.ideology <= 0 and data.religion_policy > 27 and data.econ_system > 11):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_DIPLO, 100)
			_add(W.I_INFLUENCE, 100)
			_add_power(0, -100)
			_add_relation(0, -500)
			var japan := ws.get_country_by_legacy_index(44)
			if japan != null:
				japan.government = GameConstants.Government.SOCIALIST
				japan.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				japan.chinese_name = tr(TXT_NAME_RED)
				japan.set_tag("亲中", true)
				japan.set_tag("亲美", false)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -150)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_DIPLO, 50)
			_add(W.I_INFLUENCE, 100)
			_add_power(0, -100)
			_add_relation(0, -500)
			var japan := ws.get_country_by_legacy_index(44)
			if japan != null:
				japan.government = GameConstants.Government.AUTHORITARIAN
				japan.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				japan.chinese_name = tr(TXT_NAME_EMPIRE)
				japan.set_tag("亲中", true)
				japan.set_tag("亲美", false)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -150)
			context["result_text"] = tr(TXT_R2)

	




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_318_japan_communist_power.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_318",
	"num": 318,
	"priority": 31800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_318_japan_communist_power.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
