extends Control

## 保存界面：5 槽（0=成就/铁人位，1–4=普通）。布局见 保存.tscn。
## 交互对齐原作 Savescript.cs：悬停显示 Opis、移出清空、点槽立即写档。

const DIPLO_SCENE := "uid://vq6jexkk5tru"
const MENU_SCENE := "uid://bydan4iqthbaa"

## 节点名 → 槽号（与原作 number：成就位 5 → 本端口 0）
const SLOT_NODES := {
	"成就存档位": 0,
	"无成就存档位1": 1,
	"无成就存档位2": 2,
	"无成就存档位3": 3,
	"无成就存档位4": 4,
}

var _info_label: Label


func _ready() -> void:
	if GameManager:
		UISettings.apply_font_scale(self, GameManager.ui_font_scale)
	SaveCatalog.ensure_dir()
	_info_label = get_node_or_null("保存文本") as Label
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
	_do_save(slot)


## 原作 Savescript.OnMouseEnter：槽位按钮悬停时在 Opis 显示该槽信息。
func _on_slot_hover(slot: int) -> void:
	_set_info(SaveCatalog.format_opis(slot))


## 原作 Savescript.OnMouseExit：移出时清空 Opis。
func _on_slot_exit(_slot: int) -> void:
	_set_info("")


func _do_save(slot: int) -> void:
	if GameManager == null or GameManager.world == null:
		_set_info("没有活动中的游戏，无法保存。\n请从主菜单开始新局后再存档。")
		return
	# 原作 Savescript.OnMouseDown：number==5 写当前 iron_and_blood，其余槽写 False；
	# Godot 侧 world.is_ironman 由开局难度推导（difficulty>=2），meta 同步该值。
	var iron_ov: int = 1 if (slot == 0 and GameManager.world.is_ironman) else 0
	var ok: bool = GameManager.save_to_slot(slot, iron_ov)
	# 原作保存成功后 Opis 只写「 已 保 存」
	if ok:
		_set_info(" 已 保 存")
	else:
		_set_info("保存失败（槽位 %d）" % (slot + 1))


func _set_info(text: String) -> void:
	if _info_label:
		_info_label.text = text


func _on_返回主菜单_pressed() -> void:
	var target := MENU_SCENE
	if GameManager and GameManager.save_return_scene != "":
		target = GameManager.save_return_scene
	# 有活动局默认回外交，避免丢局（原作 Save.unity Exit → Diplomacy）
	if GameManager and GameManager.world != null and target == MENU_SCENE:
		target = DIPLO_SCENE
	get_tree().change_scene_to_file(target)
