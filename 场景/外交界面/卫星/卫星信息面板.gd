extends CanvasLayer

## 东方红一号卫星信息面板 — 霓虹灯/Synthwave 风格
## 节点全部在 外交.tscn 中布局，本脚本只做逻辑。
##
## 信息文案随玩家路线（政体地图配色）切换：
##   蓝线（自由主义政体）→ 只剩一句冷冰冰的描述，蓝字；
##   黑线（革命民族主义，即 CountryData.EXTREMIST_SUBS）→ 保留基本数据，结语换成"补充"版；
##   其余路线但无"毛主义的坚实壁垒"修正 → 保留基本数据，结语改为平实总结；
##   默认（有壁垒的红/绿/灰线）→ 维持原版红色文案。

const MARKER_SIZE := 8.0

const _BASIC_DATA := """[color=#FF1A00CC]◈  基本信息[/color]
[color=#FF1A00CC]名称：东方红一号 (DFH-1)[/color]
[color=#FF1A00CC]发射日期：1970年4月24日[/color]
[color=#FF1A00CC]运载火箭：长征一号[/color]
[color=#FF1A00CC]质量：173 公斤[/color]

[color=#FF1A00CC]◈ 轨道参数[/color]
[color=#FF1A00CC]近地点高度：441 公里[/color]
[color=#FF1A00CC]远地点高度：2,386 公里[/color]
[color=#FF1A00CC]轨道倾角：68.5°[/color]
[color=#FF1A00CC]运行周期：114 分钟[/color]
"""

const _INFO_DEFAULT := _BASIC_DATA + """
[color=#FF1A00CC]宇宙高歌东方红![/color]"""

const _INFO_BLACK_LINE := _BASIC_DATA + """
[color=#FF1A00CC]东方红 固然很好，但往往需要英明领袖与张维为同志加以补充[/color]"""

const _INFO_NO_BULWARK := _BASIC_DATA + """
[color=#FF1A00CC]我国人造卫星事业从无到有的跨越。[/color]"""

## 蓝色同 世界地图渲染.gd 的 GOV_LIBERAL（Color(0.10, 0.24, 0.74)）。
const _INFO_BLUE_LINE := "[color=#1A3DBD]一颗多余且占用宝贵轨道资源的老旧卫星，仅此而已[/color]"

var _satellite: Node3D
var _camera: Camera3D
var _is_open := false
var _tween: Tween
var _dragging := false
var _drag_offset := Vector2.ZERO

@onready var _line_glow: Line2D = $连接线发光
@onready var _line_core: Line2D = $连接线
@onready var _marker: Line2D = $标记
@onready var _panel: PanelContainer = $面板
@onready var _audio: AudioStreamPlayer = $音乐


func _ready() -> void:
	var root := get_parent()
	_satellite = root.get_node_or_null("东方红轨道/东方红一号")
	var cam_pivot := root.get_node_or_null("相机枢轴")
	if cam_pivot:
		_camera = cam_pivot.get_node_or_null("SpringArm3D/Camera3D")
	if _satellite and _satellite.has_signal("satellite_clicked"):
		_satellite.satellite_clicked.connect(_toggle)
	$面板/Margin/VBox/关闭按钮.pressed.connect(_toggle)
	_panel.gui_input.connect(_on_panel_gui_input)
	_set_visible(false)


func _process(_delta: float) -> void:
	if not _is_open or _satellite == null or _camera == null:
		return
	if not _camera.is_inside_tree():
		return
	_update_line()


func _toggle() -> void:
	_is_open = not _is_open
	if _is_open:
		_show_panel()
	else:
		_hide_panel()


## 按玩家当前路线刷新卫星简介（每次展开面板时重算，路线中途变化也能生效）。
func _refresh_info_text() -> void:
	var info := $面板/Margin/VBox/信息 as RichTextLabel
	if info == null:
		return
	info.text = _political_line_info_bbcode()


func _political_line_info_bbcode() -> String:
	var pc := _player_country()
	if pc == null:
		return _INFO_DEFAULT
	if pc.government == GameConstants.Government.LIBERAL:
		return _INFO_BLUE_LINE
	if pc.sub_government in CountryData.EXTREMIST_SUBS:
		return _INFO_BLACK_LINE
	if not _mod_active(GameConstants.Modifier.MAOIST_BULWARK):
		return _INFO_NO_BULWARK
	return _INFO_DEFAULT


## 同 game_manager.gd/_mod_active：modifiers[idx] != null 且 is_active。
func _mod_active(idx: int) -> bool:
	var mods: Array = GameManager.world.modifiers
	return idx >= 0 and idx < mods.size() and mods[idx] != null and mods[idx].is_active


func _player_country() -> CountryData:
	if GameManager == null or GameManager.world == null:
		return null
	return GameManager.world.get_player_country()


func _show_panel() -> void:
	_refresh_info_text()
	_set_visible(true)
	_panel.modulate = Color(1, 1, 1, 0)
	_panel.scale = Vector2(0.9, 0.9)
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_panel, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_panel, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	if _audio and not _audio.playing:
		_audio.play()


func _hide_panel() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_panel, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN)
	_tween.tween_callback(_set_visible.bind(false)).set_delay(0.2)
	if _audio and _audio.playing:
		_audio.stop()


func _set_visible(v: bool) -> void:
	_line_glow.visible = v
	_line_core.visible = v
	_marker.visible = v
	_panel.visible = v


func _update_line() -> void:
	var sat_pos_3d := _satellite.global_position
	if _camera.is_position_behind(sat_pos_3d):
		_line_glow.visible = false
		_line_core.visible = false
		_marker.visible = false
		return
	_line_glow.visible = true
	_line_core.visible = true
	_marker.visible = true

	var sat_2d := _camera.unproject_position(sat_pos_3d)
	var panel_anchor := _panel.global_position + Vector2(0.0, _panel.size.y * 0.5)

	for line in [_line_glow, _line_core]:
		line.clear_points()
		line.add_point(sat_2d)
		line.add_point(panel_anchor)

	_marker.clear_points()
	var s := MARKER_SIZE
	_marker.add_point(sat_2d + Vector2(0, -s))
	_marker.add_point(sat_2d + Vector2(s, 0))
	_marker.add_point(sat_2d + Vector2(0, s))
	_marker.add_point(sat_2d + Vector2(-s, 0))
	_marker.add_point(sat_2d + Vector2(0, -s))


func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_dragging = true
				_drag_offset = _panel.global_position - mb.global_position
			else:
				_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		_panel.global_position = (event as InputEventMouseMotion).global_position + _drag_offset
