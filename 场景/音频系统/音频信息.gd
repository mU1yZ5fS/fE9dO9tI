extends TextureRect


func _ready() -> void:
	display_background_music_volume()
	音频总管.曲目变更.connect(_on_曲目变更)
	_on_曲目变更(音频总管.当前歌名())


# 当前播放的曲目变化时，更新「歌曲名」标签
func _on_曲目变更(歌名: String) -> void:
	$歌曲名.text = 歌名 if 歌名 != "" else "（暂无音乐）"


#获取背景音乐总线音频大小百分数值
func get_background_music_volume() -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index("背景音乐"))
#显示数值在 音频信息背景图/音量值
func display_background_music_volume() -> void:
	var db_value = get_background_music_volume()
	# 将分贝值转换为百分比（假设 -80dB ~ 0dB 对应 0% ~ 100%）
	var percent_value = 100.0 + db_value * (100.0 / 80.0)
	percent_value = clamp(percent_value, 0.0, 100.0)
	$音量值.text = str(percent_value) + "%"


func _on_减小1音量_pressed() -> void:
	var new_volume = max(get_background_music_volume() - 1.0, -80.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("背景音乐"), new_volume)
	display_background_music_volume()


func _on_减小10音量_pressed() -> void:
	var new_volume = max(get_background_music_volume() - 10.0, -80.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("背景音乐"), new_volume)
	display_background_music_volume()


func _on_增大1音量_pressed() -> void:
	var new_volume = min(get_background_music_volume() + 1.0, 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("背景音乐"), new_volume)
	display_background_music_volume()


func _on_增大10音量_pressed() -> void:
	var new_volume = min(get_background_music_volume() + 10.0, 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("背景音乐"), new_volume)
	display_background_music_volume()
