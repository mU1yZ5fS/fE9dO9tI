extends Control

## 加载界面：5 槽读取。布局见 加载.tscn。
## 交互对齐原作 LoadInScript.cs：悬停显示 Opis、移出清空、点槽立即读档进外交。
## 原版 Load.unity 没有删除存档功能，因此本界面不提供删除（删除入口不存在 = 不新增冗余）。

const DIPLO_SCENE := "uid://vq6jexkk5tru"
const MENU_SCENE := "uid://bydan4iqthbaa"

const SLOT_NODES := {
	"成就存档位": 0,
	"无成就存档位1": 1,
	"无成就存档位2": 2,
	"无成就存档位3": 3,
	"无成就存档位4": 4,
}

var _info_label: Label


func _ready() -> void:
	SaveCatalog.ensure_dir()
	_info_label = get_node_or_null("加载文本") as Label
	_wire_slots()
	_set_info("")


func _wire_slots() -> void:
	for node_name in SLOT_NODES.keys():
		var btn := get_node_or_null(node_name) as BaseButton
		if btn == null:
			continue
		var slot: int = int(SLOT_NODES[node_name])
		if not btn.pressed.is_connected(_on_slot_pressed):
			btn.pressed.connect(_on_slot_pressed.bind(slot))
		if not btn.mouse_entered.is_connected(_on_slot_hover):
			btn.mouse_entered.connect(_on_slot_hover.bind(slot))
		if not btn.mouse_exited.is_connected(_on_slot_exit):
			btn.mouse_exited.connect(_on_slot_exit.bind(slot))


func _on_slot_pressed(slot: int) -> void:
	音频总管.play_button_click_sound()
	# 原作 LoadInScript.OnMouseDown：有档才动作，无档直接返回。
	if not SaveCatalog.slot_exists(slot):
		_set_info(" 空 档 位")
		return
	_load_from_slot(slot)


## 原作 LoadInScript.OnMouseEnter：在 Opis 显示槽位摘要（首行用「激活」措辞）。
func _on_slot_hover(slot: int) -> void:
	_set_info(SaveCatalog.format_opis(slot, {}, true))


## 原作 LoadInScript.OnMouseExit：移出时清空 Opis。
func _on_slot_exit(_slot: int) -> void:
	_set_info("")


func _load_from_slot(slot: int) -> void:
	if GameManager == null:
		return
	var ok: bool = GameManager.load_from_slot(slot)
	if not ok or GameManager.world == null:
		_set_info("加载失败。")
		return
	print("加载: 槽位 %d 成功 %s" % [slot, GameManager.world.date.format() if GameManager.world.date else "?"])
	# 原作 LoadInScript.cs:118 读档成功直接 LoadScene("Diplomacy")
	get_tree().change_scene_to_file(DIPLO_SCENE)


func _set_info(text: String) -> void:
	if _info_label:
		_info_label.text = text


func _on_返回主菜单_pressed() -> void:
	音频总管.play_button_click_sound()
	var target := MENU_SCENE
	if GameManager and GameManager.save_return_scene != "":
		target = GameManager.save_return_scene
	get_tree().change_scene_to_file(target)
