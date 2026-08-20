class_name MapData
extends Resource

## 地图运行时数据（二进制 Resource）。
## 由 map_builder.gd 从 JSON 生成，运行时只 load 这个文件。

@export var meta: Dictionary = {}
## region_id -> RegionDef
@export var regions: Dictionary = {}
## gwcode -> CountryDef
@export var countries: Dictionary = {}
## region_id 有序列表（用于遍历/渲染）
@export var region_order: Array[int] = []
## region_id -> base_owner_gwcode（1976 初始归属，快捷索引）
@export var base_owner: Dictionary = {}
## region_id -> Array[int] 邻接表
@export var neighbors: Dictionary = {}
## region_id -> Array[ClaimDef]
@export var claims: Dictionary = {}


func get_region(region_id: int) -> RegionDef:
	return regions.get(region_id) as RegionDef


func get_country(gwcode: int) -> CountryDef:
	return countries.get(gwcode) as CountryDef


func get_base_owner(region_id: int) -> int:
	return int(base_owner.get(region_id, 0))


func get_neighbors(region_id: int) -> Array[int]:
	var n = neighbors.get(region_id)
	return n if n is Array else []
