class_name StatusBarViewModel
extends "res://数据脚本/ui/game_view_model.gd"

## 状态数值区 ViewModel。
## 负责从 WorldState 计算展示数据，并订阅 GameManager 的刷新信号。
## UI 只读取 get_values()，不直接访问 GameManager.world。

const W = preload("res://数据脚本/world_state.gd")


## 返回状态栏展示数据字典。
func get_values() -> Dictionary:
	var values := {}
	var gm: Node = _gm
	if gm == null:
		return values
	var w: WorldState = gm.world
	if w == null:
		return values
	w.sync_economy()
	if w.玩家经济 == null:
		return values
	var eco := w.玩家经济
	values["党内支持度"] = "%.1f" % eco.党内支持度
	values["人民支持度"] = "%.1f" % eco.民众支持度
	values["思想自由度"] = "%.1f" % eco.思想自由度
	values["生活水平"] = "%.1f" % eco.生活水平
	values["国际声望"] = "%.1f" % eco.国际声望
	values["特工网络"] = "%.1f" % (float(eco.特工网络) / 10.0)
	values["全球影响力"] = "%.1f" % eco.全球影响力
	values["预算"] = "%.1f" % (float(eco.预算) / 10.0)
	if w.empires.size() >= 2:
		values["与美国关系"] = w.display_relation(w.empires[0].relations)
		values["与苏联关系"] = w.display_relation(w.empires[1].relations)
	return values
