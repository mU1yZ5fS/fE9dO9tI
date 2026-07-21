extends Control

## 保存界面：5 槽（0=成就/铁人位，1–4=普通）。布局见 保存.tscn。

const DIPLO_SCENE := "uid://vq6jexkk5tru"
const MENU_SCENE := "uid://bydan4iqthbaa"

## 节点名 → 槽号（与原作 number：成就位≈5 → 我们用 0）
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
	_info_label = get_node_or_null("保存文本") as Label
	_wire_slots()
	_refresh_all()
	if _selected_slot < 0:
		_select_slot(1)


func _wire_slots() -> void:
	for node_name in SLOT_NODES.keys():
		var btn := get_node_or_null(node_name) as BaseButton
		if btn == null:
			continue
		var slot: int = int(SLOT_NODES[node_name])
		if not btn.pressed.is_connected(_on_slot_pressed):
			btn.pressed.connect(_on_slot_pressed.bind(slot))


func _on_slot_pressed(slot: int) -> void:
	音频总管.play_button_click_sound()
	_select_slot(slot)
	# 有活动局则直接写入该槽（对齐原作点槽即存）
	if GameManager and GameManager.world != null:
		_do_save(slot)


func _select_slot(slot: int) -> void:
	_selected_slot = slot
	_refresh_info()


func _do_save(slot: int) -> void:
	if GameManager == null or GameManager.world == null:
		_set_info("没有活动中的游戏，无法保存。\n请从主菜单开始新局后再存档。")
		return
	# 成就槽 meta 标铁人（原作成就位）；不改运行时 world.is_ironman
	var iron_ov := 1 if slot == 0 else 0
	var ok := GameManager.save_to_slot(slot, iron_ov)
	if ok:
		_set_info("已保存到槽位 %d\n\n%s" % [slot + 1, SaveCatalog.format_opis(slot)])
	else:
		_set_info("保存失败（槽位 %d）" % (slot + 1))
	_refresh_all()


func _refresh_all() -> void:
	for node_name in SLOT_NODES.keys():
		var btn := get_node_or_null(node_name) as Button
		if btn == null:
			continue
		var slot: int = int(SLOT_NODES[node_name])
		var meta: Dictionary = SaveCatalog.get_slot_meta(slot)
		var exists: bool = SaveCatalog.slot_exists(slot)
		if exists:
			var y := int(meta.get("year", 0))
			var mo := int(meta.get("month", 0))
			var d := int(meta.get("day", 0))
			if y > 0:
				btn.text = "%d.%d.%d" % [y, mo, d]
			else:
				btn.text = "有存档"
		else:
			btn.text = "空槽 %d" % (slot + 1)
	_refresh_info()


func _refresh_info() -> void:
	if _selected_slot < 0:
		_set_info("选择一个存档槽。\n有活动游戏时点击槽位将立即保存。")
		return
	_set_info(SaveCatalog.format_opis(_selected_slot))


func _set_info(text: String) -> void:
	if _info_label:
		_info_label.text = text


func _on_返回主菜单_pressed() -> void:
	音频总管.play_button_click_sound()
	var target := MENU_SCENE
	if GameManager and GameManager.save_return_scene != "":
		target = GameManager.save_return_scene
	# 有活动局默认回外交，避免丢局
	if GameManager and GameManager.world != null and target == MENU_SCENE:
		target = DIPLO_SCENE
	get_tree().change_scene_to_file(target)
