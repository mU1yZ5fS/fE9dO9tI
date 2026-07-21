class_name WarDef
extends Resource

## 代理战争静态定义。运行时状态在 WarData / WorldState.wars。

@export var id: int = 0
@export var name_zh: String = ""
@export var name_en: String = ""
## -1 = 仅影响力结束（阿富汗）
@export var fortnight_max: int = 48
@export var drift_infl1: int = 0
@export var drift_infl2: int = 0
@export var drift_extra_infl1: int = 0
@export var drift_extra_infl2: int = 0
## 空 | korea_prop_prc | iran_iraq | afghanistan
@export var drift_extra_flag: String = ""
@export var default_side1: String = ""
@export var default_side2: String = ""
@export var default_usa_side: int = 0
@export var default_ussr_side: int = 1
@export var default_infl1: int = 500
@export var default_infl2: int = 500
