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
	# 批次2/3 在此尾追加 _build_v2() / _build_v3()


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
