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

		# POL-01 调查/监视推进 — 严格对齐 TimeScript.cs:2916-2938：
		# 原版先判 sled<7 则 +1；>=7 的下一次月结才清零结案（即显示 0..7 共 8 个月历）。
		if p.is_under_investigation and p.investigator_index < 7:
			p.investigator_index += 1
		elif p.investigator_index >= 7:
			p.investigator_index = 0
			p.is_under_investigation = false

		if p.is_under_surveillance and p.days_surveillance < 7:
			p.days_surveillance += 1
		elif p.days_surveillance >= 7:
			p.days_surveillance = 0
			p.is_under_surveillance = false

		# POL-02 自动支持 — 严格对齐 TimeScript.cs:2940-2956：
		# 原版不检查资源，直接扣费；power += power/10 不带 abs。
		if p.auto_support == 10:
			d[W.I_BUDGET] -= 1
			d[W.I_PARTY_SUPPORT] -= 20
			d[W.I_AGENTS] -= 5
			p.loyalty += 50
			p.power += (1976 - w.date.year) * 5
			@warning_ignore("integer_division")
			p.power += p.power / 10

		# POL-02 自动打压 — 严格对齐 TimeScript.cs:2957-2965：
		# 原版同样不检查资源；power>=10 时 power -= power/10（不带 abs）。
		if p.auto_hound == 10:
			d[W.I_BUDGET] -= 1
			d[W.I_PARTY_SUPPORT] -= 20
			d[W.I_AGENTS] -= 20
			p.loyalty -= 250
			p.power -= (1976 - w.date.year) * 5
			if p.power >= 10:
				@warning_ignore("integer_division")
				p.power -= p.power / 10

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


## POL-06 阴谋 — 逐字对齐 TimeScript.PlotPolitics（TimeScript.cs:281-360）。
## 谓词、抵抗、随机三连、击杀/撤职保护条件全部照抄；
## 随机改走 WorldState 种子 RNG（三次独立抽取，存档续流可复现，等价替代 Unity Random）。
static func plot_politics(d: Array[int], w: WorldState) -> void:
	if not GameManager.is_mao_dead():
		return
	var rng := w.ensure_rng()
	for i in w.politicians.size():
		var target: PoliticianData = w.politicians[i]
		if is_vacant_politician(target):
			continue
		# 原版 TimeScript.cs:286：仅 power > 250 || gamerules[4]==1 进入（gamerules 未移植→0）
		if target.power <= 250 and _game_rule(w, 4) != 1:
			continue
		var plot_power := 0
		# 原版 TimeScript.cs:294 谓词：按对目标的关系矩阵（loyality_to_other[i]）
		for j in w.politicians.size():
			var pol: PoliticianData = w.politicians[j]
			if is_vacant_politician(pol) or pol.is_under_investigation:
				continue
			if pol.trait_special == 17 or pol.trait_special == 19:
				continue
			var rel := 0
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
		if w.politics_positions[0] == i:
			resist += 2.0
		if w.politics_positions[1] == i:
			resist += 1.0
		if w.politics_positions[2] == i:
			resist += 1.0

		if float(plot_power) > resist * float(target.power):
			target.is_conspiracy = true
			# 原版 TimeScript.cs:329：Random.Range(0,11)>data[57]/100 && ... 三连
			var r1 := rng.randf() * 11.0
			var r2 := rng.randf() * 22.0
			var r3 := rng.randf() * 44.0
			@warning_ignore("integer_division")
			if r1 > d[W.I_MANPOWER] / 100 and r2 > d[W.I_MANPOWER] / 50 and r3 > d[W.I_MANPOWER] / 25:
				if float(plot_power) > resist * 4.0 * float(target.power) \
						and _plot_kill_allowed(w, i):
					# 原版 TimeScript.cs:336-353：非中央职 KillPerson；中央职清职 power=100
					if w.politics_positions[0] != i and w.politics_positions[1] != i \
							and w.politics_positions[2] != i:
						kill_politician(i)
					else:
						if w.politics_positions[0] == i:
							w.politics_positions[0] = -1
						if w.politics_positions[1] == i:
							w.politics_positions[1] = -1
						if w.politics_positions[2] == i:
							w.politics_positions[2] = -1
						target.power = 100
						# 注意：原版此分支不置 you_fall（Godot 旧实现误置，已修正）
				else:
					# 原版 TimeScript.cs:356：power -= power/10，不置 you_fall
					@warning_ignore("integer_division")
					target.power -= target.power / 10
		else:
			target.is_conspiracy = false


## 阴谋击杀的历史保护条件 — 逐字对齐 TimeScript.cs:331-335（Button_Pol_Script num2 同款）。
static func _plot_kill_allowed(w: WorldState, i: int) -> bool:
	var d := w.数值表
	var ev25 := w.completed_event_ids.has("gang_of_four")
	var ev26 := w.completed_event_ids.has("weak_alliance")
	var ev80 := w.completed_event_ids.has("event_80")  # 原版 event_done[80]，Godot 未移植 → 恒 false
	var mod3: bool = GameManager._mod_active(w, 3)
	var year_ok := d[W.I_YEAR] >= 1978
	var basic := i > 5 and i != 7 and (i < 11 or i > 15) and i != 17
	var e25a := ev25 and d[W.I_GANG_OF_FOUR_PATH] != 3 and (i < 12 or i > 15)
	var e26a := ev26 and ((w.leader != null and w.leader.name_first != 0) or i == 1)
	var y1 := year_ok and not ev80 and mod3 and i > 4
	var y2 := year_ok and (ev80 or not mod3)
	var e25b := ev25 and d[W.I_GANG_OF_FOUR_PATH] == 3 and (i < 1 or i > 4)
	return (basic or e25a or e26a or y1 or y2 or e25b) and (i > 4 or not mod3)


