class_name SettingsService
extends RefCounted

## 设置持久化与快捷键服务。
## 从 GameManager 拆出，职责单一：读写 user://settings.cfg、管理 InputMap 快捷键。
## GameManager 保留同名的公开代理方法/属性，UI 调用点暂不修改。

const SETTINGS_PATH := "user://settings.cfg"

const TIME_SHORTCUT_ACTIONS: Array[String] = ["toggle_time", "speed_1", "speed_2", "speed_3", "speed_4"]
const TIME_SHORTCUT_DEFAULTS := {
	"toggle_time": KEY_SPACE,
	"speed_1": KEY_1,
	"speed_2": KEY_2,
	"speed_3": KEY_3,
	"speed_4": KEY_4,
}

## 作弊快捷键动作：仅在沙盒难度（world.difficulty == 0）生效。
const CHEAT_SHORTCUT_ACTIONS: Array[String] = [
	"party_support", "people_support", "thought_freedom", "living_standard",
	"diplo", "influence_prc", "budget", "agents", "army",
	"relations_both", "ussr_toggle", "diplo_down", "mil_add",
]
const CHEAT_SHORTCUT_DEFAULTS := {
	"party_support": KEY_1,
	"people_support": KEY_2,
	"thought_freedom": KEY_3,
	"living_standard": KEY_4,
	"diplo": KEY_5,
	"influence_prc": KEY_6,
	"budget": KEY_7,
	"agents": KEY_8,
	"army": KEY_9,
	"relations_both": KEY_0,
	"ussr_toggle": KEY_A,
	"diplo_down": KEY_D,
	"mil_add": KEY_I,
}

## 事件文本对齐：0=左对齐 1=居中 2=右对齐。
const EVENT_ALIGN_NAMES := ["左对齐", "居中", "右对齐"]

## 地图配色预设：0=原版 1=明亮 2=暗色 3=高对比。
const MAP_PALETTE_NAMES := ["原版", "明亮", "暗色", "高对比"]

## 音乐音量 0-100。原版 GlobalScript.cs:249 默认 5。
var voice: int = 5
## 自动保存档位 0=不自动 1=每月 2=半年。原版 GlobalScript.autosavej 默认 0。
var autosave_mode: int = 0
## 自动保存/快速保存目标槽（原版编号 1-5，5=成就位）。原版 GlobalScript.savePlace 默认 5。
var save_place: int = 5
## 难度设置持久值。原版 GameState.diff 会被 PlayerPrefs our_diff_in 覆盖。
var difficulty_setting: int = 2

## 当前绑定：action → 物理键码（Key）。空字典时用 TIME_SHORTCUT_DEFAULTS 兜底。
var time_shortcut_keys: Dictionary = {}
## 作弊快捷键当前绑定：action → 物理键码（Key）。
var cheat_hotkey_keys: Dictionary = {}

## 调试控制台总开关。关闭时任何模式下都不能用快捷键/按钮打开。
var debug_console_enabled: bool = false
## 调试控制台开关快捷键（可自行定义；默认 F12）。
var debug_console_toggle_key: int = KEY_F12

## 事件系统自动触发开关。关闭后不再自动扫描/轮询事件，手动触发仍可用。
var events_enabled: bool = true

## 事件文本对齐方式。0=左 1=中 2=右。
var event_text_alignment: int = 0
## 事件描述/正文、选项、结果、标题字体大小。
var event_title_font_size: int = 39
var event_desc_font_size: int = 29
var event_option_font_size: int = 28
var event_result_font_size: int = 29
## 全局 UI 字体倍率（100 = 原大小）。
var ui_font_scale: float = 1.0
## 事件段落格式：两段之间留空隙、段首自动空两格。
var paragraph_spacing_enabled: bool = true
var paragraph_indent_enabled: bool = true

## 地图国界粗细（采样像素，越大越粗）。
var map_border_width: float = 3.0
## 地图配色预设索引。
var map_color_preset: int = 0


