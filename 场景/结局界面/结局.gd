extends Control

## 结局场景主控 — 复刻原版 Ending.unity + EndingScript.cs + SwitchEndingScript.cs + EngingDLCController.cs 的交互。
## 权威出处：
##   - 分流：EndingScript.cs Awake/DoneEnding L6-55（data[35]<=0 → GoodEnd + 轮播；data[35]>0 → BadEnding，箭头与 DLC 开关销毁）。
##   - 本体轮播：EndingScript.cs OnMouseDown L1025-1042（number_of_e 0..17 循环，中文分支 L1043-3126）。
##   - DLC 面板：Ending.unity 三个 EngingDLCController（folder_name/max_pages/end1 数组）与 SwitchEndingScript.cs（num 0-3 切换面板）。
##   - 长文滚动：EndingScript.cs Update L4144-4194（UpArrow/DownArrow 移动 Name/Text），Godot 用 RichTextLabel 自带 VScrollBar。
##   - 折行：EndingScript.cs Text L4077-4121（'|'→换行，91 列空格处折行）→ Godot RichTextLabel autowrap_mode=3 + '|'→'\n'。
## 数据接口：结局内容_*.gd（见 工作记录/结局对齐规范.md 第2节）。
## 批D 已收口：data[35] 事件触发点由 GameManager.queue_ending_after_event 统一接线；
## achievements 结局成就仍为 注（见成就对齐台账）。

const 胜利内容 := preload("res://场景/结局界面/结局内容_本体_胜利.gd")
const 轮播1 := preload("res://场景/结局界面/结局内容_本体_轮播1.gd")
const 轮播2 := preload("res://场景/结局界面/结局内容_本体_轮播2.gd")
const 轮播3 := preload("res://场景/结局界面/结局内容_本体_轮播3.gd")
const 坏结局 := preload("res://场景/结局界面/结局内容_坏结局.gd")
const DLC1 := preload("res://场景/结局界面/结局内容_DLC1.gd")
const DLC2 := preload("res://场景/结局界面/结局内容_DLC2.gd")
const DLC3 := preload("res://场景/结局界面/结局内容_DLC3.gd")

## 本体轮播页上限：原作 number_of_e 0..17 循环，页 18 在源码中存在但循环不可达。
const 本体页数 := 18
## 原作三面板最大页码（Ending.unity max_pages: 8/7/7）。
const DLC_页数 := [0, 8, 7, 7]

@onready var 结局标题: Label = $结局标题
@onready var 结局文案: RichTextLabel = $结局文案
@onready var 返回主菜单: TextureButton = $返回主菜单
@onready var 左翻页: TextureButton = $左翻页
@onready var 右翻页: TextureButton = $右翻页
@onready var 本体按钮: Button = $DLC面板/本体按钮
@onready var DLC一按钮: Button = $DLC面板/DLC一按钮
@onready var DLC二按钮: Button = $DLC面板/DLC二按钮
@onready var DLC三按钮: Button = $DLC面板/DLC三按钮

var _bad_route: int = -1
var _panel: int = 0
## 各面板当前页（原作各 EngingDLCController 的 numberOfPage 独立保存）。
var _pages: Array[int] = [0, 0, 0, 0]


func _ready() -> void:
	# 事件场景同款：GameManager 触发结局后已暂停，UI 必须继续响应。
	process_mode = Node.PROCESS_MODE_ALWAYS

	_bad_route = GameManager.current_ending_id

	返回主菜单.pressed.connect(_on_返回主菜单_pressed)
	左翻页.pressed.connect(_on_左翻页_pressed)
	右翻页.pressed.connect(_on_右翻页_pressed)
	本体按钮.pressed.connect(_on_面板按钮_pressed.bind(0))
	DLC一按钮.pressed.connect(_on_面板按钮_pressed.bind(1))
	DLC二按钮.pressed.connect(_on_面板按钮_pressed.bind(2))
	DLC三按钮.pressed.connect(_on_面板按钮_pressed.bind(3))

	if _bad_route > 0:
		# 原作 DoneEnding：data[35]>0 → 箭头 Destroy、SwitchEndingScript Destroy，只显示指定坏结局。
		_show_bad_ending()
	else:
		# 原作 data[35]<=0：默认页 0 = GoodEnd 自动判定，左右箭头在 0..17 循环。
		_refresh_dlc_buttons()
		_show_panel(0, 0)


## 原作 GameState.data[35]>0 → BadEnding 分支；Godot current_ending_id 即 data[35]。
func _show_bad_ending() -> void:
	左翻页.hide()
	右翻页.hide()
	$DLC面板.hide()
	var result: Dictionary = 坏结局.new().build_bad_ending(_bad_route, GameManager.world)
	结局标题.text = str(result.get("name", ""))
	_render_text(str(result.get("text", "")))


