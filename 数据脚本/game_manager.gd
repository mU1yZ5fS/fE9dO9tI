extends Node

## 游戏全局管理器 Autoload。唯一的数据写入者。

signal date_changed(date: GameDate)
signal country_selected(slot: int, gwcode: int)
signal world_state_loaded()
signal event_started(event_id: String)
signal tech_completed(tech_id: int)
## 数值表/帝国关系变更后发出，跨场景状态栏可在暂停时也能刷新
signal stats_changed()

const W = preload("res://数据脚本/world_state.gd")
const SaveCatalog = preload("res://数据脚本/save_catalog.gd")
const WF = preload("res://数据脚本/world_factory.gd")

var world: WorldState
var is_playing: bool = false
var speed: int = 0
var selected_country_gwcode: int = -1
var settings_return_scene: String = "uid://bydan4iqthbaa"
## 保存/加载界面返回目标（esc 进存档时设为外交等）
var save_return_scene: String = "uid://bydan4iqthbaa"

## 外交（主游戏）场景是否处于激活状态。
## 只有外交场景激活时，时间才会流动 —— 与原版 Unity 行为一致
## （原版 TimeScript 只在主地图场景的 Update() 中运行，切到子界面场景时自然暂停）。
var is_diplomacy_active: bool = false

# 事件状态
var current_event_id: String = ""
var event_is_timeout: bool = false

var current_ending_id: int = -1

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
	# 时间仅在外交（主游戏）场景流动；科研/经济/派系等子界面不推进时间
	if not is_diplomacy_active:
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
	# 不传 type_hint：.res 内嵌 class_name 时强制 WorldState 会误报 not found
	var loaded = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if loaded is WorldState:
		world = loaded as WorldState
		# 运行时缓存不序列化，读档后重建
		world.rebuild_gwcode_index()
		world.sync_economy()
		if EventEngine and EventEngine.has_method("import_runtime_from_world"):
			EventEngine.import_runtime_from_world(world)
		selected_country_gwcode = world.player_country_gwcode
		is_playing = false
		speed = 0
		_tick_timer = 0.0
		current_event_id = ""
		event_is_timeout = false
		current_ending_id = -1
		world_state_loaded.emit()
		_notify_stats()
	else:
		push_error("GameManager: 加载失败 %s" % path)


func save_game(path: String) -> void:
	if world == null:
		push_error("GameManager: 无活动游戏")
		return
	# 写入前同步显示视图，避免读档后经济视图过期
	world.sync_economy()
	if EventEngine and EventEngine.has_method("export_runtime_to_world"):
		EventEngine.export_runtime_to_world(world)
	var err := ResourceSaver.save(world, path)
	if err != OK:
		push_error("GameManager: 保存失败 %d → %s" % [err, path])
		return
	# 部分环境下 user:// 相对路径需 globalize 才能立刻 FileAccess 可见
	if not FileAccess.file_exists(path):
		var abs_path := ProjectSettings.globalize_path(path)
		push_warning("GameManager: FileAccess 暂未见 %s (abs=%s exists=%s)" % [
			path, abs_path, FileAccess.file_exists(abs_path)
		])
	print("GameManager: 已保存 %s size_hint ok" % path)


## 槽位保存：WorldState.res + meta.json 摘要。
## iron_override: -1=沿用 world.is_ironman；0/1=仅写 meta，不改运行时 world。
func save_to_slot(slot: int, iron_override: int = -1) -> bool:
	if world == null:
		push_error("GameManager: 无活动游戏")
		return false
	if slot < 0:
		return false
	SaveCatalog.ensure_dir()
	var path := SaveCatalog.slot_path(slot)
	save_game(path)
	if not FileAccess.file_exists(path):
		return false
	var meta := SaveCatalog.meta_from_world(world)
	if iron_override == 0:
		meta["is_ironman"] = false
	elif iron_override == 1:
		meta["is_ironman"] = true
	SaveCatalog.write_slot_meta(slot, meta)
	return true


func load_from_slot(slot: int) -> bool:
	var path := SaveCatalog.slot_path(slot)
	if not FileAccess.file_exists(path):
		push_error("GameManager: 槽位 %d 无存档" % slot)
		return false
	load_game(path)
	return world != null


func delete_save_slot(slot: int) -> bool:
	return SaveCatalog.delete_slot(slot)


func tick() -> void:
	if world == null:
		return
	var old_month := world.date.month
	var old_year := world.date.year
	world.date.advance()

	_daily_deficit_recovery(world)
	_daily_science_gen(world)
	_update_displays(world.数值表)

	if world.date.month != old_month:
		_on_month_changed()
	if world.date.year != old_year:
		_on_year_changed()

	if world.date.day % 14 == 0:
		_on_fortnight()

	_check_war_endings()

	if EventEngine:
		EventEngine.check_and_fire()

	world.clamp_values()
	world.clamp_empire_relations()
	_mirror_empires_to_data(world)
	world.sync_economy()
	date_changed.emit(world.date)
	stats_changed.emit()


func select_country(gwcode: int) -> void:
	selected_country_gwcode = gwcode
	var slot := -1
	if world:
		var c := world.get_country_by_gwcode(gwcode)
		if c:
			slot = c.slot
	country_selected.emit(slot, gwcode)


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
	# 战争结束事件关闭后结算槽位
	if current_event_id == "war_is_over":
		resolve_war_finished()
	current_event_id = ""
	event_is_timeout = false


# ── 时间控制 ──

const 经济场景_UID := "uid://btldk7ul11cqn"

## 预算+储备 ≥ 0 才允许推进时间（原版 SpeedScript 守卫）
func can_resume() -> bool:
	if world == null or world.数值表.size() <= W.I_RESERVE:
		return false
	return world.数值表[W.I_BUDGET] + world.数值表[W.I_RESERVE] >= 0


func set_speed(s: int) -> void:
	var target := clampi(s, 0, 4)
	if target > 0 and not can_resume():
		speed = 0
		is_playing = false
		_force_goto_economy()
		return
	speed = target


func play() -> void:
	if not can_resume():
		is_playing = false
		speed = 0
		_force_goto_economy()
		return
	is_playing = true


func pause() -> void:
	is_playing = false


func toggle_play() -> void:
	if is_playing:
		is_playing = false
	else:
		play()


func get_date_string() -> String:
	if world:
		return world.date.format()
	return ""


## 赤字锁定：跳转经济界面强制调整预算（原版 goto_economy.OnMouseDown）
func _force_goto_economy() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var current := tree.current_scene
	if current != null:
		var path := current.scene_file_path
		if path.contains("经济") or path.ends_with("经济.tscn"):
			return
	tree.change_scene_to_file(经济场景_UID)


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
	# 原版 Plusmisnus_script.payment：削减「高层福利」时按 4× 扣党内支持
	# -10 → 党支持-40；-50 → -200；-100 → -400
	if category_idx == W.I_BUDGET_ENVELOPE and delta < 0:
		d[W.I_PARTY_SUPPORT] -= (-delta) * 4
	_notify_stats()
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
		d[W.I_THOUGHT_FREEDOM] += delta * 25 / 10
	else:
		if d[W.I_LOAN] < -delta:
			return false
		var repay_amount := -delta
		var budget_cost := repay_amount
		if world.difficulty >= 3:
			budget_cost = repay_amount * 3
		elif world.difficulty >= 2:
			budget_cost = repay_amount * 2
		if d[W.I_BUDGET] < budget_cost:
			return false
		d[W.I_LOAN] += delta
		d[W.I_BUDGET] -= budget_cost
		d[W.I_PARTY_SUPPORT] += 10
	_notify_stats()
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
	_notify_stats()
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
	if category_idx == W.I_ECON_SYSTEM:
		d[W.I_LIVING] -= diff * 50
	var delta := target_val - current_val
	# 意识形态漂移
	if category_idx == W.I_PARTY_SYSTEM or category_idx == W.I_ECON_SYSTEM:
		d[W.I_DIPLO] -= delta * (60 if category_idx == W.I_PARTY_SYSTEM else 40)
	else:
		d[W.I_DIPLO] -= delta * 20
	# 开放度变化
	if category_idx == W.I_ECON_SYSTEM:
		d[W.I_ECON_OPENNESS] += delta * 100
	elif category_idx == W.I_PARTY_SYSTEM:
		d[W.I_POLITICAL_OPENNESS] += delta * 100
	else:
		d[W.I_POLITICAL_OPENNESS] += delta * 50
	# 党支持与异见
	if d[W.I_PARTY_SYSTEM] < 8:
		d[W.I_PARTY_SUPPORT] -= diff * 30
		d[W.I_THOUGHT_FREEDOM] += diff * 10
	else:
		d[W.I_THOUGHT_FREEDOM] += diff * 20
	d[category_idx] = target_val
	# FAC-05 / ECO-FAC-01：政策变更反馈派系 support / points
	_apply_policy_faction_feedback(category_idx, current_val, target_val)
	# FAC-08：改革路径可能解锁自由派
	try_unlock_liberals()
	_notify_stats()
	return true


## 政策值升高 = 更开放/市场化/多元；降低 = 更集中/管制
## 反馈量按 |delta| * 步长，写入 support 与 points（FAC-01 积分体系）
func _apply_policy_faction_feedback(category_idx: int, old_val: int, new_val: int) -> void:
	if world == null or world.factions.is_empty():
		return
	var step := new_val - old_val
	if step == 0:
		return
	var mag: int = absi(step)
	# 各政策类别对「开放方向」的权重
	var open_weight := 1
	match category_idx:
		W.I_ECON_SYSTEM:
			open_weight = 3
		W.I_PARTY_SYSTEM:
			open_weight = 3
		W.I_PRESS_POLICY:
			open_weight = 2
		W.I_RELIGION:
			open_weight = 1
		W.I_TERRITORY:
			open_weight = 1
		W.I_MIL_DOCTRINE:
			open_weight = 1
		_:
			open_weight = 1
	var dir := 1 if step > 0 else -1
	var unit: int = mag * open_weight * 8
	# 0极左 1保守 2温和 3改革 4自由
	var deltas: Array[int] = [
		-unit,           # 极左：开放则受损
		-(unit * 2) / 3, # 保守
		unit / 5,        # 温和：略受益
		(unit * 2) / 3,  # 改革
		unit,            # 自由：开放则受益
	]
	if dir < 0:
		for i in deltas.size():
			deltas[i] = -deltas[i]
	@warning_ignore("integer_division")
	for i in mini(world.factions.size(), deltas.size()):
		var f: FactionData = world.factions[i]
		if not f.is_enabled and deltas[i] > 0:
			continue
		f.support = maxi(0, f.support + deltas[i])
		f.points = maxi(0, f.points + deltas[i] / 4)


func set_birth_policy(policy: int) -> void:
	if world == null:
		return
	var d := world.数值表
	# 原版 ChildScript：生育政策 = data[105]（同时作人口增长基数 0/1/2）
	# data[3] -= 50*(old-new)；data[8] -= 5*(4-new)
	if policy < 0 or policy > 2 or W.I_BIRTH_POLICY >= d.size():
		return
	var old_policy: int = d[W.I_BIRTH_POLICY]
	if old_policy == policy:
		return
	d[W.I_PEOPLE_SUPPORT] -= 50 * (old_policy - policy)
	d[W.I_BUDGET] -= 5 * (4 - policy)
	d[W.I_BIRTH_POLICY] = policy
	_notify_stats()


func set_faction_ally(faction_idx: int, is_ally: bool) -> void:
	if world == null or faction_idx >= world.factions.size():
		return
	world.factions[faction_idx].is_ally = is_ally
	_notify_stats()


func set_faction_enabled(faction_idx: int, is_enabled: bool) -> void:
	if world == null or faction_idx >= world.factions.size():
		return
	# FAC-08：自由派从禁用→启用需满足解锁条件（禁止始终允许）
	if is_enabled and faction_idx == FactionData.LIBERAL:
		var f0: FactionData = world.factions[faction_idx]
		if not f0.is_enabled:
			if not try_unlock_liberals():
				push_warning("GameManager: 自由派尚未满足解锁条件")
				return
			return
	var was_enabled := world.factions[faction_idx].is_enabled
	world.factions[faction_idx].is_enabled = is_enabled
	# FAC-04：禁止派系连锁 — support 腰斩、points 清零、同派政客忠诚/权力下滑
	if was_enabled and not is_enabled:
		var f: FactionData = world.factions[faction_idx]
		@warning_ignore("integer_division")
		f.support = maxi(0, f.support / 2)
		f.points = 0
		f.is_ally = false
		for p in world.politicians:
			if p == null or p.name_display == "空位":
				continue
			if p.party_index() == faction_idx:
				p.loyalty = maxi(0, p.loyalty - 150)
				p.power = maxi(0, p.power - 50)
	_notify_stats()


