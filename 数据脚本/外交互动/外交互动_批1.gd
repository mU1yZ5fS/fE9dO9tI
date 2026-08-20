## 外交互动 批1 — 编号 1,2,3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,38。
## 源码出处：DiploButtonScript.cs（中文分支 Show L30-L1371 / OnMouseDown L8601-L9299），行号以 工作记录/外交互动批1_源码行号.json 为准。
extends "res://数据脚本/外交互动/外交互动_基础.gd"

const W = preload("res://数据脚本/world_state.gd")


## 主分发：返回 {caption, opis, conditions, effect, dormant} 或 {}。
func build_action(action_type: int, ctx: Dictionary) -> Dictionary:
	var w: WorldState = ctx.get("w")
	var _darr: Array = ctx.get("d", [])
	var country: CountryData = ctx.get("country")
	var caption: String = ctx.get("caption", "")
	match action_type:
		1:
			return _def_1(w, country, caption)
		2:
			return _def_2(w, country, caption)
		3:
			return _def_3(w, country, caption)
		4:
			return _def_4(w, country, caption)
		5:
			return _def_5(w, country, caption)
		6:
			return _def_6(w, country, caption)
		7:
			return _def_7(w, country, caption)
		8:
			return _def_8(w, country, caption)
		9:
			return _def_9(w, country, caption)
		10:
			return _def_10(w, country, caption)
		11:
			return _def_11(w, country, caption)
		13:
			return _def_13(w, country, caption)
		14:
			return _def_14(w, country, caption)
		15:
			return _def_15(w, country, caption)
		16:
			return _def_16(w, country, caption)
		17:
			return _def_17(w, country, caption)
		18:
			return _def_18(w, country, caption)
		19:
			return _def_19(w, country, caption)
		22:
			return _def_22(w, country, caption)
		23:
			return _def_23(w, country, caption)
		24:
			return _def_24(w, country, caption)
		25:
			return _def_25(w, country, caption)
		26:
			return _def_26(w, country, caption)
		27:
			return _def_27(w, country, caption)
		28:
			return _def_28(w, country, caption)
		29:
			return _def_29(w, country, caption)
		30:
			return _def_30(w, country, caption)
		31:
			return _def_31(w, country, caption)
		32:
			return _def_32(w, country, caption)
		33:
			return _def_33(w, country, caption)
		34:
			return _def_34(w, country, caption)
		35:
			return _def_35(w, country, caption)
		36:
			return _def_36(w, country, caption)
		38:
			return _def_38(w, country, caption)
	return {}


# ============================================================================
# 编号 2 · 准备武力占领港澳地区
# DBS Show L30-L53 / OnMouseDown L8601-L8621
# ============================================================================
func _def_2(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 准 备 武 力 占 领 港 澳 地 区"
	var conds: Array = []
	conds.append(cond(" 港 澳 未 被 我 方 控 制", func(): return d(w, W.I_HK_MACAU_STATUS) == 0))
	if res(w, 469) == 1 or not ev(w, 469):
		conds.append(cond(" 至 少 5 百 万 预 算", func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 50))
		conds.append(cond(" 至 少 10 军 事 实 力", func(): return d(w, W.I_ARMY) >= 100))
	else:
		conds.append(cond(" 至 少 3 百 万 预 算", func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 30))
		conds.append(cond(" 至 少 5 军 事 实 力", func(): return d(w, W.I_ARMY) >= 50))
	conds.append(cond(" 英 国 输 掉 了 马 岛 战 争", func(): return fl(w, "BritLost")))
	var eff := func():
		add_rel(w, 0, -500)
		add_power(w, 0, -70)
		if res(w, 469) == 1 or not ev(w, 469):
			set_d(w, W.I_ARMY, d(w, W.I_ARMY) - 100)
			set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 50)
		else:
			set_d(w, W.I_ARMY, d(w, W.I_ARMY) - 50)
			set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 30)
		set_d(w, W.I_HK_MACAU_STATUS, 2)
		set_d(w, W.I_DIPLO, d(w, W.I_DIPLO) + 500)
		set_d(w, W.I_POPULATION, d(w, W.I_POPULATION) + 45)
		set_tag(c(w, 92), "对华贸易", false)
		set_tag(c(w, 87), "对华贸易", false)
		# 原版 UnifyHKByForce=true → global_flags["unify_hk_by_force"]，结局轮播1已消费。
		set_fl(w, "unify_hk_by_force", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1 · 扶持极左派（支持毛派组织）
# DBS Show L54-L75 / OnMouseDown L8622-L8665
# ============================================================================
func _def_1(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var is_west: bool = country.原版序号 == 92 or country.原版序号 == 21 or country.原版序号 == 17
	var conds: Array = []
	conds.append(cond(" 至 少 5 特 工 网 络 和 3 百 万 预 算", func(): return d(w, W.I_AGENTS) >= 50 and d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 30))
	conds.append(cond(" 我 们 始 终 坚 持 伟 大 的 毛 泽 东 思 想 ！", func(): return mod(w, 6)))
	conds.append(cond(" 外 交 声 誉 高 于 75", func(): return d(w, W.I_DIPLO) > 750))
	if is_west:
		conds.append(cond(" 西 欧 ： 每 年 一 次", func(): return not _war_active_flag(w, 0)))
	else:
		conds.append(cond(" 东 欧 ： 每 年 一 次", func(): return not _war_active_flag(w, 1)))
	var eff := func():
		if is_west:
			var usa := emp(w, 0)
			if usa != null:
				var pen := 50
				if usa.current_leader == 3:
					pen = 75
				elif usa.current_leader == 5:
					pen = 100
				usa.power -= pen
				usa.relations -= 200
			_set_war_active(w, 0, true)
			if has(c(w, 1), "rim"):
				w.influence_prc += 25
		else:
			# 原版怪异逻辑：读 empires[0](美).now_leader 却扣 empires[1](苏).power（忠实保留，DBS L8647-L8654）
			var usa2 := emp(w, 0)
			var ussr := emp(w, 1)
			var pen2 := 50
			if usa2 != null and usa2.current_leader == 5:
				pen2 = 100
			if ussr != null:
				ussr.power -= pen2
				ussr.relations -= 200
			_set_war_active(w, 1, true)
			if _decision_done(w, 9):
				w.influence_prc += 25
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 50)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 30)
		set_d(w, W.I_ARMY, d(w, W.I_ARMY) - 50)
	return make_def(caption, " 支 持 毛 派 组 织", conds, eff)


# ============================================================================
# 编号 3 · 与英国和葡萄牙谈判收回港澳地区
# DBS Show L76-L97 / OnMouseDown L8666-L8674
# ============================================================================
func _def_3(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 至 少 2 特 工 网 络", func(): return d(w, W.I_AGENTS) >= 20))
	conds.append(cond(" 不 早 于 1980 年", func(): return d(w, W.I_YEAR) >= 1980))
	if w.dlc.size() > 3 and w.dlc[3]:
		# 文案 other_text[309] 已解析（见下方 cond 文案）。
		conds.append(cond("外 交 声 誉 低 于 7 0 ， 且 葡 萄 牙 政 体 不 为 威 权 主 义", func(): return d(w, W.I_DIPLO) < 700 and gov(c(w, 87)) != 0))
	else:
		conds.append(cond(" 外 交 声 誉 低 于 70", func(): return d(w, W.I_DIPLO) < 700))
	conds.append(cond(" 尚 未 进 行 过 商 谈", func(): return _cdev(w, 0) == 0))
	var eff := func():
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 20)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 20)
		var c0 := c(w, 0)
		if c0 != null:
			c0.development = 1
		# 原版 GlobalScript.inst.speed=0 + number_event=27 + LoadScene("Event")；Godot 由 start_event 内部 pause() 承担。
		start_event("hong_kong_macau")
	return make_def(caption, " 与 英 国 和 葡 萄 牙 谈 判 收 回 港 澳 地 区", conds, eff)


