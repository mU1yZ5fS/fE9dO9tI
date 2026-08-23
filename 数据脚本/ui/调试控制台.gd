extends CanvasLayer

## 沙盒作弊快捷键 + 全局调试控制台。
## 作弊快捷键仅在沙盒难度（world.difficulty == 0）且控制台关闭时生效。
## 控制台可通过设置里的“调试控制台开关”启用，默认 F12 呼出。
## 命令面向玩家/开发者，用于测试事件、战争、数值、政策与关系。

## 作弊快捷键：显示值 +10 对应内部原始值 +100（多数数值表按 ×10 存储）。
const CHEAT_DELTA := 100
const RELATION_RESTORE := 1000
const RELATION_BREAK := 0

## 作弊动作显示名（帮助/设置页复用）。
const CHEAT_ACTION_NAMES := {
	"party_support": "党支持",
	"people_support": "民众支持",
	"thought_freedom": "思想自由",
	"living_standard": "生活水平",
	"diplo": "国际声望",
	"influence_prc": "国际影响力",
	"budget": "预算",
	"agents": "特工",
	"army": "军力",
	"relations_both": "美苏关系",
	"ussr_toggle": "中苏关系切换",
	"diplo_down": "外交声望-10",
	"mil_add": "军事介入点+10",
}

@onready var _output: RichTextLabel = $居中/面板/布局/输出
@onready var _input: LineEdit = $居中/面板/布局/输入行/输入

## claim 指令的控制台侧记忆：默认 false，保证第一次输入显示“开启”。
var _last_claim_mode: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# 控制台改用引擎默认字体：项目全局字体不区分大小写，影响命令/事件 ID 识别。
	# RichTextLabel/LineEdit 的字体 override 名称不同，分别设置。
	if _output:
		_output.add_theme_font_override("normal_font", ThemeDB.fallback_font)
	if _input:
		_input.add_theme_font_override("font", ThemeDB.fallback_font)
	_input.text_submitted.connect(_on_输入_text_submitted)
	_print_line("输入 [color=yellow]help[/color] 查看可用命令。")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		var toggle_key: int = GameManager.debug_console_toggle_key if GameManager != null else KEY_F12
		if key == toggle_key:
			# 只有设置里的“调试控制台”开关开启后才允许打开；关闭时顺带收起已打开的控制台。
			if GameManager == null or GameManager.debug_console_enabled:
				_toggle_console()
			elif visible:
				_close_console()
			get_viewport().set_input_as_handled()
			return
		if visible:
			return
		# 沙盒作弊快捷键：仅沙盒难度生效，且控制台关闭时不干扰输入框
		if event.ctrl_pressed and not event.shift_pressed and not event.alt_pressed:
			var action := _cheat_key_to_action(key)
			if action != "":
				_handle_cheat(action)
				get_viewport().set_input_as_handled()


func _cheat_key_to_action(key: int) -> String:
	if GameManager == null:
		return ""
	for action in SettingsService.CHEAT_SHORTCUT_ACTIONS:
		if GameManager.get_cheat_hotkey_key(action) == key:
			return action
	return ""


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

func _handle_cheat(action: String) -> void:
	if GameManager == null or GameManager.world == null:
		return
	if GameManager.world.difficulty != 0:
		return
	var w: WorldState = GameManager.world
	var data_key: String = action
	match data_key:
		"relations_both":
			_add_empire_relation(0, CHEAT_DELTA)
			_add_empire_relation(1, CHEAT_DELTA)
			_print_cheat("与美苏关系 +10")
		"ussr_toggle":
			_toggle_ussr_relation()
		"diplo_down":
			w.add_data_value("diplo", -CHEAT_DELTA)
			_print_cheat("外交声望 -10")
		"mil_add":
			w.add_data_value("mil_intervention", CHEAT_DELTA)
			_print_cheat("军事介入点 +10")
		"influence_prc":
			w.add_data_value("influence_prc", CHEAT_DELTA)
			_print_cheat("国际影响力 +10")
		_:
			w.add_data_value(data_key, CHEAT_DELTA)
			_print_cheat("%s +10" % CHEAT_ACTION_NAMES.get(data_key, data_key))
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
	# 原版沙盒 Ctrl+A 只切换 relres（中苏关系是否恢复正常化）标志，
	# 不改 empires[1].relations 数值。
	var new_relres := not w.get_flag("relres")
	w.set_flag("relres", new_relres)
	if new_relres:
		_print_cheat("与苏联关系：恢复")
	else:
		_print_cheat("与苏联关系：破裂")
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
		"diplo", "外交声望", "声望":
			_cmd_diplo(parts)
		"mil", "intervention", "介入", "军事介入":
			_cmd_mil(parts)
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
		"start_all_wars", "all_wars", "allwar":
			_cmd_start_all_wars()
		"claim", "claim_territory", "take_land":
			_cmd_claim_territory()
		"list_countries", "国家列表":
			_cmd_list_countries()
		"country", "国家":
			_cmd_country(parts)
		"policy", "政策", "player_policy":
			_cmd_policy(parts)
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


