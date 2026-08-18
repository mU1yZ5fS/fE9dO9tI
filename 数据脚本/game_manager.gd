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
const WF = preload("res://数据脚本/world_factory.gd")
const WAR_SYS = preload("res://数据脚本/war_system.gd")
const POL_SYS = preload("res://数据脚本/politician_system.gd")

## 设置持久化文件。键名对齐原作 PlayerPrefs：voice_china / SavePosition / SavePlaceNum / our_diff_in。
const SETTINGS_PATH := "user://settings.cfg"

var world: WorldState
var is_playing: bool = false
var speed: int = 0
var selected_country_gwcode: int = -1
var settings_return_scene: String = "uid://bydan4iqthbaa"
## 保存/加载界面返回目标（esc 进存档时设为外交等）
var save_return_scene: String = "uid://bydan4iqthbaa"

# ── 设置（对齐原版 GlobalScript/PlayerPrefs 默认值）──
## 音乐音量 0-100。原版 GlobalScript.cs:249 默认 5。
var voice: int = 5
## 自动保存档位 0=不自动 1=每月 2=半年。原版 GlobalScript.autosavej 默认 0。
var autosave_mode: int = 0
## 自动保存/快速保存目标槽（原版编号 1-5，5=成就位）。原版 GlobalScript.savePlace 默认 5。
var save_place: int = 5
## 难度设置持久值。原版 GameState.diff 会被 PlayerPrefs our_diff_in 覆盖。
var difficulty_setting: int = 2

# ── 时间控制快捷键（设置界面可重绑）──
const TIME_SHORTCUT_ACTIONS: Array[String] = ["toggle_time", "speed_1", "speed_2", "speed_3", "speed_4"]
const TIME_SHORTCUT_DEFAULTS := {
	"toggle_time": KEY_SPACE,
	"speed_1": KEY_1,
	"speed_2": KEY_2,
	"speed_3": KEY_3,
	"speed_4": KEY_4,
}
## 当前绑定：action → 物理键码（Key）。空字典时用 TIME_SHORTCUT_DEFAULTS 兜底。
var time_shortcut_keys: Dictionary = {}

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

# 预加载地图底图与数据（后台线程解析并处理，避免场景切入时卡顿）
signal map_data_preloaded
var is_map_data_preloaded: bool = false

const REGION_MAP_PATH: String = "res://资产/地图/map_color.png"
var cached_map_meta: Dictionary = {}
var cached_map_regions: Dictionary = {}
var cached_map_countries: Dictionary = {}
var cached_region_owner: Dictionary = {}
var cached_initial_owner: Dictionary = {}

## 地图数据尚未预加载完成时，事件/外交请求的领土转移先挂在这里，等预加载完成后补执行。
var _pending_map_owner_changes: Array = []

var cached_region_map_image: Image = null
var cached_owner_palette_image: Image = null
var cached_color_palette_image: Image = null

var cached_region_map_tex: ImageTexture = null
var cached_owner_palette_tex: ImageTexture = null
var cached_color_palette_tex: ImageTexture = null

## 启动加载屏预热好的外交场景 PackedScene(点开始时 change_scene_to_packed 无缝进场)
var cached_diplomacy_scene: PackedScene = null

var _map_preload_thread: Thread = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_settings_config()
	_setup_time_shortcuts()
	_load_tech_effects()
	_preload_region_map()
	if EventEngine:
		EventEngine.event_triggered.connect(_on_event_triggered)


func _preload_region_map() -> void:
	if cached_region_map_image != null:
		return
	# 按原分辨率加载底图，不做 GPU 上限缩放/压缩。
	_map_preload_thread = Thread.new()
	_map_preload_thread.start(_decode_region_map)


func _decode_region_map() -> void:
	var img: Image = null
	
	# 1. 检查底图资源是否存在并加载为 Image
	if ResourceLoader.exists(REGION_MAP_PATH):
		var tex = ResourceLoader.load(REGION_MAP_PATH)
		if tex is Texture2D:
			img = tex.get_image()
			
	if img == null:
		push_error("GameManager: 无法预加载地图底图 " + REGION_MAP_PATH)
		call_deferred("_on_region_map_preloaded_failed")
		return

	# 按原分辨率加载，不缩放/压缩底图。

	# 2. 加载与解析地图相关的 JSON 文件
	const META_PATH := "res://资产/地图/map_meta.json"
	const REGIONS_PATH := "res://资产/地图/map_regions.json"
	const COUNTRIES_PATH := "res://资产/地图/map_countries.json"

	var meta := _load_json_async(META_PATH)
	var regions_raw := _load_json_async(REGIONS_PATH)
	var countries_raw := _load_json_async(COUNTRIES_PATH)

	# 3. 在后台子线程洗数据（把 key 转换为 int，构建归属字典，规避主线程 CPU 瓶颈）
	var regions_dict: Dictionary = {}
	var countries_dict: Dictionary = {}
	var region_owner_dict: Dictionary = {}
	var initial_owner_dict: Dictionary = {}

	for key in regions_raw:
		var r_id := int(key)
		var owner_gw := int(regions_raw[key].get("owner_1976_gwcode", 0))
		regions_dict[r_id] = regions_raw[key]
		region_owner_dict[r_id] = owner_gw
		initial_owner_dict[r_id] = owner_gw

	for key in countries_raw:
		countries_dict[int(key)] = countries_raw[key]

	# 4. 初始化 owner_palette 和 color_palette 图像（像素级填充在子线程完成）
	const PALETTE_SIZE := 256
	var owner_pal_img := Image.create(PALETTE_SIZE, PALETTE_SIZE, false, Image.FORMAT_RGB8)
	var color_pal_img := Image.create(PALETTE_SIZE, PALETTE_SIZE, false, Image.FORMAT_RGB8)

	owner_pal_img.fill(Color.BLACK)
	for r_id in region_owner_dict:
		var val: int = region_owner_dict[r_id]
		var col := Color8((val >> 16) & 0xFF, (val >> 8) & 0xFF, val & 0xFF)
		if r_id > 0:
			owner_pal_img.set_pixel(r_id & 0xFF, (r_id >> 8) & 0xFF, col)

	color_pal_img.fill(Color(0.46, 0.46, 0.46)) # 预填 BLOC_NEUTRAL

	# 5. 传回主线程生成 GPU 纹理与缓存更新
	call_deferred(
		"_on_region_map_preloaded", 
		img, 
		meta, 
		regions_dict, 
		countries_dict, 
		region_owner_dict, 
		initial_owner_dict, 
		owner_pal_img, 
		color_pal_img
	)


func _on_region_map_preloaded(
	img: Image, 
	meta: Dictionary, 
	regions: Dictionary, 
	countries: Dictionary, 
	region_owner: Dictionary, 
	initial_owner: Dictionary, 
	owner_pal_img: Image, 
	color_pal_img: Image
) -> void:
	if _map_preload_thread != null:
		_map_preload_thread.wait_to_finish()
		_map_preload_thread = null

	cached_region_map_image = img
	cached_map_meta = meta
	cached_map_regions = regions
	cached_map_countries = countries
	cached_region_owner = region_owner
	cached_initial_owner = initial_owner
	
	cached_owner_palette_image = owner_pal_img
	cached_color_palette_image = color_pal_img

	# 在主线程安全创建 GPU 纹理
	cached_region_map_tex = ImageTexture.create_from_image(cached_region_map_image)
	cached_owner_palette_tex = ImageTexture.create_from_image(cached_owner_palette_image)
	cached_color_palette_tex = ImageTexture.create_from_image(cached_color_palette_image)

	# 预加载前排队的地图归属变更（如提前触发的事件）在此补执行。
	_flush_pending_map_owner_changes()
	# 读档/继续游戏时，地图数据刚重建，需把存档中持久化的归属覆盖重新套上，
	# 否则独立后的领土会显示回初始宗主国（例如吉布提又变法国）。
	_apply_map_owner_overrides()

	is_map_data_preloaded = true
	map_data_preloaded.emit()
	print("GameManager: 地图底图、数据加载及纹理分配全部完成")


func _on_region_map_preloaded_failed() -> void:
	if _map_preload_thread != null:
		_map_preload_thread.wait_to_finish()
		_map_preload_thread = null
	# 地图数据不可用：排队的领土变更无法落地，直接丢弃并记录，避免永远悬挂。
	if not _pending_map_owner_changes.is_empty():
		push_warning("GameManager: 地图预加载失败，丢弃 %d 条待补领土变更" % _pending_map_owner_changes.size())
		_pending_map_owner_changes.clear()
	is_map_data_preloaded = true
	map_data_preloaded.emit()


func _load_json_async(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("GameManager: 找不到文件 %s" % path)
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	return parsed if parsed is Dictionary else {}


func reset_map_runtime_state() -> void:
	if cached_initial_owner.size() > 0:
		cached_region_owner = cached_initial_owner.duplicate()
		if cached_owner_palette_image:
			cached_owner_palette_image.fill(Color.BLACK)
			for r_id in cached_region_owner:
				var val: int = cached_region_owner[r_id]
				var col = Color8((val >> 16) & 0xFF, (val >> 8) & 0xFF, val & 0xFF)
				if r_id > 0:
					cached_owner_palette_image.set_pixel(r_id & 0xFF, (r_id >> 8) & 0xFF, col)
			if cached_owner_palette_tex:
				cached_owner_palette_tex.update(cached_owner_palette_image)
	# 读档后先回到初始归属，再把存档中记录的领土变更覆盖回去。
	_apply_map_owner_overrides()
	print("GameManager: 地图归属运行时状态与调色板已重置")


## 将世界存档中的地图归属覆盖应用到当前缓存。地图归属不是 WorldState 直接序列化的，
## 所以事件/外交改地图时必须写入 world.map_owner_overrides，读档/重建缓存后靠本方法恢复。
func _apply_map_owner_overrides() -> void:
	if world == null or world.map_owner_overrides.is_empty():
		return
	if cached_region_owner.is_empty():
		return
	var changed := false
	for raw in world.map_owner_overrides:
		var r_id := int(raw)
		if cached_region_owner.has(r_id):
			cached_region_owner[r_id] = int(world.map_owner_overrides[raw])
			changed = true
	if changed:
		_update_cached_owner_palette()


## 事件/外交领土变更后同步地图归属缓存（预留 API：本期尚无调用方，后续领土转移事件接入）。
## 世界地图渲染每次进入场景时从 cached_region_owner 复制，因此改这里即可让下次渲染生效。
## 若外交场景常驻，可直接调用世界地图渲染节点的 transfer_* 方法；此处提供全局缓存入口。
func transfer_map_owner(from_gwcode: int, to_gwcode: int) -> void:
	if from_gwcode <= 0 or to_gwcode <= 0:
		return
	if cached_region_owner.is_empty():
		_pending_map_owner_changes.append({"kind": "transfer", "from": from_gwcode, "to": to_gwcode})
		return
	for r_id in cached_region_owner:
		if cached_region_owner[r_id] == from_gwcode:
			cached_region_owner[r_id] = to_gwcode
			_persist_map_owner_override(r_id, to_gwcode)
	_update_cached_owner_palette()
	notify_stats_changed()


func set_map_region_owner(region_ids: Array, to_gwcode: int) -> void:
	if to_gwcode <= 0:
		return
	if cached_region_owner.is_empty():
		_pending_map_owner_changes.append({"kind": "regions", "ids": region_ids.duplicate(), "to": to_gwcode})
		# 地图尚未加载也要先记录到存档覆盖，避免加载后丢失。
		for raw in region_ids:
			_persist_map_owner_override(int(raw), to_gwcode)
		return
	for raw in region_ids:
		var r_id := int(raw)
		if cached_region_owner.has(r_id):
			cached_region_owner[r_id] = to_gwcode
			_persist_map_owner_override(r_id, to_gwcode)
	_update_cached_owner_palette()
	notify_stats_changed()


func _persist_map_owner_override(r_id: int, to_gwcode: int) -> void:
	if world != null:
		world.map_owner_overrides[r_id] = to_gwcode


## 旧档兼容：在地图归属持久化功能加入前，Event585 已让吉布提独立、Event589/1035 已成立
## 非洲之角联邦，但存档没有 map_owner_overrides，读档会回到初始归属。这里按国家状态识别补写。
func _migrate_legacy_map_owner_overrides() -> void:
	const DJIBOUTI_REGION_IDS := [366, 367, 368, 370, 376, 2032]
	const SOMALIA_REGION_IDS := [30, 31, 32, 33, 34, 35, 45, 46, 1466, 2028, 2029, 2030, 2031, 4115]
	if world == null:
		return
	# 吉布提独立（Event585）：吉布提区域从法国 220 改为 522。
	var c106 := world.get_country_by_legacy_index(106)
	if c106 != null and c106.puppet_of < 0 and c106.chinese_name == "吉布提共和国":
		for r_id in DJIBOUTI_REGION_IDS:
			if not world.map_owner_overrides.has(r_id):
				world.map_owner_overrides[r_id] = 522
	# 非洲之角联邦（Event589）：索马里区域并入埃塞俄比亚 530；若 1035 已推动，吉布提也并入 530。
	var c41 := world.get_country_by_legacy_index(41)
	if c41 != null and c41.parts.size() > 0 and c41.parts[0] and c41.sub_government == 17:
		c41.gov_names[1] = "非洲之角联邦"
		for gn_key in c41.gov_names:
			c41.gov_names[gn_key] = "非洲之角联邦"
		for r_id in SOMALIA_REGION_IDS:
			if not world.map_owner_overrides.has(r_id):
				world.map_owner_overrides[r_id] = 530
		if c41.parts.size() > 1 and c41.parts[1]:
			for r_id in DJIBOUTI_REGION_IDS:
				if not world.map_owner_overrides.has(r_id):
					world.map_owner_overrides[r_id] = 530


## 旧档兼容：早期端口误用 "vietnam_peace" 作为越南和平标志，原版字段名是 "vietnampeace"。
## 读档时把旧键迁移到统一键，避免柬越和解/不战选项后仍触发柬越战争。
func _migrate_legacy_global_flags() -> void:
	if world == null:
		return
	if world.global_flags.has("vietnam_peace"):
		var old_val := bool(world.global_flags.get("vietnam_peace", false))
		if old_val:
			world.set_flag("vietnampeace", true)
		world.global_flags.erase("vietnam_peace")


## 地图预加载完成时补执行之前排队的领土转移。
func _flush_pending_map_owner_changes() -> void:
	if _pending_map_owner_changes.is_empty():
		return
	var pending := _pending_map_owner_changes.duplicate()
	_pending_map_owner_changes.clear()
	for entry in pending:
		if not entry is Dictionary:
			continue
		var kind := String(entry.get("kind", ""))
		if kind == "transfer":
			var from_gw := int(entry.get("from", 0))
			var to_gw := int(entry.get("to", 0))
			for r_id in cached_region_owner:
				if cached_region_owner[r_id] == from_gw:
					cached_region_owner[r_id] = to_gw
					_persist_map_owner_override(r_id, to_gw)
		elif kind == "regions":
			var ids: Array = entry.get("ids", [])
			var to_gw := int(entry.get("to", 0))
			for raw in ids:
				var r_id := int(raw)
				if cached_region_owner.has(r_id):
					cached_region_owner[r_id] = to_gw
					_persist_map_owner_override(r_id, to_gw)
	_update_cached_owner_palette()


func _update_cached_owner_palette() -> void:
	if cached_owner_palette_image == null:
		return
	cached_owner_palette_image.fill(Color.BLACK)
	for r_id in cached_region_owner:
		var val: int = cached_region_owner[r_id]
		var col := Color8((val >> 16) & 0xFF, (val >> 8) & 0xFF, val & 0xFF)
		if r_id > 0:
			cached_owner_palette_image.set_pixel(r_id & 0xFF, (r_id >> 8) & 0xFF, col)
	if cached_owner_palette_tex:
		cached_owner_palette_tex.update(cached_owner_palette_image)


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


# ── 设置持久化（对齐原作 PlayerPrefs 键名语义）──

func _load_settings_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		# 无配置文件时保持原版默认：voice=5、autosavej=0、savePlace=5、diff=2。
		# 快捷键保持 TIME_SHORTCUT_DEFAULTS（time_shortcut_keys 留空，由 get 默认兜底）。
		return
	voice = clampi(int(cfg.get_value("settings", "voice_china", 5)), 0, 100)
	autosave_mode = clampi(int(cfg.get_value("settings", "SavePosition", 0)), 0, 2)
	save_place = clampi(int(cfg.get_value("settings", "SavePlaceNum", 5)), 1, 5)
	difficulty_setting = clampi(int(cfg.get_value("settings", "our_diff_in", 2)), 0, 4)
	for action in TIME_SHORTCUT_ACTIONS:
		var code: int = int(cfg.get_value("time_shortcuts", action, TIME_SHORTCUT_DEFAULTS[action]))
		if code != 0:
			time_shortcut_keys[action] = code


func _save_settings_config() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "voice_china", voice)
	cfg.set_value("settings", "SavePosition", autosave_mode)
	cfg.set_value("settings", "SavePlaceNum", save_place)
	cfg.set_value("settings", "our_diff_in", difficulty_setting)
	for action in TIME_SHORTCUT_ACTIONS:
		cfg.set_value("time_shortcuts", action, int(time_shortcut_keys.get(action, TIME_SHORTCUT_DEFAULTS[action])))
	if cfg.save(SETTINGS_PATH) != OK:
		push_error("GameManager: 设置写入失败 " + SETTINGS_PATH)


# ── 时间控制快捷键 ──

## 注册动作并应用当前绑定。仅在本 Autoload _ready 调用一次；
## 动作常驻全局 InputMap，但只有外交场景监听它们。
func _setup_time_shortcuts() -> void:
	for action in TIME_SHORTCUT_ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	_apply_time_shortcuts()


func _apply_time_shortcuts() -> void:
	for action in TIME_SHORTCUT_ACTIONS:
		InputMap.action_erase_events(action)
		var code := get_time_shortcut_key(action)
		if code == 0:
			continue
		var ev := InputEventKey.new()
		ev.physical_keycode = code as Key
		InputMap.action_add_event(action, ev)


func get_time_shortcut_key(action: String) -> int:
	return int(time_shortcut_keys.get(action, TIME_SHORTCUT_DEFAULTS.get(action, 0)))


## 键位显示名：按物理键位转当前布局标签（中文输入法/不同布局下仍显示当前键帽）。
func get_time_shortcut_label(action: String) -> String:
	var code := get_time_shortcut_key(action)
	if code == 0:
		return "未设置"
	var label_key := DisplayServer.keyboard_get_label_from_physical(code as Key)
	return OS.get_keycode_string(label_key)


## 设置界面重绑入口：写入内存 + 立即改 InputMap + 持久化。
func rebind_time_shortcut(action: String, physical_keycode: int) -> void:
	if not TIME_SHORTCUT_ACTIONS.has(action) or physical_keycode == 0:
		return
	time_shortcut_keys[action] = physical_keycode
	_apply_time_shortcuts()
	_save_settings_config()


func set_voice(value: int) -> void:
	voice = clampi(value, 0, 100)
	_save_settings_config()


func set_autosave_mode(value: int) -> void:
	autosave_mode = clampi(value, 0, 2)
	_save_settings_config()


func set_save_place(value: int) -> void:
	save_place = clampi(value, 1, 5)
	_save_settings_config()


func set_difficulty(value: int) -> void:
	difficulty_setting = clampi(value, 0, 4)
	if world != null:
		world.difficulty = difficulty_setting
	_save_settings_config()


## 原作 savePlace 编号 5=成就位；本端口存档槽 0=成就位、1-4=普通位。
func autosave_slot() -> int:
	return 0 if save_place == 5 else save_place - 1


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
	_sync_date_to_data(world)
	FocusSystem.init_for_new_game()
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
		FocusCatalog.ensure_built()
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
	if world == null:
		push_error("GameManager: 无活动游戏")
		return
	# 写入前同步显示视图，避免读档后经济视图过期
	world.sync_economy()
	world.sync_rng_state()  # 镜像 RNG 流位置，保证读档精确续流
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
	if world != null:
		# LoadInScript.cs:33：number != 5 时 iron_and_blood=false（原版 5=成就位；
		# 本端口槽位 0=成就位、1-4=普通位，见 保存.gd/加载.gd SLOT_NODES）
		if slot != 0:
			world.is_ironman = false
	return world != null


func delete_save_slot(slot: int) -> bool:
	return SaveCatalog.delete_slot(slot)


func tick() -> void:
	if world == null or current_event_id != "":
		return
	var old_month := world.date.month
	var old_year := world.date.year
	world.date.advance()
	_sync_date_to_data(world)

	_daily_deficit_recovery(world)

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
	if world == null:
		return 0
	var d := world.数值表
	var total: int = d[W.I_BUDGET] + d[W.I_RESERVE]
	for i in range(W.I_BUDGET_ARMY, W.I_BUDGET_DIPLO + 1):
		total += d[i]
	if d[W.I_ECON_SYSTEM] > 12:
		total -= (d[W.I_ECON_SYSTEM] - 12) * (total / 10)
	return total


## 调整预算类别。category_idx 为 71-81，delta 为增减量。
## 返回 false 表示余额不足或超过 planka 上限。
func adjust_budget(category_idx: int, delta: int) -> bool:
	if world == null:
		return false
	var d := world.数值表
	var is_budget_category := category_idx >= W.I_BUDGET_ARMY and category_idx <= W.I_BUDGET_DIPLO
	if not is_budget_category:
		return false
	if delta > 0:
		if d[W.I_BUDGET] < delta:
			return false
		var limit6 := calc_budget_planka() / 6
		# 原版 Plusmisnus_script.cs:79（普通+10）只检查当前值 <= planka2/6，
		# 允许加到 planka2/6+10；Shift/Ctrl 分支(:87/:93)才检查 data[idx]+50/100 <= planka2/6。
		if delta == 10:
			if d[category_idx] > limit6:
				return false
		elif d[category_idx] + delta > limit6:
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
		# 借入：检查贷款上限（原版 Plusmisnus_script.cs:195 `loan < planka`）。
		# 原版 planka = (empires[0].relations + empires[1].relations) / 5，
		# 不是投资总额 calc_budget_planka()（那是 11 项预算的上限，见 CheckPlanka）。
		var loan_limit := 0
		if world.empires.size() > 0:
			loan_limit += world.empires[0].relations
		if world.empires.size() > 1:
			loan_limit += world.empires[1].relations
		loan_limit = loan_limit / 5
		if d[W.I_LOAN] >= loan_limit:
			return false
		d[W.I_LOAN] += delta
		d[W.I_BUDGET] += delta
		d[W.I_PARTY_SUPPORT] -= delta
		# 借款思想自由：原版 data[4] += 10（Plusmisnus_script.cs:201），非 ×2.5
		d[W.I_THOUGHT_FREEDOM] += delta
		# 借款影响力：原版 influencePRC--（Plusmisnus_script.cs:200）
		world.influence_prc -= 1
	else:
		# 还款：loan 为正才可还；零头(0<loan<10)只还剩余额并清零（原版:177-194）
		if d[W.I_LOAN] <= 0:
			return false
		var repay_amount := mini(-delta, d[W.I_LOAN])
		var mult := 1
		# 原版：diff==3 时 ×3，diff 2/4 时 ×2（Plusmisnus_script.cs:184-186）
		if world.difficulty == 3:
			mult = 3
		elif world.difficulty >= 2:
			mult = 2
		var budget_cost := repay_amount * mult
		# 原版不检查预算余额（Plusmisnus:158-194 无条件扣减，可为负，由日块赤字恢复兜底）
		d[W.I_LOAN] -= repay_amount
		d[W.I_BUDGET] -= budget_cost
		# 还款党支持：原版 data[1] += 5（Plusmisnus_script.cs:173/192），非 +10
		d[W.I_PARTY_SUPPORT] += 5
		# 还款影响力：原版 influencePRC++ 仅常规分支（:174），零头分支(:177-194)无
		if repay_amount >= 10:
			world.influence_prc += 1
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
# ============================================================================
# 政策切换 3 条件（对齐原版 Doctrine_button_script.OnMouseDown 的 uslovie[0..2]）
#   [0] 预算    ≥ |diff|×50
#   [1] 党内支持 ≥ |diff|×300
#   [2] 派系/路线领导：一党制(data[15]≤7)看政治路线 data[56]；多党看 data[52]/data[54]+联盟席位>66%
# 注：原版 OnMouseDown 无毛存活门槛，开局即可切（已移除此前的 mao_ok 条件）。
# ============================================================================

## 一党制(data[15]≤7)下：政策目标值 → 允许的政治路线 data[56] 集合。
## 对齐 Doctrine_button_script.cs 75-214。空数组 = 该项不施加路线限制。
## 未列出的目标值（如 OGAS 经济 11）= 无路线限制。
const POLICY_LINE_REQ_ONEPARTY := {
	10: [0, 1], 11: [0, 1], 12: [1, 2], 13: [2, 3], 14: [3, 4], 15: [4],  # 经济 data[16]（原版 :42 id11=极左/保守0,1）
	6: [0], 7: [1, 2], 8: [3], 9: [4],                                # 党政 data[15]
	16: [0, 1, 2, 3], 17: [0, 1, 2, 3, 4], 18: [2, 3, 4], 19: [3, 4],  # 人权 data[17]（16/17 按原版中文块 :85-94：16=data[56]!=4、17=data[56]<=4；旧值 [0,1]/[0,1,2,3] 系误抄俄语块，2026-08-14 主控亲验修正）
	20: [0, 1, 2, 3], 21: [2, 3], 22: [3, 4], 23: [4],                # 国家体制 data[18]
	24: [0], 25: [0, 1], 26: [1, 2, 3], 27: [2, 3, 4], 28: [3, 4], 29: [4],  # 宗教 data[50]
	30: [0], 31: [0, 1, 2], 32: [2, 3], 33: [3, 4],                   # 军事 data[51]
}

## 多党(data[15]>7)下：政策目标值 → 允许的显示等级集合。
## 经济类(10-15)看 data[52](34-37)，其余看 data[54](38-41)，均需联盟席位>66%。
## 对齐 Doctrine_button_script.cs 233-453。
const POLICY_DISPLAY_REQ_MULTIPARTY := {
	10: [34], 11: [34], 12: [34, 35], 13: [35, 36], 14: [36, 37], 15: [37],  # 经济 → data[52]（原版 :204 id11=社会主义34）
	6: [38, 39], 7: [39, 40], 8: [40, 41], 9: [41],                        # 党政 → data[54]
	16: [38, 39], 17: [39, 40], 18: [40], 19: [41],                        # 人权 → data[54]
	20: [38, 39], 21: [39, 40, 41], 22: [40, 41], 23: [41],                # 国家体制 → data[54]
	24: [38], 25: [38, 39], 26: [39, 40], 27: [40, 41], 28: [39, 41], 29: [38, 39],  # 宗教 → data[54]
	30: [38, 39], 31: [38, 41], 32: [40, 41], 33: [39, 40, 41],            # 军事 → data[54]
}


## 政策切换 4 条件检查（唯一权威）。UI 与实际切换共用，返回各条件明细。
func check_policy_change(category_idx: int, target_val: int) -> Dictionary:
	var res := {
		"can": false, "same": false,
		"budget_ok": false, "budget_need": 0,
		"party_ok": false, "party_need": 0,
		"leading_ok": false, "leading_text": "",
		"mao_ok": false,
	}
	if world == null:
		return res
	var d := world.数值表
	if category_idx < 0 or category_idx >= d.size() or d.size() <= W.I_STABILITY:
		return res
	var current_val: int = d[category_idx]
	if current_val == target_val:
		res.same = true
		res.can = true
		return res
	var diff := absi(target_val - current_val)
	res.budget_need = diff * 50
	res.budget_ok = (d[W.I_BUDGET] + d[W.I_RESERVE]) >= res.budget_need
	res.party_need = diff * 300
	res.party_ok = d[W.I_PARTY_SUPPORT] >= res.party_need
	var lead := _policy_leading_ok(category_idx, target_val, d)
	res.leading_ok = lead["ok"]
	res.leading_text = lead["text"]
	# 原版 uslovie_bool[3]：毛在世(data[38]<100)时恒为 false，不可切任何政策
	# （Doctrine_button_script.cs:446-455；number_uslovie==4 需 4 条件全满足，见 :894）
	res.mao_ok = is_mao_dead()
	# 原作 :456-461 modifies[6] 覆盖：mod6 激活且目标∈{9,14,15,22,23,28,29}
	# 或 (19 且 resultOfEvents[444]!=0) 时 uslovie_bool[3] 恒 false（"毛主席正看着你！"）。
	# 事件 444 未启用 → completed_event_ids.get(444,-1) 恒 -1（原版初始态）→ !=0 恒真。
	if _mod_active(world, 6) and (target_val in [9, 14, 15, 22, 23, 28, 29] \
			or (target_val == 19 and world.completed_event_ids.get(444, -1) != 0)):
		res.mao_ok = false
	res.can = res.budget_ok and res.party_ok and res.leading_ok and res.mao_ok
	return res


