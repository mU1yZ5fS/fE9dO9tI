extends "res://数据脚本/event_script_base.gd"

## 原作 Event666.cs：轮回的复仇（毛泽东“复活”事件，单选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1572-1577 ——
##   ((data[5]<100 && influencePRC<50 && data[14]>=5 && data[67]>0 && data[66]>0
##     && data[65]<=0 && data[62]<=0) || MoneyLevel>20) && data[104]==9。
## 差异：MoneyLevel 为 display-only，世界状态移植说明，其分支跳过并注释；
##   其余条件照抄为 ExprNode。

const TXT_TITLE := "轮回的复仇"
const TXT_DESC := "总统阁下！一件难以置信的事情发生了！在我们将政治搞得一团糟的时候，已经确认死亡且遗体被移出纪念堂的共产主义恐怖暴政的始作俑者独夫民贼——毛泽东，在几年后的今天似乎“复活”了！有线人反映，这个长相酷似那位暴君的人正在积极联系那些同情毛时代以及对当今不满的左派分子，并与那些我们的反对派甚至是政府内部的部分人士达成了某种协议。民间已经出现一种不正常的狂热和躁动，我们的军队和政府也发生了某种变化，不再像从前那样忠于我们。总统阁下，我们的统治正面临着最严峻的考验！"
const TXT_OPT0 := "必须立刻找到这个人，并立即将他处死！国安部，出动！"
const TXT_R0 := "出人意料的是，国安部的行动失败了，“毛泽东”的拥护者抓住了他们，并说服部分人员“弃暗投明”，末日已至……"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		context["result_text"] = TXT_R0
		if d.size() > W.I_PARTY_SUPPORT:
			d[W.I_PARTY_SUPPORT] = 0
		if d.size() > W.I_PEOPLE_SUPPORT:
			d[W.I_PEOPLE_SUPPORT] = 0
		if d.size() > W.I_AGENTS:
			d[W.I_AGENTS] = 0
		# 原版 load_scene_after_click：data[35]=8 并加载 Ending；
		# Godot 设 I_ENDING_ROUTE=8 并排队结局（结局界面无 8 时回退 0）。
		if d.size() > W.I_ENDING_ROUTE:
			d[W.I_ENDING_ROUTE] = 8
		GameManager.queue_ending_after_event(8)
