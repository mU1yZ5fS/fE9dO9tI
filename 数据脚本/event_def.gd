# ============================================================================
# EventDef — 事件定义资源
# ============================================================================
# 一个 .tres 文件 = 一个完整事件。包含：
#   - 元数据（ID / 标题 / 描述 / 配图）
#   - 触发条件（ExprNode 表达式树）
#   - 选项列表（EventOption，含启用条件 + 效果 + 结果文本）
#   - 事件链（触发后通知其他事件）
#
# 触发模型（2026-08-14 对齐原版）：条件满足 → 确定性立即触发（原版 TimeScript
# else-if 链），无 MTTH 随机计时。原 MTTH 字段已移除。
#
# 设计原则：
#   1. 数据与逻辑分离 —— 事件的所有信息在 .tres 中，引擎只解释执行
#   2. 编辑器友好 —— 所有字段 @export，可在 Godot Inspector 中直接编辑
#   3. 完全覆盖原版 —— 表达力足以描述原版全部事件的操作模式
#   4. 可扩展 —— CUSTOM_SCRIPT 效果节点和子类化保证不被数据模型限制
#
# 参考：
#   - Godot 4.7 Resource 系统文档（gdd_0373_Resources.md）
#   - 原版 EventsForDLC.EventsSecond 抽象基类
#   - 原版 Decision 的 Builder 模式
# ============================================================================
class_name EventDef
extends Resource

## 事件唯一标识符（新系统主键，推荐 snake_case 命名）
@export var event_id: String = ""

## 原版基础事件编号（非编号事件保持 -1），用于源码追踪和存档迁移。
@export var source_event_number: int = -1

## 自动扫描优先级；-1 使用资源文件稳定扫描次序。数值越小越先检查。
## 原版 TimeScript 使用 else-if 链，同一 tick 只进入第一个满足条件的事件。
@export var trigger_priority: int = -1

## 事件标题（显示在事件 UI 顶部）
@export var title: String = ""

## 事件描述（显示在事件 UI 第二行，支持多行）
@export_multiline var description: String = ""

## 事件配图（留空则使用随机默认图）
@export var image: Texture2D

## 触发条件列表（AND 关系 —— 全部满足才可触发）。
## 为空数组 [] 表示不通过自动扫描触发（需由外部系统如 Decision、
## queue_pending 等手动触发）。
@export var trigger_conditions: Array[ExprNode] = []

## 条件满足后是否先显示地图通知。原版 EventScript 地图标记（104 单位缓冲）；
## 选举、政变、战争结算等直接事件设为 false（当前 83 个事件均 false）。
@export var show_notification: bool = true

## 原 EventScript.Reset 的 104 计时单位 / 每日 8 单位 = 13 个游戏日。
@export_range(1, 365, 1) var notification_days: int = 13

## 通知超时代价（原 EventScript.Update：data[9]-=20, data[8]-=5）。
@export var timeout_agents_penalty: int = 20
@export var timeout_budget_penalty: int = 5

## 玩家可选的选项列表（通常 2~6 个）
@export var options: Array[EventOption] = []

## 是否仅触发一次（true = 触发后 event_done 标记，永不再次触发）
@export var fire_only_once: bool = true

## 触发完成后连带触发的事件 ID 列表（事件链）
@export var triggers_on_complete: Array[String] = []

## 该事件所属的 DLC / 资料片（空 = 本体）
@export var dlc: String = ""

## 显示前动态文案钩子（可选）。指向 extends RefCounted 的脚本，
## 事件 UI 打开前引擎调用其 prepare(event_def, world)，
## 用于按游戏状态动态改写 title/description/options 文案（原版 Event18 战争结算等）。
@export var display_script: GDScript = null


# ── 工厂方法（方便代码中动态创建事件） ──

## 创建一个简单的通知事件（无选项，纯展示）
static func create_notification(p_id: String, p_title: String, p_desc: String) -> EventDef:
	var ev := EventDef.new()
	ev.event_id = p_id
	ev.title = p_title
	ev.description = p_desc
	ev.fire_only_once = true
	# 通知事件有一个"确认"选项
	var opt := EventOption.new()
	opt.text = "确认"
	opt.result_text = p_desc
	ev.options = [opt]
	return ev
