class_name DiploActionLoader
extends RefCounted

## 外交动作 JSON -> DiploActionDef 加载器。
## 目标：把 232 个手写 _def_N 逐步迁到数据文件。
## 当前仅提供加载能力；运行时仍以代码批次为权威，后续逐步切换。

const DEFAULT_DIR := "res://资产/数据/外交动作/"


static func load_all_from_dir(dir_path: String = DEFAULT_DIR) -> Dictionary:
	var result: Dictionary = {}
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir_path)):
		return result
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var loaded := load_file(dir_path + file_name)
			for id in loaded:
				result[int(id)] = loaded[id]
		file_name = dir.get_next()
	dir.list_dir_end()
	return result


static func load_file(path: String) -> Dictionary:
	var result: Dictionary = {}
	if not FileAccess.file_exists(path):
		return result
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Array:
		for item in parsed:
			var def := _to_def(item)
			if def != null:
				result[def.id] = def
	elif parsed is Dictionary:
		# 支持 { "1": {...}, "2": {...} } 形式
		for key in parsed:
			var item: Dictionary = parsed[key]
			item["id"] = int(key) if not item.has("id") else item["id"]
			var def := _to_def(item)
			if def != null:
				result[def.id] = def
	return result


static func _to_def(data: Dictionary) -> DiploActionDef:
	if data.is_empty():
		return null
	var def := DiploActionDef.new()
	def.id = int(data.get("id", 0))
	def.caption = str(data.get("caption", ""))
	def.opis = str(data.get("opis", ""))
	def.conditions = data.get("conditions", [])
	def.effects = data.get("effects", [])
	def.dormant = bool(data.get("dormant", false))
	def.source = str(data.get("source", ""))
	return def
