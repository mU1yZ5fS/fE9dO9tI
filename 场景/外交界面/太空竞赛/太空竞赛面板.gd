extends CanvasLayer
## 太空竞赛作战室 —— 只读态势面板。
## 纯展示：仅读取 TechState / completed_event_ids / science / date，
## 不写入任何状态，不改动既有逻辑代码。

const TECH_FIRST := 27
const TECH_COUNT := 7
const TECH_NAMES: Array[String] = [
	"通讯卫星", "导航卫星", "军事卫星",
	"载人航天", "行星际飞行器", "轨道空间站", "航天飞机",
]

const EVENT_ORDER: Array[String] = [
	"event_352", "event_353", "event_354", "event_355",
	"event_356", "event_357", "event_358", "event_359",
	"event_360", "event_361", "event_362", "event_363",
	"event_364", "event_648",
]

const EVENT_RESULTS := {
	"event_352": ["西昌复工", "太原落成", "双心并建", "放弃"],
	"event_353": ["长三长四", "全线开工", "仅长征二号"],
	"event_354": ["近地轨道网", "同步卫星", "接入外网"],
	"event_355": ["北斗启动", "搁置推迟"],
	"event_356": ["FSW改装", "神舟问世", "再次下马"],
	"event_357": ["多座飞船", "无人优先"],
	"event_358": ["站器双发", "仅飞行器"],
	"event_359": ["站器双发", "仅飞行器"],
	"event_360": ["突击登月", "长期月基"],
	"event_361": ["双任务全上", "采样返回线", "仅月球车"],
	"event_362": ["火星着陆", "轨道探测器", "放弃"],
	"event_363": ["自建天宫", "中苏黎明号", "不建"],
	"event_364": ["轻型空天机", "重型空天机", "放弃"],
	"event_648": ["长庚返回", "杜环绕轨", "放弃"],
}

const COL_DONE := Color("39ff6a")
const COL_RUN := Color("ffd23f")
const COL_LOCK := Color("5c6570")
const COL_READY := Color("9fe8ff")
const COL_PEND := Color("45505c")
const COL_RESULT := Color("ffcf5c")

var _bars: Array[ProgressBar] = []
var _stats: Array[Label] = []
var _icons: Array[TextureRect] = []
var _gm: Node = null

@onready var _读数日期: Label = %读数日期
@onready var _读数科研点: Label = %读数科研点
@onready var _读数项目: Label = %读数项目
@onready var _读数总进度: Label = %读数总进度
@onready var _总进度条: ProgressBar = %总进度条


func _ready() -> void:
	for k in TECH_COUNT:
		var idx := TECH_FIRST + k
		_bars.append(get_node("%%条%d" % idx))
		_stats.append(get_node("%%态%d" % idx))
		_icons.append(get_node("%%图%d" % idx))
	_gm = get_node_or_null("/root/GameManager")
	if _gm != null:
		_gm.tech_completed.connect(_on_tech_completed)
	_refresh()


func open() -> void:
	visible = true
	_refresh()
	var t: Timer = $刷新计时器
	t.start()
	if has_animation("开窗"):
		play("开窗")


func close() -> void:
	visible = false
	$刷新计时器.stop()


func has_animation(anim_name: String) -> bool:
	return $动画机.has_animation(StringName(anim_name))


func play(anim_name: String) -> void:
	$动画机.play(StringName(anim_name))


func _on_刷新计时器_timeout() -> void:
	_refresh()


func _on_tech_completed(_tech_id: int) -> void:
	_refresh()


func _on_遮罩_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()


# ── 刷新：全部为只读取值 ─────────────────────────────────────

