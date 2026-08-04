class_name PoliticianSystem
extends RefCounted

## 政客生命周期系统（2026-08 从 GameManager 拆出）。
## 全部 static 函数，通过 GameManager autoload 访问 world 与跨系统辅助
## （is_mao_dead / is_mao_protected / _mod_active / _notify_stats）。
## 对齐来源：TimeScript.cs 政客块 + DeathPolitics/PlotPolitics + Button_Pol_Script。
##
## GameManager 保留同名公开 stub（change_of_killing / kill_politician /
## assign_politician_position / set_faction_leader_politician /
## fill_vacant_faction_leaders），外部调用点（政治界面 / 事件脚本）零改动。

const W = preload("res://数据脚本/world_state.gd")


static func is_vacant_politician(p: PoliticianData) -> bool:
	return p == null or p.name_display == "空位" or (p.power <= 0 and p.portrait == null)


# ============================================================================
# 月度 / 年度 / 阴谋循环
# ============================================================================

## 月结：调查/监视计数、自动支持·打压、在职 power 加成、空缺派系领袖补位
static func monthly_politics(d: Array[int], w: WorldState) -> void:
	@warning_ignore("integer_division")
	sync_in_power_flags(w)
	for i in w.politicians.size():
		var p: PoliticianData = w.politicians[i]
		if is_vacant_politician(p):
			continue

		# POL-01 调查：满 7 结案（原版只清标志；副作用在开调查时已扣）
		if p.is_under_investigation:
			if p.investigator_index < 0:
				p.investigator_index = 0
			p.investigator_index += 1
			if p.investigator_index >= 7:
				p.investigator_index = 0
				p.is_under_investigation = false

		# POL-01 监视：满 7 解除
		if p.is_under_surveillance:
			p.days_surveillance += 1
			if p.days_surveillance >= 7:
				p.days_surveillance = 0
				p.is_under_surveillance = false

		# POL-02 自动支持（TimeScript ~2194）
		if p.auto_support == 10:
			if d[W.I_BUDGET] < 1 or d[W.I_AGENTS] < 5:
				p.auto_support = 0
			else:
				d[W.I_BUDGET] -= 1
				d[W.I_PARTY_SUPPORT] -= 20
				d[W.I_AGENTS] -= 5
				p.loyalty += 50
				p.power += (1976 - w.date.year) * 5
				@warning_ignore("integer_division")
				p.power += absi(p.power / 10)

		# POL-02 自动打压（TimeScript ~2207）
		if p.auto_hound == 10:
			if d[W.I_BUDGET] < 1 or d[W.I_AGENTS] < 20:
				p.auto_hound = 0
			else:
				d[W.I_BUDGET] -= 1
				d[W.I_PARTY_SUPPORT] -= 20
				d[W.I_AGENTS] -= 20
				p.loyalty -= 250
				p.power -= (1976 - w.date.year) * 5
				if p.power >= 10:
					@warning_ignore("integer_division")
					p.power -= absi(p.power / 10)

		apply_monthly_position_power(w, i, p)
		# ECO-POL-06：贪腐特质(18) 在职则抬腐败
		if p.trait_special == 18 and p.in_power:
			d[W.I_CORRUPTION] += 2
		# TimeScript.cs:1871-1883：modifier[14] 每月提升改革派/非领袖自由派声势。
		if GameManager._mod_active(w, 14):
			if p.trait_personality == 2:
				p.power += 10
			elif p.trait_personality == 3:
				var liberal_leader := -1
				if w.factions.size() > FactionData.LIBERAL:
					liberal_leader = w.factions[FactionData.LIBERAL].leader_index
				if liberal_leader != i:
					p.power += 5

	fill_vacant_faction_leaders()
	sync_in_power_flags(w)
	GameManager._notify_stats()


