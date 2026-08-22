## 玩家经济数据 — WorldState 具名字段的只读显示视图。
## 不持有数据副本，仅在 sync_from_world() 时从 WorldState 提取并换算显示值。
class_name EconomyData
extends Resource

# 字段语义对照（权威源：原版 QueryChina.cs）
#   党内支持、民众支持、思想自由、生活水平、国际声望、全球影响
#   预算、特工网络、科研点、工业、农业、军力、人口、外汇储备

@export_category("社会")
@export var 党内支持度: float = 0.0
@export var 民众支持度: float = 0.0
@export var 思想自由度: float = 0.0
@export var 生活水平: float = 0.0
@export var 国际声望: float = 0.0
@export var 全球影响力: float = 0.0

@export_category("财政军事")
@export var 预算: int = 0
@export var 特工网络: int = 0
@export var 科研点数: int = 0
@export var 工业: int = 0
@export var 农业: int = 0
@export var 军力: int = 0
@export var 外汇储备: int = 0
@export var 人口: int = 0


## 从 WorldState 具名字段提取显示值。无副本，无 duplicate。
func sync_from_world(world: WorldState) -> void:
	if world == null:
		return
	党内支持度 = float(world.party_support) / 10.0
	民众支持度 = float(world.people_support) / 10.0
	思想自由度 = float(world.thought_freedom) / 10.0
	生活水平 = float(world.living_standard) / 10.0
	国际声望 = float(world.diplomatic_reputation) / 10.0
	# 原版 TimeScript.KumihaRepaint 把 data[7] 镜像为 gameState.influencePRC，
	# 因此顶栏“全球影响力/国际影响力”应显示 influence_prc，而不是独立字段 global_influence。
	全球影响力 = float(world.influence_prc) / 10.0
	预算 = world.budget
	特工网络 = world.agents
	科研点数 = world.science
	工业 = world.industry
	农业 = world.agriculture
	军力 = world.army
	人口 = world.population
	外汇储备 = world.reserve
