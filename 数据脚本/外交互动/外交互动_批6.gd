## 外交互动 批6 — 编号 82,84,85,86,87,88,91,92,93,94,95,96,97,98,99,100,101,103,104,105,106,107,110,111,113,114,115,117,118,119,120,122,123,124,125,126,127,128,130,131,132,133,134,145,146,149。
## 源码出处：DiploButtonScript.cs（Show L30-L5624 中文分支；OnMouseDown L8596 之后），行号以 工作记录/外交互动批6_源码行号.json 为准。
## 文案出处：Assets/Resources/other_text_en.txt、new_texts_en.xml、Events_text_en.txt（language==0 中文）。
extends "res://数据脚本/外交互动/外交互动_基础.gd"


## 原版 other_text_en.txt 索引 → 文案（本批引用到的行，自动提取）。
const OT := {
	29: " 通 过 煽 动 革 命 以 推 翻 敌 意 政 府",
	31: " 以 各 种 手 段 激 起 国 内 不 满 情 绪",
	32: " 破 坏 该 敌 意 国 家 的 政 治 与 经 济",
	33: " 不 满 水 平 高 于 发 展 水 平",
	34: " 不 亲 中",
	35: " 拥 有 5 百 万 预 算 ，5 特 工 网 络 ，5 军 事 实 力",
	39: " 亲 中",
	42: " 科 技 “ 情 报 部 门 新 装 备 ”",
	43: " 科 技 “ 新 式 间 谍 装 备 ”",
	44: " 尚 未 进 行 贸 易",
	45: " 工 业 和 农 业 均 >= 50.0",
	46: " 保 有 贸 易",
	47: " 协 助 该 友 好 政 权 处 理 国 内 矛 盾",
	48: " 达 成 我 们 间 的 长 效 收 益 合 约",
	49: " 郑 重 接 纳 该 国 加 入 我 们 的 经 济 联 盟",
	50: " 我 们 的 全 球 影 响 力 高 于 15.0  且 该 国 发 展 度- 不 满 度> 29",
	51: " 不 在 我 们 的 联 盟 中",
	52: " 我 们 在 军 事 联 盟 中",
	58: " 与 土 耳 其 极 左 派 建 立 联 系",
	59: " 与 土 耳 其 极 右 派 建 立 联 系",
	60: " 拥 有 {0} 百 万 资 金 ",
	61: " 需 要 {0} 点 特 工 网 络",
	62: " 在 1977 年 4 月 后",
	63: " 在 1980 年 9 月 前",
	64: " 他 们 仍 孤 立 无 援",
	66: " 就 解 决 库 尔 德 问 题 组 织 谈 判",
	67: " 土 耳 其 至 少 输 掉 了 一 场 战 争",
	68: " 还 没 有 组 织 谈 判",
	69: " 调 解 塞 浦 路 斯 问 题",
	72: " 战 争 已 经 结 束",
	74: " 施 压 当 地 政 府 ， 并 让 其 加 入 我 国 势 力 范 围",
	75: " 印 度 持 亲 中 立 场 ， 并 与 我 们 处 于 同 一 军 事 联 盟",
	76: " 国 际 影 响 力 高 于 60.0",
	77: " 拥 有 20 百 万 预 算 与 20 特 工 网 络",
	78: " 还 未 施 压 ",
	81: " 允 许 该 国 加 入 我 国 经 济 联 盟 ，建 立 全 面 战 略 合 作 伙 伴 关 系",
	82: " 邀 请 该 国 参 与 我 国 军 事 联 盟 ， 实 现 合 作 无 上 限 ， 保 障 地 区 安 全 稳 定",
	83: " 已 深 化 经 贸 关 系",
	84: " 中 国 已 建 立 经 合 组 织 ， 或 中 国 已 加 入 经 互 会",
	86: " 我 们 的 全 球 影 响 力 高 于 70.0",
	87: " 我 们 的 全 球 影 响 力 高 于 80.0",
	88: " 他 们 还 未 加 入 经 济 联 盟",
	89: " 他 们 还 未 加 入 军 事 联 盟",
	90: " 他 们 已 经 是 经 合 组 织 或 经 互 会 的 一 员",
	105: " 苏 联 未 加 入 北 约",
	107: " 将 斯 洛 伐 克 的 民 族 主 义 者 与 正 统 派 共 产 党 撮 合 为 联 合 反 对 派",
	108: " 拥 有 15 百 万 预 算 与 15 特 工 网 络",
	109: " 还 未 支 持",
	122: " 增 强 中 华 人 民 共 和 国 对 该 国 的 影 响 力{4}{0}： {1}； {2}： {3}；",
	123: " 中 国 影 响 力",
	124: " 北 约 影 响 力",
	125: " 中 国 对 该 国 的 影 响 力 高 于 35.0",
	126: " 增 强 我 国 与 该 国 的 经 济 一 体 化{4}{0}： {1}； {2}： {3}；",
	127: " 中 国 对 该 国 的 影 响 力 低 于 100.0",
	128: " 10 百 万 预 算",
	129: " 5 特 工 网 络",
	130: " 该 国 仍 保 持 中 立 地 位",
	132: " 在 该 国 建 立 中 国 军 事 基 地{4}{0}： {1}； {2}： {3}；",
	133: " 中 国 对 该 国 的 影 响 力 高 于 60.0",
	134: " 该 国 已 加 入 经 济 合 作 组 织 ， 但 尚 未 建 立 中 国 军 事 基 地",
	135: " 军 事 实 力 高 于 25.0",
	136: " 允 许 该 国 加 入 军 事 联 盟{4}{0}： {1}； {2}： {3}；",
	137: " 该 国 已 建 立 中 国 军 事 基 地 ， 但 尚 未 加 入 集 体 安 全 组 织",
	138: " 中 国 对 该 国 的 影 响 力 高 于 90.0",
	139: " 中 国 影 响 力 大 于 美 苏 影 响 力 之 和",
	141: " 加 入 情 报 组 织 联 盟 - “ 狩 猎 俱 乐 部 ”",
	142: " 1979 年 后 ； 外 交 声 誉 低 于 60.0.",
	143: " 埃 及 为 亲 美 政 权 ； 伊 朗 为 民 主 派 或 君 主 派 当 政",
	144: " 拥 有 科 技 “ 情 报 部 门 新 装 备 ” 且 我 国 未 加 入 经 互 会",
	145: " 法 国 总 统 是 德 斯 坦 或 希 拉 克 ， 且 我 们 还 未 加 入 该 组 织",
	146: " 离 开 “ 狩 猎 俱 乐 部 ”",
	147: " 我 们 已 经 加 入 该 组 织",
	159: " 支 持 埃 塞 俄 比 亚 人 民 解 放 阵 线 内 的 左 翼{0}左 翼 影 响 力 ： {1}",
	160: " 支 持 埃 塞 俄 比 亚 民 主 联 盟 内 的 右 翼{0}右 翼 影 响 力 ： {1}",
	163: " 支 持 提 格 雷 人 民 解 放 阵 线 内 的 左 翼{0}左 翼 影 响 力 ： {1}",
	164: " 支 持 提 格 雷 人 民 解 放 阵 线 内 的 右 翼{0}右 翼 影 响 力 ： {1}",
	167: " 支 持 厄 立 特 里 亚 人 民 解 放 阵 线 内 的 左 翼 民 族 主 义 者{0}左 翼 影 响 力 ： {1}",
	168: " 支 持 厄 立 特 里 亚 解 放 阵 线 内 的 右 翼 民 族 主 义 者{0}右 翼 影 响 力 ： {1}",
	169: " 其 中 一 派 已 完 全 掌 权",
	170: " 左 翼 影 响 力 低 于 100.0",
	171: " 5 百 万 预 算",
	172: " 5 特 工 网 络",
	173: " 还 未 有 一 派 完 全 掌 权",
	174: " 右 翼 影 响 力 低 于 100.0",
	177: " 支 持 工 党 内 的 托 洛 茨 基 主 义 组 织 。{0}托 派 影 响 力： {1}%",
	178: " 3 百 万 预 算 与 3 特 工 网 络",
	179: " 没 有 “ 文 化 大 革 命 ” 修 正",
	180: " 一 年 一 次",
	181: " 早 于 1981 年",
	185: " 就 联 盟 军 队 问 题 联 系 总 参 谋 部 ",
	186: " 就 联 盟 情 报 问 题 联 系 总 情 报 局",
	187: " 拥 有 修 正 效 果 “ 军 事 一 体 化 协 定 ”",
	188: " 拥 有 修 正 效 果 “ 特 勤 一 体 化 协 定 ”",
	189: " 事 件 还 未 触 发",
	196: " 加 入 东 南 亚 国 家 联 盟",
	197: " 我 国 政 体 不 是 社 会 主 义 且 党 的 路 线 至 少 为 改 良 主 义 （ 或 更 自 由 ）",
	198: " 中 国 未 加 入 经 互 会 且 未 成 立 经 合 组 织",
	199: " 还 未 加 入",
	200: " 不 早 于 1981 年",
	202: " 复 兴 东 南 亚 条 约 组 织",
	203: " 我 们 是 东 南 亚 国 家 联 盟 成 员 国",
	204: " 我 们 不 是 不 结 盟 运 动 成 员 国",
	206: " 邀 请 该 国 加 入 东 南 亚 国 家 联 盟 与 泛 亚 联 盟",
	207: " 该 国 不 处 于 苏 联 的 势 力 范 围",
	208: " 该 国 还 未 加 入 区 域 联 盟",
	209: " 我 国 政 体 不 是 社 会 主 义",
	210: " 邀 请 该 国 加 入 东 南 亚 条 约 组 织",
	211: " 邀 请 该 国 加 入 东 南 亚 条 约 组 织 与 中 央 条 约 组 织",
	212: " 我 们 是 东 南 亚 条 约 组 织 成 员 国",
	213: " 我 们 是 东 南 亚 条 约 组 织 与 中 央 条 约 组 织 成 员 国",
	214: " 他 们 已 经 加 入 了 经 济 联 盟",
	215: " 他 们 还 未 加 入 军 事 联 盟",
	216: " 条 约 组 织 与 中 央 条 约 组 织 已 被 合 并",
	221: " 引 爆 新 朝 鲜 战 争",
	222: " 拥 有 30 百 万 预 算 ，10 特 工 网 络",
	223: " 对 全 斗 焕 的 暗 杀 事 件 发 生",
	224: " 还 未 引 爆 战 争",
	227: " 支 持 持 不 同 政 见 者 组 织",
	228: " 拥 有 3 百 万 预 算 ，5 特 工 网 络",
	229: " 我 们 不 是 自 吹 自 擂 的 毛 派 分 子",
	230: " 外 交 声 誉 低 于 75.0",
	231: " 东 欧 ： 对 不 起 做 不 到",
	232: " 东 欧 ： 一 年 一 次",
	233: " 承 认 台 湾",
	235: " 离 开 我 们 所 属 的 一 切 联 盟",
	236: " 我 们 属 于 联 盟",
	237: " 一 年 一 次",
	239: " 与 美 国 一 道 组 织 自 由 派 政 变",
	241: " 拥 有 5 百 万 预 算 ，10 特 工 网 络",
	242: " 与 美 国 的 关 系 高 于 70.0",
	245: " 支 持 老 挝 反 对 派 并 发 动 起 义",
	246: " 泰 国 、 柬 埔 寨 与 越 南 均 加 入 东 南 亚 条 约 组 织",
	247: " 中 美 全 球 影 响 力 之 和 高 于 苏 联 影 响 力",
	248: " 拥 有 10 百 万 预 算 ，10 特 工 网 络 ，25 军 事 实 力",
	249: " 内 战 还 未 爆 发",
	252: " 组 织 亲 中 派 政 变",
	253: " 与 苏 联 的 关 系 高 于 70.0",
	257: " 鼓 励 戴 高 乐 主 义 者 退 出 北 约 和 欧 洲 经 济 共 同 体",
	258: " 雅 克 · 希 拉 克 为 法 国 总 统",
	259: " 中 国 全 球 影 响 力 高 于 美 国 影 响 力",
	260: " 意 大 利 、 希 腊 与 葡 萄 牙 已 退 出 北 约 和 欧 洲 经 济 共 同 体",
	261: " 法 国 处 于 北 约",
	264: " 给 葡 萄 牙 民 主 政 体 来 点 “ 尖 叫 ”{0}稳 定 度 ： {1}%",
	265: " 不 早 于 1982 年 ， 一 年 一 次",
	266: " 稳 定 度 低 于 100",
	267: " 特 工 网 络 ： - {1:F1}；  预算 ： - {0:F1} 百 万",
	268: " 现 在 还 不 是 时 候",
	269: " 该 国 政 体 不 是 自 由 主 义",
	278: " 支 持 亲 中 势 力{0}苏 联 影 响 力 ： {1}； 中 国 影 响 力 ： {2}",
	279: " 该 国 为 苏 联 势 力 范 围 或 保 持 中 立",
	280: " 拥 有 5 百 万 预 算 ，5 特 工 网 络 ，8 军 事 实 力",
	281: " 中 国 对 该 国 影 响 力 低 于 100.0",
	282: " 支 持 亲 中 势 力{0}美 国 影 响 力 ： {1}； 中 国 影 响 力 ： {2}",
	283: " 该 国 为 美 国 势 力 范 围 或 保 持 中 立",
	284: " 中 国 对 该 国 影 响 力 高 于 80.0",
	286: " 支 持 组 织 亲 中 政 变 ， 并 以 我 国 路 线 为 蓝 本 改 组 政 府 意 识 形 态",
	287: " 该 国 深 受 中 国 影 响",
	288: " 该 国 国 体 与 我 国 政 体 不 一 致",
	289: " 拥 有 5 百 万 预 算 与 5 特 工 网 络",
	294: " 对 伊 拉 克 发 起 军 事 干 涉",
	295: " 伊 拉 克 输 掉 了 对 科 威 特 的 战 争 ， 且 没 有 成 为 傀 儡 国",
	296: " 拥 有 25 百 万 预 算 ，15 特 工 网 络 ，35 军 事 实 力",
	297: " 中 国 是 集 安 组 织 的 成 员 国 ， 且 中 国 全 球 影 响 力 高 于 美 苏 影 响 力 之 和",
	298: " 还 未 策 划 入 侵",
	300: " 中 国 是 华 约 组 织 的 成 员 国 ， 且 中 苏 全 球 影 响 力 之 和 高 于 美 国 影 响 力",
	301: " 中 国 是 东 约 组 织 的 成 员 国 ， 且 中 美 全 球 影 响 力 之 和 高 于 苏 联 影 响 力",
	302: " 中 国 处 于 军 事 联 盟 中",
	304: " 对 该 国 实 施 补 贴 政 策 ， 从 而 增 强 我 国 影 响 力",
	305: " 尚 未 实 施 补 贴 政 策",
	306: " 取 消 对 该 国 的 补 贴 政 策",
	307: " 正 实 施 补 贴 政 策",
	450: " 每 3 月 一 次",
	454: " 5 特 工 网 络 ",
	460: " 对 海 湾 合 作 委 员 会 施 压 ， 要 求 其 减 产 石 油 。{0}世 界 油 价 将 变 为 每 桶 {1}$ 。",
	461: " 已 有 3 个 海 湾 合 作 委 员 会 成 员 国 选 择 亲 中 ， 且 我 国 全 球 影 响 力 高 于 60.0",
	462: " 世 界 油 价 低 于 每 桶 $60",
	463: " 对 海 湾 合 作 委 员 会 施 压 ， 要 求 其 增 产 石 油 。{0}世 界 油 价 将 变 为 每 桶 {1}$ 。",
	464: " 世 界 油 价 高 于 每 桶 $10",
	480: " 积 极 支 持 愿 意 同 我 们 合 作 的 当 地 右 派 势 力",
	481: " 20 百 万 预 算",
	482: " 20 特 工 网 络 ",
	483: " 北 约 与 欧 共 体 已 不 复 存 在",
	484: " 还 未 支 持",
}


