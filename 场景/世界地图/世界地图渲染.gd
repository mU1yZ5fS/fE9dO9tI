class_name TerritoryMap
extends MeshInstance3D

signal country_selected(gwcode: int, country_name: String)
signal region_selected(region_id: int, gwcode: int, country_name: String)
## 地区/国家数据就绪（战争图标管理器据此计算语义锚点位置）。
signal map_data_ready

# ── 数据源 ──
@export_file("*.json") var meta_path: String = "res://资产/地图/map_meta.json"
@export_file("*.json") var regions_path: String = "res://资产/地图/map_regions.json"
@export_file("*.json") var countries_path: String = "res://资产/地图/map_countries.json"
@export_file("*.png") var region_map_path: String = "res://资产/地图/map_color.png"

# ── 球体与视觉设置 ──
@export var sphere_radius: float = 1.0
@export var water_color: Color = Color(0.07, 0.22, 0.38)
@export var border_color: Color = Color(0.02, 0.02, 0.02, 0.75)
@export var selected_color: Color = Color(1.0, 0.92, 0.15, 1.0)
@export var hover_color: Color = Color(1.0, 1.0, 1.0, 0.85)

# ── 昼夜系统 ──
@export var day_night_enabled: bool = true
@export_range(0.0, 1.0, 0.01) var night_strength: float = 0.55
@export_range(0.01, 0.5, 0.01) var terminator_softness: float = 0.09
@export var daylight_cycle_seconds: float = 45.0
@export var sun_axial_tilt_degrees: float = 23.4

enum ColorMode { GOVERNMENT, INFLUENCE, MILITARY, ECONOMIC }
var color_mode: int = ColorMode.GOVERNMENT

# ── 预设颜色常量 ──
const GOV_SOCIALIST := Color(0.80, 0.10, 0.08)
const GOV_LIBERAL := Color(0.10, 0.24, 0.74)
const GOV_REFORM := Color(0.08, 0.55, 0.22)
const GOV_AUTHORITARIAN := Color(0.42, 0.42, 0.42)
const GOV_EXTREMIST := Color(0.05, 0.05, 0.05)

const BLOC_NEUTRAL := Color(0.46, 0.46, 0.46)
const MAP_PRC := Color(0.95, 0.45, 0.05)
const MAP_BLUE := Color(0.08, 0.30, 0.72)
const MAP_RED := Color(0.78, 0.08, 0.06)
const MAP_GREEN := Color(0.10, 0.55, 0.26)
const MAP_PURPLE := Color(0.50, 0.22, 0.68)
const MAP_CYAN := Color(0.12, 0.55, 0.62)

# ── 原版 Repaint() 补充色（CountryScript.cs:4829-5220，按原数值换算）──
## 南非影响：_MainColor2 = (0.25, 0.25, 0.25)（:5155-5158）
const MAP_SOUTH_AFRICA := Color(0.25, 0.25, 0.25)
## 伊拉克影响：_MainColor2 = (0.05882353, 0.125490189, 0.286274523)（:5159-5162）
const MAP_IRAQ_SPHERE := Color(0.05882353, 0.125490189, 0.286274523)
## 西班牙影响：_MainColor2 = (0.255, 0.55, 1)（:5163-5166）
const MAP_SPAIN_SPHERE := Color(0.255, 0.55, 1.0)
## 军事：NAZIMAO（:5018-5021）/ FXSEU（:5022-5025）/ AU（:5058-5061）/ RIM（:5062-5065）
const MIL_NAZIMAO := Color(0.435, 0.6274, 1.0)
const MIL_FXSEU := Color(0.47, 0.498, 0.584)
const MIL_AU := Color(0.0, 0.0, 0.5)
const MIL_RIM := Color(0.3, 1.0, 1.0)
## 经济：按玩家提供的原游戏开局经济模式截图逐色对齐。
## 原版是双色 _MainColor + _MainColor2；本端口单色调色板取其可见主色近似。
## 对华贸易 Torg：截图实测为绿色 RGB(0,147,99)。
const ECO_BALECON := Color8(142, 0, 126)
const ECO_EU_TORG := Color(1.0, 0.1, 0.0)
const ECO_ASEAN_TORG := Color(0.0, 0.22, 0.6431)
const ECO_SOCEU_TORG := Color(1.0, 0.1367925, 0.1367925)
const ECO_SEV_TORG := Color(0.0, 1.0, 0.1)
const ECO_TORG := Color8(0, 100, 60)
const ECO_OIL := Color8(0, 100, 60)
const ECO_EU := Color8(0, 65, 225)
const ECO_SEV := Color8(142, 0, 0)
const ECO_ASEAN := Color8(0, 65, 225)
const ECO_SOCEU := Color(1.0, 0.1367925, 0.1367925)
const ECO_ECON := Color(1.0, 0.549, 0.0)
const PRC_GWCODE := 710
const PALETTE_SIZE := 256

