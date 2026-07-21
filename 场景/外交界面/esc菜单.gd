extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_存档_pressed() -> void:
	#跳转到存档场景
	get_tree().paused = false
	if GameManager:
		GameManager.save_return_scene = "uid://vq6jexkk5tru"
	get_tree().change_scene_to_file("uid://wca05l6ymxge")
	音频总管.play_button_click_sound()


func _on_加载_pressed() -> void:
	#跳转到加载场景
	get_tree().paused = false
	if GameManager:
		GameManager.save_return_scene = "uid://vq6jexkk5tru"
	get_tree().change_scene_to_file("uid://b1x75pv02eanc")
	音频总管.play_button_click_sound()



func _on_设置_pressed() -> void:
	#跳转到设置场景
	GameManager.settings_return_scene = "uid://vq6jexkk5tru"
	get_tree().paused = false
	get_tree().change_scene_to_file("uid://b6l0sieu63sgv")
	音频总管.play_button_click_sound()



func _on_退出_pressed() -> void:
	#退出游戏
	get_tree().paused = false
	get_tree().quit()