## 年均政客生命周期（POL-05 / POL-12）
static func annual_politics(d: Array[int], w: WorldState) -> void:
	# 年龄增长（全体非空位；领袖独立体也 +1）
	for p in w.politicians:
		if is_vacant_politician(p):
			continue
		p.age += 1
		if p.in_power:
			p.years_in_power += 1
	if w.leader != null:
		w.leader.age += 1

	# DeathPolitics：仅毛逝后才病弱与老死
	if not GameManager.is_mao_dead():
		return
	var to_kill: Array[int] = []
	for i in w.politicians.size():
		var p: PoliticianData = w.politicians[i]
		if is_vacant_politician(p):
			continue
		# 老死：age >= 91..94
		var death_age: int = 91 + (i % 4)
		if p.age >= death_age:
			if GameManager.is_mao_protected(i):
				continue
			to_kill.append(i)
			continue
		# 病弱：非改革 traits[0]!=2 时 80..83；改革派 85..88
		if p.trait_special == 19:
			continue
		var sick_age: int
		if p.trait_personality == 2:
			sick_age = 85 + (i % 4)
		else:
			sick_age = 80 + (i % 4)
		if p.age >= sick_age:
			p.trait_special = 19
	for idx in to_kill:
		kill_politician(idx)
	# PlotPolitics 与 DeathPolitics 同频（年，TimeScript ~5734）
	plot_politics(d, w)


## POL-06 简化：对高 power 目标，若低忠诚他人 power 和过高则标记阴谋并可能削权/撤职/击杀
static func plot_politics(d: Array[int], w: WorldState) -> void:
	if not GameManager.is_mao_dead():
		return
	@warning_ignore("integer_division")
	var to_kill: Array[int] = []
	for i in w.politicians.size():
		var target: PoliticianData = w.politicians[i]
		if is_vacant_politician(target):
			continue
		if target.power <= 250 and target.trait_special != 16:
			continue
		var plot_power := 0
		for j in w.politicians.size():
			if j == i:
				continue
			var pol: PoliticianData = w.politicians[j]
			if is_vacant_politician(pol) or pol.is_under_investigation:
				continue
			if pol.trait_special == 17 or pol.trait_special == 19:
				continue
			var rel: int = 500
			if i < pol.loyalty_matrix.size():
				rel = pol.loyalty_matrix[i]
			var joins := false
			if pol.trait_special == 16 and rel < 450:
				joins = true
			elif pol.trait_special == 9 and rel < 150:
				joins = true
			elif pol.trait_special != 9 and rel < 300:
				joins = true
			if joins:
				plot_power += pol.power
		var resist := 3.0
		if target.trait_special == 14 or target.trait_special == 13:
			resist = 5.0
		elif target.trait_special == 12 or target.trait_alignment == 6:
			resist = 2.0
		for pos_id in mini(3, w.politics_positions.size()):
			if w.politics_positions[pos_id] == i:
				resist += 2.0 if pos_id == 0 else 1.0
		if float(plot_power) > resist * float(target.power):
			target.is_conspiracy = true
			var seed_v: int = abs(hash("%d-%d-%d-%d" % [w.date.year, w.date.month, i, plot_power]))
			var r1: int = seed_v % 11
			@warning_ignore("integer_division")
			var r2: int = (seed_v / 11) % 22
			@warning_ignore("integer_division")
			var r3: int = (seed_v / 242) % 44
			var man: int = d[W.I_MANPOWER]
			@warning_ignore("integer_division")
			if r1 > man / 100 and r2 > man / 50 and r3 > man / 25:
				if float(plot_power) > resist * 4.0 * float(target.power):
					var is_central := false
					for pos_id2 in mini(3, w.politics_positions.size()):
						if w.politics_positions[pos_id2] == i:
							is_central = true
							w.politics_positions[pos_id2] = -1
					if is_central:
						target.power = 100
						target.you_fall = true
					else:
						to_kill.append(i)
				else:
					@warning_ignore("integer_division")
					target.power -= absi(target.power / 10)
					target.you_fall = true
		else:
			target.is_conspiracy = false
	for idx in to_kill:
		kill_politician(idx)


