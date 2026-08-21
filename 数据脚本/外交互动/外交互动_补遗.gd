## 外交互动 补遗 — 审计发现的 19 个缺失动作定义（DiploButtonScript.cs 中文分支）。
## 源码出处：DiploButtonScript.cs Show/OnMouseDown，每个函数头标注行号。
## 与批1-6 同构：build_action 分发 + _def_N 定义，基类提供 cond/make_def/d/c/set_d 等助手。
extends "res://数据脚本/外交互动/外交互动_基础.gd"

const W = preload("res://数据脚本/world_state.gd")


# build_action 统一放在文件末尾（全部 _def_* 定义之后），避免前向引用。


# ============================================================================
# 编号 12 · 在其党内煽动亲华派势力政变
# DBS Show L446-L465 / OnMouseDown L8862-L8871
# ============================================================================
func _def_12(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	conds.append(cond(" 至 少 10 特 工 网 络 和 8 百 万 预 算", func(): return d(w, W.I_AGENTS) >= 100 and d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 80))
	conds.append(cond(" 外 交 声 誉 高 于 69", func(): return d(w, W.I_DIPLO) > 690))
	conds.append(cond(" 已 经 引 发 动 乱", func(): return country.stability != 0))
	# 原版 puppetOf==7 分支的检查恒为 false，仅文案不同（DBS L456-L463）。
	if country.puppet_of != 7:
		conds.append(cond(" 没 有 煽 动 政 变", func(): return not country.has_tag("亲中")))
	else:
		conds.append(cond(" 没 有 被 苏 联 傀 儡", func(): return false))
	var eff := func():
		var ussr := emp(w, 1)
		if ussr != null:
			ussr.relations -= 50
			ussr.power -= 200
		set_d(w, W.I_INFLUENCE, d(w, W.I_INFLUENCE) + 20)
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 100)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 80)
		var mongolia := c(w, 9)
		if mongolia != null:
			mongolia.set_tag("亲苏", false)
			mongolia.set_tag("亲中", true)
	return make_def(caption, " 在 其 党 内 煽 动 亲 华 派 势 力 政 变", conds, eff)


# ============================================================================
# 编号 20 · 派遣解放军增援前线
# DBS Show L664-L681 / OnMouseDown L8977-L8982
# ============================================================================
func _def_20(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	var idx: int = W.I_WAR_PRESSURE if country.原版序号 == 11 else W.I_INDIA_WAR_PRESSURE
	var strength: int = d(w, idx)
	@warning_ignore("integer_division")
	var opis := " 派 遣 解 放 军 增 援 前 线| 我 方 军 力 强 度 ：%d.%d" % [strength / 10, abs(strength % 10)]
	conds.append(cond(" 与 越 南 爆 发 战 争", func(): return w.war_state == GameConstants.WarState.SINO_SOVIET))
	conds.append(cond(" 至 少 7 军 事 实 力", func(): return d(w, W.I_ARMY) >= 70))
	conds.append(cond(" 本 月 增 兵 未 达 三 次", func(): return country.stability != 3))
	var eff := func():
		set_d(w, idx, d(w, idx) + 100)
		set_d(w, W.I_ARMY, d(w, W.I_ARMY) - 50)
		country.stability += 1
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 21 · 在争取权力的和平斗争中支持我们所选择的势力
# DBS Show L683-L695 / OnMouseDown L8983-L9006
# ============================================================================
func _def_21(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	# 原版 DRAagree 仅开局置 false、全工程无置 true 点；此处保留同语义的 flag 读取口。
	conds.append(cond(" 同 阿 富 汗 和 苏 联 达 成 了 协 议", func(): return w.get_flag("DRAagree")))
	conds.append(cond(" 至 少 4 特 工 网 络", func(): return d(w, W.I_AGENTS) >= 40))
	conds.append(cond(" 至 少 3 百 万 预 算", func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 30))
	conds.append(cond(" 本 年 尚 未 支 持", func(): return country.stability == 0))
	var eff := func():
		if country.development == 0:
			set_d(w, W.I_AFGHAN_OPPOSITION, d(w, W.I_AFGHAN_OPPOSITION) + 100)
		elif country.development == 1:
			set_d(w, W.I_MANPOWER, d(w, W.I_MANPOWER) + 100)
		elif country.development == 2:
			# 原版此处写 empires[1].now_leader += 100（DBS L8997），逐字保留。
			var ussr := emp(w, 1)
			if ussr != null:
				ussr.current_leader += 100
		else:
			set_d(w, W.I_ALBANIA_BREAK, d(w, W.I_ALBANIA_BREAK) + 100)
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 40)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 30)
		country.stability = 1
	return make_def(caption, " 在 争 取 权 力 的 和 平 斗 争 中 支 持 我 们 所 选 择 的 势 力", conds, eff)