func _show_panel(panel: int, page: int) -> void:
	_panel = panel
	_pages[panel] = page
	var result: Dictionary = _build_current()
	结局标题.text = str(result.get("name", ""))
	_render_text(str(result.get("text", "")))
	左翻页.visible = panel == 0
	# 原作 EngingDLCController.OnMouseDown：DLC 面板点击自身即翻页；Godot 复用右翻页按钮承担该语义。
	右翻页.visible = true


func _build_current() -> Dictionary:
	var w: WorldState = GameManager.world
	if w == null:
		# 原版 GlobalScript.inst 恒存在；Godot 直接 F6 单跑本场景时无世界状态，给出空内容占位。
		return {"name": "", "text": ""}
	if _panel == 0:
		if _pages[0] == 0:
			return 胜利内容.new().build_good_end(w)
		var result: Dictionary = 轮播1.new().try_build_page(_pages[0], w)
		if not result.is_empty():
			return result
		result = 轮播2.new().try_build_page(_pages[0], w)
		if not result.is_empty():
			return result
		result = 轮播3.new().try_build_page(_pages[0], w)
		if not result.is_empty():
			return result
		return {}
	if _panel == 1:
		return DLC1.new().try_build_dlc(_panel, _pages[_panel], w)
	if _panel == 2:
		return DLC2.new().try_build_dlc(_panel, _pages[_panel], w)
	if _panel == 3:
		return DLC3.new().try_build_dlc(_panel, _pages[_panel], w)
	return {}


## 原作 Text()：'|'→换行 + 91 列折行。Godot RichTextLabel bbcode_enabled + autowrap_mode=3 承担折行，'|' 硬换行。
## Unity RichText 标签 → Godot BBCode（gdd_0413_BBCode_in_RichTextLabel.md：color/font_size 标签）：
##   <color=xxx> → [color=xxx]，</color> → [/color]；<size=N> → [font_size=N]，</size> → [/font_size]。
func _render_text(text: String) -> void:
	text = text.replace("<color=", "[color=")
	text = text.replace("</color>", "[/color]")
	text = text.replace("<size=", "[font_size=")
	text = text.replace("</size>", "[/font_size]")
	text = text.replace("|", "\n")
	结局文案.text = text


func _refresh_dlc_buttons() -> void:
	var w: WorldState = GameManager.world
	本体按钮.show()
	# 原作 SwitchEndingScript.cs L9-13：num!=0 且 !dlc[num] 时销毁按钮；本体(num=0)恒可用。
	for num in [1, 2, 3]:
		var btn: Button = [DLC一按钮, DLC二按钮, DLC三按钮][num - 1]
		var owned: bool = w != null and w.dlc.size() > num and w.dlc[num]
		btn.visible = owned


func _on_面板按钮_pressed(panel: int) -> void:
	if panel == _panel:
		return
	_show_panel(panel, _pages[panel])


func _on_左翻页_pressed() -> void:
	var page: int = _pages[0] - 1
	if page < 0:
		page = 17  # 原作 L1029-1033：小于 0 回到 17。
	_show_panel(0, page)


func _on_右翻页_pressed() -> void:
	if _panel == 0:
		var page: int = _pages[0] + 1
		if page > 17:
			page = 0  # 原作 L1037-1041：大于 17 回到 0。
		_show_panel(0, page)
	else:
		# 原作 EngingDLCController.OnMouseDown L15-26：numberOfPage++ 循环 max_pages。
		var page: int = _pages[_panel] + 1
		if page >= DLC_页数[_panel]:
			page = 0
		_show_panel(_panel, page)


## 原作 Update L4144-4194：UpArrow/DownArrow 滚动 Name/Text 并 clamp。
## Godot 用 RichTextLabel 自带 VScrollBar（Range.value/min_value/max_value 见 gdd_0710_Range.md），
## 每次按键滚动一页的 25%，Range 自身 clamp 上下界；长按由系统键重复(echo)提供连续滚动。
func _unhandled_input(event: InputEvent) -> void:
	if _bad_route > 0:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var bar: VScrollBar = 结局文案.get_v_scroll_bar()
		if event.keycode == KEY_UP:
			bar.value -= bar.page * 0.25
		elif event.keycode == KEY_DOWN:
			bar.value += bar.page * 0.25


func _on_返回主菜单_pressed() -> void:
	get_tree().change_scene_to_file("uid://bydan4iqthbaa")
