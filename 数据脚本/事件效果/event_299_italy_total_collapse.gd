## 原作 Event299.cs：“总崩溃”（意大利第二共和国大选，三选项）。
## 触发：由 Event298 结果链手动触发（原版 load_scene_after_click + number_event=299），无自动条件。
## 差异：Gosstroy/SubGosstroy→government/sub_government；spec→special；inflCh/inflNATO→influence_china/influence_nato；
##  IsSocialism/IsAuthoritarianism 用 ws.is_socialism/ws.is_authoritarian；d[134]/d[176]/d[177] 用 raw index。
extends "res://数据脚本/event_script_base.gd"

const TXT_TITLE := "“总崩溃”"
const TXT_DESC := "第一共和国终结了，人民对于现存体制的信任已然跌落谷底。可古话说得好，有破终有立，且生活仍要继续。自该国的政治丑闻全面爆发以来，意大利的政治版图便发生了令人印象深刻的重组：由于意大利的中间派事实上在反腐调查中灭绝，国内的意识形态力量对比自然走向极化。绝大多数的政治资源不仅向现存的主流议会政党内富集（主要是意大利共产党与意大利社会运动，它们和传统政治力量相比更倾向于选择极端主义立场。出于团结该国主要选民的需要，两党均建立了以自身为核心的联合竞选名单，并确立了在左翼/右翼“联盟”旗帜下建立共识，团结一致，联合治理的基本路线），更促成了民粹主义情绪与新党运动借机迅速崛起。在国家引入比例代表制并放松政治管制的大背景下，所有的一切都为为即将到来的特别大选增添了未知数。考虑到本次大选将为第二共和国的未来定调，我们自然有理由做出干涉，得在参选者中货比三家。确保有助于中方的政治力量登上前台。"
const TXT_OPT0 := "我们将支持意大利共产党领导的“左翼”派系为该国带来进步与革新"
const TXT_OPT0_DIS := "一头羊领导的狮群，远不如一头狮率领的羊群"
const TXT_OPT1 := "我们需要关注意大利社会运动领导的“右翼”派系，终结无政府状态。"
const TXT_OPT1_DIS := "一头羊领导的狮群，远不如一头狮率领的羊群"
const TXT_OPT2 := "我们应静观其变"
const TXT_OPT0_DIS_A := "一头羊领导的狮群，远不如一头狮率领的羊群"
const TXT_OPT0_DIS_B := "意大利不需要长颈鹿"
const TXT_OPT1_DIS_A := "一头羊领导的狮群，远不如一头狮率领的羊群"
const TXT_OPT1_DIS_B := "同新法西斯主义运动勾搭？党可不会作法自毙"
const TXT_R_COLLAPSE := "意大利长期排斥极端主义政党的中间派政治实践最终产生了意想不到的效果：由于“净手行动”直接导致了该国建制派的终结，而极端主义者亦因长期处于政治舞台边缘而无力夺取政权。如此广泛的权力真空自然导致力量对比向新党运动与民粹主义浪潮看齐。这便为本就借助舆论高地聚敛空前资源的大寡头与政治投机客西尔维奥·贝卢斯科尼创造了机会。依托由自身足球俱乐部与商业伙伴改组而成的政党意大利力量党，并在此基础上大规模收编前天主教民主党与意大利社会党成员以扩充政治资本。他得以在第二共和国的乱局中迅速打出旗帜并合纵连横，直截了当地夺下该国最高权柄。"
const TXT_R_LEFT := "根据投票结果显示，意大利共产党领导的左翼联盟拿下超半数议会席位，就此赢下选举。借助共产党长期深耕意大利政界积攒的庞大体量，以及该党同工会、学生运动乃至合作社系统的密切联系。这一执政联盟在实践内事实上表现得同共产党治下的一党独大无异。由恩里科·贝林格领导的政府得以成立，宣布将立即启动“意大利社会主义”议程并重新审定内政、经济与外交路线。然而，一党独大的确立并不代表着故事结束：意大利共产党因“接待”过多来自前天主教民主党与意大利社会党的成员而显得“消化不良”。这可能为意大利有史以来首个民选的共产主义政权开残酷玩笑。"
const TXT_R_RIGHT := "根据投票结果显示，意大利社会运动领导的右翼联盟拿下超半数议会席位，就此赢下选举。借助社会运动长期深耕意大利政界积攒的庞大体量，以及该党同亲君主主义者、极右翼文化运动乃至保守主义倾向的密切联系。这一执政联盟在实践内事实上表现得同社会运动治下的一党独大无异。由乔治·阿尔米兰特领导的府得以成立，宣布将立即启动“革新法西斯主义”议程并重新审定内政、经济与外交路线。然而，一党独大的确立并不代表着故事结束：意大利社会运动因“接待”过多来自前天主教民主党的成员而显得“消化不良”。这可能为意大利有史以来首个民选的极端民族主义政权开残酷玩笑。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var line := world.数值表[W.I_POLITICAL_LINE] if world.数值表.size() > W.I_POLITICAL_LINE else 1
	var d176 := world.数值表[176] if world.数值表.size() > 176 else 0
	var d177 := world.数值表[177] if world.数值表.size() > 177 else 0
	var diplo := world.数值表[W.I_DIPLO] if world.数值表.size() > W.I_DIPLO else 0
	var war := world.数值表[W.I_WAR_SUPPORT] if world.数值表.size() > W.I_WAR_SUPPORT else 0
	var opt := event_def.options
	if line >= 2 and line <= 3 and d176 > 0:
		_enable(opt[0], TXT_OPT0)
	elif d176 <= 0:
		_disable(opt[0], TXT_OPT0_DIS_A)
	else:
		_disable(opt[0], TXT_OPT0_DIS_B)
	if diplo >= 800 and war > 300 and line <= 3 and d177 > 0:
		_enable(opt[1], TXT_OPT1)
	elif d177 <= 0:
		_disable(opt[1], TXT_OPT1_DIS_A)
	else:
		_disable(opt[1], TXT_OPT1_DIS_B)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var usa_power := ws.empires[EmpireData.USA].power if ws.empires.size() > EmpireData.USA \
			and ws.empires[EmpireData.USA] != null else 0
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
			and ws.empires[EmpireData.USSR].power < usa_power:
		_add(177, 1)
	if _c45_is_socialist():
		_add(176, 1)
	if _c84_is_socialist():
		_add(176, 1)
	var c84 := ws.get_country_by_legacy_index(84)
	if c84 != null and c84.sub_government == 7:
		_add(177, 1)
	if c84 != null and c84.sub_government == 9:
		_add(177, 2)
	var c20 := ws.get_country_by_legacy_index(20)
	if c20 != null and c20.special == 1:
		_add(177, 1)
	if c20 != null and c20.parts.size() > 0 and c20.parts[0]:
		_add(177, 1)
	if _c86_is_socialist():
		_add(176, 1)
	if _c87_is_socialist():
		_add(176, 1)
	if _c86_is_authoritarian():
		_add(177, 1)
	if _c87_is_authoritarian():
		_add(177, 1)
	if _c21_is_socialist():
		_add(176, 2)
	if _c21_is_authoritarian():
		_add(177, 3)
	if _mod_active(3):
		_add(176, -1)
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
			and ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null \
			and ws.empires[EmpireData.USSR].power >= ws.empires[EmpireData.USA].power:
		_add(176, 1)
	var italy := ws.get_country_by_legacy_index(85)
	if italy != null and italy.level_of_development <= 60 and italy.level_of_development >= 20:
		_add(176, 2)
	var d134 := d[134] if d.size() > 134 else 0
	if d134 < 60 and d134 >= 20:
		_add(176, 1)
	elif d134 < 100 and d134 >= 60:
		_add(176, -3)
	elif d134 >= 100:
		_add(176, -999)
	if d.size() > 177 and d[177] > 1:
		_add(176, -1)
	if opt == 0:
		_add(176, 3)
		_add(181, 2)
	elif opt == 1:
		_add(177, 2)
	if d.size() > 177 and d.size() > 176 and d[177] < 0 and d[176] < 0:
		if italy != null:
			italy.government = 3
			italy.sub_government = 12
		context["result_text"] = TXT_R_COLLAPSE
	elif d.size() > 177 and d.size() > 176 and d[177] < d[176]:
		if italy != null:
			italy.government = 2
			italy.sub_government = 8
			italy.influence_china = 1
		context["result_text"] = TXT_R_LEFT
	else:
		if italy != null:
			italy.influence_nato = 1
		context["result_text"] = TXT_R_RIGHT


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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _mod_active(idx: int) -> bool:
	var w := ws if ws != null else GameManager.world
	return w != null and w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