func _cmd_diplo(parts: Array) -> void:
	if parts.size() < 2:
		# 不带参数时默认降低 10 点外交声望
		_cmd_tenfold_stat("diplo", "外交声望", ["diplo", "-10"])
	else:
		_cmd_tenfold_stat("diplo", "外交声望", parts)


func _cmd_mil(parts: Array) -> void:
	if parts.size() < 2:
		# 不带参数时默认增加 10 点军事介入点
		_cmd_tenfold_stat("mil_intervention", "军事介入点", ["mil", "+10"])
	else:
		_cmd_tenfold_stat("mil_intervention", "军事介入点", parts)


## 显示值命令：内部多数数值按 ×10 存储，这里把用户输入按显示值自动 ×10。
func _cmd_tenfold_stat(key: String, label: String, parts: Array) -> void:
	if parts.size() < 2:
		_print_line("[color=yellow]用法：%s <值|+增量|-增量>（显示值，内部自动 ×10）[/color]" % parts[0])
		return
	var w: WorldState = GameManager.world if GameManager else null
	if w == null:
		_print_line("[color=red]当前没有活动世界。[/color]")
		return
	if w.get_data_index(key) < 0:
		_print_line("[color=red]未知键名：%s[/color]" % key)
		return
	var val_text: String = parts[1]
	if val_text.begins_with("+") or val_text.begins_with("-"):
		w.add_data_value(key, int(val_text) * 10)
	else:
		w.set_data_value(key, int(val_text) * 10)
	w.sync_economy()
	GameManager.notify_stats_changed()
	_print_line("[color=green]已设置 %s = %s[/color]" % [label, val_text])


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
	w.year = w.date.year
	w.month = w.date.month
	w.day = w.date.day
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


# ── 新增调试命令：全部战争 / 点击归中国 / 国家数据 ──

func _cmd_start_all_wars() -> void:
	if GameManager == null or GameManager.world == null:
		_print_line("[color=red]当前没有活动世界。[/color]")
		return
	var ids := WarCatalog.all_ids()
	var started := 0
	for war_id in ids:
		if GameManager.debug_start_war(war_id):
			started += 1
	GameManager.notify_stats_changed()
	_print_line("[color=green]已尝试开启全部 %d 场战争，成功 %d。[/color]" % [ids.size(), started])


func _cmd_claim_territory() -> void:
	var earth := get_tree().root.find_child("地球", true, false)
	if earth == null:
		_print_line("[color=red]未找到世界地图（地球）节点，请先进入世界地图/外交界面。[/color]")
		return
	if not earth.has_method("set_test_mode_enabled"):
		_print_line("[color=red]当前场景不支持领土标记模式。[/color]")
		return
	# 用控制台自身状态切换，不依赖地图节点可能残留的 is_test_mode_enabled，
	# 保证第一次输入一定是“开启”。
	var enabled := not _last_claim_mode
	_last_claim_mode = enabled
	earth.set_test_mode_enabled(enabled)
	_print_line("[color=green]点击划归中国模式：%s。关闭控制台后点击地图即可。[/color]" % ("开启" if enabled else "关闭"))


func _cmd_list_countries() -> void:
	var w: WorldState = GameManager.world if GameManager else null
	if w == null:
		_print_line("[color=red]当前没有活动世界。[/color]")
		return
	var list: Array[CountryData] = []
	for c in w.countries:
		if c != null:
			list.append(c)
	list.sort_custom(func(a: CountryData, b: CountryData) -> bool: return a.gwcode < b.gwcode)
	_print_line("[color=yellow]共 %d 个国家：[/color]" % list.size())
	_print_line("gwcode | 原版 | 中文名")
	for c in list:
		_print_line("%d | %d | %s" % [c.gwcode, c.原版序号, c.display_name()])


