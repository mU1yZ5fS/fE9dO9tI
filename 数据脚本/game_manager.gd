extends Node

## 游戏全局管理器 Autoload。唯一的数据写入者。

signal date_changed(date: GameDate)
signal country_selected(slot: int, gwcode: int)
signal world_state_loaded()
signal event_started(event_id: String)
signal tech_completed(tech_id: int)

const W = preload("res://数据脚本/world_state.gd")
const WF = preload("res://数据脚本/world_factory.gd")

var world: WorldState
var is_playing: bool = false
var speed: int = 0
var selected_country_gwcode: int = -1
var settings_return_scene: String = "uid://bydan4iqthbaa"

# 事件状态
var current_event_id: String = ""
var event_is_timeout: bool = false

# 速度 → tick 间隔（秒）
const TICK_INTERVALS: Array[float] = [0.0, 0.2, 0.1, 0.05, 0.03]
var _tick_timer: float = 0.0

var _tech_effects: Dictionary = {}

# 预加载地图底图（后台线程解码 16K PNG，避免外交场景切入时白屏）
const REGION_MAP_PATH: String = "res://资产/地图/map_color.png"
var cached_region_map_image: Image = null
var _map_preload_thread: Thread = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_tech_effects()
	_preload_region_map()
	if EventEngine:
		EventEngine.event_triggered.connect(_on_event_triggered)


func _preload_region_map() -> void:
	if cached_region_map_image != null:
		return
	_map_preload_thread = Thread.new()
	_map_preload_thread.start(_decode_region_map)


func _decode_region_map() -> void:
	var img := Image.load_from_file(ProjectSettings.globalize_path(REGION_MAP_PATH))
	call_deferred("_on_region_map_preloaded", img)


func _on_region_map_preloaded(img: Image) -> void:
	if _map_preload_thread != null:
		_map_preload_thread.wait_to_finish()
		_map_preload_thread = null
	cached_region_map_image = img
	print("GameManager: 地图底图预加载完成")


func _load_tech_effects() -> void:
	var path := "res://资产/数据/tech_effects.json"
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("GameManager: tech_effects.json 不存在")
		return
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		for key in parsed:
			_tech_effects[int(key)] = parsed[key]


func _process(delta: float) -> void:
	if not is_playing or speed <= 0:
		return
	_tick_timer += delta
	var interval := TICK_INTERVALS[speed] if speed < TICK_INTERVALS.size() else 1.0
	while _tick_timer >= interval:
		_tick_timer -= interval
		tick()


# ── 公开 API ──

func new_game(player_gwcode: int = 710, p_difficulty: int = 2) -> void:
	world = WF.create_world(player_gwcode, p_difficulty)
	selected_country_gwcode = player_gwcode
	is_playing = false
	speed = 0
	_tick_timer = 0.0
	world_state_loaded.emit()
	call_deferred("_start_initial_events")


