class_name TerritoryMap
extends MeshInstance3D

## 选中某国时发出（点击地图领土）
## gwcode: Gleditsch & Ward 国家代码
signal country_selected(gwcode: int, country_name: String)
## 选中某区域时发出（比国家更细粒度的地图单元）
signal region_selected(region_id: int, gwcode: int, country_name: String)

# ── 数据源 ──
## 地图元数据（投影参数、包围盒等）
@export_file("*.json") var meta_path: String = "res://资产/地图/map_meta.json"
## 区域定义：region_id → {owner_1976_gwcode, 邻接关系, ...}
@export_file("*.json") var regions_path: String = "res://资产/地图/map_regions.json"
## 国家定义：gwcode → {name_zh, name_1976, ...}
@export_file("*.json") var countries_path: String = "res://资产/地图/map_countries.json"
## 8K 底图 PNG：每像素 RGB 编码 region_id（region_id = (R<<16)|(G<<8)|B）
@export_file("*.png") var region_map_path: String = "res://资产/地图/map_color.png"

# ── 球体外观 ──
## 球体半径（Godot 单位）
@export var sphere_radius: float = 1.0
## 海洋颜色（默认深蓝）
@export var water_color: Color = Color(0.07, 0.22, 0.38)
## 国界线颜色
@export var border_color: Color = Color(0.02, 0.02, 0.02, 0.75)
## 选中国家高亮色（金黄色）
@export var selected_color: Color = Color(1.0, 0.92, 0.15, 1.0)
## 悬停国家高亮色（白色半透明）
@export var hover_color: Color = Color(1.0, 1.0, 1.0, 0.85)

# ── 昼夜 ──
## 是否启用昼夜循环
@export var day_night_enabled: bool = true
## 夜晚强度：0=无夜晚，1=全黑
@export_range(0.0, 1.0, 0.01) var night_strength: float = 0.55
## 晨昏线柔和度：值越小边界越锐利
@export_range(0.01, 0.5, 0.01) var terminator_softness: float = 0.09
## 一个完整昼夜循环的时长（秒），受 GameManager.speed 影响
@export var daylight_cycle_seconds: float = 45.0
## 太阳自转轴倾角（度），模拟地球 23.4° 黄赤交角
@export var sun_axial_tilt_degrees: float = 23.4

# ========================================================================
# 着色模式 —— 按国家属性染色（属性来自 WorldState.countries，经 gwcode 直查）
# ========================================================================
enum ColorMode {
	GOVERNMENT,   # 政体：社会主义(红)/自由(蓝)/改良(绿)/威权(灰)/极端(黑)
	INFLUENCE,    # 势力范围：亲美(蓝)/亲苏(红)/亲中(橙)/亲法(紫)/中立(灰)
	MILITARY,     # 军事联盟：NATO(蓝)/华约(红)/SEATO(青)/OKB(橙)/OAR(绿)
	ECONOMIC,     # 经济联盟：EU(蓝)/经互会(红)/东盟(青)/ECON(橙)/OPEC(深灰)
}
## 当前着色模式，默认按政体染色
var color_mode: int = ColorMode.GOVERNMENT

# ── 调色板预设颜色 ──
## 政体颜色
const GOV_SOCIALIST := Color(0.80, 0.10, 0.08)     # 社会主义 — 深红
const GOV_LIBERAL := Color(0.10, 0.24, 0.74)        # 自由民主 — 蓝色
const GOV_REFORM := Color(0.08, 0.55, 0.22)          # 改良主义 — 绿色
const GOV_AUTHORITARIAN := Color(0.42, 0.42, 0.42)   # 威权 — 灰色
const GOV_EXTREMIST := Color(0.05, 0.05, 0.05)       # 极端 — 近黑
## 阵营/联盟颜色
const BLOC_NEUTRAL := Color(0.46, 0.46, 0.46)        # 中立/无数据 — 中灰
const MAP_PRC := Color(0.95, 0.45, 0.05)              # 中国/亲中 — 橙色
const MAP_BLUE := Color(0.08, 0.30, 0.72)             # 美国/亲美 — 深蓝
const MAP_RED := Color(0.78, 0.08, 0.06)              # 苏联/亲苏 — 深红
const MAP_GREEN := Color(0.10, 0.55, 0.26)            # 绿色阵营
const MAP_PURPLE := Color(0.50, 0.22, 0.68)           # 法国/亲法 — 紫色
const MAP_CYAN := Color(0.12, 0.55, 0.62)             # 青色阵营
## 中国的 Gleditsch & Ward 代码
const PRC_GWCODE := 710

