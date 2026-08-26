class_name PositionCatalog
extends RefCounted

## 职位目录——已还原原版 8 槽：0总理 1军委主席 2外交部长 3-7 五大区主管。
## id 即 politics_positions 下标；-1 空缺 / -2 实权领袖兼任（哨兵不变）。
## 0/1/2 三职 penalty 逐字对齐原版 Button_Pol_Script（冻结清单 §8）。
##
## penalty = [前任忠诚-, 前任矩阵-, 新任忠诚+]；矩阵 -1 表示不动矩阵（沿用地方式规则）。

const POSITIONS_SIZE := 8

const DEFS := {
	0: {"name": "国务院总理", "min_tier": 2, "penalty": [800, 400, 400]},
	1: {"name": "中央军委主席", "min_tier": 2, "penalty": [700, 300, 350]},
	2: {"name": "外交部长", "min_tier": 2, "penalty": [600, 250, 350]},
	3: {"name": "京畿主管", "min_tier": 3, "penalty": [250, 50, 300]},
	4: {"name": "华北主管", "min_tier": 3, "penalty": [150, -1, 250]},
	5: {"name": "华西主管", "min_tier": 3, "penalty": [150, -1, 250]},
	6: {"name": "华南主管", "min_tier": 3, "penalty": [150, -1, 250]},
	7: {"name": "华东主管", "min_tier": 3, "penalty": [150, -1, 250]},
}


static func def(id: int) -> Dictionary:
	return DEFS.get(id, {})


static func name(id: int) -> String:
	return DEFS.get(id, {}).get("name", "未知职位")


## 任命列表遍历顺序：中央三职 → 五大区
static func appointment_order() -> Array:
	return [0, 1, 2, 3, 4, 5, 6, 7]
