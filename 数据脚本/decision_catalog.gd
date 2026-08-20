# ============================================================================
# DecisionCatalog — 决议目录（代码内嵌，等价原版 decisions 数组）
# ============================================================================
# 对齐 GlobalScript.CreateDecisions()（Assets/Scripts/GlobalScript.cs:6-86）。
# 原版 Decision 数组按下标 = 本目录下标；completedDecisions 同下标。
#
# 文本约定（沿用事件台账）：
#   - 原版 new_texts 逐字中文，字符间空格排版在 Godot 不再保留；
#   - <color> 标签不保留（决议 UI 不开 bbcode，先例：事件 UI）。
#
# 分步状态：
#   - 批次1（本轮）：version=1 决议 idx 0-14 的条件/效果/title/desc 完整；
#     req（门槛文本）/result（效果文本）随界面批次补齐（本批先置空）。
#   - 批次2/3：version=2（idx 15-19）、version=3（idx 20-52）。
# ============================================================================
class_name DecisionCatalog
extends RefCounted


static var _defs: Array[DecisionDef] = []
static var _built: bool = false


static func build() -> void:
	if _built:
		return
	_built = true
	_defs.clear()
	_build_v1()
	_build_v2()
	_build_v3()


## 重建目录。原版 CreateDecisions() 每次 Repaint 都重建三元分支
## （如 idx2/4/7/8 的 IsFactionLeadeng/modifies[6] 三元）；
## Godot 决议界面每次刷新前调用本方法保持同语义。
static func rebuild() -> void:
	_built = false
	build()


static func defs() -> Array[DecisionDef]:
	build()
	return _defs


static func count() -> int:
	build()
	return _defs.size()


static func get_def(index: int) -> DecisionDef:
	build()
	if index < 0 or index >= _defs.size():
		return null
	return _defs[index]


static func _new(id: int, title: String, desc: String, version: int) -> DecisionDef:
	var d := DecisionDef.new()
	d.id = id
	d.title = title
	d.desc = desc
	d.version = version
	return d


## 把原版空格排版字符串压成项目惯例（去掉全部空格；| 换行标记转 \n）
static func _s(s: String) -> String:
	return s.replace(" ", "").replace("|", "\n")