# ── 运行时数据 ──
var _meta: Dictionary = {}
var _regions: Dictionary = {}
var _countries: Dictionary = {}
var _region_owner: Dictionary = {}
var _initial_owner: Dictionary = {}

var _region_map_image: Image
var _region_map_tex: ImageTexture
var _owner_palette_image: Image
var _owner_palette_tex: ImageTexture
var _color_palette_image: Image
var _color_palette_tex: ImageTexture

var _selected_gwcode: int = 0
var _hover_gwcode: int = 0
var _camera_ref: Camera3D 
var _mouse_screen_pos: Vector2 = Vector2.ZERO
var _click_queued: bool = false
var _day_night_phase: float = 0.0
var _test_mode_enabled: bool = false

var _mouse_moved: bool = true
var _last_camera_transform: Transform3D = Transform3D()

## 轻点最大位移（超过则判为拖拽，不选国）
const TAP_MAX_MOVE := 12.0
## 收到真实触摸即置 true，屏蔽 emulate_mouse_from_touch 的模拟鼠标
var _using_touch: bool = false
## 当前按下手指数
var _active_touches: int = 0
## 单指按下起点，用于 tap 判定
var _tap_start_pos: Vector2 = Vector2.ZERO
## 本次触摸是否仍是 tap 候选（未超位移、未多指）
var _tap_candidate: bool = false


# ============================================================================
# 生命周期
# ============================================================================

func _ready() -> void:
	if GameManager:
		if not GameManager.is_map_data_preloaded:
			# 如果 GameManager 还没预加载完，我们等待它的信号
			await GameManager.map_data_preloaded
		# 监听数据变更：外交互动/事件修改国家参数或地图归属后实时刷新
		if not GameManager.stats_changed.is_connected(_on_stats_changed):
			GameManager.stats_changed.connect(_on_stats_changed)
		if not GameManager.world_state_loaded.is_connected(_on_stats_changed):
			GameManager.world_state_loaded.connect(_on_stats_changed)
		
		# 检查是否成功加载了缓存，如果缓存底图有效，我们直接复用缓存，实现 O(1) 级的无缝加载
		if GameManager.cached_region_map_image != null:
			_meta = GameManager.cached_map_meta
			_regions = GameManager.cached_map_regions
			_countries = GameManager.cached_map_countries
			_region_owner = GameManager.cached_region_owner
			_initial_owner = GameManager.cached_initial_owner
			
			_region_map_image = GameManager.cached_region_map_image
			_region_map_tex = GameManager.cached_region_map_tex
			_owner_palette_image = GameManager.cached_owner_palette_image
			_color_palette_image = GameManager.cached_color_palette_image
			_owner_palette_tex = GameManager.cached_owner_palette_tex
			_color_palette_tex = GameManager.cached_color_palette_tex
			
			# 同步当前的着色模式对应的颜色
			_sync_color_palette_image()
			_color_palette_tex.update(_color_palette_image)
			
			_inject_dynamic_textures()
			set_process(day_night_enabled)
			print("[TerritoryMap] 共享缓存加载完成 regions=%d countries=%d" % [_region_owner.size(), _countries.size()])
			map_data_ready.emit()
			return

	# Fallback 机制：仅在独立测试场景、GameManager 不存在或预加载失败时同步加载
	_meta = _load_json(meta_path)
	_build_region_data(_load_json(regions_path), _load_json(countries_path))
	map_data_ready.emit()

	# 按原分辨率加载底图，不做 GPU 上限缩放/压缩。
	var thread := Thread.new()
	thread.start(func(): 
		var img := _load_image(region_map_path)
		call_deferred("_on_region_map_loaded", img, thread)
	)
	set_process(false)


