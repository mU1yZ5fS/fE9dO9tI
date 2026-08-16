class_name FactionData
extends Resource

## 派系数据。对应原版 GameState 的派系字段。
## 5个派系: 0=极左派 1=保守派 2=温和派 3=改革派 4=自由派
## support ≡ 原版 party_number（席位/力量数据源；一党制下由 GameManager
##   _sync_faction_numbers_from_ideology 每日按 ideology+禁用派转移重算）
## ideology ≡ 原版 party_ideology（基础支持度；每 7 天盟友增长也写这里）
## points ≡ 已废弃的自造半年积分字段；仅保留以兼容旧存档，不再有任何逻辑读写

const MAOIST: int = 0
const CONSERVATIVE: int = 1
const MODERATE: int = 2
const REFORMIST: int = 3
const LIBERAL: int = 4

## Part_en.txt 的 15 个党名（逐字，含原版空格与 | 排版；显示时 Replace("|","\n")）：
## [0..4] 一党制(政党制度≤7)；[5..9] 多党制主标签；[10..14] 多党制 tooltip
const FACTION_NAMES: Array[String] = [
	"极 左 派",
	"保 守 派",
	"温 和 派",
	"改 革 派",
	"自 由 派",
]
const FACTION_NAMES_MULTI: Array[String] = [
	"异 端 社 会 主 义 者",
	"我 党",
	"社 会 国 家 主 义 者",
	"民 族 保 守 主 义 者",
	"新 启 蒙 主 义 者",
]
const FACTION_NAMES_MULTI_TIP: Array[String] = [
	"重 上 井 冈 山 ，| 走 第 二 次 长 征",
	"民 主 制 度 的 压 舱 石 就 是 你 ！",
	"承 继 父 辈 旗 帜 ，| 代 行 人 民 意 志",
	"非 新 无 以 图 进 ，| 非 旧 无 以 图 存",
	"哦 ， 永 远 年 轻 ， | 永 远 热 泪 盈 眶",
]

@export var id: int = 0                     # 0-4
@export var name: String = ""               # 派系名称
@export var ideology: int = 0               # 原版 party_ideology（基础支持度；每日重算与每周盟友增长都写这里）
@export var is_enabled: bool = false        # 是否活跃（原版 is_party_enabled）
@export var is_ally: bool = false           # 是否与玩家结盟（原版 is_party_ally）
@export var support: int = 0                # 民众支持 / party_number（一党制下每日由 ideology 重算）
@export var points: int = 0                 # 已废弃自造积分；仅存档兼容
@export var influence: int = 0              # 旧派生字段，仅存档兼容；增长/重算以 ideology 为准
@export var leader_index: int = -1          # politician 索引；-2=实权领袖本人，-1=空缺

## 兼容旧字段：席位只读派生，写入时同步到 support
@export var seats: int = 0:
	get:
		return support
	set(value):
		support = value


func _init(p_id: int = 0) -> void:
	id = p_id
	if p_id >= 0 and p_id < FACTION_NAMES.size():
		name = FACTION_NAMES[p_id]
