extends "res://数据脚本/event_script_base.gd"

## 原作 Event711.cs：碾碎他们，我的兄弟们（第五次中东战争，单选项）。
## 触发：TimeScript.cs:10588-10594 —— c14.SubGosstroy==19 && c14.puppetOf<0
##   && !c51.isNATO && c37.Gosstroy==3 && c35/c93/c104.SubGosstroy==19
##   （全部由 .tres ExprNode 表达）。
## 效果：ingamewars[4] = 第五次中东战争，伊拉克(700) vs 以色列(300)，
##   TickTime(24)（→ fortnight_max=24），无美苏支持标记（usa/ussr_side = GameConstants.WarSide.SIDE1 默认）。

const TXT_RESULT := "伊拉克的侯赛因-1型导弹带着五十年的怒火从巴格达飞向特拉维夫，惊恐的以色列人毫无防备，但以色列国防军也开始了全国总动员。伊拉克方面则从三个方向全面进攻，目标直指耶路撒冷。听命于伊拉克的巴勒斯坦解放组织也早就在当地就位，开展了自1967年的惨败以来最猛烈的回击。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		GameManager.start_war(4, "伊拉克", "以色列", 700, 300, 0, 0)
		if ws.wars.size() > 4 and ws.wars[4] != null:
			ws.wars[4].name_war = "第五次中东战争"
			ws.wars[4].fortnight_max = 24  # 原版 TickTime(24)
		context["result_text"] = TXT_RESULT
