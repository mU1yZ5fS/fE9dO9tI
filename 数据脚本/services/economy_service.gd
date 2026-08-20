class_name EconomyService
extends RefCounted

## 经济规则服务：预算分配、贷款、储备金。
## 从 GameManager 拆出；所有函数显式接收 WorldState，不访问 autoload。
## notify 为可选的变更通知回调（GameManager 传入 _notify_stats）。

const W = preload("res://数据脚本/world_state.gd")


@warning_ignore_start("integer_division")

## 计算预算分配上限（planka）。UI 可读取用于显示。
func calc_budget_planka(world: WorldState) -> int:
	if world == null:
		return 0
	var d := world.数值表
	var total: int = d[W.I_BUDGET] + d[W.I_RESERVE]
	for i in range(W.I_BUDGET_ARMY, W.I_BUDGET_DIPLO + 1):
		total += d[i]
	if d[W.I_ECON_SYSTEM] > 12:
		total -= (d[W.I_ECON_SYSTEM] - 12) * (total / 10)
	return total


## 调整预算类别。category_idx 为 71-81，delta 为增减量。
## 返回 false 表示余额不足或超过 planka 上限。
func adjust_budget(world: WorldState, category_idx: int, delta: int, notify: Callable = Callable()) -> bool:
	if world == null:
		return false
	var d := world.数值表
	var is_budget_category := category_idx >= W.I_BUDGET_ARMY and category_idx <= W.I_BUDGET_DIPLO
	if not is_budget_category:
		return false
	if delta > 0:
		if d[W.I_BUDGET] < delta:
			return false
		var limit6 := calc_budget_planka(world) / 6
		# 原版 Plusmisnus_script.cs:79（普通+10）只检查当前值 <= planka2/6，
		# 允许加到 planka2/6+10；Shift/Ctrl 分支(:87/:93)才检查 data[idx]+50/100 <= planka2/6。
		if delta == 10:
			if d[category_idx] > limit6:
				return false
		elif d[category_idx] + delta > limit6:
			return false
	if delta < 0 and d[category_idx] < -delta:
		return false
	d[category_idx] += delta
	d[W.I_BUDGET] -= delta
	# 原版 Plusmisnus_script.payment：削减「高层福利」时按 4× 扣党内支持
	# -10 → 党支持-40；-50 → -200；-100 → -400
	if category_idx == W.I_BUDGET_ENVELOPE and delta < 0:
		d[W.I_PARTY_SUPPORT] -= (-delta) * 4
	if notify.is_valid():
		notify.call()
	return true


## 调整贷款。delta > 0 借入，delta < 0 还款。借入扣减党支持。
func adjust_loan(world: WorldState, delta: int, notify: Callable = Callable()) -> bool:
	if world == null:
		return false
	var d := world.数值表
	if delta > 0:
		# 借入：检查贷款上限（原版 Plusmisnus_script.cs:195 `loan < planka`）。
		# 原版 planka = (empires[0].relations + empires[1].relations) / 5，
		# 不是投资总额 calc_budget_planka()（那是 11 项预算的上限，见 CheckPlanka）。
		var loan_limit := 0
		if world.empires.size() > 0:
			loan_limit += world.empires[0].relations
		if world.empires.size() > 1:
			loan_limit += world.empires[1].relations
		loan_limit = loan_limit / 5
		if d[W.I_LOAN] >= loan_limit:
			return false
		d[W.I_LOAN] += delta
		d[W.I_BUDGET] += delta
		d[W.I_PARTY_SUPPORT] -= delta
		# 借款思想自由：原版 data[4] += 10（Plusmisnus_script.cs:201），非 ×2.5
		d[W.I_THOUGHT_FREEDOM] += delta
		# 借款影响力：原版 influencePRC--（Plusmisnus_script.cs:200）
		world.influence_prc -= 1
	else:
		# 还款：loan 为正才可还；零头(0<loan<10)只还剩余额并清零（原版:177-194）
		if d[W.I_LOAN] <= 0:
			return false
		var repay_amount := mini(-delta, d[W.I_LOAN])
		var mult := 1
		# 原版：diff==3 时 ×3，diff 2/4 时 ×2（Plusmisnus_script.cs:184-186）
		if world.difficulty == 3:
			mult = 3
		elif world.difficulty >= 2:
			mult = 2
		var budget_cost := repay_amount * mult
		# 原版不检查预算余额（Plusmisnus:158-194 无条件扣减，可为负，由日块赤字恢复兜底）
		d[W.I_LOAN] -= repay_amount
		d[W.I_BUDGET] -= budget_cost
		# 还款党支持：原版 data[1] += 5（Plusmisnus_script.cs:173/192），非 +10
		d[W.I_PARTY_SUPPORT] += 5
		# 还款影响力：原版 influencePRC++ 仅常规分支（:174），零头分支(:177-194)无
		if repay_amount >= 10:
			world.influence_prc += 1
	if notify.is_valid():
		notify.call()
	return true


## 调整储备金。delta > 0 存入，delta < 0 取出。取出扣减党支持和民众支持。
func adjust_reserve(world: WorldState, delta: int, notify: Callable = Callable()) -> bool:
	if world == null:
		return false
	var d := world.数值表
	if delta > 0:
		if d[W.I_BUDGET] < delta:
			return false
		d[W.I_RESERVE] += delta
		d[W.I_BUDGET] -= delta
	else:
		if d[W.I_RESERVE] < -delta:
			return false
		d[W.I_RESERVE] += delta
		d[W.I_BUDGET] -= delta
		d[W.I_PARTY_SUPPORT] += delta
		d[W.I_PEOPLE_SUPPORT] += delta
	if notify.is_valid():
		notify.call()
	return true

@warning_ignore_restore("integer_division")