# ========================================================================
# 数据层 —— CPU 端字典，与 GPU 调色板保持同步
# ========================================================================
## map_meta.json 全局参数（投影、包围盒等元信息）
var _meta: Dictionary = {}
## region_id(int) → 区域字典（含 owner_1976_gwcode、邻接关系等）
var _regions: Dictionary = {}
## gwcode(int) → 国家字典（含 name_zh、name_1976，用于名称查询）
var _countries: Dictionary = {}
## region_id(int) → gwcode —— 可变，领土变迁时修改此映射（权威数据源）
var _region_owner: Dictionary = {}
## region_id(int) → gwcode —— 初始归属快照，restore_initial() 回退用
var _initial_owner: Dictionary = {}

# ========================================================================
# GPU 纹理 —— 两级调色板 + 底图
# ========================================================================
## 8K 底图（只读）：每像素 RGB = region_id 编码
var _region_map_image: Image
var _region_map_tex: ImageTexture
## owner 调色板 256×256：region_id → 编码后的 gwcode
## 领土变迁只修改此纹理中对应 region_id 位置的一个像素（O(1)）
var _owner_palette_image: Image
var _owner_palette_tex: ImageTexture
## color 调色板 256×256：gwcode → 显示颜色
## 切换着色模式时全量重建此纹理
var _color_palette_image: Image
var _color_palette_tex: ImageTexture

## 调色板边长：256×256 = 65536 个槽位
## id 映射规则：低 8 位 → X 坐标，高 8 位 → Y 坐标
## 容量足够覆盖 region_id（约 30000+）和 gwcode（约 200+）
const PALETTE_SIZE := 256

# ========================================================================
# 交互状态
# ========================================================================
## 当前选中的国家 gwcode，0=无选中
var _selected_gwcode: int = 0
## 当前鼠标悬停的国家 gwcode，0=无悬停
var _hover_gwcode: int = 0
## 相机引用（由 OrbitCamera._register_camera() 在 _ready 后注入）
## 用于 _raycast_screen() 的射线投影计算
var _camera_ref: Camera3D 
## 当前鼠标屏幕位置（由 _input 持续更新）
var _mouse_screen_pos: Vector2 = Vector2.ZERO
## 点击队列标记：_input 中置 true，_physics_process 中消费
var _click_queued: bool = false
## 昼夜循环相位（弧度），0~TAU
var _day_night_phase: float = 0.0
## 调试/测试模式：按 M 键切换，左键点击区域直接转移给中国
var _test_mode_enabled: bool = false
## 异步加载标记：底图是否已开始后台加载
var _loading_started: bool = false


# ============================================================================
# 生命周期
# ============================================================================

## 初始化：加载 JSON 数据（同步，体积小速度快） → 启动底图异步加载 → 就绪
## 球体网格、ShaderMaterial 静态参数、碰撞体均在 外交.tscn / 地球.tres 中预设。
func _ready() -> void:
	_meta = _load_json(meta_path)
	_regions = _load_json(regions_path)
	_countries = _load_json(countries_path)
	_build_region_data()
	# 尝试从 GameManager 缓存获取已解码的底图（应用启动时即开始后台解码）
	if GameManager and GameManager.cached_region_map_image != null:
		_on_region_map_loaded(GameManager.cached_region_map_image, null)
	else:
		_loading_started = true
		_load_region_map_async()
		set_process(false)


## 每帧更新昼夜循环（太阳方向）
func _process(delta: float) -> void:
	_update_day_night(delta)