## uslovie[2]：派系/路线领导条件。返回 {ok, text}。
func _policy_leading_ok(_category_idx: int, target_val: int, d: Array[int]) -> Dictionary:
	var party_sys: int = d[W.I_PARTY_SYSTEM]
	if party_sys <= 7:
		# neutral_leading：满足现状者席位 ≥ 所有派系 → 中间派主导，任何政策都不可变
		if _satisfied_leads(d):
			return {"ok": false, "text": " 满 意 现 状 者 失 去 领 导"}
		var line: int = d[W.I_POLITICAL_LINE]
		var text: String = LEADING_TEXT_ONEPARTY.get(target_val, "")
		if text == "":
			return {"ok": true, "text": "无执政路线限制"}  # 未列出（如 OGAS 经济 11 在多态另处理）
		var req: Array = POLICY_LINE_REQ_ONEPARTY.get(target_val, [])
		var ok: bool = line in req
		# 经济 10/15：额外要求 data[15]!=7（非人民民主专政）
		if target_val == 10 or target_val == 15:
			ok = ok and party_sys != 7
		# 宗教 29 特例：data[56]==4 或 (威权 data[14]==0 且 高民族主义 data[31]≥700)
		elif target_val == 29:
			ok = ok or (d[W.I_IDEOLOGY] == 0 and d[W.I_WAR_SUPPORT] >= 700)
		return {"ok": ok, "text": text}
	else:
		# 多党：路线显示等级 + 联盟席位 > 66%
		var text: String = LEADING_TEXT_MULTIPARTY.get(target_val, "")
		if text == "":
			return {"ok": true, "text": "无执政路线限制"}
		text += MULTIPARTY_SEAT_SUFFIX
		var req2: Array = POLICY_DISPLAY_REQ_MULTIPARTY.get(target_val, [])
		var seat_ok := _multiparty_seat_majority(d)
		# 经济类(10-15)看 data[52]，其余看 data[54]
		var econ_cat := target_val >= 10 and target_val <= 15
		var disp: int = d[W.I_ECON_DISPLAY] if econ_cat else d[W.I_POLITICAL_DISPLAY]
		var disp_ok: bool = disp in req2
		if target_val == 29:  # 政教协定多党特例：另需 data[52]∈{36,37}（原版 :402）
			disp_ok = disp_ok and (d[W.I_ECON_DISPLAY] == 36 or d[W.I_ECON_DISPLAY] == 37)
		return {"ok": disp_ok and seat_ok, "text": text}


## neutral_leading：满足现状者 data[106] ≥ 每个派系 support（原版 Doctrine 60）
func _satisfied_leads(d: Array[int]) -> bool:
	if world == null:
		return false
	var sat: int = d[W.I_SATISFIED]
	for f in world.factions:
		if sat < maxi(f.support, 0):
			return false
	return true


## 原版 summa_3_2>66：保守派+盟友(启用,非保守)席位 占 (全派系+满足现状者) 的比例
func _multiparty_seat_majority(d: Array[int]) -> bool:
	if world == null:
		return false
	var allied := 0
	var total := 0
	for i in world.factions.size():
		var f: FactionData = world.factions[i]
		total += maxi(f.support, 0)
		if i == FactionData.CONSERVATIVE:
			allied += maxi(f.support, 0)
		elif f.is_ally and f.is_enabled:
			allied += maxi(f.support, 0)
	total += maxi(d[W.I_SATISFIED], 0)  # 原版 summa 含 data[106]
	if total <= 0:
		return false
	# 原版整数除法：player_numbeer*100/summa > 66（Doctrine_button_script.cs:192/:630）
	@warning_ignore("integer_division")
	return allied * 100 / total > 66


## 一党制 uslovie_text[2] 逐字文案（原版 Doctrine_button_script.cs:37-173，基于 data[56] 派系，含原版空格/|排版）。
## 与 POLICY_LINE_REQ_ONEPARTY 判定一一对应；10/15 的“并非新民主主义制度”尾注见 _policy_leading_ok。
const LEADING_TEXT_ONEPARTY := {
	10: " 极 左 派/ 保 守 派 领 导\n 并 非 \" 新 民 主 主 义 制 度\"", 11: " 极 左 派/ 保 守 派 领 导",
	12: " 保 守 派/ 温 和 派 领 导", 13: " 温 和 派/ 改 革 派 领 导", 14: " 改 革 派/ 自 由 派 领 导",
	15: " 自 由 派 领 导\n 并 非 \" 新 民 主 主 义 制 度\"",
	6: " 极 左 派 领 导", 7: " 保 守 派/ 温 和 派 领 导", 8: " 改 革 派 领 导", 9: " 自 由 派 领 导",
	16: " 非 自 由 派 领 导", 17: " 任 意 派 领 导", 18: " 温 和 派/ 改 革 派/ 自 由 派 领 导", 19: " 改 革 派/ 自 由 派 领 导",
	20: " 极 左 派/ 保 守 派/ 温 和 派/ 改 革 派| 领 导", 21: " 温 和 派/ 改 革 派 领 导", 22: " 改 革 派/ 自 由 派 领 导", 23: " 自 由 派 领 导",
	24: " 极 左 派 领 导", 25: " 极 左 派/ 保 守 派 领 导", 26: " 保 守 派/ 温 和 派/ 改 革 派 领 导",
	27: " 温 和 派/ 改 革 派/ 自 由 派 领 导", 28: " 改 革 派/ 自 由 派 领 导", 29: " 自 由 派 领 导/| 威 权 主 义 且 民 族 主 义 高 涨",
	30: " 极 左 派 领 导", 31: " 极 左 派/ 保 守 派/ 温 和 派 领 导", 32: " 温 和 派/ 改 革 派 领 导", 33: " 改 革 派/ 自 由 派 领 导",
}

## 多党 uslovie_text[2] 逐字文案（原版 :195-443，基于 data[52]/data[54] 路线，含原版空格排版）。
## 统一尾注“我 方 党 派 联 盟 …”见 MULTIPARTY_SEAT_SUFFIX，此处仅存路线前缀。
const LEADING_TEXT_MULTIPARTY := {
	10: " 党 派 路 线 ： 社 会 主 义  且", 11: " 党 派 路 线 ： 社 会 主 义  且", 12: " 党 派 路 线 ： 社 会 主 义/ 改 良 主 义  且",
	13: " 党 派 路 线 ： 改 良 主 义/ 实 用 主 义  且", 14: " 党 派 路 线 ： 实 用 主 义/ 市 场 主 义  且", 15: " 党 派 路 线 ： 市 场 主 义  且",
	6: " 党 派 路 线 ： 威 权/ 强 硬  且", 7: " 党 派 路 线 ： 强 硬/ 温 和  且", 8: " 党 派 路 线 ： 温 和/ 民 主  且", 9: " 党 派 路 线 ： 民 主  且",
	16: " 党 派 路 线 ： 威 权/ 强 硬  且", 17: " 党 派 路 线 ： 强 硬/ 温 和  且", 18: " 党 派 路 线 ： 温 和  且", 19: " 党 派 路 线 ： 民 主  且",
	20: " 党 派 路 线 ： 威 权/ 强 硬  且", 21: " 党 派 路 线 ： 强 硬/ 温 和/ 民 主  且", 22: " 党 派 路 线 ： 温 和/ 民 主  且", 23: " 党 派 路 线 ： 民 主  且",
	24: " 党 派 路 线 ： 威 权  且", 25: " 党 派 路 线 ： 威 权/ 强 硬  且", 26: " 党 派 路 线 ： 强 硬/ 温 和  且",
	27: " 党 派 路 线 ： 温 和/ 民 主  且", 28: " 党 派 路 线 ： 强 硬/ 民 主  且", 29: " 党 派 路 线 ： 威 权/ 强 硬 ，| 实 用 主 义/ 市 场 主 义  且",
	30: " 党 派 路 线 ： 威 权/ 强 硬  且", 31: " 党 派 路 线 ： 威 权/ 民 主  且", 32: " 党 派 路 线 ： 温 和/ 民 主  且", 33: " 党 派 路 线 ： 强 硬/ 温 和/ 民 主  且",
}
const MULTIPARTY_SEAT_SUFFIX := " 我 方 党 派 联 盟 在 全 国 人 大 中 保 有 66% 以 上 席 位"


func change_policy(category_idx: int, target_val: int) -> bool:
	if world == null:
		return false
	var chk := check_policy_change(category_idx, target_val)
	if chk["same"]:
		return true
	if not chk["can"]:
		return false
	var d := world.数值表
	var current_val: int = d[category_idx]
	var diff := absi(target_val - current_val)
	# 原版 Doctrine_button_script.cs:896-907：经济由计划转向市场（12→13+）时的特殊块。
	if category_idx == W.I_ECON_SYSTEM and current_val <= 12 and target_val >= 13:
		if d[W.I_REFORM_STAGE] < 2:
			d[W.I_REFORM_STAGE] = 2
		elif d[W.I_ALBANIA_BREAK] < 1:
			# 原版 allcountries[20] = 阿尔巴尼亚（Country_en 第21行）；Torg/proprc → 标签
			var albania := world.get_country_by_legacy_index(20)
			if albania:
				albania.set_tag("对华贸易", false)
				albania.set_tag("亲中", false)
	# 原版 :909-983：党政切换的派系重排（此处 current_val 仍旧值，与原版读旧 data[15] 一致）
	if category_idx == W.I_PARTY_SYSTEM and world.factions.size() >= 5:
		if current_val >= 6 and current_val <= 7 and target_val >= 8 and target_val <= 9:
			# 一党 → 多党：解除异见联盟、未启用派系启用、异见席位逐次折半并入保守派
			var transferred := 0
			for i in world.factions.size():
				var f: FactionData = world.factions[i]
				if f.is_ally and i != FactionData.CONSERVATIVE:
					f.is_ally = false
				if f.ideology < 0:
					f.ideology = 0
				if f.is_enabled and i != FactionData.CONSERVATIVE and f.support > 0:
					transferred += f.support / 2
					f.support -= f.support / 2
					f.ideology -= f.support / 2
					transferred += f.support / 4
					f.support -= f.support / 4
					f.ideology -= f.support / 4
				elif not f.is_enabled:
					f.is_enabled = true
				d[W.I_PARTY_BAN_COUNT] = 0
			world.factions[FactionData.CONSERVATIVE].support += transferred
			world.factions[FactionData.CONSERVATIVE].ideology += transferred
			d[125] = 0  # 原版 data[125]（选举计时，Godot 未映射语义，保留槽位归零）
		elif current_val >= 8 and current_val <= 9 and target_val >= 6 and target_val <= 7:
			# 多党 → 一党：解除异见联盟、按基础意识形态复位席位
			for i in world.factions.size():
				var f2: FactionData = world.factions[i]
				if f2.is_ally and i != FactionData.CONSERVATIVE:
					f2.is_ally = false
				if not f2.is_enabled:
					f2.is_enabled = true
					if f2.support <= 5:
						var rv := randi_range(0, 9)
						f2.support = 10 + rv
						f2.ideology = f2.support
				else:
					f2.support = f2.ideology
			world.factions[FactionData.CONSERVATIVE].is_enabled = true
			world.factions[FactionData.MODERATE].is_enabled = true
			world.factions[FactionData.REFORMIST].is_enabled = true
			world.factions[0].support = 0
			world.factions[FactionData.CONSERVATIVE].support = 50
			world.factions[FactionData.MODERATE].support = 50
			world.factions[FactionData.REFORMIST].support = 500
			world.factions[FactionData.LIBERAL].support = 400
			if d[W.I_ECON_DISPLAY] == 37:
				world.factions[FactionData.REFORMIST].support = 200
				world.factions[FactionData.LIBERAL].support = 700
			d[W.I_PARTY_BAN_COUNT] = 0
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
	# 改革方向累计（原版 Doctrine_button_script.cs:1195-1198，军事学说 51 不计入；用旧值算 delta）
	if category_idx != W.I_MIL_DOCTRINE:
		d[W.I_REFORM_MOMENTUM] += delta * 15
	# 政策切换对政治家忠诚的位移（原版 :988-1116，按 traits[0] 分派；须在覆写旧值前）
	_apply_policy_loyalty_shift(category_idx, target_val, delta)
	d[category_idx] = target_val
	# 原版 :1154-1185 切换后立即重算 data[52]/data[54] 显示等级；:1199-1382 立即重算政体（hooray）
	_update_displays(d)
	_political_system_recalc(d, world)
	# TimeScript.cs:3786-3790：进入 data[15] > 7 后，autosave<=0 时立即进入一次选举。
	# 年度 10 月 1 日选举仍由 _check_scheduled_events 单独处理。
	if category_idx == W.I_PARTY_SYSTEM and current_val <= 7 and target_val > 7:
		world.set_flag("election_due", true)
	# FAC-SAT：满足现状者仅在切政策成功时增长一次（对齐原版 Doctrine_button.OnMouseDown 1229/1253）
	_apply_policy_satisfied_growth(d, world)
	_notify_stats()
	return true


## 政策切换对全体政治家忠诚的位移。逐类照抄 Doctrine_button_script.cs:986-1117。
## delta = target - 旧值（升高为正）；原版 (data[X]-number)=-delta、(number-data[X])=+delta。
## 每类分三桶（按 trait_personality = 原版 traits[0]）：
##   a_set 恒 -delta*K（偏好更低值）；t_set 走门槛（target>=门槛 -delta，否则 +delta）；
##   其余（原版 else 分支，含自由派 3 与变体值）恒 +delta*K。
## 关键差异：改革(2) 在 政党15 属门槛桶、经济16/舆论17 属 else(+)、领土18/宗教50/军事51 属 a_set(-)。
func _apply_policy_loyalty_shift(category_idx: int, target_val: int, delta: int) -> void:
	if world == null or delta == 0:
		return
	# 每类：门槛 threshold、系数 k、a_set(恒-)、t_set(走门槛)。原版行号见注释。
	var threshold := 0
	var k := 50
	var a_set: Array[int] = [0]
	var t_set: Array[int] = [1]
	match category_idx:
		W.I_PARTY_SYSTEM:  # :986-1007
			threshold = 7
			k = 150
			t_set = [1, 2]
		W.I_ECON_SYSTEM:  # :1008-1029
			threshold = 13
			k = 150
		W.I_PRESS_POLICY:  # :1030-1051
			threshold = 18
		W.I_TERRITORY:  # :1052-1073
			threshold = 21
			a_set = [0, 2]
		W.I_RELIGION:  # :1074-1095
			threshold = 27
			a_set = [0, 2]
		W.I_MIL_DOCTRINE:  # :1096-1117
			threshold = 32
			a_set = [0, 2]
		_:
			return
	for p in world.politicians:
		if p == null:
			continue
		var t: int = p.trait_personality
		var shift := 0
		if t in a_set:
			shift = -delta * k
		elif t in t_set:
			shift = (-delta * k) if target_val >= threshold else (delta * k)
		else:  # 原版 else：自由派(3) 及变体值
			shift = delta * k
		p.loyalty += shift


func set_birth_policy(policy: int) -> void:
	if world == null:
		return
	var d := world.数值表
	# 原版 ChildScript：按钮 this_number=1/2/3，data[105] 值域 1=一胎 2=二胎 3=无限制（开局=2）。
	# UI 槽位传 0/1/2，此处 +1 对齐原版（ChildScript.cs:12-19）。
	var target := policy + 1
	# data[3] -= 50*(old-new)；data[8] -= 5*(4-new)
	if target < 1 or target > 3 or W.I_BIRTH_POLICY >= d.size():
		return
	var old_policy: int = d[W.I_BIRTH_POLICY]
	if old_policy == target:
		return
	d[W.I_PEOPLE_SUPPORT] -= 50 * (old_policy - target)
	d[W.I_BUDGET] -= 5 * (4 - target)
	d[W.I_BIRTH_POLICY] = target
	_notify_stats()


func set_faction_ally(faction_idx: int, want_ally: bool) -> void:
	## 忠实移植原版 Party_ally_script.OnMouseDown()：
	## 一党制(≤7)：免费 toggle；多党(>7)：仅 data[15]==8 时可结盟，按占比扣预算/特工等。
	if world == null or faction_idx >= world.factions.size():
		return
	var f: FactionData = world.factions[faction_idx]
	var d := world.数值表
	var total := 0
	for x in world.factions:
		total += maxi(x.support, 0)
	@warning_ignore("integer_division")
	var pct := int(float(f.support * 100) / float(total)) if total > 0 else 0

	if d[W.I_PARTY_SYSTEM] > 7:
		# 原版：已结盟再点不会取消（OnMouseDown 多党分支只处理未结盟）
		if not f.is_ally and d[W.I_PARTY_SYSTEM] == 8 and f.is_enabled \
				and d[W.I_AGENTS] >= pct and d[W.I_BUDGET] >= pct:
			f.is_ally = true
			if pct > 10:
				d[W.I_PARTY_SUPPORT] -= pct * 5
				d[W.I_PEOPLE_SUPPORT] -= pct
				d[W.I_DIPLO] -= 10
				d[W.I_BUDGET] -= pct
				d[W.I_AGENTS] -= pct
				d[W.I_THOUGHT_FREEDOM] -= pct
			else:
				d[W.I_PARTY_SUPPORT] -= 50
				d[W.I_PEOPLE_SUPPORT] -= 10
				d[W.I_DIPLO] -= 10
				d[W.I_BUDGET] -= 10
				d[W.I_AGENTS] -= 10
				d[W.I_THOUGHT_FREEDOM] -= 10
				if world.factions.size() > FactionData.CONSERVATIVE:
					world.factions[FactionData.CONSERVATIVE].support += f.support
				f.support = 0
	else:
		f.is_ally = want_ally if f.is_enabled else false
	# 原版每次点击后都按 party_number 重算执政路线 data[56]
	_update_political_line(d, world)
	_notify_stats()


## 原版 Party_zapret 保护规则：领袖 traits[0]=0→保护0；=20→保护1；1..3→保护 traits[0]+1
func _faction_protected_by_leader(faction_idx: int) -> bool:
	if world == null or world.leader == null:
		return false
	var t: int = world.leader.trait_personality
	if t == 0:
		return faction_idx == 0
	if t == 20:
		return faction_idx == FactionData.CONSERVATIVE
	if t >= 1 and t <= 3:
		return faction_idx == t + 1
	return false


## 原版 Party_zapret 能否禁止判定
func _can_ban_faction(faction_idx: int) -> bool:
	if world == null or faction_idx >= world.factions.size():
		return false
	var f: FactionData = world.factions[faction_idx]
	var d := world.数值表
	if not f.is_enabled:
		return false
	if d[W.I_PARTY_SUPPORT] <= 0 or d[W.I_PARTY_BAN_COUNT] >= 4 or d[W.I_PARTY_SYSTEM] == 9:
		return false
	if _faction_protected_by_leader(faction_idx):
		return false
	if d[W.I_PARTY_SYSTEM] > 7 and faction_idx == FactionData.CONSERVATIVE:
		return false
	return true


## 原版 Party_zapret 能否解除禁止判定：多党下保守派(1)不可解禁
func _can_unban_faction(faction_idx: int) -> bool:
	if world == null:
		return false
	var d := world.数值表
	return d[W.I_PARTY_SYSTEM] <= 7 or faction_idx != FactionData.CONSERVATIVE


## UI 查询用的公开包装（不暴露下划线内部函数）
func can_ban_faction(faction_idx: int) -> bool:
	return _can_ban_faction(faction_idx)


func can_unban_faction(faction_idx: int) -> bool:
	return _can_unban_faction(faction_idx)


func set_faction_enabled(faction_idx: int, want_enabled: bool) -> void:
	## 忠实移植原版 Party_zapret.OnMouseDown() 的禁止/解禁语义。
	if world == null or faction_idx >= world.factions.size():
		return
	var f: FactionData = world.factions[faction_idx]
	if want_enabled == f.is_enabled:
		return
	if f.is_enabled:
		if _can_ban_faction(faction_idx):
			_ban_faction(faction_idx)
	else:
		if _can_unban_faction(faction_idx):
			_unban_faction(faction_idx)
	_update_political_line(world.数值表, world)
	_notify_stats()


func _ban_faction(faction_idx: int) -> void:
	var f: FactionData = world.factions[faction_idx]
	var d := world.数值表
	var total := 0
	for x in world.factions:
		total += maxi(x.support, 0)
	# 原版用 float 除法再转 int（截断），这里保持一致
	var pct := int(float(f.support * 100) / float(total)) if total > 0 else 0
	d[W.I_PARTY_BAN_COUNT] += 1
	f.is_enabled = false
	f.support = 0
	f.is_ally = false
	if d[W.I_PARTY_SYSTEM] > 7:
		# 原版在此分支先置 ally=false 再判 ally，因此恒走 else：国际声望+10
		d[W.I_DIPLO] += 10
		d[W.I_PEOPLE_SUPPORT] -= pct * 20
		d[W.I_THOUGHT_FREEDOM] += pct * 30
		if d[W.I_PARTY_BAN_COUNT] >= 4:
			_force_party_system_reset(d)
	else:
		d[W.I_THOUGHT_FREEDOM] += pct * 20
		d[W.I_PARTY_SUPPORT] -= pct * 30
		if f.ideology > 0:
			_transfer_ideology_forward(faction_idx)


func _unban_faction(faction_idx: int) -> void:
	var f: FactionData = world.factions[faction_idx]
	var d := world.数值表
	if d[W.I_PARTY_SYSTEM] > 7:
		d[W.I_PEOPLE_SUPPORT] += 40
		d[W.I_THOUGHT_FREEDOM] += 60
	else:
		d[W.I_PARTY_SUPPORT] -= 150
		if f.ideology > 0:
			_transfer_ideology_backward(faction_idx)
	d[W.I_PARTY_BAN_COUNT] -= 1
	f.is_enabled = true
	f.support = f.ideology if (f.ideology > 0 and d[W.I_PARTY_SYSTEM] <= 7) else 0


## Party_zapret 禁止时把本派基础意识形态转移到下一个启用派系
func _transfer_ideology_forward(faction_idx: int) -> void:
	for k in range(faction_idx + 1, world.factions.size()):
		var t: FactionData = world.factions[k]
		if t.is_enabled:
			t.support += world.factions[faction_idx].ideology
			return
	for k in range(faction_idx - 1, -1, -1):
		var t: FactionData = world.factions[k]
		if t.is_enabled:
			t.support += world.factions[faction_idx].ideology
			return


## Party_zapret 解禁时从下一启用派系扣回基础意识形态（下限=目标派系 ideology）
func _transfer_ideology_backward(faction_idx: int) -> void:
	var base: int = world.factions[faction_idx].ideology
	for k in range(faction_idx + 1, world.factions.size()):
		var t: FactionData = world.factions[k]
		if t.is_enabled:
			t.support -= base
			if t.support < t.ideology:
				t.support = t.ideology
			return
	for k in range(faction_idx - 1, 0, -1):
		var t: FactionData = world.factions[k]
		if t.is_enabled:
			t.support -= base
			if t.support < t.ideology:
				t.support = t.ideology
			return


## Party_zapret.cs:110-122 第4次禁止后的政党制度复位块
func _force_party_system_reset(d: Array[int]) -> void:
	if world.factions.size() < 5:
		return
	d[W.I_PARTY_SYSTEM] = 6
	for i in world.factions.size():
		var f: FactionData = world.factions[i]
		if i != FactionData.CONSERVATIVE:
			f.is_ally = false
		if not f.is_enabled:
			f.is_enabled = true
			if f.support <= 5:
				var rv := randi_range(0, 9)
				f.support = 10 + rv
				f.ideology = f.support
	for i in world.factions.size():
		world.factions[i].is_enabled = true
	world.factions[0].support = 0
	world.factions[1].support = 50
	world.factions[2].support = 50
	world.factions[3].support = 500
	world.factions[4].support = 400
	if d[W.I_ECON_DISPLAY] == 37:
		world.factions[3].support = 200
		world.factions[4].support = 700
	d[W.I_PARTY_BAN_COUNT] = 0
	world.数值表[170] = 999


## 执政派系判定 — 原版 GameState.IsFactionLeadeng(num)：num == data[56]
func is_faction_leading(faction_index: int) -> bool:
	if world == null or faction_index < 0:
		return false
	var d := world.数值表
	if d.size() <= W.I_POLITICAL_LINE:
		return false
	return d[W.I_POLITICAL_LINE] == faction_index


## 毛是否已逝——全项目唯一权威谓词。
## 语义标记走事件系统的 mao_dead flag（death_of_mao 各选项已 set_flag）。
## 内部 OR 一个 data[38]==100 兼容旧存档（毛死于 flag 机制加入前）：
## 这是原版把 data[38] 当“政治稳定”实为“毛死标记”的魔法数字，收编到此一处，
## 别处一律调用 is_mao_dead()，不要再写裸的 ==100 判断。
func is_mao_dead() -> bool:
	if world == null:
		return false
	if world.get_flag("mao_dead"):
		return true
	var d := world.数值表
	return d.size() > W.I_STABILITY and d[W.I_STABILITY] == 100


## POL-14：politics[0] 毛泽东在世时受保护（不可负向操作/击杀）
func is_mao_protected(pol_index: int) -> bool:
	if world == null or pol_index != 0:
		return false
	return not is_mao_dead()


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


## 自由派启用/禁用完全复刻原版 Party_zapret 手动解禁与事件路径；
## 原版不存在“改革路径自动解锁”规则，故此处不再提供任何自动解锁函数。


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
	if w.war_state == 2:
		if d[W.I_INDIA_WAR_PRESSURE] >= 1000:
			w.influence_prc += 10
			d[W.I_ARUNACHAL_STATUS] = 2
			# 原版此处调 allcountries[1].ILoveSuckCocks() 刷新中国地图 parts；
			# 项目既有裁决：地图 parts 刷新近似省略（见 _monthly_ejection_and_misc 注释）。
			d[W.I_POPULATION] += 434
			w.war_state = 0
			GameManager.start_event("event_443")
		d[W.I_POPULATION] -= 2
		if d[W.I_INDIA_WAR_PRESSURE] >= 50:
			d[W.I_INDIA_WAR_PRESSURE] -= 50
		elif w.influence_prc >= 20:
			w.influence_prc -= 20
		if d[W.I_INDIA_WAR_PRESSURE] <= 0:
			w.influence_prc -= 20
			w.war_state = 0

	# 2897-2901：瑞士(39)/古巴(138) 发展度、越南(11)/印度(19) stab 与印度亲中势力月重置。
	var switzerland := w.get_country_by_legacy_index(39)
	if switzerland != null:
		switzerland.development = 0
	var vietnam := w.get_country_by_legacy_index(11)
	if vietnam != null:
		vietnam.stab = 0
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


# ── 双周：已解锁科技持续加成（TimeScript 4974-5263行） ──
## 原版每双周对所有已解锁科技重复施加效果（非一次性）。
## 航天科技 27-33 本步补齐（原版 DLC02 内容，本移植按项目惯例无条件开放）。
## 原版 empires[0]=USA、empires[1]=USSR；relations 均为 ×10 存储。
## TimeScript.cs:11173-11717 TraitInfluence 逐字移植。
## 原版 dlc[0] 内的 gamerules[7]/[8] 分支因 gamerules 移植说明而跳过（项目既有裁决）。
func _fortnight_trait_influence(d: Array[int], w: WorldState) -> void:
	for i in w.politicians.size():
		var p: PoliticianData = w.politicians[i]
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		if _mod_active(w, 14):
			if p.trait_personality == 2:
				p.power += 10
			elif p.trait_personality == 3 and _faction_leader_slot(w, i) != 4:
				p.power += 5
		if _faction_leader_slot(w, i) >= 0:
			p.power += 20
		# dlc[0] 块：gamerules 移植说明，跳过（TimeScript.cs:11208-11231）。
		if _in_central_office(w, i):
			_trait_influence_central(w, d, p)
		if _is_foreign_minister(w, i):
			_trait_influence_foreign(w, d, p, i)
		if _is_premier(w, i):
			_trait_influence_premier(w, d, p, i)
		if _is_chairman(w, i):
			_trait_influence_chairman(w, d, p, i)


