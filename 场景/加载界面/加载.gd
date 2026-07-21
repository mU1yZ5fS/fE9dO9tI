extends Control

## 加载界面：5 槽读取 / 删除。布局见 加载.tscn。

const DIPLO_SCENE := "uid://vq6jexkk5tru"
const MENU_SCENE := "uid://bydan4iqthbaa"

const SLOT_NODES := {
	"成就存档位": 0,
	"无成就存档位1": 1,
	"无成就存档位2": 2,
	"无成就存档位3": 3,
	"无成就存档位4": 4,
}

var _selected_slot: int = -1
var _info_label: Label


func _ready() -> void:
	SaveCatalog.ensure_dir()
	_info_label = get_node_or_null("加载文本") as Label
	_wire_slots()
	_ensure_action_buttons()
	_refresh_all()
	_select_first_existing()


func _wire_slots() -> void:
	for node_name in SLOT_NODES.keys():
		var btn := get_node_or_null(node_name) as BaseButton
		if btn == null:
			continue
		var slot: int = int(SLOT_NODES[node_name])
		if not btn.pressed.is_connected(_on_slot_pressed):
			btn.pressed.connect(_on_slot_pressed.bind(slot))


func _ensure_action_buttons() -> void:
	## 布局未放「加载/删除」时运行时补一排，避免纯点槽误操作
	if get_node_or_null("操作栏") != null:
		return
	var bar := HBoxContainer.new()
	bar.name = "操作栏"
	bar.offset_left = 720.0
	bar.offset_top = 960.0
	bar.offset_right = 1200.0
	bar.offset_bottom = 1020.0
	bar.add_theme_constant_override("separation", 16)
	add_child(bar)
	var load_btn := Button.new()
	load_btn.name = "确认加载"
	load_btn.text = "加载所选"
	load_btn.custom_minimum_size = Vector2(160, 48)
	load_btn.pressed.connect(_on_确认加载_pressed)
	bar.add_child(load_btn)
	var del_btn := Button.new()
	del_btn.name = "删除所选"
	del_btn.text = "删除所选"
	del_btn.custom_minimum_size = Vector2(160, 48)
	del_btn.pressed.connect(_on_删除所选_pressed)
	bar.add_child(del_btn)


func _on_slot_pressed(slot: int) -> void:
	音频总管.play_button_click_sound()
	_select_slot(slot)


func _select_slot(slot: int) -> void:
	_selected_slot = slot
	_refresh_info()


func _select_first_existing() -> void:
	for s in range(SaveCatalog.UI_SLOT_COUNT):
		if SaveCatalog.slot_exists(s):
			_select_slot(s)
			return
	_select_slot(1)


func _on_确认加载_pressed() -> void:
	音频总管.play_button_click_sound()
	if _selected_slot < 0:
		_set_info("请先选择存档槽。")
		return
	_load_from_slot(_selected_slot)


func _on_删除所选_pressed() -> void:
	音频总管.play_button_click_sound()
	if _selected_slot < 0:
		return
	if not SaveCatalog.slot_exists(_selected_slot):
		_set_info("槽位为空，无需删除。")
		return
	if GameManager:
		GameManager.delete_save_slot(_selected_slot)
	else:
		SaveCatalog.delete_slot(_selected_slot)
	_set_info("已删除槽位 %d" % (_selected_slot + 1))
	_refresh_all()


func _load_from_slot(slot: int) -> void:
	if not SaveCatalog.slot_exists(slot):
		_set_info("槽位 %d 为空，无法加载。" % (slot + 1))
		return
	if GameManager == null:
		return
	var ok := GameManager.load_from_slot(slot)
	if not ok or GameManager.world == null:
		_set_info("加载失败。")
		return
	print("加载: 槽位 %d 成功 %s" % [slot, GameManager.world.date.format() if GameManager.world.date else "?"])
	get_tree().change_scene_to_file(DIPLO_SCENE)


func _refresh_all() -> void:
	for node_name in SLOT_NODES.keys():
		var btn := get_node_or_null(node_name) as Button
		if btn == null:
			continue
		var slot: int = int(SLOT_NODES[node_name])
		var meta: Dictionary = SaveCatalog.get_slot_meta(slot)
		if SaveCatalog.slot_exists(slot):
			var y := int(meta.get("year", 0))
			var mo := int(meta.get("month", 0))
			var d := int(meta.get("day", 0))
			btn.text = "%d.%d.%d" % [y, mo, d] if y > 0 else "有存档"
			btn.disabled = false
		else:
			btn.text = "空槽 %d" % (slot + 1)
			btn.disabled = false
	_refresh_info()


func _refresh_info() -> void:
	if _selected_slot < 0:
		_set_info("选择存档后点「加载所选」。")
		return
	var extra := "\n\n点「加载所选」进入游戏，或「删除所选」。"
	_set_info(SaveCatalog.format_opis(_selected_slot) + extra)


func _set_info(text: String) -> void:
	if _info_label:
		_info_label.text = text


func _on_返回主菜单_pressed() -> void:
	音频总管.play_button_click_sound()
	var target := MENU_SCENE
	if GameManager and GameManager.save_return_scene != "":
		target = GameManager.save_return_scene
	get_tree().change_scene_to_file(target)


## 兼容旧连接名
func _on_删除_pressed(slot: int) -> void:
	_selected_slot = slot
	_on_删除所选_pressed()