## 输入处理 —— 使用 _input（非 _unhandled_input）
## 设计意图：地图点击需要优先于 UI 处理，因为选中国家的点击
## 发生在球体表面而非 UI 控件上。UI 控件通过 mouse_filter 自行拦截。
## [评审] 与 OrbitCamera 的 _unhandled_input 配合时需注意事件消费顺序。
func _input(event: InputEvent) -> void:
	# 快捷键：M 切换测试模式（左键点击区域直接转移给中国）
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo and key.keycode == KEY_M:
			_test_mode_enabled = not _test_mode_enabled
			print("[TerritoryMap] 测试模式%s：左键点击最小地图单位归属中国" % ("开启" if _test_mode_enabled else "关闭"))

	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			# 不直接在 _input 中做射线检测（物理空间只在 _physics_process 中同步），
			# 而是在 _physics_process 中统一消费
			_click_queued = true
		_mouse_screen_pos = mb.position

	elif event is InputEventMouseMotion:
		_mouse_screen_pos = (event as InputEventMouseMotion).position


## 物理帧中统一处理射线拾取 —— 点击消费 + 悬停更新
## [评审] 每物理帧都做 raycast + get_pixelv，即使鼠标未移动。
## 建议：缓存上次位置，仅移动时更新 hover；或降低检测频率。
func _physics_process(_delta: float) -> void:
	if _region_map_image == null:
		_click_queued = false
		return
	var hit := _raycast_screen(_mouse_screen_pos)

	# 消费点击队列
	if _click_queued:
		_click_queued = false
		if not hit.is_empty():
			if _test_mode_enabled:
				_transfer_region_at_3d_to_prc(hit["position"])
			else:
				select_at_3d(hit["position"])

	# 更新悬停状态
	if not hit.is_empty():
		_update_hover(hit["position"])
	else:
		_clear_hover()


# ============================================================================
# 数据加载
# ============================================================================

## 构建 region/country 数据结构（从已加载的 JSON 字典中提取）
func _build_region_data() -> void:
	_region_owner.clear()
	_initial_owner.clear()
	for key in _regions.keys():
		var region_id := int(key)
		var region: Dictionary = _regions[key]
		_regions[region_id] = region
		var owner_gw := int(region.get("owner_1976_gwcode", 0))
		_region_owner[region_id] = owner_gw
		_initial_owner[region_id] = owner_gw

	# 清掉字符串键，统一用 int 键（避免混用导致查找失败）
	var to_erase: Array = []
	for key in _regions.keys():
		if key is String:
			to_erase.append(key)
	for key in to_erase:
		_regions.erase(key)

	# countries 同样转 int 键
	var country_erase: Array = []
	for key in _countries.keys():
		if key is String:
			var gw := int(key)
			_countries[gw] = _countries[key]
			country_erase.append(key)
	for key in country_erase:
		_countries.erase(key)


## 启动后台线程加载 8K 底图 PNG
func _load_region_map_async() -> void:
	var thread := Thread.new()
	thread.start(_load_image_thread.bind(region_map_path, thread))


## 后台线程：解码 PNG（CPU 密集，不阻塞主线程）
func _load_image_thread(path: String, thread: Thread) -> void:
	var img := _load_image(path)
	# 必须回到主线程创建 GPU 纹理
	call_deferred("_on_region_map_loaded", img, thread)


## 主线程回调：底图加载完成，构建调色板并注入 shader
func _on_region_map_loaded(img: Image, thread: Thread) -> void:
	if thread != null:
		thread.wait_to_finish()
	_region_map_image = img
	_region_map_tex = ImageTexture.create_from_image(_region_map_image)
	# 构建 owner 调色板（region_id → gwcode 编码色）
	_owner_palette_image = Image.create(PALETTE_SIZE, PALETTE_SIZE, false, Image.FORMAT_RGB8)
	_owner_palette_image.fill(Color.BLACK)
	_sync_owner_palette_image()
	# 构建 color 调色板（gwcode → 显示色），初始按政体模式
	_color_palette_image = Image.create(PALETTE_SIZE, PALETTE_SIZE, false, Image.FORMAT_RGB8)
	_color_palette_image.fill(BLOC_NEUTRAL)
	_sync_color_palette_image()
	# 注入纹理到 shader
	_inject_dynamic_textures()
	# 应用当前着色模式（_ready 期间可能已被 地图模式.gd 设置过）
	_sync_color_palette_image()
	_color_palette_tex.update(_color_palette_image)
	# 启用昼夜循环处理
	set_process(day_night_enabled)
	print("[TerritoryMap] 加载完成 regions=%d countries=%d" % [_region_owner.size(), _countries.size()])