## TraitInfluence 的 traits[3]/traits[1]/traits[2] 中央职务块（TimeScript.cs:11233-11695）。
func _trait_influence_central(w: WorldState, d: Array[int], p: PoliticianData) -> void:
	if p.trait_personality == 0:
		if _dv(d, 56) != 0:
			_addi(d, 1, -2)
		_addi(d, 5, 2)
		_add_empire_relation(w, 1, 2)
		_addi(d, 68, -1)
		_addi(d, 26, -2)
	elif p.trait_personality == 20:
		if _dv(d, 56) == 1:
			_addi(d, 1, 1)
		_addi(d, 4, 1)
		_addi(d, 5, 1)
		_add_empire_relation(w, 1, 3)
		_addi(d, 68, -1)
		_addi(d, 26, -1)
	elif p.trait_personality == 1:
		if _dv(d, 56) != 2:
			_addi(d, 1, 1)
		else:
			_addi(d, 1, 2)
		_addi(d, 4, 1)
		_addi(d, 5, 1)
	elif p.trait_personality == 2:
		if _dv(d, 56) != 3:
			_addi(d, 1, 4)
		else:
			_addi(d, 1, 5)
		_addi(d, 5, -2)
		_addi(d, 4, 2)
	elif p.trait_personality == 3:
		if _dv(d, 56) != 4:
			_addi(d, 1, 9)
		else:
			_addi(d, 1, 10)
		_addi(d, 5, -5)
		_addi(d, 4, 7)
	match p.trait_background:
		21:
			_addi(d, W.I_PARTY_SUPPORT, 3)
			_addi(d, W.I_PEOPLE_SUPPORT, -1)
			_addi(d, W.I_THOUGHT_FREEDOM, -2)
			if p.trait_personality == 1 or p.trait_personality == 2:
				_addi(d, W.I_CORRUPTION, 1)
			elif p.trait_personality == 3:
				_addi(d, W.I_CORRUPTION, 2)
		22:
			_addi(d, W.I_PARTY_SUPPORT, -2)
			_addi(d, W.I_PEOPLE_SUPPORT, 3)
			_addi(d, W.I_ARMY, 1)
			_addi(d, W.I_LIVING, 1)
			_addi(d, W.I_CORRUPTION, -1)
		23:
			_addi(d, W.I_PARTY_SUPPORT, -3)
			_addi(d, W.I_THOUGHT_FREEDOM, -3)
			_addi(d, W.I_CORRUPTION, -1)
		24:
			_addi(d, W.I_PEOPLE_SUPPORT, 3)
			_addi(d, W.I_INDUSTRY, 1)
			_addi(d, W.I_AGRICULTURE, 1)
			_addi(d, W.I_SERVICES, 1)
			_addi(d, W.I_LIVING, -1)
		25:
			_addi(d, W.I_PARTY_SUPPORT, -2)
			_addi(d, W.I_PEOPLE_SUPPORT, -2)
			_addi(d, W.I_THOUGHT_FREEDOM, -5)
			_addi(d, W.I_ARMY, 1)
			_addi(d, W.I_LIVING, -1)
			if p.trait_personality != 0:
				_addi(d, W.I_CORRUPTION, 1)
		26:
			_addi(d, W.I_LIVING, 1)
			_addi(d, W.I_SCIENCE, 1)
			if p.trait_personality == 0:
				_addi(d, W.I_PARTY_SUPPORT, -2)
				_addi(d, W.I_PEOPLE_SUPPORT, 2)
				_addi(d, W.I_THOUGHT_FREEDOM, -2)
			elif p.trait_personality == 20 or p.trait_personality == 1:
				_addi(d, W.I_PARTY_SUPPORT, 1)
				_addi(d, W.I_PEOPLE_SUPPORT, 1)
				_addi(d, W.I_THOUGHT_FREEDOM, 1)
			elif p.trait_personality == 2:
				_addi(d, W.I_PARTY_SUPPORT, 2)
				_addi(d, W.I_PEOPLE_SUPPORT, -2)
				_addi(d, W.I_THOUGHT_FREEDOM, 1)
			elif p.trait_personality == 3:
				_addi(d, W.I_PARTY_SUPPORT, 4)
				_addi(d, W.I_PEOPLE_SUPPORT, -4)
				_addi(d, W.I_THOUGHT_FREEDOM, 2)
		27:
			_addi(d, W.I_PARTY_SUPPORT, 3)
			_addi(d, W.I_PEOPLE_SUPPORT, 3)
			_addi(d, W.I_ARMY, 1)
			_addi(d, W.I_LIVING, 2)
			_addi(d, W.I_SCIENCE, 6)
		28:
			_addi(d, W.I_PARTY_SUPPORT, -5)
			_addi(d, W.I_PEOPLE_SUPPORT, -3)
			_addi(d, W.I_THOUGHT_FREEDOM, -2)
			_addi(d, W.I_AGENTS, 3)
		43:
			_addi(d, W.I_SCIENCE, 5)
	match p.trait_alignment:
		4:
			_addi(d, W.I_CORRUPTION, -1)
			_addi(d, W.I_THOUGHT_FREEDOM, -5)
			_addi(d, W.I_PARTY_SUPPORT, -2)
		5:
			_addi(d, W.I_PARTY_SUPPORT, 2)
		6:
			_addi(d, W.I_CORRUPTION, 1)
			_addi(d, W.I_THOUGHT_FREEDOM, 5)
			_addi(d, W.I_PARTY_SUPPORT, 5)
		7:
			_addi(d, W.I_SCIENCE, 2)
		29:
			_addi(d, W.I_PARTY_SUPPORT, 3)
			_addi(d, W.I_PEOPLE_SUPPORT, -5)
			_addi(d, W.I_THOUGHT_FREEDOM, 3)
			_add_empire_relation(w, 0, 2)
			if d.size() > W.I_SERVICES:
				d[W.I_SERVICES] += 1 if d[W.I_SERVICES] < 60 else -1
			if d.size() > W.I_LIVING:
				d[W.I_LIVING] += 2 if d[W.I_LIVING] < 50 else -2
		30:
			_addi(d, W.I_PARTY_SUPPORT, -3)
			_addi(d, W.I_PEOPLE_SUPPORT, -5)
			_addi(d, W.I_MANPOWER, -3)
			match p.trait_personality:
				0: _addi(d, W.I_THOUGHT_FREEDOM, -5)
				20: _addi(d, W.I_THOUGHT_FREEDOM, -3)
				2: _addi(d, W.I_THOUGHT_FREEDOM, 3)
				3: _addi(d, W.I_THOUGHT_FREEDOM, 5)
			match p.trait_personality:
				0, 1: _addi(d, W.I_WAR_SUPPORT, 3)
				20: _addi(d, W.I_WAR_SUPPORT, 6)
				2: _addi(d, W.I_WAR_SUPPORT, -3)
				3: _addi(d, W.I_WAR_SUPPORT, -6)
		39:
			_addi(d, W.I_PARTY_SUPPORT, -2)
			_addi(d, W.I_PEOPLE_SUPPORT, -1)
			_addi(d, W.I_THOUGHT_FREEDOM, -5)
			_addi(d, W.I_INDUSTRY, -1)
			_addi(d, W.I_MANPOWER, -1)
		40:
			_addi(d, W.I_PARTY_SUPPORT, 3)
			_addi(d, W.I_CORRUPTION, 1)
		41:
			_addi(d, W.I_PARTY_SUPPORT, 5)
			_addi(d, W.I_PEOPLE_SUPPORT, 2)
			_addi(d, W.I_BUDGET, -3)
			_addi(d, W.I_CORRUPTION, 1)
			if p.trait_personality == 0 or p.trait_personality == 20:
				_addi(d, W.I_THOUGHT_FREEDOM, -1)
			elif p.trait_personality == 3:
				_addi(d, W.I_THOUGHT_FREEDOM, 1)
		42:
			_addi(d, W.I_PARTY_SUPPORT, -3)
			_addi(d, W.I_PEOPLE_SUPPORT, 3)
			if p.trait_personality == 0:
				_addi(d, W.I_THOUGHT_FREEDOM, -3)
	match p.trait_special:
		8:
			_addi(d, W.I_THOUGHT_FREEDOM, -10)
			_addi(d, W.I_PARTY_SUPPORT, -5)
		9:
			_addi(d, W.I_THOUGHT_FREEDOM, 3)
			_addi(d, W.I_PARTY_SUPPORT, 3)
		10:
			_addi(d, W.I_PARTY_SUPPORT, -5)
			_addi(d, W.I_PEOPLE_SUPPORT, -5)
		11:
			_addi(d, W.I_BUDGET, 3)
		12:
			_addi(d, W.I_THOUGHT_FREEDOM, -3)
			_addi(d, W.I_PARTY_SUPPORT, -4)
		13:
			_addi(d, W.I_PARTY_SUPPORT, 6)
		14:
			_addi(d, W.I_PARTY_SUPPORT, 3)
			_addi(d, W.I_THOUGHT_FREEDOM, 3)
			_addi(d, W.I_WAR_SUPPORT, 6)
		15:
			_addi(d, W.I_PARTY_SUPPORT, -3)
			_addi(d, W.I_THOUGHT_FREEDOM, 3)
			_addi(d, W.I_WAR_SUPPORT, -6)
		16:
			_addi(d, W.I_PARTY_SUPPORT, 4)
			_addi(d, W.I_AGENTS, 3)
		17:
			_addi(d, W.I_THOUGHT_FREEDOM, 2)
		18:
			_addi(d, W.I_CORRUPTION, 3)
			_addi(d, W.I_PARTY_SUPPORT, 5)
			_addi(d, W.I_BUDGET, -1)
		19:
			_addi(d, W.I_PARTY_SUPPORT, 1)
			_addi(d, W.I_THOUGHT_FREEDOM, 2)
		31:
			match p.trait_personality:
				0:
					_addi(d, W.I_PARTY_SUPPORT, -2)
					_addi(d, W.I_PEOPLE_SUPPORT, 5)
					_addi(d, W.I_THOUGHT_FREEDOM, -2)
				20:
					_addi(d, W.I_PARTY_SUPPORT, 1)
					_addi(d, W.I_PEOPLE_SUPPORT, 3)
					_addi(d, W.I_THOUGHT_FREEDOM, -1)
				1:
					_addi(d, W.I_PARTY_SUPPORT, 4)
					_addi(d, W.I_PEOPLE_SUPPORT, 1)
					_addi(d, W.I_THOUGHT_FREEDOM, 2)
				2:
					_addi(d, W.I_PARTY_SUPPORT, 5)
					_addi(d, W.I_PEOPLE_SUPPORT, -3)
					_addi(d, W.I_THOUGHT_FREEDOM, 3)
				3:
					_addi(d, W.I_PARTY_SUPPORT, -3)
					_addi(d, W.I_PEOPLE_SUPPORT, -5)
					_addi(d, W.I_THOUGHT_FREEDOM, 5)
		32:
			_addi(d, W.I_PEOPLE_SUPPORT, 6)
			_addi(d, W.I_THOUGHT_FREEDOM, -3)
		33:
			_addi(d, W.I_PARTY_SUPPORT, 1)
			_add_empire_relation(w, 0, 1)
			_add_empire_relation(w, 1, 1)
		34:
			_addi(d, W.I_PARTY_SUPPORT, -3)
			_addi(d, W.I_PEOPLE_SUPPORT, -2)
			_addi(d, W.I_THOUGHT_FREEDOM, -5)
			_addi(d, W.I_MANPOWER, -3)
		35:
			_addi(d, W.I_PARTY_SUPPORT, -5)
			_addi(d, W.I_PEOPLE_SUPPORT, -3)
			_addi(d, W.I_AGENTS, 3)
		36:
			_addi(d, W.I_PARTY_SUPPORT, -2)
			_addi(d, W.I_PEOPLE_SUPPORT, -2)
			_addi(d, W.I_THOUGHT_FREEDOM, -5)
			_addi(d, W.I_ARMY, 1)
			_addi(d, W.I_LIVING, -1)
		37:
			_addi(d, W.I_PARTY_SUPPORT, 3)
		38:
			_addi(d, W.I_PARTY_SUPPORT, 2)
			_addi(d, W.I_THOUGHT_FREEDOM, -3)
			_addi(d, W.I_LIVING, -1)


## TraitInfluence 外交部块（politics_dolshnost[2] == i，TimeScript.cs:11696-11717 之前）。
func _trait_influence_foreign(w: WorldState, d: Array[int], p: PoliticianData, i: int) -> void:
	if _is_foreign_minister(w, i):
		if p.trait_personality == 0:
			_add_empire_relation(w, 0, -10)
			if _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 900:
				_addi(d, 6, 1)
			_add_ideology_share(w, 0, 666)
			_add_ideology_share(w, 1, 1000)
		elif p.trait_personality == 20:
			_add_empire_relation(w, 1, 5)
			_add_empire_relation(w, 0, 2)
			if _dv(d, 6) < 500:
				_addi(d, 6, 3)
			elif _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) > 1000:
				_addi(d, 6, -1)
			_add_ideology_share(w, 2, 1000)
			_add_ideology_share(w, 1, 333)
		elif p.trait_personality == 1:
			_add_empire_relation(w, 1, 10)
			_add_empire_relation(w, 0, -3)
			if _dv(d, 6) < 500:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 700:
				_addi(d, 6, 1)
			elif _dv(d, 6) > 900:
				_addi(d, 6, -1)
			_add_ideology_share(w, 2, 333)
			_add_ideology_share(w, 3, 666)
			_add_ideology_share(w, 1, 2000)
		elif p.trait_personality == 2:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, 5)
			if _dv(d, 6) < 300:
				_addi(d, 6, 1)
			elif _dv(d, 6) > 700:
				_addi(d, 6, -2)
			elif _dv(d, 6) > 500:
				_addi(d, 6, -1)
			_add_ideology_share(w, 3, 666)
			_add_ideology_share(w, 4, 666)
		elif p.trait_personality == 3:
			_add_empire_relation(w, 1, -10)
			_add_empire_relation(w, 0, 12)
			if _dv(d, 6) > 700:
				_addi(d, 6, -3)
			elif _dv(d, 6) > 500:
				_addi(d, 6, -2)
			elif _dv(d, 6) > 300:
				_addi(d, 6, -1)
			_add_ideology_share(w, 3, 666)
			_add_ideology_share(w, 4, 666)
		if p.trait_background == 21:
			_add_empire_relation(w, 1, 5)
			_add_empire_relation(w, 0, 2)
			if _dv(d, 6) < 500:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 700:
				_addi(d, 6, 1)
			elif _dv(d, 6) > 900:
				_addi(d, 6, -1)
		elif p.trait_background == 22:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -8)
			if _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 900:
				_addi(d, 6, 1)
		elif p.trait_background == 23:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -8)
			if _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 900:
				_addi(d, 6, 1)
		elif p.trait_background == 24:
			_add_empire_relation(w, 1, -2)
			_add_empire_relation(w, 0, -5)
			if _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 900:
				_addi(d, 6, 1)
		elif p.trait_background == 25:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			if _dv(d, 6) < 500:
				_addi(d, 6, 3)
			elif _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) > 1000:
				_addi(d, 6, -1)
		elif p.trait_background == 26:
			if p.trait_personality == 0:
				_add_empire_relation(w, 1, -5)
				_add_empire_relation(w, 0, -5)
				_addi(d, 6, 1)
			elif p.trait_personality == 20:
				_add_empire_relation(w, 1, 4)
				_add_empire_relation(w, 0, 2)
			elif p.trait_personality == 1:
				_add_empire_relation(w, 1, 6)
				_add_empire_relation(w, 0, -2)
			elif p.trait_personality == 2:
				_add_empire_relation(w, 1, -3)
				_add_empire_relation(w, 0, 5)
				_addi(d, 6, -1)
			elif p.trait_personality == 3:
				_add_empire_relation(w, 1, -6)
				_add_empire_relation(w, 0, 8)
				_addi(d, 6, -2)
		elif p.trait_background == 27:
			_addi(d, 11, 6)
		elif p.trait_background == 28:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
		elif p.trait_background == 43:
			_addi(d, 11, 5)
		if p.trait_alignment == 4:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
		elif p.trait_alignment == 5:
			_add_empire_relation(w, 1, 5)
			_add_empire_relation(w, 0, 5)
			if _dv(d, 6) < 700:
				_addi(d, 6, 1)
			else:
				_addi(d, 6, -1)
		elif p.trait_alignment == 6:
			_add_empire_relation(w, 1, 6)
			_add_empire_relation(w, 0, 6)
			if _dv(d, 6) > 600:
				_addi(d, 6, -1)
		elif p.trait_alignment == 7:
			_addi(d, 11, 2)
		elif p.trait_alignment == 29:
			_add_empire_relation(w, 0, 6)
			_addi(d, 6, -1)
		elif p.trait_alignment == 30:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			if _dv(d, 6) < 700:
				_addi(d, 6, 1)
			elif _dv(d, 6) > 900:
				_addi(d, 6, -1)
		elif p.trait_alignment == 39:
			_addi(d, 8, -1)
			if p.trait_personality == 0 or p.trait_personality == 20:
				_addi(d, 6, 2)
				_add_empire_relation(w, 1, 6)
				_add_empire_relation(w, 0, -6)
			elif p.trait_personality == 2 or p.trait_personality == 3:
				_addi(d, 6, -2)
				_add_empire_relation(w, 1, -6)
				_add_empire_relation(w, 0, 6)
		elif p.trait_alignment == 40:
			if _rel(w, 1) < 400:
				_add_empire_relation(w, 1, -3)
			elif _rel(w, 1) > 600:
				_add_empire_relation(w, 1, 3)
			if _rel(w, 0) < 400:
				_add_empire_relation(w, 0, -3)
			elif _rel(w, 0) > 600:
				_add_empire_relation(w, 0, 3)
			if _dv(d, 6) > 900:
				_addi(d, 6, 1)
			elif _dv(d, 6) < 500:
				_addi(d, 6, -1)
		elif p.trait_alignment == 41:
			_addi(d, 8, -1)
			if p.trait_personality == 0:
				_add_empire_relation(w, 1, -4)
				_add_empire_relation(w, 0, -4)
				_addi(d, 6, 1)
			elif p.trait_personality == 20:
				_add_empire_relation(w, 0, -1)
			elif p.trait_personality == 1:
				_add_empire_relation(w, 0, -1)
			elif p.trait_personality == 2:
				_add_empire_relation(w, 0, 3)
				_addi(d, 6, -1)
			elif p.trait_personality == 3:
				_add_empire_relation(w, 1, -4)
				_add_empire_relation(w, 0, 3)
				_addi(d, 6, -2)
		elif p.trait_alignment == 42:
			_addi(d, 8, -1)
			if p.trait_personality == 0:
				_add_empire_relation(w, 1, -6)
				_add_empire_relation(w, 0, -6)
				_addi(d, 6, 5)
				_add_ideology_share(w, 0, 1000)
			elif p.trait_personality == 3:
				_add_empire_relation(w, 1, -6)
				_add_empire_relation(w, 0, 6)
				_addi(d, 6, -5)
				_add_ideology_share(w, 4, 1000)
		if p.trait_special == 8:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			if _dv(d, 6) < 500:
				_addi(d, 6, 3)
			elif _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 1000:
				_addi(d, 6, 1)
		elif p.trait_special == 9:
			_add_empire_relation(w, 1, 4)
			_add_empire_relation(w, 0, 4)
			if _dv(d, 6) > 700:
				_addi(d, 6, -1)
		elif p.trait_special == 10:
			_add_empire_relation(w, 1, -6)
			_add_empire_relation(w, 0, -6)
			_addi(d, 6, 2)
		elif p.trait_special == 11:
			_add_empire_relation(w, 1, -2)
			_add_empire_relation(w, 0, -2)
			_addi(d, 8, 2)
		elif p.trait_special == 12:
			_add_empire_relation(w, 1, -4)
			_add_empire_relation(w, 0, -4)
			_addi(d, 6, 1)
		elif p.trait_special == 13:
			_add_empire_relation(w, 1, 4)
			_add_empire_relation(w, 0, 4)
		elif p.trait_special == 14:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			if _dv(d, 6) < 500:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 800:
				_addi(d, 6, 1)
			elif _dv(d, 6) > 900:
				_addi(d, 6, -1)
		elif p.trait_special == 15:
			_add_empire_relation(w, 1, -6)
			_add_empire_relation(w, 0, 6)
			_addi(d, 6, -1)
		elif p.trait_special == 16:
			_add_empire_relation(w, 1, 4)
			_add_empire_relation(w, 0, 4)
		elif p.trait_special == 17:
			_add_empire_relation(w, 1, -1)
			_add_empire_relation(w, 0, -1)
			_addi(d, 6, -1)
		elif p.trait_special == 18:
			_add_empire_relation(w, 1, -2)
			_add_empire_relation(w, 0, -2)
			_addi(d, 8, -1)
		elif p.trait_special == 19:
			_add_empire_relation(w, 1, -2)
			_add_empire_relation(w, 0, -2)
			_addi(d, 6, -1)
		elif p.trait_special == 31:
			if p.trait_personality == 0:
				_add_empire_relation(w, 1, -3)
				_add_empire_relation(w, 0, -3)
				_addi(d, 6, 1)
			elif p.trait_personality == 20:
				_add_empire_relation(w, 1, 3)
				_add_empire_relation(w, 0, 1)
			elif p.trait_personality == 1:
				_add_empire_relation(w, 1, 5)
				_add_empire_relation(w, 0, -1)
			elif p.trait_personality == 2:
				_add_empire_relation(w, 1, -2)
				_add_empire_relation(w, 0, 4)
				_addi(d, 6, -1)
			elif p.trait_personality == 3:
				_add_empire_relation(w, 1, -4)
				_add_empire_relation(w, 0, 6)
				_addi(d, 6, -2)
		elif p.trait_special == 32:
			_add_empire_relation(w, 1, -4)
			_add_empire_relation(w, 0, -4)
		elif p.trait_special == 33:
			_add_empire_relation(w, 1, 6)
			_add_empire_relation(w, 0, 6)
			if _dv(d, 6) < 500:
				_addi(d, 6, 3)
			elif _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 900:
				_addi(d, 6, 1)
			elif _dv(d, 6) > 1000:
				_addi(d, 6, -1)
		elif p.trait_special == 34:
			_add_empire_relation(w, 1, -5)
			_add_empire_relation(w, 0, -1)
		elif p.trait_special == 35:
			_addi(d, 6, -1)
			if _emp_pow(w, 1) > _emp_pow(w, 0):
				_add_empire_relation(w, 1, 5)
				_add_empire_relation(w, 0, -5)
			else:
				_add_empire_relation(w, 1, -5)
				_add_empire_relation(w, 0, 5)
		elif p.trait_special == 36:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			_addi(d, 6, 1)
		elif p.trait_special == 37:
			_add_empire_relation(w, 1, 2)
			_add_empire_relation(w, 0, 2)
			_addi(d, 6, -1)
		elif p.trait_special == 38:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			_addi(d, 6, 1)


## TraitInfluence 的总理块 politics_dolshnost[1]（TimeScript.cs:12187-12658 逐字移植）。
func _trait_influence_premier(w: WorldState, d: Array[int], p: PoliticianData, i: int) -> void:
	if _is_premier(w, i):
		if p.trait_personality == 0:
			if _dv(d, 56) != 0:
				_addi(d, 1, -6)
			else:
				_addi(d, 1, -3)
			_addi(d, 5, 6)
			_add_empire_relation(w, 1, 3)
			_addi(d, 68, -1)
			_addi(d, 26, -2)
			_add_ideology_share(w, 0, 333)
			_add_ideology_share(w, 1, 500)
		elif p.trait_personality == 20:
			if _dv(d, 56) != 1:
				_addi(d, 1, 4)
			else:
				_addi(d, 1, 5)
			_addi(d, 5, 4)
			_addi(d, 4, 1)
			_addi(d, 26, -1)
			_add_empire_relation(w, 1, 5)
			_add_ideology_share(w, 2, 2000)
			_add_ideology_share(w, 1, 222)
		elif p.trait_personality == 1:
			if _dv(d, 56) != 2:
				_addi(d, 1, 5)
			else:
				_addi(d, 1, 6)
			_addi(d, 5, 2)
			_addi(d, 4, 3)
			_add_ideology_share(w, 2, 222)
			_add_ideology_share(w, 3, 333)
			_add_ideology_share(w, 1, 2000)
		elif p.trait_personality == 2:
			if _dv(d, 56) != 3:
				_addi(d, 1, 6)
			else:
				_addi(d, 1, 7)
			_addi(d, 5, -3)
			_addi(d, 4, 5)
			_add_ideology_share(w, 3, 222)
			_add_ideology_share(w, 4, 333)
		elif p.trait_personality == 3:
			if _dv(d, 56) != 4:
				_addi(d, 1, 8)
			else:
				_addi(d, 1, 10)
			_addi(d, 5, -7)
			_addi(d, 4, 5)
			_addi(d, 8, 2)
			_add_ideology_share(w, 3, 333)
			_add_ideology_share(w, 4, 222)
		if p.trait_background == 21:
			_addi(d, 1, 5)
			_addi(d, 3, -2)
			_addi(d, 4, -3)
			if p.trait_personality == 1  or  p.trait_personality == 2:
				_addi(d, 26, 1)
			elif p.trait_personality == 3:
				_addi(d, 26, 2)
		elif p.trait_background == 22:
			_addi(d, 1, -4)
			_addi(d, 3, 5)
			_addi(d, 22, 5)
			_addi(d, 5, 3)
			_addi(d, 26, -2)
		elif p.trait_background == 23:
			_addi(d, 1, -5)
			_addi(d, 4, -8)
			_addi(d, 22, -3)
			_addi(d, 26, -2)
		elif p.trait_background == 24:
			_addi(d, 1, -3)
			_addi(d, 3, 5)
			_addi(d, 12, 2)
			_addi(d, 13, 2)
			_addi(d, 68, 1)
			_addi(d, 5, -3)
		elif p.trait_background == 25:
			_addi(d, 1, 5)
			_addi(d, 4, -10)
			_addi(d, 22, 12)
			_addi(d, 5, -5)
		elif p.trait_background == 26:
			_addi(d, 22, -5)
			_addi(d, 5, 3)
			_addi(d, 11, 3)
			if p.trait_personality == 0:
				_addi(d, 1, -5)
				_addi(d, 3, 2)
				_addi(d, 4, -5)
			elif p.trait_personality == 20  or  p.trait_personality == 1:
				_addi(d, 1, 2)
				_addi(d, 3, 2)
				_addi(d, 4, 2)
			elif p.trait_personality == 2:
				_addi(d, 1, 4)
				_addi(d, 3, -4)
				_addi(d, 4, 4)
			elif p.trait_personality == 3:
				_addi(d, 1, 5)
				_addi(d, 3, -5)
				_addi(d, 4, 6)
		elif p.trait_background == 27:
			_addi(d, 1, 6)
			_addi(d, 3, 6)
			_addi(d, 22, 8)
			_addi(d, 5, 2)
			_addi(d, 11, 10)
		elif p.trait_background == 28:
			_addi(d, 1, -7)
			_addi(d, 3, -5)
			_addi(d, 4, -5)
			_addi(d, 9, 6)
		elif p.trait_background == 43:
			_addi(d, 11, 8)
		if p.trait_alignment == 4:
			_addi(d, 26, -1)
			_addi(d, 4, -7)
			_addi(d, 1, -3)
		elif p.trait_alignment == 5:
			_addi(d, 1, 3)
		elif p.trait_alignment == 6:
			_addi(d, 26, 1)
			_addi(d, 4, 7)
			_addi(d, 1, 7)
		elif p.trait_alignment == 7:
			_addi(d, 11, 3)
		elif p.trait_alignment == 29:
			_addi(d, 1, 6)
			_addi(d, 3, -8)
			_addi(d, 4, 6)
			_addi(d, 22, -6)
			if _dv(d, 68) < 60:
				_addi(d, 68, 2)
			else:
				_addi(d, 68, -2)
			if _dv(d, 5) < 50:
				_addi(d, 5, 4)
			else:
				_addi(d, 5, -4)
		elif p.trait_alignment == 30:
			_addi(d, 1, -6)
			_addi(d, 3, -8)
			_addi(d, 57, -5)
			if p.trait_personality == 0:
				_addi(d, 4, -8)
			elif p.trait_personality == 20:
				_addi(d, 4, -4)
			elif p.trait_personality == 2:
				_addi(d, 4, 4)
			elif p.trait_personality == 3:
				_addi(d, 4, 8)
			if p.trait_personality == 0  or  p.trait_personality == 1:
				_addi(d, 31, 5)
			elif p.trait_personality == 20:
				_addi(d, 31, 10)
			elif p.trait_personality == 2:
				_addi(d, 31, -5)
			elif p.trait_personality == 3:
				_addi(d, 31, -10)
		elif p.trait_alignment == 39:
			_addi(d, 1, -5)
			_addi(d, 3, -3)
			_addi(d, 4, -8)
			_addi(d, 22, 3)
			_addi(d, 9, 3)
			_addi(d, 57, -2)
			_addi(d, 8, -2)
		elif p.trait_alignment == 40:
			_addi(d, 1, 6)
			_addi(d, 3, -3)
			_addi(d, 26, 2)
			if _dv(d, 51) == 30:
				_addi(d, 22, 4)
				_addi(d, 8, -4)
			elif _dv(d, 51) == 31  or  _dv(d, 51) == 32:
				_addi(d, 22, 2)
				_addi(d, 8, -2)
			elif _dv(d, 51) == 33:
				_addi(d, 8, 3)
				_addi(d, 4, 5)
		elif p.trait_alignment == 41:
			_addi(d, 8, -5)
			_addi(d, 9, -4)
			_addi(d, 4, -4)
			_addi(d, 26, 3)
			if _dv(d, 71) < 300:
				_addi(d, 1, -8)
				_addi(d, 22, 4)
			else:
				_addi(d, 1, -5)
				_addi(d, 22, 8)
		elif p.trait_alignment == 42:
			_addi(d, 1, -8)
			_addi(d, 22, 3 + d[76] / 200)
			_addi(d, 9, -3)
			if p.trait_personality == 0:
				_add_ideology_share(w, 0, 500)
			elif p.trait_personality == 3:
				_add_ideology_share(w, 4, 500)
		if p.trait_special == 8:
			_addi(d, 4, -15)
			_addi(d, 1, -7)
			_addi(d, 22, 3)
		elif p.trait_special == 9:
			_addi(d, 4, 5)
			_addi(d, 1, 6)
			_addi(d, 22, -3)
		elif p.trait_special == 10:
			_addi(d, 1, -10)
			_addi(d, 3, -10)
			_addi(d, 22, 3)
		elif p.trait_special == 11:
			_addi(d, 8, 5)
			_addi(d, 22, -5)
		elif p.trait_special == 12:
			_addi(d, 4, -5)
			_addi(d, 1, -8)
			_addi(d, 22, -3)
		elif p.trait_special == 13:
			_addi(d, 1, 12)
		elif p.trait_special == 14:
			_addi(d, 1, 5)
			_addi(d, 4, 3)
			_addi(d, 22, 3)
			_addi(d, 31, 8)
		elif p.trait_special == 15:
			_addi(d, 1, -5)
			_addi(d, 4, 3)
			_addi(d, 22, -3)
			_addi(d, 31, -8)
		elif p.trait_special == 16:
			_addi(d, 1, 6)
			_addi(d, 9, 6)
			_addi(d, 22, 3)
		elif p.trait_special == 17:
			_addi(d, 4, 5)
			_addi(d, 22, -3)
		elif p.trait_special == 18:
			_addi(d, 26, 5)
			_addi(d, 1, 7)
			_addi(d, 8, -2)
			_addi(d, 22, -3)
		elif p.trait_special == 19:
			_addi(d, 1, 2)
			_addi(d, 4, 4)
			_addi(d, 22, -2)
		elif p.trait_special == 31:
			_addi(d, 22, 3)
			if p.trait_personality == 0:
				_addi(d, 1, -4)
				_addi(d, 3, 6)
				_addi(d, 4, -4)
			elif p.trait_personality == 20:
				_addi(d, 1, 2)
				_addi(d, 3, 4)
				_addi(d, 4, -2)
			elif p.trait_personality == 1:
				_addi(d, 1, 5)
				_addi(d, 3, 2)
				_addi(d, 4, 3)
			elif p.trait_personality == 2:
				_addi(d, 1, 6)
				_addi(d, 3, -3)
				_addi(d, 4, 4)
			elif p.trait_personality == 3:
				_addi(d, 1, -5)
				_addi(d, 3, -6)
				_addi(d, 4, 8)
		elif p.trait_special == 32:
			_addi(d, 3, 12)
			_addi(d, 4, -6)
			_addi(d, 22, 5)
		elif p.trait_special == 33:
			_addi(d, 1, -3)
			_addi(d, 22, -3)
		elif p.trait_special == 34:
			_addi(d, 1, -5)
			_addi(d, 3, -3)
			_addi(d, 4, -8)
			_addi(d, 22, 2)
			_addi(d, 57, -5)
		elif p.trait_special == 35:
			_addi(d, 1, -6)
			_addi(d, 3, -4)
			_addi(d, 9, 6)
			_addi(d, 22, -3)
		elif p.trait_special == 36:
			_addi(d, 1, 6)
			_addi(d, 4, -10)
			_addi(d, 22, 10)
			_addi(d, 5, -5)
		elif p.trait_special == 37:
			_addi(d, 1, 6)
			_addi(d, 4, 2)
			_addi(d, 22, 2)
		elif p.trait_special == 38:
			_addi(d, 1, 5)
			_addi(d, 4, -6)
			_addi(d, 22, 3)
			_addi(d, 5, -2)

