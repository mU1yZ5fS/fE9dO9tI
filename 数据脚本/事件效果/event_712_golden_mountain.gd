extends "res://数据脚本/event_script_base.gd"

## 原作 Event712.cs：积玉堆金官又崇（领袖奢侈生活，四选项）。
## 触发：GlobalScript.cs:72 Decision「一箪食，一瓢饮」→ decision_catalog.gd d52 start_event(712)。
## 差异：LeaderProperty[1-3]→ws.leader_property[1-3]、LeaderAsset→ws.leader_asset；
##   result3 的 completedDecisions[52]=false → ws.decisions.completed[52]=false。

const TXT_DESC_FMT := "event.script.event_712_golden_mountain.c0"
const TXT_OPT0_DIS := "event.script.event_712_golden_mountain.c1"
const TXT_OPT1_DIS := "event.script.event_712_golden_mountain.c2"
const TXT_OPT2_DIS := "event.script.event_712_golden_mountain.c3"
const TXT_R0_FMT := "event.script.event_712_golden_mountain.c4"
const TXT_R1_FMT := "event.script.event_712_golden_mountain.c5"
const TXT_R2_FMT := "event.script.event_712_golden_mountain.c6"
const TXT_R3 := "event.script.event_712_golden_mountain.c7"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	var leader := "华国锋"
	if ws.leader != null and ws.leader.name_display != "":
		leader = ws.leader.name_display
	event_def.description = tr(TXT_DESC_FMT).replace("{0}{1}", leader)
	if event_def.options.size() < 4:
		return
	_ensure_leader_property()
	var opt := event_def.options
	if not ws.leader_property[1]:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if not ws.leader_property[2]:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if not ws.leader_property[3]:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var leader := "华国锋"
	if ws.leader != null and ws.leader.name_display != "":
		leader = ws.leader.name_display
	var opt := int(context.get("option_index", -1))
	_ensure_leader_property()
	match opt:
		0:
			context["result_text"] = tr(TXT_R0_FMT).replace("{0}{1}", leader)
			ws.leader_asset -= 800
			_add(W.I_BUDGET, -200)
			ws.leader_property[1] = true
		1:
			context["result_text"] = tr(TXT_R1_FMT).replace("{0}{1}", leader)
			ws.leader_asset -= 800
			_add(W.I_BUDGET, -200)
			ws.leader_property[2] = true
		2:
			var museum := "中国国家革命博物馆" if ws.is_socialism(ws.get_country_by_legacy_index(1), true) else "中国国家博物馆"
			context["result_text"] = tr(TXT_R2_FMT).replace("{0}{1}", leader).replace("{2}", museum)
			ws.leader_asset -= 800
			_add(W.I_BUDGET, -200)
			ws.leader_property[3] = true
		3:
			context["result_text"] = tr(TXT_R3)
			if ws.decisions != null:
				while ws.decisions.completed.size() <= 52:
					ws.decisions.completed.append(false)
				ws.decisions.completed[52] = false


func _ensure_leader_property() -> void:
	while ws.leader_property.size() < 4:
		ws.leader_property.append(false)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_712_golden_mountain.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_712",
	"nodesc": true,
	"num": 712,
	"priority": 71200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_712_golden_mountain.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
