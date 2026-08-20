# ============================================================================
# ExprNode — 事件条件表达式节点（组合模式）
# ============================================================================
# 用于描述事件的触发条件与选项的可用条件。
#
# 设计参考：
#   - Godot 4.7 Resource 系统（gdd_0373）
#   - 原版 Decision.CreateCondition() 的 lambda 组合模式
#   - P 社游戏（EU4/HOI4）的 trigger 系统
#
# 叶子节点：表达一个原子条件（如 data.agents >= 250）
# 组合节点：AND / OR / NOT 嵌套实现任意复杂条件
#
# 表达式求值器见 event_engine.gd 的 evaluate() 方法。
# ============================================================================
class_name ExprNode
extends Resource

## 条件表达式节点类型
enum Type {
	# ── 叶子节点 —— 原子条件 ──
	RESOURCE_AT_LEAST,          # key=资源名 value=阈值 → data.get_data_by_index(key) >= value
	RESOURCE_AT_MOST,           # key=资源名 value=阈值 → data.get_data_by_index(key) <= value
	MODIFIER_ACTIVE,            # key=修正名 → modifies[key].active == true
	MODIFIER_INACTIVE,          # key=修正名 → modifies[key].active == false
	PREV_EVENT_RESULT_IS,       # event_id=前序事件ID value=选项号 → resultOfEvents[event_id] == value
	PREV_EVENT_DONE,            # event_id → event_done[event_id] == true
	PREV_EVENT_NOT_DONE,        # event_id → event_done[event_id] == false
	IS_FACTION_LEADER,          # value=派系编号 → IsFactionLeadeng(value)
	EMPIRE_RELATION_AT_LEAST,   # key=帝国编号 value=阈值 → empires[key].relations >= value
	EMPIRE_RELATION_AT_MOST,    # key=帝国编号 value=阈值 → empires[key].relations <= value
	COUNTRY_HAS_TAG,            # key=标签 → 玩家国家有指定标签
	COUNTRY_IS_SUBJECT_OF,      # key=宗主国标签 → 指定国家是玩家的附庸
	DATE_AFTER,                 # key="1966.5" → 游戏日期 >= 指定日期
	DATE_BEFORE,                # key="1976.10" → 游戏日期 <= 指定日期
	HAS_FLAG,                   # key=标记名 → global_flags[key] == true
	NOT_HAS_FLAG,               # key=标记名 → global_flags[key] == false
	COUNTRY_EXISTS,             # key=国家标签 → 指定国家存在且未被吞并
	RESOURCE_AT_LEAST_FOR,      # key=资源名 value=阈值 target=国家标签 → 指定国家的资源检查

	# ── 组合节点 —— 逻辑运算 ──
	ALL,                        # AND — children 全部满足
	ANY,                        # OR  — children 任一满足
	NOT,                        # NOT — children[0] 取反

	# 新类型必须追加在组合节点之后，不能插入前方：旧 .tres 按枚举整数序列化。
	RESOURCE_EQUALS,            # key=资源名 value=值 → data.get_data_by_index(key) == value
	RESOURCE_NOT_EQUALS,        # key=资源名 value=值 → data.get_data_by_index(key) != value
	RESOURCE_SUM_AT_LEAST,      # keys=资源名数组 value=阈值 → sum(data.get_data_by_index(keys)) >= value
	RESOURCE_SUM_AT_MOST,       # keys=资源名数组 value=阈值 → sum(data.get_data_by_index(keys)) <= value
	COUNTRY_FIELD_EQUALS,       # target=国家标签/原版序号 key=字段 value=值
	COUNTRY_FIELD_NOT_EQUALS,   # target=国家标签/原版序号 key=字段 value=值
	COUNTRY_FIELD_AT_LEAST,     # target=国家标签/原版序号 key=字段 value=阈值
	COUNTRY_FIELD_AT_MOST,      # target=国家标签/原版序号 key=字段 value=阈值
	TECH_UNLOCKED,              # value=科技编号 → techs.unlocked[value]
	WAR_ACTIVE,                 # value=战争编号 → wars[value].is_going
	RESOURCE_AT_MOST_FOR,       # key=资源名 value=阈值 target=国家标签
	RESOURCE_DIFFERENCE_AT_MOST,# key=被减数 target=减数 value=阈值
	POLITICIAN_POWER_DIFFERENCE_AT_LEAST, # key=左侧性格 target=右侧性格 value=最小权力差
	WAR_FIELD_EQUALS,            # target=战争编号 key=字段 value=值
	POLITICIAN_GROUP_POWER_DIFFERENCE_AT_LEAST, # key/target=逗号分隔性格组 value=最小权力差
	COALITION_SUPPORT_AT_LEAST,  # value=阈值 → 执政联盟支持率(原 summa_3_2) >= value（仅 party_system>7 时计算，否则 0）
	EMPIRE_POWER_DIFFERENCE_AT_LEAST, # key=帝国编号 value=阈值 → influence_prc - empires[key].power >= value
	DECISION_DONE,               # key=决策编号 → decisions.completed[int(key)] == true
	# 领导人继任系统（2026-08 追加，尾追加不破坏旧 .tres 枚举整数）：
	EMPIRE_LEADER_IS,            # key=帝国编号 value=领导人索引 → empires[int(key)].current_leader == int(value)
	# 塞浦路斯大选链（Event697.cs:26-33）：keys=原版国家序号数组，value=最低数量。
	# 严格社会主义判定：government == GameConstants.Government.SOCIALIST 或 sub_government == GameConstants.SubGovernment.LEFT_RADICAL（world_state.is_socialism(country, true)）。
	SOCIALIST_COUNT_AT_LEAST,    # keys=[21,29,85,86,87,92] value=3 → IsSocialism(true) 命中数 >= 3
}

## 节点类型
@export var type: Type = Type.RESOURCE_AT_LEAST

## 通用参数：资源名 / 修正名 / 标记名 / 帝国编号 / 日期字符串（"1966.5"）
@export var key: String = ""

## 通用参数：比较值 / 阈值 / 选项号
@export var value: float = 0.0

## 通用参数：目标国家标签（RESOURCE_AT_LEAST_FOR / COUNTRY_IS_SUBJECT_OF 的 subject 方）
@export var target: String = ""

## 多资源求和条件使用的键列表（RESOURCE_SUM_*）。
@export var keys: Array[String] = []

## 引用前序事件ID（PREV_EVENT_* 节点使用，字符串 event_id）
@export var ref_event_id: String = ""

## 宗主国标签（COUNTRY_IS_SUBJECT_OF 使用）。
## 检查 node.target 是否是 node.overlord_tag 的附庸国。
@export var overlord_tag: String = ""

## 子节点（ALL / ANY / NOT 组合节点使用）
@export var children: Array[ExprNode] = []