## 执政联盟判定 — 对齐 GameState.IsFactionLeadeng（无 DLC 合作规则）
## num == data[56] 政治路线，或 多党(data[15]>7) 且 保守+盟友启用派 support 占比 >66%
func is_faction_leading(faction_index: int) -> bool:
	if world == null or faction_index < 0:
		return false
	var d := world.数值表
	if d.size() <= W.I_POLITICAL_LINE:
		return false
	if d[W.I_POLITICAL_LINE] == faction_index:
		return true
	# 一党制及以下：仅政治路线算「执政」
	if d[W.I_PARTY_SYSTEM] <= 7:
		return false
	var allied := 0
	var total := 0
	for i in world.factions.size():
		var f: FactionData = world.factions[i]
		total += maxi(f.support, 0)
		# 原版：始终计入保守派(1)，另加 is_ally && is_enabled 且非 1
		if i == FactionData.CONSERVATIVE:
			allied += maxi(f.support, 0)
		elif f.is_ally and f.is_enabled:
			allied += maxi(f.support, 0)
	if total <= 0:
		return false
	return float(allied) * 100.0 / float(total) > 66.0


## 用积分强化派系 support（Party_ally_script：每 10 点 → +2% 量级，简化为 support += points/10*2）
func spend_faction_points(faction_idx: int) -> bool:
	if world == null or faction_idx < 0 or faction_idx >= world.factions.size():
		return false
	var f: FactionData = world.factions[faction_idx]
	if f.points < 10:
		return false
	@warning_ignore("integer_division")
	var chunks: int = f.points / 10
	f.points -= 10 * chunks * 2  # 原版扣 20/chunk 量级
	if f.points < 0:
		f.points = 0
	f.support += chunks * 2
	_notify_stats()
	return true



## POL-14：politics[0] 毛泽东在 data[38]!=100 时受保护（不可负向操作/击杀）
func is_mao_protected(pol_index: int) -> bool:
	if world == null or pol_index != 0:
		return false
	var d := world.数值表
	if d.size() <= W.I_STABILITY:
		return false
	return d[W.I_STABILITY] != 100


## FAC-06：派内在世政客 power 合计
func faction_power_sum(faction_idx: int) -> int:
	if world == null or faction_idx < 0:
		return 0
	var total := 0
	for p in world.politicians:
		if p == null or p.name_display == "空位":
			continue
		if p.party_index() == faction_idx:
			total += maxi(p.power, 0)
	return total


## FAC-08：自由派解锁条件（非事件路径的规则近似）
## 原版主路径靠事件（如五中全会）与合作模式；此处提供可玩的改革解锁：
## 政党制度≥联合政府(8) 或 经济体制≥国控资本主义(13) 或 思想自由≥400
func try_unlock_liberals(force: bool = false) -> bool:
	if world == null or world.factions.size() <= FactionData.LIBERAL:
		return false
	var f: FactionData = world.factions[FactionData.LIBERAL]
	if f.is_enabled and not force:
		return false
	var d := world.数值表
	var ok := force
	if not ok and d.size() > W.I_PARTY_SYSTEM:
		ok = d[W.I_PARTY_SYSTEM] >= 8 or d[W.I_ECON_SYSTEM] >= 13 or d[W.I_THOUGHT_FREEDOM] >= 400
	if not ok:
		return false
	f.is_enabled = true
	if f.support <= 0:
		f.support = maxi(40, f.influence / 15) if f.influence > 0 else 40
	# 确保有领袖
	fill_vacant_faction_leaders()
	_notify_stats()
	return true


## 写数值表后统一：同步显示视图 + 广播刷新
func _notify_stats() -> void:
	if world != null:
		world.sync_economy()
	stats_changed.emit()


## 每日镜像：empires 权威 → 数值表[28/29/10/2]（原版 KumihaRepaint）
func _mirror_empires_to_data(w: WorldState) -> void:
	if w == null or w.数值表.size() <= 29:
		return
	var d := w.数值表
	if w.empires.size() > 0 and w.empires[0] != null:
		d[28] = w.empires[0].relations
		d[W.I_USA_INFLUENCE] = w.empires[0].power
	if w.empires.size() > 1 and w.empires[1] != null:
		d[29] = w.empires[1].relations
		d[W.I_SOVIET_INFLUENCE] = w.empires[1].power



# ============================================================================
# 月度模拟循环 — 移植自 TimeScript.InfluenceFromInvestments + QueryChina
# ============================================================================

func _on_month_changed() -> void:
	var w := world
	if w == null:
		return
	var d := w.数值表
	# 原版月块（data[19]==1）：政治体制重算、人口增长、寡头成长
	_political_system_recalc(d, w)
	_monthly_population(d, w)
	_monthly_oligarch(d, w)
	# 政客：调查/监视、自动支持打压、职位 power、空缺派系领袖（TimeScript ~937, ~2172）
	_monthly_politics(d, w)
	# 半年：factionsPoints 积分（原版 data[19]==1 && month 1 或 7）+ 简化漂移
	if w.date.month == 1 or w.date.month == 7:
		_biannual_faction_points(d, w)
		_biannual_faction_drift(w)
	_monthly_war_points()
	w.flush_economy()


func _on_year_changed() -> void:
	var w := world
	if w == null:
		return
	var d := w.数值表
	@warning_ignore("integer_division")
	# 派系 support 年度衰减（原版 party_number/=10）
	for f in w.factions:
		f.support = f.support / 10
	# 满意现秩序者衰减（原版 835 年 /=10）
	d[W.I_SATISFIED] = d[W.I_SATISFIED] / 10
	# 联合/人民民主(7/8) 额外腰斩（TimeScript 年滚 ~640）
	if d[W.I_SATISFIED] > 1 and (d[W.I_PARTY_SYSTEM] == 7 or d[W.I_PARTY_SYSTEM] == 8):
		d[W.I_SATISFIED] = d[W.I_SATISFIED] / 2
	# POL-05 / POL-12：年龄 +1、病弱/老死、任职年数（TimeScript 615–621 + DeathPolitics）
	_annual_politics(d, w)
	try_unlock_liberals()


# ============================================================================
# 政客生命周期 — POL-01/02/03/04
# ============================================================================

func _is_vacant_politician(p: PoliticianData) -> bool:
	return p == null or p.name_display == "空位" or (p.power <= 0 and p.portrait == null)


## 月结：调查/监视计数、自动支持·打压、在职 power 加成、空缺派系领袖补位
func _monthly_politics(d: Array[int], w: WorldState) -> void:
	@warning_ignore("integer_division")
	_sync_in_power_flags(w)
	for i in w.politicians.size():
		var p: PoliticianData = w.politicians[i]
		if _is_vacant_politician(p):
			continue

		# POL-01 调查：满 7 结案（原版只清标志；副作用在开调查时已扣）
		if p.is_under_investigation:
			if p.investigator_index < 0:
				p.investigator_index = 0
			p.investigator_index += 1
			if p.investigator_index >= 7:
				p.investigator_index = 0
				p.is_under_investigation = false

		# POL-01 监视：满 7 解除
		if p.is_under_surveillance:
			p.days_surveillance += 1
			if p.days_surveillance >= 7:
				p.days_surveillance = 0
				p.is_under_surveillance = false

		# POL-02 自动支持（TimeScript ~2194）
		if p.auto_support == 10:
			if d[W.I_BUDGET] < 1 or d[W.I_AGENTS] < 5:
				p.auto_support = 0
			else:
				d[W.I_BUDGET] -= 1
				d[W.I_PARTY_SUPPORT] -= 20
				d[W.I_AGENTS] -= 5
				p.loyalty += 50
				p.power += (1976 - w.date.year) * 5
				p.power += absi(p.power / 10)

		# POL-02 自动打压（TimeScript ~2207）
		if p.auto_hound == 10:
			if d[W.I_BUDGET] < 1 or d[W.I_AGENTS] < 20:
				p.auto_hound = 0
			else:
				d[W.I_BUDGET] -= 1
				d[W.I_PARTY_SUPPORT] -= 20
				d[W.I_AGENTS] -= 20
				p.loyalty -= 250
				p.power -= (1976 - w.date.year) * 5
				if p.power >= 10:
					p.power -= absi(p.power / 10)

		_apply_monthly_position_power(w, i, p)
		# ECO-POL-06：贪腐特质(18) 在职则抬腐败
		if p.trait_special == 18 and p.in_power:
			d[W.I_CORRUPTION] += 2

	fill_vacant_faction_leaders()
	_sync_in_power_flags(w)
	_notify_stats()


## 年均政客生命周期（POL-05 / POL-12）
func _annual_politics(d: Array[int], w: WorldState) -> void:
	# 年龄增长（全体非空位；领袖独立体也 +1）
	for p in w.politicians:
		if _is_vacant_politician(p):
			continue
		p.age += 1
		if p.in_power:
			p.years_in_power += 1
	if w.leader != null:
		w.leader.age += 1

	# DeathPolitics：仅 data[38]>=100（毛后/稳定满）才病弱与老死
	if d[W.I_STABILITY] < 100:
		return
	var to_kill: Array[int] = []
	for i in w.politicians.size():
		var p: PoliticianData = w.politicians[i]
		if _is_vacant_politician(p):
			continue
		# 老死：age >= 91..94
		var death_age: int = 91 + (i % 4)
		if p.age >= death_age:
			if is_mao_protected(i):
				continue
			to_kill.append(i)
			continue
		# 病弱：非改革 traits[0]!=2 时 80..83；改革派 85..88
		if p.trait_special == 19:
			continue
		var sick_age: int
		if p.trait_personality == 2:
			sick_age = 85 + (i % 4)
		else:
			sick_age = 80 + (i % 4)
		if p.age >= sick_age:
			p.trait_special = 19
	for idx in to_kill:
		kill_politician(idx)
	# PlotPolitics 与 DeathPolitics 同频（年，TimeScript ~5734）
	_plot_politics(d, w)


## POL-06 简化：对高 power 目标，若低忠诚他人 power 和过高则标记阴谋并可能削权/撤职/击杀
func _plot_politics(d: Array[int], w: WorldState) -> void:
	if d[W.I_STABILITY] < 100:
		return
	@warning_ignore("integer_division")
	var to_kill: Array[int] = []
	for i in w.politicians.size():
		var target: PoliticianData = w.politicians[i]
		if _is_vacant_politician(target):
			continue
		if target.power <= 250 and target.trait_special != 16:
			continue
		var plot_power := 0
		for j in w.politicians.size():
			if j == i:
				continue
			var pol: PoliticianData = w.politicians[j]
			if _is_vacant_politician(pol) or pol.is_under_investigation:
				continue
			if pol.trait_special == 17 or pol.trait_special == 19:
				continue
			var rel: int = 500
			if i < pol.loyalty_matrix.size():
				rel = pol.loyalty_matrix[i]
			var joins := false
			if pol.trait_special == 16 and rel < 450:
				joins = true
			elif pol.trait_special == 9 and rel < 150:
				joins = true
			elif pol.trait_special != 9 and rel < 300:
				joins = true
			if joins:
				plot_power += pol.power
		var resist := 3.0
		if target.trait_special == 14 or target.trait_special == 13:
			resist = 5.0
		elif target.trait_special == 12 or target.trait_alignment == 6:
			resist = 2.0
		for pos_id in mini(3, w.politics_positions.size()):
			if w.politics_positions[pos_id] == i:
				resist += 2.0 if pos_id == 0 else 1.0
		if float(plot_power) > resist * float(target.power):
			target.is_conspiracy = true
			var seed_v: int = abs(hash("%d-%d-%d-%d" % [w.date.year, w.date.month, i, plot_power]))
			var r1: int = seed_v % 11
			var r2: int = (seed_v / 11) % 22
			var r3: int = (seed_v / 242) % 44
			var man: int = d[W.I_MANPOWER]
			if r1 > man / 100 and r2 > man / 50 and r3 > man / 25:
				if float(plot_power) > resist * 4.0 * float(target.power):
					var is_central := false
					for pos_id2 in mini(3, w.politics_positions.size()):
						if w.politics_positions[pos_id2] == i:
							is_central = true
							w.politics_positions[pos_id2] = -1
					if is_central:
						target.power = 100
						target.you_fall = true
					else:
						to_kill.append(i)
				else:
					target.power -= absi(target.power / 10)
					target.you_fall = true
		else:
			target.is_conspiracy = false
	for idx in to_kill:
		kill_politician(idx)


