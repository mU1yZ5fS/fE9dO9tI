# ============================================================================
# EmpireLeader — 帝国领导人
# ============================================================================
# 移植自原版 Unity 项目 `Leader.cs`（Assets/Scripts/Leader.cs）。
#
# 原版字段（Leader.cs）：
#   leader_name: string    → leader_name
#   support: int           → support（民众/党内支持值）
#
# 原版构造函数：Leader(name, sup)，仅用于硬编码初始化。
# 本版保持相同的两个参数。
# ============================================================================
class_name EmpireLeader
extends Resource

# 领导人姓名（原版 leader_name）
@export var leader_name: String = ""
# 支持度（原版 support: int）
@export var support: int = 0


func _init(p_name: String = "", p_support: int = 0) -> void:
	leader_name = p_name
	support = p_support
