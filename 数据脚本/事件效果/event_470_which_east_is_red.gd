extends "res://数据脚本/event_script_base.gd"

## 原作 Event470.cs：哪个东方才是红色的（单选项）。
## 触发：GlobalScript.cs:29 的 Decision 链 StartEvent(470)（决议系统移植说明）。
##   按项目约定 trigger_conditions=[]（仅定义，待决策系统接入）。
## 差异：proprc→亲中。

const TXT_R0 := "次日，波兰，匈牙利与罗马尼亚宣布退出华沙条约组织和经济互助委员会，转而加入中国的组织。南斯拉夫也表现出了愿意加入我们阵营的意向。苏联对此极为不满，强烈谴责了我国是在搞“大国沙文主义”“谋图分裂苏联与东欧人民的友好关系”。\n先前在北京与地拉那设立办公处的苏联革命共产党（布尔什维克）在华沙和布加勒斯特开张了前线办公处，借助这两个国家的宣传机构。北京之声也开始向苏联东部地区播音，借助“改革”和“开放性”政策的春风，全联盟共产党得以在一些偏远地区得到支持者。甚至组建一些地区人民委员会并开始训练“人民卫队”作为准军事武装。\n我们也开始了一项雄心勃勃的计划，旨在苏联发生灾难性事件后能够快速驰援。波兰将负责支持波罗的海三国和白俄罗斯的革命，匈牙利与罗马尼亚将干涉乌克兰可能爆发的内乱。伊朗和阿富汗将压制苏联南部的伊斯兰势力。而我们在必要情况下将会亲自下场，旨在全面压制苏联的危机。\n这一次，我们将从苏联人的手中拯救苏联。"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_set_relation(EmpireData.USSR, 0)
			var poland := _country(4)
			if poland != null:
				poland.government = 1
				poland.sub_government = 2
				poland.set_tag("亲中", true)




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


