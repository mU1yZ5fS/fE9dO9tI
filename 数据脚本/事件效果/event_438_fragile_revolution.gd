extends "res://数据脚本/event_script_base.gd"

## 原作 Event438.cs：脆弱的革命（2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:37-40 —— modifies[3] 且 modifies[6]，且（意识形态>=4 或 经济体制>=14 或 舆论政策>=19 或 宗教>26 或 政党制度>=8），且（!event_444 或 resultOfEvents[444]!=0），且 !event_503（.tres ExprNode 表达）。
## 差异：描述由 prepare 按 data[15]/[16]/[17]/[50] 动态拼接；politic.traits[0]→trait_personality；
##   loyality→loyalty；modifies[3]→ws.modifiers[3].is_active。


const TXT_DESC_BASE := "在毛主席死后，我们仍然设法维持了他的遗产之一——文化大革命，并持续至今，但我们近期的一些政策似乎加剧了党和人民的不满："
const TXT_DESC_PARTY := "在党政中引入过多的反对派政党，"
const TXT_DESC_ECON := "经济上私有化程度的加剧，"
const TXT_DESC_SPEECH := "对言论的管制过于放松导致资产阶级反动言论的音量越来越大，"
const TXT_DESC_RELIGION := "对宗教的管控不力导致一些反党邪教的兴起，"
const TXT_DESC_TAIL := "......；已经有越来越多反对文化大革命继续进行的声音了，对此，我们是要承认应该要让这一奇特的运动盖棺定论，还是修改一些政策使其继续进行下去呢？"


const TXT_R0 := "你说文化大革命已经完成了它的历史任务，所以你开始消灭文化大革命的最后遗产，在全国各地苟延残喘至今的相关活动开始被逐步地大规模地取消，这当然使中国人民高兴了，但党内的一些激进左派分子非常愤怒，因为这意味着毛主席自认为一生中唯二做过的事之一被彻底地盖棺定论了......"
const TXT_R1 := "我们做出了一些政策上的调整，让文化大革命得以继续维系下去，党和人民仍然是有些不满的，但也仅限于牢骚的程度，不会发展到失控的局面——至少在目前看来是如此......"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null:
		return
	var data := world.数值表
	var desc := TXT_DESC_BASE
	if data.size() > W.I_PARTY_SYSTEM and data[W.I_PARTY_SYSTEM] >= 8:
		desc += TXT_DESC_PARTY
	if data.size() > W.I_ECON_SYSTEM and data[W.I_ECON_SYSTEM] >= 14:
		desc += TXT_DESC_ECON
	if data.size() > W.I_PRESS_POLICY and data[W.I_PRESS_POLICY] >= 19:
		desc += TXT_DESC_SPEECH
	if data.size() > W.I_RELIGION and data[W.I_RELIGION] >= 27:
		desc += TXT_DESC_RELIGION
	desc += TXT_DESC_TAIL
	event_def.description = desc
	if event_def.options.size() >= 2:
		_enable(event_def.options[0], event_def.options[0].text)
		_enable(event_def.options[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if ws.modifiers.size() > 3 and ws.modifiers[3] != null:
				ws.modifiers[3].is_active = false
			_add(W.I_THOUGHT_FREEDOM, 200)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_DIPLO, -10)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == 0:
					p.loyalty -= 100
				elif p.trait_personality > 1:
					p.loyalty += 100
			context["result_text"] = TXT_R0
		1:
			_add(W.I_THOUGHT_FREEDOM, 150)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_DIPLO, 10)
			var num := 0
			if d[W.I_PARTY_SYSTEM] >= 8:
				d[W.I_PARTY_SYSTEM] = 7
				num += 1
			if d[W.I_ECON_SYSTEM] >= 14:
				d[W.I_ECON_SYSTEM] = 13
				num += 1
			if d[W.I_PRESS_POLICY] >= 19:
				d[W.I_PRESS_POLICY] = 18
				num += 1
			if d[W.I_RELIGION] >= 27:
				d[W.I_RELIGION] = 26
				num += 1
			if d[W.I_IDEOLOGY] >= 4:
				d[W.I_IDEOLOGY] = 3
			_add(W.I_BUDGET, -num * 10)
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