func _sync_in_power_flags(w: WorldState) -> void:
	var holders: Dictionary = {}
	for pos_id in w.politics_positions.size():
		var h: int = w.politics_positions[pos_id]
		if h >= 0:
			holders[h] = true
	for i in w.politicians.size():
		var p: PoliticianData = w.politicians[i]
		if _is_vacant_politician(p):
			p.in_power = false
			continue
		var now: bool = holders.has(i)
		if now and not p.in_power:
			p.years_in_power = 0
		p.in_power = now


## POL-08：监视/再教育「发现·成功率」显示用（GameState.ChangeOfKilling）
## 返回 0.0~1.0 近似概率
func change_of_killing(politic_index: int) -> float:
	if world == null or politic_index < 0 or politic_index >= world.politicians.size():
		return 0.0
	var d := world.数值表
	var pol: PoliticianData = world.politicians[politic_index]
	if pol == null:
		return 0.0
	var num := 0.5
	if d[W.I_AGENTS] + d[W.I_PARTY_SUPPORT] + d[W.I_ARMY] >= pol.power:
		num += 0.05
	else:
		num -= 0.05
	if d[W.I_AGENTS] + d[W.I_PARTY_SUPPORT] >= pol.power:
		num += 0.05
	var avg_loy: int = _sum_loyalty_avg()
	if avg_loy > 900:
		num += 0.15
	elif avg_loy > 800:
		num += 0.12
	elif avg_loy > 700:
		num += 0.1
	elif avg_loy > 600:
		num += 0.07
	elif avg_loy > 500:
		num += 0.05
	else:
		num -= 0.05
	if d[W.I_PARTY_SUPPORT] > 800:
		num += 0.05
	elif d[W.I_PARTY_SUPPORT] < 700:
		num -= 0.05
	if pol.is_under_investigation:
		num += 0.1
	return clampf(num, 0.05, 0.95)


func _sum_loyalty_avg() -> int:
	if world == null or world.politicians.is_empty():
		return 0
	var s := 0
	var n := 0
	for p in world.politicians:
		if _is_vacant_politician(p):
			continue
		s += p.loyalty
		n += 1
	if n <= 0:
		return 0
	return s / n


func _apply_monthly_position_power(w: WorldState, pol_index: int, p: PoliticianData) -> void:
	# TimeScript 2223–2237：地方 +10，首都 +15，总理/军委/外交 +20
	@warning_ignore("integer_division")
	var bonus := 0
	for pos_id in w.politics_positions.size():
		if w.politics_positions[pos_id] != pol_index:
			continue
		if pos_id <= 2:
			bonus = maxi(bonus, 20)
		elif pos_id == 3:
			bonus = maxi(bonus, 15)
		else:
			bonus = maxi(bonus, 10)
	if bonus > 0:
		p.power += bonus
	elif p.trait_special == 18:
		p.power += 4
	elif p.trait_special == 19:
		p.power -= 20
	elif p.trait_special == 16:
		p.power += 1 + w.数值表[W.I_CORRUPTION] / 50


## 死亡/再教育：清职与派系领袖，同槽补员（KillPerson → BalancePolitic）
func kill_politician(pol_index: int) -> void:
	if world == null or pol_index < 0 or pol_index >= world.politicians.size():
		return
	# POL-14：毛在世保护 politics[0]（data[38]!=100 时不可杀）
	if is_mao_protected(pol_index):
		push_warning("GameManager: 毛泽东在世保护，拒绝 kill %d" % pol_index)
		return
	for i in world.politics_positions.size():
		if world.politics_positions[i] == pol_index:
			world.politics_positions[i] = -1
	for f in world.factions:
		if f.leader_index == pol_index:
			f.leader_index = -1

	var year: int = world.date.year if world.date else 1976
	var existing_parties: Array[int] = []
	for i in world.politicians.size():
		if i == pol_index:
			continue
		var other: PoliticianData = world.politicians[i]
		if not _is_vacant_politician(other):
			existing_parties.append(other.party_index())

	var replacement := PoliticianPool.pick_replacement(
		world.politician_reserve, year, existing_parties
	)
	if replacement != null:
		# 保持 matrix 长度与槽位数一致
		if replacement.loyalty_matrix.size() < world.politicians.size():
			replacement.loyalty_matrix.resize(world.politicians.size())
		world.politicians[pol_index] = replacement
		WorldFactory._calc_rel(world, pol_index)
		WorldFactory._calc_rel_leader(world, pol_index)
	else:
		var empty := world.politicians[pol_index]
		empty.power = 0
		empty.loyalty = 0
		empty.name_display = "空位"
		empty.is_under_surveillance = false
		empty.is_under_investigation = false
		empty.is_conspiracy = false
		empty.you_fall = false
		empty.in_power = false
		empty.years_in_power = 0
		empty.auto_support = 0
		empty.auto_hound = 0
		empty.portrait = null
		empty.days_surveillance = 0
		empty.investigator_index = -1

	fill_vacant_faction_leaders()
	_sync_in_power_flags(world)
	_notify_stats()


## POL-10 任命：按职位细表改 loyalty / matrix，并 POL-20 重算关系
## position_id: 0总理 1军委 2外交 3首都 4北方 5西方 6南方 7东方
## 对齐 Button_Pol_Script num7/5/6/8-12（注意原版按钮编号与 dolshnost 索引映射）
func assign_politician_position(pol_index: int, position_id: int) -> bool:
	if world == null or pol_index < 0 or pol_index >= world.politicians.size():
		return false
	if position_id < 0 or position_id >= world.politics_positions.size():
		return false
	var pol: PoliticianData = world.politicians[pol_index]
	if _is_vacant_politician(pol) or pol.is_under_investigation:
		return false
	# 已在该职
	if world.politics_positions[position_id] == pol_index:
		return false

	# 职位互斥：地方 3-7 互斥；总理清空其它；军委/外交互斥对方
	for i in range(3, 8):
		if world.politics_positions[i] == pol_index:
			world.politics_positions[i] = -1
	if position_id == 0:
		for i in range(1, 8):
			if world.politics_positions[i] == pol_index:
				world.politics_positions[i] = -1
	elif position_id == 1 or position_id == 2:
		var other_central := 2 if position_id == 1 else 1
		if world.politics_positions[other_central] == pol_index:
			world.politics_positions[other_central] = -1

	# 前任惩罚表：prev_loyalty_delta, prev_matrix_delta, new_loyalty, wanted_bonus
	# wanted 命中时 prev 额外 -400 loyalty 与 matrix（原版）
	var prev_loy := 250
	var prev_mat := 50
	var new_loy := 250
	match position_id:
		0:  # 总理 num7
			prev_loy = 800; prev_mat = 400; new_loy = 400
		1:  # 军委 num5
			prev_loy = 700; prev_mat = 300; new_loy = 350
		2:  # 外交 num6
			prev_loy = 600; prev_mat = 250; new_loy = 350
		3:  # 首都 num8
			prev_loy = 250; prev_mat = 50; new_loy = 300
		_:  # 地方 4-7
			prev_loy = 150; prev_mat = 0; new_loy = 250

	var prev_holder: int = world.politics_positions[position_id]
	if prev_holder >= 0 and prev_holder < world.politicians.size() and prev_holder != pol_index:
		var prev_pol: PoliticianData = world.politicians[prev_holder]
		if not _is_vacant_politician(prev_pol):
			var extra := 400 if prev_pol.wanted_position == position_id else 0
			prev_pol.loyalty -= prev_loy + extra
			if pol_index < prev_pol.loyalty_matrix.size():
				prev_pol.loyalty_matrix[pol_index] = maxi(
					0, prev_pol.loyalty_matrix[pol_index] - (prev_mat + extra)
				)

	world.politics_positions[position_id] = pol_index
	pol.loyalty += new_loy
	if pol.wanted_position == position_id:
		pol.loyalty += 250
		pol.power += 20
	pol.in_power = true

	# POL-20：任命后重算目标与前任关系矩阵 + 对领袖忠诚
	WorldFactory._calc_rel(world, pol_index)
	WorldFactory._calc_rel2(world, pol_index)
	WorldFactory._calc_rel_leader(world, pol_index)
	if prev_holder >= 0 and prev_holder < world.politicians.size() and prev_holder != pol_index:
		WorldFactory._calc_rel(world, prev_holder)
		WorldFactory._calc_rel2(world, prev_holder)
		WorldFactory._calc_rel_leader(world, prev_holder)

	_sync_in_power_flags(world)
	fill_vacant_faction_leaders()
	_notify_stats()
	return true


## 指定派系负责人后重算关系（FAC-07 半）
func set_faction_leader_politician(pol_index: int) -> bool:
	if world == null or pol_index < 0 or pol_index >= world.politicians.size():
		return false
	var pol: PoliticianData = world.politicians[pol_index]
	if _is_vacant_politician(pol):
		return false
	var faction_id: int = pol.party_index()
	if faction_id < 0 or faction_id >= world.factions.size():
		return false
	var prev: int = world.factions[faction_id].leader_index
	if prev >= 0 and prev < world.politicians.size() and prev != pol_index:
		var prev_pol: PoliticianData = world.politicians[prev]
		prev_pol.loyalty -= 1000
		if pol_index < prev_pol.loyalty_matrix.size():
			prev_pol.loyalty_matrix[pol_index] -= 500
	world.factions[faction_id].leader_index = pol_index
	# 同派小惩罚
	for i in world.politicians.size():
		if i == pol_index:
			continue
		var other: PoliticianData = world.politicians[i]
		if other != null and other.party_index() == faction_id:
			other.loyalty -= 100
	pol.loyalty += 400
	WorldFactory._calc_rel(world, pol_index)
	WorldFactory._calc_rel2(world, pol_index)
	WorldFactory._calc_rel_leader(world, pol_index)
	if prev >= 0 and prev < world.politicians.size() and prev != pol_index:
		WorldFactory._calc_rel(world, prev)
		WorldFactory._calc_rel2(world, prev)
		WorldFactory._calc_rel_leader(world, prev)
	_notify_stats()
	return true


## 空缺派系领袖：按 Party 槽从在世政客中选 power 最高者（POL-04）
func fill_vacant_faction_leaders() -> void:
	if world == null:
		return
	for fi in world.factions.size():
		var f: FactionData = world.factions[fi]
		if f.leader_index >= 0 and f.leader_index < world.politicians.size():
			var cur: PoliticianData = world.politicians[f.leader_index]
			if not _is_vacant_politician(cur):
				continue
			f.leader_index = -1
		if f.leader_index >= 0:
			continue
		var best_idx := -1
		var best_power := -1
		var fallback_idx := -1
		var fallback_power := -1
		for i in world.politicians.size():
			var p: PoliticianData = world.politicians[i]
			if _is_vacant_politician(p):
				continue
			var party: int = p.party_index()
			if party == fi and p.power > best_power:
				best_power = p.power
				best_idx = i
			# 保守派空缺：允许 traits 映射到 0/1 的人作次选（简化 TimeScript 957）
			if fi == 1 and (party == 0 or party == 1) and p.power > fallback_power:
				fallback_power = p.power
				fallback_idx = i
		if best_idx >= 0:
			f.leader_index = best_idx
		elif fallback_idx >= 0:
			f.leader_index = fallback_idx


