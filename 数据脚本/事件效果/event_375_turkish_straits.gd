extends "res://数据脚本/event_script_base.gd"

const TXT_375_765 := "苏联宣称土耳其领土"
const TXT_375_766 := "近日，苏联新任领导人格里戈里·罗曼诺夫提出了“反世界帝国主义理论”。西方媒体已将其称之为“罗曼诺夫主义”（类似所谓的“勃列日涅夫主义”）。因此，苏联已经开始对部分土耳其领土宣布主权。苏联领导人的声明如下：“我们已经见识到了土耳其是如何威胁苏联邻国，表露其侵略野心的。这条边界基本上被所有的延黑海国家所共用，因此，苏联不得不对其边界与海峡的安全格外关注。”因此，苏联领导人将二战结束后对土耳其的领土要求再度抛出：这也是前俄罗斯帝国控制的土地——即卡尔斯、阿尔特温和阿尔达汉；以及博斯普鲁斯与达达尼尔海峡的通行权（以及其附属附近的土地，包括伊斯坦布尔）罗曼诺夫还要求美军撤出土耳其（而苏联军队则必须进驻此地）国际社会严厉批评了“苏联的侵略野心及其帝国主义计划”，并已开始对该国引入新一轮制裁。"
const TXT_375_775 := "我们的叙利亚盟友正寻求解决“哈塔伊省问题”——叙利亚的领土因此被切断，并呈现出有利于土耳其的局势。"
const TXT_375_767 := "支持土耳其（需要25.0百万{0}与50.0点{2}）"
const TXT_375_592 := "预算"
const TXT_375_593 := "特工网络"
const TXT_375_594 := "军事实力"
const TXT_375_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_375_776 := "军事实力必须高于{0}点......"
const TXT_375_768 := "支持苏联的要求"
const TXT_375_769 := "木已成舟......"
const TXT_375_770 := "满足叙利亚的要求，但阻碍苏联的侵略野心（需要35.0百万{0}与50.0点{2}）"
const TXT_375_771 := "满足叙利亚的要求并支持苏联（需要10.0百万{0}）"
const TXT_375_772 := "与美国一起反对苏联（需要10.0百万与25.0点{2}）"
const TXT_375_658 := "还未签署中美合作协定......"
const TXT_375_777 := "我们向土耳其政府送去了军事与财政援助，并要求苏联立即撤出土耳其领土上的军队。在西方国家不计其数的“反对苏联侵略”的集会面前，苏联不得不退缩并撤回部队。然而，苏联领导层绝不会就此撤回自己的领土宣称。{1}"
const TXT_375_780 := "在我们的压力下，土耳其政府承认对哈塔伊省的占领非法。在此之后，叙利亚军进驻了该地，哈塔伊省因此回归叙利亚。"
const TXT_375_781 := "尽管我们对土耳其施加了压力，土耳其政府依然不承认它对哈塔伊省的占领非法。"
const TXT_375_778 := "我们向土耳其政府送去了军事与财政援助，并要求苏联立即撤出土耳其领土上的军队。然而，苏联已经开始向内陆推进。从保加利亚方向出动的部队占领了土耳其的欧洲部分与海峡，驻守在那里的美军则接到了撤往希腊地区，以防冲突升级的命令。.联合国安理会通过了谴责苏联侵略的决议，但除了对苏联引入新一轮制裁外，没有采取新的决定。在格里戈里·罗曼诺夫的命令下，一枚红星被安置在圣索菲亚大教堂的穹顶上。共产主义就这样胜利了。{1}"
const TXT_375_779 := "苏联已经开始向内陆推进。从保加利亚方向出动的部队占领了土耳其的欧洲部分与海峡，驻守在那里的美军则接到了撤往希腊地区，以防冲突升级的命令。.联合国安理会通过了谴责苏联侵略的决议，但除了对苏联引入新一轮制裁外，没有采取新的决定。"
const TXT_375_R1 := "中国外交部代表在发言中表达了对苏联占据伊斯坦布尔海峡的肯定，称其为“打击帝国主义，维护苏联国家安全”的明智决策。这使得国际社会普遍将我们与苏联侵略者并列进行谴责，而罗曼诺夫则表达了对我方支持的感谢。
苏联已经开始向内陆推进。从保加利亚方向出动的部队占领了土耳其的欧洲部分与海峡，驻守在那里的美军则接到了撤往希腊地区，以防冲突升级的命令。
联合国安理会通过了谴责苏联侵略的决议，但除了对苏联引入新一轮制裁外，没有采取新的决定。"
const TXT_375_783 := "中国与美国一道向土耳其政府送去了军事与财政援助，并要求苏联立即撤出土耳其领土上的军队。然而，苏联已经开始向内陆推进。从保加利亚方向出动的部队占领了土耳其的欧洲部分与海峡，驻守在那里的美军则接到了撤往希腊地区，以防冲突升级的命令。.联合国安理会通过了谴责苏联侵略的决议，但除了对苏联引入新一轮制裁外，没有采取新的决定。在格里戈里·罗曼诺夫的命令下，一枚红星被安置在圣索菲亚大教堂的穹顶上。共产主义就这样胜利了。"
const TXT_375_782 := "中国与美国一道向土耳其政府送去了军事与财政援助，并要求苏联立即撤出土耳其领土上的军队。在西方国家不计其数的“反对苏联侵略”的集会面前，苏联不得不退缩并撤回部队。然而，苏联领导层绝不会就此撤回自己的领土宣称。{1}"


