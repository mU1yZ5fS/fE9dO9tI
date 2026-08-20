extends Node

## 游戏全局管理器 Autoload。唯一的数据写入者。

signal date_changed(date: GameDate)
signal country_selected(slot: int, gwcode: int)
signal world_state_loaded()
signal event_started(event_id: String)
@warning_ignore("unused_signal")
signal tech_completed(tech_id: int)
## 数值表/帝国关系变更后发出，跨场景状态栏可在暂停时也能刷新
signal stats_changed()

const W = preload("res://数据脚本/world_state.gd")
const WF = preload("res://数据脚本/factory/world_factory.gd")
const WAR_SYS = preload("res://数据脚本/systems/war_system.gd")
const POL_SYS = preload("res://数据脚本/systems/politician_system.gd")
const POLICY_SERVICE_SCRIPT = preload("res://数据脚本/services/policy_service.gd")

var world: WorldState
var is_playing: bool = false
var speed: int = 0
var selected_country_gwcode: int = -1
var settings_return_scene: String = "uid://bydan4iqthbaa"
## 保存/加载界面返回目标（esc 进存档时设为外交等）
var save_return_scene: String = "uid://bydan4iqthbaa"

## 设置服务（从 GameManager 拆出）。_ready 中创建并加载。
var _settings: SettingsService = null

## 存档文件服务（从 GameManager 拆出）。_ready 中创建。
var _save_service: SaveService = null

## 经济规则服务（从 GameManager 拆出）。_ready 中创建。
var _economy_service: EconomyService = null

## 双周结算服务（从 GameManager 拆出）。_ready 中创建。
var _fortnight_service: FortnightSimulator = null

## 政策/派系服务（从 GameManager 拆出）。_ready 中创建。
var _policy_service = null

# ── 设置代理属性（保持 UI 现有 GameManager.xxx 调用不变）──
## 音乐音量 0-100。原版 GlobalScript.cs:249 默认 5。
var voice: int:
	get:
		return _settings.voice if _settings != null else 5
	set(value):
		if _settings != null:
			_settings.voice = value
## 自动保存档位 0=不自动 1=每月 2=半年。原版 GlobalScript.autosavej 默认 0。
var autosave_mode: int:
	get:
		return _settings.autosave_mode if _settings != null else 0
	set(value):
		if _settings != null:
			_settings.autosave_mode = value
## 自动保存/快速保存目标槽（原版编号 1-5，5=成就位）。原版 GlobalScript.savePlace 默认 5。
var save_place: int:
	get:
		return _settings.save_place if _settings != null else 5
	set(value):
		if _settings != null:
			_settings.save_place = value
## 难度设置持久值。原版 GameState.diff 会被 PlayerPrefs our_diff_in 覆盖。
var difficulty_setting: int:
	get:
		return _settings.difficulty_setting if _settings != null else 2
	set(value):
		if _settings != null:
			_settings.difficulty_setting = value
## 当前绑定：action → 物理键码（Key）。空字典时用默认值兜底。
var time_shortcut_keys: Dictionary:
	get:
		return _settings.time_shortcut_keys if _settings != null else {}
	set(value):
		if _settings != null:
			_settings.time_shortcut_keys = value

## 外交（主游戏）场景是否处于激活状态。
## 只有外交场景激活时，时间才会流动 —— 与原版 Unity 行为一致
## （原版 TimeScript 只在主地图场景的 Update() 中运行，切到子界面场景时自然暂停）。
var is_diplomacy_active: bool = false

# 事件状态
var current_event_id: String = ""
var event_is_timeout: bool = false

var current_ending_id: int = -1
var _pending_event_ending_id: int = -1

# 速度 → tick 间隔（秒），对齐原版 TimeScript.Update / Diplomacy.unity Speed 按钮：
#   now_time += speed*delta，now_time>=8 时推进 1 天 → 1 天 = 8/speed 秒。
#   原版 speed：默认 4（2 秒/天），Speed(0)=16（0.5 秒/天），Speed(1)=24（1/3 秒/天），Speed(2)=32（0.25 秒/天）。
#   Godot 档位 1-4 依次映射 4/16/24/32；最高档 0.25 秒/天，事件通知 13 天缓冲 ≈ 3.25 秒真实时间。
const TICK_INTERVALS: Array[float] = [0.0, 2.0, 0.5, 1.0 / 3.0, 0.25]
var _tick_timer: float = 0.0

var _tech_effects: Dictionary = {}

# 地图服务（从 GameManager 拆出）
signal map_data_preloaded

var _map_service: MapService = null

## 地图代理属性：保持 UI / WarSystem 现有 GameManager.xxx 调用不变。
var is_map_data_preloaded: bool:
	get:
		return _map_service.is_map_data_preloaded if _map_service != null else false

var cached_map_meta: Dictionary:
	get:
		return _map_service.cached_map_meta if _map_service != null else {}
var cached_map_regions: Dictionary:
	get:
		return _map_service.cached_map_regions if _map_service != null else {}
var cached_map_countries: Dictionary:
	get:
		return _map_service.cached_map_countries if _map_service != null else {}
var cached_region_owner: Dictionary:
	get:
		return _map_service.cached_region_owner if _map_service != null else {}
var cached_initial_owner: Dictionary:
	get:
		return _map_service.cached_initial_owner if _map_service != null else {}

var cached_region_map_image: Image:
	get:
		return _map_service.cached_region_map_image if _map_service != null else null
var cached_owner_palette_image: Image:
	get:
		return _map_service.cached_owner_palette_image if _map_service != null else null
var cached_color_palette_image: Image:
	get:
		return _map_service.cached_color_palette_image if _map_service != null else null

var cached_region_map_tex: ImageTexture:
	get:
		return _map_service.cached_region_map_tex if _map_service != null else null
var cached_owner_palette_tex: ImageTexture:
	get:
		return _map_service.cached_owner_palette_tex if _map_service != null else null
var cached_color_palette_tex: ImageTexture:
	get:
		return _map_service.cached_color_palette_tex if _map_service != null else null

## 启动加载屏预热好的外交场景 PackedScene(点开始时 change_scene_to_packed 无缝进场)
var cached_diplomacy_scene: PackedScene = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_settings = SettingsService.new()
	_settings.load_config()
	_settings.setup_time_shortcuts()
	_save_service = SaveService.new()
	_economy_service = EconomyService.new()
	_fortnight_service = FortnightSimulator.new()
	_policy_service = POLICY_SERVICE_SCRIPT.new()
	_map_service = MapService.new()
	MapService.instance = _map_service
	_map_service.map_data_preloaded.connect(func() -> void: map_data_preloaded.emit())
	_map_service.map_changed.connect(notify_stats_changed)
	WarSystem._notify_stats_cb = _notify_stats
	WarSystem._start_event_cb = start_event
	WarSystem._trigger_ending_cb = trigger_ending
	WarSystem._is_event_in_progress_cb = func() -> bool: return current_event_id != ""
	PoliticianSystem._notify_stats_cb = _notify_stats
	PoliticianSystem._is_mao_dead_cb = is_mao_dead
	PoliticianSystem._is_mao_protected_cb = is_mao_protected
	DecisionSystem._notify_stats_cb = _notify_stats
	_load_tech_effects()
	_map_service.preload_region_map()
	if EventEngine:
		EventEngine.gm = self
		DecisionAtoms.event_engine = EventEngine
		EventEngine.event_triggered.connect(_on_event_triggered)
	DecisionAtoms._is_faction_leading_cb = is_faction_leading
	DecisionAtoms._kill_politician_cb = kill_politician
	DecisionAtoms._start_event_cb = start_event


func _preload_region_map() -> void:
	if _map_service != null:
		_map_service.preload_region_map()


func reset_map_runtime_state() -> void:
	if _map_service != null:
		_map_service.reset_runtime_state()


func transfer_map_owner(from_gwcode: int, to_gwcode: int) -> void:
	if _map_service != null:
		_map_service.transfer_owner(from_gwcode, to_gwcode)


func set_map_region_owner(region_ids: Array, to_gwcode: int) -> void:
	if _map_service != null:
		_map_service.set_region_owner(region_ids, to_gwcode)


func _migrate_legacy_map_owner_overrides() -> void:
	if _map_service != null:
		_map_service.migrate_legacy_map_owner_overrides()


func _migrate_legacy_global_flags() -> void:
	if world == null:
		return
	if world.global_flags.has("vietnam_peace"):
		var old_val := bool(world.global_flags.get("vietnam_peace", false))
		if old_val:
			world.set_flag("vietnampeace", true)
		world.global_flags.erase("vietnam_peace")


## 地图预加载完成时补执行之前排队的领土转移。


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
	while _tick_timer >= interval and is_playing:
		_tick_timer -= interval
		tick()
		# tick 内可能触发事件/结局并 pause()：立刻丢弃补帧积压，禁止继续追赶日历。
		if not is_playing or current_event_id != "":
			_tick_timer = 0.0
			break


# ── 设置持久化与快捷键（委托 SettingsService）──

func _load_settings_config() -> void:
	if _settings == null:
		_settings = SettingsService.new()
	_settings.load_config()


func _save_settings_config() -> void:
	if _settings != null:
		_settings.save_config()


func _setup_time_shortcuts() -> void:
	if _settings != null:
		_settings.setup_time_shortcuts()


func _apply_time_shortcuts() -> void:
	if _settings != null:
		_settings.apply_time_shortcuts()


func get_time_shortcut_key(action: String) -> int:
	return _settings.get_time_shortcut_key(action) if _settings != null else 0


## 键位显示名：按物理键位转当前布局标签（中文输入法/不同布局下仍显示当前键帽）。
func get_time_shortcut_label(action: String) -> String:
	return _settings.get_time_shortcut_label(action) if _settings != null else "未设置"


## 设置界面重绑入口：写入内存 + 立即改 InputMap + 持久化。
func rebind_time_shortcut(action: String, physical_keycode: int) -> void:
	if _settings != null:
		_settings.rebind_time_shortcut(action, physical_keycode)


func set_voice(value: int) -> void:
	if _settings != null:
		_settings.set_voice(value)


func set_autosave_mode(value: int) -> void:
	if _settings != null:
		_settings.set_autosave_mode(value)


func set_save_place(value: int) -> void:
	if _settings != null:
		_settings.set_save_place(value)


func set_difficulty(value: int) -> void:
	if _settings != null:
		_settings.set_difficulty(value, world)


## 原作 savePlace 编号 5=成就位；本端口存档槽 0=成就位、1-4=普通位。
func autosave_slot() -> int:
	return _settings.autosave_slot() if _settings != null else 0


## 原作 TimeScript.cs:6021-6030：autosavej==1 在 data[19]==1（每月 1 日），
## autosavej==2 在 data[19]==1 且 data[20]%6==0（1 日且 6/12 月）自动写当前 savePlace。
func _check_autosave() -> void:
	if world == null or autosave_mode <= 0 or world.date.day != 1:
		return
	if autosave_mode == 2 and world.date.month % 6 != 0:
		return
	# 原作 AutoSaveMethod → Savescript.OnMouseDown：number==5 写当前 iron_and_blood，其余槽 False。
	var iron_ov := 1 if (save_place == 5 and world.is_ironman) else 0
	save_to_slot(autosave_slot(), iron_ov)


# ── 公开 API ──

func new_game(player_gwcode: int = 710, p_difficulty: int = 2) -> void:
	world = WF.create_world(player_gwcode, p_difficulty)
	WarSystem.current_world = world
	PoliticianSystem.current_world = world
	PoliticianPool.current_world = world
	DecisionSystem.current_world = world
	ModifierCatalog.current_world = world
	DecisionAtoms.current_world = world
	if EventEngine:
		EventEngine.world = world
	if _map_service:
		_map_service.world = world
	_sync_date_to_data(world)
	reset_map_runtime_state()
	selected_country_gwcode = player_gwcode
	is_playing = false
	speed = 0
	_tick_timer = 0.0
	current_event_id = ""
	event_is_timeout = false
	current_ending_id = -1
	_pending_event_ending_id = -1
	world_state_loaded.emit()
	# 同步入队，避免 deferred 之前玩家点“演讲”等事件先占住 current_event_id，
	# 导致五“不准”（周总理事件）初始事件被跳过、顺序错乱。
	_start_initial_events()


