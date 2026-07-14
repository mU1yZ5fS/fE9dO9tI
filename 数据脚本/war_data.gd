class_name WarData
extends Resource

## 战争数据。对应原版 warinwars 类。
## GameState.ingamewars[50]

@export var is_going: bool = false
@export var name_war: String = ""
@export var side1: String = ""       # 攻击方名称
@export var side2: String = ""       # 防御方名称
@export var infl1: int = 0           # 攻击方战争分数 0-1000
@export var infl2: int = 0           # 防御方战争分数 0-1000
@export var fortnight_elapsed: int = 0  # 已过双周数
@export var fortnight_max: int = 999    # 最大双周数
@export var usa_side: int = 0        # 美国支持哪方 (0/1)
@export var ussr_side: int = 0       # 苏联支持哪方 (0/1)
@export var diplo_done: Array[bool] = [false, false]

func _init(
	p_is_going: bool = false,
	p_name: String = "",
	p_side1: String = "",
	p_side2: String = "",
	p_infl1: int = 0,
	p_infl2: int = 0,
) -> void:
	is_going = p_is_going
	name_war = p_name
	side1 = p_side1
	side2 = p_side2
	infl1 = p_infl1
	infl2 = p_infl2
