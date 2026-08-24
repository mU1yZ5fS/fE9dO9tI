extends "res://数据脚本/event_script_base.gd"

## 原作 Event541.cs：我们高唱团结友谊（世界民主青年联盟，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:202-204 —— relres && 年<=1984。
## 差异：描述由 prepare 动态拼领袖姓名；resultOfEvents 缺省按原版 int 默认 0 处理。

const TXT_DESC := "event.script.event_541_sing_of_unity.c0"
const TXT_OPT0_DIS := "event.script.event_541_sing_of_unity.c1"
const TXT_OPT1_DIS := "event.script.event_541_sing_of_unity.c2"
const TXT_OPT2_DIS := "event.script.event_541_sing_of_unity.c3"
const TXT_R0 := "event.script.event_541_sing_of_unity.c4"
const TXT_R0_ALB := "event.script.sing_of_unity.txt_r0_alb"
const TXT_R0_ALB_TAIL := "event.script.event_541_sing_of_unity.c5"
const TXT_R1 := "event.script.event_541_sing_of_unity.c6"
const TXT_R1_ALB := "event.script.sing_of_unity.txt_r1_alb"
const TXT_R1_TAIL := "event.script.sing_of_unity.txt_r1_tail"
const TXT_R2 := "event.script.event_541_sing_of_unity.c7"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	event_def.description = _leader_name() + tr(TXT_DESC)
	if event_def.options.size() < 3:
		return
	var opt := event_def.options
	var line := d.political_line
	if line < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if d.albania_break == 0 and ws.influence_prc >= 350 and ws.modifiers[3].is_active:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line > 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := tr(TXT_R0)
			if d.albania_break == 0:
				text += tr(TXT_R0_ALB) + _leader_name() + tr(TXT_R0_ALB_TAIL)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_DIPLO, -50)
			_add_relation(EmpireData.USSR, 100)
			ws.influence_prc += 20
			context["result_text"] = text
		1:
			var text := tr(TXT_R1)
			if d.albania_break == 0:
				text += tr(TXT_R1_ALB)
			text += tr(TXT_R1_TAIL)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_DIPLO, 50)
			_add_relation(EmpireData.USSR, -150)
			ws.influence_prc += 20
			context["result_text"] = text
		2:
			_add_relation(EmpireData.USSR, -50)
			context["result_text"] = tr(TXT_R2)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_541_sing_of_unity.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_541",
	"nodesc": true,
	"num": 541,
	"priority": 54100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_541_sing_of_unity.gd",
	"trigger": [{"t": "HAS_FLAG", "key": "relres"}, {"t": "DATE_BEFORE", "key": "1984.12.31"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