func _process(delta: float) -> void:
	_update_day_night(delta)


func _input(event: InputEvent) -> void:
	# 键盘：测试模式开关（始终响应）
	if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_M:
		_test_mode_enabled = not _test_mode_enabled
		print("[TerritoryMap] 测试模式 %s" % ("开启" if _test_mode_enabled else "关闭"))
		return

	# 触控路径
	if event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)
		return
	if event is InputEventScreenDrag:
		_handle_touch_drag(event as InputEventScreenDrag)
		return

	# 触屏设备上忽略模拟鼠标
	if _using_touch:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# GUI 控件（如国家面板的互动按钮/关闭按钮）消费点击：不排队选国，
			# 否则按钮 pressed 与地图选国同时发生，面板会被背后国家选中信号顶掉。
			# Viewport.gui_get_hovered_control() 出处：gdd_0774_Viewport.md。
			if get_viewport().gui_get_hovered_control() == null:
				_click_queued = true
				_mouse_screen_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_mouse_moved = true
	elif event is InputEventMouseMotion:
		_mouse_screen_pos = event.position
		_mouse_moved = true


## 供调试控制台/测试脚本切换“点击划归中国”模式。
func set_test_mode_enabled(enabled: bool) -> void:
	_test_mode_enabled = enabled
	print("[TerritoryMap] 测试模式 %s" % ("开启" if enabled else "关闭"))


func is_test_mode_enabled() -> bool:
	return _test_mode_enabled


## 手指按下/抬起：维护触点计数并做轻点判定。
## 单指、短位移、全程未多指 → 判为轻点选国，复用既有 _physics_process 选国管线。
func _handle_touch(t: InputEventScreenTouch) -> void:
	_using_touch = true
	if t.pressed:
		if _active_touches == 0:
			_tap_start_pos = t.position
			_tap_candidate = true
		_active_touches += 1
		if _active_touches >= 2:
			_tap_candidate = false  # 多指=手势，不选国
	else:
		_active_touches = maxi(0, _active_touches - 1)
		if _tap_candidate and not t.canceled and t.position.distance_to(_tap_start_pos) <= TAP_MAX_MOVE:
			_click_queued = true
			_mouse_screen_pos = t.position
		if _active_touches == 0:
			_tap_candidate = false


## 手指拖动：超过位移阈值即取消本次 tap 候选（判为拖拽相机）。
func _handle_touch_drag(d: InputEventScreenDrag) -> void:
	_using_touch = true
	if d.position.distance_to(_tap_start_pos) > TAP_MAX_MOVE:
		_tap_candidate = false  # 超位移，本次不再算 tap
	_mouse_screen_pos = d.position
	_mouse_moved = true


func _physics_process(_delta: float) -> void:
	if _region_map_image == null:
		_click_queued = false
		return

	var camera_moved := false
	if _camera_ref:
		var current_trans := _camera_ref.global_transform
		if current_trans != _last_camera_transform:
			camera_moved = true
			_last_camera_transform = current_trans

	# 只有当鼠标移动过、发生滚动缩放、有点击事件排队，或者摄像机旋转/拖拽过时，才重新进行射线检测和 hover 更新，极大降低 CPU 开销
	if not _mouse_moved and not _click_queued and not camera_moved:
		return

	_mouse_moved = false # 重置移动标志

	var hit := _raycast_screen(_mouse_screen_pos)
	# 战争图标/卫星等 Area3D 覆盖层：只交给它们自己的 input_event 处理，
	# 不把点击穿透成“选中背后的国家地块”。
	var hit_ui := false
	if not hit.is_empty():
		hit_ui = hit.get("collider") is Area3D

	if _click_queued:
		_click_queued = false
		if not hit.is_empty() and not hit_ui:
			if _test_mode_enabled:
				_transfer_region_at_3d_to_prc(hit.position)
			else:
				select_at_3d(hit.position)

	if hit_ui:
		_clear_hover()
		return
	if not hit.is_empty():
		_update_hover(hit.position)
	else:
		_clear_hover()