func _cmd_country(parts: Array) -> void:
	if parts.size() < 2:
		_print_help_country()
		return
	var w: WorldState = GameManager.world if GameManager else null
	if w == null:
		_print_line("[color=red]当前没有活动世界。[/color]")
		return
	var country := _find_country(w, String(parts[1]))
	if country == null:
		_print_line("[color=red]找不到国家：%s[/color]" % parts[1])
		return
	var sub := String(parts[2]).to_lower() if parts.size() > 2 else "info"
	match sub:
		"info", "show", "查看":
			_print_country_info(country)
		"gov", "government", "政体":
			_cmd_country_set_int(country, parts, "government", 0, 3, "政体")
		"sub", "ideology", "子意识形态":
			_cmd_country_set_int(country, parts, "sub_government", 0, 22, "子意识形态")
		"sphere", "influence", "阵营", "影响":
			_cmd_country_sphere(country, parts)
		"sov", "usa", "prc", "fre":
			_cmd_country_power(country, parts)
		"puppet", "傀儡":
			_cmd_country_puppet(w, country, parts)
		"tag", "标签":
			_cmd_country_tag(country, parts)
		_:
			_print_line("[color=red]未知国家字段：%s[/color]" % parts[2])
			_print_help_country()


func _find_country(w: WorldState, query: String) -> CountryData:
	var q := query.strip_edges()
	# 统一：控制台里裸数字一律按 gwcode 解析（国名不受影响）。
	# 若要按“原版序号/数组下标”查询，请显式写 legacy:<数字> 或 原版:<数字>。
	if q.is_valid_int():
		return w.get_country_by_gwcode(int(q))
	if q.begins_with("legacy:") or q.begins_with("原版:"):
		var sid := q.substr(q.find(":") + 1).strip_edges()
		if sid.is_valid_int():
			return w.get_country_by_legacy_index(int(sid))
		return null
	if q.begins_with("slot:"):
		var slot := q.substr(q.find(":") + 1).strip_edges()
		if slot.is_valid_int():
			return w.get_country_by_slot(int(slot))
		return null
	var c := w.resolve_country(q)
	if c != null:
		return c
	for cd in w.countries:
		if cd == null:
			continue
		if cd.chinese_name == q or cd.name == q or cd.display_name() == q:
			return cd
		if cd.chinese_name.contains(q) or cd.name.contains(q) or cd.display_name().contains(q):
			return cd
	return null


func _print_country_info(c: CountryData) -> void:
	var sphere_names := {
		CountryData.SPHERE_USA: "美国",
		CountryData.SPHERE_USSR: "苏联",
		CountryData.SPHERE_CHINA: "中国",
		CountryData.SPHERE_NEUTRAL: "中立",
		CountryData.SPHERE_FRANCE: "法国",
		CountryData.SPHERE_SOUTH_AFRICA: "南非",
		CountryData.SPHERE_AUSTRALIA: "澳大利亚",
		CountryData.SPHERE_TURKEY: "土耳其",
	}
	_print_line("[color=yellow]%s[/color] gwcode=%d 原版=%d" % [c.display_name(), c.gwcode, c.原版序号])
	_print_line("政体=%s(%d) 子意识形态=%s(%d)" % [
		CountryData.GOV_NAME.get(c.government, "未知"),
		c.government,
		c.ideology_name(),
		c.sub_government,
	])
	_print_line("势力圈=%s sov=%d usa=%d prc=%d fre=%d" % [
		sphere_names.get(c.in_sphere_of_influence(), "中立"),
		c.sov_power,
		c.usa_power,
		c.prc_power,
		c.fre_power,
	])
	_print_line("傀儡=slot %d 稳定=%d 发展=%d" % [c.puppet_of, c.stability, c.development])


func _cmd_country_set_int(c: CountryData, parts: Array, field: String, min_v: int, max_v: int, label: String) -> void:
	if parts.size() < 4:
		_print_line("[color=yellow]用法：country <国家> %s <0-%d>[/color]" % [parts[2], max_v])
		return
	var v := int(parts[3])
	if v < min_v or v > max_v:
		_print_line("[color=red]%s 需在 %d-%d 之间。[/color]" % [label, min_v, max_v])
		return
	c.set(field, v)
	_print_line("[color=green]%s %s -> %d[/color]" % [c.display_name(), label, v])


