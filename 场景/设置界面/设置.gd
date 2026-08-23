extends Control

@onready var 循环播放: TextureButton = $循环播放
@onready var 随机播放: TextureButton = $随机播放
@onready var 翻页按钮_右: TextureButton = get_node_or_null("专辑右翻页")
@onready var 翻页按钮_左: TextureButton = get_node_or_null("专辑左翻页")
@onready var 难度行: Control = get_node_or_null("难度行")
@onready var 难度值: Label = get_node_or_null("难度行/值")
@onready var 难度成就: Label = get_node_or_null("难度行/成就")
@onready var 自动保存值: Label = get_node_or_null("自动保存行/值")
@onready var 保存槽位值: Label = get_node_or_null("保存槽位行/值")
@onready var 窗口模式值: Label = get_node_or_null("窗口模式行/值")
@onready var 走时间快捷键值: Label = get_node_or_null("走时间快捷键行/值")
@onready var 速度1快捷键值: Label = get_node_or_null("速度1快捷键行/值")
@onready var 速度2快捷键值: Label = get_node_or_null("速度2快捷键行/值")
@onready var 速度3快捷键值: Label = get_node_or_null("速度3快捷键行/值")
@onready var 速度4快捷键值: Label = get_node_or_null("速度4快捷键行/值")

## 显示名逐字对齐原作 DiffScript.cs / Need_save.cs 的字符串（含原空格）。
const DIFF_NAMES := [" 沙 盒", " 上 山 下 乡", " 斗 私 批 修", " 造 反 有 理", " 浩 荡 文 革"]
const AUTOSAVE_NAMES := [" 不 自 动 保 存", " 每 月 自 动 保 存", " 半 年 自 动 保 存"]
const SAVEPLACE_NAMES := {
	5: " 成 就 激 活 档 位",
	1: " 无 成 就 壹 档",
	2: " 无 成 就 贰 档",
	3: " 无 成 就 叁 档",
	4: " 无 成 就 肆 档",
}
## 窗口模式行（原作无此功能，按主人要求新增）。
## 全屏⇄窗口两态；进入窗口化固定 1280×720，回到全屏仍用 exclusive fullscreen。
## Windows 端以独占全屏启动时，若"退出全屏要恢复的矩形"等于显示器分辨率，
## 会被系统立即弹回全屏（godotengine/godot issue 120283）。
## 因此 project.godot 的 window_width/height_override 必须与 WINDOWED_SIZE 保持一致，
## 它们就是退出全屏时的预存矩形；改本常量时必须同步 project.godot。
const WINDOW_MODE_NAMES := [" 窗 口 化", " 全 屏"]
const WINDOWED_SIZE := Vector2i(1280, 720)

## 时间控制快捷键行：[行节点名, InputMap 动作名]。
## 动作与默认键定义在 GameManager（TIME_SHORTCUT_ACTIONS / TIME_SHORTCUT_DEFAULTS）。
const TIME_SHORTCUT_ROWS := [
	["走时间快捷键行", "toggle_time"],
	["速度1快捷键行", "speed_1"],
	["速度2快捷键行", "speed_2"],
	["速度3快捷键行", "speed_3"],
	["速度4快捷键行", "speed_4"],
]

var 专辑页码: int = 0   # 当前显示第几页专辑（每页 = 「专辑」组里的槽位数）
## 正在等待重绑的动作名；空串表示未处于重绑等待状态。
var _rebinding_action: String = ""
## 作弊快捷键正在等待重绑的动作名。
var _cheat_rebinding_action: String = ""

## 当前设置页：0=基础/音乐页，1=自定义页。
var _settings_page: int = 0
## 自定义页根节点（来自 自定义页.tscn 实例）。
var _custom_page: Control = null
## 自定义页每个值 Label/CheckButton 的引用。
var _custom_labels: Dictionary = {}


func _ready() -> void:
	循环播放.pressed.connect(_on_循环播放_pressed)
	随机播放.pressed.connect(_on_随机播放_pressed)
	if 翻页按钮_右:
		翻页按钮_右.pressed.connect(_on_专辑右翻页_pressed)
	if 翻页按钮_左:
		翻页按钮_左.pressed.connect(_on_专辑左翻页_pressed)
	音频总管.专辑变更.connect(_on_专辑变更)
	_连接槽位信号()
	_连接专辑槽位信号()
	_连接设置选择器()
	_连接窗口模式选择器()
	_连接时间快捷键行()
	_连接页导航()
	_连接自定义页()
	_刷新槽位显示()
	_刷新按钮外观()
	_初始化专辑页码()
	_refresh_settings_rows()
	_刷新窗口模式行()
	_refresh_time_shortcut_rows()
	_刷新自定义页()
	_show_settings_page(_settings_page)
	_apply_settings_font_scale()


