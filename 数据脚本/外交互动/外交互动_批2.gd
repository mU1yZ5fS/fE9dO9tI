## 外交互动 批2 — 编号 39,40,41,42,43,44,45,46,48,49,50,51,52,53,54,55,56,57,58,60,61,62,63,64,65,66,67,68,70,71,72,73,74,75。
## 源码出处：DiploButtonScript.cs Show 中文分支 / OnMouseDown，具体行号见各 _def_N 注释。
extends "res://数据脚本/外交互动/外交互动_基础.gd"


## 主分发：返回 {caption, opis, conditions, effect, dormant} 或 {}。
func build_action(action_type: int, ctx: Dictionary) -> Dictionary:
	var w: WorldState = ctx.get("w")
	var country: CountryData = ctx.get("country")
	var caption: String = ctx.get("caption", "")
	match action_type:
		39:
			return _def_39(w, country, caption)
		40:
			return _def_40(w, country, caption)
		41:
			return _def_41(w, country, caption)
		42:
			return _def_42(w, country, caption)
		43:
			return _def_43(w, country, caption)
		44:
			return _def_44(w, country, caption)
		45:
			return _def_45(w, country, caption)
		46:
			return _def_46(w, country, caption)
		48:
			return _def_48(w, country, caption)
		49:
			return _def_49(w, country, caption)
		50:
			return _def_50(w, country, caption)
		51:
			return _def_51(w, country, caption)
		52:
			return _def_52(w, country, caption)
		53:
			return _def_53(w, country, caption)
		54:
			return _def_54(w, country, caption)
		55:
			return _def_55(w, country, caption)
		56:
			return _def_56(w, country, caption)
		57:
			return _def_57(w, country, caption)
		58:
			return _def_58(w, country, caption)
		60:
			return _def_60(w, country, caption)
		61:
			return _def_61(w, country, caption)
		62:
			return _def_62(w, country, caption)
		63:
			return _def_63(w, country, caption)
		64:
			return _def_64(w, country, caption)
		65:
			return _def_65(w, country, caption)
		66:
			return _def_66(w, country, caption)
		67:
			return _def_67(w, country, caption)
		68:
			return _def_68(w, country, caption)
		70:
			return _def_70(w, country, caption)
		71:
			return _def_71(w, country, caption)
		72:
			return _def_72(w, country, caption)
		73:
			return _def_73(w, country, caption)
		74:
			return _def_74(w, country, caption)
		75:
			return _def_75(w, country, caption)
	return {}


