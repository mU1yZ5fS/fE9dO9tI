class_name DiploActionDef
extends Resource

## 外交动作数据定义（内容出代码的目标 Resource）。
## 当前仍以代码批次 _def_N 为运行时权威；本类用于后续逐步把动作迁到 JSON/Resource。

@export var id: int = 0
@export var caption: String = ""
@export var opis: String = ""
## 条件描述与检查表达式（预留 DSL，后续接入 ExprNode）。
@export var conditions: Array = []
## 效果描述（预留 DSL，后续接入 EffectNode）。
@export var effects: Array = []
## 是否隐藏/不可用。
@export var dormant: bool = false
@export var source: String = ""