## TraitInfluence 的主席块 politics_dolshnost[0]（TimeScript.cs:12659-13178 逐字移植）。
func _trait_influence_chairman(w: WorldState, d: Array[int], p: PoliticianData, i: int) -> void:
	if _is_chairman(w, i):
		if p.trait_personality == 0:
			if _dv(d, 56) != 0:
				_addi(d, 1, -9)
			else:
				_addi(d, 1, -3)
			_addi(d, 5, 5)
			_add_empire_relation(w, 1, 3)
			_add_empire_relation(w, 0, -12)
			_addi(d, 68, -2)
			_addi(d, 26, -4)
			_add_ideology_share(w, 0, 333)
			_add_ideology_share(w, 1, 500)
		elif p.trait_personality == 20:
			if _dv(d, 56) == 1:
				_addi(d, 1, 2)
			_addi(d, 5, 4)
			_addi(d, 4, 3)
			_addi(d, 26, -2)
			_add_empire_relation(w, 1, 6)
			_add_empire_relation(w, 0, 2)
			_add_ideology_share(w, 2, 1000)
			_add_ideology_share(w, 1, 222)
		elif p.trait_personality == 1:
			if _dv(d, 56) != 2:
				_addi(d, 1, 5)
			else:
				_addi(d, 1, 7)
			_addi(d, 5, 3)
			_addi(d, 4, 7)
			_add_empire_relation(w, 1, 12)
			_add_empire_relation(w, 0, -3)
			_add_ideology_share(w, 2, 222)
			_add_ideology_share(w, 3, 333)
			_add_ideology_share(w, 1, 1000)
		elif p.trait_personality == 2:
			if _dv(d, 56) != 3:
				_addi(d, 1, 13)
			else:
				_addi(d, 1, 15)
			_addi(d, 5, -7)
			_addi(d, 4, 8)
			_addi(d, 6, -1)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, 5)
			_add_ideology_share(w, 3, 222)
			_add_ideology_share(w, 4, 333)
		elif p.trait_personality == 3:
			if _dv(d, 56) != 4:
				_addi(d, 1, 27)
			else:
				_addi(d, 1, 30)
			_addi(d, 5, -15)
			_addi(d, 4, 22)
			_addi(d, 8, 4)
			_addi(d, 6, -2)
			_add_empire_relation(w, 1, -10)
			_add_empire_relation(w, 0, 12)
			_add_ideology_share(w, 3, 333)
			_add_ideology_share(w, 4, 222)
		if p.trait_background == 21:
			_addi(d, 1, 6)
			_addi(d, 3, -2)
			_addi(d, 4, -8)
			if p.trait_personality == 1  or  p.trait_personality == 2:
				_addi(d, 26, 2)
			elif p.trait_personality == 3:
				_addi(d, 26, 3)
		elif p.trait_background == 22:
			_addi(d, 1, -10)
			_addi(d, 3, 12)
			_addi(d, 22, 2)
			_addi(d, 5, 5)
			_addi(d, 26, -4)
		elif p.trait_background == 23:
			_addi(d, 1, -10)
			_addi(d, 4, -12)
			_addi(d, 26, -4)
		elif p.trait_background == 24:
			_addi(d, 1, -5)
			_addi(d, 3, 12)
			_addi(d, 12, 4)
			_addi(d, 13, 4)
			_addi(d, 68, 4)
			_addi(d, 5, -5)
		elif p.trait_background == 25:
			_addi(d, 1, -6)
			_addi(d, 3, -6)
			_addi(d, 4, -10)
			_addi(d, 22, 8)
			_addi(d, 5, -6)
			_add_empire_relation(w, 1, -5)
			_add_empire_relation(w, 0, -5)
			if p.trait_personality != 0:
				_addi(d, 26, 2)
		elif p.trait_background == 26:
			_addi(d, 5, 5)
			_addi(d, 11, 5)
			if p.trait_personality == 0:
				_addi(d, 1, -4)
				_addi(d, 3, 4)
				_addi(d, 4, -4)
			elif p.trait_personality == 20  or  p.trait_personality == 1:
				_addi(d, 1, 3)
				_addi(d, 3, 3)
				_addi(d, 4, 3)
			elif p.trait_personality == 2:
				_addi(d, 1, 6)
				_addi(d, 3, -6)
				_addi(d, 4, 6)
			elif p.trait_personality == 3:
				_addi(d, 1, 10)
				_addi(d, 3, -10)
				_addi(d, 4, 10)
		elif p.trait_background == 27:
			_addi(d, 1, 10)
			_addi(d, 3, 10)
			_addi(d, 22, 5)
			_addi(d, 5, 8)
			_addi(d, 11, 18)
		elif p.trait_background == 28:
			_addi(d, 1, -10)
			_addi(d, 3, -8)
			_addi(d, 4, -10)
			_addi(d, 9, 9)
			_add_empire_relation(w, 1, -5)
			_add_empire_relation(w, 0, -5)
		elif p.trait_background == 43:
			_addi(d, 11, 15)
		if p.trait_alignment == 4:
			_addi(d, 26, -2)
			_addi(d, 4, -15)
			_addi(d, 1, -7)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
		elif p.trait_alignment == 5:
			_addi(d, 1, 7)
			_add_empire_relation(w, 1, 5)
			_add_empire_relation(w, 0, 5)
		elif p.trait_alignment == 6:
			_addi(d, 26, 2)
			_addi(d, 4, 15)
			_addi(d, 1, 15)
			_add_empire_relation(w, 1, 6)
			_add_empire_relation(w, 0, 6)
			if _dv(d, 6) > 60:
				_addi(d, 6, -1)
		elif p.trait_alignment == 7:
			_addi(d, 11, 9)
		elif p.trait_alignment == 29:
			_addi(d, 1, 8)
			_addi(d, 3, -10)
			_addi(d, 4, 10)
			_add_empire_relation(w, 0, 10)
			if _dv(d, 68) < 60:
				_addi(d, 68, 4)
			else:
				_addi(d, 68, -4)
			if _dv(d, 5) < 50:
				_addi(d, 5, 6)
			else:
				_addi(d, 5, -6)
		elif p.trait_alignment == 30:
			_addi(d, 1, -8)
			_addi(d, 3, -10)
			_addi(d, 57, -6)
			if p.trait_personality == 0:
				_addi(d, 4, -10)
			elif p.trait_personality == 20:
				_addi(d, 4, -5)
			elif p.trait_personality == 2:
				_addi(d, 4, 5)
			elif p.trait_personality == 3:
				_addi(d, 4, 10)
			if p.trait_personality == 0  or  p.trait_personality == 1:
				_addi(d, 31, 6)
			elif p.trait_personality == 20:
				_addi(d, 31, 12)
			elif p.trait_personality == 2:
				_addi(d, 31, -6)
			elif p.trait_personality == 3:
				_addi(d, 31, -12)
		elif p.trait_alignment == 39:
			_addi(d, 1, -8)
			_addi(d, 3, -5)
			_addi(d, 4, -10)
			_addi(d, 8, -5)
			_addi(d, 12, -1)
			_addi(d, 13, -1)
			_addi(d, 68, 1)
			_addi(d, 57, -3)
		elif p.trait_alignment == 40:
			_addi(d, 1, 8)
			_addi(d, 8, -3)
			_addi(d, 12, -2)
			_addi(d, 13, -2)
			_addi(d, 68, -2)
			_addi(d, 26, 3)
			if _dv(d, 17) <= 17:
				_addi(d, 4, -5)
			else:
				_addi(d, 3, 5)
			if _dv(d, 18) > 20:
				_addi(d, 31, -3)
			if _dv(d, 50) > 27:
				_addi(d, 31, 3)
		elif p.trait_alignment == 41:
			_addi(d, 8, -8)
			_addi(d, 26, 5)
			_addi(d, 57, -5)
			_addi(d, 68, 3)
			if _dv(d, 75) < 100:
				_addi(d, 1, -10)
			else:
				_addi(d, 1, -6)
		elif p.trait_alignment == 42:
			_addi(d, 1, -12)
			_addi(d, 3, 8 + d[76] / 100)
			_addi(d, 8, -5)
			_addi(d, 12, -1)
			if p.trait_personality == 0:
				_addi(d, 4, -20)
				_add_empire_relation(w, 1, -6)
				_add_empire_relation(w, 0, -6)
				_add_ideology_share(w, 0, 333)
			elif p.trait_personality == 3:
				_addi(d, 4, -5)
				_add_empire_relation(w, 1, -6)
				_add_empire_relation(w, 0, 6)
				_add_ideology_share(w, 4, 333)
		if p.trait_special == 8:
			_addi(d, 4, -25)
			_addi(d, 1, -15)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			_addi(d, 6, d[6] / 150)
		elif p.trait_special == 9:
			_addi(d, 4, 6)
			_addi(d, 1, 8)
			_add_empire_relation(w, 1, 4)
			_add_empire_relation(w, 0, 4)
		elif p.trait_special == 10:
			_addi(d, 1, -16)
			_addi(d, 3, -16)
			_add_empire_relation(w, 1, -8)
			_add_empire_relation(w, 0, -8)
		elif p.trait_special == 11:
			_addi(d, 8, 8)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
		elif p.trait_special == 12:
			_addi(d, 4, -8)
			_addi(d, 1, -10)
			_add_empire_relation(w, 1, -6)
			_add_empire_relation(w, 0, -6)
		elif p.trait_special == 13:
			_addi(d, 1, 20)
		elif p.trait_special == 14:
			_addi(d, 1, 8)
			_addi(d, 4, 10)
			_addi(d, 31, 15)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			_addi(d, 6, d[6] / 150)
		elif p.trait_special == 15:
			_addi(d, 1, -8)
			_addi(d, 4, 10)
			_addi(d, 31, -15)
			_add_empire_relation(w, 1, -6)
			_add_empire_relation(w, 0, 6)
			_addi(d, 6, -d[6] / 150)
		elif p.trait_special == 16:
			_addi(d, 1, 9)
			_addi(d, 9, 6)
			_add_empire_relation(w, 1, 4)
			_add_empire_relation(w, 0, 4)
		elif p.trait_special == 17:
			_addi(d, 4, 8)
			_add_empire_relation(w, 1, -1)
			_add_empire_relation(w, 0, -1)
		elif p.trait_special == 18:
			_addi(d, 26, 10)
			_addi(d, 1, 15)
			_addi(d, 8, -3)
		elif p.trait_special == 19:
			_addi(d, 1, 4)
			_addi(d, 4, 6)
			_addi(d, 8, -1)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
		elif p.trait_special == 31:
			if p.trait_personality == 0:
				_addi(d, 1, -5)
				_addi(d, 3, 8)
				_addi(d, 4, -6)
			elif p.trait_personality == 20:
				_addi(d, 1, 3)
				_addi(d, 3, 5)
				_addi(d, 4, -3)
			elif p.trait_personality == 1:
				_addi(d, 1, 6)
				_addi(d, 3, 3)
				_addi(d, 4, 3)
			elif p.trait_personality == 2:
				_addi(d, 1, 8)
				_addi(d, 3, -5)
				_addi(d, 4, 5)
			elif p.trait_personality == 3:
				_addi(d, 1, -8)
				_addi(d, 3, -10)
				_addi(d, 4, 10)
		elif p.trait_special == 32:
			_addi(d, 3, 20)
			_addi(d, 4, -10)
		elif p.trait_special == 33:
			_addi(d, 1, 5)
			_add_empire_relation(w, 0, 6)
			_add_empire_relation(w, 1, 6)
		elif p.trait_special == 34:
			_addi(d, 1, -10)
			_addi(d, 3, -8)
			_addi(d, 4, -15)
			_addi(d, 57, -6)
		elif p.trait_special == 35:
			_addi(d, 1, -8)
			_addi(d, 3, -6)
			_addi(d, 9, 6)
		elif p.trait_special == 36:
			_addi(d, 1, -4)
			_addi(d, 3, -4)
			_addi(d, 4, -10)
			_addi(d, 22, 6)
			_addi(d, 5, -5)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
		elif p.trait_special == 37:
			_addi(d, 1, 8)
			_addi(d, 4, 3)
			_add_empire_relation(w, 1, 2)
			_add_empire_relation(w, 0, 2)
		elif p.trait_special == 38:
			_addi(d, 1, 6)
			_addi(d, 4, -8)
			_addi(d, 5, -4)

func _in_central_office(w: WorldState, idx: int) -> bool:
	for pos in [3, 4, 5, 6, 7]:
		if w.politics_positions.size() > pos and w.politics_positions[pos] == idx:
			return true
	return false


func _is_foreign_minister(w: WorldState, idx: int) -> bool:
	return w.politics_positions.size() > 2 and w.politics_positions[2] == idx

func _is_premier(w: WorldState, idx: int) -> bool:
	return w.politics_positions.size() > 1 and w.politics_positions[1] == idx


func _is_chairman(w: WorldState, idx: int) -> bool:
	return w.politics_positions.size() > 0 and w.politics_positions[0] == idx


func _faction_leader_slot(w: WorldState, idx: int) -> int:
	for fi in w.factions.size():
		if w.factions[fi] != null and w.factions[fi].leader_index == idx:
			return fi
	return -1


func _addi(d: Array, idx: int, delta: int) -> void:
	if d.size() > idx:
		d[idx] += delta


func _add_ideology(w: WorldState, idx: int, delta: int) -> void:
	if w.factions.size() > idx and w.factions[idx] != null:
		w.factions[idx].ideology += delta

func _ideology_total(w: WorldState) -> int:
	var total := 0
	for k in 5:
		if w.factions.size() > k and w.factions[k] != null:
			total += w.factions[k].ideology
	return total


@warning_ignore("integer_division")
func _add_ideology_share(w: WorldState, idx: int, divisor: int) -> void:
	if w.factions.size() > idx and w.factions[idx] != null:
		w.factions[idx].ideology += _ideology_total(w) / divisor


func _set_ideology(w: WorldState, idx: int, value: int) -> void:
	if w.factions.size() > idx and w.factions[idx] != null:
		w.factions[idx].ideology = value


func _count_tag(w: WorldState, tag: String) -> int:
	var count := 0
	for c in w.countries:
		if c != null and c.has_tag(tag):
			count += 1
	return count


## ModifiesInfuence.cs:2362-2530 的 51 号修正石油消费公式。
func _apply_modifier51_oil(d: Array, w: WorldState) -> void:
	var ind := _dv(d, W.I_INDUSTRY)
	var agr := _dv(d, W.I_AGRICULTURE)
	var srv := _dv(d, W.I_SERVICES)
	var army := _dv(d, W.I_ARMY)
	var oil := 0.0
	oil += float(ind) * 0.4
	oil += (float(ind - 499) * 0.4) if ind >= 500 else 0.0
	oil += (float(ind - 749) * 0.4) if ind >= 750 else 0.0
	oil += (float(agr - 249) * 0.35) if agr >= 250 else 0.0
	oil += (float(agr - 499) * 0.35) if agr >= 500 else 0.0
	oil += (float(agr - 749) * 0.35) if agr >= 750 else 0.0
	oil += (float(srv - 499) * 0.34) if srv >= 500 else 0.0
	oil += (float(srv - 749) * 0.34) if srv >= 750 else 0.0
	oil += 500.0 if army >= 1000 else float(army) * 0.5
	oil += float(_dv(d, W.I_LIVING)) * 0.05
	oil += float(w.army_power)
	for tech in [[2, 35.0], [3, 30.0], [6, 20.0], [7, 40.0], [8, 25.0], [10, -20.0], [11, -35.0], [13, -60.0], [14, -60.0]]:
		var tidx: int = tech[0]
		if w.techs != null and w.techs.unlocked.size() > tidx and w.techs.unlocked[tidx]:
			oil += float(tech[1])
	if oil <= 200.0:
		oil = 200.0
	w.oil_eat = oil
	var raw := float(_dv(d, 143))
	var price := raw
	if _mod_active(w, 58) and not _mod_active(w, 16) and _dv(d, 153) <= 0:
		price -= 15.0
	for idx in [14, 8, 35, 40, 30, 83, 52]:
		var cc := w.get_country_by_legacy_index(idx)
		if cc != null and cc.has_tag("亲中"):
			price -= 1.0
	if price < 10.0:
		price = 10.0
	if oil - w.oil_prod > 0.0:
		d[W.I_BUDGET] -= int(price * 7.7 * (oil - w.oil_prod) / 10000.0)
	else:
		d[W.I_BUDGET] -= int(raw * 7.7 * (oil - w.oil_prod) / 10000.0)
	var sov_price := raw
	for idx in [14, 8, 35, 40, 30, 83]:
		var cc := w.get_country_by_legacy_index(idx)
		if cc != null and cc.has_tag("亲苏"):
			sov_price -= 1.0
	if sov_price < 10.0:
		sov_price = 10.0
	var d160 := _dv(d, 160)
	if d160 > 0:
		w.empires[EmpireData.USSR].money += int(raw * 7.7 * float(d160) / 100000.0)
	else:
		w.empires[EmpireData.USSR].money += int(sov_price * 7.7 * float(d160) / 100000.0)
	var usa_price := raw
	for idx in [14, 8, 35, 40, 30, 83]:
		var cc := w.get_country_by_legacy_index(idx)
		if cc != null and cc.has_tag("亲美"):
			usa_price -= 1.0
	if usa_price < 10.0:
		usa_price = 10.0
	var d161 := _dv(d, 161)
	if d161 > 0:
		w.empires[EmpireData.USA].money += int(raw * 7.7 * float(d161) / 100000.0)
	else:
		w.empires[EmpireData.USA].money += int(usa_price * 7.7 * float(d161) / 100000.0)
	if raw - 50.0 > 0.0:
		WAR_SYS.add_empire_power(EmpireData.USA, -((int(raw) - 10) / 3))
		WAR_SYS.add_empire_power(EmpireData.USSR, (int(raw) - 10) / 3)
	elif raw - 20.0 > 0.0 and raw - 50.0 <= 0.0:
		WAR_SYS.add_empire_power(EmpireData.USA, (int(raw) - 10) / 3)
		WAR_SYS.add_empire_power(EmpireData.USSR, (int(raw) - 10) / 3)
	elif w.date.year < 1980:
		WAR_SYS.add_empire_power(EmpireData.USA, (int(raw) - 10) / 2)
		WAR_SYS.add_empire_power(EmpireData.USSR, -((int(raw) - 10) / 2))
	else:
		WAR_SYS.add_empire_power(EmpireData.USA, int(raw) - 10)
		WAR_SYS.add_empire_power(EmpireData.USSR, -((int(raw) - 10) * 2))


func _add_empire_relation(w: WorldState, idx: int, delta: int) -> void:
	if w.empires.size() > idx and w.empires[idx] != null:
		w.empires[idx].relations += delta

func _rel(w: WorldState, idx: int) -> int:
	if w.empires.size() > idx and w.empires[idx] != null:
		return w.empires[idx].relations
	return 0


func _emp_pow(w: WorldState, idx: int) -> int:
	if w.empires.size() > idx and w.empires[idx] != null:
		return w.empires[idx].power
	return 0


## TimeScript.cs:9871-9990 MutualRelationsChange 逐字移植（dlc[0] 恒 true 分支）。
func _fortnight_mutual_relations(d: Array[int], w: WorldState) -> void:
	var china := w.get_country_by_legacy_index(1)
	var science32: bool = w.techs != null and w.techs.unlocked.size() > 32 and w.techs.unlocked[32]
	var div45 := 45 if not science32 else 40
	var div40 := 40 if not science32 else 35
	var div30 := 30 if not science32 else 25
	var div15 := 15 if not science32 else 10
	var div20 := 20 if not science32 else 15
	var div25 := 25 if not science32 else 20
	var base := _dv(d, W.I_BUDGET_DIPLO)
	var usa := w.empires[0] if w.empires.size() > 0 else null
	var ussr := w.empires[1] if w.empires.size() > 1 else null
	if usa != null:
		if china != null and china.has_tag("ovd") and usa.relations > 650:
			usa.relations += base / div45
		elif china != null and (china.has_tag("sev") or china.has_tag("okb")) and usa.relations > 650:
			usa.relations += base / div40
		elif ussr != null and ussr.relations > 750 and not _mod_active(w, 17):
			usa.relations += base / div30
		elif usa.relations < 200 and _mod_active(w, 17):
			usa.relations += base / div15
		elif usa.relations < 400:
			usa.relations += base / div20
		else:
			usa.relations += base / div25
	if ussr != null:
		var usa_trade := w.get_country_by_legacy_index(51)
		if china != null and (china.has_tag("亲美") or (usa_trade != null and usa_trade.development == 1)) and ussr.relations > 650:
			ussr.relations += base / div45
		elif usa_trade != null and (usa_trade.has_tag("对华贸易") or (china != null and china.has_tag("okb"))) and ussr.relations > 650:
			ussr.relations += base / div40
		elif usa != null and usa.relations > 750 and not _mod_active(w, 17):
			ussr.relations += base / div30
		elif ussr.relations < 200 and _mod_active(w, 17):
			ussr.relations += base / div15
		elif ussr.relations < 400:
			ussr.relations += base / div20
		else:
			ussr.relations += base / div25
	# dlc[0] 恒 true → 只移植 else 分支（TimeScript.cs:9935-9975）。
	if usa != null and ussr != null:
		if usa.relations < 750 and usa.relations > 700 and ussr.relations > 300:
			ussr.relations -= 10
		elif usa.relations > 650:
			ussr.relations -= 5
		if ussr.relations < 750 and ussr.relations > 650 and usa.relations > 350:
			usa.relations -= 20
		elif ussr.relations < 750 and ussr.relations > 650:
			usa.relations -= 10
	if usa != null and usa.relations < 700:
		usa.relations += _dv(d, W.I_LOAN) / 20


## TimeScript.cs:6200-6231 AfricanBotSupport 逐字移植（调用点 TimeScript.cs:1040，每日一次）：
## 外交支出 data[81] 对非洲亲中国家提供稳定/削弱美苏影响；支出不足时亲中势力回退。
func _african_bot_support(d: Array[int], w: WorldState) -> void:
	if w == null:
		return
	var science32: bool = w.techs != null and w.techs.unlocked.size() > 32 and w.techs.unlocked[32]
	var base := _dv(d, W.I_BUDGET_DIPLO)
	var usa := w.empires[0] if w.empires.size() > 0 else null
	var ussr := w.empires[1] if w.empires.size() > 1 else null
	for i in range(53, 109):
		if i >= 69 and i <= 105:
			continue
		var c := w.get_country_by_legacy_index(i)
		if c == null or c.禁用非洲机制:
			continue
		if c.has_tag("亲中"):
			@warning_ignore("integer_division")
			var bonus := base / 2 if science32 else base / 3
			if c.stab < 1000:
				c.stab += bonus
			if c.usa_power > 0:
				c.usa_power -= bonus
			if c.sov_power > 0:
				c.sov_power -= bonus
			if _dv(d, W.I_ARMY) > (ussr.money if ussr != null else 0) and c.stab < 1000:
				c.stab += 25
			if _dv(d, W.I_ARMY) > (usa.money if usa != null else 0) and c.stab < 1000:
				c.stab += 25
		elif base < 50 and c.prc_power >= 500 and not science32:
			c.prc_power -= 60 - base


