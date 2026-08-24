extends "res://数据脚本/event_script_base.gd"

## 原作 Event693.cs：押运花石纲（瑞士存钱，手动事件，二选项）。
## 触发：DiploButtonScript.cs:9428（this_type==49, selected_country==39）
##   → 外交互动_批2.gd 的 _def_104? 分支，已改为 start_event_num(w, 693)。
## 差异：ServeRMB→ws.serve_rmb、LeaderAsset→ws.leader_asset、proprc→亲中。

const TXT_OPT1_DIS := "event.script.event_693_flower_stone_escort.c0"
const TXT_R0 := "event.script.event_693_flower_stone_escort.c1"
const TXT_R1 := "event.script.event_693_flower_stone_escort.c2"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	var mod3 := ws.modifiers.size() > 3 and ws.modifiers[3] != null and ws.modifiers[3].is_active
	var mod6 := ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	if not mod3 or not mod6:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var swiss := ws.get_country_by_legacy_index(39)
	var proprc := swiss != null and swiss.has_tag("亲中")
	if opt == 0:
		context["result_text"] = tr(TXT_R0)
		_add(W.I_CORRUPTION, 10)
		if not proprc:
			_add(W.I_PARTY_SUPPORT, 200)
			_add(W.I_BUDGET, -100)
		else:
			_add(W.I_PARTY_SUPPORT, 400)
			_add(W.I_BUDGET, -50)
		return
	if opt == 1:
		context["result_text"] = tr(TXT_R1)
		_add(W.I_CORRUPTION, 20)
		ws.leader_asset += 20
		ws.serve_rmb = true
		if not proprc:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_BUDGET, -100)
		else:
			_add(W.I_PARTY_SUPPORT, 200)
			_add(W.I_BUDGET, -50)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_693_flower_stone_escort.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_693",
	"num": 693,
	"priority": 69300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_693_flower_stone_escort.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
