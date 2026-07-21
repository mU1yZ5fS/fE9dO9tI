extends CanvasLayer

## 状态栏 — 派系界面。

const 外交场景 := "uid://vq6jexkk5tru"
const 经济场景 := "uid://btldk7ul11cqn"
const 科研场景 := "uid://d2qkifpx3o8pl"
const 政治场景 := "uid://dsmslhxc0e8u5"
const 概览场景 := "uid://cj3ye88n40e8y"


func _ready() -> void:
	if not GameManager:
		return
	GameManager.date_changed.connect(func(_d): _refresh())
	GameManager.world_state_loaded.connect(_refresh)
	_connect_nav("世界地图", 外交场景)
	_connect_nav("经济", 经济场景)
	_connect_nav("科学", 科研场景)
	_connect_nav("政治", 政治场景)
	_connect_nav("概览", 概览场景)
	if GameManager.world != null:
		_refresh()


func _refresh() -> void:
	var w := GameManager.world
	if w == null:
		return
	# 刷新前强制从数值表同步显示视图，避免跨场景后读到旧缓存
	w.sync_economy()
	if w.玩家经济 == null:
		return
	var eco := w.玩家经济
	_label("党内支持度", "%.1f" % eco.党内支持度)
	_label("人民支持度", "%.1f" % eco.民众支持度)
	_label("思想自由度", "%.1f" % eco.思想自由度)
	_label("生活水平", "%.1f" % eco.生活水平)
	_label("国际声望", "%.1f" % eco.国际声望)
	_label("特工网络", "%.1f" % (float(eco.特工网络) / 10.0))
	_label("全球影响力", "%.1f" % eco.全球影响力)
	_label("预算", "%.1f" % (float(eco.预算) / 10.0))
	if w.empires.size() >= 2:
		# 关系值内部以 ×10 存储，显示时除以 10
		_label("与美国关系", w.display_relation(w.empires[0].relations))
		_label("与苏联关系", w.display_relation(w.empires[1].relations))


func _label(label_name: String, text: String) -> void:
	var lbl := find_child(label_name, true, false)
	if lbl is Label:
		lbl.text = text


func _connect_nav(btn_name: String, scene_uid: String) -> void:
	var btn := find_child(btn_name, true, false)
	if btn is Button and not btn.pressed.is_connected(_goto):
		btn.pressed.connect(_goto.bind(scene_uid))


func _goto(scene_uid: String) -> void:
	音频总管.play_button_click_sound()
	get_tree().change_scene_to_file(scene_uid)
