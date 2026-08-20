extends "res://数据脚本/event_script_base.gd"

## 原作 Event87.cs：加利利的和平（黎巴嫩战争，单选项）。
## 触发：TimeScript.cs:10710-10716 ——
##   (日>=6 且 月>=6 且 年>=1982 或 年>=1983) && !IndOpp
##   （IndOpp 由 WorldState.ind_opp 建模）。
## 效果：ingamewars[4] 黎巴嫩战争，以色列(650) vs 巴解组织(350)，
##   ussr_place=1、usa_place=0 → Godot ussr_side = GameConstants.WarSide.SIDE2 / usa_side = GameConstants.WarSide.SIDE1。

const TXT_RESULT := "以色列宣布开始“加利利和平行动”，据以色列代表称，这项行动的目的是消灭巴解组织的基地，并在黎巴嫩南部建立一个非军事区。以色列已经宣布，它不会攻击叙利亚在黎巴嫩的武装部队，而叙利亚本身也在避免战斗，但鉴于叙利亚控制了黎巴嫩的大部分地区，他们与以色列国防军之间的冲突似乎只是时间问题。值得注意的是，传统上支持以色列的美国反应相当克制，并没有特别欣赏其“维和”的冲动。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		if ws.wars.size() <= 4:
			GameManager.start_war(4, "以色列", "巴解组织", 650, 350, 0, 1)
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
		context["result_text"] = TXT_RESULT
