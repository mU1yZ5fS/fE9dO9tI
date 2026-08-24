extends "res://数据脚本/event_script_base.gd"

## 原作 Event791.cs：1979年国庆节（三十年国庆讲话，三选项）。 ## 触发：TimeScript.cs:10038-10044 —— (月>=10 且 年>=1979) 或 年>=1980。 ## 动态文案钩子 prepare(event_def, world)（挂 display_script）： ##  - 事件描述与结果文案插入当前领导人姓名（原版 names1[name_1]+" "+names2[name_2]）。 ##  - 选项0 原版按 (name_1==2&&name_2==2&&data.political_line<=1) (name_1==3&&name_2==3) 销毁按钮； ##    Godot 用 prepare 动态设置 enable_condition（不可达 ExprNode）等价灰显。 ## 差异：字符间空格排版不保留；show_notification=false（项目约定）。

const TXT_OPT0_OK := "event.script.event_791_national_day.c0"
const TXT_OPT0_OFF := "event.script.event_791_national_day.c1"

const TXT_BODY := "event.script.event_791_national_day.c2"
const TXT_BODY2 := "event.script.event_791_national_day.c3"

const TXT_R0_OPEN := "event.script.event_791_national_day.c4"
const TXT_R0_SPEECH := "event.script.event_791_national_day.c5"
const TXT_R0_PARADE := "event.script.event_791_national_day.c6"

const TXT_R1_SPEECH := "event.script.event_791_national_day.c7"

const TXT_R2_SPEECH := "event.script.event_791_national_day.c8"

const TXT_INTRO := "event.script.event_791_national_day.c9"


## 显示前动态钩子（game_manager.gd:494-497 调用 display_script.prepare）
func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var leader_name := _leader_name(world)
	event_def.description = leader_name + tr(TXT_BODY) + leader_name + tr(TXT_BODY2)
	if event_def.options.size() > 0:
		var opt: EventOption = event_def.options[0]
		if _option0_available(world):
			opt.text = tr(TXT_OPT0_OK)
			opt.disabled_text = ""
			opt.enable_condition = null
		else:
			opt.text = tr(TXT_OPT0_OFF)
			opt.disabled_text = tr(TXT_OPT0_OFF)
			opt.enable_condition = _never_node()


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var leader_name := _leader_name(ws)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, -50)
			_add(W.I_MANPOWER, 200)
			_add(W.I_DIPLO, 50)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			context["result_text"] = \
				tr(TXT_R0_OPEN) + leader_name + tr(TXT_R0_SPEECH) + "\n" + tr(TXT_INTRO) + leader_name + tr(TXT_R0_PARADE)
		1:
			_add(W.I_PEOPLE_SUPPORT, 200)
			_add(W.I_THOUGHT_FREEDOM, -100)
			_add(W.I_INDUSTRY, 50)
			_add(W.I_AGRICULTURE, 50)
			_add(W.I_SERVICES, 50)
			context["result_text"] = \
				tr(TXT_R0_OPEN) + leader_name + tr(TXT_R1_SPEECH) + "\n" + tr(TXT_INTRO) + leader_name + tr(TXT_R0_PARADE)
		2:
			_add(W.I_PARTY_SUPPORT, 80)
			_add(W.I_PEOPLE_SUPPORT, 80)
			_add(W.I_DIPLO, -100)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, 150)
			context["result_text"] = \
				tr(TXT_R0_OPEN) + leader_name + tr(TXT_R2_SPEECH) + "\n" + tr(TXT_INTRO) + leader_name + tr(TXT_R0_PARADE)


func _leader_name(world: WorldState) -> String:
	if world.leader != null and world.leader.name_display != "":
		return world.leader.name_display
	return "华国锋"


## Event791.cs VariantsOfEvents 选项0显隐条件： ## (name_1==2 && name_2==2 && data.political_line<=1) (name_1==3 && name_2==3)
func _option0_available(world: WorldState) -> bool:
	var leader := world.leader
	if leader == null:
		return false
	var political_line := world.political_line if world.size() > W.I_POLITICAL_LINE else 1
	return (leader.name_first == 2 and leader.name_last == 2 and political_line <= 1) \
		or (leader.name_first == 3 and leader.name_last == 3)


## 不可达 ExprNode（灰显用，值域取不可能阈值）。
func _never_node() -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	return n







# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_791_national_day.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_791",
	"num": 791,
	"priority": 7910,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_791_national_day.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.10.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
