extends Sprite3D

## 战争图标 v2 —— 通用显示槽。
## 不再自己决定显示哪场战争：由 战争图标管理.gd 计算语义锚点位置后调用
## display_entry(info)。本脚本只负责：
##   1. 把图标放到球面坐标并摆正朝向；
##   2. 提供可点击的 Area3D 命中区；
##   3. 把 click 以 war_id 发回管理器（不显示文本 tooltip）。
##
## .tscn 里的 initial_war_index / special / home_key 仅为兼容旧场景序列化保留，
## 运行期不再读取。

signal clicked(war_id: int)

@export var initial_war_index: int = 0
@export var special: bool = false
@export var home_key: String = ""

const EARTH_RADIUS := 0.501
const HIT_RADIUS := 0.012
const 统一字体: Font = preload("res://资产/字体/方正跃进简体.ttf")

var _displaying := false
var current_war_id: int = -1
var _area: Area3D
var _label: Label3D
var _hovered := false


func _ready() -> void:
	visible = false
	_displaying = false
	current_war_id = -1
	_ensure_hit_area()
	_ensure_label()


func _ensure_hit_area() -> void:
	if is_instance_valid(_area):
		return
	_area = Area3D.new()
	_area.name = "图标命中区"
	add_child(_area)
	_area.input_ray_pickable = false
	_area.monitoring = false
	_area.input_event.connect(_on_area_input_event)
	if _area.has_signal("mouse_entered"):
		_area.mouse_entered.connect(_on_mouse_entered)
	if _area.has_signal("mouse_exited"):
		_area.mouse_exited.connect(_on_mouse_exited)
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = HIT_RADIUS
	shape.shape = sphere
	_area.add_child(shape)


## 显示指定战争图标；info 为空则隐藏。
func display_entry(info: Dictionary) -> void:
	if info.is_empty():
		visible = false
		_displaying = false
		current_war_id = -1
		_hovered = false
		if is_instance_valid(_area):
			_area.monitoring = false
			_area.input_ray_pickable = false
		if is_instance_valid(_label):
			_label.visible = false
		return
	current_war_id = int(info.get("war_id", -1))
	visible = true
	_displaying = true
	position = info.get("sphere_pos", Vector3.ZERO)
	_apply_sphere_basis(position)
	_ensure_label()
	if is_instance_valid(_label):
		_label.text = str(info.get("name", ""))
		_label.visible = _hovered
	if is_instance_valid(_area):
		# monitoring 置 true 让 Area3D 的 mouse_entered/mouse_exited 可用于 tooltip；
		# 该 Area3D 不连接 body/area 信号，不影响游戏逻辑。
		_area.monitoring = true
		_area.input_ray_pickable = true


## 创建悬浮战争名 Label3D（billboard，始终面向镜头）。
func _ensure_label() -> void:
	if is_instance_valid(_label):
		return
	_label = Label3D.new()
	_label.name = "战争名称提示"
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	_label.modulate = Color(1, 1, 1)
	_label.outline_modulate = Color(0, 0, 0, 0.85)
	_label.outline_size = 10
	_label.font = 统一字体
	_label.font_size = 48
	_label.pixel_size = 0.0012
	_label.position = Vector3(0, 0.018, 0)
	_label.visible = false
	add_child(_label)


func _on_mouse_entered() -> void:
	_hovered = true
	if is_instance_valid(_label) and _displaying:
		_label.visible = true


func _on_mouse_exited() -> void:
	_hovered = false
	if is_instance_valid(_label):
		_label.visible = false


## 东/北/法线三轴贴球摆放（沿用旧版贴片方案）。
func _apply_sphere_basis(sphere_pos: Vector3) -> void:
	var ll: Vector2 = _latlon_of(sphere_pos)
	var u := (ll.y + 180.0) / 360.0
	var v := (90.0 - ll.x) / 180.0
	var theta := (1.0 - v) * PI
	var phi := u * TAU
	var east := Vector3(cos(phi), 0.0, -sin(phi))
	var north := Vector3(sin(phi) * cos(theta), sin(theta), cos(phi) * cos(theta))
	basis = Basis(east, north, sphere_pos.normalized())


## 球面坐标反解经纬度（与 世界地图渲染.region_id_at_3d 同式）。
func _latlon_of(sphere_pos: Vector3) -> Vector2:
	var local := sphere_pos.normalized()
	var theta := acos(clampf(-local.y, -1.0, 1.0))
	var phi := atan2(local.x, local.z)
	var u := (phi + TAU if phi < 0.0 else phi) / TAU
	var v := 1.0 - theta / PI
	var lon := u * 360.0 - 180.0
	var lat := 90.0 - v * 180.0
	return Vector2(lat, lon)


func _on_area_input_event(
		_camera: Node, event: InputEvent,
		_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not _displaying:
		return
	if event is InputEventMouseMotion:
		_on_mouse_entered()
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			# GUI 控件（tooltip 按钮等）消费点击时，图标不得抢响应。
			if get_viewport().gui_get_hovered_control() != null:
				return
			clicked.emit(current_war_id)
