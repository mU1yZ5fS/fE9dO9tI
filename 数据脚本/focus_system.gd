# ============================================================================
# FocusSystem — 焦点树运行时（苏联 AI 自动推进）
# ============================================================================
# 对齐原版 TimeScript.cs:13791-13844：
#   FocusesResearching()：当前焦点 overtime>=time → 执行 active()、now_focus=-1、
#                         now_layer++；否则 overtime++。
#   FocusesAIMethod()：当前层无焦点时，收集 condition() 为真的焦点，
#                       随机选一个开始研究；其余全部 blocked=true。
#   调用频率：原版双周结算（TimeScript.cs:5960，裁决 Focus 默认开启）。
#
# 存档语义（对齐原版）：焦点定义代码目录重建不序列化；进度只存
# EmpireData.current_layer / current_focus / active_focus_tree（已在 @export 中）。
# ============================================================================
class_name FocusSystem
extends RefCounted


## 双周 tick 入口（GameManager._on_fortnight 调用）。
static func tick() -> void:
	var ws: WorldState = GameManager.world
	if ws == null or ws.empires.size() <= EmpireData.USSR:
		return
	var empire: EmpireData = ws.empires[EmpireData.USSR]
	var tree := FocusCatalog.tree_for_empire(empire)
	if tree == null or tree.layer_count() == 0:
		return
	if empire.current_layer < 0 or empire.current_layer >= tree.layer_count():
		# 树已走完（原版 now_layer 越过最后一层后 no-op）
		return
	var layer: Array = tree.get_layer(empire.current_layer)
	if empire.current_focus > -1:
		if empire.current_focus < layer.size():
			var foc: FocusDef = layer[empire.current_focus]
			if foc.overtime >= foc.time:
				for fx: Callable in foc.effects:
					if fx.is_valid():
						fx.call()
				empire.current_focus = -1
				empire.current_layer += 1
			else:
				foc.overtime += 1
	else:
		_focuses_ai_method(ws, empire, layer)


## FocusesAIMethod 直译（TimeScript.cs:13816-13844）。
static func _focuses_ai_method(_ws: WorldState, empire: EmpireData, layer: Array) -> void:
	var candidates: Array[int] = []
	for i in layer.size():
		var foc: FocusDef = layer[i]
		if foc == null:
			continue
		foc.blocked = true
		if foc.condition.is_valid() and foc.condition.call():
			candidates.append(i)
	if candidates.size() >= 1:
		var rng := _ws.ensure_rng()
		empire.current_focus = candidates[rng.randi_range(0, candidates.size() - 1)]
		layer[empire.current_focus].blocked = false


## UI 用：刷新本层 blocked 状态（原版 FocusesAIMethod 内联部分 + Repaint 语义）
static func repaint_blocked() -> void:
	var ws: WorldState = GameManager.world
	if ws == null or ws.empires.size() <= EmpireData.USSR:
		return
	var empire: EmpireData = ws.empires[EmpireData.USSR]
	var tree := FocusCatalog.tree_for_empire(empire)
	if tree == null:
		return
	for layer_index in tree.layer_count():
		var layer: Array = tree.get_layer(layer_index)
		for foc: FocusDef in layer:
			if foc == null:
				continue
			foc.blocked = true
		if layer_index == empire.current_layer and empire.current_focus >= 0 \
				and empire.current_focus < layer.size():
			layer[empire.current_focus].blocked = false


## 新游戏初始化（GameManager.new_game 调用一次）：
## 原版 GameStartScript.cs:987（dlc[0] 时）→ USSRFocuses.Init()。
static func init_for_new_game() -> void:
	var ws: WorldState = GameManager.world
	if ws == null:
		return
	FocusCatalog.ensure_built()
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.empires[EmpireData.USSR].active_focus_tree = "Start Focus"
		ws.empires[EmpireData.USSR].current_layer = 0
		ws.empires[EmpireData.USSR].current_focus = -1
	# 原版 GameStartScript.cs:934：SOV_PRC_PartiesConnection = data[30]；
	# 本项目已统一以 data[30]（I_COMMUNICATIONS）为唯一权威，不再保留镜像字段。
	# 原版 GameStartScript.cs:90：OilProd = 850（决议 HasOilEat 依赖的初始口径）
	if ws.oil_prod == 0.0:
		ws.oil_prod = 850.0
