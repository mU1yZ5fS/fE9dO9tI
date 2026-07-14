class_name TechState
extends Resource

## Tech tree progress. Mirrors the original science[34] state arrays.

const TECH_COUNT: int = 34

@export var unlocked: Array[bool] = []
@export var in_progress: Array[bool] = []
@export var elapsed_time: Array[int] = []
@export var required_time: Array[int] = []
@export var active_slot: int = -1


func _init() -> void:
	unlocked.resize(TECH_COUNT)
	in_progress.resize(TECH_COUNT)
	elapsed_time.resize(TECH_COUNT)
	required_time.resize(TECH_COUNT)


func is_researching() -> bool:
	return active_slot >= 0


func set_required_time(index: int, value: int) -> void:
	if _is_valid_index(index):
		required_time[index] = value


func can_research(index: int, science_points: int, budget: int, money_cost: int, dependency: int = -1) -> bool:
	if not _is_valid_index(index):
		return false
	if unlocked[index] or in_progress[index] or is_researching():
		return false
	if dependency >= 0 and _is_valid_index(dependency) and not unlocked[dependency]:
		return false
	return science_points > 0 and budget >= money_cost


func start_research(index: int, science_points: int, budget: int, money_cost: int = 0, dependency: int = -1) -> Dictionary:
	if not can_research(index, science_points, budget, money_cost, dependency):
		return {"ok": false, "science_points": science_points, "budget": budget}
	in_progress[index] = true
	active_slot = index
	elapsed_time[index] += science_points
	return {"ok": true, "science_points": 0, "budget": budget - money_cost}


func advance_tick() -> int:
	if active_slot < 0 or active_slot >= TECH_COUNT:
		return -1
	if not in_progress[active_slot]:
		return -1
	elapsed_time[active_slot] += 1
	if elapsed_time[active_slot] >= required_time[active_slot]:
		return _complete(active_slot)
	return -1


func _complete(index: int) -> int:
	in_progress[index] = false
	unlocked[index] = true
	active_slot = -1
	return index


func _is_valid_index(index: int) -> bool:
	return index >= 0 and index < TECH_COUNT