## ModifiesInfuence.cs:510-1198 的 2 号修正「服务业的发展进程」逐字移植。
## 寡头三档 + 教育路线(669) + 高校招生(456) + 合作医疗(646) + 票证分档 + 六项国策。
func _apply_modifier2_services(d: Array[int], w: WorldState) -> void:
	var oligarch := _dv(d, W.I_OLIGARCH)
	if oligarch < 54:
		pass  # 投机倒把的商人还影响不到我们
	elif oligarch < 72:
		d[W.I_PEOPLE_SUPPORT] -= 5
		d[W.I_THOUGHT_FREEDOM] += 10
		d[W.I_LIVING] -= 5
		d[W.I_AGENTS] -= 2
	else:
		d[W.I_PEOPLE_SUPPORT] -= 10
		d[W.I_THOUGHT_FREEDOM] += 20
		d[W.I_LIVING] -= 10
		d[W.I_AGENTS] -= 2
	# 教育路线（Event669）
	if not w.event_done_num(669):
		d[W.I_PEOPLE_SUPPORT] += 2
		d[W.I_BUDGET] -= 1
		d[W.I_INDUSTRY] += 2
		d[W.I_AGRICULTURE] += 2
		d[W.I_SCIENCE] += 5
	elif w.result_of_event_num(669) == 0:
		d[W.I_PEOPLE_SUPPORT] += 3
		d[W.I_BUDGET] -= 2
		d[W.I_INDUSTRY] += 3
		d[W.I_AGRICULTURE] += 3
		d[W.I_SCIENCE] += 10
	elif w.result_of_event_num(669) == 1:
		d[W.I_BUDGET] -= 1
		d[W.I_CORRUPTION] += 1
		d[W.I_SCIENCE] += 15
	elif w.result_of_event_num(669) == 2:
		d[W.I_BUDGET] += 2
		d[W.I_OLIGARCH] += 1
		d[W.I_CORRUPTION] += 1
		d[W.I_SCIENCE] += 20
	elif w.result_of_event_num(669) == 3:
		d[W.I_ARMY] += 3
		d[W.I_PEOPLE_SUPPORT] += 1
		d[W.I_THOUGHT_FREEDOM] -= 1
		d[W.I_SCIENCE] -= 20
		d[W.I_MANPOWER] += 50
		d[W.I_WAR_SUPPORT] += 50
	# 高校招生（Event456）
	if w.event_done_num(456) and w.result_of_event_num(456) == 0:
		d[W.I_SCIENCE] += 20
	elif w.event_done_num(456) and w.result_of_event_num(456) == 1:
		d[W.I_SCIENCE] += 10
	elif not w.event_done_num(456) or w.result_of_event_num(456) == 2:
		d[W.I_AGRICULTURE] += 3
		d[W.I_INDUSTRY] += 3
	# 合作医疗（Event646）
	if not w.event_done_num(646):
		d[W.I_PEOPLE_SUPPORT] += 2
		d[W.I_BUDGET] -= 1
		d[W.I_INDUSTRY] += 2
		d[W.I_AGRICULTURE] += 3
		d[W.I_SERVICES] += 2
	elif w.result_of_event_num(646) == 0:
		d[W.I_PEOPLE_SUPPORT] += 2
		d[W.I_BUDGET] -= 2
		d[W.I_INDUSTRY] += 3
		d[W.I_AGRICULTURE] += 4
		d[W.I_SERVICES] += 3
	elif w.result_of_event_num(646) == 1:
		d[W.I_BUDGET] += 2
		d[W.I_LIVING] += 1
		d[W.I_OLIGARCH] += 1
		d[W.I_SERVICES] += 1
	# 票证制度自动废止（原版在 modifier2 块内，data16==15 时无需点决策40）
	if _dv(d, W.I_ECON_SYSTEM) == 15 \
			and (not w.has_coupon_system_phase_out
				or (w.decisions != null and w.decisions.completed.size() > 40 and not w.decisions.completed[40])):
		w.has_coupon_system_phase_out = true
		if w.decisions != null and w.decisions.completed.size() > 40:
			w.decisions.completed[40] = true
	if not w.has_coupon_system_phase_out:
		d[W.I_AGRICULTURE] += 1
		d[W.I_PARTY_SUPPORT] += 2
		_apply_coupon_tiers(d, w)
	else:
		d[W.I_CORRUPTION] -= 2
		d[W.I_SERVICES] += 3
		d[W.I_PEOPLE_SUPPORT] += 5
		d[W.I_THOUGHT_FREEDOM] += 5
	# 六项国策的取消条件（ModifiesInfuence.cs:1094-1130）
	if w.planned_price_reduction > 0 and (_dv(d, W.I_ECON_SYSTEM) > 11 or _dv(d, W.I_RESERVE) <= 0):
		w.planned_price_reduction = 0
		_set_decision_flag(w, 41, false)
	if w.austerity > 0 and (_dv(d, W.I_ECON_SYSTEM) > 13 or _dv(d, W.I_LOAN) <= 0):
		w.austerity = 0
		_set_decision_flag(w, 42, false)
	if w.developed_consumerism > 0 and (_dv(d, W.I_ECON_SYSTEM) <= 13 or _dv(d, W.I_RESERVE) <= 0):
		w.developed_consumerism = 0
		_set_decision_flag(w, 43, false)
	if w.new_era_commune_member > 0 and (_dv(d, W.I_BUDGET_ENVELOPE) > 0 or _dv(d, W.I_CORRUPTION) >= 50):
		w.new_era_commune_member = 0
		_set_decision_flag(w, 44, false)
	if w.party_means_party > 0 and (_dv(d, W.I_BUDGET_ENVELOPE) < 100 or _dv(d, W.I_PARTY_SYSTEM) == 9):
		w.party_means_party = 0
		_set_decision_flag(w, 45, false)
	if w.party_subsidy > 0 and (_dv(d, W.I_PARTY_SYSTEM) < 8 or _dv(d, W.I_RESERVE) <= 0):
		w.party_subsidy = 0
		_set_decision_flag(w, 46, false)
	# 六项国策结算（ModifiesInfuence.cs:1132-1198）
	if w.planned_price_reduction > 0:
		d[W.I_BUDGET] -= 3
		d[W.I_INDUSTRY] -= 3
		d[W.I_AGRICULTURE] -= 3
		d[W.I_SERVICES] -= 3
		d[W.I_LIVING] += 20
		d[W.I_PEOPLE_SUPPORT] += 20
		d[W.I_THOUGHT_FREEDOM] -= 20
		d[W.I_MANPOWER] += 10
	if w.austerity > 0:
		if d[W.I_PEOPLE_SUPPORT] > 650:
			d[W.I_PEOPLE_SUPPORT] = 650
		if d[W.I_LIVING] > 650:
			d[W.I_LIVING] = 650
		d[W.I_BUDGET] += 20
		d[W.I_LIVING] -= 10
		d[W.I_PEOPLE_SUPPORT] -= 10
		d[W.I_THOUGHT_FREEDOM] += 10
		d[W.I_MANPOWER] -= 10
		d[W.I_SERVICES] -= 10
		d[W.I_DIPLO] += 1
		d[W.I_POPULATION] -= 2
	if w.developed_consumerism > 0:
		d[W.I_BUDGET] -= 25
		d[W.I_LIVING] += 10
		d[W.I_PEOPLE_SUPPORT] += 10
		d[W.I_THOUGHT_FREEDOM] += 10
		d[W.I_INDUSTRY] += 10
		d[W.I_SERVICES] += 10
		_add_empire_relation(w, EmpireData.USA, 2)
	if w.new_era_commune_member > 0:
		d[W.I_BUDGET] += 5
		d[W.I_PARTY_SUPPORT] -= 25
		d[W.I_PEOPLE_SUPPORT] += 10
		d[W.I_CORRUPTION] -= 10
		d[W.I_MANPOWER] += 5
	if w.party_means_party > 0:
		d[W.I_BUDGET] -= 10
		d[W.I_PARTY_SUPPORT] += 20
		d[W.I_PEOPLE_SUPPORT] -= 15
		d[W.I_THOUGHT_FREEDOM] += 5
		d[W.I_CORRUPTION] += 6
		for p in w.politicians:
			if p != null and not PoliticianSystem.is_vacant_politician(p):
				p.loyalty += 10
	if w.party_subsidy > 0:
		d[W.I_BUDGET] -= 10
		d[W.I_PARTY_SUPPORT] += 20
		d[W.I_THOUGHT_FREEDOM] -= 5
		d[W.I_CORRUPTION] += 5
		d[W.I_MANPOWER] += 10
		for p in w.politicians:
			if p != null and not PoliticianSystem.is_vacant_politician(p):
				p.loyalty += 10


## 票证制度按经济体制与工农业产值分档结算（ModifiesInfuence.cs:670-1092）。
func _apply_coupon_tiers(d: Array[int], w: WorldState) -> void:
	var sum := _dv(d, W.I_INDUSTRY) + _dv(d, W.I_AGRICULTURE)
	var econ := _dv(d, W.I_ECON_SYSTEM)
	if econ <= 11:
		if sum < 400:
			d[W.I_PEOPLE_SUPPORT] += 3
			d[W.I_MANPOWER] += 3
			d[W.I_BUDGET] += 3
		elif sum < 700:
			d[W.I_PEOPLE_SUPPORT] += 2
			d[W.I_MANPOWER] += 2
			d[W.I_BUDGET] += 2
		elif sum < 900:
			d[W.I_PEOPLE_SUPPORT] += 1
			d[W.I_MANPOWER] += 1
			d[W.I_BUDGET] += 1
		elif sum < 1300:
			d[W.I_PEOPLE_SUPPORT] -= 1
			d[W.I_BUDGET] += 1
		elif sum < 1500:
			d[W.I_PEOPLE_SUPPORT] -= 2
			d[W.I_BUDGET] += 2
		elif sum < 1600:
			d[W.I_PEOPLE_SUPPORT] -= 1
			d[W.I_CORRUPTION] += 1
		elif sum < 1700:
			d[W.I_PEOPLE_SUPPORT] -= 2
			d[W.I_CORRUPTION] += 2
		elif sum < 1800:
			d[W.I_PEOPLE_SUPPORT] -= 3
			d[W.I_CORRUPTION] += 3
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 1900:
			d[W.I_PEOPLE_SUPPORT] -= 4
			d[W.I_CORRUPTION] += 4
			d[W.I_THOUGHT_FREEDOM] += 3
		elif sum < 2000:
			d[W.I_PEOPLE_SUPPORT] -= 5
			d[W.I_CORRUPTION] += 5
			d[W.I_THOUGHT_FREEDOM] += 4
			if not w.event_done_num(5):
				GameManager.start_event("popular_discontent")
		else:
			d[W.I_PEOPLE_SUPPORT] -= 6
			d[W.I_CORRUPTION] += 6
			d[W.I_THOUGHT_FREEDOM] += 5
			if d[W.I_THOUGHT_FREEDOM] > 400 or not w.event_done_num(5):
				GameManager.start_event("popular_discontent")
	elif econ <= 13:
		if sum < 400:
			d[W.I_PARTY_SUPPORT] += 3
			d[W.I_MANPOWER] += 3
			d[W.I_BUDGET] += 3
			d[W.I_THOUGHT_FREEDOM] += 3
		elif sum < 700:
			d[W.I_PARTY_SUPPORT] += 2
			d[W.I_MANPOWER] += 2
			d[W.I_BUDGET] += 2
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 900:
			d[W.I_PARTY_SUPPORT] += 1
			d[W.I_MANPOWER] += 1
			d[W.I_BUDGET] += 1
			d[W.I_THOUGHT_FREEDOM] += 1
		elif sum < 1000:
			d[W.I_PEOPLE_SUPPORT] -= 1
			d[W.I_THOUGHT_FREEDOM] += 1
			d[W.I_BUDGET] += 1
		elif sum < 1100:
			d[W.I_LIVING] -= 1
			d[W.I_THOUGHT_FREEDOM] += 1
		elif sum < 1200:
			d[W.I_LIVING] -= 2
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 1300:
			d[W.I_LIVING] -= 3
			d[W.I_THOUGHT_FREEDOM] += 3
		elif sum < 1400:
			d[W.I_LIVING] -= 4
			d[W.I_THOUGHT_FREEDOM] += 4
			d[W.I_PEOPLE_SUPPORT] -= 1
		elif sum < 1500:
			d[W.I_LIVING] -= 5
			d[W.I_THOUGHT_FREEDOM] += 5
			d[W.I_PEOPLE_SUPPORT] -= 1
		elif sum < 1600:
			d[W.I_PEOPLE_SUPPORT] -= 1
			d[W.I_CORRUPTION] += 1
			d[W.I_LIVING] -= 5
		elif sum < 1700:
			d[W.I_PEOPLE_SUPPORT] -= 2
			# 原版此处 data[26] += 2 出现两次、data[5] += 2（文案却写生活-0.5），逐字保留。
			d[W.I_CORRUPTION] += 4
			d[W.I_LIVING] += 2
		elif sum < 1800:
			d[W.I_PEOPLE_SUPPORT] -= 3
			d[W.I_CORRUPTION] += 3
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 1900:
			d[W.I_PEOPLE_SUPPORT] -= 4
			d[W.I_CORRUPTION] += 4
			d[W.I_THOUGHT_FREEDOM] += 3
		elif sum < 2000:
			d[W.I_PEOPLE_SUPPORT] -= 5
			d[W.I_CORRUPTION] += 5
			d[W.I_THOUGHT_FREEDOM] += 4
			if not w.event_done_num(5):
				GameManager.start_event("popular_discontent")
		else:
			d[W.I_PEOPLE_SUPPORT] -= 6
			d[W.I_CORRUPTION] += 6
			d[W.I_THOUGHT_FREEDOM] += 5
			if d[W.I_THOUGHT_FREEDOM] > 400 or not w.event_done_num(5):
				GameManager.start_event("popular_discontent")
	elif econ == 14:
		if sum < 400:
			d[W.I_PEOPLE_SUPPORT] -= 3
			d[W.I_THOUGHT_FREEDOM] += 3
		elif sum < 700:
			d[W.I_PEOPLE_SUPPORT] -= 2
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 900:
			d[W.I_PEOPLE_SUPPORT] -= 1
			d[W.I_THOUGHT_FREEDOM] += 1
		elif sum < 1000:
			d[W.I_PEOPLE_SUPPORT] -= 2
			d[W.I_THOUGHT_FREEDOM] += 1
			d[W.I_BUDGET] += 1
		elif sum < 1100:
			d[W.I_LIVING] -= 1
			d[W.I_THOUGHT_FREEDOM] += 1
		elif sum < 1200:
			d[W.I_LIVING] -= 2
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 1300:
			d[W.I_LIVING] -= 3
			d[W.I_CORRUPTION] += 1
		elif sum < 1400:
			d[W.I_PEOPLE_SUPPORT] -= 2
		elif sum < 1500:
			d[W.I_LIVING] -= 4
			d[W.I_CORRUPTION] += 2
		elif sum < 1600:
			# 原版此处没有 data[3] 扣减（文案写人民-0.1），逐字保留。
			d[W.I_CORRUPTION] += 1
			d[W.I_LIVING] -= 5
		elif sum < 1700:
			# 原版 data[3]-- 与 data[3] -= 2 连续执行（共 -3），无预算扣减。
			d[W.I_PEOPLE_SUPPORT] -= 3
			d[W.I_CORRUPTION] += 2
		elif sum < 1800:
			d[W.I_PEOPLE_SUPPORT] -= 3
			d[W.I_CORRUPTION] += 3
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 1900:
			d[W.I_PEOPLE_SUPPORT] -= 4
			d[W.I_CORRUPTION] += 4
			d[W.I_THOUGHT_FREEDOM] += 3
			d[W.I_BUDGET] -= 2
		elif sum < 2000:
			d[W.I_PEOPLE_SUPPORT] -= 5
			d[W.I_CORRUPTION] += 5
			d[W.I_THOUGHT_FREEDOM] += 4
			d[W.I_BUDGET] -= 3
			if not w.event_done_num(5):
				GameManager.start_event("popular_discontent")
		else:
			d[W.I_PEOPLE_SUPPORT] -= 6
			d[W.I_CORRUPTION] += 6
			d[W.I_THOUGHT_FREEDOM] += 5
			d[W.I_BUDGET] -= 3
			if d[W.I_THOUGHT_FREEDOM] > 400 or not w.event_done_num(5):
				GameManager.start_event("popular_discontent")


## ModifiesInfuence.cs:1618-1720 的 15 号修正「农业的发展进程」逐字移植。
func _apply_modifier15_agriculture(d: Array[int], w: WorldState) -> void:
	var ev681 := w.event_done_num(681)
	var res681 := w.result_of_event_num(681)
	var ev682 := w.event_done_num(682)
	var res682 := w.result_of_event_num(682)
	if not ev681 or res681 == 0:
		d[W.I_AGRICULTURE] += 1
		d[W.I_SCIENCE] -= 10
		d[W.I_THOUGHT_FREEDOM] += 4
	elif res681 == 1:
		d[W.I_LIVING] -= 1
		d[W.I_THOUGHT_FREEDOM] += 2
	elif res681 == 2:
		d[W.I_BUDGET] -= 7
		d[W.I_PEOPLE_SUPPORT] += 4
		d[W.I_AGRICULTURE] += 4
		d[W.I_INDUSTRY] += 2
		d[W.I_SERVICES] += 2
		d[W.I_LIVING] += 4
	elif res681 == 3:
		d[W.I_BUDGET] += 1
		d[W.I_AGRICULTURE] += 1
		d[W.I_AGENTS] -= 2
		d[W.I_THOUGHT_FREEDOM] -= 2
		d[W.I_DIPLO] += 4
		d[W.I_SCIENCE] -= 10
		# 原版此处两行都是 empires[0].relations -= 10（美国扣两次，共 -20）。
		_add_empire_relation(w, EmpireData.USA, -20)
	elif res681 == 4 and not ev682:
		d[W.I_AGRICULTURE] -= 1
		d[W.I_THOUGHT_FREEDOM] += 3
	elif res682 == 0:
		d[W.I_BUDGET] -= 6
		d[W.I_AGRICULTURE] += 2
		d[W.I_LIVING] += 2
		d[W.I_THOUGHT_FREEDOM] -= 4
	elif res682 == 1:
		d[W.I_BUDGET] += 2
		d[W.I_AGRICULTURE] += 3
		d[W.I_INDUSTRY] += 1
		d[W.I_SERVICES] += 1
		d[W.I_LIVING] += 1
		d[W.I_THOUGHT_FREEDOM] += 12
		d[W.I_DIPLO] -= 2
		_add_empire_relation(w, EmpireData.USA, 2)
		WAR_SYS.add_empire_power(EmpireData.USA, 1)
		w.influence_prc -= 1
	elif res682 == 2:
		d[W.I_BUDGET] -= 4
		d[W.I_AGRICULTURE] += 3
		d[W.I_SERVICES] += 1
		d[W.I_LIVING] += 1
		d[W.I_AGENTS] += 1
		d[W.I_THOUGHT_FREEDOM] -= 1
	elif res682 == 3:
		d[W.I_BUDGET] += 3
		d[W.I_AGRICULTURE] += 5
		d[W.I_INDUSTRY] -= 4
		d[W.I_SERVICES] -= 2
		d[W.I_LIVING] -= 1
		d[W.I_THOUGHT_FREEDOM] += 2
	elif res682 == 4:
		d[W.I_BUDGET] -= 7
		d[W.I_PEOPLE_SUPPORT] += 4
		d[W.I_AGRICULTURE] += 4
		d[W.I_INDUSTRY] += 2
		d[W.I_SERVICES] += 2
		d[W.I_LIVING] += 4
	elif res682 == 5:
		d[W.I_BUDGET] += 10
		d[W.I_AGRICULTURE] += 3
		d[W.I_INDUSTRY] += 2
		d[W.I_LIVING] -= 6
		d[W.I_PEOPLE_SUPPORT] -= 10
		d[W.I_THOUGHT_FREEDOM] += 10
		_add_empire_relation(w, EmpireData.USA, 2)
		_add_empire_relation(w, EmpireData.USSR, 2)
		w.influence_prc -= 1
	# 公社路线（Event53 + Event682 交叉门控）
	var ev53 := w.event_done_num(53)
	var res53 := w.result_of_event_num(53)
	if (not ev53 or res53 == 0) and (not ev682 or res682 == 4):
		d[W.I_AGRICULTURE] += 1
		d[W.I_INDUSTRY] += 1
		d[W.I_LIVING] += 2
		d[W.I_BUDGET] += 1
	elif res53 == 1:
		d[W.I_BUDGET] += 4
		d[W.I_CORRUPTION] += 3
		if _dv(d, W.I_BUDGET_WELFARE) <= 200:
			d[W.I_AGRICULTURE] -= 2
			d[W.I_LIVING] -= 2
			d[W.I_SERVICES] -= 2
		if _dv(d, W.I_BUDGET_WELFARE) > 200:
			d[W.I_AGRICULTURE] += 2
			d[W.I_LIVING] += 2
			d[W.I_SERVICES] += 2
	elif res53 == 2:
		d[W.I_BUDGET] += 10
		d[W.I_CORRUPTION] += 4
		d[W.I_OLIGARCH] += 4
		d[W.I_AGRICULTURE] -= 4
		d[W.I_LIVING] -= 4
		d[W.I_SERVICES] += 2
	elif res53 == 3 and (not ev682 or res682 == 4):
		d[W.I_AGRICULTURE] += 4
		d[W.I_INDUSTRY] += 4
		d[W.I_LIVING] += 4
		d[W.I_BUDGET] += 2
	# 农业科技三件套
	if w.techs != null and w.techs.unlocked.size() > 3 and w.techs.unlocked[3]:
		d[W.I_AGRICULTURE] += 6
		d[W.I_INDUSTRY] += 4
	if w.techs != null and w.techs.unlocked.size() > 6 and w.techs.unlocked[6]:
		d[W.I_AGRICULTURE] += 3
		d[W.I_LIVING] += 4
	if w.techs != null and w.techs.unlocked.size() > 7 and w.techs.unlocked[7]:
		d[W.I_AGRICULTURE] += 2
		d[W.I_INDUSTRY] += 2
		d[W.I_LIVING] += 4
		d[W.I_BUDGET] += 3


func _set_decision_flag(w: WorldState, idx: int, value: bool) -> void:
	if w.decisions != null and idx >= 0 and idx < w.decisions.completed.size():
		w.decisions.completed[idx] = value


## ModifiesInfuence.cs:27-500 的 50 号修正「军事的发展进程」逐字移植。
## 依据事件 513-521/540/544/545/685 与军购/PMC/机械陆军等状态，每双周结算一次。
func _apply_modifier50_military(d: Array[int], w: WorldState) -> void:
	if not _mod_active(w, 50):
		return
	if w.event_done_num(513) and w.techs != null and w.techs.unlocked.size() > 18 and w.techs.unlocked[18]:
		if w.result_of_event_num(513) == 0:
			d[W.I_ARMY] += 1
		elif w.result_of_event_num(513) == 1:
			d[W.I_ARMY] += 2
	if w.event_done_num(514) and w.techs != null and w.techs.unlocked.size() > 23 and w.techs.unlocked[23]:
		match w.result_of_event_num(514):
			0:
				d[W.I_PEOPLE_SUPPORT] += 1
				d[W.I_THOUGHT_FREEDOM] -= 1
				if d[W.I_DIPLO] > 900:
					d[W.I_DIPLO] -= 1
				elif d[W.I_DIPLO] < 700:
					d[W.I_DIPLO] += 1
			1:
				d[W.I_PEOPLE_SUPPORT] += 1
				d[W.I_THOUGHT_FREEDOM] += 1
				d[W.I_DIPLO] -= 2
			2:
				d[W.I_PEOPLE_SUPPORT] += 1
				d[W.I_THOUGHT_FREEDOM] -= 2
				d[W.I_DIPLO] += 2
	if w.event_done_num(345):
		match w.result_of_event_num(345):
			0:
				d[W.I_PEOPLE_SUPPORT] += 3
				d[W.I_ARMY] += 2
				d[W.I_MIL_INTERVENTION] += 2
			1:
				d[W.I_BUDGET] -= 1
				d[W.I_ARMY] += 5
				d[W.I_MIL_INTERVENTION] += 2
				d[W.I_CORRUPTION] += 2
	if w.event_done_num(515) and w.result_of_event_num(515) == 0:
		d[W.I_AGENTS] += 1
		d[W.I_ARMY] += 2
	if w.event_done_num(516):
		match w.result_of_event_num(516):
			0:
				d[W.I_ARMY] += 3
				d[W.I_BUDGET] -= 1
			1:
				d[W.I_ARMY] += 6
				d[W.I_BUDGET] -= 2
				d[W.I_MANPOWER] += 2
	if w.event_done_num(517):
		match w.result_of_event_num(517):
			0:
				d[W.I_ARMY] += 3
				d[W.I_BUDGET] -= 2
				d[W.I_PEOPLE_SUPPORT] += 2
			1:
				d[W.I_ARMY] += 5
				d[W.I_BUDGET] -= 2
				_add_empire_relation(w, 0, -2)
				_add_empire_relation(w, 1, -2)
			2:
				d[W.I_ARMY] += 10
				d[W.I_PEOPLE_SUPPORT] += 3
				d[W.I_BUDGET] -= 3
				_add_empire_relation(w, 0, -2)
				_add_empire_relation(w, 1, -2)
	if w.event_done_num(518):
		match w.result_of_event_num(518):
			0:
				d[W.I_ARMY] += 2
				d[W.I_PEOPLE_SUPPORT] += 2
				d[W.I_BUDGET] -= 2
				d[W.I_MIL_INTERVENTION] += 10
			1:
				d[W.I_ARMY] += 3
				d[W.I_BUDGET] -= 2
				_add_empire_relation(w, 0, -1)
				_add_empire_relation(w, 1, -1)
				d[W.I_MIL_INTERVENTION] += 10
			2:
				d[W.I_ARMY] += 8
				d[W.I_PEOPLE_SUPPORT] += 2
				d[W.I_BUDGET] -= 3
				_add_empire_relation(w, 0, -1)
				_add_empire_relation(w, 1, -1)
				d[W.I_MIL_INTERVENTION] += 10
	if w.event_done_num(519):
		match w.result_of_event_num(519):
			0:
				d[W.I_ARMY] += 18
				d[W.I_PEOPLE_SUPPORT] += 5
				d[W.I_BUDGET] -= 4
			1:
				d[W.I_ARMY] += 15
				d[W.I_PEOPLE_SUPPORT] += 2
				d[W.I_BUDGET] -= 3
			2:
				d[W.I_ARMY] += 35
				d[W.I_PEOPLE_SUPPORT] += 10
				d[W.I_BUDGET] -= 5
	if w.event_done_num(520):
		match w.result_of_event_num(520):
			0:
				d[W.I_ARMY] += 20
				d[W.I_PEOPLE_SUPPORT] += 5
				_add_empire_relation(w, 0, -3)
				_add_empire_relation(w, 1, -3)
			1:
				d[W.I_ARMY] += 50
				d[W.I_BUDGET] -= 5
				d[W.I_PEOPLE_SUPPORT] += 8
				_add_empire_relation(w, 0, -4)
				_add_empire_relation(w, 1, -4)
			2:
				d[W.I_ARMY] += 10
				d[W.I_PEOPLE_SUPPORT] += 10
				_add_empire_relation(w, 0, -2)
				_add_empire_relation(w, 1, -2)
	if w.event_done_num(521):
		match w.result_of_event_num(521):
			0:
				d[W.I_ARMY] += 30
				d[W.I_PEOPLE_SUPPORT] += 10
				w.influence_prc += 5
			1:
				d[W.I_ARMY] += 30
				d[W.I_MIL_INTERVENTION] += 20
				d[W.I_PEOPLE_SUPPORT] += 10
				w.influence_prc += 5
			2:
				d[W.I_ARMY] += 50
				d[W.I_PEOPLE_SUPPORT] += 25
				d[W.I_MIL_INTERVENTION] += 30
				w.influence_prc += 10
	if w.event_done_num(540):
		match w.result_of_event_num(540):
			0:
				d[W.I_ARMY] += 4
				d[W.I_MIL_INTERVENTION] += 2
			1:
				d[W.I_ARMY] += 2
				d[W.I_MIL_INTERVENTION] += 2
	if w.event_done_num(544):
		match w.result_of_event_num(544):
			0:
				d[W.I_ARMY] += 7
				d[W.I_DIPLO] -= 5
			1:
				d[W.I_ARMY] += 20
				_add_empire_relation(w, 0, -2)
				_add_empire_relation(w, 1, -2)
			2:
				d[W.I_ARMY] += 40
				_add_empire_relation(w, 0, -4)
				_add_empire_relation(w, 1, -4)
	if w.event_done_num(545):
		match w.result_of_event_num(545):
			0:
				d[W.I_ARMY] += 10
			1:
				d[W.I_LIVING] += 10
				d[W.I_PEOPLE_SUPPORT] += 10
				d[W.I_THOUGHT_FREEDOM] -= 5
			2:
				d[W.I_ARMY] += 20
				d[W.I_LIVING] += 15
				d[W.I_PEOPLE_SUPPORT] += 15
				d[W.I_THOUGHT_FREEDOM] -= 10
	if w.event_done_num(685):
		match w.result_of_event_num(685):
			0:
				_add_empire_relation(w, 0, 2)
				_add_empire_relation(w, 1, 2)
				d[W.I_ARMY] -= 4
				d[W.I_AGENTS] += 2
				d[W.I_THOUGHT_FREEDOM] += 2
				if d[W.I_DIPLO] > 900:
					d[W.I_DIPLO] -= 2
				elif d[W.I_DIPLO] < 500:
					d[W.I_DIPLO] += 2
			1:
				_add_empire_relation(w, 0, 1)
				_add_empire_relation(w, 1, 1)
				d[W.I_ARMY] -= 2
				if d[W.I_DIPLO] > 900:
					d[W.I_DIPLO] -= 1
				elif d[W.I_DIPLO] < 500:
					d[W.I_DIPLO] += 1
				d[W.I_BUDGET] -= 40
				d[W.I_ARMY] += 20
				d[W.I_PEOPLE_SUPPORT] += 10
				d[W.I_LIVING] += 6
				d[W.I_MIL_INTERVENTION] += 40
				d[W.I_SCIENCE] += 100
			2:
				_add_empire_relation(w, 0, -1)
				_add_empire_relation(w, 1, -1)
				d[W.I_DIPLO] += 2
	# 军购协定 / PMC / 机械陆军 / 军力封顶（ModifiesInfuence.cs:433-500）
	# 433-442 取消分支：条件满足时清零协定/PMC 并撤销对应国策标记。
	if w.arms_purchase_agreement > 0:
		var ussr_c := w.get_country_by_legacy_index(7)
		var china := w.get_country_by_legacy_index(1)
		var usa_c := w.get_country_by_legacy_index(51)
		var ussr_e := w.empires[EmpireData.USSR] if w.empires.size() > EmpireData.USSR else null
		if ussr_c != null and ussr_c.sub_government != 21 \
				and (china != null and (china.government == 3
					or (usa_c != null and usa_c.has_tag("对华贸易"))
					or (ussr_e != null and ussr_e.relations < 500))):
			w.arms_purchase_agreement = 0
			if w.decisions != null and w.decisions.completed.size() > 47:
				w.decisions.completed[47] = false
	if w.pmc > 0 and (d[W.I_ECON_SYSTEM] <= 13 or d[W.I_ARMY] < 50 or d[W.I_MIL_DOCTRINE] != 33):
		w.pmc = 0
		if w.decisions != null and w.decisions.completed.size() > 48:
			w.decisions.completed[48] = false
	if w.arms_purchase_agreement > 0:
		d[W.I_BUDGET] -= 6
		d[W.I_ARMY] += 12
		d[W.I_SCIENCE] += 5
		_add_empire_relation(w, 1, 8)
		if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
			w.empires[EmpireData.USSR].money += 6
			w.empires[EmpireData.USSR].power += 1
	if w.pmc > 0:
		d[W.I_BUDGET] += 10
		d[W.I_ARMY] -= 10
		d[W.I_BUDGET] += 2
		d[W.I_CORRUPTION] += 2
		for ei in range(2):
			if w.empires.size() > ei and w.empires[ei] != null:
				if w.empires[ei].relations < 250:
					w.empires[ei].relations = 250
				elif w.empires[ei].relations > 750:
					w.empires[ei].relations = 750
	var c16 := w.get_country_by_legacy_index(16)
	if c16 != null and c16.prc_influence != 0:
		d[W.I_ARMY] += 5
		d[W.I_AGENTS] += 3
		d[W.I_MIL_INTERVENTION] += 10
		d[W.I_BUDGET] -= 8
		d[W.I_SCIENCE] -= 2
		d[W.I_PEOPLE_SUPPORT] += 10
	if d[W.I_ARMY] >= 2000:
		@warning_ignore("integer_division")
		var num41 := (d[W.I_ARMY] - 2000) / 100
		d[W.I_ARMY] -= 10 * num41
		d[W.I_BUDGET] += 2 * num41
		d[W.I_AGENTS] += 2 * num41
		d[W.I_RESERVE] += 2 * num41


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
	if u[4]: d[W.I_LIVING] += 4; d[W.I_AGRICULTURE] += 5
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
	if u[24]: d[W.I_ARMY] += 4; d[W.I_PEOPLE_SUPPORT] += 2
	if u[25]: d[W.I_AGENTS] += 2; d[W.I_THOUGHT_FREEDOM] -= 2; d[W.I_PARTY_SUPPORT] += 3
	if u[26]: d[W.I_ARMY] += 4; d[W.I_THOUGHT_FREEDOM] -= 2
	# 航天科技（TimeScript.cs:5201-5263 逐条）
	if u[27]: d[W.I_BUDGET] += 2; d[W.I_LIVING] += 2; d[W.I_PEOPLE_SUPPORT] += 2
	if u[28]: d[W.I_ARMY] += 5; d[W.I_AGENTS] += 5
	if u[29]:
		d[W.I_ARMY] += 10
		if w.empires.size() > 0:
			w.empires[0].relations -= 5
		if w.empires.size() > 1:
			w.empires[1].relations -= 5
	if u[30]:
		d[W.I_PEOPLE_SUPPORT] += 3
		# 原版不对称：美国 empire.power -1、苏联 empire.relations -1（照抄）
		if w.empires.size() > 0:
			w.empires[0].power -= 1
		if w.empires.size() > 1:
			w.empires[1].relations -= 1
	if u[31]: d[W.I_ARMY] += 5; d[W.I_SCIENCE] += 5
	if u[32]: d[W.I_AGRICULTURE] += 5; d[W.I_LIVING] += 5
	if u[33]:
		d[W.I_ARMY] += 5; d[W.I_INDUSTRY] += 5
		if w.empires.size() > 0:
			w.empires[0].relations -= 5
		if w.empires.size() > 1:
			w.empires[1].relations -= 5