## 未移植的 gamerules 读取口（原版 ChoiceSystemController.cs:13-20,249-250）。
static func _game_rule(w: WorldState, idx: int) -> int:
	var v: Variant = w.global_flags.get("gamerule_%d" % idx, 0)
	if v is int:
		return v
	if v is float:
		return int(v)
	return 0


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
	var w: WorldState = GameManager.world
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
	var w: WorldState = GameManager.world
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
	# TimeScript.cs:2972-3010：地方 +10，首都 +15，总理/军委/外交 +20；
	# 无职按 traits[2]：18 +4、19 -20、16 +1+腐败/50、其它 +1；
	# 最后 1978 年起每年 power += (1976-year)/2（C# int 除法向零）。
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
	else:
		p.power += 1
	if w.数值表[W.I_YEAR] > 1977:
		@warning_ignore("integer_division")
		p.power += (1976 - w.数值表[W.I_YEAR]) / 2


# ============================================================================
# 死亡 / 任命 / 派系领袖
# ============================================================================

## 死亡/再教育：清职与派系领袖，同槽补员（KillPerson → BalancePolitic）
static func kill_politician(pol_index: int) -> void:
	var w: WorldState = GameManager.world
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
	var w: WorldState = GameManager.world
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
	# prev_matrix_delta < 0 表示原版不扣关系矩阵（地方职 num9-12，Button_Pol_Script.cs:865-944）
	var prev_loy := 250
	var prev_mat := -1
	var new_loy := 250
	match position_id:
		0:  # 总理 num7（Button_Pol_Script.cs:823-843）
			prev_loy = 800; prev_mat = 400; new_loy = 400
		1:  # 军委 num5（Button_Pol_Script.cs:773-797）
			prev_loy = 700; prev_mat = 300; new_loy = 350
		2:  # 外交 num6（Button_Pol_Script.cs:798-822）
			prev_loy = 600; prev_mat = 250; new_loy = 350
		3:  # 首都 num8（Button_Pol_Script.cs:844-864）
			prev_loy = 250; prev_mat = 50; new_loy = 300
		_:  # 地方 4-7（Button_Pol_Script.cs:865-944：只扣 loyalty，不动矩阵）
			prev_loy = 150; prev_mat = -1; new_loy = 250

	var prev_holder: int = w.politics_positions[position_id]
	if prev_holder >= 0 and prev_holder < w.politicians.size() and prev_holder != pol_index:
		var prev_pol: PoliticianData = w.politicians[prev_holder]
		if not is_vacant_politician(prev_pol):
			var extra := 400 if prev_pol.wanted_position == position_id else 0
			prev_pol.loyalty -= prev_loy + extra
			# 原版矩阵无下限钳制；地方职不扣矩阵
			if prev_mat >= 0 and pol_index < prev_pol.loyalty_matrix.size():
				prev_pol.loyalty_matrix[pol_index] -= prev_mat + extra

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


## 派系领袖槽判定 — 改版口径（用户确认）：
## 优先 PoliticianData.faction 显式 Party 槽（改版新增字段，与派系界面/事件脚本一致）；
## faction 未显式指定时回退原版 traits[0] 映射（Button_Pol_Script.cs:947-967）：
## 0→槽0；20→槽1；1→槽2；2→槽3；3→槽4。
static func trait_faction_slot(p: PoliticianData) -> int:
	if p == null:
		return -1
	if p.faction >= 0 and p.faction <= 4:
		return p.faction
	var t0 := p.trait_personality
	if t0 <= 0:
		return 0
	if t0 == 20:
		return 1
	if t0 >= 1 and t0 <= 4:
		return t0 + 1
	return -1


## 指定派系负责人（原版 num14，Button_Pol_Script.cs:945-976；槽位判定按改版 faction 口径）
static func set_faction_leader_politician(pol_index: int) -> bool:
	var w: WorldState = GameManager.world
	if w == null or pol_index < 0 or pol_index >= w.politicians.size():
		return false
	var pol: PoliticianData = w.politicians[pol_index]
	if is_vacant_politician(pol):
		return false
	var faction_id: int = trait_faction_slot(pol)
	if faction_id < 0 or faction_id >= w.factions.size():
		return false
	var prev: int = w.factions[faction_id].leader_index
	if prev >= 0 and prev < w.politicians.size() and prev != pol_index:
		var prev_pol: PoliticianData = w.politicians[prev]
		prev_pol.loyalty -= 1000
		if pol_index < prev_pol.loyalty_matrix.size():
			prev_pol.loyalty_matrix[pol_index] -= 500
	w.factions[faction_id].leader_index = pol_index
	# 原版 foreach 不排除本人：同 traits[0] 全员 -100，本人随后 +400（净 +300）
	for i in w.politicians.size():
		var other: PoliticianData = w.politicians[i]
		if other != null and other.trait_personality == pol.trait_personality:
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


## 空缺派系领袖 — 对齐 TimeScript.cs:1051-1111 的「每槽只从本派选 power 最高者」；
## 派系归属用改版 faction 字段（原版按 traits[0]，见 trait_faction_slot 说明）。
static func fill_vacant_faction_leaders() -> void:
	var w: WorldState = GameManager.world
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
		var best_power := 0
		for i in w.politicians.size():
			var p: PoliticianData = w.politicians[i]
			if is_vacant_politician(p):
				continue
			if trait_faction_slot(p) == fi and p.power > best_power:
				best_power = p.power
				best_idx = i
		if best_idx >= 0:
			f.leader_index = best_idx
		# 原版找不到则保持 200（Godot -1 空缺），无兜底人选
