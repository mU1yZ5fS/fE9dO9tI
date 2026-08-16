# ============================================================================
# DecisionSystem — 决议运行时（条件判定 / 执行 / 列表排序）
# ============================================================================
# 对齐原版：
#   - DecisionButtonScript.OnMouseDown：ready 时 dec.active() + completed=true + Repaint
#   - FocusesScript.CreateDecisions 的列表排序（GlobalScript.cs 无，见
#     FocusesScript.cs:75-124）：ready 排最前、unready 居中、done 排最后，
#     未购 dlc（dlc[version]==false）的决议不显示。
# ============================================================================
class_name DecisionSystem
extends RefCounted


## 决议是否已完成（原版 completedDecisions[idx]）
static func is_completed(index: int) -> bool:
	var ws: WorldState = GameManager.world
	if ws == null or ws.decisions == null:
		return false
	if index < 0 or index >= ws.decisions.completed.size():
		return false
	return ws.decisions.completed[index]


## 条件满足且未完成、且 dlc 版本开启（原版 DecisionButtonScript.ChangeCondition
## 只判 completed/condition；dlc 过滤在列表构建层，本方法供 UI 单项判定）
static func is_ready(index: int) -> bool:
	if is_completed(index):
		return false
	var def := DecisionCatalog.get_def(index)
	if def == null or not def.condition.is_valid():
		return false
	return def.condition.call()


## 按原版 CreateDecisions 顺序返回可见决议（ready → unready → done）。
static func ordered_defs() -> Array[DecisionDef]:
	DecisionCatalog.rebuild()  # 原版每次 Repaint 重建三元分支
	var ws: WorldState = GameManager.world
	var ready: Array[DecisionDef] = []
	var unready: Array[DecisionDef] = []
	var done: Array[DecisionDef] = []
	for def: DecisionDef in DecisionCatalog.defs():
		if ws == null or def.version < 0 or def.version >= ws.dlc.size() or not ws.dlc[def.version]:
			continue
		if is_completed(def.id):
			done.append(def)
		elif def.condition.is_valid() and def.condition.call():
			ready.append(def)
		else:
			unready.append(def)
	var out: Array[DecisionDef] = []
	out.append_array(ready)
	out.append_array(unready)
	out.append_array(done)
	return out


## 执行决议：效果链顺序执行 + completed 置位 + 目录重建（原版 Repaint）。
static func execute(index: int) -> bool:
	var def := DecisionCatalog.get_def(index)
	if def == null or is_completed(index):
		return false
	if not (def.condition.is_valid() and def.condition.call()):
		return false
	def.execute()
	var ws: WorldState = GameManager.world
	if ws != null and ws.decisions != null:
		while ws.decisions.completed.size() <= index:
			ws.decisions.completed.append(false)
		ws.decisions.completed[index] = true
	DecisionCatalog.rebuild()
	if GameManager.has_method("_notify_stats"):
		GameManager._notify_stats()
	return true