# ============================================================================
# 编号 37 · 挑起军事政变，以推翻波尔布特
# DBS Show L1344-L1356 / OnMouseDown L9283-L9290
# ============================================================================
func _def_37(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	conds.append(cond(" 柬 埔 寨 持 亲 中 立 场", func(): return country.has_tag("亲中")))
	conds.append(cond(" 毛 主 席 已 离 世", func(): return GameManager.is_mao_dead()))
	conds.append(cond(" 尚 未 挑 起 军 事 政 变", func(): return country.stability == 0 and country.government != GameConstants.Government.SOCIALIST))
	conds.append(cond(" 至 少 3 特 工 网 络 和 3 百 万 预 算", func(): return d(w, W.I_BUDGET) + d(w, W.I_AGENTS) >= 30))
	var eff := func():
		country.government = GameConstants.Government.SOCIALIST
		country.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		country.stability = 1
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 30)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 30)
	return make_def(caption, " 挑 起 军 事 政 变 ， 以 推 翻 波 尔 布 特", conds, eff)


# ============================================================================
# 编号 47 · 为双边关系正常化搭建磋商平台
# DBS Show L1502-L1517 / OnMouseDown L9403-L9409
# ============================================================================
func _def_47(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	# LeaderProperty[2] && IsSocialism(false) 时阈值放宽（DBS L1508-1511）。
	if w.leader_property.size() > 2 and w.leader_property[2] and soc(w, country, false):
		conds.append(cond(" 外 交 声 誉 低 于 11451.4", func(): return d(w, W.I_DIPLO) < 114514))
	else:
		conds.append(cond(" 外 交 声 誉 低 于 55", func(): return d(w, W.I_DIPLO) < 550))
	var usa_trade := c(w, 51)
	conds.append(cond("已 与 美 国 签 署 友 好 合 作 协 定", func(): return usa_trade != null and usa_trade.has_tag("对华贸易")))
	conds.append(cond(" 尚 未 进 行 磋 商", func(): return not country.has_tag("对华贸易")))
	var eff := func():
		var usa := emp(w, 0)
		if usa != null:
			usa.relations += 200
			usa.power += 10
		set_d(w, W.I_INFLUENCE, d(w, W.I_INFLUENCE) - 10)
		country.set_tag("对华贸易", true)
	return make_def(caption, " 为 双 边 关 系 正 常 化 搭 建 磋 商 平 台", conds, eff)


# ============================================================================
# 编号 69 · 同当地共产主义者建立联系并给予支持
# DBS Show L881-L894 / OnMouseDown L9043-L9047
# ============================================================================
func _def_69(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	conds.append(cond(" 外 交 声 誉 高 于 79", func(): return d(w, W.I_DIPLO) > 790))
	conds.append(cond(" 至 少 3 特 工 网 络", func(): return d(w, W.I_AGENTS) >= 30))
	conds.append(cond(" 萨 达 姆 正 大 肆 镇 压 共 产 主 义 者", func(): return ev(w, 3)))
	conds.append(cond(" 尚 未 提 供 支 持", func(): return country.stability == 0))
	var eff := func():
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 30)
		country.stability = 1
	return make_def(caption, " 同 当 地 共 产 主 义 者 建 立 联 系 并 给 予 支 持", conds, eff)


# ============================================================================
# 编号 83 · 通过挑动政变以坚实友方势力
# DBS Show L2188-L2198 / OnMouseDown L9890-L9915
# ============================================================================
func _def_83(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	conds.append(cond(" 亲 中", func(): return country.has_tag("亲中")))
	conds.append(cond(" 该 国 为 自 由 主 义", func(): return country.government == GameConstants.Government.REFORMIST))
	conds.append(cond(" 拥 有 5 百 万 预 算 ，5 特 工 网 络 ，5 军 事 实 力",
		func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 50 and d(w, W.I_AGENTS) >= 50 and d(w, W.I_ARMY) >= 50))
	var eff := func():
		var usa := emp(w, 0)
		var ussr := emp(w, 1)
		if country.has_tag("亲美"):
			if usa != null:
				usa.power -= 10
				usa.relations -= 150
		elif country.has_tag("亲苏"):
			if ussr != null:
				ussr.power -= 10
				ussr.relations -= 150
		country.set_tag("亲美", false)
		country.set_tag("亲苏", false)
		country.set_tag("亲中", true)
		country.set_tag("对华贸易", true)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 50)
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 50)
		set_d(w, W.I_ARMY, d(w, W.I_ARMY) - 50)
		set_d(w, W.I_INFLUENCE, d(w, W.I_INFLUENCE) + 5)
		if usa != null:
			usa.power -= 10
			usa.relations -= 250
		country.sub_government = _sub_gosstory(w)
		var china := c(w, 1)
		if china != null:
			country.government = china.government
		country.next_election_year = 2222
		country.next_election_month = 2
		country.next_election_day = 22
	return make_def(caption, " 通 过 挑 动 政 变 以 坚 实 友 方 势 力", conds, eff)