func _refresh() -> void:
	if _gm == null or not is_instance_valid(_gm):
		_gm = get_node_or_null("/root/GameManager")
	if _gm == null or _gm.world == null or _gm.world.techs == null:
		读数待机()
		return
	var w = _gm.world
	var ts = w.techs

	_读数日期.text = w.date.format() if w.date != null else "----"
	_读数科研点.text = str(w.science)

	if ts.active_slot >= 0 and ts.active_slot >= TECH_FIRST and ts.active_slot < TECH_FIRST + TECH_COUNT:
		_读数项目.text = "在研：" + TECH_NAMES[ts.active_slot - TECH_FIRST]
	elif ts.active_slot >= 0:
		_读数项目.text = "在研：非航天项目"
	else:
		_读数项目.text = "当前无在研项目"

	var unlocked_space := 0
	for k in TECH_COUNT:
		if ts.unlocked.size() > TECH_FIRST + k and ts.unlocked[TECH_FIRST + k]:
			unlocked_space += 1
		_update_tech_row(ts, k)

	var events_done := 0
	for id in EVENT_ORDER:
		var done: bool = w.completed_event_ids.has(id)
		var dot: ColorRect = get_node("%%点%s" % id.substr(6))
		var res_label: Label = get_node("%%果%s" % id.substr(6))
		if done:
			events_done += 1
			dot.color = COL_DONE
			var ri := int(w.completed_event_ids.get(id, -1))
			var table: Array = EVENT_RESULTS.get(id, [])
			if ri >= 0 and ri < table.size():
				res_label.text = "▶ " + str(table[ri])
				res_label.add_theme_color_override("font_color", COL_RESULT)
			else:
				res_label.text = "▶ 已完成"
				res_label.add_theme_color_override("font_color", COL_RESULT)
		else:
			dot.color = COL_PEND
			res_label.text = "—— 待触发 ——"
			res_label.add_theme_color_override("font_color", COL_LOCK)

	var pct := unlocked_space * 70.0 / TECH_COUNT + events_done * 30.0 / EVENT_ORDER.size()
	_总进度条.value = pct
	_读数总进度.text = "%.1f%%" % pct


func 读数待机() -> void:
	_读数日期.text = "等待世界状态"
	_读数科研点.text = "0"
	_读数项目.text = "——"
	_读数总进度.text = "0.0%"


func _update_tech_row(ts, k: int) -> void:
	var idx := TECH_FIRST + k
	var bar := _bars[k]
	var stat := _stats[k]
	var icon := _icons[k]
	var req := int(ts.required_time[idx]) if idx < ts.required_time.size() else 1
	var done: bool = ts.unlocked.size() > idx and ts.unlocked[idx]

	bar.max_value = req
	if done:
		bar.value = req
		stat.text = "已解锁"
		stat.add_theme_color_override("font_color", COL_DONE)
		icon.self_modulate.a = 1.0
	elif ts.in_progress.size() > idx and ts.in_progress[idx]:
		var elapsed := int(ts.elapsed_time[idx]) if idx < ts.elapsed_time.size() else 0
		bar.value = elapsed
		stat.text = "研究中 %d/%d" % [elapsed, req]
		stat.add_theme_color_override("font_color", COL_RUN)
		icon.self_modulate.a = 0.85
	else:
		var dep := int(ts.TECH_DEPENDENCY[idx]) if idx < ts.TECH_DEPENDENCY.size() else -1
		var dep_ready := true
		var dep_name := ""
		if dep >= 0:
			dep_ready = ts.unlocked.size() > dep and ts.unlocked[dep]
			if not dep_ready and dep >= TECH_FIRST and dep < TECH_FIRST + TECH_COUNT:
				dep_name = TECH_NAMES[dep - TECH_FIRST]
		bar.value = 0
		icon.self_modulate.a = 0.30
		if dep_ready:
			stat.text = "可研究"
			stat.add_theme_color_override("font_color", COL_READY)
		elif dep_name.is_empty():
			stat.text = "锁定"
			stat.add_theme_color_override("font_color", COL_LOCK)
		else:
			stat.text = "需先解锁：" + dep_name
			stat.add_theme_color_override("font_color", COL_LOCK)
