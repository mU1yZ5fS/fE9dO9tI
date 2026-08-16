extends Control

## 决议界面 — 原版 Decisions.unity（FocusesScript.notFocuses=1 分支）的 Godot 等价。
## 列表语义对齐 FocusesScript.CreateDecisions：
##   ready → unready → done 排序；dlc[version]==false 不显示；
## 条目点击对齐 DecisionButtonScript.OnMouseDown：条件满足才执行。
## 布局：场景文件提供背景/标题/返回；滚动列表运行时补齐（沿用战争界面模式）。

const DIPLOMACY_SCENE := "uid://vq6jexkk5tru"

var _list: VBoxContainer
var _refresh_queued: bool = false


func _ready() -> void:
	_ensure_list_host()
	if GameManager:
		if GameManager.has_signal("stats_changed") and not GameManager.stats_changed.is_connected(_on_stats):
			GameManager.stats_changed.connect(_on_stats)
		if not GameManager.world_state_loaded.is_connected(_on_world_loaded):
			GameManager.world_state_loaded.connect(_on_world_loaded)
	_rebuild_list()


func _ensure_list_host() -> void:
	var scroll := get_node_or_null("决议滚动") as ScrollContainer
	if scroll == null:
		scroll = ScrollContainer.new()
		scroll.name = "决议滚动"
		scroll.anchor_left = 0.5
		scroll.anchor_right = 0.5
		scroll.offset_left = -460.0
		scroll.offset_right = 460.0
		scroll.offset_top = 110.0
		scroll.offset_bottom = 1040.0
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		add_child(scroll)
	_list = scroll.get_node_or_null("决议列表") as VBoxContainer
	if _list == null:
		_list = VBoxContainer.new()
		_list.name = "决议列表"
		_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_list.add_theme_constant_override("separation", 10)
		scroll.add_child(_list)


func _on_stats() -> void:
	_request_refresh()


func _on_world_loaded() -> void:
	_request_refresh()


func _request_refresh() -> void:
	if _refresh_queued:
		return
	_refresh_queued = true
	call_deferred("_rebuild_list")


func _rebuild_list() -> void:
	_refresh_queued = false
	if _list == null or not is_instance_valid(_list):
		return
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	if GameManager == null or GameManager.world == null:
		return
	var defs := DecisionSystem.ordered_defs()
	if defs.is_empty():
		var empty := Label.new()
		empty.text = "当前没有可显示的决议"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_list.add_child(empty)
		return
	for def: DecisionDef in defs:
		_list.add_child(_make_entry(def))


func _make_entry(def: DecisionDef) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(920, 96)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var done := DecisionSystem.is_completed(def.id)
	var ready: bool = not done and def.condition.is_valid() and def.condition.call()
	var state := "已完成" if done else ("条件未满足" if not ready else "可执行")
	# 悬浮介绍：标题+描述+状态，多行自动换行（复用 BbcTooltip，460px 宽按 26 字/行折行）
	b.tooltip_text = "%s\n\n%s\n\n【%s】" % [def.title, def.desc, state]
	BbcTooltip.attach(b)
	if done:
		b.text = "%s（已完成）" % def.title
		b.disabled = true
		b.modulate = Color(0.6, 0.7, 0.6, 1)
	elif ready:
		b.text = def.title
		b.modulate = Color(1, 1, 1, 1)
	else:
		b.text = "%s（条件未满足）" % def.title
		b.disabled = true
		b.modulate = Color(0.55, 0.55, 0.55, 1)
	b.pressed.connect(_on_entry_pressed.bind(def.id))
	return b


func _on_entry_pressed(decision_id: int) -> void:
	音频总管.play_button_click_sound()
	DecisionSystem.execute(decision_id)
	# stats_changed → deferred rebuild；这里主动排一次刷新兜底
	_request_refresh()


func _on_返回_pressed() -> void:
	音频总管.play_button_click_sound()
	get_tree().change_scene_to_file(DIPLOMACY_SCENE)
