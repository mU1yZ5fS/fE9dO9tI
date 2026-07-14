## 游戏界面基类 — 提供共享的节点查找缓存和 Label 更新工具。
## 所有界面脚本（经济、派系等）继承此类以消除重复代码。
class_name GameUIBase
extends Control

# 节点引用缓存（首次查找后缓存，避免每帧 find_child）
var _node_cache: Dictionary = {}


func _find(node_name: String) -> Node:
	if _node_cache.has(node_name):
		return _node_cache[node_name]
	var n := find_child(node_name, true, false)
	if n != null:
		_node_cache[node_name] = n
	return n


func _label(node_name: String, text: String) -> void:
	var lbl := _find(node_name)
	if lbl is Label:
		lbl.text = text


func _set_visible(node_name: String, vis: bool) -> void:
	var n := _find(node_name)
	if n:
		n.visible = vis


func _raw(w: WorldState, idx: int) -> int:
	if idx >= 0 and idx < w.数值表.size():
		return w.数值表[idx]
	return 0