static func _build_v1() -> void:
	var A := DecisionAtoms

	# ── idx 0 朝鲜的命运（new_texts[113]/[131]）──────────────────────────
	var d0 := _new(0, _s("朝 鲜 的 命 运"), _s("有 赖 于 我 们 的 帮 助 ， 朝 鲜 半 岛 逐 渐 走 向 了 统 一 ， 但 是 统 一 后 的 朝 鲜 内 部 派 系 复 杂 多 样 。 为 了 我 们 邻 国 的 稳 定 ， 或 许 我 们 可 以 选 择 帮 助 其 中 一 个 派 系 ， 打 造 令 我 们 和 朝 鲜 民 众 都 满 意 的 新 政 府 。"), 1)
	d0.condition = func() -> bool:
		return A.they_are_ours(10) and A.quelle_gosstroy(10, 1, true) \
			and A.has_money(250) and A.has_agents(250)
	d0.effects = [
		func(): A.add_agents(-250),
		func(): A.add_army(-250),
		func(): A.start_event(120),
	]
	_defs.append(d0)

	# ── idx 1 西藏自治（new_texts[114]/[132]）──────────────────────────
	var d1 := _new(1, _s("西 藏 自 治"), _s("如 果 我 们 过 去 的 政 策 存 在 失 误 ， 那 么 通 过 西 藏 自 治 方 案 ， 就 完 全 有 希 望 去 构 建 中 国 公 民 间 的 和 谐 社 会 关 系 。  当 然 ， 我 们 不 会 容 忍 那 些 野 蛮 的 奴 隶 制 传 统 和 落 后 的 农 牧 方 式 存 续 下 去 。"), 1)
	d1.condition = func() -> bool:
		return A.tibet_is_ours(true) and A.is_unitarism(false) and A.is_liberal(true)
	d1.effects = [
		func(): A.add_loyality_to_all_politicians_in_the_faction(0, -500),
		func(): A.add_loyality_to_all_politicians_in_the_faction(1, -500),
		func(): A.add_loyality_to_all_politicians_in_the_faction(2, -500),
		func(): A.add_loyality_to_all_politicians_in_the_faction(3, 250),
		func(): A.add_relations(0, 250),
		func(): A.add_relations(1, 250),
		func(): A.start_event(121),
	]
	_defs.append(d1)

	# ── idx 2 博巴金珠帕其玛托瓦 / 根除藏文化（三元，new_texts[115]/[133]）──
	var d2: DecisionDef
	var d2_special := 5 if A._faction_leading(0) else 6
	if A._faction_leading(0):
		d2 = _new(2, _s("博 巴 金 珠 帕 其 玛 托 瓦"), _s("从 古 至 今 ， 这 片 最 高 最 高 的 世 界 脊 柱 上 的 人 民 一 直 在 遭 受 着 最 深 最 深 的 苦 。 农 奴 制 将 每 一 个 藏 族 人 民 都 被 拴 在 等 级 制 度 下 生 不 如 死 ， 而 那 些 王 公 贵 族 却 能 一 刻 不 停 地 尽 享 奢 靡 。 饱 经 苦 难 的 人 们 在 虚 幻 的 经 文 和 虚 伪 的 许 诺 中 虔 诚 祈 祷 ， 而 喇 嘛 活 佛 们 转 手 就 把 这 些 诚 心 人 的 香 火 钱 拿 去 占 田 屯 兵 ， 以 保 证 他 们 的 统 治 万 世 不 断 。 而 现 在 ， 我 们 将 带 领 解 放 了 的 藏 区 人 民 让 他 们 为 曾 经 的 作 威 作 福 彻 底 付 出 代 价 ！"), 1)
		d2.condition = func() -> bool:
			return A.tibet_is_ours(true) and A.is_unitarism(true) \
				and A.is_leftradical_lead(true) and A.is_radical_tradition(true) and A.has_army(250)
	else:
		d2 = _new(2, _s("根 除 藏 文 化"), _s("藏 不 是 一 个 国 号 ， 而 是 奴 役 本 族 人 民 的 封 建 农 奴 主 的 代 名 词 。  我 们 必 须 抹 去 他 们 骇 人 历 史 的 所 有 痕 迹 ： 寺 庙 、 经 幡 、 佛 学 院 。  我 们 会 把 孩 子 送 到 育 儿 院 ， 让 他 们 远 离 毒 草 思 想 ， 我 们 会 把 藏 族 成 年 人 送 到 再 教 育 中 心 ， 让 他 们 努 力 为 祖 国 利 益 做 贡 献 ， 净 化 心 灵 中 的 罪 孽 。"), 1)
		d2.condition = func() -> bool:
			return A.tibet_is_ours(true) and A.is_unitarism(true) \
				and A.is_autoritharian(true) and A.is_radical_tradition(true) and A.has_army(250)
	d2.effects = [
		func(): A.tibet_must_stay(2),
		func(): A.add_relations(0, -250),
		func(): A.add_relations(1, -250),
		func(): A.add_chinese_influence(25),
		func(): A.add_money(-250),
		func(): A.add_nationalism(250),
		func(): A.change_special_ending_for_the_country(69, d2_special),
		func(): A.start_event(547),
	]
	_defs.append(d2)

	# ── idx 3 维吾尔自治（new_texts[116]/[134]）────────────────────────
	var d3 := _new(3, _s("维 吾 尔 自 治"), _s("要 解 决 维 吾 尔 群 众 的 民 族 问 题 ， 应 该 审 慎 对 待 ， 予 其 宽 泛 的 自 治 权 。  但 首 先 得 考 虑 选 谁 树 威 ， 以 免 对 这 块 地 域 失 去 控 制 。"), 1)
	d3.condition = func() -> bool:
		return A.uyghur_is_ours(true) and A.is_unitarism(false) and A.is_liberal(true)
	d3.effects = [
		func(): A.add_loyality_to_all_politicians_in_the_faction(0, -500),
		func(): A.add_loyality_to_all_politicians_in_the_faction(1, -500),
		func(): A.add_loyality_to_all_politicians_in_the_faction(2, -500),
		func(): A.add_loyality_to_all_politicians_in_the_faction(3, 250),
		func(): A.add_relations(0, 250),
		func(): A.add_relations(1, 250),
		func(): A.start_event(122),
	]
	_defs.append(d3)

	# ── idx 4 天山脚下红旗飞扬 / 根除维吾尔文化（三元）────────────────
	var d4: DecisionDef
	var d4_special := 5 if A._faction_leading(0) else 6
	if A._faction_leading(0):
		d4 = _new(4, _s("天 山 脚 下 红 旗 飞 扬"), _s("昔 日 的 星 月 光 辉 不 再 ， 而 崭 新 的 红 日 则 高 升 雪 山 之 上 。 一 千 多 年 以 来 ， 这 片 黄 沙 漫 天 的 土 地 长 期 处 于 回 教 统 治 者 的 严 格 控 制 和 残 酷 剥 削 下 ， 贫 穷 和 暴 力 每 时 每 刻 充 斥 着 普 通 百 姓 的 生 活 。 而 毛 拉 与 阿 訇 则 协 助 统 治 者 愚 弄 人 民 的 思 想 ， 使 广 大 劳 动 群 众 在 思 想 的 桎 梏 下 被 肆 意 奴 役 。 如 今 ， 昔 日 的 反 动 宗 教 势 力 奄 奄 一 息 ， 各 路 新 出 现 的 牛 鬼 蛇 神 也 在 新 疆 人 民 的 共 同 抵 制 下 抱 头 鼠 窜 ， 是 时 候 对 我 国 西 北 边 疆 长 期 存 在 的 害 人 虫 们 发 起 最 后 一 击 了 ！"), 1)
		d4.condition = func() -> bool:
			return A.uyghur_is_ours(true) and A.is_unitarism(true) \
				and A.is_leftradical_lead(true) and A.is_radical_tradition(true) and A.has_army(250)
	else:
		d4 = _new(4, _s("根 除 维 吾 尔 文 化"), _s("由 于 长 期 与 世 隔 绝 ， 维 吾 尔 人 的 老 旧 文 化 远 远 落 后 于 时 代 ， 这 是 造 成 民 族 问 题 的 主 要 原 因 。  我 们 应 尽 一 切 办 法 消 除 这 些 沉 疴 思 想 ， 为 他 们 点 亮 崭 新 的 现 代 文 明 之 光 。"), 1)
		d4.condition = func() -> bool:
			return A.uyghur_is_ours(true) and A.is_unitarism(true) \
				and A.is_autoritharian(true) and A.is_radical_tradition(true) and A.has_army(250)
	d4.effects = [
		func(): A.uyghur_must_stay(4),
		func(): A.add_relations(0, -250),
		func(): A.add_relations(1, -250),
		func(): A.add_chinese_influence(25),
		func(): A.add_money(-250),
		func(): A.add_nationalism(250),
		func(): A.change_special_ending_for_the_country(70, d4_special),
		func(): A.start_event(546),
	]
	_defs.append(d4)

	# ── idx 5 精英治国（new_texts[118]/[136]）──────────────────────────
	var d5 := _new(5, _s("精 英 治 国"), _s("老 办 法 总 是 不 断 地 调 动 人 事 ， 但 这 不 可 能 永 远 奏 效 。  在 新 时 代 新 征 程 新 挑 战 下 ， 我 们 应 当 拿 出 新 本 领 ， 做 好 新 规 划 ， 在 人 事 新 政 策 上 树 立 新 典 范 。"), 1)
	d5.condition = func() -> bool:
		return A.is_party_enabled(false, 0) and A.has_one_party_mechanic(true) and A.all_leaders_are_dead()
	d5.effects = [func(): A.start_event(123)]
	_defs.append(d5)

	# ── idx 6 一国两制（new_texts[119]/[137]）──────────────────────────
	var d6 := _new(6, _s("一 国 两 制"), _s("中 国 已 向 世 界 展 示 了 足 够 的 善 意 ， 而 美 国 人 还 希 望 我 们 同 苏 联 尽 可 能 保 持 更 远 的 距 离 ， 既 然 如 此 ， 我 们 正 好 就 以 台 湾 作 为 要 价 。"), 1)
	d6.condition = func() -> bool:
		return A.has_autonomy_for_macao(true) and A.is_taiwan_attacked(false) \
			and A.is_taiwan_return(false) and A.is_in_the_ovd(false, 1) and A.is_in_the_sev(false, 1) \
			and A.has_cultural_revolution(false) and A.has_maoismus(false) \
			and A.is_dip_rep_less_than(true, 500)
	d6.effects = [
		func(): A.make_pro_chinese(true, 38),
		func(): A.make_pro_usa(false, 38),
		func(): A.change_bot_system(2, 38),
		func(): A.add_chinese_influence(30),
		func(): A.add_support(50),
		func(): A.add_liberalization(-50),
		func(): A.start_event(462),
	]
	_defs.append(d6)

	# ── idx 7 解放台湾（三元，new_texts[120]/[138]）────────────────────
	var d7 := _new(7, _s("解 放 台 湾"), _s("我 们 比 以 往 任 何 时 候 都 更 加 强 大 ， 而 美 国 也 怯 懦 到 了 极 点 。 是 时 候 收 复 台 湾 了 ， 美 国 人 畏 惧 全 面 战 争 的 爆 发 ， 只 会 对 着 他 们 的 “ 盟 友 ” 望 洋 兴 叹 。"), 1)
	# 原版三元在 CreateDecisions 时定型分支（modifies[6].active 决定用
	# IsChiSovInfluenceLessThan 还是 IsUnityLessThan），build 时固化。
	if A._mod_active(6):
		d7.condition = func() -> bool:
			return A.tibet_is_ours(true) and A.uyghur_is_ours(true) \
				and A.has_agents(1500) and A.has_army(1500) and A.has_money(1500) \
				and A.is_chi_sov_influence_less_than(false, 500) \
				and A.has_maoismus(true) and A.is_american_influence_less_than(true, 100) \
				and A.is_taiwan_attacked(true) and A.is_taiwan_return(false) \
				and A.they_are_ours(1) and A.has_annexed_macao(true) \
				and A.has_agressive_military_doctrine(true) and A.is_science_done(24, true)
	else:
		d7.condition = func() -> bool:
			return A.tibet_is_ours(true) and A.uyghur_is_ours(true) \
				and A.has_agents(1500) and A.has_army(1500) and A.has_money(1500) \
				and A.is_unity_less_than(false, 700) \
				and A.has_maoismus(true) and A.is_american_influence_less_than(true, 100) \
				and A.is_taiwan_attacked(true) and A.is_taiwan_return(false) \
				and A.they_are_ours(1) and A.has_annexed_macao(true) \
				and A.has_agressive_military_doctrine(true) and A.is_science_done(24, true)
	d7.effects = [
		func(): A.annexation_info(7, 38, 1),
		func(): A.make_pro_usa(false, 38),
		func(): A.add_relations(0, -1000),
		func(): A.add_chinese_influence(50),
		func(): A.add_population(180),
		func(): A.add_support(50),
		func(): A.add_liberalization(-50),
		func(): A.add_agents(-1500),
		func(): A.add_money(-1500),
		func(): A.add_army(-1500),
		func(): A.start_event(457),
	]
	_defs.append(d7)

	# ── idx 8 平反林彪集团（三元，new_texts[121]，desc 内嵌）───────────
	var d8 := _new(8, _s("平 反 林 彪 集 团"),
		_s("林 副 主 席 作 为 毛 主 席 的 亲 密 战 友 和 接 班 人 ， 怎 么 可 能 是 修 正 主 义 者 ？ 让 我 们 揭 穿 邓 小 平 修 正 主 义 集 团 与 四 人 帮 笔 杆 子 集 团 的 阴 谋 ， 为 林 副 主 席 和 他 的 战 友 们 平 反 昭 雪 。")
		if A._mod_active(6)
		else _s("林 彪 作 为 一 个 对 毛 泽 东 的 社 会 封 建 主 义 幡 然 醒 悟 的 革 命 者 ， 怎 么 可 能 是 修 正 主 义 者 ？ 让 我 们 揭 穿 毛 泽 东 集 团 对 他 们 的 迫 害 ， 为 林 彪 和 他 的 战 友 们 平 反 昭 雪 。"), 1)
	d8.condition = func() -> bool:
		return A.has_arrest_gof(true) and A.has_conservative_moderate_leading(true) and A.has_lin_biao(true)
	d8.effects = [
		func(): A.add_liberalization(250),
		func(): A.add_relations(1, 250),
		func(): A.add_power_to_leader_faction(200),
		func(): A.get_lin_biao(true),
	]
	_defs.append(d8)

	# ── idx 9 另类改组，倒反天罡（new_texts[122]/[140]）────────────────
	var d9 := _new(9, _s("另 类 改 组 ， 倒 反 天 罡"), _s("在 波 兰 、 匈 牙 利 与 罗 马 尼 亚 的 权 力 更 迭 下 ， 在 苏 联 同 发 达 社 会 主 义 愿 景 的 渐 行 渐 远 中 ， 东 欧 诸 国 并 没 有 迎 来 它 的 美 好 明 天 ， 而 中 国 正 以 越 来 越 自 信 的 态 度 登 上 舞 台 ， 并 即 将 接 棒 世 界 革 命 领 军 人 身 份 。 我 们 可 以 回 头 审 视 一 番 ， 看 看 能 否 利 用 马 林 老 同 志 提 出 ， 老 大 哥 力 倡 的 打 入 主 义 策 略 。 从 内 部 重 振 苏 东 集 团 的 社 会 主 义 性 质 ！"), 1)
	d9.condition = func() -> bool:
		return A.has_communist_leader(true) and A.has_soviet_friendship(false) \
			and A.they_are_ours(1) and A.has_europeans_puppets() \
			and A.pro_chinese(12) and A.pro_chinese(8) \
			and A.is_chinese_influence_less_than(false, 350) \
			and A.has_chosen_in_the_event(471, 0) and A.has_gorbachev() \
			and A.is_year_less(false, 1984) and A.has_maoismus(true) \
			and A.has_cultural_revolution(true)
	d9.effects = [
		func(): A.east_europe_abandon_sov(true),
		func(): A.make_east_europa_pro_china(true),
		func(): A.add_american_influence(100),
		func(): A.add_relations(0, 250),
		func(): A.add_relations(1, -1000),
		func(): A.add_soviet_influence(-1000),
		func(): A.add_loyality_to_all_politicians_in_the_faction(0, 500),
		func(): A.maoism_sov_is_better(9),
		func(): A.start_event(470),
	]
	_defs.append(d9)

	# ── idx 10 组织革命国际主义运动（new_texts[123]/[141]）────────────
	var d10 := _new(10, _s("组 织 革 命 国 际 主 义 运 动"), _s("自 中 国 革 命 的 伟 大 领 袖 毛 泽 东 主 席 去 世 后 ， 世 界 格 局 瞬 息 万 变 ， 短 短 数 年 便 换 了 新 颜 。 有 赖 于 全 党 全 军 全 国 各 族 人 民 的 努 力 ， 相 当 数 量 的 国 家 选 择 站 在 求 民 主 、 求 革 命 的 一 方 。 我 们 的 国 际 盟 友 也 愈 加 将 我 们 同 以 往 的 “ 世 界 革 命 祖 国 ” 苏 联 相 提 并 论 . . . . . . 也 许 ， 现 在 也 到 了 该 趁 热 打 铁 的 时 候 — — 我 们 将 高 举 革 命 国 际 主 义 运 动 旗 帜 ， 复 兴 列 宁 、 斯 大 林 曾 致 力 的 事 业 ！"), 1)
	d10.condition = func() -> bool:
		return A.has_left_radical_leader(true) and A.they_are_ours(1) \
			and A.quelle_gosstroy(33, 1, true) and A.quelle_gosstroy(58, 1, true) \
			and A.quelle_gosstroy(80, 1, true) and A.has_maoismus(true) \
			and A.has_cultural_revolution(true) and A.is_not_revisionist(true)
	d10.effects = [
		func(): A.add_agents(-250),
		func(): A.add_army(-250),
		func(): A.add_relations(0, -250),
		func(): A.add_relations(1, -250),
		func(): A.add_american_influence(-100),
		func(): A.add_soviet_influence(-100),
		func(): A.add_diplo(100),
		func(): A.add_chinese_influence(100),
		func(): A.add_loyality_to_all_politicians_in_the_faction(0, 500),
		func(): A.add_loyality_to_all_politicians_in_the_faction(2, -500),
		func(): A.add_loyality_to_all_politicians_in_the_faction(3, -500),
		func(): A.maoism_is_better(10),
		func(): A.start_event(548),
	]
	_defs.append(d10)

	# ── idx 11 这里的苦跌塔静悄悄（new_texts[124]/[142]）──────────────
	var d11 := _new(11, _s("这 里 的 苦 跌 塔 静 悄 悄"), _s("一 群 温 和 的 变 革 家 ， 他 们 人 数 不 多 ， 却 力 压 群 雄 ， 将 对 手 一 扫 而 空 ， 按 部 就 班 夺 得 了 政 权 。  这 一 派 的 领 导 人 宣 告 会 坚 守 初 心 ， 坚 决 维 护 党 规 党 纪 ， 通 过 国 家 全 面 管 控 ， 实 行 类 似 于 新 经 济 政 策 的 经 济 改 革 。 总 之 ， 时 间 会 检 验 一 切......"), 1)
	d11.condition = func() -> bool:
		return A.is_politician_alive(16, 16, 1, 21, 5, 11) and A.has_agents(250) \
			and A.has_cultural_revolution(false) and A.has_moderate_faction(true) \
			and A.has_moderate_leader(true)
	d11.effects = [
		func(): A.add_relations(0, 250),
		func(): A.add_relations(1, 250),
		func(): A.add_agents(-250),
		func(): A.add_liberalization(250),
		func(): A.add_support(150),
		func(): A.add_standard_of_living(50),
		func(): A.make_him_leader(16, 16, 1, 21, 5, 11),
		func(): A.kill_the_leader_of_the_faction(0),
		func(): A.kill_the_leader_of_the_faction(1),
		func(): A.kill_the_leader_of_the_faction(3),
		func(): A.kill_the_leader_of_the_faction(4),
	]
	_defs.append(d11)

	# ── idx 12 嚼嚼口香糖，友谊长又长（new_texts[125]/[143]）──────────
	var d12 := _new(12, _s("嚼 嚼 口 香 糖 ， 友 谊 长 又 长"), _s("寡 头 们 在 国 内 已 经 初 具 气 候 ， 甚 至 很 快 就 要 在 政 治 领 域 翻 云 覆 雨 。  如 果 阻 止 不 了 寡 头 ， 就 该 发 挥 我 们 党 总 揽 全 局 、 协 调 各 方 的 领 导 核 心 作 用 ， 趁 着 大 权 在 握 ， 提 前 建 设 完 备 的 规 范 体 系 ， 打 好 镣 铐 ， 上 好 笼 套 ， 免 得 资 本 无 序 发 展 。"), 1)
	d12.condition = func() -> bool:
		return A.has_one_party_mechanic(true) and A.has_agents(250) \
			and A.is_liberal(true) and A.is_left_rad_banned() \
			and A.has_capitalist_economy(true) and A.has_oligarchy_power_less(false, 60)
	d12.effects = [func(): A.agree_to_oligarchy(12)]
	_defs.append(d12)

	# ── idx 13 王明的遗产（new_texts[126]/[144]）──────────────────────
	var d13 := _new(13, _s("王 明 的 遗 产"), _s("王 明 的 思 想 论 辩 在 他 的 祖 国 一 度 掀 起 热 潮 。 在 新 生 的 中 华 人 民 共 和 国 ， 重 整 旗 鼓 的 共 产 党 人 决 不 允 许 自 由 主 义 者 和 新 马 克 思 主 义 者 篡 夺 政 权 。  我 们 必 须 拿 起 一 切 武 器 ， 坚 决 捍 卫 和 维 护 社 会 主 义 道 路 与 共 产 主 义 路 线 ！"), 1)
	d13.condition = func() -> bool:
		return A.has_one_party_mechanic(true) and A.has_capitalist_economy(false) \
			and A.has_soviet_friendship(true) and A.is_year_less(true, 1984) \
			and A.is_mao_demaoised(true) and A.has_real_moderate_leader(true)
	d13.effects = [
		func(): A.add_relations(1, 1000),
		func(): A.block_market(13),
		func(): A.start_event(124),
	]
	_defs.append(d13)

	# ── idx 14 印度大棋，弃子争先（new_texts[127]/[145]）──────────────
	var d14 := _new(14, _s("印 度 大 棋 ， 弃 子 争 先"), _s("当 前 ， 印 度 人 民 对 他 们 的 领 导 层 正 极 度 不 满 ， 而 背 靠 我 国 ， 持 激 进 主 义 立 场 的 纳 萨 尔 派 恰 好 有 很 大 的 影 响 力 。因 此 ， 我 们 自 然 获 得 了 在 印 度 推 进 社 会 主 义 事 业 的 难 得 机 会 ， 甚 至 能 考 虑 在 当 地 建 立 一 个 毛 派 壁 垒 ！ 只 是 我 们 需 要 谨 慎 行 事 ， 得 货 比 三 家 ， 看 看 哪 派 共 产 党 人 最 合 我 们 的 口 味 ......"), 1)
	d14.condition = func() -> bool:
		return A.has_agents(1000) and A.has_money(500) and A.has_maoismus(true) \
			and A.is_dead_janata_in_india(true) and A.has_naxalits_power_less(false, 799)
	d14.effects = [
		func(): A.add_money(-500),
		func(): A.add_agents(-1500),
		func(): A.add_relations(1, -1000),
		func(): A.add_chinese_influence(50),
		func(): A.start_event(125),
	]
	_defs.append(d14)


