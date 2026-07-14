extends Node3D
class_name OrbitCamera

## =============================================================================
## OrbitCamera — Google Earth 风格轨道摄像机
## =============================================================================
## 功能：右键拖拽绕球心旋转 + 滚轮缩放，模拟 Google Earth 操作体验。
##
## 节点结构要求（挂在本节点上）：
##   CameraPivot (本 Node3D)
##     └── SpringArm3D        ← 弹簧臂，控制相机距离
##           └── Camera3D      ← 实际相机
##
## 使用方式：将本脚本挂到场景根节点下的某个 Node3D 上，并确保其子节点
## 包含 SpringArm3D → Camera3D 的层级结构。
##
## 注意事项（评审意见）：
##   1. _find_child() 只搜索两层（直接子节点 + SpringArm3D 的子节点），
##      如果层级更深则找不到。建议改用递归搜索或直接用 @onready 导出引用。
##   2. _find_territory_map() 通过遍历父节点的子节点来查找 TerritoryMap，
##      耦合较紧。建议改用全局单例（autoload）或信号机制解耦。
##   3. 使用 _unhandled_input 而非 _input，意味着 UI 控件可以优先消费鼠标
##      事件，这对策略游戏是有利的设计，但需要确保 UI 设置了 mouse_filter。
##   4. _orbit() 的参数 mouse_pos 实际上仅用于计算 delta，方法内部也依赖
##      _last_mouse_pos 的先前值，耦合性略高。可以考虑改为接收 delta 向量。
## =============================================================================

## 鼠标灵敏度，值越大旋转越快
@export var mouse_sensitivity: float = 0.005
## 滚轮缩放倍率因子：>1 时每格滚轮缩放 zoom_speed 倍
@export var zoom_speed: float = 1.15
## 最小相机距离（最近能拉到多近）
@export var min_distance: float = 0.68
## 最大相机距离（最远能拉到多远）
@export var max_distance: float = 5.0
## 俯仰角限制（度），防止翻过南北极点导致视角反转
@export var tilt_limit_deg: float = 85.0

## SpringArm3D 引用，控制相机与旋转中心的距离
var _spring_arm: SpringArm3D
## Camera3D 引用，供外部（如 TerritoryMap）使用
var _camera: Camera3D
## 右键是否正在拖拽中
var _is_dragging: bool = false
## 上一帧的鼠标位置，用于计算拖拽增量
var _last_mouse_pos: Vector2 = Vector2.ZERO


## ---------------------------------------------------------------------------
## 生命周期
## ---------------------------------------------------------------------------

func _ready() -> void:
	_spring_arm = $SpringArm3D
	_camera = $SpringArm3D/Camera3D
	
	# 初始化时确保弹簧臂长度在合法范围内
	if _spring_arm:
		_spring_arm.spring_length = clampf(_spring_arm.spring_length, min_distance, max_distance)

	# 延迟一帧注册相机到 TerritoryMap：确保场景树已完全构建
	call_deferred("_register_camera")


## 将相机引用注入到 TerritoryMap，供其射线拾取使用。
## call_deferred 确保 TerritoryMap._ready() 先执行完毕。
func _register_camera() -> void:
	if _camera == null:
		return
	var globe := _find_territory_map()
	if globe:
		globe._camera_ref = _camera


## 在同级子节点中查找 TerritoryMap 实例
func _find_territory_map() -> TerritoryMap:
	var parent := get_parent()
	if parent == null:
		return null
	for c in parent.get_children():
		if c is TerritoryMap:
			return c as TerritoryMap
	return null




## ---------------------------------------------------------------------------
## 输入处理
## ---------------------------------------------------------------------------

## 使用 _unhandled_input 而非 _input：
## 当 UI 控件（按钮、面板等）消费了鼠标事件后，此处不再响应，
## 避免拖拽地图时误触 UI 元素。确保 UI 控件的 mouse_filter 设为 STOP。
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		match mb.button_index:
			MOUSE_BUTTON_RIGHT:
				# 右键按下 → 开始拖拽；右键释放 → 结束拖拽
				_is_dragging = mb.pressed
				_last_mouse_pos = mb.position
			MOUSE_BUTTON_WHEEL_UP:
				# 滚轮向上 → 拉近（除以 zoom_speed）
				_zoom(1.0 / zoom_speed)
			MOUSE_BUTTON_WHEEL_DOWN:
				# 滚轮向下 → 拉远（乘以 zoom_speed）
				_zoom(zoom_speed)

	elif event is InputEventMouseMotion and _is_dragging:
		# 拖拽中移动鼠标 → 旋转视角
		_orbit((event as InputEventMouseMotion).position)


## ---------------------------------------------------------------------------
## 旋转与缩放
## ---------------------------------------------------------------------------

## 根据鼠标位移增量旋转摄像机。
## - Yaw（水平旋转）：绕世界 Y 轴，鼠标横向移动
## - Pitch（垂直旋转）：绕自身 X 轴，受 tilt_limit_deg 约束
## [注意] 参数 mouse_pos 是当前鼠标位置，方法内部结合 _last_mouse_pos 
##        计算增量后更新 _last_mouse_pos。
func _orbit(mouse_pos: Vector2) -> void:
	# 计算本帧鼠标位移增量
	var delta := mouse_pos - _last_mouse_pos
	_last_mouse_pos = mouse_pos

	# Yaw — 绕世界 Y 轴旋转（水平方向）
	# 取负号使拖拽方向与直觉一致：鼠标右移 → 视角右转
	rotate_y(-delta.x * mouse_sensitivity)

	# Pitch — 绕自身 X 轴旋转（垂直方向），限制在 ±tilt_limit 范围内
	var tilt_limit := deg_to_rad(tilt_limit_deg)
	rotation.x -= delta.y * mouse_sensitivity
	rotation.x = clampf(rotation.x, -tilt_limit, tilt_limit)


## 缩放：修改 SpringArm3D 的 spring_length，限制在 [min_distance, max_distance]。
## factor > 1 拉远，factor < 1 拉近。
func _zoom(factor: float) -> void:
	if _spring_arm == null:
		return
	_spring_arm.spring_length = clampf(
		_spring_arm.spring_length * factor,
		min_distance,
		max_distance
	)