## 原作 Event375.cs：土耳其海峡危机/蒙古并苏事件链。
## 来源：Event375.cs；触发 ReqEventsDLC02/ReqEventForDLC02.cs:1044。
## 本脚本只负责效果；选项条件在 event_375_turkish_straits.tres 用 ExprNode 表达。
## 效果逐项对应 Event375.cs ResultsOfEvents。
## 字段映射：
##   allcountries[7]→苏联（parts[0/1/2]）；allcountries[35]→叙利亚；allcountries[51]→美国；
##   allcountries[84]→土耳其；allcountries[1]→中国；
##   data.turkish_route_result→ws.turkish_route_result；data.get_data_by_index(124/126) 只由其他事件/外交按钮写入。
##   relres→ws.get_flag("relres")（项目惯例，国家面板.gd:406 同源）。
## 文本：原版 new_events_text 长文未逐字移植，按项目英文风格写入结果摘要。


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	if event_def.event_id != "event_375":
		return
	var d2 := p_ws
	var syria := p_ws.get_country_by_legacy_index(35)
	var syria_ally := syria != null and syria.has_tag("亲中") and syria.has_tag("okb")
	event_def.description = TXT_375_766.replace("{1}", TXT_375_775 if syria_ally else "")
	if event_def.options.size() < 5:
		return
	var opt0 := event_def.options[0]
	var budget_sum: int = d2.budget + d2.reserve
	var army: int = d2.army
	opt0.text = TXT_375_767.replace("{0}", TXT_375_592).replace("{2}", TXT_375_594)
	if army >= 500 and budget_sum >= 250:
		opt0.disabled_text = ""
	else:
		if budget_sum < 250:
			opt0.disabled_text = TXT_375_566.replace("{0}", "25")
		else:
			opt0.disabled_text = TXT_375_776.replace("{0}", "50")
	var opt3 := event_def.options[3]
	if syria_ally:
		opt3.text = TXT_375_770.replace("{0}", TXT_375_592).replace("{2}", TXT_375_594)
		if army >= 500 and budget_sum >= 350:
			opt3.disabled_text = ""
		elif budget_sum < 350:
			opt3.disabled_text = TXT_375_566.replace("{0}", "35")
		else:
			opt3.disabled_text = TXT_375_776.replace("{0}", "50")
		var opt4 := event_def.options[4]
		opt4.text = TXT_375_771.replace("{0}", TXT_375_592)
		if budget_sum >= 100:
			opt4.disabled_text = ""
		else:
			opt4.disabled_text = TXT_375_566.replace("{0}", "35")
	else:
		var usa := p_ws.get_country_by_legacy_index(51)
		opt3.text = TXT_375_772.replace("{2}", TXT_375_594)
		if budget_sum >= 100 and army >= 250 and usa != null and usa.has_tag("对华贸易"):
			opt3.disabled_text = ""
		elif usa == null or not usa.has_tag("对华贸易"):
			opt3.disabled_text = TXT_375_658.replace("{0}", "10")
		elif budget_sum < 100:
			opt3.disabled_text = TXT_375_566.replace("{0}", "10")
		else:
			opt3.disabled_text = TXT_375_776.replace("{0}", "35")

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	_event_375(option_index, context)
	if MapService.instance != null:
		MapService.instance.sync_map_merges()
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_375(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_result_0(context)
		1:
			_result_1(context)
		2:
			_result_2(context)
		3:
			_result_3(context)
		4:
			_result_4(context)


## Event375.cs:85-130 result 0：出兵土耳其；按影响力 75 分为亲中土耳其或蒙古并苏。
func _result_0(context: Dictionary) -> void:
	_add_data(W.I_BUDGET, -250)   # Event375.cs:86
	_add_data(W.I_ARMY, -500)     # Event375.cs:87
	if ws.influence_prc >= 750:
		# Event375.cs:89-101
		_turkey_join_pro_china()
		_add_empire_power(EmpireData.USSR, -50)
		ws.influence_prc += 80
		_add_data(W.I_PARTY_SUPPORT, 300)
		_add_empire_relation(EmpireData.USSR, -500)
		_add_empire_relation(EmpireData.USA, 300)
		context["result_text"] = TXT_375_777.replace("{1}", TXT_375_780)
	else:
		# Event375.cs:103-120
		_set_ussr_parts()
		ws.turkish_route_result = 1
		ws.influence_prc -= 50
		_add_empire_power(EmpireData.USSR, 100)
		_add_empire_relation(EmpireData.USSR, -500)
		_add_data(W.I_PARTY_SUPPORT, -300)
		context["result_text"] = TXT_375_778.replace("{1}", TXT_375_780)
	_clear_relres()


## Event375.cs:135-156 result 1：声援苏联。
func _result_1(context: Dictionary) -> void:
	_set_ussr_parts()
	_add_data(W.I_DIPLO, 100)
	_add_empire_power(EmpireData.USSR, 100)
	_add_empire_relation(EmpireData.USSR, 300)
	_add_empire_relation(EmpireData.USA, -500)
	_add_data(W.I_PARTY_SUPPORT, -300)
	context["result_text"] = TXT_375_R1


## Event375.cs:161-169 result 2：谴责苏联。
func _result_2(context: Dictionary) -> void:
	_add_data(W.I_PARTY_SUPPORT, -300)
	_add_empire_power(EmpireData.USSR, 100)
	_set_ussr_parts()
	context["result_text"] = TXT_375_779


## Event375.cs:171-265 result 3：有叙利亚盟友分支与无叙利亚盟友分支。
func _result_3(context: Dictionary) -> void:
	if _syria_ally():
		_result_3_syria(context)
	else:
		_result_3_no_syria(context)
	_clear_relres()


func _result_3_syria(context: Dictionary) -> void:
	_add_data(W.I_BUDGET, -350)   # Event375.cs:174
	_add_data(W.I_ARMY, -500)     # Event375.cs:175
	# Event375.cs:176-190：叙利亚分支先按影响力>500 判定土耳其 parts[3]
	if ws.influence_prc > 500:
		_turkey_parts_3()
		_add_data(W.I_DIPLO, 50)
		_add_data(W.I_PARTY_SUPPORT, 100)
		_add_empire_relation(EmpireData.USA, -150)
	else:
		_add_data(W.I_PARTY_SUPPORT, -100)
		_add_data(W.I_DIPLO, 50)
		_add_empire_relation(EmpireData.USA, -150)
	# Event375.cs:191-217：随后按影响力>=750 分亲中土耳其或蒙古并苏
	if ws.influence_prc >= 750:
		_turkey_join_pro_china()
		_add_empire_power(EmpireData.USSR, -50)
		_add_data(W.I_PARTY_SUPPORT, 300)
		_add_empire_relation(EmpireData.USSR, -500)
		_add_empire_relation(EmpireData.USA, 300)
		context["result_text"] = TXT_375_777.replace("{1}", TXT_375_780)
	else:
		ws.turkish_route_result = 1
		ws.influence_prc -= 50
		_set_ussr_parts()
		_add_empire_relation(EmpireData.USSR, -500)
		_add_data(W.I_PARTY_SUPPORT, -300)
		context["result_text"] = TXT_375_778.replace("{1}", TXT_375_780)


func _result_3_no_syria(context: Dictionary) -> void:
	_add_data(W.I_BUDGET, -100)   # Event375.cs:224
	_add_data(W.I_ARMY, -250)     # Event375.cs:225
	if ws.influence_prc + _usa_power() >= 750:
		# Event375.cs:227-244
		_turkey_join_pro_china()
		_add_empire_power(EmpireData.USSR, -50)
		ws.influence_prc += 80
		_add_data(W.I_PARTY_SUPPORT, 300)
		_add_empire_relation(EmpireData.USSR, -500)
		_add_empire_relation(EmpireData.USA, 300)
		context["result_text"] = TXT_375_782.replace("{1}", TXT_375_780)
	else:
		# Event375.cs:246-260
		ws.turkish_route_result = 1
		ws.influence_prc -= 50
		_set_ussr_parts()
		_add_empire_power(EmpireData.USSR, 100)
		_add_empire_relation(EmpireData.USSR, -500)
		_add_data(W.I_PARTY_SUPPORT, -300)
		context["result_text"] = TXT_375_783


## Event375.cs:267-300 result 4：叙利亚盟友分支的声援路线。
func _result_4(context: Dictionary) -> void:
	_set_ussr_parts()
	_add_data(W.I_DIPLO, 100)
	_add_empire_power(EmpireData.USSR, 100)
	_add_empire_relation(EmpireData.USSR, 300)
	_add_empire_relation(EmpireData.USA, -500)
	if ws.influence_prc > 500 and _syria_ally():
		_turkey_parts_3()
		_add_data(W.I_DIPLO, 50)
		_add_data(W.I_PARTY_SUPPORT, 100)
		_add_empire_relation(EmpireData.USA, -150)
	else:
		_add_data(W.I_PARTY_SUPPORT, -100)
		_add_data(W.I_DIPLO, 50)
		_add_empire_relation(EmpireData.USA, -150)
	context["result_text"] = TXT_375_777.replace("{1}", TXT_375_780)


func _syria_ally() -> bool:
	var syria := ws.get_country_by_legacy_index(35)
	return syria != null and syria.has_tag("亲中") and syria.has_tag("okb")


func _usa_power() -> int:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		return ws.empires[EmpireData.USA].power
	return 0


func _set_ussr_parts() -> void:
	var ussr := ws.get_country_by_legacy_index(7)
	if ussr == null:
		return
	if ussr.parts.size() < 3:
		ussr.parts.resize(3)
	if ussr.parts[1]:
		# Event375.cs:107-109：parts[1] → 清 1、置 2
		ussr.parts[1] = false
		ussr.parts[2] = true
	else:
		# Event375.cs:110-112：否则置 parts[0]
		ussr.parts[0] = true


func _turkey_parts_3() -> void:
	var turkey := ws.get_country_by_legacy_index(84)
	if turkey == null:
		return
	if turkey.parts.size() < 4:
		turkey.parts.resize(4)
	turkey.parts[3] = true


## Event375.cs 中 allcountries[84].JoinAllOurAlliances(true).EstablishGovernment(ProChina)
## 之后把土耳其 Gosstroy/SubGosstroy 复制为中国值。Godot 按既有标签集合近似 JoinAllOurAlliances。
func _turkey_join_pro_china() -> void:
	var turkey := ws.get_country_by_legacy_index(84)
	var china := ws.get_country_by_legacy_index(1)
	if turkey == null or china == null:
		return
	turkey.set_tag("亲中", true)
	turkey.set_tag("亲美", false)
	turkey.set_tag("亲苏", false)
	if china.has_tag("econ"):
		turkey.set_tag("econ", true)
	if china.has_tag("okb"):
		turkey.set_tag("okb", true)
	if china.has_tag("sev"):
		turkey.set_tag("sev", true)
	if china.has_tag("ovd"):
		turkey.set_tag("ovd", true)
	if china.has_tag("rim"):
		turkey.set_tag("rim", true)
	turkey.government = china.government
	turkey.sub_government = china.sub_government


func _clear_relres() -> void:
	if ws.get_flag("relres"):
		ws.set_flag("relres", false)


func _add_data(index: int, delta: int) -> void:
	if index >= 0 and index < d.size():
		d.add_data_by_index(index, delta)


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		d.usa_relations = ws.empires[EmpireData.USA].relations
		d.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		d.ussr_relations = ws.empires[EmpireData.USSR].relations
		d.soviet_influence = ws.empires[EmpireData.USSR].power
