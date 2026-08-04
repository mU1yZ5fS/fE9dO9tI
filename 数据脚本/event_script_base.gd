class_name EventScriptBase
extends RefCounted

## 事件效果脚本统一基类（2026-08 架构收敛）。
## 收敛逐脚本重复的样板：
##   const W = preload(world_state)  → 基类常量 W（子类直接使用）
##   var ws = GameManager.world; if null return; var d := ws.数值表
##                                     → execute 开头调 _bind_world()，直接用成员 ws / d
##
## 使用方式：
##   extends EventScriptBase
##   func execute(context: Dictionary) -> void:
##       if not _bind_world():
##           return
##       d[W.I_PEOPLE_SUPPORT] -= 20   # 直接读写成员
##
## 入口契约（与 EventEngine / GameManager 的调用点对应）：
##   - execute(context)：CUSTOM_SCRIPT 效果执行（EventEngine._run_custom_script）
##   - prepare(event_def, ws)：显示前动态文案钩子（GameManager 对 display_script 调用）
##   基类提供空实现，任何脚本被两种入口调用都安全。

const W = preload("res://数据脚本/world_state.gd")

## 当前 WorldState（_bind_world() 成功后可用）
var ws: WorldState = null

## 数值表快捷引用（= ws.数值表，引用语义，修改即写回）
var d: Array[int] = []


## execute 开头调用：绑定 ws / d。WorldState 未就绪返回 false，调用方直接 return。
func _bind_world() -> bool:
	ws = GameManager.world
	if ws == null:
		return false
	d = ws.数值表
	return true


## 显示前动态文案钩子（game_manager 对 display_script 调用；无钩子的脚本用基类空实现）
func prepare(_event_def: EventDef, _p_ws: WorldState) -> void:
	pass


## 效果入口（event_engine 的 CUSTOM_SCRIPT 效果调用；子类实现）
func execute(_context: Dictionary) -> void:
	pass
