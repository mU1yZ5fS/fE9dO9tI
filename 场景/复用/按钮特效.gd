extends Node

## 按钮特效 — 全局 UI 横切关注点（2026-08 统一化）。
##
## 自动为场景树中**所有按钮**统一绑定：
##   - 点击音效（音频总管.play_button_click_sound）
##   - 悬停音效（音频总管.play_button_hover_sound）
##   - 按下缩放动效（0.95 回弹）+ 悬停轻微放大（1.03）
##
## 无需任何界面代码调用；动态创建的按钮（node_added）也自动覆盖。
## 个别按钮可配置（Inspector → Meta）：
##   metadata/no_fx      = true  完全排除（不绑定音效与动效）
##   metadata/no_hover   = true  仅禁用悬停音效（点击音效保留）
##   metadata/no_anim    = true  仅禁用动效（音效保留）
## 统一调整（改音效、改动效幅度/时长）只需改本文件。

## 按下动效缩放比例与时长
const PRESS_SCALE := 0.95
const PRESS_DOWN_TIME := 0.05
const PRESS_UP_TIME := 0.12

## 悬停动效放大比例与时长
const HOVER_SCALE := 1.03
const HOVER_TIME := 0.08

## 已绑定按钮（instance_id → true），防重复绑定
var _bound: Dictionary = {}

## 可安全使用居中缩放动效的按钮（instance_id → bool）：
## 仅 rotation==0 且 scale≈1 的按钮（改 pivot 不改变视觉基准）；
## 斜按钮/自带缩放按钮（主菜单 ±35°、设置界面音乐按钮 0.2x）用 modulate 亮度动效，避免位移/消失。
var _anim_safe: Dictionary = {}


func _ready() -> void:
	# 场景树中新增节点即检查（覆盖场景加载与运行时动态创建）
	get_tree().node_added.connect(_on_node_added)
	# 当前已在树中的按钮（autoload 先于场景加载，正常场景都会走 node_added；
	# 兜底扫描一次当前树）
	call_deferred("_scan_current_tree")


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		_bind(node)


func _scan_current_tree() -> void:
	if get_tree().current_scene == null:
		return
	_bind_recursive(get_tree().current_scene)


func _bind_recursive(node: Node) -> void:
	if node is BaseButton:
		_bind(node)
	for child in node.get_children():
		_bind_recursive(child)


func _bind(btn: BaseButton) -> void:
	var id := btn.get_instance_id()
	if _bound.has(id):
		return
	_bound[id] = true
	# 按钮销毁时清理缓存，避免 _bound/_anim_safe 无限膨胀
	if not btn.tree_exited.is_connected(_on_btn_exited):
		btn.tree_exited.connect(_on_btn_exited.bind(id))
	if btn.has_meta("no_fx") and btn.get_meta("no_fx"):
		return
	# 记录原始缩放（部分按钮自带 scale，如 决议按钮 0.78、音乐按钮 0.2），动效按比例缩放
	btn.set_meta("fx_orig_scale", btn.scale)
	# 居中缩放动效仅对"无旋转且无缩放"的按钮安全（pivot 改动会改变视觉基准）
	_anim_safe[id] = btn.rotation == 0.0 and btn.scale.is_equal_approx(Vector2.ONE)
	if not btn.pressed.is_connected(_on_pressed):
		btn.pressed.connect(_on_pressed.bind(btn))
	if not btn.mouse_entered.is_connected(_on_hover):
		btn.mouse_entered.connect(_on_hover.bind(btn))
	if not btn.mouse_exited.is_connected(_on_hover_end):
		btn.mouse_exited.connect(_on_hover_end.bind(btn))


## 按钮退出场景树时清理缓存；只传 instance_id，不持有按钮引用，避免影响释放。
func _on_btn_exited(id: int) -> void:
	_bound.erase(id)
	_anim_safe.erase(id)