func load_game(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("GameManager: 存档不存在 %s" % path)
		return
	# 不传 type_hint：.res 内嵌 class_name 时强制 WorldState 会误报 not found
	var loaded = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if loaded is WorldState:
		world = loaded as WorldState
		WarSystem.current_world = world
		PoliticianSystem.current_world = world
		PoliticianPool.current_world = world
		DecisionSystem.current_world = world
		ModifierCatalog.current_world = world
		DecisionAtoms.current_world = world
		if EventEngine:
			EventEngine.world = world
		if _map_service:
			_map_service.world = world
		# 旧档/异常档防御：数值表不足 200 槽会令 tick 内 d[I_*] 越界，读档即补全。
		if world.数值表.size() < 200:
			world.数值表.resize(200)
		# Godot 改版无 DLC 购买限制：读档也强制 0-3 号 DLC 全免费（dlc[4] 预留保持原值）。
		if world.dlc.size() < 4:
			world.dlc.resize(4)
		for i in 4:
			world.dlc[i] = true
		# 读档后游戏内难度权威来自存档（原作 LoadInScript 用二进制存档覆盖 gameState.diff）；
		# 同步到持久化难度，主菜单开新局时沿用。
		difficulty_setting = world.difficulty
		_sync_date_to_data(world)
		# 旧档科技数组可能只有 27 槽（TECH_COUNT 已扩到 34），迁移补齐
		if world.techs != null:
			world.techs.ensure_size()
		# 旧档兼容：地图归属持久化功能上线前触发的吉布提独立，补写覆盖，读档后不再变回法国。
		_migrate_legacy_map_owner_overrides()
		# 旧档兼容：修正早期 war_*.tres 中误配的战争超时（999=无超时，-1=仅影响力结束）。
		WAR_SYS.migrate_legacy_war_timeouts(world)
		# 旧档兼容：越南和平标志统一为原版字段名 vietnampeace。
		_migrate_legacy_global_flags()
		reset_map_runtime_state()
		# 运行时缓存不序列化，读档后重建
		world.rebuild_gwcode_index()
		world.sync_economy()
		world.ensure_rng()  # 从 rng_seed + rng_state 恢复随机流位置
		if EventEngine and EventEngine.has_method("import_runtime_from_world"):
			EventEngine.import_runtime_from_world(world)
		selected_country_gwcode = world.player_country_gwcode
		is_playing = false
		speed = 0
		_tick_timer = 0.0
		current_event_id = ""
		event_is_timeout = false
		current_ending_id = -1
		_pending_event_ending_id = -1
		world_state_loaded.emit()
		_notify_stats()
		# 旧档兜底：若五“不准”（周总理事件）尚未完成/入队，读档后立即补队，
		# 避免其在自动扫描中排到 popular_discontent 之后。
		_start_initial_events()
	else:
		push_error("GameManager: 加载失败 %s" % path)


func save_game(path: String) -> void:
	if _save_service != null:
		_save_service.save_game(world, path, EventEngine)


## 槽位保存：WorldState.res + meta.json 摘要。
## iron_override: -1=沿用 world.is_ironman；0/1=仅写 meta，不改运行时 world。
func save_to_slot(slot: int, iron_override: int = -1) -> bool:
	return _save_service.save_to_slot(slot, world, EventEngine, iron_override) if _save_service != null else false


func load_from_slot(slot: int) -> bool:
	var path := SaveCatalog.slot_path(slot)
	if not FileAccess.file_exists(path):
		push_error("GameManager: 槽位 %d 无存档" % slot)
		return false
	load_game(path)
	if world != null:
		# LoadInScript.cs:33：number != 5 时 iron_and_blood=false（原版 5=成就位；
		# 本端口槽位 0=成就位、1-4=普通位，见 保存.gd/加载.gd SLOT_NODES）
		if slot != 0:
			world.is_ironman = false
	return world != null


func delete_save_slot(slot: int) -> bool:
	return _save_service.delete_save_slot(slot) if _save_service != null else false


func tick() -> void:
	if world == null or current_event_id != "":
		return
	var old_month := world.date.month
	var old_year := world.date.year
	world.date.advance()
	_sync_date_to_data(world)

	_daily_deficit_recovery(world)

	# 原版 TimeScript.cs:640-653（Repaint 日块）：危地马拉/尼加拉瓜内战触发。
	_daily_latin_war_triggers(world)

	# 原版日块行序：年块(743) → 联盟日块(955) → 派系领袖补位(1051) →
	# 派系席位重算(1114) → 政治路线(1173) → 显示等级(1237) → 体制重算(1269) →
	# 阴谋判定(1453) → 科研点(1458) → 北欧联动(1648) → 月块(1680)。
	if world.date.year != old_year:
		_on_year_changed()
	_daily_rim_and_alliance_checks(world)
	fill_vacant_faction_leaders()
	_sync_faction_numbers_from_ideology(world.数值表, world)
	_update_political_line(world.数值表, world)
	_update_displays(world.数值表)
	_political_system_recalc(world.数值表, world)
	_plot_player_cause(world.数值表, world)
	_check_daily_conspiracy(world.数值表)
	_daily_science_gen(world)
	_daily_finland_linkage(world)
	if world.date.month != old_month:
		_on_month_changed()

	# 原版 data[19] % 7 == 0：已结盟派系 ideology 增长，并扣预算/特工。
	if world.date.day % 7 == 0:
		_weekly_ally_upkeep(world.数值表, world)

	_check_scheduled_events()

	if current_event_id == "" and world.date.day % 14 == 0:
		_on_fortnight()

	WAR_SYS.check_war_endings()

	if EventEngine:
		EventEngine.check_and_fire()

	# 原版 TimeScript.cs:11154-11166：无事件弹窗时按 DLC02→DLC03→DLC01 轮询 ReqEventForDLC02。
	if current_event_id == "":
		ReqEventTriggers.poll(world)

	_check_periodic_achievements(world)

	world.clamp_values()
	world.clamp_empire_relations()
	_mirror_empires_to_data(world)
	world.sync_economy()
	date_changed.emit(world.date)
	stats_changed.emit()
	# 原作自动存档在月块末尾（TimeScript.cs:6021-6030），所有月度效果结算后再写。
	_check_autosave()


## GameDate 是日期权威源；原版公式/事件仍通过 data[19..21] 读日期。
func _sync_date_to_data(w: WorldState) -> void:
	if w == null or w.date == null or w.数值表.size() <= W.I_YEAR:
		return
	w.数值表[W.I_DAY] = w.date.day
	w.数值表[W.I_MONTH] = w.date.month
	w.数值表[W.I_YEAR] = w.date.year


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
	if world == null or world.techs == null or world.techs.unlocked.size() < TechState.TECH_COUNT:
		return
	# 原版 TimeScript.cs:5626-5722：按 num132（刚刚完成的科技编号）走 if/else-if 链，
	# 只对“本次完成项”施加一次性效果。原移植按 unlocked 链判断会在后续科技完成时
	# 重复施加首个已解锁项的效果，本步一并修正。
	# 注1：原版 gameState.influencePRC 是独立累计字段（对应 world.influence_prc），
	#     不是数值表 data[7]（全球影响力）。
	# 注2：进口需求沿用本移植既有换算（原版 -15/-10 → 本端口 -3/-2）；
	#     该单位问题（原版显示 /5，本端口显示 /10）与本次航天科技无关，另立步修正。
	# 注3：原版 3/6/7 号还会往 old_modify_desc[15] 追加描述文案，
	#     本端口没有对应文案存储，暂不移植。
	var d := world.数值表
	if tech_id == 0:
		d[W.I_IMPORT_NEEDS] -= 3
	elif tech_id == 1:
		d[W.I_IMPORT_NEEDS] -= 2
	elif tech_id == 2:
		world.influence_prc += 10
	elif tech_id == 3:
		d[W.I_IMPORT_NEEDS] -= 3
	elif tech_id == 4:
		d[W.I_IMPORT_NEEDS] -= 2
	elif tech_id == 6:
		pass  # 原版仅追加 old_modify_desc 文案，数值表无变化
	elif tech_id == 7:
		d[W.I_IMPORT_NEEDS] -= 2
	elif tech_id == 10:
		d[W.I_IMPORT_NEEDS] -= 2
		world.influence_prc += 5
	elif tech_id == 12:
		d[W.I_IMPORT_NEEDS] -= 2
	elif tech_id == 13:
		d[W.I_IMPORT_NEEDS] -= 2
	elif tech_id == 14:
		d[W.I_IMPORT_NEEDS] -= 2
	elif tech_id == 23:
		world.influence_prc += 5
	elif tech_id == 28:
		d[W.I_IMPORT_NEEDS] -= 2
	elif tech_id == 30:
		world.influence_prc += 10
	elif tech_id == 31:
		world.influence_prc += 5
	elif tech_id == 32:
		world.influence_prc += 5
	elif tech_id == 33:
		world.influence_prc += 10


## 公开方法（科研界面也需要读取效果描述）
func get_tech_effects(tech_id: int) -> Array:
	return _tech_effects.get(tech_id, [])


## 顶栏「科研未研究」提示图标判定。
## 原版 TimeScript.cs:5605-5754：双周块 flag4=有科技正在研究；
## !flag4 时 alarmIcons[0].SetActive(true)；全部科技完成时隐藏（5743-5746）。
func science_alert_active() -> bool:
	if world == null or world.techs == null:
		return false
	return not world.techs.is_researching() and not world.techs.is_all_researched()


## 顶栏「政治局缺人」提示图标判定。
## 用户口径：中央三职（总理/军委/外交）与地方主管（京畿/华北/华西/华南/华东）
## 任一槽为 -1 空缺时显示。
func political_bureau_vacancy_alert_active() -> bool:
	const SLOT_COUNT := 8  # 与 WorldState._init 的 politics_positions.resize(8) 对齐
	if world == null:
		return false
	for i in mini(SLOT_COUNT, world.politics_positions.size()):
		if world.politics_positions[i] == -1:
			return true
	return false


# ── 事件 ──

func _on_event_triggered(event_id: String, is_timeout: bool) -> void:
	if world == null or EventEngine == null or current_event_id != "":
		return
	var event_def: EventDef = EventEngine.get_event(event_id)
	if event_def == null:
		push_error("GameManager: 事件 %s 未找到" % event_id)
		return
	current_event_id = event_id
	event_is_timeout = is_timeout
	# 显示前动态文案钩子（原版 Event18 战争结算等按 data[82] 动态生成标题/描述/按钮）
	if event_def.display_script != null:
		var display_inst: RefCounted = event_def.display_script.new()
		if display_inst != null and display_inst.has_method("prepare"):
			display_inst.prepare(event_def, world)
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


## 派系界面“选举”按钮（原版 ElectScript.OnMouseDown 手动选举，:35-43）
## 原版 is_elect 由月块重置 → 用 flag 在 _on_month_changed 里复位。
func manual_election() -> bool:
	if world == null or current_event_id != "":
		return false
	var d := world.数值表
	if d[W.I_PARTY_SYSTEM] <= 7:
		return false
	if world.get_flag("manual_election_used"):
		return false
	world.set_flag("manual_election_used", true)
	d[W.I_BUDGET] -= 10  # 原版 data[8] -= 10
	d[125] = 1           # 原版 data[125] = 1（Godot 未映射语义，保留槽位）
	_notify_stats()
	start_event("npc_elections")
	return true


## 派系界面“演讲”按钮（原版 speechscript.OnMouseDown，进入同一事件1；is_speech 永不复位）
func manual_speech() -> bool:
	if world == null or current_event_id != "":
		return false
	if world.get_flag("speech_done"):
		return false
	world.set_flag("speech_done", true)
	start_event("npc_elections")
	return true


## 派系界面同盟按钮可用性 — 原版 ElectScript.OnMouseDown is_alliance 分支（:10-25）：
## 经济同盟：event_done[59] 且中国未加入 sev/asean/econ/ovd；
## 军事同盟：event_done[60] 且中国已建经济同盟(econ)且未加入 okb。
func can_manual_alliance(is_military: bool) -> bool:
	if world == null:
		return false
	var china := world.get_country_by_legacy_index(1)
	if china == null:
		return false
	if is_military:
		return world.completed_event_ids.has("military_alliance") \
			and china.has_tag("econ") and not china.has_tag("okb")
	return world.completed_event_ids.has("economic_union") \
		and not china.has_tag("sev") and not china.has_tag("asean") \
		and not china.has_tag("econ") and not china.has_tag("ovd")


func clear_event() -> void:
	# 战争结束事件关闭后结算槽位
	if current_event_id == "war_is_over":
		resolve_war_finished()
	current_event_id = ""
	event_is_timeout = false
	if _pending_event_ending_id >= 0:
		var ending_id := _pending_event_ending_id
		_pending_event_ending_id = -1
		_trigger_ending(ending_id)
	# 兜底：任何早期事件（如开局误触演讲）结束后，若五“不准”尚未完成/入队，立即补队。
	_start_initial_events()


## 事件结果页确认后再进入结局，复现原版 Results_text 的 load_scene_after_click。
func queue_ending_after_event(ending_id: int) -> void:
	_pending_event_ending_id = ending_id


## 非事件上下文（外交按钮等）的即时结局切换；原版 SceneManager.LoadScene("Ending") 语义。
func trigger_ending(ending_id: int) -> void:
	_trigger_ending(ending_id)


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
	return _economy_service.calc_budget_planka(world) if _economy_service != null else 0


## 调整预算类别。category_idx 为 71-81，delta 为增减量。
## 返回 false 表示余额不足或超过 planka 上限。
func adjust_budget(category_idx: int, delta: int) -> bool:
	return _economy_service.adjust_budget(world, category_idx, delta, _notify_stats) if _economy_service != null else false


## 调整贷款。delta > 0 借入，delta < 0 还款。借入扣减党支持。
func adjust_loan(delta: int) -> bool:
	return _economy_service.adjust_loan(world, delta, _notify_stats) if _economy_service != null else false


## 调整储备金。delta > 0 存入，delta < 0 取出。取出扣减党支持和民众支持。
func adjust_reserve(delta: int) -> bool:
	return _economy_service.adjust_reserve(world, delta, _notify_stats) if _economy_service != null else false


## 政策切换。category_idx 为数值表索引（15/16/17/18/50/51），target_val 为目标值。
## 需满足预算和党支持条件，切换后扣减预算、生活水平、党支持。
# ============================================================================
# 政策切换 3 条件（对齐原版 Doctrine_button_script.OnMouseDown 的 uslovie[0..2]）
#   [0] 预算    ≥ |diff|×50
#   [1] 党内支持 ≥ |diff|×300
#   [2] 派系/路线领导：一党制(data[15]≤7)看政治路线 data[56]；多党看 data[52]/data[54]+联盟席位>66%
# 注：原版 OnMouseDown 无毛存活门槛，开局即可切（已移除此前的 mao_ok 条件）。
# ============================================================================



## 政策切换 4 条件检查（唯一权威）。UI 与实际切换共用，返回各条件明细。
func check_policy_change(category_idx: int, target_val: int) -> Dictionary:
	if _policy_service == null:
		return {}
	_policy_service.bind(self, world)
	return _policy_service.check_policy_change(category_idx, target_val)

func change_policy(category_idx: int, target_val: int) -> bool:
	if _policy_service == null:
		return false
	_policy_service.bind(self, world)
	return _policy_service.change_policy(category_idx, target_val)

func set_birth_policy(policy: int) -> void:
	if _policy_service == null:
		return
	_policy_service.bind(self, world)
	_policy_service.set_birth_policy(policy)

func set_faction_ally(faction_idx: int, want_ally: bool) -> void:
	if _policy_service == null:
		return
	_policy_service.bind(self, world)
	_policy_service.set_faction_ally(faction_idx, want_ally)

func can_ban_faction(faction_idx: int) -> bool:
	if _policy_service == null:
		return false
	_policy_service.bind(self, world)
	return _policy_service.can_ban_faction(faction_idx)

func can_unban_faction(faction_idx: int) -> bool:
	if _policy_service == null:
		return false
	_policy_service.bind(self, world)
	return _policy_service.can_unban_faction(faction_idx)

func set_faction_enabled(faction_idx: int, want_enabled: bool) -> void:
	if _policy_service == null:
		return
	_policy_service.bind(self, world)
	_policy_service.set_faction_enabled(faction_idx, want_enabled)

func is_faction_leading(faction_index: int) -> bool:
	if _policy_service == null:
		return false
	_policy_service.bind(self, world)
	return _policy_service.is_faction_leading(faction_index)

func is_mao_dead() -> bool:
	if _policy_service == null:
		return false
	_policy_service.bind(self, world)
	return _policy_service.is_mao_dead()

func is_mao_protected(pol_index: int) -> bool:
	if _policy_service == null:
		return false
	_policy_service.bind(self, world)
	return _policy_service.is_mao_protected(pol_index)

func faction_power_sum(faction_idx: int) -> int:
	if _policy_service == null:
		return 0
	_policy_service.bind(self, world)
	return _policy_service.faction_power_sum(faction_idx)

## 写数值表后统一：同步显示视图 + 广播刷新
func _notify_stats() -> void:
	if world != null:
		world.sync_economy()
	stats_changed.emit()


## 供外交互动/事件效果在直接修改 WorldState 后广播刷新（地图渲染、国家面板等监听）。
func notify_stats_changed() -> void:
	_notify_stats()


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
	w.set_flag("manual_election_used", false)  # 原版月块 is_elect=false（TimeScript.cs:505-512）
	var d := w.数值表
	# 原版 54 号事件触发就是 TimeScript.cs:10425 的 ev45 && data[16]>11，无 6 个月延迟；
	# 早期误加的 investment_delay 等待已移除（trigger 在 event_054*.tres 里对齐）。
	# TimeScript.cs:1925：中国 level_of_unstab 月块重置（原版在 data[19]==1 月块内，非每日）。
	var china_unstab := w.get_country_by_legacy_index(1)
	if china_unstab != null:
		china_unstab.level_of_instability = 10
	# 原版 926-954 的各国 stab/cw 重置属于 1 月 1 日年块，已移至 _on_year_changed。
	# 916-954 年块维护在 _yearly_jan1_maintenance；955-1048 RIM 日块在 _daily_rim_and_alliance_checks；
	# 本函数保留季度/半年度条件与 1689+ 月维护。
	_monthly_rim_and_alliance_cleanup(w)
	# 原版月块（data[19]==1）行序：1682-2565 已由 _monthly_rim_and_alliance_cleanup 及其子函数执行；
	# 2555-2851 寡头、2852-2913 后期维护、2914-3024 政客循环、3025 非洲政变、
	# 3026-3037 事件清空与瑞士发展、3038-3135 人口增长。
	_monthly_oligarch(d, w)
	_monthly_late_maintenance(d, w)
	POL_SYS.monthly_politics(d, w)
	_monthly_african_coups(w)
	_monthly_post_coups(w)
	_monthly_population(d, w)
	WAR_SYS.monthly_war_points()
	w.flush_economy()


## TimeScript.cs:955-1048：革命国际/亲中联盟日块（Repaint 每日执行，非月块）。
## 含 1000-1015 全部国家 SubGosstroy 17/0 亲中退出与 AU 退出（此前遗漏）。
func _daily_rim_and_alliance_checks(w: WorldState) -> void:
	var d := w.数值表
	var china := w.get_country_by_legacy_index(1)

	# 957-983：RIM（革命国际）条件退出。
	var rim_exit := china != null and china.has_tag("rim") and (
		w.is_socialism(china, false)
		or not _mod_active(w, 3)
		or not _mod_active(w, 6)
		or d[W.I_PARTY_SYSTEM] > 7
		or d[W.I_ECON_SYSTEM] > 12
		or d[W.I_RELIGION] > 25
		or _country_tag(w, 51, "对华贸易")
		or _country_dev_is(w, 51, 1)
		or china.has_tag("seato")
		or ((china.has_tag("sev") or china.has_tag("ovd")) and not w.event_done_num(380))
	)
	if rim_exit:
		china.set_tag("rim", false)
		w.influence_prc -= 3000
		w.set_event_done_num(686, false)
		for c in w.countries:
			if c == null:
				continue
			if c.has_tag("rim") and c.puppet_of != 1:
				c.set_tag("亲中", false)
				c.set_tag("对华贸易", false)
				c.set_tag("econ", false)
				c.set_tag("okb", false)
			elif c.puppet_of == 1:
				c.set_tag("rim", false)

	# 984-1000：事件713后革命国际扩张/清理。
	if w.event_done_num(713):
		for c in w.countries:
			if c == null:
				continue
			if (c.sub_government == 17 or c.sub_government == 2) and c.原版序号 != 1 \
					and c.puppet_of != 1 and not c.has_tag("亲苏") and not c.has_tag("亲美") \
					and not c.has_tag("sev") and not c.has_tag("ovd") and not c.has_tag("rim"):
				c.set_tag("亲中", false)
				c.set_tag("对华贸易", false)
				c.set_tag("econ", false)
				c.set_tag("okb", false)
				c.set_tag("rim", true)
			elif c.原版序号 == 1 or c.puppet_of == 1:
				c.set_tag("rim", false)

	# 993-999：阿尔巴尼亚(20)亲中条件退出（cond_full 含 data[52]>36）。
	var cond_soft := d[W.I_IDEOLOGY] > 3 or d[W.I_PARTY_SYSTEM] > 7 \
		or d[W.I_ECON_SYSTEM] > 13 or d[W.I_RELIGION] > 28 \
		or (china != null and china.has_tag("seato"))
	var cond_full := cond_soft or d[W.I_ECON_DISPLAY] > 36
	var albania := w.get_country_by_legacy_index(20)
	if albania != null and d[W.I_ALBANIA_BREAK] == 0 and albania.has_tag("亲中") and cond_full:
		albania.set_tag("亲中", false)
		albania.set_tag("对华贸易", false)
		albania.set_tag("econ", false)
		albania.set_tag("okb", false)

	# 1000-1015：全部国家——sub==17 用 cond_soft、sub==0 用 cond_full 退亲中；
	# AU 国家在更宽条件下退出亲中/对华贸易/econ/okb 并扣影响力。
	# 注：原版 TimeScript.cs:1014 循环体内还有一句 num10++（与 for 头叠加，实际只处理偶数序号），
	# 判定为反编译噪音/原版笔误，本项目按“遍历全部国家”执行。
	var cond_au := cond_soft or _country_tag(w, 51, "对华贸易") \
		or _country_dev_is(w, 51, 1) or not _mod_active(w, 6)
	for c in w.countries:
		if c == null:
			continue
		if c.原版序号 != 1 and c.has_tag("亲中"):
			if c.sub_government == 17 and cond_soft:
				c.set_tag("亲中", false)
			elif c.sub_government == 0 and cond_full:
				c.set_tag("亲中", false)
		if c.has_tag("au") and w.event_done_num(500) and cond_au \
				and (c.has_tag("亲中") or c.has_tag("对华贸易") or c.has_tag("econ")):
			c.set_tag("亲中", false)
			c.set_tag("对华贸易", false)
			c.set_tag("econ", false)
			c.set_tag("okb", false)
			w.influence_prc -= 50

	# 1016-1019：菲律宾(24)亲中条件退出。
	var c24 := w.get_country_by_legacy_index(24)
	if c24 != null and c24.parts.size() > 0 and c24.parts[0] \
			and c24.government == 1 and c24.has_tag("亲中") and cond_full:
		c24.set_tag("亲中", false)

	# 1020-1023：阿尔巴尼亚 econ/okb 残留清理。
	if albania != null and d[W.I_ALBANIA_BREAK] == 0 and not albania.has_tag("亲中") \
			and (albania.has_tag("econ") or albania.has_tag("okb")):
		albania.set_tag("econ", false)
		albania.set_tag("okb", false)

	# 1025：ExportValue 每日重算（原版日块；完整 400 行版见 Phase 2，当前用核心版）。
	_recalc_export_value(d, w)

	# 1026-1029：多党制下 data[125]==4 的选举余波清空。
	if d[W.I_PARTY_SYSTEM] > 7 and d.size() > 125 and d[125] == 4:
		d[125] = 0

	# 1028-1039：菲律宾(47)影响力达标时转亲中并触发事件441。
	if d[37] >= 1000:
		var c47 := w.get_country_by_legacy_index(47)
		if c47 != null and not c47.has_tag("亲中") and not w.event_done_num(441):
			c47.set_tag("亲中", true)
			c47.government = 1
			c47.set_tag("asean", false)
			c47.sub_government = 17
			c47.set_tag("亲美", false)
			GameManager.start_event("event_441")

	# 1040：非洲亲中支援（AfricanBotSupport 方法体 6200-6231，调用点是日块）。
	_african_bot_support(d, w)

	# 1040-1043：美国关系<=500 时取消对华贸易。
	if w.empires.size() > 0 and w.empires[0] != null \
			and w.empires[0].relations <= 500 and _country_tag(w, 51, "对华贸易"):
		var usa51 := w.get_country_by_legacy_index(51)
		if usa51 != null:
			usa51.set_tag("对华贸易", false)

	# 1045-1048：苏联关系<=500 时清除 relres 标志。
	if w.empires.size() > 1 and w.empires[1] != null \
			and w.empires[1].relations <= 500 and w.get_flag("relres"):
		w.set_flag("relres", false)


## TimeScript.cs:640-653（Repaint 日块）：危地马拉(149)/尼加拉瓜(147)内战触发。
## 原版条件（level_of_unstab 与 500 阈值；Godot 显示值为 /10，故 500=显示 50.0）：
##   - 危地马拉：非社会主义且 gov!=2 且不稳定度 > 500（用户反馈“到50未爆”→ 用 >= 500），
##     或社会主义/gov==2 且不稳定度 < 500 → 开战 64，并置 parts[1]（URNG 控制区）。
##   - 尼加拉瓜：社会主义/gov==2 且不稳定度 < 500 → 开战 67，置 parts[0]。
func _daily_latin_war_triggers(w: WorldState) -> void:
	if w == null:
		return
	var c149 := w.get_country_by_legacy_index(149)
	if c149 != null and not _war_going_idx(w, 64) \
			and ((not w.is_socialism(c149, true) and c149.government != 2 \
				and c149.level_of_instability >= 500) \
				or ((w.is_socialism(c149, true) or c149.government == 2) \
				and c149.level_of_instability < 500)):
		WAR_SYS.start_war(64, "军政府", "URNG", 500, 500, 0, 1)
		var war := _war_idx(w, 64)
		if war != null:
			war.name_war = "危地马拉内战"
			war.fortnight_max = 24
		_set_country_part(c149, 1, true)
	var c147 := w.get_country_by_legacy_index(147)
	if c147 != null and not _war_going_idx(w, 67) \
			and (w.is_socialism(c147, true) or c147.government == 2) \
			and c147.level_of_instability < 500:
		WAR_SYS.start_war(67, "康特拉", "FSLN", 500, 500, 0, 1)
		var war67 := _war_idx(w, 67)
		if war67 != null:
			war67.name_war = "尼加拉瓜内战"
			war67.fortnight_max = 24
		_set_country_part(c147, 0, true)


func _war_going_idx(w: WorldState, idx: int) -> bool:
	return idx >= 0 and idx < w.wars.size() and w.wars[idx] != null and w.wars[idx].is_going


func _war_idx(w: WorldState, idx: int) -> WarData:
	return w.wars[idx] if idx >= 0 and idx < w.wars.size() else null


func _set_country_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value


## TimeScript.cs:1648-1679：瑞典(28)/丹麦(90)/挪威(91) econ+okb 且事件686 时，
## 芬兰(26) 脱离亲苏阵营转亲中（Repaint 日块，非月块）。
func _daily_finland_linkage(w: WorldState) -> void:
	var sweden := w.get_country_by_legacy_index(28)
	var denmark := w.get_country_by_legacy_index(90)
	var norway := w.get_country_by_legacy_index(91)
	var finland := w.get_country_by_legacy_index(26)
	if sweden != null and sweden.has_tag("econ") and sweden.has_tag("okb") \
			and denmark != null and denmark.has_tag("econ") and denmark.has_tag("okb") \
			and norway != null and norway.has_tag("econ") and norway.has_tag("okb") \
			and finland != null and not finland.has_tag("okb") and w.event_done_num(686):
		finland.set_tag("亲苏", false)
		finland.set_tag("sev", false)
		finland.set_tag("亲中", true)
		finland.set_tag("对华贸易", true)
		finland.set_tag("econ", true)
		finland.set_tag("okb", true)
		w.influence_prc += 50
		if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
			w.empires[EmpireData.USSR].relations -= 200
			w.empires[EmpireData.USSR].power -= 50
		var china_fin := w.get_country_by_legacy_index(1)
		if china_fin != null and w.is_socialism(china_fin, true):
			finland.government = 1
			finland.sub_government = 1
		elif china_fin != null and china_fin.government == 2:
			finland.government = 2
			finland.sub_government = 15
		elif china_fin != null and china_fin.government == 3:
			finland.government = 3
			finland.sub_government = 5
		else:
			finland.government = 0
			finland.sub_government = 20


## TimeScript.cs:1490-1634 / 1636-1648 / 1689-2089：季度、半年度与月维护。
## 注：916-954（政变/stab/war_active 重置）是 1 月 1 日年块，已移 _yearly_jan1_maintenance；
## 955-1048 是日块，已移 _daily_rim_and_alliance_checks；1648-1679 北欧联动也是日块。
func _monthly_rim_and_alliance_cleanup(w: WorldState) -> void:
	var d := w.数值表
	var china := w.get_country_by_legacy_index(1)

	# 1490-1634：每季度 1 日维护（data[19]==1 && data[20]%3==0）。
	if w.date.day == 1 and w.date.month % 3 == 0:
		if w.event_done_num(36) and w.result_of_event_num(36) == 2:
			var iraq_q := w.get_country_by_legacy_index(14)
			if iraq_q != null:
				iraq_q.stab = 0
		for legacy_idx in [8, 24]:
			var c_q := w.get_country_by_legacy_index(legacy_idx)
			if c_q != null:
				c_q.stab = 0
		var ussr_q := w.get_country_by_legacy_index(7)
		if ussr_q != null:
			ussr_q.development = 0
		for legacy_idx in [118, 112]:
			var c_cw := w.get_country_by_legacy_index(legacy_idx)
			if c_cw != null:
				c_cw.内战中 = false
		for legacy_idx in [139, 123]:
			var c_based := w.get_country_by_legacy_index(legacy_idx)
			if c_based != null:
				c_based.有驻军基地 = false
		# 事件677/678 未完成且国家29/166未分立时，按结果给 data[162..165] 各最多+1。
		var c29 := w.get_country_by_legacy_index(29)
		var c166 := w.get_country_by_legacy_index(166)
		if w.event_done_num(677) and not w.event_done_num(678) \
				and (c29 == null or c29.parts.size() == 0 or not c29.parts[0]) \
				and (c166 == null or c166.parts.size() == 0 or not c166.parts[0]):
			var r677 := w.result_of_event_num(677)
			var inc_slots: Array[int] = []
			match r677:
				0: inc_slots = [163, 164, 165]
				1: inc_slots = [162, 164, 165]
				2: inc_slots = [162, 163, 165]
				3: inc_slots = [162, 163, 164]
				4: inc_slots = [162, 163, 164, 165]
			for slot in inc_slots:
				if slot < d.size() and d[slot] <= 100:
					d[slot] += 1

	# 1636-1648：每半年 1 日维护（data[19]==1 && data[20]%6==0）。
	# 原版机制：6 月 1 日 / 12 月 1 日清除 126/149/147/66 的内战冷却标记，
	# 因此“桑解阵(1043)”5 月按一次后，6 月 1 日冷却清空、6 月可再按。
	if w.date.day == 1 and w.date.month % 6 == 0:
		for legacy_idx in [126, 149, 147, 66]:
			var c_h := w.get_country_by_legacy_index(legacy_idx)
			if c_h != null:
				if legacy_idx == 147 and c_h.内战中:
					print("GameManager: 半年冷却重置 147 尼加拉瓜（桑解阵按钮可再按）")
				c_h.内战中 = false
		for legacy_idx in [60, 85]:
			var c_hb := w.get_country_by_legacy_index(legacy_idx)
			if c_hb != null:
				c_hb.有驻军基地 = false
		w.set_event_done_num(671, false)

	# 1644-1647：年度抽出的两个“坏事件清空月”复位 bad_done（原版字段未建，用 flag）。
	if w.date.day == 1 and d.size() > 121 \
			and (w.date.month == d[119] or w.date.month == d[121]):
		w.set_flag("bad_done", false)

	# 1689-1740：月维护计时器与决议清理。
	if d.size() > 44 and d[44] > 0:
		d[44] -= 1
	if w.event_done_num(36) and w.result_of_event_num(36) == 3 and w.date.month % 2 == 0:
		var iraq_36 := w.get_country_by_legacy_index(14)
		if iraq_36 != null:
			iraq_36.stab = 0
	# 1716-1760：决议计数器递减与对应决议清除。
	if w.planned_price_reduction > 0:
		w.planned_price_reduction -= 1
	if w.austerity > 0:
		w.austerity -= 1
	if w.developed_consumerism > 0:
		w.developed_consumerism -= 1
	if w.new_era_commune_member > 0:
		w.new_era_commune_member -= 1
	if w.party_means_party > 0:
		w.party_means_party -= 1
	if w.party_subsidy > 0:
		w.party_subsidy -= 1
	if w.arms_purchase_agreement > 0:
		w.arms_purchase_agreement -= 1
	if w.pmc > 0:
		w.pmc -= 1
	var counter_decisions := [
		[w.planned_price_reduction, 41],
		[w.austerity, 42],
		[w.developed_consumerism, 43],
		[w.new_era_commune_member, 44],
		[w.party_means_party, 45],
		[w.party_subsidy, 46],
		[w.arms_purchase_agreement, 47],
		[w.pmc, 48],
	]
	for pair in counter_decisions:
		var counter_val: int = pair[0]
		var decision_idx: int = pair[1]
		if counter_val <= 0 and w.decisions != null \
				and w.decisions.completed.size() > decision_idx \
				and w.decisions.completed[decision_idx]:
			w.decisions.completed[decision_idx] = false
	for decision_idx in [49, 50, 51, 52]:
		if w.decisions != null and w.decisions.completed.size() > decision_idx:
			w.decisions.completed[decision_idx] = false

	# 1940-1976：月度递减/清零。
	for slot in [167, 183, 144, 145, 142, 150, 151]:
		if slot < d.size() and d[slot] > 0:
			d[slot] -= 1
	# 原版 TimeScript.cs:1896-1898 仅当 data[168] > 0 时清零。
	if d.size() > 168 and d[168] > 0:
		d[168] = 0
	if china != null and china.has_tag("ovd") and china.has_tag("seato"):
		if d.size() > 142:
			d[141] = 0
			d[142] = 0

	# 1980-1995：帝国资金换油价冷却。
	if w.empires.size() > 1 and w.empires[1] != null \
			and w.empires[1].money >= 200 and (d.size() <= 150 or d[150] <= 0) \
			and w.empires[1].power - 200 >= (w.empires[0].power if w.empires.size() > 0 else 0) \
			and w.empires[1].power - 200 >= w.influence_prc and d[143] < 50:
		w.empires[1].money -= 200
		d[143] += 1
		d[150] = 6
	if w.empires.size() > 0 and w.empires[0] != null \
			and w.empires[0].money >= 200 and (d.size() <= 151 or d[151] <= 0) \
			and w.empires[0].power - 200 >= (w.empires[1].power if w.empires.size() > 1 else 0) \
			and w.empires[0].power - 200 >= w.influence_prc and d[143] > 10:
		w.empires[0].money -= 200
		d[143] -= 1
		d[151] = 6

	# 2005-2070：国家36/123 与海湾 101-105 的影响衰减与亲中判定。
	for legacy_idx in [36, 123]:
		var c_infl := w.get_country_by_legacy_index(legacy_idx)
		if c_infl == null:
			continue
		if c_infl.sov_influence > 0:
			c_infl.sov_influence -= 1
		if c_infl.usa_influence > 0:
			c_infl.usa_influence -= 1
		if c_infl.prc_influence > 0:
			c_infl.prc_influence -= 1
	for legacy_idx in range(101, 106):
		if legacy_idx == 104:
			continue
		var c_gulf := w.get_country_by_legacy_index(legacy_idx)
		if c_gulf == null:
			continue
		if c_gulf.sov_influence > 0:
			c_gulf.sov_influence -= 1
		if c_gulf.usa_influence > 0:
			c_gulf.usa_influence -= 1
		if c_gulf.prc_influence > 0:
			c_gulf.prc_influence -= 1
		if c_gulf.influence_china >= 1000 and not c_gulf.has_tag("亲中") \
				and not w.event_done_num(568) and c_gulf.puppet_of < 0:
			c_gulf.set_tag("亲中", true)
	var c36 := w.get_country_by_legacy_index(36)
	if c36 != null and c36.influence_china >= 1000 and not c36.has_tag("亲中") \
			and not w.event_done_num(568) and c36.puppet_of < 0:
		c36.set_tag("亲中", true)

	# 2071-2090：desnull 递减与对应决议清除。
	for desnull_idx in w.desnull.size():
		if w.desnull[desnull_idx] > 0:
			w.desnull[desnull_idx] -= 1
		if desnull_idx in [24, 25, 26, 27, 28, 29, 30, 31, 32, 34] \
				and w.desnull[desnull_idx] <= 0 \
				and w.decisions != null and w.decisions.completed.size() > desnull_idx \
				and w.decisions.completed[desnull_idx]:
			w.decisions.completed[desnull_idx] = false
	var kenya_infl := w.get_country_by_legacy_index(36)
	if kenya_infl != null and kenya_infl.influence_nato > 0:
		kenya_infl.influence_nato -= 1

	# 1770-1881 事件686 月块（本项目先移植其中的芬兰 based 分支）。
	_monthly_finland_linkage(w)
	# 1898-1917：乌干达事件659/661 月块推进与开战。
	_monthly_uganda_linkage(w, d)
	# 2090-2300：事件418 中东影响力争夺。
	_monthly_event418_mideast(w)
	# 2299-2565：外援消耗、英法西葡政体、被美苏逐出联盟等月块维护。
	_monthly_ejection_and_misc(w, d)


## TimeScript.cs:2090-2300：事件418 中东影响力争夺（月块）。
## 美苏各自用 money 拉拢中东六国与海湾/肯尼亚，降低中国影响力；中国按亲中/经济合作反向支持。
func _monthly_event418_mideast(w: WorldState) -> void:
	if not w.event_done_num(418):
		return
	var usa := w.empires[0] if w.empires.size() > 0 else null
	var ussr := w.empires[1] if w.empires.size() > 1 else null
	var middle_six := [14, 8, 30, 37, 35, 40]
	var kenya := w.get_country_by_legacy_index(36)

	var num59 := 0
	if usa != null and usa.money >= 250:
		for legacy_idx in middle_six:
			var c_usa := w.get_country_by_legacy_index(legacy_idx)
			if c_usa != null and c_usa.has_tag("亲美"):
				num59 += 5
		if kenya != null:
			if kenya.has_tag("亲中"):
				if usa.money >= 300:
					@warning_ignore("integer_division")
					num59 += usa.power / 25
					kenya.influence_china -= num59
					usa.money -= 300
			elif kenya.influence_china > 200:
				@warning_ignore("integer_division")
				num59 += usa.power / 15
				kenya.influence_china -= num59
				usa.money -= 250
		for legacy_idx in range(101, 106):
			var c_gulf := w.get_country_by_legacy_index(legacy_idx)
			if c_gulf == null:
				continue
			if c_gulf.has_tag("亲中"):
				if usa.money >= 300:
					@warning_ignore("integer_division")
					num59 += usa.power / 25
					c_gulf.influence_china -= num59
					usa.money -= 300
			elif c_gulf.influence_china > 200:
				@warning_ignore("integer_division")
				num59 += usa.power / 15
				c_gulf.influence_china -= num59
				usa.money -= 250

	var num60 := 0
	if ussr != null and ussr.money >= 250:
		for legacy_idx in middle_six:
			var c_ussr := w.get_country_by_legacy_index(legacy_idx)
			if c_ussr != null and c_ussr.has_tag("亲苏"):
				num60 += 5
		if kenya != null:
			if kenya.has_tag("亲中"):
				if ussr.money >= 300:
					@warning_ignore("integer_division")
					num60 += ussr.power / 25
					kenya.influence_china -= num60
					ussr.money -= 300
			elif kenya.influence_china > 200:
				@warning_ignore("integer_division")
				num60 += ussr.power / 15
				kenya.influence_china -= num60
				ussr.money -= 250
		for legacy_idx in range(101, 106):
			var c_gulf := w.get_country_by_legacy_index(legacy_idx)
			if c_gulf == null:
				continue
			if c_gulf.has_tag("亲中"):
				if ussr.money >= 300:
					@warning_ignore("integer_division")
					num60 += ussr.power / 25
					c_gulf.influence_china -= num60
					ussr.money -= 300
			elif c_gulf.influence_china > 200:
				@warning_ignore("integer_division")
				num60 += ussr.power / 15
				c_gulf.influence_china -= num60
				ussr.money -= 250

	var num61 := 0
	for legacy_idx in middle_six:
		var c_prc := w.get_country_by_legacy_index(legacy_idx)
		if c_prc == null:
			continue
		if c_prc.has_tag("亲中"):
			num61 += 15
		if c_prc.has_tag("econ"):
			num61 += 5
	for legacy_idx in range(101, 106):
		var c_gulf := w.get_country_by_legacy_index(legacy_idx)
		if c_gulf != null:
			c_gulf.influence_china += num61
	if kenya != null:
		kenya.influence_china += num61
	for legacy_idx in range(101, 106):
		var c_gulf := w.get_country_by_legacy_index(legacy_idx)
		if c_gulf == null:
			continue
		c_gulf.influence_china = clampi(c_gulf.influence_china, 0, 1000)
		if c_gulf.has_tag("亲中") and c_gulf.influence_china < 250:
			c_gulf.set_tag("亲中", false)
	if kenya != null:
		kenya.influence_china = clampi(kenya.influence_china, 0, 1000)
		if kenya.has_tag("亲中") and kenya.influence_china < 250:
			kenya.set_tag("亲中", false)


## TimeScript.cs:2299-2565：外援消耗、英法西葡政体、modifies 41/53、被美苏逐出联盟、OAR 等月块维护。
func _monthly_ejection_and_misc(w: WorldState, d: Array[int]) -> void:
	var china := w.get_country_by_legacy_index(1)

	# 2299-2325：data[146] 外援消耗与贸易同盟国家影响。
	if d.size() > W.I_FOREIGN_AID and d[W.I_FOREIGN_AID] > 0:
		d[W.I_BUDGET] -= d[W.I_FOREIGN_AID]
		d[W.I_AGENTS] -= d[W.I_FOREIGN_AID]
		d[W.I_ARMY] -= d[W.I_FOREIGN_AID]
		for c in w.countries:
			if c == null or not c.has_tag("贸易同盟"):
				continue
			if china != null and china.has_tag("ovd"):
				c.sov_influence -= 10
			else:
				c.usa_influence -= 10
			c.prc_influence += 5

	# 2326-2335：英国 spec 上限、1981.1 希腊入欧。
	var britain := w.get_country_by_legacy_index(92)
	if britain != null and britain.special > 1:
		britain.special = 1
	if w.date.year == 1981 and w.date.month == 1:
		var greece := w.get_country_by_legacy_index(45)
		if greece != null and greece.government == 3:
			greece.set_tag("eu", true)
			if w.empires.size() > 0 and w.empires[0] != null:
				w.empires[0].power += 10

	# 2336-2345：美国/苏联 spec 月度递减。
	for legacy_idx in [51, 7]:
		var c_spec := w.get_country_by_legacy_index(legacy_idx)
		if c_spec != null and c_spec.special > 0:
			c_spec.special -= 1

	# 2346-2350：中国 parts[0..10] 全空 → 原版 ILoveSuckCocks() 刷新地图；
	# 项目按惯例近似省略地图 parts 刷新（见 war_system 注释）。
	# 2351-2355：1979.5 英国亲美路线（原版 !dlc[3] 分支；Godot 改版 dlc[3]=true 全免费 → 不执行）。
	if w.date.year == 1979 and w.date.month == 5 and not w.dlc[3]:
		if w.empires.size() > 0 and w.empires[0] != null:
			w.empires[0].power += 10
		if britain != null:
			britain.sub_government = 12

	# 2356-2361：modifies[41] 停用条件。
	if d[W.I_DIPLO] >= 850 or (d.size() > 131 and (d[131] == 1 or d[131] == 2)):
		w.modifiers[41].is_active = false
	var egypt41 := w.get_country_by_legacy_index(30)
	if egypt41 != null and not egypt41.has_tag("亲美"):
		w.modifiers[41].is_active = false
	var iran41 := w.get_country_by_legacy_index(8)
	if iran41 != null and (iran41.government == 1 or iran41.sub_government == 20):
		w.modifiers[41].is_active = false
	if china != null and china.has_tag("sev"):
		w.modifiers[41].is_active = false

	# 2362-2377：东德(16)/西德(17) 对华贸易与 modifies[53] 停用。
	var east_germany := w.get_country_by_legacy_index(16)
	var west_germany := w.get_country_by_legacy_index(17)
	if east_germany != null and east_germany.has_tag("亲苏") \
			and (china == null or china.government != 1 or china.has_tag("asean") or not w.get_flag("relres")):
		w.modifiers[53].is_active = false
		east_germany.set_tag("对华贸易", false)
	if east_germany != null and east_germany.has_tag("亲中") \
			and (china == null or china.government != 1 or china.has_tag("asean")):
		w.modifiers[53].is_active = false
		east_germany.set_tag("对华贸易", false)
	if west_germany != null and west_germany.parts.size() > 0 and west_germany.parts[0] \
			and west_germany.government == 1 \
			and (china == null or china.government != 1 or china.has_tag("asean")):
		w.modifiers[53].is_active = false
		west_germany.set_tag("对华贸易", false)

	# 2378-2385：中国非 SEV 时，东欧 2..6 亲苏国取消对华贸易。
	if china != null and not china.has_tag("sev"):
		for legacy_idx in range(2, 7):
			var c_ee := w.get_country_by_legacy_index(legacy_idx)
			if c_ee != null and c_ee.has_tag("亲苏"):
				c_ee.set_tag("对华贸易", false)

	# 2386-2391：英国社会主义时巴基斯坦/伊朗退出 SENTO。
	if britain != null and (britain.government == 1 or britain.sub_government == 3):
		for legacy_idx in [31, 8]:
			var c_sento := w.get_country_by_legacy_index(legacy_idx)
			if c_sento != null:
				c_sento.set_tag("sento", false)

	# 2392-2470：data[139] 递减与被美苏逐出联盟。
	if d.size() > 139 and d[139] > 0:
		d[139] -= 1
	var is_sev := china != null and china.has_tag("sev")
	var is_asean := china != null and china.has_tag("asean")
	var evict_pre := (d.size() > 140 and d[140] <= 0) \
		and ((not _mod_active(w, 16) and is_sev) or (not _mod_active(w, 17) and is_asean))
	var evict_bad := (d.size() > 140 and d[139] > 0) and (
		(d[140] == 1 and is_sev and china.government != 3 and d[W.I_ECON_DISPLAY] != 37)
		or (d[140] == 2 and is_asean and china.government != 1 and d[W.I_ECON_DISPLAY] != 34)
	)
	if (evict_pre or evict_bad) and d.size() > 139 and d[139] > 0:
		d[139] = 0
	var do_evict := d.size() > 139 and d[139] <= 0 and (
		(is_sev and _mod_active(w, 16) and (d.size() <= 140 or d[140] <= 0))
		or (is_asean and _mod_active(w, 17) and (d.size() <= 140 or d[140] <= 0))
		or (d.size() > 140 and d[140] > 0)
	)
	if do_evict:
		if is_asean:
			if w.empires.size() > 0 and w.empires[0] != null:
				w.empires[0].relations -= 300
		else:
			if w.empires.size() > 1 and w.empires[1] != null:
				w.empires[1].relations -= 300
			var ussr_ev := w.get_country_by_legacy_index(7)
			if ussr_ev != null:
				ussr_ev.set_tag("对华贸易", false)
		if d.size() > 140:
			d[140] = 0
		if d.size() > 135 and d[135] > 0:
			w.modifiers[47].is_active = true
			d[135] = 0
		if d.size() > 136 and d[136] > 0:
			w.modifiers[48].is_active = true
			d[136] = 0
		if d.size() > 139:
			d[139] = 0
		var ussr_spec := w.get_country_by_legacy_index(7)
		if ussr_spec != null:
			ussr_spec.special = 0
		var usa_spec := w.get_country_by_legacy_index(51)
		if usa_spec != null:
			usa_spec.special = 0
		for c in w.countries:
			if c == null or not c.has_tag("亲中"):
				continue
			if c.原版序号 < 2:
				continue  # 原版 num70 从 2 起，跳过 0/1
			if is_asean:
				c.set_tag("asean", false)
				c.set_tag("seato", false)
				if w.empires.size() > 0 and w.empires[0] != null:
					w.empires[0].power -= 5
			else:
				c.set_tag("ovd", false)
				c.set_tag("sev", false)
				if w.empires.size() > 1 and w.empires[1] != null:
					w.empires[1].power -= 5
		if d.size() > 137 and d[137] > 0:
			d[137] = 0
			for c in w.countries:
				if c != null and c.has_tag("亲中"):
					c.set_tag("econ", true)
		if d.size() > 138 and d[138] > 0:
			d[138] = 0
			for c in w.countries:
				if c != null and c.has_tag("亲中"):
					c.set_tag("okb", true)
		if china != null:
			china.set_tag("ovd", false)
			china.set_tag("asean", false)
			china.set_tag("sev", false)
			china.set_tag("seato", false)

	# 2471-2475：1983.6 法国亲美路线（原版 !dlc[3] 分支；Godot 改版 dlc[3]=true 全免费 → 不执行）。
	if w.date.year == 1983 and w.date.month == 6 and not w.dlc[3]:
		if w.empires.size() > 0 and w.empires[0] != null:
			w.empires[0].power += 10
		var france83 := w.get_country_by_legacy_index(21)
		if france83 != null:
			france83.sub_government = 12

	# 2476-2494：苏联加入北约时按外交标记改战争阵营。
	var ussr_nato := w.get_country_by_legacy_index(7)
	if ussr_nato != null and ussr_nato.has_tag("nato"):
		for i in w.wars.size():
			var war_nato: WarData = w.wars[i]
			if war_nato == null or not war_nato.is_going or i == 5:
				continue
			if war_nato.diplo_done[0]:
				war_nato.usa_side = 1
				war_nato.ussr_side = 1
			elif war_nato.diplo_done[1]:
				war_nato.usa_side = 0
				war_nato.ussr_side = 0

	# 2495-2502：1977 年后西班牙/葡萄牙自由化（原版 !dlc[3] 分支；Godot 改版 dlc[3]=true 全免费 → 不执行）。
	if w.date.year > 1976 and not w.dlc[3]:
		var portugal := w.get_country_by_legacy_index(87)
		if portugal != null:
			portugal.sub_government = 6
			portugal.government = 3
		var spain := w.get_country_by_legacy_index(86)
		if spain != null:
			spain.sub_government = 5
			spain.government = 3

	# 2503-2509：dlc[3] 分支（Godot 改版 dlc[3]=true 全免费 → 执行）。
	# 原版：1984 年土耳其 sub==7 时改开化（SubGosstroy=6、Gosstroy=3）。
	if w.dlc[3]:
		var turkey84 := w.get_country_by_legacy_index(84)
		if turkey84 != null and turkey84.sub_government == 7 and w.date.year == 1984:
			turkey84.sub_government = 6
			turkey84.government = 3

	# 2510-2550：OAR 成立后阿拉伯国家退出其它联盟。
	if w.oar:
		var egypt_oar := w.get_country_by_legacy_index(30)
		if egypt_oar == null or egypt_oar.government == 1:
			pass
		else:
			for legacy_idx in [14, 35, 40, 30, 13]:
				var c_oar := w.get_country_by_legacy_index(legacy_idx)
				if c_oar == null:
					continue
				if (c_oar.has_tag("okb") or c_oar.has_tag("ovd") or c_oar.has_tag("nato")) \
						and c_oar.has_tag("oar"):
					c_oar.set_tag("okb", false)
					c_oar.set_tag("ovd", false)
					c_oar.set_tag("nato", false)

	# 2551-2555：1982.5 西班牙入北约（原版 !dlc[3] 分支；Godot 改版 dlc[3]=true 全免费 → 不执行）。
	if w.date.year == 1982 and w.date.month == 5 and not w.dlc[3]:
		var spain_nato := w.get_country_by_legacy_index(86)
		if spain_nato != null and spain_nato.sub_government == 5:
			spain_nato.set_tag("nato", true)

	# 2556-2564：土耳其 sub==9 改名（new_events_text[784] 建模说明 → 跳过）。
	# DaysInSouthAmerica 建模说明 → 跳过（项目月块不处理南美选举漂移）。


## TimeScript.cs:1770-1881 事件686 月块中的芬兰(26)部分（1860-1890）：
## 瑞典(28)/丹麦(90)/挪威(91) 都 based 且芬兰未 based 时，芬兰按苏联领导人转亲苏。
## （1648-1679 三国 econ+okb 转亲中分支是日块，已移 _daily_finland_linkage。）
## Phase 2 缺口：1772-1856 北欧 sovpower 累积/封顶/转 based 的 80 行尚移植说明，
## 目前三国“有驻军基地”主要靠外交/事件置位。
func _monthly_finland_linkage(w: WorldState) -> void:
	var sweden := w.get_country_by_legacy_index(28)
	var denmark := w.get_country_by_legacy_index(90)
	var norway := w.get_country_by_legacy_index(91)
	var finland := w.get_country_by_legacy_index(26)

	if sweden != null and sweden.有驻军基地 and denmark != null and denmark.有驻军基地 \
			and norway != null and norway.有驻军基地 and finland != null and not finland.有驻军基地:
		var ussr_now := w.empires[EmpireData.USSR].current_leader \
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null else -1
		if ussr_now == 6:
			finland.government = 2
			finland.sub_government = 14
		else:
			finland.government = 1
			finland.sub_government = 1
		finland.set_tag("亲中", false)
		finland.set_tag("亲苏", true)
		if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
			pass
		var ussr_fin := w.get_country_by_legacy_index(7)
		if ussr_fin != null and ussr_fin.has_tag("sev"):
			finland.set_tag("sev", true)
		if ussr_fin != null and ussr_fin.has_tag("ovd"):
			finland.set_tag("ovd", true)
		finland.有驻军基地 = true


## TimeScript.cs:1898-1917：乌干达(118) 事件659/661 月块推进与战争 81 触发。
func _monthly_uganda_linkage(w: WorldState, _d: Array[int]) -> void:
	if not w.event_done_num(659) or w.event_done_num(661) or w.war_going(81):
		return
	var uganda := w.get_country_by_legacy_index(118)
	if uganda == null:
		return
	uganda.influence_china += 15
	uganda.prc_influence += 2
	uganda.sov_influence -= 1
	if uganda.influence_nato >= 1000:
		var war81 := _war_at_ensure(w, 81)
		if war81 != null:
			war81.name_war = "乌 干 达 内 战"
			war81.infl2 = 1000
			w.数值表[W.I_WAR_RESOLVE] = 81
			GameManager.start_event("event_661")
	if uganda.prc_influence > 700:
		while uganda.parts.size() <= 0:
			uganda.parts.append(false)
		uganda.parts[0] = true
		GameManager.start_war(81, "阿 明 残 军", "政 府 军", 600, 400)
	if uganda.sov_influence > 700:
		while uganda.parts.size() <= 0:
			uganda.parts.append(false)
		uganda.parts[0] = true
		GameManager.start_war(81, "布 干 达 武 装", "政 府 军", 600, 400)


func _war_at_ensure(w: WorldState, idx: int) -> WarData:
	while w.wars.size() <= idx:
		w.wars.append(WarData.new())
	return w.wars[idx]


## TimeScript.cs:743-954：1 月 1 日年块（Repaint 内 data[19]==1 && data[20]==1）。
## 原版这些内容只在每年 1 月 1 日执行一次，不是月块。
func _yearly_jan1_maintenance(w: WorldState) -> void:
	var d := w.数值表
	var china := w.get_country_by_legacy_index(1)

	# 745-754：意大利(85)发展度年增，美苏花钱换 data[160/161]。
	var italy := w.get_country_by_legacy_index(85)
	if italy != null:
		italy.level_of_development += 10
		if italy.level_of_development >= 100:
			italy.level_of_development = 100
	if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null \
			and w.empires[EmpireData.USSR].money >= 200 and randi_range(0, 4) == 1:
		w.empires[EmpireData.USSR].money -= 100
		if d.size() > 160:
			d[160] += 500
	if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null \
			and w.empires[EmpireData.USA].money >= 200 and randi_range(0, 4) == 1:
		w.empires[EmpireData.USA].money -= 100
		if d.size() > 161:
			d[161] += 500

	# 758-767：AnthemCooldownTime 年递减与决议39清除。
	if w.anthem_cooldown_time > 0:
		w.anthem_cooldown_time -= 1
	if w.anthem_cooldown_time <= 0 and w.decisions != null \
			and w.decisions.completed.size() > 39 and w.decisions.completed[39]:
		w.decisions.completed[39] = false

	# 768-776：中国发展度、英国/法国 special、菲律宾(24)亲中势力年重置/衰减。
	if china != null:
		china.development = 0
	var britain := w.get_country_by_legacy_index(92)
	if britain != null:
		britain.special = 0
	var france := w.get_country_by_legacy_index(21)
	if france != null:
		france.special = 0
	var c24 := w.get_country_by_legacy_index(24)
	if c24 != null and c24.prc_power > 0 and c24.prc_power < 100:
		c24.prc_power -= 10

	# 777-870：危地马拉(149)/尼加拉瓜(147)不稳定度年漂移。
	var c149 := w.get_country_by_legacy_index(149)
	if c149 != null and c149.level_of_instability > 0 and c149.level_of_instability < 1000:
		c149.level_of_instability += 10
		if w.is_socialism(c149, true) or c149.government == 2:
			c149.level_of_instability -= 10
			for idx_vyshi in [141, 140, 148, 147, 146, 144]:
				var vc := w.get_country_by_legacy_index(idx_vyshi)
				if vc != null and vc.has_tag("亲美"):
					c149.level_of_instability -= 10
		for idx_soc in [147, 148]:
			var sc := w.get_country_by_legacy_index(idx_soc)
			if sc != null and (w.is_socialism(sc, true) or sc.government == 2):
				c149.level_of_instability += 25
		for idx_pro in [138, 141]:
			var pc := w.get_country_by_legacy_index(idx_pro)
			if pc != null and pc.has_tag("亲中"):
				c149.level_of_instability += 25
	var c147 := w.get_country_by_legacy_index(147)
	if c147 != null and c147.level_of_instability > 0 and c147.level_of_instability < 1000:
		c147.level_of_instability += 10
		if w.is_socialism(c147, true) or c147.government == 2:
			c147.level_of_instability -= 10
			for idx_vyshi in [141, 140, 148, 147, 146, 144]:
				var vc := w.get_country_by_legacy_index(idx_vyshi)
				if vc != null and vc.has_tag("亲美"):
					c147.level_of_instability -= 10
		for idx_soc in [149, 148]:
			var sc := w.get_country_by_legacy_index(idx_soc)
			if sc != null and (w.is_socialism(sc, true) or sc.government == 2):
				c147.level_of_instability += 25
		for idx_pro in [138, 141]:
			var pc := w.get_country_by_legacy_index(idx_pro)
			if pc != null and pc.has_tag("亲中"):
				c147.level_of_instability += 25

	# 871-886：伊拉克(14)/日本(44)/塞内加尔(112)年衰减。
	var iraq := w.get_country_by_legacy_index(14)
	if iraq != null and iraq.prc_power > 0 and w.event_done_num(36) \
			and w.result_of_event_num(36) == 2 and not w.event_done_num(566):
		iraq.prc_power -= 10
	var japan := w.get_country_by_legacy_index(44)
	if japan != null:
		if japan.prc_power > 0:
			japan.prc_power -= 10
		if japan.prc_influence > 0:
			japan.prc_influence -= 5
	var senegal := w.get_country_by_legacy_index(112)
	if senegal != null and senegal.level_of_instability > 0:
		senegal.level_of_instability -= 100

	# 887-894：葡萄牙(87)special 年增、中国对美/对华影响与中美基地标记年清。
	var portugal := w.get_country_by_legacy_index(87)
	if portugal != null and w.date.year != 1976:
		portugal.special += 5
	if china != null:
		china.influence_nato = 0
		china.influence_china = 0
		china.有驻军基地 = false
	if portugal != null:
		portugal.有驻军基地 = false

	# 897-906：1986 年西班牙(86)/葡萄牙(87)随卢森堡(0)欧盟状态入欧。
	if w.date.year == 1986:
		var luxemburg := w.get_country_by_legacy_index(0)
		var spain := w.get_country_by_legacy_index(86)
		var portugal_eu := w.get_country_by_legacy_index(87)
		if luxemburg != null and luxemburg.has_tag("eu"):
			if spain != null and spain.government == 3:
				spain.join_eu()
			if portugal_eu != null and portugal_eu.government == 3:
				portugal_eu.join_eu()

	# 907-914：中国在 SEATO 内时内战标记解除。
	if china != null and china.has_tag("seato"):
		var any_seato := false
		for c in w.countries:
			if c != null and c.has_tag("seato"):
				any_seato = true
				break
		if any_seato:
			china.内战中 = false

	# 918-923：除意大利(85)外所有政变标记清除。
	for c in w.countries:
		if c != null and c.原版序号 != 85:
			c.政变中 = false

	# 926-942：各国 stab/prcpower/cw/影响年重置与衰减。
	# 注意：原版这里清的是 Country.stab（外交按钮冷却标志），不是 port 的 stability 统计值。
	for legacy_idx in [11, 19, 12, 21, 47, 51]:
		var c_stab := w.get_country_by_legacy_index(legacy_idx)
		if c_stab != null:
			c_stab.stab = 0
	var india := w.get_country_by_legacy_index(19)
	if india != null:
		india.prc_power = 0
	var nigeria := w.get_country_by_legacy_index(60)
	if nigeria != null and nigeria.prc_power > 0 and nigeria.prc_power < 100:
		nigeria.prc_power -= 5
	var burma := w.get_country_by_legacy_index(33)
	if burma != null:
		burma.内战中 = false
	var thailand := w.get_country_by_legacy_index(34)
	if burma != null and (thailand == null or not thailand.has_tag("亲中")) \
			and burma.influence_china > 0 and burma.influence_china < 100:
		burma.influence_china -= 5
	var cameroon := w.get_country_by_legacy_index(66)
	if cameroon != null and cameroon.level_of_instability > 0 \
			and cameroon.level_of_instability < 100:
		cameroon.level_of_instability -= 5

	# 946-947：war_active 年度重置（扶持极左派冷却）。
	for i in w.war_active.size():
		w.war_active[i] = false

	# 952-954：满意现秩序者 data[106] 与派系 party_number 年 /=10。
	# Godot 侧由 _on_year_changed 随后对 factions.support 与 data[106] 执行同一衰减。


func _on_year_changed() -> void:
	var w := world
	if w == null:
		return
	var d := w.数值表
	# 原版 TimeScript.cs:500-501：年滚时抽两个“坏事件清空月”（1-6 / 7-12），供月块 bad_done 复位。
	if d.size() > 121:
		d[119] = randi_range(1, 6)
		d[121] = randi_range(7, 12)
	# 原版 TimeScript.cs:743-954：1 月 1 日年块维护。
	_yearly_jan1_maintenance(w)
	@warning_ignore("integer_division")
	# 派系 support 年度衰减（原版 party_number/=10）。
	# 注意：原版同 tick 稍后会用 ideology 重算 party_number，一党制下此衰减会被覆盖；
	# Godot 在 tick() 中同样先衰减、后 _sync_faction_numbers_from_ideology，保持一致。
	for f in w.factions:
		f.support = f.support / 10
	# 满意现秩序者衰减（原版 835 年 /=10）
	d[W.I_SATISFIED] = d[W.I_SATISFIED] / 10
	# 联合/人民民主(7/8) 额外腰斩（TimeScript 年滚 ~640）
	if d[W.I_SATISFIED] > 1 and (d[W.I_PARTY_SYSTEM] == 7 or d[W.I_PARTY_SYSTEM] == 8):
		d[W.I_SATISFIED] = d[W.I_SATISFIED] / 2
	# 年度进口需求增量（原版 TimeScript.cs:514 data[24] += ImportChange；公式 GameState.cs:11-16）
	d[W.I_IMPORT_NEEDS] += w.import_change()
	# POL-05 / POL-12：年龄 +1、病弱/老死、任职年数（TimeScript 615–621 + DeathPolitics）
	POL_SYS.annual_politics(d, w)
	# 1980-01-01 成就检查（TimeScript.cs:687-696：人口>=10000 → Set(63)；
	# 工业/农业/服务业均>=700 → Set(62)；原作在 iron_and_blood 内，Achievements 内部有同守卫）。
	if w.date.year == 1980:
		if d[W.I_POPULATION] >= 10000:
			Achievements.set_achievement(63)
		if d[W.I_INDUSTRY] >= 700 and d[W.I_AGRICULTURE] >= 700 and d[W.I_SERVICES] >= 700:
			Achievements.set_achievement(62)


# ============================================================================
# 政客生命周期 — 逻辑已拆至 数据脚本/politician_system.gd，此处仅保留公开 API 转发 stub
# （外部调用点：政治界面 / 事件脚本 kill_politician 零改动）
# ============================================================================

func change_of_killing(politic_index: int) -> float:
	return POL_SYS.change_of_killing(politic_index)


func kill_politician(pol_index: int, preferred_name: String = "") -> void:
	POL_SYS.kill_politician(pol_index, preferred_name)


func assign_politician_position(pol_index: int, position_id: int) -> bool:
	return POL_SYS.assign_politician_position(pol_index, position_id)


func set_faction_leader_politician(pol_index: int) -> bool:
	return POL_SYS.set_faction_leader_politician(pol_index)


func fill_vacant_faction_leaders() -> void:
	POL_SYS.fill_vacant_faction_leaders()


# ── 每日：赤字恢复（原版 399-411，日块 Repaint(true)）──
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


# ── 每日：科研点生成（原版 1458-1488，日块）──
## data[11] += data[73]/40；data[16]<=12 且事件92 时按 data[102] 修正。
func _daily_science_gen(w: WorldState) -> void:
	var d := w.数值表
	d[W.I_SCIENCE] += d[W.I_BUDGET_SCIENCE] / 40
	if d[W.I_ECON_SYSTEM] <= 12 and w.event_done_num(92):
		match _dv(d, 102):
			1, 2, 3:
				d[W.I_SCIENCE] -= 1
			4:
				d[W.I_SCIENCE] += 1


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


# ── 月度：人口增长（原版 3038-3135，月块 data[19]==1）──
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


# ── 月度：寡头成长（原版 2559-2850，月块 data[19]==1）──
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


## TimeScript.cs:2852-2913：改革阶段→美国关系、波兰 1983.7、中印战争(war==2)、
## 瑞士/越南/印度/古巴月度重置、莫桑比克内战漂移、伊朗革命结算（月块）。
func _monthly_late_maintenance(d: Array[int], w: WorldState) -> void:
	# 2852-2858：data[89]==2 且事件54 未完成 → 对美关系 +1。
	if _dv(d, W.I_REFORM_STAGE) == 2 and not w.event_done_num(54):
		_add_empire_relation(w, EmpireData.USA, 1)

	# 2859-2863：1983.7 波兰 gov==0 且亲苏 → 军政体(2/21)。
	if w.date.year == 1983 and w.date.month == 7:
		var poland := w.get_country_by_legacy_index(2)
		if poland != null and poland.government == 0 and poland.has_tag("亲苏"):
			poland.government = 2
			poland.sub_government = 21

	# 2864-2896：中印边境战争(war_state==2)月度推进与胜利结算。
	if w.war_state == GameConstants.WarState.INDIA:
		if d[W.I_INDIA_WAR_PRESSURE] >= 1000:
			w.influence_prc += 10
			d[W.I_ARUNACHAL_STATUS] = 2
			# 原版此处调 allcountries[1].ILoveSuckCocks() 刷新中国地图 parts；
			# 项目既有裁决：地图 parts 刷新近似省略 → 用地图归属转移等价实现
			# （藏南/阿鲁纳恰尔地块归中国 710，对应原版 parts 重绘中国全图）。
			_arunachal_to_china(w)
			d[W.I_POPULATION] += 434
			w.war_state = GameConstants.WarState.PEACE
			GameManager.start_event("event_443")
		d[W.I_POPULATION] -= 2
		if d[W.I_INDIA_WAR_PRESSURE] >= 50:
			d[W.I_INDIA_WAR_PRESSURE] -= 50
		elif w.influence_prc >= 20:
			w.influence_prc -= 20
		if d[W.I_INDIA_WAR_PRESSURE] <= 0:
			w.influence_prc -= 20
			w.war_state = GameConstants.WarState.PEACE

	# 2897-2901：瑞士(39)/古巴(138) 发展度、越南(11)/印度(19) stab 与印度亲中势力月重置。
	var switzerland := w.get_country_by_legacy_index(39)
	if switzerland != null:
		switzerland.development = 0
	var vietnam := w.get_country_by_legacy_index(11)
	if vietnam != null:
		vietnam.stab = 0
		# 越南被拉入我国经济同盟/经互会后，下一回合起脱离苏联影响
		# （用户需求；原版各拉拢动作只置 econ/sev 不剥 prosov，这里在月结落实）。
		if vietnam.has_tag("亲苏") and (vietnam.has_tag("econ") or vietnam.has_tag("sev")):
			vietnam.set_tag("亲苏", false)
			vietnam.set_tag("苏联盟友", false)
	var india := w.get_country_by_legacy_index(19)
	if india != null:
		india.stab = 0
		india.prc_power = 0
	var cuba := w.get_country_by_legacy_index(138)
	if cuba != null:
		cuba.development = 0

	# 2902-2908：莫桑比克(126) 内战期间不稳定度按美苏力量漂移。
	var mozambique := w.get_country_by_legacy_index(126)
	if mozambique != null and mozambique.parts.size() > 0 and mozambique.parts[0]:
		if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
			@warning_ignore("integer_division")
			mozambique.level_of_instability -= w.empires[EmpireData.USA].power / 100
		if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
			@warning_ignore("integer_division")
			mozambique.level_of_instability += w.empires[EmpireData.USSR].power / 100

	# 2909-2913：伊朗革命进行中且事件58 未完成时，左右势力按美苏力量增长。
	if w.get_flag("iranrev") and not w.event_done_num(58):
		var ussr_power: int = w.empires[EmpireData.USSR].power \
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null else 0
		var usa_power: int = w.empires[EmpireData.USA].power \
			if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null else 0
		@warning_ignore("integer_division")
		d[W.I_IRAN_LEFT_SUPPORT] += ussr_power / 25 + 30
		@warning_ignore("integer_division")
		d[W.I_IRAN_SHAH_SUPPORT] += usa_power / 30


## 藏南/阿鲁纳恰尔地块（map_regions.json region 43）归中国（gwcode 710）。
## 对应原版 ILoveSuckCocks() 在 data[62]>=2 时把中国地图 parts 重绘为含藏南的整图。
const ARUNACHAL_REGION_IDS: Array[int] = [43]
const CHINA_GWCODE := 710


## 中印边境冲突胜利（或事件443 确认）后把藏南地块转给中国。
func _arunachal_to_china(w: WorldState) -> void:
	if w == null:
		return
	set_map_region_owner(ARUNACHAL_REGION_IDS, CHINA_GWCODE)


## TimeScript.cs:3026-3037：7 月/1 月清空事件5/7/8/9/10，瑞士发展==1 清零（月块）。
func _monthly_post_coups(w: WorldState) -> void:
	if w.date.month == 7 or w.date.month == 1:
		for event_idx in [5, 7, 8, 9, 10]:
			w.set_event_done_num(event_idx, false)
	var switzerland := w.get_country_by_legacy_index(39)
	if switzerland != null and switzerland.development == 1:
		switzerland.development = 0


## TimeScript.cs:3025 调用 AfricanCoups()（方法体 6434-6525，月块内执行一次）。
func _monthly_african_coups(w: WorldState) -> void:
	for i in range(53, 153):
		if not ((i < 69) or (i > 105 and i < 109) or (i > 111 and i < 134)):
			continue
		var c := w.get_country_by_legacy_index(i)
		if c == null or c.禁用非洲机制:
			continue
		if d103_excluded(w, i):
			continue
		if i == 54 and not (w.event_done_num(463) and c.stab != 10):
			continue
		if i == 58 or i == 128 or i == 55 or i == 69 or i == 70:
			continue

		if not c.has_tag("亲美") and c.government != 3 and not c.has_tag("亲苏") \
				and not c.has_tag("亲中") and c.sov_power > 300 and c.sov_power >= c.usa_power:
			# 6438-6451：亲苏和平转向。
			var roll := randi_range(80, 99)
			@warning_ignore("integer_division")
			if roll >= 50 and roll <= c.sov_power / 10:
				c.set_tag("亲苏", true)
				c.set_tag("对华贸易", false)
				if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
					w.empires[EmpireData.USSR].power += 1
		elif not c.has_tag("亲美") and c.government != 1 and not c.has_tag("亲苏") \
				and not c.has_tag("亲中") and c.usa_power > 300 and c.sov_power < c.usa_power:
			# 6452-6465：亲美和平转向。
			var roll := randi_range(80, 99)
			@warning_ignore("integer_division")
			if roll >= 50 and roll <= c.usa_power / 10:
				c.set_tag("亲美", true)
				c.set_tag("对华贸易", false)
				if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
					w.empires[EmpireData.USA].power += 1
		elif not c.has_tag("亲苏") and c.sov_power > 300 and c.sov_power >= c.usa_power:
			# 6466-6489：苏联策动政变。
			c.stab -= c.sov_power
			var ussr_power: int = w.empires[EmpireData.USSR].power \
				if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null else 0
			var usa_power: int = w.empires[EmpireData.USA].power \
				if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null else 0
			if (c.stab < -200 and c.has_tag("亲中")) or c.stab < -300 \
					or (c.stab < -200 and c.has_tag("亲美") and ussr_power > usa_power):
				if c.has_tag("亲美"):
					if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
						w.empires[EmpireData.USA].power -= 5
					c.set_tag("亲美", false)
				if c.has_tag("亲中"):
					w.influence_prc -= 5
					c.set_tag("亲中", false)
				c.government = randi_range(0, 2)
				c.sub_government = _african_sub_gosstroy(c.government)
				c.set_tag("亲苏", true)
				c.set_tag("对华贸易", false)
				c.stab = 100
				c.development -= 200
				@warning_ignore("integer_division")
				c.usa_power -= c.usa_power / 2
				@warning_ignore("integer_division")
				c.prc_power -= c.prc_power / 2
				if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
					w.empires[EmpireData.USSR].power += 5
		elif not c.has_tag("亲美") and c.usa_power > 300 and c.sov_power < c.usa_power:
			# 6490-6519：美国策动政变。
			c.stab -= c.usa_power
			var ussr_power: int = w.empires[EmpireData.USSR].power \
				if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null else 0
			var usa_power: int = w.empires[EmpireData.USA].power \
				if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null else 0
			if (c.stab < -200 and c.has_tag("亲中")) or c.stab < -300 \
					or (c.stab < -200 and c.has_tag("亲苏") and usa_power > ussr_power):
				if c.has_tag("亲苏"):
					if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
						w.empires[EmpireData.USSR].power -= 5
					c.set_tag("亲苏", false)
				if c.has_tag("亲中"):
					w.influence_prc -= 5
					c.set_tag("亲中", false)
				c.government = randi_range(0, 2)
				if c.government == 1:
					c.government = 3
				c.sub_government = _african_sub_gosstroy(c.government)
				c.set_tag("亲美", true)
				c.stab = 100
				c.set_tag("对华贸易", false)
				c.development -= 200
				@warning_ignore("integer_division")
				c.sov_power -= c.sov_power / 2
				@warning_ignore("integer_division")
				c.prc_power -= c.prc_power / 2
				if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
					w.empires[EmpireData.USA].power += 5


## 原版 GameState.cs:5057-5127 AfricanSubGosstroy 逐字移植。
func _african_sub_gosstroy(gov: int) -> int:
	if gov == 0:
		var roll0 := randi_range(0, 5)
		if roll0 == 0:
			return 0
		if roll0 == 1:
			return 7
		if roll0 == 2:
			return 9
		if roll0 == 3:
			return 10
		return 13
	if gov == 1:
		var roll1 := randi_range(0, 2)
		if roll1 == 0:
			return 1
		if roll1 == 1:
			return 2
		return 16
	if gov == 2:
		var roll2 := randi_range(0, 4)
		if roll2 == 0:
			return 3
		if roll2 == 1:
			return 8
		if roll2 == 2:
			return 11
		if roll2 == 3:
			return 14
		return 15
	# gov == 3
	var roll3 := randi_range(0, 3)
	if roll3 == 0:
		return 4
	if roll3 == 1:
		return 5
	if roll3 == 2:
		return 6
	return 12


## AfricanCoups 中 data[103]==15 时排除 61（上沃尔特）。
func d103_excluded(w: WorldState, i: int) -> bool:
	var d := w.数值表
	return d.size() > 103 and d[103] == 15 and i == 61


# ── 修正辅助：modifier 是否激活 ──
func _mod_active(w: WorldState, idx: int) -> bool:
	return w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


# ── 双周：科研推进（原版 5608-5755，双周块）──
func _on_fortnight() -> void:
	if _fortnight_service != null:
		_fortnight_service.run(self, world)

func _add_empire_relation(w: WorldState, idx: int, delta: int) -> void:
	if _fortnight_service != null:
		_fortnight_service._add_empire_relation(w, idx, delta)

func _african_bot_support(d: Array[int], w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._african_bot_support(d, w)

func _political_system_recalc(d: Array[int], w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._political_system_recalc(d, w)

func _update_political_line(d: Array[int], w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._update_political_line(d, w)

func _sync_faction_numbers_from_ideology(d: Array[int], w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._sync_faction_numbers_from_ideology(d, w)

func _weekly_ally_upkeep(d: Array[int], w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._weekly_ally_upkeep(d, w)

func _apply_policy_satisfied_growth(d: Array[int], w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._apply_policy_satisfied_growth(d, w)

func _recalc_export_value(d: Array[int], w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._recalc_export_value(d, w)

func _plot_player_cause(d: Array[int], w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._plot_player_cause(d, w)

func _check_daily_conspiracy(d: Array[int]) -> void:
	if _fortnight_service != null:
		_fortnight_service._check_daily_conspiracy(d)

func _check_scheduled_events() -> void:
	if _fortnight_service != null:
		_fortnight_service._check_scheduled_events(world)

func _dv(d: Array, idx: int) -> int:
	return _fortnight_service._dv(d, idx) if _fortnight_service != null else 0

func _country_tag(w: WorldState, idx: int, tag: String) -> bool:
	return _fortnight_service._country_tag(w, idx, tag) if _fortnight_service != null else false

func _country_dev_is(w: WorldState, idx: int, dev: int) -> bool:
	return _fortnight_service._country_dev_is(w, idx, dev) if _fortnight_service != null else false

func _check_periodic_achievements(w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._check_periodic_achievements(w)


func plot_alert_active() -> bool:
	return _fortnight_service.plot_alert_active(world) if _fortnight_service != null else false


func _trigger_ending(ending_id: int) -> void:
	if current_ending_id >= 0:
		return
	current_ending_id = ending_id
	pause()
	get_tree().change_scene_to_file("uid://b1dm8nycmn3gw")
# ============================================================================
# 代理战争 — 逻辑已拆至 数据脚本/war_system.gd，此处仅保留公开 API 转发 stub
# （外部调用点：战争界面 / EventEngine START_WAR / 事件脚本 start_war 零改动）
# ============================================================================

func get_active_wars() -> Array[WarData]:
	return WAR_SYS.get_active_wars()


func get_mil_intervention_display() -> String:
	return WAR_SYS.get_mil_intervention_display()


func start_war(
		war_id: int,
		side1: String = "",
		side2: String = "",
		infl1: int = -1,
		infl2: int = -1,
		usa_side: int = -1,
		ussr_side: int = -1
) -> bool:
	return WAR_SYS.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)


func debug_start_war(war_id: int) -> bool:
	return WAR_SYS.start_war(war_id)


func can_intervene(war_id: int, action_id: int) -> bool:
	return WAR_SYS.can_intervene(war_id, action_id)


func intervene_war(war_id: int, action_id: int) -> bool:
	return WAR_SYS.intervene_war(war_id, action_id)


func resolve_war_finished(war_id: int = -1) -> void:
	WAR_SYS.resolve_war_finished(war_id)
