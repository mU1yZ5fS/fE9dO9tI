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

## 作弊快捷键绑定：action → 物理键码（Key）。空字典时用默认值兜底。
var cheat_hotkey_keys: Dictionary:
	get:
		return _settings.cheat_hotkey_keys if _settings != null else {}
	set(value):
		if _settings != null:
			_settings.cheat_hotkey_keys = value

## 调试控制台总开关。关闭后任何模式都无法用快捷键打开。
var debug_console_enabled: bool:
	get:
		return _settings.debug_console_enabled if _settings != null else false
	set(value):
		if _settings != null:
			_settings.set_debug_console_enabled(value)

## 调试控制台开关快捷键（默认 F12）。
var debug_console_toggle_key: int:
	get:
		return _settings.debug_console_toggle_key if _settings != null else KEY_F12
	set(value):
		if _settings != null:
			_settings.set_debug_console_toggle_key(value)

## 事件系统自动触发总开关。
var events_enabled: bool:
	get:
		return _settings.events_enabled if _settings != null else true
	set(value):
		if _settings != null:
			_settings.set_events_enabled(value)

## 事件文本对齐方式：0=左 1=中 2=右。
var event_text_alignment: int:
	get:
		return _settings.event_text_alignment if _settings != null else 0
	set(value):
		if _settings != null:
			_settings.set_event_text_alignment(value)

var event_desc_font_size: int:
	get:
		return _settings.event_desc_font_size if _settings != null else 29
	set(value):
		if _settings != null:
			_settings.set_event_desc_font_size(value)

var event_option_font_size: int:
	get:
		return _settings.event_option_font_size if _settings != null else 28
	set(value):
		if _settings != null:
			_settings.set_event_option_font_size(value)

var event_result_font_size: int:
	get:
		return _settings.event_result_font_size if _settings != null else 29
	set(value):
		if _settings != null:
			_settings.set_event_result_font_size(value)

## 全局 UI 字体倍率（1.0 = 原始大小）。
var ui_font_scale: float:
	get:
		return _settings.ui_font_scale if _settings != null else 1.0
	set(value):
		if _settings != null:
			_settings.set_ui_font_scale(value)

var paragraph_spacing_enabled: bool:
	get:
		return _settings.paragraph_spacing_enabled if _settings != null else true
	set(value):
		if _settings != null:
			_settings.set_paragraph_spacing_enabled(value)

var paragraph_indent_enabled: bool:
	get:
		return _settings.paragraph_indent_enabled if _settings != null else true
	set(value):
		if _settings != null:
			_settings.set_paragraph_indent_enabled(value)

## 地图国界粗细（像素采样范围）。
var map_border_width: float:
	get:
		return _settings.map_border_width if _settings != null else 3.0
	set(value):
		if _settings != null:
			_settings.set_map_border_width(value)

var map_color_preset: int:
	get:
		return _settings.map_color_preset if _settings != null else 0
	set(value):
		if _settings != null:
			_settings.set_map_color_preset(value)

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

const TICK_INTERVALS: Array[float] = [0.0, 1.0, 0.5, 0.25, 0.05]
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
	PoliticianSystem.configure_callbacks(_notify_stats, is_mao_dead, is_mao_protected)
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


func _migrate_legacy_oil_modifier() -> void:
	if world == null or world.modifiers.size() <= 51 or world.modifiers[51] == null:
		return
	# 早期 Godot 档漏激活 51「黑金/OIL_MONEY」；原版在 dlc[3] 环境开局恒激活。
	# 读档补齐，否则石油决议、石油经济和 event_418 黑金事件全部被卡死。
	world.modifiers[51].is_active = true
	if world.modifiers[51].level <= 0:
		world.modifiers[51].level = 1


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


# ── 作弊快捷键（仅沙盒难度生效）──

func get_cheat_hotkey_key(action: String) -> int:
	return _settings.get_cheat_hotkey_key(action) if _settings != null else 0


func get_cheat_hotkey_label(action: String) -> String:
	return _settings.get_cheat_hotkey_label(action) if _settings != null else "未设置"


func rebind_cheat_hotkey(action: String, physical_keycode: int) -> void:
	if _settings != null:
		_settings.rebind_cheat_hotkey(action, physical_keycode)


func set_debug_console_enabled(value: bool) -> void:
	if _settings != null:
		_settings.set_debug_console_enabled(value)


func set_debug_console_toggle_key(physical_keycode: int) -> void:
	if _settings != null:
		_settings.set_debug_console_toggle_key(physical_keycode)


func set_events_enabled(value: bool) -> void:
	if _settings != null:
		_settings.set_events_enabled(value)


func set_event_text_alignment(value: int) -> void:
	if _settings != null:
		_settings.set_event_text_alignment(value)


func set_event_desc_font_size(value: int) -> void:
	if _settings != null:
		_settings.set_event_desc_font_size(value)


func set_event_option_font_size(value: int) -> void:
	if _settings != null:
		_settings.set_event_option_font_size(value)


func set_event_result_font_size(value: int) -> void:
	if _settings != null:
		_settings.set_event_result_font_size(value)


func set_ui_font_scale(value: float) -> void:
	if _settings != null:
		_settings.set_ui_font_scale(value)


func set_paragraph_spacing_enabled(value: bool) -> void:
	if _settings != null:
		_settings.set_paragraph_spacing_enabled(value)


func set_paragraph_indent_enabled(value: bool) -> void:
	if _settings != null:
		_settings.set_paragraph_indent_enabled(value)


func set_map_border_width(value: float) -> void:
	if _settings != null:
		_settings.set_map_border_width(value)


func set_map_color_preset(value: int) -> void:
	if _settings != null:
		_settings.set_map_color_preset(value)


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


## 设置界面“恢复默认”：一次性还原全部持久化设置并应用快捷键。
func reset_settings() -> void:
	if _settings != null:
		_settings.reset_to_defaults()
	if world != null:
		world.difficulty = 2


## 原作 savePlace 编号 5=成就位；本端口存档槽 0=成就位、1-4=普通位。
func autosave_slot() -> int:
	return _settings.autosave_slot() if _settings != null else 0


## 原作 TimeScript.cs:6021-6030：autosavej==1 在 data.day==1（每月 1 日），
## autosavej==2 在 data.day==1 且 data.month%6==0（1 日且 6/12 月）自动写当前 savePlace。
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
	PoliticianSystem.set_world(world)
	PoliticianSystem.sync_in_power_flags(world)
	PoliticianPool.current_world = world
	DecisionSystem.current_world = world
	ModifierCatalog.current_world = world
	DecisionAtoms.current_world = world
	if _fortnight_service != null:
		_fortnight_service.configure(self, world)
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
		PoliticianSystem.set_world(world)
		PoliticianSystem.sync_in_power_flags(world)
		PoliticianPool.current_world = world
		DecisionSystem.current_world = world
		ModifierCatalog.current_world = world
		DecisionAtoms.current_world = world
		if _fortnight_service != null:
			_fortnight_service.configure(self, world)
		if EventEngine:
			EventEngine.world = world
		if _map_service:
			_map_service.world = world
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
		# 旧档兼容：早期档漏激活 51 黑金/OIL_MONEY，读档补齐以解锁石油经济。
		_migrate_legacy_oil_modifier()
		# 旧档兼容：补建魁北克/南墨西哥虚拟国（新档在 WorldFactory 中已生成）。
		WF.ensure_fictional_countries(world)
		reset_map_runtime_state()
		# 运行时缓存不序列化，读档后重建
		world.rebuild_gwcode_index()
		world.sync_economy()
		world.ensure_rng()  # 从 rng_seed + rng_state 恢复随机流位置
		# 读档后清洗旧版本存档中可能残留的越界美苏影响力/关系，
		# 避免概览页直接显示 int32 回绕脏值（合法内部区间 [0, 1000]）。
		world.clamp_empire_relations()
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
	_sync_faction_numbers_from_ideology(world, world)
	_update_political_line(world, world)
	_update_displays(world)
	_political_system_recalc(world, world)
	_plot_player_cause(world, world)
	_check_daily_conspiracy(world)
	_daily_science_gen(world)
	_daily_finland_linkage(world)
	if world.date.month != old_month:
		_on_month_changed()

	# 原版 data.day % 7 == 0：已结盟派系 ideology 增长，并扣预算/特工。
	if world.date.day % 7 == 0:
		_weekly_ally_upkeep(world, world)

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
	# 月度同步原版 UpdateMap 的地图合并规则（金马澎/藏南/蒙古/也门/朝鲜等）
	if _map_service != null:
		_map_service.sync_map_merges()
	date_changed.emit(world.date)
	stats_changed.emit()
	# 原作自动存档在月块末尾（TimeScript.cs:6021-6030），所有月度效果结算后再写。
	_check_autosave()