# ============================================================================
# 动态纹理注入
# ============================================================================
# 球体网格、ShaderMaterial 静态参数（颜色、昼夜等）均在 外交.tscn 中预设
# （地球.tres 资源）。此处仅注入三张运行时生成的纹理。

## 将运行时构建的底图 + 两级调色板纹理注入到 ShaderMaterial 中
## 材质来源优先级：material_override > mesh 材质
func _inject_dynamic_textures() -> void:
	var mat := _get_shader_material()
	if mat == null:
		push_warning("TerritoryMap: 未找到 ShaderMaterial，请检查 外交.tscn 中地球节点的材质配置")
		return

	# 底图纹理（8K PNG 加载后生成）
	mat.set_shader_parameter("region_map", _region_map_tex)

	# owner 调色板纹理（region_id → gwcode）
	_owner_palette_tex = ImageTexture.create_from_image(_owner_palette_image)
	mat.set_shader_parameter("owner_palette", _owner_palette_tex)

	# color 调色板纹理（gwcode → 显示色）
	_color_palette_tex = ImageTexture.create_from_image(_color_palette_image)
	mat.set_shader_parameter("color_palette", _color_palette_tex)


## 查找当前生效的 ShaderMaterial
## 外交.tscn 中材质挂在 SphereMesh.material 上（地球.tres），非 material_override
func _get_shader_material() -> ShaderMaterial:
	if material_override is ShaderMaterial:
		return material_override as ShaderMaterial
	# mesh 为 PrimitiveMesh（SphereMesh）时，材质在 mesh.material 上
	if mesh is PrimitiveMesh:
		var prim := mesh as PrimitiveMesh
		if prim.material is ShaderMaterial:
			return prim.material as ShaderMaterial
	return null


# ============================================================================
# 着色模式 —— 按国家属性生成 color 调色板
# ============================================================================

## 切换着色模式并立即重建 color 调色板。
## mode 应取 ColorMode 枚举值。无效值将被静默忽略。
func set_color_mode(mode: int) -> void:
	if mode < 0 or mode > ColorMode.size() - 1:
		return
	color_mode = mode
	if _color_palette_image == null:
		return
	_sync_color_palette_image()
	_color_palette_tex.update(_color_palette_image)


## 游戏状态变化后刷新当前模式调色板（外部调用）。
## 例如：国家政体改变、联盟变动后，调用此方法使地图颜色即时更新。
func refresh_palette() -> void:
	if _color_palette_image == null:
		return
	_sync_color_palette_image()
	_color_palette_tex.update(_color_palette_image)


## 全量重建 color 调色板：遍历所有 gwcode，逐个查色写入
func _sync_color_palette_image() -> void:
	_color_palette_image.fill(BLOC_NEUTRAL)  # 先全部填默认灰色
	for gwcode in _countries.keys():
		var color := _color_for_country(int(gwcode))
		_set_palette_pixel(_color_palette_image, int(gwcode), color)


## 根据当前 ColorMode 与国家属性计算显示色。
## 属性经 gwcode 从 WorldState 干净直查（O(1)），不依赖 _countries 字典。
func _color_for_country(gwcode: int) -> Color:
	var c := _country_data(gwcode)
	match color_mode:
		ColorMode.GOVERNMENT: return _gov_color(c)
		ColorMode.INFLUENCE:  return _influence_color(c)
		ColorMode.MILITARY:   return _military_color(c)
		ColorMode.ECONOMIC:   return _economic_color(c)
	return BLOC_NEUTRAL


# ── 政体着色 ──
## 着色优先级：极端政体 > 社会主义阵营 > 自由阵营 > government 数值
## [评审] 硬编码的布尔标志判断链，新增政体类型需修改此方法。
## 建议：将政体→颜色的映射配置化（JSON/资源文件）。
func _gov_color(c: CountryData) -> Color:
	if c == null:
		return BLOC_NEUTRAL
	if c.government < 0:
		return GOV_EXTREMIST
	if c.has_tag("亲苏") or c.has_tag("ovd") or c.has_tag("sev") or c.has_tag("苏联盟友") or c.has_tag("亲中") or c.has_tag("对华贸易"):
		return GOV_SOCIALIST
	if c.has_tag("亲美") or c.has_tag("美国盟友") or c.has_tag("nato") or c.has_tag("seato") or c.has_tag("sento"):
		return GOV_LIBERAL
	match c.government:
		1: return GOV_SOCIALIST
		2: return GOV_REFORM
		3: return GOV_LIBERAL
		_: return GOV_AUTHORITARIAN


