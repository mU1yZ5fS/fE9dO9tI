extends CanvasLayer

## 导航栏 — 六界面共用顶部场景切换按钮组（组件化重构 v2）。
## 所有按钮均为 .tscn 预置节点（编辑器可见、可维护），脚本只做通用逻辑：
##   显隐规则 + 紧凑重排 + 点击跳转。
## 按钮节点通过 metadata 配置（在编辑器 Inspector 的 Meta 里维护）：
##   metadata/screen_id = 界面 id（与 current_screen 相同则隐藏该按钮）
##   metadata/scene_uid = 跳转目标场景 uid（uid://...）
##   metadata/is_extra  = true 表示附加按钮（决议），仅外交界面显示
## 加新界面：编辑器里复制一个按钮改 text / screen_id / scene_uid 即可。

## 当前界面 id（与按钮的 screen_id 对应）。实例化时在各场景中设置。
@export var current_screen: String = "diplomacy"

## 主按钮排列参数（紧凑重排：跳过当前界面按钮后从起始 X 连续排列）
const 起始X := 56
const 间距 := 310
const 按钮宽 := 279
const 按钮Y := 80
const 按钮高 := 65

var _main_buttons: Array[BaseButton] = []


func _ready() -> void:
	_collect_buttons()
	_refresh()


## 收集导航按钮（带 screen_id meta 的 BaseButton 子节点），按树顺序排列并绑定跳转。
func _collect_buttons() -> void:
	_main_buttons.clear()
	for child in get_children():
		if child is BaseButton and child.has_meta("screen_id"):
			_main_buttons.append(child)
			var uid: String = child.get_meta("scene_uid", "")
			if not child.pressed.is_connected(_goto):
				child.pressed.connect(_goto.bind(uid))
	_main_buttons.sort_custom(func(a: BaseButton, b: BaseButton) -> bool:
		return a.get_index() < b.get_index())


## 显隐 + 重排：当前界面按钮隐藏；决议仅外交显示；可见主按钮紧凑排列。
func _refresh() -> void:
	var i := 0
	for btn in _main_buttons:
		var screen_id: String = btn.get_meta("screen_id", "")
		var is_extra: bool = btn.get_meta("is_extra", false)
		var should_show := screen_id != current_screen
		if is_extra and current_screen != "diplomacy":
			should_show = false
		btn.visible = should_show
		if should_show and not is_extra:
			btn.position = Vector2(起始X + i * 间距, 按钮Y)
			btn.size = Vector2(按钮宽, 按钮高)
			i += 1


func _goto(scene_uid: String) -> void:
	if scene_uid == "":
		return
	get_tree().change_scene_to_file(scene_uid)