## GameDate 是日期权威源；原版公式/事件仍通过 data.get_data_by_index(19..21) 读日期。
func _sync_date_to_data(w: WorldState) -> void:
	if w == null or w.date == null or w.size() <= W.I_YEAR:
		return
	w.day = w.date.day
	w.month = w.date.month
	w.year = w.date.year


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
	#     不是数值表 data.global_influence（全球影响力）。
	# 注2：进口需求沿用本移植既有换算（原版 -15/-10 → 本端口 -3/-2）；
	#     该单位问题（原版显示 /5，本端口显示 /10）与本次航天科技无关，另立步修正。
	# 注3：原版 3/6/7 号还会往 old_modify_desc[15] 追加描述文案，
	#     本端口没有对应文案存储，暂不移植。
	var d := world
	if tech_id == 0:
		d.import_needs -= 3
	elif tech_id == 1:
		d.import_needs -= 2
	elif tech_id == 2:
		world.influence_prc += 10
	elif tech_id == 3:
		d.import_needs -= 3
	elif tech_id == 4:
		d.import_needs -= 2
	elif tech_id == 6:
		pass  # 原版仅追加 old_modify_desc 文案，数值表无变化
	elif tech_id == 7:
		d.import_needs -= 2
	elif tech_id == 10:
		d.import_needs -= 2
		world.influence_prc += 5
	elif tech_id == 12:
		d.import_needs -= 2
	elif tech_id == 13:
		d.import_needs -= 2
	elif tech_id == 14:
		d.import_needs -= 2
	elif tech_id == 23:
		world.influence_prc += 5
	elif tech_id == 28:
		d.import_needs -= 2
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
## 用户口径：中央三职（总理/军委/外交）与地方主管（北京/华北/华西/华南/华东）
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
	# 显示前动态文案钩子（原版 Event18 战争结算等按 data.war_resolve 动态生成标题/描述/按钮）
	if event_def.display_script != null:
		var display_inst: RefCounted = event_def.display_script.new()
		if display_inst != null and display_inst.has_method("prepare"):
			display_inst.prepare(event_def, world)
	pause()
	# 防止 ESC 菜单暂停状态被带进事件场景：事件场景自身可交互，进入前先解除全局暂停
	if get_tree() != null:
		get_tree().paused = false
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
	var d := world
	if d.party_system <= 7:
		return false
	if world.get_flag("manual_election_used"):
		return false
	world.set_flag("manual_election_used", true)
	d.budget -= 10  # 原版 data.budget -= 10
	d.election_timer = 1           # 原版 data.election_timer = 1（Godot 未映射语义，保留槽位）
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
	if world == null or world.size() <= W.I_RESERVE:
		return false
	return world.budget + world.reserve >= 0


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
#   [2] 派系/路线领导：一党制(data.party_system≤7)看政治路线 data.political_line；多党看 data.econ_display/data.political_display+联盟席位>66%
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

## UI/事件脚本统一状态写入命令：避免界面直接改 WorldState 字段。
## 这些方法只做“改状态 + 通知刷新”，规则校验仍由对应 Service/调用方负责。

func add_influence_prc(delta: int) -> void:
	if world == null:
		return
	world.influence_prc += delta


func add_people_support(delta: int) -> void:
	if world == null:
		return
	world.people_support += delta


func add_party_support(delta: int) -> void:
	if world == null:
		return
	world.party_support += delta


func add_agents(delta: int) -> void:
	if world == null:
		return
	world.agents += delta


func add_budget(delta: int) -> void:
	if world == null:
		return
	world.budget += delta


func add_army(delta: int) -> void:
	if world == null:
		return
	world.army += delta


func add_thought_freedom(delta: int) -> void:
	if world == null:
		return
	world.thought_freedom += delta


func add_political_repression_count(delta: int) -> void:
	if world == null:
		return
	world.political_repression_count += delta


func set_politician_killed_flag(position: int) -> void:
	if world == null:
		return
	match position:
		0:
			world.killed_premier_flag = 9
		1:
			world.killed_military_flag = 9
		2:
			world.killed_foreign_flag = 9


func apply_research_cost(money_cost: int) -> void:
	if world == null:
		return
	world.science = 0
	world.budget -= money_cost


## 国家/帝国/政治家对象写入命令：避免 UI 直接修改领域对象字段。

func set_country_tag(country: CountryData, tag: String, value: bool) -> void:
	if country != null:
		country.set_tag(tag, value)


func set_country_influence(country: CountryData, field: String, value: int) -> void:
	if country == null:
		return
	match field:
		"prc":
			country.prc_influence = value
		"sov":
			country.sov_influence = value
		"usa":
			country.usa_influence = value
		"fre":
			country.fre_influence = value


func set_country_social_stability(country: CountryData, value: int) -> void:
	if country != null:
		country.social_stability = value


func add_empire_power(empire: EmpireData, delta: int) -> void:
	if empire != null:
		empire.power = clampi(empire.power + delta, 0, 1000)


func add_empire_relations(empire: EmpireData, delta: int) -> void:
	if empire != null:
		empire.relations += delta


func add_politician_power(pol: PoliticianData, delta: int) -> void:
	if pol != null:
		pol.power += delta


## 政治家对象写入命令：避免 UI 直接修改 PoliticianData 字段。

func add_politician_loyalty(pol: PoliticianData, delta: int) -> void:
	if pol != null:
		pol.loyalty += delta


func set_politician_you_fall(pol: PoliticianData, value: bool) -> void:
	if pol != null:
		pol.you_fall = value


func set_politician_investigation(pol: PoliticianData, value: bool) -> void:
	if pol != null:
		pol.is_under_investigation = value


func set_politician_investigator(pol: PoliticianData, value: int) -> void:
	if pol != null:
		pol.investigator_index = value


func set_politician_surveillance(pol: PoliticianData, value: bool) -> void:
	if pol != null:
		pol.is_under_surveillance = value


func set_politician_surveillance_days(pol: PoliticianData, value: int) -> void:
	if pol != null:
		pol.days_surveillance = value


func toggle_politician_auto_support(pol: PoliticianData) -> void:
	if pol == null:
		return
	pol.auto_support = 10 if pol.auto_support == 0 else 0


func toggle_politician_auto_hound(pol: PoliticianData) -> void:
	if pol == null:
		return
	pol.auto_hound = 10 if pol.auto_hound == 0 else 0