## 难度/自动保存/存档槽三行的左右箭头（对应原作 DiffScript / Need_save OnMouseDown）。
func _连接设置选择器() -> void:
	for 行 in ["难度行", "自动保存行", "保存槽位行"]:
		var 左 := get_node_or_null(行 + "/左") as BaseButton
		var 右 := get_node_or_null(行 + "/右") as BaseButton
		if 左:
			左.pressed.connect(_on_选择器左_pressed.bind(行))
		if 右:
			右.pressed.connect(_on_选择器右_pressed.bind(行))


func _on_选择器左_pressed(行: String) -> void:
	match 行:
		"难度行":
			_change_difficulty(-1)
		"自动保存行":
			_change_autosave(-1)
		"保存槽位行":
			_change_saveplace(-1)


func _on_选择器右_pressed(行: String) -> void:
	match 行:
		"难度行":
			_change_difficulty(1)
		"自动保存行":
			_change_autosave(1)
		"保存槽位行":
			_change_saveplace(1)


## 窗口模式行左右箭头：两态直接翻转，不做循环列表。
func _连接窗口模式选择器() -> void:
	var 左 := get_node_or_null("窗口模式行/左") as BaseButton
	var 右 := get_node_or_null("窗口模式行/右") as BaseButton
	if 左:
		左.pressed.connect(_on_窗口模式切换)
	if 右:
		右.pressed.connect(_on_窗口模式切换)


## DisplayServer 窗口模式切换。
## API 出处：本地文档 gdd_1242_DisplayServer.md
##   - window_set_mode(mode)（L4237）
##   - window_set_size(size)（L4312）
##   - window_set_flag(flag, enabled)（L4155）
##   - WINDOW_FLAG_BORDERLESS / WINDOW_MODE_WINDOWED / WINDOW_MODE_EXCLUSIVE_FULLSCREEN（L1269-1294、L1352）
## 全屏模式会强制 borderless=true，切回窗口前必须把 borderless 设回 false（L4243）。
## 退出全屏时，Windows 端引擎按启动时预存的矩形恢复窗口
## （window_width/height_override，本地文档 gdd_1421_ProjectSettings.md L2596-2608）；
## project.godot 里 override=1280x720 是"能正常切出全屏"的关键，不能删。
func _on_窗口模式切换() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		# 先退出全屏：引擎恢复 project.godot 预存的 1280×720 矩形（见上方 issue 120283），
		# 再恢复边框、最后套 1280×720 兜底，避免在全屏态直接改尺寸。
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_size(WINDOWED_SIZE)
	_刷新窗口模式行()


func _刷新窗口模式行() -> void:
	if 窗口模式值 == null:
		return
	var is_windowed: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED
	窗口模式值.text = WINDOW_MODE_NAMES[0 if is_windowed else 1]


## 原作 DiffScript.OnMouseDown：右 +1 越界回 0，左 -1 越界回 4。
## 主菜单无活动局时也允许调整：改的是 GameManager.difficulty_setting，新开/读档会沿用。
func _change_difficulty(delta: int) -> void:
	if GameManager == null:
		return
	var d: int = GameManager.world.difficulty if GameManager.world != null else GameManager.difficulty_setting
	if delta > 0:
		d = 0 if d >= 4 else d + 1
	else:
		d = 4 if d <= 0 else d - 1
	GameManager.set_difficulty(d)
	_refresh_settings_rows()


## 原作 Need_save.DownToAutoSave：右 +1 越界回 0，左 -1 越界回 2。
func _change_autosave(delta: int) -> void:
	var v: int = GameManager.autosave_mode
	if delta > 0:
		v = 0 if v >= 2 else v + 1
	else:
		v = 2 if v <= 0 else v - 1
	GameManager.set_autosave_mode(v)
	_refresh_settings_rows()


