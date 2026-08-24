extends "res://数据脚本/event_script_base.gd"

## 原作 Event931.cs：民主的故乡——第二幕（希腊第三次议会选举）。 ## 触发：TimeScript.cs:10773-10779 —— ##   ((日>=18 且 月>=10 且 年>=1981) (月>=11 且 年>=1981) 年>=1982)。 ## 差异：resultOfEvents[93] 分支决定 1/3 选项（prepare 动态替换）；其余逐字保留。

static var _opts_full: Array[EventOption] = []


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	if _opts_full.is_empty():
		for o in event_def.options:
			_opts_full.append(o)
	var result93: int = world.completed_event_ids.get("event_093", -1)
	if result93 != 0:
		event_def.description = "希腊即将迎来后军政府时代的第三次议会选举。主要反对党新民主党面临严重的内部冲突。于此同时，希腊社会的左倾让左翼有望在此次大选中获胜。在左翼方面，泛希腊社会主义运动和希腊共产党都希望退出北约和欧共体，而新民主党则希望继续推进进入欧共体的进程，并深化与北约的合作。如果左翼在此次大选中获得胜利，希腊将有望退出北约并终止加入欧共体的进程。选举的结果将影响希腊和欧洲的局势。"
		var arr: Array[EventOption] = []
		for o in _opts_full:
			arr.append(o)
		event_def.options = arr
		var agents := world.agents if world.size() > W.I_AGENTS else 0
		if agents >= 40:
			_enable(arr[0], "支持泛希腊社会主义运动")
		else:
			_disable(arr[0], "我们没有足够的力量")
		if agents >= 40:
			_enable(arr[1], "支持新民主党")
		else:
			_disable(arr[1], "我们没有足够的力量")
		_enable(arr[2], "保持距离")
	else:
		event_def.description = "希腊即将迎来后军政府时代的第三次议会选举。主要反对党新民主党面临严重的内部冲突。希腊左翼政府实行的社会主义改革在国内很受欢迎。左翼政府通过的宪法修正案使得总统完全失去了权力，希腊彻底成为了议会制共和国。泛希腊社会主义运动、希腊共产党等左翼政党在国内巩固了他们的影响力。可以说，此次大选让右翼党派已经无力与左翼抗衡了。"
		var arr: Array[EventOption] = []
		arr.append(_opts_full[0])
		event_def.options = arr
		_enable(arr[0], "我们只需等待！")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var result93: int = ws.completed_event_ids.get("event_093", -1)
	var greece := ws.get_country_by_legacy_index(45)
	var cyprus := ws.get_country_by_legacy_index(87)
	var cyprus2 := ws.get_country_by_legacy_index(94)
	var opt := int(context.get("option_index", -1))
	if result93 != 0:
		match opt:
			0:
				_add(W.I_DIPLO, 10)
				_add_relation(EmpireData.USA, -50)
				_add_relation(EmpireData.USSR, 50)
				if greece != null:
					greece.government = GameConstants.Government.REFORMIST
					greece.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					greece.set_tag("亲美", false)
					if cyprus2 == null or not cyprus2.内战中:
						greece.set_tag("对华贸易", true)
				if cyprus != null:
					cyprus.special -= 5
				_add_power(EmpireData.USA, -50)
				context["result_text"] = tr("event.script.event_931_greece_act2.i0")
			1:
				_add(W.I_DIPLO, -10)
				_add_relation(EmpireData.USA, 80)
				_add_power(EmpireData.USA, 20)
				if greece != null:
					greece.set_tag("eu", true)
					if cyprus2 == null or not cyprus2.内战中:
						greece.set_tag("对华贸易", true)
				if cyprus != null:
					cyprus.special += 5
				context["result_text"] = tr("event.script.event_931_greece_act2.i1")
			2:
				_add_power(EmpireData.USA, 20)
				if greece != null:
					greece.set_tag("eu", true)
					greece.government = GameConstants.Government.REFORMIST
					greece.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				context["result_text"] = tr("event.script.event_931_greece_act2.i2")
	else:
		if opt == 0:
			_add(W.I_DIPLO, 10)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, 50)
			if greece != null:
				greece.government = GameConstants.Government.REFORMIST
				greece.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				if cyprus2 == null or not cyprus2.内战中:
					greece.set_tag("对华贸易", true)
			if cyprus != null:
				cyprus.special -= 5
			_add_power(EmpireData.USA, -50)
			context["result_text"] = tr("event.script.event_931_greece_act2.i3")






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_931_greece_act2.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_931",
	"nodesc": true,
	"num": 931,
	"priority": 9310,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_931_greece_act2.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1981.10.18"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
