# ============================================================================
# DecisionState — 国策系统状态追踪
# ============================================================================
# 移植自原版 Unity 项目 GameState.cs 的决策相关字段。
#
# 原版数据结构（GameState.cs 第 3414~3416 行）：
#   public Decision[] decisions;        // 所有国策定义（名称、描述、条件、效果）
#   public bool[] completedDecisions;   // 已完成的国策（按索引标记）
#
# 原版 Decision 类（Decision.cs）是一个复杂的链式条件系统：
#   Decision(name, desc, version)
#     .Expr.thirdOne.HasOnePartyMechanic(true).thirdOne.IsLiberal(false)...End
#   每个 Decision 通过 Func<bool> 委托动态计算是否可用，
#   无需单独的 "available" 数组。
#
# 本 Godot 版简化：
#   - completed  → 对应原版 completedDecisions
#   - available  → Godot 新增字段，用于手动管理当前可选国策列表
#                   （原版通过条件表达式动态计算，此简化便于 Inspector 调试）
#
# 【未完成】原版 Decision 数据类（名称/描述/条件/效果）尚未移植。
#   当前仅追踪完成/可用状态，国策的具体定义需另行实现。
# ============================================================================
class_name DecisionState
extends Resource

# 已完成的国策标记（对应原版 completedDecisions: bool[]）
# 索引即国策 ID，例如 completed[7] = true 表示第 7 号国策已完成
@export var completed: Array[bool] = []

# 当前可选国策的 ID 列表（Godot 新增，原版无此字段）
# 原版通过 Decision.condition() 动态计算可用性，此字段便于在 Inspector 中手动管理
@export var available: Array[int] = []


func _init() -> void:
	# 预分配 100 个槽位（与原版决策数量一致）
	completed.resize(100)
	# 【注意】available 未在 _init 中初始化，
	# 需由外部逻辑（如 GameManager）在加载或新游戏时填充
