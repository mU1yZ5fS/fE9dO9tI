class_name FactionData
extends Resource

## 派系数据。对应原版 GameState 的派系字段。
## 5个派系: 0=极左派 1=保守派 2=温和派 3=改良派 4=自由派

const MAOIST: int = 0
const CONSERVATIVE: int = 1
const MODERATE: int = 2
const REFORMIST: int = 3
const LIBERAL: int = 4

const FACTION_NAMES: Array[String] = [
	"极左派",
	"保守派",
	"温和派",
	"改良派",
	"自由派",
]

@export var id: int = 0                     # 0-4
@export var name: String = ""               # 派系名称
@export var ideology: int = 0               # 意识形态类型
@export var is_enabled: bool = false        # 是否活跃
@export var is_ally: bool = false           # 是否与玩家结盟
@export var support: int = 0                # 民众支持度（原 party_number）
@export var seats: int = 0                  # 议会席位
@export var influence: int = 0              # 政治影响力
@export var leader_index: int = -1          # 派系领袖的 politician 索引

func _init(p_id: int = 0) -> void:
	id = p_id
	if p_id >= 0 and p_id < FACTION_NAMES.size():
		name = FACTION_NAMES[p_id]
