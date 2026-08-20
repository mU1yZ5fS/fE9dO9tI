extends "res://数据脚本/event_script_base.gd"

## 原作 Event597.cs：社会主义，亦或死亡（冈比亚革命，三选项）。
## 触发：ReqEventForDLC02.cs:839-841 —— DATE_AFTER 1981.7.30；fire_only_once 承担 !event_done[597]。
## 差异：proprc→亲中；Gosstroy→government；原版 puppetOf=21 照抄（项目按原版序号存宗主）。

const TXT_OPT0_DIS := "这与我们无关……"
const TXT_OPT1_DIS := "我们鞭长莫及…"
const TXT_R0 := "1981年7月31日午夜，三百名塞内加尔伞兵在冈比亚西海岸詹布尔村登陆，向首都班珠尔进发。在云杜姆机场，他们与叛乱者展开了交火，尽管叛军的抵抗比预想的要强大，最终还是被攻破。与此同时，近三千名塞内加尔特遣队乘坐重型装甲车从南部开往班珠尔、布里卡马和塞瑞库达。在人民日报上，我们热烈欢呼了“非洲大陆的又一场社会主义革命”的发生。\n然而，在塞内加尔的压倒性优势下，萨尼扬和他的支持者自然不会有任何翻盘的机会。几天之内，叛军就彻底被镇压，乌斯曼·博容在战斗中阵亡，萨尼扬被迫流亡，据事后统计，有数百人死亡，三千多名涉嫌参与叛乱者被捕，连合法反对党领袖也被绳之以法。直到起义军被镇压，我们的援助都没有顺利送达。而贾瓦拉在回国后就立即同塞内加尔签订了合作条约，统一两国的军队与货币，成立塞内冈比亚邦联，该邦联自然是塞内加尔主导的。贾瓦拉同我国断绝了外交关系，并再次同中华民国复交。"
const TXT_R1 := "1981年7月31日午夜左右，三百名塞内加尔伞兵在冈比亚西海岸詹布尔村附近登陆，向首都班珠尔进发。在中途，他们遭遇了几内亚比绍空降兵的攻击。与此同时，近三千名塞内加尔特遣队乘坐重型装甲车从南部开往班珠尔、布里卡马和塞瑞库达，塞古·杜尔与路易斯·卡布拉尔严厉谴责了“塞内加尔对他国的侵略”行径，并在我们的支持下，于他们国家与塞内加尔的边境集结了一支规模庞大的联合部队。在塞内加尔干涉军开入冈比亚后，联军向塞内加尔发起了进攻。但愿他们能取得胜利。"
const TXT_WAR_NAME := "冈比亚战争"
const TXT_WAR_SIDE1 := "几内亚-几比联军"
const TXT_WAR_SIDE2 := "塞内加尔"
const TXT_R2 := "1981年7月31日午夜，三百名塞内加尔伞兵在冈比亚西海岸詹布尔村登陆，向首都班珠尔进发。在云杜姆机场，他们与叛乱者展开了交火，尽管叛军的抵抗比预想的要强大，最终还是被攻破。与此同时，近三千名塞内加尔特遣队乘坐重型装甲车从南部开往班珠尔、布里卡马和塞瑞库达。在塞内加尔的压倒性优势下，萨尼扬和他的支持者自然不会有任何翻盘的机会。几天之内，叛军就彻底被镇压，乌斯曼·博容在战斗中阵亡，萨尼扬被迫流亡，据事后统计，有数百人死亡，三千多名涉嫌参与叛乱者被捕，连合法反对党领袖也被绳之以法。而贾瓦拉在回国后就立即同塞内加尔签订了合作条约，统一两国的军队与货币，成立塞内冈比亚邦联，而该邦联自然是塞内加尔主导的。很显然，没有人会在意这个人口稀少且面积狭小的小国所发生的事情…"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 3
	var guinea_bissau := world.get_country_by_legacy_index(114)
	var opt := event_def.options
	if line < 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line < 2 and guinea_bissau != null and guinea_bissau.has_tag("亲中") and guinea_bissau.government == GameConstants.Government.SOCIALIST:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var gambia := _country(113)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if gambia != null:
				gambia.puppet_of = 21
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, -100)
			ws.influence_prc -= 10
		1:
			context["result_text"] = TXT_R1
			_start_war(52, TXT_WAR_NAME, TXT_WAR_SIDE1, TXT_WAR_SIDE2, 600, 400, 1, 0, 24)
			if gambia != null:
				_set_part(gambia, 0, true)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -80)
		2:
			context["result_text"] = TXT_R2
			if gambia != null:
				gambia.puppet_of = 21






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

func _foreign_minister_name() -> String:
	if ws != null and ws.politics_positions.size() > 2:
		var idx: int = ws.politics_positions[2]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
				and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return "黄华"

func _war_going(war_id: int) -> bool:
	var war := _get_war(war_id)
	return war != null and war.is_going

func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)

func _establish_prosoviet(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲苏", true)
	c.set_tag("亲中", false)
	c.set_tag("亲美", false)

func _start_war(war_id: int, war_name: String, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, tick_time: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	var war := _get_war(war_id)
	if war != null:
		war.name_war = war_name
		war.fortnight_max = tick_time

func _free_puppets(overlord: int) -> void:
	if ws == null:
		return
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			c.puppet_of = -1