func load_game(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("GameManager: 存档不存在 %s" % path)
		return
	var loaded = ResourceLoader.load(path, "WorldState", ResourceLoader.CACHE_MODE_IGNORE)
	if loaded is WorldState:
		world = loaded
		world.sync_economy()
		is_playing = false
		speed = 0
		_tick_timer = 0.0
		world_state_loaded.emit()
	else:
		push_error("GameManager: 加载失败")


func save_game(path: String) -> void:
	if world == null:
		push_error("GameManager: 无活动游戏")
		return
	var err := ResourceSaver.save(world, path)
	if err != OK:
		push_error("GameManager: 保存失败 %d" % err)


func tick() -> void:
	if world == null:
		return
	var old_month := world.date.month
	var old_year := world.date.year
	world.date.advance()
	date_changed.emit(world.date)

	# 月度模拟（月份变化时执行）
	if world.date.month != old_month:
		_on_month_changed()
	if world.date.year != old_year:
		_on_year_changed()

	if EventEngine:
		EventEngine.check_and_fire()

	if world.techs != null and world.techs.is_researching():
		var completed_tech := world.techs.advance_tick()
		if completed_tech >= 0:
			_apply_tech(completed_tech)
			tech_completed.emit(completed_tech)

	world.flush_economy()
	world.clamp_values()


func select_country(gwcode: int) -> void:
	selected_country_gwcode = gwcode
	country_selected.emit(gwcode, gwcode)


# ── 科技 ──

func _apply_tech(tech_id: int) -> void:
	if world == null:
		return
	for effect in get_tech_effects(tech_id):
		world.add_data_value(effect.key, effect.delta)


## 公开方法（科研界面也需要读取效果描述）
func get_tech_effects(tech_id: int) -> Array:
	return _tech_effects.get(tech_id, [])


# ── 事件 ──

func _on_event_triggered(event_id: String, is_timeout: bool) -> void:
	if world == null or EventEngine == null:
		return
	var event_def: EventDef = EventEngine.get_event(event_id)
	if event_def == null:
		push_error("GameManager: 事件 %s 未找到" % event_id)
		return
	current_event_id = event_id
	event_is_timeout = is_timeout
	pause()
	event_started.emit(event_id)
	get_tree().change_scene_to_file("uid://bheujwt4qte1y")


func start_event(event_id: String) -> void:
	_on_event_triggered(event_id, false)


func _start_initial_events() -> void:
	if world == null or current_event_id != "" or EventEngine == null:
		return
	if world.completed_event_ids.has("five_no"):
		return
	EventEngine.queue_pending("five_no")


func clear_event() -> void:
	current_event_id = ""
	event_is_timeout = false


# ── 时间控制 ──

func set_speed(s: int) -> void:
	speed = clampi(s, 0, 4)

func play() -> void:
	is_playing = true

func pause() -> void:
	is_playing = false

func toggle_play() -> void:
	is_playing = not is_playing

func get_date_string() -> String:
	if world:
		return world.date.format()
	return ""


# ============================================================================
# 数据写入 API — UI 通过这些方法修改 WorldState，不直接写数值表
# ============================================================================
@warning_ignore_start("integer_division")

## 计算预算分配上限（planka）。UI 可读取用于显示。
func calc_budget_planka() -> int:
	if world == null:
		return 0
	var d := world.数值表
	var total: int = d[W.I_BUDGET] + d[W.I_RESERVE]
	for i in range(W.I_BUDGET_ARMY, W.I_BUDGET_DIPLO + 1):
		total += d[i]
	if d[W.I_ECON_SYSTEM] > 12:
		total -= (d[W.I_ECON_SYSTEM] - 12) * (total / 10)
	return total


## 调整预算类别。category_idx 为 71-81 之一，delta 为增减量。
## 返回 false 表示余额不足或超过 planka 上限。
func adjust_budget(category_idx: int, delta: int) -> bool:
	if world == null:
		return false
	var d := world.数值表
	if category_idx < W.I_BUDGET_ARMY or category_idx > W.I_BUDGET_DIPLO:
		return false
	if delta > 0:
		if d[W.I_BUDGET] < delta:
			return false
		var planka := calc_budget_planka()
		if d[category_idx] > planka / 6:
			return false
	if delta < 0 and d[category_idx] < -delta:
		return false
	d[category_idx] += delta
	d[W.I_BUDGET] -= delta
	world.sync_economy()
	return true


## 调整贷款。delta > 0 借入，delta < 0 还款。借入扣减党支持。
func adjust_loan(delta: int) -> bool:
	if world == null:
		return false
	var d := world.数值表
	if delta > 0:
		# 借入：检查贷款上限
		var usa_rel := 0
		var ussr_rel := 0
		if world.empires.size() > 0:
			usa_rel = world.empires[0].relations
		if world.empires.size() > 1:
			ussr_rel = world.empires[1].relations
		var max_loan := (usa_rel + ussr_rel) / 5
		if d[W.I_LOAN] + delta > max_loan:
			return false
		d[W.I_LOAN] += delta
		d[W.I_BUDGET] += delta
		d[W.I_PARTY_SUPPORT] -= delta
	else:
		if d[W.I_LOAN] < -delta:
			return false
		if d[W.I_BUDGET] < -delta:
			return false
		d[W.I_LOAN] += delta
		d[W.I_BUDGET] += delta
		d[W.I_PARTY_SUPPORT] -= delta
	world.sync_economy()
	return true


## 调整储备金。delta > 0 存入，delta < 0 取出。取出扣减党支持和民众支持。
func adjust_reserve(delta: int) -> bool:
	if world == null:
		return false
	var d := world.数值表
	if delta > 0:
		if d[W.I_BUDGET] < delta:
			return false
		d[W.I_RESERVE] += delta
		d[W.I_BUDGET] -= delta
	else:
		if d[W.I_RESERVE] < -delta:
			return false
		d[W.I_RESERVE] += delta
		d[W.I_BUDGET] -= delta
		d[W.I_PARTY_SUPPORT] += delta
		d[W.I_PEOPLE_SUPPORT] += delta
	world.sync_economy()
	return true


## 政策切换。category_idx 为数值表索引（15/16/17/18/50/51），target_val 为目标值。
## 需满足预算和党支持条件，切换后扣减预算、生活水平、党支持。
func change_policy(category_idx: int, target_val: int) -> bool:
	if world == null:
		return false
	var d := world.数值表
	if category_idx < 0 or category_idx >= d.size():
		return false
	var current_val: int = d[category_idx]
	if current_val == target_val:
		return true
	var diff := absi(target_val - current_val)
	var budget_need: int = diff * 50
	var party_need: int = diff * 300
	var budget_have: int = d[W.I_BUDGET] + d[W.I_RESERVE]
	var party_have: int = d[W.I_PARTY_SUPPORT]
	if budget_have < budget_need or party_have < party_need:
		return false
	d[W.I_BUDGET] -= diff * 50
	d[W.I_LIVING] -= diff * 50
	d[W.I_PARTY_SUPPORT] -= diff * 30
	d[category_idx] = target_val
	world.flush_economy()
	return true


func set_birth_policy(policy: int) -> void:
	if world == null:
		return
	var d := world.数值表
	if W.I_BIRTH_POLICY < d.size():
		d[W.I_BIRTH_POLICY] = policy


func set_faction_ally(faction_idx: int, is_ally: bool) -> void:
	if world == null or faction_idx >= world.factions.size():
		return
	world.factions[faction_idx].is_ally = is_ally


func set_faction_enabled(faction_idx: int, is_enabled: bool) -> void:
	if world == null or faction_idx >= world.factions.size():
		return
	world.factions[faction_idx].is_enabled = is_enabled


# ============================================================================
# 月度模拟循环 — 移植自 TimeScript.InfluenceFromInvestments + QueryChina
# ============================================================================

func _on_month_changed() -> void:
	var w := world
	if w == null:
		return
	var d := w.数值表
	var month := w.date.month
	var year := w.date.year

	_monthly_income(d)
	_monthly_expenses(d, year)
	_deficit_recovery(d)
	_influence_from_investments(d, year)
	_monthly_deficit_penalty(d)
	_political_system_recalc(d, w)

	if month % 6 == 0:
		_biannual_living_drift(d)
		_biannual_faction_drift(w)
		_biannual_manpower(d)
		_biannual_econ_system_effect(d, year)

	w.flush_economy()


func _on_year_changed() -> void:
	var w := world
	if w == null:
		return
	var d := w.数值表

	# 人口增长（按生育政策）
	match d[W.I_BIRTH_POLICY]:
		0: d[W.I_POPULATION] += d[W.I_POPULATION] / 100       # 一胎: 1%
		1: d[W.I_POPULATION] += d[W.I_POPULATION] * 2 / 100   # 二胎: 2%
		2: d[W.I_POPULATION] += d[W.I_POPULATION] * 3 / 100   # 无限制: 3%

	# 派系席位年度衰减
	for f in w.factions:
		f.support = f.support / 10

	# 满意现秩序者衰减
	d[W.I_SATISFIED] = d[W.I_SATISFIED] / 10


# ── 月度收入 ──

func _monthly_income(d: Array[int]) -> void:
	var income: int = d[W.I_INDUSTRY] / 15 + d[W.I_AGRICULTURE] / 35 \
		+ d[W.I_SERVICES] / 50 + d[W.I_INCOME]
	d[W.I_BUDGET] += income


# ── 月度扣除 ──

func _monthly_expenses(d: Array[int], year: int) -> void:
	if d[W.I_LOAN] > 0:
		d[W.I_BUDGET] -= maxi(d[W.I_LOAN] / 40, 1)
	d[W.I_BUDGET] -= d[W.I_CORRUPTION] / 10
	if year >= 1980:
		d[W.I_BUDGET] -= 1
	if year >= 1983:
		d[W.I_BUDGET] -= 2


# ── 赤字处理（储备吸收） ──

func _deficit_recovery(d: Array[int]) -> void:
	if d[W.I_BUDGET] >= 0:
		return
	if d[W.I_RESERVE] + d[W.I_BUDGET] >= 0:
		d[W.I_RESERVE] += d[W.I_BUDGET]
		d[W.I_BUDGET] = 0
	else:
		d[W.I_BUDGET] += d[W.I_RESERVE]
		d[W.I_RESERVE] = 0


# ── 预算赤字→党支持惩罚 ──

func _monthly_deficit_penalty(d: Array[int]) -> void:
	if d[W.I_BUDGET] < 0:
		d[W.I_PARTY_SUPPORT] -= 1


# ── 11项预算的完整月度效果 ──
# 移植自 TimeScript.cs InfluenceFromInvestments() 第 8081 行起

func _influence_from_investments(d: Array[int], year: int) -> void:
	# ─ 军费 ─
	var army_year_cost := (year - 1976 + 6) * 10
	var ind_mod := 1.0 - (100.0 - float(d[W.I_INDUSTRY])) / 400.0
	d[W.I_ARMY] += int(float(d[W.I_BUDGET_ARMY] - army_year_cost) / 10.0 * ind_mod)
	d[W.I_MANPOWER] += d[W.I_BUDGET_ARMY] / 150
	d[W.I_THOUGHT_FREEDOM] -= d[W.I_BUDGET_ARMY] / 80
	d[W.I_CORRUPTION] += d[W.I_BUDGET_ARMY] / 50
	d[W.I_INDUSTRY] += d[W.I_BUDGET_ARMY] / 90
	if d[W.I_BUDGET_ARMY] < 80 and d[W.I_LIVING] < 500:
		d[W.I_LIVING] -= (90 - d[W.I_BUDGET_ARMY]) / 20
	if d[W.I_BUDGET_ARMY] < 80:
		d[W.I_INDUSTRY] -= (90 - d[W.I_BUDGET_ARMY]) / 20
	if d[W.I_LIVING] < 500:
		d[W.I_LIVING] += d[W.I_BUDGET_ARMY] / 50

	# ─ 国安部(MGB) ─
	d[W.I_AGENTS] += d[W.I_BUDGET_MGB] / 10
	d[W.I_THOUGHT_FREEDOM] -= d[W.I_BUDGET_MGB] / 50 + d[W.I_BUDGET_MGB] / 90 * 2 \
		+ d[W.I_BUDGET_MGB] / 100 * 2
	d[W.I_PEOPLE_SUPPORT] -= d[W.I_BUDGET_MGB] / 90 * 2 + d[W.I_BUDGET_MGB] / 100
	d[W.I_PARTY_SUPPORT] -= d[W.I_BUDGET_MGB] / 90 * 2 + d[W.I_BUDGET_MGB] / 100
	if d[W.I_LIVING] < 500:
		d[W.I_LIVING] += d[W.I_BUDGET_MGB] / 80
	if d[W.I_BUDGET_MGB] >= d[W.I_AGENTS] and d[W.I_BUDGET_MGB] <= 150:
		d[W.I_CORRUPTION] -= d[W.I_BUDGET_MGB] / 50 + d[W.I_BUDGET_MGB] / 100

	# ─ 科研经费 ─
	d[W.I_SCIENCE] += d[W.I_BUDGET_SCIENCE] / 50
	d[W.I_CORRUPTION] += d[W.I_BUDGET_SCIENCE] / 50

	# ─ 行政支出 ─
	d[W.I_CORRUPTION] -= d[W.I_BUDGET_ADMIN] / 20
	d[W.I_PARTY_SUPPORT] += d[W.I_BUDGET_ADMIN] / 25
	d[W.I_LIVING] += d[W.I_BUDGET_ADMIN] / 70

	# ─ 高层福利(信封) ─
	d[W.I_CORRUPTION] += d[W.I_BUDGET_ENVELOPE] / 25
	if d[W.I_BUDGET_ENVELOPE] > 61:
		d[W.I_PARTY_SUPPORT] += (d[W.I_BUDGET_ENVELOPE] - 61) / 5

	# ─ 宣传支出 ─
	d[W.I_MANPOWER] += d[W.I_BUDGET_PROPAGANDA] / 150
	d[W.I_CORRUPTION] += d[W.I_BUDGET_PROPAGANDA] / 150
	d[W.I_CORRUPTION] -= d[W.I_BUDGET_PROPAGANDA] / 100
	d[W.I_THOUGHT_FREEDOM] -= d[W.I_BUDGET_PROPAGANDA] / 100
	if d[W.I_BUDGET_PROPAGANDA] > 70:
		d[W.I_PEOPLE_SUPPORT] += (d[W.I_BUDGET_PROPAGANDA] - 70) / 10
	if d[W.I_BUDGET_PROPAGANDA] < 50:
		d[W.I_CORRUPTION] += (50 - d[W.I_BUDGET_PROPAGANDA]) / 20
		d[W.I_PEOPLE_SUPPORT] -= (50 - d[W.I_BUDGET_PROPAGANDA]) / 20
		d[W.I_MANPOWER] -= (50 - d[W.I_BUDGET_PROPAGANDA]) / 20

	# ─ 农业支出 ─
	d[W.I_CORRUPTION] += d[W.I_BUDGET_AGRI] / 80
	d[W.I_AGRICULTURE] += d[W.I_BUDGET_AGRI] / 15
	d[W.I_LIVING] += d[W.I_BUDGET_AGRI] / 100
	if d[W.I_BUDGET_AGRI] < 40:
		d[W.I_AGRICULTURE] += (d[W.I_BUDGET_AGRI] - 40) / 10

	# ─ 工业支出 ─
	d[W.I_CORRUPTION] += d[W.I_BUDGET_INDUSTRY] / 80
	d[W.I_INDUSTRY] += d[W.I_BUDGET_INDUSTRY] / 10
	d[W.I_LIVING] += d[W.I_BUDGET_INDUSTRY] / 80
	if d[W.I_BUDGET_INDUSTRY] < 70:
		d[W.I_INDUSTRY] += (d[W.I_BUDGET_INDUSTRY] - 70) / 10

	# ─ 服务业支出 ─
	d[W.I_CORRUPTION] += d[W.I_BUDGET_SERVICES] / 50
	d[W.I_SERVICES] += d[W.I_BUDGET_SERVICES] / 10
	d[W.I_LIVING] += d[W.I_BUDGET_SERVICES] / 40
	if d[W.I_BUDGET_SERVICES] < 40:
		d[W.I_SERVICES] += (d[W.I_BUDGET_SERVICES] - 40) / 10

	# ─ 福利支出 ─
	d[W.I_LIVING] += (d[W.I_BUDGET_WELFARE] - 40) / 5
	d[W.I_PEOPLE_SUPPORT] += d[W.I_BUDGET_WELFARE] / 80
	if d[W.I_ECON_SYSTEM] < 13:
		d[W.I_CORRUPTION] += d[W.I_BUDGET_WELFARE] / 80
	else:
		d[W.I_CORRUPTION] += d[W.I_BUDGET_WELFARE] / 50

	# ─ 外交支出 ─
	if d[W.I_BUDGET_DIPLO] <= 0:
		d[W.I_DIPLO] -= 2
	elif d[W.I_BUDGET_DIPLO] < 60:
		d[W.I_DIPLO] -= 1


# ── 政治体制自动重算 ──

func _political_system_recalc(d: Array[int], w: WorldState) -> void:
	var score: int = (d[W.I_ECON_SYSTEM] - 9) + (d[W.I_PARTY_SYSTEM] - 5) \
		+ (d[W.I_PRESS_POLICY] - 15) + (d[W.I_RELIGION] - 23) \
		+ (d[W.I_TERRITORY] + d[W.I_MIL_DOCTRINE] - 48) / 2
	if d[W.I_ECON_SYSTEM] == 11:
		score += 1
	if d[W.I_ECON_SYSTEM] == 10:
		score += 2

	var new_system: int
	var new_gosstroy: int
	if d[W.I_PARTY_SYSTEM] <= 6 and d[W.I_ECON_SYSTEM] >= 14 \
			and d[W.I_PRESS_POLICY] <= 16 and d[W.I_TERRITORY] <= 21:
		new_system = 0; new_gosstroy = 0
	elif score <= 6:
		new_system = 0; new_gosstroy = 0
	elif score <= 9 and d[W.I_ECON_SYSTEM] <= 11:
		new_system = 1; new_gosstroy = 1
	elif score <= 11:
		new_system = 2; new_gosstroy = 1
	elif score <= 15 and d[W.I_ECON_SYSTEM] > 11:
		new_system = 3; new_gosstroy = 2
	elif score <= 20:
		new_system = 4; new_gosstroy = 3
	else:
		new_system = 5; new_gosstroy = 3

	d[W.I_IDEOLOGY] = new_system
	var pc := w.get_player_country()
	if pc:
		pc.government = new_gosstroy


# ── 半年度：生活水平漂移 ──

func _biannual_living_drift(d: Array[int]) -> void:
	var target: int = (d[W.I_INDUSTRY] + d[W.I_AGRICULTURE] + d[W.I_SERVICES]) / 30 \
		- d[W.I_CORRUPTION] / 5
	if d[W.I_LIVING] < target:
		d[W.I_LIVING] += 1
	elif d[W.I_LIVING] > target:
		d[W.I_LIVING] -= 1


# ── 半年度：派系支持漂移 ──

func _biannual_faction_drift(w: WorldState) -> void:
	var political_line: int = w.数值表[W.I_POLITICAL_LINE]
	for i in w.factions.size():
		var f: FactionData = w.factions[i]
		if f.id == political_line:
			f.support += 2
		else:
			f.support -= 1
		if f.is_ally:
			f.support += 1
		if not f.is_enabled:
			f.support = maxi(0, f.support - 3)
		f.support = maxi(0, f.support)


# ── 半年度：兵源重算 ──

func _biannual_manpower(d: Array[int]) -> void:
	match d[W.I_MIL_DOCTRINE]:
		30: d[W.I_MANPOWER] = d[W.I_POPULATION] / 10   # 全民皆兵
		31: d[W.I_MANPOWER] = d[W.I_POPULATION] / 15   # 积极建军
		32: d[W.I_MANPOWER] = d[W.I_POPULATION] / 25   # 国防建设
		33: d[W.I_MANPOWER] = d[W.I_POPULATION] / 40   # 职业军队


# ── 半年度：经济体制对经济的影响 ──

func _biannual_econ_system_effect(d: Array[int], year: int) -> void:
	var reserve := d[W.I_RESERVE]
	var econ := d[W.I_ECON_SYSTEM]

	if econ == 12:
		d[W.I_CORRUPTION] -= reserve / 200
		if reserve < 600:
			var penalty := 3 - reserve / 150
			d[W.I_LIVING] -= penalty; d[W.I_SERVICES] -= penalty; d[W.I_INDUSTRY] -= penalty
		else:
			d[W.I_LIVING] += 1; d[W.I_SERVICES] += 1; d[W.I_INDUSTRY] += 1

	elif econ == 13:
		var threshold := 600 if year < 1980 else 750
		var base_loss := 3 if year < 1980 else 4
		d[W.I_CORRUPTION] -= reserve / (400 if year < 1980 else 600)
		if reserve < threshold:
			var penalty := base_loss - reserve / 150
			d[W.I_LIVING] -= penalty; d[W.I_SERVICES] -= penalty; d[W.I_INDUSTRY] -= penalty
		else:
			d[W.I_LIVING] += 1; d[W.I_SERVICES] += 1; d[W.I_INDUSTRY] += 1

	elif econ == 14:
		d[W.I_CORRUPTION] -= reserve / 400
		if year >= 1980:
			if reserve < 1500:
				var penalty := 7 - reserve / 150
				d[W.I_LIVING] -= penalty; d[W.I_SERVICES] -= penalty; d[W.I_INDUSTRY] -= penalty
			else:
				d[W.I_LIVING] += 3; d[W.I_SERVICES] += 3; d[W.I_INDUSTRY] += 3

	elif econ == 15:
		d[W.I_CORRUPTION] -= reserve / 200
		var penalty := 13 - reserve / 150
		d[W.I_LIVING] -= penalty; d[W.I_SERVICES] -= penalty; d[W.I_INDUSTRY] -= penalty
