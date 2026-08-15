extends "res://数据脚本/event_script_base.gd"

## 原作 Event300.cs：越南战争（边境冲突失败后，四选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:447-449 ——
##   !event_done[300] && event_done[56] && resultOfEvents[56]==1 && war==1
##   && data[21]>=1979 && data[20]>=3；fire_only_once 承担 !event_done[300]。
## 差异：
##  - war→ws.war_state；isOVD/isSEV→set_tag("ovd"/"sev")；
##  - empires[1].relations=-250 按项目约定 clampi(…,0,1000) 处理；
##  - 死代码 result_num==5 跳过。

const TXT_TITLE := "越南战争"
const TXT_DESC := "我们的部队能够在边境冲突中击败敌人，并开始向内陆推进，但我们走得越远，面临的问题就越多。越军成功地利用了不可逾越的地形优势，在已经占领的地区，解放军不得不对付积极破坏我们补给线的游击队。部分军队领导层和党员主张，应立即停止军事行动，并隐瞒事态。另一派则建议联系联合国，与越南谈判让步，以换取我们停止进攻行动和撤军。然而，我们可以继续进攻，我们有巨大的动员潜力，我们在人力和武器上超过越南，如果我们定期向前线增援，我们迟早会粉碎他们的防御。然而，你现在可以用核打击来结束一切，即使这样做的后果将是真正的灾难。"
const TXT_OPT0 := "止步于目前进度。"
const TXT_OPT1 := "我们正通过联合国解决事态。。"
const TXT_OPT1_DIS := "我们绝不与资本主义者和修正主义者妥协！"
const TXT_OPT2 := "我们继续战争。"
const TXT_OPT3 := "愿毛泽东的核太阳升起！"
const TXT_OPT3_DIS := "哪怕是为了对抗修正主义者，我们也不会先发动核打击"
const TXT_R0 := "我们无法实现我们的目标，并决定立即撤军。很明显，我们的军队急需改革和现代化建设，党应该处理失败的具体原因。另一方面，越南正在巩固自身边界，要求我们对其赔款，并且已在就在其领土上部署一支苏联部队的问题与苏联进行谈判，并已申请加入华约，申请得到通过只是时间问题。"
const TXT_R1 := "目睹了前线的失败，我们转而采取外交手段。不久，在联合国安理会的一次会议上，解决越南问题的议题被提了出来。借助我们的影响力与美国的支持，我们能够依照自身意志解决大多数问题，越南甚至还得把部分大陆领土割让给我们。尽管苏联和其他一些国家对此感到愤懑不满，这个决定还是给我们挽回了颜面。在那之后，越南政府加强了与苏联的军事和经济合作，并开始在我国边界附近定期举行军事演习。"
const TXT_R2 := "我们不需要谈判！我们在武器和人力方面有巨大的优势。尽管难免有些军事和经济损失，我们仍将有条不紊地摧毁他们的防御。"
const TXT_R3 := "凌晨五点，一架轰六轰炸机升空飞向河内。机上搭载着一枚300万吨当量的热核炸弹。不久后，越南首都便化作了一片废墟。当天结束时，蘑菇云已在越南的许多其他城市和工业重镇冉冉升起。解放军正从四面八方突破越军的防线。这是场压倒性的胜利，但这值得么？"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var vietnam := ws.get_country_by_legacy_index(11)
	var war1 := _get_war(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			ws.war_state = 0
			_set_data(W.I_WAR_PRESSURE, 5)
			if vietnam != null:
				vietnam.set_tag("ovd", true)
				vietnam.set_tag("sev", true)
			if war1 != null:
				war1.side1 = "柬埔寨"
				war1.name_war = "柬埔寨－越南战争"
		1:
			context["result_text"] = TXT_R1
			_add_relation(EmpireData.USSR, -200)
			ws.war_state = 0
			if vietnam != null:
				vietnam.set_tag("sev", true)
			if war1 != null:
				war1.side1 = "柬埔寨"
				war1.name_war = "柬埔寨－越南战争"
		2:
			context["result_text"] = TXT_R2
		3:
			context["result_text"] = TXT_R3
			if war1 != null:
				war1.infl1 = 1000
				war1.infl2 = -1000
			if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
				ws.empires[EmpireData.USA].relations = 0
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
				ws.empires[EmpireData.USSR].relations = clampi(-250, 0, 1000)
			_add(W.I_ARMY, -200)
			_add(W.I_WAR_SUPPORT, 50)
			_add(W.I_MANPOWER, -100)
			_add(W.I_DIPLO, 500)


func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)
