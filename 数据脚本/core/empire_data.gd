# ============================================================================
# EmpireData — 超级大国数据模型
# ============================================================================
# 移植自原版 Unity 项目 `Empire.cs`（Assets/Scripts/Empire.cs）。
# 原版使用 `empires[0]=USA, empires[1]=USSR` 数组，本版用 type 字段区分。
#
# 原版字段对照（Empire.cs 全部 public 字段）：
#   active_tree: string       → active_focus_tree
#   leaders: Leader[]         → leaders: Array[EmpireLeader]
#   modifies: int[]           → modifier_ids
#   insiders: Insider[]       → insiders: Array[EmpireInsider]
#   money: int                → money
#   power: int                → power
#   relations: int            → relations
#   now_leader: int           → current_leader
#   now_focus: int = -1       → current_focus
#   now_layer: int            → current_layer
#   historical: bool = true   → ai_historical
#   agressive: bool           → ai_aggressive
#   reformist: bool           → ai_reformist
#
# 原版 Leader 类（Leader.cs）：leader_name: string, support: int
# 原版 Insider 类（Insider.cs）：name: string, influence: int
# ============================================================================
class_name EmpireData
extends Resource

const USA: int = 0
const USSR: int = 1

# 帝国类型：0=美国, 1=苏联（替代原版数组索引）
@export var type: int = 0

# 领导人列表（原版 leaders: Leader[]，映射为 EmpireLeader 资源数组）
@export var leaders: Array[EmpireLeader] = []

# 现任领导人索引（原版 now_leader: int）
@export var current_leader: int = 0

# 内部成员/附庸国（原版 insiders: Insider[]，映射为 EmpireInsider 资源数组）
@export var insiders: Array[EmpireInsider] = []

# 帝国专用修正 ID 列表（原版 modifies: int[]）
@export var modifier_ids: Array[int] = []

# 资金（原版 money: int）
@export var money: int = 0

# 综合实力值（原版 power: int，影响非洲争夺等全局计算）
@export var power: int = 0

# 对华关系内部 ×10 存储（0~1000 对应显示 0~100；原版 relations）
@export var relations: int = 500

# 当前启用的国策树名称（原版 active_tree: string）
@export var active_focus_tree: String = ""

# 当前国策节点索引，-1 = 无（原版 now_focus: int = -1）
@export var current_focus: int = -1

# 当前国策树层级（原版 now_layer: int）
@export var current_layer: int = 0

# ========================================================================
# AI 行为（原版 historical / agressive / reformist: bool）
# 互斥状态，通过 MakeHistorical/MakeAgressive/MakeReformist 等方法切换
# ========================================================================

# 遵循历史路线（默认）
@export var ai_historical: bool = true
# 激进路线
@export var ai_aggressive: bool = false
# 改良路线
@export var ai_reformist: bool = false


func _init(p_type: int = 0) -> void:
	type = p_type


func type_name() -> String:
	return "美国" if type == USA else "苏联"
