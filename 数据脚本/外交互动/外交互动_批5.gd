## 外交互动 批5 — 编号 1051, 1052, 1053, 1054, 1056, 1057, 1058, 1059, 1060, 1061, 1062, 1063, 1064, 1065, 1066, 1067, 1068, 1069, 1070, 1071, 1072, 1074, 1075, 1076, 1077, 1078, 1079, 1080, 5000, 5001, 10000。
## 源码出处：DiploButtonScript.cs Show L4892-5563（仅 start < 5625 的中文分支）/ OnMouseDown L12197-12715。
## 严格遵循《外交互动对齐规范》，caption 用 ctx["caption"]，条件用 cond("原版文案", Callable)，效果用 Callable。
extends "res://数据脚本/外交互动/外交互动_基础.gd"


## 主分发：返回 {caption, opis, conditions, effect, dormant} 或 {}。
func build_action(action_type: int, ctx: Dictionary) -> Dictionary:
	var w: WorldState = ctx.get("w")
	var country: CountryData = ctx.get("country")
	var caption: String = ctx.get("caption", "")
	match action_type:
		1051:
			return _def_1051(w, country, caption)
		1052:
			return _def_1052(w, country, caption)
		1053:
			return _def_1053(w, country, caption)
		1054:
			return _def_1054(w, country, caption)
		1056:
			return _def_1056(w, country, caption)
		1057:
			return _def_1057(w, country, caption)
		1058:
			return _def_1058(w, country, caption)
		1059:
			return _def_1059(w, country, caption)
		1060:
			return _def_1060(w, country, caption)
		1061:
			return _def_1061(w, country, caption)
		1062:
			return _def_1062(w, country, caption)
		1063:
			return _def_1063(w, country, caption)
		1064:
			return _def_1064(w, country, caption)
		1065:
			return _def_1065(w, country, caption)
		1066:
			return _def_1066(w, country, caption)
		1067:
			return _def_1067(w, country, caption)
		1068:
			return _def_1068(w, country, caption)
		1069:
			return _def_1069(w, country, caption)
		1070:
			return _def_1070(w, country, caption)
		1071:
			return _def_1071(w, country, caption)
		1072:
			return _def_1072(w, country, caption)
		1074:
			return _def_1074(w, country, caption)
		1075:
			return _def_1075(w, country, caption)
		1076:
			return _def_1076(w, country, caption)
		1077:
			return _def_1077(w, country, caption)
		1078:
			return _def_1078(w, country, caption)
		1079:
			return _def_1079(w, country, caption)
		1080:
			return _def_1080(w, country, caption)
		5000:
			return _def_5000(w, country, caption)
		5001:
			return _def_5001(w, country, caption)
		10000:
			return _def_10000(w, country, caption)
	return {}


# ════════════════════════════════════════════════════════════════════════════
# 本批局部助手
# ════════════════════════════════════════════════════════════════════════════

## 原版 science[i]：科技已完成 → Godot TechState.unlocked[i]。
func _sci(w: WorldState, idx: int) -> bool:
	if w == null or w.techs == null:
		return false
	return idx >= 0 and idx < w.techs.unlocked.size() and w.techs.unlocked[idx]


## 原版 1059 uslovie[0]：伊拉克是尘埃落定的改良主义复兴党政权，或萨达姆亲中（DBS L5178）。
func _iraq_1059_ready(w: WorldState) -> bool:
	var c14 := c(w, 14)
	if c14 == null:
		return false
	return (((c14.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or c14.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST) and has(c14, "亲中")) \
			or (c14.government == GameConstants.Government.REFORMIST and ev(w, 36))) \
		and not has(c14, "asean") and c14.puppet_of < 0


## 原版 1051 所罗门分支 uslovie[0]（DBS L4898）。
func _oceania_presence_1051(w: WorldState) -> bool:
	return soc(w, c(w, 159), true) or (c(w, 159) != null and c(w, 159).government == GameConstants.Government.REFORMIST) \
		or has(c(w, 154), "亲中") or has(c(w, 135), "亲中") or has(c(w, 136), "亲中")


## 原版 1051 所罗门分支 uslovie[1]（DBS L4900）。
func _australia_1051(w: WorldState) -> bool:
	var c135 := c(w, 135)
	return c135 != null and not has(c135, "亲美") and not auth(w, c135) \
		and c135.sub_government != GameConstants.SubGovernment.LEFT_CONSERVATIVE


## 原版 1056 uslovie[0]（DBS L5032）。
func _chad_1056_socialist_bloc(w: WorldState) -> bool:
	return soc(w, c(w, 56), true) \
		and (soc(w, c(w, 13), true) or parts(c(w, 30), 2)) \
		and (soc(w, c(w, 53), true) or soc(w, c(w, 150), true)) \
		and soc(w, c(w, 65), true) and soc(w, c(w, 66), true) \
		and has(c(w, 56), "au") \
		and (has(c(w, 13), "okb") or parts(c(w, 30), 2)) \
		and (has(c(w, 53), "okb") or has(c(w, 150), "au")) \
		and has(c(w, 65), "au") and has(c(w, 66), "au") and ev(w, 500)


## 原版 1062 uslovie[0]（DBS L5232）。
func _panama_1062_usa_fallen(w: WorldState) -> bool:
	return not has(c(w, 51), "nato") \
		or (ev(w, 667) and not war(w, 84) and not has(c(w, 141), "亲美"))


## 原版 1068 强硬派分支 uslovie[0]（DBS L5325）。
func _western_europe_socialist_1068(w: WorldState) -> bool:
	return soc(w, c(w, 21), true) and soc(w, c(w, 92), true) \
		and soc(w, c(w, 86), true) and soc(w, c(w, 87), true)


## 原版“欧社联国家计数”（DBS L5264-5269 / L5335-5342 同款循环）。
func _soc_eu_count(w: WorldState) -> int:
	var n := 0
	for cc in w.countries:
		if cc != null and cc.has_tag("soc_eu"):
			n += 1
	return n


## 原版 1069-1072 动态描述中的中苏影响力对。
## C# 字段是 ×10 内部值，/10 与 %10 拼成 X.Y 显示。
func _power_pair(country: CountryData) -> String:
	if country == null:
		return " 我 国 影 响 力 ： 0.0 ， 苏 联 影 响 力 ：0.0"
	@warning_ignore("integer_division")
	return " 我 国 影 响 力 ： " + str(country.prc_power / 10) + "." + str(country.prc_power % 10) \
		+ " ， 苏 联 影 响 力 ：" + str(country.sov_power / 10) + "." + str(country.sov_power % 10)


