class_name WarCatalog
extends RefCounted

## 扫描 res://资产/数据/战争/*.tres 加载 WarDef。

const WAR_DIR := "res://资产/数据/战争/"

static var _by_id: Dictionary = {}
static var _loaded: bool = false


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_by_id.clear()
	# 用 ResScan 以兼容导出包（.tres 会被重映射为 .tres.remap）
	for path in ResScan.list_files(WAR_DIR, [".tres"]):
		var res = load(path)
		if res is WarDef:
			var def := res as WarDef
			_by_id[def.id] = def
		elif res != null:
			push_warning("WarCatalog: 非 WarDef %s" % path)


static func reload() -> void:
	_loaded = false
	_ensure_loaded()


static func get_def(id: int) -> WarDef:
	_ensure_loaded()
	return _by_id.get(id) as WarDef


static func all_ids() -> Array[int]:
	_ensure_loaded()
	var ids: Array[int] = []
	for k in _by_id.keys():
		ids.append(int(k))
	ids.sort()
	return ids


static func count_loaded() -> int:
	_ensure_loaded()
	return _by_id.size()
