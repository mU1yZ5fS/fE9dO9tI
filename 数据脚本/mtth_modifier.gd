# ============================================================================
# MTTHModifier — 事件触发时间加权修正
# ============================================================================
# Mean Time To Happen（MTTH）是 P 社游戏的事件触发机制核心。
#
# 基础概念：
#   每个事件有一个 mtth_base（基础平均触发月数）。
#   MTTHModifier 列表通过 factor 乘数加速或延缓触发。
#     factor=0.5  → 触发快一倍（基础12月 → 实际6月）
#     factor=2.0  → 触发慢一倍（基础12月 → 实际24月）
#   每个 modifier 只有在 condition 满足时才生效。
#
# 原版对应：原版 GameState 中没有显式 MTTH 系统，事件通过 EventScript.time
#   和 Update() 中的倒计时实现。本系统将计时逻辑统一管理。
#
# 使用示例（Event120 无 MTTH 修正，由 Decision 直接触发）：
#   mtth_modifiers = []
#
# 使用示例（饥荒事件 —— 缺粮时加速）：
#   mtth_modifiers = [
#       MTTHModifier.new(0.3,  ExprNode.resource_at_most("food", 100)),
#       MTTHModifier.new(2.0,  ExprNode.resource_at_least("food", 500)),
#   ]
# ============================================================================
class_name MTTHModifier
extends Resource

## 乘数因子。小于 1 加速触发，大于 1 延缓触发
@export var factor: float = 1.0

## 该修正生效的条件（null = 始终生效）
@export var condition: ExprNode


func _init(p_factor: float = 1.0, p_condition: ExprNode = null) -> void:
	factor = p_factor
	condition = p_condition
