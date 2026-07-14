class_name ModifierSlot
extends Resource

## 修正项槽位。对应原版 Modifiers 类。
## GameState.modifies[250]

@export var id: int = -1          # 修正 ID
@export var is_active: bool = false   # 当前是否激活
@export var is_available: bool = true # 是否可用（原版 turned）
@export var level: int = 0        # 等级/叠层数

func _init(p_id: int = -1, p_is_active: bool = false, p_is_available: bool = true, p_level: int = 0) -> void:
	id = p_id
	is_active = p_is_active
	is_available = p_is_available
	level = p_level
