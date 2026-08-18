extends Node3D

## 外交（主游戏）场景逻辑。
## 节点结构（来自 外交.tscn）：
##   外交 (Node3D, 本脚本)
##     地球 (MeshInstance3D + territory_map.gd)
##       战争图标 (Node3D + 战争图标管理.gd) → 36 个 Sprite3D 战争小图标
##     主游戏ui (实例化)
##     时间 (CanvasLayer)
##       时间背景
##       时间启停 (TextureButton, toggle_mode) → 控制 GameManager 播放/暂停
##       时间 (Label) → 显示当前日期
##       速度1~4 (ColorRect) → 速度档位指示灯
##       速度按钮1~4 (Button) → 切换速度档位
##     右侧栏 (CanvasLayer + 右侧栏.gd)
##     预警图标 (CanvasLayer)
##       科研未研究提示 (TextureRect) → 原版 alarmIcons[0]
##       阴谋临近提示 (TextureRect) → 原版 alarmIcons[1]
##     ESC菜单 (CanvasLayer + esc菜单.gd)

var ESC菜单_open: bool = false
var _resume_after_esc: bool = false
# 时间启停按钮引用（快捷键切换后同步按压态）
var _time_toggle_btn: TextureButton = null
# 速度指示灯块（ColorRect 数组）
var _speed_blocks: Array[ColorRect] = []
const SPEED_BLOCK_ON := Color(0.92, 0.12, 0.12, 1.0)    # 亮红色
const SPEED_BLOCK_OFF := Color(0.18, 0.08, 0.08, 0.55)   # 暗红色
# 原版 Diplomacy.unity alarmIcons[0]/[1] 的 OkoshkoScript.text_en 文案
const 科研未研究提示文本 := "<color=red>研究完成</color>. 前往科学界面并点击任意科技图标继续"
const 阴谋临近提示文本 := "<color=red>有针对你的阴谋</color>. 提升党内支持度,政客的忠诚度,要不然干脆开始调查或清除惹麻烦的政客."
const 政治局缺人提示文本 := "<color=red>政治局缺人</color>. 有中央三职或主管职位空缺，请前往政治界面任命."
# 预警图标点击跳转目标（复用状态栏场景 UID）
const 科研场景 := "uid://d2qkifpx3o8pl"
const 政治场景 := "uid://dsmslhxc0e8u5"

# 可互动国家提示缓存
var _interactive_countries: Array[CountryData] = []
var _interactive_popup: Panel = null
var _interactive_list: VBoxContainer = null

func _ready() -> void:
	# 始终处理，确保暂停时仍能接收 ESC 输入
	process_mode = Node.PROCESS_MODE_ALWAYS

	# 标记外交场景已激活 —— GameManager 仅在此期间推进时间
	if GameManager:
		GameManager.is_diplomacy_active = true

	# 连接地球的国家选择信号 → GameManager
	var earth := get_node_or_null("地球")
	if earth and earth.has_signal("country_selected"):
		earth.country_selected.connect(_on_country_selected)

	# 连接时间启停按钮 → 切换播放/暂停
	var btn := get_node_or_null("时间/时间启停")
	if btn is TextureButton:
		_time_toggle_btn = btn
		btn.toggled.connect(_on_time_toggled)
		# 按钮状态与 GameManager.is_playing 同步（从子界面返回时恢复原播放状态）
		btn.set_pressed_no_signal(GameManager.is_playing if GameManager else false)

	# 连接速度按钮
	_connect_speed_buttons()

	# 连接 GameManager 信号 → 刷新日期显示
	if GameManager:
		GameManager.date_changed.connect(_on_date_changed)
		GameManager.world_state_loaded.connect(_on_world_loaded)
		if not GameManager.tech_completed.is_connected(_on_tech_completed):
			GameManager.tech_completed.connect(_on_tech_completed)
		if GameManager.world != null:
			_on_world_loaded()

	# 预警图标：挂 BbcTooltip 悬浮提示 + 按当前世界状态刷新可见性
	_setup_alert_icons()
	_refresh_alert_icons()
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

	# 事件缩小时显示“继续事件”按钮
	_refresh_resume_event_button()

	# 可互动国家提示（点击时即时刷新，避免每次数值变化全量扫描）
	_create_interactive_countries_ui()
	_refresh_interactive_countries()

# ── 可互动国家提示 ──