## 原作 Need_save.DownToSaveSlot：savePlace 1..5 循环，持久化 SavePlaceNum。
func _change_saveplace(delta: int) -> void:
	var v: int = GameManager.save_place
	if delta > 0:
		v = 1 if v >= 5 else v + 1
	else:
		v = 5 if v <= 1 else v - 1
	GameManager.set_save_place(v)
	_refresh_settings_rows()


## 原作 SettingInGameScript：无活动局时销毁难度选择器；本项目按需求改为始终显示，
## 主菜单也能预设难度（新开局沿用 difficulty_setting）。
func _refresh_settings_rows() -> void:
	if GameManager == null:
		return
	if 难度行:
		难度行.visible = true
	if 难度值:
		var d := clampi(GameManager.world.difficulty if GameManager.world != null else GameManager.difficulty_setting, 0, 4)
		难度值.text = DIFF_NAMES[d]
		# 原作 DiffScript.Textotext：diff 0/1 → 成就 X，2-4 → 成就 V。
		if 难度成就:
			难度成就.text = " 成 就 ： X" if d < 2 else " 成 就 ： V"
	if 自动保存值:
		自动保存值.text = AUTOSAVE_NAMES[clampi(GameManager.autosave_mode, 0, 2)]
	if 保存槽位值:
		保存槽位值.text = SAVEPLACE_NAMES.get(GameManager.save_place, str(GameManager.save_place))


# ============================================================================
# 设置翻页与自定义页（节点位于 设置.tscn / 自定义页.tscn，可直接在编辑器微调）
# ============================================================================

const CHEAT_VALUE_NODES := {
	"party_support": "CheatPartyValue",
	"people_support": "CheatPeopleValue",
	"thought_freedom": "CheatThoughtValue",
	"living_standard": "CheatLivingValue",
	"diplo": "CheatDiploValue",
	"influence_prc": "CheatInfluenceValue",
	"budget": "CheatBudgetValue",
	"agents": "CheatAgentsValue",
	"army": "CheatArmyValue",
	"relations_both": "CheatRelationsValue",
	"ussr_toggle": "CheatUssrValue",
	"diplo_down": "CheatDiploDownValue",
	"mil_add": "CheatMilValue",
}

const CHEAT_REBIND_NODES := {
	"party_support": "CheatPartyRebind",
	"people_support": "CheatPeopleRebind",
	"thought_freedom": "CheatThoughtRebind",
	"living_standard": "CheatLivingRebind",
	"diplo": "CheatDiploRebind",
	"influence_prc": "CheatInfluenceRebind",
	"budget": "CheatBudgetRebind",
	"agents": "CheatAgentsRebind",
	"army": "CheatArmyRebind",
	"relations_both": "CheatRelationsRebind",
	"ussr_toggle": "CheatUssrRebind",
	"diplo_down": "CheatDiploDownRebind",
	"mil_add": "CheatMilRebind",
}

const CHEAT_ROW_NODES := {
	"party_support": "CheatPartyRow",
	"people_support": "CheatPeopleRow",
	"thought_freedom": "CheatThoughtRow",
	"living_standard": "CheatLivingRow",
	"diplo": "CheatDiploRow",
	"influence_prc": "CheatInfluenceRow",
	"budget": "CheatBudgetRow",
	"agents": "CheatAgentsRow",
	"army": "CheatArmyRow",
	"relations_both": "CheatRelationsRow",
	"ussr_toggle": "CheatUssrRow",
	"diplo_down": "CheatDiploDownRow",
	"mil_add": "CheatMilRow",
}

const TOGGLE_ROWS := {
	"debug_console": "DebugConsoleRow",
	"paragraph_spacing": "ParagraphSpacingRow",
	"paragraph_indent": "ParagraphIndentRow",
}

const NUMBER_DEFS := {
	"event_desc": ["EventDescRow", "EventDescPrev", "EventDescValue", "EventDescNext", 12, 72, 1],
	"event_option": ["EventOptionRow", "EventOptionPrev", "EventOptionValue", "EventOptionNext", 12, 72, 1],
	"event_result": ["EventResultRow", "EventResultPrev", "EventResultValue", "EventResultNext", 12, 72, 1],
	"ui_scale": ["UiScaleRow", "UiScalePrev", "UiScaleValue", "UiScaleNext", 60, 200, 5],
	"map_border": ["MapBorderRow", "MapBorderPrev", "MapBorderValue", "MapBorderNext", 10, 120, 5],
}


