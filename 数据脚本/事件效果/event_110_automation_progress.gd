extends "res://数据脚本/event_script_base.gd"

## 原作 Event110.cs：自动化的缓慢进展（四选项）。
## 触发：TimeScript.cs:10966-10972 —— 年>=1980 && !modifies[12].active
##   && science[15] && data.econ_system<=11。
## 差异：relres → global flag；modifies[17] → modifiers[17].is_active。

const TXT_R0 := "event.script.event_110_automation_progress.c0"

const TXT_R1 := "event.script.event_110_automation_progress.c1"

const TXT_R2 := "event.script.event_110_automation_progress.c2"

const TXT_R3 := "event.script.event_110_automation_progress.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var dip := data.diplomatic_reputation if data.size() > W.I_DIPLO else 0
	var china := world.get_country_by_legacy_index(1)
	var ussr_rel := world.empires[EmpireData.USSR].relations if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null else 0
	var usa_rel := world.empires[EmpireData.USA].relations if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null else 0
	var mod17 := world.modifiers.size() > 17 and world.modifiers[17] != null and world.modifiers[17].is_active
	var opt := event_def.options
	_enable(opt[0], "让我们再等几年……或者更久……")
	_enable(opt[1], "宣布一门关于生产自动化的课题，并设立一个委员会来实施它(需要10百万预算)")
	if ussr_rel >= 500 and world.get_flag("relres") and china != null and china.has_tag("sev"):
		_enable(opt[2], "开始自动化和邀请苏联科学家")
	else:
		_disable(opt[2], "苏维埃不会帮助我们")
	if usa_rel >= 600 and dip <= 800 and china != null \
			and not china.has_tag("sev") and not china.has_tag("okb") and not mod17:
		_enable(opt[3], "我们准备工作了，西方专家会帮助我们的！")
	else:
		_disable(opt[3], "向西方求助？你是认真的吗？")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add(W.I_PARTY_SUPPORT, -600)
			if d.size() > 118:
				d.automation_progress = 1
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -80)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, 120)
			_add(W.I_PARTY_SUPPORT, -600)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, 100)
			if d.size() > 118:
				d.automation_progress = 1
			if d.size() > 73:
				d.budget_science += 300
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_BUDGET, -80)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, 150)
			_add(W.I_PARTY_SUPPORT, -600)
			_add_relation(EmpireData.USA, 50)
			if d.size() > 118:
				d.automation_progress = 1
			if d.size() > 73:
				d.budget_science += 300
			context["result_text"] = tr(TXT_R3)






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_110_automation_progress.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_110",
	"num": 110,
	"priority": 11000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_110_automation_progress.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1980.1.1"}, {"t": "MODIFIER_INACTIVE", "key": "12"}, {"t": "TECH_UNLOCKED", "v": 15}, {"t": "RESOURCE_AT_MOST", "key": "economy_system", "v": 11}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
