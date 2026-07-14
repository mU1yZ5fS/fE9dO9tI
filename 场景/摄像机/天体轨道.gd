class_name CelestialBody
extends Node3D

## 通用天体轨道脚本：绕 Y 轴旋转 + 可选倾角。
## 子节点放在离原点 orbit_radius 距离处即可。

@export var orbit_speed: float = 0.3          ## 弧度/秒
@export var orbit_inclination_deg: float = 0.0  ## 轨道的倾斜角
@export var orbit_radius: float = 3.0         ## 轨道半径（仅作提示，不参与逻辑）
@export var self_rotation_speed: float = 0.0  ## 天体自转速度 (rad/s)，0 则不转


func _ready() -> void:
	rotation_degrees.x = orbit_inclination_deg


func _process(delta: float) -> void:
	rotate_y(orbit_speed * delta)
	if self_rotation_speed != 0.0 and get_child_count() > 0:
		get_child(0).rotate_y(self_rotation_speed * delta)
