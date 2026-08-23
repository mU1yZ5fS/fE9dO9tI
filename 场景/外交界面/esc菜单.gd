extends CanvasLayer

## preload 而非 class_name 全局引用：新增全局类在未重建 .godot 类缓存时不可见。
const EndingSvc := preload("res://数据脚本/services/ending_service.gd")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	refresh_post_exit()


## 原版 CascadScrupt.cs:26-36 —— ESC 菜单（menu）在游戏年份 >= 1986 时显示
## PostExit（「结束」）按钮，点击走 in1992_script.cs 右按钮的「功成身退」判定。
func refresh_post_exit() -> void:
	var btn := get_node_or_null("结束") as Button
	if btn == null:
		return
	var show_btn := false
	if GameManager != null and GameManager.world != null and GameManager.world.date != null:
		show_btn = GameManager.world.date.year >= 1986
	btn.visible = show_btn


## 原版 PostExit 即 in1992_script.cs（is_left=false）右按钮：直接进入结局判定。
func _on_结束_pressed() -> void:
	if GameManager == null or GameManager.world == null:
		return
	var parent := get_parent()
	if parent != null and parent.has_method("close_esc_menu"):
		parent.close_esc_menu()
	else:
		get_tree().paused = false
	EndingSvc.end_after_1986_via_menu(GameManager.world, GameManager, EventEngine)


func _on_存档_pressed() -> void:
	#跳转到存档场景
	get_tree().paused = false
	if GameManager:
		GameManager.save_return_scene = "uid://vq6jexkk5tru"
	get_tree().change_scene_to_file("uid://wca05l6ymxge")


func _on_加载_pressed() -> void:
	#跳转到加载场景
	get_tree().paused = false
	if GameManager:
		GameManager.save_return_scene = "uid://vq6jexkk5tru"
	get_tree().change_scene_to_file("uid://b1x75pv02eanc")



func _on_设置_pressed() -> void:
	#跳转到设置场景
	GameManager.settings_return_scene = "uid://vq6jexkk5tru"
	get_tree().paused = false
	get_tree().change_scene_to_file("uid://b6l0sieu63sgv")



func _on_退出_pressed() -> void:
	# ESC 菜单的“退出”回到主菜单，不是退出游戏
	get_tree().paused = false
	if GameManager:
		GameManager.reset_map_runtime_state()
	get_tree().change_scene_to_file("uid://bydan4iqthbaa")
