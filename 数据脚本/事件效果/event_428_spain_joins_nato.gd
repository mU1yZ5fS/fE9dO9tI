extends "res://数据脚本/event_script_base.gd"

## 原作 Event428.cs：西班牙加入北约（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1399-1401 —— c86.Gosstroy==3 + resultOfEvents[424]==1 + DATE_AFTER。
## 差异：spec→special；isNATO→标签 nato；Vyshi→亲美。

const TXT_TITLE := "西班牙加入北约"
const TXT_DESC := "军事政变的失败，反而让政治家坚定了决心：北约组织的部队，也许比他们本国深受长枪党思想与等级制影响的部队更加可靠。西班牙领导人们开始考虑改变他们的外交政策，并寻求让西班牙加入北大西洋公约组织。倘若说在苏亚雷斯时期，前首相还怀疑如此做的可行性，并相信中立才最有利于西班牙的发展。而到了他的继承人卡尔沃·索特洛这里，外交政策便发生了显著转变。1982年5月30日，西班牙被批准加入北约。"
const TXT_OPT0 := "密切关注......"
const TXT_RESULT := "然而，卡尔沃·索特洛与民主中间派联盟的支持率仍在下降。而在1979年选择抛弃马克思主义，并参与民主选举游戏的西班牙工人社会党则有望赢得接下来举行的选举。也许先前对北约极度谨慎的社会党人，将重新考虑西班牙的外交政策？"
const TXT_IDX_1431 := "西班牙加入北约"
const TXT_IDX_1432 := "军事政变的失败，反而让政治家坚定了决心：北约组织的部队，也许比他们本国深受长枪党思想与等级制影响的部队更加可靠。西班牙领导人们开始考虑改变他们的外交政策，并寻求让西班牙加入北大西洋公约组织。倘若说在苏亚雷斯时期，前首相还怀疑如此做的可行性，并相信中立才最有利于西班牙的发展。而到了他的继承人卡尔沃·索特洛这里，外交政策便发生了显著转变。1982年5月30日，西班牙被批准加入北约。"
const TXT_IDX_1433 := "密切关注......"
const TXT_IDX_1434 := "然而，卡尔沃·索特洛与民主中间派联盟的支持率仍在下降。而在1979年选择抛弃马克思主义，并参与民主选举游戏的西班牙工人社会党则有望赢得接下来举行的选举。也许先前对北约极度谨慎的社会党人，将重新考虑西班牙的外交政策？"

func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _raw(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


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
		spain.set_tag("nato", true)
		spain.set_tag("亲美", true)
	_add_power(EmpireData.USA, 70)
	context["result_text"] = TXT_RESULT