func _cmd_country_sphere(c: CountryData, parts: Array) -> void:
	if parts.size() < 4:
		_print_line("[color=yellow]用法：country <国家> sphere <中国|美国|苏联|法国|中立>[/color]")
		return
	var s := String(parts[3])
	c.set_tag("亲中", false)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)
	c.set_tag("亲法", false)
	match s:
		"中国", "china", "prc":
			c.set_tag("亲中", true)
		"美国", "usa", "美":
			c.set_tag("亲美", true)
		"苏联", "ussr", "sov", "苏":
			c.set_tag("亲苏", true)
		"法国", "france", "fre":
			c.set_tag("亲法", true)
		"中立", "neutral", "none":
			pass
		_:
			_print_line("[color=red]未知势力：%s[/color]" % s)
			return
	GameManager.notify_stats_changed()
	_print_line("[color=green]%s 势力圈 -> %s[/color]" % [c.display_name(), s])


func _cmd_country_power(c: CountryData, parts: Array) -> void:
	if parts.size() < 4:
		_print_line("[color=yellow]用法：country <国家> sov|usa|prc|fre <值>[/color]")
		return
	var field: String = {
		"sov": "sov_power",
		"usa": "usa_power",
		"prc": "prc_power",
		"fre": "fre_power",
	}.get(String(parts[2]).to_lower(), "")
	if field == "":
		_print_line("[color=red]未知影响力字段：%s[/color]" % parts[2])
		return
	var v := int(parts[3])
	c.set(field, v)
	GameManager.notify_stats_changed()
	_print_line("[color=green]%s %s -> %d[/color]" % [c.display_name(), parts[2], v])


func _cmd_country_puppet(w: WorldState, c: CountryData, parts: Array) -> void:
	if parts.size() < 4:
		_print_line("[color=yellow]用法：country <国家> puppet <slot|-1|国家名>[/color]")
		return
	var q := String(parts[3])
	if q == "-1" or q.to_lower() == "none" or q == "独立":
		c.puppet_of = -1
		_print_line("[color=green]%s 已设为独立。[/color]" % c.display_name())
		return
	var target := _find_country(w, q)
	var slot := -1
	if target != null:
		slot = target.slot
	elif q.is_valid_int():
		slot = int(q)
	else:
		_print_line("[color=red]找不到傀儡宗主国：%s[/color]" % q)
		return
	c.puppet_of = slot
	GameManager.notify_stats_changed()
	_print_line("[color=green]%s 傀儡 -> slot %d[/color]" % [c.display_name(), slot])


func _cmd_country_tag(c: CountryData, parts: Array) -> void:
	if parts.size() < 5:
		_print_line("[color=yellow]用法：country <国家> tag <标签> <0|1>[/color]")
		return
	var val := int(parts[4]) != 0
	c.set_tag(String(parts[3]), val)
	GameManager.notify_stats_changed()
	_print_line("[color=green]%s 标签 %s -> %s[/color]" % [c.display_name(), parts[3], "true" if val else "false"])


# ── 玩家政策调整 ──

const POLICY_CATEGORIES := {
	"econ": {"idx": WorldState.I_ECON_SYSTEM, "name": "经济体制", "alias": ["经济", "经济体制", "economy", "economic"]},
	"party": {"idx": WorldState.I_PARTY_SYSTEM, "name": "党政", "alias": ["党政", "政党制度", "party_system"]},
	"press": {"idx": WorldState.I_PRESS_POLICY, "name": "人权/舆论", "alias": ["人权", "舆论", "press"]},
	"territory": {"idx": WorldState.I_TERRITORY, "name": "国家体制", "alias": ["国家体制", "领土", "territory"]},
	"religion": {"idx": WorldState.I_RELIGION, "name": "宗教政策", "alias": ["宗教", "religion"]},
	"military": {"idx": WorldState.I_MIL_DOCTRINE, "name": "军事力量", "alias": ["军事", "军事学说", "military"]},
	"birth": {"idx": WorldState.I_BIRTH_POLICY, "name": "生育政策", "alias": ["生育", "birth"]},
}


