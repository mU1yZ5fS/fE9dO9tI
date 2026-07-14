extends Control

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://bydan4iqthbaa")
	音频总管.play_button_click_sound()
