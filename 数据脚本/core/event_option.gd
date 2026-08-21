# ============================================================================
# EventOption — 事件选项定义
# ============================================================================
# 描述玩家在事件中可选择的一个选项分支。
#
# 设计参考：
#   - 原版 EventsSecond.VariantsOfEvents() 的三个输出参数：
#       kolvo_variant → count
#       button_text   → text / disabled_text
#       button[]      → enable_condition（替代原版 SetActive(false)）
#   - Godot 4.7 Resource 序列化（gdd_0373）
#
# 与原版的差异：
#   - 原版通过 SetActive(false) 直接控制按钮显隐；
#     本版通过 enable_condition 数据驱动，由 UI 场景根据条件渲染。
#   - 原版禁用选项文本和正常文本共用一个 button_text 数组；
#     本版分离为 text（可选时）和 disabled_text（不可选时），更清晰。
# ============================================================================
class_name EventOption
extends Resource

## 选项按钮文本（条件满足时显示）
@export var text: String = ""

## 选项不可选时显示的门槛文本（如 "需要特工：25"）
@export var disabled_text: String = ""

## 可选条件。null 或条件满足 → 选项可点击；条件不满足 → 灰显
@export var enable_condition: ExprNode

## 选中后执行的效果列表（按数组顺序依次执行）
@export var effects: Array[EffectNode] = []

## 结果标题（为空则沿用事件标题）
@export var result_title: String = ""

## 结果描述文本（显示在事件第三页"结果"页）
@export_multiline var result_text: String = ""
