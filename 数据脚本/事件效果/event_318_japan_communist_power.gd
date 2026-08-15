extends "res://数据脚本/event_script_base.gd"

## 原作 Event318.cs：我们的势力会在日本掌权吗？（3选项）。
## 触发：全目录搜索无 this_num_event = 318 / Reset(318) / StartEvent(318)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：选项显隐 prepare 动态改写；Gosstroy/SubGosstroy→government/sub_government；name→chinese_name；proprc/Vyshi→亲中/亲美标签。

const TXT_TITLE := "我们的势力会在日本掌权吗？"
const TXT_DESC := "近些年来，中日两国关系十分密切，我们的情报部门在旭日之国的影响力越来越大。我党甚至可以影响日本国内政治......还可以让与我们更为亲密的人上台。一方面，日本共产党与我们的关系更为密切，但该党内部可谓矛盾重重，一边是前激进分子、现积极信奉改革思想和奉行机会主义的宫本显治领导的右倾分子，另一边是由我们的老朋友、抗日战争期间的解放军战士野坂参三领导的亲中反君主制的温和左翼势力。另一方面，我们还能选与军队关系密切的日本民族主义者，当然，他们是法西斯分子。但换个角度，他们对美国持强烈的负面态度，会同意与我们合作。"
const TXT_NAME_EMPIRE := "日本帝国"
const TXT_NAME_RED := "赤色日本"
const TXT_OPT0 := "我们没有足够的预算"
const TXT_OPT1 := "让日共上台"
const TXT_OPT1_DIS := "和解不可接受。"
const TXT_OPT2 := "让军国主义者上台"
const TXT_OPT2_DIS := "和解不可接受。"
const TXT_R0 := "当然，日本领导层的更迭对我们有用，但不幸的是，此举会使该地区的局势不稳定，也肯定不会有什么好事发生，美国还将做出极其消极的反应。"
const TXT_R1 := "借助我们大笔的经济援助，日共成功赢得竞选，并组建了一党政府。起初，一切都非常不稳定——党派分裂，资产阶级问题，美国不愿撤军。但如今，日本正在建设社会主义，往昔日本国旗旁飘扬着星条旗的地方，现已升起了我们的红旗。"
const TXT_R2 := "夜间，日本坦克进入了东京及各大城市。第二天早上，全体日本政府成员在电视直播中被枪决。美军基地被封锁，美军也被迫撤离。受害者的人数尚未公布，但据我们的情报，受害者至多两三千。当然，新政府宣称要走向民族主义和独立，但在被国际孤立的背景下，他们被迫与我们合作，即使这对他们来说不是很愉快。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	if data.size() <= W.I_RELIGION:
		return
	var opt := event_def.options
	var japan := world.get_country_by_legacy_index(44)
	_enable(opt[0], TXT_OPT0)
	if japan != null and japan.government < 3:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if data[W.I_WAR_SUPPORT] >= 700 or (data[W.I_IDEOLOGY] <= 0 and data[W.I_RELIGION] > 27 and data[W.I_ECON_SYSTEM] > 11):
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_DIPLO, 100)
			_add(W.I_INFLUENCE, 100)
			_add_power(0, -100)
			_add_relation(0, -500)
			var japan := ws.get_country_by_legacy_index(44)
			if japan != null:
				japan.government = 1
				japan.sub_government = 1
				japan.chinese_name = TXT_NAME_RED
				japan.set_tag("亲中", true)
				japan.set_tag("亲美", false)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -150)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_DIPLO, 50)
			_add(W.I_INFLUENCE, 100)
			_add_power(0, -100)
			_add_relation(0, -500)
			var japan := ws.get_country_by_legacy_index(44)
			if japan != null:
				japan.government = 0
				japan.sub_government = 9
				japan.chinese_name = TXT_NAME_EMPIRE
				japan.set_tag("亲中", true)
				japan.set_tag("亲美", false)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -150)
			context["result_text"] = TXT_R2

	
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

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta
