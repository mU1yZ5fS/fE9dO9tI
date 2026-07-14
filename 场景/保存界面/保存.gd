extends Control

## 保存界面逻辑。
## .tscn 布局由你设计，这里只写信号响应逻辑。

const SAVE_DIR: String = "user://saves"
const MAX_SLOTS: int = 10
var _selected_slot: int = -1

func _ready() -> void:
	# 确保存档目录存在
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func _save_to_slot(slot: int) -> void:
	if GameManager.world == null:
		push_error("保存: 没有活动游戏")
		return
	var path := _slot_path(slot)
	GameManager.save_game(path)
	print("保存: 已保存到槽位 %d" % slot)

func _get_slot_info(slot: int) -> Dictionary:
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return {"exists": false, "date": "", "slot": slot}
	# 读取存档文件头获取日期信息
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"exists": false, "date": "", "slot": slot}
	# Resource 文件前几行包含日期字段
	var date_str := ""
	for i in 20:
		var line := file.get_line()
		if line.begins_with("date = "):
			# 尝试从内联 Resource 提取日期（启发式）
			pass
		if line.find("year = ") != -1:
			var year := _extract_int(line)
			date_str += str(year) + "年"
		if line.find("month = ") != -1:
			date_str += str(_extract_int(line)) + "月"
		if line.find("day = ") != -1:
			date_str += str(_extract_int(line)) + "日"
	file.close()
	return {"exists": true, "date": date_str if date_str else "未知", "slot": slot}

func _slot_path(slot: int) -> String:
	return SAVE_DIR + "/save_%02d.res" % slot

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

func _on_保存_pressed() -> void:
	if _selected_slot >= 0:
		_save_to_slot(_selected_slot)