# ── 势力影响着色 ──
func _influence_color(c: CountryData) -> Color:
	if c == null:
		return BLOC_NEUTRAL
	if c.has_tag("亲美") or c.has_tag("美国盟友"):
		return MAP_BLUE
	if c.has_tag("亲苏") or c.has_tag("苏联盟友"):
		return MAP_RED
	if c.has_tag("亲中"):
		return MAP_PRC
	if c.has_tag("亲法"):
		return MAP_PURPLE
	return BLOC_NEUTRAL


# ── 军事联盟着色 ──
func _military_color(c: CountryData) -> Color:
	if c == null:
		return BLOC_NEUTRAL
	if c.has_tag("nato") or c.has_tag("seato"):
		return MAP_BLUE
	if c.has_tag("sento"):
		return MAP_CYAN
	if c.has_tag("ovd"):
		return MAP_RED
	if c.has_tag("okb"):
		return MAP_PRC
	if c.has_tag("oar"):
		return MAP_GREEN
	return BLOC_NEUTRAL


# ── 经济联盟着色 ──
func _economic_color(c: CountryData) -> Color:
	if c == null:
		return BLOC_NEUTRAL
	if c.has_tag("eu"):
		return MAP_BLUE
	if c.has_tag("sev") or c.has_tag("soc_eu"):
		return MAP_RED
	if c.has_tag("asean"):
		return MAP_CYAN
	if c.has_tag("econ"):
		return MAP_PRC
	if c.has_tag("oil"):
		return Color(0.18, 0.18, 0.18)
	return BLOC_NEUTRAL


# ============================================================================
# 领土变迁 —— 自主 API（只改 owner 调色板，不动底图）
# ============================================================================
# 核心设计：8K 底图永不修改。领土变迁仅修改 owner 调色板中对应 region_id
# 位置的一个像素（O(1)），然后 update() 纹理即可立即在 GPU 端生效。
# ============================================================================

## 转移单个区域给指定国家
## region_id: 目标区域 ID（来自 map_regions.json）
## to_gwcode: 目标国家 G&W 代码
func transfer_region(region_id: int, to_gwcode: int) -> void:
	if not _region_owner.has(region_id) or to_gwcode <= 0:
		return
	# 更新 CPU 端权威数据
	_region_owner[region_id] = to_gwcode
	# 更新 GPU 调色板：仅修改一个像素
	_set_palette_pixel(_owner_palette_image, region_id, _encode_id(to_gwcode))
	_owner_palette_tex.update(_owner_palette_image)


## 吞并整国：把 from_gwcode 名下所有区域转给 to_gwcode
## [评审] 遍历全部 region 做 O(n) 操作。如果有大量领土变迁，
## 建议批量修改后统一 update() 一次而非每区域 update()。
func transfer_country(from_gwcode: int, to_gwcode: int) -> void:
	if from_gwcode <= 0 or to_gwcode <= 0:
		return
	for region_id in _region_owner.keys():
		if int(_region_owner[region_id]) == from_gwcode:
			_region_owner[region_id] = to_gwcode
			_set_palette_pixel(_owner_palette_image, int(region_id), _encode_id(to_gwcode))
	_owner_palette_tex.update(_owner_palette_image)  # 批量修改后统一刷新


## 批量设置一组区域的归属
## region_ids: 区域 ID 数组（支持 int 或可转为 int 的值）
func set_regions_owner(region_ids: Array, to_gwcode: int) -> void:
	if to_gwcode <= 0:
		return
	for raw in region_ids:
		var region_id := int(raw)
		if _region_owner.has(region_id):
			_region_owner[region_id] = to_gwcode
			_set_palette_pixel(_owner_palette_image, region_id, _encode_id(to_gwcode))
	_owner_palette_tex.update(_owner_palette_image)


## 恢复到 1976 初始归属（重置所有领土变迁）
func restore_initial() -> void:
	_region_owner = _initial_owner.duplicate()  # 深拷贝初始快照
	_sync_owner_palette_image()                 # 全量重建 owner 调色板
	_owner_palette_tex.update(_owner_palette_image)
	# 清空选中/悬停状态
	_selected_gwcode = 0
	_hover_gwcode = 0
	_apply_selection_shader()


