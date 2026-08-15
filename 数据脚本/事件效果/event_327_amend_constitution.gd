extends "res://数据脚本/event_script_base.gd"

## 原作 Event327.cs：修宪？（2选项）。
## 触发：全目录搜索无 this_num_event = 327 / Reset(327) / StartEvent(327)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：party_ideology→factions[i].ideology；文本来自 Events_text_en 索引 245-250。

const TXT_TITLE := "修宪？"
const TXT_DESC := "在1978年的旧宪法中，带有革命浪漫色彩与“革命委员会”风格的名词比比皆是。但是我们的革命已经结束了，我们想要韬光养晦，而在此过程中，革命的悲情和浪漫就显得不太合适了。也许去掉这些名词，用更枯燥些的文字取而代之是值当的？很明显，保留这些名词将表明极左派在政治舞台上仍占据一席之地。如果这些名词被除掉了，党和人民就会明白我们站在改革派一边。"
const TXT_OPT0 := "就这样吧。"
const TXT_OPT1 := "将其移除。"
const TXT_R0 := "拒绝革命用语就是拒绝革命！不得改变人民宪法！"
const TXT_R1 := "为什么我们需要这些早在四十年代便已沦为空谈的词汇？只有那帮妄图破坏社会稳定、合法谋杀他人的激进分子才需要这些东西！"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_faction_ideology(0, 50)
			_add_faction_ideology(1, 10)
			_add_faction_ideology(2, 5)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == 0:
					p.power += 25
				elif p.trait_personality > 1:
					p.loyalty -= 25
			context["result_text"] = TXT_R0
		1:
			_add_faction_ideology(2, 10)
			_add_faction_ideology(3, 10)
			_add_faction_ideology(4, 50)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == 4:
					p.power += 25
				elif p.trait_personality < 2:
					p.loyalty -= 25
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

func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta

func _add_faction_support(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].support += delta

func _add_faction_ideology(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].ideology += delta
