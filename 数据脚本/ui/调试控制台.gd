extends CanvasLayer

## 沙盒作弊快捷键 + 全局调试控制台。
## 作弊快捷键仅在沙盒难度（world.difficulty == 0）且控制台关闭时生效。
## 控制台用 F12 开关，命令面向玩家/开发者，用于测试事件、战争、数值与关系。

const CONSOLE_TOGGLE_KEY := KEY_F12

## 作弊快捷键：显示值 +10 对应内部原始值 +100（多数数值表按 ×10 存储）。
const CHEAT_DELTA := 100
const RELATION_RESTORE := 1000
const RELATION_BREAK := 0

## 作弊键位表：physical_keycode → 数值表 key
const CHEAT_KEYS := {
	KEY_1: "party_support",
	KEY_2: "people_support",
	KEY_3: "thought_freedom",
	KEY_4: "living_standard",
	KEY_5: "diplo",
	KEY_6: "global_influence",
	KEY_7: "budget",
	KEY_8: "agents",
	KEY_9: "budget_army",
	KEY_0: "relations_both",
	KEY_A: "ussr_toggle",
}

@onready var _output: RichTextLabel = $居中/面板/布局/输出
@onready var _input: LineEdit = $居中/面板/布局/输入行/输入


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_input.text_submitted.connect(_on_输入_text_submitted)
	_print_line("输入 [color=yellow]help[/color] 查看可用命令。")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if key == CONSOLE_TOGGLE_KEY:
			_toggle_console()
			get_viewport().set_input_as_handled()
			return
		if visible:
			return
		# 沙盒作弊快捷键：仅沙盒难度生效，且控制台关闭时不干扰输入框
		if event.ctrl_pressed and not event.shift_pressed and not event.alt_pressed:
			if CHEAT_KEYS.has(key):
				_handle_cheat(key)
				get_viewport().set_input_as_handled()


# ── 控制台开关 ──

func _toggle_console() -> void:
	if visible:
		_close_console()
	else:
		_open_console()


func _open_console() -> void:
	visible = true
	_input.clear()
	call_deferred("_focus_input")


func _close_console() -> void:
	visible = false


func _focus_input() -> void:
	_input.grab_focus()


func _on_关闭_pressed() -> void:
	_close_console()


func _on_执行_pressed() -> void:
	_execute(_input.text)


func _on_输入_text_submitted(_text: String) -> void:
	_execute(_input.text)


# ── 沙盒作弊 ──

func _handle_cheat(key: int) -> void:
	if GameManager == null or GameManager.world == null:
		return
	if GameManager.world.difficulty != 0:
		return
	var w: WorldState = GameManager.world
	var data_key: String = CHEAT_KEYS[key]
	match data_key:
		"relations_both":
			_add_empire_relation(0, CHEAT_DELTA)
			_add_empire_relation(1, CHEAT_DELTA)
			_print_cheat("与美苏关系 +10")
		"ussr_toggle":
			_toggle_ussr_relation()
		_:
			w.add_data_value(data_key, CHEAT_DELTA)
			_print_cheat("%s +10" % data_key)
	w.sync_economy()
	GameManager.notify_stats_changed()


func _add_empire_relation(empire_idx: int, delta: int) -> void:
	var w: WorldState = GameManager.world
	if w == null or empire_idx < 0 or empire_idx >= w.empires.size():
		return
	w.empires[empire_idx].relations = clampi(w.empires[empire_idx].relations + delta, 0, 1000)
	w.mirror_empires_to_data()


func _toggle_ussr_relation() -> void:
	var w: WorldState = GameManager.world
	if w == null or w.empires.size() < 2:
		return
	var ussr := w.empires[1]
	if ussr.relations >= 600:
		ussr.relations = RELATION_BREAK
		_print_cheat("与苏联关系：破裂")
	else:
		ussr.relations = RELATION_RESTORE
		_print_cheat("与苏联关系：恢复")
	w.mirror_empires_to_data()


func _print_cheat(text: String) -> void:
	if visible:
		_print_line("[color=aqua][沙盒] %s[/color]" % text)


# ── 命令执行 ──

func _execute(line: String) -> void:
	var text := line.strip_edges()
	if text.is_empty():
		return
	_input.clear()
	_print_line("> " + text)
	var parts := text.split(" ", false)
	var cmd: String = parts[0].to_lower()
	match cmd:
		"help":
			_print_help()
		"clear":
			_output.clear()
		"close":
			_close_console()
		"stat", "set", "add":
			_cmd_stat(parts)
		"event":
			_cmd_event(parts)
		"war":
			_cmd_war(parts)
		"relations":
			_cmd_relations(parts)
		"date":
			_cmd_date(parts)
		"list_events":
			_cmd_list_events()
		"list_wars":
			_cmd_list_wars()
		_:
			_print_line("[color=red]未知命令：%s（输入 help 查看帮助）[/color]" % cmd)


func _cmd_stat(parts: Array) -> void:
	if parts.size() < 3:
		_print_line("[color=yellow]用法：stat <键名> <值|+增量|-增量>[/color]")
		return
	var w: WorldState = GameManager.world if GameManager else null
	if w == null:
		_print_line("[color=red]当前没有活动世界。[/color]")
		return
	var key: String = parts[1]
	var val_text: String = parts[2]
	if w.get_data_index(key) < 0 and key.to_lower() not in ["war", "war_state", "influence_prc"]:
		_print_line("[color=red]未知键名：%s[/color]" % key)
		return
	if val_text.begins_with("+") or val_text.begins_with("-"):
		w.add_data_value(key, int(val_text))
	else:
		w.set_data_value(key, int(val_text))
	w.sync_economy()
	GameManager.notify_stats_changed()
	_print_line("[color=green]已设置 %s = %s[/color]" % [key, val_text])


