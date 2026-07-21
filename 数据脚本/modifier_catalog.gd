class_name ModifierCatalog
extends RefCounted

## 从 res://资产/数据/修正/mod_XX.tres 加载修正展示文案与图标。
## 运行时激活状态仍看 WorldState.modifiers；本类只负责定义与展示资源。

const MOD_DIR := "res://资产/数据/修正/"

static var _by_id: Dictionary = {}  # int -> ModifierDef
static var _loaded: bool = false


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_by_id.clear()
	var dir := DirAccess.open(MOD_DIR)
	if dir == null:
		push_warning("ModifierCatalog: 无法打开 %s" % MOD_DIR)
		return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.ends_with(".tres"):
			var path := MOD_DIR.path_join(fname)
			var res = load(path)
			if res is ModifierDef:
				var def := res as ModifierDef
				_by_id[def.id] = def
			elif res != null:
				push_warning("ModifierCatalog: 非 ModifierDef 资源 %s" % path)
		fname = dir.get_next()
	dir.list_dir_end()


static func get_def(id: int) -> ModifierDef:
	_ensure_loaded()
	return _by_id.get(id) as ModifierDef


## 已加载定义 id 列表（升序），供概览列出激活/未激活项
static func all_ids() -> Array[int]:
	_ensure_loaded()
	var ids: Array[int] = []
	for k in _by_id.keys():
		ids.append(int(k))
	ids.sort()
	return ids


static func name_zh(id: int) -> String:
	var def := get_def(id)
	if def != null and def.name_zh != "":
		return def.name_zh
	return "修正 #%d" % id


static func effect_zh(id: int, w: WorldState = null) -> String:
	# 13 号可按经济体制拼动态摘要；静态底稿仍来自 .tres
	if id == 13 and w != null and w.数值表.size() > WorldState.I_ECON_SYSTEM:
		var living: int = w.数值表[WorldState.I_LIVING]
		var econ: int = w.数值表[WorldState.I_ECON_SYSTEM]
		var denom := 500
		if econ == 14:
			denom = 330
		elif econ == 15:
			denom = 250
		elif econ == 13:
			denom = 500
		else:
			var base := get_def(id)
			return base.effect_zh if base else "效果未录入"
		var whole := living / (denom * 10)
		var frac := absi(living / denom % 10)
		return "预算收入约 +%d.%d（随生活水平）" % [whole, frac]
	var def := get_def(id)
	if def != null and def.effect_zh != "":
		return def.effect_zh
	return "效果未录入"


## 图标命名约定（与原版/资源目录一致）：
##   res://资产/修正图标/{id}_0.png = 激活
##   res://资产/修正图标/{id}_1.png = 未激活
const ICON_DIR := "res://资产/修正图标/"


static func _load_icon_file(id: int, active: bool) -> Texture2D:
	var suffix := "0" if active else "1"
	var path := "%s%d_%s.png" % [ICON_DIR, id, suffix]
	if ResourceLoader.exists(path):
		var tex = load(path)
		if tex is Texture2D:
			return tex as Texture2D
	return null


## 按激活状态取图：优先 .tres 里配置的 icon_active/icon_inactive，否则按 {id}_0/{id}_1 约定加载
static func icon(id: int, is_active: bool = true) -> Texture2D:
	var def := get_def(id)
	if is_active:
		if def != null and def.icon_active != null:
			return def.icon_active
		return _load_icon_file(id, true)
	if def != null and def.icon_inactive != null:
		return def.icon_inactive
	var off := _load_icon_file(id, false)
	if off != null:
		return off
	# 仅有激活图：返回激活图，由 UI 变暗表示未激活
	if def != null and def.icon_active != null:
		return def.icon_active
	return _load_icon_file(id, true)


static func is_known(id: int) -> bool:
	_ensure_loaded()
	return _by_id.has(id)


## 编辑器/调试：已加载条数
static func count_loaded() -> int:
	_ensure_loaded()
	return _by_id.size()
