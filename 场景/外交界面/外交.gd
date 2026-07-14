extends Node3D

## 外交（主游戏）场景逻辑。
## 节点结构（来自 外交.tscn）：
##   外交 (Node3D, 本脚本)
##     地球 (MeshInstance3D + territory_map.gd)
##     主游戏ui (实例化)
##     时间 (CanvasLayer)
##       时间背景
##       时间启停 (TextureButton, toggle_mode) → 控制 GameManager 播放/暂停
##       时间 (Label) → 显示当前日期
##       速度1~4 (ColorRect) → 速度档位指示灯
##       速度按钮1~4 (Button) → 切换速度档位
##     右侧栏 (CanvasLayer + 右侧栏.gd)
##     ESC菜单 (CanvasLayer + esc菜单.gd)

var ESC菜单_open: bool = false
var _resume_after_esc: bool = false
# 速度指示灯块（ColorRect 数组）
var _speed_blocks: Array[ColorRect] = []
const SPEED_BLOCK_ON := Color(0.92, 0.12, 0.12, 1.0)    # 亮红色
const SPEED_BLOCK_OFF := Color(0.18, 0.08, 0.08, 0.55)   # 暗红色

func _ready() -> void:
	# 始终处理，确保暂停时仍能接收 ESC 输入
	process_mode = Node.PROCESS_MODE_ALWAYS

	# 连接地球的国家选择信号 → GameManager
	var earth := get_node_or_null("地球")
	if earth and earth.has_signal("country_selected"):
		earth.country_selected.connect(_on_country_selected)

	# 连接时间启停按钮 → 切换播放/暂停
	var btn := get_node_or_null("时间/时间启停")
	if btn is TextureButton:
		btn.toggled.connect(_on_time_toggled)

	# 连接速度按钮
	_connect_speed_buttons()

	# 连接 GameManager 信号 → 刷新日期显示
	if GameManager:
		GameManager.date_changed.connect(_on_date_changed)
		GameManager.world_state_loaded.connect(_on_world_loaded)
		if GameManager.world != null:
			_on_world_loaded()
		_refresh_speed_indicator()

	# 连接事件通知信号 → 显示/隐藏提示弹窗
	if EventEngine:
		EventEngine.event_notification.connect(_on_event_notification)
		EventEngine.event_notification_dismissed.connect(_on_event_notification_dismissed)
		if EventEngine.pending_event_id != "":
			_on_event_notification(EventEngine.pending_event_id, "")

	# 连接通知按钮
	var notify_btn := get_node_or_null("提示弹窗/TextureButton")
	if notify_btn is TextureButton:
		notify_btn.pressed.connect(_on_event_notify_clicked)

# ── 国家选择 ──

func _on_country_selected(gwcode: int, _country_name: String) -> void:
	GameManager.select_country(gwcode)

# ── 时间控制 ──

func _on_time_toggled(button_pressed: bool) -> void:
	if button_pressed:
		GameManager.play()
		if GameManager.speed == 0:
			GameManager.set_speed(1)  # 默认正常速度（一秒一天）
			_refresh_speed_indicator()
	else:
		GameManager.pause()

# ── 速度档位 ──

func _connect_speed_buttons() -> void:
	_speed_blocks.clear()
	for i in range(1, 5):
		var block := get_node_or_null("时间/速度%d" % i)
		if block is ColorRect:
			_speed_blocks.append(block)
		var spd_btn := get_node_or_null("时间/速度按钮%d" % i)
		if spd_btn is Button:
			spd_btn.pressed.connect(_on_speed_pressed.bind(i))

func _on_speed_pressed(speed: int) -> void:
	GameManager.set_speed(speed)
	_refresh_speed_indicator()

func _refresh_speed_indicator() -> void:
	var current := GameManager.speed if GameManager else 0
	for i in _speed_blocks.size():
		_speed_blocks[i].color = SPEED_BLOCK_ON if (i + 1) <= current else SPEED_BLOCK_OFF



# ── 日期显示 ──

func _on_world_loaded() -> void:
	if GameManager.world:
		_refresh_date(GameManager.world.date)

func _on_date_changed(date: GameDate) -> void:
	_refresh_date(date)

func _refresh_date(date: GameDate) -> void:
	var lbl := get_node_or_null("时间/时间")
	if lbl is Label:
		lbl.text = date.format()

# ── ESC 菜单 ──

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if ESC菜单_open:
			ESC菜单_open = false
			get_tree().paused = false
			$ESC菜单.hide()
			if _resume_after_esc:
				GameManager.play()
			_resume_after_esc = false
		else:
			ESC菜单_open = true
			_resume_after_esc = GameManager.is_playing
			GameManager.pause()
			get_tree().paused = true
			$ESC菜单.show()
		return
	# 调试：按 F9 触发「五不准」事件测试（仅调试构建）
	if OS.is_debug_build() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		_trigger_test_event()


# ── 事件通知弹窗 ──

func _on_event_notification(event_id: String, _title: String) -> void:
	# 确保游戏继续运行（不暂停），让倒计时 ticking
	print("外交: 收到事件通知 %s" % event_id)
	var popup := get_node_or_null("提示弹窗")
	if popup:
		popup.visible = true


func _on_event_notification_dismissed() -> void:
	var popup := get_node_or_null("提示弹窗")
	if popup:
		popup.visible = false


func _on_event_notify_clicked() -> void:
	if EventEngine:
		EventEngine.accept_pending()


# ── 调试：事件触发 ──

func _trigger_test_event() -> void:
	if GameManager.world == null:
		return
	# 临时给足资源用于测试
	GameManager.world.set_data_value("agents", 300)
	GameManager.world.set_data_value("money", 300)
	# 直接启动即时事件
	GameManager.start_event("korea_unification")