## 通用领土命令分发（兼容字典式调用，供事件系统/控制台使用）
## 支持的命令类型：
##   "transfer_region"  {region_id: int, to_gwcode: int}
##   "transfer_country" {from_gwcode: int, to_gwcode: int}
##   "set_owner"        {region_ids: Array, to_gwcode: int}
##   "restore"          {}
func apply_territory_command(command: Dictionary) -> void:
	match String(command.get("type", "")):
		"transfer_region":
			transfer_region(int(command.get("region_id", 0)), int(command.get("to_gwcode", 0)))
		"transfer_country":
			transfer_country(int(command.get("from_gwcode", 0)), int(command.get("to_gwcode", 0)))
		"set_owner":
			set_regions_owner(command.get("region_ids", []), int(command.get("to_gwcode", 0)))
		"restore":
			restore_initial()
		_:
			push_warning("TerritoryMap: 未知领土命令 %s" % command)


# ============================================================================
# 3D 拾取 → region_id → owner
# ============================================================================

## 点击选中：根据 3D 世界坐标定位区域，触发选中信号
func select_at_3d(world_pos: Vector3) -> void:
	var region_id := region_id_at_3d(world_pos)
	var gwcode := int(_region_owner.get(region_id, 0))
	_selected_gwcode = gwcode
	_apply_selection_shader()
	var country_name := country_name_for_gwcode(gwcode)
	if region_id != 0:
		print("[TerritoryMap] 选中 region=%d gwcode=%d %s" % [region_id, gwcode, country_name])
	# 即使点击海洋（region_id=0, gwcode=0）也发出信号，让 UI 清除选择
	region_selected.emit(region_id, gwcode, country_name)
	country_selected.emit(gwcode, country_name)


## [评审] 测试专用方法 —— 将点击区域强制转移给中国（gwcode=710）
## 发布前应移除或改为通用 "转移给当前选中国家" 接口。
func _transfer_region_at_3d_to_prc(world_pos: Vector3) -> void:
	var region_id := region_id_at_3d(world_pos)
	if region_id == 0 or not _region_owner.has(region_id):
		return
	var previous_gwcode := int(_region_owner.get(region_id, 0))
	transfer_region(region_id, PRC_GWCODE)
	_selected_gwcode = PRC_GWCODE
	_apply_selection_shader()
	var country_name := country_name_for_gwcode(PRC_GWCODE)
	print("[TerritoryMap] 测试模式转移 region=%d gwcode=%d -> %d %s" % [region_id, previous_gwcode, PRC_GWCODE, country_name])
	region_selected.emit(region_id, PRC_GWCODE, country_name)
	country_selected.emit(PRC_GWCODE, country_name)


## 从屏幕坐标发射射线，返回与球体碰撞体的交点信息
func _raycast_screen(screen_pos: Vector2) -> Dictionary:
	if _camera_ref == null:
		return {}  # 相机尚未注册，无法做射线检测
	var space := get_world_3d().direct_space_state
	var origin := _camera_ref.project_ray_origin(screen_pos)
	var end := origin + _camera_ref.project_ray_normal(screen_pos) * 100.0
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	return space.intersect_ray(query)


## 球面世界坐标 → 等距矩形 UV（与 Godot SphereMesh 标准 UV 一致）
## 算法：将世界交点转为球体局部坐标，然后球坐标 → UV
##   theta = acos(-local.y)  → 纬度角（0=北极，PI=南极）
##   phi = atan2(local.x, local.z) → 经度角（-PI~PI）
##   u = phi/TAU（归一化到 0~1）
##   v = 1 - theta/PI（翻转使 V=0 为北极，匹配图像坐标系）
func _world_to_uv(world_pos: Vector3) -> Vector2:
	var local := to_local(world_pos).normalized()
	var theta := acos(clampf(-local.y, -1.0, 1.0))  # 纬度角
	var phi := atan2(local.x, local.z)                # 经度角
	var u := phi / TAU
	if u < 0.0:
		u += 1.0  # 将 [-PI,0) 映射到 [0.5, 1.0)
	var v := 1.0 - theta / PI  # 北极=v=0，南极=v=1
	return Vector2(u, v)


