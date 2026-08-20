extends "res://数据脚本/event_script_base.gd"

## 原作 Event549.cs：铲除杂草（蒙古泽登巴尔，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:47-49 —— 复杂条件见 evaluate()。
## 差异：ingamewars[22]→ws.wars[22]；IndOpp/is_gkchp→global_flags；
##   data[133]/data[130] raw index 直接读 数值表。

const TXT_OPT0_DIS := "没人会听我们的"
const TXT_R0 := "在我们的特工资助了蒙古人民革命党内部的反对派的情况下，扎兰阿扎布获得了相当一部分的支持者，而苏联在此时也对他的政策不满，对其进行施压。在来自党内和来自苏联的双重压力下，泽登巴尔放弃了“铲除杂草”运动，甚至平反了此前被打倒的干部（包括丹巴等前竞争对手），他们得以重返中央委员会。如今，泽登巴尔的地位已经大大动摇，他的倒台似乎也已经出现在地平线上。"
const TXT_R1 := "1983年7月，扎兰阿扎布被突然解除全部职务。但直到1984年2月，蒙古人民革命党机关刊物《党的生活》才刊登了相关通告，通告内称扎兰阿扎布为“反党分子”，据称已经酝酿了20年“邪恶的阴谋”，准备在朝克特奥其尔·洛呼兹、巴勒丹道尔吉·宁布、班地·苏尔玛扎布以及达拉姆·图木尔奥其尔的支持下推翻泽登巴尔。扎兰阿扎布被开除出党并被流放，罪名是“破坏党的团结”。“铲除杂草”运动仍在继续，到1984年，三分之一的中央委员会成员和1981年任命的近一半的部委首脑都被泽登巴尔解职。"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var dd := world.数值表
	if dd.size() <= W.I_DAY:
		return false
	if world.wars.size() > 22 and world.wars[22] != null and world.wars[22].is_going:
		return false
	if dd[133] == 1 or dd[130] == 1 or dd[133] == 3:
		return false
	if world.get_flag("IndOpp") or world.get_flag("is_gkchp"):
		return false
	var c7 := world.get_country_by_legacy_index(7)
	var c9 := world.get_country_by_legacy_index(9)
	if c7 == null or c9 == null:
		return false
	if c7.has_tag("nato") or c9.has_tag("ovd"):
		return false
	var y := dd[W.I_YEAR]
	var mo := dd[W.I_MONTH]
	var day := dd[W.I_DAY]
	if (y >= 1983 and mo >= 7 and day >= 1) or (y >= 1983 and mo >= 8) or y >= 1984:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var c9 := world.get_country_by_legacy_index(9)
	var r62 := int(ws.completed_event_ids.get("event_62", 0))
	if c9 != null and c9.内战中 and ws.influence_prc >= 300 and r62 != 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add_relation(EmpireData.USSR, -50)
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1
