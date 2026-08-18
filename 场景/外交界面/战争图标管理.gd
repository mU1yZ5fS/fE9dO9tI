extends Node3D

## 战争图标容器 — 对应原版 TimeScript.re_war 数组的集中刷新。
## 原版 TimeScript.Awake:19-24 初始化时刷新、月结 6013-6019 再刷新；
## Godot 端口在 world_state_loaded / stats_changed / date_changed 时刷新，
## 进入外交场景 _ready 也会刷新。stats_changed 在 start_war/resolve_war_finished
## 时由 WarSystem 触发，因此战争图标可以实时显示（如沙巴战争）。

func _ready() -> void:
	if GameManager:
		if not GameManager.world_state_loaded.is_connected(_refresh):
			GameManager.world_state_loaded.connect(_refresh)
		if not GameManager.date_changed.is_connected(_on_date_changed):
			GameManager.date_changed.connect(_on_date_changed)
		if GameManager.has_signal("stats_changed") and not GameManager.stats_changed.is_connected(_refresh):
			GameManager.stats_changed.connect(_refresh)
	_refresh()


func _on_date_changed(_date: GameDate) -> void:
	# 原版只在月结刷新 re_war（TimeScript.cs:6013-6019，data[19]==1 月块）；
	# 这里保留每日刷新作为 stats_changed 之外的兜底（repaint 很轻量）。
	_refresh()


func _refresh() -> void:
	for child in get_children():
		if child.has_method("repaint"):
			child.repaint()
