extends "res://数据脚本/event_script_base.gd"

## 原作 Event882.cs：罗德斯与伊安的土地（南非入侵津巴布韦，单选项）。
## 触发：原版无自动条件；由 Event881.cs 结果后 load_scene_after_click →
##   number_event=882。项目已由 event_881_zimbabwe_election.gd 的
##   EventEngine.enqueue_chain(["event_882"]) 承接，故 trigger_conditions=[]。
## 差异：
##  - level_of_unstab→level_of_instability；resultOfEvents[609]==0 缺省按原版 0；
##  - War().Name(...).Attacker(...).Defender(...).TickTime(24)
##    .AmericanSupportAttacker.SovietSupportDefender → GameManager.start_war()
##    后覆盖 name_war/fortnight_max。

const TXT_TITLE := "罗德斯与伊安的土地"
const TXT_DESC := "最终，独立的津巴布韦最担心的事情还是发生了。随着南非状态在多方驰援之下不断的稳定下来了，越来越多的部队开始越境袭扰津巴布韦的定居点，在放一把火或掠夺一番后便班师回朝。如果仅仅是这样，津巴布韦的武装力量尚能反制，那么当南非大军压境，他们还能做什么呢？而这样的噩梦已经成真了。就在最近，南非外交部对外宣布发起“石英”行动，名义上是打击在藏身于津巴布韦南部的黑人游击队，事实上就是针对津巴布韦现政权的军事行动。许多车上同时挂着绿白旗和橙白蓝的南非国旗，许多士兵喊着“为1980复仇”之类的口号，冲着前往布拉瓦约和哈拉雷。"
const TXT_OPT0 := "情况会好下来的！"
const TXT_R0 := "赞比亚和坦桑尼亚惊恐的看着津巴布韦的现状，并呼吁联合国介入。但在如此多的“神秘人”的帮助下，谁还能阻挡伟大的白人酋长们呢？"
const WAR_NAME := "南非入侵津巴布韦"
const WAR_SIDE1 := "南非"
const WAR_SIDE2 := "津巴布韦"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var zimbabwe := ws.get_country_by_legacy_index(127)
	var zambia := ws.get_country_by_legacy_index(126)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		context["result_text"] = TXT_R0
		if zimbabwe != null:
			if zimbabwe.parts.size() == 0:
				zimbabwe.parts.resize(1)
			zimbabwe.parts[0] = true
		if zambia != null:
			zambia.level_of_instability -= 200
		var num := 0
		# 原版 resultOfEvents[609]==0 缺省为 0（未触发时同样成立）
		if ws.completed_event_ids.get("event_609", 0) == 0:
			num = 50
		GameManager.start_war(44, WAR_SIDE1, WAR_SIDE2, 700 - num, 300 + num, 0, 1)
		if ws.wars.size() > 44 and ws.wars[44] != null:
			ws.wars[44].name_war = WAR_NAME
			ws.wars[44].fortnight_max = 24