## 根据 3D 世界坐标查询对应像素的 region_id
## 流程：世界坐标 → UV → 像素坐标 → 读取底图像素 → 解码 region_id
func region_id_at_3d(world_pos: Vector3) -> int:
	if _region_map_image == null:
		return 0
	var uv := _world_to_uv(world_pos)
	var px := Vector2i(
		floori(uv.x * _region_map_image.get_width()),
		floori(uv.y * _region_map_image.get_height())
	)
	# 边界检查（UV 可能在接缝处有浮点误差）
	if px.x < 0 or px.y < 0 or px.x >= _region_map_image.get_width() or px.y >= _region_map_image.get_height():
		return 0
	return _decode_id(_region_map_image.get_pixelv(px))


## 更新悬停国家（仅在 gwcode 变化时刷新 shader，避免无效更新）
func _update_hover(world_pos: Vector3) -> void:
	var region_id := region_id_at_3d(world_pos)
	var gw := int(_region_owner.get(region_id, 0))
	if gw == _hover_gwcode:
		return  # 同一国家内移动，无需更新
	_hover_gwcode = gw
	_apply_selection_shader()


## 清除悬停状态（鼠标移出球体）
func _clear_hover() -> void:
	if _hover_gwcode == 0:
		return  # 已经是无悬停状态
	_hover_gwcode = 0
	_apply_selection_shader()


## 将选中/悬停 gwcode 推送到 GPU shader 参数
func _apply_selection_shader() -> void:
	var mat := _get_shader_material()
	if mat == null:
		return
	mat.set_shader_parameter("selected_gwcode", _selected_gwcode)
	mat.set_shader_parameter("hover_gwcode", _hover_gwcode)


# ============================================================================
# 昼夜循环
# ============================================================================

## 每帧更新太阳方向，驱动 shader 中的昼夜效果
## 太阳绕球体旋转（相位 _day_night_phase），带 23.4° 轴倾角
## 速度受 GameManager.speed 影响：暂停时昼夜停止，加速时昼夜加快
func _update_day_night(delta: float) -> void:
	var mat := _get_shader_material()
	if mat == null:
		return
	mat.set_shader_parameter("day_night_enabled", day_night_enabled)
	if not day_night_enabled:
		return

	# 计算当前周期速度（受游戏速度控制）
	var cycle := maxf(daylight_cycle_seconds, 1.0)
	var speed := 1.0
	var gm := get_node_or_null("/root/GameManager")
	if gm != null:
		# GameManager.is_playing 为 false 时暂停昼夜
		speed = float(gm.speed) if bool(gm.is_playing) else 0.0

	# 推进相位
	_day_night_phase = fmod(_day_night_phase + delta * TAU / cycle * speed, TAU)

	# 计算太阳在球体局部空间的方向
	# sin(tilt)*0.38: 模拟黄赤交角，0.38 是经验系数让视觉效果合理
	var tilt := deg_to_rad(sun_axial_tilt_degrees)
	var sun := Vector3(sin(_day_night_phase), sin(tilt) * 0.38, cos(_day_night_phase)).normalized()
	mat.set_shader_parameter("sun_direction_local", sun)


# ============================================================================
# 查询辅助
# ============================================================================

## 按 gwcode 获取国家显示名。
## 优先级：CountryData.display_name()（按政体动态国名）→ name_zh → name_1976
func country_name_for_gwcode(gwcode: int) -> String:
	# 优先从 WorldState 取动态国名（按政体变化）
	if GameManager and GameManager.world:
		var cd := GameManager.world.get_country_by_gwcode(gwcode)
		if cd:
			var dn := cd.display_name()
			if dn != "":
				return dn
	# 回退到 map_countries.json 静态数据
	if not _countries.has(gwcode):
		return ""
	var c: Dictionary = _countries[gwcode]
	var zh := String(c.get("name_zh", ""))
	if zh != "":
		return zh
	return String(c.get("name_1976", ""))


## 经 gwcode 从 WorldState 干净直查国家属性（O(1) 字典查找）。
## 返回类型为 CountryData，包含 government、各联盟标志等字段。
## 与 _countries 字典不同：此方法返回运行时游戏状态，后者是静态 JSON 数据。
func _country_data(gwcode: int) -> CountryData:
	var ws := _get_world_state()
	if ws == null:
		return null
	return ws.get_country_by_gwcode(gwcode)


