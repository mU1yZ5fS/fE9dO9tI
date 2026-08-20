class_name TechState
extends Resource

const TECH_COUNT: int = 34

@export var unlocked: Array[bool] = []
@export var in_progress: Array[bool] = []
@export var elapsed_time: Array[int] = []
@export var required_time: Array[int] = []
@export var active_slot: int = -1

## 完成通知是一次性运行时状态；用 -1 表示本轮无完成项。
@export var completed_this_tick: int = -1

# 每个科技的预算花费（启动时一次性扣除，data[8] -= money）
# [0-26] 出处 Science.unity 科技组件 money 字段；[27-33] 航天科技（DLC02 内容，按项目惯例无条件开放）
const TECH_MONEY: Array[int] = [
	3, 3, 5, 5, 5, 5, 7, 9, 7,
	3, 3, 5, 7, 5, 7, 9, 9, 9,
	3, 5, 5, 9, 9, 3, 5, 7, 9,
	7, 12, 17, 22, 27, 32, 37,
]

# 每个科技所需的总科研点数
# [27-33] 出处 Science.unity：1200/1300/1400/1500/1600/1700/1800
const TECH_DAYS: Array[int] = [
	500, 500, 700, 700, 700, 700, 1000, 1200, 1000,
	500, 500, 700, 1000, 700, 1000, 1200, 1200, 1200,
	500, 700, 700, 1200, 1200, 500, 700, 1000, 1200,
	1200, 1300, 1400, 1500, 1600, 1700, 1800,
]

# 每个科技的前置依赖（-1=无前置，非线性分叉树）
# 农业: 0→1→2─┬→3→6→8
#              └→4→5→7
# 工业: 9→10→11─┬→12→15→17
#               └→13→14→16
# 军事: 18→23→19─┬→20→25→22
#               └→24→21→26
# 航天: 27→28→29→30→31→32→33（线性链，27 无前置）
const TECH_DEPENDENCY: Array[int] = [
	-1, 0, 1, 2, 2, 4, 3, 5, 6,
	-1, 9, 10, 11, 11, 13, 12, 14, 15,
	-1, 23, 19, 24, 25, 18, 19, 20, 21,
	-1, 27, 28, 29, 30, 31, 32,
]

# 每个科技的最低年份要求（低于此年份不可研究）
# [27-33] 出处 Science.unity data 字段，全部 1976
const TECH_YEAR: Array[int] = [
	1976, 1976, 1978, 1978, 1978, 1978, 1980, 1981, 1980,
	1976, 1976, 1978, 1980, 1978, 1980, 1981, 1981, 1983,
	1976, 1978, 1978, 1981, 1981, 1976, 1978, 1980, 1981,
	1976, 1976, 1976, 1976, 1976, 1976, 1976,
]


func _init() -> void:
	unlocked.resize(TECH_COUNT)
	in_progress.resize(TECH_COUNT)
	elapsed_time.resize(TECH_COUNT)
	required_time.resize(TECH_COUNT)
	for i in TECH_COUNT:
		if required_time[i] == 0:
			required_time[i] = TECH_DAYS[i] if i < TECH_DAYS.size() else 300


## 旧存档迁移：把 27 槽科技数组补齐到 TECH_COUNT。
## 新增槽位按未研究处理，required_time 用 TECH_DAYS 回填。
func ensure_size() -> void:
	unlocked.resize(TECH_COUNT)
	in_progress.resize(TECH_COUNT)
	elapsed_time.resize(TECH_COUNT)
	var old_size := required_time.size()
	required_time.resize(TECH_COUNT)
	for i in range(old_size, TECH_COUNT):
		required_time[i] = TECH_DAYS[i] if i < TECH_DAYS.size() else 300
	# 迁移前不可能存在 27+ 的研究中项目；保险起见清理越界活动槽
	if active_slot >= TECH_COUNT:
		active_slot = -1


func is_researching() -> bool:
	return active_slot >= 0


## 全部科技是否研究完成（原版 TimeScript.cs:5740-5746 flag5 语义）。
func is_all_researched() -> bool:
	for i in TECH_COUNT:
		if i >= unlocked.size() or not unlocked[i]:
			return false
	return true


## 判断能否开始研究（对齐 Science_Script.OnMouseDown:230-233 的点击条件，不检查资源）
## 原版点击判定不含年份：超前年份会走“超前惩罚”扣减研究进度，而不是禁止研究。
func can_start(index: int) -> bool:
	if not _is_valid_index(index):
		return false
	if unlocked[index] or in_progress[index] or is_researching():
		return false
	if elapsed_time[index] > 0:
		return false
	var dep := TECH_DEPENDENCY[index] if index < TECH_DEPENDENCY.size() else -1
	if dep >= 0 and _is_valid_index(dep) and not unlocked[dep]:
		return false
	return true


## 启动研究 — 移植自 Science_Script.OnMouseDown:234-244
## science_pool = data[11], year = data[21], month = data[20]
## 原版超前惩罚（Science_Script.cs:237-238）：
##   science_time -= days * (data - year) - month * (days / 12)
## science_time 允许为负（负进度=额外欠账），monthly_advance 逐月回填。
## 返回扣除的预算金额
func start_research(index: int, science_pool: int, year: int, month: int) -> int:
	if not can_start(index):
		return 0
	var money := TECH_MONEY[index] if index < TECH_MONEY.size() else 3
	var days := TECH_DAYS[index] if index < TECH_DAYS.size() else 300
	var req_year := TECH_YEAR[index] if index < TECH_YEAR.size() else 1976

	elapsed_time[index] = science_pool
	if year < req_year:
		@warning_ignore("integer_division")
		elapsed_time[index] -= days * (req_year - year) - month * (days / 12)

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
	var completed := completed_this_tick
	completed_this_tick = -1
	return completed


func _complete(index: int) -> void:
	in_progress[index] = false
	unlocked[index] = true
	active_slot = -1
	completed_this_tick = index


func _is_valid_index(index: int) -> bool:
	return index >= 0 and index < TECH_COUNT
