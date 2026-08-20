extends "res://数据脚本/event_script_base.gd"

## 原作 Event620.cs：让我们在幸福的大路上迈开步伐（赤道几内亚解放，单选项）。
## 触发：无自动触发点——原版由 DiploButtonScript.cs:4678-4680（this_type 外交按钮）手动 number_event=620。
## 差异：结果页标题与事件标题原版不同（大陆/大路），execute 设置 result_title；proprc→亲中。

const TXT_TITLE_RESULT := "让我们在幸福的大陆上迈开步伐"
const TXT_R0 := "在喀麦隆和加蓬的多面攻击下，赤道几内亚军队迅速溃退，最终两国联军占领了整个赤道几内亚。多亏了马西埃长期的反智教育，赤道几内亚军队质量堪忧，整场行动伤亡人数不超百人，奥比昂·恩圭马被抓捕并被枪毙，马西埃的尸体被挖出来重新公审再枪毙，整个恩圭马家族统统关进大牢中，马西埃在其家乡所建造的别墅则被充公，部分奢侈品则被拍卖以换取外汇来购买工业农业设备。新政府由流亡到刚果（布）的左翼组织几内亚国家和人民解放阵线（FRENAPO）组建，秘书长赫苏斯·姆巴·奥沃诺担任总统。整个赤道几内亚由于恩圭马家族的统治而变得落后不堪，为了使得赤道几内亚发展起来，非盟开始为赤道几内亚提供大量低息贷款，喀麦隆和加蓬的部分军队在此驻扎混编成为非盟维和部队并一直持续到赤道几内亚社会秩序稳定为止。FRENAPO开始按照各社会主义国家的宪法来建立出属于自己的宪法，逐步进行扫盲教育和无神论教育，以求去除马西埃的神化所造成的影响，并对被屠杀的各少数民族和知识分子进行平反和纪念；将国内的官僚资本全部充公，并学习坦桑尼亚的乌贾马运动，逐步建设农村合作社。FRENAPO还预计在数年之后进行一次关于是否并入喀麦隆的全民公投，但是由于赤道几内亚的现状，并入喀麦隆的可能性将会很大。"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var eq_guinea := _country(115)
	var opt := int(context.get("option_index", -1))
	context["result_title"] = TXT_TITLE_RESULT
	match opt:
		0:
			context["result_text"] = TXT_R0
			if eq_guinea != null:
				eq_guinea.government = 1
				eq_guinea.sub_government = 1
				_leave_alliances(eq_guinea)
				eq_guinea.set_tag("对华贸易", true)
				eq_guinea.set_tag("亲中", true)
			_add_relation(EmpireData.USA, -150)






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


