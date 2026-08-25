extends "res://数据脚本/event_script_base.gd"

## 原作 Event87.cs：加利利的和平（黎巴嫩战争，单选项）。
## 触发：TimeScript.cs:10710-10716 ——
##   (日>=6 且 月>=6 且 年>=1982 或 年>=1983) && !IndOpp
##   （IndOpp 由 WorldState.ind_opp 建模）。
## 效果：ingamewars[4] 黎巴嫩战争，以色列(650) vs 巴解组织(350)，
##   ussr_place=1、usa_place=0 → Godot ussr_side = GameConstants.WarSide.SIDE2 / usa_side = GameConstants.WarSide.SIDE1。

const TXT_RESULT := "event.script.event_087_galilee_peace.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		if ws.wars.size() <= 4:
			game.start_war(4, "以色列", "巴解组织", 650, 350, 0, 1)
		var war := ws.wars[4] if ws.wars.size() > 4 else null
		if war != null:
			war.name_war = "黎巴嫩战争"
			war.is_going = true
			war.side1 = "以色列"
			war.side2 = "巴解组织"
			war.ussr_side = GameConstants.WarSide.SIDE2
			war.usa_side = GameConstants.WarSide.SIDE1
			war.infl1 = 650
			war.infl2 = 350
		context["result_text"] = tr(TXT_RESULT)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_087_galilee_peace.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_087",
	"num": 87,
	"priority": 8700,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1982.6.6"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