# ── 每日：赤字恢复（原版 546-563，日块 Repaint(true)）──
## 原版条件 data[36]+(data[8]+data[36])>=0 即 2*reserve+budget>=0。
## 储备耗尽仍赤字时：speed=0 + 强制跳转经济界面（原版 goto_economy）。
func _daily_deficit_recovery(w: WorldState) -> void:
	var d := w.数值表
	if d[W.I_BUDGET] >= 0:
		return
	if d[W.I_RESERVE] + (d[W.I_BUDGET] + d[W.I_RESERVE]) >= 0:
		d[W.I_RESERVE] += d[W.I_BUDGET]
		d[W.I_BUDGET] = 0
	else:
		d[W.I_BUDGET] += d[W.I_RESERVE]
		d[W.I_RESERVE] = 0
		if d[W.I_BUDGET] < 0:
			speed = 0
			is_playing = false
			call_deferred("_force_goto_economy")


# ── 每日：科研点生成（原版 1224，日块）──
## data[11] += data[73]/50，每日执行（原版日块，非月块）。
func _daily_science_gen(w: WorldState) -> void:
	w.数值表[W.I_SCIENCE] += w.数值表[W.I_BUDGET_SCIENCE] / 50


# ── 每日：开放度→显示等级映射（原版 1136-1167，日块）──
func _update_displays(d: Array[int]) -> void:
	if d[W.I_ECON_OPENNESS] <= 250: d[W.I_ECON_DISPLAY] = 34
	elif d[W.I_ECON_OPENNESS] <= 500: d[W.I_ECON_DISPLAY] = 35
	elif d[W.I_ECON_OPENNESS] <= 750: d[W.I_ECON_DISPLAY] = 36
	else: d[W.I_ECON_DISPLAY] = 37
	if d[W.I_POLITICAL_OPENNESS] <= 250: d[W.I_POLITICAL_DISPLAY] = 38
	elif d[W.I_POLITICAL_OPENNESS] <= 500: d[W.I_POLITICAL_DISPLAY] = 39
	elif d[W.I_POLITICAL_OPENNESS] <= 750: d[W.I_POLITICAL_DISPLAY] = 40
	else: d[W.I_POLITICAL_DISPLAY] = 41


# ── 月度：人口增长（原版 2280-2356，月块 data[19]==1）──
func _monthly_population(d: Array[int], w: WorldState) -> void:
	var pop_base: int = d[105]  # 人口增长基数（原版 data[105]，开局=2）
	# 产值过低 → 人口下降
	if d[W.I_AGRICULTURE] < 250:
		d[W.I_POPULATION] -= 15
	elif d[W.I_AGRICULTURE] < 410:
		d[W.I_POPULATION] -= 8
	if d[W.I_SERVICES] < 250:
		d[W.I_POPULATION] -= 4
	if d[W.I_INDUSTRY] < 250:
		d[W.I_POPULATION] -= 8
	elif d[W.I_INDUSTRY] < 410:
		d[W.I_POPULATION] -= 4
	# 舆论政策 18/19 → 人口下降
	if d[W.I_PRESS_POLICY] == 18:
		d[W.I_POPULATION] -= 4
	elif d[W.I_PRESS_POLICY] == 19:
		d[W.I_POPULATION] -= 9
	# 宗教政策 28/29 → 人口增长
	if d[W.I_RELIGION] == 28:
		d[W.I_POPULATION] += pop_base
	elif d[W.I_RELIGION] == 29:
		d[W.I_POPULATION] += 2 * pop_base
	# 经济体制基于人口规模的影响
	if d[W.I_ECON_SYSTEM] == 11 or d[W.I_ECON_SYSTEM] == 10:
		d[W.I_INDUSTRY] += d[W.I_POPULATION] / 5000
	elif d[W.I_ECON_SYSTEM] == 14 and not _mod_active(w, 13):
		d[W.I_PEOPLE_SUPPORT] -= d[W.I_POPULATION] / 4000
	elif d[W.I_ECON_SYSTEM] == 15 and not _mod_active(w, 13):
		d[W.I_PEOPLE_SUPPORT] -= d[W.I_POPULATION] / 4000
	# 生活水平 → 人口增长
	d[W.I_POPULATION] += d[W.I_LIVING] / 60 * pop_base
	# 意识形态/生活水平条件块
	if d[W.I_IDEOLOGY] <= 0 and d[W.I_LIVING] <= 500:
		d[W.I_POPULATION] += 6 * pop_base
	elif d[W.I_IDEOLOGY] <= 3 and d[W.I_LIVING] <= 400:
		d[W.I_POPULATION] += 2 * pop_base
	elif d[W.I_IDEOLOGY] == 4 and d[W.I_LIVING] >= 850:
		d[W.I_POPULATION] -= 11
	elif d[W.I_IDEOLOGY] == 4 and d[W.I_LIVING] >= 650:
		d[W.I_POPULATION] -= 9
	elif d[W.I_IDEOLOGY] == 5 and d[W.I_LIVING] >= 850:
		d[W.I_POPULATION] -= 13
	elif d[W.I_IDEOLOGY] == 5 and d[W.I_LIVING] >= 650:
		d[W.I_POPULATION] -= 11


# ── 月度：寡头成长（原版 1902-2123，月块 data[19]==1）──
func _monthly_oligarch(d: Array[int], w: WorldState) -> void:
	var year: int = w.date.year
	var econ := d[W.I_ECON_SYSTEM]
	if econ > 13:
		# econ == 14/15
		if econ == 14 and year < 1980:
			d[W.I_OLIGARCH] += 5
		elif econ == 14:
			d[W.I_OLIGARCH] += 1
		elif econ == 15 and year < 1980:
			d[W.I_OLIGARCH] += 10
		elif econ == 15:
			d[W.I_OLIGARCH] += 4
		if d[W.I_PARTY_SYSTEM] <= 7:
			d[W.I_OLIGARCH] += 2
		elif d[W.I_PARTY_SYSTEM] == 8:
			d[W.I_OLIGARCH] += 1
		elif d[W.I_PARTY_SYSTEM] == 9:
			d[W.I_OLIGARCH] -= 1
		if d[W.I_PRESS_POLICY] <= 16:
			d[W.I_OLIGARCH] += 2
		elif d[W.I_PRESS_POLICY] == 17:
			d[W.I_OLIGARCH] += 1
		elif d[W.I_PRESS_POLICY] == 19:
			d[W.I_OLIGARCH] -= 1
		if d[W.I_TERRITORY] == 21:
			d[W.I_OLIGARCH] += 1
		elif d[W.I_TERRITORY] == 22:
			d[W.I_OLIGARCH] += 2
		elif d[W.I_TERRITORY] == 23:
			d[W.I_OLIGARCH] += 3
		if d[W.I_RELIGION] == 24:
			d[W.I_OLIGARCH] += 1
		elif d[W.I_RELIGION] == 25:
			d[W.I_OLIGARCH] -= 1
		elif d[W.I_RELIGION] == 28:
			d[W.I_OLIGARCH] += 1
		elif d[W.I_RELIGION] == 29:
			d[W.I_OLIGARCH] += 3
		if d[W.I_MIL_DOCTRINE] == 30:
			d[W.I_OLIGARCH] += 2
		elif d[W.I_MIL_DOCTRINE] == 31:
			d[W.I_OLIGARCH] += 1
		if _mod_active(w, 7):
			d[W.I_OLIGARCH] -= 1
		if _mod_active(w, 13):
			d[W.I_OLIGARCH] -= 2
		if _mod_active(w, 5):
			d[W.I_OLIGARCH] += 3
	elif econ == 13:
		if year < 1980:
			d[W.I_OLIGARCH] += 1
		if d[W.I_PARTY_SYSTEM] == 9:
			d[W.I_OLIGARCH] -= 1
		if d[W.I_PRESS_POLICY] == 19:
			d[W.I_OLIGARCH] -= 1
		if d[W.I_TERRITORY] == 21:
			d[W.I_OLIGARCH] += 1
		elif d[W.I_TERRITORY] == 22:
			d[W.I_OLIGARCH] += 2
		elif d[W.I_TERRITORY] == 23:
			d[W.I_OLIGARCH] += 3
		if d[W.I_RELIGION] == 24:
			d[W.I_OLIGARCH] += 1
		elif d[W.I_RELIGION] == 25:
			d[W.I_OLIGARCH] -= 1
		elif d[W.I_RELIGION] == 28:
			d[W.I_OLIGARCH] += 1
		elif d[W.I_RELIGION] == 29:
			d[W.I_OLIGARCH] += 3
		if _mod_active(w, 7):
			d[W.I_OLIGARCH] -= 1
		if _mod_active(w, 13):
			d[W.I_OLIGARCH] -= 2
		if _mod_active(w, 5):
			d[W.I_OLIGARCH] += 3
	elif econ == 12:
		if d[W.I_OLIGARCH] > 50:
			d[W.I_PARTY_SUPPORT] -= (d[W.I_OLIGARCH] - 50) * 10
			if w.empires.size() > 0:
				w.empires[0].relations -= (d[W.I_OLIGARCH] - 50) * 5
			d[W.I_LIVING] += (d[W.I_OLIGARCH] - 50) * 5
			d[W.I_DIPLO] += (d[W.I_OLIGARCH] - 50) * 5
			d[W.I_AGENTS] -= (d[W.I_OLIGARCH] - 50) * 5
			d[W.I_OLIGARCH] = 50
		if d[W.I_PARTY_SYSTEM] == 9:
			d[W.I_OLIGARCH] -= 1
		if d[W.I_PRESS_POLICY] == 19:
			d[W.I_OLIGARCH] -= 1
		if d[W.I_RELIGION] == 24:
			d[W.I_OLIGARCH] += 1
		elif d[W.I_RELIGION] == 25:
			d[W.I_OLIGARCH] -= 1
		elif d[W.I_RELIGION] == 28:
			d[W.I_OLIGARCH] += 1
		elif d[W.I_RELIGION] == 29:
			d[W.I_OLIGARCH] += 3
		d[W.I_OLIGARCH] -= 3
		if _mod_active(w, 5):
			d[W.I_OLIGARCH] += 3
	elif d[W.I_OLIGARCH] > 0:
		# econ <= 11：寡头归零
		d[W.I_PARTY_SUPPORT] -= d[W.I_OLIGARCH] * 10
		if w.empires.size() > 0:
			w.empires[0].relations -= d[W.I_OLIGARCH] * 5
		d[W.I_LIVING] += d[W.I_OLIGARCH] * 5
		d[W.I_DIPLO] += d[W.I_OLIGARCH] * 5
		d[W.I_AGENTS] -= d[W.I_OLIGARCH] * 5
		d[W.I_OLIGARCH] = 0


# ── 修正辅助：modifier 是否激活 ──
func _mod_active(w: WorldState, idx: int) -> bool:
	return w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


# ── 双周：科研推进（原版 5458-5574，双周块）──
func _fortnight_research_advance(d: Array[int], w: WorldState) -> void:
	if w.techs == null:
		return
	if w.techs.is_researching():
		d[W.I_SCIENCE] = w.techs.monthly_advance(d[W.I_SCIENCE])
		var completed: int = w.techs.get_completed_this_tick()
		if completed >= 0:
			_apply_tech(completed)
			tech_completed.emit(completed)
	# 无研究时科研点上限 300（原版 5585-5587）
	if not w.techs.is_researching() and d[W.I_SCIENCE] > 300:
		d[W.I_SCIENCE] = 300


