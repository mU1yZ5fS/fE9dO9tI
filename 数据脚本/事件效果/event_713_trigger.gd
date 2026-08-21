extends RefCounted

## Event713 复杂触发钩子（EventDef.trigger_script 调用 evaluate(world) -> bool）。
## 对齐 TimeScript.cs EventsRequirements()：
##  - 10034-10040 的事件 713 分支；
##  - 9979-10018 分支上方预计算的 array / flag / num 统计。
## 原版条件：
##   allcountries[80].SubGosstroy==17 && allcountries[44].SubGosstroy==17
##   && (allcountries[19].SubGosstroy==17 || ==0)
##   && flag（array 中任一 IsSocialism(true) 且 SubGosstroy==17）
##   && num>=3（array 中 IsSocialism(true) 命中数）
##   && (!modifies[6].active || IsSocialism(false, 1))
##   && !event_done[713]（由 EventDef.fire_only_once 承担）
##   && !event_done[548]（548 端口后 event_id 约定为 "event_548"）
##   && !completedDecisions[10]
##   && !events[0].activeSelf（原版地图标记互斥；Godot 每 tick 只触发一个，等价）
## array = {85,86,87,21,92,29,17,45,84,0,27,28,88,89,90,91,26}
const ARRAY := [85, 86, 87, 21, 92, 29, 17, 45, 84, 0, 27, 28, 88, 89, 90, 91, 26]


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	# 预统计：flag / num（原版 TimeScript.cs:9979-10018）
	var num := 0
	var flag := false
	for legacy_index in ARRAY:
		var c := world.get_country_by_legacy_index(legacy_index)
		if c == null:
			continue
		if world.is_socialism(c, true):
			num += 1
			if c.sub_government == GameConstants.SubGovernment.MAOIST:
				flag = true
	var c80 := world.get_country_by_legacy_index(80)
	var c44 := world.get_country_by_legacy_index(44)
	var c19 := world.get_country_by_legacy_index(19)
	if c80 == null or c44 == null or c19 == null:
		return false
	if c80.sub_government != GameConstants.SubGovernment.MAOIST:
		return false
	if c44.sub_government != GameConstants.SubGovernment.MAOIST:
		return false
	if c19.sub_government != GameConstants.SubGovernment.MAOIST and c19.sub_government != GameConstants.SubGovernment.LEFT_RADICAL:
		return false
	if not flag:
		return false
	if num < 3:
		return false
	# (!modifies[6].active || IsSocialism(false, 1))
	if world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active:
		var china := world.get_country_by_legacy_index(1)
		if china == null or not world.is_socialism(china, false):
			return false
	# !event_done[548]：后续移植约定事件 ID 为 "event_548"
	if world.completed_event_ids.has("event_548"):
		return false
	# !completedDecisions[10]
	if world.decisions != null and world.decisions.completed.size() > 10 and world.decisions.completed[10]:
		return false
	return true
