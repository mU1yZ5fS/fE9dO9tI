class_name ModifierDef
extends Resource

## 单条修正的展示定义（只读文案/图标，不含运行时 is_active）。
## 运行时激活状态仍在 WorldState.modifiers / ModifierSlot。

@export var id: int = -1
@export var name_zh: String = ""
## 静态效果说明；动态公式可在 catalog 层按 id 覆盖
@export_multiline var effect_zh: String = ""
## 概览列表用图标；可在 Inspector 拖入 Texture2D，留空则模板隐藏图标位
@export var icon: Texture2D
