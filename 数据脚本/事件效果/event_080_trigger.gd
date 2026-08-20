extends RefCounted

const W = preload("res://数据脚本/world_state.gd")

## Event80 复杂触发钩子（EventDef.trigger_script 调用 evaluate(world) -> bool）。
## 对齐 TimeScript.cs:10637-10650 的两条 OR 分支：
##   日期 = (月>=9 且 年>=1982) || 年>=1983
##   A = (data.mao_history_line==1 || data.mao_history_line==2) && (!event_done[503] || resultOfEvents[503]!=0)
##   B = modifies[3].active && modifies[6].active && leader(name_1==2,name_2==2)
##       && NumberOfPolitician(0,0)>=0 && (3,3)>=0 && (4,4)>=0 && (5,5)>=0
## event_done[80] 由 fire_only_once 承担；result503 用 completed_event_ids
## 缺省 -1（原版缺省 0），(not done503) 时 A 恒真、与缺省无关。


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world
	if data.size() <= W.I_YEAR:
		return false
	var date_ok := (data.month >= 9 and data.year >= 1982) or data.year >= 1983
	if not date_ok:
		return false
	# 分支 A
	var done503: bool = world.completed_event_ids.has("event_503")
	var result503: int = world.completed_event_ids.get("event_503", -1)
	var a_ok := false
	if data.size() > W.I_MAO_HISTORY_LINE:
		var mhl := data.mao_history_line
		a_ok = (mhl == 1 or mhl == 2) and (not done503 or result503 != 0)
	if a_ok:
		return true
	# 分支 B
	if not _mod_active(world, 3) or not _mod_active(world, 6):
		return false
	if world.leader == null or world.leader.name_first != 2 or world.leader.name_last != 2:
		return false
	for pair in [[0, 0], [3, 3], [4, 4], [5, 5]]:
		if _find_politician(world, pair[0], pair[1]) < 0:
			return false
	return true


func _mod_active(world: WorldState, index: int) -> bool:
	return index >= 0 and index < world.modifiers.size() \
		and world.modifiers[index] != null and world.modifiers[index].is_active


func _find_politician(world: WorldState, name_first: int, name_last: int) -> int:
	for i in world.politicians.size():
		var p: PoliticianData = world.politicians[i]
		if p != null and p.name_first == name_first and p.name_last == name_last:
			return i
	return -1
