# ============================================================================
# DecisionDef — 决议定义
# ============================================================================
# 移植自原版 Unity 项目：
#   - Decision.cs（Assets/Scripts/Decision.cs，110 行）
#   - GlobalScript.CreateDecisions()（Assets/Scripts/GlobalScript.cs:6-86）
#   - DecisionButtonScript.cs（点击执行与 completedDecisions 置位）
#
# 原版 Decision 字段（Decision.cs:119-?）：
#   name / desc / version / req / result / condition / active
# 本版：
#   - title/desc/version 数据字段
#   - req（门槛文本）/ result（效果文本）用于决议界面 tooltip，逐字移植
#   - condition: Callable() -> bool —— 可用条件（原版 Func<bool>）
#   - effects: Array[Callable] —— 顺序执行的效果链（原版 Action 委托）
#   - condition/effects 为代码内嵌目录（decision_catalog.gd）运行时注入，
#     不进 .tres 序列化；存档只存 WorldState.decisions.completed（与原版
#     completedDecisions 对齐，原版 Decision 定义在 GameState 中序列化、
#     本版改代码目录等价重建，避免 Callable 无法序列化）。
# ============================================================================
class_name DecisionDef
extends Resource


## 决议编号（= 原版 decisions 数组下标，completedDecisions 同下标）
@export var id: int = -1

## 决议标题（原版 name）
@export var title: String = ""

## 决议描述（原版 desc）
@export var desc: String = ""

## DLC 版本（原版 version）：列表按 WorldState.dlc[version] 过滤。
## 裁决（2026-08-16）：默认 dlc[1..3]=true，45 条全部显示；字段保留以备接入购买检测。
@export var version: int = 1

## 门槛文本（原版 req，逐字中文，| 换行符由 UI 转 \n）
@export_multiline var req: String = ""

## 效果文本（原版 result，逐字中文）
@export_multiline var result: String = ""

# ── 运行时注入（不序列化） ──

## 可用条件：原版 Decision.condition() 的 lambda 链
var condition: Callable = Callable()

## 效果链：原版 Decision.active() 的 Action 委托链，按序调用
var effects: Array[Callable] = []


## 条件满足且未完成时可点击（DecisionButtonScript.cs:38-40 的 ChangeCondition 逻辑
## 由界面调用本方法 + completed 判定）
func is_available(completed: bool) -> bool:
	if completed:
		return false
	if not condition.is_valid():
		return false
	return condition.call()


## 执行：原版 DecisionButtonScript.OnMouseDown 的 dec.active() + completed=true
func execute() -> void:
	for fx: Callable in effects:
		if fx.is_valid():
			fx.call()
