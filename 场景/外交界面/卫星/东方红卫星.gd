extends Node3D

## 东方红一号卫星交互脚本
## 挂在卫星实例节点上，监听 Area3D 的点击事件。

signal satellite_clicked


func _ready() -> void:
	var area := get_node_or_null("Area3D") as Area3D
	if area:
		area.input_ray_pickable = true
		area.input_event.connect(_on_body_input_event)


func _on_body_input_event(
		_camera: Node, event: InputEvent,
		_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			satellite_clicked.emit()