func _连接页导航() -> void:
	var btn0 := get_node_or_null("页导航/基础页按钮") as BaseButton
	var btn1 := get_node_or_null("页导航/自定义页按钮") as BaseButton
	if btn0:
		btn0.pressed.connect(func(): _show_settings_page(0))
	if btn1:
		btn1.pressed.connect(func(): _show_settings_page(1))


func _show_settings_page(page: int) -> void:
	_settings_page = page
	if _custom_page == null:
		_custom_page = get_node_or_null("自定义页")
	if _custom_page == null:
		return
	# 页面导航、返回、恢复默认始终可见；其余为第一页内容。
	var always_visible := ["页导航", "自定义页", "返回", "恢复默认", "背景层"]
	for child in get_children():
		if child.name in always_visible:
			continue
		child.visible = (page == 0)
	_custom_page.visible = (page == 1)
	# 避免自定义页在页面上时被隐藏的旧控件挡住交互；页导航始终保持在最上层
	if page == 1:
		_custom_page.move_to_front()
		var nav := get_node_or_null("页导航")
		if nav:
			nav.move_to_front()


func _连接自定义页() -> void:
	_custom_page = get_node_or_null("自定义页")
	if _custom_page == null:
		return
	# 功能开关
	for key in TOGGLE_ROWS:
		var row_name: String = TOGGLE_ROWS[key]
		var cb_name := ""
		match key:
			"debug_console":
				cb_name = "DebugConsoleToggle"
			"paragraph_spacing":
				cb_name = "ParagraphSpacingToggle"
			"paragraph_indent":
				cb_name = "ParagraphIndentToggle"
		_connect_toggle(row_name, cb_name, key)
	# 数字行
	for key in NUMBER_DEFS:
		var def: Array = NUMBER_DEFS[key]
		_connect_number(key, String(def[0]), String(def[1]), String(def[2]), String(def[3]), int(def[4]), int(def[5]), int(def[6]))
	# 选择器
	var on_align := func(index: int) -> void:
		GameManager.set_event_text_alignment(index)
		_刷新自定义页()
	_connect_selector("event_align", "EventAlignRow", "EventAlignPrev", "EventAlignValue", "EventAlignNext", SettingsService.EVENT_ALIGN_NAMES, on_align)
	var on_palette := func(index: int) -> void:
		GameManager.set_map_color_preset(index)
		_刷新自定义页()
	_connect_selector("map_palette", "MapPaletteRow", "MapPalettePrev", "MapPaletteValue", "MapPaletteNext", SettingsService.MAP_PALETTE_NAMES, on_palette)
	# 作弊快捷键
	for action in SettingsService.CHEAT_SHORTCUT_ACTIONS:
		var row_name: String = CHEAT_ROW_NODES.get(action, "")
		var value_name: String = CHEAT_VALUE_NODES.get(action, "")
		var rebind_name: String = CHEAT_REBIND_NODES.get(action, "")
		if value_name != "":
			var val := get_node_or_null("自定义页/滚动/列表/" + row_name + "/" + value_name) as Label
			if val:
				_custom_labels["cheat_" + action] = val
		if rebind_name != "":
			var rebind := get_node_or_null("自定义页/滚动/列表/" + row_name + "/" + rebind_name) as BaseButton
			if rebind:
				rebind.pressed.connect(_on_作弊快捷键重绑_pressed.bind(action))


func _connect_toggle(row_name: String, node_name: String, key: String) -> void:
	var cb := get_node_or_null("自定义页/滚动/列表/" + row_name + "/" + node_name) as CheckButton
	if cb == null:
		return
	_custom_labels[key] = cb
	cb.toggled.connect(func(on: bool) -> void:
		match key:
			"debug_console":
				GameManager.set_debug_console_enabled(on)
			"paragraph_spacing":
				GameManager.set_paragraph_spacing_enabled(on)
			"paragraph_indent":
				GameManager.set_paragraph_indent_enabled(on)
		_刷新自定义页()
	)


func _connect_number(key: String, row_name: String, prev_name: String, value_name: String, next_name: String, min_v: int, max_v: int, step: int) -> void:
	var prev := get_node_or_null("自定义页/滚动/列表/" + row_name + "/" + prev_name) as BaseButton
	var val := get_node_or_null("自定义页/滚动/列表/" + row_name + "/" + value_name) as Label
	var next := get_node_or_null("自定义页/滚动/列表/" + row_name + "/" + next_name) as BaseButton
	if val:
		_custom_labels[key] = val
	if prev:
		prev.pressed.connect(func(): _change_number(key, -step, min_v, max_v))
	if next:
		next.pressed.connect(func(): _change_number(key, step, min_v, max_v))