static func sync_in_power_flags(w: WorldState) -> void:
	var holders: Dictionary = {}
	for pos_id in w.politics_positions.size():
		var h: int = w.politics_positions[pos_id]
		if h >= 0:
			holders[h] = true
	for i in w.politicians.size():
		var p: PoliticianData = w.politicians[i]
		if is_vacant_politician(p):
			p.in_power = false
			continue
		var now: bool = holders.has(i)
		if now and not p.in_power:
			p.years_in_power = 0
		p.in_power = now


## POL-08：监视/再教育「发现·成功率」显示用（GameState.ChangeOfKilling）
## 返回 0.0~1.0 近似概率
static func change_of_killing(politic_index: int) -> float:
	var w := GameManager.world
	if w == null or politic_index < 0 or politic_index >= w.politicians.size():
		return 0.0
	var d := w.数值表
	var pol: PoliticianData = w.politicians[politic_index]
	if pol == null:
		return 0.0
	var num := 0.5
	# 硬目标惩罚（原版 GameState.cs:5160）：traits[3]==28 或 traits[1]==41 → -0.1
	if pol.trait_background == 28 or pol.trait_alignment == 41:
		num -= 0.1
	if d[W.I_AGENTS] + d[W.I_PARTY_SUPPORT] + d[W.I_ARMY] >= pol.power:
		num += 0.05
	else:
		num -= 0.05
	if d[W.I_AGENTS] + d[W.I_PARTY_SUPPORT] >= pol.power:
		num += 0.05
	var avg_loy: int = sum_loyalty_avg()
	if avg_loy > 900:
		num += 0.15
	elif avg_loy > 800:
		num += 0.12
	elif avg_loy > 700:
		num += 0.1
	elif avg_loy > 600:
		num += 0.07
	elif avg_loy > 500:
		num += 0.05
	else:
		num -= 0.05
	if d[W.I_PARTY_SUPPORT] > 800:
		num += 0.05
	elif d[W.I_PARTY_SUPPORT] < 700:
		num -= 0.05
	if pol.is_under_investigation:
		num += 0.1
	# 原版 GameState.cs:5212 return num，不钳制（允许 <0 必败 / >1 必成）
	return num


static func sum_loyalty_avg() -> int:
	var w := GameManager.world
	if w == null or w.politicians.is_empty():
		return 0
	var s := 0
	var n := 0
	for p in w.politicians:
		if is_vacant_politician(p):
			continue
		s += p.loyalty
		n += 1
	if n <= 0:
		return 0
	@warning_ignore("integer_division")
	return s / n


static func apply_monthly_position_power(w: WorldState, pol_index: int, p: PoliticianData) -> void:
	# TimeScript 2223–2237：地方 +10，首都 +15，总理/军委/外交 +20
	@warning_ignore("integer_division")
	var bonus := 0
	for pos_id in w.politics_positions.size():
		if w.politics_positions[pos_id] != pol_index:
			continue
		if pos_id <= 2:
			bonus = maxi(bonus, 20)
		elif pos_id == 3:
			bonus = maxi(bonus, 15)
		else:
			bonus = maxi(bonus, 10)
	if bonus > 0:
		p.power += bonus
	elif p.trait_special == 18:
		p.power += 4
	elif p.trait_special == 19:
		p.power -= 20
	elif p.trait_special == 16:
		@warning_ignore("integer_division")
		p.power += 1 + w.数值表[W.I_CORRUPTION] / 50


# ============================================================================
# 死亡 / 任命 / 派系领袖
# ============================================================================

