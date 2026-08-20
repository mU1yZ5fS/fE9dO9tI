extends "res://数据脚本/event_script_base.gd"

## 原作 Event666.cs：轮回的复仇（毛泽东“复活”事件，单选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1572-1577 ——
##   ((data.living_standard<100 && influencePRC<50 && data.ideology>=5 && data.tibet_policy>0 && data.xinjiang_policy>0
##     && data.hk_macau_status<=0 && data.arunachal_status<=0) || MoneyLevel>20) && data.mao_mausoleum==9。
## 差异：MoneyLevel 为 display-only，世界状态移植说明，其分支跳过并注释；
##   其余条件照抄为 ExprNode。

const TXT_R0 := "出人意料的是，国安部的行动失败了，“毛泽东”的拥护者抓住了他们，并说服部分人员“弃暗投明”，末日已至……"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		context["result_text"] = TXT_R0
		if d.size() > W.I_PARTY_SUPPORT:
			d.party_support = 0
		if d.size() > W.I_PEOPLE_SUPPORT:
			d.people_support = 0
		if d.size() > W.I_AGENTS:
			d.agents = 0
		# 原版 load_scene_after_click：data.ending_route=8 并加载 Ending；
		# Godot 设 I_ENDING_ROUTE=8 并排队结局（结局界面无 8 时回退 0）。
		if d.size() > W.I_ENDING_ROUTE:
			d.ending_route = 8
		GameManager.queue_ending_after_event(8)
