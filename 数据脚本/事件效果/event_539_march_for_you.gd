extends "res://数据脚本/event_script_base.gd"

## 原作 Event539.cs：献给你的进行曲（韩国光州后续，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:312-314 —— 复杂条件见 evaluate()。
## 差异：SKRebel→ws.get_flag("SKRebel")；ingamewars[0]→ws.wars[0]；
##   parts[0]→CountryData.parts[0]；IsSocialism 谓词对应关系见 evaluate。

const TXT_TITLE := "献给你的进行曲"
const TXT_DESC := "为了纪念518光州事件，数十名首尔地区的大学生占领了首尔美国文化中心，并高举“美国为光州事件负责，必须道歉”的口号。美国大使为此前来与学生们交流，但在交流无果后离开文化中心。在静坐了数天以后，军警突然闯入二楼并将学生全部抓捕。这一消息使得本就因为镇压民主化导致左翼化激进化的学生运动变得更加激进，更多的学生走上街头要求释放学生，因为被封锁导致失业的工人们也开始上街游行，民主派们也正蠢蠢欲动。或许，我们应该趁此出手，使这个东亚最后的反共堡垒从内部摧毁？"
const TXT_OPT0 := "为学生们提供支持"
const TXT_OPT0_DIS := "我们无法支持！"
const TXT_OPT1 := "无动于衷"
const TXT_R0 := "在特工的帮助下，左翼学生，工人和部分前左翼政党的政治人物被团结在一起，武装的工人与学生等在全国各地进行暴动，韩国事实上正在进行一场小型内战。但在我们的施压下，军政府被迫倒台，全斗焕，卢泰愚，李鹤捧等军政府高层被临时法庭判处死刑并立即执行。反对派们上台了，没有一刻为军政府的倒台感到高兴，紧接而来的便是反对派内部激烈的派系斗争。不过在我们顾问的帮助下，反对派决定先与朝鲜进行和平谈判，并在不久之后与朝鲜一起召开宪政大会。"
const TXT_R1 := "在美国驻军的支持下，韩国再一次颁布全国戒严令，各地均有军警与学生和工人们爆发冲突的事件，在冲突激烈的地区军警被批准直接向参与运动的人群开火，坦克也被使用冲散暴动的人群，前所未有的镇压强度使得这场席卷全韩国的民主运动被迅速平定，运动骨干被当作共匪和通北人士进行枪决。韩国未来将会一直与美国保持紧密的联系，但是能否一直维持军政府甚至维持韩国这个国家的存在仍打一个大大的问号。"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if world.wars.size() <= 0 or world.wars[0] == null or world.wars[0].is_going:
		return false
	var c46 := world.get_country_by_legacy_index(46)
	var c10 := world.get_country_by_legacy_index(10)
	var c44 := world.get_country_by_legacy_index(44)
	var c38 := world.get_country_by_legacy_index(38)
	if c46 == null or c10 == null or c44 == null or c38 == null:
		return false
	if c46.parts.size() > 0 and c46.parts[0]:
		return false
	if c10.parts.size() > 0 and c10.parts[0]:
		return false
	if c46.sub_government != 7:
		return false
	if c10.puppet_of >= 0:
		return false
	if not (c10.government == 1 or c10.sub_government == 0 or c10.sub_government == 10):
		return false
	if not (c44.government == 1 or c44.government == 2):
		return false
	if not (c38.government == 1 or c38.government == 2 or world.decisions.completed[7]):
		return false
	var y := world.数值表[W.I_YEAR]
	var mo := world.数值表[W.I_MONTH]
	var day := world.数值表[W.I_DAY]
	if (y >= 1985 and mo >= 5 and day >= 23) or (y >= 1985 and mo >= 6) or y >= 1986:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var r474 := int(ws.completed_event_ids.get("event_474", 0))
	if ws.get_flag("SKRebel") and r474 == 0 and ws.completed_event_ids.has("event_474"):
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c46 := ws.get_country_by_legacy_index(46)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -150)
			if c46 != null:
				c46.government = 1
				c46.sub_government = 1
				_leave_alliances(c46)
				c46.set_tag("亲中", true)
				c46.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -200)
			_add_power(EmpireData.USA, -50)
			ws.influence_prc += 50
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1