# ── 双周：贷款利息（TimeScript 5512-5605行；外援 dota 在月块 2295-2318，见 _monthly_ejection_and_misc） ──
func _fortnight_loan_interest(d: Array[int], w: WorldState) -> void:
	var loan: int = d[W.I_LOAN]
	var year: int = w.date.year if w.date else 1976
	var pc := w.get_player_country()
	# 原版对苏关系惩罚都包在 allcountries[1].isSEV 内（中国加入经互会才扣）
	var china_in_sev := pc != null and pc.has_tag("sev")
	# 国债利息（与 UI「债务损耗」对齐）
	if loan > 0:
		var interest: int = loan / 40
		# 里根豁免（原版 TimeScript.cs:5514-5605）：empires[0].now_leader==3（=里根，1980 大选后）
		# 且奇数月(data[20]%2!=0)时免预算扣息，仅保留本金递减与对苏关系惩罚。
		# Godot 领导人索引 0=里根（world_factory.gd:1010-1011），原版 3=里根（Event402.cs:168）；
		# Godot current_leader 初始即 0，故开局即生效（原版需 1980 大选，领导人继任模型差异另记）。
		var usa: EmpireData = w.empires[0] if w.empires.size() > 0 else null
		if usa != null and usa.current_leader == 0 and w.date.month % 2 != 0:
			if interest <= 0:
				if loan > 10:
					d[W.I_LOAN] -= 1
				if china_in_sev and w.empires.size() > 1 and w.empires[1] != null:
					w.empires[1].relations -= 2
			else:
				if china_in_sev and w.empires.size() > 1 and w.empires[1] != null:
					w.empires[1].relations -= loan / 20
				if loan > 10:
					@warning_ignore("integer_division")
					d[W.I_LOAN] -= loan / 40 / 2 + 1
			return
		if interest <= 0:
			d[W.I_BUDGET] -= 1
			if year >= 1983:
				d[W.I_BUDGET] -= 2
			elif year >= 1980:
				d[W.I_BUDGET] -= 1
			if loan > 10:
				d[W.I_LOAN] -= 1
			if china_in_sev and w.empires.size() > 1 and w.empires[1] != null:
				w.empires[1].relations -= 2
		else:
			d[W.I_BUDGET] -= interest
			if year >= 1983:
				d[W.I_BUDGET] -= 1
			elif year >= 1980:
				# 反编译第二条件写作 >=1983（不可达冗余）；按原版语义应为 >=1980，
				# 1980-1982 年额外扣 2（与利息<=0 分支相反，照抄原作行为）。
				d[W.I_BUDGET] -= 2
			if china_in_sev and w.empires.size() > 1 and w.empires[1] != null:
				w.empires[1].relations -= loan / 20
			if loan > 10:
				d[W.I_LOAN] -= interest / 2 + 1


# ── 11项预算的完整月度效果 ──
# 移植自 TimeScript.cs InfluenceFromInvestments() 第 9764-9870 行（调用点 5264）

func _influence_from_investments(d: Array[int], year: int) -> void:
	# ─ 军费 ─
	var army_year_cost := (year - 1976 + 6) * 10
	# 军力：原版整数除法 (data[71]-(year-1976+6)*10)/10（TimeScript.cs:9766）；
	# 此前新增的 ind_mod（按工业缩放）在原版全库无出处，已移除。
	@warning_ignore("integer_division")
	d[W.I_ARMY] += (d[W.I_BUDGET_ARMY] - army_year_cost) / 10
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
	# 科研点生成（data[11]+=data[73]/40）原版在日块（1457-1458行），已移至 _daily_science_gen
	d[W.I_CORRUPTION] += d[W.I_BUDGET_SCIENCE] / 50

	# ─ 行政支出 ─
	d[W.I_CORRUPTION] -= d[W.I_BUDGET_ADMIN] / 20
	d[W.I_PARTY_SUPPORT] += d[W.I_BUDGET_ADMIN] / 25
	d[W.I_LIVING] += d[W.I_BUDGET_ADMIN] / 70

	# ─ 高层福利(信封) ─
	d[W.I_CORRUPTION] += d[W.I_BUDGET_ENVELOPE] / 25
	d[W.I_PARTY_SUPPORT] += (d[W.I_BUDGET_ENVELOPE] - 61) / 5

	# ─ 宣传支出（原版 9818-9827 + 兵源 9777-9780）──
	d[W.I_CORRUPTION] -= d[W.I_BUDGET_PROPAGANDA] / 100   # 原版 :9818
	d[W.I_MANPOWER] += d[W.I_BUDGET_PROPAGANDA] / 150     # 原版 :9776/:9819
	d[W.I_CORRUPTION] += d[W.I_BUDGET_PROPAGANDA] / 150   # 原版 :9820
	d[W.I_THOUGHT_FREEDOM] -= d[W.I_BUDGET_PROPAGANDA] / 100  # 原版 :9821
	# 原版无条件：data[3] += (data[76]-70)/10（prop<70 时为负，扣民众支持）
	d[W.I_PEOPLE_SUPPORT] += (d[W.I_BUDGET_PROPAGANDA] - 70) / 10  # 原版 :9822
	if d[W.I_BUDGET_PROPAGANDA] < 50:
		d[W.I_CORRUPTION] += (50 - d[W.I_BUDGET_PROPAGANDA]) / 20   # 原版 :9825
		d[W.I_PEOPLE_SUPPORT] -= (50 - d[W.I_BUDGET_PROPAGANDA]) / 20  # 原版 :9826
		d[W.I_MANPOWER] -= (50 - d[W.I_BUDGET_PROPAGANDA]) / 20     # 原版 :9777-9780

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
	# 每 5 点外交支出 +0.1 军事介入点（内部 ×10，显示 0.1 = 内部 1）
	@warning_ignore("integer_division")
	d[W.I_MIL_INTERVENTION] += d[W.I_BUDGET_DIPLO] / 5

	# ─ 腐败扣预算/生活水平（原版 8186-8187，投资块末尾，用投资后腐败值）──
	d[W.I_BUDGET] -= d[W.I_CORRUPTION] / 10
	d[W.I_LIVING] -= d[W.I_CORRUPTION] / 50


# ── 政治体制自动重算 ──

func _political_system_recalc(d: Array[int], w: WorldState) -> void:
	# 原版 TimeScript.cs 日块体制重算（num20=5 逐项修正体系，:1265-1445），
	# 2026-08 对齐审查重写：此前移植用 "score=(econ-9)+(party-5)+..." 数学公式与
	# 分支阈值（score<=6/9/11/15/20），与原版 num20<=0/3/6/9/12 体系完全不符；
	# 开局数据下两者恰都收敛到威权（num20=5-1-1-2-1=0 → 分支1），但政策变化后
	# 结果分歧。逐字重写如下（2026-08 补齐 DevelopedConsumerism 与事件 502/681/674/675 条件）。
	var num20 := 5
	if d[W.I_ECON_SYSTEM] == 10:
		num20 -= 1
	if d[W.I_ECON_SYSTEM] == 14 or d[W.I_ECON_SYSTEM] == 15:
		if d[W.I_PRESS_POLICY] > 17:
			num20 += 1
		else:
			num20 -= 1
	if d[W.I_PARTY_SYSTEM] == 6:
		num20 -= 1
	if d[W.I_PARTY_SYSTEM] == 8:
		num20 += 1
	if d[W.I_PARTY_SYSTEM] == 9:
		num20 += 2
	if d[W.I_PRESS_POLICY] == 16:
		num20 -= 1
	if d[W.I_PRESS_POLICY] == 18:
		num20 += 1
	if d[W.I_PRESS_POLICY] == 19:
		num20 += 3
	if d[W.I_RELIGION] == 24 or d[W.I_RELIGION] == 29:
		num20 -= 2
	if d[W.I_RELIGION] == 25 or d[W.I_RELIGION] == 28:
		num20 -= 1
	if d[W.I_RELIGION] == 27:
		num20 += 1
	if d[W.I_TERRITORY] == 20 and d[W.I_MIL_DOCTRINE] == 30:
		num20 -= 1
	if d[W.I_TERRITORY] >= 22 and d[W.I_MIL_DOCTRINE] == 33:
		num20 += 1
	if d[W.I_TERRITORY] == 23:
		num20 += 1
	# TimeScript.cs:1333-1336：DevelopedConsumerism > 0 → num20++。
	if w.developed_consumerism > 0:
		num20 += 1
	if _mod_active(w, 40):
		num20 -= 1
	if _mod_active(w, 38) and num20 > 0:
		num20 = 0
	# TimeScript.cs:1341-1349：event_done[502] && res502!=4 → num20-=3；
	# 且 data[15]==8（政党制度8）再 -3。
	if w.event_done_num(502) and w.result_of_event_num(502) != 4:
		num20 -= 3
		if d[W.I_PARTY_SYSTEM] == 8:
			num20 -= 3
	# TimeScript.cs:1350-1353：event_done[681] && res681==3 → num20--。
	if w.event_done_num(681) and w.result_of_event_num(681) == 3:
		num20 -= 1
	# TimeScript.cs:1354-1357：(res675==2 || res674==2) && num20>0 → num20=0。
	if (w.result_of_event_num(675) == 2 or w.result_of_event_num(674) == 2) and num20 > 0:
		num20 = 0

	var new_system: int
	var new_gosstroy: int
	if num20 <= 0:
		new_system = 0; new_gosstroy = 0
	elif num20 <= 3 and d[W.I_ECON_SYSTEM] <= 11:
		new_system = 1; new_gosstroy = 1
	elif num20 <= 6:
		if d[W.I_ECON_SYSTEM] <= 11:
			new_system = 2; new_gosstroy = 1
		elif d[W.I_ECON_SYSTEM] <= 13 and num20 <= 4:
			new_system = 2; new_gosstroy = 1
		else:
			new_system = 3; new_gosstroy = 2
	elif num20 <= 9:
		if d[W.I_ECON_SYSTEM] <= 13:
			if d[W.I_ECON_SYSTEM] <= 11:
				new_system = 2; new_gosstroy = 1
			else:
				new_system = 3; new_gosstroy = 2
		else:
			new_system = 4; new_gosstroy = 3
	elif num20 <= 12:
		if d[W.I_ECON_SYSTEM] <= 13:
			if d[W.I_ECON_SYSTEM] <= 11:
				new_system = 3; new_gosstroy = 2
			else:
				new_system = 4; new_gosstroy = 3
		else:
			new_system = 5; new_gosstroy = 3
	elif d[W.I_ECON_SYSTEM] > 12:
		new_system = 5; new_gosstroy = 3
	elif d[W.I_ECON_SYSTEM] > 11:
		new_system = 4; new_gosstroy = 3
	else:
		new_system = 3; new_gosstroy = 2

	d[W.I_IDEOLOGY] = new_system
	var pc := w.get_player_country()
	if pc:
		pc.government = new_gosstroy
	# 原版 1440-1444：modifies[40] 激活且 Gosstroy==1 时强制覆盖为 data[14]=3 / Gosstroy=2
	if _mod_active(w, 40) and pc != null and pc.government == 1:
		d[W.I_IDEOLOGY] = 3
		pc.government = 2
	# 注意：data[56] 政治路线重算也在日块（tick 中先于本函数调用），不在此处


## 政治路线 data[56]：一党制(≤7)下每月跟随席位(support)最大的派系。
## 对齐原版 TimeScript 日块 1146-1226（幂等派生值，每日重算无副作用）。
## 注意：满足现状者 data[106] 的增长【不在这里】——原版月块完全不碰 data[106]，
##       它只在切政策 Doctrine_button.OnMouseDown 时 += 一次（见 change_policy →
##       _apply_policy_satisfied_growth）。之前放在月度导致每月暴涨，即本次修复的 bug。
func _update_political_line(d: Array[int], w: WorldState) -> void:
	## 原版 Party_ally_script / Party_zapret 点击后与日块重算 data[56] 的算法，逐分支照抄。
	if w.factions.is_empty() or d.size() <= W.I_POLITICAL_LINE:
		return
	var p0: int = w.factions[0].support if w.factions.size() > 0 else 0
	var p1: int = w.factions[1].support if w.factions.size() > 1 else 0
	var p2: int = w.factions[2].support if w.factions.size() > 2 else 0
	var p3: int = w.factions[3].support if w.factions.size() > 3 else 0
	var p4: int = w.factions[4].support if w.factions.size() > 4 else 0
	if d[W.I_PARTY_SYSTEM] <= 7:
		if p0 >= p1 and p0 >= p2 and p0 >= p3 and p0 >= p4:
			d[W.I_POLITICAL_LINE] = 0
		elif p0 <= p1 and p1 >= p2 and p1 >= p3 and p1 >= p4:
			d[W.I_POLITICAL_LINE] = 1
		elif p2 >= p1 and p0 <= p2 and p2 >= p3 and p2 >= p4:
			d[W.I_POLITICAL_LINE] = 2
		elif p3 >= p1 and p3 >= p2 and p0 <= p3 and p3 >= p4:
			d[W.I_POLITICAL_LINE] = 3
		elif p4 >= p1 and p4 >= p2 and p4 >= p3 and p0 <= p4:
			d[W.I_POLITICAL_LINE] = 4
		return
	# 多党(>7)：保守派支持 + 所有已结盟启用派系支持
	var coalition := p1
	for i in w.factions.size():
		var f: FactionData = w.factions[i]
		if i != FactionData.CONSERVATIVE and f.is_ally and f.is_enabled:
			coalition += f.support
	if coalition >= p0 and coalition >= p2 and coalition >= p3 and coalition >= p4:
		d[W.I_POLITICAL_LINE] = 1
	elif not w.factions[0].is_ally and w.factions[0].is_enabled and coalition <= p0 \
			and p0 >= p2 and p0 >= p3 and p0 >= p4:
		d[W.I_POLITICAL_LINE] = 0
	elif not w.factions[2].is_ally and w.factions[2].is_enabled and p2 >= p0 \
			and coalition <= p2 and p2 >= p3 and p2 >= p4:
		d[W.I_POLITICAL_LINE] = 2
	elif not w.factions[3].is_ally and w.factions[3].is_enabled and p3 >= p0 \
			and p3 >= p2 and coalition <= p3 and p3 >= p4:
		d[W.I_POLITICAL_LINE] = 3
	elif not w.factions[4].is_ally and w.factions[4].is_enabled and p4 >= p0 \
			and p4 >= p2 and p4 >= p3 and coalition <= p4:
		d[W.I_POLITICAL_LINE] = 4


## 每日：一党制下把 party_number(=support) 按 party_ideology(=ideology) 重算。
## 忠实移植原版 TimeScript.Repaint 日块（DLL 反编译 TimeScript.Repaint(bool)：
## data[53] 重算段 + party_number 重算段；旧 Assets/Scripts/TimeScript.cs:1113-1171
## 同源，但旧文本把 ref 写入误排成死局部变量，以 DLL 反编译语义为准）。
## 原版每次日块先把 data[53] 置为当前禁用派系数；多党下禁用>=4 时政党制度退回 6；
## 一党制：启用派系 support = ideology + 前方禁用派系转移额；负 ideology 归零。
func _sync_faction_numbers_from_ideology(d: Array[int], w: WorldState) -> void:
	if w == null or w.factions.is_empty() or d.size() <= W.I_PARTY_BAN_COUNT:
		return
	var disabled := 0
	for f in w.factions:
		if f != null and not f.is_enabled:
			disabled += 1
	d[W.I_PARTY_BAN_COUNT] = disabled
	if d[W.I_PARTY_SYSTEM] > 7 and disabled >= 4:
		d[W.I_PARTY_SYSTEM] = 6
	if d[W.I_PARTY_SYSTEM] > 7:
		return
	var transferred: Array[int] = [0, 0, 0, 0, 0]
	for i in w.factions.size():
		var f: FactionData = w.factions[i]
		if f == null:
			continue
		if f.ideology > 0 and not f.is_enabled:
			var found := false
			for k in range(i + 1, w.factions.size()):
				var t: FactionData = w.factions[k]
				if t != null and t.is_enabled and k < transferred.size():
					transferred[k] = f.ideology
					found = true
					break
			if not found:
				for k in range(i - 1, 0, -1):
					var t2: FactionData = w.factions[k]
					if t2 != null and t2.is_enabled:
						t2.support += f.ideology
						break
		elif f.ideology > 0 and f.is_enabled:
			f.support = f.ideology + (transferred[i] if i < transferred.size() else 0)
		elif f.ideology < 0:
			f.ideology = 0


## 每 7 天（原版 data[19] % 7 == 0）：一党制下每个已结盟派系
##   ideology += (五个派系 ideology 之和) / 100
##   预算 -1，特工网络 -2
## 出处：原版 TimeScript.Repaint 日块；DLL 反编译 TimeScript 中
## "if (this.global2.data[19] % 7 == 0) ... is_party_ally[num39]" 一段
## （旧 Assets/Scripts/TimeScript.cs:3155-3170 的 ref 写入被误排，以 DLL 为准）。
## 原版此段在 party_number 每日重算之后执行，所以本次增长下一日块才反映到 support。
func _weekly_ally_upkeep(d: Array[int], w: WorldState) -> void:
	if w == null or w.factions.is_empty() or d.size() <= W.I_AGENTS:
		return
	if d[W.I_PARTY_SYSTEM] > 7:
		return
	for f in w.factions:
		if f == null or not f.is_ally:
			continue
		var ideo_sum := 0
		for x in w.factions:
			if x != null:
				ideo_sum += x.ideology
		@warning_ignore("integer_division")
		var gain: int = ideo_sum / 100
		f.ideology += gain
		d[W.I_BUDGET] -= 1
		d[W.I_AGENTS] -= 2


## 满足现状者 data[106] 增长——【仅切政策成功时】调用一次，对齐原版
## Doctrine_button_script.OnMouseDown（1229/1253）。放这里而非月度是本次修复关键。
##   一党制(≤7)：data[106] += 当前政治路线派系的 ideology/4，随后重算政治路线
##   多党(>7)：  data[106] += 保守派 support(party_number[1])/4
## party_ideology 我方以 FactionData.ideology 为准（influence 仅旧存档兼容，勿作增长源）。
## 顺序与原版一致：先用【旧】政治路线加 satisfied，再重算路线。
func _apply_policy_satisfied_growth(d: Array[int], w: WorldState) -> void:
	if w.factions.is_empty() or d.size() <= W.I_SATISFIED:
		return
	@warning_ignore("integer_division")
	if d[W.I_PARTY_SYSTEM] <= 7:
		var line: int = clampi(d[W.I_POLITICAL_LINE], 0, w.factions.size() - 1)
		var base_ideo: int = w.factions[line].ideology
		if base_ideo <= 0:
			base_ideo = w.factions[line].support
		d[W.I_SATISFIED] += base_ideo / 4
		_update_political_line(d, w)
	else:
		var cons: int = 0
		if w.factions.size() > FactionData.CONSERVATIVE:
			cons = w.factions[FactionData.CONSERVATIVE].support
		d[W.I_SATISFIED] += cons / 4
		# 原版 :1407-1438：多党分支同样在加完 data[106] 后重算 data[56]
		_update_political_line(d, w)
	d[W.I_SATISFIED] = maxi(0, d[W.I_SATISFIED])


# ── 双周：生活水平上限调整（原版 3749-3752，双周块）──
## 生活水平高于三产均值（扣除腐败）+20 时，向该上限回落 1/10。
func _fortnight_living_cap(d: Array[int]) -> void:
	@warning_ignore("integer_division")
	var output_avg := (d[W.I_INDUSTRY] + d[W.I_AGRICULTURE] + d[W.I_SERVICES] - d[W.I_CORRUPTION]) / 3
	if d[W.I_LIVING] > output_avg + 20:
		d[W.I_LIVING] -= (output_avg + 20) / 10


# ── 双周：allcountries[15] 内战压力（原版 3755-3779，生活上限之后、储备结算之前）──
## 国家 15 处于内战时：美苏关系向 700 靠拢、预算-2、外交声誉向 400-600 区间靠拢。
func _fortnight_cw_block(d: Array[int], w: WorldState) -> void:
	var cw_country := w.get_country_by_legacy_index(15)
	if cw_country == null or not cw_country.内战中:
		return
	if w.empires.size() > 1 and w.empires[1] != null and w.empires[1].relations < 700:
		w.empires[1].relations += 5
	if w.empires.size() > 0 and w.empires[0] != null and w.empires[0].relations < 700:
		w.empires[0].relations += 5
	d[W.I_BUDGET] -= 2
	if d[W.I_DIPLO] > 600:
		d[W.I_DIPLO] -= 2
	elif d[W.I_DIPLO] < 400:
		d[W.I_DIPLO] += 2


# ── 双周：威权+市场体制的腐败微降（原版 3780-3787）──
func _fortnight_ideology_corruption(d: Array[int]) -> void:
	if d[W.I_IDEOLOGY] >= 4 and d[W.I_ECON_SYSTEM] >= 14:
		d[W.I_CORRUPTION] -= 1


# ── 双周：储备金影响（原版 TimeScript.cs:3788-3912，双周块）──
## 除 UI 文案（经济.gd:_reserve_effect）外，原版还会真实结算：按年份/经济体制
## 降低腐败，并把三产与生活同时推向（或拉离）储备金锚点。
func _fortnight_reserve_effect(d: Array[int], year: int) -> void:
	var reserve := d[W.I_RESERVE]
	var econ := d[W.I_ECON_SYSTEM]
	var v := 0
	var corr := 0
	@warning_ignore("integer_division")
	if year < 1980:
		if econ == 13:
			corr = -(reserve / 400)
			v = 1 if reserve >= 600 else -(3 - reserve / 150)
		elif econ >= 14:
			corr = -(reserve / 200)
			v = 1 if reserve >= 750 else -(4 - reserve / 150)
	elif econ == 13:
		corr = -(reserve / 600)
		v = 1 if reserve >= 750 else -(4 - reserve / 150)
	elif econ == 14:
		corr = -(reserve / 400)
		v = 3 if reserve >= 1500 else -(7 - reserve / 150)
	elif econ == 15:
		corr = -(reserve / 200)
		v = -(13 - reserve / 150)
	elif econ == 12:
		corr = -(reserve / 200)
		v = 1 if reserve >= 600 else -(3 - reserve / 150)
	if corr != 0 or v != 0:
		d[W.I_CORRUPTION] += corr
		d[W.I_LIVING] += v
		d[W.I_SERVICES] += v
		d[W.I_INDUSTRY] += v


