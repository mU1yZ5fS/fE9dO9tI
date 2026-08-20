extends "res://数据脚本/event_script_base.gd"

## 原作 Event574.cs：选举：旋转起舞（澳大利亚大选结果，单选项）。
## 触发：ReqEventForDLC02.cs:784-787 —— (日>=5 且 月>=3 且 年>=1983) || (月>=4 且 年>=1983) || 年>=1984
##   → DATE_AFTER 1983.3.5。
## 差异：
##  - 描述与结果均按 resultOfEvents[573] 分支（缺省按原版 int 默认 0）；
##  - Vyshi → 亲美；Torg → 对华贸易。


const TXT_DESC_R0 := "虽说在立法上成就显著，可宪政危机余波与近年的愈演愈烈的通货膨胀问题仍持续损害澳大利亚自由党联合政府的权威。因此，今年选举将格外激烈：工党吸取了惠特拉姆政策教训，转而推出和英国王室关系密切的党内稳健派比尔·海登参选总理。马尔科姆·弗雷泽则急需选战胜利巩固改革政策，否则必将被不满其方略的党内大佬们一脚踢下。"
const TXT_DESC_R1 := "虽说在立法上成就显著，可宪政危机余波与近年的愈演愈烈的通货膨胀问题仍持续损害澳大利亚自由党联合政府的权威。因此，今年选举将格外激烈：工党吸取了宪政危机教训，转而推出反英王的党内激进派鲍勃·霍克参选总理。马尔科姆·弗雷泽则急需选战胜利巩固改革政策，否则必将被不满其方略的党内大佬们一脚踢下。"
const TXT_DESC_R2 := "虽说在立法上成就显著，可宪政危机余波与近年的愈演愈烈的通货膨胀问题仍持续损害澳大利亚自由党联合政府的权威。因此，今年选举将格外激烈：工党少壮派的临时倒戈导致了温和派比尔·海登出局，并由反英王的党内激进派鲍勃·霍克参选总理。马尔科姆·弗雷泽则急需选战胜利巩固改革政策，否则必将被不满其方略的党内大佬们一脚踢下。"


const TXT_R0 := "结果，弗雷泽成功稳住了总理宝座，并得以用选举胜利暂时击退党内对其的质疑：不过，他似乎对进一步改造自由党路线这点上稍显力不从心。工党则被选战结果彻底击垮，预计需要较长时间恢复元气。这意味着弗雷泽下届任期的主要对手是党内反对派。"
const TXT_R1 := "结果，鲍勃·霍克赢得了选举胜利，野心勃勃的霍克发誓将力行社会改革，遏制通货膨胀并重新审视外交关系：工党硬左派们领导的澳大利亚开始主张非军事化、和平主义与协调冷战超级大国间关系，事实上奉行多边主义政策。现在，我们可以说我们在地球的那一边有了自己人！"
const TXT_R2 := "结果，鲍勃·霍克赢得了选举胜利，野心勃勃的霍克发誓将力行社会改革并遏制通货膨胀。由此启动了澳大利亚工党内的少壮派的新社会民主主义路线：他们试图在协调劳资关系的基础上开展新自由主义改革，最终建成一个既亲商又包容万象的工人国家（并以此同支持社会保守主义的旧右派和支持白澳政策的旧社会民主主义区分开来）。让我们看看接下来会发生什么……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var r573 := int(world.completed_event_ids.get("event_573", 0))
	if r573 == 0:
		event_def.description = TXT_DESC_R0
	elif r573 == 1:
		event_def.description = TXT_DESC_R1
	else:
		event_def.description = TXT_DESC_R2


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c135 := ws.get_country_by_legacy_index(135)
	var r573 := int(ws.completed_event_ids.get("event_573", 0))
	match r573:
		0:
			_add_power(EmpireData.USA, 20)
			context["result_text"] = TXT_R0
		1:
			if c135 != null:
				c135.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				c135.set_tag("亲美", false)
				c135.set_tag("对华贸易", true)
			_add_power(EmpireData.USA, -10)
			context["result_text"] = TXT_R1
		_:
			if c135 != null:
				c135.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			context["result_text"] = TXT_R2
