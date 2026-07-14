# ============================================================================
# EffectNode — 事件效果节点
# ============================================================================
# 描述事件选项执行后的游戏状态变更。
#
# 设计参考：
#   - Godot 4.7 Resource 系统（gdd_0373）
#   - 原版 EventsSecond.ResultsOfEvents() 的模式归纳
#   - P 社游戏的 effect 系统
#
# 覆盖原版事件中所有操作类型：
#   - 资源加减：data[X] += value
#   - 联盟加入：allcountries[X].isNATO = true
#   - 国家变量：allcountries[X].numberOfSpecialEnding = value
#   - 帝国关系：empires[X].relations += value
#   - 战争状态：war = value
#   - 修正激活：modifies[X].active = true
#   - 事件链：触发另一个事件
#
# 扩展点：CUSTOM_SCRIPT 类型加载指定 GDScript 执行任意逻辑，
# 确保系统不被数据模型限制。
#
# 效果执行器见 event_engine.gd 的 execute() 方法。
# ============================================================================
class_name EffectNode
extends Resource

## 效果类型
enum Type {
	# ── 资源操作 ──
	ADD_RESOURCE,               # key=资源名 value=变化量 → data[key] += value
	SET_RESOURCE,               # key=资源名 value=目标值 → data[key] = value

	# ── 联盟操作 ──
	JOIN_ALLIANCE,              # target=国家标签 key=联盟名 → country.is_{key} = true
	LEAVE_ALLIANCE,             # target=国家标签 key=联盟名 → country.is_{key} = false
	JOIN_ALL_ALLIANCES,         # target=国家标签 → 跟随玩家的全部联盟
	JOIN_ECONOMIC_ALLIANCE,     # target=国家标签 → 仅加入经济联盟

	# ── 国家变量 ──
	SET_COUNTRY_VAR,            # target=国家标签 key=变量名 value=值
	ADD_COUNTRY_VAR,            # target=国家标签 key=变量名 value=增量

	# ── 帝国/外交关系 ──
	ADD_EMPIRE_RELATION,        # key=帝国编号 value=变化量
	SET_EMPIRE_RELATION,        # key=帝国编号 value=目标值
	ADD_EMPIRE_POWER,           # key=帝国编号 value=变化量 → empires[key].power += value

	# ── 派系 ──
	ADD_FACTION_SUPPORT,        # key=派系编号 value=变化量

	# ── 战争 ──
	SET_WAR_STATE,              # value=战争状态值

	# ── 修正 ──
	SET_MODIFIER_ACTIVE,        # key=修正索引 value: 0=停用 1=激活
	SET_MODIFIER_AVAILABLE,     # key=修正索引 value: 0=禁用 1=可用

	# ── 全局标记 ──
	SET_FLAG,                   # key=标记名 → global_flags[key] = true
	CLEAR_FLAG,                 # key=标记名 → global_flags[key] = false

	# ── 事件链 ──
	TRIGGER_EVENT,              # key=目标事件ID → 触发另一个事件

	# ── 逃生舱口 —— 高级事件回退到自定义脚本 ──
	CUSTOM_SCRIPT,              # custom_script 指向 GDScript，引擎调用其 execute(context)
}

## 效果类型
@export var type: Type = Type.ADD_RESOURCE

## 通用参数：资源名 / 联盟名 / 变量名 / 修正名 / 标记名 / 事件ID
@export var key: String = ""

## 通用参数：变化量 / 目标值
@export var value: float = 0.0

## 目标国家标签（ROOT=玩家 FROM=对方 或具体标签如 KOR）
@export var target: String = "ROOT"

## 自定义脚本（仅 CUSTOM_SCRIPT 类型使用）。
## 【重要】此脚本必须继承 RefCounted（而非 Node），
## 以避免 new() 创建的实例泄漏到场景树之外。
@export var custom_script: GDScript
