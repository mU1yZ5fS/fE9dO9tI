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
var _pending_event_ending_id: int = -1

# 速度 → tick 间隔（秒）
const TICK_INTERVALS: Array[float] = [0.0, 0.2, 0.1, 0.05, 0.03]
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

var cached_region_map_image: Image = null
var cached_owner_palette_image: Image = null
var cached_color_palette_image: Image = null

var cached_region_map_tex: ImageTexture = null
var cached_owner_palette_tex: ImageTexture = null
var cached_color_palette_tex: ImageTexture = null

## 启动加载屏预热好的外交场景 PackedScene(点开始时 change_scene_to_packed 无缝进场)
var cached_diplomacy_scene: PackedScene = null

var _map_preload_thread: Thread = null
## 本机 GPU 安全纹理上限（主线程查询后缓存，供后台解码线程读取）
var _safe_max_tex_size: int = 4096


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_tech_effects()
	_preload_region_map()
	if EventEngine:
		EventEngine.event_triggered.connect(_on_event_triggered)


func _preload_region_map() -> void:
	if cached_region_map_image != null:
		return
	# 主线程查询本机 GPU 2D 纹理上限（RenderingServer 不可在子线程调用）。
	# 取 min(GPU上限, 8192)：8192 已足够保真且显存可控；只支持 4096 的旧机自动降到 4096。
	# 移动 GPU 常见上限仅 4096（见 Godot 文档 3D rendering limitations），超限会上传失败→采样全黑→地球全蓝。
	var rd := RenderingServer.get_rendering_device()
	if rd:
		var gpu_limit := rd.limit_get(RenderingDevice.LIMIT_MAX_TEXTURE_SIZE_2D)
		if gpu_limit > 0:
			_safe_max_tex_size = mini(gpu_limit, 8192)
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

	# 按本机 GPU 安全上限缩放底图，避免在纹理上限较低的手机上上传失败（地球全蓝）。
	# region 图为 id 编码图，只能用 INTERPOLATE_NEAREST，禁止插值/有损压缩以免 id 混色。
	var max_size := _safe_max_tex_size
	if img.get_width() > max_size or img.get_height() > max_size:
		var ratio := float(max_size) / float(maxi(img.get_width(), img.get_height()))
		img.resize(int(img.get_width() * ratio), int(img.get_height() * ratio), Image.INTERPOLATE_NEAREST)

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

	is_map_data_preloaded = true
	map_data_preloaded.emit()
	print("GameManager: 地图底图、数据加载及纹理分配全部完成")


func _on_region_map_preloaded_failed() -> void:
	if _map_preload_thread != null:
		_map_preload_thread.wait_to_finish()
		_map_preload_thread = null
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
		print("GameManager: 地图归属运行时状态与调色板已重置")


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
	call_deferred("_start_initial_events")


