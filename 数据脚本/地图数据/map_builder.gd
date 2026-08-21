class_name MapBuilder
extends RefCounted

## 地图 JSON -> 运行时 MapData Resource 的生成器。
## 用法（编辑器或工具脚本）：
##   var md := MapBuilder.build()
##   # 输出到 res://资产/地图/generated/map_data.res
##
## 源文件约定（当前兼容根目录，后续建议迁到 source/）：
##   map_meta.json
##   map_countries.json
##   map_regions.json
##   map_neighbors.json  （可选，缺省为空邻接）
##   map_claims.json     （可选，缺省由 map_countries 重复 region 自动推导）

const DEFAULT_SOURCE_DIR := "res://资产/地图"
const DEFAULT_OUTPUT_PATH := "res://资产/地图/generated/map_data.res"


static func build(source_dir: String = DEFAULT_SOURCE_DIR, output_path: String = DEFAULT_OUTPUT_PATH) -> MapData:
	var meta := _load_json(source_dir + "/map_meta.json")
	var countries_raw := _load_json(source_dir + "/map_countries.json")
	var actors_raw := _load_json(source_dir + "/map_actors.json") \
		if FileAccess.file_exists(source_dir + "/map_actors.json") else {}
	var regions_raw := _load_json(source_dir + "/map_regions.json")
	var neighbors_raw := _load_json(source_dir + "/map_neighbors.json") \
		if FileAccess.file_exists(source_dir + "/map_neighbors.json") else {}
	var claims_raw := _load_json(source_dir + "/map_claims.json") \
		if FileAccess.file_exists(source_dir + "/map_claims.json") else {}

	var map_data := MapData.new()
	map_data.meta = meta

	# ── 1. 国家/行为体 ──
	var region_to_countries: Dictionary = {}
	for gw_key in countries_raw:
		var entry: Dictionary = countries_raw[gw_key]
		var cd := CountryDef.new()
		cd.gwcode = int(gw_key)
		cd.name_1976 = str(entry.get("name_1976", ""))
		cd.name_zh = str(entry.get("name_zh", ""))
		cd.gov_names = entry.get("gov_names", {})
		cd.raw = entry
		cd.is_fictional = cd.gwcode < 0 or cd.gwcode >= 9000
		var region_ids: Array = entry.get("regions", [])
		for raw_rid in region_ids:
			var rid := int(raw_rid)
			cd.region_ids.append(rid)
			if not region_to_countries.has(rid):
				region_to_countries[rid] = []
			region_to_countries[rid].append(cd.gwcode)
		map_data.countries[cd.gwcode] = cd

	# 伪实体/分离实体/无主地（map_actors.json）
	for gw_key in actors_raw:
		var entry: Dictionary = actors_raw[gw_key]
		var cd := CountryDef.new()
		cd.gwcode = int(gw_key)
		cd.name_1976 = str(entry.get("name_1976", ""))
		cd.name_zh = str(entry.get("name_zh", ""))
		cd.gov_names = entry.get("gov_names", {})
		cd.raw = entry
		cd.is_fictional = true
		var region_ids: Array = entry.get("regions", [])
		for raw_rid in region_ids:
			var rid := int(raw_rid)
			cd.region_ids.append(rid)
			if not region_to_countries.has(rid):
				region_to_countries[rid] = []
			region_to_countries[rid].append(cd.gwcode)
		map_data.countries[cd.gwcode] = cd

	# ── 2. 区域 ──
	var region_ids_all: Array[int] = []
	for raw_rid in regions_raw:
		region_ids_all.append(int(raw_rid))
	region_ids_all.sort()

	for raw_rid in region_ids_all:
		var rid := int(raw_rid)
		var entry: Dictionary = regions_raw[str(raw_rid)]
		var rd := RegionDef.new()
		rd.region_id = rid
		rd.name = str(entry.get("name", ""))
		rd.name_zh = str(entry.get("name_zh", ""))
		rd.is_water = bool(entry.get("is_water", false))
		rd.base_owner_gwcode = int(entry.get("owner_1976_gwcode", 0))
		rd.core_country_gwcode = rd.base_owner_gwcode
		rd.center = Vector2(
			float(entry.get("longitude", 0.0)),
			float(entry.get("latitude", 0.0))
		)
		rd.raw = entry

		# 邻接（可选）
		if neighbors_raw.has(str(rid)):
			var nb: Array = neighbors_raw[str(rid)]
			for n in nb:
				rd.neighbors.append(int(n))
		elif neighbors_raw.has(rid):
			var nb: Array = neighbors_raw[rid]
			for n in nb:
				rd.neighbors.append(int(n))

		# 宣称（优先外部 claims，否则从重复 region 自动推导）
		var region_claims: Array[ClaimDef] = []
		if claims_raw.has(str(rid)):
			var raw_claims: Array = claims_raw[str(rid)]
			for raw_claim in raw_claims:
				var claim := ClaimDef.new()
				claim.region_id = rid
				claim.gwcode = int(raw_claim.get("gwcode", 0))
				claim.kind = str(raw_claim.get("kind", "event"))
				claim.source = str(raw_claim.get("source", ""))
				region_claims.append(claim)
		else:
			var owners: Array = region_to_countries.get(rid, [])
			for owner_gw in owners:
				var owner_id := int(owner_gw)
				if owner_id == rd.base_owner_gwcode:
					continue
				var claim := ClaimDef.new()
				claim.region_id = rid
				claim.gwcode = owner_id
				if owner_id < 0:
					claim.kind = "unclaimed"
				elif owner_id >= 9000:
					claim.kind = "breakaway"
				else:
					claim.kind = "colonial"
				claim.source = "auto:map_countries"
				region_claims.append(claim)
		rd.claims = region_claims

		map_data.regions[rid] = rd
		map_data.region_order.append(rid)
		map_data.base_owner[rid] = rd.base_owner_gwcode
		map_data.neighbors[rid] = rd.neighbors.duplicate()
		map_data.claims[rid] = region_claims

	# ── 3. 国家核心 region 推导 ──
	for gw_key in map_data.countries:
		var cd: CountryDef = map_data.countries[gw_key]
		for rid in cd.region_ids:
			var base: int = map_data.get_base_owner(rid)
			if base == cd.gwcode:
				cd.core_region_ids.append(rid)

	# ── 4. 输出 ──
	var dir := output_path.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var err := ResourceSaver.save(map_data, output_path)
	if err != OK:
		push_error("MapBuilder: 保存失败 %d -> %s" % [err, output_path])
	else:
		print("MapBuilder: 已生成 %s (regions=%d countries=%d)" % [
			output_path, map_data.region_order.size(), map_data.countries.size()
		])
	return map_data


static func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("MapBuilder: 找不到 %s，按空字典处理" % path)
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	return parsed if parsed is Dictionary else {}