# ============================================================================
# 编号 39 · 允许该国加入我国经济联盟（阿拉伯联合共和国成立后）
# DBS Show L1372-1385 / OnMouseDown L9300-9316
# ============================================================================
func _def_39(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var player := c(w, 1)
	var opis := " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系"
	var conds: Array = []
	conds.append(cond(" 已 深 化 经 贸 关 系", func(): return country.has_tag("对华贸易")))
	conds.append(cond(" 阿 拉 伯 联 合 共 和 国 已 经 成 立", func(): return w.oar))
	conds.append(cond(" 该 国 未 加 入 经 合 组 织", func(): return not country.has_tag("econ") and not country.has_tag("sev")))
	conds.append(cond(" 中 国 已 成 立 经 合 组 织 或 已 加 入 经 互 会", func(): return player != null and (player.has_tag("econ") or player.has_tag("sev"))))
	var eff := func():
		if player != null and player.has_tag("sev"):
			add_power(w, 1, 20)
			w.influence_prc += 10
			country.set_tag("sev", true)
		else:
			w.influence_prc += 20
			set_d(w, 3, d(w, 3) + 20)
			set_d(w, 1, d(w, 1) + 30)
			country.set_tag("econ", true)
			country.social_stability = 1000
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 40 · 允许巴基斯坦加入我国经济联盟
# DBS Show L1386-1399 / OnMouseDown L9323-9341
# ============================================================================
func _def_40(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var player := c(w, 1)
	var c19 := c(w, 19)
	var opis := " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系"
	var conds: Array = []
	conds.append(cond(" 巴 基 斯 坦 未 持 亲 美 立 场", func(): return not country.has_tag("亲美")))
	conds.append(cond(" 中 印 关 系 尚 未 正 常 化 或 布 托 是 总 理", func(): return (c19 != null and not c19.has_tag("对华贸易")) or country.has_tag("亲中")))
	conds.append(cond(" 该 国 未 加 入 经 合 组 织", func(): return not country.has_tag("econ") and not country.has_tag("sev") and not country.has_tag("asean")))
	conds.append(cond(" 中 国 已 成 立 经 合 组 织 或 已 加 入 经 互 会", func(): return player != null and (player.has_tag("econ") or player.has_tag("sev"))))
	var eff := func():
		if player != null and player.has_tag("sev"):
			add_power(w, 1, 20)
			w.influence_prc += 10
			add_rel(w, 0, -50)
			country.set_tag("sev", true)
		else:
			w.influence_prc += 20
			set_d(w, 3, d(w, 3) + 20)
			set_d(w, 1, d(w, 1) + 30)
			add_rel(w, 0, -50)
			country.set_tag("econ", true)
			country.social_stability = 1000
	return make_def(caption, opis, conds, eff)

# ============================================================================
# 编号 41 · 邀请巴基斯坦参与我国军事联盟
# DBS Show L1400-1413 / OnMouseDown L9342-9359
# ============================================================================
func _def_41(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var player := c(w, 1)
	var opis := " 邀 请 该 国 参 与 我 国 军 事 联 盟 ， 实 现 合 作 无 上 限 ， 保 障 地 区 安 全 稳 定"
	var conds: Array = []
	conds.append(cond(" 至 少 2 军 事 实 力", func(): return d(w, 22) >= 20))
	conds.append(cond(" 巴 基 斯 坦 持 亲 中 立 场| 中 国 已 成 立 集 安 组 织 或 已 加 入 华 约", func(): return (country.has_tag("econ") or country.has_tag("sev")) and player != null and (player.has_tag("okb") or player.has_tag("ovd"))))
	conds.append(cond(" 巴 基 斯 坦 尚 未 参 与 军 事 联 盟", func(): return not country.has_tag("okb") and not country.has_tag("ovd") and not country.has_tag("seato") and not country.has_tag("sento")))
	conds.append(cond(" 巴 基 斯 坦 已 加 入 经 合 组 织", func(): return country.has_tag("econ") or country.has_tag("sev")))
	var eff := func():
		if player != null and player.has_tag("ovd"):
			add_power(w, 1, 20)
			w.influence_prc += 10
			country.set_tag("ovd", true)
		else:
			w.influence_prc += 20
			country.set_tag("okb", true)
			if country.social_stability <= 0:
				country.social_stability = 1000
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 42 · 打入缅甸社会主义纲领党政府并支持体制内反对派
# DBS Show L1414-1425 / OnMouseDown L9360-9366
# ============================================================================
func _def_42(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 打 入 缅 甸 社 会 主 义 纲 领 党 政 府 并 支 持 体 制 内 反 对 派"
	var conds: Array = []
	conds.append(cond(" 至 少 8 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 80))
	conds.append(cond(" 至 少 3 特 工 网 络", func(): return d(w, 9) >= 30))
	conds.append(cond(" 尚 未 援 助", func(): return country.stab == 0))
	var eff := func():
		set_d(w, 8, d(w, 8) - 80)
		set_d(w, 9, d(w, 9) - 50)
		w.influence_prc += 10
		country.stab = 1
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 43 · 支持泰国共产党
# DBS Show L1426-1439 / OnMouseDown L9367-9373
# ============================================================================
func _def_43(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 支 持 泰 国 共 产 党"
	var conds: Array = []
	conds.append(cond(" 至 少 4 特 工 网 络", func(): return d(w, 9) >= 40))
	conds.append(cond(" 至 少 2 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 20))
	conds.append(cond(" 泰 国 尚 未 发 生 政 变", func(): return not fl(w, "TaiCoup")))
	conds.append(cond(" 泰 国 尚 未 翻 红", func(): return country == null or (country.government != GameConstants.Government.SOCIALIST and not country.has_tag("亲中"))))
	conds.append(cond(" 尚 未 提 供 支 持", func(): return country.stab == 0))
	var eff := func():
		set_d(w, 9, d(w, 9) - 40)
		set_d(w, 8, d(w, 8) - 20)
		set_d(w, 41, 100)
		country.stab = 1
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 44 · 允许该国加入我国经济联盟（共产党获胜）
# DBS Show L1440-1461 / OnMouseDown L9374-9390
# ============================================================================
func _def_44(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var player := c(w, 1)
	var opis := " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系"
	var conds: Array = []
	if country.原版序号 == 52:
		conds.append(cond("推 翻 右 翼 独 裁 体 制", func(): return country.special > 0))
	else:
		conds.append(cond(" 共 产 党 获 胜", func(): return gov(country) == 1))
	conds.append(cond(" 已 深 化 经 贸 关 系", func(): return country.has_tag("对华贸易")))
	conds.append(cond(" 该 国 未 加 入 经 合 组 织", func(): return not country.has_tag("econ") and not country.has_tag("sev")))
	conds.append(cond(" 中 国 已 成 立 经 合 组 织 或 已 加 入 经 互 会", func(): return player != null and (player.has_tag("econ") or player.has_tag("sev"))))
	var eff := func():
		if player != null and player.has_tag("sev"):
			add_power(w, 1, 20)
			w.influence_prc += 10
			country.set_tag("sev", true)
		else:
			w.influence_prc += 20
			set_d(w, 3, d(w, 3) + 20)
			set_d(w, 1, d(w, 1) + 30)
			country.set_tag("econ", true)
			country.social_stability = 1000
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 45 · 促成该国加入阿拉伯联合共和国
# DBS Show L1462-1491 / OnMouseDown L9391-9395
# ============================================================================
func _def_45(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var c30 := c(w, 30)
	var opis := " 促 成 该 国 加 入 阿 拉 伯 联 合 共 和 国 ，实 现 阿 拉 伯 世 界 的 政 治 统 一"
	var conds: Array = []
	conds.append(cond(" 阿 拉 伯 联 合 共 和 国 已 经 成 立", func(): return w.oar))
	if c30 != null and c30.government == GameConstants.Government.SOCIALIST:
		conds.append(cond(" 该 国 未 加 入 阿 拉 伯 联 合 共 和 国", func(): return not country.has_tag("oar")))
	else:
		conds.append(cond(" 该 国 未 加 入 阿 拉 伯 联 合 共 和 国\n 且 未 参 与 军 事 联 盟", func(): return not country.has_tag("oar") and not country.has_tag("nato") and not country.has_tag("okb") and not country.has_tag("ovd")))
	conds.append(cond(" 他 们 不 属 于 美 国 的 势 力 范 围", func(): return not country.has_tag("亲美")))
	if c30 != null and c30.government == GameConstants.Government.SOCIALIST:
		conds.append(cond(" 该 国 为 社 会 主 义", func(): return soc(w, country, true)))
	else:
		conds.append(cond(" 该 国 为 改 良 主 义 或 左 翼 民 族 主 义", func(): return gov(country) == 2 or sub(country) == 10))
	var eff := func():
		country.set_tag("oar", true)
		w.influence_prc += 10
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 46 · 为解决巴勒斯坦问题组织双方调解
# DBS Show L1492-1501 / OnMouseDown L9396-9402
# ============================================================================
func _def_46(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 为 解 决 巴 勒 斯 坦 问 题 组 织 双 方 调 解"
	var conds: Array = []
	conds.append(cond(" 以 色 列 输 掉 了 黎 巴 嫩 战 争", func(): return fl(w, "israellost") or fl(w, "israel_lost_lebanon_war")))
	conds.append(cond(" 尚 未 组 织 调 解", func(): return country.development == 0))
	var eff := func():
		country.development = 1
		# 原版 number_event=30 → 本项目 event_id 为 palestine_settlement
		start_event("palestine_settlement")
	return make_def(caption, opis, conds, eff)

# ============================================================================
# 编号 48 · 发动战略进攻，解放台海岛屿
# DBS Show L1519-1530 / OnMouseDown L9410-9422
# ============================================================================
func _def_48(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var c51 := c(w, 51)
	var opis := " 发 动 战 略 进 攻 ， 解 放 台 海 岛 屿"
	var conds: Array = []
	conds.append(cond(" 至 少 50 军 事 实 力", func(): return d(w, 22) >= 500))
	conds.append(cond(" 尚 未 关 系 正 常 化", func(): return c51 != null and not c51.has_tag("对华贸易")))
	conds.append(cond(" 尚 未 发 动 进 攻", func(): return country.development == 0))
	var eff := func():
		set_d(w, 22, d(w, 22) - 500)
		set_rel(w, 0, 0)
		add_power(w, 0, -50)
		set_d(w, 4, d(w, 4) - 500)
		w.influence_prc += 50
		set_d(w, 3, d(w, 3) + 100)
		set_d(w, 1, d(w, 1) + 200)
		set_d(w, 6, d(w, 6) + 200)
		set_d(w, 63, 1)
		country.development = 1
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 49 · 按目标国分支的杂项行动（瑞士/古巴/卡纳克/乐队）
# DBS Show L1531-1605 / OnMouseDown L9423-9531
# ============================================================================
func _def_49(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var sid := country.原版序号
	var opis := ""
	var conds: Array = []
	if sid == 39:
		if soc(w, c(w, 39), false):
			opis = " 将 钱 汇 入 中 国 共 产 党 的 海 外 秘 密 账 户"
		else:
			opis = " 将 钱 汇 入 瑞 士 农 村 信 用 合 作 社"
		if not country.has_tag("亲中"):
			conds.append(cond(" 至 少 10 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 100))
		else:
			conds.append(cond(" 至 少 5 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 50))
		var c39 := c(w, 39)
		conds.append(cond(" 每 月 限 一 次", func(): return c39 != null and c39.development == 0))
	elif sid == 138:
		opis = " 从 古 巴 进 口 高 档 雪 茄"
		if not country.has_tag("亲中"):
			conds.append(cond(" 至 少 10 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 100))
		else:
			conds.append(cond(" 至 少 5 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 50))
		var c138 := c(w, 138)
		conds.append(cond(" 每 月 限 一 次", func(): return c138 != null and c138.development == 0))
		conds.append(cond(" 与 古 巴 有 贸 易", func(): return c138 != null and c138.has_tag("对华贸易")))
	elif sid == 154:
		opis = "  夏 日 ， 阳 光 ， 度 假 ！|为 我 国 的 先 进 份 子 提 供 疗 养 地 ， 在 风 景 如 画 的 小 岛 上 享 受 人 生 "
		if not country.has_tag("亲中"):
			conds.append(cond(" 至 少 5 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 50))
		else:
			conds.append(cond(" 至 少 2 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 20))
		conds.append(cond(" 党 支 持 度 低 于 1 0 0 ", func(): return d(w, 1) < 1000))
		var c154 := c(w, 154)
		conds.append(cond(" 卡 纳 克 已 独 立", func(): return c154 != null and c154.puppet_of < 0))
	elif sid == 152:
		opis = " 邀 请 乐 队 访 华"
		conds.append(cond(" 至 少 3 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 30))
		var c152 := c(w, 152)
		conds.append(cond(" 未 邀 请 过", func(): return c152 != null and not c152.内战中))
	else:
		return {}
	var eff := func():
		if sid == 39:
			if GameManager != null:
				GameManager.set_speed(0)
			start_event_num(w, 693)
			var c39 := c(w, 39)
			if c39 != null:
				c39.development = 1
		elif sid == 138:
			set_d(w, 26, d(w, 26) + 10)
			if w.leader_property.size() < 1:
				w.leader_property.resize(1)
			w.leader_property[0] = true
			if not country.has_tag("亲中"):
				set_d(w, 1, d(w, 1) + 200)
				set_d(w, 3, d(w, 3) + 100)
				set_d(w, 5, d(w, 5) + 50)
				set_d(w, 8, d(w, 8) - 100)
			else:
				set_d(w, 1, d(w, 1) + 200)
				set_d(w, 3, d(w, 3) + 100)
				set_d(w, 5, d(w, 5) + 50)
				set_d(w, 8, d(w, 8) - 50)
			var c138 := c(w, 138)
			if c138 != null:
				c138.development = 1
		elif sid == 154:
			set_d(w, 1, d(w, 1) + 50)
			if not country.has_tag("亲中"):
				set_d(w, 8, d(w, 8) - 50)
			else:
				set_d(w, 8, d(w, 8) - 20)
			var num4 := 900
			for ck in w.countries:
				if ck == null:
					continue
				if ck.has_tag("对华贸易"):
					num4 += 1
				else:
					num4 -= 1
				if ck.has_tag("亲中"):
					num4 += 5
				else:
					num4 -= 5
				if soc(w, ck, true) and not mod(w, 6):
					num4 -= 10
				if soc(w, ck, true) and mod(w, 6):
					num4 += 10
			if not fl(w, "relres"):
				num4 -= 100
			var c51 := c(w, 51)
			if c51 == null or not c51.has_tag("对华贸易"):
				num4 -= 100
			if rel(w, 0) < 500:
				num4 -= 150
			if rel(w, 1) < 500:
				num4 -= 150
			num4 -= country.prc_influence
			if num4 > 900:
				num4 = 900
			var num5 := _rng(w, 0, 1000)
			if num4 <= num5:
				set_d(w, 35, 10)
				# 原 DiploButtonScript.cs:9515：data.ending_route=10 + LoadScene("Ending")。
				GameManager.trigger_ending(10)
			if w.leader != null and w.leader.name_first == 13 and w.leader.name_last == 13 and d(w, 20) == 2 and d(w, 19) == 19:
				set_d(w, 35, 10)
				# 原 DiploButtonScript.cs:9520：data.ending_route=10 + LoadScene("Ending")。
				GameManager.trigger_ending(10)
			country.prc_influence += 100
		elif sid == 152:
			set_d(w, 8, d(w, 8) - 30)
			set_d(w, 3, d(w, 3) + 50)
			var c152 := c(w, 152)
			if c152 != null:
				c152.内战中 = true
	return make_def(caption, opis, conds, eff)

# ============================================================================
# 编号 50 · 深化经贸关系（工业70档）
# DBS Show L838-880 / OnMouseDown L9291-9294
# ============================================================================
func _def_50(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 深 化 经 贸 关 系"
	var conds: Array = []
	if w.leader_property.size() > 2 and w.leader_property[2] and not soc(w, country, false):
		conds.append(cond(" 外 交 声 誉 低 于 11451.4", func(): return d(w, 6) < 114514))
	elif auth(w, country):
		conds.append(cond(" 外 交 声 誉 在 39 到 80 之 间", func(): return d(w, 6) > 390 and d(w, 6) < 800))
	elif soc(w, country, true):
		conds.append(cond(" 外 交 声 誉 高 于 69", func(): return d(w, 6) > 690))
	elif gov(country) == 2:
		conds.append(cond(" 外 交 声 誉 在 39 到 85 之 间", func(): return d(w, 6) > 390 and d(w, 6) < 850))
	else:
		conds.append(cond(" 外 交 声 誉 低 于 50", func(): return d(w, 6) < 500))
	conds.append(cond(" 尚 未 深 化 经 贸 关 系", func(): return not country.has_tag("对华贸易")))
	conds.append(cond(" 工 业 不 低 于 70", func(): return d(w, 12) >= 700))
	var c7 := c(w, 7)
	if c7 != null and c7.has_tag("nato") and (country.has_tag("亲美") or country.has_tag("亲苏") or country.has_tag("nato")):
		conds.append(cond(" 苏 联 未 加 入 北 约", func(): return c7 != null and not c7.has_tag("nato")))
	var eff := func():
		country.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 51 · 支援日本革命共产党 / 日本共产主义抵抗者同盟
# DBS Show L1606-1633 / OnMouseDown L9532-9550
# ============================================================================
func _def_51(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var japan_rev := ev(w, 532) and res(w, 532) == 0
	var opis := " 支 持 日 本 共 产 主 义 抵 抗 者 同 盟。\n影 响 力： " + str(country.prc_power)
	var conds: Array = []
	if japan_rev:
		opis = " 支 援 日 本 革 命 共 产 党 。\n影 响 力： " + str(country.prc_power)
		conds.append(cond(" 至 少 5 特 工 网 络", func(): return d(w, 9) >= 50))
		conds.append(cond(" 至 少 5 点 军 事 力 量", func(): return d(w, 22) >= 50))
		conds.append(cond(" 至 少 5 点 预 算", func(): return d(w, 8) + d(w, 36) >= 50))
		conds.append(cond(" 外 交 声 誉 高 于 69", func(): return d(w, 6) >= 690))
	else:
		conds.append(cond(" 至 少 3 特 工 网 络", func(): return d(w, 9) >= 30))
		conds.append(cond(" 至 少 3 点 军 事 力 量", func(): return d(w, 22) >= 30))
		conds.append(cond(" 至 少 3 点 预 算", func(): return d(w, 8) + d(w, 36) >= 30))
		conds.append(cond(" 外 交 声 誉 高 于 69", func(): return d(w, 6) >= 690))
	var eff := func():
		if japan_rev:
			add_rel(w, 0, -20)
			set_d(w, 8, d(w, 8) - 50)
			set_d(w, 9, d(w, 9) - 50)
			set_d(w, 22, d(w, 22) - 50)
			country.prc_power += 15
		else:
			add_rel(w, 0, -20)
			set_d(w, 8, d(w, 8) - 30)
			set_d(w, 9, d(w, 9) - 30)
			set_d(w, 22, d(w, 22) - 30)
			country.prc_power += 10
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 52 · 深化经贸关系（工业80档）
# DBS Show L1634-1669 / OnMouseDown L9551-9555
# ============================================================================
func _def_52(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 深 化 经 贸 关 系"
	var conds: Array = []
	if w.leader_property.size() > 2 and w.leader_property[2] and not soc(w, country, false):
		conds.append(cond(" 外 交 声 誉 低 于 11451.4", func(): return d(w, 6) < 114514))
	elif gov(country) == 1:
		conds.append(cond(" 外 交 声 誉 不 低 于 80", func(): return d(w, 6) >= 800))
	elif gov(country) <= 2:
		conds.append(cond(" 外 交 声 誉 在 39 到 85 之 间", func(): return d(w, 6) > 390 and d(w, 6) < 850))
	elif gov(country) == 3:
		conds.append(cond(" 外 交 声 誉 低 于 50", func(): return d(w, 6) < 500))
	else:
		conds.append(cond(" 外 交 声 誉 无 匹 配 分 支", func(): return false))
	conds.append(cond(" 尚 未 深 化 经 贸 关 系", func(): return not country.has_tag("对华贸易")))
	conds.append(cond(" 工 业 不 低 于 80", func(): return d(w, 12) >= 800))
	var c7 := c(w, 7)
	if c7 != null and c7.has_tag("nato") and (country.has_tag("亲美") or country.has_tag("亲苏") or country.has_tag("nato")):
		conds.append(cond(" 苏 联 未 加 入 北 约", func(): return c7 != null and not c7.has_tag("nato")))
	var eff := func():
		set_d(w, 1, d(w, 1) + 50)
		country.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 53 · 允许该国加入我国经济联盟（阵营分支）
# DBS Show L1670-1726 / OnMouseDown L9556-9571
# ============================================================================
func _def_53(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var player := c(w, 1)
	var sid := country.原版序号
	var opis := " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系"
	var conds: Array = []
	if sid != 94 and sid != 95 and sid != 84 and sid != 14 and sid != 35:
		conds.append(cond(" 已 深 化 经 贸 关 系| 且 由 持 亲 中 立 场 的 政 府 执 政", func(): return country.has_tag("对华贸易") and country.has_tag("亲中")))
	else:
		conds.append(cond(" 已 深 化 经 贸 关 系", func(): return country.has_tag("对华贸易")))
	if sid == 26 or sid == 27 or sid == 39 or sid == 88 or sid == 0 or sid == 89 or sid == 90 or sid == 91 or sid == 28:
		conds[0] = cond(" 已 对 某 一 派 系 施 以 援 手", func(): return country.内战中)
	conds.append(cond(" 中 国 已 成 立 经 合 组 织 或 已 加 入 经 互 会", func(): return player != null and (player.has_tag("econ") or player.has_tag("sev"))))
	conds.append(cond(" 该 国 未 加 入 经 合 组 织", func(): return not country.has_tag("econ") and not country.has_tag("sev")))
	if sid == 94:
		var c94 := c(w, 94)
		var c45 := c(w, 45)
		if c94 != null and (c94.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST or c94.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST):
			conds.append(cond(" 塞 浦 路 斯 已 武 力 统 一 且 希 腊 亲 中", func(): return d(w, 127) == 100 and c94 != null and parts(c94, 0) and c45 != null and c45.has_tag("亲中")))
		else:
			conds.append(cond(" 塞 浦 路 斯 已 统 一", func(): return d(w, 127) == 100 and c94 != null and parts(c94, 0)))
	elif sid == 14 or sid == 35:
		if soc(w, country, true):
			conds.append(cond(" 我 国 体 制 为 社 会 主 义 或 该 国 处 于 中 国 势 力 范 围", func(): return soc(w, country, true) or country.has_tag("亲中")))
		else:
			conds.append(cond("该 国 持 亲 中 立 场", func(): return country.has_tag("亲中")))
	if country.has_tag("亲美"):
		conds.append(cond(" 该 国 不 受 美 国 的 影 响", func(): return not country.has_tag("亲美")))
	var eff := func():
		w.influence_prc += 30
		set_d(w, 1, d(w, 1) + 30)
		country.stab = 1000
		country.social_stability = 1000
		if player != null and player.has_tag("sev"):
			country.set_tag("sev", true)
		else:
			country.set_tag("econ", true)
			country.social_stability = 1000
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 54 · 允许该国加入我国经济联盟（左翼阵线掌权）
# DBS Show L1727-1744 / OnMouseDown L9572-9590
# ============================================================================
func _def_54(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var player := c(w, 1)
	var opis := " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系"
	var conds: Array = []
	conds.append(cond(" 左 翼 阵 线 掌 权", func(): return gov(country) == 2))
	conds.append(cond(" 中 国 已 成 立 经 合 组 织 或 已 加 入 经 互 会", func(): return player != null and (player.has_tag("econ") or player.has_tag("sev"))))
	conds.append(cond(" 该 国 未 加 入 经 合 组 织", func(): return not country.has_tag("econ") and not country.has_tag("sev")))
	if country.has_tag("亲美"):
		conds.append(cond(" 该 国 不 受 美 国 的 影 响", func(): return not country.has_tag("亲美")))
	var eff := func():
		country.stab = 1000
		country.social_stability = 1000
		if player != null and player.has_tag("sev"):
			add_power(w, 1, 20)
			w.influence_prc += 10
			country.set_tag("sev", true)
		else:
			w.influence_prc += 20
			set_d(w, 3, d(w, 3) + 20)
			set_d(w, 1, d(w, 1) + 30)
			country.set_tag("econ", true)
			country.social_stability = 1000
	return make_def(caption, opis, conds, eff)

# ============================================================================
# 编号 55 · 同时施加政治和经济压力
# DBS Show L1745-1770 / OnMouseDown L9591-9599
# ============================================================================
func _def_55(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 同 时 施 加 政 治 和 经 济 压 力"
	var conds: Array = []
	conds.append(cond(" 越 南 ， 泰 国 ， 菲 律 宾| 与 我 们 在 同 一 经 济 联 盟 中", func(): return (c(w, 11) != null and c(w, 11).has_tag("econ") and c(w, 34) != null and c(w, 34).has_tag("econ") and c(w, 47) != null and c(w, 47).has_tag("econ")) or (c(w, 11) != null and c(w, 11).has_tag("sev") and c(w, 34) != null and c(w, 34).has_tag("sev") and c(w, 47) != null and c(w, 47).has_tag("sev")) or (c(w, 11) != null and c(w, 11).has_tag("asean") and c(w, 34) != null and c(w, 34).has_tag("asean") and c(w, 47) != null and c(w, 47).has_tag("asean"))))
	conds.append(cond(" 至 少 4 特 工 网 络", func(): return d(w, 9) >= 40))
	conds.append(cond(" 支 持 釜 山 起 义 和 光 州 起 义", func(): return fl(w, "south_korea_gwangju_rebellion") and res(w, 474) == 0))
	var c46 := c(w, 46)
	if c46 != null and c46.government == GameConstants.Government.SOCIALIST:
		conds.append(cond(" 左 翼 分 子 尚 未 在 韩 国 掌 权", func(): return c46 != null and c46.government != GameConstants.Government.SOCIALIST))
	elif war(w, 0):
		conds.append(cond(" 该 国 当 前 没 有 战 争", func(): return not war(w, 0)))
	else:
		conds.append(cond(" 尚 未 进 行 施 压", func(): return country.stab == 0))
	var eff := func():
		set_d(w, 9, d(w, 9) - 40)
		add_rel(w, 0, -100)
		country.stab = 1
		# 原版 number_event=31 → 本项目 event_id 为 south_korea_election
		start_event("south_korea_election")
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 56 · 支持菲律宾毛派游击武装 / 伊拉克武装反对派
# DBS Show L1771-1816 / OnMouseDown L9600-9627
# ============================================================================
func _def_56(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var sid := country.原版序号
	var opis := ""
	var conds: Array = []
	if sid == 47:
		@warning_ignore("integer_division")
		opis = " 支 持 毛 派 游 击 武 装| 毛 主 义 者 力 量 ：" + str(d(w, 37) / 10) + "." + str(absi(d(w, 37) % 10))
		conds.append(cond(" 至 少 4 特 工 网 络", func(): return d(w, 9) >= 40))
		conds.append(cond(" 至 少 3 军 事 实 力", func(): return d(w, 22) >= 30))
		conds.append(cond(" 外 交 声 誉 高 于 75", func(): return d(w, 6) >= 750))
		conds.append(cond(" 本 年 尚 未 支 持", func(): return country.stab == 0 and d(w, 37) < 1000))
	elif sid == 14:
		var c14 := c(w, 14)
		var prc14 := c14.prc_power if c14 != null else 0
		if ev(w, 36) and res(w, 36) == 2:
			opis = " 支 持 伊 拉 克 武 装 反 对 派| 反 对 派 力 量 ：" + str(prc14)
			conds.append(cond(" 至 少 2 特 工 网 络", func(): return d(w, 9) >= 20))
			conds.append(cond(" 至 少 2 军 事 实 力", func(): return d(w, 22) >= 20))
			conds.append(cond(" 外 交 声 誉 高 于 75", func(): return d(w, 6) >= 750))
			conds.append(cond(" 三 月 一 次", func(): return country.stab == 0))
		elif ev(w, 36) and res(w, 36) == 3:
			opis = " 召 唤 什 叶 派 群 众 们 起 来 反 抗 复 兴 党 政 府| 达 瓦 党 力 量 ：" + str(prc14)
			conds.append(cond(" 至 少 2 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 20))
			conds.append(cond(" 至 少 3 军 事 实 力", func(): return d(w, 22) >= 30))
			conds.append(cond(" 两 月 一 次", func(): return country.stab == 0))
		else:
			return {}
	else:
		return {}
	var eff := func():
		if sid == 47:
			set_d(w, 6, d(w, 6) + 10)
			set_d(w, 9, d(w, 9) - 40)
			set_d(w, 22, d(w, 22) - 30)
			set_d(w, 37, d(w, 37) + 100)
			country.stab = 1
		elif sid == 14:
			var c14 := c(w, 14)
			if ev(w, 36) and res(w, 36) == 2:
				set_d(w, 9, d(w, 9) - 20)
				set_d(w, 22, d(w, 22) - 20)
				if c14 != null:
					c14.prc_power += 10
				country.stab = 1
			elif ev(w, 36) and res(w, 36) == 3:
				set_d(w, 8, d(w, 8) - 20)
				set_d(w, 22, d(w, 22) - 30)
				if c14 != null:
					c14.prc_power += 5
				country.stab = 2
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 57 · 支持南非抗议 / 西南非洲民族联盟
# DBS Show L1817-1844 / OnMouseDown L9628-9642
# ============================================================================
func _def_57(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := ""
	var conds: Array = []
	if not country.内战中:
		opis = " 支 持 抗 议 种 族 隔 离 的 民 众 示 威 运 动"
		conds.append(cond(" 至 少 10 特 工 网 络", func(): return d(w, 9) >= 100))
		conds.append(cond(" 至 少 10 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 100))
		conds.append(cond(" 不 早 于 1980 年", func(): return d(w, 21) >= 1980))
		conds.append(cond(" 尚 未 推 波 助 澜", func(): return not country.内战中))
	else:
		opis = " 继 续 支 持 西 南 非 洲 民 族 联 盟 争 取 纳 米 比 亚 民 族 独 立 的 斗 争"
		conds.append(cond(" 至 少 5 特 工 网 络 与 5 百 万 预 算", func(): return d(w, 9) >= 50 and d(w, 8) + d(w, 36) >= 50))
		conds.append(cond(" 我 们 仍 坚 持 毛 泽 东 思 想", func(): return mod(w, 6)))
		var c123 := c(w, 123)
		conds.append(cond(" 安 哥 拉 没 有 亲 美 立 场 且 不 是 南 非 傀 儡", func(): return c123 != null and not c123.has_tag("亲美") and c123.puppet_of != GameConstants.LegacySlot.SOUTH_AFRICA))
		var c153 := c(w, 153)
		conds.append(cond(" 尚 未 支 持", func(): return c153 != null and not c153.内战中))
	var eff := func():
		if not country.内战中:
			set_d(w, 9, d(w, 9) - 100)
			set_d(w, 8, d(w, 8) - 100)
			country.内战中 = true
		else:
			set_d(w, 9, d(w, 9) - 50)
			set_d(w, 8, d(w, 8) - 50)
			var c153 := c(w, 153)
			if c153 != null:
				c153.内战中 = true
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 58 · 对该国右翼独裁政权实施制裁
# DBS Show L1845-1880 / OnMouseDown L9643-9663
# ============================================================================
func _def_58(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var sid := country.原版序号
	var opis := " 对 该 国 右 翼 独 裁 政 权 实 施 制 裁"
	var conds: Array = []
	if sid == 52:
		conds.append(cond(" 印 度 尼 西 亚 ， 菲 律 宾 ， 马 来 西 亚| 在 同 一 经 合 组 织 中", func(): return (c(w, 47) != null and c(w, 47).has_tag("econ") and c(w, 50) != null and c(w, 50).has_tag("econ") and c(w, 49) != null and c(w, 49).has_tag("econ")) or (c(w, 47) != null and c(w, 47).has_tag("sev") and c(w, 50) != null and c(w, 50).has_tag("sev") and c(w, 49) != null and c(w, 49).has_tag("sev")) or (c(w, 47) != null and c(w, 47).has_tag("asean") and c(w, 50) != null and c(w, 50).has_tag("asean") and c(w, 49) != null and c(w, 49).has_tag("asean"))))
		conds.append(cond(" 至 少 8 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 80))
	else:
		conds.append(cond(" 越 南 ， 泰 国 ， 马 来 西 亚 ， 菲 律 宾| 在 同 一 经 合 组 织 中", func(): return (c(w, 11) != null and c(w, 11).has_tag("econ") and c(w, 34) != null and c(w, 34).has_tag("econ") and c(w, 49) != null and c(w, 49).has_tag("econ") and c(w, 47) != null and c(w, 47).has_tag("econ")) or (c(w, 11) != null and c(w, 11).has_tag("sev") and c(w, 34) != null and c(w, 34).has_tag("sev") and c(w, 49) != null and c(w, 49).has_tag("sev") and c(w, 47) != null and c(w, 47).has_tag("sev")) or (c(w, 11) != null and c(w, 11).has_tag("asean") and c(w, 34) != null and c(w, 34).has_tag("asean") and c(w, 49) != null and c(w, 49).has_tag("asean") and c(w, 47) != null and c(w, 47).has_tag("asean"))))
		conds.append(cond(" 至 少 4 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 40))
	conds.append(cond(" 尚 未 进 行 施 压", func(): return country.stab == 0))
	if sid == 52:
		conds.append(cond(" 中 国 全 球 影 响 力 高 于 70.0 且 该 国 不 是 我 国 联 盟 的 一 员", func(): return w.influence_prc >= 700 and ((c(w, 1) != null and c(w, 1).has_tag("sev") and not country.has_tag("sev")) or (c(w, 1) != null and c(w, 1).has_tag("econ") and not country.has_tag("econ")) or (c(w, 1) != null and c(w, 1).has_tag("asean") and not country.has_tag("asean")))))
	var eff := func():
		if sid == 52:
			set_d(w, 8, d(w, 8) - 80)
			country.stab = 1
			country.set_tag("对华贸易", false)
			add_rel(w, 0, -150)
			add_power(w, 0, 50)
			country.set_tag("亲美", true)
		else:
			set_d(w, 8, d(w, 8) - 40)
			add_rel(w, 0, -50)
			country.stab = 1
			# 原版 number_event=28 → 本项目 event_id 为 indonesia_after_suharto
			start_event("indonesia_after_suharto")
	return make_def(caption, opis, conds, eff)

# ============================================================================
# 编号 60 · 签署友好合作协定（中美关系70档）
# DBS Show L1881-1897 / OnMouseDown L9664-9667
# ============================================================================
func _def_60(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 签 署 一 份 友 好 合 作 协 定"
	var conds: Array = []
	conds.append(cond(" 中 美 关 系 至 少 为 70", func(): return rel(w, 0) > 700))
	if w.leader_property.size() > 2 and w.leader_property[2] and not soc(w, country, false):
		conds.append(cond(" 外 交 声 誉 低 于 11451.4", func(): return d(w, 6) < 114514))
	else:
		conds.append(cond(" 外 交 声 誉 低 于 50", func(): return d(w, 6) < 500))
	conds.append(cond(" 尚 未 签 署 协 定", func(): return not country.has_tag("对华贸易")))
	var eff := func():
		country.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 61 · 同美国中央情报局（CIA）开展合作
# DBS Show L1898-1909 / OnMouseDown L9668-9674
# ============================================================================
func _def_61(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 同 美 国 中 央 情 报 局 （ CIA ） 开 展 合 作"
	var conds: Array = []
	conds.append(cond(" 中 美 关 系 至 少 为 80", func(): return rel(w, 0) > 800))
	conds.append(cond(" 外 交 声 誉 低 于 60", func(): return d(w, 6) < 600))
	conds.append(cond(" 尚 未 开 展 合 作", func(): return country.development == 0))
	var eff := func():
		w.influence_prc -= 50
		add_power(w, 1, -20)
		add_power(w, 0, 50)
		w.set_flag("cia_cooperation", true)
		country.development = 1
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 62 · 帮助我们的朋友 / 在当地扶持亲中势力
# DBS Show L1910-1954 / OnMouseDown L9675-9715
# ============================================================================
func _def_62(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var proprc := country.has_tag("亲中")
	@warning_ignore("integer_division")
	var opis := " 在 当 地 扶 持 亲 中 势 力| 亲 中 势 力 规 模 ：" + str(country.prc_power / 10) + "." + str(absi(country.prc_power % 10))
	var conds: Array = []
	if proprc:
		@warning_ignore("integer_division")
		opis = " 帮 助 我 们 的 朋 友| 稳 定 度 ：" + str(country.stab / 10) + "." + str(absi(country.stab % 10))
		conds.append(cond(" 至 少 10 特 工 网 络", func(): return d(w, 9) >= 100))
		conds.append(cond(" 至 少 4 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 40))
		conds.append(cond(" 政 权 稳 定 度 低 于 100", func(): return country.stab < 1000))
		conds.append(cond(" 至 少 8 军 事 实 力", func(): return d(w, 22) >= 80))
	else:
		conds.append(cond(" 至 少 8 特 工 网 络", func(): return d(w, 9) >= 80))
		conds.append(cond(" 至 少 4 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 40))
		conds.append(cond(" 亲 中 势 力 规 模 低 于 100", func(): return country.prc_power < 1000))
		conds.append(cond(" 至 少 10 军 事 实 力", func(): return d(w, 22) >= 100))
	var eff := func():
		if proprc:
			set_d(w, 9, d(w, 9) - 100)
			set_d(w, 8, d(w, 8) - 40)
			set_d(w, 22, d(w, 22) - 80)
			country.stab += 200
			country.development += 80
			country.usa_power -= 200
			country.sov_power -= 200
			if country.stab > 1000:
				country.stab = 1000
				country.development = 1000
			if country.development > 1000:
				country.development = 1000
			if country.usa_power < 0:
				country.usa_power = 0
			if country.sov_power < 0:
				country.sov_power = 0
		else:
			country.prc_power += 200
			if country.prc_power > 1000:
				country.prc_power = 1000
			set_d(w, 9, d(w, 9) - 80)
			set_d(w, 8, d(w, 8) - 40)
			set_d(w, 22, d(w, 22) - 100)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 63 · 同亲苏势力进行联合，共同反美
# DBS Show L1955-1976 / OnMouseDown L9716-9720
# ============================================================================
func _def_63(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	@warning_ignore("integer_division")
	var opis := " 同 亲 苏 势 力 进 行 联 合 ， 共 同 反 美| 亲 苏 势 力 规 模 ：" + str(country.sov_power / 10) + "." + str(absi(country.sov_power % 10))
	var conds: Array = []
	conds.append(cond(" 至 少 2 特 工 网 络", func(): return d(w, 9) >= 20))
	conds.append(cond(" 外 交 声 誉 高 于 69", func(): return d(w, 6) > 690))
	conds.append(cond(" 尚 未 进 行 联 合", func(): return not country.has_tag("美国盟友") and not country.has_tag("苏联盟友")))
	conds.append(cond(" 该 国 未 持 亲 苏 或 亲 中 立 场", func(): return not country.has_tag("亲苏") and not country.has_tag("亲中")))
	var eff := func():
		country.set_tag("苏联盟友", true)
		set_d(w, 9, d(w, 9) - 20)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 64 · 同亲美势力进行联合，共同反苏
# DBS Show L1977-1998 / OnMouseDown L9721-9725
# ============================================================================
func _def_64(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	@warning_ignore("integer_division")
	var opis := " 同 亲 美 势 力 进 行 联 合 ， 共 同 反 苏| 亲 美 势 力 规 模 ：" + str(country.usa_power / 10) + "." + str(absi(country.usa_power % 10))
	var conds: Array = []
	conds.append(cond(" 至 少 2 特 工 网 络", func(): return d(w, 9) >= 20))
	conds.append(cond(" 外 交 声 誉 低 于 50", func(): return d(w, 6) < 500))
	conds.append(cond(" 尚 未 进 行 联 合", func(): return not country.has_tag("美国盟友") and not country.has_tag("苏联盟友")))
	conds.append(cond(" 该 国 未 持 亲 美 或 亲 中 立 场", func(): return not country.has_tag("亲美") and not country.has_tag("亲中")))
	var eff := func():
		country.set_tag("美国盟友", true)
		set_d(w, 9, d(w, 9) - 20)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 65 · 给乱局火上浇油，颠覆现政府
# DBS Show L1999-2008 / OnMouseDown L9726-9852
# ============================================================================
func _def_65(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 给 乱 局 火 上 浇 油 ， 颠 覆 现 政 府"
	var conds: Array = []
	conds.append(cond(" 亲 中 势 力 规 模 超 过 30", func(): return country.prc_power > 300 or country.stab > 300))
	conds.append(cond(" 该 国 未 持 亲 中 立 场", func(): return not country.has_tag("亲中") or country.has_tag("亲苏") or country.has_tag("亲美")))
	var eff := func():
		if country.stab >= 1000:
			var player := c(w, 1)
			if player != null:
				country.government = player.government
			country.set_tag("亲中", true)
			country.sub_government = chinese_sub_gosstroy(w)
			country.set_tag("亲苏", false)
			country.set_tag("亲美", false)
			country.puppet_of = GameConstants.LegacySlot.NONE
			w.influence_prc += 5
			country.stab = 100
			country.development -= 200
			country.set_tag("苏联盟友", false)
			country.set_tag("美国盟友", false)
			country.set_tag("亲美", false)
			country.set_tag("亲苏", false)
			@warning_ignore("integer_division")
			country.usa_power = (country.usa_power + 1) / 2
			@warning_ignore("integer_division")
			country.sov_power = (country.sov_power + 1) / 2
		if country.has_tag("美国盟友"):
			country.stab -= country.prc_power + country.usa_power + 100
		elif country.has_tag("苏联盟友"):
			country.stab -= country.prc_power + country.sov_power + 100
		else:
			country.stab -= country.prc_power + 100
		if country.stab < -200:
			if country.has_tag("美国盟友") and country.usa_power > country.prc_power:
				country.government = GameConstants.Government.LIBERAL
				country.sub_government = african_sub_gosstroy(w, country.government)
				country.set_tag("亲美", true)
				country.puppet_of = GameConstants.LegacySlot.NONE
				country.set_tag("亲苏", false)
				country.stab = 100
				country.development -= 200
				country.set_tag("美国盟友", false)
				@warning_ignore("integer_division")
				country.sov_power = (country.sov_power + 1) / 2
				add_power(w, 0, 10)
			elif country.has_tag("苏联盟友") and country.sov_power > country.prc_power:
				country.government = GameConstants.Government.SOCIALIST
				country.sub_government = african_sub_gosstroy(w, country.government)
				country.set_tag("亲苏", true)
				country.puppet_of = GameConstants.LegacySlot.NONE
				country.set_tag("亲美", false)
				country.stab = 100
				country.development -= 200
				country.set_tag("苏联盟友", false)
				@warning_ignore("integer_division")
				country.usa_power = (country.usa_power + 1) / 2
				add_power(w, 1, 10)
			elif country.has_tag("美国盟友"):
				country.government = GameConstants.Government.LIBERAL
				country.set_tag("亲中", true)
				country.puppet_of = GameConstants.LegacySlot.NONE
				country.sub_government = african_sub_gosstroy(w, country.government)
				country.set_tag("亲苏", false)
				country.set_tag("亲美", false)
				country.stab = 100
				country.development -= 200
				country.set_tag("美国盟友", false)
				@warning_ignore("integer_division")
				country.usa_power = (country.usa_power + 1) / 2
				@warning_ignore("integer_division")
				country.sov_power = (country.sov_power + 1) / 2
				add_power(w, 0, 5)
				w.influence_prc += 5
			elif country.has_tag("苏联盟友"):
				country.government = GameConstants.Government.SOCIALIST
				country.set_tag("亲中", true)
				country.puppet_of = GameConstants.LegacySlot.NONE
				country.sub_government = african_sub_gosstroy(w, country.government)
				country.set_tag("亲苏", false)
				country.set_tag("亲美", false)
				country.stab = 100
				country.development -= 200
				country.set_tag("苏联盟友", false)
				@warning_ignore("integer_division")
				country.usa_power = (country.usa_power + 1) / 2
				@warning_ignore("integer_division")
				country.sov_power = (country.sov_power + 1) / 2
				add_power(w, 1, 5)
				w.influence_prc += 5
			else:
				var player := c(w, 1)
				if player != null:
					country.government = player.government
				country.set_tag("亲中", true)
				country.puppet_of = GameConstants.LegacySlot.NONE
				country.sub_government = chinese_sub_gosstroy(w)
				country.set_tag("亲苏", false)
				country.set_tag("亲美", false)
				w.influence_prc += 5
				country.stab = 100
				country.development -= 200
				country.set_tag("苏联盟友", false)
				country.set_tag("美国盟友", false)
				country.set_tag("亲美", false)
				country.set_tag("亲苏", false)
				country.puppet_of = GameConstants.LegacySlot.NONE
				@warning_ignore("integer_division")
				country.usa_power = (country.usa_power + 1) / 2
				@warning_ignore("integer_division")
				country.sov_power = (country.sov_power + 1) / 2
		elif country.stab >= -200 and country.stab <= 100:
			country.stab = 0
			country.development -= 400
			country.prc_power = 100
			country.usa_power = 100
			country.sov_power = 100
		else:
			country.stab -= 200
			country.development -= 100
			country.prc_power = 0
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 66 · 圈地建立/关闭独占资源开发区
# DBS Show L2009-2031 / OnMouseDown L9853-9863
# ============================================================================
func _def_66(_w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	@warning_ignore("integer_division")
	var opis := "关 闭 我 们 位 于 该 国 的 独 占 资 源 开 发 区| 稳 定 度 ：" + str(country.stab / 10) + "." + str(absi(country.stab % 10))
	if not country.has_tag("对华贸易"):
		@warning_ignore("integer_division")
		opis = "要 求 在 该 国 圈 地 ， 建 立 独 占 资 源 开 发 区| 稳 定 度 ：" + str(country.stab / 10) + "." + str(absi(country.stab % 10))
	var conds: Array = []
	conds.append(cond(" 该 国 持 亲 中 立 场", func(): return country.has_tag("亲中")))
	var eff := func():
		if not country.has_tag("对华贸易"):
			country.set_tag("对华贸易", true)
		else:
			country.set_tag("对华贸易", false)
	return make_def(caption, opis, conds, eff)

# ============================================================================
# 编号 67 · 促成该国加入阿拉伯联合共和国（67号变体）
# DBS Show L733-777 / OnMouseDown L9034-9038
# ============================================================================
func _def_67(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var c30 := c(w, 30)
	var opis := " 促 成 该 国 加 入 阿 拉 伯 联 合 共 和 国 ，实 现 阿 拉 伯 世 界 的 政 治 统 一"
	var conds: Array = []
	conds.append(cond(" 阿 拉 伯 联 合 共 和 国 已 经 成 立", func(): return w.oar))
	if c30 != null and c30.government == GameConstants.Government.SOCIALIST:
		conds.append(cond(" 该 国 未 加 入 阿 拉 伯 联 合 共 和 国", func(): return not country.has_tag("oar")))
	else:
		conds.append(cond(" 该 国 未 加 入 阿 拉 伯 联 合 共 和 国\n 且 未 参 与 军 事 联 盟", func(): return not country.has_tag("oar") and not country.has_tag("nato") and not country.has_tag("okb") and not country.has_tag("ovd")))
	if c30 != null and c30.government == GameConstants.Government.SOCIALIST:
		if country.原版序号 == 13:
			conds.append(cond(" 卡 扎 菲 已 被 推 翻 并 建 成 社 会 主 义 政 权", func(): return c(w, 13) != null and gov(c(w, 13)) == 1))
		else:
			conds.append(cond(" 该 国 为 社 会 主 义", func(): return soc(w, country, true)))
	else:
		if country.原版序号 == 13:
			conds.append(cond("利 比 亚 与 乍 得 未 合 并", func(): return c(w, 13) != null and not parts(c(w, 13), 1)))
		else:
			conds.append(cond(" 该 国 为 改 良 主 义 或 左 翼 民 族 主 义", func(): return gov(country) == 2 or sub(country) == 10))
	var eff := func():
		country.set_tag("oar", true)
		w.influence_prc += 10
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 68 · 接纳加入经济互助委员会
# DBS Show L697-710 / OnMouseDown L9007-9021
# ============================================================================
func _def_68(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var player := c(w, 1)
	var opis := " 接 纳 加 入 经 济 互 助 委 员 会 ，联 合 力 量 ，促 进 发 展"
	var conds: Array = []
	conds.append(cond(" 国 家 状 态 没 有 内 战", func(): return not war(w, 5)))
	conds.append(cond(" 阿 富 汗 持 亲 中 或 亲 苏 立 场\n 中 国 已 加 入 经 互 会", func(): return country.has_tag("亲中") or (player != null and player.has_tag("sev") and country.has_tag("亲苏"))))
	conds.append(cond(" 已 深 化 经 贸 关 系", func(): return country.has_tag("对华贸易") and player != null and (player.has_tag("econ") or player.has_tag("sev"))))
	conds.append(cond(" 该 国 未 加 入 经 合 组 织", func(): return not country.has_tag("econ") and not country.has_tag("sev") and not country.has_tag("asean")))
	var eff := func():
		if player != null and player.has_tag("sev"):
			add_power(w, 1, 20)
			w.influence_prc += 10
			country.set_tag("sev", true)
		else:
			w.influence_prc += 20
			country.set_tag("econ", true)
			country.social_stability = 1000
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 70 · 按目标国分支的社会主义理论传授
# DBS Show L2032-2168 / OnMouseDown L10789-10890
# ============================================================================
func _def_70(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var sid := country.原版序号
	var opis := ""
	var conds: Array = []
	if sid == 41:
		opis = " 稍 稍 帮 助 马 里 亚 姆 完 成 自 己 的 伟 大 理 想"
		conds.append(cond(" 至 少 10 百 万 预 算 与 10 特 勤", func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100))
		conds.append(cond(" 我 们 已 经 应 用 了 先 进 的 社 会 主 义 理 论", func(): return c(w, 1) != null and sub(c(w, 1)) == 19))
		conds.append(cond(" 埃 塞 俄 比 亚 尚 未 被 邀 请 去 参 加 “ 世 界 野 餐 ”", func(): return not ev(w, 590)))
	elif sid == 65:
		opis = " 邀 请 博 卡 萨 同 志 来 精 进 革 命 理 论 "
		conds.append(cond(" 至 少 10 百 万 预 算 与 10 特 勤", func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100))
		conds.append(cond(" 我 们 已 经 应 用 了 先 进 的 社 会 主 义 理 论", func(): return c(w, 1) != null and sub(c(w, 1)) == 19))
		conds.append(cond(" 尚 未 对 中 非 传 授 经 验", func(): return not ev(w, 644)))
	elif sid == 117:
		opis = " 为 扎 伊 尔 共 和 国 送 上 我 们 的 百 亿 补 贴 ， 给 他 们 带 来 真 正 的 社 会 主 义"
		conds.append(cond(" 至 少 10 百 万 预 算 与 10 特 勤", func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100))
		conds.append(cond(" 我 们 已 经 应 用 了 先 进 的 社 会 主 义 理 论", func(): return c(w, 1) != null and sub(c(w, 1)) == 19))
		conds.append(cond(" 尚 未 教 授 他 们 方 法", func(): return c(w, 117) != null and sub(c(w, 117)) != 19))
	elif sid == 127:
		opis = " 让 我 们 教 教 津 巴 布 韦 的 同 志 们 怎 么 建 设 社 会 主 义"
		conds.append(cond(" 至 少 10 百 万 预 算 与 10 特 勤", func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100))
		conds.append(cond(" 我 们 已 经 应 用 了 先 进 的 社 会 主 义 理 论", func(): return c(w, 1) != null and sub(c(w, 1)) == 19))
		conds.append(cond(" 尚 未 教 授 他 们 方 法", func(): return not ev(w, 883)))
	elif sid == 115:
		opis = " 让 我 们 为 赤 道 几 内 亚 的 同 志 们 引 入 真 正 的 社 会 主 义"
		conds.append(cond(" 至 少 10 百 万 预 算 与 10 特 勤", func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100))
		conds.append(cond(" 我 们 已 经 应 用 了 先 进 的 社 会 主 义 理 论", func(): return c(w, 1) != null and sub(c(w, 1)) == 19))
		conds.append(cond(" 尚 未 教 授 他 们 方 法", func(): return not ev(w, 622)))
	elif sid == 139:
		var c139 := c(w, 139)
		if c139 != null and c139.sub_government != GameConstants.SubGovernment.FEUDAL_SOCIALIST:
			opis = " 小 杜 瓦 利 埃 将 学 习 前 人 的 先 进 经 验 ， 在 海 地 建 成 反 抗 资 本 主 义 旧 制 度 和 苏 联 邪 恶 帝 国 的 桥 头 堡"
			conds.append(cond(" 至 少 35 百 万 预 算 与 20 军 力", func(): return d(w, 8) + d(w, 36) >= 350 and d(w, 22) >= 200))
			conds.append(cond(" 法 国 与 中 非 已 经 应 用 了 先 进 的 社 会 主 义 理 论", func(): return c(w, 21) != null and sub(c(w, 21)) == 19 and c(w, 65) != null and sub(c(w, 65)) == 19))
			conds.append(cond(" 大 西 洋 秩 序 不 复 存 在", func(): return c(w, 51) != null and not c(w, 51).has_tag("nato")))
		else:
			opis = " 以 海 地 为 核 心 ， 我 们 将 促 使 美 国 的 黑 人 民 权 运 动 回 到 六 十 年 代 … …"
			conds.append(cond(" 至 少 5 百 万 预 算 ， 5 特 工 ， 5 军 力", func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50 and d(w, 22) >= 50))
			conds.append(cond(" 海 地 已 经 应 用 了 先 进 的 社 会 主 义 理 论", func(): return c(w, 139) != null and sub(c(w, 139)) == 19))
			conds.append(cond(" 三 月 一 次", func(): return c(w, 139) != null and not c(w, 139).有驻军基地))
	elif sid == 131:
		opis = " 既 然 阿 扎 尼 亚 已 经 加 入 了 我 们 行 务 之 中 ， 那 么 有 必 要 让 依 附 于 阿 扎 尼 亚 的 小 国 家 与 我 们 的 步 调 更 加 一 致"
		conds.append(cond(" 至 少 5 特 勤 与 3 军 力", func(): return d(w, 9) >= 50 and d(w, 22) >= 30))
		conds.append(cond(" 尚 未 行 动", func(): return c(w, 131) != null and not parts(c(w, 131), 5)))
	elif sid == 108:
		var num := 0
		for ck in w.countries:
			if ck == null:
				continue
			var i := ck.原版序号
			if (i == 56 or (i >= 58 and i <= 64) or i == 67 or i == 68 or i == 107 or i == 108 or (i >= 112 and i <= 114)) and pup(ck) == 21:
				num += 1
		opis = " 以 非 洲 的 盟 邦 为 榜 样 ， 鼓 励 纳 辛 贝 · 埃 亚 德 马 发 动 一 场 “ 自 我 革 命 ”"
		conds.append(cond(" 扎 伊 尔 为 封 建 社 会 主 义", func(): return c(w, 117) != null and sub(c(w, 117)) == 19))
		conds.append(cond(" 法 国 总 统 不 是 雅 克 · 希 拉 克 ， 且 法 国 影 响 下 的 西 非 国 家 少 于8 个", func(): return not mod(w, 45) and num < 8))
		conds.append(cond(" 晚 于1983 年", func(): return d(w, 21) > 1983))
		conds.append(cond(" 5 百 万 预 算 ， 5 特 勤", func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	elif sid == 14:
		opis = " 邀 请 我 们 在 阿 拉 伯 世 界 的 盟 友 — — 萨 达 姆 同 志 学 习 我 方 先 进 经 验 。"
		conds.append(cond(" 我 们 已 经 应 用 了 先 进 的 社 会 主 义 理 论", func(): return c(w, 1) != null and sub(c(w, 1)) == 19))
		conds.append(cond(" 萨 达 姆 是 我 们 的 忠 实 战 友", func(): return c(w, 14) != null and c(w, 14).has_tag("亲中")))
		conds.append(cond(" 胡 齐 斯 坦 与 科 威 特 属 于 伊 拉 克", func(): return c(w, 14) != null and parts(c(w, 14), 6)))
		conds.append(cond(" 10 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 100))
	elif sid == 123:
		opis = " 奥 尔 登 · 罗 贝 托 将 加 冕 为 罗 贝 托 一 世 ， 让 安 哥 拉 走 上 彻 底 独 立 的 道 路 。"
		conds.append(cond(" 我 们 已 经 应 用 了 先 进 的 社 会 主 义 理 论", func(): return c(w, 1) != null and sub(c(w, 1)) == 19))
		conds.append(cond(" 10 百 万 预 算 ， 10 军 力", func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 22) >= 100))
		conds.append(cond(" 尚 未 加 冕", func(): return c(w, 123) != null and sub(c(w, 123)) != 19))
	else:
		return {}
	var eff := func():
		if sid == 41:
			# 原版 number_event=590 → 本项目 event_id 为 event_590
			start_event_num(w, 590)
		elif sid == 65:
			# 原版 number_event=644 → 本项目 event_id 为 event_644
			start_event_num(w, 644)
		elif sid == 127:
			# 原版 number_event=883 → 本项目 event_id 为 event_883
			start_event_num(w, 883)
		elif sid == 115:
			# 原版 number_event=622 → 本项目 event_id 为 event_622
			start_event_num(w, 622)
		elif sid == 117:
			set_d(w, 8, d(w, 8) - 100)
			set_d(w, 9, d(w, 9) - 100)
			var c117 := c(w, 117)
			if c117 != null:
				c117.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
		elif sid == 139:
			var c139 := c(w, 139)
			if c139 != null and c139.sub_government != GameConstants.SubGovernment.FEUDAL_SOCIALIST:
				set_d(w, 8, d(w, 8) - 350)
				set_d(w, 22, d(w, 22) - 200)
				if GameManager != null:
					GameManager.set_speed(0)
				start_event_num(w, 705)
			else:
				set_d(w, 8, d(w, 8) - 50)
				set_d(w, 9, d(w, 9) - 50)
				set_d(w, 22, d(w, 22) - 50)
				add_power(w, 0, -50)
				add_rel(w, 0, -100)
				if c139 != null:
					c139.有驻军基地 = true
		elif sid == 131:
			set_d(w, 9, d(w, 9) - 50)
			set_d(w, 22, d(w, 22) - 30)
			for idx in [132, 130, 129, 153]:
				var cc := c(w, idx)
				if cc != null:
					cc.leave_alliances()
					cc.government = GameConstants.Government.AUTHORITARIAN
					cc.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
					cc.set_tag("亲中", true)
					cc.set_tag("对华贸易", true)
			var c131 := c(w, 131)
			if c131 != null:
				set_parts(c131, 5, true)
		elif sid == 108:
			set_d(w, 8, d(w, 8) - 50)
			set_d(w, 9, d(w, 9) - 50)
			if GameManager != null:
				GameManager.set_speed(0)
			start_event_num(w, 706)
		elif sid == 14:
			for ck in w.countries:
				if ck != null and (ck.原版序号 == GameConstants.LegacySlot.IRAQ or pup(ck) == 14):
					ck.government = GameConstants.Government.AUTHORITARIAN
					ck.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
			set_d(w, 186, 6)
			set_d(w, 8, d(w, 8) - 100)
		elif sid == 123:
			set_d(w, 8, d(w, 8) - 100)
			set_d(w, 22, d(w, 22) - 100)
			var c123 := c(w, 123)
			if c123 != null:
				c123.government = GameConstants.Government.AUTHORITARIAN
				c123.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
				c123.name = " 安 哥 拉 人 民 联 合 王 国"
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 71 · 派遣解放军增援前线（中印战争）
# DBS Show L1194-1212 / OnMouseDown L9317-9322
# ============================================================================
func _def_71(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := ""
	if country.原版序号 == 11:
		@warning_ignore("integer_division")
		opis = " 派 遣 解 放 军 增 援 前 线| 我 方 军 力 强 度 ：" + str(d(w, 39) / 10) + "." + str(absi(d(w, 39) % 10))
	elif country.原版序号 == 19:
		@warning_ignore("integer_division")
		opis = " 派 遣 解 放 军 增 援 前 线| 我 方 军 力 强 度 ：" + str(d(w, 40) / 10) + "." + str(absi(d(w, 40) % 10))
	else:
		return {}
	var conds: Array = []
	conds.append(cond(" 与 印 度 爆 发 战 争", func(): return w.war_state == GameConstants.WarState.INDIA))
	conds.append(cond(" 至 少 7 军 事 实 力", func(): return d(w, 22) >= 70))
	conds.append(cond(" 本 月 增 兵 未 达 三 次", func(): return country.prc_power != 3))
	var eff := func():
		set_d(w, 40, d(w, 40) + 100)
		set_d(w, 22, d(w, 22) - 50)
		country.prc_power += 1
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 72 · 加入不结盟运动
# DBS Show L1106-1119 / OnMouseDown L9170-9176
# ============================================================================
func _def_72(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var player := c(w, 1)
	var c15 := c(w, 15)
	var opis := " 加 入 不 结 盟 运 动"
	var conds: Array = []
	conds.append(cond(" 我 们 未 参 与 任 何 军 事 联 盟", func(): return player != null and not player.has_tag("ovd") and not player.has_tag("okb") and not player.has_tag("seato")))
	conds.append(cond(" 至 少 2 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 20))
	conds.append(cond(" 未 加 入 不 结 盟 运 动", func(): return c15 != null and not c15.内战中))
	conds.append(cond(" 我 们 没 有 战 争", func(): return w.war_state <= GameConstants.WarState.PEACE))
	var eff := func():
		set_d(w, 1, d(w, 1) - 300)
		set_d(w, 8, d(w, 8) - 20)
		w.influence_prc -= 20
		country.内战中 = true
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 73 · 退出不结盟运动
# DBS Show L1120-1131 / OnMouseDown L9177-9198
# ============================================================================
func _def_73(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var c15 := c(w, 15)
	var opis := " 退 出 不 结 盟 运 动"
	var conds: Array = []
	conds.append(cond(" 党 内 团 结 度 至 少 75", func(): return d(w, 1) > 750))
	conds.append(cond(" 至 少 5 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 50))
	conds.append(cond(" 已 加 入 不 结 盟 运 动", func(): return c15 != null and c15.内战中))
	var eff := func():
		set_d(w, 1, d(w, 1) - 300)
		set_d(w, 8, d(w, 8) - 50)
		if d(w, 6) >= 600:
			add_rel(w, 0, -300)
		else:
			add_rel(w, 1, -300)
		if d(w, 6) >= 500:
			set_d(w, 6, d(w, 6) + 200)
		else:
			set_d(w, 6, d(w, 6) - 200)
		country.内战中 = false
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 74 · 成为经济互助委员会的观察员国
# DBS Show L170-181 / OnMouseDown L8738-8743
# ============================================================================
func _def_74(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var c51 := c(w, 51)
	var opis := " 成 为 经 济 互 助 委 员 会 的 观 察 员 国"
	var conds: Array = []
	conds.append(cond(" 中 苏 关 系 正 常 化", func(): return fl(w, "relres")))
	conds.append(cond(" 没 有 同 美 国 维 持 友 好 关 系", func(): return c51 != null and not c51.has_tag("对华贸易")))
	conds.append(cond(" 外 交 声 誉 高 于 60", func(): return d(w, 6) > 600))
	var eff := func():
		country.set_tag("对华贸易", true)
		add_rel(w, 0, -50)
		add_rel(w, 1, 50)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 75 · 向美国人分享科技
# DBS Show L958-969 / OnMouseDown L9136-9143
# ============================================================================
func _def_75(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 向 美 国 人 分 享 科 技"
	var conds: Array = []
	conds.append(cond(" 至 少 10 科 研 点", func(): return d(w, 11) >= 100))
	conds.append(cond(" 极 左 派 不 占 主 导 地 位", func(): return d(w, 56) != 0))
	conds.append(cond(" 美 国 的 世 界 影 响 力 低 于 60", func(): return power(w, 0) < 600))
	var eff := func():
		set_d(w, 11, d(w, 11) - 100)
		set_d(w, 1, d(w, 1) - 50)
		set_d(w, 8, d(w, 8) + 4)
		add_power(w, 0, 2)
		add_rel(w, 1, -10)
	return make_def(caption, opis, conds, eff)
# ============================================================================
# Python 自检结果（由移植工程师静态检查脚本写入，未运行 Godot）
# 文件 UTF-8 可读: 通过
# 总行数: 1353（不含本自检块）
# 行首空格: 0 处，通过
# 编号定义 _def_N: 34 个，缺失: 无
# build_action 分支: 34 个，缺失: 无
# 括号平衡: 小括号 1639/1639 OK；方括号 50/50 OK；花括号 42/42 OK
# 裸 W 引用: 0 处，通过
# cond 调用: 204 处；func 单行 lambda 238 处
# 状态行: 0 处
# ============================================================================