func assign_leader_cmc() -> void:
	if world == null:
		return
	var prev: int = world.politics_positions[1]
	if prev >= 0 and prev < world.politicians.size():
		add_politician_loyalty(world.politicians[prev], -1000)
	world.politics_positions[1] = -2
	for i in range(3, world.politics_positions.size()):
		if world.politics_positions[i] == -2:
			world.politics_positions[i] = -1


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
	if w == null or w.size() <= 29:
		return
	var d := w
	if w.empires.size() > 0 and w.empires[0] != null:
		d.usa_relations = w.empires[0].relations
		d.usa_influence = w.empires[0].power
	if w.empires.size() > 1 and w.empires[1] != null:
		d.ussr_relations = w.empires[1].relations
		d.soviet_influence = w.empires[1].power



# ============================================================================
# 月度模拟循环 — 移植自 TimeScript.InfluenceFromInvestments + QueryChina
# ============================================================================

func _on_month_changed() -> void:
	var w := world
	if w == null:
		return
	w.set_flag("manual_election_used", false)  # 原版月块 is_elect=false（TimeScript.cs:505-512）
	var d := w
	# 原版 54 号事件触发就是 TimeScript.cs:10425 的 ev45 && data.econ_system>11，无 6 个月延迟；
	# 早期误加的 investment_delay 等待已移除（trigger 在 event_054*.tres 里对齐）。
	# TimeScript.cs:1925：中国 level_of_unstab 月块重置（原版在 data.day==1 月块内，非每日）。
	var china_unstab := w.get_country_by_legacy_index(1)
	if china_unstab != null:
		china_unstab.level_of_instability = 10
	# 原版 926-954 的各国 stab/cw 重置属于 1 月 1 日年块，已移至 _on_year_changed。
	# 916-954 年块维护在 _yearly_jan1_maintenance；955-1048 RIM 日块在 _daily_rim_and_alliance_checks；
	# 本函数保留季度/半年度条件与 1689+ 月维护。
	_monthly_rim_and_alliance_cleanup(w)
	# 原版月块（data.day==1）行序：1682-2565 已由 _monthly_rim_and_alliance_cleanup 及其子函数执行；
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
	var d := w
	var china := w.get_country_by_legacy_index(1)

	# 957-983：RIM（革命国际）条件退出。
	var rim_exit := china != null and china.has_tag("rim") and (
		w.is_socialism(china, false)
		or not _mod_active(w, GameConstants.Modifier.CULTURAL_REVOLUTION)
		or not _mod_active(w, GameConstants.Modifier.MAOIST_BULWARK)
		or d.party_system > 7
		or d.econ_system > 12
		or d.religion_policy > 25
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
			if c.has_tag("rim") and c.puppet_of != GameConstants.LegacySlot.CHINA:
				c.set_tag("亲中", false)
				c.set_tag("对华贸易", false)
				c.set_tag("econ", false)
				c.set_tag("okb", false)
			elif c.puppet_of == GameConstants.LegacySlot.CHINA:
				c.set_tag("rim", false)

	# 984-1000：事件713后革命国际扩张/清理。
	if w.event_done_num(713):
		for c in w.countries:
			if c == null:
				continue
			if (c.sub_government == GameConstants.SubGovernment.MAOIST or c.sub_government == GameConstants.SubGovernment.MARXIST_LENINIST) and c.原版序号 != GameConstants.LegacySlot.CHINA \
					and c.puppet_of != GameConstants.LegacySlot.CHINA and not c.has_tag("亲苏") and not c.has_tag("亲美") \
					and not c.has_tag("sev") and not c.has_tag("ovd") and not c.has_tag("rim"):
				c.set_tag("亲中", false)
				c.set_tag("对华贸易", false)
				c.set_tag("econ", false)
				c.set_tag("okb", false)
				c.set_tag("rim", true)
			elif c.原版序号 == GameConstants.LegacySlot.CHINA or c.puppet_of == GameConstants.LegacySlot.CHINA:
				c.set_tag("rim", false)

	# 993-999：阿尔巴尼亚(20)亲中条件退出（cond_full 含 data.econ_display>36）。
	var cond_soft := d.ideology > 3 or d.party_system > 7 \
		or d.econ_system > 13 or d.religion_policy > 28 \
		or (china != null and china.has_tag("seato"))
	var cond_full := cond_soft or d.econ_display > 36
	var albania := w.get_country_by_legacy_index(20)
	if albania != null and d.albania_break == 0 and albania.has_tag("亲中") and cond_full:
		albania.set_tag("亲中", false)
		albania.set_tag("对华贸易", false)
		albania.set_tag("econ", false)
		albania.set_tag("okb", false)

	# 1000-1015：全部国家——sub==17 用 cond_soft、sub==0 用 cond_full 退亲中；
	# AU 国家在更宽条件下退出亲中/对华贸易/econ/okb 并扣影响力。
	# 注：原版 TimeScript.cs:1014 循环体内还有一句 num10++（与 for 头叠加，实际只处理偶数序号），
	# 判定为反编译噪音/原版笔误，本项目按“遍历全部国家”执行。
	var cond_au := cond_soft or _country_tag(w, 51, "对华贸易") \
		or _country_dev_is(w, 51, 1) or not _mod_active(w, GameConstants.Modifier.MAOIST_BULWARK)
	for c in w.countries:
		if c == null:
			continue
		if c.原版序号 != GameConstants.LegacySlot.CHINA and c.has_tag("亲中"):
			if c.sub_government == GameConstants.SubGovernment.MAOIST and cond_soft:
				c.set_tag("亲中", false)
			elif c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and cond_full:
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
			and c24.government == GameConstants.Government.SOCIALIST and c24.has_tag("亲中") and cond_full:
		c24.set_tag("亲中", false)

	# 1020-1023：阿尔巴尼亚 econ/okb 残留清理。
	if albania != null and d.albania_break == 0 and not albania.has_tag("亲中") \
			and (albania.has_tag("econ") or albania.has_tag("okb")):
		albania.set_tag("econ", false)
		albania.set_tag("okb", false)

	# 1025：ExportValue 每日重算（原版日块；完整 400 行版见 Phase 2，当前用核心版）。
	_recalc_export_value(d, w)

	# 1026-1029：多党制下 data.election_timer==4 的选举余波清空。
	if d.party_system > 7 and d.size() > 125 and d.election_timer == 4:
		d.election_timer = 0

	# 1028-1039：菲律宾(47)影响力达标时转亲中并触发事件441。
	if d.philippines_maoist_power >= 1000:
		var c47 := w.get_country_by_legacy_index(47)
		if c47 != null and not c47.has_tag("亲中") and not w.event_done_num(441):
			c47.set_tag("亲中", true)
			c47.government = GameConstants.Government.SOCIALIST
			c47.set_tag("asean", false)
			c47.sub_government = GameConstants.SubGovernment.MAOIST
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
			and ((not w.is_socialism(c149, true) and c149.government != GameConstants.Government.REFORMIST \
				and c149.level_of_instability >= 500) \
				or ((w.is_socialism(c149, true) or c149.government == GameConstants.Government.REFORMIST) \
				and c149.level_of_instability < 500)):
		WAR_SYS.start_war(64, "军政府", "URNG", 500, 500, 0, 1)
		var war := _war_idx(w, 64)
		if war != null:
			war.name_war = "危地马拉内战"
			war.fortnight_max = 24
		_set_country_part(c149, 1, true)
	var c147 := w.get_country_by_legacy_index(147)
	if c147 != null and not _war_going_idx(w, 67) \
			and (w.is_socialism(c147, true) or c147.government == GameConstants.Government.REFORMIST) \
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
			w.empires[EmpireData.USSR].power = clampi(w.empires[EmpireData.USSR].power - 50, 0, 1000)
		var china_fin := w.get_country_by_legacy_index(1)
		if china_fin != null and w.is_socialism(china_fin, true):
			finland.government = GameConstants.Government.SOCIALIST
			finland.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		elif china_fin != null and china_fin.government == GameConstants.Government.REFORMIST:
			finland.government = GameConstants.Government.REFORMIST
			finland.sub_government = GameConstants.SubGovernment.PRAGMATIST
		elif china_fin != null and china_fin.government == GameConstants.Government.LIBERAL:
			finland.government = GameConstants.Government.LIBERAL
			finland.sub_government = GameConstants.SubGovernment.MODERATE
		else:
			finland.government = GameConstants.Government.AUTHORITARIAN
			finland.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN


## TimeScript.cs:1490-1634 / 1636-1648 / 1689-2089：季度、半年度与月维护。
## 注：916-954（政变/stab/war_active 重置）是 1 月 1 日年块，已移 _yearly_jan1_maintenance；
## 955-1048 是日块，已移 _daily_rim_and_alliance_checks；1648-1679 北欧联动也是日块。
func _monthly_rim_and_alliance_cleanup(w: WorldState) -> void:
	var d := w
	var china := w.get_country_by_legacy_index(1)

	# 1490-1634：每季度 1 日维护（data.day==1 && data.month%3==0）。
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
		# 事件677/678 未完成且国家29/166未分立时，按结果给 data.get_data_by_index(162..165) 各最多+1。
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
				if slot < d.size() and d.get_data_by_index(slot) <= 100:
					d.add_data_by_index(slot, 1)

	# 1636-1648：每半年 1 日维护（data.day==1 && data.month%6==0）。
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
			and (w.date.month == d.election_month_first or w.date.month == d.election_month_second):
		w.set_flag("bad_done", false)

	# 1689-1740：月维护计时器与决议清理。
	if d.size() > 44 and d.iran_democrat_support > 0:
		d.iran_democrat_support -= 1
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
		if slot < d.size() and d.get_data_by_index(slot) > 0:
			d.add_data_by_index(slot, -(1))
	# 原版 TimeScript.cs:1896-1898 仅当 data.support_sent_flag > 0 时清零。
	if d.support_sent_flag:
		d.support_sent_flag = false
	if china != null and china.has_tag("ovd") and china.has_tag("seato"):
		if d.size() > 142:
			d.alliance_coercion_target = 0
			d.alliance_coercion_progress = 0

	# 1980-1995：帝国资金换油价冷却。
	if w.empires.size() > 1 and w.empires[1] != null \
			and w.empires[1].money >= 200 and (d.size() <= 150 or d.soviet_intervention_cooldown <= 0) \
			and w.empires[1].power - 200 >= (w.empires[0].power if w.empires.size() > 0 else 0) \
			and w.empires[1].power - 200 >= w.influence_prc and d.oil_price < 50:
		w.empires[1].money -= 200
		d.oil_price += 1
		d.soviet_intervention_cooldown = 6
	if w.empires.size() > 0 and w.empires[0] != null \
			and w.empires[0].money >= 200 and (d.size() <= 151 or d.usa_intervention_cooldown <= 0) \
			and w.empires[0].power - 200 >= (w.empires[1].power if w.empires.size() > 1 else 0) \
			and w.empires[0].power - 200 >= w.influence_prc and d.oil_price > 10:
		w.empires[0].money -= 200
		d.oil_price -= 1
		d.usa_intervention_cooldown = 6

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

	# 1770-1881 事件686 月块（事件686 后欧洲中立国苏联影响力累积/芬兰分支）。
	_monthly_finland_linkage(w)
	# 1898-1917：乌干达事件659/661 月块推进与开战。
	_monthly_uganda_linkage(w, d)
	# 3302-3340：安哥拉事件638 后三方势力月度增长与内战 68 自动爆发。
	_monthly_angola_linkage(w)
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
func _monthly_ejection_and_misc(w: WorldState, d: WorldState) -> void:
	var china := w.get_country_by_legacy_index(1)

	# 2299-2325：data.foreign_aid 外援消耗与贸易同盟国家影响。
	if d.size() > W.I_FOREIGN_AID and d.foreign_aid > 0:
		d.budget -= d.foreign_aid
		d.agents -= d.foreign_aid
		d.army -= d.foreign_aid
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
		if greece != null and greece.government == GameConstants.Government.LIBERAL:
			greece.set_tag("eu", true)
			if w.empires.size() > 0 and w.empires[0] != null:
				w.empires[0].power = clampi(w.empires[0].power + 10, 0, 1000)

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
			w.empires[0].power = clampi(w.empires[0].power + 10, 0, 1000)
		if britain != null:
			britain.sub_government = GameConstants.SubGovernment.NEOLIBERAL

	# 2356-2361：modifies[41] 停用条件。
	if d.diplomatic_reputation >= 850 or (d.size() > 131 and (d.world_political_balance == 1 or d.world_political_balance == 2)):
		w.modifiers[41].is_active = false
	var egypt41 := w.get_country_by_legacy_index(30)
	if egypt41 != null and not egypt41.has_tag("亲美"):
		w.modifiers[41].is_active = false
	var iran41 := w.get_country_by_legacy_index(8)
	if iran41 != null and (iran41.government == GameConstants.Government.SOCIALIST or iran41.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN):
		w.modifiers[41].is_active = false
	if china != null and china.has_tag("sev"):
		w.modifiers[41].is_active = false

	# 2362-2377：东德(16)/西德(17) 对华贸易与 modifies[53] 停用。
	var east_germany := w.get_country_by_legacy_index(16)
	var west_germany := w.get_country_by_legacy_index(17)
	if east_germany != null and east_germany.has_tag("亲苏") \
			and (china == null or china.government != GameConstants.Government.SOCIALIST or china.has_tag("asean") or not w.get_flag("relres")):
		w.modifiers[53].is_active = false
		east_germany.set_tag("对华贸易", false)
	if east_germany != null and east_germany.has_tag("亲中") \
			and (china == null or china.government != GameConstants.Government.SOCIALIST or china.has_tag("asean")):
		w.modifiers[53].is_active = false
		east_germany.set_tag("对华贸易", false)
	if west_germany != null and west_germany.parts.size() > 0 and west_germany.parts[0] \
			and west_germany.government == GameConstants.Government.SOCIALIST \
			and (china == null or china.government != GameConstants.Government.SOCIALIST or china.has_tag("asean")):
		w.modifiers[53].is_active = false
		west_germany.set_tag("对华贸易", false)

	# 2378-2385：中国非 SEV 时，东欧 2..6 亲苏国取消对华贸易。
	if china != null and not china.has_tag("sev"):
		for legacy_idx in range(2, 7):
			var c_ee := w.get_country_by_legacy_index(legacy_idx)
			if c_ee != null and c_ee.has_tag("亲苏"):
				c_ee.set_tag("对华贸易", false)

	# 2386-2391：英国社会主义时巴基斯坦/伊朗退出 SENTO。
	if britain != null and (britain.government == GameConstants.Government.SOCIALIST or britain.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST):
		for legacy_idx in [31, 8]:
			var c_sento := w.get_country_by_legacy_index(legacy_idx)
			if c_sento != null:
				c_sento.set_tag("sento", false)

	# 2392-2470：data.alliance_kickout_timer 递减与被美苏逐出联盟。
	if d.size() > 139 and d.alliance_kickout_timer > 0:
		d.alliance_kickout_timer -= 1
	var is_sev := china != null and china.has_tag("sev")
	var is_asean := china != null and china.has_tag("asean")
	var evict_pre := (d.size() > 140 and d.alliance_kickout_type <= 0) \
		and ((not _mod_active(w, GameConstants.Modifier.SOVIET_EMBARGO) and is_sev) or (not _mod_active(w, GameConstants.Modifier.USA_EMBARGO) and is_asean))
	var evict_bad := (d.size() > 140 and d.alliance_kickout_timer > 0) and (
		(d.alliance_kickout_type == 1 and is_sev and china.government != GameConstants.Government.LIBERAL and d.econ_display != 37)
		or (d.alliance_kickout_type == 2 and is_asean and china.government != GameConstants.Government.SOCIALIST and d.econ_display != 34)
	)
	if (evict_pre or evict_bad) and d.size() > 139 and d.alliance_kickout_timer > 0:
		d.alliance_kickout_timer = 0
	var do_evict := d.size() > 139 and d.alliance_kickout_timer <= 0 and (
		(is_sev and _mod_active(w, GameConstants.Modifier.SOVIET_EMBARGO) and (d.size() <= 140 or d.alliance_kickout_type <= 0))
		or (is_asean and _mod_active(w, GameConstants.Modifier.USA_EMBARGO) and (d.size() <= 140 or d.alliance_kickout_type <= 0))
		or (d.size() > 140 and d.alliance_kickout_type > 0)
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
			d.alliance_kickout_type = 0
		if d.restore_agent_mod_47:
			w.modifiers[47].is_active = true
			d.restore_agent_mod_47 = false
		if d.restore_agent_mod_48:
			w.modifiers[48].is_active = true
			d.restore_agent_mod_48 = false
		if d.size() > 139:
			d.alliance_kickout_timer = 0
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
					w.empires[0].power = clampi(w.empires[0].power - 5, 0, 1000)
			else:
				c.set_tag("ovd", false)
				c.set_tag("sev", false)
				if w.empires.size() > 1 and w.empires[1] != null:
					w.empires[1].power = clampi(w.empires[1].power - 5, 0, 1000)
		if d.restore_econ_alliance:
			d.restore_econ_alliance = false
			for c in w.countries:
				if c != null and c.has_tag("亲中"):
					c.set_tag("econ", true)
		if d.restore_okb_alliance:
			d.restore_okb_alliance = false
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
			w.empires[0].power = clampi(w.empires[0].power + 10, 0, 1000)
		var france83 := w.get_country_by_legacy_index(21)
		if france83 != null:
			france83.sub_government = GameConstants.SubGovernment.NEOLIBERAL

	# 2476-2494：苏联加入北约时按外交标记改战争阵营。
	var ussr_nato := w.get_country_by_legacy_index(7)
	if ussr_nato != null and ussr_nato.has_tag("nato"):
		for i in w.wars.size():
			var war_nato: WarData = w.wars[i]
			if war_nato == null or not war_nato.is_going or i == 5:
				continue
			if war_nato.diplo_done[0]:
				war_nato.usa_side = GameConstants.WarSide.SIDE2
				war_nato.ussr_side = GameConstants.WarSide.SIDE2
			elif war_nato.diplo_done[1]:
				war_nato.usa_side = GameConstants.WarSide.SIDE1
				war_nato.ussr_side = GameConstants.WarSide.SIDE1

	# 2495-2502：1977 年后西班牙/葡萄牙自由化（原版 !dlc[3] 分支；Godot 改版 dlc[3]=true 全免费 → 不执行）。
	if w.date.year > 1976 and not w.dlc[3]:
		var portugal := w.get_country_by_legacy_index(87)
		if portugal != null:
			portugal.sub_government = GameConstants.SubGovernment.LIBERAL
			portugal.government = GameConstants.Government.LIBERAL
		var spain := w.get_country_by_legacy_index(86)
		if spain != null:
			spain.sub_government = GameConstants.SubGovernment.MODERATE
			spain.government = GameConstants.Government.LIBERAL

	# 2503-2509：dlc[3] 分支（Godot 改版 dlc[3]=true 全免费 → 执行）。
	# 原版：1984 年土耳其 sub==7 时改开化（SubGosstroy=6、Gosstroy=3）。
	if w.dlc[3]:
		var turkey84 := w.get_country_by_legacy_index(84)
		if turkey84 != null and turkey84.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN and w.date.year == 1984:
			turkey84.sub_government = GameConstants.SubGovernment.LIBERAL
			turkey84.government = GameConstants.Government.LIBERAL

	# 2510-2550：OAR 成立后阿拉伯国家退出其它联盟。
	if w.oar:
		var egypt_oar := w.get_country_by_legacy_index(30)
		if egypt_oar == null or egypt_oar.government == GameConstants.Government.SOCIALIST:
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
		if spain_nato != null and spain_nato.sub_government == GameConstants.SubGovernment.MODERATE:
			spain_nato.set_tag("nato", true)

	# 2556-2564：土耳其 sub==9 改名（new_events_text[784] 建模说明 → 跳过）。
	# DaysInSouthAmerica 建模说明 → 跳过（项目月块不处理南美选举漂移）。


## TimeScript.cs:1770-1881 事件686 月块：对西欧/北欧中立国进行苏联影响力累积，
## 达到 1000 后苏联化（based/亲苏/加入经互会华约），并处理芬兰(26)特殊分支。
## （1648-1679 三国 econ+okb 转亲中分支是日块，已移 _daily_finland_linkage。）
func _monthly_finland_linkage(w: WorldState) -> void:
	if not w.event_done_num(686):
		return
	var spain_eu := w.get_country_by_legacy_index(85)
	var france_fx := w.get_country_by_legacy_index(21)
	if spain_eu != null and spain_eu.has_tag("soc_eu"):
		return
	if france_fx != null and (france_fx.has_tag("fxseu") or france_fx.has_tag("nazimao")):
		return

	var gdr := w.get_country_by_legacy_index(7)
	var ussr_leader := -1
	if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
		ussr_leader = w.empires[EmpireData.USSR].current_leader

	var neutral_indices: Array[int] = [0, 27, 28, 88, 89, 90, 91]
	var pro_sov_indices: Array[int] = [21, 85, 86, 87, 92]
	for idx in neutral_indices:
		var c := w.get_country_by_legacy_index(idx)
		if c == null:
			continue
		c.stab = 0
		c.special = 0
		if not c.has_tag("okb") and not c.有驻军基地 and not c.has_tag("rim"):
			if c.sov_power < 1000:
				c.sov_power += 10
				if ussr_leader == 3 or ussr_leader == 4:
					c.sov_power += 10
				if gdr != null and gdr.has_tag("sev"):
					c.sov_power += 20
				if gdr != null and gdr.has_tag("ovd"):
					c.sov_power += 20
				for pro_idx in pro_sov_indices:
					var p := w.get_country_by_legacy_index(pro_idx)
					if p != null and (p.has_tag("亲苏") or p.has_tag("sev")):
						c.sov_power += 10
				if c.has_tag("econ"):
					c.sov_power -= 30
			if c.sov_power >= 1000:
				c.sov_power = 1000
				c.有驻军基地 = true
				c.prc_power = 0
				if ussr_leader == 6:
					c.government = GameConstants.Government.REFORMIST
					c.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
				else:
					c.government = GameConstants.Government.SOCIALIST
					c.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				c.set_tag("亲苏", true)
				c.set_tag("亲中", false)
				c.set_tag("econ", false)
				c.set_tag("对华贸易", false)
				if gdr != null and gdr.has_tag("sev"):
					c.set_tag("sev", true)
				if gdr != null and gdr.has_tag("ovd"):
					c.set_tag("ovd", true)
		elif c.has_tag("okb") and not c.有驻军基地:
			c.sov_power = 0

	# 芬兰：瑞典/丹麦/挪威都已苏联化后，芬兰自动转亲苏（1860-1890）。
	var sweden := w.get_country_by_legacy_index(28)
	var denmark := w.get_country_by_legacy_index(90)
	var norway := w.get_country_by_legacy_index(91)
	var finland := w.get_country_by_legacy_index(26)
	if sweden != null and sweden.有驻军基地 and denmark != null and denmark.有驻军基地 \
			and norway != null and norway.有驻军基地 and finland != null and not finland.有驻军基地:
		if ussr_leader == 6:
			finland.government = GameConstants.Government.REFORMIST
			finland.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
		else:
			finland.government = GameConstants.Government.SOCIALIST
			finland.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		finland.set_tag("亲中", false)
		finland.set_tag("亲苏", true)
		if gdr != null and gdr.has_tag("sev"):
			finland.set_tag("sev", true)
		if gdr != null and gdr.has_tag("ovd"):
			finland.set_tag("ovd", true)
		finland.有驻军基地 = true


## TimeScript.cs:1898-1917：乌干达(118) 事件659/661 月块推进与战争 81 触发。
func _monthly_uganda_linkage(w: WorldState, _d: WorldState) -> void:
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
			w.war_resolve = 81
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


## TimeScript.cs:3302-3340：安哥拉事件638 后，三方势力按美苏国力每月增长；
## 同时 TimeScript.cs:656-681 在一方达到 900 且另两方仍存在时自动爆发战争 68。
func _monthly_angola_linkage(w: WorldState) -> void:
	if not w.event_done_num(638):
		return
	var angola := w.get_country_by_legacy_index(123)
	if angola == null or angola.内战中:
		return
	if w.war_going(68):
		return
	var usa_power_emp: int = w.empires[EmpireData.USA].power \
		if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null else 0
	var ussr_power_emp: int = w.empires[EmpireData.USSR].power \
		if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null else 0

	# 月度势力增长（原版 3302/3324/3337）。
	if angola.prc_power > 0 and angola.prc_power < 900:
		if ussr_power_emp > 0:
			@warning_ignore("integer_division")
			angola.prc_power += ussr_power_emp * 3 / 100
		if w.result_of_event_num(638) == 0:
			angola.prc_power += 10
	if angola.sov_power > 0 and angola.sov_power < 900:
		if usa_power_emp > 0:
			@warning_ignore("integer_division")
			angola.sov_power += usa_power_emp * 3 / 100
		if w.result_of_event_num(638) == 1:
			angola.sov_power += 10
	if angola.usa_power > 0 and angola.usa_power < 900:
		if usa_power_emp > 0:
			@warning_ignore("integer_division")
			angola.usa_power += usa_power_emp * 3 / 100
		if w.result_of_event_num(638) == 2:
			angola.usa_power += 10

	# 自动开战（原版 TimeScript 656-681）。
	if angola.prc_power >= 900 and angola.sov_power > 0 and angola.usa_power > 0:
		angola.prc_power = 1000
		angola.sov_power = 0
		angola.usa_power = 0
		while angola.parts.size() <= 0:
			angola.parts.append(false)
		angola.parts[0] = true
		WAR_SYS.start_war(68, "安 人 运", "安 盟 - 安 解 阵", 700, 300,
			GameConstants.WarSide.SIDE2, GameConstants.WarSide.SIDE1)
	elif angola.sov_power >= 900 and angola.prc_power > 0 and angola.usa_power > 0:
		angola.sov_power = 1000
		angola.prc_power = 0
		angola.usa_power = 0
		while angola.parts.size() <= 0:
			angola.parts.append(false)
		angola.parts[0] = true
		WAR_SYS.start_war(68, "安 盟", "安 人 运", 600, 400,
			GameConstants.WarSide.SIDE1, GameConstants.WarSide.SIDE2)
	elif angola.usa_power >= 900 and angola.prc_power > 0 and angola.sov_power > 0:
		angola.usa_power = 1000
		angola.prc_power = 0
		angola.sov_power = 0
		while angola.parts.size() <= 0:
			angola.parts.append(false)
		angola.parts[0] = true
		WAR_SYS.start_war(68, "安 解 阵", "安 人 运 - 安 盟", 500, 500,
			GameConstants.WarSide.SIDE1, GameConstants.WarSide.SIDE2)


func _war_at_ensure(w: WorldState, idx: int) -> WarData:
	while w.wars.size() <= idx:
		w.wars.append(WarData.new())
	return w.wars[idx]


## TimeScript.cs:743-954：1 月 1 日年块（Repaint 内 data.day==1 && data.month==1）。
## 原版这些内容只在每年 1 月 1 日执行一次，不是月块。
func _yearly_jan1_maintenance(w: WorldState) -> void:
	var d := w
	var china := w.get_country_by_legacy_index(1)

	# 745-754：意大利(85)发展度年增，美苏花钱换 data.get_data_by_index(160/161)。
	var italy := w.get_country_by_legacy_index(85)
	if italy != null:
		italy.level_of_development += 10
		if italy.level_of_development >= 100:
			italy.level_of_development = 100
	if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null \
			and w.empires[EmpireData.USSR].money >= 200 and randi_range(0, 4) == 1:
		w.empires[EmpireData.USSR].money -= 100
		if d.size() > 160:
			d.soviet_money += 500
	if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null \
			and w.empires[EmpireData.USA].money >= 200 and randi_range(0, 4) == 1:
		w.empires[EmpireData.USA].money -= 100
		if d.size() > 161:
			d.usa_money += 500

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
		if w.is_socialism(c149, true) or c149.government == GameConstants.Government.REFORMIST:
			c149.level_of_instability -= 10
			for idx_vyshi in [141, 140, 148, 147, 146, 144]:
				var vc := w.get_country_by_legacy_index(idx_vyshi)
				if vc != null and vc.has_tag("亲美"):
					c149.level_of_instability -= 10
		for idx_soc in [147, 148]:
			var sc := w.get_country_by_legacy_index(idx_soc)
			if sc != null and (w.is_socialism(sc, true) or sc.government == GameConstants.Government.REFORMIST):
				c149.level_of_instability += 25
		for idx_pro in [138, 141]:
			var pc := w.get_country_by_legacy_index(idx_pro)
			if pc != null and pc.has_tag("亲中"):
				c149.level_of_instability += 25
	var c147 := w.get_country_by_legacy_index(147)
	if c147 != null and c147.level_of_instability > 0 and c147.level_of_instability < 1000:
		c147.level_of_instability += 10
		if w.is_socialism(c147, true) or c147.government == GameConstants.Government.REFORMIST:
			c147.level_of_instability -= 10
			for idx_vyshi in [141, 140, 148, 147, 146, 144]:
				var vc := w.get_country_by_legacy_index(idx_vyshi)
				if vc != null and vc.has_tag("亲美"):
					c147.level_of_instability -= 10
		for idx_soc in [149, 148]:
			var sc := w.get_country_by_legacy_index(idx_soc)
			if sc != null and (w.is_socialism(sc, true) or sc.government == GameConstants.Government.REFORMIST):
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
			if spain != null and spain.government == GameConstants.Government.LIBERAL:
				spain.join_eu()
			if portugal_eu != null and portugal_eu.government == GameConstants.Government.LIBERAL:
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
		if c != null and c.原版序号 != GameConstants.LegacySlot.SPAIN:
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

	# 952-954：满意现秩序者 data.satisfied 与派系 party_number 年 /=10。
	# Godot 侧由 _on_year_changed 随后对 factions.support 与 data.satisfied 执行同一衰减。


func _on_year_changed() -> void:
	var w := world
	if w == null:
		return
	var d := w
	# 原版 TimeScript.cs:500-501：年滚时抽两个“坏事件清空月”（1-6 / 7-12），供月块 bad_done 复位。
	if d.size() > 121:
		d.election_month_first = randi_range(1, 6)
		d.election_month_second = randi_range(7, 12)
	# 原版 TimeScript.cs:743-954：1 月 1 日年块维护。
	_yearly_jan1_maintenance(w)
	@warning_ignore("integer_division")
	# 派系 support 年度衰减（原版 party_number/=10）。
	# 注意：原版同 tick 稍后会用 ideology 重算 party_number，一党制下此衰减会被覆盖；
	# Godot 在 tick() 中同样先衰减、后 _sync_faction_numbers_from_ideology，保持一致。
	for f in w.factions:
		f.support = f.support / 10
	# 满意现秩序者衰减（原版 835 年 /=10）
	d.satisfied = d.satisfied / 10
	# 联合/人民民主(7/8) 额外腰斩（TimeScript 年滚 ~640）
	if d.satisfied > 1 and (d.party_system == 7 or d.party_system == 8):
		d.satisfied = d.satisfied / 2
	# 年度进口需求增量（原版 TimeScript.cs:514 data.import_needs += ImportChange；公式 GameState.cs:11-16）
	d.import_needs += w.import_change()
	# POL-05 / POL-12：年龄 +1、病弱/老死、任职年数（TimeScript 615–621 + DeathPolitics）
	POL_SYS.annual_politics(d, w)
	# 1980-01-01 成就检查（TimeScript.cs:687-696：人口>=10000 → Set(63)；
	# 工业/农业/服务业均>=700 → Set(62)；原作在 iron_and_blood 内，Achievements 内部有同守卫）。
	if w.date.year == 1980:
		if d.population >= 10000:
			Achievements.set_achievement(63)
		if d.industry >= 700 and d.agriculture >= 700 and d.services >= 700:
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
## 原版条件 data.reserve+(data.budget+data.reserve)>=0 即 2*reserve+budget>=0。
## 储备耗尽仍赤字时：speed=0 + 强制跳转经济界面（原版 goto_economy）。
func _daily_deficit_recovery(w: WorldState) -> void:
	var d := w
	if d.budget >= 0:
		return
	if d.reserve + (d.budget + d.reserve) >= 0:
		d.reserve += d.budget
		d.budget = 0
	else:
		d.budget += d.reserve
		d.reserve = 0
		if d.budget < 0:
			speed = 0
			is_playing = false
			call_deferred("_force_goto_economy")


# ── 每日：科研点生成（原版 1458-1488，日块）──
## data.science += data.budget_science/40；data.econ_system<=12 且事件92 时按 data.five_year_plan_focus 修正。
func _daily_science_gen(w: WorldState) -> void:
	var d := w
	d.science += d.budget_science / 40
	if d.econ_system <= 12 and w.event_done_num(92):
		match _dv(d, 102):
			1, 2, 3:
				d.science -= 1
			4:
				d.science += 1


# ── 每日：开放度→显示等级映射（原版 1136-1167，日块）──
func _update_displays(d: WorldState) -> void:
	if d.econ_openness <= 250: d.econ_display = 34
	elif d.econ_openness <= 500: d.econ_display = 35
	elif d.econ_openness <= 750: d.econ_display = 36
	else: d.econ_display = 37
	if d.political_openness <= 250: d.political_display = 38
	elif d.political_openness <= 500: d.political_display = 39
	elif d.political_openness <= 750: d.political_display = 40
	else: d.political_display = 41


# ── 月度：人口增长（原版 3038-3135，月块 data.day==1）──
func _monthly_population(d: WorldState, w: WorldState) -> void:
	var pop_base: int = d.birth_policy  # 人口增长基数（原版 data.birth_policy，开局=2）
	# 产值过低 → 人口下降
	if d.agriculture < 250:
		d.population -= 15
	elif d.agriculture < 410:
		d.population -= 8
	if d.services < 250:
		d.population -= 4
	if d.industry < 250:
		d.population -= 8
	elif d.industry < 410:
		d.population -= 4
	# 舆论政策 18/19 → 人口下降
	if d.press_policy == 18:
		d.population -= 4
	elif d.press_policy == 19:
		d.population -= 9
	# 宗教政策 28/29 → 人口增长
	if d.religion_policy == 28:
		d.population += pop_base
	elif d.religion_policy == 29:
		d.population += 2 * pop_base
	# 经济体制基于人口规模的影响
	if d.econ_system == 11 or d.econ_system == 10:
		d.industry += d.population / 5000
	elif d.econ_system == 14 and not _mod_active(w, GameConstants.Modifier.BOOMING_SMALL_BUSINESS):
		d.people_support -= d.population / 4000
	elif d.econ_system == 15 and not _mod_active(w, GameConstants.Modifier.BOOMING_SMALL_BUSINESS):
		d.people_support -= d.population / 4000
	# 生活水平 → 人口增长
	d.population += d.living_standard / 60 * pop_base
	# 意识形态/生活水平条件块
	if d.ideology <= 0 and d.living_standard <= 500:
		d.population += 6 * pop_base
	elif d.ideology <= 3 and d.living_standard <= 400:
		d.population += 2 * pop_base
	elif d.ideology == 4 and d.living_standard >= 850:
		d.population -= 11
	elif d.ideology == 4 and d.living_standard >= 650:
		d.population -= 9
	elif d.ideology == 5 and d.living_standard >= 850:
		d.population -= 13
	elif d.ideology == 5 and d.living_standard >= 650:
		d.population -= 11


# ── 月度：寡头成长（原版 2559-2850，月块 data.day==1）──
func _monthly_oligarch(d: WorldState, w: WorldState) -> void:
	var year: int = w.date.year
	var econ := d.econ_system
	if econ > 13:
		# econ == 14/15
		if econ == 14 and year < 1980:
			d.oligarch += 5
		elif econ == 14:
			d.oligarch += 1
		elif econ == 15 and year < 1980:
			d.oligarch += 10
		elif econ == 15:
			d.oligarch += 4
		if d.party_system <= 7:
			d.oligarch += 2
		elif d.party_system == 8:
			d.oligarch += 1
		elif d.party_system == 9:
			d.oligarch -= 1
		if d.press_policy <= 16:
			d.oligarch += 2
		elif d.press_policy == 17:
			d.oligarch += 1
		elif d.press_policy == 19:
			d.oligarch -= 1
		if d.territory_policy == 21:
			d.oligarch += 1
		elif d.territory_policy == 22:
			d.oligarch += 2
		elif d.territory_policy == 23:
			d.oligarch += 3
		if d.religion_policy == 24:
			d.oligarch += 1
		elif d.religion_policy == 25:
			d.oligarch -= 1
		elif d.religion_policy == 28:
			d.oligarch += 1
		elif d.religion_policy == 29:
			d.oligarch += 3
		if d.military_doctrine == 30:
			d.oligarch += 2
		elif d.military_doctrine == 31:
			d.oligarch += 1
		if _mod_active(w, GameConstants.Modifier.BLACK_CAT_WHITE_CAT):
			d.oligarch -= 1
		if _mod_active(w, GameConstants.Modifier.BOOMING_SMALL_BUSINESS):
			d.oligarch -= 2
		if _mod_active(w, GameConstants.Modifier.COMPROMISE_WITH_UNDERWORLD):
			d.oligarch += 3
	elif econ == 13:
		if year < 1980:
			d.oligarch += 1
		if d.party_system == 9:
			d.oligarch -= 1
		if d.press_policy == 19:
			d.oligarch -= 1
		if d.territory_policy == 21:
			d.oligarch += 1
		elif d.territory_policy == 22:
			d.oligarch += 2
		elif d.territory_policy == 23:
			d.oligarch += 3
		if d.religion_policy == 24:
			d.oligarch += 1
		elif d.religion_policy == 25:
			d.oligarch -= 1
		elif d.religion_policy == 28:
			d.oligarch += 1
		elif d.religion_policy == 29:
			d.oligarch += 3
		if _mod_active(w, GameConstants.Modifier.BLACK_CAT_WHITE_CAT):
			d.oligarch -= 1
		if _mod_active(w, GameConstants.Modifier.BOOMING_SMALL_BUSINESS):
			d.oligarch -= 2
		if _mod_active(w, GameConstants.Modifier.COMPROMISE_WITH_UNDERWORLD):
			d.oligarch += 3
	elif econ == 12:
		if d.oligarch > 50:
			d.party_support -= (d.oligarch - 50) * 10
			if w.empires.size() > 0:
				w.empires[0].relations -= (d.oligarch - 50) * 5
			d.living_standard += (d.oligarch - 50) * 5
			d.diplomatic_reputation += (d.oligarch - 50) * 5
			d.agents -= (d.oligarch - 50) * 5
			d.oligarch = 50
		if d.party_system == 9:
			d.oligarch -= 1
		if d.press_policy == 19:
			d.oligarch -= 1
		if d.religion_policy == 24:
			d.oligarch += 1
		elif d.religion_policy == 25:
			d.oligarch -= 1
		elif d.religion_policy == 28:
			d.oligarch += 1
		elif d.religion_policy == 29:
			d.oligarch += 3
		d.oligarch -= 3
		if _mod_active(w, GameConstants.Modifier.COMPROMISE_WITH_UNDERWORLD):
			d.oligarch += 3
	elif d.oligarch > 0:
		# econ <= 11：寡头归零
		d.party_support -= d.oligarch * 10
		if w.empires.size() > 0:
			w.empires[0].relations -= d.oligarch * 5
		d.living_standard += d.oligarch * 5
		d.diplomatic_reputation += d.oligarch * 5
		d.agents -= d.oligarch * 5
		d.oligarch = 0


## TimeScript.cs:2852-2913：改革阶段→美国关系、波兰 1983.7、中印战争(war==2)、
## 瑞士/越南/印度/古巴月度重置、莫桑比克内战漂移、伊朗革命结算（月块）。
func _monthly_late_maintenance(d: WorldState, w: WorldState) -> void:
	# 2852-2858：data.reform_stage==2 且事件54 未完成 → 对美关系 +1。
	if _dv(d, W.I_REFORM_STAGE) == 2 and not w.event_done_num(54):
		_add_empire_relation(w, EmpireData.USA, 1)

	# 2859-2863：1983.7 波兰 gov==0 且亲苏 → 军政体(2/21)。
	if w.date.year == 1983 and w.date.month == 7:
		var poland := w.get_country_by_legacy_index(2)
		if poland != null and poland.government == GameConstants.Government.AUTHORITARIAN and poland.has_tag("亲苏"):
			poland.government = GameConstants.Government.REFORMIST
			poland.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST

	# 2864-2896：中印边境战争(war_state==2)月度推进与胜利结算。
	if w.war_state == GameConstants.WarState.INDIA:
		if d.india_war_pressure >= 1000:
			w.influence_prc += 10
			d.arunachal_status = 2
			# 原版此处调 allcountries[1].ILoveSuckCocks() 刷新中国地图 parts；
			# 项目既有裁决：地图 parts 刷新近似省略 → 用地图归属转移等价实现
			# （藏南/阿鲁纳恰尔地块归中国 710，对应原版 parts 重绘中国全图）。
			_arunachal_to_china(w)
			d.population += 434
			w.war_state = GameConstants.WarState.PEACE
			GameManager.start_event("event_443")
		d.population -= 2
		if d.india_war_pressure >= 50:
			d.india_war_pressure -= 50
		elif w.influence_prc >= 20:
			w.influence_prc -= 20
		if d.india_war_pressure <= 0:
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
		d.iran_left_support += ussr_power / 25 + 30
		@warning_ignore("integer_division")
		d.iran_shah_support += usa_power / 30


## 藏南/阿鲁纳恰尔地块（map_regions.json region 43）归中国（gwcode 710）。
## 对应原版 ILoveSuckCocks() 在 data.arunachal_status>=2 时把中国地图 parts 重绘为含藏南的整图。
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

		if not c.has_tag("亲美") and c.government != GameConstants.Government.LIBERAL and not c.has_tag("亲苏") \
				and not c.has_tag("亲中") and c.sov_power > 300 and c.sov_power >= c.usa_power:
			# 6438-6451：亲苏和平转向。
			var roll := randi_range(80, 99)
			@warning_ignore("integer_division")
			if roll >= 50 and roll <= c.sov_power / 10:
				c.set_tag("亲苏", true)
				c.set_tag("对华贸易", false)
				if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
					w.empires[EmpireData.USSR].power = clampi(w.empires[EmpireData.USSR].power + 1, 0, 1000)
		elif not c.has_tag("亲美") and c.government != GameConstants.Government.SOCIALIST and not c.has_tag("亲苏") \
				and not c.has_tag("亲中") and c.usa_power > 300 and c.sov_power < c.usa_power:
			# 6452-6465：亲美和平转向。
			var roll := randi_range(80, 99)
			@warning_ignore("integer_division")
			if roll >= 50 and roll <= c.usa_power / 10:
				c.set_tag("亲美", true)
				c.set_tag("对华贸易", false)
				if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA] != null:
					w.empires[EmpireData.USA].power = clampi(w.empires[EmpireData.USA].power + 1, 0, 1000)
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
						w.empires[EmpireData.USA].power = clampi(w.empires[EmpireData.USA].power - 5, 0, 1000)
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
					w.empires[EmpireData.USSR].power = clampi(w.empires[EmpireData.USSR].power + 5, 0, 1000)
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
						w.empires[EmpireData.USSR].power = clampi(w.empires[EmpireData.USSR].power - 5, 0, 1000)
					c.set_tag("亲苏", false)
				if c.has_tag("亲中"):
					w.influence_prc -= 5
					c.set_tag("亲中", false)
				c.government = randi_range(0, 2)
				if c.government == GameConstants.Government.SOCIALIST:
					c.government = GameConstants.Government.LIBERAL
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
					w.empires[EmpireData.USA].power = clampi(w.empires[EmpireData.USA].power + 5, 0, 1000)


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


## AfricanCoups 中 data.africa_coup_route==15 时排除 61（上沃尔特）。
func d103_excluded(w: WorldState, i: int) -> bool:
	var d := w
	return d.size() > 103 and d.africa_coup_route == 15 and i == 61


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

func _african_bot_support(d: WorldState, w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._african_bot_support(d, w)

func _political_system_recalc(d: WorldState, w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._political_system_recalc(d, w)

func _update_political_line(d: WorldState, w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._update_political_line(d, w)

func _sync_faction_numbers_from_ideology(d: WorldState, w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._sync_faction_numbers_from_ideology(d, w)

func _weekly_ally_upkeep(d: WorldState, w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._weekly_ally_upkeep(d, w)

func _apply_policy_satisfied_growth(d: WorldState, w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._apply_policy_satisfied_growth(d, w)

func _recalc_export_value(d: WorldState, w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._recalc_export_value(d, w)

func _plot_player_cause(d: WorldState, w: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._plot_player_cause(d, w)

func _check_daily_conspiracy(d: WorldState) -> void:
	if _fortnight_service != null:
		_fortnight_service._check_daily_conspiracy(d)

func _check_scheduled_events() -> void:
	if _fortnight_service != null:
		_fortnight_service._check_scheduled_events(world)

func _dv(d: WorldState, idx: int) -> int:
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
	if get_tree() != null:
		get_tree().paused = false
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
