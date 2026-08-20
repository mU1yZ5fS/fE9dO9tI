class_name GameViewModel
extends RefCounted

## UI ViewModel 基类。
## 负责持有 GameManager 引用、订阅/退订刷新信号，子类实现 get_values() 等展示逻辑。

signal changed

var _gm: Node = null


func bind(gm: Node) -> void:
	_gm = gm
	if _gm == null:
		return
	if _gm.has_signal("stats_changed") and not _gm.stats_changed.is_connected(_on_stats_changed):
		_gm.stats_changed.connect(_on_stats_changed)
	if _gm.has_signal("date_changed") and not _gm.date_changed.is_connected(_on_date_changed):
		_gm.date_changed.connect(_on_date_changed)
	if _gm.has_signal("world_state_loaded") and not _gm.world_state_loaded.is_connected(_on_world_loaded):
		_gm.world_state_loaded.connect(_on_world_loaded)


func unbind() -> void:
	if _gm == null:
		return
	if _gm.stats_changed.is_connected(_on_stats_changed):
		_gm.stats_changed.disconnect(_on_stats_changed)
	if _gm.date_changed.is_connected(_on_date_changed):
		_gm.date_changed.disconnect(_on_date_changed)
	if _gm.world_state_loaded.is_connected(_on_world_loaded):
		_gm.world_state_loaded.disconnect(_on_world_loaded)
	_gm = null


func _on_stats_changed() -> void:
	changed.emit()


func _on_date_changed(_date: GameDate) -> void:
	changed.emit()


func _on_world_loaded() -> void:
	changed.emit()
