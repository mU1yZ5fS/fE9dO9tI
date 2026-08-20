extends "res://数据脚本/event_script_base.gd"

## 原作 Event456.cs：高考？高考！（教育路线三选项）。
## 触发：全目录无 this_num_event=456 / StartEvent(456)；仅各系统读 event_done[456]/resultOfEvents[456]
##   做显示分支。按项目约定 trigger_conditions=[]（仅定义，待外部入口接入）。
## 差异：politic.traits[0]→trait_personality；原版随后改写 old_modify_desc[2] 的
##   大段修正描述为显示层文案，按项目约定跳过（display-only）。

const TXT_OPT0_DIS := "恢复高考？你想和毛主席的七·二一指示对着干吗？"
const TXT_OPT1_DIS_A := "现在的制度有什么问题？"
const TXT_OPT1_DIS_B := "这还不如不改！"
const TXT_OPT2_DIS := "总得来点变化，对吧？"
const TXT_R0 := "中共中央和教育部颁布了一项通报，宣布将恢复自66年终止的全国高校统一招生考试。1977年10月21日，人民日报头版头条《高等学校招生进行重大改革》，宣布中断了十余年的高考将恢复考试，这一消息迅速传遍了全国各地。\n1977年冬天，举行了恢复高考后的第一次考试，考试分为文史与理工两科，文史类科目是思想政治、语文、数学、史地（历史和地理），理工类科目是政治、语文、数学、理化（物理和化学），报考外语专业的要加试外语。\n全国各地的考生对此投来了热切的目光，这是一个时代的终结，也是一个时代的开始。"
const TXT_R1 := "中共中央和教育局决定引入预科制度。这将作为工农兵大学生的替代品，在每个学生接受了“工人农民和解放军的再教育”之后。他们将继续接受高等院校的教育（当然他们也可以选择结束教育，并得到专科学历）。这给了一些愿意为祖国做贡献的青年人接受进一步教育的机会，同时这也顾及到了一些高级知识份子的脸面。\n总体来说，这一方案刚刚好，反对的人不多，赞同的人不少。"
const TXT_R2 := "我们必须承认现在的这些政策的确不妥，但这不是问题的核心。一旦恢复高考制，上海和北京这样的大都市和石河子，克拉玛依这样的地方的差距只会越来越大。高考制不会利好无产阶级，只会构建一批新的脱产者，他们不学无术，只会给祖国带来问题却不想着解决。而太多学校一听到要招收农民和工人子弟就难受的不得了，这难道是正确的吗？我们应该让更多优秀的高等教育机构进一步深入农村。而推荐制可以为我们找到最优秀的无产者，他们肯融入无产者，也愿意接受新知识。难道一个因为生产队长没时间复习，就一定表明他是个差生吗？恰恰相反！他只是想更好的建设农村，为无产阶级文化大革命添砖加瓦。而试图为高考辩护的人才是真正的资产阶级，恢复高考就是资产阶级对无产阶级的反扑，我们必须要说不！"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line56 := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var opt := event_def.options
	if not mod3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line56 >= 1 and line56 < 3 and not mod3:
		_enable(opt[1], event_def.options[1].text)
	elif mod3 or line56 == 0:
		_disable(opt[1], TXT_OPT1_DIS_A)
	else:
		_disable(opt[1], TXT_OPT1_DIS_B)
	if line56 == 0 or mod3:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			for p in ws.politicians:
				if p != null:
					if p.trait_personality == 0:
						p.power -= 10
					elif p.trait_personality == 2 or p.trait_personality == 3:
						p.power += 20
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, 100)
		1:
			context["result_text"] = TXT_R1
			for p in ws.politicians:
				if p != null:
					if p.trait_personality == 0:
						p.power -= 5
					elif p.trait_personality == 2:
						p.power += 5
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 100)
		2:
			context["result_text"] = TXT_R2
			for p in ws.politicians:
				if p != null:
					if p.trait_personality == 0:
						p.power += 10
					elif p.trait_personality == 3 or p.trait_personality == 4:
						p.power -= 5
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, 50)




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)


func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