# ── 双周：已解锁科技持续加成（TimeScript 4936-5140行） ──
## 原版每双周对所有已解锁科技重复施加效果（非一次性）。
func _apply_tech_periodic(w: WorldState) -> void:
	if w.techs == null:
		return
	var d := w.数值表
	var u := w.techs.unlocked
	if u.size() < w.techs.TECH_COUNT:
		return
	if u[0]: d[W.I_LIVING] += 2; d[W.I_AGRICULTURE] += 1
	if u[1]: d[W.I_AGRICULTURE] += 2
	if u[2]: d[W.I_LIVING] += 1; d[W.I_AGRICULTURE] += 1; d[W.I_BUDGET] += 1
	if u[3]: d[W.I_LIVING] += 2; d[W.I_AGRICULTURE] += 1
	if u[4]: d[W.I_LIVING] += 4; d[W.I_SCIENCE] += 5
	if u[5]: d[W.I_LIVING] += 2; d[W.I_SCIENCE] += 10
	if u[6]: d[W.I_LIVING] += 2; d[W.I_AGRICULTURE] += 1
	if u[7]: d[W.I_LIVING] += 2; d[W.I_BUDGET] += 1
	if u[8]: d[W.I_AGRICULTURE] += 2
	if u[9]: d[W.I_BUDGET] += 1; d[W.I_INDUSTRY] += 2
	if u[10]: d[W.I_BUDGET] += 1; d[W.I_ARMY] += 4; d[W.I_INDUSTRY] += 2
	if u[11]: d[W.I_LIVING] += 2
	if u[12]: d[W.I_BUDGET] += 2; d[W.I_INDUSTRY] += 1
	if u[13]: d[W.I_LIVING] += 3
	if u[14]: d[W.I_LIVING] += 2; d[W.I_BUDGET] += 1; d[W.I_INDUSTRY] += 2
	if u[15]: d[W.I_LIVING] += 2; d[W.I_BUDGET] += 2; d[W.I_INDUSTRY] += 1; d[W.I_AGRICULTURE] += 1
	if u[16]: d[W.I_LIVING] += 3; d[W.I_BUDGET] += 2; d[W.I_SCIENCE] += 5; d[W.I_MANPOWER] += 4
	if u[17]: d[W.I_LIVING] += 3; d[W.I_BUDGET] += 3
	if u[18]: d[W.I_ARMY] += 2
	if u[19]: d[W.I_AGENTS] += 3; d[W.I_THOUGHT_FREEDOM] -= 3
	if u[20]: d[W.I_AGENTS] += 2; d[W.I_THOUGHT_FREEDOM] -= 2; d[W.I_PEOPLE_SUPPORT] += 2
	if u[21]: d[W.I_ARMY] += 2; d[W.I_PARTY_SUPPORT] += 3; d[W.I_PEOPLE_SUPPORT] += 1
	if u[22]: d[W.I_PEOPLE_SUPPORT] += 2; d[W.I_THOUGHT_FREEDOM] -= 2; d[W.I_PARTY_SUPPORT] += 2
	if u[23]: d[W.I_ARMY] += 4
	if u[24]: d[W.I_ARMY] += 4; d[W.I_THOUGHT_FREEDOM] -= 2
	if u[25]: d[W.I_AGENTS] += 2; d[W.I_THOUGHT_FREEDOM] -= 2; d[W.I_PARTY_SUPPORT] += 3
	if u[26]: d[W.I_ARMY] += 4; d[W.I_THOUGHT_FREEDOM] -= 2


# ── 双周：贷款利息 + 外援(dota)（TimeScript 5365-5454 + 1620-1645） ──
func _fortnight_loan_interest(d: Array[int], w: WorldState) -> void:
	var loan: int = d[W.I_LOAN]
	var year: int = w.date.year if w.date else 1976
	# 国债利息（与 UI「债务损耗」对齐）
	if loan > 0:
		var interest: int = loan / 40
		var usa_leader := 0
		if w.empires.size() > 0 and w.empires[0] != null:
			usa_leader = w.empires[0].current_leader
		# 原版：里根(now_leader==3) 奇数月可豁免预算扣款
		var skip_budget := (usa_leader == 3 and w.date != null and w.date.month % 2 != 0)
		if interest <= 0:
			if not skip_budget:
				d[W.I_BUDGET] -= 1
				if year >= 1983:
					d[W.I_BUDGET] -= 2
				elif year >= 1980:
					d[W.I_BUDGET] -= 1
			if loan > 10:
				d[W.I_LOAN] -= 1
			if w.empires.size() > 1 and w.empires[1] != null:
				w.empires[1].relations -= 2
		else:
			if not skip_budget:
				d[W.I_BUDGET] -= interest
				if year >= 1983:
					d[W.I_BUDGET] -= 1
			if w.empires.size() > 1 and w.empires[1] != null:
				w.empires[1].relations -= loan / 20
			if loan > 10:
				d[W.I_LOAN] -= interest / 2 + 1
	# 外援 dota（data[146] = 援助强度；贸易同盟国吃援助）
	var aid: int = d[W.I_FOREIGN_AID] if d.size() > W.I_FOREIGN_AID else 0
	if aid > 0:
		d[W.I_BUDGET] -= aid
		d[W.I_AGENTS] -= aid
		d[W.I_ARMY] -= aid
		var ovd_alive := false
		for x in w.countries:
			if x != null and x.has_tag("ovd"):
				ovd_alive = true
				break
		for c in w.countries:
			if c == null or not c.has_tag("贸易同盟"):
				continue
			if ovd_alive:
				c.sov_power = maxi(c.sov_power - 10, 0)
			else:
				c.usa_power = maxi(c.usa_power - 10, 0)
			c.prc_power = mini(c.prc_power + 5, 1000)


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
	elif d[W.I_AGENTS] > 0 and d[W.I_AGENTS] <= 150 and d[W.I_BUDGET_MGB] <= 150:
		d[W.I_CORRUPTION] -= d[W.I_AGENTS] / 50 + d[W.I_BUDGET_MGB] / 100
	elif d[W.I_AGENTS] > 0 and d[W.I_AGENTS] <= 150 and d[W.I_BUDGET_MGB] > 150:
		d[W.I_CORRUPTION] -= d[W.I_AGENTS] / 50 + 1
	elif d[W.I_BUDGET_MGB] > 150:
		d[W.I_CORRUPTION] -= 4

	# ─ 科研经费 ─
	# 科研点生成（data[11]+=data[73]/50）原版在日块（1224行），已移至 _daily_science_gen
	d[W.I_CORRUPTION] += d[W.I_BUDGET_SCIENCE] / 50

	# ─ 行政支出 ─
	d[W.I_CORRUPTION] -= d[W.I_BUDGET_ADMIN] / 20
	d[W.I_PARTY_SUPPORT] += d[W.I_BUDGET_ADMIN] / 25
	d[W.I_LIVING] += d[W.I_BUDGET_ADMIN] / 70

	# ─ 高层福利(信封) ─
	d[W.I_CORRUPTION] += d[W.I_BUDGET_ENVELOPE] / 25
	d[W.I_PARTY_SUPPORT] += (d[W.I_BUDGET_ENVELOPE] - 61) / 5
	# ECO-POL-01：信封高低影响政客忠诚
	_apply_envelope_loyalty(d)

	# ─ 宣传支出（原版 8138-8146）──
	d[W.I_MANPOWER] += d[W.I_BUDGET_PROPAGANDA] / 150
	d[W.I_CORRUPTION] += d[W.I_BUDGET_PROPAGANDA] / 150
	d[W.I_THOUGHT_FREEDOM] -= d[W.I_BUDGET_PROPAGANDA] / 100
	# 原版无条件：data[3] += (data[76]-70)/10（prop<70 时为负，扣民众支持）
	d[W.I_PEOPLE_SUPPORT] += (d[W.I_BUDGET_PROPAGANDA] - 70) / 10
	if d[W.I_BUDGET_PROPAGANDA] < 50:
		d[W.I_CORRUPTION] += (50 - d[W.I_BUDGET_PROPAGANDA]) / 20
		d[W.I_PEOPLE_SUPPORT] -= (50 - d[W.I_BUDGET_PROPAGANDA]) / 20

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

	# ─ 腐败扣预算/生活水平（原版 8186-8187，投资块末尾，用投资后腐败值）──
	d[W.I_BUDGET] -= d[W.I_CORRUPTION] / 10
	d[W.I_LIVING] -= d[W.I_CORRUPTION] / 50


## ECO-POL-01：高层福利预算 → 政客忠诚微调
func _apply_envelope_loyalty(d: Array[int]) -> void:
	if world == null:
		return
	var env: int = d[W.I_BUDGET_ENVELOPE]
	var delta := 0
	if env >= 90:
		delta = 8
	elif env >= 70:
		delta = 3
	elif env <= 30:
		delta = -8
	elif env <= 50:
		delta = -3
	if delta == 0:
		return
	for p in world.politicians:
		if p == null or p.name_display == "空位":
			continue
		p.loyalty += delta


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
			and d[W.I_PRESS_POLICY] <= 16 and d[W.I_TERRITORY] <= 21 \
			and (d[W.I_RELIGION] <= 24 or d[W.I_RELIGION] >= 28) \
			and (d[W.I_MIL_DOCTRINE] <= 31 or d[W.I_MIL_DOCTRINE] >= 33):
		new_system = 0; new_gosstroy = 0
	# 原版 1183：system=0 的第二分支含 3 个子条件
	elif (score <= 6 or (score <= 7 and d[W.I_ECON_SYSTEM] <= 11) \
			or (score <= 9 and _mod_active(w, 40))) and d[W.I_PRESS_POLICY] < 18:
		new_system = 0; new_gosstroy = 0
	elif score <= 9 and d[W.I_ECON_SYSTEM] <= 11:
		new_system = 1; new_gosstroy = 1
	elif score <= 11:
		new_system = 2; new_gosstroy = 1
	elif score <= 15 and d[W.I_ECON_SYSTEM] > 11:
		new_system = 3; new_gosstroy = 2
	elif score <= 20 and d[W.I_ECON_SYSTEM] > 11:
		new_system = 4; new_gosstroy = 3
	elif d[W.I_ECON_SYSTEM] > 11:
		new_system = 5; new_gosstroy = 3
	else:
		new_system = 2; new_gosstroy = 2

	d[W.I_IDEOLOGY] = new_system
	var pc := w.get_player_country()
	if pc:
		pc.government = new_gosstroy
	# FAC-SAT：满意现秩序者 + 一党制下政治路线跟最大派（Doctrine_button ~1227）
	_update_satisfied_and_political_line(d, w)


## 满意现秩序者 data[106] 与政治路线 data[56]
## 原版 Doctrine_button_script：
##   data[15]<=7：data[106] += party_ideology[data[56]]/4，并按 party_number 最大派写 data[56]
##   data[15]>7：data[106] += party_number[1]/4（保守基座）
## party_ideology 我方用 FactionData.influence（开局=原 ideology 列）
func _update_satisfied_and_political_line(d: Array[int], w: WorldState) -> void:
	if w.factions.is_empty() or d.size() <= W.I_SATISFIED:
		return
	@warning_ignore("integer_division")
	var party_sys: int = d[W.I_PARTY_SYSTEM]
	if party_sys <= 7:
		# 一党/专政：按当前政治路线的 ideology 基座增长
		var line: int = clampi(d[W.I_POLITICAL_LINE], 0, w.factions.size() - 1)
		var base_ideo: int = w.factions[line].influence
		if base_ideo <= 0:
			base_ideo = w.factions[line].support
		d[W.I_SATISFIED] += base_ideo / 4
		# 政治路线跟随最大启用派 support（原版 party_number 比较链）
		var best_i := 0
		var best_s := -1
		for i in w.factions.size():
			var f: FactionData = w.factions[i]
			if not f.is_enabled and i != 0:
				# 极左即使禁用仍可比较？原版不查 enabled；用 support 即可
				pass
			if f.support > best_s:
				best_s = f.support
				best_i = i
		d[W.I_POLITICAL_LINE] = best_i
	else:
		# 多党/联合：满意现秩序者吃保守派 support/4
		var cons: int = 0
		if w.factions.size() > FactionData.CONSERVATIVE:
			cons = w.factions[FactionData.CONSERVATIVE].support
		d[W.I_SATISFIED] += cons / 4
	d[W.I_SATISFIED] = maxi(0, d[W.I_SATISFIED])


# ── 半年度：factionsPoints（TimeScript ~740–762，非合作模式也可用经济指标）──
## 原版挂在 dlc[0]&&gamerules；本移植：始终按经济/党支持给积分，供 spend_faction_points 或自动折算。

