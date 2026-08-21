class_name ClaimDef
extends Resource

## 区域宣称定义：某 region 除了 base_owner 之外，还有哪些行为体可能拥有它。
## kind 取值建议：
##   core        — 核心领土（通常 base_owner 本身）
##   colonial    — 殖民地/海外领地
##   breakaway   — 可分裂/分离实体（如巴斯克、加泰罗尼亚）
##   unclaimed   — 无主地
##   event       — 由特定事件/决议赋予

@export var region_id: int = 0
@export var gwcode: int = 0
@export var kind: String = "event"
@export var source: String = ""
