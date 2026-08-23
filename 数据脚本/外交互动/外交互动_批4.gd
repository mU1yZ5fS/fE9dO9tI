## 外交互动 批4 — 编号 1017-1050（共 34 个编号）。
## 源码出处：DiploButtonScript.cs
##   Show（中文分支，start < 5625）L3847-L4891；OnMouseDown L11496-L12196。
## 翻译规范：工作记录/外交互动对齐规范.md。
## 本批编号：1017,1018,1019,1020,1021,1022,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1040,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050
extends "res://数据脚本/外交互动/外交互动_基础.gd"


## 主分发：返回 {caption, opis, conditions, effect, dormant} 或 {}。
func build_action(action_type: int, ctx: Dictionary) -> Dictionary:
	var w: WorldState = ctx.get("w")
	var country: CountryData = ctx.get("country")
	var caption: String = ctx.get("caption", "")
	if w == null or country == null:
		return {}
	match action_type:
		1017:
			return _def_1017(w, country, caption)
		1018:
			return _def_1018(w, country, caption)
		1019:
			return _def_1019(w, country, caption)
		1020:
			return _def_1020(w, country, caption)
		1021:
			return _def_1021(w, country, caption)
		1022:
			return _def_1022(w, country, caption)
		1023:
			return _def_1023(w, country, caption)
		1024:
			return _def_1024(w, country, caption)
		1025:
			return _def_1025(w, country, caption)
		1026:
			return _def_1026(w, country, caption)
		1027:
			return _def_1027(w, country, caption)
		1028:
			return _def_1028(w, country, caption)
		1029:
			return _def_1029(w, country, caption)
		1030:
			return _def_1030(w, country, caption)
		1031:
			return _def_1031(w, country, caption)
		1032:
			return _def_1032(w, country, caption)
		1033:
			return _def_1033(w, country, caption)
		1034:
			return _def_1034(w, country, caption)
		1035:
			return _def_1035(w, country, caption)
		1036:
			return _def_1036(w, country, caption)
		1037:
			return _def_1037(w, country, caption)
		1038:
			return _def_1038(w, country, caption)
		1039:
			return _def_1039(w, country, caption)
		1040:
			return _def_1040(w, country, caption)
		1041:
			return _def_1041(w, country, caption)
		1042:
			return _def_1042(w, country, caption)
		1043:
			return _def_1043(w, country, caption)
		1044:
			return _def_1044(w, country, caption)
		1045:
			return _def_1045(w, country, caption)
		1046:
			return _def_1046(w, country, caption)
		1047:
			return _def_1047(w, country, caption)
		1048:
			return _def_1048(w, country, caption)
		1049:
			return _def_1049(w, country, caption)
		1050:
			return _def_1050(w, country, caption)
	return {}