## 死亡/再教育：清职与派系领袖，同槽补员（KillPerson → BalancePolitic）
static func kill_politician(pol_index: int) -> void:
	var w := GameManager.world
	if w == null or pol_index < 0 or pol_index >= w.politicians.size():
		return
	# POL-14：毛在世保护 politics[0]（data[38]!=100 时不可杀）
	if GameManager.is_mao_protected(pol_index):
		push_warning("GameManager: 毛泽东在世保护，拒绝 kill %d" % pol_index)
		return
	for i in w.politics_positions.size():
		if w.politics_positions[i] == pol_index:
			w.politics_positions[i] = -1
	for f in w.factions:
		if f.leader_index == pol_index:
			f.leader_index = -1

	var year: int = w.date.year if w.date else 1976
	var existing_parties: Array[int] = []
	for i in w.politicians.size():
		if i == pol_index:
			continue
		var other: PoliticianData = w.politicians[i]
		if not is_vacant_politician(other):
			existing_parties.append(other.party_index())

	var replacement := PoliticianPool.pick_replacement(
		w.politician_reserve, year, existing_parties
	)
	if replacement != null:
		# 保持 matrix 长度与槽位数一致
		if replacement.loyalty_matrix.size() < w.politicians.size():
			replacement.loyalty_matrix.resize(w.politicians.size())
		w.politicians[pol_index] = replacement
		WorldFactory._calc_rel(w, pol_index)
		WorldFactory._calc_rel_leader(w, pol_index)
	else:
		var empty := w.politicians[pol_index]
		empty.power = 0
		empty.loyalty = 0
		empty.name_display = "空位"
		empty.is_under_surveillance = false
		empty.is_under_investigation = false
		empty.is_conspiracy = false
		empty.you_fall = false
		empty.in_power = false
		empty.years_in_power = 0
		empty.auto_support = 0
		empty.auto_hound = 0
		empty.portrait = null
		empty.days_surveillance = 0
		empty.investigator_index = -1

	fill_vacant_faction_leaders()
	sync_in_power_flags(w)
	GameManager._notify_stats()


## POL-10 任命：按职位细表改 loyalty / matrix，并 POL-20 重算关系
## position_id: 0总理 1军委 2外交 3首都 4北方 5西方 6南方 7东方
## 对齐 Button_Pol_Script num7/5/6/8-12（注意原版按钮编号与 dolshnost 索引映射）
static func assign_politician_position(pol_index: int, position_id: int) -> bool:
	var w := GameManager.world
	if w == null or pol_index < 0 or pol_index >= w.politicians.size():
		return false
	if position_id < 0 or position_id >= w.politics_positions.size():
		return false
	var pol: PoliticianData = w.politicians[pol_index]
	if is_vacant_politician(pol) or pol.is_under_investigation:
		return false
	# 已在该职
	if w.politics_positions[position_id] == pol_index:
		return false

	# 职位互斥：地方 3-7 互斥；总理清空其它；军委/外交互斥对方
	for i in range(3, 8):
		if w.politics_positions[i] == pol_index:
			w.politics_positions[i] = -1
	if position_id == 0:
		for i in range(1, 8):
			if w.politics_positions[i] == pol_index:
				w.politics_positions[i] = -1
	elif position_id == 1 or position_id == 2:
		var other_central := 2 if position_id == 1 else 1
		if w.politics_positions[other_central] == pol_index:
			w.politics_positions[other_central] = -1

	# 前任惩罚表：prev_loyalty_delta, prev_matrix_delta, new_loyalty, wanted_bonus
	# wanted 命中时 prev 额外 -400 loyalty 与 matrix（原版）
	var prev_loy := 250
	var prev_mat := 50
	var new_loy := 250
	match position_id:
		0:  # 总理 num7
			prev_loy = 800; prev_mat = 400; new_loy = 400
		1:  # 军委 num5
			prev_loy = 700; prev_mat = 300; new_loy = 350
		2:  # 外交 num6
			prev_loy = 600; prev_mat = 250; new_loy = 350
		3:  # 首都 num8
			prev_loy = 250; prev_mat = 50; new_loy = 300
		_:  # 地方 4-7
			prev_loy = 150; prev_mat = 0; new_loy = 250

	var prev_holder: int = w.politics_positions[position_id]
	if prev_holder >= 0 and prev_holder < w.politicians.size() and prev_holder != pol_index:
		var prev_pol: PoliticianData = w.politicians[prev_holder]
		if not is_vacant_politician(prev_pol):
			var extra := 400 if prev_pol.wanted_position == position_id else 0
			prev_pol.loyalty -= prev_loy + extra
			if pol_index < prev_pol.loyalty_matrix.size():
				prev_pol.loyalty_matrix[pol_index] = maxi(
					0, prev_pol.loyalty_matrix[pol_index] - (prev_mat + extra)
				)

	w.politics_positions[position_id] = pol_index
	pol.loyalty += new_loy
	# 原版 Button_Pol_Script num5-12：命中意向职位仅 loyality+=250，不加 power
	if pol.wanted_position == position_id:
		pol.loyalty += 250
	pol.in_power = true

	# POL-20：任命后重算目标与前任关系矩阵 + 对领袖忠诚
	WorldFactory._calc_rel(w, pol_index)
	WorldFactory._calc_rel2(w, pol_index)
	WorldFactory._calc_rel_leader(w, pol_index)
	if prev_holder >= 0 and prev_holder < w.politicians.size() and prev_holder != pol_index:
		WorldFactory._calc_rel(w, prev_holder)
		WorldFactory._calc_rel2(w, prev_holder)
		WorldFactory._calc_rel_leader(w, prev_holder)

	sync_in_power_flags(w)
	fill_vacant_faction_leaders()
	GameManager._notify_stats()
	return true


