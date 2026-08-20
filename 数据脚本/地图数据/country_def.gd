class_name CountryDef
extends Resource

## 地图国家/行为体定义（运行时 Resource）。
## 由 map_builder.gd 从 JSON 生成。
## 注意：这里的 gwcode 与 CountryData.gwcode 是同一套规范 id。

@export var gwcode: int = 0
@export var name_1976: String = ""
@export var name_zh: String = ""
## 该行为体在 map_countries.json 中列出的全部 region。
## 注意：这些 region 可能是“初始归属”，也可能是“可宣称/可分裂区域”。
@export var region_ids: Array[int] = []
## 真正属于该国的核心 region（1976 实际控制）。
## 生成器会尽量从 map_regions.owner_1976_gwcode 推导。
@export var core_region_ids: Array[int] = []
## 是否为正式国家（false 表示无主地/分离实体/虚构行为体）。
@export var is_fictional: bool = false
@export var gov_names: Dictionary = {}
@export var raw: Dictionary = {}