# ── 双周：人口超限特工惩罚（原版 TimeScript.cs:4538-4541，经济体制效果前）──
## 人口超过 9307 的部分，每 200 扣 1 特工。
func _fortnight_population_agent_penalty(d: Array[int]) -> void:
	@warning_ignore("integer_division")
	if (d[W.I_POPULATION] - 9307) / 200 > 0:
		d[W.I_AGENTS] -= (d[W.I_POPULATION] - 9307) / 200


# ── 双周：经济思想漂移（原版 TimeScript.cs:5311-5321，压力修正之后、工业衰减之前）──
## 计划经济体制（<=12）下，思想自由按年份不同速率向 1000 靠拢。
func _fortnight_econ_thought_drift(d: Array[int], year: int) -> void:
	@warning_ignore("integer_division")
	if d[W.I_ECON_SYSTEM] <= 11:
		if year < 1980:
			d[W.I_THOUGHT_FREEDOM] += (1000 - d[W.I_LIVING]) / 50
		else:
			d[W.I_THOUGHT_FREEDOM] += (1000 - d[W.I_LIVING]) / 40
	elif d[W.I_ECON_SYSTEM] == 12:
		if year < 1980:
			d[W.I_THOUGHT_FREEDOM] += (1000 - d[W.I_LIVING]) / 70
		else:
			d[W.I_THOUGHT_FREEDOM] += (1000 - d[W.I_LIVING]) / 60


# ── 双周：战后战争支持/兵源衰减（原版 TimeScript.cs:5878-5890，难度修正之后）──
## 用双周入口快照 array9[31]/array9[57] 回落当前超过 700 的战争支持/兵源。
func _fortnight_post_war_decay(d: Array[int], war_support_before: int, manpower_before: int) -> void:
	@warning_ignore("integer_division")
	if d[W.I_WAR_SUPPORT] >= 700:
		d[W.I_WAR_SUPPORT] -= war_support_before / 40
	if d[W.I_MANPOWER] >= 700:
		d[W.I_MANPOWER] -= manpower_before / 40


# ── 双周：预算增长回落（原版 TimeScript.cs:5903-5919，战后衰减之后）──
## 本轮预算比入口快照多 50 以上时，扣掉增长额的 1/4，再扣当前预算的 1/20。
## 原版内层 >50/>75/>100 为反编译不可达冗余（外层已 >50），只保留 /4 分支。
func _fortnight_budget_growth_fallback(d: Array[int], budget_before: int) -> void:
	@warning_ignore("integer_division")
	if d[W.I_BUDGET] - budget_before > 50:
		d[W.I_BUDGET] -= (d[W.I_BUDGET] - budget_before) / 4
		d[W.I_BUDGET] -= d[W.I_BUDGET] / 20


# ── 双周：人口预算加成（原版 TimeScript.cs:5928-5945，预算回落之后）──
## 市场经济体制 13/14/15 按人口规模分别以 /3000、/2000、/1000 给预算加成。
func _fortnight_population_budget_bonus(d: Array[int]) -> void:
	if d[W.I_ECON_SYSTEM] == 13:
		d[W.I_BUDGET] += int(round(float(d[W.I_POPULATION] - 9037) / 3000.0 + 1.0))
	elif d[W.I_ECON_SYSTEM] == 14:
		d[W.I_BUDGET] += int(round(float(d[W.I_POPULATION] - 9037) / 2000.0 + 1.0))
	elif d[W.I_ECON_SYSTEM] == 15:
		d[W.I_BUDGET] += int(round(float(d[W.I_POPULATION] - 9037) / 1000.0 + 1.0))


# ── 双周：经济体制效果（原版 4538-4715，双周块）──
## 含 data[52]/data[54] 显示等级条件副效果。
func _fortnight_econ_system_effect(d: Array[int]) -> void:
	var econ := d[W.I_ECON_SYSTEM]
	match econ:
		11:
			d[W.I_BUDGET] += 1
			d[W.I_THOUGHT_FREEDOM] -= 2
			d[W.I_LIVING] += 2
			d[W.I_INDUSTRY] += 2
			d[W.I_CORRUPTION] -= 2
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
	# TimeScript.cs:1224-1228：本次双周块入口快照，供 modifier[9/10]、战后衰减与预算回落使用。
	# 同一份入口快照也持久化给经济界面悬浮提示的 ±变化（data_old 语义）。
	w.记录入口快照()
	var support_before := d[W.I_PEOPLE_SUPPORT]
	var budget_before := d[W.I_BUDGET]
	var freedom_before := d[W.I_THOUGHT_FREEDOM]
	var war_support_before := d[W.I_WAR_SUPPORT]
	var manpower_before := d[W.I_MANPOWER]

	# 双周块按原版 TimeScript.cs 行序重排（本次审计对齐）：
	# 生活上限 3749 → 储备结算 3788 → 贸易 4135 → 战争支持漂移 4168 →
	# 领导人与军备资金 4318 → 人口特工惩罚/经济体制 4538 → 党政/舆论/领土漂移 4716 →
	# 军事学说 4897 → 科技持续 4974 → 投资效果 5264 → 压力修正 5266 → 经济思想漂移 5311 →
	# 工业 5323 → 服务业 5393 → 农业 5461 → 贷款 5512 → 科研 5608 → 难度 5757 →
	# 战后衰减 5878 → 预算回落 5903 → 人口预算加成 5928。
	# （TraitInfluence 4973 / MutualRelationsChange 5265 移植说明，见审计报告；modifier 周期块另算。）
	_fortnight_living_cap(d)
	_fortnight_cw_block(d, w)
	_fortnight_ideology_corruption(d)
	_fortnight_reserve_effect(d, year)
	_fortnight_trade_balance(d, w)
	_fortnight_satisfaction_drift(d, w)
	_fortnight_leader_effects(d, w)
	_fortnight_population_agent_penalty(d)
	_fortnight_econ_system_effect(d)
	_fortnight_political_drift(d, w)
	_fortnight_military_doctrine(d, w)
	_fortnight_trait_influence(d, w)
	_apply_tech_periodic(w)
	_influence_from_investments(d, year)
	_fortnight_mutual_relations(d, w)
	# AfricanBotSupport 的调用点在原版日块 TimeScript.cs:1040，已移入 _daily_rim_and_alliance_checks。
	_update_modifier_population_industry_pressure(d, w)
	_fortnight_econ_thought_drift(d, year)
	_fortnight_industry_decay(d)
	_fortnight_services_decay(d)
	_fortnight_agriculture_decay(d)
	_fortnight_loan_interest(d, w)
	_fortnight_research_advance(d, w)
	_fortnight_difficulty_bonus(d, w)
	_fortnight_post_war_decay(d, war_support_before, manpower_before)
	# ModifiesChanges 原版在 5907（战后衰减 5878 之后、预算回落 5903 之前）调用；
	# Godot 只移植了其中 modifier 0-17 的可确认部分，移植说明项见审计报告。
	_fortnight_modifiers(d, w, support_before, budget_before, freedom_before)
	_apply_modifier50_military(d, w)
	# 原版 ModifiesInfuence.cs:502-508：每轮双周强制激活修正 1 与 50。
	# （Godot 改版 dlc[3]=true 全 DLC 免费，开局已激活 50；这里保留原版强制激活作双保险。）
	if w.modifiers.size() > 1 and not _mod_active(w, 1):
		w.modifiers[1].is_active = true
	if w.modifiers.size() > 50 and not _mod_active(w, 50):
		w.modifiers[50].is_active = true
	_fortnight_budget_growth_fallback(d, budget_before)
	_fortnight_population_budget_bonus(d)
	_check_coup(d, w)
	# 原版 TimeScript.cs:5958：双周结算内 dlc[0] 时 FocusesResearching()
	# （裁决 2026-08-16：Focus 默认开启）。
	FocusSystem.tick()
	WAR_SYS.fortnight_wars(w)
	# 阴谋网也挂双周一次（原版 Death/Plot 在年/特定块；月结已跑，此处不重复击杀）
	if current_event_id == "":
		_check_endings(d, w, year)

	w.flush_economy()
	# 原版 TimeScript.cs:5943-5953：双周结束时写 data_old = 当前值 - 入口 array9。
	# 结算一次后保持不变，期间玩家加减不再改动（与原版一致）。
	w.结算两周变化()


# ============================================================================
# 修正双周效果 — 对齐 TimeScript.cs:5266-5310（modifies[4] 人口/工业压力）
# 及 ModifiesInfuence.ModifiesChanges 的 modifier 周期块（原版 5907 调用）。
# 内部数值为原版 ×10 量级（如 -5 工业 = -0.5 显示）
# ============================================================================

## modifier[4] 在产业自然衰减之前计算，因此与其它修正分开以保持原作顺序。
func _update_modifier_population_industry_pressure(d: Array[int], w: WorldState) -> void:
	if w == null or w.modifiers.size() <= 4:
		return
	if d[W.I_LIVING] < 200:
		w.modifiers[4].is_active = true
		d[W.I_THOUGHT_FREEDOM] += 2
		d[W.I_MANPOWER] -= 3
		d[W.I_INDUSTRY] -= (250 - d[W.I_LIVING]) / 40
	elif d[W.I_ECON_SYSTEM] > 12 and d[W.I_LIVING] < (d[W.I_ECON_SYSTEM] - 10) * 100:
		w.modifiers[4].is_active = true
		d[W.I_INDUSTRY] -= ((d[W.I_ECON_SYSTEM] - 10) * 100 - d[W.I_LIVING]) / 40
		d[W.I_CORRUPTION] += 1
		d[W.I_MANPOWER] -= 3
	else:
		w.modifiers[4].is_active = false


func _fortnight_modifiers(
		d: Array[int],
		w: WorldState,
		support_before: int,
		_budget_before: int,
		freedom_before: int
) -> void:
	if w == null:
		return
	var player := w.get_player_country()

	# 0 工业技术依赖：原作在解除的当轮仍会扣一次工业。
	if _mod_active(w, 0):
		if w.techs and w.techs.unlocked.size() > 10 and w.techs.unlocked[10]:
			w.modifiers[0].is_active = false
		d[W.I_INDUSTRY] -= 5

	# 2 服务业发展进程（ModifiesInfuence.cs:510-1198：寡头/教育/高考/医疗/票证/国策，动态结算）。
	if _mod_active(w, 2):
		_apply_modifier2_services(d, w)

	# 3 后毛时代效应。
	if _mod_active(w, 3):
		# 深度改革则解除并冲击。解除当轮仍继续执行下方周期效果。
		if d[W.I_IDEOLOGY] >= 4 or d[W.I_ECON_SYSTEM] >= 14:
			w.modifiers[3].is_active = false
			d[W.I_THOUGHT_FREEDOM] += 200
			d[W.I_PEOPLE_SUPPORT] += 100
			d[W.I_PARTY_SUPPORT] -= 250
			d[W.I_DIPLO] -= 10
			for p in w.politicians:
				if PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0:
					p.loyalty -= 100
				elif p.trait_personality > 1:
					p.loyalty += 100
		d[W.I_BUDGET] += 6
		d[W.I_AGENTS] += 2
		d[W.I_ARMY] += 5
		if is_mao_dead():
			d[W.I_PEOPLE_SUPPORT] += 5
			d[W.I_THOUGHT_FREEDOM] += 10
			d[W.I_LIVING] -= 5
			if w.empires.size() > EmpireData.USA:
				w.empires[EmpireData.USA].relations -= 5

	# 5 市场改革冲击。
	if _mod_active(w, 5):
		d[W.I_PEOPLE_SUPPORT] -= 2
		d[W.I_THOUGHT_FREEDOM] += 10
		d[W.I_BUDGET] += 2

	# 6 意识形态动员。
	if _mod_active(w, 6):
		d[W.I_PARTY_SUPPORT] += 5
		d[W.I_THOUGHT_FREEDOM] -= 2
		d[W.I_MANPOWER] += 1
		d[W.I_DIPLO] += 2
		if w.empires.size() > EmpireData.USA:
			w.empires[EmpireData.USA].relations -= 2
		if w.empires.size() > EmpireData.USSR:
			w.empires[EmpireData.USSR].relations -= 4

	# 7 五年计划：条件动态激活/解除。
	var plan_condition := (
		d[W.I_IDEOLOGY] == 3
		and w.leader != null
		and w.leader.trait_alignment == 5
		and w.leader.trait_personality > 0
		and d[W.I_REFORM_STAGE] >= 3
		and player != null
		and not player.has_tag("sev")
		and not player.has_tag("ovd")
		and not player.has_tag("okb")
	)
	if _mod_active(w, 7):
		if d[W.I_CORRUPTION] > 200:
			d[W.I_CORRUPTION] -= 1
		if d[W.I_THOUGHT_FREEDOM] > 800:
			d[W.I_THOUGHT_FREEDOM] -= 3
		if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA].relations < 400:
			w.empires[EmpireData.USA].relations += (500 - w.empires[EmpireData.USA].relations) / 100
		if d[W.I_INDUSTRY] < 500:
			d[W.I_INDUSTRY] += 3
		if d[W.I_MANPOWER] <= 400:
			d[W.I_MANPOWER] += 3
		if not plan_condition:
			w.modifiers[7].is_active = false
	elif plan_condition:
		w.modifiers[7].is_active = true

	# 8 经济联盟身份：加入时激活，退出当轮施加一次余波后解除。
	if player != null and player.has_tag("econ"):
		w.modifiers[8].is_active = true
	elif _mod_active(w, 8):
		w.modifiers[8].is_active = false
		if w.empires.size() > EmpireData.USA:
			w.empires[EmpireData.USA].relations += 2
		if w.empires.size() > EmpireData.USSR:
			w.empires[EmpireData.USSR].relations += 2
		d[W.I_THOUGHT_FREEDOM] -= 10

	# 9/10 边疆文化政策：以本轮入口快照削弱支持/自由化涨幅。
	if not _mod_active(w, 9):
		if d[W.I_XINJIANG_POLICY] > 0:
			w.modifiers[9].is_active = true
	else:
		d[W.I_MANPOWER] -= 10
		if d[W.I_PEOPLE_SUPPORT] > support_before:
			d[W.I_PEOPLE_SUPPORT] -= (d[W.I_PEOPLE_SUPPORT] - support_before) / 2
		if freedom_before > d[W.I_THOUGHT_FREEDOM]:
			d[W.I_THOUGHT_FREEDOM] += (freedom_before - d[W.I_THOUGHT_FREEDOM]) / 2
	if not _mod_active(w, 10):
		if d[W.I_TIBET_POLICY] > 0:
			w.modifiers[10].is_active = true
	else:
		d[W.I_MANPOWER] -= 10
		if d[W.I_PEOPLE_SUPPORT] > support_before:
			d[W.I_PEOPLE_SUPPORT] -= (d[W.I_PEOPLE_SUPPORT] - support_before) / 4
		if freedom_before > d[W.I_THOUGHT_FREEDOM]:
			d[W.I_THOUGHT_FREEDOM] += (freedom_before - d[W.I_THOUGHT_FREEDOM]) / 4

	# 11 自动化计划经济（OGAS）。原版唯一激活入口 = 事件97选项0（Event97.cs:58：
	# data[1]=0/忠诚±/激活均为该事件的一次性副作用；触发需 science[17]+体制10/11，
	# TimeScript.cs:10810）。事件97移植说明 → 恒不激活。原版无「econ==11 自动激活」
	# 逻辑（开局 data[16]=11 即中式计划，此前误加致开局党内支持清零，已移除）。
	# ModifiesInfuence.cs:1558-1570：每两周 +50（显示+5.0）；解除只在 Event112.cs:148。
	if _mod_active(w, 11):
		d[W.I_INDUSTRY] += 50
		d[W.I_SERVICES] += 50
		d[W.I_AGRICULTURE] += 50
		d[W.I_BUDGET] += 50
		d[W.I_PARTY_SUPPORT] -= 50
		d[W.I_LIVING] += 10
		d[W.I_CORRUPTION] -= 10

	# 12 政治危机的动态激活条件与完整代价。
	var output_average := (d[W.I_INDUSTRY] + d[W.I_AGRICULTURE] + d[W.I_SERVICES] - d[W.I_CORRUPTION]) / 3
	w.modifiers[12].is_active = output_average < 500 and w.date.year >= 1980
	if _mod_active(w, 12):
		d[W.I_BUDGET] -= 10
		d[W.I_AGENTS] -= 10
		d[W.I_MANPOWER] -= 3

	# 预算增长过快回落已拆到 _fortnight_budget_growth_fallback（TimeScript.cs:5903-5919），
	# 在 _on_fortnight 中按原版位置（战后衰减之后、人口预算加成之前）单独调用。

	# 13 工业创收。原作激活后不在此处自动解除。
	if not _mod_active(w, 13):
		if d[W.I_ECON_SYSTEM] >= 13 and d[W.I_LIVING] >= 700:
			w.modifiers[13].is_active = true
	elif d[W.I_ECON_SYSTEM] == 13:
		d[W.I_BUDGET] += d[W.I_LIVING] / 500
	elif d[W.I_ECON_SYSTEM] == 14:
		d[W.I_BUDGET] += d[W.I_LIVING] / 330
	elif d[W.I_ECON_SYSTEM] == 15:
		d[W.I_BUDGET] += d[W.I_LIVING] / 250

	# 14 改革派声势：邓小平不再占据原 politics[12] 身份时解除。
	if _mod_active(w, 14):
		var deng_valid := false
		if w.politicians.size() > 12:
			var deng: PoliticianData = w.politicians[12]
			deng_valid = (
				deng != null
				and deng.name_first == 13
				and deng.name_last == 13
				and deng.trait_personality == 2
				and deng.trait_alignment == 5
				and deng.trait_special == 11
			)
		if not deng_valid:
			w.modifiers[14].is_active = false

	# 15 农业发展进程（ModifiesInfuence.cs:1618-1720：下乡/乡建/公社/农业科技，动态结算；
	# 无封顶、无科技解除——Godot 早期版本自造的“>700 封顶 + 科技2解除”在原版全库无出处，已删除）。
	if _mod_active(w, 15):
		_apply_modifier15_agriculture(d, w)

	# 16/17 对苏/对美关系受损。
	if _mod_active(w, 16):
		var ussr_relation := w.empires[EmpireData.USSR].relations if w.empires.size() > EmpireData.USSR else d[W.I_USSR_RELATIONS]
		if ussr_relation >= 500:
			w.modifiers[16].is_active = false
		else:
			d[W.I_BUDGET] -= (500 - ussr_relation) / 50
			d[W.I_AGENTS] -= (500 - ussr_relation) / 100
	if _mod_active(w, 17):
		var usa_relation := w.empires[EmpireData.USA].relations if w.empires.size() > EmpireData.USA else d[W.I_USA_RELATIONS]
		if usa_relation >= 500:
			w.modifiers[17].is_active = false
		else:
			d[W.I_BUDGET] -= (500 - usa_relation) / 50
			d[W.I_AGENTS] -= (500 - usa_relation) / 100

	# ── 18-42：ModifiesInfuence.cs:1866-2260 ──
	if _mod_active(w, 18):
		d[W.I_THOUGHT_FREEDOM] += 2
		d[W.I_AGENTS] += 2
	elif _mod_active(w, 19):
		d[W.I_MANPOWER] -= 2
		_add_empire_relation(w, 0, 5)
		d[W.I_THOUGHT_FREEDOM] += 2
		d[W.I_BUDGET] += 2
	elif _mod_active(w, 20):
		_add_empire_relation(w, 0, -5)
		_add_empire_relation(w, 1, 2)
		d[W.I_ARMY] -= 2
		d[W.I_BUDGET] += 2
	if _mod_active(w, 21):
		_add_empire_relation(w, 1, 2)
		_add_empire_relation(w, 0, -2)
		d[W.I_ARMY] -= 2
		d[W.I_SCIENCE] += 5
	elif _mod_active(w, 22):
		d[W.I_THOUGHT_FREEDOM] += 2
		_add_empire_relation(w, 1, -5)
		d[W.I_AGENTS] += 2
		d[W.I_MANPOWER] += 2
	elif _mod_active(w, 23):
		_add_empire_relation(w, 0, 5)
		d[W.I_MANPOWER] -= 2
		d[W.I_THOUGHT_FREEDOM] += 2
		d[W.I_BUDGET] += 2
	if _mod_active(w, 24):
		d[W.I_PARTY_SUPPORT] += 2
		d[W.I_THOUGHT_FREEDOM] += 2
		d[W.I_BUDGET] += 2
	elif _mod_active(w, 25):
		d[W.I_SCIENCE] += 2
		d[W.I_PEOPLE_SUPPORT] -= 2
		d[W.I_THOUGHT_FREEDOM] -= 2
		d[W.I_CORRUPTION] -= 2
		d[W.I_BUDGET] -= 3
	elif _mod_active(w, 26):
		d[W.I_PARTY_SUPPORT] += 5
		d[W.I_PEOPLE_SUPPORT] -= 5
		d[W.I_THOUGHT_FREEDOM] -= 5
		d[W.I_CORRUPTION] -= 5
		d[W.I_LIVING] -= 5
	elif _mod_active(w, 27):
		d[W.I_ARMY] += 5
		d[W.I_PEOPLE_SUPPORT] -= 2
		d[W.I_CORRUPTION] -= 2
		d[W.I_BUDGET] -= 2
	if _mod_active(w, 28):
		if w.event_done_num(326) and w.result_of_event_num(326) == 0 \
				and _mod_active(w, 3) and _mod_active(w, 6) \
				and d[W.I_RELIGION] <= 25 and d[W.I_PARTY_SYSTEM] == 6 and d[W.I_ECON_SYSTEM] <= 11:
			_add_ideology(w, 0, 3)
			d[W.I_PARTY_SUPPORT] -= 5
			d[W.I_PEOPLE_SUPPORT] += 15
			d[W.I_THOUGHT_FREEDOM] -= 15
			d[W.I_CORRUPTION] -= 5
			d[W.I_BUDGET] += 3
			d[W.I_AGENTS] += 3
			for p in w.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0:
					p.power += 30
					p.loyalty += 30
		else:
			_add_ideology(w, 0, 1)
			_add_ideology(w, 1, 1)
			for p in w.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0 or p.trait_personality == 20:
					p.power += 10
					p.loyalty += 10
			d[W.I_PARTY_SUPPORT] -= 2
			d[W.I_PEOPLE_SUPPORT] += 2
			d[W.I_THOUGHT_FREEDOM] -= 2
			d[W.I_CORRUPTION] -= 2
			d[W.I_AGENTS] += 2
			if not _mod_active(w, 6):
				w.modifiers[28].is_active = false
	elif _mod_active(w, 29):
		_add_ideology(w, 0, -1)
		_add_ideology(w, 3, -1)
		_add_ideology(w, 4, -1)
		d[W.I_SERVICES] += 2
		d[W.I_INDUSTRY] += 2
		d[W.I_LIVING] += 5
		for p in w.politicians:
			if p == null or PoliticianSystem.is_vacant_politician(p):
				continue
			if p.trait_personality != 1:
				p.power -= 5
		if d[W.I_PARTY_SYSTEM] > 7:
			w.modifiers[29].is_active = false
			w.modifiers[28].is_active = true
	elif _mod_active(w, 30):
		_add_ideology(w, 3, 1)
		d[W.I_BUDGET] += 5
		d[W.I_DIPLO] -= 2
		_add_empire_relation(w, 0, 5)
		for p in w.politicians:
			if p == null or PoliticianSystem.is_vacant_politician(p):
				continue
			if p.trait_personality == 2:
				p.power += 10
		if d[W.I_ECON_SYSTEM] < 13:
			w.modifiers[30].is_active = false
			w.modifiers[28].is_active = true
	elif _mod_active(w, 31):
		_add_ideology(w, 4, 1)
		_add_empire_relation(w, 0, 5)
		for p in w.politicians:
			if p == null or PoliticianSystem.is_vacant_politician(p):
				continue
			if p.trait_personality == 3:
				p.power += 10
		d[W.I_CORRUPTION] -= 2
		d[W.I_OLIGARCH] -= 2
		d[W.I_DIPLO] -= 2
		if d[W.I_ECON_SYSTEM] < 14 or d[W.I_PRESS_POLICY] < 17:
			w.modifiers[31].is_active = false
			w.modifiers[28].is_active = true
	if _mod_active(w, 32):
		for p in w.politicians:
			if p == null or PoliticianSystem.is_vacant_politician(p):
				continue
			if p.trait_personality == 0:
				p.power += 10
			else:
				p.power -= 5
		if _mod_active(w, 6):
			d[W.I_PEOPLE_SUPPORT] += 10
			d[W.I_THOUGHT_FREEDOM] -= 10
			if w.event_done_num(670) and (w.result_of_event_num(670) == 0 or w.result_of_event_num(670) == 1):
				d[W.I_AGENTS] += 2
				d[W.I_ARMY] += 2
			if w.event_done_num(444) and w.result_of_event_num(444) == 0 and d[W.I_PRESS_POLICY] == 19:
				d[W.I_AGENTS] += 2
				d[W.I_ARMY] += 2
			# 复用函数开头声明的 player（w.get_player_country() 在同一轮内不变），
			# 避免内层重复声明触发 GDScript “There is already a variable named player” 解析错误。
			if player != null and player.has_tag("rim"):
				d[W.I_AGENTS] += 2
				d[W.I_ARMY] += 2
		else:
			d[W.I_PEOPLE_SUPPORT] -= 10
			d[W.I_THOUGHT_FREEDOM] += 15
		var china := w.get_player_country()
		if china != null and w.is_socialism(china, true):
			d[W.I_AGENTS] += 2
			d[W.I_ARMY] += 2
		if d[W.I_LIVING] > 1100:
			d[W.I_AGENTS] += 2
			d[W.I_ARMY] += 2
	if _mod_active(w, 33):
		d[W.I_PEOPLE_SUPPORT] += 2
		d[W.I_LIVING] += 2
		d[W.I_INDUSTRY] -= 2
		d[W.I_SERVICES] += 2
		d[W.I_ARMY] -= 5
	if _mod_active(w, 34):
		var r320 := w.result_of_event_num(320)
		if r320 == 1:
			d[W.I_AGRICULTURE] += 7
			d[W.I_INDUSTRY] += 2
			d[W.I_BUDGET] -= 3
			d[W.I_WAR_SUPPORT] += 2
			d[W.I_PEOPLE_SUPPORT] += 1
		elif r320 == 2:
			d[W.I_AGRICULTURE] += 3
			d[W.I_INDUSTRY] += 5
			d[W.I_BUDGET] -= 5
			d[W.I_MANPOWER] += 2
		elif r320 == 3:
			d[W.I_AGRICULTURE] += 7
			d[W.I_INDUSTRY] += 2
			d[W.I_BUDGET] -= 3
			d[W.I_WAR_SUPPORT] += 2
			d[W.I_PEOPLE_SUPPORT] += 1
			d[W.I_AGRICULTURE] += 3
			d[W.I_INDUSTRY] += 5
			d[W.I_BUDGET] -= 5
			d[W.I_MANPOWER] += 2
		elif r320 == 4:
			d[W.I_SERVICES] += 1
			d[W.I_INDUSTRY] += 1
			d[W.I_BUDGET] += 2
	if _mod_active(w, 35):
		d[W.I_BUDGET] -= 5
		d[W.I_INDUSTRY] += 5
		d[W.I_LIVING] += 5
		d[W.I_MANPOWER] += 2
	if _mod_active(w, 36):
		d[W.I_SCIENCE] += 5
		WAR_SYS.add_empire_power(EmpireData.USA, 5)
		WAR_SYS.add_empire_power(EmpireData.USSR, 5)
	if _mod_active(w, 37):
		d[W.I_CORRUPTION] -= 2
		d[W.I_SERVICES] += 2
		d[W.I_LIVING] += 5
		d[W.I_THOUGHT_FREEDOM] += 5
	if _mod_active(w, 38):
		d[W.I_PARTY_SUPPORT] += 5
		d[W.I_DIPLO] += 1
		d[W.I_WAR_SUPPORT] += 1
		if w.leader == null or w.leader.name_first != 32 or w.leader.name_last != 47:
			w.modifiers[38].is_active = false
	if _mod_active(w, 39):
		var usa_rel := w.empires[EmpireData.USA].relations if w.empires.size() > EmpireData.USA else 0
		if usa_rel < 150 and w.empires.size() > EmpireData.USA:
			w.empires[EmpireData.USA].relations = 150
		WAR_SYS.add_empire_power(EmpireData.USA, -5)
		_add_empire_relation(w, 1, -5)
		d[W.I_RESERVE] += 5
	if _mod_active(w, 40):
		if d[W.I_AGRICULTURE] < 400:
			d[W.I_AGRICULTURE] = 400
		if d[W.I_INDUSTRY] > 500:
			d[W.I_INDUSTRY] = 500
		if d[W.I_SERVICES] > 500:
			d[W.I_SERVICES] = 500
		if d[W.I_ARMY] > 2000:
			d[W.I_ARMY] = 2000
		_set_ideology(w, 0, 0)
		d[W.I_WAR_SUPPORT] += 10
		d[W.I_MANPOWER] += 5
		d[W.I_AGRICULTURE] += 4
		d[W.I_CORRUPTION] -= 5
		d[W.I_THOUGHT_FREEDOM] -= 10
		d[W.I_DIPLO] += 2
	if _mod_active(w, 41):
		_add_ideology(w, 3, 1)
		d[W.I_AGENTS] += 10
		WAR_SYS.add_empire_power(EmpireData.USA, 1)
		_add_ideology(w, 4, 1)
		for p in w.politicians:
			if p == null or PoliticianSystem.is_vacant_politician(p):
				continue
			if p.trait_personality == 2:
				p.power += 10

	# ── 42-51：ModifiesInfuence.cs:2228-2420 ──
	if _mod_active(w, 42):
		var c21 := w.get_country_by_legacy_index(21)
		if d[W.I_POLITICAL_DISPLAY] > 39 and not _mod_active(w, 17) \
				and c21 != null and c21.has_tag("对华贸易"):
			_add_empire_relation(w, 0, 4)
			d[W.I_BUDGET] += 2
			d[W.I_DIPLO] -= 1
		WAR_SYS.add_empire_power(EmpireData.USA, 1)
	if _mod_active(w, 43):
		var c21 := w.get_country_by_legacy_index(21)
		var china := w.get_player_country()
		if c21 != null and c21.has_tag("对华贸易") and china != null \
				and not china.has_tag("seato") and not china.has_tag("okb") and not china.has_tag("ovd") \
				and (china.government == 2 or china.government == 3):
			d[W.I_BUDGET] += 3
			d[W.I_SCIENCE] += 4
	if _mod_active(w, 44):
		var c21 := w.get_country_by_legacy_index(21)
		if not w.get_flag("YugAgree"):
			if c21 != null and c21.has_tag("对华贸易") and d[W.I_ECON_DISPLAY] < 36 and not _mod_active(w, 16):
				_add_empire_relation(w, 1, 4)
				d[W.I_BUDGET] += 2
				d[W.I_SCIENCE] += 2
		else:
			if c21 != null and c21.has_tag("对华贸易") and d[W.I_IDEOLOGY] < 2 and not _mod_active(w, 16):
				_add_empire_relation(w, 1, 5)
				d[W.I_BUDGET] += 6
				d[W.I_SCIENCE] += 6
		WAR_SYS.add_empire_power(EmpireData.USSR, 1)
	var c21b := w.get_country_by_legacy_index(21)
	var chinab := w.get_player_country()
	if _mod_active(w, 44) and c21b != null and c21b.has_tag("对华贸易") \
			and chinab != null and chinab.has_tag("okb") and d[W.I_INFLUENCE] >= 500:
		d[W.I_MIL_INTERVENTION] += 5
		d[W.I_BUDGET] += 2
		_add_empire_relation(w, 0, -3)
		_add_empire_relation(w, 1, -3)
		WAR_SYS.add_empire_power(EmpireData.USA, -1)
		WAR_SYS.add_empire_power(EmpireData.USSR, -1)
	if _mod_active(w, 46):
		d[W.I_BUDGET] += 6
		d[W.I_ARMY] += 5
		d[W.I_AGENTS] += 5
		_add_empire_relation(w, 0, -5)
		_add_empire_relation(w, 1, -5)
		WAR_SYS.add_empire_power(EmpireData.USA, -1)
		WAR_SYS.add_empire_power(EmpireData.USSR, -1)
	if _mod_active(w, 47):
		var okb47 := _count_tag(w, "okb")
		if okb47 < 7:
			d[W.I_BUDGET] -= 10
		elif okb47 < 14:
			d[W.I_BUDGET] -= 20
		else:
			d[W.I_BUDGET] -= 30
		d[W.I_AGENTS] += okb47 * 2
	if _mod_active(w, 48):
		var okb48 := _count_tag(w, "okb")
		if okb48 < 7:
			d[W.I_BUDGET] -= 10
		elif okb48 < 14:
			d[W.I_BUDGET] -= 20
		else:
			d[W.I_BUDGET] -= 30
		d[W.I_ARMY] += okb48
	if _mod_active(w, 49):
		d[W.I_MIL_INTERVENTION] += 30
		d[W.I_AGENTS] += 20
		_add_empire_relation(w, 0, -20)
		_add_empire_relation(w, 1, -20)
		if w.event_done_num(691):
			d[W.I_BUDGET] -= 2
			d[W.I_PARTY_SUPPORT] += 2
			d[W.I_THOUGHT_FREEDOM] += 1
			if d[W.I_WAR_SUPPORT] > 200:
				d[W.I_WAR_SUPPORT] = 200
			if w.result_of_event_num(691) == 1:
				d[W.I_BUDGET] += 4
				d[W.I_PARTY_SUPPORT] += 1
				d[W.I_PEOPLE_SUPPORT] -= 1
				d[W.I_DIPLO] += 2
				d[W.I_THOUGHT_FREEDOM] += 4
			elif w.result_of_event_num(691) == 2:
				var ussr_leader := w.empires[EmpireData.USSR].current_leader if w.empires.size() > EmpireData.USSR else -1
				if ussr_leader == 6 or ussr_leader == 7:
					_add_empire_relation(w, 1, 1)
	if _mod_active(w, 51):
		_apply_modifier51_oil(d, w)

	# ── 53/58/59/61/63/65：ModifiesInfuence.cs:2556-2890 ──
	if _mod_active(w, 53):
		var c17 := w.get_country_by_legacy_index(17)
		if c17 != null and c17.parts.size() > 0 and not c17.parts[0]:
			_add_ideology(w, 0, 1)
			_add_ideology(w, 2, 1)
			d[W.I_AGENTS] += 10
			WAR_SYS.add_empire_power(EmpireData.USSR, 1)
			for p in w.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0 or p.trait_personality == 1:
					p.power += 10
		elif c17 != null and c17.parts.size() > 0 and c17.parts[0] \
				and c17.has_tag("亲中") and c17.government == 1:
			_add_ideology(w, 0, 1)
			d[W.I_AGENTS] += 15
			for p in w.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0:
					p.power += 10
	if _mod_active(w, 58) and w.empires.size() > EmpireData.USSR \
			and w.empires[EmpireData.USSR].relations >= 500 and _dv(d, 153) > 0:
		d[153] -= 1
		d[W.I_BUDGET] -= 5
	var china59 := w.get_player_country()
	if not _mod_active(w, 59) and china59 != null and china59.has_tag("okb"):
		w.modifiers[59].is_active = true
	if _mod_active(w, 59):
		var okb59 := _count_tag(w, "okb")
		var au59 := 0
		var oar59 := _count_tag(w, "oar")
		var rim59 := _count_tag(w, "rim")
		for c in w.countries:
			if c != null and c.has_tag("au") and (c.government == 1 or c.sub_government == 0) \
					and w.event_done_num(500) and w.result_of_event_num(500) == 0:
				au59 += 1
		if okb59 > 0:
			d[W.I_ARMY] += okb59 * 3
			d[W.I_AGENTS] += okb59 * 2
			d[W.I_MIL_INTERVENTION] += okb59
		if au59 > 0:
			d[W.I_ARMY] += au59 * 3
			d[W.I_AGENTS] += au59 * 2
			d[W.I_MIL_INTERVENTION] += au59
		if oar59 > 0:
			d[W.I_ARMY] += oar59 * 3
			d[W.I_AGENTS] += oar59 * 2
			d[W.I_MIL_INTERVENTION] += oar59
		if rim59 > 0:
			d[W.I_ARMY] += rim59 * 6
			d[W.I_AGENTS] += rim59 * 4
			d[W.I_MIL_INTERVENTION] += rim59 * 2
	if _mod_active(w, 61):
		match _dv(d, 185):
			0:
				d[W.I_MANPOWER] += 1
			1:
				d[W.I_PARTY_SUPPORT] += 1
			2:
				d[W.I_MANPOWER] += 2
			3:
				d[W.I_PEOPLE_SUPPORT] += 1
			4:
				d[W.I_WAR_SUPPORT] -= 1
				if d[W.I_WAR_SUPPORT] > 700:
					d[W.I_WAR_SUPPORT] -= 3
			5:
				pass
			6:
				var china61 := w.get_player_country()
				if china61 != null and china61.sub_government == 19:
					d[W.I_THOUGHT_FREEDOM] -= 2
					d[W.I_DIPLO] += 2
					d[W.I_WAR_SUPPORT] += 4
	if _mod_active(w, 63):
		if not w.event_done_num(687):
			d[W.I_THOUGHT_FREEDOM] += 50
			d[W.I_WAR_SUPPORT] -= 15
			d[W.I_PARTY_SUPPORT] -= 10
			d[W.I_PEOPLE_SUPPORT] += 30
		else:
			d[W.I_THOUGHT_FREEDOM] -= 30
			d[W.I_WAR_SUPPORT] += 10
			d[W.I_PARTY_SUPPORT] -= 10
			d[W.I_PEOPLE_SUPPORT] += 30
			for p in w.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 20:
					p.power += 10
	if w.money_level > 0 and not _mod_active(w, 65):
		w.modifiers[65].is_active = true
	elif w.money_level <= 0 and _mod_active(w, 65):
		w.modifiers[65].is_active = false
	if _mod_active(w, 65):
		var ml := w.money_level
		w.leader_asset += 10 * ml
		d[W.I_PEOPLE_SUPPORT] -= 2 * ml
		d[W.I_THOUGHT_FREEDOM] += 2 * ml
		d[W.I_LIVING] -= 5 * ml
		d[W.I_INDUSTRY] -= 4 * ml
		d[W.I_AGRICULTURE] -= 4 * ml
		d[W.I_SERVICES] -= 4 * ml
		d[W.I_CORRUPTION] -= 2 * ml
		if w.leader_property.size() > 1 and w.leader_property[1]:
			d[W.I_BUDGET] -= 10
			d[W.I_SCIENCE] += 5
			d[W.I_MIL_INTERVENTION] += 10
			_add_empire_relation(w, 1, -2)
		if w.leader_property.size() > 2 and w.leader_property[2]:
			d[W.I_BUDGET] -= 20
			d[W.I_SCIENCE] += 5
			d[W.I_MIL_INTERVENTION] += 10
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR].relations < 250:
				w.empires[EmpireData.USSR].relations = 250
			if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA].relations < 250:
				w.empires[EmpireData.USA].relations = 250
		if w.leader_property.size() > 3 and w.leader_property[3]:
			d[W.I_BUDGET] -= 20
			d[W.I_PARTY_SUPPORT] += 5
			if d[W.I_PARTY_SUPPORT] < 400:
				d[W.I_PARTY_SUPPORT] = 400
			if d[W.I_PARTY_SYSTEM] > 7 and d[W.I_THOUGHT_FREEDOM] > 400:
				d[W.I_THOUGHT_FREEDOM] = 400
			d[W.I_MIL_INTERVENTION] += 10
			_add_empire_relation(w, 1, -2)
		if ml > 20 and d[W.I_MAO_MAUSOLEUM] != 9:
			start_event("popular_discontent")

	_mirror_empires_to_data(world)