## 指定派系负责人后重算关系（FAC-07 半）
static func set_faction_leader_politician(pol_index: int) -> bool:
	var w := GameManager.world
	if w == null or pol_index < 0 or pol_index >= w.politicians.size():
		return false
	var pol: PoliticianData = w.politicians[pol_index]
	if is_vacant_politician(pol):
		return false
	var faction_id: int = pol.party_index()
	if faction_id < 0 or faction_id >= w.factions.size():
		return false
	var prev: int = w.factions[faction_id].leader_index
	if prev >= 0 and prev < w.politicians.size() and prev != pol_index:
		var prev_pol: PoliticianData = w.politicians[prev]
		prev_pol.loyalty -= 1000
		if pol_index < prev_pol.loyalty_matrix.size():
			prev_pol.loyalty_matrix[pol_index] -= 500
	w.factions[faction_id].leader_index = pol_index
	# 同派小惩罚
	for i in w.politicians.size():
		if i == pol_index:
			continue
		var other: PoliticianData = w.politicians[i]
		if other != null and other.party_index() == faction_id:
			other.loyalty -= 100
	pol.loyalty += 400
	WorldFactory._calc_rel(w, pol_index)
	WorldFactory._calc_rel2(w, pol_index)
	WorldFactory._calc_rel_leader(w, pol_index)
	if prev >= 0 and prev < w.politicians.size() and prev != pol_index:
		WorldFactory._calc_rel(w, prev)
		WorldFactory._calc_rel2(w, prev)
		WorldFactory._calc_rel_leader(w, prev)
	GameManager._notify_stats()
	return true


## 空缺派系领袖：按 Party 槽从在世政客中选 power 最高者（POL-04）
static func fill_vacant_faction_leaders() -> void:
	var w := GameManager.world
	if w == null:
		return
	for fi in w.factions.size():
		var f: FactionData = w.factions[fi]
		# 事件26第三分支对应原 faction_leader[0]=200：实权领袖本人领导极左派。
		if f.leader_index == WorldFactory.LEADER_POSITION_SENTINEL and w.leader != null:
			continue
		if f.leader_index >= 0 and f.leader_index < w.politicians.size():
			var cur: PoliticianData = w.politicians[f.leader_index]
			if not is_vacant_politician(cur):
				continue
			f.leader_index = -1
		if f.leader_index >= 0:
			continue
		var best_idx := -1
		var best_power := -1
		var fallback_idx := -1
		var fallback_power := -1
		for i in w.politicians.size():
			var p: PoliticianData = w.politicians[i]
			if is_vacant_politician(p):
				continue
			var party: int = p.party_index()
			if party == fi and p.power > best_power:
				best_power = p.power
				best_idx = i
			# 保守派空缺：允许 traits 映射到 0/1 的人作次选（简化 TimeScript 957）
			if fi == 1 and (party == 0 or party == 1) and p.power > fallback_power:
				fallback_power = p.power
				fallback_idx = i
		if best_idx >= 0:
			f.leader_index = best_idx
		elif fallback_idx >= 0:
			f.leader_index = fallback_idx