func _biannual_faction_points(d: Array[int], w: WorldState) -> void:
	if w.factions.is_empty():
		return
	@warning_ignore("integer_division")
	# 按 support 排序 (index, support)
	var ranked: Array = []
	for i in w.factions.size():
		ranked.append([i, w.factions[i].support])
	ranked.sort_custom(func(a, b) -> bool: return a[1] > b[1])

	var people: int = d[W.I_PEOPLE_SUPPORT] / 100
	var living: int = d[W.I_LIVING] / 100
	var liberal: int = d[W.I_THOUGHT_FREEDOM] / 100
	var party_u: int = d[W.I_PARTY_SUPPORT] / 100

	# 最大 2 派：+民众支持/100、+生活/100
	for k in mini(2, ranked.size()):
		var idx: int = ranked[k][0]
		w.factions[idx].points += people
		w.factions[idx].points += living
	# 最大 3 派：再 +生活（原版 top3 都加 living；top2 已加一次 → top3 再加 living 等价 top2 双倍）
	if ranked.size() >= 3:
		w.factions[ranked[2][0]].points += living
	# 最小 2 派：+自由化；最小 3 派：+(10-民众)
	var n := ranked.size()
	for k in mini(2, n):
		var idx2: int = ranked[n - 1 - k][0]
		w.factions[idx2].points += liberal
	for k in mini(3, n):
		var idx3: int = ranked[n - 1 - k][0]
		w.factions[idx3].points += 10 - people
	# 非最大派：+党支持/100
	var top_idx: int = ranked[0][0]
	for i in w.factions.size():
		if i != top_idx:
			w.factions[i].points += party_u

	# 自动轻量折算：积分≥10 时每半年自动花一轮，避免积分只涨不花
	for i in w.factions.size():
		var f: FactionData = w.factions[i]
		if f.points >= 10 and f.is_enabled:
			var chunks: int = f.points / 10
			# 最多折 3 档，避免半年暴涨
			chunks = mini(chunks, 3)
			f.points -= 10 * chunks
			f.support += chunks * 2


# ── 半年度：派系支持漂移（路线/结盟微调，叠在积分折算之上）──

func _biannual_faction_drift(w: WorldState) -> void:
	var d := w.数值表
	var political_line: int = d[W.I_POLITICAL_LINE]
	var econ: int = d[W.I_ECON_SYSTEM]
	var freedom: int = d[W.I_THOUGHT_FREEDOM]
	# ECO-FAC-02：经济越开放(数值越大) / 思想自由越高，改革/自由略受益
	var open_bias := 0
	if econ >= 14:
		open_bias = 2
	elif econ >= 12:
		open_bias = 1
	elif econ <= 11:
		open_bias = -1
	if freedom >= 400:
		open_bias += 1
	elif freedom <= 150:
		open_bias -= 1
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
		# 开放偏向：3改革 +bias，4自由 +bias，0极左/1保守 -bias
		if open_bias != 0:
			if f.id >= 3:
				f.support += open_bias
			elif f.id <= 1:
				f.support -= open_bias
		f.support = maxi(0, f.support)


# ── 双周：经济体制效果（原版 3551-3664，双周块）──
## 含 data[52]/data[54] 显示等级条件副效果。
func _fortnight_econ_system_effect(d: Array[int]) -> void:
	var econ := d[W.I_ECON_SYSTEM]
	match econ:
		11:
			d[W.I_BUDGET] += 1
			d[W.I_THOUGHT_FREEDOM] -= 2
			d[W.I_LIVING] += 4
			d[W.I_INDUSTRY] += 2
			d[W.I_CORRUPTION] -= 5
			if d[W.I_ECON_DISPLAY] > 34:
				d[W.I_ECON_OPENNESS] -= 50
		10:
			d[W.I_LIVING] += 2
			d[W.I_THOUGHT_FREEDOM] += 1
			d[W.I_SERVICES] -= 1
			d[W.I_INDUSTRY] += 1
			d[W.I_CORRUPTION] += 1
			if d[W.I_ECON_DISPLAY] > 34:
				d[W.I_ECON_OPENNESS] -= 50
		12:
			d[W.I_AGRICULTURE] += 1
			d[W.I_BUDGET] += 1
			d[W.I_SERVICES] += 1
			d[W.I_LIVING] -= 2
			d[W.I_THOUGHT_FREEDOM] -= 2
			d[W.I_CORRUPTION] += 1
			if d[W.I_POLITICAL_DISPLAY] < 40:
				d[W.I_CORRUPTION] += 1
			if d[W.I_ECON_DISPLAY] > 35:
				d[W.I_ECON_OPENNESS] -= 20
			elif d[W.I_ECON_DISPLAY] < 35:
				d[W.I_ECON_OPENNESS] += 30
		13:
			d[W.I_BUDGET] += 2
			d[W.I_SERVICES] += 1
			d[W.I_LIVING] -= 4
			d[W.I_THOUGHT_FREEDOM] += 1
			d[W.I_CORRUPTION] += 1
			if d[W.I_POLITICAL_DISPLAY] < 40:
				d[W.I_CORRUPTION] += 2
			if d[W.I_ECON_DISPLAY] > 36:
				d[W.I_ECON_OPENNESS] -= 40
			elif d[W.I_ECON_DISPLAY] < 36:
				d[W.I_ECON_OPENNESS] += 30
		14:
			d[W.I_BUDGET] += 2
			d[W.I_SERVICES] += 2
			d[W.I_LIVING] -= 5
			d[W.I_THOUGHT_FREEDOM] += 2
			d[W.I_INDUSTRY] -= 1
			d[W.I_CORRUPTION] += 2
			if d[W.I_POLITICAL_DISPLAY] < 40:
				d[W.I_CORRUPTION] += 4
			if d[W.I_ECON_DISPLAY] < 37:
				d[W.I_ECON_OPENNESS] += 40
		15:
			d[W.I_AGRICULTURE] -= 1
			d[W.I_SERVICES] += 3
			d[W.I_LIVING] -= 7
			d[W.I_THOUGHT_FREEDOM] += 4
			d[W.I_INDUSTRY] -= 2
			d[W.I_CORRUPTION] += 2
			if d[W.I_POLITICAL_DISPLAY] < 40:
				d[W.I_CORRUPTION] += 5
			if d[W.I_ECON_DISPLAY] < 37:
				d[W.I_ECON_OPENNESS] += 50


# ============================================================================
# 双周 tick — 移植自 TimeScript.cs 每14天周期的核心模拟
# ============================================================================

func _on_fortnight() -> void:
	var w := world
	if w == null:
		return
	var d := w.数值表
	var year := w.date.year

	_fortnight_industry_decay(d)
	_fortnight_agriculture_decay(d)
	_fortnight_services_decay(d)
	_influence_from_investments(d, year)
	_apply_tech_periodic(w)
	_fortnight_loan_interest(d, w)
	_fortnight_research_advance(d, w)
	_fortnight_trade_balance(d, w)
	_fortnight_satisfaction_drift(d, w)
	_fortnight_political_drift(d, w)
	_fortnight_military_doctrine(d, w)
	_fortnight_econ_system_effect(d)
	_fortnight_difficulty_bonus(d, w)
	_fortnight_modifiers(d, w)
	_check_coup(d, w)
	_fortnight_wars(w)
	# 阴谋网也挂双周一次（原版 Death/Plot 在年/特定块；月结已跑，此处不重复击杀）
	_check_endings(d, w, year)

	w.flush_economy()


# ── 产业自然衰减（TimeScript 5195-5260行） ──

func _fortnight_industry_decay(d: Array[int]) -> void:
	var v := d[W.I_INDUSTRY]
	if v < 250:
		d[W.I_INDUSTRY] -= 2
		d[W.I_PARTY_SUPPORT] -= 10
		d[W.I_LIVING] -= 5
		d[W.I_ARMY] -= 5
	elif v < 410:
		d[W.I_INDUSTRY] -= 3
		d[W.I_PARTY_SUPPORT] -= 5
		d[W.I_LIVING] -= 2
		d[W.I_ARMY] -= 2
	elif v < 610:
		d[W.I_INDUSTRY] -= 15
		d[W.I_PARTY_SUPPORT] -= 1
	elif v < 710:
		d[W.I_INDUSTRY] -= 22
	elif v < 810:
		d[W.I_INDUSTRY] -= 28
	else:
		d[W.I_INDUSTRY] -= 40
		d[W.I_AGENTS] += 5
	if d[W.I_ECON_SYSTEM] < 13:
		if d[W.I_AGRICULTURE] < 300:
			d[W.I_INDUSTRY] -= 4
		elif d[W.I_AGRICULTURE] < 500:
			d[W.I_INDUSTRY] -= 2
	d[W.I_BUDGET] += d[W.I_INDUSTRY] / 50


# ── 农业自然衰减（TimeScript 5319-5364行） ──

func _fortnight_agriculture_decay(d: Array[int]) -> void:
	var v := d[W.I_AGRICULTURE]
	if v < 250:
		d[W.I_AGRICULTURE] -= 2
		d[W.I_PARTY_SUPPORT] -= 10
		d[W.I_LIVING] -= 5
	elif v < 410:
		d[W.I_AGRICULTURE] -= 9
		d[W.I_PARTY_SUPPORT] -= 5
		d[W.I_LIVING] -= 2
	elif v < 610:
		d[W.I_AGRICULTURE] -= 15
		d[W.I_PARTY_SUPPORT] -= 1
	elif v < 710:
		d[W.I_AGRICULTURE] -= 22
	elif v < 810:
		d[W.I_AGRICULTURE] -= 28
	else:
		d[W.I_AGRICULTURE] -= 40
		d[W.I_ARMY] += 5
	d[W.I_BUDGET] += d[W.I_AGRICULTURE] / 100


# ── 服务业自然衰减（TimeScript 5258-5318行） ──

func _fortnight_services_decay(d: Array[int]) -> void:
	var v := d[W.I_SERVICES]
	if v < 250:
		d[W.I_SERVICES] -= 1
		d[W.I_PARTY_SUPPORT] -= 10
		d[W.I_LIVING] -= 5
	elif v < 410:
		d[W.I_SERVICES] -= 3
		d[W.I_PARTY_SUPPORT] -= 5
		d[W.I_LIVING] -= 2
	elif v < 610:
		d[W.I_SERVICES] -= 15
		d[W.I_PARTY_SUPPORT] -= 1
	elif v < 710:
		d[W.I_SERVICES] -= 22
	elif v < 810:
		d[W.I_SERVICES] -= 28
	else:
		d[W.I_SERVICES] -= 40
		d[W.I_LIVING] += 5
	if d[W.I_ECON_SYSTEM] < 13:
		if d[W.I_AGRICULTURE] < 300:
			d[W.I_SERVICES] -= 5
		elif d[W.I_AGRICULTURE] < 500:
			d[W.I_SERVICES] -= 2
	d[W.I_BUDGET] += d[W.I_SERVICES] / 50


# ── 军事学说周期效果（TimeScript 3806-3862行） ──

func _fortnight_military_doctrine(d: Array[int], _w: WorldState) -> void:
	var pop_excess := d[W.I_POPULATION] - 9307
	match d[W.I_MIL_DOCTRINE]:
		30:
			if pop_excess > 99:
				d[W.I_BUDGET] -= pop_excess / 100
				d[W.I_ARMY] += pop_excess / 100
			if d[W.I_POLITICAL_DISPLAY] > 38:
				d[W.I_POLITICAL_OPENNESS] -= 10
		31:
			if pop_excess > 199:
				d[W.I_BUDGET] -= pop_excess / 200
				d[W.I_ARMY] += pop_excess / 200
		32:
			if pop_excess > 299:
				d[W.I_BUDGET] -= pop_excess / 300
				d[W.I_ARMY] += pop_excess / 300
		33:
			if pop_excess > 149:
				if d[W.I_LIVING] < 500:
					d[W.I_BUDGET] -= pop_excess / 150
					d[W.I_ARMY] += pop_excess / 250
				elif d[W.I_LIVING] < 700:
					d[W.I_BUDGET] -= pop_excess / 150
					d[W.I_ARMY] += pop_excess / 300
				else:
					d[W.I_BUDGET] -= pop_excess / 500
					d[W.I_ARMY] += pop_excess / 500
			if d[W.I_POLITICAL_DISPLAY] < 40:
				d[W.I_POLITICAL_OPENNESS] += 10
			if d[W.I_ECON_DISPLAY] < 36:
				d[W.I_ECON_OPENNESS] += 10


# ── 贸易计算（TimeScript 854-911 + 3247-3272行） ──