func load_config() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		# 无配置文件时保持原版默认：voice=5、autosavej=0、savePlace=5、diff=2。
		# 快捷键保持 TIME_SHORTCUT_DEFAULTS（time_shortcut_keys 留空，由 get 默认兜底）。
		return
	voice = clampi(int(cfg.get_value("settings", "voice_china", 5)), 0, 100)
	autosave_mode = clampi(int(cfg.get_value("settings", "SavePosition", 0)), 0, 2)
	save_place = clampi(int(cfg.get_value("settings", "SavePlaceNum", 5)), 1, 5)
	difficulty_setting = clampi(int(cfg.get_value("settings", "our_diff_in", 2)), 0, 4)
	for action in TIME_SHORTCUT_ACTIONS:
		var code: int = int(cfg.get_value("time_shortcuts", action, TIME_SHORTCUT_DEFAULTS[action]))
		if code != 0:
			time_shortcut_keys[action] = code
	# 新快捷键/功能开关
	debug_console_enabled = bool(cfg.get_value("settings", "debug_console_enabled", false))
	debug_console_toggle_key = int(cfg.get_value("settings", "debug_console_toggle_key", KEY_F12))
	events_enabled = bool(cfg.get_value("settings", "events_enabled", true))
	event_text_alignment = clampi(int(cfg.get_value("ui", "event_text_alignment", 0)), 0, 2)
	event_title_font_size = clampi(int(cfg.get_value("ui", "event_title_font_size", 39)), 12, 96)
	event_desc_font_size = clampi(int(cfg.get_value("ui", "event_desc_font_size", 29)), 12, 72)
	event_option_font_size = clampi(int(cfg.get_value("ui", "event_option_font_size", 28)), 12, 72)
	event_result_font_size = clampi(int(cfg.get_value("ui", "event_result_font_size", 29)), 12, 72)
	ui_font_scale = clampf(float(cfg.get_value("ui", "ui_font_scale", 1.0)), 0.6, 2.0)
	paragraph_spacing_enabled = bool(cfg.get_value("ui", "paragraph_spacing_enabled", true))
	paragraph_indent_enabled = bool(cfg.get_value("ui", "paragraph_indent_enabled", true))
	map_border_width = clampf(float(cfg.get_value("map", "border_width", 3.0)), 1.0, 12.0)
	map_color_preset = clampi(int(cfg.get_value("map", "color_preset", 0)), 0, MAP_PALETTE_NAMES.size() - 1)
	for action in CHEAT_SHORTCUT_ACTIONS:
		var code: int = int(cfg.get_value("cheat_hotkeys", action, CHEAT_SHORTCUT_DEFAULTS[action]))
		if code != 0:
			cheat_hotkey_keys[action] = code


func save_config() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "voice_china", voice)
	cfg.set_value("settings", "SavePosition", autosave_mode)
	cfg.set_value("settings", "SavePlaceNum", save_place)
	cfg.set_value("settings", "our_diff_in", difficulty_setting)
	cfg.set_value("settings", "debug_console_enabled", debug_console_enabled)
	cfg.set_value("settings", "debug_console_toggle_key", debug_console_toggle_key)
	cfg.set_value("settings", "events_enabled", events_enabled)
	cfg.set_value("ui", "event_text_alignment", event_text_alignment)
	cfg.set_value("ui", "event_title_font_size", event_title_font_size)
	cfg.set_value("ui", "event_desc_font_size", event_desc_font_size)
	cfg.set_value("ui", "event_option_font_size", event_option_font_size)
	cfg.set_value("ui", "event_result_font_size", event_result_font_size)
	cfg.set_value("ui", "ui_font_scale", ui_font_scale)
	cfg.set_value("ui", "paragraph_spacing_enabled", paragraph_spacing_enabled)
	cfg.set_value("ui", "paragraph_indent_enabled", paragraph_indent_enabled)
	cfg.set_value("map", "border_width", map_border_width)
	cfg.set_value("map", "color_preset", map_color_preset)
	for action in TIME_SHORTCUT_ACTIONS:
		cfg.set_value("time_shortcuts", action, int(time_shortcut_keys.get(action, TIME_SHORTCUT_DEFAULTS[action])))
	for action in CHEAT_SHORTCUT_ACTIONS:
		cfg.set_value("cheat_hotkeys", action, int(cheat_hotkey_keys.get(action, CHEAT_SHORTCUT_DEFAULTS[action])))
	if cfg.save(SETTINGS_PATH) != OK:
		push_error("SettingsService: 设置写入失败 " + SETTINGS_PATH)


## 恢复全部持久化设置为原版默认值，并立即应用到 InputMap 与配置文件。
func reset_to_defaults() -> void:
	voice = 5
	autosave_mode = 0
	save_place = 5
	difficulty_setting = 2
	time_shortcut_keys.clear()
	cheat_hotkey_keys.clear()
	debug_console_enabled = false
	debug_console_toggle_key = KEY_F12
	events_enabled = true
	event_text_alignment = 0
	event_title_font_size = 39
	event_desc_font_size = 29
	event_option_font_size = 28
	event_result_font_size = 29
	ui_font_scale = 1.0
	paragraph_spacing_enabled = true
	paragraph_indent_enabled = true
	map_border_width = 3.0
	map_color_preset = 0
	apply_time_shortcuts()
	save_config()


