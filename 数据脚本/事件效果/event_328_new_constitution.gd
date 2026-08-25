extends "res://数据脚本/event_script_base.gd"

## 原作 Event328.cs：新宪法（3选项）。
## 触发：全目录搜索无 this_num_event = 328 / Reset(328) / StartEvent(328)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：party_number→factions[i].support；文本来自 Events_text_en 索引 251-258。

const TXT_R0 := "event.script.event_328_new_constitution.c0"
const TXT_R1 := "event.script.event_328_new_constitution.c1"
const TXT_R2 := "event.script.event_328_new_constitution.c2"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_faction_support(0, 50)
			_add_faction_support(1, 50)
			_add_faction_support(2, 25)
			context["result_text"] = tr(TXT_R0)
		1:
			_add_faction_support(2, 25)
			_add_faction_support(3, 50)
			_add_faction_support(4, 50)
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)

	


func _add_faction_support(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].support += delta

func _add_faction_ideology(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].ideology += delta



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_328_new_constitution.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_328",
	"num": 328,
	"priority": 32800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_328_new_constitution.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
