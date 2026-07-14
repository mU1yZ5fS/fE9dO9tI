## 玩家经济数据 — WorldState.数值表[] 的只读显示视图。
## 不持有数据副本，仅在 sync() 时从源数组提取并换算显示值。
class_name EconomyData
extends Resource

# 数值表索引 → 语义名对照（权威源：原版 QueryChina.cs）
#   [1]党内支持  [3]民众支持  [4]思想自由  [5]生活水平
#   [6]国际声望  [7]全球影响  [8]预算      [9]特工网络
#   [11]科研点   [12]工业     [13]农业     [22]军力
#   [34]人口     [36]外汇储备

@export_category("社会")
@export var 党内支持度: float = 0.0
@export var 民众支持度: float = 0.0
@export var 思想自由度: float = 0.0
@export var 生活水平: float = 0.0
@export var 国际声望: float = 0.0
@export var 全球影响力: float = 0.0

@export_category("财政军事")
@export var 预算: int = 0
@export var 特工网络: int = 0
@export var 科研点数: int = 0
@export var 工业: int = 0
@export var 农业: int = 0
@export var 军力: int = 0
@export var 外汇储备: int = 0
@export var 人口: int = 0


## 从数值表（int[150]）提取显示值。无副本，无 duplicate。
func sync(数值表: Array[int]) -> void:
	if 数值表.size() < 150:
		return
	党内支持度 = float(数值表[1]) / 10.0
	民众支持度 = float(数值表[3]) / 10.0
	思想自由度 = float(数值表[4]) / 10.0
	生活水平 = float(数值表[5]) / 10.0
	国际声望 = float(数值表[6]) / 10.0
	全球影响力 = float(数值表[7]) / 10.0
	预算 = 数值表[8]
	特工网络 = 数值表[9]
	科研点数 = 数值表[11]
	工业 = 数值表[12]
	农业 = 数值表[13]
	军力 = 数值表[22]
	人口 = 数值表[34]
	外汇储备 = 数值表[36]
