class_name RegionDef
extends Resource

## 地图区域定义（运行时 Resource）。
## 由 map_builder.gd 从 JSON 生成，运行时只读，不直接手改。

@export var region_id: int = 0
@export var name: String = ""
@export var name_zh: String = ""
@export var base_owner_gwcode: int = 0
## 核心/现代归属国：用于事件后“回归”或默认显示。
@export var core_country_gwcode: int = 0
@export var is_water: bool = false
## 区域中心点（经纬度或像素坐标，由生成器决定）。
@export var center: Vector2 = Vector2.ZERO
## 邻接 region_id 列表。
@export var neighbors: Array[int] = []
## 可宣称/可分裂实体列表。
@export var claims: Array[ClaimDef] = []
## 保留原始 JSON 字段，便于调试和迁移。
@export var raw: Dictionary = {}
