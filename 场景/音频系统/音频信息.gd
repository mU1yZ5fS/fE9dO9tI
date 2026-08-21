extends TextureRect

## 音量面板：原作 Settings.unity 的 AudioScript（滑条）+ VoiceSciptr（±1/±10 按钮）。
## voice 是 0-100 整数，显示不带 %（原版 text.text = voice.ToString()）。

@onready var 音量滑条 := get_node_or_null("音量滑条") as HSlider


func _ready() -> void:
	# 原版默认 voice_china=5；GameManager 启动时已从 user://settings.cfg 读取。
	if 音量滑条:
		音量滑条.min_value = 0.0
		音量滑条.max_value = 100.0
		音量滑条.step = 1.0
		音量滑条.value = float(_当前音量())
		音量滑条.value_changed.connect(_on_音量滑条_value_changed)
	音频总管.曲目变更.connect(_on_曲目变更)
	_on_曲目变更(音频总管.当前歌名())
	_refresh_volume_display()


func _当前音量() -> int:
	return GameManager.voice if GameManager else 5


# 当前播放的曲目变化时，更新「歌曲名」标签
func _on_曲目变更(歌名: String) -> void:
	$歌曲名.text = 歌名 if 歌名 != "" else "（暂无音乐）"


## 原版 VoiceSciptr.OnMouseDown：-1/-10 在 0 时回绕到 100，+1/+10 在 100 时回绕到 0。
func _change_voice(delta: int) -> void:
	var 当前: int = _当前音量()
	var 目标: int
	if delta < 0 and 当前 == 0:
		目标 = 100
	elif delta > 0 and 当前 == 100:
		目标 = 0
	else:
		目标 = clampi(当前 + delta, 0, 100)
	_set_voice(目标)


func _set_voice(value: int) -> void:
	if GameManager:
		GameManager.set_voice(value)
	音频总管.apply_voice()
	if 音量滑条 and int(音量滑条.value) != value:
		音量滑条.set_value_no_signal(value)
	_refresh_volume_display()


func _on_音量滑条_value_changed(value: float) -> void:
	_set_voice(clampi(int(round(value)), 0, 100))


func _refresh_volume_display() -> void:
	$音量值.text = str(_当前音量())


func _on_减小1音量_pressed() -> void:
	_change_voice(-1)


func _on_减小10音量_pressed() -> void:
	_change_voice(-10)


func _on_增大1音量_pressed() -> void:
	_change_voice(1)


func _on_增大10音量_pressed() -> void:
	_change_voice(10)