func _connect_selector(key: String, row_name: String, prev_name: String, value_name: String, next_name: String, options: Array, on_changed: Callable) -> void:
	var prev := get_node_or_null("自定义页/滚动/列表/" + row_name + "/" + prev_name) as BaseButton
	var val := get_node_or_null("自定义页/滚动/列表/" + row_name + "/" + value_name) as Label
	var next := get_node_or_null("自定义页/滚动/列表/" + row_name + "/" + next_name) as BaseButton
	if val:
		_custom_labels[key] = val
	if prev:
		prev.pressed.connect(func() -> void:
			var cur := _selector_index(key)
			var nxt := (cur - 1 + options.size()) % options.size()
			on_changed.call(nxt)
		)
	if next:
		next.pressed.connect(func() -> void:
			var cur := _selector_index(key)
			var nxt := (cur + 1) % options.size()
			on_changed.call(nxt)
		)


func _selector_index(key: String) -> int:
	match key:
		"event_align":
			return GameManager.event_text_alignment
		"map_palette":
			return GameManager.map_color_preset
	return 0


func _number_current(key: String) -> int:
	match key:
		"event_desc":
			return GameManager.event_desc_font_size
		"event_option":
			return GameManager.event_option_font_size
		"event_result":
			return GameManager.event_result_font_size
		"ui_scale":
			return int(roundi(GameManager.ui_font_scale * 100.0))
		"map_border":
			return int(roundi(GameManager.map_border_width * 10.0))
	return 0


func _change_number(key: String, delta: int, min_v: int, max_v: int) -> void:
	var value := clampi(_number_current(key) + delta, min_v, max_v)
	match key:
		"event_desc":
			GameManager.set_event_desc_font_size(value)
		"event_option":
			GameManager.set_event_option_font_size(value)
		"event_result":
			GameManager.set_event_result_font_size(value)
		"ui_scale":
			GameManager.set_ui_font_scale(float(value) / 100.0)
			_apply_settings_font_scale()
		"map_border":
			GameManager.set_map_border_width(float(value) / 10.0)
	_刷新自定义页()


func _刷新自定义页() -> void:
	if _custom_labels.is_empty() or GameManager == null:
		return
	if _custom_labels.has("debug_console"):
		var cb := _custom_labels["debug_console"] as CheckButton
		cb.button_pressed = GameManager.debug_console_enabled
	if _custom_labels.has("paragraph_spacing"):
		var cb := _custom_labels["paragraph_spacing"] as CheckButton
		cb.button_pressed = GameManager.paragraph_spacing_enabled
	if _custom_labels.has("paragraph_indent"):
		var cb := _custom_labels["paragraph_indent"] as CheckButton
		cb.button_pressed = GameManager.paragraph_indent_enabled
	if _custom_labels.has("event_align"):
		var lbl := _custom_labels["event_align"] as Label
		lbl.text = SettingsService.EVENT_ALIGN_NAMES[clampi(GameManager.event_text_alignment, 0, 2)]
	if _custom_labels.has("event_desc"):
		var lbl := _custom_labels["event_desc"] as Label
		lbl.text = str(GameManager.event_desc_font_size)
	if _custom_labels.has("event_option"):
		var lbl := _custom_labels["event_option"] as Label
		lbl.text = str(GameManager.event_option_font_size)
	if _custom_labels.has("event_result"):
		var lbl := _custom_labels["event_result"] as Label
		lbl.text = str(GameManager.event_result_font_size)
	if _custom_labels.has("ui_scale"):
		var lbl := _custom_labels["ui_scale"] as Label
		lbl.text = "%d%%" % int(roundi(GameManager.ui_font_scale * 100.0))
	if _custom_labels.has("map_border"):
		var lbl := _custom_labels["map_border"] as Label
		lbl.text = "%.1f" % GameManager.map_border_width
	if _custom_labels.has("map_palette"):
		var lbl := _custom_labels["map_palette"] as Label
		lbl.text = SettingsService.MAP_PALETTE_NAMES[clampi(GameManager.map_color_preset, 0, SettingsService.MAP_PALETTE_NAMES.size() - 1)]
	for action in SettingsService.CHEAT_SHORTCUT_ACTIONS:
		var key := "cheat_" + action
		if _custom_labels.has(key):
			var lbl := _custom_labels[key] as Label
			if _cheat_rebinding_action == action:
				lbl.text = "按下任意键…"
			else:
				lbl.text = GameManager.get_cheat_hotkey_label(action)


