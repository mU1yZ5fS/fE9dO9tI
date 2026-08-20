extends "res://数据脚本/event_script_base.gd"

## 原作 Event429.cs：1982年西班牙选举（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1404-1406 —— c86.isNATO + DATE_AFTER。
## 差异：Gosstroy→government；SubGosstroy→sub_government；spec→special。

const TXT_RESULT := "由费利佩·冈萨雷斯领导的工人社会党成为了议会选举内毋庸置疑的赢家，在选举中拿下几乎50%的选票。4%选民选择支持卡里略领导的西班牙共产党。佛朗哥所恐惧的共产党合法化将导致后者不可避免地拿下西班牙，并将该国拉入无政府状态的预言没有实现。苏亚雷斯与其新党仅获得不到3%的选票，而他的“心血结晶”民主中间派联盟则得票不到7%。曼努埃尔·弗拉加领导的保守派则利用了中间派的分裂，他的国民联盟党拿下了26%的选票。\n西班牙将首次迎来一个一党领导下的社会主义政府，该政府由冈萨雷斯领导。首先，新政府宣布开始“反思近期奉行的外交政策，并暂停西班牙与北约的军事一体化议程”。然而在1981年政变后，社会党对这一问题的立场发送了显著变化......"
const TXT_IDX_1435 := "1982年西班牙选举"
const TXT_IDX_1436 := "妥协候选人卡尔沃·索特洛的当选并不能解救执政党于崩溃之中。1982年8月，民主中间派联盟的创始人阿道弗·苏亚雷斯离开该党，并另建立了社会民主中心党。这导致了执政党内部派系的崩溃，该党也因此在议会内失去多数。结果，西班牙将迎来新一届议会代表选举。"
const TXT_IDX_1154 := "谁将得胜？"
const TXT_IDX_1437 := "由费利佩·冈萨雷斯领导的工人社会党成为了议会选举内毋庸置疑的赢家，在选举中拿下几乎50%的选票。4%选民选择支持卡里略领导的西班牙共产党。佛朗哥所恐惧的共产党合法化将导致后者不可避免地拿下西班牙，并将该国拉入无政府状态的预言没有实现。苏亚雷斯与其新党仅获得不到3%的选票，而他的“心血结晶”民主中间派联盟则得票不到7%。曼努埃尔·弗拉加领导的保守派则利用了中间派的分裂，他的国民联盟党拿下了26%的选票。\n西班牙将首次迎来一个一党领导下的社会主义政府，该政府由冈萨雷斯领导。首先，新政府宣布开始“反思近期奉行的外交政策，并暂停西班牙与北约的军事一体化议程”。然而在1981年政变后，社会党对这一问题的立场发送了显著变化......"



func _raw(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0






func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s





func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, war_name: String, fortnight: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var spain := ws.get_country_by_legacy_index(86)
	var portugal := ws.get_country_by_legacy_index(87)
	if portugal != null:
		portugal.special += 5
	if spain != null:
		spain.government = 3
		spain.sub_government = 4
	context["result_text"] = TXT_RESULT
