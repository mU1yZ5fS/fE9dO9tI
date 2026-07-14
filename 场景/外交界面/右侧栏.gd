extends CanvasLayer

## 右侧栏逻辑 — 只负责展开/收回动画。
## 右侧栏是新加功能，原版没有。具体内容待设计。

func _on_右侧栏展开按钮_pressed() -> void:
	$右侧栏展开按钮.hide()
	$右侧栏收回按钮.show()
	$右侧栏展开后背景.show()
	音频总管.play_button_click_sound()

func _on_右侧栏收回按钮_pressed() -> void:
	$右侧栏收回按钮.hide()
	$右侧栏展开后背景.hide()
	$右侧栏展开按钮.show()
	音频总管.play_button_click_sound()
