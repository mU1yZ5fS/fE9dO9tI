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


func save_config() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "voice_china", voice)
	cfg.set_value("settings", "SavePosition", autosave_mode)
	cfg.set_value("settings", "SavePlaceNum", save_place)
	cfg.set_value("settings", "our_diff_in", difficulty_setting)
	for action in TIME_SHORTCUT_ACTIONS:
		cfg.set_value("time_shortcuts", action, int(time_shortcut_keys.get(action, TIME_SHORTCUT_DEFAULTS[action])))
	if cfg.save(SETTINGS_PATH) != OK:
		push_error("SettingsService: 设置写入失败 " + SETTINGS_PATH)


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
	var code := get_time_shortcut_key(action)
	if code == 0:
		return "未设置"
	var label_key := DisplayServer.keyboard_get_label_from_physical(code as Key)
	return OS.get_keycode_string(label_key)


## 设置界面重绑入口：写入内存 + 立即改 InputMap + 持久化。
func rebind_time_shortcut(action: String, physical_keycode: int) -> void:
	if not TIME_SHORTCUT_ACTIONS.has(action) or physical_keycode == 0:
		return
	time_shortcut_keys[action] = physical_keycode
	apply_time_shortcuts()
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