# ============================================================================
# 数据初始化与加载
# ============================================================================

func _build_region_data(raw_regions: Dictionary, raw_countries: Dictionary) -> void:
	_regions.clear()
	_countries.clear()
	_region_owner.clear()
	_initial_owner.clear()

	for key in raw_regions:
		var r_id := int(key)
		var owner_gw := int(raw_regions[key].get("owner_1976_gwcode", 0))
		_regions[r_id] = raw_regions[key]
		_region_owner[r_id] = owner_gw
		_initial_owner[r_id] = owner_gw

	for key in raw_countries:
		_countries[int(key)] = raw_countries[key]


func _on_region_map_loaded(img: Image, thread: Thread) -> void:
	if thread: thread.wait_to_finish()
	
	_region_map_image = img
	_region_map_tex = ImageTexture.create_from_image(_region_map_image)
	
	_owner_palette_image = Image.create(PALETTE_SIZE, PALETTE_SIZE, false, Image.FORMAT_RGB8)
	_color_palette_image = Image.create(PALETTE_SIZE, PALETTE_SIZE, false, Image.FORMAT_RGB8)
	
	_sync_owner_palette_image()
	_sync_color_palette_image()

	_owner_palette_tex = ImageTexture.create_from_image(_owner_palette_image)
	_color_palette_tex = ImageTexture.create_from_image(_color_palette_image)

	_inject_dynamic_textures()
	set_process(day_night_enabled)
	print("[TerritoryMap] 加载完成 regions=%d countries=%d" % [_region_owner.size(), _countries.size()])


func _inject_dynamic_textures() -> void:
	var mat := _get_shader_material()
	if not mat:
		push_warning("TerritoryMap: 未找到 ShaderMaterial")
		return

	mat.set_shader_parameter("region_map", _region_map_tex)
	mat.set_shader_parameter("owner_palette", _owner_palette_tex)
	mat.set_shader_parameter("color_palette", _color_palette_tex)


func _get_shader_material() -> ShaderMaterial:
	if material_override is ShaderMaterial:
		return material_override as ShaderMaterial
	if mesh is PrimitiveMesh and mesh.material is ShaderMaterial:
		return mesh.material as ShaderMaterial
	return null


# ============================================================================
# 着色模式处理
# ============================================================================

func set_color_mode(mode: int) -> void:
	if mode < 0 or mode >= ColorMode.size(): return
	color_mode = mode
	refresh_palette()


func refresh_palette() -> void:
	if not _color_palette_image: return
	_sync_color_palette_image()
	_color_palette_tex.update(_color_palette_image)


## GameManager.stats_changed / world_state_loaded 回调：
## 同步本地地图归属查询字典 + 重新生成着色调色板，让外交互动/事件改动实时生效。
## owner 调色板由 MapService 统一维护（与这里共享同一 Image/Texture），无需重复重建。
func _on_stats_changed() -> void:
	if GameManager == null:
		return
	if GameManager.cached_region_owner.size() > 0:
		_region_owner = GameManager.cached_region_owner.duplicate()
	refresh_palette()


