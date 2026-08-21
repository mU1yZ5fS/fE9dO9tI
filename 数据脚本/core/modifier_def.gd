class_name ModifierDef
extends Resource

## 单条修正的展示定义（只读文案/图标，不含运行时 is_active）。
## 运行时激活状态仍在 WorldState.modifiers / ModifierSlot。
## 对齐原版 Modify_iconsScript 的 this_on / this_off 两套图。

@export var id: int = -1
@export var name_zh: String = ""
## 静态效果说明；动态公式可在 catalog 层按 id 覆盖
@export_multiline var effect_zh: String = ""
## 激活态图标（原版 this_on）
@export var icon_active: Texture2D
## 未激活态图标（原版 this_off）
@export var icon_inactive: Texture2D
