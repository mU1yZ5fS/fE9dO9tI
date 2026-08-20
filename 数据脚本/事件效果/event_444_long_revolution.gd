extends "res://数据脚本/event_script_base.gd"

## 原作 Event444.cs：漫长的革命（2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:442-445 —— modifies[3] 且 modifies[6] 且 modifies[11] 且 年>=1985 且 !is_gkchp（.tres ExprNode 表达）。
## 差异：doctr[] 显示文案表建模说明，跳过；traits[0]→trait_personality、traits[1]→trait_alignment；
##   loyality→loyalty；KillPerson→PoliticianSystem.kill_politician（同槽补员，先收集下标再杀）。




const TXT_R0 := "根据中央委员会的决议，我们的党决定开始逐步放松过去因为需要引导群众而采取的政策，实施真正的无产阶级大民主！在政治方面，各个革命委员会依靠造反派群众组织，开始改组为类似巴黎公社的体制；审查方面，由群众选举的审查委员会和党的干部共同审查的制度，过去仅供内部放映的内参片正在公开上映，交由群众批判；社会上，大字报、大辩论再次活跃于街头各处，这是和资产阶级的“自由”完全不同的风气……新一轮变革正在开始，无产阶级文化大革命进入了新的阶段！"
const TXT_R1 := "现在还没有到那种程度，我们的国家和党还没有做好准备迎接那种状况。这种保守姿态令党内左派和革命群众感到不满，甚至有人开始贴大字报批评党中央的“右倾”......"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var data := world.数值表
	var opt := event_def.options
	var cond := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active \
			and data[W.I_POLITICAL_LINE] < 1 \
			and int(world.completed_event_ids.get("event_307", -1)) == 2 \
			and int(world.completed_event_ids.get("event_111", -1)) == 1
	if cond:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable_blank(opt[0])
	_enable(opt[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# 原版 doctr[6]/doctr[19]/doctr[24] 为显示文案表赋值，Godot 建模说明，跳过。
			d[W.I_PEOPLE_SUPPORT] = 1000
			d[W.I_PARTY_SYSTEM] = 6
			d[W.I_PRESS_POLICY] = 19
			d[W.I_RELIGION] = 24
			_add(W.I_PARTY_SUPPORT, 300)
			ws.influence_prc += 100
			var kill_list: Array[int] = []
			for i in ws.politicians.size():
				var p: PoliticianData = ws.politicians[i]
				if p != null and (p.trait_alignment == 40 or p.trait_alignment == 41):
					kill_list.append(i)
			for i in kill_list:
				PoliticianSystem.kill_politician(i)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == 0:
					p.loyalty += 1000
				elif p.trait_personality == 1:
					p.loyalty -= 300
				elif p.trait_personality == 2:
					p.loyalty -= 700
				elif p.trait_personality == 3:
					p.loyalty -= 1000
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PEOPLE_SUPPORT, -200)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == 0:
					p.loyalty -= 1000
				elif p.trait_personality == 1:
					p.loyalty += 300
			context["result_text"] = TXT_R1


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


func _disable_blank(opt: EventOption) -> void:
	opt.text = ""
	opt.disabled_text = ""
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n








func _modifier_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active


func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)
