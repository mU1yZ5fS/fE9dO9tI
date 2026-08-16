extends Node3D

## 战争图标容器 — 对应原版 TimeScript.re_war 数组的集中刷新。
## 原版 TimeScript.Awake:19-24 初始化时刷新、月结 6013-6019 再刷新；
## Godot 端口在 world_state_loaded / date_changed 时刷新，进入外交场景 _ready 也会刷新。

func _ready() -> void:
	if GameManager:
		if not GameManager.world_state_loaded.is_connected(_refresh):
			GameManager.world_state_loaded.connect(_refresh)
		if not GameManager.date_changed.is_connected(_on_date_changed):
			GameManager.date_changed.connect(_on_date_changed)
	_refresh()


func _on_date_changed(date: GameDate) -> void:
	# 原版只在月结刷新 re_war（TimeScript.cs:6013-6019，data[19]==1 月块）。
	if date.day == 1:
		_refresh()


func _refresh() -> void:
	for child in get_children():
		if child.has_method("repaint"):
			child.repaint()
