extends Control

## 科技条目 — 科技树单个科技的单位组件（2026-08 重构：34 个手摆条目 → 实例化复用）。
## 内部 4 节点相对按钮固定偏移：状态图标(+8,75)、进度条(+146,8)、年份(+8,109)。
## 实例化时设置：
##   tech_name       → 节点名改为科技名（科研.gd 按 TECH_NAMES 查找）
##   button_texture  → 科技按钮底图（资产/UI/科研/<类>_<科技名>.png）
## 布局调整只需改本场景一个模板。

@export var tech_name: String = ""
@export var button_texture: Texture2D


func _ready() -> void:
	if tech_name != "":
		name = tech_name
	if button_texture:
		$按钮.texture_normal = button_texture