## 作弊快捷键重绑入口。
func _on_作弊快捷键重绑_pressed(action: String) -> void:
	_cheat_rebinding_action = action
	_刷新自定义页()


## 应用全局 UI 字体倍率到当前设置页。
func _apply_settings_font_scale() -> void:
	if GameManager == null:
		return
	UISettings.apply_font_scale(self, GameManager.ui_font_scale)


# ============ 单曲列表（左/右共 40 槽位，显示当前播放专辑的曲目） ============

func _获取槽位() -> Array:
	var 槽位: Array = []
	for 子节点 in get_children():
		if 子节点.has_node("播放按钮"):
			槽位.append(子节点)
	return 槽位


func _连接槽位信号() -> void:
	var 槽位 := _获取槽位()
	for i in 槽位.size():
		槽位[i].get_node("播放按钮").pressed.connect(_on_播放单曲.bind(i))


func _刷新槽位显示() -> void:
	var 曲名列表: Array = 音频总管.获取当前曲目名列表()
	var 槽位 := _获取槽位()
	for i in 槽位.size():
		var 槽: Control = 槽位[i]
		if i < 曲名列表.size():
			槽.get_node("歌名").text = str(曲名列表[i])
			槽.visible = true
		else:
			槽.visible = false


func _on_播放单曲(索引: int) -> void:
	音频总管.播放曲目(索引)


# ============ 专辑按钮（分页浏览，点击播放） ============

# 专辑槽位 = 加入「专辑」组的节点（专辑.tscn 实例，根为 Control，内含「专辑按钮」TextureButton）
# 每次实时取组，保证增删槽位后无需改代码
func _获取专辑槽位() -> Array:
	return get_tree().get_nodes_in_group("专辑")


func _连接专辑槽位信号() -> void:
	var 槽位 := _获取专辑槽位()
	for i in 槽位.size():
		var 按钮 := 槽位[i].get_node_or_null("专辑按钮") as TextureButton
		if 按钮 != null:
			按钮.pressed.connect(_on_专辑槽位_按下.bind(i))


# 进入设置时，翻到正在播放的专辑所在的那一页
func _初始化专辑页码() -> void:
	var 每页 := _获取专辑槽位().size()
	if 每页 > 0 and 音频总管.当前专辑索引 >= 0:
		专辑页码 = floori(float(音频总管.当前专辑索引) / float(每页))
	_刷新专辑槽位()


# 把当前页的专辑封面填进各槽位；本页没有对应专辑的槽位隐藏
func _刷新专辑槽位() -> void:
	var 槽位 := _获取专辑槽位()
	var 每页 := 槽位.size()
	var 起始 := 专辑页码 * 每页
	var 专辑数: int = 音频总管.专辑总数()
	for i in 每页:
		var 槽: CanvasItem = 槽位[i]
		var 专辑索引 := 起始 + i
		var 按钮 := 槽.get_node_or_null("专辑按钮") as TextureButton
		if 专辑索引 < 专辑数:
			if 按钮 != null:
				var 封面: Texture2D = 音频总管.获取专辑封面(专辑索引)
				var 按下: Texture2D = 音频总管.获取专辑封面_按下(专辑索引)
				按钮.texture_normal = 封面
				按钮.texture_pressed = 按下 if 按下 != null else 封面
			槽.visible = true
		else:
			槽.visible = false


func _总页数() -> int:
	var 每页 := _获取专辑槽位().size()
	var 专辑数: int = 音频总管.专辑总数()
	if 每页 == 0 or 专辑数 == 0:
		return 1
	return ceili(float(专辑数) / float(每页))


func _on_专辑右翻页_pressed() -> void:
	专辑页码 = (专辑页码 + 1) % _总页数()
	_刷新专辑槽位()


func _on_专辑左翻页_pressed() -> void:
	var 页数 := _总页数()
	专辑页码 = (专辑页码 - 1 + 页数) % 页数
	_刷新专辑槽位()


