# ============================================================================
# EmpireInsider — 帝国内部成员/附庸国
# ============================================================================
# 移植自原版 Unity 项目 `Insider.cs`（Assets/Scripts/Insider.cs）。
#
# 原版字段（Insider.cs）：
#   name: string       → name
#   influence: int     → influence（对帝国决策的影响力）
#
# 原版构造函数：Insider(name, sup)，参数名为 sup 但语义为 influence。
# 本版将参数名修正为 p_influence，消除歧义。
# ============================================================================
class_name EmpireInsider
extends Resource

# 成员/附庸国名称（原版 name: string）
@export var name: String = ""
# 对帝国的影响力（原版 influence: int，注意原版构造函数参数名为 sup）
@export var influence: int = 0


func _init(p_name: String = "", p_influence: int = 0) -> void:
	name = p_name
	influence = p_influence
