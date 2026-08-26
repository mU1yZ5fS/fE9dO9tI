class_name EventGraphLive
extends RefCounted

# ============================================================================
# 事件拓扑图 —— 游戏内实时条件求值探针（只读）。
# ============================================================================
# 回答拓扑图最核心的问题：「这个事件为什么还没触发？」
#
# 依赖：EventEngine Autoload（游戏内 world 已绑定；evaluate() 纯只读查询）。
# 主菜单（无世界）下 available()==false，查看器自动降级为纯静态模式。
#
# 求值路径：META 条件字典 → EventDefBuilder.build_expr() → ExprNode
#           → EventEngine.evaluate()（与正式触发判定同一套语义，杜绝口径漂移）。
# ============================================================================

const LX := preload("res://数据脚本/systems/event_graph_lexicon.gd")

## 事件总体状态
enum St { DONE, READY, LOCKED }

static var _valid_types := {}


static func _ensure_types() -> void:
	if _valid_types.is_empty():
		for k in ExprNode.Type.keys():
			_valid_types[k] = true


## 是否处于可求值的游戏局中
static func available() -> bool:
	return GameManager.world != null


## ── 单事件探针 ────────────────────────────────────────────────────────────
## 返回 { state: St, trigger_lines: Array[String], gate_lines: Array[String] }
static func probe(n: EventGraphData) -> Dictionary:
	var ws := GameManager.world
	var out := {"state": St.LOCKED, "trigger_lines": [], "gate_lines": []}
	if ws == null or n == null:
		return out
	_ensure_types()
	var done: bool = ws.completed_event_ids.has(n.id)
	var lines: Array[String] = []
	var all_ok := true
	for cd in n.trigger_list:
		if not (cd is Dictionary) or (cd as Dictionary).is_empty():
			continue
		if not _probe_node(cd, 0, lines):
			all_ok = false
	out.trigger_lines = lines
	out.gate_lines = _gate_lines(n)
	if done:
		out.state = St.DONE
	elif all_ok:
		out.state = St.READY
	return out


## 选项门槛逐条求值（仅列有门槛的选项）
static func _gate_lines(n: EventGraphData) -> Array[String]:
	var lines: Array[String] = []
	for o in n.options:
		if o.cond_dict.is_empty():
			continue
		var ok := _eval(o.cond_dict)
		lines.append("%s 选项%d门槛 %s" % [_mark(ok), o.index + 1,
				EventGraphData.humanize(o.text)])
	return lines


## 递归探针：组合节点打 ✓/✗ 头行，子节点缩进；叶子附当前值提示。
## 返回该节点是否满足。语义对齐 EventEngine.evaluate 的 ALL/ANY/NOT 空集处理。
static func _probe_node(d: Dictionary, depth: int, lines: Array[String]) -> bool:
	var t := str(d.get("t", "?"))
	var pad := "    ".repeat(depth)
	match t:
		"ALL", "ANY":
			var kids: Array = d.get("c", [])
			var child_lines: Array[String] = []
			var results: Array[bool] = []
			for c in kids:
				results.append(_probe_node(c, depth + 1, child_lines))
			var ok := true
			if t == "ALL":
				ok = not results.has(false)          # 空集 → true（同引擎）
			else:
				ok = results.has(true)               # 空集 → false（同引擎）
			lines.append("%s%s [color=#c8a457]【%s】[/color]" %
					[pad, _mark(ok), "且" if t == "ALL" else "任一"])
			lines.append_array(child_lines)
			return ok
		"NOT":
			var kids2: Array = d.get("c", [])
			if kids2.is_empty():
				# 引擎语义：NOT 无子节点 → evaluate 整体为 false
				lines.append("%s%s [color=#c8a457]【非】[/color]" % [pad, _mark(false)])
				return false
			var child_lines2: Array[String] = []
			var inner_ok := _probe_node(kids2[0], depth + 1, child_lines2)
			lines.append("%s%s [color=#c8a457]【非】[/color]" % [pad, _mark(not inner_ok)])
			lines.append_array(child_lines2)
			return not inner_ok
		_:
			var leaf_ok := _eval(d)
			lines.append("%s%s %s%s" % [pad, _mark(leaf_ok),
					EventGraphData.cond_to_bbcode(d), _current_hint(d)])
			return leaf_ok


static func _mark(ok: bool) -> String:
	return "[color=#7fd17f]✓[/color]" if ok else "[color=#e06c5a]✗[/color]"


## 与正式触发同语义的一次性求值；未知类型按不满足处理并留痕
static func _eval(cd: Dictionary) -> bool:
	_ensure_types()
	var tname := str(cd.get("t", ""))
	if not _valid_types.has(tname):
		return false
	var node := EventDefBuilder.build_expr(cd)
	if node == null:
		return false
	return EventEngine.evaluate(node)


## ── 当前值提示（四类高价值叶子；拿不到就空串，不硬造）────────────────────
static func _current_hint(d: Dictionary) -> String:
	var t := str(d.get("t", ""))
	var key := str(d.get("key", ""))
	match t:
		"COUNTRY_FIELD_AT_LEAST", "COUNTRY_FIELD_AT_MOST", "COUNTRY_FIELD_EQUALS", "COUNTRY_FIELD_NOT_EQUALS":
			var cur: int = EventEngine._get_country_field(str(d.get("target", "")), key)
			return "　[color=#6f7480]当前 %s[/color]" % LX.field_value(key, float(cur))
		"RESOURCE_AT_LEAST", "RESOURCE_AT_MOST", "RESOURCE_EQUALS", "RESOURCE_NOT_EQUALS":
			var cur2: int = EventEngine._get_resource(key)
			var shown := cur2 / 10.0 if LX.resource_tenfold(key) else float(cur2)
			return "　[color=#6f7480]当前 %s[/color]" % String.num(shown, 1).trim_suffix(".0")
		"EMPIRE_RELATION_AT_LEAST", "EMPIRE_RELATION_AT_MOST":
			var idx := int(key) if key.is_valid_int() else -1
			var rel := _empire_relation(idx)
			return "　[color=#6f7480]当前 %s[/color]" % (String.num(rel / 10.0, 1) if rel >= 0 else "?")
		"PREV_EVENT_RESULT_IS":
			var ref := str(d.get("ref", d.get("ref_event_id", "")))
			var v := int(GameManager.world.completed_event_ids.get(ref, -1))
			return "　[color=#6f7480]当前结果 %d[/color]" % v
	return ""


static func _empire_relation(idx: int) -> int:
	var emps: Array = GameManager.world.empires
	if idx < 0 or idx >= emps.size() or emps[idx] == null:
		return -1
	return int(emps[idx].relations)


## ── 全量状态扫描（列表着色用）：{stem: St}，纯查询毫秒级 ──────────────────
static func scan_all(nodes: Array[EventGraphData]) -> Dictionary:
	var out := {}
	for n in nodes:
		out[n.stem] = probe(n).state
	return out
