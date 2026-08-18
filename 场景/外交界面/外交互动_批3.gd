## 外交互动 批3 — 编号 76, 77, 78, 79, 80, 81, 89, 102, 108, 116, 121, 135, 136, 137, 138, 142, 143, 144, 148, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1013, 1014, 1015, 1016。
## 源码出处：DiploButtonScript.cs（Show 中文分支 L30-L5624；OnMouseDown L8596-L12715）。
## 本批行号区间按《外交互动批3_源码行号.json》；caption 一律来自 ctx["caption"]，不得自造。
extends "res://场景/外交界面/外交互动_基础.gd"


## 主分发：返回 {caption, opis, conditions, effect, dormant} 或 {}。
func build_action(action_type: int, ctx: Dictionary) -> Dictionary:
	var w: WorldState = ctx.get("w")
	var _darr: Array = ctx.get("d", [])
	var country: CountryData = ctx.get("country")
	var caption: String = ctx.get("caption", "")
	match action_type:
		76:
			return _def_76(w, country, caption)
		77:
			return _def_77(w, country, caption)
		78:
			return _def_78(w, country, caption)
		79:
			return _def_79(w, country, caption)
		80:
			return _def_80(w, country, caption)
		81:
			return _def_81(w, country, caption)
		89:
			return _def_89(w, country, caption)
		102:
			return _def_102(w, country, caption)
		108:
			return _def_108(w, country, caption)
		116:
			return _def_116(w, country, caption)
		121:
			return _def_121(w, country, caption)
		135:
			return _def_135(w, country, caption)
		136:
			return _def_136(w, country, caption)
		137:
			return _def_137(w, country, caption)
		138:
			return _def_138(w, country, caption)
		142:
			return _def_142(w, country, caption)
		143:
			return _def_143(w, country, caption)
		144:
			return _def_144(w, country, caption)
		148:
			return _def_148(w, country, caption)
		1000:
			return _def_1000(w, country, caption)
		1001:
			return _def_1001(w, country, caption)
		1002:
			return _def_1002(w, country, caption)
		1003:
			return _def_1003(w, country, caption)
		1004:
			return _def_1004(w, country, caption)
		1005:
			return _def_1005(w, country, caption)
		1006:
			return _def_1006(w, country, caption)
		1007:
			return _def_1007(w, country, caption)
		1008:
			return _def_1008(w, country, caption)
		1009:
			return _def_1009(w, country, caption)
		1010:
			return _def_1010(w, country, caption)
		1013:
			return _def_1013(w, country, caption)
		1014:
			return _def_1014(w, country, caption)
		1015:
			return _def_1015(w, country, caption)
		1016:
			return _def_1016(w, country, caption)
	return {}


