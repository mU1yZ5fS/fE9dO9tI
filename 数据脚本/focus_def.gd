# ============================================================================
# FocusDef / FocusTreeDef — 焦点树数据模型
# ============================================================================
# 移植自原版 Unity 项目：
#   - Focus.cs（Assets/Scripts/Focus.cs，148 行）
#   - KGFocus/FocusTree.cs（Assets/Scripts/KGFocus/FocusTree.cs，43 行）
#   - KGFocus/FocusManager.cs（all_trees 字典）
#   - Focuses/USSRFocuses.cs（唯一焦点树 "Start Focus"，7 层 20 焦点）
#
# 原版字段对照（Focus.cs:119-147）：
#   desc(title/desc/icon) → 文本来自 new_focuses_texts_en.xml（裁决：xml 为权威）
#   time=75              → time
#   overtime             → overtime（不存档，原版也不序列化）
#   blocked              → blocked
#   condition/expression/LeaderCondition → condition（单一 Callable 链）
#   active               → effects（Action 委托链）
#   req / result         → req / result（显示文本）
#
# 存档语义（对齐原版）：树/焦点定义代码目录重建，不序列化；
# 进度只存 EmpireData.current_layer / current_focus / active_focus_tree。
# ============================================================================
class_name FocusDef
extends RefCounted


## 焦点英文 key（= xml <name>，也用于图标加载）
var name_key: String = ""

## 标题（xml <title> 逐字中文）
var title: String = ""

## 描述（xml <desc> 逐字中文）
var desc: String = ""

## 图标（xml <icon>；"none" 表示无图标）
var icon: String = "none"

## 研究耗时（原版 time，tick 单位：1 tick = 双周）
var time: int = 75

## 已研究时长（原版 overtime；不存档）
var overtime: int = 0

## 被封锁（原版 blocked：本层当前焦点之外全部置 true 灰显）
var blocked: bool = false

## 层内序号（0 起，UI 定位用）
var index_in_layer: int = 0

## 可用条件（原版 condition() lambda 链）
var condition: Callable = Callable()

## 完成效果链（原版 active() Action 链）
var effects: Array[Callable] = []

## 门槛文本（原版 req，逐字）
var req: String = ""

## 效果文本（原版 result，逐字）
var result: String = ""


func is_completed(_time_ratio: float) -> bool:
	## 颜色状态用（FocusButtoNScript.ChangeCondition）：
	## overtime >= time → 已完成（红/蓝），> 0 → 进行中（黄）
	return float(overtime) >= float(time)


func tick() -> void:
	overtime += 1
