extends "res://数据脚本/event_script_base.gd"

## 原作 Event678.cs：你正在进入自由德里（北爱尔兰动乱，单选项）。
## 触发：ReqEventsDLC02.cs:1461-1464 —— !ev673 && !c29.parts[0] && !c166.parts[0]
##   && (d162/163/164/166 任一>=100) && DATE_AFTER 1979.8.27 → trigger_script evaluate。
## 差异：data.get_data_by_index(162-166) raw index；BritLost→get_flag；ingamewars[86] 兜底创建后补名。

const TXT_DESC_A := "贝尔法斯特的街头再也没有虚假的和平，狙击手在行动，爆炸声此起彼伏，时不时就能传来自动步枪和机枪的声音。终于，一切虚假的和平被一枚共和军士兵的火箭弹击碎了。他们袭击了北爱尔兰英军最高指挥官的车队，理查德·罗森将军和同行的安保人员当场殒命。以此为号，南阿马地区和斯特拉班爆发了大规模的反抗英军士兵的暴乱。贝尔法斯特更是出现了共和军士兵与INLA成员同时对英军发动袭击的空前盛况，UDA，UVF与其他忠诚派也不甘示弱，走上街头和天主教徒们打成一团。爱尔兰抵抗组织们在都柏林宣布为这次袭击负责，并高呼一切留在被占领的北爱尔兰的爱国志士，全世界热爱自由的人们都站起来支持他们的斗争。唐宁街十号宣布在北爱尔兰额外增派约3000人的兵力，并授权皇家阿尔斯特警察使用致命武器。北爱尔兰的动乱已经达到了新的高峰，看起来这就是一场你死我活的斗争……"
const TXT_DESC_B_PRE := "贝尔法斯特的王室特派专员们已经陷入了绝望之中，一支异军突起的马克思主义者正在整个阿尔斯特攻城略地，运用毛的游击战思想分割包围，再加以恐怖手段钳制百姓。"
const TXT_DESC_THATCHER := "撒切尔内阁完全无法接受北爱尔兰大部分被马克思主义者所占领的事实"
const TXT_DESC_LABOUR := "工党内阁成为了街头抗议所要打倒的修正主义者"
const TXT_DESC_OTHER := "英国内阁不得不惊恐的看向自己即将失效的阿尔斯特政策"
const TXT_DESC_B_TAIL := "，在窘境之下，唐宁街十号宣布向当地额外增兵。终于，一切虚假的和平被一枚共和军士兵的火箭弹击碎了。他们袭击了北爱尔兰英军最高指挥官的车队，理查德·罗森将军和同行的安保人员当场殒命。以此为号，南阿马地区和斯特拉班爆发了大规模的反抗英军士兵的暴乱。贝尔法斯特更是出现了共和军士兵与INLA成员同时对英军发动袭击的空前盛况，UDA，UVF等忠诚派民兵也不甘示弱，走上街头和天主教徒们打成一团。爱尔兰抵抗组织们在都柏林宣布为这次袭击负责，并高呼一切留在被占领的北爱尔兰的爱国志士，全世界热爱自由的人们都站起来支持他们的斗争。BICO正式动员起了其所占领的北爱尔兰领土，并正式成立了阿尔斯特民主共和国临时政府。让战火烧起来吧。"
const TXT_R0 := "这会又是一场战争的前兆吗？"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	if int(ws.completed_event_ids.get("event_677", 0)) != 4:
		event_def.description = TXT_DESC_A
		return
	var branch := TXT_DESC_OTHER
	var data147 := d.britain_political_route if d.size() > 147 else 0
	if data147 == 5:
		branch = TXT_DESC_THATCHER
	elif data147 == 3 or data147 == 6 or data147 == 8:
		branch = TXT_DESC_LABOUR
	event_def.description = TXT_DESC_B_PRE + branch + TXT_DESC_B_TAIL


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	var num := 100 if ws.get_flag("BritLost") else 0
	for idx in [162, 163, 164, 166]:
		if d.size() > idx and d.get_data_by_index(idx) >= 100:
			d.set_data_by_index(idx, 100)
	context["result_text"] = TXT_R0
	# 原版 ingamewars[86]：北爱尔兰冲突，爱尔兰武装(400-num) vs 英国(600+num)，AmericanSupportDefender
	game.start_war(86, "爱尔兰武装", "英国", 400 - num, 600 + num, 2, -1)
	if ws.wars.size() > 86 and ws.wars[86] != null:
		ws.wars[86].name_war = "北爱尔兰冲突"
	var ireland := ws.get_country_by_legacy_index(29)
	if ireland != null:
		_set_part(ireland, 1, true)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19790827:
		return false
	if world.completed_event_ids.has("event_673"):
		return false
	var ireland := world.get_country_by_legacy_index(29)
	if ireland != null and ireland.parts.size() > 0 and ireland.parts[0]:
		return false
	var northern := world.get_country_by_legacy_index(166)
	if northern != null and northern.parts.size() > 0 and northern.parts[0]:
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	for idx in [162, 163, 164, 166]:
		if d.size() > idx and d.get_data_by_index(idx) >= 100:
			return true
	return false


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value
