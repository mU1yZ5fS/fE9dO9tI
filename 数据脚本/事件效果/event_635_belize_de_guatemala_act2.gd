extends "res://数据脚本/event_script_base.gd"

## 原作 Event635.cs：Belice de Guatemala（危地马拉军政府声索伯利兹，三选项）。
## 触发：ReqEventsDLC02.cs:981-984 —— IsAuthoritarianism(149) && BritLost && DATE_AFTER 1983.1.1。
##   IsAuthoritarianism 无单一 ExprNode → trigger_script evaluate。
## 差异：ingamewars[66] 建模说明 WarDef → GameManager.start_war 兜底创建后手工补名；
##   AmericanSupportAttacker→usa_side=1、SovietSupportDefender→ussr_side=2。

const TXT_R0 := "以凯比尔（kaibil）特种兵为主力，危地马拉军队迅速跨过两国边境，一场战争打响了。"
const TXT_R1 := "以凯比尔（kaibil）特种兵为主力，危地马拉军队迅速跨过两国边境，一场战争打响了。\n我们大力支持了伯利兹抵抗危地马拉军政府侵略的行动，向英国提供了军事支持。在新一期人民日报的头版上，大幅刊登了伯利兹的反侵略战争，盛赞了伯利兹人民抗击危地马拉扩张主义侵略的英勇举动和英军千里迢迢赶来帮助伯利兹人民反击侵略的国际主义精神。"
const TXT_R2 := "以凯比尔（kaibil）特种兵为主力，危地马拉军队迅速跨过两国边境，一场战争打响了。\n我们大力支持了危地马拉收复故土的行动，向其提供了军事支持。在新一期人民日报的头版上，大幅刊登了危地马拉统一战争，盛赞了军政府不畏强暴、敢于直面英帝而发动统一战争的魄力，而伯利兹也在文中被类比为“危地马拉的台湾”。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var guatemala := ws.get_country_by_legacy_index(149)
	var opt := int(context.get("option_index", -1))
	# 原版 :30：ResultsOfEvents 开头统一置 parts[2]
	if guatemala != null:
		_set_part(guatemala, 2, true)
	match opt:
		0:
			context["result_text"] = TXT_R0
			_start_war66(600, 400)
		1:
			context["result_text"] = TXT_R1
			_add(W.I_BUDGET, -20)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add_power(EmpireData.USA, 5)
			_start_war66(550, 450)
		2:
			context["result_text"] = TXT_R2
			_add(W.I_THOUGHT_FREEDOM, -50)
			_add_power(EmpireData.USA, 10)  # 原 :49/:52 两次 +5
			_add(W.I_BUDGET, -20)
			if guatemala != null:
				guatemala.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 80)
			_start_war66(700, 300)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19830101:
		return false
	if not world.get_flag("BritLost"):
		return false
	var guatemala := world.get_country_by_legacy_index(149)
	return guatemala != null and world.is_authoritarian(guatemala)


func _start_war66(infl1: int, infl2: int) -> void:
	# 原版 ingamewars[66]：危地马拉 vs 伯利兹，AmericanSupportAttacker、SovietSupportDefender
	GameManager.start_war(66, "危地马拉", "伯利兹", infl1, infl2, 1, 2)
	if ws.wars.size() > 66 and ws.wars[66] != null:
		ws.wars[66].name_war = "危地马拉统一战争"


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value
