extends CanvasLayer

## 状态数值区 — 六界面共用顶栏数值区（2026-08 组件化重构）。
## 显示 10 项指标 + 悬浮提示。根节点名固定为"状态栏"（经济.gd 等按名字查找并调用 _refresh()）。
## 导航按钮已拆到 导航栏.tscn。

const BBC = preload("res://数据脚本/bbc_tooltip.gd")
const W = preload("res://数据脚本/world_state.gd")
const STATUS_BAR_VM_SCRIPT = preload("res://数据脚本/ui/status_bar_view_model.gd")

## 节点名 → [原版悬浮提示名, 数值表索引]
const 提示配置 := {
	"党内支持度": ["党内支持度", W.I_PARTY_SUPPORT],
	"人民支持度": ["人民支持度", W.I_PEOPLE_SUPPORT],
	"思想自由度": ["思想自由化", W.I_THOUGHT_FREEDOM],
	"生活水平": ["生活水平", W.I_LIVING],
	"国际声望": ["国际声誉", W.I_DIPLO],
	"特工网络": ["特工网络", W.I_AGENTS],
	"全球影响力": ["全球影响力", W.I_INFLUENCE],
	"预算": ["预算", W.I_BUDGET],
	"与美国关系": ["与美国的关系", W.I_USA_RELATIONS],
	"与苏联关系": ["与苏联的关系", W.I_USSR_RELATIONS],
}

var _vm = null

## 各 Label 上一次显示的文本，用于判断数值是否变化并触发刷新特效。
var _prev_texts: Dictionary = {}
## Label 正在播放的刷新特效 Tween，按 Label 实例 id 保存，避免重复叠加。
var _flash_tweens: Dictionary = {}


func _ready() -> void:
	if not GameManager:
		return
	_vm = STATUS_BAR_VM_SCRIPT.new()
	_vm.bind(GameManager)
	_vm.changed.connect(_refresh)
	_setup_tooltips()
	if GameManager.world != null:
		_refresh()


## 公开刷新入口（经济.gd 等跨界面脚本按名查找后调用）。
func _refresh() -> void:
	if _vm == null:
		return
	var values: Dictionary = _vm.get_values()
	for key in values:
		_label(String(key), String(values[key]))
	_refresh_tooltips(GameManager.world)


func _label(label_name: String, text: String) -> void:
	var lbl := find_child(label_name, true, false)
	if lbl is Label:
		var old: String = _prev_texts.get(label_name, "")
		if old != text:
			_prev_texts[label_name] = text
			lbl.text = text
			_flash_label(lbl)


## 数值变化时给 Label 一个短暂高亮回弹，让玩家一眼看到哪项在变。
func _flash_label(lbl: Label) -> void:
	var id := lbl.get_instance_id()
	if _flash_tweens.has(id):
		var old_tween: Tween = _flash_tweens[id]
		if old_tween != null and old_tween.is_valid():
			old_tween.kill()
		_flash_tweens.erase(id)
	var orig: Color = lbl.get_meta("fx_orig_modulate", Color.WHITE)
	lbl.set_meta("fx_orig_modulate", orig)
	lbl.modulate = Color(1.0, 0.92, 0.55, 1.0)
	var tw := create_tween()
	_flash_tweens[id] = tw
	tw.tween_property(lbl, "modulate", orig, 0.45) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void:
		_flash_tweens.erase(id)
	)


# ── 悬浮提示 ──

func _setup_tooltips() -> void:
	for label_name in 提示配置:
		_set_tip_node(label_name)


func _set_tip_node(node_name: String) -> void:
	var n := find_child(node_name, true, false)
	if n is Control:
		BBC.attach(n)


func _set_tip(node_name: String, text: String) -> void:
	var n := find_child(node_name, true, false)
	if n is Control:
		BBC.attach(n)
		n.tooltip_text = text


func _delta_str(v: int) -> String:
	var 符号 := "-" if v < 0 else "+"
	@warning_ignore("integer_division")
	return "%s%d.%d" % [符号, absi(v / 10), absi(v % 10)]


func _faction_suffix(v: int) -> String:
	if v > 900:
		return "\n<color=red> 威 权 派</color>"
	elif v > 790:
		return "\n<color=purple> 保 守 派</color>"
	elif v > 590:
		return "\n<color=fuchsia> 温 和 派</color>"
	elif v > 390:
		return "\n<color=green> 改 革 派</color>"
	elif v > 190:
		return "\n<color=aqua> 自 由 派</color>"
	return "\n<color=blue> 西 渐 派</color>"


func _refresh_tooltips(w: WorldState) -> void:
	for label_name in 提示配置:
		var cfg: Array = 提示配置[label_name]
		var idx: int = cfg[1]
		var tip := "%s: %s" % [cfg[0], _delta_str(w.两周变化(idx))]
		if idx == W.I_DIPLO:
			tip += _faction_suffix(w.数值表[W.I_DIPLO])
		_set_tip(label_name, tip)
