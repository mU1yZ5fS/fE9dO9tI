extends "res://数据脚本/event_script_base.gd"

## 原作 Event327.cs：修宪？（2选项）。
## 触发：全目录搜索无 this_num_event = 327 / Reset(327) / StartEvent(327)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：party_ideology→factions[i].ideology；文本来自 Events_text_en 索引 245-250。

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

	


func _add_faction_support(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].support += delta

func _add_faction_ideology(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].ideology += delta
