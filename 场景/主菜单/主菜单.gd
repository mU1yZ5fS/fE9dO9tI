extends Control

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



func _on_开始游戏_pressed() -> void:
	#创建新游戏 → 跳转到外交场景
	GameManager.new_game()
	get_tree().change_scene_to_file("uid://vq6jexkk5tru")
	音频总管.play_button_click_sound()


func _on_加载_pressed() -> void:
	#跳转到加载场景
	if GameManager:
		GameManager.save_return_scene = "uid://bydan4iqthbaa"
	get_tree().change_scene_to_file("uid://b1x75pv02eanc")
	音频总管.play_button_click_sound()