## 原版 new_texts_en.xml / Events_text_en.txt 引用行。
const NT167 := " 美 国 影 响"
const NT168 := " 苏 联 影 响"
const NTE1214 := " 中 国 国 际 影 响 力"
const NTE1237 := " 老 挝 内 战"
const NTE1238 := " 老 挝 人 民 民 主 共 和 国"
const NTE1239 := " 老 挝 民 族 联 合 解 放 阵 线"
const NTE1320 := " 华 沙 条 约 入 侵 伊 拉 克"
const NTE1321 := " 华 沙 条 约"
const NTE1322 := " 伊 拉 克"
const NTE1323 := " 东 约 与 北 约 联 合 入 侵 伊 拉 克"
const NTE1324 := " 北 约 / 东 约"
const NTE1325 := " 集 安 组 织 入 侵 伊 拉 克"
const NTE1326 := " 集 安 组 织"



# ── 批6 专用辅助 ──

## 原版 science[i] → w.techs.unlocked[i]（越界默认 false）。
func _sci(w: WorldState, idx: int) -> bool:
	return w.techs != null and idx >= 0 and idx < w.techs.unlocked.size() and w.techs.unlocked[idx]


## 原版 modifies[i].active 写入；槽位不存在则补齐。
func _set_mod(w: WorldState, idx: int, value: bool) -> void:
	while w.modifiers.size() <= idx:
		w.modifiers.append(null)
	var slot := w.modifiers[idx]
	if slot == null:
		slot = ModifierSlot.new(idx)
		w.modifiers[idx] = slot
	slot.is_active = value


## 原版 completedDecisions[i] 读取。
func _dec_done(w: WorldState, idx: int) -> bool:
	return w.decisions != null and idx >= 0 and idx < w.decisions.completed.size() and w.decisions.completed[idx]


## 原版 LeaderProperty[i] 读取（WorldState.leader_property）。
func _lp(w: WorldState, idx: int) -> bool:
	return idx >= 0 and idx < w.leader_property.size() and w.leader_property[idx]


## 原版 war_active[i] 读取（越界默认 false）。
func _war_active(w: WorldState, idx: int) -> bool:
	return idx >= 0 and idx < w.war_active.size() and w.war_active[idx]


## 原版 war_active[i] 写入；数组按需补齐。
func _set_war_active(w: WorldState, idx: int, value: bool) -> void:
	while w.war_active.size() <= idx:
		w.war_active.append(false)
	w.war_active[idx] = value


## 原版 Israellost（批6 类型93）：两个旗标等价。
func _israel_lost(w: WorldState) -> bool:
	return w.get_flag("israellost") or w.get_flag("israel_lost_lebanon_war")


## 原版 Show 中的“不满度/发展度”尾部说明。
func _opis_ub(_w: WorldState, country: CountryData, head: String) -> String:
	return "%s|不 满 度 ：%d ， 发 展 度 ：%d" % [head, country.level_of_instability, country.level_of_development]


## 主分发：返回 {caption, opis, conditions, effect, dormant} 或 {}。
func build_action(action_type: int, ctx: Dictionary) -> Dictionary:
	var w: WorldState = ctx.get("w")
	var _darr: Array = ctx.get("d", [])
	var country: CountryData = ctx.get("country")
	var caption: String = ctx.get("caption", "")
	match action_type:
		82:
			return _def_82(w, country, caption)
		84:
			return _def_84(w, country, caption)
		85:
			return _def_85(w, country, caption)
		86:
			return _def_86(w, country, caption)
		87:
			return _def_87(w, country, caption)
		88:
			return _def_88(w, country, caption)
		91:
			return _def_91(w, country, caption)
		92:
			return _def_92(w, country, caption)
		93:
			return _def_93(w, country, caption)
		94:
			return _def_94(w, country, caption)
		95:
			return _def_95(w, country, caption)
		96:
			return _def_96(w, country, caption)
		97:
			return _def_97(w, country, caption)
		98:
			return _def_98(w, country, caption)
		99:
			return _def_99(w, country, caption)
		100:
			return _def_100(w, country, caption)
		101:
			return _def_101(w, country, caption)
		103:
			return _def_103(w, country, caption)
		104:
			return _def_104(w, country, caption)
		105:
			return _def_105(w, country, caption)
		106:
			return _def_106(w, country, caption)
		107:
			return _def_107(w, country, caption)
		110:
			return _def_110(w, country, caption)
		111:
			return _def_111(w, country, caption)
		113:
			return _def_113(w, country, caption)
		114:
			return _def_114(w, country, caption)
		115:
			return _def_115(w, country, caption)
		117:
			return _def_117(w, country, caption)
		118:
			return _def_118(w, country, caption)
		119:
			return _def_119(w, country, caption)
		120:
			return _def_120(w, country, caption)
		122:
			return _def_122(w, country, caption)
		123:
			return _def_123(w, country, caption)
		124:
			return _def_124(w, country, caption)
		125:
			return _def_125(w, country, caption)
		126:
			return _def_126(w, country, caption)
		127:
			return _def_127(w, country, caption)
		128:
			return _def_128(w, country, caption)
		130:
			return _def_130(w, country, caption)
		131:
			return _def_131(w, country, caption)
		132:
			return _def_132(w, country, caption)
		133:
			return _def_133(w, country, caption)
		134:
			return _def_134(w, country, caption)
		145:
			return _def_145(w, country, caption)
		146:
			return _def_146(w, country, caption)
		149:
			return _def_149(w, country, caption)
	return {}


