extends CanvasLayer

## 预警图标动效：科研/阴谋/政治局缺人三个提示图标可见时做呼吸闪烁，
## 引导玩家注意到当前需要处理的事项。不可见时恢复默认透明度，不占性能。

const ALERT_NODE_NAMES := ["科研未研究提示", "阴谋临近提示", "政治局缺人提示"]
const PULSE_SPEED := 4.0
const MIN_ALPHA := 0.65
const MAX_ALPHA := 1.0

var _time := 0.0
var _icons: Array[CanvasItem] = []


func _ready() -> void:
	for node_name in ALERT_NODE_NAMES:
		var n := get_node_or_null(node_name)
		if n is CanvasItem:
			_icons.append(n)


func _process(delta: float) -> void:
	if _icons.is_empty():
		return
	_time += delta
	var alpha := MIN_ALPHA + (MAX_ALPHA - MIN_ALPHA) * (0.5 + 0.5 * sin(_time * PULSE_SPEED))
	for icon in _icons:
		if icon.visible:
			icon.modulate.a = alpha