func _sync_color_palette_image() -> void:
	_color_palette_image.fill(BLOC_NEUTRAL)
	var seen := {}
	for gwcode in _countries:
		seen[gwcode] = true
		_set_palette_pixel(_color_palette_image, gwcode, _color_for_country(gwcode))
	# map_countries 里没有 9000+ 虚构/分离实体（库尔德斯坦二号、魁北克、南墨西哥等），
	# 但它们激活后会被 MapService 移到相应地块；若不在调色板写入对应颜色，
	# 地图上会一直显示中立色，且影响模式也无法显示“在谁影响下”。
	var ws := _get_world_state()
	if ws != null:
		for c in ws.countries:
			if c == null or c.gwcode <= 0 or seen.has(c.gwcode):
				continue
			seen[c.gwcode] = true
			_set_palette_pixel(_color_palette_image, c.gwcode, _color_for_country(c.gwcode))


func _color_for_country(gwcode: int) -> Color:
	var c := _country_data(gwcode)
	if not c: return BLOC_NEUTRAL
	
	match color_mode:
		ColorMode.GOVERNMENT:
			# 政府模式只按政体/子意识形态判定，不套用亲苏/亲美等阵营标签
			if c.sub_government in CountryData.EXTREMIST_SUBS:
				return GOV_EXTREMIST
			if c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
				return GOV_SOCIALIST
			match c.government:
				2: return GOV_REFORM
				3: return GOV_LIBERAL
				_: return GOV_AUTHORITARIAN

		ColorMode.INFLUENCE:
			# 原版 Repaint map_type==3 顺序（CountryScript.cs:5150-5175）：
			# 法国 → 南非 → 伊拉克 → 西班牙 → 美国 → 苏联 → 中国
			if c.is_french_influence(): return MAP_PURPLE
			if c.is_south_african_influence(): return MAP_SOUTH_AFRICA
			if c.is_iraqi_influence(): return MAP_IRAQ_SPHERE
			if c.is_spanish_influence(): return MAP_SPAIN_SPHERE
			if c.has_tag("亲美") or (c.alliance_zone_counts() and c.has_tag("美国盟友")):
				return MAP_BLUE
			if c.has_tag("亲苏") or (c.alliance_zone_counts() and c.has_tag("苏联盟友")):
				return MAP_RED
			if c.has_tag("亲中"): return MAP_PRC

		ColorMode.MILITARY:
			# 原版 Repaint map_type==0 顺序（CountryScript.cs:5018-5069）
			if c.has_tag("nazimao"): return MIL_NAZIMAO
			if c.has_tag("fxseu"): return MIL_FXSEU
			if c.has_tag("nato"): return MAP_BLUE
			if c.has_tag("seato"): return MAP_BLUE
			if c.has_tag("sento"): return MAP_CYAN
			if c.has_tag("ovd"): return MAP_RED
			if c.has_tag("oar"): return MAP_GREEN
			if _is_iraq_syria_union(c): return MAP_GREEN
			if c.has_tag("au"): return MIL_AU
			if c.has_tag("rim"): return MIL_RIM
			if c.has_tag("okb"): return MAP_PRC

		ColorMode.ECONOMIC:
			# 原版 map_type==2 顺序（CountryScript.cs:4521-4590）；
			# Torg=对华贸易，按原版优先级叠加在联盟色之上。
			# 单色显示统一用上面 ECO_* 常量近似原版双色。
			var has_torg := c.has_tag("对华贸易")
			if _balecon_active(c): return ECO_BALECON
			if c.has_tag("eu") and has_torg: return ECO_EU_TORG
			if c.has_tag("asean") and has_torg: return ECO_ASEAN_TORG
			if c.has_tag("eu"): return ECO_EU
			if c.has_tag("soc_eu") and has_torg: return ECO_SOCEU_TORG
			if c.has_tag("soc_eu"): return ECO_SOCEU
			if c.has_tag("oil"): return ECO_OIL
			if c.has_tag("asean"): return ECO_ASEAN
			if c.has_tag("sev") and has_torg: return ECO_SEV_TORG
			if c.has_tag("sev"): return ECO_SEV
			if c.has_tag("econ"): return ECO_ECON
			if has_torg: return ECO_TORG

	return BLOC_NEUTRAL


