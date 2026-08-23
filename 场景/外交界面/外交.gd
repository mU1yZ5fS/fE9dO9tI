extends Node3D

## 外交（主游戏）场景逻辑。
## 节点结构（来自 外交.tscn）：
##   外交 (Node3D, 本脚本)
##     地球 (MeshInstance3D + territory_map.gd)
##       战争图标 (Node3D + 战争图标管理.gd) → 37 个 Sprite3D 通用槽
##         （v2：按 war_icon_anchors.json 的参战国语义锚点动态定位；点击仅高亮选国）
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
## 可互动国家全量扫描开销较大（逐国构建外交动作），最高速度下不能每 tick 刷新；
## 改为低频周期刷新，打开弹窗和关键事件时仍可强制即时刷新。
const INTERACTIVE_REFRESH_INTERVAL := 1.0
var _interactive_refresh_timer := 0.0


func _ready() -> void:
	# 始终处理，确保暂停时仍能接收 ESC 输入
	process_mode = Node.PROCESS_MODE_ALWAYS

	# 防止从事件/子界面返回时残留全局暂停（ESC菜单→事件等路径）
	if get_tree() != null:
		get_tree().paused = false

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

	# 可互动国家提示（点击时即时刷新，避免每次数值变化全量扫描）
	var inter_btn := get_node_or_null("预警图标/可互动国家按钮") as Button
	if inter_btn and not inter_btn.pressed.is_connected(_on_interactive_countries_pressed):
		inter_btn.pressed.connect(_on_interactive_countries_pressed)
	var close_btn := get_node_or_null("预警图标/可互动国家弹窗/关闭") as Button
	if close_btn and not close_btn.pressed.is_connected(_close_interactive_popup):
		close_btn.pressed.connect(_close_interactive_popup)
	var item_list := get_node_or_null("预警图标/可互动国家弹窗/可互动国家列表") as ItemList
	if item_list and not item_list.item_activated.is_connected(_on_interactive_country_item_activated):
		item_list.item_activated.connect(_on_interactive_country_item_activated)
	_refresh_interactive_countries()

	# 战争图标 v2：点击图标只高亮参战国（不切场景、不弹文本面板）。
	_connect_war_icon_click()


func _process(delta: float) -> void:
	# 可互动国家扫描开销大，改为低频刷新，避免最高速度下每 tick 全量构建外交动作。
	_interactive_refresh_timer -= delta
	if _interactive_refresh_timer <= 0.0:
		_interactive_refresh_timer = INTERACTIVE_REFRESH_INTERVAL
		if GameManager != null and GameManager.world != null:
			_refresh_interactive_countries()


# ── 可互动国家提示 ──

func _close_interactive_popup() -> void:
	var popup := get_node_or_null("预警图标/可互动国家弹窗") as Panel
	if popup:
		popup.visible = false

func _refresh_interactive_countries(_unused = null) -> void:
	var btn := get_node_or_null("预警图标/可互动国家按钮") as Button
	if btn == null:
		return
	_interactive_countries.clear()
	var w: WorldState = GameManager.world if GameManager else null
	if w != null:
		var live_gw := _collect_live_gwcodes()
		var panel := get_node_or_null("国家面板")
		if panel != null and panel.has_method("_build_actions_v2"):
			for country in w.countries:
				if country == null:
					continue
				# 只提示当前确实存在于地图上/已经通过事件激活的国家。
				# 9000+ 的库尔德斯坦二号、魁北克、南墨西哥、北爱尔兰等，
				# 以及尚无初始地块的纳米比亚等，必须在 parts/地图归属激活后才进入列表。
				if not _country_is_live(country, live_gw):
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


func _collect_live_gwcodes() -> Dictionary:
	var live := {}
	var owners: Dictionary = GameManager.cached_region_owner if GameManager else {}
	for r_id in owners:
		var gw := int(owners[r_id])
		if gw > 0:
			live[gw] = true
	return live


func _country_is_live(country: CountryData, live_gw: Dictionary) -> bool:
	if country == null:
		return false
	# 地图缓存尚未就绪时退化为旧行为：真实地图国家放行，幽灵国家仍看 parts。
	if live_gw.is_empty() and country.gwcode > 0 and country.gwcode < 9000:
		return true
	if live_gw.has(country.gwcode):
		return true
	# 事件建立的幽灵国家先通过 parts 标记激活，再交给 MapService 转移地图地块。
	for p in country.parts:
		if p:
			return true
	return false


func _action_available(action: Dictionary) -> bool:
	var conditions: Array = action.get("conditions", [])
	for cond in conditions:
		if cond is Dictionary and cond.has("check"):
			var check: Callable = cond["check"]
			if not check.call():
				return false
	return true


func _on_interactive_countries_pressed() -> void:
	_refresh_interactive_countries()
	var popup := get_node_or_null("预警图标/可互动国家弹窗") as Panel
	var item_list := get_node_or_null("预警图标/可互动国家弹窗/可互动国家列表") as ItemList
	if popup == null or item_list == null:
		return
	item_list.clear()
	for country in _interactive_countries:
		item_list.add_item(country.display_name())
	popup.visible = true


func _on_interactive_country_item_activated(index: int) -> void:
	if index < 0 or index >= _interactive_countries.size():
		return
	var country: CountryData = _interactive_countries[index]
	var popup := get_node_or_null("预警图标/可互动国家弹窗") as Panel
	if popup:
		popup.visible = false
	var panel := get_node_or_null("国家面板")
	if panel != null and panel.has_method("_on_country_selected"):
		panel._on_country_selected(country.gwcode, country.display_name())
	_focus_country(country.gwcode)


# ── 国家选择 ──

func _on_country_selected(gwcode: int, _country_name: String) -> void:
	GameManager.select_country(gwcode)
	# 正常点选国家不自动跳镜头，避免玩家只是想选国研究/操作时视角被拉走；
	# 只有从“可互动国家”弹窗点选时才跳转（见 _on_interactive_country_item_activated）。


## 点击/选择国家后把镜头转到该国质心（首都/几何中心均可，这里用地图质心）。
func _focus_country(gwcode: int) -> void:
	var earth := get_node_or_null("地球")
	if earth == null or not earth.has_method("country_centroid") or not earth.has_method("latlon_to_sphere_pos"):
		return
	var ll: Vector2 = earth.country_centroid(gwcode)
	if ll.x == INF or ll.y == INF:
		return
	var point: Vector3 = earth.latlon_to_sphere_pos(ll.x, ll.y, 0.501)
	var pivot := get_node_or_null("相机枢轴")
	if pivot != null and pivot.has_method("focus_on_sphere_point"):
		pivot.focus_on_sphere_point(point)


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


# ============================================================================
# 战争图标 v2：点击图标只高亮参战国（不切场景、不弹文本面板）
# ============================================================================

func _connect_war_icon_click() -> void:
	var icons := get_node_or_null("地球/战争图标")
	if icons == null:
		return
	if icons.has_signal("war_icon_clicked") 			and not icons.war_icon_clicked.is_connected(_on_war_icon_clicked):
		icons.war_icon_clicked.connect(_on_war_icon_clicked)


func _on_war_icon_clicked(info: Dictionary) -> void:
	var earth := get_node_or_null("地球")
	if earth != null and earth.has_method("highlight_country"):
		earth.highlight_country(int(info.get("a_gw", 0)))
