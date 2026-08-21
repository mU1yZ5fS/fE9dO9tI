extends "res://数据脚本/event_script_base.gd"

## 原作 Event328.cs：新宪法（3选项）。
## 触发：全目录搜索无 this_num_event = 328 / Reset(328) / StartEvent(328)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：party_number→factions[i].support；文本来自 Events_text_en 索引 251-258。

const TXT_R0 := "我国是亚洲革命的发源地，我们不能背离为我们的未来而奋斗的先辈们的思想！我们将展现通过任何形式实现社会主义与繁荣的愿望，哪怕是现在，我国的主要任务也是维护国家稳定与人民的高生活水平。"
const TXT_R1 := "我们受够了这场革命！让我们再次成为一个冷静的大国，融入国际社会，发展对外贸易，共同繁荣！但是，我们当然不能允许疯狂的资本主义让我们的公民陷入恐惧，就像在美国那样，因此，我们必须建立一个庞大的社会保护和援助体系。"
const TXT_R2 := "所有权形式问题"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_faction_support(0, 50)
			_add_faction_support(1, 50)
			_add_faction_support(2, 25)
			context["result_text"] = TXT_R0
		1:
			_add_faction_support(2, 25)
			_add_faction_support(3, 50)
			_add_faction_support(4, 50)
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2

	


func _add_faction_support(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].support += delta

func _add_faction_ideology(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].ideology += delta