# 点击某个专辑槽位 → 播放该槽位当前对应的专辑
func _on_专辑槽位_按下(槽序号: int) -> void:
	var 专辑索引 := 专辑页码 * _获取专辑槽位().size() + 槽序号
	if 专辑索引 < 音频总管.专辑总数():
		音频总管.选择专辑(专辑索引)


# ============ 其余按钮 ============

func _on_专辑变更() -> void:
	_刷新槽位显示()


func _on_循环播放_pressed() -> void:
	音频总管.切换循环()
	_刷新按钮外观()


func _on_随机播放_pressed() -> void:
	音频总管.切换随机()
	_刷新按钮外观()


func _刷新按钮外观() -> void:
	循环播放.modulate = Color.WHITE if 音频总管.循环 else Color(1, 1, 1, 0.35)
	随机播放.modulate = Color.WHITE if 音频总管.随机 else Color(1, 1, 1, 0.35)


## 连接五行"重绑"按钮：点击进入等待按键状态。
func _连接时间快捷键行() -> void:
	for row in TIME_SHORTCUT_ROWS:
		var btn := get_node_or_null(String(row[0]) + "/重绑") as BaseButton
		if btn:
			btn.pressed.connect(_on_快捷键重绑_pressed.bind(String(row[1])))


func _on_快捷键重绑_pressed(action: String) -> void:
	_rebinding_action = action
	_refresh_time_shortcut_rows()


## 刷新五行的键名显示；等待重绑的动作显示提示。
func _refresh_time_shortcut_rows() -> void:
	var labels: Array = [走时间快捷键值, 速度1快捷键值, 速度2快捷键值, 速度3快捷键值, 速度4快捷键值]
	for i in TIME_SHORTCUT_ROWS.size():
		var lbl := labels[i] as Label
		if lbl == null:
			continue
		if _rebinding_action == String(TIME_SHORTCUT_ROWS[i][1]):
			lbl.text = "按下任意键…"
		else:
			lbl.text = GameManager.get_time_shortcut_label(String(TIME_SHORTCUT_ROWS[i][1]))


## 重绑捕获：等待状态下捕获第一个真实按键；ESC 取消，不修改绑定。
## physical_keycode 优先（布局无关，gdd_0959_InputEventKey.md L101-116），合成事件兜底用 keycode。
func _input(event: InputEvent) -> void:
	if _rebinding_action.is_empty() and _cheat_rebinding_action.is_empty():
		return
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			_rebinding_action = ""
			_cheat_rebinding_action = ""
			_refresh_time_shortcut_rows()
			_刷新自定义页()
			return
		var code: int = int(event.physical_keycode) if event.physical_keycode != 0 else int(event.keycode)
		if code == 0:
			return
		if not _rebinding_action.is_empty():
			GameManager.rebind_time_shortcut(_rebinding_action, code)
			_rebinding_action = ""
			_refresh_time_shortcut_rows()
		if not _cheat_rebinding_action.is_empty():
			GameManager.rebind_cheat_hotkey(_cheat_rebinding_action, code)
			_cheat_rebinding_action = ""
			_刷新自定义页()


## 恢复默认：还原持久化设置、音乐循环/随机、音量、快捷键与窗口模式。
func _on_恢复默认_pressed() -> void:
	_rebinding_action = ""
	_cheat_rebinding_action = ""
	if GameManager:
		GameManager.reset_settings()
	if 音频总管:
		音频总管.循环 = false
		音频总管.随机 = true
		音频总管.apply_voice()
	var audio_info := get_node_or_null("音频信息背景图")
	if audio_info:
		if audio_info.has_method("_refresh_volume_display"):
			audio_info._refresh_volume_display()
		var slider := audio_info.get_node_or_null("音量滑条") as HSlider
		if slider:
			slider.set_value_no_signal(float(GameManager.voice if GameManager else 5))
	# 项目默认启动为独占全屏，恢复默认时也切回全屏
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	_refresh_settings_rows()
	_刷新按钮外观()
	_refresh_time_shortcut_rows()
	_刷新窗口模式行()
	_刷新自定义页()
	_apply_settings_font_scale()


func _on_返回_pressed() -> void:
	var return_scene: String = GameManager.settings_return_scene
	if return_scene == "":
		return_scene = "uid://bydan4iqthbaa"
	get_tree().paused = false
	get_tree().change_scene_to_file(return_scene)