func _set_leader_from(p: PoliticianData) -> void:
	if ws.leader == null or p == null:
		return
	ws.leader.name_display = p.name_display
	ws.leader.name_first = p.name_first
	ws.leader.name_last = p.name_last
	ws.leader.trait_personality = p.trait_personality
	ws.leader.trait_background = p.trait_background
	ws.leader.trait_alignment = p.trait_alignment
	ws.leader.trait_special = p.trait_special
	ws.leader.age = p.age
	ws.leader.face_type = p.face_type
	if p.face_parts.size() >= 8:
		ws.leader.face_parts = p.face_parts.duplicate()
	ws.leader.jacket = p.jacket


func _c45_is_socialist() -> bool:
	var c := ws.get_country_by_legacy_index(45)
	return c != null and (c.government == 2 or ws.is_socialism(c, true))


func _c84_is_socialist() -> bool:
	var c := ws.get_country_by_legacy_index(84)
	return c != null and (c.government == 2 or ws.is_socialism(c, true))


func _c86_is_socialist() -> bool:
	var c := ws.get_country_by_legacy_index(86)
	return c != null and (c.government == 2 or ws.is_socialism(c, true))


func _c87_is_socialist() -> bool:
	var c := ws.get_country_by_legacy_index(87)
	return c != null and (c.government == 2 or ws.is_socialism(c, true))


func _c21_is_socialist() -> bool:
	var c := ws.get_country_by_legacy_index(21)
	return c != null and (c.government == 2 or ws.is_socialism(c, true))


func _c86_is_authoritarian() -> bool:
	var c := ws.get_country_by_legacy_index(86)
	return c != null and ws.is_authoritarian(c)


func _c87_is_authoritarian() -> bool:
	var c := ws.get_country_by_legacy_index(87)
	return c != null and ws.is_authoritarian(c)


func _c21_is_authoritarian() -> bool:
	var c := ws.get_country_by_legacy_index(21)
	return c != null and ws.is_authoritarian(c)