## 原版 1057 乌干达四方力量对比后缀（DBS L5048-5063 等四处同一结构）。
func _uganda_power_text(c118: CountryData) -> String:
	if c118 == null:
		return "政 府 军0.0全 国 抵 抗 军0.0阿 明 残 军0.0乌 干 达 自 由 军0.0"
	@warning_ignore("integer_division")
	return "政 府 军" + str(c118.influence_nato / 10) + "." + str(absi(c118.influence_nato % 10)) \
		+ "全 国 抵 抗 军" + str(c118.influence_china / 10) + "." + str(absi(c118.influence_china % 10)) \
		+ "阿 明 残 军" + str(c118.prc_influence / 10) + "." + str(absi(c118.prc_influence % 10)) \
		+ "乌 干 达 自 由 军" + str(c118.sov_influence / 10) + "." + str(absi(c118.sov_influence % 10))


## 原版 1069/1070 效果尾部：prcpower 满 1000 后的政体改写（DBS L12444-12468 / L12479-12503）。
func _apply_prc_dominance(w: WorldState, country: CountryData) -> void:
	if country == null:
		return
	country.prc_power = 1000
	country.set_tag("亲中", true)
	country.set_tag("对华贸易", true)
	var c1 := c(w, 1)
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
		country.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN


## 原版 5000 非 gkchp 分支政体条件（DBS L5528）。
func _rim5000_regime_check(w: WorldState, country: CountryData) -> bool:
	if country == null:
		return false
	return w.is_socialism(country, true) \
		and country.sub_government != GameConstants.SubGovernment.SOVIET_STYLE \
		and country.sub_government != GameConstants.SubGovernment.TROTSKYIST \
		and not country.has_tag("sev") \
		and not country.has_tag("ovd") \
		and not country.has_tag("亲苏")