func load_game(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("GameManager: 存档不存在 %s" % path)
		return
	# 不传 type_hint：.res 内嵌 class_name 时强制 WorldState 会误报 not found
	var loaded = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if loaded is WorldState:
		world = loaded as WorldState
		_sync_date_to_data(world)
		# 旧档科技数组可能只有 27 槽（TECH_COUNT 已扩到 34），迁移补齐
		if world.techs != null:
			world.techs.ensure_size()
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
	return world != null


func delete_save_slot(slot: int) -> bool:
	return SaveCatalog.delete_slot(slot)


func tick() -> void:
	if world == null:
		return
	var old_month := world.date.month
	var old_year := world.date.year
	world.date.advance()
	_sync_date_to_data(world)

	_daily_deficit_recovery(world)
	_daily_science_gen(world)
	_update_displays(world.数值表)
	# 原版日块顺序：政治路线 data[56]（1146-1226）先于体制重算（1265-1445），每日执行。
	_update_political_line(world.数值表, world)
	_political_system_recalc(world.数值表, world)

	if world.date.month != old_month:
		_on_month_changed()
	if world.date.year != old_year:
		_on_year_changed()

	_check_scheduled_events()
	_check_daily_conspiracy(world.数值表)

	if current_event_id == "" and world.date.day % 14 == 0:
		_on_fortnight()

	WAR_SYS.check_war_endings()

	if EventEngine:
		EventEngine.check_and_fire()

	world.clamp_values()
	world.clamp_empire_relations()
	_mirror_empires_to_data(world)
	world.sync_economy()
	date_changed.emit(world.date)
	stats_changed.emit()


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


## 事件结果页确认后再进入结局，复现原版 Results_text 的 load_scene_after_click。
func queue_ending_after_event(ending_id: int) -> void:
	_pending_event_ending_id = ending_id


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
	# 事件 444 未接入 → completed_event_ids.get(444,-1) 恒 -1（原版初始态）→ !=0 恒真。
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
	# FAC-05 / ECO-FAC-01：政策变更反馈派系 support / points
	_apply_policy_faction_feedback(category_idx, current_val, target_val)
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
	# TimeScript.cs:918-925：改革开放进入第二阶段后，等待满 6 个月才讨论外资。
	# 原作仅在 54 号事件尚未完成时累计，事件引擎以 event_id 保存同一状态。
	if d[W.I_REFORM_STAGE] == 2 and not w.completed_event_ids.has("reform_investment"):
		d[W.I_INVESTMENT_DELAY] += 1
	# TimeScript.cs:952-956：印度/越南外交操作的月度冷却与印度支援标记。
	var vietnam := w.get_country_by_legacy_index(11)
	if vietnam != null:
		vietnam.stability = 0
	var india := w.get_country_by_legacy_index(19)
	if india != null:
		india.stability = 0
		india.prc_power = 0
	# TimeScript.cs:913-918：伊朗与苏联特殊外交槽每季度重置。
	if w.date.month % 3 == 0:
		var iran := w.get_country_by_legacy_index(8)
		if iran != null:
			iran.stability = 0
		var soviet_country := w.get_country_by_legacy_index(7)
		if soviet_country != null:
			soviet_country.development = 0
	# 原版月块（data[19]==1）：人口增长、寡头成长、外援 dota。
	# （体制重算与政治路线 data[56] 都在日块，见 tick。）
	_monthly_population(d, w)
	_monthly_oligarch(d, w)
	_monthly_foreign_aid(d, w)
	# 政客：调查/监视、自动支持打压、职位 power、空缺派系领袖（TimeScript ~937, ~2172）
	POL_SYS.monthly_politics(d, w)
	# 半年：factionsPoints 积分（原版 data[19]==1 && month 1 或 7）+ 简化漂移
	if w.date.month == 1 or w.date.month == 7:
		_biannual_faction_points(d, w)
		_biannual_faction_drift(w)
	WAR_SYS.monthly_war_points()
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
	# 年度进口需求增量（原版 TimeScript.cs:514 data[24] += ImportChange；公式 GameState.cs:11-16）
	d[W.I_IMPORT_NEEDS] += w.import_change()
	# POL-05 / POL-12：年龄 +1、病弱/老死、任职年数（TimeScript 615–621 + DeathPolitics）
	POL_SYS.annual_politics(d, w)


# ============================================================================
# 政客生命周期 — 逻辑已拆至 数据脚本/politician_system.gd，此处仅保留公开 API 转发 stub
# （外部调用点：政治界面 / 事件脚本 kill_politician 零改动）
# ============================================================================

func change_of_killing(politic_index: int) -> float:
	return POL_SYS.change_of_killing(politic_index)


func kill_politician(pol_index: int) -> void:
	POL_SYS.kill_politician(pol_index)


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


# ── 每日：科研点生成（原版 1457-1458，日块）──
## data[11] += data[73]/40，每日执行（原版日块，非月块）。
func _daily_science_gen(w: WorldState) -> void:
	w.数值表[W.I_SCIENCE] += w.数值表[W.I_BUDGET_SCIENCE] / 40


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


# ── 双周：贷款利息（TimeScript 5512-5605行；外援 dota 在月块 2295-2318，见 _monthly_foreign_aid） ──
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


## 月度外援 dota（原版 TimeScript.cs:2295-2318，月块 data[19]==1）。
## data[146] = 援助强度；贸易同盟国吃援助，减美/苏势力、增中势力。
func _monthly_foreign_aid(d: Array[int], w: WorldState) -> void:
	var aid: int = d[W.I_FOREIGN_AID] if d.size() > W.I_FOREIGN_AID else 0
	if aid <= 0:
		return
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

	# ─ 腐败扣预算/生活水平（原版 8186-8187，投资块末尾，用投资后腐败值）──
	d[W.I_BUDGET] -= d[W.I_CORRUPTION] / 10
	d[W.I_LIVING] -= d[W.I_CORRUPTION] / 50


# ── 政治体制自动重算 ──

func _political_system_recalc(d: Array[int], w: WorldState) -> void:
	# 原版 TimeScript.cs 日块体制重算（num20=5 逐项修正体系，:1265-1445），
	# 2026-08 对齐审查重写：此前移植用 "score=(econ-9)+(party-5)+..." 数学公式与
	# 分支阈值（score<=6/9/11/15/20），与原版 num20<=0/3/6/9/12 体系完全不符；
	# 开局数据下两者恰都收敛到威权（num20=5-1-1-2-1=0 → 分支1），但政策变化后
	# 结果分歧。逐字重写如下（差异：DevelopedConsumerism/事件 502/681/674/675 未移植 → 跳过）。
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
	# DevelopedConsumerism（原版开局 0，GameStartScript.cs:127）端口无对应 → 跳过
	if _mod_active(w, 40):
		num20 -= 1
	if _mod_active(w, 38) and num20 > 0:
		num20 = 0
	# event_done[502]/[681]/(674/675) 未移植 → 跳过

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


## 满足现状者 data[106] 增长——【仅切政策成功时】调用一次，对齐原版
## Doctrine_button_script.OnMouseDown（1229/1253）。放这里而非月度是本次修复关键。
##   一党制(≤7)：data[106] += 当前政治路线派系的 ideology(influence)/4，随后重算政治路线
##   多党(>7)：  data[106] += 保守派 support(party_number[1])/4
## party_ideology 我方用 FactionData.influence（开局=原 ideology 列）。
## 顺序与原版一致：先用【旧】政治路线加 satisfied，再重算路线。
func _apply_policy_satisfied_growth(d: Array[int], w: WorldState) -> void:
	if w.factions.is_empty() or d.size() <= W.I_SATISFIED:
		return
	@warning_ignore("integer_division")
	if d[W.I_PARTY_SYSTEM] <= 7:
		var line: int = clampi(d[W.I_POLITICAL_LINE], 0, w.factions.size() - 1)
		var base_ideo: int = w.factions[line].influence
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
	# （TraitInfluence 4973 / MutualRelationsChange 5265 未移植，见审计报告；modifier 周期块另算。）
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
	_apply_tech_periodic(w)
	_influence_from_investments(d, year)
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
	# Godot 只移植了其中 modifier 0-17 的可确认部分，未移植项见审计报告。
	_fortnight_modifiers(d, w, support_before, budget_before, freedom_before)
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

	# 2 社会动荡。
	if _mod_active(w, 2):
		d[W.I_PEOPLE_SUPPORT] -= 10
		d[W.I_THOUGHT_FREEDOM] += 20

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
	# TimeScript.cs:10810）。事件97未移植 → 恒不激活。原版无「econ==11 自动激活」
	# 逻辑（开局 data[16]=11 即中式计划，此前误加致开局党内支持清零，已移除）。
	if _mod_active(w, 11):
		d[W.I_INDUSTRY] += 20
		d[W.I_AGRICULTURE] += 20
		d[W.I_BUDGET] += 50
		d[W.I_PARTY_SUPPORT] -= 50
		d[W.I_LIVING] += 2
		d[W.I_CORRUPTION] -= 1
		if d[W.I_ECON_SYSTEM] > 11:
			w.modifiers[11].is_active = false
			d[W.I_PARTY_SUPPORT] += 500
			d[W.I_AGENTS] -= 500
			d[W.I_BUDGET] -= 500

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

	# 15 上山下乡（原版 ModifiesInfuence.cs:1618+ 只有激活与文案/小数值效果，无封顶、无科技解除；
	# Godot 早期版本自造的“>700 封顶 + 科技2解除”在原版全库无出处，已删除）。

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

func _fortnight_trade_balance(d: Array[int], w: WorldState) -> void:
	# data[25] 贸易伙伴数：原版为静态初值 14 + 外交/事件增减；Godot 以国家标签动态重算（差异已注释）
	d[W.I_TRADE_PARTNERS] = 0
	var pc := w.get_player_country()
	if pc == null:
		return
	for c in w.countries:
		if c == pc or c.gwcode <= 0:
			continue
		if c.has_tag("对华贸易"):
			d[W.I_TRADE_PARTNERS] += 1
		elif c.has_tag("econ") and pc.has_tag("econ"):
			d[W.I_TRADE_PARTNERS] += 1
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
## 默认 false → 该分支恒真。Godot 未建模 DLC 系统，按恒真移植。
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


## TimeScript.cs:891-894：这个支按每日判定，且同样进入事件 4，不是结局。
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
