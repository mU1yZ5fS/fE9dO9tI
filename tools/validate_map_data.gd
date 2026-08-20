extends SceneTree

## 地图数据 headless 校验工具。
## 用法：
##   godot --headless --path . -s res://tools/validate_map_data.gd
## 检查：
##   1. 运行时 JSON 字段白名单（地图原始 GIS 字段应只存在于 source/ 备份）
##   2. map_neighbors 的 key 必须是 map_regions 的合法 region_id
##   3. country_identity.json 中每个 legacy_id → gwcode 映射有效：
##      真实 gwcode 必须存在于 map_countries；9000+ 虚拟国必须落在允许范围

const MAP_DIR := "res://资产/地图"
const INITIAL_DIR := "res://资产/数据/初始/"

const REGION_FIELDS := ["name", "name_zh", "owner_1976_gwcode", "is_water", "longitude", "latitude"]
const COUNTRY_FIELDS := ["name_1976", "name_zh", "gov_names", "regions"]
const ACTOR_FIELDS := ["name_1976", "name_zh", "gov_names", "regions"]


func _initialize() -> void:
	var errors: Array[String] = []

	var regions := _load_dict(MAP_DIR + "/map_regions.json", errors)
	var countries := _load_dict(MAP_DIR + "/map_countries.json", errors)
	var actors := _load_dict(MAP_DIR + "/map_actors.json", errors)
	var neighbors := _load_dict(MAP_DIR + "/map_neighbors.json", errors)
	var identity := _load_dict(INITIAL_DIR + "/country_identity.json", errors)

	_check_fields(MAP_DIR + "/map_regions.json", regions, REGION_FIELDS, errors)
	_check_fields(MAP_DIR + "/map_countries.json", countries, COUNTRY_FIELDS, errors)
	_check_fields(MAP_DIR + "/map_actors.json", actors, ACTOR_FIELDS, errors)

	for nk in neighbors:
		if not regions.has(nk):
			errors.append("map_neighbors.json: %s 不是合法 region_id" % nk)

	for sid in identity:
		var gw := int(identity[sid])
		if gw >= 9000:
			if gw < 9000 or gw > 9200:
				errors.append("country_identity.json: %s -> %d 超出 9000+ 虚拟国范围" % [sid, gw])
		else:
			var gw_str := str(gw)
			if not countries.has(gw_str):
				errors.append("country_identity.json: %s -> %d 不存在于 map_countries.json" % [sid, gw])

	if errors.is_empty():
		print("MapData validation OK")
		quit(0)
	else:
		for e in errors:
			push_error(e)
		quit(1)


func _load_dict(path: String, errors: Array[String]) -> Dictionary:
	if not FileAccess.file_exists(path):
		errors.append("缺失文件: %s" % path)
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		return parsed
	errors.append("JSON 根节点不是 Dictionary: %s" % path)
	return {}


func _check_fields(path: String, data: Dictionary, allowed: Array, errors: Array[String]) -> void:
	for key in data:
		var entry = data[key]
		if entry is Dictionary:
			for f in entry.keys():
				if not allowed.has(f):
					errors.append("%s: key=%s 含白名单外字段 %s" % [path, key, f])
