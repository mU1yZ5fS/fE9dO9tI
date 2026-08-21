extends "res://数据脚本/event_script_base.gd"

## 原作 Event491.cs：在巴尔干的繁星下（保加利亚佩塔尔事件，二选项）。
## 触发：ReqEventForDLC02.cs:1519-1521 ——
##   c6.SubGosstroy==16 && ((年>=1982 月>=11 日>=17) || (年>=1982 月>=12) || 年>=1983)。
## 差异：cw → 内战中。




const TXT_R0 := "在我们特工的帮助下，佩塔尔没能吃下掺了毒药的炖菜。出于对日夫科夫追杀的恐惧，我们为他提供了政治难民的身份。允许其以保加利亚驻华武官的身份暂住在北京。日夫科夫对我们“赤裸裸干涉保加利亚内政”的行动感到“十分疑惑”。他下令驱逐一名我国大使馆的三等秘书用于表达自己的态度。"

const TXT_R1 := "1982年11月17日，这位老英雄吃下了掺有烈性毒药的炖菜。日夫科夫的政权变得越发稳固……至少暂时如此。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var bulgaria := ws.get_country_by_legacy_index(6)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			if bulgaria != null:
				bulgaria.内战中 = true
			_add_relation(EmpireData.USSR, -50)
			ws.influence_prc += 5
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1