func _fortnight_trade_balance(d: Array[int], w: WorldState) -> void:
	d[W.I_TRADE_PARTNERS] = 0
	var trade_income := d[W.I_INCOME]
	var pc := w.get_player_country()
	if pc == null:
		return
	for c in w.countries:
		if c == pc or c.gwcode <= 0:
			continue
		var added := false
		if c.has_tag("对华贸易"):
			d[W.I_TRADE_PARTNERS] += 1
			trade_income += 2
			added = true
		if not added and c.has_tag("econ") and pc.has_tag("econ"):
			d[W.I_TRADE_PARTNERS] += 1
			if c.government > 0:
				trade_income += 2 + maxi(0, 3 - c.government)
			else:
				trade_income += 3
	if _mod_active(w, 12):
		trade_income -= trade_income / 6
	var surplus := trade_income - d[W.I_IMPORT_NEEDS]
	if surplus > 0:
		d[W.I_BUDGET] += surplus / 2
		d[W.I_PEOPLE_SUPPORT] += surplus / 3
	elif surplus < 0:
		d[W.I_BUDGET] += surplus / 2
		d[W.I_PEOPLE_SUPPORT] += surplus / 3
		d[W.I_LIVING] += surplus / 4
	if d[W.I_TRADE_PARTNERS] <= 4:
		d[W.I_THOUGHT_FREEDOM] -= -5 + d[W.I_TRADE_PARTNERS]
		d[W.I_AGENTS] -= -5 + d[W.I_TRADE_PARTNERS]
	elif d[W.I_TRADE_PARTNERS] > 12:
		d[W.I_THOUGHT_FREEDOM] += d[W.I_TRADE_PARTNERS] - 12
		d[W.I_AGENTS] -= d[W.I_TRADE_PARTNERS] - 12


# ── 满意度/异见漂移（TimeScript 3273-3292行） ──

func _fortnight_satisfaction_drift(d: Array[int], w: WorldState) -> void:
	var ws := d[W.I_WAR_SUPPORT]
	if ws > 700:
		d[W.I_LIVING] -= (ws - 500) / 100
		d[W.I_PARTY_SUPPORT] += (ws - 500) / 100
		d[W.I_AGENTS] += (ws - 500) / 100
		if d[W.I_DIPLO] < 500:
			d[W.I_DIPLO] += 5
	elif ws < 400:
		d[W.I_THOUGHT_FREEDOM] += (500 - ws) / 100
		d[W.I_PARTY_SUPPORT] += (500 - ws) / 100
		d[W.I_AGENTS] += (500 - ws) / 100
		if w.empires.size() > 0:
			w.empires[0].relations += (500 - ws) / 100
		if w.empires.size() > 1:
			w.empires[1].relations += (500 - ws) / 100


# ── 政治满意度漂移（TimeScript 3665-3730行） ──

func _fortnight_political_drift(d: Array[int], _w: WorldState) -> void:
	var pd := d[W.I_POLITICAL_DISPLAY]
	match d[W.I_PARTY_SYSTEM]:
		6:
			if pd > 38: d[W.I_POLITICAL_OPENNESS] -= 10
		7:
			if pd > 39: d[W.I_POLITICAL_OPENNESS] -= 20
			elif pd < 39: d[W.I_POLITICAL_OPENNESS] += 20
		8:
			if pd > 40: d[W.I_POLITICAL_OPENNESS] -= 20
			elif pd < 40: d[W.I_POLITICAL_OPENNESS] += 20
		9:
			if pd < 41: d[W.I_POLITICAL_OPENNESS] += 30
	match d[W.I_PRESS_POLICY]:
		16:
			if pd > 38: d[W.I_POLITICAL_OPENNESS] -= 10
		17:
			if pd > 39: d[W.I_POLITICAL_OPENNESS] -= 20
			elif pd < 39: d[W.I_POLITICAL_OPENNESS] += 20
		18:
			if pd > 40: d[W.I_POLITICAL_OPENNESS] -= 20
			elif pd < 40: d[W.I_POLITICAL_OPENNESS] += 20
		19:
			if pd < 41: d[W.I_POLITICAL_OPENNESS] += 30
	# ── 领土制度效果（TimeScript 3756-3805行） ──
	match d[W.I_TERRITORY]:
		20:
			d[W.I_BUDGET] -= 1
			d[W.I_PEOPLE_SUPPORT] -= 2
			d[W.I_THOUGHT_FREEDOM] -= 4
			d[W.I_MANPOWER] += 1
			if pd > 39:
				d[W.I_POLITICAL_OPENNESS] -= 10
		21:
			d[W.I_PARTY_SUPPORT] -= 2
			d[W.I_THOUGHT_FREEDOM] -= 1
			if pd < 40:
				d[W.I_POLITICAL_OPENNESS] += 20
		22:
			d[W.I_PARTY_SUPPORT] -= 3
			d[W.I_PEOPLE_SUPPORT] -= 1
			d[W.I_THOUGHT_FREEDOM] += 2
			d[W.I_MANPOWER] -= 2
			if pd > 40:
				d[W.I_POLITICAL_OPENNESS] -= 20
			elif pd < 40:
				d[W.I_POLITICAL_OPENNESS] += 20
		23:
			d[W.I_MANPOWER] -= 4
			d[W.I_THOUGHT_FREEDOM] += 5
			d[W.I_PEOPLE_SUPPORT] -= 2
			d[W.I_PARTY_SUPPORT] -= 5
			if pd < 41:
				d[W.I_POLITICAL_OPENNESS] += 30



# ── 难度修正（TimeScript 5589-5706行） ──

func _fortnight_difficulty_bonus(d: Array[int], w: WorldState) -> void:
	match w.difficulty:
		0:
			d[W.I_PARTY_SUPPORT] += 5
			d[W.I_PEOPLE_SUPPORT] += 5
			d[W.I_THOUGHT_FREEDOM] -= 5
			d[W.I_LIVING] += 5
			d[W.I_BUDGET] += 50
			d[W.I_AGENTS] += 50
			if d[W.I_CORRUPTION] > 200:
				d[W.I_CORRUPTION] -= 30
			elif d[W.I_CORRUPTION] > 100:
				d[W.I_CORRUPTION] -= 20
			else:
				d[W.I_CORRUPTION] -= 10
		1:
			d[W.I_PARTY_SUPPORT] += 3
			d[W.I_PEOPLE_SUPPORT] += 3
			d[W.I_THOUGHT_FREEDOM] -= 3
			d[W.I_LIVING] += 3
			d[W.I_BUDGET] += 3
			d[W.I_AGENTS] += 3
		2:
			if d[W.I_CORRUPTION] < 50:
				d[W.I_CORRUPTION] += 8
			elif d[W.I_CORRUPTION] < 100:
				d[W.I_CORRUPTION] += 5
		3:
			d[W.I_PARTY_SUPPORT] -= 6
			d[W.I_PEOPLE_SUPPORT] -= 7
			d[W.I_THOUGHT_FREEDOM] += 7
			d[W.I_LIVING] -= 7
			d[W.I_BUDGET] -= 7
			d[W.I_AGENTS] -= 7
			if d[W.I_CORRUPTION] < 50:
				d[W.I_CORRUPTION] += 10
			elif d[W.I_CORRUPTION] < 100:
				d[W.I_CORRUPTION] += 6
			else:
				d[W.I_CORRUPTION] += 1
		4:
			d[W.I_PARTY_SUPPORT] -= d[W.I_IDEOLOGY] * 3
			d[W.I_PEOPLE_SUPPORT] -= d[W.I_IDEOLOGY] * 3
			if w.empires.size() > 0:
				w.empires[0].relations -= 5
			if w.empires.size() > 1:
				w.empires[1].relations -= 5
			if d[W.I_STABILITY] == 100:
				for p in w.politicians:
					if p == null:
						continue
					if p.trait_personality == 0:
						p.power += 50
					else:
						p.loyalty -= 10


# ── 政变条件（TimeScript PlotPlayer 389-403行） ──

func _check_coup(d: Array[int], w: WorldState) -> void:
	if d[W.I_STABILITY] < 100:
		return
	var disloyal_power := 0
	for p in w.politicians:
		if p == null:
			continue
		# 原版 traits[2] → trait_special；含 you_fall（POL-07）
		var special: int = p.trait_special
		var dominated := false
		if p.loyalty < 300 and special == 16:
			dominated = true
		elif p.you_fall:
			dominated = true
		elif p.loyalty < 150 and special != 9:
			dominated = true
		elif p.loyalty < 50:
			dominated = true
		if dominated and special != 17 and special != 19 and not p.is_under_investigation:
			disloyal_power += p.power
	if disloyal_power / 5 > d[W.I_PARTY_SUPPORT]:
		_trigger_ending(2)
	if d[W.I_PARTY_SUPPORT] <= 300 + d[W.I_THOUGHT_FREEDOM] / 5 - (d[W.I_PEOPLE_SUPPORT] - 500) / 5:
		_trigger_ending(2)


func _check_endings(d: Array[int], _w: WorldState, year: int) -> void:
	if d[W.I_POPULATION] < 6671:
		_trigger_ending(4)
		return
	if year >= 1993:
		if d[W.I_INFLUENCE] >= 800:
			_trigger_ending(5)
		elif d[W.I_ECON_SYSTEM] >= 13 and d[W.I_LIVING] >= 600:
			_trigger_ending(6)
		elif d[W.I_IDEOLOGY] == 0 and d[W.I_INFLUENCE] >= 500:
			_trigger_ending(7)
		else:
			_trigger_ending(0)
		return
	if d[W.I_BUDGET] < -500 and d[W.I_RESERVE] <= 0 and d[W.I_LOAN] > 0:
		_trigger_ending(3)
		return
	if d[W.I_PARTY_SUPPORT] <= 50 and d[W.I_THOUGHT_FREEDOM] >= 800:
		_trigger_ending(1)


func _trigger_ending(ending_id: int) -> void:
	if current_ending_id >= 0:
		return
	current_ending_id = ending_id
	pause()
	get_tree().change_scene_to_file("uid://b1dm8nycmn3gw")
# ============================================================================
# 代理战争 — WarCatalog + WarActionCatalog
# ============================================================================

func _monthly_war_points() -> void:
	var w := world
	if w == null:
		return
	var d := w.数值表
	@warning_ignore("integer_division")
	d[W.I_MIL_INTERVENTION] += d[W.I_PROJECTION] / 50
	var any_war := false
	for war in w.wars:
		if war != null and war.is_going:
			any_war = true
			break
	if any_war:
		@warning_ignore("integer_division")
		d[W.I_MIL_INTERVENTION] += d[W.I_INFLUENCE] / 12


func _clamp_war_infl(war: WarData) -> void:
	if war.infl1 > 1000 or war.infl2 < 0:
		war.infl1 = 1000
		war.infl2 = 0
	elif war.infl2 > 1000 or war.infl1 < 0:
		war.infl2 = 1000
		war.infl1 = 0
	war.infl1 = clampi(war.infl1, 0, 1000)
	war.infl2 = clampi(war.infl2, 0, 1000)


func _fortnight_wars(w: WorldState) -> void:
	if w == null:
		return
	for i in w.wars.size():
		var war: WarData = w.wars[i]
		if war == null or not war.is_going:
			continue
		var def := WarCatalog.get_def(i)
		if def:
			war.infl1 += def.drift_infl1
			war.infl2 += def.drift_infl2
			_apply_war_drift_extra(w, war, def)
		war.fortnight_elapsed += 1
		_clamp_war_infl(war)


func _apply_war_drift_extra(w: WorldState, war: WarData, def: WarDef) -> void:
	var flag := def.drift_extra_flag
	if flag.is_empty():
		return
	match flag:
		"korea_prop_prc":
			war.infl1 += def.drift_extra_infl1
			war.infl2 += def.drift_extra_infl2
		"iran_iraq":
			pass
		"afghanistan":
			if war.ussr_side == 1:
				war.infl1 -= 50
				war.infl2 += 50
			if w.数值表.size() > W.I_AFGHAN_POLICY:
				var pol: int = w.数值表[W.I_AFGHAN_POLICY]
				if pol == 1:
					war.infl1 += 4
					war.infl2 -= 4
				elif pol == 3:
					war.infl1 += 6
					war.infl2 -= 6
				elif pol == 2:
					war.infl1 -= 2
					war.infl2 += 2
		_:
			pass


