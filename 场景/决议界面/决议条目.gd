extends Control

## 决议条目 — 原版 DecisionPref.prefab + DecisionButtonScript.cs 的 Godot 等价。
## 显示逻辑对齐 DecisionButtonScript.ChangeText / ChangeIcon / ChangeCondition：
##   - 文案 = name + desc
##   - 背景 = ready / unready / done 三态
##   - 图标 = decision_sp/D{id}.png（id>35 用 D36-D52；id=20 且阿拉伯统一时用 D20-special）
##   - 点击执行按钮仅在 ready 态可点，点击后 emit exec_requested 交由主界面执行
##     （对应原版 OnMouseDown 里 dec.active() + completedDecisions=true + Repaint）。
##
## 条目自身有脚本，BbcTooltip.attach 不适用；按焦点条目先例委托 build_tooltip。

signal exec_requested(decision_id: int)

var decision_id: int = -1

const ENTRY_W := 1068.0
const ENTRY_H := 236.0
const 图标目录 := "res://资产/UI/决议/决议条目图标/D%s.png"


func _ready() -> void:
	_wire_execute_button()
	# 让鼠标事件穿透到根节点，悬浮提示由条目整体显示
	_set_children_mouse_ignore()
	# 新拷贝的 DecisionDone.png 尚未在编辑器导入时，用 ImageTexture 运行时加载，
	# 已导入后仍走普通 load()（_load_tex 内先试 load）。
	var done_bg := get_node_or_null("已完成决议_背景") as TextureRect
	if done_bg != null:
		done_bg.texture = _load_tex("res://资产/UI/决议/DecisionDone.png")


func _make_custom_tooltip(for_text: String) -> Control:
	return BbcTooltip.build_tooltip(for_text)


func setup(def: DecisionDef) -> void:
	decision_id = def.id
	var completed := DecisionSystem.is_completed(def.id)
	var can_exec: bool = not completed and def.condition.is_valid() and def.condition.call()

	# 文案：原版 ChangeText 显示 name\n desc（Text 方法按 60 列折行）。
	# RichTextLabel 自动换行交给引擎，这里保留标题/描述两个自然段。
	var rtl := get_node_or_null("文案") as RichTextLabel
	if rtl != null:
		rtl.text = "%s\n%s" % [def.title, def.desc]
		rtl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# 三态背景：原版 ChangeCondition 根据 completed / condition 换 sprite。
	_set_bg_visible("背景", can_exec)
	_set_bg_visible("不可执行决议_背景", not completed and not can_exec)
	_set_bg_visible("已完成决议_背景", completed)

	# 执行按钮：原版 OnMouseDown 只在 ready 态执行；不可执行/已完成都不给入口。
	var exec_btn := get_node_or_null("执行决议") as TextureButton
	if exec_btn != null:
		exec_btn.visible = can_exec
		exec_btn.disabled = not can_exec

	# 原版没有独立“不可执行提示”贴图；保留节点但不显示（避免占位空白）。
	var unready_hint := get_node_or_null("不可执行提示") as TextureRect
	if unready_hint != null:
		unready_hint.visible = false

	# 图标：ChangeIcon 规则。
	_set_icon(def.id)

	# 悬浮提示：原版 ChangeText 把 dec.req/dec.result 塞进 okno1；
	# 这里在 req/result 数据补齐后自动显示，未补齐时只显示标题/描述/状态。
	var state := "已完成" if completed else ("可执行" if can_exec else "条件未满足")
	var tip := "%s\n\n%s\n\n【%s】" % [def.title, def.desc, state]
	if not def.req.is_empty():
		tip += "\n\n【条件】\n%s" % def.req
	if not def.result.is_empty():
		tip += "\n\n【效果】\n%s" % def.result
	tooltip_text = tip


func _wire_execute_button() -> void:
	var btn := get_node_or_null("执行决议") as TextureButton
	if btn != null and not btn.pressed.is_connected(_on_exec_pressed):
		btn.pressed.connect(_on_exec_pressed)


func _on_exec_pressed() -> void:
	if decision_id < 0:
		return
	if GameManager == null or GameManager.world == null:
		return
	# 双保险：即使按钮因布局残留可见，也只在 ready 态放行。
	if DecisionSystem.is_completed(decision_id):
		return
	var def := DecisionCatalog.get_def(decision_id)
	if def == null or not def.condition.is_valid() or not def.condition.call():
		return
	exec_requested.emit(decision_id)


func _set_bg_visible(node_name: String, vis: bool) -> void:
	var n := get_node_or_null(node_name)
	if n is CanvasItem:
		n.visible = vis


func _set_icon(id: int) -> void:
	var icon := get_node_or_null("决议条目图标") as TextureRect
	if icon == null:
		return
	var path := 图标目录 % id
	if id == 20 and GameManager != null and GameManager.world != null:
		var c30 := GameManager.world.get_country_by_legacy_index(30)
		if c30 != null and c30.government == GameConstants.Government.SOCIALIST:
			path = "res://资产/UI/决议/决议条目图标/D20-special.png"
	var tex := _load_tex(path)
	icon.texture = tex
	icon.visible = tex != null


func _load_tex(path: String) -> Texture2D:
	# 优先使用已导入纹理；未导入时回退 ImageTexture，保证新拷贝的 PNG 可立即显示。
	var tex := load(path) as Texture2D
	if tex != null:
		return tex
	var img := Image.new()
	if img.load(path) == OK:
		return ImageTexture.create_from_image(img)
	return null


func _set_children_mouse_ignore() -> void:
	for child in get_children():
		if child is Control and child != get_node_or_null("执行决议"):
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