## 获取 WorldState 单例引用（通过 GameManager autoload）
func _get_world_state() -> WorldState:
	var gm := get_node_or_null("/root/GameManager")
	if gm == null:
		return null
	return gm.get("world")


# ============================================================================
# 调色板像素 / 编解码工具
# ============================================================================
# ID 编码方案（与底图 region_id 编码一致）：
#   24-bit RGB: value = (R<<16) | (G<<8) | B
#   支持 0 ~ 16,777,215（约 1677 万个 ID），远超实际需求。
#
# 调色板寻址（256×256 = 65536 槽位）：
#   X = id & 0xFF        （低 8 位，0~255）
#   Y = (id >> 8) & 0xFF （高 8 位，0~255）
#   放弃 id 的高 16 位 —— 65536 槽位足够覆盖 region_id(~30000) 和 gwcode(~200)。
#   [评审] 如果 region_id 超过 65535，高位会被截断导致哈希冲突。建议加断言。
# ============================================================================

## 将整数值编码为 RGB Color（24-bit 大端序）
func _encode_id(value: int) -> Color:
	return Color8((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)


## 将 RGB Color 解码为整数值
func _decode_id(c: Color) -> int:
	return (int(roundi(c.r * 255.0)) << 16) | (int(roundi(c.g * 255.0)) << 8) | int(roundi(c.b * 255.0))


## 在调色板纹理中写入一个像素
## id 的低 8 位决定 X 坐标，高 8 位决定 Y 坐标
## id <= 0 被跳过（0=海洋/无主，不写入调色板）
func _set_palette_pixel(img: Image, id: int, color: Color) -> void:
	if id <= 0:
		return
	img.set_pixel(id & 0xFF, (id >> 8) & 0xFF, color)


## 全量重建 owner 调色板：遍历所有 region_id，写入对应 gwcode 编码色
## 用于 restore_initial() 或首次初始化
func _sync_owner_palette_image() -> void:
	_owner_palette_image.fill(Color.BLACK)  # id=0 → 黑色 = 无主/海洋
	for region_id in _region_owner.keys():
		var gwcode := int(_region_owner[region_id])
		_set_palette_pixel(_owner_palette_image, int(region_id), _encode_id(gwcode))


# ============================================================================
# 文件 IO
# ============================================================================

## 加载 JSON 文件，返回解析后的 Dictionary
## 失败时打印错误并返回空字典（不会崩溃）
func _load_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("TerritoryMap: 无法打开 %s" % path)
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		return parsed
	push_error("TerritoryMap: JSON 解析失败 %s" % path)
	return {}


## 加载 PNG 底图，自动处理超大纹理降采样
## [评审] GPU_MAX_SIZE=16384 对移动端/旧 GPU 可能过大（部分仅支持 4096/8192）。
## 建议：运行时查询 RenderingDevice.limit_get() 获取实际最大纹理尺寸。
func _load_image(path: String) -> Image:
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if img == null:
		push_error("TerritoryMap: 无法加载底图 %s" % path)
		return Image.create(1, 1, false, Image.FORMAT_RGB8)

	# GPU 最大纹理尺寸约束：超过则最近邻降采样。
	# 用 INTERPOLATE_NEAREST 保证 region_id 整数值不被混合（双线性会生出非法 ID）。
	# 颜色由调色板查表决定，分辨率降低不影响颜色正确性，只影响边缘锐利度。
	const GPU_MAX_SIZE := 16384
	if img.get_width() > GPU_MAX_SIZE or img.get_height() > GPU_MAX_SIZE:
		var ratio := float(GPU_MAX_SIZE) / float(maxi(img.get_width(), img.get_height()))
		var new_w := maxi(1, int(img.get_width() * ratio))
		var new_h := maxi(1, int(img.get_height() * ratio))
		print("[TerritoryMap] 底图 %dx%d 超过 GPU 纹理上限(%d)，最近邻降采样 → %dx%d" %
			[img.get_width(), img.get_height(), GPU_MAX_SIZE, new_w, new_h])
		img.resize(new_w, new_h, Image.INTERPOLATE_NEAREST)
	return img