func _check_war_endings() -> void:
	var w := world
	if w == null:
		return
	if w.数值表.size() <= W.I_WAR_RESOLVE:
		return
	if w.数值表[W.I_WAR_RESOLVE] >= 0:
		return
	for i in w.wars.size():
		var war: WarData = w.wars[i]
		if war == null or not war.is_going:
			continue
		var by_time := war.fortnight_max >= 0 and war.fortnight_elapsed >= war.fortnight_max
		var by_infl := war.infl1 >= 1000 or war.infl2 >= 1000
		if by_time or by_infl:
			w.数值表[W.I_WAR_RESOLVE] = i
			if EventEngine:
				EventEngine.queue_pending("war_is_over")
			_notify_stats()
			return


func get_active_wars() -> Array[WarData]:
	var out: Array[WarData] = []
	if world == null:
		return out
	for war in world.wars:
		if war != null and war.is_going:
			out.append(war)
	return out


func get_mil_intervention_display() -> String:
	if world == null:
		return "0.0"
	return "%.1f" % (float(world.数值表[W.I_MIL_INTERVENTION]) / 10.0)


func start_war(
	war_id: int,
	side1: String = "",
	side2: String = "",
	infl1: int = -1,
	infl2: int = -1,
	usa_side: int = -1,
	ussr_side: int = -1
) -> bool:
	if world == null or war_id < 0:
		return false
	while world.wars.size() <= war_id:
		world.wars.append(WarData.new())
	var war: WarData = world.wars[war_id]
	if war == null:
		war = WarData.new()
		world.wars[war_id] = war
	var def := WarCatalog.get_def(war_id)
	war.is_going = true
	if def:
		war.name_war = def.name_zh
		war.side1 = side1 if side1 != "" else def.default_side1
		war.side2 = side2 if side2 != "" else def.default_side2
		war.infl1 = infl1 if infl1 >= 0 else def.default_infl1
		war.infl2 = infl2 if infl2 >= 0 else def.default_infl2
		war.usa_side = usa_side if usa_side >= 0 else def.default_usa_side
		war.ussr_side = ussr_side if ussr_side >= 0 else def.default_ussr_side
		war.fortnight_max = def.fortnight_max
	else:
		war.name_war = "战争 #%d" % war_id
		war.side1 = side1 if side1 != "" else "side1"
		war.side2 = side2 if side2 != "" else "side2"
		war.infl1 = infl1 if infl1 >= 0 else 500
		war.infl2 = infl2 if infl2 >= 0 else 500
		war.usa_side = usa_side if usa_side >= 0 else 0
		war.ussr_side = ussr_side if ussr_side >= 0 else 0
	war.fortnight_elapsed = 0
	war.diplo_done = [false, false]
	_clamp_war_infl(war)
	_notify_stats()
	return true


func debug_start_war(war_id: int) -> bool:
	return start_war(war_id)


func can_intervene(war_id: int, action_id: int) -> bool:
	if world == null:
		return false
	if war_id < 0 or war_id >= world.wars.size():
		return false
	var war: WarData = world.wars[war_id]
	if war == null or not war.is_going:
		return false
	var act := WarActionCatalog.get_action(action_id)
	if act.is_empty():
		return false
	var d := world.数值表
	var side: int = int(act["side"])
	if side == 1:
		if war.infl1 >= 1000 or war.infl2 <= 0:
			return false
	else:
		if war.infl2 >= 1000 or war.infl1 <= 0:
			return false
	if bool(act["diplo"]):
		return not (war.diplo_done[0] or war.diplo_done[1])
	if d[W.I_MIL_INTERVENTION] < int(act["interv"]):
		return false
	if d[W.I_BUDGET] < int(act["budget"]):
		return false
	if d[W.I_AGENTS] < int(act["agents"]):
		return false
	if d[W.I_ARMY] < int(act["army"]):
		return false
	return true


func intervene_war(war_id: int, action_id: int) -> bool:
	if not can_intervene(war_id, action_id):
		return false
	var war: WarData = world.wars[war_id]
	var act := WarActionCatalog.get_action(action_id)
	var d := world.数值表
	var side: int = int(act["side"])
	d[W.I_BUDGET] -= int(act["budget"])
	d[W.I_AGENTS] -= int(act["agents"])
	d[W.I_ARMY] -= int(act["army"])
	if not bool(act["diplo"]):
		d[W.I_MIL_INTERVENTION] -= int(act["interv"])
	if side == 1:
		war.infl1 += int(act["d_self"])
		war.infl2 += int(act["d_other"])
	else:
		war.infl2 += int(act["d_self"])
		war.infl1 += int(act["d_other"])
	if bool(act["diplo"]):
		var di: int = int(act["diplo_i"])
		if di >= 0 and di < war.diplo_done.size():
			war.diplo_done[di] = true
		var rf: int = int(act["rel_friend"])
		if rf != 0:
			if war.usa_side == side - 1 and world.empires.size() > 0:
				world.empires[0].relations += rf
			if war.ussr_side == side - 1 and world.empires.size() > 1:
				world.empires[1].relations += rf
	else:
		var re: int = int(act["rel_enemy"])
		if re != 0:
			var enemy_place := 1 if side == 1 else 0
			if war.usa_side == enemy_place and world.empires.size() > 0:
				world.empires[0].relations += re
			if war.ussr_side == enemy_place and world.empires.size() > 1:
				world.empires[1].relations += re
	_clamp_war_infl(war)
	_mirror_empires_to_data(world)
	_notify_stats()
	return true


func resolve_war_finished(war_id: int = -1) -> void:
	if world == null:
		return
	var id := war_id
	if id < 0:
		id = world.数值表[W.I_WAR_RESOLVE]
	if id >= 0 and id < world.wars.size() and world.wars[id] != null:
		_apply_war_result(id)
		world.wars[id].is_going = false
	world.数值表[W.I_WAR_RESOLVE] = -1
	_notify_stats()


# ============================================================================
# 修正双周效果 — 对齐 ModifiesInfuence.ModifiesChanges（MVP 子集）
# 内部数值为原版 ×10 量级（如 -5 工业 = -0.5 显示）
# ============================================================================

func _fortnight_modifiers(d: Array[int], w: WorldState) -> void:
	if w == null:
		return
	# 0 工业技术依赖：工业 -5；科技 10 解除
	if _mod_active(w, 0):
		if w.techs and w.techs.unlocked.size() > 10 and w.techs.unlocked[10]:
			w.modifiers[0].is_active = false
		else:
			d[W.I_INDUSTRY] -= 5
	# 1 工业产能上限：科技 11 解除（上限在 clamp）
	if _mod_active(w, 1) and w.techs and w.techs.unlocked.size() > 11 and w.techs.unlocked[11]:
		w.modifiers[1].is_active = false
	# 3 后毛时代效应
	if _mod_active(w, 3):
		d[W.I_BUDGET] += 6
		d[W.I_AGENTS] += 2
		d[W.I_ARMY] += 5
		if d.size() > W.I_STABILITY and d[W.I_STABILITY] >= 100:
			d[W.I_PEOPLE_SUPPORT] += 5
			d[W.I_THOUGHT_FREEDOM] += 10
			d[W.I_LIVING] -= 5
			if w.empires.size() > 0:
				w.empires[0].relations -= 5
		# 深度改革则解除并冲击
		if d[W.I_IDEOLOGY] >= 4 or d[W.I_ECON_SYSTEM] >= 14 or d[W.I_PRESS_POLICY] > 18:
			w.modifiers[3].is_active = false
			d[W.I_THOUGHT_FREEDOM] += 200
			d[W.I_PEOPLE_SUPPORT] += 100
			d[W.I_PARTY_SUPPORT] -= 250
			d[W.I_DIPLO] -= 10
	# 5 市场改革冲击
	if _mod_active(w, 5):
		d[W.I_PEOPLE_SUPPORT] -= 2
		d[W.I_THOUGHT_FREEDOM] += 10
		d[W.I_BUDGET] += 2
	# 6 意识形态动员
	if _mod_active(w, 6):
		d[W.I_PARTY_SUPPORT] += 5
		d[W.I_THOUGHT_FREEDOM] -= 2
		d[W.I_MANPOWER] += 1
		d[W.I_DIPLO] += 2
		if w.empires.size() > 0:
			w.empires[0].relations -= 2
		if w.empires.size() > 1:
			w.empires[1].relations -= 4
	# 12 政治危机：伤收入（简化为预算）
	if _mod_active(w, 12):
		d[W.I_BUDGET] -= 10
		d[W.I_AGENTS] -= 10
	# 15 农业产能上限：科技解除若有农业关键科技则关（无则仅 clamp）
	# 15 农业上限：仅 cap，解除靠科技/事件（MVP 不自动关）
	_apply_modifier_caps(d, w)
	_mirror_empires_to_data(world)


func _apply_modifier_caps(d: Array[int], w: WorldState) -> void:
	# 工业上限：mod1 激活 → 500，否则 1000
	var ind_cap := 500 if _mod_active(w, 1) else 1000
	if d[W.I_INDUSTRY] > ind_cap:
		d[W.I_INDUSTRY] = ind_cap
	# 农业上限：mod15 激活 → 700，否则 1000
	var agri_cap := 700 if _mod_active(w, 15) else 1000
	if d[W.I_AGRICULTURE] > agri_cap:
		d[W.I_AGRICULTURE] = agri_cap
	if d[W.I_SERVICES] > 1000:
		d[W.I_SERVICES] = 1000


# ============================================================================
# 战争结束结算 — WarResult 简化（MVP：影响力/关系/预算，无完整地图吞并）
# ============================================================================

func _apply_war_result(war_id: int) -> void:
	if world == null or war_id < 0 or war_id >= world.wars.size():
		return
	var war: WarData = world.wars[war_id]
	if war == null:
		return
	var d := world.数值表
	var side1_win := war.infl1 >= war.infl2
	# 通用：胜方给一点介入点恢复
	d[W.I_MIL_INTERVENTION] += 5
	match war_id:
		0:  # 朝鲜
			if war.infl1 >= 900:
				d[W.I_INFLUENCE] += 50
				if world.empires.size() > 0:
					world.empires[0].power = maxi(0, world.empires[0].power - 40)
			elif war.infl2 >= 900:
				d[W.I_INFLUENCE] -= 20
				if world.empires.size() > 0:
					world.empires[0].power += 50
				if world.empires.size() > 1:
					world.empires[1].power = maxi(0, world.empires[1].power - 20)
		1:  # 柬越
			if war.infl1 >= 900:
				d[W.I_INFLUENCE] += 20
				d[W.I_PARTY_SUPPORT] += 100
				if world.empires.size() > 1:
					world.empires[1].power = maxi(0, world.empires[1].power - 20)
			elif war.infl2 >= 900:
				d[W.I_INFLUENCE] -= 30
				if world.empires.size() > 1:
					world.empires[1].power += 10
		2:  # 泰国
			if war.infl1 >= 750:
				d[W.I_INFLUENCE] += 20
				if world.empires.size() > 0:
					world.empires[0].power = maxi(0, world.empires[0].power - 20)
			else:
				d[W.I_INFLUENCE] -= 10
		3:  # 两伊
			if side1_win:
				if world.empires.size() > 1:
					world.empires[1].power += 10
			else:
				if world.empires.size() > 0:
					world.empires[0].power += 10
		5:  # 阿富汗
			if war.infl1 >= 900:  # 圣战者
				d[W.I_INFLUENCE] += 15
				if world.empires.size() > 1:
					world.empires[1].power = maxi(0, world.empires[1].power - 30)
			elif war.infl2 >= 900:
				d[W.I_INFLUENCE] -= 10
				if world.empires.size() > 1:
					world.empires[1].power += 15
		6:  # 福克兰
			if war.infl1 >= 400:
				d[W.I_INFLUENCE] += 5
			else:
				if world.empires.size() > 0:
					world.empires[0].power += 10
		_:
			if side1_win:
				d[W.I_INFLUENCE] += 10
			else:
				d[W.I_INFLUENCE] -= 5
	_mirror_empires_to_data(world)
