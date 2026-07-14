# ============================================================================
# MapModePanel — 地图着色模式切换面板
# ============================================================================
# 挂在 外交.tscn 的 地图模式 (CanvasLayer) 节点上。
# 提供四种按国家属性着色的模式，通过重建 color 调色板实现。
#
# 四种模式（属性经 gwcode 从 WorldState 干净直查）：
#   政府 — 按政体类型（社会主义/自由/改良/威权）
#   影响 — 按超级大国势力范围（美/苏/中/法/中立）
#   军事 — 按军事同盟（NATO/华约/SEATO...）
#   经济 — 按经济同盟（经互会/欧盟/东盟...）
#
# 原理：region_map 标识每个像素属于哪个国家(gwcode)，color 调色板决定该国显示什么色。
#   切换模式 = 重建 color 调色板。无需预烘焙，联盟/政体变化后立即可见。
# ============================================================================

extends CanvasLayer

## 着色模式枚举（与 TerritoryMap.ColorMode 一致）
enum DisplayMode {
	GOVERNMENT,   # 政府 — 政体类型
	INFLUENCE,    # 影响 — 势力范围
	MILITARY,     # 军事 — 军事同盟
	ECONOMIC,     # 经济 — 经济同盟
}

## 当前选中的显示模式
var current_mode: int = DisplayMode.GOVERNMENT :
	set(value):
		current_mode = value
		_apply_mode()
		_refresh_button_styles()

signal mode_changed(new_mode: int)

# ── 节点引用 ──

@onready var _globe: TerritoryMap = _find_globe()

@onready var _btn_government: Button = $政府类型地图模式
@onready var _btn_influence: Button = $影响地图模式
@onready var _btn_military: Button = $军事阵营地图模式
@onready var _btn_economic: Button = $经济阵营地图模式
@onready var _btn_terrain: Button = get_node_or_null("自然地理地图模式")

@onready var _mode_buttons: Array[Button] = [
	_btn_government, _btn_influence, _btn_military, _btn_economic,
]
# 每个按钮对应的 DisplayMode（与 _mode_buttons 下标对齐）
const _BUTTON_MODES: Array[int] = [
	DisplayMode.GOVERNMENT,
	DisplayMode.INFLUENCE,
	DisplayMode.MILITARY,
	DisplayMode.ECONOMIC,
]


func _ready() -> void:
	# 新数据无地形层，隐藏自然地理按钮
	if _btn_terrain != null:
		_btn_terrain.visible = false
	_connect_signals()
	current_mode = DisplayMode.GOVERNMENT
	_apply_mode()
	_refresh_button_styles()


func _connect_signals() -> void:
	_btn_government.pressed.connect(_on_government_pressed)
	_btn_influence.pressed.connect(_on_influence_pressed)
	_btn_military.pressed.connect(_on_military_pressed)
	_btn_economic.pressed.connect(_on_economic_pressed)


func _on_government_pressed() -> void:
	current_mode = DisplayMode.GOVERNMENT

func _on_influence_pressed() -> void:
	current_mode = DisplayMode.INFLUENCE

func _on_military_pressed() -> void:
	current_mode = DisplayMode.MILITARY

func _on_economic_pressed() -> void:
	current_mode = DisplayMode.ECONOMIC


## 将当前模式应用到地球仪（重建 color 调色板）
func _apply_mode() -> void:
	if _globe == null:
		return
	_globe.set_color_mode(_BUTTON_MODES[current_mode] if current_mode < _BUTTON_MODES.size() else DisplayMode.GOVERNMENT)
	mode_changed.emit(current_mode)


## 刷新当前模式调色板（游戏状态变化时外部调用，如事件效果执行后）
func refresh() -> void:
	if _globe != null:
		_globe.refresh_palette()


## 根据当前模式更新按钮样式（选中高亮，未选中变暗+禁用）
func _refresh_button_styles() -> void:
	for i in _mode_buttons.size():
		var btn: Button = _mode_buttons[i]
		var is_selected: bool = (current_mode == _BUTTON_MODES[i])
		btn.modulate = Color.WHITE if is_selected else Color(0.55, 0.55, 0.55, 1.0)
		btn.disabled = is_selected


func _find_globe() -> TerritoryMap:
	var parent := get_parent()
	if parent == null:
		return null
	var node := parent.get_node_or_null("地球")
	if node is TerritoryMap:
		return node
	return null


func reset_to_default() -> void:
	current_mode = DisplayMode.GOVERNMENT


func get_mode_name(mode: int = -1) -> String:
	if mode < 0:
		mode = current_mode
	match mode:
		DisplayMode.GOVERNMENT: return "政府类型"
		DisplayMode.INFLUENCE: return "势力影响"
		DisplayMode.MILITARY: return "军事阵营"
		DisplayMode.ECONOMIC: return "经济阵营"
	return "未知"


func set_panel_visible(p_show: bool) -> void:
	visible = p_show


func toggle_panel() -> void:
	visible = not visible