func _create_interactive_countries_ui() -> void:
	var layer := get_node_or_null("预警图标") as CanvasLayer
	if layer == null:
		return
	if not layer.has_node("可互动国家按钮"):
		var btn := Button.new()
		btn.name = "可互动国家按钮"
		btn.text = "可互动国家（0）"
		btn.position = Vector2(24, 140)
		btn.pressed.connect(_on_interactive_countries_pressed)
		layer.add_child(btn)
	if _interactive_popup == null:
		_interactive_popup = Panel.new()
		_interactive_popup.name = "可互动国家弹窗"
		_interactive_popup.position = Vector2(24, 180)
		_interactive_popup.size = Vector2(360, 520)
		_interactive_popup.visible = false
		layer.add_child(_interactive_popup)
		var scroll := ScrollContainer.new()
		scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
		scroll.offset_bottom = -32.0
		_interactive_popup.add_child(scroll)
		_interactive_list = VBoxContainer.new()
		_interactive_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(_interactive_list)
		var close_btn := Button.new()
		close_btn.text = "关闭"
		close_btn.position = Vector2(292, 6)
		close_btn.pressed.connect(func() -> void: _interactive_popup.visible = false)
		_interactive_popup.add_child(close_btn)


func _refresh_interactive_countries(_unused = null) -> void:
	var btn := get_node_or_null("预警图标/可互动国家按钮") as Button
	if btn == null:
		return
	_interactive_countries.clear()
	var w: WorldState = GameManager.world if GameManager else null
	if w != null:
		var panel := get_node_or_null("国家面板")
		if panel != null and panel.has_method("_build_actions_v2"):
			for country in w.countries:
				if country == null:
					continue
				var actions: Array = panel._build_actions_v2(country)
				var has_available := false
				for action in actions:
					if action is Dictionary and _action_available(action):
						has_available = true
						break
				if has_available:
					_interactive_countries.append(country)
	btn.text = "可互动国家（%d）" % _interactive_countries.size()


func _action_available(action: Dictionary) -> bool:
	var conditions: Array = action.get("conditions", [])
	for cond in conditions:
		if cond is Dictionary and cond.has("check"):
			var check: Callable = cond["check"]
			if not check.call():
				return false
	return true


func _on_interactive_countries_pressed() -> void:
	音频总管.play_button_click_sound()
	_refresh_interactive_countries()
	if _interactive_list == null:
		return
	for child in _interactive_list.get_children():
		child.queue_free()
	for country in _interactive_countries:
		var b := Button.new()
		b.text = country.display_name()
		b.pressed.connect(_on_interactive_country_pressed.bind(country))
		_interactive_list.add_child(b)
	if _interactive_popup:
		_interactive_popup.visible = true


func _on_interactive_country_pressed(country: CountryData) -> void:
	if _interactive_popup:
		_interactive_popup.visible = false
	var panel := get_node_or_null("国家面板")
	if panel != null and panel.has_method("_on_country_selected"):
		panel._on_country_selected(country.gwcode, country.display_name())


# ── 事件缩小恢复 ──

## 事件场景点“缩小查看地图”后回到外交，这里显示继续按钮；正常完成事件后自动隐藏。
func _refresh_resume_event_button() -> void:
	var layer := get_node_or_null("预警图标") as CanvasLayer
	if layer == null:
		return
	var btn := layer.get_node_or_null("继续事件按钮") as Button
	var should_show := GameManager != null and GameManager.current_event_id != "" \
			and GameManager.current_ending_id < 0
	if should_show:
		if btn == null:
			btn = Button.new()
			btn.name = "继续事件按钮"
			btn.text = "继续事件"
			btn.position = Vector2(24, 96)
			btn.pressed.connect(_on_resume_event_pressed)
			layer.add_child(btn)
		btn.visible = true
	elif btn != null:
		btn.visible = false


func _on_resume_event_pressed() -> void:
	音频总管.play_button_click_sound()
	get_tree().change_scene_to_file("uid://bheujwt4qte1y")

# ── 国家选择 ──

func _on_country_selected(gwcode: int, _country_name: String) -> void:
	GameManager.select_country(gwcode)


## 离开外交场景时清除激活标记，停止时间流动
func _exit_tree() -> void:
	if GameManager:
		GameManager.is_diplomacy_active = false

# ── 时间控制 ──

func _on_time_toggled(button_pressed: bool) -> void:
	if button_pressed:
		GameManager.play()
		if GameManager.speed == 0:
			GameManager.set_speed(1)  # 默认正常速度（原版 speed=4，两秒一天）
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


