class_name TechState
extends Resource

const TECH_COUNT: int = 27

@export var unlocked: Array[bool] = []
@export var in_progress: Array[bool] = []
@export var elapsed_time: Array[int] = []
@export var required_time: Array[int] = []
@export var active_slot: int = -1

# 每个科技的预算花费（启动时一次性扣除，data[8] -= money）
const TECH_MONEY: Array[int] = [
	3, 3, 5, 5, 5, 5, 7, 9, 7,
	3, 3, 5, 7, 5, 7, 9, 9, 9,
	3, 5, 5, 9, 9, 3, 5, 7, 9,
]

# 每个科技所需的总科研点数
const TECH_DAYS: Array[int] = [
	500, 500, 700, 700, 700, 700, 1000, 1200, 1000,
	500, 500, 700, 1000, 700, 1000, 1200, 1200, 1200,
	500, 700, 700, 1200, 1200, 500, 700, 1000, 1200,
]

# 每个科技的前置依赖（-1=无前置，非线性分叉树）
# 农业: 0→1→2─┬→3→6→8
#              └→4→5→7
# 工业: 9→10→11─┬→12→15→17
#               └→13→14→16
# 军事: 18→23→19─┬→20→25→22
#               └→24→21→26
const TECH_DEPENDENCY: Array[int] = [
	-1, 0, 1, 2, 2, 4, 3, 5, 6,
	-1, 9, 10, 11, 11, 13, 12, 14, 15,
	-1, 23, 19, 24, 25, 18, 19, 20, 21,
]

# 每个科技的最低年份要求（低于此年份不可研究）
const TECH_YEAR: Array[int] = [
	1976, 1976, 1978, 1978, 1978, 1978, 1980, 1981, 1980,
	1976, 1976, 1978, 1980, 1978, 1980, 1981, 1981, 1983,
	1976, 1978, 1978, 1981, 1981, 1976, 1978, 1980, 1981,
]


func _init() -> void:
	unlocked.resize(TECH_COUNT)
	in_progress.resize(TECH_COUNT)
	elapsed_time.resize(TECH_COUNT)
	required_time.resize(TECH_COUNT)
	for i in TECH_COUNT:
		if required_time[i] == 0:
			required_time[i] = TECH_DAYS[i] if i < TECH_DAYS.size() else 300


func is_researching() -> bool:
	return active_slot >= 0


## 判断能否开始研究（检查状态、依赖和年份，不检查资源）
func can_start(index: int, year: int = 9999) -> bool:
	if not _is_valid_index(index):
		return false
	if unlocked[index] or in_progress[index] or is_researching():
		return false
	if elapsed_time[index] > 0:
		return false
	var dep := TECH_DEPENDENCY[index] if index < TECH_DEPENDENCY.size() else -1
	if dep >= 0 and _is_valid_index(dep) and not unlocked[dep]:
		return false
	var req_year := TECH_YEAR[index] if index < TECH_YEAR.size() else 1976
	if year < req_year:
		return false
	return true


## 启动研究 — 移植自 Science_Script.OnMouseDown
## science_pool = data[11], year = data[21]
## 返回扣除的预算金额
func start_research(index: int, science_pool: int, year: int, _month: int) -> int:
	if not can_start(index, year):
		return 0
	var money := TECH_MONEY[index] if index < TECH_MONEY.size() else 3

	elapsed_time[index] = science_pool

	in_progress[index] = true
	active_slot = index
	return money


## 月度推进 — 移植自 TimeScript 5458-5574行
## science_pool = data[11]，返回消耗后剩余的 data[11]
func monthly_advance(science_pool: int) -> int:
	if active_slot < 0 or active_slot >= TECH_COUNT:
		return science_pool
	if not in_progress[active_slot]:
		return science_pool
	if unlocked[active_slot]:
		return science_pool

	var need := required_time[active_slot]
	var have := elapsed_time[active_slot]

	if have >= need:
		_complete(active_slot)
		return science_pool

	if have + science_pool <= need:
		elapsed_time[active_slot] += science_pool
		science_pool = 0
	else:
		var remaining := need - have
		elapsed_time[active_slot] = need
		science_pool -= remaining

	if elapsed_time[active_slot] >= required_time[active_slot]:
		_complete(active_slot)

	return science_pool


func get_completed_this_tick() -> int:
	for i in TECH_COUNT:
		if unlocked[i] and in_progress[i]:
			in_progress[i] = false
			return i
	return -1


func _complete(index: int) -> void:
	in_progress[index] = false
	unlocked[index] = true
	active_slot = -1


func _is_valid_index(index: int) -> bool:
	return index >= 0 and index < TECH_COUNT