## 原版巴尔干经济联盟判定（CountryScript.cs:5075-5080）：
## 需要本国带 balecon 标签，且阿尔巴尼亚(20).spec == 1。
func _balecon_active(c: CountryData) -> bool:
	if not c.has_tag("balecon"):
		return false
	var ws := _get_world_state()
	if ws == null:
		return false
	var albania := ws.get_country_by_legacy_index(20)
	return albania != null and albania.special == 1


## 原版军事地图的伊拉克-叙利亚联邦分支（CountryScript.cs:5053-5057）：
## event_done[707] 且国家为 14/35 且 SubGosstroy==15 时按 OAR 色显示。
func _is_iraq_syria_union(c: CountryData) -> bool:
	var sid := int(c.原版序号)
	if sid != 14 and sid != 35:
		return false
	if c.sub_government != GameConstants.SubGovernment.PRAGMATIST:
		return false
	var ws := _get_world_state()
	return ws != null and ws.get_flag("event_done_707")


# ============================================================================
# 领土变迁 API
# ============================================================================

func transfer_region(region_id: int, to_gwcode: int) -> void:
	if not _region_owner.has(region_id) or to_gwcode <= 0: return
	_region_owner[region_id] = to_gwcode
	_set_palette_pixel(_owner_palette_image, region_id, _encode_id(to_gwcode))
	_owner_palette_tex.update(_owner_palette_image)


func transfer_country(from_gwcode: int, to_gwcode: int) -> void:
	if from_gwcode <= 0 or to_gwcode <= 0: return
	for r_id in _region_owner:
		if _region_owner[r_id] == from_gwcode:
			_region_owner[r_id] = to_gwcode
			_set_palette_pixel(_owner_palette_image, r_id, _encode_id(to_gwcode))
	_owner_palette_tex.update(_owner_palette_image)


func set_regions_owner(region_ids: Array, to_gwcode: int) -> void:
	if to_gwcode <= 0: return
	for raw in region_ids:
		var r_id := int(raw)
		if _region_owner.has(r_id):
			_region_owner[r_id] = to_gwcode
			_set_palette_pixel(_owner_palette_image, r_id, _encode_id(to_gwcode))
	_owner_palette_tex.update(_owner_palette_image)


func restore_initial() -> void:
	_region_owner = _initial_owner.duplicate()
	_sync_owner_palette_image()
	_owner_palette_tex.update(_owner_palette_image)
	_selected_gwcode = 0
	_hover_gwcode = 0
	_apply_selection_shader()


func apply_territory_command(command: Dictionary) -> void:
	match command.get("type", ""):
		"transfer_region": transfer_region(int(command.get("region_id", 0)), int(command.get("to_gwcode", 0)))
		"transfer_country": transfer_country(int(command.get("from_gwcode", 0)), int(command.get("to_gwcode", 0)))
		"set_owner": set_regions_owner(command.get("region_ids", []), int(command.get("to_gwcode", 0)))
		"restore": restore_initial()
		_: push_warning("TerritoryMap: 未知领土命令 %s" % command)


# ============================================================================
# 射线与拾取计算
# ============================================================================

func select_at_3d(world_pos: Vector3) -> void:
	var region_id := region_id_at_3d(world_pos)
	var gwcode := int(_region_owner.get(region_id, 0))
	_selected_gwcode = gwcode
	_apply_selection_shader()
	var c_name := country_name_for_gwcode(gwcode)
	
	if region_id != 0:
		print("[TerritoryMap] 选中 region=%d gwcode=%d %s" % [region_id, gwcode, c_name])
	region_selected.emit(region_id, gwcode, c_name)
	country_selected.emit(gwcode, c_name)