## 时间控制快捷键（动作由 GameManager 在启动时注册，默认 空格=播放/暂停、1~4=速度档）。
## 用 _unhandled_input：GUI 按钮消费按键时不再响应，与地图/相机输入同一约定。
func _unhandled_input(event: InputEvent) -> void:
	if ESC菜单_open:
		return
	if event is InputEventKey and event.is_echo():
		return
	if event.is_action_pressed("toggle_time"):
		GameManager.toggle_play()
		_sync_time_controls()
	elif event.is_action_pressed("speed_1"):
		GameManager.set_speed(1)
		_refresh_speed_indicator()
	elif event.is_action_pressed("speed_2"):
		GameManager.set_speed(2)
		_refresh_speed_indicator()
	elif event.is_action_pressed("speed_3"):
		GameManager.set_speed(3)
		_refresh_speed_indicator()
	elif event.is_action_pressed("speed_4"):
		GameManager.set_speed(4)
		_refresh_speed_indicator()


## 播放/暂停状态变化后，按钮按压态与速度指示灯一起刷新。
func _sync_time_controls() -> void:
	if _time_toggle_btn:
		_time_toggle_btn.set_pressed_no_signal(GameManager.is_playing if GameManager else false)
	_refresh_speed_indicator()


func _refresh_speed_indicator() -> void:
	var current: int = GameManager.speed if GameManager else 0
	for i in _speed_blocks.size():
		_speed_blocks[i].color = SPEED_BLOCK_ON if (i + 1) <= current else SPEED_BLOCK_OFF



# ── 日期显示 ──

func _on_world_loaded() -> void:
	if GameManager.world:
		_refresh_date(GameManager.world.date)
	_refresh_alert_icons()
	_refresh_interactive_countries()

func _on_date_changed(date: GameDate) -> void:
	_refresh_date(date)
	_refresh_alert_icons()
	_refresh_interactive_countries()

func _refresh_date(date: GameDate) -> void:
	var lbl := get_node_or_null("时间/时间")
	if lbl is Label:
		lbl.text = date.format()


# ── 预警图标（原版 TimeScript alarmIcons[0]/[1]） ──

func _setup_alert_icons() -> void:
	var science := get_node_or_null("预警图标/科研未研究提示") as Control
	if science:
		science.tooltip_text = 科研未研究提示文本
		BbcTooltip.attach(science)
		science.mouse_filter = Control.MOUSE_FILTER_STOP
		if not science.gui_input.is_connected(_on_alert_icon_input.bind(科研场景)):
			science.gui_input.connect(_on_alert_icon_input.bind(科研场景))
	var plot := get_node_or_null("预警图标/阴谋临近提示") as Control
	if plot:
		plot.tooltip_text = 阴谋临近提示文本
		BbcTooltip.attach(plot)
		plot.mouse_filter = Control.MOUSE_FILTER_STOP
		if not plot.gui_input.is_connected(_on_alert_icon_input.bind(政治场景)):
			plot.gui_input.connect(_on_alert_icon_input.bind(政治场景))
	var politburo := get_node_or_null("预警图标/政治局缺人提示") as Control
	if politburo:
		politburo.tooltip_text = 政治局缺人提示文本
		BbcTooltip.attach(politburo)
		politburo.mouse_filter = Control.MOUSE_FILTER_STOP
		if not politburo.gui_input.is_connected(_on_alert_icon_input.bind(政治场景)):
			politburo.gui_input.connect(_on_alert_icon_input.bind(政治场景))


func _on_alert_icon_input(event: InputEvent, scene_uid: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		音频总管.play_button_click_sound()
		get_tree().change_scene_to_file(scene_uid)


func _refresh_alert_icons() -> void:
	var science := get_node_or_null("预警图标/科研未研究提示") as CanvasItem
	if science:
		science.visible = GameManager.science_alert_active() if GameManager else false
	var plot := get_node_or_null("预警图标/阴谋临近提示") as CanvasItem
	if plot:
		plot.visible = GameManager.plot_alert_active() if GameManager else false
	var politburo := get_node_or_null("预警图标/政治局缺人提示") as CanvasItem
	if politburo:
		politburo.visible = GameManager.political_bureau_vacancy_alert_active() if GameManager else false


func _on_tech_completed(_tech_id: int) -> void:
	_refresh_alert_icons()


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
