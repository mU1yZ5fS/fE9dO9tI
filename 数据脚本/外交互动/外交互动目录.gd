## 外交互动目录 — 编号 → 动作定义的统一分发器。
## 各批文件由 CountryScript/DiploButtonScript 翻译而来，本目录只做查找与组装。
class_name DiploActionCatalog
extends RefCounted

const BATCH1 := preload("res://数据脚本/外交互动/外交互动_批1.gd")
const BATCH2 := preload("res://数据脚本/外交互动/外交互动_批2.gd")
const BATCH3 := preload("res://数据脚本/外交互动/外交互动_批3.gd")
const BATCH4 := preload("res://数据脚本/外交互动/外交互动_批4.gd")
const BATCH5 := preload("res://数据脚本/外交互动/外交互动_批5.gd")
const BATCH6 := preload("res://数据脚本/外交互动/外交互动_批6.gd")
const BATCH_EXTRA := preload("res://数据脚本/外交互动/外交互动_补遗.gd")

var _batches: Array = []


## 惰性创建批次实例；顺序不影响结果（编号无重叠）。
func _ensure_batches() -> void:
	if _batches.size() > 0:
		return
	_batches.append(BATCH1.new())
	_batches.append(BATCH2.new())
	_batches.append(BATCH3.new())
	_batches.append(BATCH4.new())
	_batches.append(BATCH5.new())
	_batches.append(BATCH6.new())
	_batches.append(BATCH_EXTRA.new())


## 查找动作定义。ctx = {w, d, country, caption}。
## 返回 {caption, opis, conditions, effect, dormant} 或 {}。
func build_action(action_type: int, ctx: Dictionary) -> Dictionary:
	_ensure_batches()
	for batch in _batches:
		var def: Dictionary = batch.build_action(action_type, ctx)
		if not def.is_empty():
			return def
	return {}


## 该编号是否已纳入目录（静态审计用，不实际构造动作）。
func has_action(action_type: int) -> bool:
	_ensure_batches()
	for batch in _batches:
		if batch.has_method("_def_%d" % action_type):
			return true
	return false