# ============================================================================
# 编号 76 · 对当地金融运转和债务流通施行优待政策
# DiploButtonScript Show L984-993 / OnMouseDown L9066-9069
# ============================================================================
func _def_76(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 对 当 地 金 融 运 转 和 债 务 流 通 施 行 优 待 政 策"
	var conds: Array = []
	conds.append(cond(" 储 备 金 －20 百 万", func(): return d(w, 36) >= 200))
	conds.append(cond(" 尚 未 施 行 帮 扶 政 策", func(): return not country.内战中))
	var eff := func():
		country.内战中 = true
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 77 · 针对民族分离主义政府组织不留血政变
# DiploButtonScript Show L994-1008 / OnMouseDown L9070-9074
# ============================================================================
func _def_77(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := "针 对 民 族 分 离 主 义 政 府| 组 织 不 留 血 政 变"
	opis += "|Our influence: " + str(country.development) + "%"
	var conds: Array = []
	conds.append(cond(" 经 济 上 紧 密 联 结", func(): return country.内战中))
	conds.append(cond(" 尚 未 组 织 罢 免", func(): return not has(country, "对华贸易")))
	conds.append(cond(" 我 们 对 当 地 的 影 响 力 达 到 30", func(): return country.development >= 30))
	conds.append(cond(" 特 工 网 络 －8", func(): return d(w, 9) >= 80))
	var eff := func():
		set_tag(country, "对华贸易", true)
		set_d(w, 9, d(w, 9) - 80)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 78 · 在此设立军事基地以保护主权不受侵害
# DiploButtonScript Show L1009-1023 / OnMouseDown L9075-9080
# ============================================================================
func _def_78(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 在 此 设 立 军 事 基 地 以 保 护 主 权 不 受 侵 害"
	opis += "| 我 们 的 影 响 力 ：" + str(country.development) + "%"
	var conds: Array = []
	conds.append(cond(" 尚 未 设 立 军 事 基 地", func(): return not has(country, "亲中")))
	conds.append(cond(" 民 族 分 离 主 义 政 府 被 罢 免", func(): return has(country, "对华贸易")))
	conds.append(cond(" 我 们 对 当 地 的 影 响 力 达 到 60", func(): return country.development >= 60))
	conds.append(cond(" 特 工 网 络 －6 ， 军 事 实 力 －10", func(): return d(w, 9) >= 60 and d(w, 22) >= 100))
	var eff := func():
		set_tag(country, "亲中", true)
		set_d(w, 9, d(w, 9) - 60)
		set_d(w, 22, d(w, 22) - 100)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 79 · 在当地组织一场呼吁回归祖国的公投
# DiploButtonScript Show L1024-1036 / OnMouseDown L9081-9106
# ============================================================================
func _def_79(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 在 当 地 组 织 一 场 呼 吁 回 归 祖 国 的 公 投"
	opis += "| 我 们 的 影 响 力 ：" + str(country.development) + "%"
	var conds: Array = []
	conds.append(cond(" 在 此 设 有 军 事 基 地", func(): return has(country, "亲中")))
	conds.append(cond(" 我 们 对 当 地 的 影 响 力 达 到 100", func(): return country.development >= 100))
	conds.append(cond(" 特 工 网 络 - 8", func(): return d(w, 9) >= 80))
	var eff := func():
		country.government = 0
		country.内战中 = false
		set_tag(country, "对华贸易", false)
		set_tag(country, "亲中", false)
		set_tag(country, "亲苏", false)
		set_tag(country, "亲美", false)
		country.development = 0
		set_d(w, 57, d(w, 57) + 200)
		set_d(w, 9, d(w, 9) - 80)
		w.influence_prc += 10
		if country.原版序号 == 70:
			set_ev(w, 10, false)
			set_d(w, 66, 0)
			set_parts(c(w, 1), 9, false)
		elif country.原版序号 == 69:
			set_ev(w, 9, false)
			set_d(w, 67, 0)
			set_parts(c(w, 1), 7, false)
			set_parts(c(w, 1), 8, false)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 80 · 参照我国制度整饬他们的政体
# DiploButtonScript Show L1037-1079 / OnMouseDown L9107-9135
# ============================================================================
func _def_80(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var c1 := c(w, 1)
	var sub_ch := chinese_sub_gosstroy(w)
	var opis := " 参 照 我 国 制 度 整 饬 他 们 的 政 体"
	if sub_ch < 19:
		# CountryData.IDEOLOGY 已按 other_text 索引映射（sub<10→idx+13，10..17→idx+82，18→182）。
		opis += "| 当 前 我 国 政 体 为 ：" + str(CountryData.IDEOLOGY.get(sub_ch, ""))
	elif sub_ch == 20:
		opis += "| 当 前 我 国 政 体 为 ：宪 政 威 权 主 义"
	elif sub_ch == 21:
		opis += "| 当 前 我 国 政 体 为 ：革 新 社 会 主 义"
	elif sub_ch == 22:
		opis += "| 当 前 我 国 政 体 为 ：革 命 民 族 主 义"
	var conds: Array = []
	var proprc := has(country, "亲中")
	var prosov := has(country, "亲苏")
	var vyshi := has(country, "亲美")
	var c1_okb := c1 != null and has(c1, "okb")
	if c1_okb and proprc and country.sub_government != sub_ch:
		conds.append(cond(" 我 们 的 国 体 不 一 致", func(): return country.sub_government != sub_ch))
	elif c1_okb and (not proprc or prosov or vyshi):
		conds.append(cond(" 不 在 我 们 影 响 下", func(): return not proprc or prosov or vyshi))
	else:
		conds.append(cond(" 我 们 有 自 己 的 军 事 同 盟", func(): return c1 != null and has(c1, "okb")))
	conds.append(cond(" 预 算 ： 5", func(): return d(w, 8) + d(w, 36) >= 50))
	conds.append(cond(" 特 工 网 络 ： 5", func(): return d(w, 9) >= 50))
	conds.append(cond(" 军 事 实 力 ： 5", func(): return d(w, 22) >= 50))
	var eff := func():
		country.social_stability += 250
		if not has(country, "美国盟友") and not has(country, "苏联盟友"):
			set_tag(country, "美国盟友", false)
			set_tag(country, "苏联盟友", false)
			country.social_stability -= 500
		set_tag(country, "亲苏", false)
		set_tag(country, "亲美", false)
		set_tag(country, "苏联盟友", false)
		set_tag(country, "美国盟友", false)
		country.establish_government(2)
		set_tag(country, "亲中", true)
		if country.puppet_of != 1:
			country.puppet_of = -1
		if c1 != null:
			country.government = c1.government
			country.sub_government = sub_ch
		else:
			# allcountries[1] 缺失时原版会空引用；Godot 做空安全跳过政体复制。
			pass
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 50)
		set_d(w, 22, d(w, 22) - 50)
		if country.原版序号 == 14 or country.原版序号 == 8:
			set_d(w, 117, 0)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 81 · 向苏联人转售科技
# DiploButtonScript Show L970-983 / OnMouseDown L9144-9151
# ============================================================================
func _def_81(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 向 苏 联 人 转 售 科 技"
	var conds: Array = []
	conds.append(cond(" 至 少 10 科 研 点", func(): return d(w, 11) >= 100))
	conds.append(cond(" 是 经 互 会 的 观 察 员 国 或 成 员 国", func(): return has(c(w, 1), "sev") or has(c(w, 7), "对华贸易")))
	conds.append(cond(" 苏 联 的 世 界 影 响 力 低 于 60", func(): return power(w, 1) < 600))
	conds.append(cond(" 已 与 美 国 签 署 友 好 合 作 协 定", func(): return has(c(w, 51), "对华贸易")))
	var eff := func():
		set_d(w, 11, d(w, 11) - 100)
		set_d(w, 1, d(w, 1) - 50)
		set_d(w, 8, d(w, 8) + 5)
		add_power(w, 1, 2)
		add_rel(w, 0, -25)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 89 · 以我国投资为筹码，收回藏南地区
# DiploButtonScript Show L1182-1193 / OnMouseDown L9219-9226
# ============================================================================
func _def_89(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 以 我 国 投 资 为 筹 码 ， 收 回 藏 南 地 区 "
	var conds: Array = []
	conds.append(cond(" 中 国 的 世 界 影 响 力 不 低 于 50", func(): return w.influence_prc >= 500))
	conds.append(cond(" 至 少 25 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 250))
	conds.append(cond(" 领 土 争 端 仍 悬 而 未 决", func(): return w.get_flag("cb_india")))
	var eff := func():
		w.set_flag("cb_india", false)
		set_d(w, 62, 3)
		# 原版 allcountries[1].ILoveSuckCocks() 刷新地图 parts；Godot 用等价 helper。
		_refresh_china_map_parts(w, c(w, 1))
		set_d(w, 8, d(w, 8) - 250)
		# map1.UpdateMap() 由外交动作执行后的 GameManager.notify_stats_changed() 承担。
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 102 · 深化经贸关系
# DiploButtonScript Show L2496-2554 / OnMouseDown L10064-10067
# ============================================================================
func _def_102(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 深 化 经 贸 关 系"
	var conds: Array = []
	var proprc := has(country, "亲中")
	var leader_prop2 := w.leader_property.size() > 2 and w.leader_property[2]
	if leader_prop2 and soc(w, country, false):
		conds.append(cond(" 外 交 声 誉 低 于 11451.4", func(): return d(w, 6) < 114514))
	elif not proprc:
		if soc(w, country, true):
			conds.append(cond(" 外 交 声 誉 高 于 69", func(): return d(w, 6) >= 690))
		elif country.government <= 2:
			conds.append(cond(" 外 交 声 誉 在 39 到 85 之 间", func(): return d(w, 6) > 390 and d(w, 6) < 850))
		elif country.government == 3:
			conds.append(cond(" 外 交 声 誉 低 于 50", func(): return d(w, 6) < 500))
		conds.append(cond(" 尚 未 深 化 经 贸 关 系", func(): return not has(country, "对华贸易")))
		conds.append(cond(" 工 业 不 低 于 50", func(): return d(w, 12) >= 500))
		conds.append(cond(" 也 门 已 经 统 一", func(): return parts(country, 0)))  # other_text[117]
	else:
		if country.government == 1:
			conds.append(cond(" 外 交 声 誉 高 于 69", func(): return d(w, 6) >= 690))
		elif country.government <= 2:
			conds.append(cond(" 外 交 声 誉 在 39 到 85 之 间", func(): return d(w, 6) > 390 and d(w, 6) < 850))
		elif country.government == 3:
			conds.append(cond(" 外 交 声 誉 低 于 50", func(): return d(w, 6) < 500))
		conds.append(cond(" 尚 未 深 化 经 贸 关 系", func(): return not has(country, "对华贸易")))
		conds.append(cond(" 工 业 不 低 于 50", func(): return d(w, 12) >= 500))
	var eff := func():
		set_tag(country, "对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 108 · 强化意大利国内的恐怖主义网络
# DiploButtonScript Show L2663-2670 / OnMouseDown L10116-10122
# ============================================================================
func _def_108(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := "强 化 意 大 利 国 内 的 恐 怖 主 义 网 络 %s 恐 怖 组 织 实 力 ：%d" % ["\n", d(w, 134)]
	var conds: Array = []
	conds.append(cond(" 预 算 不 少 于 4百万 ，特 工 网 络 不 少 于 2 ，军 事 力 量 不 少 于 2",
		func(): return d(w, 8) + d(w, 36) >= 40 and d(w, 9) >= 20 and d(w, 22) >= 20))
	var eff := func():
		set_d(w, 9, d(w, 9) - 20)
		set_d(w, 8, d(w, 8) - 40)
		set_d(w, 22, d(w, 22) - 20)
		set_d(w, 134, d(w, 134) + 10)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 116 · 让我们一劳永逸的解决两德之间的问题
# DiploButtonScript Show L2785-2798 / OnMouseDown L10226-10231
# ============================================================================
func _def_116(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 让 我 们 一 劳 永 逸 的 解 决 两 德 之 间 的 问 题"
	var conds: Array = []
	conds.append(cond(" 两 德 尚 未 统 一", func(): return res(w, 484) == 3 or not ev(w, 484)))
	conds.append(cond(" 1985 年 后", func(): return d(w, 21) >= 1985))
	conds.append(cond(" 中 国 影 响 力 大 于 80", func(): return w.influence_prc >= 800))
	conds.append(cond(" 西 德 没 有 处 于 军 事 管 制", func(): return c(w, 17) != null and c(w, 17).government != 0))
	var eff := func():
		start_event_num(w, 484)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 121 · 允许该国加入我国经济联盟（东南亚/经互会分支）
# DiploButtonScript Show L2879-2931 / OnMouseDown L10327-10356
# ============================================================================
func _def_121(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var is_24 := country.原版序号 == 24
	var proprc := has(country, "亲中")
	var opis: String
	if is_24:
		if not proprc:
			opis = " 允 许 该 国 加 入 经 互 会"  # other_text[218]
		else:
			opis = " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系"
	elif not proprc:
		opis = " 邀 请 该 国 加 入 东 南 亚 国 家 联 盟 与 泛 亚 联 盟"  # other_text[206]
	else:
		opis = " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系"
	var conds: Array = []
	conds.append(cond(" 已 深 化 经 贸 关 系", func(): return has(country, "对华贸易")))  # other_text[83]
	if is_24:
		if not proprc:
			conds.append(cond(" 中 国 已 加 入 经 互 会", func(): return has(c(w, 1), "sev")))  # other_text[220]
		else:
			conds.append(cond(" 中 国 已 建 立 经 济 联 盟", func(): return has(c(w, 1), "econ")))
	elif not proprc:
		conds.append(cond(" 我 们 是 东 南 亚 国 家 联 盟 成 员 国", func(): return has(c(w, 1), "asean")))  # other_text[203]
	else:
		conds.append(cond(" 中 国 已 建 立 经 济 联 盟", func(): return has(c(w, 1), "econ")))
	conds.append(cond(" 他 们 还 未 加 入 经 济 联 盟",  # other_text[88]
		func(): return not has(country, "asean") and not has(country, "sev") and not has(country, "econ")))
	conds.append(cond(" 该 国 已 经 统 一", func(): return parts(country, 0)))  # other_text[219]
	var eff := func():
		if is_24:
			if not proprc:
				add_power(w, 1, 10)
				add_rel(w, 1, 50)
				set_tag(country, "sev", true)
			else:
				w.influence_prc += 10
				add_rel(w, 1, -50)
				set_tag(country, "econ", true)
		elif not proprc:
			add_power(w, 0, 10)
			add_rel(w, 0, 50)
			set_tag(country, "asean", true)
		else:
			w.influence_prc += 10
			add_rel(w, 0, -50)
			set_tag(country, "econ", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 135 · 与史塔西建立/终止合作（革命保卫办公室）
# DiploButtonScript Show L3209-3284 / OnMouseDown L10891-10910
# ============================================================================
func _def_135(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	var c1 := c(w, 1)
	var c1_asean := has(c1, "asean")
	var sci19 := w.techs != null and w.techs.unlocked.size() > 19 and w.techs.unlocked[19]
	var opis: String
	if country.原版序号 == 17:
		opis = " 与 革 命 保 卫 办 公 室 建 立 合 作 关 系"
		conds.append(cond(" 我 国 体 制 为 社 会 主 义 或 该 国 处 于 中 国 势 力 范 围",  # other_text[313]
			func(): return soc(w, c1, true) or has(country, "亲中")))
		conds.append(cond(" 拥 有 科 技 “ 情 报 部 门 新 装 备 ” 且 我 国 未 加 入 东 盟",  # other_text[315]
			func(): return not c1_asean and sci19))
		conds.append(cond(" 未 和 狩 猎 俱 乐 部 合 作", func(): return not mod(w, 41)))
		conds.append(cond(" 还 未 合 作", func(): return not mod(w, 53)))  # other_text[314]
	elif country.原版序号 == 16 and has(country, "亲苏") and not mod(w, 53):
		opis = " 与 史 塔 西 建 立 合 作 关 系"  # other_text[311]
		conds.append(cond(" 与 苏 联 实 现 和 解", func(): return fl(w, "relres")))  # other_text[312]
		conds.append(cond(" 我 国 体 制 为 社 会 主 义 或 该 国 处 于 中 国 势 力 范 围",  # other_text[313]
			func(): return soc(w, c1, true)))
		conds.append(cond(" 拥 有 科 技 “ 情 报 部 门 新 装 备 ” 且 我 国 未 加 入 东 盟",  # other_text[315]
			func(): return not c1_asean and sci19))
		conds.append(cond(" 还 未 合 作", func(): return not mod(w, 41)))  # other_text[314]
	elif country.原版序号 == 16 and has(country, "亲苏"):
		opis = " 终 止 与 史 塔 西 的 合 作"  # other_text[316]
		conds.append(cond(" 正 与 史 塔 西 合 作", func(): return mod(w, 53)))  # other_text[317]
	elif country.原版序号 == 16 and not mod(w, 53):
		opis = " 与 史 塔 西 建 立 合 作 关 系"  # other_text[311]
		conds.append(cond(" 我 国 体 制 为 社 会 主 义 或 该 国 处 于 中 国 势 力 范 围",  # other_text[313]
			func(): return soc(w, c1, true) or has(country, "亲中")))
		conds.append(cond(" 拥 有 科 技 “ 情 报 部 门 新 装 备 ” 且 我 国 未 加 入 东 盟",  # other_text[315]
			func(): return not c1_asean and sci19))
		conds.append(cond(" 还 未 合 作", func(): return not mod(w, 41)))  # other_text[314]
	elif country.原版序号 == 16:
		opis = " 终 止 与 史 塔 西 的 合 作"  # other_text[316]
		conds.append(cond(" 正 与 史 塔 西 合 作", func(): return mod(w, 53)))  # other_text[317]
	elif not mod(w, 53):
		opis = " 与 史 塔 西 建 立 合 作 关 系"  # other_text[311]
		conds.append(cond(" 我 国 体 制 为 社 会 主 义 或 该 国 处 于 中 国 势 力 范 围",  # other_text[313]
			func(): return soc(w, c1, true) or has(country, "亲中")))
		conds.append(cond(" 拥 有 科 技 “ 情 报 部 门 新 装 备 ” 且 我 国 未 加 入 东 盟",  # other_text[315]
			func(): return not c1_asean and sci19))
		conds.append(cond(" 还 未 合 作", func(): return not mod(w, 41)))  # other_text[314]
	else:
		# 原版 type135 当 selected_country 既非 17/16 且 modifies[53].active 时，
		# Show 未设置任何 uslovie（DBS L3270-3282），Godot 侧返回 {} 不显示。
		return {}
	var eff := func():
		if country.原版序号 == 16:
			# 原版 OnMouseDown L10893-10896：country16 分支无条件置 true（不是切换）。
			if w.modifiers.size() > 53:
				w.modifiers[53].is_active = true
		elif not mod(w, 53):
			if w.modifiers.size() > 53:
				w.modifiers[53].is_active = true
			if has(c1, "sev"):
				set_tag(c(w, 16), "对华贸易", true)
		else:
			if w.modifiers.size() > 53:
				w.modifiers[53].is_active = false
			set_tag(c(w, 16), "对华贸易", false)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 136 · 同巴斯克和加泰罗尼亚分离主义者建立联系
# DiploButtonScript Show L3285-3296 / OnMouseDown L10911-10916
# ============================================================================
func _def_136(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 同 巴 斯 克 和 加 泰 罗 尼 亚 分 离 主 义 者 建 立 联 系"  # other_text[318]
	var conds: Array = []
	var c86 := c(w, 86)
	conds.append(cond(" 拥 有 5 百 万 预 算 与 5 特 工 网 络",  # other_text[319]
		func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	conds.append(cond(" 1978 年 11 月 前 夕",  # other_text[320]
		func(): return d(w, 21) < 1978 or (d(w, 21) == 1978 and d(w, 20) < 11)))
	conds.append(cond(" 还 未 建 立 联 系", func(): return c86 == null or not c86.有驻军基地))  # other_text[321]
	var eff := func():
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 50)
		if c86 != null:
			c86.有驻军基地 = true
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 137 · 让我们给这群不知好歹的德国佬一点教训
# DiploButtonScript Show L3297-3310 / OnMouseDown L10917-10924
# ============================================================================
func _def_137(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 让 我 们 给 这 群 不 知 好 歹 的 德 国 佬 一 点 教 训"
	var conds: Array = []
	var c17 := c(w, 17)
	conds.append(cond(" 西 德 没 有 亲 美 的 邻 国",
		func(): return not has(c(w, 0), "亲美") and not has(c(w, 88), "亲美") and not has(c(w, 89), "亲美") and not has(c(w, 90), "亲美")))
	conds.append(cond(" 西 德 尚 未 被 禁 运", func(): return c17 == null or not c17.内战中))
	conds.append(cond(" 欧 共 体 已 解 散", func(): return not has(c(w, 0), "eu")))
	conds.append(cond(" 尚 未 煽 动 西 德 局 势", func(): return not ev(w, 485)))
	var eff := func():
		if c17 != null:
			c17.内战中 = true
		set_d(w, 6, d(w, 6) + 100)
		w.influence_prc -= 20
		if c17 != null:
			c17.government = 0
			c17.sub_government = 7
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 138 · 是时候了，行动！（西德政变）
# DiploButtonScript Show L3311-3324 / OnMouseDown L10925-10930
# ============================================================================
func _def_138(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 是 时 候 了 ， 行 动 ！"
	var conds: Array = []
	conds.append(cond(" 我 们 支 持 过 德 国 的 反 对 派",
		func(): return (ev(w, 486) and res(w, 486) == 0) or res(w, 487) != 0))
	conds.append(cond(" 我 们 有 20 点 军 力 、 2 0 点 特 勤 和 20 点 预 算",
		func(): return d(w, 8) + d(w, 36) >= 200 and d(w, 9) >= 200 and d(w, 22) >= 200))
	conds.append(cond(" 西 德 被 禁 运 中", func(): return c(w, 17) != null and c(w, 17).内战中))
	conds.append(cond(" 政 府 尚 未 被 推 翻", func(): return not ev(w, 485) or res(w, 485) == 3))
	var eff := func():
		start_event_num(w, 485)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 142 · 为安哥拉提供军事援助
# DiploButtonScript Show L3361-3398 / OnMouseDown L10995-11019
# 注：外层 142-144 组还有公共收尾 L11088-11102，本函数一并翻译（见 eff 尾部）。
# ============================================================================
func _def_142(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var c123 := c(w, 123)
	var conds: Array = []
	if country.原版序号 == 123:
		var pp := c123.prc_power if c123 != null else 0
		var sp := c123.sov_power if c123 != null else 0
		var up := c123.usa_power if c123 != null else 0
		@warning_ignore("integer_division")
		var opis := "为 我 们 选 择 了 的 派 系 提 供 军 事 援 助|安 人 运 力 量：%d.%d安 盟 力 量：%d.%d安 解 阵 力 量：%d.%d" % [pp / 10, absi(pp % 10), sp / 10, absi(sp % 10), up / 10, absi(up % 10)]
		conds.append(cond("至 少10 军 事 力 量", func(): return d(w, 22) >= 100))
		conds.append(cond(" 每 3 月 一 次", func(): return c123 != null and c123.sov_influence <= 0))  # other_text[450]
		var eff := func():
			set_d(w, 22, d(w, 22) - 100)
			if c123 != null:
				c123.sov_influence = 3
				if res(w, 638) == 0:
					c123.prc_power += 25
				elif res(w, 638) == 1:
					c123.sov_power += 25
				elif res(w, 638) == 2:
					c123.usa_power += 25
		return make_def(caption, opis, conds, eff)
	var infl := country.influence_china / 10.0
	var opis2 := " 为 %s 提 供 武 器 援 助%s对 该 国 的 影 响 力 ： %.1f" % [country.display_name(), "\n", infl]  # other_text[448]
	conds.append(cond(" 5 军 事 实 力", func(): return d(w, 22) >= 50))  # other_text[449]
	conds.append(cond(" 每 3 月 一 次", func(): return country.sov_influence <= 0))  # other_text[450]
	conds.append(cond(" 对 该 国 的 影 响 力 低 于 100.0", func(): return country.influence_china < 1000))  # other_text[452]
	conds.append(cond(" 海 湾 合 作 委 员 会 已 经 建 立", func(): return ev(w, 418)))  # other_text[451]
	var eff2 := func():
		set_d(w, 22, d(w, 22) - 50)
		country.sov_influence = 3
		# 外层 142-144 组公共收尾（DBS L11088-11102，对 type142/143/144 均执行；type144 按本批规范置空）。
		country.influence_china += 200
		if country.influence_china > 1000:
			country.influence_china = 1000
		if country.influence_china >= 1000:
			w.influence_prc += 10
			add_rel(w, 0, -100)
			add_rel(w, 1, -100)
			set_tag(country, "亲中", true)
	return make_def(caption, opis2, conds, eff2)


# ============================================================================
# 编号 143 · 为安哥拉提供资金援助
# DiploButtonScript Show L3399-3436 / OnMouseDown L11020-11108
# 注：JSON 区间 11020-11108 包含 type144 回落分支与 142-144 组公共收尾；
#     按规范只取 else if (this.this_type == 143) 块（L11020-11044），公共收尾 L11088-11102 一并翻译。
# ============================================================================
func _def_143(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var c123 := c(w, 123)
	var conds: Array = []
	if country.原版序号 == 123:
		var pp := c123.prc_power if c123 != null else 0
		var sp := c123.sov_power if c123 != null else 0
		var up := c123.usa_power if c123 != null else 0
		@warning_ignore("integer_division")
		var opis := "为 我 们 选 择 了 的 派 系 提 供 资 金 援 助|安 人 运 力 量：%d.%d安 盟 力 量：%d.%d安 解 阵 力 量：%d.%d" % [pp / 10, absi(pp % 10), sp / 10, absi(sp % 10), up / 10, absi(up % 10)]
		conds.append(cond("至 少5 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 50))
		conds.append(cond(" 每 3 月 一 次", func(): return c123 != null and c123.usa_influence <= 0))  # other_text[450]
		var eff := func():
			set_d(w, 8, d(w, 8) - 50)
			if c123 != null:
				c123.usa_influence = 3
				if res(w, 638) == 0:
					c123.prc_power += 15
				elif res(w, 638) == 1:
					c123.sov_power += 15
				elif res(w, 638) == 2:
					c123.usa_power += 15
		return make_def(caption, opis, conds, eff)
	var infl := country.influence_china / 10.0
	var opis2 := " 密 切 联 系 %s 王 室%s对 该 国 的 影 响 力 ： %.1f" % [country.display_name(), "\n", infl]  # other_text[453]
	conds.append(cond(" 5 特 工 网 络 ", func(): return d(w, 9) >= 50))  # other_text[454]
	conds.append(cond(" 每 3 月 一 次", func(): return country.usa_influence <= 0))  # other_text[450]
	conds.append(cond(" 对 该 国 的 影 响 力 低 于 100.0", func(): return country.influence_china < 1000))  # other_text[452]
	conds.append(cond(" 海 湾 合 作 委 员 会 已 经 建 立", func(): return ev(w, 418)))  # other_text[451]
	var eff2 := func():
		set_d(w, 9, d(w, 9) - 50)
		country.usa_influence = 3
		# 外层 142-144 组公共收尾（DBS L11088-11102，对 type142/143/144 均执行；type144 按本批规范置空）。
		country.influence_china += 200
		if country.influence_china > 1000:
			country.influence_china = 1000
		if country.influence_china >= 1000:
			w.influence_prc += 10
			add_rel(w, 0, -100)
			add_rel(w, 1, -100)
			set_tag(country, "亲中", true)
	return make_def(caption, opis2, conds, eff2)


# ============================================================================
# 编号 144 · 散播其余派系的黑材料
# DiploButtonScript Show L3437-3476 / OnMouseDown 无
# 说明：原版 OnMouseDown 无独立 type144 的 else if 块；JSON onmouse 为空，
#       按本批规范效果置空 Callable（外层 142-144 组公共收尾不在此实现）。
# ============================================================================
func _def_144(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var c123 := c(w, 123)
	var conds: Array = []
	if country.原版序号 == 123:
		var pp := c123.prc_power if c123 != null else 0
		var sp := c123.sov_power if c123 != null else 0
		var up := c123.usa_power if c123 != null else 0
		@warning_ignore("integer_division")
		var opis := "散 播 其 余 派 系 的 黑 材 料|安 人 运 力 量：%d.%d安 盟 力 量：%d.%d安 解 阵 力 量：%d.%d" % [pp / 10, absi(pp % 10), sp / 10, absi(sp % 10), up / 10, absi(up % 10)]
		conds.append(cond("至 少5 特 工 网 络", func(): return d(w, 9) >= 50))
		conds.append(cond(" 每 3 月 一 次", func(): return c123 != null and c123.prc_influence <= 0))  # other_text[450]
		var empty_eff := func():
			pass
		return make_def(caption, opis, conds, empty_eff)
	var infl := country.influence_china / 10.0
	var opis2 := " 投 资 %s 石 油 生 产%s对 该 国 的 影 响 力 ： %.1f" % [country.display_name(), "\n", infl]  # other_text[455]
	conds.append(cond(" 3 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 30))  # other_text[456]
	conds.append(cond(" 每 3 月 一 次", func(): return country.prc_influence <= 0))  # other_text[450]
	conds.append(cond(" 对 该 国 的 影 响 力 低 于 100.0", func(): return country.influence_china < 1000))  # other_text[452]
	conds.append(cond(" 海 湾 合 作 委 员 会 已 经 建 立", func(): return ev(w, 418)))  # other_text[451]
	var empty_eff2 := func():
		pass
	return make_def(caption, opis2, conds, empty_eff2)


# ============================================================================
# 编号 148 · 欧洲社会主义联盟/扶持欧洲左派（多分支）
# DiploButtonScript Show L3569-3623 / OnMouseDown L11151-11278
# ============================================================================
func _def_148(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var conds: Array = []
	var spain := c(w, 85)
	var france := c(w, 21)
	if spain != null and has(spain, "soc_eu"):
		var opis := " 邀 请 该 国 加 入 欧 洲 社 会 主 义 联 盟 ， 推 进 建 设 人 道 、 民 主 的 社 会 主 义"
		conds.append(cond(" 5 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 50))
		conds.append(cond(" 5 特 工 网 络 ", func(): return d(w, 9) >= 50))
		conds.append(cond(" 北 约 与 欧 共 体 已 不 复 存 在",  # other_text[483]
			func(): return not has(c(w, 0), "nato") and not has(c(w, 0), "eu")))
		conds.append(cond(" 还 未 邀 请", func(): return not has(country, "soc_eu")))
		var eff := func():
			country.leave_alliances()
			set_tag(country, "对华贸易", true)
			set_tag(country, "soc_eu", true)
			country.government = 2
			country.sub_government = 14
			country.内战中 = true
			w.influence_prc += 5
			set_d(w, 8, d(w, 8) - 50)
			set_d(w, 9, d(w, 9) - 50)
		return make_def(caption, opis, conds, eff)
	if france != null and has(france, "fxseu"):
		var opis2 := " 扶 持 当 地 主 权 民 主 主 义 者 并 促 使 其 加 入 欧 洲 社 会 国 家 组 织"
		conds.append(cond(" 5 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 50))
		conds.append(cond(" 5 特 工 网 络 ", func(): return d(w, 9) >= 50))
		conds.append(cond(" 北 约 与 欧 共 体 已 不 复 存 在",  # other_text[483]
			func(): return not has(c(w, 0), "nato") and not has(c(w, 0), "eu")))
		conds.append(cond(" 还 未 邀 请", func(): return not has(country, "fxseu")))
		var eff2 := func():
			country.leave_alliances()
			set_tag(country, "对华贸易", true)
			set_tag(country, "fxseu", true)
			country.government = 0
			country.sub_government = 9
			w.influence_prc += 5
			set_d(w, 8, d(w, 8) - 50)
			set_d(w, 9, d(w, 9) - 50)
		return make_def(caption, opis2, conds, eff2)
	if france != null and has(france, "nazimao"):
		var opis3 := " 扶 持 当 地 革 命 民 族 主 义 者 并 促 使 其 加 入 欧 罗 巴 解 放 阵 线"
		conds.append(cond(" 5 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 50))
		conds.append(cond(" 5 特 工 网 络 ", func(): return d(w, 9) >= 50))
		conds.append(cond(" 北 约 与 欧 共 体 已 不 复 存 在",  # other_text[483]
			func(): return not has(c(w, 0), "nato") and not has(c(w, 0), "eu")))
		conds.append(cond(" 还 未 邀 请", func(): return not has(country, "nazimao")))
		var eff3 := func():
			country.leave_alliances()
			set_tag(country, "对华贸易", true)
			set_tag(country, "nazimao", true)
			country.government = 0
			country.sub_government = 22
			w.influence_prc += 5
			set_d(w, 8, d(w, 8) - 50)
			set_d(w, 9, d(w, 9) - 50)
		return make_def(caption, opis3, conds, eff3)
	var opis4 := " 积 极 支 持 愿 意 同 我 们 合 作 的 当 地 左 派 势 力"  # other_text[479]
	conds.append(cond(" 20 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 200))  # other_text[481]
	conds.append(cond(" 20 特 工 网 络 ", func(): return d(w, 9) >= 200))  # other_text[482]
	conds.append(cond(" 北 约 与 欧 共 体 已 不 复 存 在",  # other_text[483]
		func(): return not has(c(w, 0), "nato") and not has(c(w, 0), "eu")))
	conds.append(cond(" 还 未 支 持", func(): return not country.内战中))  # other_text[484]
	var eff4 := func():
		country.leave_alliances()
		set_tag(country, "亲中", true)
		set_tag(country, "对华贸易", true)
		var num25 := 0
		var num26 := 0
		for idx in [21, 45, 84, 85, 86, 87, 92]:
			var cc := c(w, idx)
			if cc != null and soc(w, cc, true):
				num25 += 1
			if cc != null and cc.government == 2:
				num26 += 1
		var c1 := c(w, 1)
		if num25 >= num26:
			if c1 != null and soc(w, c1, false):
				country.government = 1
				country.sub_government = 1
			else:
				country.government = c1.government if c1 != null else 0
				country.sub_government = c1.sub_government if c1 != null else 0
		elif c1 != null and c1.government != 2:
			country.government = 2
			country.sub_government = 3
		else:
			country.government = c1.government if c1 != null else 2
			country.sub_government = c1.sub_government if c1 != null else 3
		country.内战中 = true
		w.influence_prc += 20
		set_d(w, 8, d(w, 8) - 200)
		set_d(w, 9, d(w, 9) - 200)
	return make_def(caption, opis4, conds, eff4)


# ============================================================================
# 编号 1000 · 挑起政变，以推翻黎笋政权
# DiploButtonScript Show L3637-3650 / OnMouseDown L11377-11382
# ============================================================================
func _def_1000(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 挑 起 政 变 ， 以 推 翻 黎 笋 政 权"
	var conds: Array = []
	conds.append(cond(" 黎 笋 尚 未 被 推 翻", func(): return d(w, 171) != 0))
	conds.append(cond(" 至 少 4 特 工 网 络 和 4 百 万 预 算", func(): return d(w, 8) + d(w, 36) >= 40))
	conds.append(cond(" 该 国 不 受 苏 联 影 响", func(): return not has(country, "亲苏")))
	conds.append(cond(" 我 国 体 制 为 社 会 主 义", func(): return c(w, 1) != null and (c(w, 1).government == 1 or c(w, 1).sub_government == 0)))
	var eff := func():
		start_event_num(w, 535)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1001 · 就戈兰高地的归属问题组织谈判
# DiploButtonScript Show L3651-3662 / OnMouseDown L11383-11388
# ============================================================================
func _def_1001(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 就 戈 兰 高 地 的 归 属 问 题 组 织 谈 判"
	var conds: Array = []
	var israel_lost := w.get_flag("israellost") or w.get_flag("israel_lost_lebanon_war")
	conds.append(cond(" 黎 巴 嫩 战 争 已 结 束",
		func(): return israel_lost or (c(w, 93) != null and c(w, 93).puppet_of == 37)))
	conds.append(cond(" 还 未 组 织 谈 判", func(): return not ev(w, 439) or res(w, 439) == 3))
	conds.append(cond(" 叙 利 亚 不 受 美 国 影 响", func(): return not has(country, "亲美")))
	var eff := func():
		start_event_num(w, 439)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1002 · 尝试利用我们的影响力结束黎巴嫩内战
# DiploButtonScript Show L3663-3674 / OnMouseDown L11389-11394
# ============================================================================
func _def_1002(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 尝 试 利 用 我 们 的 影 响 力 结 束 黎 巴 嫩 内 战"
	var conds: Array = []
	conds.append(cond(" 以 色 列 输 掉 了 黎 巴 嫩 战 争",
		func(): return w.get_flag("israellost") or w.get_flag("israel_lost_lebanon_war")))
	conds.append(cond(" 还 未 组 织 谈 判", func(): return not ev(w, 440)))
	conds.append(cond(" 黎 巴 嫩 不 受 美 国 影 响", func(): return not has(country, "亲美")))
	var eff := func():
		start_event_num(w, 440)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1003 · 支持建制内健康力量反对特拉奥雷
# DiploButtonScript Show L3675-3688 / OnMouseDown L11395-11400
# ============================================================================
func _def_1003(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 支 持 建 制 内 健 康 力 量 反 对 特 拉 奥 雷"
	var conds: Array = []
	conds.append(cond(" 声 誉 大 于 等 于79", func(): return d(w, 6) >= 790))
	conds.append(cond(" 至 少 5 特 工 网 络 和 5 百 万 预 算",
		func(): return d(w, 9) >= 50 and d(w, 8) + d(w, 36) >= 50))
	conds.append(cond(" 没 有 支 持 过", func(): return c(w, 58) == null or not c(w, 58).内战中))
	conds.append(cond(" 趁 我 们 还 来 得 及", func(): return not ev(w, 458)))
	var eff := func():
		set_d(w, 9, d(w, 9) - 50)
		set_d(w, 8, d(w, 8) - 50)
		if c(w, 58) != null:
			c(w, 58).内战中 = true
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1004 · 让马里走向真正的人民民主
# DiploButtonScript Show L3689-3700 / OnMouseDown L11401-11410
# ============================================================================
func _def_1004(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 让 马 里 走 向 真 正 的 人 民 民 主"
	var conds: Array = []
	conds.append(cond(" 至 少 10 百 万 预 算 与 10 特 勤",
		func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100))
	conds.append(cond(" 我 们 已 经 应 用 了 先 进 的 社 会 主 义 理 论",
		func(): return c(w, 1) != null and c(w, 1).sub_government == 19))
	conds.append(cond(" 尚 未 向 马 里 传 授 经 验",
		func(): return c(w, 58) == null or c(w, 58).sub_government != 19))
	var eff := func():
		set_d(w, 9, d(w, 9) - 100)
		set_d(w, 8, d(w, 8) - 100)
		if c(w, 58) != null:
			c(w, 58).government = 0
			c(w, 58).sub_government = 19
			c(w, 58).leave_alliances()
			set_tag(c(w, 58), "对华贸易", true)
			set_tag(c(w, 58), "亲中", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1005 · 封锁制裁台湾当局，以促使将伪政权倒台
# DiploButtonScript Show L3701-3710 / OnMouseDown L11411-11415
# ============================================================================
func _def_1005(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 封 锁 制 裁 台 湾 当 局 ， 以 促 使 将 伪 政 权 倒 台"
	var conds: Array = []
	conds.append(cond(" 已 支 持 台 湾 美 丽 岛 运 动",
		func(): return ev(w, 460) and res(w, 460) != 2))
	conds.append(cond(" 美 国 已 失 去 对 台 湾 的 掌 控",
		func(): return c(w, 38) == null or not has(c(w, 38), "亲美")))
	var eff := func():
		start_event_num(w, 461)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1006 · 秘密联络拉巴特派，为将来作准备
# DiploButtonScript Show L3711-3722 / OnMouseDown L11416-11421
# ============================================================================
func _def_1006(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 秘 密 联 络 拉 巴 特 派 ， 为 将 来 作 准 备"
	var conds: Array = []
	conds.append(cond(" 趁 我 们 还 来 得 及", func(): return not ev(w, 463)))
	conds.append(cond(" 至 少 5 特 工 网 络 和 3 百 万 预 算",
		func(): return d(w, 9) >= 50 and d(w, 8) + d(w, 36) >= 30))
	conds.append(cond(" 尚 未 提 供 援 助", func(): return c(w, 54) == null or not c(w, 54).内战中))
	var eff := func():
		if c(w, 54) != null:
			c(w, 54).内战中 = true
		set_d(w, 8, d(w, 8) - 30)
		set_d(w, 9, d(w, 9) - 50)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1007 · 向玻里沙里欧阵线出售军火，支持他们的武装斗争
# DiploButtonScript Show L3723-3734 / OnMouseDown L11422-11428
# ============================================================================
func _def_1007(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 向 玻 里 沙 里 欧 阵 线 出 售 军 火 ， 支 持 他 们 的 武 装 斗 争"
	var conds: Array = []
	conds.append(cond(" 需 要 5 军 力", func(): return d(w, 22) >= 50))
	conds.append(cond(" 科 技 《 加 强 军 备 开 发 》 研 发 完 毕",
		func(): return w.techs != null and w.techs.unlocked.size() > 18 and w.techs.unlocked[18]))
	conds.append(cond(" 我 们 没 有 出 售 过 军 火", func(): return c(w, 18) == null or not c(w, 18).内战中))
	var eff := func():
		set_d(w, 22, d(w, 22) - 5)
		set_d(w, 8, d(w, 8) + 3)
		if c(w, 18) != null:
			c(w, 18).内战中 = true
		set_tag(c(w, 54), "对华贸易", false)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1008 · 重新讨论关于东方申根协定的事宜
# DiploButtonScript Show L3735-3742 / OnMouseDown L11429-11433
# ============================================================================
func _def_1008(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 重 新 讨 论 关 于 东 方 申 根 协 定 的 事 宜"
	var conds: Array = []
	conds.append(cond(" 还 未 签 订", func(): return res(w, 464) != 1 and res(w, 464) != 0))
	var eff := func():
		start_event_num(w, 464)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1009 · 支持法国共产党内部的正统派
# DiploButtonScript Show L3743-3756 / OnMouseDown L11434-11440
# ============================================================================
func _def_1009(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 支 持 法 国 共 产 党 内 部 的 正 统 派"
	var conds: Array = []
	conds.append(cond(" 3 百 万 预 算 和 3 特 工 网 络",
		func(): return d(w, 8) + d(w, 36) >= 30 and d(w, 9) >= 30))
	conds.append(cond(" 一 年 一 次", func(): return country.special <= 0))
	conds.append(cond(" 文 化 大 革 命 已 结 束", func(): return not mod(w, 3)))
	conds.append(cond(" 早 于 1 9 8 1 年", func(): return d(w, 21) < 1981))
	var eff := func():
		if c(w, 21) != null:
			c(w, 21).social_stability += 10
		set_d(w, 8, d(w, 8) - 30)
		set_d(w, 9, d(w, 9) - 30)
		if c(w, 21) != null:
			c(w, 21).special = 1
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1010 · 支持法共正统派发起政变
# DiploButtonScript Show L3757-3770 / OnMouseDown L11441-11445
# ============================================================================
func _def_1010(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 支 持 法 共 正 统 派 发 起 政 变"
	var conds: Array = []
	conds.append(cond(" 与 苏 联 和 解", func(): return fl(w, "relres")))
	conds.append(cond(" 10 百 万 预 算 和 10 特 工 网 络",
		func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 100))
	conds.append(cond(" 尚 未 推 翻 马 歇", func(): return not ev(w, 482) or res(w, 482) != 1))
	conds.append(cond(" 早 于 1 9 8 1 年", func(): return d(w, 21) < 1981))
	var eff := func():
		start_event_num(w, 482)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1013 · 试图将已经民主化的朝鲜和韩国整合成一个统一的国家
# DiploButtonScript Show L3802-3811 / OnMouseDown L11466-11470
# ============================================================================
func _def_1013(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 试 图 将 已 经 民 主 化 的 朝 鲜 和 韩 国 整 合 成 一 个 统 一 的 国 家"
	var conds: Array = []
	conds.append(cond(" 尚 未 推 进 统 一", func(): return res(w, 495) != 1))
	var c46 := c(w, 46)
	var c10 := c(w, 10)
	conds.append(cond(" 韩 国 和 朝 鲜 都 已 民 主 化",
		func(): return ((c46 != null and ((c46.government == 3 and not has(c46, "亲美")) or c46.government == 2))
			and c10 != null and c10.government == 2)))
	var eff := func():
		start_event_num(w, 495)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1014 · 支持自民党中的亲华派
# DiploButtonScript Show L3812-3824 / OnMouseDown L11471-11478
# ============================================================================
func _def_1014(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 支 持 自 民 党 中 的 亲 华 派 。%s影 响 力： %d" % ["\n", country.prc_influence]
	var conds: Array = []
	conds.append(cond(" 至 少 8 特 工 网 络", func(): return d(w, 9) >= 50))
	conds.append(cond(" 至 少 8 点 军 事 力 量", func(): return d(w, 22) >= 50))
	conds.append(cond(" 至 少 8 点 预 算", func(): return d(w, 8) + d(w, 36) >= 50))
	conds.append(cond(" 外 交 声 誉 低 于 69", func(): return d(w, 6) <= 690))
	var eff := func():
		add_rel(w, 0, 20)
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 50)
		set_d(w, 22, d(w, 22) - 50)
		country.prc_influence += 10
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1015 · 发动反自民党政府的赤色革命
# DiploButtonScript Show L3825-3837 / OnMouseDown L11479-11488
# ============================================================================
func _def_1015(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 发 动 反 自 民 党 政 府 的 赤 色 革 命"
	var conds: Array = []
	conds.append(cond(" 预 算 、 特 工 网 络 、 军 事 力 量 均 大 于 15",
		func(): return d(w, 8) + d(w, 36) >= 150 and d(w, 9) >= 150 and d(w, 22) >= 150))
	conds.append(cond(" 不 晚 于 1984 年 7 月",
		func(): return (d(w, 21) <= 1984 and d(w, 20) <= 7) or d(w, 21) <= 1983))
	conds.append(cond(" 日 本 革 命 共 产 党 的 力 量 强 于 200",
		func(): return c(w, 44) != null and c(w, 44).prc_power >= 200))
	conds.append(cond(" 尚 未 发 动 革 命",
		func(): return not ev(w, 538) and (c(w, 44) == null or not c(w, 44).有驻军基地)))
	var eff := func():
		set_d(w, 9, d(w, 9) - 150)
		set_d(w, 8, d(w, 8) - 150)
		set_d(w, 22, d(w, 22) - 150)
		if c(w, 44) != null:
			c(w, 44).有驻军基地 = true
		start_event_num(w, 538)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 1016 · 联络叙利亚反对阿萨德的反对派
# DiploButtonScript Show L3838-3846 / OnMouseDown L11489-11495
# ============================================================================
func _def_1016(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis := " 联 络 叙 利 亚 反 对 阿 萨 德 的 反 对 派"
	var conds: Array = []
	conds.append(cond(" 预 算 不 少 于 10百万 ，特 工 网 络 不 少 于 5 ， 军 力 不 少 于5",
		func(): return d(w, 8) + d(w, 36) >= 100 and d(w, 9) >= 50 and d(w, 22) >= 50))
	conds.append(cond(" 尚 未 联 络 过", func(): return c(w, 35) == null or not c(w, 35).内战中))
	var eff := func():
		set_d(w, 8, d(w, 8) - 100)
		set_d(w, 9, d(w, 9) - 50)
		set_d(w, 22, d(w, 22) - 50)
		if c(w, 35) != null:
			c(w, 35).内战中 = true
	return make_def(caption, opis, conds, eff)


## ============================================================================
## 静态自检结果（Python 静态检查，非 Godot 运行）：
## - UTF-8 可读：通过
## - 全文件 tab 缩进（无行首空格）：通过
## - build_action 分支数：34 / 34，编号覆盖本批全部编号
## - _def_N 函数数：34 / 34，与编号一一对应
## - 每个 func 括号平衡：通过（build_action + 34 个 _def_N）
## - 条件工厂调用数与 append 数量一致：157 / 157
## - 无 W 点裸引用：通过
## - 末尾兜底 return 空字典存在：通过
## ============================================================================