# ── 产业自然衰减（TimeScript 5323-5370行） ──

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
		d[W.I_INDUSTRY] -= 8
		d[W.I_PARTY_SUPPORT] -= 1
	elif v < 710:
		d[W.I_INDUSTRY] -= 18
	elif v < 810:
		d[W.I_INDUSTRY] -= 25
	elif v < 1100:
		d[W.I_INDUSTRY] -= 40
		d[W.I_AGENTS] += 5
	else:
		d[W.I_INDUSTRY] -= 80
		d[W.I_AGENTS] += 10
	if d[W.I_ECON_SYSTEM] < 13:
		if d[W.I_AGRICULTURE] < 300:
			d[W.I_INDUSTRY] -= 4
		elif d[W.I_AGRICULTURE] < 500:
			d[W.I_INDUSTRY] -= 2
	d[W.I_BUDGET] += d[W.I_INDUSTRY] / 50


# ── 农业自然衰减（TimeScript 5461-5505行） ──

func _fortnight_agriculture_decay(d: Array[int]) -> void:
	var v := d[W.I_AGRICULTURE]
	if v < 250:
		d[W.I_AGRICULTURE] -= 2
		d[W.I_PARTY_SUPPORT] -= 10
		d[W.I_LIVING] -= 5
	elif v < 410:
		d[W.I_AGRICULTURE] -= 5
		d[W.I_PARTY_SUPPORT] -= 5
		d[W.I_LIVING] -= 2
	elif v < 610:
		d[W.I_AGRICULTURE] -= 9
		d[W.I_PARTY_SUPPORT] -= 1
	elif v < 710:
		d[W.I_AGRICULTURE] -= 19
	elif v < 810:
		d[W.I_AGRICULTURE] -= 26
	elif v < 1100:
		d[W.I_AGRICULTURE] -= 40
		d[W.I_ARMY] += 5
	else:
		d[W.I_AGRICULTURE] -= 80
		d[W.I_ARMY] += 10
	d[W.I_BUDGET] += d[W.I_AGRICULTURE] / 100


# ── 服务业自然衰减（TimeScript 5393-5438行） ──

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
		d[W.I_SERVICES] -= 8
		d[W.I_PARTY_SUPPORT] -= 1
	elif v < 710:
		d[W.I_SERVICES] -= 18
	elif v < 810:
		d[W.I_SERVICES] -= 25
	elif v < 1100:
		d[W.I_SERVICES] -= 40
		d[W.I_LIVING] += 5
	else:
		d[W.I_SERVICES] -= 80
		d[W.I_LIVING] += 10
	if d[W.I_ECON_SYSTEM] < 13:
		if d[W.I_AGRICULTURE] < 300:
			d[W.I_SERVICES] -= 5
		elif d[W.I_AGRICULTURE] < 500:
			d[W.I_SERVICES] -= 2
	d[W.I_BUDGET] += d[W.I_SERVICES] / 50


# ── 军事学说周期效果（TimeScript 4897-4969行） ──

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


# ── 贸易平衡（TimeScript.cs:4135-4167，双周块；原注释 854-911/3247-3272 系错误出处） ──

## 出口规模重算（原版 TimeScript.ExportValue，13180 起）。
## 完整版约 400 行；此处先实现“按对华贸易/经济联盟/经互会成员数重算出口与伙伴数”的核心，
## 让概览出口规模随外交关系变化，后续可按原版逐国加成继续细化。
func _recalc_export_value(d: Array[int], w: WorldState) -> void:
	var pc := w.get_player_country()
	if pc == null:
		return
	d[W.I_TRADE_PARTNERS] = 0
	d[W.I_INCOME] = _dv(d, W.I_EXPORT_BASE)  # 原版 ExportValue：data[23] = data[70]
	for c in w.countries:
		if c == pc or c.gwcode <= 0:
			continue
		var linked := c.has_tag("对华贸易") \
			or (c.has_tag("econ") and pc.has_tag("econ")) \
			or (c.has_tag("sev") and pc.has_tag("sev"))
		if linked:
			d[W.I_TRADE_PARTNERS] += 1
			d[W.I_INCOME] += 10


func _fortnight_trade_balance(d: Array[int], w: WorldState) -> void:
	# 先按原版 ExportValue 重算出口规模与贸易伙伴数，再执行石油危机修正与顺逆差结算。
	# 注意：_recalc_export_value 已归零并统计完三类贸易伙伴，这里绝不能再叠加旧循环。
	_recalc_export_value(d, w)
	# 石油危机修正（原版 :4135-4139）：modifies[12] 激活时 data[23] -= data[23]/6
	if _mod_active(w, 12):
		d[W.I_INCOME] -= d[W.I_INCOME] / 6
	# 贸易平衡（原版 :4140-4155）：顺差 budget+=(23-24)/10、people+=(23-24)/15；
	# 逆差 budget-=(23-24)/10、people-=(23-24)/15、living-=(23-24)/20
	@warning_ignore("integer_division")
	var diff := d[W.I_INCOME] - d[W.I_IMPORT_NEEDS]
	if diff > 0:
		d[W.I_BUDGET] += diff / 10
		d[W.I_PEOPLE_SUPPORT] += diff / 15
	else:
		d[W.I_BUDGET] -= diff / 10
		d[W.I_PEOPLE_SUPPORT] -= diff / 15
		d[W.I_LIVING] -= diff / 20
	# 伙伴数效应（原版 :4156-4167）：≤10 → thought/agents -= (-9+data[25])；>18 → thought += data[25]-18
	if d[W.I_TRADE_PARTNERS] <= 10:
		d[W.I_THOUGHT_FREEDOM] -= -9 + d[W.I_TRADE_PARTNERS]
		d[W.I_AGENTS] -= -9 + d[W.I_TRADE_PARTNERS]
	elif d[W.I_TRADE_PARTNERS] > 18:
		d[W.I_THOUGHT_FREEDOM] += d[W.I_TRADE_PARTNERS] - 18


# ── 满意度/异见漂移（TimeScript 4168-4201行） ──

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


# ── 双周：大国领导人与军备资金效果（TimeScript.cs:4318-4510） ──
## 原版外层 if(!dlc[0])：dlc 是 new bool[5]（GlobalScript.cs:221），无任何 =true 写入点，
## 默认 false → 该分支恒真。Godot 建模说明 DLC 系统，按恒真移植。
## now_leader 语义按 modify_choose.cs 显示索引（Event89.cs 也按 1=安德罗波夫/3=谢尔比茨基
## 写 now_leader），与 leaders[] 数组下标解耦。
func _fortnight_leader_effects(d: Array[int], w: WorldState) -> void:
	if w.empires.size() < 2 or w.empires[0] == null or w.empires[1] == null:
		return
	var usa: EmpireData = w.empires[0]
	var ussr: EmpireData = w.empires[1]
	var player := w.get_player_country()
	var china_in_sev: bool = player != null and player.has_tag("sev")
	var relres: bool = w.get_flag("relres")

	# data[69]>7 → 美国储备资金 += data[69]/7（TimeScript.cs:4318-4321）
	if d[W.I_LOAN] > 7:
		usa.money += d[W.I_LOAN] / 7

	# 苏联领导人双周效果（TimeScript.cs:4324-4443）
	match ussr.current_leader:
		0:
			ussr.money += 20
			if not relres and not china_in_sev:
				usa.relations += 5
				d[W.I_MANPOWER] -= 2
		1:
			if not relres and not china_in_sev:
				usa.relations += 5
			else:
				_politician_power_boost(w, [2])
		2:
			ussr.relations += 5
			if relres or china_in_sev:
				_politician_power_boost(w, [1])
		3:
			if not relres and not china_in_sev:
				usa.relations += 5
				d[W.I_MANPOWER] -= 2
			else:
				ussr.relations += 5
		4:
			if not relres and not china_in_sev:
				d[W.I_AGENTS] -= 5
			else:
				ussr.relations += 5
				d[W.I_AGENTS] += 5
		5:
			ussr.relations += 5
			if relres or china_in_sev:
				_politician_power_boost(w, [2])
		6:
			ussr.money -= 20
			ussr.relations += 5
			d[W.I_THOUGHT_FREEDOM] += 5
			_politician_power_boost(w, [3])
		8:
			ussr.money -= 20
			ussr.relations += 5
			d[W.I_THOUGHT_FREEDOM] += 5

	# 美国总统双周效果（TimeScript.cs:4444-4502）
	var year := d[W.I_YEAR] if d.size() > W.I_YEAR else w.date.year
	if year >= 1981 and usa.current_leader <= 0:
		usa.money += 5
		d[W.I_THOUGHT_FREEDOM] += 5
	elif usa.current_leader == 1 or (year >= 1977 and year < 1981):
		usa.relations += 10
	elif usa.current_leader == 2:
		usa.money += 5
		if player != null and not player.has_tag("ovd") and not player.has_tag("okb"):
			usa.relations += 5
	elif usa.current_leader == 3:
		usa.relations += 10
	elif usa.current_leader == 4:
		usa.money += 2
		usa.power -= 2
		ussr.power += 1
	elif usa.current_leader == 5:
		usa.power -= 4
		ussr.power += 2
		usa.relations += 2
		if player != null and player.government == 3:
			usa.relations += 2
	elif usa.current_leader == 6:
		usa.money += 1
		usa.power -= 1
	elif usa.current_leader == 7:
		usa.money -= 2
		if player != null and player.government == 2:
			usa.relations += 2
		_politician_power_boost(w, [2, 3])


## TimeScript 领导人效果里的 politics.traits[0]∈set 循环：对应 Godot trait_personality。
func _politician_power_boost(w: WorldState, personalities: Array[int]) -> void:
	for p in w.politicians:
		if p == null:
			continue
		if personalities.has(p.trait_personality):
			p.power += 5


# ── 政治满意度漂移（TimeScript 4716-4895行，党政/舆论/领土/宗教） ──

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
	# ── 宗教政策对政治开放度的漂移（原版 TimeScript.cs:4791-4815）──
	match d[W.I_RELIGION]:
		24, 25:
			if pd > 38:
				d[W.I_POLITICAL_OPENNESS] -= 15
		28:
			if pd < 40:
				d[W.I_POLITICAL_OPENNESS] += 10
		29:
			if pd > 39:
				d[W.I_POLITICAL_OPENNESS] -= 15



# ── 难度修正（TimeScript 5757-5853行） ──

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
			if is_mao_dead():
				for p in w.politicians:
					if p == null:
						continue
					if p.trait_personality == 0:
						p.power += 50
					else:
						p.loyalty -= 10


# ── 政变条件（TimeScript.PlotPlayer 100-113行） ──

func _check_coup(d: Array[int], w: WorldState) -> void:
	if not is_mao_dead():
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
		elif p.loyalty < 50 and special == 9:
			dominated = true
		if dominated and special != 17 and special != 19 and not p.is_under_investigation:
			disloyal_power += p.power
	if disloyal_power / 5 > d[W.I_PARTY_SUPPORT]:
		start_event("congress_conspiracy")


## TimeScript.PlotPlayerCause（TimeScript.cs:250-266）：按不忠势力判断「针对你的阴谋」，
## 并把结果写到 leader.is_sagovor（本端口对应 leader.is_conspiracy）。
## 谓词与 _check_coup（PlotPlayer）不同：trait_background=28 阈值 1500、
## trait_alignment=41 阈值 1200、trait_special 16/35 阈值 300 等。
func _plot_player_cause(d: Array[int], w: WorldState) -> void:
	if w == null or w.leader == null:
		return
	var disloyal_power := 0
	for p in w.politicians:
		if p == null or p.is_under_investigation:
			continue
		if p.trait_special == 17 or p.trait_special == 19 or p.trait_alignment == 40:
			continue
		var dominated := false
		if p.trait_background == 28 and p.loyalty < 1500:
			dominated = true
		elif p.trait_alignment == 41 and p.loyalty < 1200:
			dominated = true
		elif p.loyalty < 300 and (p.trait_special == 16 or p.trait_special == 35):
			dominated = true
		elif p.you_fall:
			dominated = true
		elif p.loyalty < 150 and p.trait_special != 9 and p.trait_special != 37:
			dominated = true
		elif p.loyalty < 50 and (p.trait_special == 9 or p.trait_special == 37):
			dominated = true
		if dominated:
			disloyal_power += p.power
	@warning_ignore("integer_division")
	var threshold: int = d[W.I_PARTY_SUPPORT] / 4 * 3
	@warning_ignore("integer_division")
	w.leader.is_conspiracy = disloyal_power / 5 > threshold


## 顶栏「阴谋临近」提示图标判定（TimeScript.AlarmIconChange 45-49 行）：
## leader.is_sagovor（= leader.is_conspiracy）或党内支持-70 低于临界线时亮。
func plot_alert_active() -> bool:
	if world == null or world.leader == null:
		return false
	var d := world.数值表
	var leader_threat: bool = world.leader.is_conspiracy
	@warning_ignore("integer_division")
	var party_threat: bool = _dv(d, W.I_PARTY_SUPPORT) - 70 \
		<= 300 + _dv(d, W.I_THOUGHT_FREEDOM) / 5 - (_dv(d, W.I_PEOPLE_SUPPORT) - 500) / 5
	return leader_threat or party_threat


## TimeScript.cs:1453-1456：党内支持低于临界线时进入事件4（阴谋），每日判定。
func _check_daily_conspiracy(d: Array[int]) -> void:
	if current_event_id != "":
		return
	if d[W.I_PARTY_SUPPORT] <= 300 + d[W.I_THOUGHT_FREEDOM] / 5 - (d[W.I_PEOPLE_SUPPORT] - 500) / 5:
		start_event("congress_conspiracy")


## TimeScript.cs:289-294：政党制度达标后，每年 10 月 1 日直接进入选举。
func _check_scheduled_events() -> void:
	if world == null or current_event_id != "":
		return
	if world.get_flag("election_due") and world.数值表[W.I_PARTY_SYSTEM] > 7:
		world.set_flag("election_due", false)
		start_event("npc_elections")
		return
	if world.date.day == 1 and world.date.month == 10 and world.数值表[W.I_PARTY_SYSTEM] > 7:
		start_event("npc_elections")


func _dv(d: Array, idx: int) -> int:
	return d[idx] if d.size() > idx else 0


func _country_tag(w: WorldState, idx: int, tag: String) -> bool:
	var c := w.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)


func _country_dev_is(w: WorldState, idx: int, dev: int) -> bool:
	var c := w.get_country_by_legacy_index(idx)
	return c != null and c.development == dev


## TimeScript.cs 逐帧/逐块成就检查的移植子集（其余 9 个在 GameState.WarResult 各战争分支内，
## 待战争胜利特效批移植时同步接线）。
func _check_periodic_achievements(w: WorldState) -> void:
	if w == null:
		return
	var d := w.数值表
	# TimeScript.cs:5965：data[113..116] 全为 9 → Set(28)。
	if _dv(d, 113) == 9 and _dv(d, 114) == 9 and _dv(d, 115) == 9 and _dv(d, 116) == 9:
		Achievements.set_achievement(28)
	# TimeScript.cs:3220：data[131]==1 且 44.sub∈{7,9}、86.sub==9、85.sub==9、87.sub==7 → Set(131)。
	var c44 := w.get_country_by_legacy_index(44)
	var c85 := w.get_country_by_legacy_index(85)
	var c86 := w.get_country_by_legacy_index(86)
	var c87 := w.get_country_by_legacy_index(87)
	if _dv(d, 131) == 1 and c44 != null and (c44.sub_government == 9 or c44.sub_government == 7) \
			and c86 != null and c86.sub_government == 9 \
			and c85 != null and c85.sub_government == 9 \
			and c87 != null and c87.sub_government == 7:
		Achievements.set_achievement(131)
	# TimeScript.cs:3257：台湾路线2/决议7 且 51 内战中 且 data[157]>0 → Set(155)。
	var c51 := w.get_country_by_legacy_index(51)
	var dec7 := w.decisions != null and w.decisions.completed.size() > 7 and w.decisions.completed[7]
	if (_dv(d, W.I_TAIWAN_STATUS) == 2 or dec7) and c51 != null and c51.内战中 and _dv(d, 157) > 0:
		Achievements.set_achievement(155)
	# TimeScript.cs:3261/3265：data[143] <=10 / >=60 且 modifier51 激活 → Set(158)/Set(157)。
	var mod51 := w.modifiers.size() > 51 and w.modifiers[51] != null and w.modifiers[51].is_active
	if mod51 and _dv(d, 143) <= 10:
		Achievements.set_achievement(158)
	if mod51 and _dv(d, 143) >= 60:
		Achievements.set_achievement(157)
	# TimeScript.cs:3269：36/101/102/103/105 全亲中 → Set(156)。
	var all_proprc := true
	for idx in [36, 101, 102, 103, 105]:
		var cc := w.get_country_by_legacy_index(idx)
		if cc == null or not cc.has_tag("亲中"):
			all_proprc = false
			break
	if all_proprc:
		Achievements.set_achievement(156)


func _check_endings(d: Array[int], _w: WorldState, _year: int) -> void:
	# 原版自动结局只有 TimeScript.cs:705 的人口崩盘 ToEnding(4)。
	# 1993 强制结局与预算/派系两个分支在原版源码无对应（grep 全量 0 命中），
	# 属早期误植；正常终局走 1986-01-01 的 ending_choice 事件（in1992_script 语义）。
	if d[W.I_POPULATION] < 6671:
		_trigger_ending(4)
		return


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
