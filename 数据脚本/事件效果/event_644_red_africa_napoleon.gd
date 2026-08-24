extends "res://数据脚本/event_script_base.gd"

## 原作 Event644.cs：红色非洲拿破仑（中非博卡萨路线，二选项）。
## 触发：DiploButtonScript.cs:10800 —— 外交按钮 70，selected_country==65（中非），手动触发。
## 差异：原版选项1 event_done[644]=false → Godot context["skip_mark_done"]；
##   JoinAllOurAlliances(true)→_join_alliances；soc_stab→social_stability。

const TXT_R0 := "event.script.event_644_red_africa_napoleon.c0"
const TXT_R1 := "event.script.event_644_red_africa_napoleon.c1"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var car := ws.get_country_by_legacy_index(65)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if car != null:
				car.government = GameConstants.Government.AUTHORITARIAN
				car.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
				car.set_tag("亲中", true)
				_join_alliances(car)
				car.social_stability = 1000
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			ws.influence_prc += 50
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
		1:
			context["result_text"] = tr(TXT_R1)
			# 原版 :59 event_done[644]=false → 跳过完成标记，按钮可再次选择
			context["skip_mark_done"] = true



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_644_red_africa_napoleon.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_644",
	"num": 644,
	"priority": 64400,
	"notify": false,
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
