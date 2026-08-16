extends Control

const CAT = preload("res://数据脚本/achievement_catalog.gd")

@onready var _ach_mask: ColorRect = $成就遮罩
@onready var _ach_popup: PopupPanel = $成就弹窗
@onready var _ach_list: VBoxContainer = $成就弹窗/布局/列表滚动/成就列表
@onready var _ach_count: Label = $成就弹窗/布局/标题栏/计数

const COLOR_UNLOCKED := Color(0.13, 0.5, 0.16, 1)
const COLOR_LOCKED := Color(0.5, 0.5, 0.5, 1)


func _ready() -> void:
	_ach_mask.gui_input.connect(_on_成就遮罩_gui_input)
	_refresh_achievement_rows()


func _on_退出_pressed() -> void:
	#退出游戏
	get_tree().quit()
	音频总管.play_button_click_sound()


func _on_关于_pressed() -> void:
	#跳转到关于场景
	get_tree().change_scene_to_file("uid://cb1wvmuscp64r")
	音频总管.play_button_click_sound()


func _on_设置_pressed() -> void:
	#跳转到设置场景
	GameManager.settings_return_scene = "uid://bydan4iqthbaa"
	get_tree().change_scene_to_file("uid://b6l0sieu63sgv")
	音频总管.play_button_click_sound()


func _on_成就_pressed() -> void:
	音频总管.play_button_click_sound()
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
	音频总管.play_button_click_sound()


func _refresh_achievement_rows() -> void:
	_ach_count.text = "%d/%d" % [CAT.unlocked_count(), CAT.LIST.size()]
	for child in _ach_list.get_children():
		child.queue_free()
	for item in CAT.LIST:
		_ach_list.add_child(_make_row(int(item["number"]), String(item["title"]), String(item["desc"])))


func _make_row(number: int, title: String, desc: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.custom_minimum_size = Vector2(0, 56)

	var unlocked: bool = Achievements.is_unlocked(number)

	var status := Label.new()
	status.custom_minimum_size = Vector2(110, 0)
	status.add_theme_font_size_override("font_size", 26)
	status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status.add_theme_color_override("font_color", COLOR_UNLOCKED if unlocked else COLOR_LOCKED)
	status.text = "已解锁" if unlocked else "未解锁"

	var title_label := Label.new()
	title_label.custom_minimum_size = Vector2(150, 0)
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color(0, 0, 0, 1) if unlocked else COLOR_LOCKED)
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
	return row


func _on_开始游戏_pressed() -> void:
	#创建新游戏 → 跳转到外交场景(优先用启动加载屏预热好的 PackedScene,无缝进场)
	# 难度沿用设置界面的持久化值（原作 GameState.diff 由 PlayerPrefs our_diff_in 覆盖）。
	GameManager.new_game(710, GameManager.difficulty_setting)
	if GameManager.cached_diplomacy_scene is PackedScene:
		get_tree().change_scene_to_packed(GameManager.cached_diplomacy_scene)
	else:
		get_tree().change_scene_to_file("uid://vq6jexkk5tru")
	音频总管.play_button_click_sound()


func _on_加载_pressed() -> void:
	#跳转到加载场景
	if GameManager:
		GameManager.save_return_scene = "uid://bydan4iqthbaa"
	get_tree().change_scene_to_file("uid://b1x75pv02eanc")
	音频总管.play_button_click_sound()
