extends Node2D

## 科研关系线 —— 科技树依赖连线（2026-08 重构：替代手摆的 13 个科研关系_纵向/横向 TextureRect）。
##
## 数据源：TechState.TECH_DEPENDENCY（科技 i 的前置编号）；按钮节点名 = 科研.gd 的 TECH_NAMES。
## 每条依赖画一条 Line2D，端点取两个科技按钮中心（实时读取布局，调按钮位置线自动跟随）。
## 布局调整后无需再手动摆线；新增科技只需补 TECH_NAMES/TECH_DEPENDENCY 并摆好按钮。

const 科研脚本 := preload("res://场景/科研界面/科研.gd")
const TechStateScript := preload("res://数据脚本/core/tech_state.gd")

## 线样式：原 科研关系竖线.png 主色 RGB(74,30,49)（与科技按钮标题色同源）
const 线色 := Color(0.2901961, 0.11764706, 0.19215687, 1)
const 线宽 := 15.0


func _ready() -> void:
	# 延迟到本帧 ready 流程结束后构建（科技条目实例可能刚进入树）
	call_deferred("_build_lines")


func _build_lines() -> void:
	var names: Array = 科研脚本.TECH_NAMES
	var deps: Array = TechStateScript.TECH_DEPENDENCY
	var drawn := 0
	for i in names.size():
		var dep: int = deps[i] if i < deps.size() else -1
		if dep < 0:
			continue
		var from := _btn_center(names[dep])
		var to := _btn_center(names[i])
		if from == Vector2.ZERO or to == Vector2.ZERO:
			continue
		var line := Line2D.new()
		line.width = 线宽
		line.default_color = 线色
		line.points = PackedVector2Array([from, to])
		add_child(line)
		drawn += 1
	if drawn == 0:
		push_warning("科研关系线: 未画出任何连线（科技条目实例未找到？）")


## 科技条目中心（转为本节点局部坐标）。
## 条目已是 科技条目.tscn 组件实例：根为 Control（节点名=科技名），按钮为其子节点"按钮"。
func _btn_center(tech_name: String) -> Vector2:
	var root := get_parent()
	if root == null:
		return Vector2.ZERO
	var entry := root.find_child(tech_name, true, false) as Control
	if entry == null:
		return Vector2.ZERO
	var btn := entry.get_node_or_null("按钮") as TextureButton
	if btn == null:
		return Vector2.ZERO
	return to_local(btn.get_global_rect().get_center())