# ============================================================================
# 编号 82 · 通过煽动革命以推翻敌意政府
# DBS Show L2169-L2187 / OnMouseDown L9864-L9889
# ============================================================================
func _def_82(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := _opis_ub(w, country, OT[29])
	var conds: Array = []
	conds.append(cond(OT[33], func(): return country.level_of_instability - country.level_of_development > 0))
	conds.append(cond(OT[34], func(): return not has(country, "亲中")))
	conds.append(cond(OT[35], func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50 and d(w, 22) >= 50))
	var eff := func():
		if has(country, "亲美"):
			add_power(w, 0, -10)
			add_rel(w, 0, -150)
		elif has(country, "亲苏"):
			add_power(w, 1, -10)
			add_rel(w, 1, -150)
		country.set_tag("亲美", false)
		country.set_tag("亲苏", false)
		country.set_tag("亲中", true)
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 50)
		set_d(w, 22, d(w, 22) - 50)
		w.influence_prc += 5
		add_power(w, 0, -10)
		add_rel(w, 0, -250)
		# 原版 rev_done=true 为散落 bool；Godot 用全局旗标建模。
		set_fl(w, "rev_done", true)
		country.sub_government = get_sub_gosstory(w)
		var c1 := c(w, 1)
		if c1 != null:
			country.government = c1.government
		country.next_election_year = 2222
		country.next_election_month = 2
		country.next_election_day = 22
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 84 · 以各种手段激起国内不满情绪
# DBS Show L2200-L2218 / OnMouseDown L9916-L9930
# ============================================================================
func _def_84(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := _opis_ub(w, country, OT[31])
	var conds: Array = []
	conds.append(cond(OT[42], func(): return _sci(w, 19)))
	conds.append(cond(OT[34], func(): return not has(country, "亲中")))
	conds.append(cond(" 拥 有 1 百 万 预 算 ，1 特 工 网 络 ，1 军 事 实 力",
		func(): return d(w, 8) + d(w, 36) >= 10 and d(w, 9) >= 10 and d(w, 22) >= 10))
	var eff := func():
		if has(country, "亲美"):
			add_rel(w, 0, -10)
		elif has(country, "亲苏"):
			add_rel(w, 1, -10)
		country.level_of_instability += 10
		set_d(w, 8, d(w, 8) - 10)
		set_d(w, 9, d(w, 9) - 10)
		set_d(w, 22, d(w, 22) - 10)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 85 · 破坏该敌意国家的政治与经济
# DBS Show L2219-L2237 / OnMouseDown L9931-L9945
# ============================================================================
func _def_85(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := _opis_ub(w, country, OT[32])
	var conds: Array = []
	conds.append(cond(OT[43], func(): return _sci(w, 20)))
	conds.append(cond(OT[34], func(): return not has(country, "亲中")))
	conds.append(cond(" 拥 有 1 百 万 预 算 ，1 特 工 网 络 ，1 军 事 实 力",
		func(): return d(w, 8) + d(w, 36) >= 10 and d(w, 9) >= 10 and d(w, 22) >= 10))
	var eff := func():
		if has(country, "亲美"):
			add_rel(w, 0, -10)
		elif has(country, "亲苏"):
			add_rel(w, 1, -10)
		country.level_of_development -= 10
		set_d(w, 8, d(w, 8) - 10)
		set_d(w, 9, d(w, 9) - 10)
		set_d(w, 22, d(w, 22) - 10)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 86 · 协助该友好政权处理国内矛盾
# DBS Show L2238-L2256 / OnMouseDown L9946-L9954
# ============================================================================
func _def_86(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := _opis_ub(w, country, OT[47])
	var conds: Array = []
	conds.append(cond(OT[39], func(): return has(country, "亲中")))
	conds.append(cond(OT[46], func(): return has(country, "对华贸易")))
	conds.append(cond("拥 有 2 百 万 预 算 ，2 特 工 网 络 ，2 军 事 实 力",
		func(): return d(w, 8) + d(w, 36) >= 20 and d(w, 9) >= 20 and d(w, 22) >= 20))
	var eff := func():
		add_rel(w, 0, -15)
		country.level_of_instability -= 10
		country.level_of_development += 10
		set_d(w, 8, d(w, 8) - 20)
		set_d(w, 9, d(w, 9) - 20)
		set_d(w, 22, d(w, 22) - 20)
	return make_def(caption, opis, conds, eff)
# ============================================================================
# 编号 87 · 达成我们间的长效收益合约
# DBS Show L2257-L2275 / OnMouseDown L9955-L9959
# ============================================================================
func _def_87(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := _opis_ub(w, country, OT[48])
	var conds: Array = []
	conds.append(cond(OT[39], func(): return has(country, "亲中")))
	conds.append(cond(OT[44], func(): return not has(country, "对华贸易")))
	conds.append(cond(OT[45], func(): return d(w, 12) >= 500 and d(w, 13) >= 500))
	var eff := func():
		add_rel(w, 0, -15)
		country.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 88 · 郑重接纳该国加入我们的经济联盟
# DBS Show L2276-L2296 / OnMouseDown L9960-L9969
# ============================================================================
func _def_88(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := _opis_ub(w, country, OT[49])
	var c1 := c(w, 1)
	var conds: Array = []
	conds.append(cond(OT[39], func(): return has(country, "亲中")))
	conds.append(cond(OT[46], func(): return has(country, "对华贸易")))
	conds.append(cond(OT[50], func():
		return (w.influence_prc >= 150
			and country.level_of_development - country.level_of_instability >= 30)))
	var t88_desc: String = OT[51] if (c1 != null and (has(c1, "sev") or has(c1, "econ"))) else OT[52]
	conds.append(cond(t88_desc,
		func():
			return (c1 != null and (has(c1, "sev") or has(c1, "econ"))
			and not has(country, "sev") and not has(country, "econ"))))
	var eff := func():
		if c1 != null and (has(c1, "sev") or has(c1, "econ")):
			add_rel(w, 0, -250)
			country.set_tag("sev", has(c1, "sev"))
			country.set_tag("econ", has(c1, "econ"))
			w.influence_prc += 5
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 91 · 与土耳其极左派建立联系
# DBS Show L2297-L2324 / OnMouseDown L9970-L9976
# ============================================================================
func _def_91(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[58]
	var e366 := ev(w, 366)
	var conds: Array = []
	conds.append(cond(" 拥 有 5 百 万 资 金 ", func(): return d(w, 8) + d(w, 36) >= 50))
	conds.append(cond(" 需 要 3 点 特 工 网 络", func(): return d(w, 9) >= 30))
	if not e366:
		conds.append(cond(OT[62], func(): return (d(w, 20) > 4 and d(w, 21) >= 1977) or d(w, 21) > 1977))
	else:
		conds.append(cond(OT[63], func(): return not ev(w, 367)))
	if not e366:
		conds.append(cond(OT[64], func(): return not ev(w, 366)))
	else:
		conds.append(cond(OT[64], func(): return res(w, 366) != 0 and res(w, 366) != 1))
	var eff := func():
		set_d(w, 6, d(w, 6) + 20)
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 30)
		set_res(w, 366, 0)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 92 · 与土耳其极右派建立联系
# DBS Show L2325-L2354 / OnMouseDown L9977-L9983
# ============================================================================
func _def_92(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[59]
	var e366 := ev(w, 366)
	var conds: Array = []
	conds.append(cond(" 拥 有 5 百 万 资 金 ", func(): return d(w, 8) + d(w, 36) >= 50))
	conds.append(cond(" 需 要 3 点 特 工 网 络", func(): return d(w, 9) >= 30))
	if not e366:
		conds.append(cond(OT[62], func(): return (d(w, 20) > 4 and d(w, 21) >= 1977) or d(w, 21) > 1977))
	else:
		conds.append(cond(OT[63], func(): return not ev(w, 367)))
	if not e366:
		conds.append(cond(OT[64], func(): return not ev(w, 366)))
	else:
		conds.append(cond(OT[64], func(): return res(w, 366) != 0 and res(w, 366) != 1))
	var eff := func():
		set_d(w, 6, d(w, 6) + 2)
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 30)
		set_res(w, 366, 1)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 93 · 深化经贸关系（以色列战败后）
# DBS Show L2355-L2386 / OnMouseDown L9984-L9987
# ============================================================================
func _def_93(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 深 化 经 贸 关 系"
	var conds: Array = []
	if _lp(w, 2) and soc(w, country, false):
		conds.append(cond(" 外 交 声 誉 低 于 11451.4", func(): return d(w, 6) < 114514))
	elif soc(w, country, true):
		conds.append(cond(" 外 交 声 誉 不 低 于 80", func(): return d(w, 6) >= 800))
	elif country.government <= 2:
		conds.append(cond(" 外 交 声 誉 在 39 到 85 之 间", func(): return d(w, 6) > 390 and d(w, 6) < 850))
	else:
		conds.append(cond(" 外 交 声 誉 低 于 50", func(): return d(w, 6) < 500))
	conds.append(cond(" 尚 未 深 化 经 贸 关 系", func(): return not has(country, "对华贸易")))
	conds.append(cond(" 工 业 不 低 于 50", func(): return d(w, 12) >= 500))
	conds.append(cond(" 以 色 列 输 掉 了 黎 巴 嫩 战 争", func(): return _israel_lost(w)))
	var eff := func():
		var c93 := c(w, 93)
		if c93 != null:
			c93.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)
# ============================================================================
# 编号 94 · 就解决库尔德问题组织谈判
# DBS Show L2387-L2396 / OnMouseDown L9988-L9994
# ============================================================================
func _def_94(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[66]
	var conds: Array = []
	conds.append(cond(OT[67], func(): return d(w, 124) >= 1))
	conds.append(cond(OT[68], func(): return d(w, 124) != 100))
	var eff := func():
		set_d(w, 124, 10)
		if GameManager != null:
			GameManager.set_speed(0)
		start_event_num(w, 372)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 95 · 调解塞浦路斯问题
# DBS Show L2397-L2406 / OnMouseDown L9995-L10001
# ============================================================================
func _def_95(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[69]
	var conds: Array = []
	conds.append(cond(" 塞 浦 路 斯 大 选 已 结 束", func(): return ev(w, 697)))
	conds.append(cond(OT[68], func(): return d(w, 127) != 100))
	var eff := func():
		set_d(w, 127, 10)
		if GameManager != null:
			GameManager.set_speed(0)
		start_event_num(w, 374)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 96 · 深化经贸关系（对朝鲜）
# DBS Show L2407-L2419 / OnMouseDown L10002-L10005
# ============================================================================
func _def_96(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 深 化 经 贸 关 系"
	var conds: Array = []
	conds.append(cond(" 尚 未 深 化 经 贸 关 系", func(): return not has(country, "对华贸易")))
	conds.append(cond(" 工 业 不 低 于 50", func(): return d(w, 12) >= 500))
	conds.append(cond(OT[72], func(): return not war(w, 8)))
	var eff := func():
		var c95 := c(w, 95)
		if c95 != null:
			c95.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 97 · 施压当地政府，并让其加入我国势力范围
# DBS Show L2420-L2433 / OnMouseDown L10006-L10017
# ============================================================================
func _def_97(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[74]
	var c19 := c(w, 19)
	var conds: Array = []
	conds.append(cond(OT[75], func():
		return (c19 != null and has(c19, "亲中")
		and ((has(c19, "okb") and has(c19, "econ"))
			or (has(c19, "sev") and has(c19, "ovd"))
			or has(c19, "nato")))))
	conds.append(cond(OT[76], func(): return w.influence_prc > 600))
	conds.append(cond(OT[77], func(): return d(w, 8) + d(w, 36) >= 200 and d(w, 9) >= 200))
	conds.append(cond(OT[78], func(): return not has(country, "亲中")))
	var eff := func():
		country.leave_alliances()
		country.set_tag("对华贸易", true)
		country.establish_government(2)
		set_d(w, 8, d(w, 8) - 200)
		set_d(w, 9, d(w, 9) - 200)
		w.influence_prc += 10
		set_d(w, 6, d(w, 6) + 10)
		var c1 := c(w, 1)
		if c1 != null:
			country.government = c1.government
		country.sub_government = chinese_sub_gosstroy(w)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 98 · 允许该国加入我国经济联盟（已深化经贸）
# DBS Show L2434-L2447 / OnMouseDown L10018-L10029
# ============================================================================
func _def_98(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[81]
	var c1 := c(w, 1)
	var conds: Array = []
	conds.append(cond(OT[83], func(): return has(country, "对华贸易")))
	conds.append(cond(OT[86], func(): return w.influence_prc > 700))
	conds.append(cond(OT[84], func(): return c1 != null and (has(c1, "sev") or has(c1, "econ"))))
	conds.append(cond(OT[88], func():
		return (not has(country, "econ")
		and not has(country, "sev") and not has(country, "asean"))))
	var eff := func():
		if c1 != null and has(c1, "econ"):
			country.set_tag("econ", true)
		else:
			country.set_tag("sev", true)
		w.influence_prc += 5
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 99 · 邀请该国参与我国军事联盟
# DBS Show L2448-L2461 / OnMouseDown L10030-L10046
# ============================================================================
func _def_99(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[82]
	var c1 := c(w, 1)
	var conds: Array = []
	conds.append(cond(OT[90], func(): return has(country, "sev") or has(country, "econ")))
	conds.append(cond(OT[87], func(): return w.influence_prc > 800))
	conds.append(cond(OT[84], func():
		return (c1 != null
		and (has(c1, "sev") or has(c1, "econ") or has(c1, "nato")))))
	conds.append(cond(OT[89], func():
		return (not has(country, "okb")
		and not has(country, "seato") and not has(country, "ovd"))))
	var eff := func():
		if c1 != null and has(c1, "okb"):
			country.set_tag("okb", true)
		elif c1 != null and has(c1, "nato"):
			country.set_tag("nato", true)
		else:
			country.set_tag("ovd", true)
		w.influence_prc += 5
		country.social_stability = 900
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 100 · 将斯洛伐克的民族主义者与正统派共产党撮合为联合反对派
# DBS Show L2462-L2481 / OnMouseDown L10047-L10052
# ============================================================================
func _def_100(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[107]
	var conds: Array = []
	conds.append(cond(OT[86], func(): return w.influence_prc >= 700))
	conds.append(cond(OT[108], func(): return d(w, 8) + d(w, 36) >= 150 and d(w, 9) >= 150))
	conds.append(cond(OT[109], func(): return country.development <= 0))
	var c7 := c(w, 7)
	if c7 != null and has(c7, "nato"):
		conds.append(cond(OT[105], func(): return c7 != null and not has(c7, "nato")))
	var eff := func():
		set_d(w, 8, d(w, 8) - 150)
		set_d(w, 9, d(w, 9) - 150)
		country.development = 1
	return make_def(caption, opis, conds, eff)
# ============================================================================
# 编号 101 · 允许该国加入我国经济联盟（有驻军基地）
# DBS Show L2482-L2495 / OnMouseDown L10053-L10063
# ============================================================================
func _def_101(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[81]
	var c1 := c(w, 1)
	var conds: Array = []
	conds.append(cond(OT[169], func(): return country.有驻军基地))
	conds.append(cond(OT[83], func(): return has(country, "对华贸易")))
	conds.append(cond(OT[88], func(): return not has(country, "sev") and not has(country, "econ")))
	conds.append(cond(OT[84], func(): return c1 != null and (has(c1, "sev") or has(c1, "econ"))))
	var eff := func():
		if c1 != null and has(c1, "econ"):
			country.set_tag("econ", true)
		else:
			country.set_tag("sev", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 103 · 增强中华人民共和国对该国的影响力
# DBS Show L2555-L2575 / OnMouseDown L10068-L10080
# ============================================================================
func _def_103(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 增 强 中 华 人 民 共 和 国 对 该 国 的 影 响 力%s%s： %s； %s： %s；" % [
		"\n", OT[123], str(float(country.influence_china) / 10.0),
		OT[124], str(float(country.influence_nato) / 10.0)]
	var conds: Array = []
	conds.append(cond(OT[127], func(): return country.influence_china < 1000))
	conds.append(cond(OT[128], func(): return d(w, 8) + d(w, 36) >= 100))
	conds.append(cond(OT[129], func(): return d(w, 9) >= 50))
	conds.append(cond(OT[130], func(): return not has(country, "亲苏") and not has(country, "亲美")))
	var eff := func():
		add_rel(w, 0, -20)
		add_rel(w, 1, -20)
		country.influence_china += 150
		country.influence_nato -= 150
		if country.influence_nato < 0:
			country.influence_nato = 0
		set_d(w, 8, d(w, 8) - 100)
		set_d(w, 9, d(w, 9) - 50)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 104 · 增强我国与该国的经济一体化
# DBS Show L2576-L2596 / OnMouseDown L10081-L10087
# ============================================================================
func _def_104(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 增 强 我 国 与 该 国 的 经 济 一 体 化%s%s： %s； %s： %s；" % [
		"\n", OT[123], str(float(country.influence_china) / 10.0),
		OT[124], str(float(country.influence_nato) / 10.0)]
	var conds: Array = []
	conds.append(cond(OT[125], func(): return country.influence_china >= 350))
	conds.append(cond(OT[88], func(): return not has(country, "econ")))
	conds.append(cond(OT[83], func(): return has(country, "对华贸易")))
	conds.append(cond(OT[130], func(): return not has(country, "亲苏") and not has(country, "亲美")))
	var eff := func():
		add_rel(w, 0, -200)
		add_rel(w, 1, -200)
		set_d(w, 7, d(w, 7) + 10)
		country.set_tag("econ", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 105 · 在该国建立中国军事基地
# DBS Show L2597-L2617 / OnMouseDown L10088-L10096
# ============================================================================
func _def_105(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 在 该 国 建 立 中 国 军 事 基 地%s%s： %s； %s： %s；" % [
		"\n", OT[123], str(float(country.influence_china) / 10.0),
		OT[124], str(float(country.influence_nato) / 10.0)]
	var conds: Array = []
	conds.append(cond(OT[133], func(): return country.influence_china >= 600))
	conds.append(cond(OT[134], func(): return not country.有驻军基地 and has(country, "econ")))
	conds.append(cond(OT[135], func(): return d(w, 22) >= 250))
	conds.append(cond(OT[130], func(): return not has(country, "亲苏") and not has(country, "亲美")))
	var eff := func():
		add_rel(w, 0, -400)
		add_rel(w, 1, -400)
		set_d(w, 7, d(w, 7) + 15)
		country.set_tag("亲中", true)
		country.有驻军基地 = true
		set_d(w, 22, d(w, 22) - 250)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 106 · 允许该国加入军事联盟
# DBS Show L2618-L2638 / OnMouseDown L10097-L10104
# ============================================================================
func _def_106(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := " 允 许 该 国 加 入 军 事 联 盟%s%s： %s； %s： %s；" % [
		"\n", OT[123], str(float(country.influence_china) / 10.0),
		OT[124], str(float(country.influence_nato) / 10.0)]
	var conds: Array = []
	conds.append(cond(OT[138], func(): return country.influence_china >= 900))
	conds.append(cond(OT[137], func(): return country.有驻军基地 and not has(country, "okb")))
	conds.append(cond(OT[139], func(): return d(w, 7) > power(w, 0) + power(w, 1)))
	conds.append(cond(OT[130], func(): return not has(country, "亲苏") and not has(country, "亲美")))
	var eff := func():
		add_rel(w, 0, -500)
		add_rel(w, 1, -500)
		country.set_tag("okb", true)
		country.set_tag("ovd", false)
		set_d(w, 7, d(w, 7) + 30)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 107 · 加入/离开情报组织联盟“狩猎俱乐部”
# DBS Show L2639-L2662 / OnMouseDown L10105-L10115
# ============================================================================
func _def_107(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis: String
	var conds: Array = []
	if not mod(w, 41):
		opis = OT[141]
		conds.append(cond(OT[142], func(): return d(w, 6) < 600 and d(w, 21) > 1979))
		var c30 := c(w, 30)
		var c8 := c(w, 8)
		conds.append(cond(OT[143], func():
			return (c30 != null and has(c30, "亲美")
			and c8 != null and (c8.government == GameConstants.Government.LIBERAL or has(c8, "亲美")))))
		var c1 := c(w, 1)
		conds.append(cond(OT[144], func(): return (c1 == null or not has(c1, "sev")) and _sci(w, 19)))
		conds.append(cond(OT[145], func(): return (d(w, 131) == 0 or d(w, 131) == 3) and not mod(w, 41)))
	else:
		opis = OT[146]
		conds.append(cond(OT[147], func(): return mod(w, 41)))
	var eff := func():
		_set_mod(w, 41, not mod(w, 41))
	return make_def(caption, opis, conds, eff)
# ============================================================================
# 编号 110 · 支持埃塞俄比亚/厄立特里亚/提格雷左翼
# DBS Show L2685-L2709 / OnMouseDown L10132-L10163
# ============================================================================
func _def_110(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := ""
	if country.原版序号 == 41:
		opis = String(OT[159]).format(["\n", str(float(country.influence_china) / 10.0)])
	elif country.原版序号 == 99:
		opis = String(OT[167]).format(["\n", str(float(country.influence_china) / 10.0)])
	elif country.原版序号 == 100:
		opis = String(OT[163]).format(["\n", str(float(country.influence_china) / 10.0)])
	var conds: Array = []
	conds.append(cond(OT[170], func(): return country.influence_china < 1000))
	conds.append(cond(OT[171], func(): return d(w, 8) + d(w, 36) >= 50))
	conds.append(cond(OT[172], func(): return d(w, 22) >= 50))
	conds.append(cond(OT[173], func(): return not country.有驻军基地))
	var eff := func():
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 22, d(w, 22) - 50)
		country.influence_china += 100
		country.influence_nato -= 100
		if country.influence_china >= 1000:
			country.有驻军基地 = true
			if country.原版序号 == 41:
				country.establish_government(2)
				country.government = GameConstants.Government.SOCIALIST
				country.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				country.set_tag("对华贸易", true)
			elif country.原版序号 == 99:
				country.establish_government(2)
				country.government = GameConstants.Government.AUTHORITARIAN
				country.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				country.set_tag("对华贸易", true)
			elif country.原版序号 == 100:
				country.establish_government(2)
				country.government = GameConstants.Government.SOCIALIST
				country.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				country.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 111 · 支持埃塞俄比亚/厄立特里亚/提格雷右翼
# DBS Show L2710-L2734 / OnMouseDown L10164-L10195
# ============================================================================
func _def_111(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis := ""
	if country.原版序号 == 41:
		opis = String(OT[160]).format(["\n", str(float(country.influence_nato) / 10.0)])
	elif country.原版序号 == 99:
		opis = String(OT[168]).format(["\n", str(float(country.influence_nato) / 10.0)])
	elif country.原版序号 == 100:
		opis = String(OT[164]).format(["\n", str(float(country.influence_nato) / 10.0)])
	var conds: Array = []
	conds.append(cond(OT[174], func(): return country.influence_nato < 1000))
	conds.append(cond(OT[171], func(): return d(w, 8) + d(w, 36) >= 50))
	conds.append(cond(OT[172], func(): return d(w, 22) >= 50))
	conds.append(cond(OT[173], func(): return not country.有驻军基地))
	var eff := func():
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 22, d(w, 22) - 50)
		country.influence_nato += 100
		country.influence_china -= 100
		if country.influence_nato >= 1000:
			country.有驻军基地 = true
			if country.原版序号 == 41:
				country.establish_government(2)
				country.government = GameConstants.Government.LIBERAL
				country.sub_government = GameConstants.SubGovernment.LIBERAL
				country.set_tag("对华贸易", true)
			elif country.原版序号 == 99:
				country.establish_government(2)
				country.government = GameConstants.Government.AUTHORITARIAN
				country.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				country.set_tag("对华贸易", true)
			elif country.原版序号 == 100:
				country.establish_government(2)
				country.government = GameConstants.Government.LIBERAL
				country.sub_government = GameConstants.SubGovernment.MODERATE
				country.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 113 · 支持工党内的托洛茨基主义组织
# DBS Show L2747-L2760 / OnMouseDown L10207-L10213
# ============================================================================
func _def_113(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	# 用 format 而非 %：OT[177] 含字面百分号，% 运算符会把 % 当格式符报 incomplete format。
	var opis: String = String(OT[177]).format(["\n", str(country.influence_nato)])
	var conds: Array = []
	conds.append(cond(OT[178], func(): return d(w, 8) + d(w, 36) >= 30 and d(w, 9) >= 30))
	conds.append(cond(OT[179], func(): return not mod(w, 3)))
	conds.append(cond(OT[180], func(): return country.special <= 0))
	conds.append(cond(OT[181], func(): return d(w, 21) < 1981))
	var eff := func():
		var c92 := c(w, 92)
		if c92 != null:
			c92.influence_nato += 10
		set_d(w, 8, d(w, 8) - 30)
		set_d(w, 9, d(w, 9) - 30)
		if c92 != null:
			c92.special = 1
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 114 · 就联盟军队问题联系总参谋部
# DBS Show L2761-L2772 / OnMouseDown L10214-L10219
# ============================================================================
func _def_114(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[185]
	var c1 := c(w, 1)
	var conds: Array = []
	conds.append(cond(OT[187], func(): return mod(w, 48)))
	conds.append(cond(OT[180], func(): return c1 == null or c1.influence_nato <= 0))
	conds.append(cond(OT[189], func(): return c1 == null or c1.development <= 0))
	var eff := func():
		country.development = 1
		start_event_num(w, 408)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 115 · 就联盟情报问题联系总情报局
# DBS Show L2773-L2784 / OnMouseDown L10220-L10225
# ============================================================================
func _def_115(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[186]
	var c1 := c(w, 1)
	var conds: Array = []
	conds.append(cond(OT[188], func(): return mod(w, 47)))
	conds.append(cond(OT[180], func(): return c1 == null or c1.influence_china <= 0))
	conds.append(cond(OT[189], func(): return c1 == null or c1.development <= 0))
	var eff := func():
		country.development = 1
		start_event_num(w, 409)
	return make_def(caption, opis, conds, eff)
# ============================================================================
# 编号 117 · 加入东南亚国家联盟
# DBS Show L2799-L2812 / OnMouseDown L10232-L10255
# ============================================================================
func _def_117(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[196]
	var c1 := c(w, 1)
	var conds: Array = []
	conds.append(cond(OT[197], func(): return c1 != null and c1.government != GameConstants.Government.SOCIALIST and d(w, 52) > 34))
	conds.append(cond(OT[198], func(): return c1 == null or (not has(c1, "sev") and not has(c1, "econ"))))
	conds.append(cond(OT[199], func(): return c1 == null or not has(c1, "asean")))
	conds.append(cond(OT[200], func(): return d(w, 21) > 1978))
	var eff := func():
		w.influence_prc -= 20
		add_power(w, 0, 100)
		add_rel(w, 1, -350)
		add_rel(w, 0, 350)
		if c1 != null and has(c1, "econ"):
			set_d(w, 137, 1)
		for cc in w.countries:
			if cc != null and cc.has_tag("econ"):
				cc.set_tag("econ", false)
				cc.set_tag("asean", true)
				add_power(w, 0, 10)
				w.influence_prc += 5
		if c1 != null:
			c1.join_asean()
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 118 · 复兴东南亚条约组织
# DBS Show L2813-L2824 / OnMouseDown L10256-L10298
# ============================================================================
func _def_118(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[202]
	var c1 := c(w, 1)
	var c15 := c(w, 15)
	var conds: Array = []
	conds.append(cond(OT[203], func(): return c1 != null and has(c1, "asean")))
	conds.append(cond(OT[204], func(): return c15 == null or not c15.内战中))
	conds.append(cond(OT[199], func(): return c1 == null or not has(c1, "seato")))
	var eff := func():
		w.influence_prc -= 20
		add_power(w, 0, 100)
		set_d(w, 143, d(w, 143) + 5)
		add_rel(w, 1, -500)
		add_rel(w, 0, 350)
		if mod(w, 47):
			_set_mod(w, 47, false)
			set_d(w, 135, 1)
		if mod(w, 48):
			_set_mod(w, 48, false)
			set_d(w, 136, 1)
		if c1 != null and has(c1, "okb"):
			set_d(w, 138, 1)
		for cc in w.countries:
			if cc == null:
				continue
			if cc.has_tag("okb"):
				cc.set_tag("okb", false)
				cc.set_tag("seato", true)
				add_power(w, 0, 10)
				w.influence_prc += 5
			if cc.has_tag("亲中"):
				cc.prc_influence = 500
			elif cc.has_tag("亲美"):
				cc.usa_influence = 500
		if c1 != null:
			c1.join_seato()
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 119 · 邀请该国加入东南亚国家联盟与泛亚联盟
# DBS Show L2825-L2844 / OnMouseDown L10299-L10306
# ============================================================================
func _def_119(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[206]
	var c1 := c(w, 1)
	var conds: Array = []
	conds.append(cond(OT[203], func(): return c1 != null and has(c1, "asean")))
	conds.append(cond(OT[207], func(): return not has(country, "亲苏")))
	conds.append(cond(OT[208], func(): return not has(country, "asean") and not has(country, "sev")))
	if country.原版序号 != 38:
		conds.append(cond(OT[209], func(): return country.government != GameConstants.Government.SOCIALIST))
	else:
		conds.append(cond(OT[233], func(): return d(w, 64) == 1 or _dec_done(w, 6)))
	var eff := func():
		add_power(w, 0, 10)
		w.influence_prc += 5
		add_rel(w, 0, 50)
		country.set_tag("asean", true)
		country.set_tag("对华贸易", true)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 120 · 邀请该国加入东南亚条约组织
# DBS Show L2845-L2878 / OnMouseDown L10307-L10326
# ============================================================================
func _def_120(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var c51 := c(w, 51)
	var c51_cw: bool = c51 != null and c51.内战中
	var opis: String = OT[211] if c51_cw else OT[210]
	var c1 := c(w, 1)
	var conds: Array = []
	conds.append(cond(OT[213] if c51_cw else OT[212],
		func(): return c1 != null and has(c1, "asean")))
	conds.append(cond(OT[214], func(): return has(country, "asean")))
	conds.append(cond(OT[215], func(): return not has(country, "seato") and not has(country, "ovd")))
	if country.原版序号 in [8, 12, 14, 35, 36, 31, 37, 25]:
		conds.append(cond(OT[216], func(): return c51 != null and c51.内战中))
	var eff := func():
		add_power(w, 0, 10)
		w.influence_prc += 5
		if country.原版序号 == 47:
			set_d(w, 37, 0)
		add_rel(w, 0, 50)
		country.set_tag("sento", false)
		country.set_tag("seato", true)
		if has(country, "亲中"):
			country.prc_influence = 500
		elif has(country, "亲美"):
			country.usa_influence = 500
	return make_def(caption, opis, conds, eff)
# ============================================================================
# 编号 122 · 引爆新朝鲜战争
# DBS Show L2932-L2943 / OnMouseDown L10357-L10388
# ============================================================================
func _def_122(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[221]
	var c46 := c(w, 46)
	var conds: Array = []
	conds.append(cond(OT[222], func(): return d(w, 9) >= 100 and d(w, 8) + d(w, 36) >= 300))
	conds.append(cond(OT[223], func(): return ev(w, 91) and c46 != null and c46.government == GameConstants.Government.AUTHORITARIAN))
	conds.append(cond(OT[224], func(): return country.development == 0))
	var eff := func():
		country.development = 1
		set_d(w, 9, d(w, 9) - 100)
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 6, d(w, 6) + 100)
		var c10 := c(w, 10)
		var ussr_support: int = -1 if (c10 != null and has(c10, "亲中")) else 0
		# 原版 ingamewars[0].ussr_place/usa_place → WarData.ussr_side/usa_side；-1 表示不介入。
		GameManager.start_war(0, " 朝 鲜", " 韩 国", 400, 600, 1, 0)
		var war0 := w.get_war(0)
		if war0 != null:
			war0.name_war = " 第 二 次 朝 鲜 战 争"
			war0.side1 = " 朝 鲜"
			war0.side2 = " 韩 国"
			war0.infl1 = 400
			war0.infl2 = 600
			war0.usa_side = 1
			war0.ussr_side = ussr_support
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 123 · 支持持不同政见者组织
# DBS Show L2944-L2965 / OnMouseDown L10389-L10401
# ============================================================================
func _def_123(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[227]
	var conds: Array = []
	conds.append(cond(OT[228], func(): return d(w, 9) >= 50 and d(w, 8) + d(w, 36) >= 30))
	conds.append(cond(OT[229], func(): return not mod(w, 6)))
	conds.append(cond(OT[230], func(): return d(w, 6) <= 750))
	if power(w, 1) < 50:
		conds.append(cond(OT[231], func(): return power(w, 1) >= 50))
	else:
		conds.append(cond(OT[232], func(): return not _war_active(w, 1)))
	var eff := func():
		add_power(w, 1, -50)
		add_rel(w, 1, -200)
		_set_war_active(w, 1, true)
		if _dec_done(w, 9):
			w.influence_prc += 25
		set_d(w, 9, d(w, 9) - 50)
		set_d(w, 8, d(w, 8) - 30)
		set_d(w, 22, d(w, 22) - 50)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 124 · 离开我们所属的一切联盟
# DBS Show L2966-L2975 / OnMouseDown L10402-L10532
# ============================================================================
func _def_124(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[235]
	var c1 := c(w, 1)
	var conds: Array = []
	conds.append(cond(OT[236], func(): return c1 != null and (has(c1, "sev") or has(c1, "asean"))))
	conds.append(cond(OT[237], func(): return c1 == null or not c1.有驻军基地))
	var eff := func():
		if c1 != null:
			c1.有驻军基地 = true
		if c1 != null and has(c1, "asean"):
			add_rel(w, 0, -300)
		else:
			add_rel(w, 1, -300)
			var c7 := c(w, 7)
			if c7 != null:
				c7.set_tag("对华贸易", false)
		var c7b := c(w, 7)
		if c7b != null:
			c7b.special = 0
		set_d(w, 143, d(w, 143) - 5)
		var c51 := c(w, 51)
		if c51 != null:
			c51.special = 0
		set_d(w, 140, 0)
		if d(w, 135) > 0:
			_set_mod(w, 47, true)
			set_d(w, 135, 0)
		if d(w, 136) > 0:
			_set_mod(w, 48, true)
			set_d(w, 136, 0)
		set_d(w, 139, 0)
		if not _dec_done(w, 9):
			for cc in w.countries:
				if cc != null and has(cc, "亲中") and cc.原版序号 != 1 and cc.原版序号 != 2 \
						and cc.原版序号 != 5 and cc.原版序号 != 9:
					if c1 != null and has(c1, "asean"):
						cc.leave_asean()
						cc.leave_seato()
						add_power(w, 0, -5)
					else:
						cc.leave_wp()
						cc.leave_comecon()
						add_power(w, 1, -5)
			if d(w, 137) > 0:
				for cc in w.countries:
					if cc != null and cc.原版序号 != 2 and cc.原版序号 != 5 and cc.原版序号 != 9:
						set_d(w, 137, 0)
						if has(cc, "亲中") and cc.原版序号 != 2 and cc.原版序号 != 5 and cc.原版序号 != 9:
							cc.join_econ()
			if d(w, 138) > 0:
				for cc in w.countries:
					if cc != null and cc.原版序号 != 2 and cc.原版序号 != 5 and cc.原版序号 != 9:
						set_d(w, 138, 0)
						if has(cc, "亲中"):
							cc.join_okb()
		else:
			for cc in w.countries:
				if cc != null and has(cc, "亲中") and cc.原版序号 != 1 and cc.原版序号 != 9:
					if c1 != null and has(c1, "asean"):
						cc.leave_asean()
						cc.leave_seato()
						add_power(w, 0, -5)
					else:
						cc.leave_wp()
						cc.leave_comecon()
						add_power(w, 1, -5)
			if d(w, 137) > 0:
				for cc in w.countries:
					if cc != null and cc.原版序号 != 9:
						set_d(w, 137, 0)
						if has(cc, "亲中"):
							cc.join_econ()
			if d(w, 138) > 0:
				for cc in w.countries:
					if cc != null and cc.原版序号 != 9:
						set_d(w, 138, 0)
						if has(cc, "亲中"):
							cc.join_okb()
		if c1 != null:
			c1.leave_wp()
			c1.leave_asean()
			c1.leave_comecon()
			c1.leave_seato()
	return make_def(caption, opis, conds, eff)
# ============================================================================
# 编号 125 · 组织亲中派政变
# DBS Show L2976-L3004 / OnMouseDown L10533-L10600
# ============================================================================
func _def_125(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var c1 := c(w, 1)
	var opis: String = OT[239] if (c1 != null and has(c1, "seato")) else OT[252]
	var conds: Array = []
	conds.append(cond(OT[284], func(): return country.prc_influence >= 800))
	conds.append(cond(OT[241], func(): return d(w, 9) >= 100 and d(w, 8) + d(w, 36) >= 50))
	if c1 != null and has(c1, "seato"):
		conds.append(cond(OT[242], func(): return rel(w, 0) >= 700))
	else:
		conds.append(cond(OT[253], func(): return rel(w, 1) >= 700))
	conds.append(cond(OT[237], func(): return not country.政变中))
	var eff := func():
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 100)
		country.政变中 = true
		var num15: int = 0
		var num16: int = 0
		var num17: int = 0
		@warning_ignore("integer_division")
		num15 += country.sov_influence / 100
		@warning_ignore("integer_division")
		num16 += country.usa_influence / 100
		@warning_ignore("integer_division")
		num17 += country.prc_influence / 100
		@warning_ignore("integer_division")
		num15 += power(w, 1) / 100
		@warning_ignore("integer_division")
		num16 += power(w, 0) / 100
		@warning_ignore("integer_division")
		num17 += w.influence_prc / 100
		var c1b := c(w, 1)
		if c1b != null and has(c1b, "seato"):
			if num17 >= num16:
				if not has(country, "亲中"):
					country.establish_government(2)
					w.influence_prc += 5
				add_power(w, 0, -5)
				country.usa_influence = 0
				country.prc_influence = 500
				if c1b != null:
					country.government = c1b.government
					country.sub_government = c1b.sub_government
			else:
				if not has(country, "亲美"):
					country.establish_government(0)
					add_power(w, 0, 5)
				country.usa_influence = 500
				country.prc_influence = 0
				var c51 := c(w, 51)
				if c51 != null:
					country.government = c51.government
					country.sub_government = c51.sub_government
		elif num17 >= num15:
			if not has(country, "亲中"):
				country.establish_government(2)
				w.influence_prc += 5
			add_power(w, 1, -5)
			country.sov_influence = 0
			country.prc_influence = 500
			if c1b != null:
				country.government = c1b.government
				country.sub_government = c1b.sub_government
		else:
			if not has(country, "亲苏"):
				country.establish_government(1)
			country.sov_influence = 500
			country.prc_influence = 0
			add_power(w, 1, 5)
			var c7 := c(w, 7)
			if c7 != null:
				country.government = c7.government
				country.sub_government = c7.sub_government
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 126 · 支持老挝反对派并发动起义
# DBS Show L3005-L3018 / OnMouseDown L10601-L10609
# ============================================================================
func _def_126(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[245]
	var c11 := c(w, 11)
	var c34 := c(w, 34)
	var c23 := c(w, 23)
	var conds: Array = []
	conds.append(cond(OT[246], func():
		return (c11 != null and has(c11, "seato")
		and c34 != null and has(c34, "seato")
		and c23 != null and has(c23, "seato"))))
	conds.append(cond(OT[247], func(): return w.influence_prc + power(w, 0) >= power(w, 1)))
	conds.append(cond(OT[248], func():
		return (d(w, 8) + d(w, 36) >= 100
		and d(w, 9) >= 100 and d(w, 22) >= 250)))
	conds.append(cond(OT[249], func(): return not country.内战中))
	var eff := func():
		set_d(w, 8, d(w, 8) - 100)
		set_d(w, 9, d(w, 9) - 100)
		set_d(w, 22, d(w, 22) - 100)
		var c22 := c(w, 22)
		if c22 != null:
			c22.内战中 = true
		add_rel(w, 1, -250)
		# 原版 new War() 链式创建 27 号战争；Godot 用 GameManager.start_war + war_27 定义。
		GameManager.start_war(27, NTE1238, NTE1239, 700, 300, 1, 0)
		var war27 := w.get_war(27)
		if war27 != null:
			war27.name_war = NTE1237
			war27.fortnight_max = 30
	return make_def(caption, opis, conds, eff)
# ============================================================================
# 编号 127 · 鼓励戴高乐主义者退出北约和欧洲经济共同体
# DBS Show L3019-L3032 / OnMouseDown L10610-L10615
# ============================================================================
func _def_127(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[257]
	var c85 := c(w, 85)
	var c45 := c(w, 45)
	var c87 := c(w, 87)
	var c21 := c(w, 21)
	var conds: Array = []
	conds.append(cond(OT[258], func(): return d(w, 131) == 3))
	conds.append(cond(OT[259], func(): return w.influence_prc >= power(w, 0)))
	conds.append(cond(OT[260], func():
		return ((c85 == null or (not has(c85, "nato") and not has(c85, "eu")))
			and (c45 == null or (not has(c45, "nato") and not has(c45, "eu")))
			and (c87 == null or (not has(c87, "nato") and not has(c87, "eu"))))))
	conds.append(cond(OT[261], func(): return c21 != null and has(c21, "nato")))
	var eff := func():
		add_power(w, 0, -70)
		if c21 != null:
			c21.set_tag("nato", false)
			c21.set_tag("eu", false)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 128 · 给葡萄牙民主政体来点“尖叫”
# DBS Show L3033-L3052 / OnMouseDown L10616-L10624
# ============================================================================
func _def_128(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var c87 := c(w, 87)
	var c87_spec: int = c87.special if c87 != null else 0
	var opis: String = String(OT[264]).format(["\n", str(c87_spec)])
	var conds: Array = []
	conds.append(cond(OT[266], func(): return c87 != null and c87.special < 100))
	var c87_infl_nato_f: float = float(c87.influence_nato if c87 != null else 0) / 10.0
	var c87_infl_ch_f: float = float(c87.influence_china if c87 != null else 0) / 10.0
	conds.append(cond(" 特 工 网 络 ： - %s；  预算 ： - %s 百 万" % [str(c87_infl_ch_f), str(c87_infl_nato_f)],
		func():
			return (c87 != null and d(w, 8) + d(w, 36) >= c87.influence_china
			and d(w, 9) >= c87.influence_nato)))
	conds.append(cond(OT[269], func(): return c87 != null and c87.government != GameConstants.Government.LIBERAL))
	if not ev(w, 414):
		conds.append(cond(OT[268], func(): return ev(w, 414)))
	else:
		conds.append(cond(OT[265], func():
			return (d(w, 21) < 1982
			and (c87 == null or not c87.有驻军基地))))
	var eff := func():
		if c87 != null:
			set_d(w, 8, d(w, 8) - c87.influence_nato)
			set_d(w, 9, d(w, 9) - c87.influence_china)
			c87.有驻军基地 = true
			c87.special -= 10
			c87.influence_china += 20
			c87.influence_nato += 20
	return make_def(caption, opis, conds, eff)
# ============================================================================
# 编号 130 · 支持亲中势力（对苏联势力范围）
# DBS Show L3075-L3102 / OnMouseDown L10654-L10666
# ============================================================================
func _def_130(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	# 原版 Show 先钳制 sovinfl/prcinfl 到 0..1000（DBS L3078-L3093），此处忠实保留。
	if country.sov_influence > 1000:
		country.sov_influence = 1000
	if country.sov_influence < 0:
		country.sov_influence = 0
	if country.prc_influence > 1000:
		country.prc_influence = 1000
	if country.prc_influence < 0:
		country.prc_influence = 0
	var opis: String = String(OT[278]).format([
		"\n",
		str(float(country.sov_influence) / 10.0),
		str(float(country.prc_influence) / 10.0)])
	var conds: Array = []
	conds.append(cond(OT[279], func():
		return (has(country, "亲苏")
		or (not has(country, "亲中") and not has(country, "亲苏") and not has(country, "亲美")))))
	conds.append(cond(OT[280], func():
		return (d(w, 8) + d(w, 36) >= 50
		and d(w, 9) >= 50 and d(w, 22) >= 80)))
	conds.append(cond(OT[281], func(): return country.prc_influence < 1000))
	var eff := func():
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 50)
		add_rel(w, 1, -10)
		set_d(w, 22, d(w, 22) - 80)
		country.prc_influence += 200
		country.sov_influence -= 400
		if country.prc_influence > 1000:
			country.prc_influence = 1000
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 131 · 支持亲中势力（对美国势力范围）
# DBS Show L3103-L3130 / OnMouseDown L10667-L10679
# ============================================================================
func _def_131(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	# 原版 Show 先钳制 usainfl/prcinfl 到 0..1000（DBS L3106-L3121），此处忠实保留。
	if country.usa_influence > 1000:
		country.usa_influence = 1000
	if country.usa_influence < 0:
		country.usa_influence = 0
	if country.prc_influence > 1000:
		country.prc_influence = 1000
	if country.prc_influence < 0:
		country.prc_influence = 0
	var opis: String = String(OT[282]).format([
		"\n",
		str(float(country.usa_influence) / 10.0),
		str(float(country.prc_influence) / 10.0)])
	var conds: Array = []
	conds.append(cond(OT[283], func():
		return (has(country, "亲美")
		or (not has(country, "亲中") and not has(country, "亲苏") and not has(country, "亲美")))))
	conds.append(cond(OT[280], func():
		return (d(w, 8) + d(w, 36) >= 50
		and d(w, 9) >= 50 and d(w, 22) >= 80)))
	conds.append(cond(OT[281], func(): return country.prc_influence < 1000))
	var eff := func():
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 50)
		add_rel(w, 0, -10)
		set_d(w, 22, d(w, 22) - 80)
		country.prc_influence += 200
		if country.prc_influence > 1000:
			country.prc_influence = 1000
		country.usa_influence -= 400
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 132 · 支持组织亲中政变，并以我国路线为蓝本改组政府意识形态
# DBS Show L3131-L3142 / OnMouseDown L10680-L10694
# ============================================================================
func _def_132(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[286]
	var c1 := c(w, 1)
	var conds: Array = []
	conds.append(cond(OT[287], func(): return has(country, "亲中")))
	conds.append(cond(OT[288], func():
		return (c1 != null
		and country.sub_government != c1.sub_government)))
	conds.append(cond(OT[289], func(): return d(w, 8) + d(w, 36) >= 50 and d(w, 9) >= 50))
	var eff := func():
		set_d(w, 8, d(w, 8) - 50)
		set_d(w, 9, d(w, 9) - 50)
		if c1 != null and has(c1, "seato"):
			add_rel(w, 0, -50)
		else:
			add_rel(w, 1, -50)
		if c1 != null:
			country.government = c1.government
			country.sub_government = c1.sub_government
	return make_def(caption, opis, conds, eff)
# ============================================================================
# 编号 133 · 对伊拉克发起军事干涉
# DBS Show L3143-L3174 / OnMouseDown L10695-L10767
# ============================================================================
func _def_133(w: WorldState, _country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[294]
	var c36 := c(w, 36)
	var c14 := c(w, 14)
	var c1 := c(w, 1)
	var conds: Array = []
	conds.append(cond(OT[295], func():
		return (c36 != null and c36.内战中
		and c14 != null and c14.puppet_of <= 0)))
	conds.append(cond(OT[296], func():
		return (d(w, 8) + d(w, 36) >= 250
		and d(w, 9) >= 150 and d(w, 22) >= 350)))
	if c1 != null and has(c1, "okb"):
		conds.append(cond(OT[297], func(): return w.influence_prc >= power(w, 0) + power(w, 1)))
	elif c1 != null and has(c1, "ovd"):
		conds.append(cond(OT[300], func(): return w.influence_prc + power(w, 1) >= power(w, 0)))
	elif c1 != null and has(c1, "seato"):
		conds.append(cond(OT[301], func(): return w.influence_prc + power(w, 0) >= power(w, 1)))
	else:
		conds.append(cond(OT[302], func():
			return (c1 != null
			and (has(c1, "okb") or has(c1, "seato") or has(c1, "ovd")))))
	conds.append(cond(OT[298], func(): return c14 == null or not c14.内战中))
	var eff := func():
		set_d(w, 8, d(w, 8) - 250)
		set_d(w, 9, d(w, 9) - 150)
		set_d(w, 22, d(w, 22) - 350)
		if c14 != null:
			c14.内战中 = true
		var num18: int = 0
		var c1b := c(w, 1)
		var c30 := c(w, 30)
		var c35 := c(w, 35)
		var c8 := c(w, 8)
		var c37 := c(w, 37)
		if c1b != null and has(c1b, "ovd"):
			if c30 != null and c30.government != GameConstants.Government.LIBERAL:
				num18 += 50
			if c35 != null and (has(c35, "亲中") or has(c35, "亲苏")):
				num18 += 50
			if c8 != null and has(c8, "ovd"):
				num18 += 50
			if c37 != null and has(c37, "ovd"):
				num18 += 50
			add_rel(w, 0, -350)
			# 原版 new War() 链式创建 29 号战争；Godot 用 GameManager.start_war + war_29 定义。
			GameManager.start_war(29, NTE1321, NTE1322, 500 + num18, 500 - num18, 1, 0)
			var war29a := w.get_war(29)
			if war29a != null:
				war29a.name_war = NTE1320
		elif c1b != null and has(c1b, "seato"):
			add_rel(w, 1, -350)
			if c30 != null and c30.government == GameConstants.Government.LIBERAL:
				num18 += 50
			if c35 != null and (has(c35, "亲中") or has(c35, "亲美")):
				num18 += 50
			if c8 != null and has(c8, "seato"):
				num18 += 50
			if c37 != null and has(c37, "seato"):
				num18 += 50
			GameManager.start_war(29, NTE1324, NTE1322, 500 + num18, 500 - num18, 0, 1)
			var war29b := w.get_war(29)
			if war29b != null:
				war29b.name_war = NTE1323
		else:
			add_rel(w, 0, -350)
			add_rel(w, 1, -350)
			if c30 != null and c30.government == GameConstants.Government.REFORMIST:
				num18 += 50
			if c35 != null and has(c35, "亲中"):
				num18 += 50
			if c8 != null and has(c8, "okb"):
				num18 += 50
			if c37 != null and has(c37, "okb"):
				num18 += 50
			num18 -= 150
			GameManager.start_war(29, NTE1326, NTE1322, 500 + num18, 500 - num18, 1, 1)
			var war29c := w.get_war(29)
			if war29c != null:
				war29c.name_war = NTE1325
				war29c.fortnight_max = 15
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 134 · 对该国实施/取消补贴政策
# DBS Show L3175-L3208 / OnMouseDown L10768-L10788
# ============================================================================
func _def_134(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var c1 := c(w, 1)
	var opis: String
	var conds: Array = []
	if not has(country, "贸易同盟"):
		if c1 != null and has(c1, "seato"):
			opis = "%s%s%s:%s; %s: %s" % [OT[304], "\n", NT167,
				str(float(country.usa_influence) / 10.0), NTE1214,
				str(float(country.prc_influence) / 10.0)]
		else:
			opis = "%s%s%s:%s; %s: %s" % [OT[304], "\n", NT168,
				str(float(country.sov_influence) / 10.0), NTE1214,
				str(float(country.prc_influence) / 10.0)]
		conds.append(cond(OT[287], func(): return has(country, "亲中")))
		conds.append(cond(OT[305], func(): return not has(country, "贸易同盟")))
	else:
		if c1 != null and has(c1, "seato"):
			opis = "%s%s%s: %s; %s: %s" % [OT[306], "\n", NT167,
				str(float(country.usa_influence) / 10.0), NTE1214,
				str(float(country.prc_influence) / 10.0)]
		else:
			opis = "%s%s%s: %s; %s: %s" % [OT[306], "\n", NT168,
				str(float(country.sov_influence)), NTE1214,
				str(float(country.prc_influence) / 10.0)]
		conds.append(cond(OT[307], func(): return has(country, "亲中")))
	var eff := func():
		if not has(country, "贸易同盟"):
			country.set_tag("贸易同盟", true)
			# 原版反编译后 data[146] 的增减只写入局部变量 ptr，未写回数组；
			# 疑似反编译丢失。按原版行为不修改 data[146]。
		else:
			country.set_tag("贸易同盟", false)
			# 同上：原版 data[146] 递减只写入局部变量，未写回数组，按原版不修改。
	return make_def(caption, opis, conds, eff)
# ============================================================================
# 编号 145 · 对海湾合作委员会施压，要求其减产石油
# DBS Show L3477-L3515 / OnMouseDown L11109-L11135
# 注：原版 OnMouseDown 的 145/146 共用段为 L11104-L11135，本函数一并翻译共用前奏。
# ============================================================================
func _def_145(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var new_price: int = (d(w, 143) + 5) if (d(w, 143) + 5 <= 60) else 60
	var opis: String
	if country.puppet_of == 14:
		opis = " 通 过 我 们 和 石 油 与 主 权 委 员 会 的 关 系 调 整 油 价 ， 使 其 更 有 利 于 我 国 发 展|世 界 油 价 将 变 为 每 桶 %d$ 。" % new_price
	else:
		opis = OT[460].format(["\n", str(new_price)])
	var conds: Array = []
	var num2: int = 0
	for legacy_idx in [101, 102, 103, 104, 105, 106]:
		var cc := c(w, legacy_idx)
		if cc != null and has(cc, "亲中"):
			num2 += 1
	var c36 := c(w, 36)
	if c36 != null and has(c36, "亲中"):
		num2 += 1
	if country.puppet_of == 14:
		conds.append(cond(" 石 油 与 主 权 委 员 会 已 建 立", func(): return country.puppet_of == 14))
	else:
		conds.append(cond(OT[461], func(): return num2 >= 3))
	conds.append(cond(OT[454], func(): return d(w, 9) >= 50))
	conds.append(cond(OT[450], func(): return c36 == null or c36.influence_nato <= 0))
	conds.append(cond(OT[462], func(): return d(w, 143) < 60))
	var eff := func():
		# 共用前奏（DBS L11106-L11108）
		set_d(w, 9, d(w, 9) - 50)
		w.influence_prc -= 5
		if c36 != null:
			c36.influence_nato = 3
		# 145 分支（DBS L11109-L11121）
		if d(w, 143) + 5 <= 60:
			set_d(w, 143, d(w, 143) + 5)
		else:
			set_d(w, 143, 60)
		add_rel(w, 1, 50)
		add_rel(w, 0, -50)
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 146 · 对海湾合作委员会施压，要求其增产石油
# DBS Show L3516-L3554 / OnMouseDown 无（批6 JSON 未列；效果为空 Callable）
# ============================================================================
func _def_146(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var new_price: int = (d(w, 143) - 5) if (d(w, 143) - 5 >= 10) else 10
	var opis: String
	if country.puppet_of == 14:
		opis = " 通 过 我 们 和 石 油 与 主 权 委 员 会 的 关 系 调 整 油 价 ， 使 其 更 有 利 于 我 国 发 展|世 界 油 价 将 变 为 每 桶 %d$ 。" % new_price
	else:
		opis = OT[463].format(["\n", str(new_price)])
	var conds: Array = []
	var num4: int = 0
	for legacy_idx in [101, 102, 103, 104, 105, 106]:
		var cc := c(w, legacy_idx)
		if cc != null and has(cc, "亲中"):
			num4 += 1
	var c36 := c(w, 36)
	if c36 != null and has(c36, "亲中"):
		num4 += 1
	if country.puppet_of == 14:
		conds.append(cond(" 石 油 与 主 权 委 员 会 已 建 立", func(): return country.puppet_of == 14))
	else:
		conds.append(cond(OT[461], func(): return num4 >= 3))
	conds.append(cond(OT[454], func(): return d(w, 9) >= 50))
	conds.append(cond(OT[450], func(): return c36 == null or c36.influence_nato <= 0))
	conds.append(cond(OT[464], func(): return d(w, 143) > 10))
	# 注意：批6 JSON 未列 146 的 OnMouseDown 区间，按任务要求效果为空 Callable。
	var eff := func():
		pass
	return make_def(caption, opis, conds, eff)


# ============================================================================
# 编号 149 · 积极支持愿意同我们合作的当地右派势力
# DBS Show L3624-L3636 / OnMouseDown L11279-L11376
# ============================================================================
func _def_149(w: WorldState, country: CountryData, caption: String) -> Dictionary:
	var opis: String = OT[480]
	var c0 := c(w, 0)
	var conds: Array = []
	conds.append(cond(OT[481], func(): return d(w, 8) + d(w, 36) >= 200))
	conds.append(cond(OT[482], func(): return d(w, 9) >= 200))
	conds.append(cond(OT[483], func(): return c0 == null or (not has(c0, "nato") and not has(c0, "eu"))))
	conds.append(cond(OT[484], func(): return not country.内战中))
	var eff := func():
		country.set_tag("亲中", true)
		country.内战中 = true
		country.set_tag("对华贸易", true)
		var num27: int = 0
		var num28: int = 0
		for legacy_idx in [21, 45, 84, 85, 86, 87, 92]:
			var cc := c(w, legacy_idx)
			if cc != null and auth(w, cc):
				num27 += 1
			if cc != null and cc.government == GameConstants.Government.LIBERAL:
				num28 += 1
		var c1 := c(w, 1)
		if num27 >= num28:
			if c1 == null or not auth(w, c1):
				var any_fascist := false
				for legacy_idx2 in [21, 45, 84, 85, 86, 87, 92]:
					var cc2 := c(w, legacy_idx2)
					if cc2 != null and cc2.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
						any_fascist = true
				if any_fascist:
					country.government = GameConstants.Government.AUTHORITARIAN
					country.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				else:
					country.government = GameConstants.Government.AUTHORITARIAN
					country.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			else:
				country.government = c1.government
				country.sub_government = c1.sub_government
		elif c1 != null and c1.government != GameConstants.Government.LIBERAL:
			country.government = GameConstants.Government.LIBERAL
			country.sub_government = GameConstants.SubGovernment.MODERATE
		else:
			if c1 != null:
				country.government = c1.government
				country.sub_government = c1.sub_government
		w.influence_prc += 20
		set_d(w, 8, d(w, 8) - 200)
		set_d(w, 9, d(w, 9) - 200)
	return make_def(caption, opis, conds, eff)




# ============================================================================
# Python 自检结果（本文件写入后运行）
#   UTF-8 可读：OK
#   行首空格：0 处
#   46 个编号在 build_action 中均有分支：通过
#   46 个 _def_N 全部定义：通过
#   括号平衡 ( )：[1559, 1559]；[ ]：[302, 302]；{ }：[2, 2]
#   裸 W 点号引用：0 处
#   残留字面 	：0 处
# ============================================================================
