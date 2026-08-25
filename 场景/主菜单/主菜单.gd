extends Control

const CAT = preload("res://数据脚本/achievement_catalog.gd")

const ACH_FRAME_TEX := preload("uid://byw8pr1qq7a4w")
const ACH_HANDLE_TEX := preload("uid://cx2p3gjuloxo5")
const UPDATE_POPUP_SCENE := preload("res://场景/主菜单/更新弹窗.tscn")

@onready var _ach_mask: ColorRect = $成就遮罩
@onready var _ach_popup: PopupPanel = $成就弹窗
@onready var _ach_list: VBoxContainer = $成就弹窗/布局/列表滚动/成就列表
@onready var _ach_count: Label = $成就弹窗/布局/标题栏/计数
@onready var _ach_scroll: ScrollContainer = $成就弹窗/布局/列表滚动

const COLOR_UNLOCKED := Color(0.13, 0.5, 0.16, 1)
const COLOR_LOCKED := Color(0.5, 0.5, 0.5, 1)
const COLOR_TITLE_GREEN := Color(0.1, 0.55, 0.2, 1)

var _row_style: StyleBoxTexture = null
var _update_popup: PopupPanel = null


func _ready() -> void:
	if GameManager:
		UISettings.apply_font_scale(self, GameManager.ui_font_scale)
	_ach_mask.gui_input.connect(_on_成就遮罩_gui_input)
	_style_scrollbar()
	_refresh_achievement_rows()


func _on_退出_pressed() -> void:
	#退出游戏
	get_tree().quit()


func _on_关于_pressed() -> void:
	#跳转到关于场景
	get_tree().change_scene_to_file("uid://cb1wvmuscp64r")


func _on_事件拓扑_pressed() -> void:
	#跳转到事件拓扑图（调试工具）
	get_tree().change_scene_to_file("res://场景/调试界面/event_graph_viewer.tscn")


func _on_设置_pressed() -> void:
	#跳转到设置场景
	GameManager.settings_return_scene = "uid://bydan4iqthbaa"
	get_tree().change_scene_to_file("uid://b6l0sieu63sgv")


func _on_成就_pressed() -> void:
	_refresh_achievement_rows()
	_ach_mask.visible = true
	# gdd_0706_Popup.md：Popup 默认不可见，用 Window 的 popup_centered() 显示
	_ach_popup.popup_centered()


func _on_成就关闭_pressed() -> void:
	_close_achievements()


func _on_成就遮罩_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_close_achievements()


func _close_achievements() -> void:
	if _ach_popup.visible:
		_ach_popup.hide()
	_ach_mask.visible = false


func _refresh_achievement_rows() -> void:
	_ach_count.text = "%d/%d" % [CAT.unlocked_count(), CAT.LIST.size()]
	for child in _ach_list.get_children():
		child.queue_free()
	var i := 0
	for item in CAT.LIST:
		var row := _make_row(int(item["number"]), String(item["title"]), String(item["desc"]))
		_ach_list.add_child(row)
		_animate_row(row, i)
		i += 1


func _style_scrollbar() -> void:
	if _ach_scroll == null:
		return
	var bar: VScrollBar = _ach_scroll.get_v_scroll_bar()
	if bar == null:
		return
	var handle := StyleBoxTexture.new()
	handle.texture = ACH_HANDLE_TEX
	bar.add_theme_stylebox_override("grabber", handle)
	# 让滚动条本身不显示默认的深色背景条，只保留手柄图片
	bar.add_theme_stylebox_override("grabber_area", StyleBoxEmpty.new())
	bar.add_theme_stylebox_override("track", StyleBoxEmpty.new())


func _row_stylebox() -> StyleBoxTexture:
	if _row_style == null:
		_row_style = StyleBoxTexture.new()
		_row_style.texture = ACH_FRAME_TEX
		_row_style.texture_margin_left = 14.0
		_row_style.texture_margin_top = 8.0
		_row_style.texture_margin_right = 14.0
		_row_style.texture_margin_bottom = 8.0
	return _row_style


func _make_row(number: int, title: String, desc: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _row_stylebox())
	panel.custom_minimum_size = Vector2(0, 80)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var unlocked: bool = Achievements.is_unlocked(number)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(56, 56)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = load(CAT.icon_path(number)) as Texture2D
	row.add_child(icon)

	var status := Label.new()
	status.custom_minimum_size = Vector2(110, 0)
	status.add_theme_font_size_override("font_size", 26)
	status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status.add_theme_color_override("font_color", COLOR_UNLOCKED if unlocked else COLOR_LOCKED)
	status.text = "已解锁" if unlocked else "未解锁"

	var title_label := Label.new()
	title_label.custom_minimum_size = Vector2(160, 0)
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", COLOR_TITLE_GREEN)
	title_label.text = title

	var desc_label := Label.new()
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 22)
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	desc_label.add_theme_color_override("font_color", Color(0, 0, 0, 1) if unlocked else COLOR_LOCKED)
	desc_label.text = desc

	row.add_child(status)
	row.add_child(title_label)
	row.add_child(desc_label)
	panel.add_child(row)
	return panel


## 成就列表行淡入动效：从上到下依次出现，避免一次性刷出来。
func _animate_row(row: CanvasItem, index: int) -> void:
	row.modulate.a = 0.0
	var tw := row.create_tween()
	if index > 0:
		tw.tween_interval(index * 0.03)
	tw.tween_property(row, "modulate:a", 1.0, 0.22) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_开始游戏_pressed() -> void:
	#创建新游戏 → 跳转到外交场景(优先用启动加载屏预热好的 PackedScene,无缝进场)
	# 难度沿用设置界面的持久化值（原作 GameState.diff 由 PlayerPrefs our_diff_in 覆盖）。
	GameManager.new_game(710, GameManager.difficulty_setting)
	if GameManager.cached_diplomacy_scene is PackedScene:
		get_tree().change_scene_to_packed(GameManager.cached_diplomacy_scene)
	else:
		get_tree().change_scene_to_file("uid://vq6jexkk5tru")


func _on_加载_pressed() -> void:
	#跳转到加载场景
	if GameManager:
		GameManager.save_return_scene = "uid://bydan4iqthbaa"
	get_tree().change_scene_to_file("uid://b1x75pv02eanc")


func _on_更新公告_pressed() -> void:
	if _update_popup == null:
		_update_popup = UPDATE_POPUP_SCENE.instantiate()
		add_child(_update_popup)
	_update_popup.open_update_popup()
