# ============================================================================
# Achievements — 成就系统 Autoload（对齐原作 Assets/Scripts/achievements.cs）
# ============================================================================
# 原作机制（查档出处）：
#   - Set(n)：仅 gameState.iron_and_blood 时置 ach_this[n]=true
#     （achievements.cs:32-37）
#   - Update：每帧 for i=1..Length-1，遇 true 先清位再解锁 ACH_i
#     （achievements.cs:80-91）；i 从 1 开始 → Set(0) 永不刷新，逐字保留
#   - ach_this 实际长度 1000：Assets/Prefab/Ach.prefab 序列化 1000 个 0，
#     覆盖代码 new bool[100] 的字段初值，因此原作 Set(222)/Set(666) 合法
#
# 端口裁决（2026-08-16，用户确认）：
#   - 完全不接 Steam：原作经 SteamUserStats.SetAchievement 解锁；本端口
#     解锁动作由 _unlock 落地为 user:// 本地持久化 + print 记录。
#   - 方法名不用 set()：Object.set(property, value) 是 Godot 内建方法
#     （本地文档 gdd_1214_Object.md:1020），避免遮蔽，命名 set_achievement()。
#   - 原作 Steam 统计握手（m_bStatsValid）不建模：_process 每帧直接刷新，
#     等价于原作「已收到统计」之后的状态。
#   - 2026-08-16 追加裁决：成就 UI 需要跨启动显示 → unlocked 位图写入
#     user://achievements_unlocked.json（本端口自造存储，与 Steam 云端无关）。
# ============================================================================

extends Node

## 对齐 Ach.prefab 序列化长度（原作 achievements.cs 代码初值 100 被 prefab 覆盖为 1000）
const QUEUE_SIZE := 1000

## 本地解锁记录（用户裁决：持久化到 user://，供成就 UI 跨启动显示）
const UNLOCKED_SAVE_PATH := "user://achievements_unlocked.json"

## 待刷新位（原 achievements.ach_this：true=待解锁）
var ach_this: Array[bool] = []

## 已解锁位图（索引 1..999 有意义；与 ach_this 同长）
var unlocked: Array[bool] = []


func _ready() -> void:
	# gdd_1552_Array.md: resize 扩容补默认元素；此处再 fill(false) 保证类型默认值
	ach_this.resize(QUEUE_SIZE)
	ach_this.fill(false)
	unlocked.resize(QUEUE_SIZE)
	unlocked.fill(false)
	_load_unlocked()


## 对齐原 achievements.Set(number)（achievements.cs:32-37）：
## 仅铁人档（world.is_ironman）置位；本端口把数组越界从「原作崩溃」改为告警并忽略。
func set_achievement(number: int) -> void:
	if GameManager == null or GameManager.world == null:
		return
	if not GameManager.world.is_ironman:
		return
	if number < 0 or number >= ach_this.size():
		push_warning("Achievements: 编号 %d 超出 0..%d，原作此处数组越界异常，本端口忽略" % [
			number, ach_this.size() - 1
		])
		return
	ach_this[number] = true


func _process(_delta: float) -> void:
	# achievements.cs:84-90：循环从 i=1 开始（Set(0) 永不刷新，逐字保留）
	for i in range(1, ach_this.size()):
		if ach_this[i]:
			ach_this[i] = false
			_unlock(i)


## 原作 UnlockAchievement → SteamUserStats.SetAchievement("ACH_n")；
## 本端口不接 Steam，改为：置 unlocked 位 + 写 user:// 持久化 + print 记录。
func _unlock(number: int) -> void:
	unlocked[number] = true
	_save_unlocked()
	print("Achievements: ACH_%d 解锁（已写入 user:// 本地记录）" % number)


## 查询是否已解锁（成就 UI 用）。
func is_unlocked(number: int) -> bool:
	return number >= 0 and number < unlocked.size() and unlocked[number]


## 已解锁编号列表（升序）。
func unlocked_numbers() -> Array[int]:
	var out: Array[int] = []
	for i in range(1, unlocked.size()):
		if unlocked[i]:
			out.append(i)
	return out


## 读 user://achievements_unlocked.json（不存在/损坏时保持全未解锁）。
func _load_unlocked() -> void:
	# gdd_1291_FileAccess.md:15-19 open + get_as_text
	if not FileAccess.file_exists(UNLOCKED_SAVE_PATH):
		return
	var f := FileAccess.open(UNLOCKED_SAVE_PATH, FileAccess.READ)
	if f == null:
		push_warning("Achievements: 无法读取 %s" % UNLOCKED_SAVE_PATH)
		return
	# gdd_0972_JSON.md:36 parse_string 失败返回 null
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Array:
		for v in parsed:
			if v is float or v is int:
				var n := int(v)
				if n >= 1 and n < unlocked.size():
					unlocked[n] = true
	elif parsed != null:
		push_warning("Achievements: 解锁记录格式异常，已忽略（期望 JSON 数组）")


## 写 user://achievements_unlocked.json（已解锁编号数组）。
func _save_unlocked() -> void:
	var nums: Array = []
	for i in range(1, unlocked.size()):
		if unlocked[i]:
			nums.append(i)
	# gdd_0972_JSON.md:17 stringify；gdd_1291_FileAccess.md:15-16 open(WRITE)+store_string
	var f := FileAccess.open(UNLOCKED_SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("Achievements: 无法写入 %s" % UNLOCKED_SAVE_PATH)
		return
	f.store_string(JSON.stringify(nums))
	f.close()