## version=2 决议（GlobalScript.cs:35-39，idx 15-19）
static func _build_v2() -> void:
	var A := DecisionAtoms

	# idx 15 共青一代（new_texts[551]/[556]）
	var age15 := _year() - 1928
	var d15 := _new(15, _s("共 青 一 代"), _s("现 在 是 老 一 代 “ 革 命 家 ” 把 权 力 交 给 年 轻 人 的 时 候 了 ， 不 然 我 们 就 有 可 能 陷 入 一 种 局 面 ， 即 许 多 老 党 员 逝 世 所 导 致 的 权 力 真 空 和 危 机 。 为 达 此 目 的 ， 我 们 心 中 已 有 一 个 积 极 向 上 的 青 年 党 员 ， 一 个 热 心 爱 国 、 胸 怀 宽 广 的 人 。"), 2)
	d15.condition = func() -> bool:
		return A.has_communist_leader(false) and A.has_maoismus(false) \
			and A.has_cultural_revolution(false) and A.has_capitalist_economy(true)
	d15.effects = [
		func(): A.create_new_leader(32, 47, 3, 21, 4, 14, age15),
		func(): A.add_liberalization(50),
		func(): A.add_support(50),
		func(): A.add_chinese_influence(1),
	]
	_defs.append(d15)

	# idx 16 效法袁世凯（new_texts[552]/[557]）
	var d16 := _new(16, _s("效 法 袁 世 凯"), _s("是 时 候 让 中 国 在 一 位 伟 大 领 袖 、 一 位 强 人 、 一 位 伟 大 的 中 国 人 民 的 庇 护 者 的 正 义 统 治 下 重 新 走 向 伟 大 了 。 为 进 行 真 正 的 改 革 ， 并 迅 速 而 独 特 地 让 中 国 重 获 伟 大 ， 我 们 应 当 把 巨 大 的 权 力 移 交 给 我 们 无 可 争 议 的 领 导 人 。"), 2)
	d16.condition = func() -> bool:
		return A.has_leader(32, 47, 3, 21, 4, 14) and A.is_autoritharian(true) \
			and A.is_traditional(true) and A.has_agents(1500) and A.has_army(1500)
	d16.effects = [
		func(): A.block_freedom(16),
		func(): A.add_new_modify(38),
		func(): A.add_agents(-1500),
		func(): A.add_army(-1500),
	]
	_defs.append(d16)

	# idx 17 关于处理海外麻匪的指导意见（new_texts[553]/[558]）
	var d17 := _new(17, _s("关 于 处 理 海 外 麻 匪 的 指 导 意 见"), _s("任 何 邪 恶 都 将 绳 之 以 法 ， 当 然 ， 得 在 境 内 才 算 ， 境 外 犯 罪 也 可 以 谈 ， 也 可 以 爱 国 。 一 旦 想 通 了 就 不 难 发 现 ， 我 们 有 着 得 天 独 厚 的 资 源 ， 足 以 在 美 国 织 起 一 张 情 报 交 易 和 政 治 资 源 的 大 网 ， 只 要 不 介 意 下 脏 手 ， 我 们 完 全 可 以 与 美 洲 大 陆 上 的 华 人 帮 派 建 立 起 坚 实 又 密 切 的 联 系 。"), 2)
	d17.condition = func() -> bool:
		return A.is_year_less(false, 1981) and A.has_chosen_in_the_event(308, 1) \
			and A.has_agents(500) and A.has_money(500)
	d17.effects = [
		func(): A.add_agents(-500),
		func(): A.add_money(-500),
		func(): A.add_new_modify(39),
	]
	_defs.append(d17)

	# idx 18 回归农业文明（内嵌文本）
	var age18a := _year() - 1893
	var age18b := _year() - 1895
	var d18 := _new(18, _s("回 归 农 业 文 明"), _s("自 古 以 来 ， 农 民 与 乡 土 社 会 便 是 中 国 的 中 流 砥 柱 ， 并 一 直 肩 负 着 保 护 和 发 展 文 明 的 重 任 。 因 此 ， “ 中 国 特 色 社 会 主 义 ” 必 须 根 植 于 这 代 人 的 生 活 中 ： 随 着 新 儒 家 与 中 国 建 制 派 的 联 盟 正 式 建 立 ， 乃 至 对 近 代 化 思 想 的 反 思 越 加 深 入 人 心 。 也 是 时 候 纠 正 过 往 的 一 切 错 误 ， 回 归 中 国 社 会 的 本 源 。"), 2)
	d18.condition = func() -> bool:
		return A.has_moderate_leader(true) and A.is_faction_banned(0) and A.is_faction_banned(4) \
			and A.has_chosen_in_the_event(451, 1) and A.has_chosen_in_the_event(15, 1) \
			and A.has_someone_won_in_the_war(1, 0) and A.is_dip_rep_less_than(false, 700) \
			and A.has_maoismus(false) and A.is_traditional(true) and A.is_new_democracy(true) \
			and A.has_chosen_in_the_event(682, 0) and A.has_agents(500) and A.has_money(500)
	d18.effects = [
		func(): A.add_agents(-500),
		func(): A.add_money(-500),
		func(): A.add_new_modify(40),
		func(): A.block_for_statemoncap(18),
		func(): A.block_for_new_democracy(18),
		func(): A.create_new_leader(47, 65, 2, 26, 4, 14, age18a),
		func(): A.create_new_politician(39, 66, 2, 26, 5, 14, age18b),
	]
	_defs.append(d18)

	# idx 19 中华秋海棠叶遂归于一统 / 整合漠北（三元 puppetOf!=1）
	var d19: DecisionDef
	if A._country(9) != null and A._country(9).puppet_of != GameConstants.LegacySlot.CHINA:
		d19 = _new(19, _s("中 华 秋 海 棠 叶 遂 归 于 一 统"), _s("蒙 古 人 很 久 以 前 就 和 我 们 断 绝 了 联 系 ， 但 这 不 是 中 国 的 错 。 他 们 不 是 同 中 国 断 绝 联 系 ， 而 是 同 末 代 皇 帝 及 其 母 亲 的 疯 狂 专 制 政 权 断 绝 。 现 在 ， 这 一 障 碍 已 经 消 除 ， 蒙 古 人 民 相 信 我 们 的 善 意 ， 我 们 可 以 开 始 启 动 一 个 项 目 ， 让 蒙 古 重 新 融 入 我 们 伟 大 的 中 国 人 民 大 家 庭 ！"), 2)
		d19.condition = func() -> bool:
			return A.is_unitarism(false) and A.pro_chinese(9) and A.they_are_ours(1) \
				and A.has_agents(500) and A.has_money(500) \
				and A.is_chinese_influence_less_than(false, 750) and A.is_unity_less_than(false, 700)
		d19.effects = [
			func(): A.add_population(20),
			func(): A.add_support(100),
			func(): A.add_chinese_influence(10),
			func(): A.add_agents(-500),
			func(): A.add_money(-500),
			func(): A.get_mongolia(19),
		]
	else:
		d19 = _new(19, _s("整 合 漠 北"), _s("时 代 的 浪 潮 滚 滚 向 前 ， 在 我 们 对 蒙 古 的 战 争 大 获 全 胜 后 ， 是 时 候 把 蒙 古 纳 入 辽 阔 的 国 土 之 中 了 。 我 们 将 把 蒙 古 细 细 的 拆 分 ， 恢 复 乌 兰 巴 托 的 古 老 名 称 库 伦 。 组 建 特 别 联 合 治 安 部 ， 开 设 “ 汉 语 学 习 班 ” ， 监 控 所 有 的 坏 分 子 ， 削 弱 蒙 文 的 地 位 ， 并 最 终 摧 毁 蒙 人 抵 抗 的 意 识 。 他 们 将 变 成 像 壮 族 一 样 的 模 范 公 民 ， 在 为 祖 国 保 卫 边 疆 的 过 程 中 证 明 自 己 。 这 就 是 叛 徒 的 下 场 ！"), 1)
		d19.condition = func() -> bool:
			return A.pro_chinese(9) and A.they_are_ours(1)
		d19.effects = [
			func(): A.add_population(20),
			func(): A.add_support(100),
			func(): A.add_chinese_influence(100),
			func(): A.get_mongolia(19),
		]
	_defs.append(d19)