func _cmd_policy(parts: Array) -> void:
	var w: WorldState = GameManager.world if GameManager else null
	if w == null:
		_print_line("[color=red]当前没有活动世界。[/color]")
		return
	if parts.size() < 2:
		_print_line("[color=yellow]当前玩家政策：[/color]")
		for key in POLICY_CATEGORIES:
			var c: Dictionary = POLICY_CATEGORIES[key]
			var v: int = w.get_data_by_index(int(c["idx"]))
			_print_line("%s：%d" % [c["name"], v])
		_print_help_policy()
		return
	var query := String(parts[1]).to_lower()
	var cat_key := ""
	var cat: Dictionary = {}
	for key in POLICY_CATEGORIES:
		var c: Dictionary = POLICY_CATEGORIES[key]
		if query == key or query in c["alias"]:
			cat_key = key
			cat = c
			break
	if cat.is_empty():
		_print_line("[color=red]未知政策类别：%s（输入 policy 查看列表）[/color]" % parts[1])
		return
	var idx: int = int(cat["idx"])
	var current: int = w.get_data_by_index(idx)
	if parts.size() < 3:
		_print_line("[color=yellow]%s 当前值：%d（政策数值表索引 %d）[/color]" % [cat["name"], current, idx])
		_print_help_policy()
		return
	var val := int(parts[2])
	if cat_key == "birth":
		GameManager.set_birth_policy(clampi(val, 1, 3))
		_print_line("[color=green]%s 已切换 -> %d[/color]" % [cat["name"], val])
		w.sync_economy()
		GameManager.notify_stats_changed()
		return
	if GameManager.change_policy(idx, val):
		_print_line("[color=green]%s 已切换 -> %d[/color]" % [cat["name"], val])
	else:
		# 调试控制台可直接改数值；若常规政策切换条件不满足，这里强制写入。
		w.set_data_by_index(idx, val)
		_print_line("[color=yellow]常规切换条件未通过，已强制写入 %s = %d[/color]" % [cat["name"], val])
	w.sync_economy()
	GameManager.notify_stats_changed()


func _print_help_policy() -> void:
	_print_line("""
[color=yellow]===== policy 玩家政策调整 =====[/color]
[color=green]policy[/color]                            查看所有政策类别与当前值
[color=green]policy <类别>[/color]                     查看某类政策当前值
[color=green]policy <类别> <值>[/color]                切换/强制写入政策
类别：econ(经济体制) party(党政) press(人权/舆论)
      territory(国家体制) religion(宗教) military(军事) birth(生育)
""")


func _print_help_country() -> void:
	_print_line("""
[color=yellow]===== country 国家调试命令 =====[/color]
[color=green]country <国家> info[/color]                  查看政体/势力圈/影响力
[color=green]country <国家> gov <0-3>[/color]             设置政体（0威权 1社会主义 2改良 3自由）
[color=green]country <国家> sub <0-22>[/color]            设置子意识形态
[color=green]country <国家> sphere <中国|美国|苏联|法国|中立>[/color]  切换势力圈
[color=green]country <国家> sov|usa|prc|fre <值>[/color]  设置大国影响力
[color=green]country <国家> puppet <国家名|-1>[/color]    设置/解除傀儡
[color=green]country <国家> tag <标签> <0|1>[/color]      设置外交/联盟标签
""")


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
[color=green]diplo <值|+增量|-增量>[/color]  设置/增减外交声望（不带参数默认 -10；例：diplo -10）
[color=green]mil <值|+增量|-增量>[/color]   设置/增减军事介入点（不带参数默认 +10；例：mil +10）
[color=green]event <事件id>[/color]        触发事件（例：event death_of_mao）
[color=green]war <战争id>[/color]          强制开始战争（例：war 0）
[color=green]relations <usa|ussr> <0-1000>[/color]  设置美/苏关系
[color=green]date <年> <月> <日>[/color]   设置日期
[color=green]list_events[/color]           列出全部事件 id
[color=green]list_wars[/color]             列出全部战争 id
[color=green]list_countries[/color]        列出全部国家（gwcode/原版序号/名称）
[color=green]start_all_wars[/color]        开启全部战争
[color=green]claim[/color]                 切换“点击地图划归中国”模式
[color=green]country <国家> ...[/color]     查看/修改国家政体、势力圈、影响力（输入 country 查看用法）
[color=green]policy <类别> <值>[/color]     调整玩家政策（输入 policy 查看类别）

[color=yellow]===== 沙盒作弊快捷键（仅沙盒难度）=====[/color]
快捷键在“设置 → 自定义页 → 作弊快捷键”中自定义。
当前默认：左Ctrl+1~9、0：党支持/民支持/思想/生活/国际声望/国际影响力/预算/特工/军力/美苏关系 +10
左Ctrl+D：外交声望 -10
左Ctrl+I：军事介入点 +10
左Ctrl+A：与苏联关系 恢复/破裂 切换
""")