## 注册动作并应用当前绑定。仅应由 GameManager._ready 调用一次；
## 动作常驻全局 InputMap，但只有外交场景监听它们。
func setup_time_shortcuts() -> void:
	for action in TIME_SHORTCUT_ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	apply_time_shortcuts()


func apply_time_shortcuts() -> void:
	for action in TIME_SHORTCUT_ACTIONS:
		InputMap.action_erase_events(action)
		var code := get_time_shortcut_key(action)
		if code == 0:
			continue
		var ev := InputEventKey.new()
		ev.physical_keycode = code as Key
		InputMap.action_add_event(action, ev)


func get_time_shortcut_key(action: String) -> int:
	return int(time_shortcut_keys.get(action, TIME_SHORTCUT_DEFAULTS.get(action, 0)))


## 键位显示名：按物理键位转当前布局标签（中文输入法/不同布局下仍显示当前键帽）。
func get_time_shortcut_label(action: String) -> String:
	return _key_label(get_time_shortcut_key(action))


## 设置界面重绑入口：写入内存 + 立即改 InputMap + 持久化。
func rebind_time_shortcut(action: String, physical_keycode: int) -> void:
	if not TIME_SHORTCUT_ACTIONS.has(action) or physical_keycode == 0:
		return
	time_shortcut_keys[action] = physical_keycode
	apply_time_shortcuts()
	save_config()


# ── 作弊快捷键 ──

func get_cheat_hotkey_key(action: String) -> int:
	return int(cheat_hotkey_keys.get(action, CHEAT_SHORTCUT_DEFAULTS.get(action, 0)))


func get_cheat_hotkey_label(action: String) -> String:
	return _key_label(get_cheat_hotkey_key(action))


func rebind_cheat_hotkey(action: String, physical_keycode: int) -> void:
	if not CHEAT_SHORTCUT_ACTIONS.has(action) or physical_keycode == 0:
		return
	cheat_hotkey_keys[action] = physical_keycode
	save_config()


func _key_label(code: int) -> String:
	if code == 0:
		return "未设置"
	if DisplayServer.get_name() != "headless":
		var label_key := DisplayServer.keyboard_get_label_from_physical(code as Key)
		if label_key != 0:
			return OS.get_keycode_string(label_key)
	return OS.get_keycode_string(code as Key)


# ── 新功能设置 ──

func set_debug_console_enabled(value: bool) -> void:
	debug_console_enabled = value
	save_config()


func set_debug_console_toggle_key(physical_keycode: int) -> void:
	if physical_keycode == 0:
		return
	debug_console_toggle_key = physical_keycode
	save_config()


func set_events_enabled(value: bool) -> void:
	events_enabled = value
	save_config()


func set_event_text_alignment(value: int) -> void:
	event_text_alignment = clampi(value, 0, 2)
	save_config()


func set_event_desc_font_size(value: int) -> void:
	event_desc_font_size = clampi(value, 12, 72)
	save_config()


func set_event_title_font_size(value: int) -> void:
	event_title_font_size = clampi(value, 12, 96)
	save_config()


func set_event_option_font_size(value: int) -> void:
	event_option_font_size = clampi(value, 12, 72)
	save_config()


func set_event_result_font_size(value: int) -> void:
	event_result_font_size = clampi(value, 12, 72)
	save_config()


func set_ui_font_scale(value: float) -> void:
	ui_font_scale = clampf(value, 0.6, 2.0)
	save_config()


func set_paragraph_spacing_enabled(value: bool) -> void:
	paragraph_spacing_enabled = value
	save_config()


func set_paragraph_indent_enabled(value: bool) -> void:
	paragraph_indent_enabled = value
	save_config()


func set_map_border_width(value: float) -> void:
	map_border_width = clampf(value, 1.0, 12.0)
	save_config()


func set_map_color_preset(value: int) -> void:
	map_color_preset = clampi(value, 0, MAP_PALETTE_NAMES.size() - 1)
	save_config()


func set_voice(value: int) -> void:
	voice = clampi(value, 0, 100)
	save_config()


func set_autosave_mode(value: int) -> void:
	autosave_mode = clampi(value, 0, 2)
	save_config()


func set_save_place(value: int) -> void:
	save_place = clampi(value, 1, 5)
	save_config()


func set_difficulty(value: int, world: WorldState = null) -> void:
	difficulty_setting = clampi(value, 0, 4)
	if world != null:
		world.difficulty = difficulty_setting
	save_config()


## 原作 savePlace 编号 5=成就位；本端口存档槽 0=成就位、1-4=普通位。
func autosave_slot() -> int:
	return 0 if save_place == 5 else save_place - 1