static func _year() -> int:
	var ws := DecisionAtoms._ws()
	if ws != null and ws.数值表.size() > WorldState.I_YEAR:
		return ws.数值表[WorldState.I_YEAR]
	return 1976


## version=3 决议（GlobalScript.cs:40-72，idx 20-52）
static func _build_v3() -> void:
	var A := DecisionAtoms

	# idx 20 建立阿拉伯联合国家 / 成立阿拉伯革命社会主义联邦共和国（三元 government != GameConstants.Government.SOCIALIST）
	var d20: DecisionDef
	if A._country(30) != null and A._country(30).government != GameConstants.Government.SOCIALIST:
		d20 = _new(20, _s("建 立 阿 拉 伯 联 合 国 家"), _s("数 十 年 间 ， 泛 阿 拉 伯 主 义 情 绪 便 已 从 点 点 星 火 燃 作 燎 原 之 势 。 可 遗 憾 的 是 ， 并 没 有 一 个 行 之 有 效 的 一 体 化 项 目 匹 配 如 此 雄 心 。 毕 竟 ， 当 地 的 纳 赛 尔 只 有 一 个 。 但 在 东 方 神 秘 力 量 日 益 壮 大 ， 并 能 为 第 三 世 界 盟 友 搭 把 手 的 情 况 下 ， 阿 拉 伯 人 能 真 正 以 同 一 个 声 音 说 话 吗 ？"), 3)
		d20.condition = func() -> bool:
			return A.is_oar_created(true) and A.is_oar_full(true) and A.is_no_wars(true) \
				and A.is_year_less(false, 1983) and A.is_chinese_influence_less_than(false, 800) \
				and A.has_money(300) and A.quelle_gosstroy(84, 2, true) and A.quelle_gosstroy(30, 2, true) \
				and A.has_agents(300) and A.is_rael(true)
		d20.effects = [
			func(): A.add_agents(-300),
			func(): A.add_money(-300),
			func(): A.create_big_oar(true),
			func(): A.start_event(465),
		]
	else:
		d20 = _new(20, _s("成 立 阿 拉 伯 革 命 社 会 主 义 联 邦 共 和 国"), _s("时 代 的 浪 潮 滚 滚 向 前 ， 新 的 革 命 者 们 接 过 了 前 辈 的 旗 帜 ， 社 会 主 义 的 东 风 已 经 吹 入 了 阿 拉 伯 半 岛 。 碍 于 国 内 外 形 势 ， 阿 拉 伯 的 革 命 者 们 不 得 不 抱 团 取 暖 ， 在 剿 匪 镇 反 方 面 共 同 合 作 ， 组 建 了 一 个 超 越 国 境 线 的 经 济 - 政 治 - 军 事 联 盟 。 但 我 们 应 当 更 进 一 步 ， 帮 助 他 们 落 实 统 一 于 同 一 面 社 会 主 义 旗 帜 下 的 目 标 。 革 命 的 红 旗 高 高 飘 扬 , 试 问 谁 能 阻 挡 的 了 ？"), 1)
		d20.condition = func() -> bool:
			return A.is_revotionary_oar_full(true) and A.is_no_wars(true) \
				and A.is_chinese_influence_less_than(false, 500) and A.has_money(100) and A.has_agents(100)
		d20.effects = [
			func(): A.add_agents(-100),
			func(): A.add_money(-100),
			func(): A.unite_arab(),
		]
	_defs.append(d20)

	# idx 21 统一情报网络（new_texts[589]/[590]）
	var d21 := _new(21, _s("统 一 情 报 网 络"), _s("众 人 拾 柴 火 焰 高 ， 建 立 统 一 的 总 情 报 局 将 让 我 们 的 情 报 工 作 能 力 远 超 往 昔 。"), 3)
	d21.condition = func() -> bool:
		return A.is_chinese_influence_less_than(false, 200) and A.is_china_war_aliance(true) \
			and A.is_science_done(19, true) and A.has_money(100)
	d21.effects = [func(): A.add_money(-100), func(): A.on_agent_modif(true)]
	_defs.append(d21)

	# idx 22 建立统一的总参谋部（new_texts[629]/[630]）
	var d22 := _new(22, _s("建 立 统 一 的 总 参 谋 部"), _s("众 人 拾 柴 火 焰 高 ， 建 立 统 一 的 总 参 谋 局 将 让 我 们 的 整 体 军 事 实 力 远 超 往 昔 。"), 3)
	d22.condition = func() -> bool:
		return A.is_chinese_influence_less_than(false, 200) and A.is_china_war_aliance(true) \
			and A.is_science_done(23, true) and A.has_money(100)
	d22.effects = [func(): A.add_money(-100), func(): A.on_army_modif(true)]
	_defs.append(d22)

	# idx 23 统一东南亚条约组织与中央条约组织（new_texts[632]/[636]）
	var d23 := _new(23, _s("统 一 东 南 亚 条 约 组 织 与 中 央 条 约 组 织"), _s("东 南 亚 条 约 组 织 与 中 央 条 约 组 织 两 大 神 圣 联 盟 的 合 二 为 一 ， 必 将 在 第 三 世 界 打 造 一 道 牢 不 可 破 的 反 苏 反 赤 民 主 长 城 ！"), 3)
	d23.condition = func() -> bool:
		return A.is_in_the_seato(true, 1) and A.is_in_the_sento(true, 8) and A.is_in_the_sento(true, 31) \
			and A.is_year_less(false, 1980) and A.has_money(300) and A.has_army(300)
	d23.effects = [
		func(): A.add_money(-300),
		func(): A.add_army(-300),
		func(): A.add_chinese_influence(50),
		func(): A.add_american_influence(50),
		func(): A.add_soviet_influence(-50),
		func(): A.add_relations(1, -250),
		func(): A.add_relations(0, 250),
		func(): A.make_in_wpo(true, 9),
		func(): A.on_seato(true),
	]
	_defs.append(d23)

	# idx 24 打倒苏修新沙皇（new_texts[641]/[642]）
	var d24 := _new(24, _s("打 倒 苏 修 新 沙 皇"), _s("苏 修 新 沙 皇 ， 胃 口 大 诡 计 狂 ， 我 们 必 须 保 和 平 卫 祖 国 。 打 倒 苏 修 新 沙 皇 ！"), 3)
	d24.condition = func() -> bool:
		return A.has_agents(150) and A.is_science_done(25, true) and A.oncein(24, true)
	d24.effects = [
		func(): A.do_timer(24, 6),
		func(): A.add_agents(-150),
		func(): A.add_soviet_influence(-50),
	]
	_defs.append(d24)

	# idx 25 打倒美帝野心狼（new_texts[645]/[646]）
	var d25 := _new(25, _s("打 倒 美 帝 野 心 狼"), _s("美 帝 野 心 狼 ， 胃 口 大 诡 计 狂 ， 我 们 必 须 保 和 平 卫 祖 国  。 打 倒 美 帝 野 心 狼 ！"), 3)
	d25.condition = func() -> bool:
		return A.has_agents(150) and A.is_science_done(25, true) and A.oncein(25, true)
	d25.effects = [
		func(): A.add_agents(-150),
		func(): A.do_timer(25, 6),
		func(): A.add_american_influence(-50),
	]
	_defs.append(d25)

	# idx 26 在苏修集团内挖墙脚（new_texts[647]/[648]）
	var d26 := _new(26, _s("在 苏 修 集 团 内 挖 墙 脚"), _s("显 然 ， 苏 修 德 不 配 位 ！ 但 他 们 留 下 的 躯 壳 还 是 能 为 我 们 所 用 。 既 然 我 们 已 经 打 入 了 苏 修 集 团 ， 那 当 然 得 好 好 创 造 条 件 ， 随 后 顺 势 而 为 ！ 我 们 将 运 用 各 类 权 术 势 争 取 盟 友 ， 瓦 解 敌 人 ， 让 万 国 来 朝 的 盛 况 重 演 ！"), 3)
	d26.condition = func() -> bool:
		return A.is_in_the_wp(true, 1) and A.has_agents(50) and A.has_army(150) \
			and A.has_money(50) and A.is_science_done(19, true) and A.oncein(26, true)
	d26.effects = [
		func(): A.add_agents(-50),
		func(): A.add_army(-150),
		func(): A.add_money(-50),
		func(): A.do_timer(26, 6),
		func(): A.add_soviet_influence(-10),
		func(): A.add_infl_alliance(-350, 1),
		func(): A.add_infl_alliance(200, 3),
	]
	_defs.append(d26)

	# idx 27 在美帝集团内挖墙脚（new_texts[653]/[654]）
	var d27 := _new(27, _s("在 美 帝 集 团 内 挖 墙 脚"), _s("显 然 ， 美 帝 德 不 配 位 ！ 但 他 们 留 下 的 躯 壳 还 是 能 为 我 们 所 用 。 既 然 我 们 已 经 打 入 了 美 帝 集 团 ， 那 当 然 得 好 好 创 造 条 件 ， 随 后 顺 势 而 为 ！ 我 们 将 运 用 各 类 权 术 势 争 取 盟 友 ， 瓦 解 敌 人 ， 让 万 国 来 朝 的 盛 况 重 演 ！"), 3)
	d27.condition = func() -> bool:
		return A.is_in_the_seato(true, 1) and A.has_agents(50) and A.has_army(150) \
			and A.has_money(50) and A.is_science_done(19, true) and A.oncein(27, true)
	d27.effects = [
		func(): A.add_agents(-50),
		func(): A.add_army(-150),
		func(): A.add_money(-50),
		func(): A.do_timer(27, 6),
		func(): A.add_american_influence(-10),
		func(): A.add_infl_alliance(-350, 2),
		func(): A.add_infl_alliance(200, 3),
	]
	_defs.append(d27)

	# idx 28 斩断苏修伸向非洲的黑手（new_texts[655]/[656]）
	var d28 := _new(28, _s("斩 断 苏 修 伸 向 非 洲 的 黑 手"), _s("苏 修 新 沙 皇 正 向 非 洲 地 区 伸 出 黑 手 ， 大 放 本 国 修 正 主 义 毒 草 。 必 须 坚 决 扫 除 这 些 害 人 虫 ！"), 3)
	d28.condition = func() -> bool:
		return A.has_agents(200) and A.has_army(250) and A.has_money(200) \
			and A.is_science_done(20, true) and A.is_science_done(24, true) and A.oncein(28, true)
	d28.effects = [
		func(): A.add_agents(-200),
		func(): A.add_army(-250),
		func(): A.add_money(-200),
		func(): A.do_timer(28, 6),
		func(): A.add_soviet_influence(-10),
		func(): A.add_all_afrique(-250, 1),
		func(): A.add_all_afrique(100, 3),
		func(): A.add_stability_afrique(-100),
	]
	_defs.append(d28)

	# idx 29 斩断美帝伸向非洲的黑手（new_texts[657]/[658]）
	var d29 := _new(29, _s("斩 断 美 帝 伸 向 非 洲 的 黑 手"), _s("美 帝 野 心 狼 正 向 非 洲 地 区 伸 出 黑 手 ， 大 放 本 国 帝 国 主 义 毒 草 。 必 须 坚 决 扫 除 这 些 害 人 虫 ！"), 3)
	d29.condition = func() -> bool:
		return A.has_agents(200) and A.has_army(250) and A.has_money(200) \
			and A.is_science_done(20, true) and A.is_science_done(24, true) and A.oncein(29, true)
	d29.effects = [
		func(): A.add_agents(-200),
		func(): A.add_army(-250),
		func(): A.add_money(-200),
		func(): A.do_timer(29, 6),
		func(): A.add_american_influence(-10),
		func(): A.add_all_afrique(-250, 2),
		func(): A.add_all_afrique(100, 3),
		func(): A.add_stability_afrique(-100),
	]
	_defs.append(d29)

	# idx 30 作有关战争与革命主题的演讲（new_texts[667]/[669]）
	var d30 := _new(30, _s("作 有 关 战 争 与 革 命 主 题 的 演 讲"), _s("我 国 领 导 人 将 站 上 联 合 国 主 席 台 ， 代 表 全 体 中 国 人 民 的 揭 露 超 级 大 国 的 真 面 目 ， 揭 露 帝 国 主 义 的 丑 恶 野 心 ， 揭 露 他 们 未 来 定 灭 亡 的 历 史 大 势 ！"), 3)
	d30.condition = func() -> bool:
		return A.has_money(50) and A.oncein(30, true)
	d30.effects = [
		func(): A.add_money(-50),
		func(): A.do_timer(30, 6),
		func(): A.add_chinese_influence(-10),
		func(): A.add_relations(0, -150),
		func(): A.add_relations(1, -150),
		func(): A.add_diplo(100),
	]
	_defs.append(d30)

	# idx 31 作有关和平与发展主题的演讲（new_texts[670]/[671]）
	var d31 := _new(31, _s("作 有 关 和 平 与 发 展 主 题 的 演 讲"), _s("我 国 领 导 人 将 站 上 联 合 国 主 席 台 ， 喊 出 全 体 中 国 人 民 的 呼 声 ： 不 要 战 争 要 和 平 ！ 不 要 扩 军 要 裁 军 ！ 不 要 冷 战 要 合 作 ！"), 3)
	d31.condition = func() -> bool:
		return A.has_money(50) and A.oncein(31, true)
	d31.effects = [
		func(): A.add_money(-50),
		func(): A.do_timer(31, 6),
		func(): A.add_chinese_influence(-10),
		func(): A.add_relations(0, 150),
		func(): A.add_relations(1, 150),
		func(): A.add_diplo(-100),
	]
	_defs.append(d31)

	# idx 32 发展石油生产（new_texts[672]/[673]）—— IsIndustry 阈值运行时取 data[152]
	var d32 := _new(32, _s("发 展 石 油 生 产"), _s("在 自 产 石 油 方 面 站 稳 了 脚 跟 子 ， 我 们 的 经 济 才 能 立 起 腰 杆 子 ， 在 洋 油 的 糖 衣 炮 弹 面 前 也 就 有 了 底 子 。"), 3)
	d32.condition = func() -> bool:
		var ws := A._ws()
		var how := ws.数值表[WorldState.I_INDUSTRY_BASE] if ws != null and ws.数值表.size() > WorldState.I_INDUSTRY_BASE else 0
		return A.has_money(50) and A.oncein(32, true) and A.is_science_done(10, true) \
			and A.has_oil(true) and A.is_industry(how, true)
	d32.effects = [
		func(): A.do_timer(32, 6),
		func(): A.add_money(-50),
		func(): A.add_oil_prud(150),
	]
	_defs.append(d32)

	# idx 33 东西伯利亚-太平洋管道计划（new_texts[678]/[679]）
	var d33 := _new(33, _s("东 西 伯 利 亚 - 太 平 洋 管 道 计 划"), _s("苏 联 ， 老 产 油 国 了 。 中 国 ， 老 油 老 虎 了 。 既 然 这 样 ， 在 双 方 之 间 修 建 条 石 油 管 道 ， 岂 不 是 一 件 皆 大 欢 喜 的 事 吗 ？ 我 们 的 经 济 将 腾 飞 ， 我 们 将 花 出 去 的 油 料 钱 将 留 下 ！工 期 将 持 续 12 月 ， 每 两 周 消 耗 0.5 点 预 算"), 3)
	d33.condition = func() -> bool:
		return A.has_money(100) and A.is_science_done(12, true) and A.has_oil(true) \
			and A.is_industry(700, true) and A.has_soviet_friendship(true) and A.is_realtions(700, 1, true)
	d33.effects = [
		func(): A.add_money(-100),
		func(): A.add_old_modify(58),
	]
	_defs.append(d33)

	# idx 34 绿水青山，省下金山银山（new_texts[682]/[683]）
	var d34 := _new(34, _s("绿 水 青 山 ， 省 下 金 山 银 山"), _s("新 技 术 将 帮 助 我 们 开 源 节 流 ， 今 天 我 们 对 此 投 资 的 越 多 ， 明 天 我 们 所 要 花 的 石 油 进 口 费 就 将 更 少 。"), 3)
	d34.condition = func() -> bool:
		return A.has_money(50) and A.oncein(34, true) and A.is_science_done(16, true) \
			and A.has_oil(true) and A.is_industry(700, true) and A.has_oil_eat(200)
	d34.effects = [
		func(): A.do_timer(34, 6),
		func(): A.add_money(-50),
		func(): A.add_oil_eat(-100),
	]
	_defs.append(d34)

	# idx 35 “世纪交易”的终结（new_texts[688]/[689]）—— 链尾三条件原版重复一次，照抄
	var d35 := _new(35, _s("“ 世 纪 交 易 ” 的 终 结"), _s("20 世 纪 70 年 代 签 署 的 “ 天 然 气 换 管 道 ” 协 定 对 苏 联 来 说 意 义 非 凡 ， 它 得 以 让 苏 联 绕 开 美 国 禁 运 ， 牢 牢 把 持 自 己 对 碳 氢 化 合 物 能 源 价 格 的 控 制 权 。 然 而 ， 在 联 邦 德 国 境 内 社 民 党 执 政 联 盟 的 垮 台 ， 亲 西 方 的 基 督 教 民 主 党 人 得 以 重 返 政 坛 的 大 背 景 下 。 我 们 可 以 同 美 国 伙 伴 一 道 对 德 方 “ 晓 之 以 情 ” ， 从 而 结 束 苏 联 的 好 日 子 ， 转 而 让 我 们 的 缅 甸 盟 友 的 油 气 业 务 赢 得 发 展 的 第 二 春 。"), 3)
	d35.condition = func() -> bool:
		return A.has_money(100) and A.has_agents(100) and A.is_cia(true) \
			and A.has_soviet_friendship(false) and A.is_year_less(false, 1983) \
			and A.is_chinese_influence_less_than(false, 350) and A.is_science_done(10, true) \
			and A.has_oil(true) and A.is_industry(700, true) and A.pro_chinese(33) \
			and A.is_science_done(10, true) and A.has_oil(true) and A.is_industry(700, true)
	d35.effects = [
		func(): A.add_money(-100),
		func(): A.add_agents(-100),
		func(): A.add_oil_price(-10),
		func(): A.add_soviet_influence(-200),
		func(): A.add_american_influence(150),
		func(): A.add_chinese_influence(100),
	]
	_defs.append(d35)

	# idx 36 斩断锁链，涅槃重生（内嵌文本）
	var d36 := _new(36, _s("斩 断 锁 链 ， 涅 槃 重 生"), _s("非 洲 - - 人 类 的 故 乡 ， 在 殖 民 者 的 手 中 饱 经 摧 残 ， 造 成 了 人 类 有 史 以 来 最 残 暴 的 强 制 迁 徙 和 种 族 灭 绝 。 而 随 着 非 洲 人 民 的 觉 醒 ， 这 一 切 都 不 会 再 发 生 了 。 泛 非 主 义 者 们 强 烈 要 求 在 某 种 程 度 上 统 一 非 洲 ， 不 论 国 际 组 织 还 是 松 散 的 联 邦 。 我 们 将 帮 助 他 们 组 建 用 于 协 调 非 洲 各 进 步 国 家 和 革 命 组 织 的 联 盟 , 这 对 我 们 和 非 洲 各 国 都 有 好 处 。 不 过 帝 国 主 义 者 … … 但 是 谁 在 乎 他 们 呢 ， 胜 利 属 于 觉 醒 的 人 民 !"), 3)
	d36.condition = func() -> bool:
		return A.has_revolutionary_leader(true) and A.has_money(200) and A.has_army(300) \
			and A.is_chinese_influence_less_than(false, 500) and A.is_african_proprc(true) \
			and A.is_african_socialism(true)
	d36.effects = [
		func(): A.african_alliance(true),
		func(): A.start_event(500),
	]
	_defs.append(d36)

	# idx 37 攘外安内，伟大复兴（内嵌文本）
	var d37 := _new(37, _s("攘 外 安 内 ， 伟 大 复 兴"), _s("我 们 内 部 的 敌 人 固 然 凶 险 ， 但 在 名 义 上 他 们 还 是 我 国 内 政 。 相 比 起 来 ， 境 外 的 敌 人 更 令 我 们 担 忧 。 不 论 是 虎 视 眈 眈 的 苏 联 社 会 帝 国 主 义 ， 像 猎 鹰 般 凶 狠 的 美 帝 国 主 义 ， 乃 至 于 山 连 山 水 连 水 的 “ 兄 弟 国 家 ” 越 南 都 展 现 出 了 令 人 担 忧 的 离 心 力 。 为 了 我 们 社 会 的 安 定 发 展 ， 我 们 有 必 要 展 开 一 场 特 别 的 “ 联 合 军 事 演 习 ” 。"), 3)
	d37.condition = func() -> bool:
		return A.have_been_zhu_ti(true) and A.have_full_china(true) and A.they_are_ours(1) \
			and A.no_zhu_ti_war(true) and A.hasnt_jue_qi(true)
	d37.effects = [func(): A.start_event(642)]
	_defs.append(d37)

	# idx 38 乡土中国（内嵌文本）
	var d38 := _new(38, _s("乡 土 中 国"), _s("如 果 我 们 要 彻 底 重 构 中 国 社 会 ， 那 便 绕 不 开 构 成 其 根 本 ， 占 据 相 当 多 数 的 农 民 、 农 业 与 农 村 ： 毕 竟 ， 中 国 革 命 的 成 功 正 仰 赖 于 此 。 现 在 我 们 所 作 的 不 过 是 摸 着 前 人 过 河 ， 让 农 村 地 带 的 大 转 变 成 为 通 向 未 来 的 坚 实 基 础 。"), 3)
	d38.condition = func() -> bool:
		return A.has_chosen_in_the_event(681, 4) and A.has_maoismus(false) \
			and A.is_party_support_less_than(false, 800) and A.has_money(200)
	d38.effects = [func(): A.start_event(682)]
	_defs.append(d38)

	# idx 39 我们的国歌（内嵌文本）
	var d39 := _new(39, _s("我 们 的 国 歌"), _s("国 歌 是 我 国 国 家 的 象 征 ， 但 由 于 政 治 因 素 长 期 无 法 正 式 确 立 。 现 在 ， 如 果 通 过 行 政 手 段 确 定 我 国 的 国 歌 ， 就 能 为 我 们 在 新 的 时 代 指 引 航 向 。"), 3)
	d39.condition = func() -> bool:
		return A.is_after_the_day(true, 1978, 3, 5) and A.has_money(30) \
			and A.is_party_support_less_than(false, 500) and A.has_one_party_mechanic(true) \
			and A.has_anthem_confirmed(true)
	d39.effects = [func(): A.start_event(61)]
	_defs.append(d39)

	# idx 40 废除票证制度（三元 data[16]<14）
	var d40 := _new(40, _s("废 除 票 证 制 度"), _s("随 着 我 国 经 济 水 平 的 上 升 与 经 济 形 势 的 进 一 步 变 化 ， 有 必 要 渐 进 废 除 票 证 制 度 ， 以 满 足 人 民 群 众 的 日 常 生 活 和 消 费 需 求 ， 为 我 国 经 济 的 后 续 变 革 打 下 基 础 。"), 3)
	var d40_party := -100 if A._d().size() > WorldState.I_ECON_SYSTEM and A._d()[WorldState.I_ECON_SYSTEM] < 14 else 200
	d40.condition = func() -> bool:
		return A.can_coupon_system_phase_out(true) and A.has_money(50) and A.has_reserve(150)
	d40.effects = [
		func(): A.add_money(-50),
		func(): A.add_support(250),
		func(): A.add_party_support(d40_party),
		func(): A.coupon_system_will_phase_out(true),
	]
	_defs.append(d40)

	# idx 41 建立计划性降价制度（内嵌文本）
	var d41 := _new(41, _s("建 立 计 划 性 降 价 制 度"), _s("若 要 建 立 为 人 民 服 务 的 体 制 ， 就 必 须 充 分 考 虑 社 会 效 益 ， 照 顾 国 内 人 民 需 求 。 既 然 代 表 全 民 利 益 的 经 济 成 分 已 占 据 国 民 经 济 的 制 高 点 ， 那 要 求 其 向 全 民 让 利 也 是 理 所 应 当 。 今 后 ， 国 家 计 划 委 员 会 将 在 履 行 一 般 经 济 计 划 的 同 时 ， 以 季 度 与 年 度 为 基 本 单 位 导 入 并 扩 充 产 品 降 价 计 划 ， 让 社 会 生 产 惠 及 全 体 人 民 ！"), 3)
	d41.condition = func() -> bool:
		return A.is_coupon_system_phased_out(true) and A.left_in_major(true) \
			and A.has_planned_economy(true) and A.has_money(50) \
			and A.is_party_support_less_than(false, 700) and A.is_sectors_well(true) \
			and A.has_planned_price_reduction(false)
	d41.effects = [
		func(): A.add_money(-50),
		func(): A.add_support(250),
		func(): A.get_planned_price_reduction(true),
	]
	_defs.append(d41)

	# idx 42 引入有民族特色的紧缩疗法（内嵌文本）
	var d42 := _new(42, _s("引 入 有 民 族 特 色 的 紧 缩 疗 法"), _s("在 国 家 仍 占 据 国 内 经 济 制 高 点 ， 对 国 内 经 济 控 制 力 依 然 坚 挺 的 情 况 下 ， 我 们 能 以 远 超 海 外 同 行 想 象 的 方 式 实 行 紧 缩 政 策 ： 从 物 价 控 制 到 贸 易 管 控 ， 从 削 减 预 算 到 取 消 补 贴 ， 以 及 引 入 限 电 限 产 令 与 票 证 制 度 。 只 要 我 们 想 ， 那 大 可 能 够 调 动 一 切 积 极 因 素 为 积 累 资 金 做 准 备 。"), 3)
	d42.condition = func() -> bool:
		return A.left_in_major(true) and A.has_capitalist_economy(false) \
			and A.is_party_support_less_than(false, 700) and A.is_debt_less_than(false, 150) \
			and A.is_reserve_less_than(true, 50) and A.has_austerity(false)
	d42.effects = [
		func(): A.add_money(100),
		func(): A.add_party_support(-250),
		func(): A.add_support(-250),
		func(): A.add_import(-50),
		func(): A.get_austerity(true),
	]
	_defs.append(d42)

	# idx 43 广泛实行消费券与负所得税制度（内嵌文本）
	var d43 := _new(43, _s("广 泛 实 行 消 费 券 与 负 所 得 税 制 度"), _s("上 述 概 念 均 源 自 货 币 学 派 理 论 家 ， 新 自 由 主 义 学 者 米 尔 顿 · 弗 里 德 曼 的 理 论 。 要 求 政 府 以 消 费 者 服 务 员 ， 而 非 生 产 供 给 者 的 身 份 参 与 经 济 事 务 并 丰 富 社 会 需 求 ： 国 家 将 以 发 放 代 金 券 的 方 式 鼓 励 居 民 购 买 市 场 服 务 与 支 持 企 业 ， 并 通 过 一 个 逆 向 支 付 体 系 实 现 财 富 从 富 裕 阶 层 向 贫 困 人 口 的 再 分 配 。"), 3)
	d43.condition = func() -> bool:
		return A.left_in_major(false) and A.has_capitalist_economy(true) \
			and A.is_party_support_less_than(false, 700) and A.is_reserve_less_than(false, 200) \
			and A.has_developed_consumerism(false)
	d43.effects = [
		func(): A.add_support(200),
		func(): A.get_developed_consumerism(true),
	]
	_defs.append(d43)

	# idx 44 打造新时代公社社员（内嵌文本）
	var d44 := _new(44, _s("打 造 新 时 代 公 社 社 员"), _s("除 却 冲 锋 陷 阵 打 头 阵 外 ， 我 党 党 员 绝 无 其 他 特 权 。 作 为 中 国 进 步 事 业 的 排 头 兵 ， 我 们 也 理 应 以 相 应 规 格 的 高 标 准 要 求 自 身 — — 首 先 便 是 为 特 供 特 办 画 上 句 号 ， 解 决 党 员 与 群 众 间 物 质 待 遇 不 平 等 ， 社 会 身 份 差 距 大 的 问 题 ； 接 下 来 便 是 通 过 引 入 薪 酬 最 高 限 额 、 公 职 任 期 与 替 代 选 举 等 政 策 将 党 员 们 训 练 为 全 心 全 意 为 人 民 服 务 的 公 仆 ！"), 3)
	d44.condition = func() -> bool:
		return A.has_corrupt_leader(false) and A.is_party_support_less_than(false, 950) \
			and A.is_corruption_less_than(true, 1) and A.is_envelope_less_than(true, 1) \
			and A.has_money_level(false) and A.has_new_era_commune_member(false) \
			and A.has_party_means_party(false)
	d44.effects = [
		func(): A.add_party_support(-250),
		func(): A.add_support(250),
		func(): A.get_new_era_commune_member(true),
		func(): A.eliminate_corrupt_elements(true),
	]
	_defs.append(d44)

	# idx 45 政党即派对（内嵌文本）
	var d45 := _new(45, _s("政 党 即 派 对"), _s("政 党 政 党 ， 顾 名 思 义 ， 它 首 先 是 属 于 党 员 的 组 织 — — 倘 若 我 们 连 嫡 系 都 没 法 照 顾 好 ， 又 何 谈 治 国 平 天 下 呢 ？ 因 此 ， 我 们 有 必 要 在 苏 联 编 制 党 管 干 部 特 权 的 经 验 上 更 胜 一 筹 ， 为 我 党 健 儿 们 安 排 好 专 属 住 宅 、 养 老 金 、 购 物 优 惠 ； 以 及 包 括 司 法 豁 免 与 优 先 任 命 在 内 的 各 种 政 治 便 利 ！ 顺 带 引 入 根 据 党 龄 与 阶 级 向 高 层 反 向 支 付 与 税 费 优 惠 的 体 系 。 人 人 为 我 ， 才 能 谈 我 为 人 人 ！"), 3)
	d45.condition = func() -> bool:
		return A.has_money(50) and A.is_party_support_less_than(false, 500) \
			and A.is_envelope_less_than(false, 150) and A.is_consociational_democracy(false) \
			and A.has_new_era_commune_member(false) and A.has_party_means_party(false)
	d45.effects = [
		func(): A.add_money(-50),
		func(): A.add_party_support(100),
		func(): A.add_loyality_to_all_politicians(500),
		func(): A.get_party_means_party(true),
	]
	_defs.append(d45)

	# idx 46 设立政党补助金（内嵌文本）
	var d46 := _new(46, _s("设 立 政 党 补 助 金"), _s("现 代 民 主 国 家 为 鼓 励 政 党 制 度 发 展 而 采 纳 的 创 举 ： 为 降 低 政 党 组 织 对 工 会 、 公 司 等 专 门 赞 助 者 的 依 附 性 ， 国 家 将 从 国 库 内 拨 付 一 部 分 款 项 支 付 给 议 会 政 党 ， 以 协 助 国 内 主 要 的 政 治 力 量 开 展 政 治 活 动 。 议 会 议 员 将 同 公 务 员 般 享 受 国 家 支 持 — — 当 然 也 意 味 着 他 们 也 将 同 公 务 员 般 受 驱 使 。"), 3)
	d46.condition = func() -> bool:
		return A.has_money(150) and A.has_one_party_mechanic(false) and A.is_major_in_election(true) \
			and A.has_new_era_commune_member(false) and A.has_party_subsidy(false)
	d46.effects = [
		func(): A.add_party_support(100),
		func(): A.add_loyality_to_all_politicians(500),
		func(): A.ally_with_other_parties(true),
		func(): A.get_party_subsidy(true),
	]
	_defs.append(d46)

	# idx 47 与苏联达成购买T-72坦克的长期军事合同（内嵌文本）
	var d47 := _new(47, _s("与 苏 联 达 成 购 买T-72 坦 克 的 长 期 军 事 合 同"), _s("我 国 幅 员 辽 阔 ， 兼 有 世 界 上 最 为 复 杂 的 边 界 ， 国 防 压 力 可 想 而 知 。 而 苏 联 的T-72 坦 克 恰 能 满 足 我 国 的 战 略 需 求 ： 物 美 价 廉 ， 易 于 列 装 ， 尤 其 适 合 大 规 模 作 战 。 将 其 列 入 我 国 制 式 装 备 不 仅 有 助 于 中 国 国 防 事 业 ， 还 能 让 我 们 有 机 会 一 瞥 国 际 最 新 技 术 成 果 。"), 3)
	d47.condition = func() -> bool:
		return A.has_soviet_cooperation(true) and A.has_soviet_in_nato(false) \
			and A.has_trade_with_usa(false) and A.is_realtions(800, 1, true) \
			and A.has_money(100) and A.has_t72(false)
	d47.effects = [
		func(): A.add_money(-50),
		func(): A.get_t72(true),
	]
	_defs.append(d47)

	# idx 48 为私人军事服务公司发展提供便利（内嵌文本）
	var d48 := _new(48, _s("为 私 人 军 事 服 务 公 司 发 展 提 供 便 利"), _s("直 接 实 施 干 预 的 时 代 早 已 成 为 历 史 ， 当 今 的 战 场 是 属 于 代 理 人 们 的 ！ 早 在 古 希 腊 时 期 ， 各 国 就 已 开 始 使 用 雇 佣 兵 为 自 身 利 益 效 力 。 现 在 的 他 们 更 是 顺 应 时 势 拓 展 经 营 业 务 ， 并 已 换 上 “ 私 人 军 事 服 务 公 司 ” 的 马 甲 赚 血 钱 。 其 中 有 些 角 色 更 是 扮 演 了 超 级 大 国 的 白 手 套 — — 作 为 “ 负 责 任 的 大 国 ” ， 我 们 为 什 么 不 能 如 此 入 局 呢 ？"), 3)
	d48.condition = func() -> bool:
		return A.is_socialism(false, 1) and A.has_capitalist_economy(true) and A.has_mercenary(true) \
			and A.is_science_done(19, true) and A.is_party_support_less_than(false, 900) \
			and A.has_army(150) and A.has_money(100)
	d48.effects = [
		func(): A.add_party_support(-100),
		func(): A.add_army(-100),
		func(): A.add_money(-100),
		func(): A.get_pmc(true),
	]
	_defs.append(d48)

	# idx 49 通过特殊渠道购买军事服务（内嵌文本）
	var d49 := _new(49, _s("通 过 特 殊 渠 道 购 买 军 事 服 务"), _s("历 史 经 验 表 明 ， 依 靠 义 务 征 召 与 国 家 强 制 集 结 与 培 训 军 人 既 耗 时 又 耗 力 ， 且 极 可 能 招 致 社 会 普 遍 不 满 与 部 分 行 业 内 的 劳 动 力 短 缺 ； 而 将 军 队 公 务 员 化 的 合 同 制 又 可 能 导 致 军 内 塞 满 尸 位 素 餐 之 徒 ， 难 以 确 保 其 战 斗 力 。 那 么 为 什 么 不 试 着 通 过 专 业 人 士 的 引 荐 ， 直 接 将 别 国 已 练 好 的 精 兵 悍 将 引 入 我 国 部 队 内 呢 ？"), 3)
	d49.condition = func() -> bool:
		return A.has_mercenary(true) and A.is_party_support_less_than(false, 800) \
			and A.has_money(150) and A.has_pmc(true) and A.has_eastern_rome(false) \
			and A.once_a_month(true)
	d49.effects = [
		func(): A.add_party_support(-100),
		func(): A.add_money(-150),
		func(): A.add_army(100),
		func(): A.mercenary_rebellion(true),
	]
	_defs.append(d49)

	# idx 50 窃国者侯（内嵌文本）
	var d50 := _new(50, _s("窃 国 者 侯"), _s("自 古 以 来 ， 中 国 便 以 地 大 物 博 ， 文 明 富 饶 著 称 。 长 期 以 来 ， 中 国 的 领 袖 也 基 本 上 以 匹 配 该 国 气 象 的 气 派 示 人 ， 并 将 国 家 作 为 私 产 运 营 — — 为 什 么 我 们 不 能 也 试 着 这 么 做 呢 ？|“ 人 的 欲 望 和 其 他 激 情 ， 本 质 上 是 受 到 他 自 己 控 制 的 ； 他 真 正 的 困 难 在 于 ， 要 知 道 何 时 需 要 加 以 控 制 ， 何 时 不 需 要 。 ” — — 托 马 斯 · 霍 布 斯"), 3)
	d50.condition = func() -> bool:
		return A.has_leader_asset(50) and A.has_maoismus(false) \
			and A.has_fourth_international(false) and A.has_nong_u(false) and A.once_a_month(true)
	d50.effects = [func(): A.start_event(694)]
	_defs.append(d50)

	# idx 51 破财消灾（内嵌文本）—— LeaderProperty 运行时读取（原版 lambda 内读）
	var d51 := _new(51, _s("破 财 消 灾"), _s("除 却 小 说 故 事 内 的 吝 啬 鬼 外 ， 没 人 想 一 直 捏 着 铜 板 — — 即 便 是 以 存 款 著 称 的 银 行 ， 也 是 更 热 衷 于 经 营 让 钱 脱 手 滚 利 的 贷 款 业 务 。 总 之 ， 有 挣 就 得 有 花 ： 西 方 国 家 的 朋 友 们 已 在 公 共 捐 赠 方 面 八 仙 过 海 ， 我 们 大 可 学 习 它 们 的 经 验 并 将 自 己 好 好 打 扮 。 前 提 当 然 是 还 有 余 粮 。"), 3)
	d51.condition = func() -> bool:
		return A.has_leader_asset(100) and A.once_a_month(true)
	d51.effects = [
		func(): A.add_leader_asset(-100),
		func():
			var ws := A._ws()
			var lp3 := ws != null and ws.leader_property.size() > 3 and ws.leader_property[3]
			A.add_party_support(50 if lp3 else 0),
		func(): A.add_support(100),
		func():
			var ws := A._ws()
			var lp2 := ws != null and ws.leader_property.size() > 2 and ws.leader_property[2]
			A.add_agents(25 if lp2 else 0),
		func():
			var ws := A._ws()
			var lp2 := ws != null and ws.leader_property.size() > 2 and ws.leader_property[2]
			A.add_army(25 if lp2 else 0),
	]
	_defs.append(d51)

	# idx 52 一箪食，一瓢饮（内嵌文本）
	var d52 := _new(52, _s("一 箪 食 ， 一 瓢 饮"), _s("欲 不 穷 于 物 ， 物 不 屈 于 欲 。 为 国 家 操 劳 一 生 的 伟 大 同 志 也 要 顾 及 最 小 家 ， 让 自 己 同 国 家 共 同 进 步 ， 齐 头 并 进 。 从 而 彰 显 大 国 领 袖 的 大 气 度 ， 打 出 大 国 元 首 的 大 招 牌 。"), 3)
	d52.condition = func() -> bool:
		return A.has_leader_asset(1000) and A.has_money_level(true) and A.once_a_month(true)
	d52.effects = [func(): A.start_event(712)]
	_defs.append(d52)