# ════════════════════════════════════════════════════════════════════════════
# 编号 1051
# DBS Show L4892-L4922 / OnMouseDown L12197-L12228
# ════════════════════════════════════════════════════════════════════════════
func _def_1051(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	if country.原版序号 == 161:
		var opis := " 为 所 罗 门 群 岛 当 地 政 府 送 去 援 助 ， 我 们 能 开 出 比 台 湾 当 局 更 高 的 价 格 … …"
		var conds: Array = []
		conds.append(cond(" 利 尼 在 瓦 努 阿 图 掌 权 或 我 们 在 大 洋 洲 有 势 力 存 在 ",
			func(): return _oceania_presence_1051(w)))
		conds.append(cond("澳 大 利 亚 不 亲 美 ， 不 为 威 权 主 义 和 左 倾 保 守 主 义",
			func(): return _australia_1051(w)))
		conds.append(cond(" 至 少 2 0 百 万 预 算 和 2 0 特 工 网 络",
			func(): return d(w, 8) + d(w, 36) >= 200 and d(w, 9) >= 200))
		conds.append(cond("  没 有 支 持 过", func(): return not has(country, "对华贸易")))
		var eff := func():
			set_d(w, 8, d(w, 8) - 200)
			set_d(w, 9, d(w, 9) - 200)
			var c161 := c(w, 161)
			if c161 == null:
				return
			c161.leave_alliances()
			c161.government = GameConstants.Government.LIBERAL
			c161.sub_government = GameConstants.SubGovernment.LIBERAL
			if has(c(w, 135), "亲中") or has(c(w, 159), "亲中") or has(c(w, 136), "亲中"):
				c161.set_tag("亲中", true)
			c161.set_tag("对华贸易", true)
			w.influence_prc += 10
		return make_def(caption, opis, conds, eff)
	if country.原版序号 == 160:
		var opis := " 支 持 斐 济 国 王 的 后 裔 乔 治 · 卡 达 武 莱 武 · 卡 科 鲍 阁 下 重 建 斐 济 王 国"
		var conds: Array = []
		conds.append(cond(" 澳 大 利 亚 不 亲 美 ", func(): return not has(c(w, 135), "亲美")))
		conds.append(cond("中 国 是 威 权 主 义", func(): return auth(w, c(w, 1))))
		conds.append(cond(" 至 少 2 0 百 万 预 算 和 2 0 特 工 网 络",
			func(): return d(w, 8) + d(w, 36) >= 200 and d(w, 9) >= 200))
		conds.append(cond("  没 有 支 持 过",
			func(): return c(w, 160) != null and (c(w, 160).government != GameConstants.Government.AUTHORITARIAN or not has(c(w, 160), "亲中"))))
		var eff := func():
			set_d(w, 8, d(w, 8) - 200)
			set_d(w, 9, d(w, 9) - 200)
			var c160 := c(w, 160)
			if c160 == null:
				return
			c160.government = GameConstants.Government.AUTHORITARIAN
			c160.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			c160.leave_alliances()
			c160.set_tag("亲中", true)
			c160.set_tag("对华贸易", true)
			var c1 := c(w, 1)
			if c1 != null and c1.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
				c160.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
			c160.name = "斐 济 王 国"
		return make_def(caption, opis, conds, eff)
	return {}


# ════════════════════════════════════════════════════════════════════════════
# 编号 1052
# DBS Show L4923-L4953 / OnMouseDown L12229-L12252
# ════════════════════════════════════════════════════════════════════════════
func _def_1052(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	if country.原版序号 == 9:
		var opis := " 对 蒙 古 进 行 特 别 军 事 行 动"
		var conds: Array = []
		conds.append(cond(" 中 国 影 响 力 大 于100 ， 苏 联 影 响 力 低 于15",
			func(): return w.influence_prc > 1000 and power(w, 1) < 150))
		conds.append(cond(" 至 少 2 0 百 万 预 算 和80 军 事 力 量",
			func(): return d(w, 8) + d(w, 36) >= 200 and d(w, 22) >= 800))
		conds.append(cond(" 尚 未 入 侵 蒙 古",
			func(): return country.puppet_of < 0 and not war(w, 69)))
		var eff := func():
			# 原版 number_event=640 → 本项目 event_id 为 event_640。
			start_event_num(w, 640)
		return make_def(caption, opis, conds, eff)
	if country.原版序号 == 7:
		var opis := " 支 持 斐 济 国 王 的 后 裔 乔 治 · 卡 达 武 莱 武 · 卡 科 鲍 阁 下 重 建 斐 济 王 国"
		var conds: Array = []
		conds.append(cond(" 澳 大 利 亚 不 亲 美 ", func(): return not has(c(w, 135), "亲美")))
		conds.append(cond("中 国 是 威 权 主 义", func(): return auth(w, c(w, 1))))
		conds.append(cond(" 至 少 2 0 百 万 预 算 和 2 0 特 工 网 络",
			func(): return d(w, 8) + d(w, 36) >= 200 and d(w, 9) >= 200))
		conds.append(cond("  没 有 支 持 过",
			func(): return c(w, 160) != null and (c(w, 160).government != GameConstants.Government.AUTHORITARIAN or not has(c(w, 160), "亲中"))))
		var eff := func():
			set_d(w, 8, d(w, 8) - 200)
			set_d(w, 9, d(w, 9) - 200)
			var c160 := c(w, 160)
			if c160 == null:
				return
			c160.government = GameConstants.Government.AUTHORITARIAN
			c160.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			c160.leave_alliances()
			c160.set_tag("亲中", true)
			c160.set_tag("对华贸易", true)
			var c1 := c(w, 1)
			if c1 != null and c1.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
				c160.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
			c160.name = "斐 济 王 国"
		return make_def(caption, opis, conds, eff)
	return {}


# ════════════════════════════════════════════════════════════════════════════
# 编号 1053
# DBS Show L4954-L4967 / OnMouseDown L12253-L12258
# ════════════════════════════════════════════════════════════════════════════
func _def_1053(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 整 合 塞 拉 利 昂 的 革 命 左 翼 ， 为 推 翻 政 府 做 准 备"
	var conds: Array = []
	conds.append(cond(" 非 洲 联 盟 已 经 成 立 ", func(): return ev(w, 500)))
	conds.append(cond("1982 年 后", func(): return d(w, 21) >= 1982))
	conds.append(cond(" 至 少 5 百 万 预 算 和 5 特 工 网 络",
		func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	conds.append(cond(" 尚 未 整 合", func(): return c(w, 107) != null and not c(w, 107).内战中))
	var eff := func():
		var c107 := c(w, 107)
		if c107 != null:
			c107.内战中 = true
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 50)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1054
# DBS Show L4968-L4991 / OnMouseDown L12259-L12266
# ════════════════════════════════════════════════════════════════════════════
func _def_1054(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c60 := c(w, 60)
	var opis := ""
	var conds: Array = []
	if c60 != null and c60.内战中:
		opis = " 援 助 扬 塔 特 斯 尼|力 量 ：" + str(c60.prc_power)
		conds.append(cond(" 一 年 二 次", func(): return c60 != null and not c60.有驻军基地))
		conds.append(cond(" 至 少 3 百 万 预 算 ， 3 特 工 网 络 和 3 军 力",
			func(): return d(w, 8) + d(w, 36) >= 30 and d(w, 9) >= 30 and d(w, 22) >= 30))
		conds.append(cond(" 国 际 声 誉 在 39 到 80 之 间",
			func(): return d(w, 6) > 390 and d(w, 6) < 800))
	else:
		opis = " 援 助 革 命 派|力 量 ：" + str(c60.prc_power if c60 != null else 0)
		conds.append(cond(" 一 年 二 次", func(): return c60 != null and not c60.有驻军基地))
		conds.append(cond(" 至 少 3 百 万 预 算 ， 3 特 工 网 络 和 3 军 力",
			func(): return d(w, 8) + d(w, 36) >= 30 and d(w, 9) >= 30 and d(w, 22) >= 30))
		conds.append(cond(" 国 际 声 誉 大 于 69", func(): return d(w, 6) >= 690))
	var eff := func():
		var target := c(w, 60)
		if target == null:
			return
		target.有驻军基地 = true
		set_d(w, 8, d(w, 8) - 30)
		set_d(w, 9, d(w, 9) - 30)
		set_d(w, 22, d(w, 22) - 30)
		target.prc_power += 10
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1056
# DBS Show L5028-L5041 / OnMouseDown L12282-L12290
# ════════════════════════════════════════════════════════════════════════════
func _def_1056(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 是 时 候 终 结 乍 得 的 乱 象 了 ！"
	var conds: Array = []
	conds.append(cond(" 尼 日 尔 ， 利 比 亚 ， 苏 丹 ， 中 非 ， 喀 麦 隆 是 社 会 主 义 且 是 集 安 / 非 盟 成 员",
		func(): return _chad_1056_socialist_bloc(w)))
	conds.append(cond(" 至 少 10 百 万 预 算 ，10 特 工 网 络 和 10 军 力",
		func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100 and d(w, 22) >= 100))
	conds.append(cond(" 中 国 是 社 会 主 义 ", func(): return soc(w, c(w, 1), true)))
	conds.append(cond(" 尚 未 发 动", func(): return not ev(w, 386)))
	var eff := func():
		set_d(w, 8, d(w, 8) - 100)
		set_d(w, 9, d(w, 9) - 100)
		set_d(w, 22, d(w, 22) - 100)
		start_event_num(w, 386)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1057
# DBS Show L5042-L5162 / OnMouseDown L12291-L12325
# ════════════════════════════════════════════════════════════════════════════
func _def_1057(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c118 := c(w, 118)
	var r659 := res(w, 659)
	var opis := ""
	var conds: Array = []
	match r659:
		1:
			opis = " 在 内 战 中 支 持 乌 干 达 民 族 解 放 军 粉 碎 反 政 府 武 装\n力 量 对 比 ： " + _uganda_power_text(c118)
			conds.append(cond(" 至 少 2 百 万 预 算 ，2 特 工 网 络 和 2 军 力",
				func(): return d(w, 8) + d(w, 36) >= 20 and d(w, 9) >= 20 and d(w, 22) >= 20))
			conds.append(cond(" 我 们 没 有 支 持 叛 乱 分 子", func(): return res(w, 659) < 2))
			conds.append(cond(" 三 月 一 次", func(): return c118 != null and not c118.内战中))
		2:
			opis = " 支 持 穆 塞 韦 尼 和 他 在 卢 韦 罗 三 角 地 带 发 动 的 人 民 战 争|力 量 对 比 ： " + _uganda_power_text(c118)
			conds.append(cond(" 极 左 至 保 守 派 主 导", func(): return d(w, 56) <= 1))
			conds.append(cond(" 至 少 2 百 万 预 算 ，2 特 工 网 络 和 2 军 力",
				func(): return d(w, 8) + d(w, 36) >= 20 and d(w, 9) >= 20 and d(w, 22) >= 20))
			conds.append(cond(" 东 方 的 风 将 芥 菜 种 子 带 向 了 四 方 ", func(): return res(w, 659) == 2))
			conds.append(cond(" 三 月 一 次", func(): return c118 != null and not c118.内战中))
		3:
			opis = " 与 扎 伊 尔 、 苏 丹 和 沙 特 一 道 向 前 乌 干 达 国 民 军 与 乌 干 达 民 族 拯 救 阵 线 提 供 支 持|力 量 对 比 ： " + _uganda_power_text(c118)
			conds.append(cond(" 至 少 2 百 万 预 算 ，2 特 工 网 络 和 2 军 力",
				func(): return d(w, 8) + d(w, 36) >= 20 and d(w, 9) >= 20 and d(w, 22) >= 20))
			conds.append(cond(" 我 们 与 扎 伊 尔 有 贸 易", func(): return has(c(w, 117), "对华贸易")))
			conds.append(cond(" 三 月 一 次", func(): return c118 != null and not c118.内战中))
		4:
			opis = " 支 持 乌 干 达 自 由 运 动 等 布 干 达 人 的 武 装 组 织|力 量 对 比 ： " + _uganda_power_text(c118)
			conds.append(cond(" 至 少 2 百 万 预 算 ，2 特 工 网 络 和 2 军 力",
				func(): return d(w, 8) + d(w, 36) >= 20 and d(w, 9) >= 20 and d(w, 22) >= 20))
			conds.append(cond(" 温 和 至 自 由 主 导", func(): return d(w, 56) > 1))
			conds.append(cond(" 三 月 一 次", func(): return c118 != null and not c118.内战中))
		_:
			# 原版 resultOfEvents[659] 不为 1-4 时没有为 1057 赋值任何条件与描述，按钮不成立。
			return {}
	var eff := func():
		if c118 == null:
			return
		match r659:
			1:
				c118.influence_nato += 50
			2:
				c118.influence_china += 50
			3:
				c118.prc_influence += 75
			4:
				c118.sov_influence += 75
			_:
				return
		set_d(w, 8, d(w, 8) - 20)
		set_d(w, 9, d(w, 9) - 20)
		set_d(w, 22, d(w, 22) - 20)
		c118.内战中 = true
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1058
# DBS Show L5163-L5173 / OnMouseDown L12326-L12333
# ════════════════════════════════════════════════════════════════════════════
func _def_1058(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 援 助 苏 丹 的 革 命 者 ， 伺 机 推 翻 尼 迈 里"
	var conds: Array = []
	conds.append(cond(" 已 完 成 “ 加 强 军 备 开 发”", func(): return _sci(w, 18)))
	conds.append(cond(" 至 少 有 1 5 军 力", func(): return d(w, 22) >= 150))
	conds.append(cond(" 我 们 还 没 有 援 助 过 他 们", func(): return c(w, 53) != null and not c(w, 53).内战中))
	var eff := func():
		set_d(w, 22, d(w, 22) - 150)
		var c53 := c(w, 53)
		if c53 != null:
			c53.set_tag("对华贸易", false)
			c53.内战中 = true
		set_d(w, 8, d(w, 8) + 30)
		w.oil_prod += 100.0
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1059
# DBS Show L5174-L5186 / OnMouseDown L12334-L12339
# ════════════════════════════════════════════════════════════════════════════
func _def_1059(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 和 伊 拉 克 人 合 作 ， 在 苏 丹 培 植 复 兴 主 义 者"
	var conds: Array = []
	conds.append(cond(" 伊 拉 克 是 尘 埃 落 定 的 改 良 主 义 复 兴 党 政 权 ， 或 萨 达 姆 亲 中",
		func(): return _iraq_1059_ready(w)))
	conds.append(cond(" 至 少 有 5 百 万 预 算 和 5 特 工 网 络",
		func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	conds.append(cond(" 早 于1983 年", func(): return d(w, 21) < 1983))
	conds.append(cond(" 我 们 还 没 有 支 持 过 其 中 之 一",
		func(): return c(w, 53) != null and c(w, 53).prc_influence == 0))
	var eff := func():
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 50)
		var c53 := c(w, 53)
		if c53 != null:
			c53.prc_influence = 1
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1060
# DBS Show L5187-L5199 / OnMouseDown L12340-L12345
# ════════════════════════════════════════════════════════════════════════════
func _def_1060(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 联 络 苏 丹 境 内 的 亲 利 比 亚 势 力 ， 为 民 众 革 命 做 准 备"
	var conds: Array = []
	conds.append(cond(" 卡 扎 菲 未 被 推 翻", func(): return c(w, 13) != null and c(w, 13).sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST))
	conds.append(cond(" 至 少 有 5 百 万 预 算 和 5 特 工 网 络",
		func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	conds.append(cond(" 早 于1983 年", func(): return d(w, 21) < 1983))
	conds.append(cond(" 我 们 还 没 有 支 持 过 其 中 之 一",
		func(): return c(w, 53) != null and c(w, 53).prc_influence == 0))
	var eff := func():
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 50)
		var c53 := c(w, 53)
		if c53 != null:
			c53.prc_influence = 2
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1061
# DBS Show L5200-L5227 / OnMouseDown L12346-L12353
# ════════════════════════════════════════════════════════════════════════════
func _def_1061(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c33 := c(w, 33)
	var opis := " 援 助 缅 甸 共 产 主 义 游 击 队|力量：" + str(c33.influence_china if c33 != null else 0)
	if res(w, 662) == 2:
		opis = " 援 助 民 族 团 结 联 盟|力量：" + str(c33.influence_china if c33 != null else 0)
	var conds: Array = []
	var r662 := res(w, 662)
	if r662 == 2:
		conds.append(cond(" 已 组 成 民 族 团 结 联 盟", func(): return res(w, 662) == 2))
	elif r662 == 4:
		conds.append(cond(" 我 们 还 坚 持 输 出 革 命 的 方 针", func(): return soc(w, c(w, 1), true)))
	else:
		conds.append(cond(" 我 们 还 坚 持 输 出 革 命 的 方 针", func(): return mod(w, 6) and soc(w, c(w, 1), true)))
	conds.append(cond(" 至 少 有 3 百 万 预 算 ， 3 特 工 网 络 和 3 军 事 力 量",
		func(): return d(w, 8) + d(w, 36) >= 30 and d(w, 9) >= 30 and d(w, 22) >= 30))
	conds.append(cond(" 每 年 一 次", func(): return c33 != null and not c33.内战中))
	var eff := func():
		set_d(w, 8, d(w, 8) - 30)
		set_d(w, 9, d(w, 9) - 30)
		set_d(w, 22, d(w, 22) - 30)
		if c33 != null:
			c33.influence_china += 10
			c33.内战中 = true
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1062
# DBS Show L5228-L5240 / OnMouseDown L12354-L12357
# ════════════════════════════════════════════════════════════════════════════
func _def_1062(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 要 巴 拿 马 ， 不 要 第 五 十 二 颗 星 星 ！"
	var conds: Array = []
	conds.append(cond(" 美 国 已 衰 落 或 遭 受 了 耻 辱 性 的 大 败",
		func(): return _panama_1062_usa_fallen(w)))
	conds.append(cond(" 中 国 影 响 力 高 于500", func(): return w.influence_prc >= 5000))
	conds.append(cond(" 巴 拿 马 ， 哥 伦 比 亚 和 尼 加 拉 瓜 亲 中",
		func(): return has(c(w, 141), "亲中") and has(c(w, 147), "亲中") and has(c(w, 75), "亲中")))
	conds.append(cond(" 尚 未 接 管 运 河", func(): return parts(c(w, 141), 1)))
	var eff := func():
		set_parts(c(w, 141), 1, false)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1063
# DBS Show L5241-L5247 / OnMouseDown L12358-L12363
# ════════════════════════════════════════════════════════════════════════════
func _def_1063(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 和 我 们 的 欧 洲 伙 伴 一 起 取 长 补 短"
	var conds: Array = []
	conds.append(cond(" 已 签 订 东 方 申 根 协 定", func(): return res(w, 464) == 1 or res(w, 464) == 0))
	var eff := func():
		# 原版 number_event=671 → 本项目 event_id 为 event_671。
		start_event_num(w, 671)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1064
# DBS Show L5248-L5260 / OnMouseDown L12364-L12371
# ════════════════════════════════════════════════════════════════════════════
func _def_1064(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 邀 请 玛 格 丽 特 · 撒 切 尔 首 相 访 问 天 国 ， 同 上 帝 来 一 场 亲 密 会 晤 。"
	var conds: Array = []
	conds.append(cond(" 英 国 保 守 党 在1983 年 大 选 之 后 继 续 执 政",
		func(): return ev(w, 406) and c(w, 92) != null and c(w, 92).sub_government == GameConstants.SubGovernment.NEOLIBERAL))
	conds.append(cond(" 北 爱 尔 兰 未 独 立",
		func(): return not parts(c(w, 29), 0) and not parts(c(w, 166), 0)))
	conds.append(cond(" 已 研 究 现 代 特 勤 科 技 ， 至 少10 预 算20 特 工",
		func(): return _sci(w, 20) and d(w, 8) >= 100 and d(w, 9) >= 200))
	conds.append(cond(" 尚 未 邀 请", func(): return not ev(w, 673)))
	var eff := func():
		set_d(w, 8, d(w, 8) - 100)
		set_d(w, 9, d(w, 9) - 200)
		# 原版 number_event=673 → 本项目 event_id 为 event_673。
		start_event_num(w, 673)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1065
# DBS Show L5261-L5281 / OnMouseDown L12372-L12379
# ════════════════════════════════════════════════════════════════════════════
func _def_1065(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 背 靠 国 际 盟 友 支 持 ， 将 大 不 列 颠 共 产 党 与 《 英 国 通 向 社 会 主 义 之 路 》 带 入 左 翼 政 治 议 程 。 "
	var conds: Array = []
	conds.append(cond(" 英 国 已 加 入 欧 社 联 与 欧 社 联 内 至 少 有5 个 国 家",
		func(): return has(c(w, 92), "soc_eu") and _soc_eu_count(w) >= 5))
	conds.append(cond(" 工 党 “ 软 左 派 ” 当 政", func(): return d(w, 147) == 3))
	conds.append(cond(" 至 少8 预 算5 特 工", func(): return d(w, 8) + d(w, 36) >= 80 and d(w, 9) >= 50))
	conds.append(cond(" 尚 未 推 动", func(): return c(w, 92) != null and c(w, 92).sub_government != GameConstants.SubGovernment.EUROCOMMUNIST))
	var eff := func():
		set_d(w, 8, d(w, 8) - 80)
		set_d(w, 9, d(w, 9) - 50)
		var c92 := c(w, 92)
		if c92 != null:
			c92.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
			c92.set_tag("亲中", true)
		w.influence_prc += 10
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1066
# DBS Show L5282-L5307 / OnMouseDown L12380-L12406
# ════════════════════════════════════════════════════════════════════════════
func _def_1066(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := ""
	if res(w, 677) == 4:
		opis = " 为 我 们 所 支 持 的 派 系 送 去 支 持|BICO 力 量 ：" + str(d(w, 166)) \
			+ "其 他 组 织 ：" + str(d(w, 162) + d(w, 163) + d(w, 164) + d(w, 165))
	else:
		opis = " 为 我 们 所 支 持 的 派 系 送 去 支 持|正 式 派 力 量 ：" + str(d(w, 162)) \
			+ "临 时 派 力 量 ：" + str(d(w, 163)) \
			+ "共 和 社 会 党 力 量 ：" + str(d(w, 164)) \
			+ "亲 英 武 装 力 量 ：" + str(d(w, 165))
	var conds: Array = []
	conds.append(cond(" 至 少2 预 算2 特 工4 军 力",
		func(): return d(w, 8) + d(w, 36) >= 20 and d(w, 9) >= 20 and d(w, 22) >= 40))
	conds.append(cond(" 每 月 一 次", func(): return d(w, 168) == 0))
	var eff := func():
		var r677 := res(w, 677)
		if r677 == 0:
			set_d(w, 162, d(w, 162) + 5)
		elif r677 == 1:
			set_d(w, 163, d(w, 163) + 5)
		elif r677 == 2:
			set_d(w, 164, d(w, 164) + 5)
		elif r677 == 3:
			set_d(w, 165, d(w, 165) + 5)
		elif r677 == 4:
			set_d(w, 166, d(w, 166) + 5)
		set_d(w, 168, 1)
		set_d(w, 8, d(w, 8) - 20)
		set_d(w, 9, d(w, 9) - 20)
		set_d(w, 22, d(w, 22) - 40)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1067
# DBS Show L5308-L5318 / OnMouseDown L12407-L12415
# ════════════════════════════════════════════════════════════════════════════
func _def_1067(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 推 进 爱 尔 兰 和 平 统 一"
	var conds: Array = []
	conds.append(cond(" 北 约 与 欧 共 体 已 经 解 散",
		func(): return not has(c(w, 51), "nato") and not has(c(w, 0), "eu")))
	conds.append(cond(" 爱 尔 兰 是 左 翼 政 权",
		func(): return soc(w, c(w, 29), true) or (c(w, 29) != null and c(w, 29).government == GameConstants.Government.REFORMIST)))
	conds.append(cond(" 尚 未 统 一", func(): return not parts(c(w, 29), 0)))
	var eff := func():
		set_parts(c(w, 166), 0, false)
		var c29 := c(w, 29)
		if c29 != null:
			c29.内战中 = true
			set_parts(c29, 0, true)
			c29.leave_alliances()
			c29.set_tag("亲中", true)
			c29.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1068
# DBS Show L5319-L5351 / OnMouseDown L12416-L12435
# ════════════════════════════════════════════════════════════════════════════
func _def_1068(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c166 := c(w, 166)
	if c166 != null and c166.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST and has(c166, "亲中"):
		var opis := " 推 动 新 芬 工 人 党 强 硬 派 与 爱 尔 兰 共 产 党 、 爱 尔 兰 工 党 、 新 芬 党 等 的 联 合 阵 线 夺 得 爱 尔 兰 共 和 国 主 导 权 ， 以 最 终 与 北 方 共 同 走 向 3 2 郡 的 社 会 主 义 共 和 国"
		var conds: Array = []
		conds.append(cond(" 英 国 法 国 西 班 牙 葡 萄 牙 均 已 选 择 社 会 主 义",
			func(): return _western_europe_socialist_1068(w)))
		conds.append(cond(" 北 爱 尔 兰 是 “ 正 式 派 ”", func(): return c166 != null and c166.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST))
		conds.append(cond(" 尚 未 推 动", func(): return c(w, 29) != null and c(w, 29).sub_government != GameConstants.SubGovernment.STATE_SOCIALIST))
		var eff := func():
			set_d(w, 8, d(w, 8) - 80)
			set_d(w, 9, d(w, 9) - 50)
			var c29 := c(w, 29)
			if c29 != null:
				c29.government = GameConstants.Government.SOCIALIST
				c29.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				c29.leave_alliances()
		return make_def(caption, opis, conds, eff)
	if has(c(w, 85), "soc_eu"):
		var opis := " 推 动 新 芬 工 人 党 内 的 改 良 主 义 者 进 一 步 接 纳 欧 洲 共 产 主 义 纲 领 ， 夺 得 爱 尔 兰 共 和 国 主 导 权"
		var conds: Array = []
		conds.append(cond(" 欧 社 联 内 至 少 有 五 个 国 家", func(): return _soc_eu_count(w) >= 5))
		conds.append(cond(" 北 爱 尔 兰 未 独 立", func(): return not parts(c(w, 166), 0)))
		conds.append(cond(" 尚 未 推 动", func(): return not has(c(w, 29), "soc_eu")))
		var eff := func():
			set_d(w, 8, d(w, 8) - 80)
			set_d(w, 9, d(w, 9) - 50)
			var c29 := c(w, 29)
			if c29 != null:
				c29.government = GameConstants.Government.REFORMIST
				c29.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
				c29.leave_alliances()
				c29.set_tag("soc_eu", true)
		return make_def(caption, opis, conds, eff)
	return {}


# ════════════════════════════════════════════════════════════════════════════
# 编号 1069
# DBS Show L5352-L5370 / OnMouseDown L12436-L12470
# ════════════════════════════════════════════════════════════════════════════
func _def_1069(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 为 当 地 的 亲 中 派 政 治 团 体 提 供 政 治 援 助\n" + _power_pair(country)
	var conds: Array = []
	conds.append(cond(" 至 少 需 要 8 百 万 预 算 ， 4 特 工",
		func(): return d(w, 8) + d(w, 36) >= 80 and d(w, 9) >= 40))
	conds.append(cond(" 一 月 一 次", func(): return country.stab == 0))
	var eff := func():
		country.stab = 100
		set_d(w, 8, d(w, 8) - 80)
		set_d(w, 9, d(w, 9) - 40)
		add_rel(w, 1, -40)
		country.prc_power += 100
		country.sov_power -= 50
		if country.prc_power >= 1000:
			_apply_prc_dominance(w, country)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1070
# DBS Show L5371-L5389 / OnMouseDown L12471-L12505
# ════════════════════════════════════════════════════════════════════════════
func _def_1070(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 抹 黑 该 国 境 内 的 亲 苏 组 织 ， 并 对 相 关 团 体 组 织 恐 怖 袭 击\n" + _power_pair(country)
	var conds: Array = []
	conds.append(cond(" 至 少 需 要 8 军 力 ， 4 特 工",
		func(): return d(w, 22) >= 80 and d(w, 9) >= 40))
	conds.append(cond(" 一 月 一 次", func(): return country.special == 0))
	var eff := func():
		country.special = 100
		set_d(w, 22, d(w, 22) - 80)
		set_d(w, 9, d(w, 9) - 40)
		add_rel(w, 1, -60)
		country.prc_power += 50
		country.sov_power -= 100
		if country.prc_power >= 1000:
			_apply_prc_dominance(w, country)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1071
# DBS Show L5390-L5412 / OnMouseDown L12506-L12513
# ════════════════════════════════════════════════════════════════════════════
func _def_1071(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 同 该 国 政 府 签 署 互 助 协 定 ， 促 进 双 边 深 度 合 作\n" + _power_pair(country)
	var conds: Array = []
	conds.append(cond(" 需 要 3 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 30))
	conds.append(cond(" 该 国 已 向 我 国 看 齐", func(): return has(country, "亲中")))
	conds.append(cond(" 苏 联 对 该 国 的 影 响 力 低 于25.0", func(): return country.sov_power < 250))
	conds.append(cond(" 还 未 签 署 互 助 协 定", func(): return not has(country, "econ")))
	var eff := func():
		country.set_tag("econ", true)
		set_d(w, 8, d(w, 8) - 30)
		add_rel(w, 1, -50)
		w.influence_prc += 20
		country.sov_power -= 150
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1072
# DBS Show L5413-L5435 / OnMouseDown L12514-L12521
# ════════════════════════════════════════════════════════════════════════════
func _def_1072(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 同 该 国 政 府 签 署 安 保 条 约 ， 保 护 该 国 不 受 境 外 势 力 演 变 威 胁\n" + _power_pair(country)
	var conds: Array = []
	conds.append(cond(" 需 要 3 百 万 预 算", func(): return d(w, 22) >= 30))
	conds.append(cond(" 该 国 已 向 我 国 看 齐", func(): return has(country, "亲中")))
	conds.append(cond(" 苏 联 对 该 国 的 影 响 力 低 于10.0", func(): return country.sov_power < 100))
	conds.append(cond(" 还 未 签 署 安 保 条 约", func(): return not has(country, "okb")))
	var eff := func():
		country.set_tag("okb", true)
		set_d(w, 22, d(w, 22) - 30)
		add_rel(w, 1, -100)
		w.influence_prc += 20
		country.sov_power = 0
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1074
# DBS Show L5449-L5455 / OnMouseDown L12529-L12538
# ════════════════════════════════════════════════════════════════════════════
func _def_1074(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 邀 请 该 国 加 入 欧 洲 社 会 主 义 联 盟 ， 推 进 建 设 人 道 、 民 主 的 社 会 主 义"
	var conds: Array = []
	conds.append(cond(" 还 未 邀 请", func(): return not has(country, "soc_eu")))
	var eff := func():
		var c94 := c(w, 94)
		if c94 == null:
			return
		c94.leave_alliances()
		if not c94.内战中:
			c94.set_tag("对华贸易", true)
		c94.set_tag("soc_eu", true)
		w.influence_prc += 5
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1075
# DBS Show L5456-L5462 / OnMouseDown L12539-L12544
# ════════════════════════════════════════════════════════════════════════════
func _def_1075(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 承 认 北 塞 浦 路 斯 政 权 ， 这 将 是 土 耳 其 “ 国 家 主 义 ” 的 一 大 步"
	var conds: Array = []
	conds.append(cond(" 尚 未 承 认", func(): return c(w, 94) != null and not c(w, 94).内战中))
	var eff := func():
		var c94 := c(w, 94)
		if c94 != null:
			c94.内战中 = true
			c94.set_tag("对华贸易", false)
		var c45 := c(w, 45)
		if c45 != null:
			c45.set_tag("对华贸易", false)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1076
# DBS Show L5463-L5475 / OnMouseDown L12545-L12550
# ════════════════════════════════════════════════════════════════════════════
func _def_1076(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 支 持 魁 北 克 分 离 主 义 者 ， 为 裂 土 封 疆 做 准 备"
	var conds: Array = []
	conds.append(cond(" 至 少5 百 万 预 算 ，20 特 工", func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 200))
	conds.append(cond(" 未 与 加 拿 大 建 立 合 作 伙 伴 关 系", func(): return not has(c(w, 137), "对华贸易")))
	conds.append(cond(" 魁 北 克 问 题 仍 悬 而 未 决", func(): return not ev(w, 702)))
	conds.append(cond(" 尚 未 支 持", func(): return c(w, 167) != null and not c(w, 167).内战中))
	var eff := func():
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 200)
		var c167 := c(w, 167)
		if c167 != null:
			c167.内战中 = true
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1077
# DBS Show L5476-L5488 / OnMouseDown L12551-L12556
# ════════════════════════════════════════════════════════════════════════════
func _def_1077(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 让 我 们 给 美 帝 国 主 义 的 “ 第 51 个 州 ” 一 点 颜 色 瞧 瞧"
	var conds: Array = []
	conds.append(cond(" 美 国 霸 权 已 然 落 幕", func(): return not has(c(w, 51), "nato")))
	conds.append(cond(" 中 国 国 际 影 响 力 不 低 于90", func(): return w.influence_prc >= 900))
	conds.append(cond(" 1984 年9 月 后",
		func(): return (d(w, 21) >= 1984 and d(w, 20) >= 9) or d(w, 21) >= 1985))
	conds.append(cond(" 英 国 君 主 制 已 终 结", func(): return c(w, 92) != null and c(w, 92).sub_government == GameConstants.SubGovernment.STATE_SOCIALIST))
	var eff := func():
		# 原版 number_event=704 → SceneManager.LoadScene("Event")；event_704 资源已就位。
		start_event_num(w, 704)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1078
# DBS Show L5489-L5499 / OnMouseDown L12557-L12565
# ════════════════════════════════════════════════════════════════════════════
func _def_1078(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 促 使 激 进 派 在 伊 拉 克 共 产 党 内 夺 取 权 力"
	var conds: Array = []
	conds.append(cond(" 5 百 万 预 算 ， 4 特 工", func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 40))
	conds.append(cond(" 1978 年 7 月 前", func(): return not ev(w, 36)))
	conds.append(cond(" 尚 未 夺 权", func(): return c(w, 14) != null and not c(w, 14).有驻军基地))
	var eff := func():
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 40)
		w.influence_prc += 10
		add_power(w, 1, -20)
		add_rel(w, 1, -50)
		var c14 := c(w, 14)
		if c14 != null:
			c14.有驻军基地 = true
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1079
# DBS Show L5500-L5508 / OnMouseDown L12566-L12578
# ════════════════════════════════════════════════════════════════════════════
func _def_1079(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var opis := " 和 伊 拉 克 盟 友 一 起 接 管 富 饶 的 产 油 国 ， 武 装 保 卫 我 国 的 生 命 线"
	var conds: Array = []
	conds.append(cond(" 10 百 万 预 算 ， 10 军 力", func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 22) >= 100))
	conds.append(cond(" 尚 未 接 管", func(): return country.puppet_of != GameConstants.LegacySlot.IRAQ))
	var eff := func():
		set_d(w, 8, d(w, 8) - 100)
		set_d(w, 22, d(w, 22) - 100)
		w.oil_prod += 100.0
		country.leave_alliances()
		country.puppet_of = GameConstants.LegacySlot.IRAQ
		country.government = GameConstants.Government.AUTHORITARIAN
		country.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
		country.set_tag("亲中", true)
		country.set_tag("对华贸易", true)
		join_all_our_alliances(w, country, true)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 1080
# DBS Show L5509-L5519 / OnMouseDown L12579-L12584
# ════════════════════════════════════════════════════════════════════════════
func _def_1080(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 让 我 们 与 安 哥 拉 同 志 签 订 石 油 贸 易 协 定 ， 这 对 我 们 双 方 都 有 好 处"
	var conds: Array = []
	conds.append(cond(" 3 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 30))
	conds.append(cond(" 安 哥 拉 亲 中", func(): return has(country, "亲中")))
	conds.append(cond(" 三 月 一 次", func(): return country == null or not country.有驻军基地))
	var eff := func():
		set_d(w, 8, d(w, 8) - 30)
		w.oil_prod += 150.0
		var c123 := c(w, 123)
		if c123 != null:
			c123.有驻军基地 = true
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 编号 5000
# DBS Show L5520-L5538 / OnMouseDown L12585-L12589
# 与 国家面板.gd L1057-L1119 已有实现保持一致；本批使用 ctx["caption"] 作为按钮文案。
# ════════════════════════════════════════════════════════════════════════════
func _def_5000(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var player := w.get_player_country()
	var conds: Array = []
	# uslovie[0]：event_done[548]（DBS L5524）
	conds.append(cond(" 已 建 立 革 命 国 际", func(): return ev(w, 548)))
	# 列表级守卫（CS L550 等）：中国已入革命国际
	conds.append(cond("中 国 已 加 入 革 命 国 际", func(): return player != null and player.has_tag("rim")))
	# uslovie[1]：非 gkchp / gkchp 两分支（DBS L5528 / L5533）。
	# is_gkchp 按规范用 WorldState.global_flags["is_gkchp"]（默认 false=原版默认值）。
	if not w.get_flag("is_gkchp"):
		conds.append(cond(" 该 国 已 建 立 革 命 的 政 权", func(): return _rim5000_regime_check(w, country)))
	else:
		conds.append(cond(" 该 国 愿 意 认 可 我 们", func():
			return ((country.sub_government == GameConstants.SubGovernment.LEFT_RADICAL or country.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST
					or country.sub_government == GameConstants.SubGovernment.MAOIST or country.sub_government == GameConstants.SubGovernment.MARXIST_LENINIST)
				and not has(country, "sev") and not has(country, "ovd")
				and has(country, "亲中"))))
	# 列表级守卫（CS L550 等）：目标亲中
	conds.append(cond(" 该 国 持 亲 中 立 场", func(): return has(country, "亲中")))
	# uslovie[2]：!isRIM（DBS L5536）
	conds.append(cond(" 尚 未 加 入", func(): return not has(country, "rim")))
	var eff := func():
		w.influence_prc += 50
		country.set_tag("rim", true)
	var def := make_def(caption, " 邀 请 该 国 加 入 革 命 国 际 主 义 运 动 ， 为 争 得 新 世 界 而 战 ！", conds, eff)
	def["dormant"] = true
	return def


# ════════════════════════════════════════════════════════════════════════════
# 编号 5001
# DBS Show L5539-L5551 / OnMouseDown L12590-L12594
# 与 国家面板.gd L1097-L1119 已有实现保持一致；本批使用 ctx["caption"] 作为按钮文案。
# ════════════════════════════════════════════════════════════════════════════
func _def_5001(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	# uslovie[0]：event_done[500]（DBS L5543）
	conds.append(cond(" 非 洲 联 盟 已 建 立", func(): return ev(w, 500)))
	# 列表级守卫（CS L2679 等）：目标社会主义 且 亲中
	conds.append(cond(" 该 国 是 社 会 主 义 政 权", func(): return soc(w, country, true)))
	conds.append(cond(" 该 国 持 亲 中 立 场", func(): return has(country, "亲中")))
	# uslovie[1]：data.army>=20（DBS L5545）
	conds.append(cond(" 至 少 2 军 事 实 力", func(): return d(w, 22) >= 20))
	# uslovie[2]：!isAU（DBS L5547）
	conds.append(cond(" 他 们 未 加 入 非 洲 联 盟", func(): return not has(country, "au")))
	# uslovie[3]：data.diplomatic_reputation>790（DBS L5549）
	conds.append(cond(" 外 交 声 誉 高 于 79", func(): return d(w, 6) > 790))
	var eff := func():
		w.influence_prc += 30
		country.set_tag("au", true)
	var def := make_def(caption, " 邀 请 该 国 加 入 非 洲 联 盟 ，投 身 于 非 洲 革 命 与 解 放 的 伟 大 事 业 中", conds, eff)
	def["dormant"] = true
	return def


# ════════════════════════════════════════════════════════════════════════════
# 编号 10000
# DBS Show L5552-L5563 / OnMouseDown L12595-L12600
# ════════════════════════════════════════════════════════════════════════════
func _def_10000(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 再 次 协 商 重 建 第 四 国 际 事 宜"
	var conds: Array = []
	conds.append(cond(" 已 宣 布 将 复 兴 第 四 国 际", func(): return ev(w, 407)))
	conds.append(cond(" 我 国 体 制 为 社 会 主 义", func(): return c(w, 1) != null and c(w, 1).government == GameConstants.Government.SOCIALIST))
	conds.append(cond(" 还 未 重 建 第 四 国 际", func(): return not mod(w, 49)))
	var eff := func():
		start_event_num(w, 407)
	return make_def(caption, opis, conds, eff)


# ════════════════════════════════════════════════════════════════════════════
# 静态自检结果（Python 脚本，写入时生成）：
#   - 文件 UTF-8 可读：OK
#   - 全部使用 tab 缩进、无行首空格：OK
#   - 31 个编号在 build_action 中均有 match 分支：OK
#   - 每个 func 括号平衡（() [] {}）：OK
#   - 无裸 W 引用（代码区）：OK
#   - 无分号语句：OK
#   - cond 调用数（代码区）：126
# ════════════════════════════════════════════════════════════════════════════