# ============================================================================
# 编号 1017 · 支持意大利强硬派共产主义者的政治议程
# DBS Show L3847-3853 / OnMouseDown L11496-11502
# ============================================================================
func _def_1017(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 支 持 意 大 利 强 硬 派 共 产 主 义 者 的 政 治 议 程 " + String.chr(10) + " 激 进 左 翼 力 量 ： %d" % d(w, 134)
	var conds: Array = []
	conds.append(cond(" 预 算 不 少 于 4百万 ，特 工 网 络 不 少 于 2 ，军 事 力 量 不 少 于 2",
		func(): return d(w, 8) + d(w, 36) >= 40 and d(w, 9) >= 20 and d(w, 22) >= 20))
	var eff := func():
		_add_d(w, 9, -20)
		_add_d(w, 8, -40)
		_add_d(w, 22, -20)
		_add_d(w, 134, 10)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1018 · 为意大利民主制度“上火药味”
# DBS Show L3854-3864 / OnMouseDown L11503-11514
# ============================================================================
func _def_1018(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c85 := c(w, 85)
	var opis := " 为 意 大 利 民 主 制 度 “ 上 火 药 味 ”  " + String.chr(10) + " 意 大 利 政 权 稳 定 度 ： %d %%" % _lvl_dev(w, 85)
	var conds: Array = []
	conds.append(cond(" 已 支 持 激 进 分 子",
		func(): return c85 != null and (c85.内战中 or c85.政变中)))
	conds.append(cond(" 预 算 不 少 于 2百万 ，特 工 网 络 不 少 于 3 ，军 事 力 量 不 少 于 3",
		func(): return d(w, 8) + d(w, 36) >= 20 and d(w, 9) >= 30 and d(w, 22) >= 30))
	conds.append(cond(" 半 年 一 次",
		func(): return c85 != null and not c85.有驻军基地))
	var eff := func():
		if c85 == null:
			return
		_add_d(w, 9, -30)
		_add_d(w, 22, -30)
		_add_d(w, 8, -20)
		c85.level_of_development -= 15
		if mod(w, 53):
			c85.level_of_development -= 5
		c85.有驻军基地 = true
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1019 · 联络阿尔及利亚的反对派
# DBS Show L3865-3873 / OnMouseDown L11515-11520
# ============================================================================
func _def_1019(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c40 := c(w, 40)
	var opis := " 联 络 阿 尔 及 利 亚 的 反 对 派"
	var conds: Array = []
	conds.append(cond(" 尚 未 联 络",
		func(): return c40 != null and not c40.内战中))
	conds.append(cond(" 预 算 不 少 于 5百万 ，特 工 网 络 不 少 于 5",
		func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	var eff := func():
		if c40 == null:
			return
		c40.内战中 = true
		_add_d(w, 8, -50)
		_add_d(w, 9, -50)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1020 · 煽动阿尔及利亚的反对派，试图颠覆现有政府
# DBS Show L3874-3886 / OnMouseDown L11521-11529
# ============================================================================
func _def_1020(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 煽 动 阿 尔 及 利 亚 的 反 对 派 ， 试 图 颠 覆 现 有 政 府"
	var conds: Array = []
	conds.append(cond(" 利 比 亚 已 建 成 亲 中 政 权",
		func(): return _has(w, 13, "亲中")))
	conds.append(cond(" 预 算 不 少 于 15百万 ，特 工 网 络 不 少 于 15 ， 军 力 不 少 于15",
		func(): return d(w, 8) + d(w, 36) >= 150 and d(w, 9) >= 150 and d(w, 22) >= 150))
	conds.append(cond(" 不 早 于 1984年",
		func(): return d(w, 21) >= 1984))
	conds.append(cond(" 尚 未 煽 动",
		func(): return not ev(w, 563)))
	var eff := func():
		_add_d(w, 8, -150)
		_add_d(w, 9, -150)
		_add_d(w, 22, -150)
		start_event_num(w, 563)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1021 · 协助阿湾人阵进行重建工作（也门 24/25）
# DBS Show L3887-3936 / OnMouseDown L11530-11535
# ============================================================================
func _def_1021(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var sid := country.原版序号
	if sid == 24:
		var c24 := c(w, 24)
		var c25 := c(w, 25)
		var c30 := c(w, 30)
		var c1 := c(w, 1)
		if c24 != null and c24.has_tag("亲中") and c24.government == GameConstants.Government.SOCIALIST:
			var opis_a := " 协 助 阿 湾 人 阵 进 行 重 建 工 作"
			var conds_a: Array = []
			conds_a.append(cond(" 也 门 已 统 一", func(): return parts(c24, 0)))
			conds_a.append(cond(" 也 门 为 亲 中 红 色 政 权 且 阿 拉 伯 革 命 同 盟 已 建 成",
				func(): return c24.government == GameConstants.Government.SOCIALIST and c24.has_tag("亲中") and c30 != null and c30.government == GameConstants.Government.SOCIALIST and w.oar))
			conds_a.append(cond(" 预 算 不 少 于 10百 万 ，特 工 网 络 不 少 于 10 ， 军 力 不 少 于10",
				func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100 and d(w, 22) >= 100))
			conds_a.append(cond(" 尚 未 重 建", func(): return not ev(w, 567)))
			var eff_a := func():
				start_event_num(w, 567)
			return make_def(caption, opis_a, conds_a, eff_a)
		if c24 != null and c24.government == GameConstants.Government.REFORMIST:
			var opis_b := " 协 助 阿 湾 人 阵 进 行 重 建 工 作"
			var conds_b: Array = []
			conds_b.append(cond(" 也 门 已 统 一", func(): return parts(c25, 0)))
			conds_b.append(cond(" 也 门 为 亲 中 改 良 主 义 且 埃 及 为 纳 赛 尔 主 义 者",
				func(): return c25 != null and c25.government == GameConstants.Government.REFORMIST and c25.has_tag("亲中") and c30 != null and c30.government == GameConstants.Government.REFORMIST))
			conds_b.append(cond(" 预 算 不 少 于 10百 万 ，特 工 网 络 不 少 于 10 ， 军 力 不 少 于10",
				func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100 and d(w, 22) >= 100))
			conds_b.append(cond(" 尚 未 重 建", func(): return not ev(w, 567)))
			var eff_b := func():
				start_event_num(w, 567)
			return make_def(caption, opis_b, conds_b, eff_b)
		var opis := " 协 助 阿 湾 人 阵 进 行 重 建 工 作"
		var conds: Array = []
		conds.append(cond(" 也 门 已 统 一", func(): return parts(c24, 0)))
		conds.append(cond(" 也 门 为 亲 苏 红 色 政 权 且 中 国 在 华 约",
			func(): return c24 != null and c24.government == GameConstants.Government.SOCIALIST and c24.has_tag("亲苏") and c1 != null and c1.has_tag("ovd")))
		conds.append(cond(" 预 算 不 少 于 10百 万 ，特 工 网 络 不 少 于 10 ， 军 力 不 少 于10",
			func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100 and d(w, 22) >= 100))
		conds.append(cond(" 尚 未 重 建", func(): return not ev(w, 567)))
		var eff := func():
			start_event_num(w, 567)
		return make_def(caption, opis, conds, eff)
	if sid == 25:
		var c25 := c(w, 25)
		var c30 := c(w, 30)
		var opis := " 协 助 阿 湾 人 阵 进 行 重 建 工 作"
		var conds: Array = []
		conds.append(cond(" 也 门 已 统 一", func(): return parts(c25, 0)))
		conds.append(cond(" 也 门 为 亲 中 改 良 主 义 且 埃 及 为 纳 赛 尔 主 义 者",
			func(): return c25 != null and c25.government == GameConstants.Government.REFORMIST and c25.has_tag("亲中") and c30 != null and c30.government == GameConstants.Government.REFORMIST))
		conds.append(cond(" 预 算 不 少 于 10百 万 ，特 工 网 络 不 少 于 10 ， 军 力 不 少 于10",
			func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100 and d(w, 22) >= 100))
		conds.append(cond(" 尚 未 重 建", func(): return not ev(w, 567)))
		var eff := func():
			start_event_num(w, 567)
		return make_def(caption, opis, conds, eff)
	return {}


# ============================================================================
# 编号 1022 · 支持阿拉伯湾国家的阿湾人阵 / 推动革命推翻君主统治
# DBS Show L3937-3965 / OnMouseDown L11536-11555
# ============================================================================
func _def_1022(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c24 := c(w, 24)
	if c24 != null and c24.prc_power < 100:
		var opis_a := " 支 持 阿 拉 伯 湾 国 家 的 阿 湾 人 阵|阿 湾 人 阵 力 量 ：%d" % c24.prc_power
		var conds_a: Array = []
		conds_a.append(cond(" 已 协 助 重 建 阿 湾 人 阵", func(): return ev(w, 567)))
		conds_a.append(cond(" 阿 湾 人 阵 力 量 小 于100", func(): return c24.prc_power < 100))
		conds_a.append(cond(" 预 算 不 少 于 3百 万 ，特 工 网 络 不 少 于 3 ， 军 力 不 少 于3",
			func(): return d(w, 8) + d(w, 36) >= 30 and d(w, 9) >= 30 and d(w, 22) >= 30))
		conds_a.append(cond(" 三 月 一 次", func(): return c24.stab == 0))
		var eff_a := func():
			c24.prc_power += 10
			_add_d(w, 8, -30)
			_add_d(w, 9, -30)
			_add_d(w, 22, -30)
			c24.stab = 1
		return make_def(caption, opis_a, conds_a, eff_a)
	var c8 := c(w, 8)
	var opis := " 推 动 阿 拉 伯 湾 国 家 的 阿 湾 人 阵 发 起 革 命 推 翻 君 主 统 治"
	var conds: Array = []
	conds.append(cond(" 阿 湾 人 阵 力 量 不 低 于100", func(): return c24 != null and c24.prc_power >= 100))
	conds.append(cond(" 伊 朗 为 亲 中 绿 色 或 红 色 政 权",
		func(): return c8 != null and (c8.government == GameConstants.Government.SOCIALIST or c8.government == GameConstants.Government.REFORMIST or c8.sub_government == GameConstants.SubGovernment.LEFT_RADICAL)))
	conds.append(cond(" 预 算 不 少 于 15百 万 ，特 工 网 络 不 少 于 15 ， 军 力 不 少 于15",
		func(): return d(w, 8) + d(w, 36) >= 150 and d(w, 9) >= 150 and d(w, 22) >= 150))
	conds.append(cond(" 尚 未 推 动 革 命", func(): return not ev(w, 568)))
	var eff := func():
		_add_d(w, 8, -150)
		_add_d(w, 9, -150)
		_add_d(w, 22, -150)
		start_event_num(w, 568)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1023 · 发起一场把阿拉伯半岛上最后的王爷送入坟墓的革命
# DBS Show L3966-3978 / OnMouseDown L11556-11561
# ============================================================================
func _def_1023(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 发 起 一 场 把 阿 拉 伯 半 岛 上 最 后 的 王 爷 送 入 坟 墓 的 革 命"
	var conds: Array = []
	conds.append(cond(" 美 国 已 衰 落", func(): return ev(w, 421)))
	conds.append(cond(" 阿 拉 伯 湾 和 约 旦 的 革 命 都 已 胜 利",
		func(): return not auth(w, c(w, 102)) and not auth(w, c(w, 104))))
	conds.append(cond(" 外 交 声 誉 高 于 79", func(): return d(w, 6) > 790))
	conds.append(cond(" 尚 未 策 动 革 命", func(): return not ev(w, 569)))
	var eff := func():
		start_event_num(w, 569)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1024 · 督促社会改革 / 支持各国左翼（澳大利亚、新西兰、尼日尔、塞内加尔、喀麦隆、加蓬）
# DBS Show L3979-4066 / OnMouseDown L11562-11650
# ============================================================================
func _def_1024(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var sid := country.原版序号
	if sid == 134:
		var c135 := c(w, 135)
		var c134 := c(w, 134)
		var opis := " 督 促 社 会 改 革"
		var conds: Array = []
		conds.append(cond(" 澳 大 利 亚 已 倒 向 社 会 主 义 阵 容",
			func(): return (c135 != null and c135.has_tag("亲中") and soc(w, c(w, 1), true)) or (c135 != null and c135.has_tag("亲苏"))))
		conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5",
			func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
		conds.append(cond(" 尚 未 督 促", func(): return c134 != null and not c134.内战中))
		var eff := func():
			if c134 == null:
				return
			c134.内战中 = true
			c134.government = GameConstants.Government.REFORMIST
			c134.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			c134.puppet_of = GameConstants.LegacySlot.NONE
			c134.leave_alliances()
			c134.set_tag("亲中", true)
			c134.set_tag("对华贸易", true)
			_add_d(w, 8, -50)
			_add_d(w, 9, -50)
		return make_def(caption, opis, conds, eff)
	if sid == 136:
		var c1 := c(w, 1)
		var c136 := c(w, 136)
		var c21 := c(w, 21)
		var opis: String
		if soc(w, c1, true):
			opis = " 支 持 工 党 左 派 和 共 产 主 义 者 联 合 政 府 上 台"
		elif c1 != null and c1.government == GameConstants.Government.REFORMIST:
			opis = " 支 持 工 党 进 行 社 会 改 革"
		elif auth(w, c1):
			opis = " 支 持 社 会 信 用 党 上 台"
		else:
			opis = " 支 持 新 西 兰 党 上 台"
		var conds: Array = []
		conds.append(cond(" 美 国 已 衰 落", func(): return ev(w, 421)))
		conds.append(cond(" 预 算 不 少 于 20百 万 ，特 工 网 络 不 少 于 20",
			func(): return d(w, 8) + d(w, 36) >= 200 and d(w, 9) >= 200))
		conds.append(cond(" 尚 未 支 持", func(): return c136 != null and not c136.内战中))
		var eff := func():
			if c136 == null:
				return
			c136.内战中 = true
			_add_d(w, 8, -200)
			_add_d(w, 9, -200)
			if soc(w, c(w, 1), true):
				c136.government = GameConstants.Government.SOCIALIST
				c136.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				c136.puppet_of = GameConstants.LegacySlot.NONE
				c136.leave_alliances()
				c136.set_tag("亲中", true)
				c136.set_tag("对华贸易", true)
				c136.name = "奥 特 亚 罗 瓦 人 民 共 和 国"
			elif c1 != null and c1.government == GameConstants.Government.REFORMIST:
				c136.government = GameConstants.Government.REFORMIST
				c136.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				c136.puppet_of = GameConstants.LegacySlot.NONE
				c136.leave_alliances()
				c136.set_tag("亲中", true)
				c136.set_tag("对华贸易", true)
				if c21 != null and c21.has_tag("soc_eu"):
					c136.set_tag("soc_eu", true)
			elif auth(w, c1):
				c136.government = GameConstants.Government.REFORMIST
				c136.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
				c136.puppet_of = GameConstants.LegacySlot.NONE
				c136.leave_alliances()
				c136.set_tag("亲中", true)
				c136.set_tag("对华贸易", true)
			else:
				c136.government = GameConstants.Government.LIBERAL
				c136.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				c136.puppet_of = GameConstants.LegacySlot.NONE
				c136.leave_alliances()
				c136.set_tag("亲中", true)
				c136.set_tag("对华贸易", true)
		return make_def(caption, opis, conds, eff)
	if sid == 56:
		var c56 := c(w, 56)
		var opis := " 开 始 复 苏 萨 瓦 巴 党 在 该 国 内 的 行 动 ， 并 提 供 理 论 指 导"
		var conds: Array = []
		conds.append(cond(" 我 们 始 终 坚 持 战 无 不 胜 的 毛 泽 东 思 想 ！", func(): return mod(w, 6)))
		conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5",
			func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
		conds.append(cond(" 尚 未 支 持", func(): return c56 != null and not c56.内战中))
		var eff := func():
			if c56 == null:
				return
			c56.内战中 = true
			_add_d(w, 8, -50)
			_add_d(w, 9, -50)
		return make_def(caption, opis, conds, eff)
	if sid == 112:
		var c112 := c(w, 112)
		var opis := " 支 持 塞 共 / 马 列 ， 力 量 ：" + _ctrl(w, 112)
		var conds: Array = []
		conds.append(cond(" 我 们 始 终 坚 持 战 无 不 胜 的 毛 泽 东 思 想 ！", func(): return mod(w, 6)))
		conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5",
			func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
		conds.append(cond(" 三 月 一 次", func(): return c112 != null and not c112.内战中))
		var eff := func():
			if c112 == null:
				return
			c112.内战中 = true
			_add_d(w, 8, -50)
			_add_d(w, 9, -50)
			c112.level_of_instability += 100
		return make_def(caption, opis, conds, eff)
	if sid == 66:
		var c66 := c(w, 66)
		var opis := "  为 喀 人 盟 和 喀 麦 隆 民 族 解 放 军 提 供 支 持| 力 量 ：%d" % _lvl_inst(w, 66)
		var conds: Array = []
		conds.append(cond(" 喀 麦 隆 至 少 一 个 邻 国 为 亲 中 社 会 主 义 政 权",
			func():
				return ((soc(w, c(w, 60), true) and _has(w, 60, "亲中"))
					or (soc(w, c(w, 57), true) and _has(w, 57, "亲中"))
					or (soc(w, c(w, 65), true) and _has(w, 65, "亲中"))
					or (soc(w, c(w, 52), true) and _has(w, 52, "亲中"))
					or (soc(w, c(w, 115), true) and _has(w, 115, "亲中"))
					or (soc(w, c(w, 116), true) and _has(w, 116, "亲中")))))
		conds.append(cond(" 至 少 2 百 万 预 算 ， 2 特 工 ， 4 军 力",
			func(): return d(w, 22) >= 100 and d(w, 9) >= 50))
		conds.append(cond(" 一 年 两 次", func(): return c66 != null and not c66.内战中))
		conds.append(cond(" 力 量 小 于 1 0 0", func(): return c66 != null and c66.level_of_instability < 100))
		var eff := func():
			if c66 == null:
				return
			c66.level_of_instability += 10
			c66.内战中 = true
			_add_d(w, 8, -20)
			_add_d(w, 9, -20)
			_add_d(w, 22, -40)
		return make_def(caption, opis, conds, eff)
	if sid == 116:
		var c116 := c(w, 116)
		var opis := " 与 加 蓬 的 流 亡 反 对 派 和 国 内 潜 伏 的 反 对 派 取 得 联 系 ， 并 为 他 们 提 供 支 持"
		var conds: Array = []
		conds.append(cond(" 不 早 于 1981 年 且 影 响 力 不 低 于 60",
			func(): return d(w, 21) >= 1981 and w.influence_prc >= 600))
		conds.append(cond(" 预 算 不 少 于 7百 万 ，特 工 网 络 不 少 于 10",
			func(): return d(w, 8) + d(w, 36) >= 70 and d(w, 9) >= 100))
		conds.append(cond(" 科 技 《 情 报 部 门 新 装 备 》 已 研 发 完 毕", func(): return _sci(w, 19)))
		conds.append(cond(" 尚 未 联 络", func(): return c116 != null and not c116.内战中))
		var eff := func():
			if c116 == null:
				return
			c116.内战中 = true
			_add_d(w, 9, -100)
			_add_d(w, 8, -70)
		return make_def(caption, opis, conds, eff)
	return {}


# ============================================================================
# 编号 1025 · 巴布亚人建国
# DBS Show L4067-4078 / OnMouseDown L11651-11662
# ============================================================================
func _def_1025(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c50 := c(w, 50)
	var c135 := c(w, 135)
	var c134 := c(w, 134)
	var opis := " 巴 布 亚 人 建 国"
	var conds: Array = []
	conds.append(cond(" 印 度 尼 西 亚 与 澳 大 利 亚 均 持 积 极 态 度",
		func(): return c50 != null and c50.government == GameConstants.Government.SOCIALIST and c135 != null and not c135.has_tag("亲美")))
	conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5",
		func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	conds.append(cond(" 还 未 推 动", func(): return not parts(c134, 0)))
	var eff := func():
		if c134 == null:
			return
		_add_d(w, 8, -50)
		_add_d(w, 9, -50)
		set_parts(c134, 0, true)
		c134.puppet_of = GameConstants.LegacySlot.NONE
		c134.leave_alliances()
		c134.government = GameConstants.Government.SOCIALIST
		c134.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		c134.set_tag("亲中", true)
		c134.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1026 · 支持墨西哥的左翼反对派
# DBS Show L4079-4090 / OnMouseDown L11663-11668
# ============================================================================
func _def_1026(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c140 := c(w, 140)
	var opis := " 支 持 墨 西 哥 的 左 翼 反 对 派"
	var conds: Array = []
	conds.append(cond(" 科 技 《 新 式 间 谍 装 备 》 研 发 完 毕", func(): return _sci(w, 20)))
	conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5",
		func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	conds.append(cond(" 尚 未 支 持 过 反 对 派", func(): return c140 != null and c140.stab == 0))
	var eff := func():
		if c140 == null:
			return
		_add_d(w, 8, -50)
		_add_d(w, 9, -50)
		c140.stab = 1
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1027 · 支持墨西哥的右翼反对派
# DBS Show L4091-4102 / OnMouseDown L11669-11674
# ============================================================================
func _def_1027(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c140 := c(w, 140)
	var opis := " 支 持 墨 西 哥 的 右 翼 反 对 派"
	var conds: Array = []
	conds.append(cond(" 科 技 《 新 式 间 谍 装 备 》 研 发 完 毕", func(): return _sci(w, 20)))
	conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5",
		func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	conds.append(cond(" 尚 未 支 持 反 对 派", func(): return c140 != null and c140.stab == 0))
	var eff := func():
		if c140 == null:
			return
		_add_d(w, 8, -50)
		_add_d(w, 9, -50)
		c140.stab = 2
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1028 · 支持南方解放军中的墨西哥共产党
# DBS Show L4103-4116 / OnMouseDown L11675-11681
# ============================================================================
func _def_1028(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c145 := c(w, 145)
	var opis := " 支 持 南 方 解 放 军 中 的 墨 西 哥 共 产 党"
	var conds: Array = []
	conds.append(cond(" 尚 未 支 持 任 一 左 翼 激 进 派", func(): return c145 != null and not c145.内战中))
	conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5",
		func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	conds.append(cond(" 我 国 为 社 会 主 义", func(): return soc(w, c(w, 1), true)))
	conds.append(cond(" 我 们 未 与 霍 查 决 裂",
		func(): return (d(w, 60) == 0 or d(w, 60) == 3) and _has(w, 20, "亲中")))
	var eff := func():
		if c145 == null:
			return
		c145.内战中 = true
		_add_d(w, 8, -50)
		_add_d(w, 9, -50)
		c145.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1029 · 支持南方解放军中的墨西哥无产阶级革命党
# DBS Show L4117-4130 / OnMouseDown L11682-11688
# ============================================================================
func _def_1029(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c145 := c(w, 145)
	var opis := " 支 持 南 方 解 放 军 中 的 墨 西 哥 无 产 阶 级 革 命 党"
	var conds: Array = []
	conds.append(cond(" 尚 未 支 持 任 一 左 翼 激 进 派", func(): return c145 != null and not c145.内战中))
	conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5",
		func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	conds.append(cond(" 我 国 为 社 会 主 义", func(): return soc(w, c(w, 1), true)))
	conds.append(cond(" 我 们 仍 信 奉 毛 主 义", func(): return mod(w, 6)))
	var eff := func():
		if c145 == null:
			return
		c145.内战中 = true
		_add_d(w, 8, -50)
		_add_d(w, 9, -50)
		c145.sub_government = GameConstants.SubGovernment.MAOIST
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1030 · 支持南方解放军中的墨西哥统一社会党
# DBS Show L4131-4144 / OnMouseDown L11689-11695
# ============================================================================
func _def_1030(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c145 := c(w, 145)
	var opis := " 支 持 南 方 解 放 军 中 的 墨 西 哥 统 一 社 会 党"
	var conds: Array = []
	conds.append(cond(" 尚 未 支 持 任 一 左 翼 激 进 派", func(): return c145 != null and not c145.内战中))
	conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5",
		func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	conds.append(cond(" 我 国 为 社 会 主 义", func(): return soc(w, c(w, 1), true)))
	conds.append(cond(" 我 国 与 苏 联 有 友 好 关 系", func(): return fl(w, "relres")))
	var eff := func():
		if c145 == null:
			return
		c145.内战中 = true
		_add_d(w, 8, -50)
		_add_d(w, 9, -50)
		c145.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1031 · 支持南方解放军中的革命工人党
# DBS Show L4145-4158 / OnMouseDown L11696-11702
# ============================================================================
func _def_1031(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c145 := c(w, 145)
	var opis := " 支 持 南 方 解 放 军 中 的 革 命 工 人 党"
	var conds: Array = []
	conds.append(cond(" 尚 未 支 持 任 一 左 翼 激 进 派", func(): return c145 != null and not c145.内战中))
	conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5",
		func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	conds.append(cond(" 我 国 为 社 会 主 义", func(): return soc(w, c(w, 1), true)))
	conds.append(cond(" 我 国 为 托 洛 茨 基 主 义 且 加 入 了 第 四 国 际",
		func(): return _sub(w, 1) == 18 and mod(w, 49)))
	var eff := func():
		if c145 == null:
			return
		c145.内战中 = true
		_add_d(w, 8, -50)
		_add_d(w, 9, -50)
		c145.sub_government = GameConstants.SubGovernment.TROTSKYIST
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1032 · 非洲/加勒比多国干预（马拉维、肯尼亚、多哥、科特迪瓦、尼日尔、塞内加尔、喀麦隆、加蓬、赤道几内亚、毛里塔尼亚、瓦努阿图、牙买加）
# DBS Show L4159-4326 / OnMouseDown L11703-11789
# ============================================================================
func _def_1032(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var sid := country.原版序号
	if sid == 125:
		var opis := " 我 们 已 经 有 了 封 锁 马 拉 维 能 力 ， 是 时 候 推 翻 这 个 小 号 反 共 堡 垒 了"
		var conds: Array = []
		conds.append(cond(" 非 洲 联 盟 已 成 立", func(): return ev(w, 500)))
		conds.append(cond(" 预 算 不 少 于 5百 万", func(): return d(w, 8) + d(w, 36) >= 50))
		conds.append(cond(" 津 巴 布 韦 ， 赞 比 亚 ， 坦 桑 尼 亚 ， 莫 桑 比 克 均 亲 中 且 为 社 会 主 义",
			func():
				return (_has(w, 127, "亲中") and soc(w, c(w, 127), true)
				and _has(w, 124, "亲中") and soc(w, c(w, 124), true)
				and _has(w, 122, "亲中") and soc(w, c(w, 122), true)
				and _has(w, 126, "亲中") and soc(w, c(w, 126), true))))
		conds.append(cond(" 尚 未 封 锁", func(): return not ev(w, 584)))
		var eff := func():
			start_event_num(w, 584)
		return make_def(caption, opis, conds, eff)
	if sid == 119:
		var c119 := c(w, 119)
		var opis := " 帮 助 肯 尼 亚 社 会 主 义 者 组 建 新 党"
		var conds: Array = []
		conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 3",
			func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 30))
		conds.append(cond(" 尚 未 重 组", func(): return c119 != null and not c119.内战中))
		var eff := func():
			if c119 == null:
				return
			_add_d(w, 8, -50)
			_add_d(w, 9, -30)
			c119.内战中 = true
		return make_def(caption, opis, conds, eff)
	if sid == 108:
		var opis := " 埃 亚 德 马 需 要 对 自 己 的 身 份 有 点 认 识"
		var conds: Array = []
		conds.append(cond(" 贝 宁 和 加 纳 愿 意 听 我 们 的 话 且 为 社 会 主 义",
			func():
				return (_has(w, 62, "亲中") and soc(w, c(w, 62), true)
				and _has(w, 63, "亲中") and (_gov(w, 63) == 1 or _sub(w, 63) == 0))))
		conds.append(cond(" 国 际 影 响 力 超 过 30", func(): return w.influence_prc >= 300))
		conds.append(cond(" 尚 未 制 裁", func(): return not ev(w, 593)))
		var eff := func():
			start_event_num(w, 593)
		return make_def(caption, opis, conds, eff)
	if sid == 64:
		var opis := " 时 机 已 到 ， 该 敲 打 敲 打 他 了"
		var conds: Array = []
		conds.append(cond(" 几 内 亚 ， 布 基 纳 法 索 和 加 纳 亲 中",
			func(): return _has(w, 68, "亲中") and _has(w, 63, "亲中") and _has(w, 61, "亲中")))
		conds.append(cond(" 国 际 影 响 力 超 过 30", func(): return w.influence_prc >= 300))
		conds.append(cond(" 非 洲 联 盟 已 成 立", func(): return ev(w, 500)))
		conds.append(cond(" 尚 未 制 裁", func(): return not ev(w, 592)))
		var eff := func():
			start_event_num(w, 592)
		return make_def(caption, opis, conds, eff)
	if sid == 56:
		var opis := " 给 尼 日 尔 掀 个 底 朝 天 ！"
		var conds: Array = []
		conds.append(cond(" 马 里 ， 布 基 纳 法 索 和 贝 宁 已 经 建 成 了 亲 中 社 会 主 义 政 权",
			func():
				return (soc(w, c(w, 58), true) and soc(w, c(w, 61), true) and soc(w, c(w, 62), true)
				and _has(w, 58, "亲中") and _has(w, 61, "亲中") and _has(w, 62, "亲中"))))
		conds.append(cond(" 非 洲 联 盟 成 立", func(): return ev(w, 500)))
		conds.append(cond(" 至 少 拥 有 10 军 力", func(): return d(w, 22) >= 100))
		conds.append(cond(" 尚 未 发 动 革 命", func(): return not ev(w, 606)))
		var eff := func():
			start_event_num(w, 606)
		return make_def(caption, opis, conds, eff)
	if sid == 112:
		var opis := " 时 机 已 到 ， 是 时 候 发 动 革 命 了"
		var conds: Array = []
		conds.append(cond(" 塞 内 加 尔 在 冈 比 亚 战 争 中 失 败",
			func(): return res(w, 597) == 1 and not parts(c(w, 112), 1) and not war(w, 52)))
		conds.append(cond(" 反 对 派 力 量 到 达100", func(): return _lvl_inst(w, 112) >= 1000))
		conds.append(cond(" 至 少 拥 有10 百 万 预 算 、10 特 工 网 络 与 10 军 力",
			func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100 and d(w, 22) >= 100))
		conds.append(cond(" 尚 未 发 动 革 命", func(): return not ev(w, 616)))
		var eff := func():
			_add_d(w, 8, -100)
			_add_d(w, 9, -100)
			_add_d(w, 22, -100)
			start_event_num(w, 616)
		return make_def(caption, opis, conds, eff)
	if sid == 66:
		var opis := " 对 喀 麦 隆 政 府 的 反 对 派 提 供 支 持"
		var conds: Array = []
		conds.append(cond(" 科 技 《 情 报 部 门 新 装 备 》 已 研 发 完 毕", func(): return _sci(w, 19)))
		conds.append(cond(" 我 们 是 社 会 主 义 或 改 良 主 义",
			func(): return soc(w, c(w, 1), true) or _gov(w, 1) == 2))
		conds.append(cond(" 影 响 力 不 低 于 30", func(): return w.influence_prc >= 300))
		conds.append(cond(" 尚 未 支 持", func(): return not ev(w, 680) or res(w, 680) == 2))
		var eff := func():
			_add_d(w, 9, -100)
			_add_d(w, 22, -100)
			start_event_num(w, 680)
		return make_def(caption, opis, conds, eff)
	if sid == 116:
		var opis := " 时 机 已 到 ， 给 邦 戈 政 权 施 压"
		var conds: Array = []
		conds.append(cond(" 加 蓬 有 两 个 亲 中 邻 国",
			func(): return _count_proprc(w, [66, 52, 115]) >= 2))
		conds.append(cond(" 支 持 过 反 对 派", func(): return _cw(w, 116)))
		conds.append(cond(" 不 早 于 1985 年 且 影 响 力 不 低 于 100",
			func(): return d(w, 21) >= 1985 and w.influence_prc > 1000))
		conds.append(cond(" 没 有 制 裁 过", func(): return not ev(w, 619)))
		var eff := func():
			start_event_num(w, 619)
		return make_def(caption, opis, conds, eff)
	if sid == 115:
		var opis := " 对 赤 道 几 内 亚 进 行 特 别 解 放 行 动"
		var conds: Array = []
		conds.append(cond(" 喀 麦 隆 ， 加 蓬 为 亲 中 社 会 主 义 政 权",
			func():
				return (soc(w, c(w, 66), true) and _has(w, 66, "亲中")
				and soc(w, c(w, 116), true) and _has(w, 116, "亲中"))))
		conds.append(cond(" 喀 麦 隆 ， 加 蓬 在 非 盟 中",
			func(): return _has(w, 116, "au") and _has(w, 66, "au") and ev(w, 500)))
		conds.append(cond(" 至 少 拥 有10 军 力", func(): return d(w, 22) >= 100))
		conds.append(cond(" 尚 未 解 放", func(): return not ev(w, 620)))
		var eff := func():
			_add_d(w, 22, -100)
			start_event_num(w, 620)
		return make_def(caption, opis, conds, eff)
	if sid == 59:
		var opis := " 敦 促 达 达 赫 政 府 加 大 社 会 主 义 改 革 力 度"
		var conds: Array = []
		conds.append(cond(" 我 们 坚 持 战 无 不 胜 的 毛 泽 东 思 想", func(): return mod(w, 6)))
		conds.append(cond(" 非 洲 联 盟 成 立 且 摩 洛 哥 、 阿 尔 及 利 亚 、 马 里 和 塞 内 加 尔 是 亲 中 的 社 会 主 义 国 家 ；",
			func():
				return (ev(w, 500) and soc(w, c(w, 54), true) and _has(w, 54, "亲中")
				and soc(w, c(w, 40), true) and _has(w, 40, "亲中")
				and soc(w, c(w, 58), true) and _has(w, 58, "亲中")
				and soc(w, c(w, 112), true) and _has(w, 112, "亲中"))))
		conds.append(cond(" 至 少15 百 万 预 算 与10 特 工 网 络",
			func(): return d(w, 8) + d(w, 36) >= 150 and d(w, 9) >= 100))
		conds.append(cond(" 尚 未 敦 促", func(): return not ev(w, 627)))
		var eff := func():
			_add_d(w, 8, -150)
			_add_d(w, 9, -100)
			start_event_num(w, 627)
		return make_def(caption, opis, conds, eff)
	if sid == 154:
		var c154 := c(w, 154)
		var opis := " 支 持 人 民 的 斗 争"
		var conds: Array = []
		conds.append(cond(" 瓦 努 阿 图 已 独 立",
			func(): return ev(w, 629) and _pup(w, 159) < 0))
		conds.append(cond(" 我 们 依 然 支 持 第 三 世 界 的 民 族 解 放 , 未 与 美 帝 国 主 义 眉 来 眼 去",
			func(): return not _has(w, 51, "对华贸易")))
		conds.append(cond(" 至 少5 百 万 预 算 与5 特 工 网 络",
			func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
		conds.append(cond(" 尚 未 支 持", func(): return c154 != null and not c154.内战中))
		var eff := func():
			if c154 == null:
				return
			_add_d(w, 8, -50)
			_add_d(w, 9, -50)
			c154.内战中 = true
		return make_def(caption, opis, conds, eff)
	if sid == 152:
		var c152 := c(w, 152)
		var opis := " 为 牙 买 加 送 去 援 助 ， 让 他 们 学 习 古 巴 经 验"
		var conds: Array = []
		conds.append(cond(" 古 巴 为 亲 中 社 会 主 义 政 权",
			func(): return _has(w, 138, "亲中") and soc(w, c(w, 138), true)))
		conds.append(cond(" 至 少5 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 50))
		conds.append(cond(" 尚 未 援 助", func(): return not soc(w, c(w, 152), true)))
		var eff := func():
			if c152 == null:
				return
			_add_d(w, 8, -50)
			c152.government = GameConstants.Government.SOCIALIST
			c152.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			c152.leave_alliances()
			c152.set_tag("对华贸易", true)
			c152.set_tag("亲中", true)
			add_rel(w, 0, -50)
		return make_def(caption, opis, conds, eff)
	return {}


# ============================================================================
# 编号 1033 · 为危难之际的社会主义古巴送上我们的支持
# DBS Show L4327-4338 / OnMouseDown L11790-11795
# ============================================================================
func _def_1033(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 为 危 难 之 际 的 社 会 主 义 古 巴 送 上 我 们 的 支 持"
	var conds: Array = []
	conds.append(cond(" 古 巴 中 立",
		func(): return not _has(w, 138, "亲苏") and not _has(w, 138, "亲美") and not _has(w, 138, "亲中")))
	conds.append(cond(" 中 国 影 响 力 大 于 苏 联", func(): return w.influence_prc > power(w, 1)))
	conds.append(cond(" 尚 未 支 持", func(): return not ev(w, 591)))
	var eff := func():
		start_event_num(w, 591)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1034 · 协助美国入侵古巴
# DBS Show L4339-4352 / OnMouseDown L11796-11804
# ============================================================================
func _def_1034(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c138 := c(w, 138)
	var opis := " 协 助 美 国 入 侵 古 巴"
	var conds: Array = []
	conds.append(cond(" 格 林 纳 达 亲 美", func(): return _has(w, 48, "亲美")))
	conds.append(cond(" 中 国 与 美 国 在 同 一 阵 容 内", func(): return _has(w, 1, "seato")))
	conds.append(cond(" 预 算 不 少 于 15百 万 ，特 工 网 络 不 少 于 15 ， 军 力 不 少 于15",
		func(): return d(w, 8) + d(w, 36) >= 150 and d(w, 9) >= 150 and d(w, 22) >= 150))
	conds.append(cond(" 尚 未 策 划 入 侵", func(): return c138 != null and not c138.内战中))
	var eff := func():
		if c138 == null:
			return
		_add_d(w, 8, -150)
		_add_d(w, 9, -150)
		_add_d(w, 22, -150)
		c138.内战中 = true
		set_parts(c138, 0, true)
		var war49 := _ensure_war(w, 49)
		war49.is_going = true
		war49.name_war = "第 二 次 猪 湾 事 件"
		war49.side1 = "美 国"
		war49.side2 = "古 巴"
		war49.infl1 = 500
		war49.infl2 = 500
		war49.usa_side = GameConstants.WarSide.SIDE1
		war49.ussr_side = GameConstants.WarSide.SIDE2
		war49.fortnight_elapsed = 0
		war49.diplo_done = [false, false]
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1035 · 督促吉布提加入非洲之角联邦
# DBS Show L4353-4366 / OnMouseDown L11805-11811
# ============================================================================
func _def_1035(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	const DJIBOUTI_REGION_IDS := [366, 367, 368, 370, 376, 2032]
	const HORN_FEDERATION_GWCODE := 530
	var c41 := c(w, 41)
	var c106 := c(w, 106)
	var opis := " 督 促 吉 布 提 加 入 非 洲 之 角 联 邦"
	var conds: Array = []
	conds.append(cond(" 非 洲 之 角 已 成 立",
		func(): return c41 != null and parts(c41, 0) and c41.sub_government == GameConstants.SubGovernment.MAOIST))
	conds.append(cond(" 吉 布 提 为 社 会 主 义",
		func(): return c106 != null and (c106.government == GameConstants.Government.SOCIALIST or c106.sub_government == GameConstants.SubGovernment.LEFT_RADICAL)))
	conds.append(cond(" 预 算 不 少 于 10百 万 ", func(): return d(w, 8) + d(w, 36) >= 100))
	conds.append(cond(" 尚 未 推 动 合 并", func(): return c41 != null and not parts(c41, 1)))
	var eff := func():
		if c41 == null:
			return
		_add_d(w, 8, -100)
		set_parts(c41, 0, false)
		set_parts(c41, 1, true)
		# 确保世界地图/国家面板显示“非洲之角联邦”（政体名优先于 chinese_name）。
		# 原版 name 固定为联邦名，不随政体变化，因此覆盖全部政体名。
		for gn_key in c41.gov_names:
			c41.gov_names[gn_key] = "非洲之角联邦"
		if c106 != null:
			c106.leave_alliances()
		# Godot 地图显示增量：吉布提区域并入非洲之角联邦（530）。
		if GameManager != null:
			GameManager.set_map_region_owner(DJIBOUTI_REGION_IDS, HORN_FEDERATION_GWCODE)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1036 · 煽动当地推翻政府（南美洲亲中国家>=5）
# DBS Show L4367-4386 / OnMouseDown L11812-11840
# ============================================================================
func _def_1036(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var c1 := c(w, 1)
	var opis := " 煽 动 当 地 推 翻 政 府"
	var conds: Array = []
	conds.append(cond(" 南 美 洲 至 少 有 五 个 亲 中 国 家",
		func(): return _count_proprc_range(w, 71, 83) >= 5))
	conds.append(cond(" 预 算 不 少 于 10百 万 ", func(): return d(w, 8) + d(w, 36) >= 100))
	conds.append(cond(" 尚 未 煽 动", func(): return not country.has_tag("亲中")))
	var eff := func():
		_add_d(w, 8, -100)
		country.leave_alliances()
		country.set_tag("亲中", true)
		country.set_tag("对华贸易", true)
		# 手动颠覆标记：南美选举链（ReqEventTriggers DLC01）据此不再触发该国选举剧情。
		country.set_tag("手动颠覆", true)
		if soc(w, c1, true):
			country.government = GameConstants.Government.SOCIALIST
			country.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		elif c1 != null and c1.government == GameConstants.Government.REFORMIST:
			country.government = GameConstants.Government.REFORMIST
			country.sub_government = GameConstants.SubGovernment.PRAGMATIST
		elif c1 != null and c1.government == GameConstants.Government.LIBERAL:
			country.government = GameConstants.Government.LIBERAL
			country.sub_government = GameConstants.SubGovernment.MODERATE
		else:
			country.government = GameConstants.Government.AUTHORITARIAN
			country.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		add_rel(w, 0, -250)
		add_power(w, 0, -20)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1037 · 为阿扎尼亚大会的革命根据地提供物资 / 帮助毛主义派系掌权
# DBS Show L4387-4416 / OnMouseDown L11841-11857
# ============================================================================
func _def_1037(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var c153 := c(w, 153)
	if not country.内战中:
		var opis_a := " 为 阿 扎 尼 亚 大 会 的 革 命 根 据 地 提 供 物 资"
		var conds_a: Array = []
		conds_a.append(cond(" 至 少 10 特 工 网 络 和 10 百 万 预 算",
			func(): return d(w, 9) >= 100 and d(w, 8) + d(w, 36) >= 100))
		conds_a.append(cond(" 国 际 声 誉 高 于 7 9", func(): return d(w, 6) > 790))
		conds_a.append(cond("津 巴 布 韦 亲 华", func(): return _has(w, 127, "亲中")))
		conds_a.append(cond(" 尚 未 支 援", func(): return not country.内战中))
		var eff_a := func():
			_add_d(w, 8, -100)
			_add_d(w, 9, -100)
			country.内战中 = true
		return make_def(caption, opis_a, conds_a, eff_a)
	var opis := " 帮 助 阿 扎 尼 亚 大 会 内 的 毛 主 义 派 系 掌 权"
	var conds: Array = []
	conds.append(cond(" 至 少 10 特 工 网 络 、10 军 事 力 量 和 5 百 万 预 算",
		func(): return d(w, 9) >= 100 and d(w, 22) >= 100 and d(w, 8) + d(w, 36) >= 50))
	conds.append(cond(" 国 际 声 誉 高 于 7 9 且 坚 持 毛 泽 东 思 想",
		func(): return d(w, 6) > 790 and mod(w, 6)))
	conds.append(cond(" 1981年 前", func(): return d(w, 21) < 1981))
	conds.append(cond(" 尚 未 帮 助", func(): return c153 != null and c153.government == GameConstants.Government.AUTHORITARIAN))
	var eff := func():
		if c153 == null:
			return
		_add_d(w, 8, -50)
		_add_d(w, 9, -100)
		_add_d(w, 22, -100)
		c153.government = GameConstants.Government.SOCIALIST
		c153.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1038 · 推翻斯威士兰君主制政权
# DBS Show L4417-4430 / OnMouseDown L11858-11870
# ============================================================================
func _def_1038(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var c1 := c(w, 1)
	var opis := "  推 翻 斯 威 士 兰 君 主 制 政 权"
	var conds: Array = []
	conds.append(cond(" 至 少 10 特 工 网 络 、10 军 事 力 量 和 10 百 万 预 算",
		func(): return d(w, 9) >= 100 and d(w, 22) >= 100 and d(w, 8) + d(w, 36) >= 100))
	conds.append(cond(" 国 际 声 誉 高 于 7 9", func(): return d(w, 6) > 790))
	conds.append(cond(" 南 非 种 族 隔 离 政 权 垮 台 且 莫 桑 比 克 亲 中",
		func(): return _has(w, 126, "亲中") and _sub(w, 131) != 7 and _sub(w, 131) != 9))
	conds.append(cond(" 尚 未 推 翻", func(): return not country.内战中))
	var eff := func():
		_add_d(w, 8, -100)
		_add_d(w, 9, -100)
		_add_d(w, 22, -100)
		country.内战中 = true
		country.leave_alliances()
		country.set_tag("亲中", true)
		country.set_tag("对华贸易", true)
		if c1 != null:
			country.government = c1.government
			country.sub_government = c1.sub_government
		else:
			# 中国(c1)缺失时政体复制无法执行；正常存档中国必存在，做空安全跳过。
			pass
		country.name = "斯 威 士 兰 人 民 共 和 国"
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1039 · 支持左翼（纳米比亚已独立）
# DBS Show L4431-4444 / OnMouseDown L11871-11890
# ============================================================================
func _def_1039(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := "  支 持 左 翼"
	var conds: Array = []
	conds.append(cond(" 至 少 10 特 工 网 络 、10 军 事 力 量 和 10 百 万 预 算",
		func(): return d(w, 9) >= 100 and d(w, 22) >= 100 and d(w, 8) + d(w, 36) >= 100))
	conds.append(cond(" 国 际 声 誉 高 于 7 9", func(): return d(w, 6) > 790))
	conds.append(cond(" 纳 米 比 亚 已 独 立", func(): return parts(c(w, 153), 0)))
	conds.append(cond(" 尚 未 支 持", func(): return _gov(w, country.原版序号) == 2))
	var eff := func():
		_add_d(w, 8, -100)
		_add_d(w, 9, -100)
		_add_d(w, 22, -100)
		if country.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST:
			country.government = GameConstants.Government.SOCIALIST
			country.sub_government = GameConstants.SubGovernment.MAOIST
			country.set_tag("亲中", true)
			country.set_tag("对华贸易", true)
		else:
			country.government = GameConstants.Government.SOCIALIST
			country.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
			country.set_tag("亲苏", true)
			country.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1040 · 支持右翼（纳米比亚已独立）
# DBS Show L4445-4458 / OnMouseDown L11891-11910
# ============================================================================
func _def_1040(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := "  支 持 右 翼"
	var conds: Array = []
	conds.append(cond(" 至 少 10 特 工 网 络 、10 军 事 力 量 和 10 百 万 预 算",
		func(): return d(w, 9) >= 100 and d(w, 22) >= 100 and d(w, 8) + d(w, 36) >= 100))
	conds.append(cond(" 国 际 声 誉 高 于 7 9", func(): return d(w, 6) > 790))
	conds.append(cond(" 纳 米 比 亚 已 独 立", func(): return parts(c(w, 153), 0)))
	conds.append(cond(" 尚 未 支 持", func(): return _gov(w, country.原版序号) == 2))
	var eff := func():
		_add_d(w, 8, -100)
		_add_d(w, 9, -100)
		_add_d(w, 22, -100)
		if country.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST:
			country.government = GameConstants.Government.LIBERAL
			country.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			country.set_tag("亲中", true)
			country.set_tag("对华贸易", true)
		else:
			country.government = GameConstants.Government.AUTHORITARIAN
			country.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			country.set_tag("亲中", true)
			country.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1041 · 帮助刚果人民换一位领袖（自由世界路线）
# DBS Show L4459-4472 / OnMouseDown L11911-11918
# ============================================================================
func _def_1041(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 蒙 博 托 坐 的 太 久 了 ， 我 们 将 帮 助 刚 果 人 民 换 一 位 领 袖"
	var conds: Array = []
	conds.append(cond(" 我 们 顺 应 了 时 代 潮 流 成 为 自 由 世 界 的 一 员",
		func(): return _gov(w, 1) == 3))
	conds.append(cond(" 我 们 还 没 有 和 蒙 博 托 撕 破 脸", func(): return _has(w, 117, "对华贸易")))
	conds.append(cond(" UDPS 被 建 立 起 来 了 ", func(): return ev(w, 613) and res(w, 613) == 0))
	conds.append(cond(" 尚 未 支 持", func(): return country.government != GameConstants.Government.LIBERAL))
	var eff := func():
		_add_d(w, 8, -100)
		country.government = GameConstants.Government.LIBERAL
		country.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
		country.set_tag("亲中", true)
		country.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1042 · 帮助刚果人民换一位领袖（亲中六国路线）
# DBS Show L4473-4486 / OnMouseDown L11919-11924
# ============================================================================
func _def_1042(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 蒙 博 托 坐 的 太 久 了 ， 我 们 将 帮 助 刚 果 人 民 换 一 位 领 袖"
	var conds: Array = []
	conds.append(cond(" 1 9 8 3 年 以 后", func(): return d(w, 21) >= 1983))
	conds.append(cond(" 赞 比 亚 ， 坦 桑 尼 亚 ， 卢 旺 达 ， 安 哥 拉 ， 刚 果 布 与 乌 干 达 亲 中",
		func():
			return (_has(w, 122, "亲中") and _has(w, 124, "亲中") and _has(w, 120, "亲中")
			and _has(w, 118, "亲中") and _has(w, 123, "亲中") and _has(w, 52, "亲中"))))
	conds.append(cond(" 至 少 10 特 工 网 络 和 20 军 事 力 量",
		func(): return d(w, 9) >= 100 and d(w, 22) >= 200))
	conds.append(cond(" 尚 未 掀 起 革 命", func(): return not ev(w, 612)))
	var eff := func():
		start_event_num(w, 612)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1043 · 非洲/拉美多国支持行动（莫桑比克、毛里塔尼亚、博茨瓦纳、瓦努阿图、危地马拉、尼加拉瓜）
# DBS Show L4487-4591 / OnMouseDown L11925-12002
# ============================================================================
func _def_1043(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var sid := country.原版序号
	if sid == 126:
		var c126 := c(w, 126)
		var opis := " 为 莫 桑 比 克 解 放 阵 线 送 去 援 助|控 制 度 ：" + _ctrl(w, 126)
		var conds: Array = []
		conds.append(cond(" 国 际 声 望 高 于 7 9", func(): return d(w, 6) >= 790))
		conds.append(cond(" 预 算 不 少 于 5百 万 ，军 力 不 少 于 5",
			func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 22) >= 50))
		conds.append(cond(" 控 制 度 低 于100 %且 不 为 0",
			func(): return c126 != null and c126.level_of_instability > 0 and c126.level_of_instability < 1000))
		conds.append(cond(" 半 年 内 尚 未 支 持 任 一 派 系", func(): return c126 != null and not c126.内战中))
		var eff := func():
			if c126 == null:
				return
			_add_d(w, 8, -50)
			_add_d(w, 22, -50)
			c126.level_of_instability += 15
			c126.内战中 = true
		return make_def(caption, opis, conds, eff)
	if sid == 59:
		var c59 := c(w, 59)
		var c54 := c(w, 54)
		var opis := " 和 摩 洛 哥 一 起 为 达 达 赫 总 统 组 织 的 毛 里 塔 尼 亚 民 主 联 盟 的 打 入 行 动 提 供 助 力 ， 促 使 军 政 府 内 形 成 毛 里 塔 尼 亚 民 主 联 盟 多 数 格 局 ， 以 恢 复 多 党 民 主"
		var conds: Array = []
		conds.append(cond(" 我 们 与 自 由 的 摩 洛 哥 有 密 切 联 系",
			func(): return c54 != null and (c54.has_tag("对华贸易") or ((c54.government == GameConstants.Government.LIBERAL or c54.sub_government == GameConstants.SubGovernment.TITOIST) and c54.has_tag("亲中")))))
		conds.append(cond(" 预 算 不 少 于 10百 万 ，特 工 网 络 不 少 于 10",
			func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100))
		conds.append(cond(" 进 入 1 9 8 0 年 5 月 及 以 后",
			func(): return (d(w, 21) >= 1980 and d(w, 20) >= 5) or d(w, 21) >= 1981))
		conds.append(cond(" 没 有 联 络 过 其 他 反 对 派", func(): return c59 != null and not c59.内战中))
		var eff := func():
			if c59 == null:
				return
			_add_d(w, 8, -100)
			_add_d(w, 9, -100)
			c59.内战中 = true
			c59.government = GameConstants.Government.LIBERAL
			c59.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			c59.leave_alliances()
			if c54 != null and c54.has_tag("亲中"):
				c59.set_tag("亲中", true)
				c59.set_tag("对华贸易", true)
			else:
				c59.leave_alliances()
				c59.set_tag("对华贸易", true)
		return make_def(caption, opis, conds, eff)
	if sid == 129:
		var c129 := c(w, 129)
		var opis := " 我 们 将 在 社 会 主 义 和 独 立 的 大 旗 下 组 建 博 茨 瓦 纳 争 取 社 会 主 义 运 动"
		var conds: Array = []
		conds.append(cond(" 预 算 不 少 于 8百 万 ，特 工 网 络 不 少 于 3",
			func(): return d(w, 8) + d(w, 36) >= 80 and d(w, 9) >= 30))
		conds.append(cond(" 尚 未 完 全 促 成 团 结", func(): return c129 != null and c129.level_of_instability < 200))
		var eff := func():
			if c129 == null:
				return
			_add_d(w, 8, -80)
			_add_d(w, 9, -30)
			c129.level_of_instability += 100
		return make_def(caption, opis, conds, eff)
	if sid == 159:
		var c159 := c(w, 159)
		var opis := " 邀 请 该 党 领 导 人 沃 尔 特 · 利 尼 前 来 我 国 学 习 建 党 经 验"
		var conds: Array = []
		conds.append(cond(" 我 们 是 社 会 主 义", func(): return soc(w, c(w, 1), true)))
		conds.append(cond(" 预 算 不 少 于 5百 万 ", func(): return d(w, 8) + d(w, 36) >= 50))
		conds.append(cond(" 不 早 于1977 年1 月 ， 不 晚 于1980 年6 月30 日",
			func(): return d(w, 21) >= 1977 and ((d(w, 21) <= 1980 and d(w, 20) <= 6 and d(w, 19) <= 30)
				or (d(w, 21) <= 1980 and d(w, 20) <= 5) or d(w, 21) <= 1979)))
		conds.append(cond(" 尚 未 邀 请", func(): return c159 != null and c159.level_of_instability <= 0))
		var eff := func():
			if c159 == null:
				return
			_add_d(w, 8, -50)
			c159.level_of_instability = 100
		return make_def(caption, opis, conds, eff)
	if sid == 149:
		var c149 := c(w, 149)
		if c149 != null and c149.government != GameConstants.Government.AUTHORITARIAN and c149.government != GameConstants.Government.LIBERAL:
			var opis_a := " 镇 压 右 翼 叛 乱|控 制 度 ：" + _ctrl(w, 149)
			var conds_a: Array = []
			conds_a.append(cond(" 危 地 马 拉 为 亲 中 或 亲 苏 政 权",
				func(): return c149.has_tag("亲中") or c149.has_tag("亲苏")))
			conds_a.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5 ， 军 事 力 量 不 少 于5 ",
				func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50 and d(w, 22) >= 50))
			conds_a.append(cond(" 半 年 一 次", func(): return not c149.内战中))
			var eff_a := func():
				if c149.government != GameConstants.Government.LIBERAL and not auth(w, c149):
					_add_d(w, 8, -50)
					_add_d(w, 9, -50)
					_add_d(w, 22, -50)
					c149.level_of_instability += 25
					c149.内战中 = true
				else:
					_add_d(w, 8, -50)
					_add_d(w, 9, -50)
					_add_d(w, 22, -50)
					c149.level_of_instability += 10
					c149.内战中 = true
			return make_def(caption, opis_a, conds_a, eff_a)
		var opis := " 支 持 左 翼 游 击 队|控 制 度 ：" + _ctrl(w, 149)
		var conds: Array = []
		conds.append(cond(" 我 们 是 社 会 主 义", func(): return soc(w, c(w, 1), true)))
		conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5 ， 军 事 力 量 不 少 于5 ",
			func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50 and d(w, 22) >= 50))
		conds.append(cond(" 尼 加 拉 瓜 为 亲 中 或 亲 苏 政 权",
			func(): return _has(w, 147, "亲中") or _has(w, 147, "亲苏")))
		conds.append(cond(" 半 年 一 次", func(): return c149 != null and not c149.内战中))
		var eff := func():
			if c149 == null:
				return
			if c149.government != GameConstants.Government.LIBERAL and not auth(w, c149):
				_add_d(w, 8, -50)
				_add_d(w, 9, -50)
				_add_d(w, 22, -50)
				c149.level_of_instability += 25
				c149.内战中 = true
			else:
				_add_d(w, 8, -50)
				_add_d(w, 9, -50)
				_add_d(w, 22, -50)
				c149.level_of_instability += 10
				c149.内战中 = true
		return make_def(caption, opis, conds, eff)
	if sid == 147:
		var c147 := c(w, 147)
		if c147 != null and not auth(w, c147) and c147.government != GameConstants.Government.LIBERAL:
			var opis_a := " 自 由 祖 国 或 死 亡 ！|控 制 度 ：" + _ctrl(w, 147)
			var conds_a: Array = []
			conds_a.append(cond(" 尼 加 拉 瓜 为 亲 中 或 亲 苏 政 权",
				func(): return c147.has_tag("亲中") or c147.has_tag("亲苏")))
			conds_a.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5 ， 军 事 力 量 不 少 于5 ",
				func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50 and d(w, 22) >= 50))
			conds_a.append(cond(" 半 年 一 次", func(): return not c147.内战中))
			var eff_a := func():
				_add_d(w, 8, -50)
				_add_d(w, 9, -50)
				_add_d(w, 22, -50)
				c147.level_of_instability += 30
				c147.内战中 = true
			return make_def(caption, opis_a, conds_a, eff_a)
		var opis := " 支 持 桑 地 诺 人 民 革 命|控 制 度 ：" + _ctrl(w, 147)
		var conds: Array = []
		conds.append(cond(" 我 们 是 社 会 主 义", func(): return soc(w, c(w, 1), true)))
		conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5 ， 军 事 力 量 不 少 于5 ",
			func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50 and d(w, 22) >= 50))
		conds.append(cond(" 半 年 一 次", func(): return c147 != null and not c147.内战中))
		var eff := func():
			if c147 == null:
				return
			# 原版两分支效果相同（DBS L11985-12000）：都是 level_of_unstab += 30 并置 cw。
			_add_d(w, 8, -50)
			_add_d(w, 9, -50)
			_add_d(w, 22, -50)
			c147.level_of_instability += 30
			c147.内战中 = true
		return make_def(caption, opis, conds, eff)
	return {}


# ============================================================================
# 编号 1044 · 非洲/拉美多国支持行动（莫抵运、毛里塔尼亚、博茨瓦纳、加蓬、瓦努阿图、危地马拉、尼加拉瓜）
# DBS Show L4592-4701 / OnMouseDown L12003-12059
# ============================================================================
func _def_1044(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var sid := country.原版序号
	if sid == 126:
		var c126 := c(w, 126)
		var opis := " 为 莫 桑 比 克 全 国 抵 抗 运 动 送 去 援 助|控 制 度 ：" + _ctrl(w, 126)
		var conds: Array = []
		conds.append(cond(" 已 与 莫 抵 运 取 得 联 系", func(): return res(w, 623) == 1))
		conds.append(cond(" 预 算 不 少 于 5百 万 ，军 力 不 少 于 5 ，特 工 网 络 不 少 于 5",
			func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 22) >= 50 and d(w, 9) >= 50))
		conds.append(cond(" 控 制 度 高 于 0且 不 为 100 %",
			func(): return c126 != null and c126.level_of_instability > 0 and c126.level_of_instability < 1000))
		conds.append(cond(" 半 年 内 尚 未 支 持 任 一 派 系", func(): return c126 != null and not c126.内战中))
		var eff := func():
			if c126 == null:
				return
			_add_d(w, 8, -50)
			_add_d(w, 22, -50)
			_add_d(w, 9, -50)
			c126.level_of_instability -= 30
			c126.内战中 = true
		return make_def(caption, opis, conds, eff)
	if sid == 59:
		var c59 := c(w, 59)
		var c13 := c(w, 13)
		var opis := " 和 利 比 亚 一 起 为 卡 扎 菲 主 义 者 的 打 入 行 动 提 供 助 力 ， 促 使 军 政 府 内 形 成 卡 扎 菲 主 义 者 多 数 格 局 ， 以 输 出 民 众 革 命"
		var conds: Array = []
		conds.append(cond(" 利 比 亚 是 卡 扎 菲 执 政 ， 且 支 持 过 利 比 亚",
			func(): return c13 != null and (c13.sub_government == GameConstants.SubGovernment.PRAGMATIST or c13.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST) and c13.has_tag("对华贸易")))
		conds.append(cond(" 预 算 不 少 于 10百 万 ，特 工 网 络 不 少 于 10",
			func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100))
		conds.append(cond(" 进 入 1 9 8 0 年 后", func(): return d(w, 21) >= 1980))
		conds.append(cond(" 没 有 联 络 过 其 他 反 对 派", func(): return c59 != null and not c59.内战中))
		var eff := func():
			if c59 == null:
				return
			_add_d(w, 8, -100)
			_add_d(w, 9, -100)
			c59.内战中 = true
			c59.government = GameConstants.Government.AUTHORITARIAN
			c59.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			c59.leave_alliances()
			c59.puppet_of = 13
			c59.set_tag("对华贸易", true)
			c59.name = "阿 拉 伯 毛 里 塔 尼 亚" + String.chr(10) + " 人 民 社 会 主 义 民 众 国"
		return make_def(caption, opis, conds, eff)
	if sid == 129:
		var c129 := c(w, 129)
		var opis := " 我 们 将 在 博 茨 瓦 纳 周 边 开 设 训 练 营 地"
		var conds: Array = []
		conds.append(cond(" 特 工 网 络 不 少 于 5 ，军 事 力 量 不 少 于 5",
			func(): return d(w, 22) >= 50 and d(w, 9) >= 50))
		conds.append(cond(" 博 茨 瓦 纳 有 两 个 邻 国 为 亲 中 社 会 主 义 政 权",
			func(): return _count_soc(w, [127, 131, 124, 123]) >= 2))
		conds.append(cond(" 尚 未 训 练", func(): return c129 != null and not c129.内战中))
		var eff := func():
			if c129 == null:
				return
			_add_d(w, 22, -50)
			_add_d(w, 9, -50)
			c129.内战中 = true
		return make_def(caption, opis, conds, eff)
	if sid == 116:
		var c116 := c(w, 116)
		var opis := " 我 们 将 在 加 蓬 周 围 开 设 训 练 营 地 ， 帮 助 左 翼 反 对 派 恢 复 武 装 斗 争"
		var conds: Array = []
		conds.append(cond(" 不 少 于 10 百 万 预 算，特 工 网 络 不 少 于 10 ，军 事 力 量 不 少 于 10",
			func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 22) >= 100 and d(w, 9) >= 100))
		conds.append(cond(" 加 蓬 有 亲 中 的 两 个 社 会 主 义 邻 国",
			func():
				return (soc(w, c(w, 66), true) and _has(w, 66, "亲中")
				and soc(w, c(w, 52), true) and _has(w, 52, "亲中"))))
		conds.append(cond(" 中 国 是 社 会 主 义 且 影 响 力 不 低 于 80",
			func(): return soc(w, c(w, 1), true) and w.influence_prc > 800))
		conds.append(cond(" 尚 未 支 持", func(): return c116 != null and not c116.有驻军基地))
		var eff := func():
			if c116 == null:
				return
			_add_d(w, 22, -100)
			_add_d(w, 9, -100)
			_add_d(w, 8, -100)
			c116.有驻军基地 = true
		return make_def(caption, opis, conds, eff)
	if sid == 159:
		var c159 := c(w, 159)
		var opis := " 为 利 尼 的 党 提 供 经 济 支 持"
		var conds: Array = []
		conds.append(cond(" 预 算 不 少 于 10百 万 ", func(): return d(w, 8) + d(w, 36) >= 100))
		conds.append(cond(" 尚 未 支 持 过", func(): return c159 != null and not c159.内战中))
		var eff := func():
			if c159 == null:
				return
			_add_d(w, 8, -100)
			c159.内战中 = true
		return make_def(caption, opis, conds, eff)
	if sid == 149:
		var c149 := c(w, 149)
		var opis := " 镇 压 左 翼 叛 乱|控 制 度 ：" + _ctrl(w, 149)
		var conds: Array = []
		conds.append(cond(" 我 们 不 是 社 会 主 义", func(): return not soc(w, c(w, 1), true)))
		conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5 ， 军 事 力 量 不 少 于5 ",
			func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50 and d(w, 22) >= 50))
		conds.append(cond(" 半 年 一 次", func(): return c149 != null and not c149.内战中))
		var eff := func():
			if c149 == null:
				return
			_add_d(w, 8, -50)
			_add_d(w, 9, -50)
			_add_d(w, 22, -50)
			c149.level_of_instability -= 10
			c149.内战中 = true
		return make_def(caption, opis, conds, eff)
	if sid == 147:
		var c147 := c(w, 147)
		var opis := " 上 帝 ， 祖 国 ， 民 主 。|控 制 度 ：" + _ctrl(w, 147)
		var conds: Array = []
		conds.append(cond(" 我 们 不 是 社 会 主 义", func(): return not soc(w, c(w, 1), true)))
		conds.append(cond(" 预 算 不 少 于 5百 万 ，特 工 网 络 不 少 于 5 ， 军 事 力 量 不 少 于5 ",
			func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50 and d(w, 22) >= 50))
		conds.append(cond(" 尼 加 拉 瓜 为 社 会 主 义 或 改 良 主 义 政 体",
			func(): return soc(w, c(w, 147), true) or _gov(w, 147) == 2))
		conds.append(cond(" 半 年 一 次", func(): return c147 != null and not c147.内战中))
		var eff := func():
			if c147 == null:
				return
			_add_d(w, 8, -50)
			_add_d(w, 9, -50)
			_add_d(w, 22, -50)
			c147.level_of_instability -= 25
			c147.内战中 = true
		return make_def(caption, opis, conds, eff)
	return {}


# ============================================================================
# 编号 1045 · 全非人民革命军支援（莫桑比克、喀麦隆、尼日利亚、塞内加尔、毛里塔尼亚、博茨瓦纳、瓦努阿图、危地马拉）
# DBS Show L4702-4812 / OnMouseDown L12060-12133
# ============================================================================
func _def_1045(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var sid := country.原版序号
	if sid == 126:
		var c126 := c(w, 126)
		var opis := " 号 召 全 非 人 民 革 命 军 前 往 支 援 当 地 人 民 的 革 命 斗 争"
		var conds: Array = []
		conds.append(cond(" 非 洲 联 盟 已 建 立", func(): return ev(w, 500)))
		conds.append(cond(" 预 算 不 少 于 10百 万 ，军 力 不 少 于 10",
			func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 22) >= 100))
		conds.append(cond(" 控 制 度 高 于 0且 不 为 100 %",
			func(): return c126 != null and c126.level_of_instability > 0 and c126.level_of_instability < 1000))
		conds.append(cond("尚 未 支 援", func(): return c126 != null and c126.level_of_development == 0))
		var eff := func():
			if c126 == null:
				return
			_add_d(w, 8, -100)
			_add_d(w, 22, -100)
			c126.level_of_instability += 200
			c126.level_of_development = 200
		return make_def(caption, opis, conds, eff)
	if sid == 66:
		var c66 := c(w, 66)
		var opis := " 号 召 全 非 人 民 革 命 军 前 往 支 援 当 地 人 民 的 革 命 斗 争"
		var conds: Array = []
		conds.append(cond(" 非 洲 联 盟 已 建 立", func(): return ev(w, 500)))
		conds.append(cond(" 预 算 不 少 于 10百 万 ，军 力 不 少 于 10",
			func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 22) >= 100))
		conds.append(cond(" UPC 的 力 量 小 于 100", func(): return c66 != null and c66.level_of_instability < 100))
		conds.append(cond("尚 未 支 援", func(): return c66 != null and c66.level_of_development == 0))
		var eff := func():
			if c66 == null:
				return
			_add_d(w, 8, -100)
			_add_d(w, 22, -100)
			c66.level_of_instability += 20
			c66.level_of_development = 200
		return make_def(caption, opis, conds, eff)
	if sid == 60:
		var c60 := c(w, 60)
		var opis := " 号 召 全 非 人 民 革 命 军 前 往 支 援 当 地 人 民 的 革 命 斗 争"
		var conds: Array = []
		conds.append(cond(" 非 洲 联 盟 已 建 立", func(): return ev(w, 500)))
		conds.append(cond(" 预 算 不 少 于 10百 万 ，军 力 不 少 于 10",
			func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 22) >= 100))
		conds.append(cond(" 革 命 派 力 量 小 于 100", func(): return c60 != null and c60.prc_power < 100))
		conds.append(cond("尚 未 支 援", func(): return c60 != null and c60.level_of_development == 0))
		var eff := func():
			if c60 == null:
				return
			_add_d(w, 8, -100)
			_add_d(w, 22, -100)
			c60.prc_power += 20
			c60.level_of_development = 200
		return make_def(caption, opis, conds, eff)
	if sid == 112:
		var c112 := c(w, 112)
		var opis := " 号 召 全 非 人 民 革 命 军 前 往 支 援 当 地 人 民 的 革 命 斗 争"
		var conds: Array = []
		conds.append(cond(" 非 洲 联 盟 已 建 立", func(): return ev(w, 500)))
		conds.append(cond(" 预 算 不 少 于 10百 万 ，军 力 不 少 于 10",
			func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 22) >= 100))
		conds.append(cond(" 塞 共 / 马 列 力 量 小 于 100", func(): return c112 != null and c112.level_of_instability < 1000))
		conds.append(cond("尚 未 支 援", func(): return c112 != null and c112.level_of_development == 0))
		var eff := func():
			if c112 == null:
				return
			_add_d(w, 8, -100)
			_add_d(w, 22, -100)
			c112.level_of_instability += 200
			c112.level_of_development = 200
		return make_def(caption, opis, conds, eff)
	if sid == 59:
		var c59 := c(w, 59)
		var c14 := c(w, 14)
		var c30 := c(w, 30)
		var opis := " 和 伊 拉 克 一 起 为 复 兴 党 的 打 入 行 动 提 供 助 力 ， 促 使 军 政 府 内 形 成 复 兴 党 多 数 格 局 ， 以 助 力 泛 阿 拉 伯 事 业"
		var conds: Array = []
		conds.append(cond(" 伊 拉 克 是 尘 埃 落 定 的 改 良 主 义 复 兴 党 政 权 ， 或 萨 达 姆 亲 中",
			func(): return c14 != null and (c14.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST
				or (c14.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST and c14.has_tag("亲中"))
				or (c14.government == GameConstants.Government.REFORMIST and ev(w, 36))) and c14.puppet_of < 0))
		conds.append(cond(" 预 算 不 少 于 10百 万 ，特 工 网 络 不 少 于 10",
			func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100))
		conds.append(cond(" 没 有 联 络 过 其 他 反 对 派", func(): return c59 != null and not c59.内战中))
		var eff := func():
			if c59 == null or c14 == null:
				return
			_add_d(w, 8, -100)
			_add_d(w, 9, -100)
			c59.内战中 = true
			c59.name = "阿 拉 伯 毛 里 塔 尼 亚 共 和 国"
			c59.government = c14.government
			c59.sub_government = c14.sub_government
			c59.leave_alliances()
			c59.set_tag("对华贸易", true)
			if c14.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or c14.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
				c59.puppet_of = GameConstants.LegacySlot.IRAQ
			elif (w.oar and c30 != null and c30.has_tag("亲苏")) or c14.has_tag("亲苏"):
				c59.set_tag("亲苏", true)
			elif (w.oar and c30 != null and c30.has_tag("亲中")) or c14.has_tag("亲中"):
				c59.set_tag("亲中", true)
		return make_def(caption, opis, conds, eff)
	if sid == 129:
		var c129 := c(w, 129)
		var opis := " 吉 时 已 到 ， 是 时 候 开 展 行 动 了"
		var conds: Array = []
		conds.append(cond(" 军 力 不 少 于 10", func(): return d(w, 22) >= 100))
		conds.append(cond(" 该 国 左 派 已 统 一", func(): return c129 != null and c129.level_of_instability > 0))
		conds.append(cond(" 尚 未 起 义", func(): return not ev(w, 628)))
		var eff := func():
			_add_d(w, 9, -100)
			start_event_num(w, 628)
		return make_def(caption, opis, conds, eff)
	if sid == 159:
		var c154 := c(w, 154)
		var opis := " 在 瓦 努 阿 图 为FLNKS 提 供 帮 助"
		var conds: Array = []
		conds.append(cond(" F L N K S 已 组 建", func(): return c154 != null and c154.内战中))
		conds.append(cond(" 预 算 不 少 于 5百 万 ， 特 工 网 络 不 少 于10",
			func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 100))
		conds.append(cond(" 尚 未 提 供 帮 助", func(): return c154 != null and c154.level_of_instability <= 0))
		var eff := func():
			if c154 == null:
				return
			_add_d(w, 8, -50)
			_add_d(w, 9, -100)
			c154.level_of_instability = 100
		return make_def(caption, opis, conds, eff)
	if sid == 149:
		var opis := " 危 地 马 拉 ， 一 寸 也 不 能 少 ！"
		var conds: Array = []
		conds.append(cond(" 危 地 马 拉 为 亲 中 或 亲 苏 政 权",
			func(): return _has(w, 149, "亲中") or _has(w, 149, "亲苏")))
		conds.append(cond(" 英 国 输 掉 了 马 岛 战 争 ", func(): return fl(w, "BritLost")))
		conds.append(cond(" 军 事 力 量 不 少 于 8", func(): return d(w, 22) >= 80))
		conds.append(cond(" 尚 未 收 复", func(): return not ev(w, 634)))
		var eff := func():
			_add_d(w, 22, -80)
			start_event_num(w, 634)
		return make_def(caption, opis, conds, eff)
	return {}


# ============================================================================
# 编号 1046 · 支持左派对新喀里多尼亚政府的全面夺权
# DBS Show L4813-4826 / OnMouseDown L12134-12141
# ============================================================================
func _def_1046(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c154 := c(w, 154)
	var opis := " 支 持 左 派 对 新 喀 里 多 尼 亚 政 府 的 全 面 夺 权"
	var conds: Array = []
	conds.append(cond(" 已 组 建 并 支 持 F L N K S",
		func(): return c154 != null and c154.内战中 and c154.level_of_instability > 0))
	conds.append(cond(" 军 事 力 量 不 少 于 10 ， 特 工 网 络 不 少 于10",
		func(): return d(w, 22) >= 100 and d(w, 9) >= 100))
	conds.append(cond(" 不 早 于1984 年", func(): return d(w, 21) >= 1984))
	conds.append(cond(" 尚 未 发 动 起 义", func(): return not ev(w, 630)))
	var eff := func():
		_add_d(w, 22, -100)
		_add_d(w, 9, -100)
		start_event_num(w, 630)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1047 · 支持安哥拉国内的左派发动政变，借此夺取安人运内部领导权
# DBS Show L4827-4838 / OnMouseDown L12142-12150
# ============================================================================
func _def_1047(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c123 := c(w, 123)
	var opis := " 支 持 安 哥 拉 国 内 的 左 派 发 动 政 变 ， 借 此 夺 取 安 人 运 内 部 领 导 权"
	var conds: Array = []
	conds.append(cond(" 特 工 网 络 不 少 于10", func(): return d(w, 9) >= 100))
	conds.append(cond("  早 于1978 年", func(): return d(w, 21) < 1978))
	conds.append(cond(" 尚 未 支 持", func(): return c123 != null and c123.level_of_instability == 0))
	var eff := func():
		if c123 == null:
			return
		_add_d(w, 9, -100)
		c123.level_of_instability = 100
		c123.sub_government = GameConstants.SubGovernment.MAOIST
		c123.leave_alliances()
		c123.set_tag("亲中", true)
		c123.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1048 · 支持安人运内的“强硬派”夺权
# DBS Show L4839-4850 / OnMouseDown L12151-12159
# ============================================================================
func _def_1048(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c123 := c(w, 123)
	var opis := " 支 持 安 人 运 内 的 “ 强 硬 派 ” 夺 权"
	var conds: Array = []
	conds.append(cond(" 特 工 网 络 不 少 于10", func(): return d(w, 9) >= 100))
	conds.append(cond("  早 于1978 年", func(): return d(w, 21) < 1978))
	conds.append(cond(" 尚 未 支 持", func(): return c123 != null and c123.level_of_instability == 0))
	var eff := func():
		if c123 == null:
			return
		_add_d(w, 9, -100)
		c123.level_of_instability = 200
		c123.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		c123.leave_alliances()
		c123.set_tag("亲中", true)
		c123.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1049 · 我们已经做好入局安哥拉的准备了
# DBS Show L4851-4860 / OnMouseDown L12160-12165
# ============================================================================
func _def_1049(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 我 们 已 经 做 好 入 局 安 哥 拉 的 准 备 了"
	var conds: Array = []
	conds.append(cond(" 1979年9月10日以后",
		func():
			return ((d(w, 21) >= 1979 and d(w, 20) >= 9 and d(w, 19) >= 10)
			or (d(w, 21) >= 1979 and d(w, 20) >= 10) or d(w, 21) >= 1980)))
	conds.append(cond(" 尚 未 决 定 ", func(): return not ev(w, 638)))
	var eff := func():
		start_event_num(w, 638)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1050 · 所罗门群岛马西纳运动 / 斐济联合政府
# DBS Show L4861-4891 / OnMouseDown L12166-12196
# ============================================================================
func _def_1050(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var sid := country.原版序号
	if sid == 161:
		var c161 := c(w, 161)
		var opis := " 从 所 罗 门 群 岛 全 国 工 人 联 盟 中 吸 纳 支 持 者 ， 复 兴 马 西 纳 运 动 ， 彻 底 打 倒 殖 民 主 义 ！"
		var conds: Array = []
		conds.append(cond(" 利 尼 在 瓦 努 阿 图 掌 权 ， 新 喀 里 多 尼 亚 已 解 放 ，澳 大 利 亚 是 社 会 主 义 或 改 良 主 义 政 体 且 不 为 左 倾 保 守 主 义",
			func():
				return ((soc(w, c(w, 159), true) or _gov(w, 159) == 2) and _pup(w, 154) < 0
				and (soc(w, c(w, 135), true) or _gov(w, 135) == 2) and _sub(w, 135) != 8)))
		conds.append(cond("国 际 影 响 力 高 于 80", func(): return w.influence_prc >= 800))
		conds.append(cond(" 至 少 2 0 百 万 预 算 和 2 0 特 工 网 络",
			func(): return d(w, 8) + d(w, 36) >= 200 and d(w, 9) >= 200))
		conds.append(cond("  没 有 支 持 过", func(): return c161 != null and not c161.内战中))
		var eff := func():
			if c161 == null:
				return
			_add_d(w, 8, -200)
			_add_d(w, 9, -200)
			c161.leave_alliances()
			c161.set_tag("亲中", true)
			c161.set_tag("对华贸易", true)
			c161.内战中 = true
			w.influence_prc += 20
			if soc(w, c(w, 135), true) and soc(w, c(w, 159), true) and soc(w, c(w, 136), true) and _sub(w, 135) != 8:
				c161.government = GameConstants.Government.SOCIALIST
				c161.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			else:
				c161.government = GameConstants.Government.REFORMIST
				c161.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		return make_def(caption, opis, conds, eff)
	if sid == 160:
		var opis := " 支 持 全 国 联 邦 党 和 斐 济 工 会 大 会 成 立 联 合 政 府"
		var conds: Array = []
		conds.append(cond(" 利 尼 在 瓦 努 阿 图 掌 权 ",
			func(): return soc(w, c(w, 159), true) or _gov(w, 159) == 2))
		conds.append(cond("国 际 影 响 力 高 于 80", func(): return w.influence_prc >= 800))
		conds.append(cond(" 至 少 2 0 百 万 预 算 和 2 0 特 工 网 络",
			func(): return d(w, 8) + d(w, 36) >= 200 and d(w, 9) >= 200))
		conds.append(cond("  没 有 支 持 过", func(): return not ev(w, 639)))
		var eff := func():
			_add_d(w, 8, -200)
			_add_d(w, 9, -200)
			start_event_num(w, 639)
		return make_def(caption, opis, conds, eff)
	return {}


# ============================================================================
# 批4 本地安全访问器（原版 allcountries[N] 在 Godot 中可能为 null，条件统一走这里）
# ============================================================================

## data.get_data_by_index(idx) 相对增减（原版 data.add_data_by_index(i, n / -= n 的忠实等价）。)
func _add_d(w: WorldState, idx: int, delta: int) -> void:
	set_d(w, idx, d(w, idx) + delta)


## 原版 science[idx] → Godot TechState.unlocked[idx]。
func _sci(w: WorldState, idx: int) -> bool:
	return w != null and w.techs != null and idx >= 0 and idx < w.techs.unlocked.size() and w.techs.unlocked[idx]


## 原版 allcountries[N].proprc → has_tag("亲中") 的 null 安全版。
func _has(w: WorldState, idx: int, tag: String) -> bool:
	var cc := c(w, idx)
	return cc != null and cc.has_tag(tag)


## 原版 allcountries[N].Gosstroy。
func _gov(w: WorldState, idx: int) -> int:
	var cc := c(w, idx)
	return cc.government if cc != null else -1


## 原版 allcountries[N].SubGosstroy。
func _sub(w: WorldState, idx: int) -> int:
	var cc := c(w, idx)
	return cc.sub_government if cc != null else -1


## 原版 allcountries[N].cw。
func _cw(w: WorldState, idx: int) -> bool:
	var cc := c(w, idx)
	return cc != null and cc.内战中


## 原版 allcountries[N].puppetOf。
func _pup(w: WorldState, idx: int) -> int:
	var cc := c(w, idx)
	return cc.puppet_of if cc != null else -1


## 原版 allcountries[N].level_of_dev。
func _lvl_dev(w: WorldState, idx: int) -> int:
	var cc := c(w, idx)
	return cc.level_of_development if cc != null else 0


## 原版 allcountries[N].level_of_unstab。
func _lvl_inst(w: WorldState, idx: int) -> int:
	var cc := c(w, idx)
	return cc.level_of_instability if cc != null else 0


## 原版 allcountries[N].prcpower。
func _prc_power(w: WorldState, idx: int) -> int:
	var cc := c(w, idx)
	return cc.prc_power if cc != null else 0


## 原版控制度/力量显示：level_of_unstab/10 + "." + Abs(level_of_unstab % 10)。
func _ctrl(w: WorldState, idx: int) -> String:
	var v := _lvl_inst(w, idx)
	@warning_ignore("integer_division")
	var whole: int = v / 10
	return "%d.%d" % [whole, absi(v % 10)]


## 统计若干原版序号中 proprc 的数量。
func _count_proprc(w: WorldState, ids: Array) -> int:
	var n := 0
	for id in ids:
		if _has(w, int(id), "亲中"):
			n += 1
	return n


## 统计 [from_idx, to_idx] 闭区间内 proprc 的数量（原版 for m=71; m<84）。
func _count_proprc_range(w: WorldState, from_idx: int, to_idx: int) -> int:
	var n := 0
	for m in range(from_idx, to_idx + 1):
		if _has(w, m, "亲中"):
			n += 1
	return n


## 统计若干原版序号中 IsSocialism(true, N) 的数量（原版 1044 博茨瓦纳分支）。
func _count_soc(w: WorldState, ids: Array) -> int:
	var n := 0
	for id in ids:
		if soc(w, c(w, int(id)), true):
			n += 1
	return n


## 确保 wars 数组长度覆盖 idx 并返回该槽（原版 ingamewars[idx] 直接赋值）。
func _ensure_war(w: WorldState, idx: int) -> WarData:
	while w.wars.size() <= idx:
		w.wars.append(WarData.new())
	var wd: WarData = w.wars[idx]
	if wd == null:
		wd = WarData.new()
		w.wars[idx] = wd
	return wd


# ============================================================================
# 静态自检结果（Python 脚本，2026-08-16）
#   - UTF-8 可读：OK
#   - 全文件 tab 缩进、无行首空格：OK（1787 行）
#   - 34 个编号均在 build_action 中有 match 分支且存在 _def_N：OK
#   - 每个 _def_N 括号平衡：OK
#   - cond("文案", Callable) 数量与 func(): return 一一对应：OK（269）
#   - 每个 _def_N 均标注 DBS Show / OnMouseDown 行号：OK
#   - 无大写 W 点号裸引用：OK
#   - extends "res://数据脚本/外交互动/外交互动_基础.gd"：OK
# ============================================================================
