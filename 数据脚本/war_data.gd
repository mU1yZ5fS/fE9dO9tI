class_name WarData
extends Resource

## 战争运行时数据。对应原版 warinwars。
## 静态规则见 WarDef / WarCatalog。

@export var is_going: bool = false
@export var name_war: String = ""
@export var side1: String = ""
@export var side2: String = ""
@export var infl1: int = 0
@export var infl2: int = 0
@export var fortnight_elapsed: int = 0
## 开战时从 WarDef 拷贝；-1 = 仅 infl 结束
@export var fortnight_max: int = 48
## 0 = 支持 side1，1 = 支持 side2
@export var usa_side: int = 0
@export var ussr_side: int = 0
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
	diplo_done = [false, false]
