extends Control

## 加载界面逻辑。
## .tscn 布局由你设计，这里只写信号响应逻辑。

const SAVE_DIR: String = "user://saves"
const MAX_SLOTS: int = 10

func _ready() -> void:
	pass

func _load_from_slot(slot: int) -> void:
	var path := SAVE_DIR + "/save_%02d.res" % slot
	if not FileAccess.file_exists(path):
		push_error("加载: 槽位 %d 为空" % slot)
		return
	# 先加载数据，再切换场景
	GameManager.load_game(path)
	# 加载成功后切换到外交场景
	if GameManager.world != null:
		get_tree().change_scene_to_file("uid://vq6jexkk5tru")
		print("加载: 从槽位 %d 加载成功" % slot)

func _get_slot_info(slot: int) -> Dictionary:
	var path := SAVE_DIR + "/save_%02d.res" % slot
	if not FileAccess.file_exists(path):
		return {"exists": false, "date": "", "slot": slot}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"exists": false, "date": "", "slot": slot}
	var date_str := ""
	for i in 20:
		var line := file.get_line()
		if line.find("year = ") != -1:
			var y := _extract_int(line)
			date_str += str(y) + "年"
		if line.find("month = ") != -1 and date_str.ends_with("年"):
			date_str += str(_extract_int(line)) + "月"
		if line.find("day = ") != -1:
			date_str += str(_extract_int(line)) + "日"
	file.close()
	return {"exists": true, "date": date_str if date_str else "未知", "slot": slot}

func _slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_DIR + "/save_%02d.res" % slot)

func _extract_int(line: String) -> int:
	var parts := line.split("= ", false)
	if parts.size() >= 2:
		var s := parts[1].strip_edges()
		if s.is_valid_int():
			return s.to_int()
	return 0

func _on_返回主菜单_pressed() -> void:
	get_tree().change_scene_to_file("uid://bydan4iqthbaa")
	音频总管.play_button_click_sound()

func _on_删除_pressed(slot: int) -> void:
	var path := SAVE_DIR + "/save_%02d.res" % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("加载: 删除槽位 %d" % slot)