# ============================================================================
# 编号 109 · 发动反政府的激进派起义
# DBS Show L2671-L2683 / OnMouseDown L10123-L10131
# ============================================================================
func _def_109(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	conds.append(cond(" 拥 有 15 百 万 资 金", func(): return d(w, W.I_AGENTS) >= 150))
	conds.append(cond(" 军 事 实 力 15", func(): return d(w, W.I_ARMY) >= 150))
	conds.append(cond(" 恐 怖 组 织 实 力 ： 100.0", func(): return d(w, 134) >= 1000))
	var usa := emp(w, 0)
	var ussr := emp(w, 1)
	conds.append(cond(" 还 未 策 动 起 义 ， 且 美 苏 影 响 力 之 和 低 于 35.0",
		func(): return not ev(w, 396) and (usa.power if usa != null else 0) + (ussr.power if ussr != null else 0) < 350))
	var eff := func():
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 150)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 150)
		var italy := c(w, 85)
		if italy != null:
			italy.有驻军基地 = true
		start_event_num(w, 396)
	return make_def(caption, " 发 动 反 政 府 的 激 进 派 起 义", conds, eff)


# ============================================================================
# 编号 112 · 邀请该国参与我国军事联盟
# DBS Show L2735-L2745 / OnMouseDown L10196-L10206
# ============================================================================
func _def_112(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	conds.append(cond(" 他 们 已 经 是 经 合 组 织 或 经 互 会 的 一 员",
		func(): return country.has_tag("sev") or country.has_tag("econ")))
	conds.append(cond(" 该 国 已 经 是 中 国 势 力 范 围 ， 并 与 中 国 建 立 了 贸 易 关 系",
		func(): return country.has_tag("对华贸易") and country.has_tag("亲中")))
	conds.append(cond(" 他 们 还 未 加 入 军 事 联 盟 ， 集 体 安 全 组 织 已 建 立 ， 或 中 国 已 加 入 华 沙 条 约",
		func():
			var china := c(w, 1)
			return not country.has_tag("okb") and not country.has_tag("ovd") \
				and china != null and (china.has_tag("ovd") or china.has_tag("okb"))))
	var eff := func():
		var china := c(w, 1)
		if china != null and china.has_tag("okb"):
			country.set_tag("okb", true)
		else:
			country.set_tag("ovd", true)
	return make_def(caption, " 邀 请 该 国 参 与 我 国 军 事 联 盟 ， 实 现 合 作 无 上 限 ， 保 障 地 区 安 全 稳 定", conds, eff)


# ============================================================================
# 编号 129 · 施压该国并迫使其退出东南亚国家联盟
# DBS Show L3053-L3071 / OnMouseDown L10625-L10653
# ============================================================================
func _def_129(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	conds.append(cond(" 泰 国 、 越 南 与 菲 律 宾 均 加 入 单 一 经 济 联 盟",
		func():
			var all_econ := _tag_all(w, [1, 11, 34, 47], "econ")
			var all_sev := _tag_all(w, [1, 11, 34, 47], "sev")
			var all_asean := _tag_all(w, [1, 11, 34, 47], "asean")
			return all_econ or all_sev or all_asean))
	var china := c(w, 1)
	conds.append(cond(" 我 国 未 加 入 东 南 亚 国 家 联 盟", func(): return china != null and not china.has_tag("asean")))
	var c49 := c(w, 49)
	conds.append(cond(" 该 国 为 东 南 亚 国 家 联 盟 成 员 国", func(): return c49 != null and c49.has_tag("asean")))
	if china != null and china.has_tag("sev"):
		conds.append(cond(" 中 苏 全 球 影 响 力 之 和 高 于 30.0 ， 且 拥 有 15 百 万 预 算",
			func():
				var ussr := emp(w, 1)
				return d(w, W.I_INFLUENCE) + (ussr.power if ussr != null else 0) >= 300 \
					and d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 150))
	else:
		conds.append(cond(" 中 国 全 球 影 响 力 高 于 30.0 ， 且 拥 有 15 百 万 预 算",
			func(): return d(w, W.I_INFLUENCE) >= 300 and d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 150))
	var eff := func():
		if c49 != null:
			c49.set_tag("asean", false)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 150)
		if c49 != null:
			var ussr := emp(w, 1)
			if china != null and china.has_tag("sev") and ussr != null and ussr.power > d(w, W.I_INFLUENCE):
				c49.set_tag("亲苏", true)
				ussr.power += 40
				var c7 := c(w, 7)
				if c7 != null:
					c49.government = c7.government
					c49.sub_government = c7.sub_government
			else:
				c49.set_tag("亲中", true)
				set_d(w, W.I_INFLUENCE, d(w, W.I_INFLUENCE) + 40)
				if china != null:
					c49.government = china.government
					c49.sub_government = china.sub_government
	return make_def(caption, " 施 压 该 国 并 迫 使 其 退 出 东 南 亚 国 家 联 盟", conds, eff)


# ============================================================================
# 编号 139 · 承认阿拉伯撒哈拉民主共和国的独立并送去援助
# DBS Show L3325-L3335 / OnMouseDown L10931-L10950
# ============================================================================
func _def_139(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds := _sahara_conds(w)
	var eff := func():
		var egypt := c(w, 18)
		if egypt == null:
			return
		egypt.set_tag("对华贸易", true)
		egypt.special = 1
		var china := c(w, 1)
		if china != null:
			egypt.government = china.government
			egypt.sub_government = china.sub_government
		egypt.name = "西 撒 哈 拉"
		set_d(w, W.I_INFLUENCE, d(w, W.I_INFLUENCE) + 20)
		var usa := emp(w, 0)
		var ussr := emp(w, 1)
		if usa != null:
			usa.relations -= 150
		if ussr != null:
			ussr.relations -= 150
		egypt.set_tag("亲中", true)
		_sahara_alliance(w, egypt)
	return make_def(caption, " 承 认 阿 拉 伯 撒 哈 拉 民 主 共 和 国 的 独 立 并 送 去 援 助", conds, eff)


# ============================================================================
# 编号 140 · 承认西撒哈拉属于摩洛哥并送去援助
# DBS Show L3337-L3347 / OnMouseDown L10951-L10971
# ============================================================================
func _def_140(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds := _sahara_conds(w)
	var eff := func():
		var ethiopia := c(w, 54)
		if ethiopia == null:
			return
		ethiopia.禁用非洲机制 = true
		ethiopia.set_tag("对华贸易", true)
		var egypt := c(w, 18)
		if egypt != null:
			egypt.special = 1
		var china := c(w, 1)
		if china != null:
			ethiopia.government = china.government
			ethiopia.sub_government = china.sub_government
		set_d(w, W.I_INFLUENCE, d(w, W.I_INFLUENCE) + 20)
		var usa := emp(w, 0)
		var ussr := emp(w, 1)
		if usa != null:
			usa.relations -= 150
		if ussr != null:
			ussr.relations -= 150
		ethiopia.set_tag("亲中", true)
		if ethiopia.parts.size() > 0:
			ethiopia.parts[0] = true
		_sahara_alliance(w, ethiopia)
	return make_def(caption, " 承 认 西 撒 哈 拉 属 于 摩 洛 哥 并 送 去 援 助", conds, eff)


# ============================================================================
# 编号 141 · 承认西撒哈拉属于毛里塔尼亚并送去援助
# DBS Show L3349-L3359 / OnMouseDown L10972-L10992
# ============================================================================
func _def_141(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds := _sahara_conds(w)
	var eff := func():
		var somalia := c(w, 59)
		if somalia == null:
			return
		somalia.禁用非洲机制 = true
		somalia.set_tag("对华贸易", true)
		var egypt := c(w, 18)
		if egypt != null:
			egypt.special = 1
		var china := c(w, 1)
		if china != null:
			somalia.government = china.government
			somalia.sub_government = china.sub_government
		set_d(w, W.I_INFLUENCE, d(w, W.I_INFLUENCE) + 20)
		var usa := emp(w, 0)
		var ussr := emp(w, 1)
		if usa != null:
			usa.relations -= 150
		if ussr != null:
			ussr.relations -= 150
		somalia.set_tag("亲中", true)
		if somalia.parts.size() > 0:
			somalia.parts[0] = true
		_sahara_alliance(w, somalia)
	return make_def(caption, " 承 认 西 撒 哈 拉 属 于 毛 里 塔 尼 亚 并 送 去 援 助", conds, eff)


# ============================================================================
# 编号 147 · 组织新加坡民主派推翻右翼独裁体制
# DBS Show L3555-L3567 / OnMouseDown L11136-L11150
# ============================================================================
func _def_147(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	conds.append(cond(" 10 百 万 预 算", func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 100))
	conds.append(cond(" 5 特 工 网 络 与 10 军 事 实 力", func(): return d(w, W.I_AGENTS) >= 50 and d(w, W.I_ARMY) >= 100))
	conds.append(cond(" 引 入 制 裁", func(): return country.stability > 0))
	conds.append(cond(" 还 未 推 翻 独 裁 体 制", func(): return country.special <= 0))
	var eff := func():
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 50)
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 100)
		set_d(w, W.I_ARMY, d(w, W.I_ARMY) - 100)
		set_d(w, W.I_INFLUENCE, d(w, W.I_INFLUENCE) + 80)
		country.establish_government(2)
		country.set_tag("对华贸易", true)
		country.stability = 0
		country.special = 1
		country.government = GameConstants.Government.REFORMIST
		country.sub_government = GameConstants.SubGovernment.PRAGMATIST
		var usa := emp(w, 0)
		if usa != null:
			usa.relations -= 300
			usa.power -= 30
	return make_def(caption, " 组 织 新 加 坡 民 主 派 推 翻 右 翼 独 裁 体 制", conds, eff)


# ============================================================================
# 编号 1011 · 煽动罗马尼亚局势，推翻“吸血鬼”的统治
# DBS Show L3788-L3800 / OnMouseDown L11446-L11452
# ============================================================================
func _def_1011(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	conds.append(cond(" 尚 未 掀 起 罗 马 尼 亚 革 命", func(): return not ev(w, 490)))
	conds.append(cond(" 10 百 万 预 算 和 5 特 工 网 络", func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 100 and d(w, W.I_AGENTS) >= 50))
	conds.append(cond(" 晚 于 1 9 8 3 年", func(): return w.date.year >= 1983))
	var romania := c(w, 5)
	conds.append(cond(" 已 联 络 罗 马 尼 亚 反 对 派", func(): return romania != null and romania.special > 0))
	var eff := func():
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 100)
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 50)
		start_event_num(w, 490)
	return make_def(caption, " 煽 动 罗 马 尼 亚 局 势 ， 推 翻 “ 吸 血 鬼 ” 的 统 治", conds, eff)


# ============================================================================
# 编号 1012 · 秘密联络米利塔鲁与流亡海外的反对派，促成联合
# DBS Show L3771-L3786 / OnMouseDown L11453-L11465
# ============================================================================
func _def_1012(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var china := c(w, 1)
	var opis := " 秘 密 联 络 米 利 塔 鲁 与 流 亡 海 外 的 伊 利 埃 斯 库 ， 促 成 联 合 。"
	if china != null and (china.government == GameConstants.Government.AUTHORITARIAN or china.government == GameConstants.Government.SOCIALIST):
		opis = " 秘 密 联 络 米 利 塔 鲁 与 流 亡 海 外 的 阿 波 斯 托 尔 ， 促 成 联 合 。"
	var conds: Array = []
	var romania := c(w, 5)
	conds.append(cond(" 还 未 促 成 联 合", func(): return romania == null or romania.special <= 0))
	conds.append(cond(" 5 百 万 预 算 和 10 特 工 网 络",
		func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 50 and d(w, W.I_AGENTS) >= 100))
	var eff := func():
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 50)
		set_d(w, W.I_AGENTS, d(w, W.I_AGENTS) - 100)
		if romania != null:
			romania.special = 1 if (china != null and (china.government == GameConstants.Government.AUTHORITARIAN or china.government == GameConstants.Government.SOCIALIST)) else 2
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1055 · 发动圣战 / 发动革命
# DBS Show L4992-L5024 / OnMouseDown L12267-L12280
# ============================================================================
func _def_1055(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var nigeria := c(w, 60)
	var conds: Array = []
	var opis := ""
	if nigeria != null and nigeria.内战中:
		opis = " 发 动 圣 战"
		conds.append(cond(" 力 量 大 于 100", func(): return nigeria.prc_power >= 100))
		conds.append(cond("尼 日 利 亚 选 举 已 经 尘 埃 落 地", func(): return ev(w, 655)))
		conds.append(cond(" 尚 未 发 动", func(): return not ev(w, 657)))
	else:
		opis = " 发 动 革 命"
		conds.append(cond(" 力 量 大 于 100", func(): return nigeria != null and nigeria.prc_power >= 100))
		conds.append(cond("尼 日 利 亚 选 举 已 经 尘 埃 落 地", func(): return ev(w, 655)))
		conds.append(cond(" 尼 日 利 亚 不 是 民 选 左 翼 政 府 且 西 非 至 少 有5 个 社 会 主 义 国 家",
			func(): return nigeria != null and nigeria.government != GameConstants.Government.REFORMIST and _west_africa_socialist_count(w) >= 5))
		conds.append(cond(" 尚 未 发 动", func(): return not ev(w, 656)))
	var eff := func():
		if nigeria != null and nigeria.内战中:
			start_event_num(w, 657)
		else:
			start_event_num(w, 656)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1073 · 同墨西哥政府达成协议，将托洛茨基流散海外的各项遗产运至中国
# DBS Show L5436-L5447 / OnMouseDown L12522-L12528
# ============================================================================
func _def_1073(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var conds: Array = []
	conds.append(cond(" 墨 西 哥 对 我 国 持 积 极 态 度",
		func(): return country.has_tag("亲中") or (country.has_tag("对华贸易") and not w.is_authoritarian(country))))
	conds.append(cond(" 墨 西 哥 国 内 局 势 稳 定",
		func(): return not _war_going_c(w, 45) and not _war_going_c(w, 46) and not _war_going_c(w, 47)))
	var usa := emp(w, 0)
	conds.append(cond(" 与 美 国 的 关 系 高 于 50.0", func(): return usa != null and usa.relations > 500))
	var china := c(w, 1)
	conds.append(cond(" 中 国 正 奉 行 托 洛 茨 基 主 义", func(): return china != null and china.sub_government == GameConstants.SubGovernment.TROTSKYIST))
	var eff := func():
		set_d(w, W.I_BUDGET, d(w, W.I_BUDGET) - 20)
		start_event_num(w, 691)
	return make_def(caption, " 同 墨 西 哥 政 府 达 成 协 议 ， 将 托 洛 茨 基 流 散 海 外 的 各 项 遗 产 运 至 中 国", conds, eff)


# ============================================================================
# 编号 10001 · 短剑力量（仅显示无点击效果，DBS Show L5564-L5594）
# ============================================================================
func _def_10001(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	if country == null:
		return {}
	var italy := c(w, 85)
	var opis := "短剑力量%d" % d(w, 182)
	if not ev(w, 556):
		opis += "早饭事件未触发"
	if not ev(w, 396):
		opis += "早饭2事件未触发"
	if italy != null and (italy.influence_china > 0 or w.get_flag("VasilyisGay") or italy.sub_government == GameConstants.SubGovernment.MODERATE):
		opis += "政府符合"
	if d(w, 182) > 6:
		opis += "短剑力量符合"
	if d(w, 182) > 6:
		opis += "短剑力量符合"
	var conds: Array = []
	conds.append(cond(" 已 宣 布 将 复 兴 第 四 国 际", func(): return ev(w, 407)))
	var china := c(w, 1)
	conds.append(cond(" 我 国 体 制 为 社 会 主 义", func(): return china != null and china.government == GameConstants.Government.SOCIALIST))
	conds.append(cond(" 还 未 重 建 第 四 国 际", func(): return not mod(w, 49)))
	var eff := func():
		pass
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 公共助手
# ============================================================================

## 139/140/141 共用条件（DBS L3327-3334 / L3339-3346 / L3351-3358）。
func _sahara_conds(w: WorldState) -> Array:
	var conds: Array = []
	conds.append(cond(" 中 国 的 全 球 影 响 力 高 于 美 苏 影 响 力 之 和 或 中 国 的 全 球 影 响 力 高 于 80.0",
		func():
			var usa := emp(w, 0)
			var ussr := emp(w, 1)
			var powers: int = (usa.power if usa != null else 0) + (ussr.power if ussr != null else 0)
			return d(w, W.I_INFLUENCE) >= powers or d(w, W.I_INFLUENCE) >= 800))
	conds.append(cond(" 15 百 万 预 算", func(): return d(w, W.I_BUDGET) + d(w, W.I_RESERVE) >= 150))
	var egypt := c(w, 18)
	conds.append(cond(" 西 撒 哈 拉 问 题 仍 未 被 解 决", func(): return egypt == null or egypt.special <= 0))
	return conds


func _sahara_alliance(w: WorldState, target: CountryData) -> void:
	var china := c(w, 1)
	if china == null or target == null:
		return
	if china.has_tag("sev"):
		target.set_tag("sev", true)
	elif china.has_tag("econ"):
		target.set_tag("econ", true)


func _tag_all(w: WorldState, indices: Array, tag: String) -> bool:
	for idx in indices:
		var cc := c(w, int(idx))
		if cc == null or not cc.has_tag(tag):
			return false
	return true


## 1055 西非社会主义国家计数（DBS L5006-5013）。
func _west_africa_socialist_count(w: WorldState) -> int:
	var count := 0
	for idx in [59, 112, 113, 114, 68, 107, 67, 64, 63, 62, 108, 61, 56, 58]:
		var cc := c(w, idx)
		if cc != null and w.is_socialism(cc, true):
			count += 1
	return count


func _war_going_c(w: WorldState, idx: int) -> bool:
	if idx < 0 or idx >= w.wars.size():
		return false
	var war_data: WarData = w.wars[idx]
	return war_data != null and war_data.is_going


# ============================================================================
# 公共助手
# ============================================================================

## 数值表安全读取（越界按 0，与原版 int 默认一致）。
func _data_at(darr: WorldState, idx: int) -> int:
	return darr.get_data_by_index(idx) if darr.size() > idx else 0


## 原版 GameState.GetSubGosstory()（GameState.cs:7409-7435）。
func _sub_gosstory(w: WorldState) -> int:
	var darr: WorldState = w
	var china := c(w, 1)
	if _data_at(darr, W.I_IDEOLOGY) <= 2 and _data_at(darr, W.I_ECON_SYSTEM) < 13 \
			and _data_at(darr, W.I_DIPLO) >= 700 and _data_at(darr, W.I_PARTY_SYSTEM) < 8:
		return 0
	if _data_at(darr, W.I_IDEOLOGY) <= 3 and _data_at(darr, W.I_ECON_SYSTEM) <= 13 \
			and _data_at(darr, W.I_DIPLO) >= 500:
		return _rng(w, 1, 4)
	if _data_at(darr, W.I_IDEOLOGY) >= 2 and _data_at(darr, W.I_ECON_SYSTEM) >= 13 \
			and _data_at(darr, W.I_DIPLO) <= 700 \
			and _data_at(darr, W.I_PARTY_SYSTEM) >= 8 and _data_at(darr, W.I_PRESS_POLICY) >= 18 \
			and china != null and not china.has_tag("ovd"):
		return _rng(w, 4, 7)
	if china != null and not china.has_tag("sev"):
		return 7
	return 8


## 动作分发（必须置于全部 _def_* 之后）。
func build_action(action_type: int, ctx: Dictionary) -> Dictionary:
	var w: WorldState = ctx.get("w")
	var country: CountryData = ctx.get("country")
	var caption: String = ctx.get("caption", "")
	match action_type:
		12:
			return _def_12(w, country, caption)
		20:
			return _def_20(w, country, caption)
		21:
			return _def_21(w, country, caption)
		37:
			return _def_37(w, country, caption)
		47:
			return _def_47(w, country, caption)
		69:
			return _def_69(w, country, caption)
		83:
			return _def_83(w, country, caption)
		109:
			return _def_109(w, country, caption)
		112:
			return _def_112(w, country, caption)
		129:
			return _def_129(w, country, caption)
		139:
			return _def_139(w, country, caption)
		140:
			return _def_140(w, country, caption)
		141:
			return _def_141(w, country, caption)
		147:
			return _def_147(w, country, caption)
		1011:
			return _def_1011(w, country, caption)
		1012:
			return _def_1012(w, country, caption)
		1055:
			return _def_1055(w, country, caption)
		1073:
			return _def_1073(w, country, caption)
		10001:
			return _def_10001(w, country, caption)
	return {}
