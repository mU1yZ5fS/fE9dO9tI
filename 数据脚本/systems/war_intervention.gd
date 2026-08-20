class_name WarIntervention
extends RefCounted

## WarSystem 的干预动作执行器（2026-08 门面拆分）。
## 纯函数：所有 WorldState 依赖显式传入，不持有 current_world。

const W = preload("res://数据脚本/world_state.gd")

# 战争支援辅助（原版 WarButtonScript.OnMouseDown 逐段）
# ============================================================================

## 基础增援：side 方 +delta，对方 -delta
static func apply_base(war: WarData, side: int, delta: int) -> void:
	if side == 1:
		war.infl1 += delta
		war.infl2 -= delta
	else:
		war.infl2 += delta
		war.infl1 -= delta


## 人力增援（0/5）：无事件548时基础 +20/-20；事件548 result1 +30/-30、result2 +50/-50，
## result0 时无额外变化（原版 if/else if 链）。
static func apply_human_aid(w: WorldState, war: WarData, side: int) -> void:
	if not w.event_done_num(548):
		apply_base(war, side, 20)
		return
	var r := w.result_of_event_num(548)
	if r == 1:
		apply_base(war, side, 30)
	elif r == 2:
		apply_base(war, side, 50)


## 事件548：result 1 → +30/-30，result 2 → +50/-50（用于 0/5）
static func apply_event548(w: WorldState, war: WarData, side: int, delta_r1: int, delta_r2: int) -> void:
	if not w.event_done_num(548):
		return
	var r := w.result_of_event_num(548)
	if r == 1:
		apply_base(war, side, delta_r1)
	elif r == 2:
		apply_base(war, side, delta_r2)


## 事件548：仅 result 2 时 +20/-20（用于 2/6）
static func apply_event548_2(w: WorldState, war: WarData, side: int) -> void:
	if w.event_done_num(548) and w.result_of_event_num(548) == 2:
		apply_base(war, side, 20)


## 事件548：外交声援 result 1 → +110/-110，result 2 → +140/-140
static func apply_event548_diplo(w: WorldState, war: WarData, side: int) -> void:
	# 原版：事件548未完成 → +80/-80；已完成且 result1/2 → +110/-110、+140/-140；
	# 已完成但 result0 → 不加（if/else if 链）。
	if not w.event_done_num(548):
		apply_base(war, side, 80)
		return
	var r := w.result_of_event_num(548)
	if r == 1:
		apply_base(war, side, 110)
	elif r == 2:
		apply_base(war, side, 140)


## 科技24（专家）：+10/-10
static func apply_science24(w: WorldState, war: WarData, side: int) -> void:
	if w != null and w.techs != null and w.techs.unlocked.size() > 24 and w.techs.unlocked[24]:
		apply_base(war, side, 10)


## 科技23（武器）：true 时基础增援用 40，否则 30
static func science23(w: WorldState) -> bool:
	return w != null and w.techs != null and w.techs.unlocked.size() > 23 and w.techs.unlocked[23]


## 事件517：result 0/1 → +10/-10，result 2 → +20/-20
static func apply_event517(w: WorldState, war: WarData, side: int) -> void:
	if not w.event_done_num(517):
		return
	var r := w.result_of_event_num(517)
	if r == 0 or r == 1:
		apply_base(war, side, 10)
	elif r == 2:
		apply_base(war, side, 20)


## 事件521：result 1 → +10/-10，result 2 → +20/-20
static func apply_event521(w: WorldState, war: WarData, side: int) -> void:
	if not w.event_done_num(521):
		return
	var r := w.result_of_event_num(521)
	if r == 1:
		apply_base(war, side, 10)
	elif r == 2:
		apply_base(war, side, 20)


## PMC > 0：+20/-20
static func apply_pmc(w: WorldState, war: WarData, side: int) -> void:
	if w != null and w.pmc > 0:
		apply_base(war, side, 20)


## 非外交动作：对敌方阵营帝国关系 -5（side1 的敌人在 usa_place==1/ussr_place==1）
static func apply_enemy_relation(w: WorldState, war: WarData, side: int, delta: int) -> void:
	if side == 1:
		if war.usa_side == GameConstants.WarSide.SIDE2 and w.empires.size() > 0:
			w.empires[0].relations += delta
		if war.ussr_side == GameConstants.WarSide.SIDE2 and w.empires.size() > 1:
			w.empires[1].relations += delta
	else:
		if war.usa_side == GameConstants.WarSide.SIDE1 and w.empires.size() > 0:
			w.empires[0].relations += delta
		if war.ussr_side == GameConstants.WarSide.SIDE1 and w.empires.size() > 1:
			w.empires[1].relations += delta


## 外交声援：友方阵营帝国关系 +30
static func apply_diplo(w: WorldState, war: WarData, side: int) -> void:
	if side == 1:
		if war.usa_side == GameConstants.WarSide.SIDE1 and w.empires.size() > 0:
			w.empires[0].relations += 30
		if war.ussr_side == GameConstants.WarSide.SIDE1 and w.empires.size() > 1:
			w.empires[1].relations += 30
	else:
		if war.usa_side == GameConstants.WarSide.SIDE2 and w.empires.size() > 0:
			w.empires[0].relations += 30
		if war.ussr_side == GameConstants.WarSide.SIDE2 and w.empires.size() > 1:
			w.empires[1].relations += 30


## 事件545 分档的党内支持（军事介入点 data[0]）消耗；结束后中国不稳定度 +8。
static func apply_party_cost(w: WorldState, d: Array, china: CountryData) -> void:
	if china == null:
		return
	var unstab := china.level_of_instability
	var mult := 10
	if w.event_done_num(545):
		var r := w.result_of_event_num(545)
		if r == 0:
			mult = 8
		elif r == 2:
			mult = 5
	@warning_ignore("integer_division")
	var cost := mult * unstab / 10
	if d.size() > W.I_MIL_INTERVENTION:
		d[W.I_MIL_INTERVENTION] -= cost
	china.level_of_instability += 8