func _on_pressed(btn: BaseButton) -> void:
	音频总管.play_button_click_sound()
	if not (btn.has_meta("no_anim") and btn.get_meta("no_anim")):
		_press_anim(btn)


func _on_hover(btn: BaseButton) -> void:
	if not (btn.has_meta("no_hover") and btn.get_meta("no_hover")):
		音频总管.play_button_hover_sound()
	if not (btn.has_meta("no_anim") and btn.get_meta("no_anim")):
		_hover_anim(btn, true)


func _on_hover_end(btn: BaseButton) -> void:
	if not (btn.has_meta("no_anim") and btn.get_meta("no_anim")):
		_hover_anim(btn, false)


## 按下动效：安全按钮缩放回弹；特殊按钮（斜/自带缩放）modulate 变暗回弹
func _press_anim(btn: BaseButton) -> void:
	if _anim_safe.get(btn.get_instance_id(), false):
		_scale_tween(btn, PRESS_SCALE, PRESS_DOWN_TIME, PRESS_UP_TIME)
	else:
		_modulate_tween(btn, 0.82, PRESS_DOWN_TIME, PRESS_UP_TIME)


## 悬停动效：安全按钮轻微放大；特殊按钮 modulate 提亮（结束恢复按下前的值）
func _hover_anim(btn: BaseButton, hovering: bool) -> void:
	if _anim_safe.get(btn.get_instance_id(), false):
		if hovering:
			_scale_tween(btn, HOVER_SCALE, HOVER_TIME, HOVER_TIME)
		else:
			_scale_tween(btn, 1.0, HOVER_TIME, HOVER_TIME)
	else:
		if hovering:
			btn.set_meta("fx_prev_modulate", btn.modulate)
			_tween_to(btn, "modulate", btn.modulate * 1.18, HOVER_TIME)
		else:
			var prev: Color = btn.get_meta("fx_prev_modulate", Color.WHITE)
			_tween_to(btn, "modulate", prev, HOVER_TIME)


## 缩放动效（基于原始 scale，居中缩放；仅安全按钮调用）
func _scale_tween(btn: BaseButton, factor: float, down_time: float, up_time: float) -> void:
	_ensure_pivot(btn)
	var orig: Vector2 = btn.get_meta("fx_orig_scale", Vector2.ONE)
	_kill_tween(btn)
	var tw := btn.create_tween()
	btn.set_meta("fx_tween", tw)
	tw.tween_property(btn, "scale", orig * factor, down_time)
	tw.tween_property(btn, "scale", orig, up_time) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## modulate 动效：变暗/提亮后恢复原值（不改变几何，兼容半透明态按钮）
func _modulate_tween(btn: BaseButton, factor: float, down_time: float, up_time: float) -> void:
	if not btn.has_meta("fx_prev_modulate"):
		btn.set_meta("fx_prev_modulate", btn.modulate)
	var prev: Color = btn.get_meta("fx_prev_modulate", Color.WHITE)
	_kill_tween(btn)
	var tw := btn.create_tween()
	btn.set_meta("fx_tween", tw)
	tw.tween_property(btn, "modulate", prev * factor, down_time)
	tw.tween_property(btn, "modulate", prev, up_time) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## 单段属性补间（悬停提亮/恢复用）
func _tween_to(btn: BaseButton, prop: String, value: Variant, dur: float) -> void:
	_kill_tween(btn)
	var tw := btn.create_tween()
	btn.set_meta("fx_tween", tw)
	tw.tween_property(btn, prop, value, dur)


## 缩放中心 = 按钮中心（绑定时机早于布局，动效发生时布局已就绪）
func _ensure_pivot(btn: BaseButton) -> void:
	btn.pivot_offset = btn.size / 2.0


func _kill_tween(btn: BaseButton) -> void:
	if btn.has_meta("fx_tween"):
		var tw: Tween = btn.get_meta("fx_tween")
		if tw != null and tw.is_valid():
			tw.kill()