func _transfer_region_at_3d_to_prc(world_pos: Vector3) -> void:
	var region_id := region_id_at_3d(world_pos)
	if region_id == 0 or not _region_owner.has(region_id): return
	
	var prev_gw := int(_region_owner[region_id])
	transfer_region(region_id, PRC_GWCODE)
	_selected_gwcode = PRC_GWCODE
	_apply_selection_shader()
	
	var c_name := country_name_for_gwcode(PRC_GWCODE)
	print("[TerritoryMap] 测试转移 region=%d gwcode=%d -> %d %s" % [region_id, prev_gw, PRC_GWCODE, c_name])
	region_selected.emit(region_id, PRC_GWCODE, c_name)
	country_selected.emit(PRC_GWCODE, c_name)


func _raycast_screen(screen_pos: Vector2) -> Dictionary:
	if not _camera_ref: return {}
	var space := get_world_3d().direct_space_state
	var origin := _camera_ref.project_ray_origin(screen_pos)
	var end := origin + _camera_ref.project_ray_normal(screen_pos) * 100.0
	return space.intersect_ray(PhysicsRayQueryParameters3D.create(origin, end))


func region_id_at_3d(world_pos: Vector3) -> int:
	if not _region_map_image: return 0
	
	var local := to_local(world_pos).normalized()
	var theta := acos(clampf(-local.y, -1.0, 1.0))
	var phi := atan2(local.x, local.z)
	var u := (phi + TAU if phi < 0.0 else phi) / TAU
	var v := 1.0 - theta / PI

	var px := Vector2i(floori(u * _region_map_image.get_width()), floori(v * _region_map_image.get_height()))
	if px.x < 0 or px.y < 0 or px.x >= _region_map_image.get_width() or px.y >= _region_map_image.get_height():
		return 0
	return _decode_id(_region_map_image.get_pixelv(px))


func _update_hover(world_pos: Vector3) -> void:
	var gw := int(_region_owner.get(region_id_at_3d(world_pos), 0))
	if gw != _hover_gwcode:
		_hover_gwcode = gw
		_apply_selection_shader()


func _clear_hover() -> void:
	if _hover_gwcode != 0:
		_hover_gwcode = 0
		_apply_selection_shader()


func _apply_selection_shader() -> void:
	var mat := _get_shader_material()
	if mat:
		mat.set_shader_parameter("selected_gwcode", _selected_gwcode)
		mat.set_shader_parameter("hover_gwcode", _hover_gwcode)


# ============================================================================
# 昼夜更新与辅助工具
# ============================================================================

func _update_day_night(delta: float) -> void:
	var mat := _get_shader_material()
	if not mat: return
	mat.set_shader_parameter("day_night_enabled", day_night_enabled)
	if not day_night_enabled: return

	var gm := GameManager
	var speed: float = float(gm.speed) if (gm and gm.is_playing) else (1.0 if not gm else 0.0)
	
	_day_night_phase = fmod(_day_night_phase + delta * TAU / maxf(daylight_cycle_seconds, 1.0) * speed, TAU)
	var tilt := deg_to_rad(sun_axial_tilt_degrees)
	var sun := Vector3(sin(_day_night_phase), sin(tilt) * 0.38, cos(_day_night_phase)).normalized()
	mat.set_shader_parameter("sun_direction_local", sun)


func country_name_for_gwcode(gwcode: int) -> String:
	var ws := _get_world_state()
	if ws:
		var cd = ws.get_country_by_gwcode(gwcode)
		if cd and cd.display_name() != "":
			return cd.display_name()
	
	var c: Dictionary = _countries.get(gwcode, {})
	return c.get("name_zh", c.get("name_1976", ""))


## 战争图标 v2：语义锚点 → 地图地块质心（不记死经纬度）。
## 数据源就是 map_countries.json 的 regions + map_regions.json 的 latitude/longitude。

## 国家的全部地块 id（战争图标锚点用）。
func country_region_ids(gwcode: int) -> Array[int]:
	var out: Array[int] = []
	if not _countries.has(gwcode):
		return out
	var raw: Array = _countries[gwcode].get("regions", [])
	for r in raw:
		out.append(int(r))
	return out