func _cmd_event(parts: Array) -> void:
	if parts.size() < 2:
		_print_line("[color=yellow]用法：event <事件id>[/color]")
		return
	if GameManager == null or EventEngine == null:
		_print_line("[color=red]事件系统未就绪。[/color]")
		return
	var event_id: String = parts[1]
	if EventEngine.get_event(event_id) == null:
		_print_line("[color=red]未找到事件：%s[/color]" % event_id)
		return
	GameManager.start_event(event_id)
	_print_line("[color=green]已触发事件：%s[/color]" % event_id)


func _cmd_war(parts: Array) -> void:
	if parts.size() < 2:
		_print_line("[color=yellow]用法：war <战争id>[/color]")
		return
	if GameManager == null:
		_print_line("[color=red]GameManager 未就绪。[/color]")
		return
	var war_id := int(parts[1])
	if GameManager.debug_start_war(war_id):
		_print_line("[color=green]已开始战争：%d[/color]" % war_id)
	else:
		_print_line("[color=red]战争 %d 启动失败（可能已在进行或 id 无效）。[/color]" % war_id)


func _cmd_relations(parts: Array) -> void:
	if parts.size() < 3:
		_print_line("[color=yellow]用法：relations <usa|ussr> <0-1000>[/color]")
		return
	var w: WorldState = GameManager.world if GameManager else null
	if w == null:
		_print_line("[color=red]当前没有活动世界。[/color]")
		return
	var target: String = parts[1].to_lower()
	var idx := -1
	if target in ["usa", "美", "美国"]:
		idx = 0
	elif target in ["ussr", "苏", "苏联"]:
		idx = 1
	else:
		_print_line("[color=red]目标必须是 usa 或 ussr。[/color]")
		return
	if idx < 0 or idx >= w.empires.size():
		_print_line("[color=red]对应帝国数据不存在。[/color]")
		return
	w.empires[idx].relations = clampi(int(parts[2]), 0, 1000)
	w.mirror_empires_to_data()
	GameManager.notify_stats_changed()
	_print_line("[color=green]已设置 %s 关系 = %s[/color]" % [parts[1], parts[2]])


func _cmd_date(parts: Array) -> void:
	if parts.size() < 4:
		_print_line("[color=yellow]用法：date <年> <月> <日>[/color]")
		return
	var w: WorldState = GameManager.world if GameManager else null
	if w == null or w.date == null:
		_print_line("[color=red]当前没有活动世界。[/color]")
		return
	w.date.year = clampi(int(parts[1]), 1976, 2030)
	w.date.month = clampi(int(parts[2]), 1, 12)
	w.date.day = clampi(int(parts[3]), 1, 31)
	w.数值表[WorldState.I_YEAR] = w.date.year
	w.数值表[WorldState.I_MONTH] = w.date.month
	w.数值表[WorldState.I_DAY] = w.date.day
	GameManager.notify_stats_changed()
	_print_line("[color=green]已设置日期：%s[/color]" % w.date.format())


func _cmd_list_events() -> void:
	if EventEngine == null or not EventEngine.has_method("get_all_event_ids"):
		_print_line("[color=red]事件系统未提供事件列表。[/color]")
		return
	var ids: Array = EventEngine.get_all_event_ids()
	ids.sort()
	_print_line("[color=yellow]共 %d 个事件：[/color]" % ids.size())
	_print_line("、".join(ids))


func _cmd_list_wars() -> void:
	var ids := WarCatalog.all_ids()
	var parts: Array[String] = []
	for id in ids:
		parts.append(str(id))
	_print_line("[color=yellow]共 %d 个战争：[/color]" % ids.size())
	_print_line("、".join(parts))


# ── 输出 ──

func _print_line(text: String) -> void:
	_output.append_text(text + "\n")


func _print_help() -> void:
	_print_line("""
[color=yellow]===== 调试控制台命令 =====[/color]
[color=green]help[/color]                   显示本帮助
[color=green]clear[/color]                 清空输出
[color=green]close[/color]                 关闭控制台
[color=green]stat <键名> <值>[/color]      设置数值（例：stat budget 9999）
[color=green]stat <键名> +增量[/color]     增加数值（例：stat party_support +100）
[color=green]stat <键名> -增量[/color]     减少数值（例：stat living_standard -50）
[color=green]event <事件id>[/color]        触发事件（例：event death_of_mao）
[color=green]war <战争id>[/color]          强制开始战争（例：war 0）
[color=green]relations <usa|ussr> <0-1000>[/color]  设置美/苏关系
[color=green]date <年> <月> <日>[/color]   设置日期
[color=green]list_events[/color]           列出全部事件 id
[color=green]list_wars[/color]             列出全部战争 id

[color=yellow]===== 沙盒作弊快捷键（仅沙盒难度）=====[/color]
左Ctrl+1~9、0：党支持/民支持/思想/生活/国际声望/全球影响/预算/特工/军费/美苏关系 +10
左Ctrl+A：与苏联关系 恢复/破裂 切换
""")