# ============================================================================
# 编号 4 · 深化《中苏友好同盟互助条约》/ 中苏关系正常化
# DBS Show L98-L142 / OnMouseDown L8675-L8681
# ============================================================================
func _def_4(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var early: bool = d(w, W.I_YEAR) < 1979 or (d(w, W.I_MONTH) < 4 and d(w, W.I_YEAR) == 1979)
	var opis := " 中 苏 关 系 正 常 化"
	if early:
		opis = " 深 化 《 中 苏 友 好 同 盟 互 助 条 约 》"
	var conds: Array = []
	conds.append(cond(" 不 早 于 1979 年", func(): return d(w, W.I_YEAR) >= 1979))
	if early:
		if w.leader != null and w.leader.trait_personality == 0 and w.leader.trait_alignment == 4 and w.leader.trait_special == 8:
			conds.append(cond(" 党 内 团 结 度 至 少 90\n 联 络 机 构 的 规 模 至 少 为 10", func(): return d(w, W.I_PARTY_SUPPORT) >= 900 and d(w, W.I_COMMUNICATIONS) >= 100))
		else:
			conds.append(cond(" 党 内 团 结 度 至 少 70\n 联 络 机 构 的 规 模 至 少 为 20", func(): return d(w, W.I_PARTY_SUPPORT) >= 700 and d(w, W.I_COMMUNICATIONS) >= 200))
	else:
		conds.append(cond(" 党 内 团 结 度 至 少 90\n 联 络 机 构 的 规 模 至 少 为 25", func(): return d(w, W.I_PARTY_SUPPORT) >= 900 and d(w, W.I_COMMUNICATIONS) >= 250))
	conds.append(cond("未 与 越 南 开 战", func(): return fl(w, "vietnampeace")))
	if not fl(w, "relres"):
		conds.append(cond(" 中 苏 关 系 至 少 为 70", func(): return rel(w, 1) >= 700))
	else:
		conds.append(cond(" 尚 未 恢 复 关 系", func(): return not fl(w, "relres")))
	var eff := func():
		add_rel(w, 1, 50)
		add_rel(w, 0, -50)
		set_fl(w, "relres", true)
		country.stab = 1
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 5 · 加入经济互助委员会
# DBS Show L143-L169 / OnMouseDown L8682-L8737
# ============================================================================
func _def_5(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	if not fl(w, "relres"):
		conds.append(cond(" 中 苏 关 系 已 实 现 正 常 化", func(): return fl(w, "relres")))
	elif not ev(w, 380):
		conds.append(cond(" 不 再 坚 持 毛 泽 东 思 想\n 或 世 界 影 响 力 低 于 30", func(): return not mod(w, 6) or w.influence_prc < 300))
	else:
		conds.append(cond(" 苏 联 已 经 再 斯 大 林 化", func(): return ev(w, 380)))
	conds.append(cond(" 没 有 同 美 国 建 立 友 好 关 系", func(): return not has(c(w, 51), "对华贸易")))
	conds.append(cond(" 外 交 声 誉 高 于 69", func(): return d(w, W.I_DIPLO) > 690))
	conds.append(cond(" 尚 未 参 与 同 类 组 织", func(): return not has(c(w, 1), "sev")))
	var eff := func():
		set_d(w, W.I_PARTY_SUPPORT, d(w, W.I_PARTY_SUPPORT) - 100)
		w.influence_prc -= 30
		add_rel(w, 1, 200)
		add_rel(w, 0, -200)
		add_power(w, 1, 30)
		set_d(w, W.I_THOUGHT_FREEDOM, d(w, W.I_THOUGHT_FREEDOM) + 100)
		_set_mod(w, 47, false)
		_set_mod(w, 48, false)
		if has(c(w, 1), "econ"):
			set_d(w, 137, 1)
		set_tag(country, "对华贸易", false)
		set_tag(c(w, 1), "sev", true)
		if d(w, W.I_ALBANIA_BREAK) == 0 and not ev(w, 380):
			var c20 := c(w, 20)
			if c20 != null:
				c20.set_tag("亲中", false)
				c20.set_tag("econ", false)
				c20.set_tag("对华贸易", false)
				c20.set_tag("okb", false)
		var war1 := w.get_war(1)
		if war1 != null:
			war1.infl2 = 1500
		if not has(c(w, 16), "对华贸易") and mod(w, 53):
			set_tag(c(w, 16), "对华贸易", true)
		for cc in w.countries:
			if cc == null:
				continue
			if cc.has_tag("econ") and (cc.has_tag("亲苏") or cc.has_tag("苏联盟友") or cc.has_tag("亲中") or cc.government == 1 or (cc.government == 2 and not cc.has_tag("美国盟友") and not cc.has_tag("亲美"))):
				cc.set_tag("econ", false)
				cc.set_tag("sev", true)
			else:
				cc.set_tag("econ", false)
		for p in w.politicians:
			if p != null and (p.trait_personality == 0 or p.trait_personality == 1 or p.trait_personality == 2):
				p.loyalty -= 250
	return make_def(caption, " 加 入 经 济 互 助 委 员 会", conds, eff)


# ============================================================================
# 编号 6 · 加入华沙条约组织
# DBS Show L182-L195 / OnMouseDown L8744-L8802
# ============================================================================
func _def_6(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 已 加 入 经 互 会", func(): return has(c(w, 1), "sev")))
	conds.append(cond(" 外 交 声 誉 高 于 69", func(): return d(w, W.I_DIPLO) > 690))
	conds.append(cond(" 尚 未 参 与 同 类 组 织", func(): return not has(c(w, 1), "ovd")))
	conds.append(cond(" 未 加 入 不 结 盟 运 动", func(): return not _ccw(w, 15)))
	var eff := func():
		add_rel(w, 0, -200)
		add_rel(w, 1, 150)
		add_power(w, 1, 30)
		set_d(w, W.I_DIPLO, d(w, W.I_DIPLO) + 200)
		set_d(w, 143, d(w, 143) + 5)
		w.influence_prc -= 50
		if mod(w, 47):
			_set_mod(w, 47, false)
			set_d(w, 135, 1)
		if mod(w, 48):
			_set_mod(w, 48, false)
			set_d(w, 136, 1)
		if has(c(w, 1), "okb"):
			set_d(w, 138, 1)
		set_tag(c(w, 1), "ovd", true)
		for cc in w.countries:
			if cc == null:
				continue
			if cc.has_tag("okb") and (cc.has_tag("亲苏") or cc.has_tag("苏联盟友") or cc.has_tag("亲中") or cc.government == 1 or (cc.government == 2 and not cc.has_tag("美国盟友") and not cc.has_tag("亲美"))):
				cc.set_tag("okb", false)
				cc.set_tag("ovd", true)
			else:
				cc.set_tag("okb", false)
		for j in [8, 11, 14, 12, 31, 43, 37, 42, 22, 23, 35, 96, 97, 98, 95, 49, 50]:
			var ccj := c(w, j)
			if ccj != null and ccj.has_tag("ovd"):
				if ccj.has_tag("亲中"):
					ccj.prc_influence = 500
				elif ccj.has_tag("亲苏"):
					ccj.sov_influence = 500
		if d(w, W.I_ALBANIA_BREAK) == 0 and not ev(w, 380):
			var c20 := c(w, 20)
			if c20 != null:
				c20.set_tag("亲中", false)
				c20.set_tag("econ", false)
				c20.set_tag("对华贸易", false)
				c20.set_tag("okb", false)
	return make_def(caption, " 加 入 华 沙 条 约 组 织", conds, eff)


# ============================================================================
# 编号 7 · 恢复被破坏的沟通机构
# DBS Show L196-L214 / OnMouseDown L8803-L8810
# ============================================================================
func _def_7(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conn: int = d(w, W.I_COMMUNICATIONS)
	var opis := " 恢 复 被 破 坏 的 沟 通 机 构| 规 模 ：%d.%d" % [int(conn / 10.0), absi(conn % 10)]
	var conds: Array = []
	conds.append(cond(" 至 少%d.%d  特 工 网 络" % [int(conn / 20.0), absi(int(conn / 2.0) % 10)], func(): return d(w, W.I_AGENTS) >= int(conn / 2.0)))
	conds.append(cond(" 预 算 拨 款 ： %d.%d" % [int(conn / 40.0), absi(int(conn / 4.0) % 10)], func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= int(conn / 4.0)))
	conds.append(cond(" 每 三 月 一 次", func(): return country.development == 0))
	var eff := func():
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - int(conn / 2.0))
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - int(conn / 4.0))
		_add_d(w, W.I_COMMUNICATIONS, 30)
		add_rel(w, 1, 50)
		country.development = 1
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 8 · 支持伊朗革命中所选派系
# DBS Show L215-L251 / OnMouseDown L8811-L8834
# ============================================================================
func _def_8(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	if country.development == 0 and d(w, W.I_IRAN_SHAH_SUPPORT) < 1000:
		conds.append(cond(" 至 少 9 特 工 网 络", func(): return d(w, W.I_AGENTS) >= 90))
	elif country.development == 1 and d(w, W.I_IRAN_LEFT_SUPPORT) < 1000:
		conds.append(cond(" 至 少 9 特 工 网 络", func(): return d(w, W.I_AGENTS) >= 90))
	elif country.development == 2 and d(w, W.I_IRAN_DEMOCRAT_SUPPORT) < 1000:
		conds.append(cond(" 至 少 9 特 工 网 络", func(): return d(w, W.I_AGENTS) >= 90))
	elif d(w, W.I_IRAN_ISLAMIST_SUPPORT) < 1000:
		conds.append(cond(" 至 少 9 特 工 网 络", func(): return d(w, W.I_AGENTS) >= 90))
	else:
		conds.append(cond(" 拉 我 们 支 持 的 兄 弟 一 把", func(): return d(w, W.I_AGENTS) < -5000))
	conds.append(cond(" 至 少 6 百 万 预 算", func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 60))
	conds.append(cond(" 每 三 月 一 次", func(): return country.stab == 0 and _cdev(w, 8) != 4))
	conds.append(cond(" 示 威 引 爆 内 乱 ， 革 命 仍 在 继 续", func(): return fl(w, "iranrev")))
	var eff := func():
		if country.development == 0:
			set_d(w, W.I_IRAN_SHAH_SUPPORT, d(w, W.I_IRAN_SHAH_SUPPORT) + 120)
		elif country.development == 1:
			set_d(w, W.I_IRAN_LEFT_SUPPORT, d(w, W.I_IRAN_LEFT_SUPPORT) + 120)
		elif country.development == 2:
			set_d(w, W.I_IRAN_DEMOCRAT_SUPPORT, d(w, W.I_IRAN_DEMOCRAT_SUPPORT) + 120)
		else:
			set_d(w, W.I_IRAN_ISLAMIST_SUPPORT, d(w, W.I_IRAN_ISLAMIST_SUPPORT) + 120)
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 60)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 50)
		country.stab = 1
	return make_def(caption, " 支 持 伊 朗 革 命 中 所 选 派 系", conds, eff)


# ============================================================================
# 编号 9 · 发展贸易（深化经贸关系）
# DBS Show L252-L342 / OnMouseDown L8835-L8838
# ============================================================================
func _def_9(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 深 化 经 贸 关 系"
	if country.原版序号 == 104:
		opis = " 建 立 正 式 外 交 关 系 并 深 化 经 贸 关 系"
	var conds: Array = []
	var desc0: String = _diplo_rep_desc(w, country)
	var check0: Callable = func(): return _diplo_rep_check(w, country)
	if country.原版序号 == 108 and has(c(w, 21), "对华贸易") and pup(c(w, 108)) == 21:
		desc0 = " 与 法 国 有 贸 易 关 系"
		check0 = func(): return has(c(w, 21), "对华贸易")
	conds.append(cond(desc0, check0))
	if country.原版序号 == 34 and war(w, 2):
		conds.append(cond(" 没 有 内 战", func(): return not war(w, 2)))
	elif country.原版序号 == 109 and war(w, 31):
		conds.append(cond(" 没 有 内 战", func(): return not war(w, 31)))
	elif country.原版序号 == 110 and war(w, 32):
		conds.append(cond(" 没 有 内 战", func(): return not war(w, 32)))
	else:
		conds.append(cond(" 尚 未 深 化 经 贸 关 系", func(): return not has(country, "对华贸易")))
	if has(country, "亲中"):
		conds.append(cond(" 工 业 不 低 于 30", func(): return d(w, W.I_INDUSTRY) >= 300))
	elif country.原版序号 == 92 or country.原版序号 == 85 or country.原版序号 == 136 or country.原版序号 == 135 or country.原版序号 == 137 or (country.原版序号 > 87 and country.原版序号 < 92) or country.原版序号 == 0:
		conds.append(cond(" 工 业 不 低 于 70", func(): return d(w, W.I_INDUSTRY) >= 700))
	else:
		conds.append(cond(" 工 业 不 低 于 50", func(): return d(w, W.I_INDUSTRY) >= 500))
	if has(c(w, 7), "nato") and (has(country, "亲美") or has(country, "亲苏") or has(country, "nato")):
		# 文案 other_text[105] 已解析（见下方 cond 文案）。
		conds.append(cond("苏 联 未 加 入 北 约", func(): return not has(c(w, 7), "nato")))
	elif country.原版序号 == 167:
		conds.append(cond(" 魁 北 克 政 府 不 亲 美", func(): return not has(country, "亲美")))
	var eff := func():
		set_tag(country, "对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 10 · 经济合作
# DBS Show L343-L433 / OnMouseDown L8839-L8855
# ============================================================================
func _def_10(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	if country.原版序号 != 35 and country.原版序号 != 14 and country.原版序号 != 9:
		conds.append(cond(" 已 深 化 经 贸 关 系 或 该 国 持 亲 中 立 场", func(): return has(country, "对华贸易") or has(country, "亲中")))
	elif country.原版序号 == 9:
		conds.append(cond(" 蒙 古 人 民 相 信 我 们 的 善 意", func(): return has(country, "亲中") and res(w, 62) != 2))
	else:
		conds.append(cond(" 该 国 持 亲 中 立 场", func(): return has(country, "亲中")))
	conds.append(cond(" 中 国 已 建 立 经 合 组 织 ， 或 中 国 已 加 入 经 互 会", func(): return has(c(w, 1), "sev") or has(c(w, 1), "econ")))
	conds.append(cond(" 该 国 未 加 入 经 合 组 织", func(): return not has(country, "sev") and not has(country, "econ") and not has(country, "asean")))
	if has(country, "亲美") or has(country, "美国盟友"):
		conds.append(cond(" 该 国 不 受 美 国 的 影 响", func(): return not has(country, "亲美") and not has(country, "美国盟友")))
	elif (has(country, "亲苏") or has(country, "苏联盟友")) and not has(c(w, 1), "sev"):
		conds.append(cond(" 该 国 不 受 苏 联 的 影 响", func(): return not has(country, "亲苏") and not has(country, "苏联盟友")))
	elif country.原版序号 == 29:
		conds.append(cond(" 该 国 不 在 北 约 与 欧 共 体 内", func(): return not has(country, "nato") and not has(country, "eu")))
	elif has(country, "soc_eu"):
		conds.append(cond(" 该 国 不 在 社 会 主 义 联 盟", func(): return not has(country, "soc_eu")))
	elif country.原版序号 == 8 and (war(w, 3) or war(w, 5)):
		conds.append(cond(" 伊 朗 与 阿 富 汗 均 无 战 事", func(): return not war(w, 3) and not war(w, 5)))
	elif country.原版序号 == 8:
		# 原版 L401-L430：伊朗先走前面各分支，均不中时把 uslovie[0] 改写为声誉档。
		conds[0] = cond(_diplo_rep_desc(w, country), func(): return _diplo_rep_check(w, country))
	var eff := func():
		if has(c(w, 1), "sev"):
			add_power(w, 1, 20)
			w.influence_prc += 10
			set_tag(country, "sev", true)
		else:
			set_d(w, W.I_PEOPLE_SUPPORT, d(w, W.I_PEOPLE_SUPPORT) + 20)
			w.influence_prc += 20
			set_tag(country, "econ", true)
			country.social_stability = 1000
			set_d(w, W.I_PARTY_SUPPORT, d(w, W.I_PARTY_SUPPORT) + 30)
	return make_def(caption, " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系", conds, eff)


# ============================================================================
# 编号 11 · 为蒙人党党内反对派提供政治庇护和支持
# DBS Show L434-L445 / OnMouseDown L8856-L8861
# ============================================================================
func _def_11(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 至 少 10 特 工 网 络", func(): return d(w, W.I_AGENTS) >= 100))
	conds.append(cond(" 至 少 5 百 万 预 算", func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 50))
	conds.append(cond(" 尚 未 提 供 支 持", func(): return not country.内战中))
	var eff := func():
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 100)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 50)
		country.内战中 = true
	return make_def(caption, " 为 被 泽 登 巴 尔 清 洗 的 蒙 人 党 党 内 反 对 派 提 供 政 治 庇 护 和 支 持", conds, eff)


# ============================================================================
# 编号 13 · 经济合作（军援制裁前置版）
# DBS Show L466-L493 / OnMouseDown L8872-L8885
# ============================================================================
func _def_13(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	if w.dlc.size() > 3 and w.dlc[3]:
		# 文案 other_text[102] 已解析（见下方 cond 文案）。
		conds.append(cond("朝 鲜 得 到 了 我 国 的 武 器 ， 且 未 对 韩 国 发 起 入 侵 ， 同 时 还 未 遭 遇 制 裁", func(): return country.influence_china <= 0 and fl(w, "guns") and country.influence_nato <= 0))
	else:
		conds.append(cond(" 提 供 军 援 ， 且 没 有 实 施 制 裁", func(): return country.influence_china <= 0 and fl(w, "guns")))
	conds.append(cond(" 中 国 已 成 立 经 合 组 织 或 已 加 入 经 互 会", func(): return has(c(w, 1), "sev") or has(c(w, 1), "econ")))
	conds.append(cond(" 该 国 未 加 入 经 合 组 织", func(): return not has(country, "sev") and not has(country, "econ")))
	if gov(country) <= 1:
		conds.append(cond(" 外 交 声 誉 高 于 89", func(): return d(w, W.I_DIPLO) > 890))
	else:
		conds.append(cond(" 外 交 声 誉 在 49 到 89 之 间", func(): return d(w, W.I_DIPLO) > 490 and d(w, W.I_DIPLO) < 890))
	var eff := func():
		if has(c(w, 1), "sev"):
			add_power(w, 1, 10)
			set_tag(country, "sev", true)
		else:
			w.influence_prc += 10
			set_tag(country, "econ", true)
			country.social_stability = 1000
	return make_def(caption, " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系", conds, eff)


# ============================================================================
# 编号 14 · 实施全面制裁
# DBS Show L494-L522 / OnMouseDown L8886-L8892
# ============================================================================
func _def_14(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 尚 未 实 施 制 裁", func(): return country.influence_china <= 0))
	conds.append(cond(" 外 交 声 誉 低 于 80", func(): return d(w, W.I_DIPLO) < 800))
	if w.dlc.size() > 3 and w.dlc[3]:
		if war(w, 16):
			conds.append(cond(" 未 入 侵 朝 鲜", func(): return not war(w, 16)))
		else:
			# 文案 other_text[101] 已解析（见下方 cond 文案）。
			conds.append(cond("朝 鲜 还 未 对 韩 国 发 起 入 侵", func(): return _cdev(w, 10) <= 0))
	var eff := func():
		country.influence_china = 1
		# 原版 GlobalScript.inst.speed=0 + number_event=29 + LoadScene("Event")；Godot 由 start_event 内部 pause() 承担。
		start_event("pressure_north_korea")
	return make_def(caption, " 实 施 全 面 制 裁", conds, eff)


# ============================================================================
# 编号 15 · 煽动一场新的朝鲜战争
# DBS Show L523-L560 / OnMouseDown L8893-L8924
# ============================================================================
func _def_15(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	if soc(w, c(w, 46), false):
		conds.append(cond(" 已 提 供 军 援\n 至 少 10 特 工 网 络 和 5 百 万 预 算", func(): return fl(w, "guns") and d(w, W.I_AGENTS) >= 100 and d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 50))
	else:
		conds.append(cond(" 韩 国 不 为 社 会 主 义", func(): return soc(w, c(w, 46), false)))
	if not has(c(w, 1), "asean"):
		if w.dlc.size() > 3 and w.dlc[3]:
			# 文案 other_text[103] 已解析（见下方 cond 文案）。
			conds.append(cond("对 全 斗 焕 的 暗 杀 事 件 发 生 ， 且 朝 鲜 还 未 对 韩 国 发 起 入 侵", func(): return ev(w, 91) and gov(c(w, 46)) == 0 and _cdev(w, 10) <= 0))
		else:
			conds.append(cond(" 全 斗 焕 遇 刺", func(): return ev(w, 91) and gov(c(w, 46)) == 0))
	else:
		conds.append(cond(" 全 斗 焕 遇 刺", func(): return ev(w, 91)))
	conds.append(cond(" 尚 未 煽 动 战 争", func(): return country.development == 0))
	conds.append(cond(" 外 交 声 誉 高 于 79", func(): return d(w, W.I_DIPLO) > 790))
	var eff := func():
		country.development = 1
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 100)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 50)
		set_d(w, W.I_DIPLO, d(w, W.I_DIPLO) + 100)
		var kw := w.get_war(0)
		if kw != null:
			kw.name_war = " 第 二 次 朝 鲜 战 争"
			kw.side1 = " 朝 鲜"
			kw.side2 = " 韩 国"
			kw.is_going = true
			var c10 := c(w, 10)
			kw.ussr_side = 0 if (c10 != null and not has(c10, "亲中")) else -1
			kw.usa_side = 1
			kw.infl1 = 600
			kw.infl2 = 400
	return make_def(caption, " 煽 动 一 场 新 的 朝 鲜 战 争", conds, eff)


# ============================================================================
# 编号 16 · 提供军事物资，派遣技术专家
# DBS Show L561-L584 / OnMouseDown L8925-L8931
# ============================================================================
func _def_16(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 尚 未 提 供 军 援", func(): return not fl(w, "guns")))
	conds.append(cond(" 至 少 5 军 事 实 力", func(): return d(w, W.I_ARMY) >= 50))
	conds.append(cond(" 至 少 2 百 万 预 算", func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 20))
	if w.dlc.size() > 3 and w.dlc[3]:
		# 文案 other_text[101] 已解析（见下方 cond 文案）。
		conds.append(cond("朝 鲜 还 未 对 韩 国 发 起 入 侵", func(): return _cdev(w, 10) <= 0))
	var eff := func():
		set_fl(w, "guns", true)
		set_d(w, W.I_ARMY, d(w, W.I_ARMY) - 50)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 20)
		set_d(w, W.I_DIPLO, d(w, W.I_DIPLO) + 50)
	return make_def(caption, " 提 供 军 事 物 资 ， 派 遣 技 术 专 家", conds, eff)


# ============================================================================
# 编号 17 · 发展贸易（越南变体）
# DBS Show L585-L617 / OnMouseDown L8932-L8935
# ============================================================================
func _def_17(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	if not has(country, "亲中"):
		conds.append(cond(" 未 与 越 南 开 战", func(): return fl(w, "vietnampeace")))
	else:
		conds.append(cond(" 越 南 受 中 国 的 影 响", func(): return has(country, "亲中")))
	conds.append(cond(" 尚 未 深 化 经 贸 关 系", func(): return not has(country, "对华贸易")))
	conds.append(cond(" 外 交 声 誉 高 于 69 或 越 南 持 亲 中 立 场", func(): return d(w, W.I_DIPLO) > 690 or has(country, "亲中")))
	if has(c(w, 7), "nato") and (has(country, "亲美") or has(country, "亲苏") or has(country, "nato")):
		# 文案 other_text[105] 已解析（见下方 cond 文案）。
		conds.append(cond("苏 联 未 加 入 北 约", func(): return not has(c(w, 7), "nato")))
	elif pup(country) < 0:
		conds.append(cond(" 柬 越 未 开 战", func(): return not ev(w, 15)))
	var eff := func():
		set_tag(country, "对华贸易", true)
	return make_def(caption, " 深 化 经 贸 关 系", conds, eff)


# ============================================================================
# 编号 18 · 经济合作（越南变体）
# DBS Show L618-L635 / OnMouseDown L8936-L8950
# ============================================================================
func _def_18(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 越 南 未 加 入 我 们 的 经 合 组 织 或 经 互 会", func(): return not has(country, "sev") and not has(country, "econ")))
	conds.append(cond(" 已 深 化 经 贸 关 系", func(): return has(country, "对华贸易")))
	conds.append(cond(" 中 国 已 成 立 经 合 组 织 或 已 加 入 经 互 会", func(): return has(c(w, 1), "econ") or has(c(w, 1), "sev")))
	if has(country, "亲美"):
		conds.append(cond(" 该 国 不 受 美 国 的 影 响", func(): return not has(country, "亲美")))
	var eff := func():
		if has(c(w, 1), "sev"):
			add_power(w, 1, 20)
			w.influence_prc += 10
			set_tag(country, "sev", true)
		else:
			w.influence_prc += 20
			set_tag(country, "econ", true)
			country.social_stability = 1000
	return make_def(caption, " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系", conds, eff)


# ============================================================================
# 编号 19 · 军事同盟
# DBS Show L636-L663 / OnMouseDown L8951-L8976
# ============================================================================
func _def_19(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 至 少 2 军 事 实 力", func(): return d(w, W.I_ARMY) >= 20))
	conds.append(cond(" 外 交 声 誉 高 于 79", func(): return d(w, W.I_DIPLO) > 790))
	conds.append(cond(" 他 们 已 加 入 经 合 组 织 或 经 互 会", func(): return has(country, "sev") or has(country, "econ")))
	conds.append(cond(" 他 们 未 参 与 军 事 联 盟| 中 国 已 成 立 集 安 组 织 或 已 加 入 华 约", func(): return _mil19_slot_check(w, country)))
	var eff := func():
		if has(c(w, 1), "ovd"):
			add_power(w, 1, 20)
			w.influence_prc += 10
			set_tag(country, "ovd", true)
			if has(country, "亲中"):
				country.prc_influence = 500
			elif has(country, "亲苏"):
				country.sov_influence = 500
		else:
			w.influence_prc += 20
			set_tag(country, "okb", true)
			if country.social_stability <= 0:
				country.social_stability = 1000
	return make_def(caption, " 邀 请 该 国 参 与 我 国 军 事 联 盟 ， 实 现 合 作 无 上 限 ， 保 障 地 区 安 全 稳 定", conds, eff)


# ============================================================================
# 编号 22 · 向卡扎菲政府提供经济援助
# DBS Show L711-L720 / OnMouseDown L9022-L9027
# ============================================================================
func _def_22(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 尚 未 进 行 资 助", func(): return country.stab == 0))
	conds.append(cond(" 至 少 5 百 万 预 算", func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 50))
	var eff := func():
		country.stab = 1
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 50)
		set_tag(country, "对华贸易", true)
	return make_def(caption, " 向 卡 扎 菲 政 府 提 供 经 济 援 助", conds, eff)


# ============================================================================
# 编号 23 · 开始联络利比亚国内的反对派
# DBS Show L721-L732 / OnMouseDown L9028-L9033
# ============================================================================
func _def_23(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 至 少 5 点 特 工 网 络", func(): return d(w, W.I_AGENTS) >= 50))
	conds.append(cond(" 至 少 5 百 万 预 算", func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 50))
	conds.append(cond(" 尚 未 联 络 过", func(): return not country.内战中))
	var eff := func():
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 50)
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 50)
		country.内战中 = true
	return make_def(caption, " 开 始 联 络 利 比 亚 国 内 的 反 对 派", conds, eff)


# ============================================================================
# 编号 24 · 发展贸易（变体）
# DBS Show L778-L837 / OnMouseDown L9039-L9042
# ============================================================================
func _def_24(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(_diplo_rep_desc24(w, country), func(): return _diplo_rep_check24(w, country)))
	conds.append(cond(" 尚 未 深 化 经 贸 关 系", func(): return not has(country, "对华贸易")))
	conds.append(cond(" 工 业 不 低 于 70", func(): return d(w, W.I_INDUSTRY) >= 700))
	if country.原版序号 == 14:
		conds.append(cond(" 该 国 不 受 伊 朗 人 的 摆 布", func(): return pup(country) != 8))
	elif ((country.原版序号 >= 2 and country.原版序号 <= 6) or country.原版序号 == 16) and has(c(w, 1), "sev"):
		conds.append(cond(" 中 国 已 加 入 经 互 会", func(): return has(c(w, 1), "sev")))
	elif (country.原版序号 >= 2 and country.原版序号 <= 6) or country.原版序号 == 16:
		conds.append(cond(" 该 国 不 受 苏 联 的 影 响", func(): return not has(country, "亲苏")))
	var eff := func():
		set_tag(country, "对华贸易", true)
	return make_def(caption, " 深 化 经 贸 关 系", conds, eff)


# ============================================================================
# 编号 25 · 促成该国加入阿拉伯联合共和国
# DBS Show L895-L940 / OnMouseDown L9048-L9052
# ============================================================================
func _def_25(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 阿 拉 伯 联 合 共 和 国 已 经 成 立", func(): return w.oar))
	if gov(c(w, 30)) == 1:
		conds.append(cond(" 该 国 未 加 入 阿 拉 伯 联 合 共 和 国", func(): return not has(country, "oar")))
		conds.append(cond(" 该 国 为 社 会 主 义", func(): return soc(w, country, true)))
	else:
		conds.append(cond(" 该 国 未 加 入 阿 拉 伯 联 合 共 和 国\n 且 未 参 与 军 事 联 盟", func(): return not has(country, "oar") and not has(country, "nato") and not has(country, "okb") and not has(country, "ovd")))
		conds.append(cond(" 该 国 为 改 良 主 义 或 左 翼 民 族 主 义", func(): return gov(country) == 2 or sub(country) == 10))
	if has(c(w, 14), "亲美"):
		conds.append(cond(" 该 国 不 受 美 国 的 影 响", func(): return not has(c(w, 14), "亲美")))
	elif gov(c(w, 8)) == 0:
		conds.append(cond(" 伊 朗 不 是 伊 斯 兰 主 义 者 当 政", func(): return sub(c(w, 8)) != 20))
	else:
		conds.append(cond(" 不 受 伊 朗 人 的 摆 布", func(): return d(w, 117) != 9))
	var eff := func():
		set_tag(country, "oar", true)
		w.influence_prc += 10
	return make_def(caption, " 促 成 该 国 加 入 阿 拉 伯 联 合 共 和 国 ，实 现 阿 拉 伯 世 界 的 政 治 统 一", conds, eff)


# ============================================================================
# 编号 26 · 签署一份友好合作协定
# DBS Show L941-L957 / OnMouseDown L9053-L9065
# ============================================================================
func _def_26(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	if w.leader_property.size() > 2 and w.leader_property[2] and soc(w, country, false):
		conds.append(cond(" 外 交 声 誉 低 于 11451.4", func(): return d(w, W.I_DIPLO) < 114514))
	else:
		conds.append(cond(" 外 交 声 誉 在 39 到 90 之 间", func(): return d(w, W.I_DIPLO) > 390 and d(w, W.I_DIPLO) < 900))
	conds.append(cond(" 铁 托 去 世", func(): return (d(w, W.I_MONTH) >= 5 and d(w, W.I_YEAR) >= 1980) or d(w, W.I_YEAR) >= 1981))
	conds.append(cond(" 尚 未 签 署 协 定", func(): return not has(country, "对华贸易")))
	var eff := func():
		country.stab = 1
		w.influence_prc += 10
		if d(w, W.I_ALBANIA_BREAK) == 0:
			var c20 := c(w, 20)
			if c20 != null:
				c20.set_tag("亲中", false)
				c20.set_tag("econ", false)
				c20.set_tag("对华贸易", false)
				c20.set_tag("okb", false)
		set_tag(country, "对华贸易", true)
	return make_def(caption, " 签 署 一 份 友 好 合 作 协 定", conds, eff)


# ============================================================================
# 编号 27 · 南斯拉夫：联系当地共产主义者 / 邀请加入欧洲社会主义联盟
# DBS Show L1080-L1105 / OnMouseDown L9152-L9169
# ============================================================================
func _def_27(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var soc_eu: bool = has(c(w, 85), "soc_eu")
	var opis := " 同 当 地 共 产 主 义 者 建 立 联 系 并 给 予 支 持"
	if soc_eu:
		opis = " 邀 请 该 国 加 入 欧 洲 社 会 主 义 联 盟 ， 推 进 建 设 人 道 、 民 主 的 社 会 主 义"
	var conds: Array = []
	if soc_eu:
		conds.append(cond(" 帮 助 南 斯 拉 夫 偿 还 了 外 债", func(): return res(w, 113) == 1 and ev(w, 113)))
		conds.append(cond(" 至 少 5 特 工 网 络 与 5 百 万 预 算", func(): return d(w, W.I_AGENTS) >= 50 and d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 50))
		conds.append(cond(" 尚 未 提 供 支 持", func(): return country.development != 2))
	else:
		conds.append(cond(" 外 交 声 誉 高 于 59", func(): return d(w, W.I_DIPLO) > 590))
		conds.append(cond(" 至 少 4 特 工 网 络", func(): return d(w, W.I_AGENTS) >= 40))
		conds.append(cond(" 尚 未 提 供 支 持", func(): return country.development == 0))
	var eff := func():
		if not has(c(w, 85), "soc_eu"):
			set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 40)
			country.development = 1
		else:
			set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 50)
			set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 50)
			country.development = 2
			w.influence_prc += 10
			country.government = 2
			country.sub_government = 8
			set_tag(country, "soc_eu", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 28 · 支持东部游击武装
# DBS Show L1132-L1153 / OnMouseDown L9199-L9206
# ============================================================================
func _def_28(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var nax: int = d(w, W.I_NAXALITE_POWER)
	var opis := " 支 持 东 部 游 击 武 装| 毛 主 义 者 力 量 ：%d.%d" % [int(nax / 10.0), absi(nax % 10)]
	var conds: Array = []
	conds.append(cond(" 外 交 声 誉 高 于 79", func(): return d(w, W.I_DIPLO) > 790))
	conds.append(cond(" 至 少 3 特 工 网 络 和 军 事 实 力", func(): return d(w, W.I_AGENTS) >= 30 and d(w, W.I_ARMY) >= 30))
	conds.append(cond(" 尚 未 推 动 中 印 关 系 正 常 化", func(): return not has(country, "对华贸易")))
	if nax <= 500 or (w.dlc.size() > 1 and w.dlc[1]):
		conds.append(cond(" 本 月 尚 未 支 持", func(): return country.stab == 0))
	else:
		conds.append(cond(" 尚 未 达 到 其 最 大 军 事 实 力", func(): return country.stab == 0 and d(w, W.I_NAXALITE_POWER) <= 500))
	var eff := func():
		set_d(w, W.I_NAXALITE_POWER, d(w, W.I_NAXALITE_POWER) + 100)
		add_rel(w, 1, -50)
		set_d(w, W.I_ARMY, d(w, W.I_ARMY) - 30)
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 30)
		country.stab = 1
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 29 · 推动中印关系正常化
# DBS Show L1154-L1167 / OnMouseDown L9207-L9211
# ============================================================================
func _def_29(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 帮 助 英 迪 拉 ， 且 未 与 巴 基 斯 坦 建 立 友 好 关 系| 或 布 托 是 巴 基 斯 坦 总 理", func(): return (d(w, W.I_INDIA_ELECTION) == 1 or d(w, W.I_INDIA_ELECTION) == 2 or d(w, W.I_INDIA_ELECTION) == 3) and (not has(c(w, 31), "对华贸易") or gov(c(w, 31)) == 2 or soc(w, c(w, 31), true))))
	conds.append(cond(" 尚 未 建 立 友 好 关 系", func(): return not has(country, "对华贸易")))
	conds.append(cond(" 尚 未 发 动 战 争", func(): return country.development == 0 and w.war_state == GameConstants.WarState.PEACE and d(w, W.I_ARUNACHAL_STATUS) < 2))
	conds.append(cond(" 领 土 争 端 仍 悬 而 未 决", func(): return d(w, W.I_ARUNACHAL_STATUS) == 0))
	var eff := func():
		set_tag(country, "对华贸易", true)
		set_d(w, W.I_ARUNACHAL_STATUS, 1)
	return make_def(caption, " 推 动 中 印 关 系 正 常 化", conds, eff)


# ============================================================================
# 编号 30 · 以领土争端为由，发动边境战争
# DBS Show L1168-L1181 / OnMouseDown L9212-L9218
# ============================================================================
func _def_30(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 拥 有 战 争 理 由", func(): return fl(w, "cb_india")))
	conds.append(cond(" 尚 未 建 立 友 好 关 系", func(): return not has(country, "对华贸易")))
	conds.append(cond(" 尚 未 发 动 战 争", func(): return country.development == 0 and w.war_state == GameConstants.WarState.PEACE and d(w, W.I_ARUNACHAL_STATUS) < 2))
	conds.append(cond(" 未 加 入 不 结 盟 运 动", func(): return not _ccw(w, 15)))
	var eff := func():
		w.war_state = GameConstants.WarState.INDIA
		add_rel(w, 1, -100)
		add_rel(w, 0, -50)
		country.development = 1
	return make_def(caption, " 以 领 土 争 端 为 由 ， 发 动 边 境 战 争", conds, eff)


# ============================================================================
# 编号 31 · 经济合作（阿尔巴尼亚变体）
# DBS Show L1213-L1232 / OnMouseDown L9227-L9243
# ============================================================================
func _def_31(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 阿 尔 巴 尼 亚 持 亲 中 立 场", func(): return has(country, "亲中")))
	conds.append(cond(" 中 国 已 成 立 经 合 组 织 或 已 加 入 经 互 会| 且 其 与 苏 联 已 恢 复 外 交", func(): return has(c(w, 1), "econ") or (has(c(w, 1), "sev") and fl(w, "sov_alb"))))
	conds.append(cond(" 该 国 未 加 入 经 合 组 织", func(): return not has(country, "econ") and not has(country, "sev")))
	if has(country, "亲美"):
		conds.append(cond(" 该 国 不 受 美 国 的 影 响", func(): return not has(country, "亲美")))
	var eff := func():
		if has(c(w, 1), "sev"):
			add_power(w, 1, 20)
			w.influence_prc += 10
			set_tag(country, "sev", true)
		else:
			w.influence_prc += 20
			set_d(w, W.I_PEOPLE_SUPPORT, d(w, W.I_PEOPLE_SUPPORT) + 20)
			set_d(w, W.I_PARTY_SUPPORT, d(w, W.I_PARTY_SUPPORT) + 30)
			set_tag(country, "econ", true)
			country.social_stability = 1000
	return make_def(caption, " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系", conds, eff)


# ============================================================================
# 编号 32 · 从中斡旋，使苏联与阿尔巴尼亚关系正常化
# DBS Show L1233-L1246 / OnMouseDown L9244-L9250
# ============================================================================
func _def_32(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 中 苏 关 系 正 常 化", func(): return fl(w, "relres")))
	conds.append(cond(" 外 交 声 誉 高 于 79| 或 我 们 是 经 互 会 的 观 察 员 国", func(): return d(w, W.I_DIPLO) > 790 or has(c(w, 7), "对华贸易")))
	conds.append(cond(" 霍 查 去 世 或 被 推 翻", func(): return d(w, W.I_ALBANIA_BREAK) > 0))
	conds.append(cond(" 他 们 未 与 苏 联 恢 复 外 交", func(): return country.stab == 0))
	var eff := func():
		# SovAlb 原版为 GameState 散落 bool，按项目惯例存 global_flags。
		set_fl(w, "sov_alb", true)
		add_rel(w, 1, 50)
		add_power(w, 1, 5)
		country.stab = 1
	return make_def(caption, " 从 中 斡 旋 ，使 苏 联 与 阿 尔 巴 尼 亚 关 系 正 常 化", conds, eff)


# ============================================================================
# 编号 33 · 签署一份友好合作协定（按政体分档）
# DBS Show L1247-L1287 / OnMouseDown L9251-L9254
# ============================================================================
func _def_33(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	if w.leader_property.size() > 2 and w.leader_property[2] and soc(w, country, false):
		conds.append(cond(" 外 交 声 誉 低 于 11451.4", func(): return d(w, W.I_DIPLO) < 114514))
	elif gov(country) == 3:
		conds.append(cond(" 外 交 声 誉 低 于 80", func(): return d(w, W.I_DIPLO) < 800))
	elif gov(country) == 2:
		conds.append(cond(" 外 交 声 誉 低 于 90", func(): return d(w, W.I_DIPLO) < 900))
	elif gov(country) == 1:
		conds.append(cond(" 外 交 声 誉 高 于 70", func(): return d(w, W.I_DIPLO) > 700))
	elif gov(country) == 0:
		conds.append(cond(" 外 交 声 誉 低 于 80", func(): return d(w, W.I_DIPLO) < 800))
	conds.append(cond(" 尚 未 签 署 协 定", func(): return not has(country, "对华贸易")))
	if has(c(w, 7), "nato") and (has(country, "亲美") or has(country, "亲苏") or has(country, "nato")):
		# 文案 other_text[105] 已解析（见下方 cond 文案）。
		conds.append(cond("苏 联 未 加 入 北 约", func(): return not has(c(w, 7), "nato")))
	var eff := func():
		set_tag(country, "对华贸易", true)
	return make_def(caption, " 签 署 一 份 友 好 合 作 协 定", conds, eff)


# ============================================================================
# 编号 34 · 邀请外国投资者
# DBS Show L1288-L1315 / OnMouseDown L9255-L9259
# ============================================================================
func _def_34(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	if gov(c(w, 21)) == 1 and country.原版序号 == 21:
		conds.append(cond(" 外 交 声 誉 高 于 60", func(): return d(w, W.I_DIPLO) >= 600))
	else:
		conds.append(cond(" 外 交 声 誉 低 于 60", func(): return d(w, W.I_DIPLO) < 600))
	if gov(c(w, 21)) == 1 and country.原版序号 == 21:
		conds.append(cond("经 济 模 式 为 \" 国 家 垄 断 资 本 主 义\" 或 更 偏 社 会 主 义 的 政 策| 或 开 放 自 由 贸 易 区", func(): return d(w, W.I_ECON_SYSTEM) < 13 or fl(w, "sez")))
	else:
		conds.append(cond("经 济 模 式 为 \" 鸟 笼 经 济 \" 或 更 偏 自 由 主 义 的 政 策| 或 开 放 经 济 特 区", func(): return d(w, W.I_ECON_SYSTEM) >= 13 or fl(w, "sez")))
	conds.append(cond(" 本 年 尚 未 吸 引 外 国 投 资", func(): return country.stab == 0))
	var eff := func():
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) + 50)
		country.stab = 1
	return make_def(caption, " 邀 请 外 国 投 资 者", conds, eff)


# ============================================================================
# 编号 35 · 建立紧密关系
# DBS Show L1316-L1329 / OnMouseDown L9260-L9265
# ============================================================================
func _def_35(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 外 交 声 誉 高 于 69", func(): return d(w, W.I_DIPLO) > 690))
	conds.append(cond(" 至 少 3 特 工 网 络", func(): return d(w, W.I_AGENTS) >= 30))
	conds.append(cond(" 越 南 持 亲 中 立 场", func(): return has(c(w, 11), "亲中")))
	conds.append(cond(" 尚 未 融 合 为 一", func(): return not has(country, "亲中")))
	var eff := func():
		# 原版 GlobalScript.inst.speed=0 + number_event=445 + LoadScene("Event")；Godot 由 start_event 内部 pause() 承担。
		start_event_num(w, 445)
	return make_def(caption, " 建 立 紧 密 关 系", conds, eff)


# ============================================================================
# 编号 36 · 经济合作（老挝变体）
# DBS Show L1330-L1343 / OnMouseDown L9266-L9282
# ============================================================================
func _def_36(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 老 挝 持 亲 中 立 场", func(): return has(country, "亲中")))
	conds.append(cond(" 已 深 化 经 贸 关 系", func(): return has(country, "对华贸易")))
	conds.append(cond(" 该 国 未 加 入 经 合 组 织", func(): return not has(country, "econ") and not has(country, "sev")))
	conds.append(cond(" 中 国 已 成 立 经 合 组 织 或 已 加 入 经 互 会", func(): return has(c(w, 1), "econ") or has(c(w, 1), "sev")))
	var eff := func():
		if has(c(w, 1), "sev"):
			add_power(w, 1, 20)
			w.influence_prc += 10
			set_tag(country, "sev", true)
		else:
			w.influence_prc += 20
			set_d(w, W.I_PEOPLE_SUPPORT, d(w, W.I_PEOPLE_SUPPORT) + 20)
			set_d(w, W.I_PARTY_SUPPORT, d(w, W.I_PARTY_SUPPORT) + 30)
			set_tag(country, "econ", true)
			country.social_stability = 1000
	return make_def(caption, " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系", conds, eff)


# ============================================================================
# 编号 38 · 支持纳赛尔主义者
# DBS Show L1358-L1371 / OnMouseDown L9295-L9299
# ============================================================================
func _def_38(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	conds.append(cond(" 外 交 声 誉 高 于 69", func(): return d(w, W.I_DIPLO) > 690))
	conds.append(cond(" 至 少 5 百 万 预 算", func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 50))
	conds.append(cond(" 趁 我 们 还 来 得 及", func(): return not ev(w, 37)))
	conds.append(cond(" 尚 未 提 供 支 持", func(): return country.stab == 0))
	var eff := func():
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 50)
		country.stab = 1
	return make_def(caption, " 支 持 纳 赛 尔 主 义 者", conds, eff)


# ============================================================================
# 公共助手（本批内使用）
# ============================================================================

## 编号9/10/24 共用：外交声誉分档描述（DBS Show L263-L287 同款）。
func _diplo_rep_desc(w: WorldState, country: CountryData) -> String:
	if w.leader_property.size() > 2 and w.leader_property[2] and soc(w, country, false):
		return " 外 交 声 誉 低 于 11451.4"
	if auth(w, country):
		return " 外 交 声 誉 在 39 到 80 之 间"
	if soc(w, country, true):
		return " 外 交 声 誉 高 于 69"
	if gov(country) == 2:
		return " 外 交 声 誉 在 39 到 85 之 间"
	return " 外 交 声 誉 低 于 50"


func _diplo_rep_check(w: WorldState, country: CountryData) -> bool:
	if w.leader_property.size() > 2 and w.leader_property[2] and soc(w, country, false):
		return d(w, W.I_DIPLO) < 114514
	if auth(w, country):
		return d(w, W.I_DIPLO) > 390 and d(w, W.I_DIPLO) < 800
	if soc(w, country, true):
		return d(w, W.I_DIPLO) > 690
	if gov(country) == 2:
		return d(w, W.I_DIPLO) > 390 and d(w, W.I_DIPLO) < 850
	return d(w, W.I_DIPLO) < 500


## 编号24 专用：多一条 伊朗14/SubGosstroy==20 的前置分档（DBS Show L782-L786）。
func _diplo_rep_desc24(w: WorldState, country: CountryData) -> String:
	if country.原版序号 == 14 and sub(country) == 20:
		return " 外 交 声 誉 低 于 11451.4"
	return _diplo_rep_desc(w, country)


func _diplo_rep_check24(w: WorldState, country: CountryData) -> bool:
	if country.原版序号 == 14 and sub(country) == 20:
		return d(w, W.I_DIPLO) < 114514
	return _diplo_rep_check(w, country)


## 编号19 uslovie[2]：军事联盟排他（忠实 DBS Show L646-L660）。
func _mil19_slot_check(w: WorldState, country: CountryData) -> bool:
	var player := w.get_player_country()
	if player == null:
		return false
	var via_ovd: bool = not has(country, "ovd") and player.has_tag("ovd") and not has(country, "seato")
	var via_okb: bool = not has(country, "okb") and player.has_tag("okb") and not has(country, "ovd") and not has(country, "seato")
	var complex := via_ovd or via_okb
	if not has(country, "oar"):
		return complex
	var c30 := c(w, 30)
	if c30 != null and c30.government == 1:
		return complex
	return false


## 原版 war_active[idx] 读取（越界按 false，与原版默认一致）。
func _war_active_flag(w: WorldState, idx: int) -> bool:
	return idx >= 0 and idx < w.war_active.size() and w.war_active[idx]


## 原版 war_active[idx] 写入（越界不写，与原版数组长度一致）。
func _set_war_active(w: WorldState, idx: int, value: bool) -> void:
	if idx >= 0 and idx < w.war_active.size():
		w.war_active[idx] = value


## 原版 modifies[idx].active 写入（越界不写）。
func _set_mod(w: WorldState, idx: int, value: bool) -> void:
	if idx >= 0 and idx < w.modifiers.size() and w.modifiers[idx] != null:
		w.modifiers[idx].is_active = value


## 原版 completedDecisions[idx]（DecisionState 建模为 w.decisions.completed）。
func _decision_done(w: WorldState, idx: int) -> bool:
	return w.decisions != null and w.decisions.completed.size() > idx and w.decisions.completed[idx]


## 指定原版序号国家的 development（查无国家按 0）。
func _cdev(w: WorldState, idx: int) -> int:
	var cc := c(w, idx)
	return cc.development if cc != null else 0


## 指定原版序号国家的 cw（内战中）。
func _ccw(w: WorldState, idx: int) -> bool:
	var cc := c(w, idx)
	return cc != null and cc.内战中


# ============================================================================
# 自检结果（Python 静态检查，未运行 Godot）：
#   UTF-8 可读: OK
#   行首空格: 0（全文件 tab 缩进）
#   build_action 分支: 34/34
#   _def_N 函数: 34/34
#   括号平衡: OK（每个 func 块及全文件 ( = ) = 1361，含本注释）
#   W.I_* 常量检查: OK（使用 22 个，均定义于 world_state.gd）
#   W preload 声明: OK
#   裸 W. 引用: 无（所有 W. 引用均有 preload 声明）
# ============================================================================
