extends "res://数据脚本/event_script_base.gd"

## 原作 Event692.cs：勿忘1204年，勿忘马基雅维利教诲（雇佣兵叛乱/结局事件，单选项）。
## 触发：QueryDecisions`1 where T.cs:5773 MercenaryRebellion —— MilitaryService++；
##   >=3 且 rng(0..3)==1 → number_event=692。Godot 对应 decision_atoms.mercenary_rebellion 已就位。
## 差异：load_scene_after_click + data.ending_route=14 + LoadScene("Ending")
##   → d.ending_route=14 + game.queue_ending_after_event(14)（项目既有惯例）。

const TXT_DESC_FMT := "event.script.event_692_mercenary_rebellion.c0"
const TXT_R0_FMT := "event.script.event_692_mercenary_rebellion.c1"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	var leader := "华国锋"
	if ws.leader != null and ws.leader.name_display != "":
		leader = ws.leader.name_display
	event_def.description = tr(TXT_DESC_FMT).replace("{0}{1}", leader)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	var leader := "华国锋"
	if ws.leader != null and ws.leader.name_display != "":
		leader = ws.leader.name_display
	context["result_text"] = tr(TXT_R0_FMT).replace("{0}{1}", leader)
	_set_data(W.I_PARTY_SUPPORT, 0)
	_set_data(W.I_PEOPLE_SUPPORT, 0)
	_set_data(W.I_AGENTS, 0)
	# 原版 load_scene_after_click：点击结果后 data.ending_route=14 并进入 Ending。
	if d.size() > W.I_ENDING_ROUTE:
		d.ending_route = 14
	game.queue_ending_after_event(14)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_692_mercenary_rebellion.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_692",
	"nodesc": true,
	"num": 692,
	"priority": 69200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_692_mercenary_rebellion.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