## 地块中心经纬度；无数据返回 (INF, INF)。
func region_latlon(region_id: int) -> Vector2:
	if not _regions.has(region_id):
		return Vector2(INF, INF)
	var r: Dictionary = _regions[region_id]
	if not r.has("latitude") or not r.has("longitude"):
		return Vector2(INF, INF)
	return Vector2(float(r["latitude"]), float(r["longitude"]))


## 国家质心经纬度：优先按当前领土归属（_region_owner）算，领土易主后图标跟着走；
## 若当前已无地块，回退到静态 map_countries.regions；再没有返回 (INF, INF)。
func country_centroid(gwcode: int) -> Vector2:
	var region_ids: Array[int] = []
	for rid in _region_owner:
		if int(_region_owner[rid]) == gwcode:
			region_ids.append(int(rid))
	if region_ids.is_empty():
		region_ids = country_region_ids(gwcode)
	var lat_total := 0.0
	var lon_total := 0.0
	var count := 0
	for rid in region_ids:
		var ll := region_latlon(rid)
		if ll.x == INF or ll.y == INF:
			continue
		lat_total += ll.x
		lon_total += ll.y
		count += 1
	if count == 0:
		return Vector2(INF, INF)
	return Vector2(lat_total / count, lon_total / count)


## 经纬度 → 球面坐标。与 region_id_at_3d 的 u/v 公式严格互逆。
func latlon_to_sphere_pos(lat: float, lon: float, radius: float = 0.501) -> Vector3:
	var u := (lon + 180.0) / 360.0
	var v := (90.0 - lat) / 180.0
	var theta := (1.0 - v) * PI
	var phi := u * TAU
	return Vector3(
		sin(phi) * sin(theta),
		-cos(theta),
		cos(phi) * sin(theta)
	) * radius


## 战争图标点击联动：只高亮国家，不弹国家面板（由调用方决定）。
func highlight_country(gwcode: int) -> void:
	_selected_gwcode = gwcode
	_apply_selection_shader()


func _country_data(gwcode: int) -> CountryData:
	var ws := _get_world_state()
	if ws == null:
		return null
	var cd := ws.get_country_by_gwcode(gwcode)
	if cd != null:
		return cd
	# 兼容旧存档：旧档里 CountryData.gwcode 可能还是原版数组下标（如吉布提 106，
	# 而地图 key 是 522）。按 map_countries 的 name_1976 回退查一次。
	if _countries.has(gwcode):
		var map_name: String = _countries[gwcode].get("name_1976", "")
		if map_name != "":
			var by_name := ws.get_country_by_tag(map_name)
			if by_name != null:
				return by_name
	return null


func _get_world_state() -> WorldState:
	return GameManager.world if GameManager else null


# ── 调色板工具函数 ──
func _encode_id(v: int) -> Color:
	return Color8((v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF)

func _decode_id(c: Color) -> int:
	return (int(roundi(c.r * 255.0)) << 16) | (int(roundi(c.g * 255.0)) << 8) | int(roundi(c.b * 255.0))

func _set_palette_pixel(img: Image, id: int, color: Color) -> void:
	if id > 0:
		img.set_pixel(id & 0xFF, (id >> 8) & 0xFF, color)

func _sync_owner_palette_image() -> void:
	_owner_palette_image.fill(Color.BLACK)
	for r_id in _region_owner:
		_set_palette_pixel(_owner_palette_image, r_id, _encode_id(_region_owner[r_id]))

# ── IO 工具函数 ──
func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("TerritoryMap: 找不到文件 %s" % path)
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	return parsed if parsed is Dictionary else {}


func _load_image(path: String) -> Image:
	var img: Image = null
	if ResourceLoader.exists(path):
		var res := ResourceLoader.load(path)
		if res is Texture2D: img = res.get_image()
	
	if not img and FileAccess.file_exists(path):
		img = Image.load_from_file(ProjectSettings.globalize_path(path))

	if not img:
		push_error("TerritoryMap: 无法加载底图 %s" % path)
		return Image.create(1, 1, false, Image.FORMAT_RGB8)

	# 按原分辨率加载，不缩放/压缩底图。
	return img
