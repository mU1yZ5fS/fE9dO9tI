extends GameUIBase

## 派系界面逻辑。
## 左栏: 6 大政策类别 + 5 个派系支持/禁止
## 中栏: 政体 + 路线 + 饼图 + 生育政策
## 右栏: 政策选项面板 + 条件说明 + 政策介绍

const W = preload("res://数据脚本/world_state.gd")

# 饼图/派系标签色，逐值对齐原版 Politic.unity Crushko._Col
const 派系颜色: Array[Color] = [
	Color(0.725, 0.008, 0.008),
	Color(0.588, 0.102, 0.984),
	Color(0.980, 0.337, 0.325),
	Color(0.0, 0.659, 0.043),
	Color(0.0, 0.502, 0.737),
	Color(0.368, 0.368, 0.368),
]

const 派系列表 := ["极左派", "保守派", "温和派", "改革派", "自由派"]

# num=this_number（原版 Doctrine_script 分支键）；slots=.tscn 面板内按钮节点名（场景顺序，
# 作定位槽用，文案由 _build_options 运行时覆盖）；政策介绍文案由 _policy_intro 按原版 fake_text 提供。
const 政策类别 := {
	"经济类型": {
		"idx": W.I_ECON_SYSTEM, "num": 16, "panel": "右栏经济类型",
		"slots": ["中央计划经济", "中式计划经济", "国家资本主义", "国控资本主义", "市场经济", "自由市场"],
	},
	"党政": {
		"idx": W.I_PARTY_SYSTEM, "num": 15, "panel": "右栏党政",
		"slots": ["无产阶级专政", "人民民主专政", "联合政府", "西式民主"],
	},
	"人权": {
		"idx": W.I_PRESS_POLICY, "num": 17, "panel": "右栏人权",
		"slots": ["舆论一律", "纪律约束", "自然限制", "多元自由"],
	},
	"国家体制": {
		"idx": W.I_TERRITORY, "num": 18, "panel": "右栏国家体制",
		"slots": ["单一制", "区域自治", "联邦制", "邦联制"],
	},
	"传统与宗教": {
		"idx": W.I_RELIGION, "num": 50, "panel": "右栏传统与宗教",
		"slots": ["文化革命", "国家无神论", "宗教管制", "世俗化", "尊崇传统", "政教协定"],
	},
	"军事力量": {
		"idx": W.I_MIL_DOCTRINE, "num": 51, "panel": "右栏军事力量",
		"slots": ["全民皆兵", "积极建军", "国防建设", "职业化军队"],
	},
}

# ── 政策介绍（原版 Doctrine_button_script.cs OnMouseEnter fake_text，逐字含空格）──
# modifies[6] 激活版与非激活版两套；10/11 再按 modifies[11] 分支；6/19/24 按 resultOfEvents[444]；
# 21 按 event_done[550]/resultOfEvents[550]；13（非 mod6）按 event_done[682]/resultOfEvents[682]。
const INTRO_10A := "以 约 瑟 夫 · 斯 大 林 时 代 苏 联 的 经 济 制 度 为 蓝 本 形 成 的 发 展 模 式 ： 国 营 经 济 为 支 柱 ， 集 体 产 业 促 过 渡 ， 并 通 过 适 量 的 副 业 经 营 形 式 为 补 充 。 国 家 以 五 年 计 划 形 式 统 筹 国 民 经 济 ， 并 引 入 经 济 核 算 制 度 估 量 生 产 效 益 ， 从 而 实 现 国 民 经 济 持 续 发 展 。"
const INTRO_10B := "在 中 央 计 划 经 济 的 基 础 上 引 入 计 算 机 ， 建 立 数 据 库 并 启 用 自 动 收 集 与 处 理 经 济 信 息 的 自 动 化 系 统 ， 将 决 策 方 案 交 由 计 算 机 运 算 得 出 。 这 将 迅 速 提 高 经 济 决 策 效 率 与 经 济 生 活 的 透 明 度"
const INTRO_11A := "依 托 中 国 国 情 生 成 的 计 划 经 济 变 种 ， 在 确 保 计 划 经 济 基 本 特 点 的 同 时 拓 展 了 地 方 部 门 与 基 层 生 产 单 位 在 所 有 制 与 生 产 组 织 的 权 限 （ 如 农 村 层 面 实 行 的 三 级 所 有 ， 队 为 基 础 ） 。 国 家 计 委 、 地 方 政 府 与 生 产 单 位 将 在 共 同 协 作 的 基 础 上 达 成 五 年 计 划 指 标 ， 由 此 既 可 确 保 各 方 能 动 性 ， 又 可 使 全 国 经 济 发 展 统 筹 兼 顾 。"
const INTRO_11B := "在 分 权 计 划 经 济 的 基 础 上 引 入 计 算 机 ， 通 过 高 效 、 迅 速 、 精 确 的 数 字 工 作 组 织 起 不 间 断 的 供 应 — 生 产 — 商 品 网 络 ， 极 大 的 改 善 企 业 、 商 店 、 仓 库 和 交 通 之 间 的 协 调 运 转 ， 以 实 现 经 济 繁 荣"
const INTRO_12 := "该 经 济 体 制 充 分 利 用 市 场 关 系 与 商 品 货 币 机 制 ， 在 确 保 国 家 掌 握 经 济 制 高 点 的 同 时 积 极 运 用 经 济 核 算 机 制 ， 促 进 企 业 增 产 增 效 。 与 此 同 时 ， 我 们 将 在 无 足 轻 重 的 领 域 内 放 开 多 种 经 营 形 式 ， 进 一 步 巩 固 现 有 经 济 制 度 。"
const INTRO_18 := "凡 是 违 反 人 道 主 义 ，背 叛 社 会 福 利 ，违 背 国 家 民 族 利 益 的 言 论 ，不 会 包 含 真 理  ，不 会 劲 得 试 验 ，不 会 被 人 赞 同 ，不 会 言 之 无 愧 ，这 都 是 言 论 自 由 自 规 的 范 围"
const INTRO_20 := "中 华 人 民 共 和 国 是 全 国 各 族 人 民 共 同 缔 造 的 统 一 的 多 民 族 国 家 ，在 统 一 的 国 家 内 实 行 民 族 区 域 自 治 ，更 有 利 于 民 族 平 等 原 则 的 实 现"
const INTRO_21_R2 := "综 合 考 虑 中 国 基 本 国 情 、 政 治 传 统 与 社 会 舆 论 影 响 ， 并 兼 采 区 域 自 治 与 联 邦 之 长 ， 在 民 主 集 中 制 原 则 上 所 建 立 的 极 具 灵 活 性 的 动 态 联 邦 制 。"
const INTRO_21_R0 := "我 国 联 邦 构 建 基 于 央 地 平 等 原 则 ， 并 在 中 央 与 地 方 机 构 间 建 立 了 明 确 的 职 权 边 界 与 分 工 体 系 。 由 此 可 在 促 使 各 地 充 分 自 治 ， 展 现 主 观 能 动 性 的 同 时 发 挥 中 央 协 调 各 方 ， 统 筹 诸 多 利 益 的 中 枢 作 用 ， 并 培 育 适 应 现 代 生 活 ， 积 极 承 担 义 务 的 新 公 民 。"
const INTRO_21_R1 := "我 国 联 邦 构 建 基 于 民 族 自 决 原 则 ， 并 以 各 地 民 族 权 力 机 构 的 设 置 为 参 照 重 新 设 计 了 国 家 机 构 。 通 过 配 额 制 度 、 民 族 代 表 与 建 构 社 会 主 义 爱 国 精 神 。 我 们 得 以 在 促 进 经 济 社 会 平 等 的 同 时 构 建 统 一 的 中 华 劳 动 民 族 群 体 ， 由 此 将 各 族 人 民 团 结 一 致 。"
const INTRO_21_DEF := "如 果 我 们 想 要 贯 彻 马 克 思 列 宁 主 义 的 民 族 政 策 ， 那 就 必 须 在 充 分 了 解 地 方 情 况 的 基 础 上 统 筹 兼 顾 ， 建 立 民 族 权 力 机 构 与 下 放 文 化 自 治 权 将 是 落 实 民 族 自 决 权 的 关 键 一 招 。"
const INTRO_26 := "公 民 拥 有 宗 教 信 仰 自 由 ，但 国 家 也 依 法 管 理 宗 教 事 务 ，坚 持 独 立 自 主 自 办 原 则 ，积 极 引 导 宗 教 与 社 会 主 义 社 会 相 适 应"
const INTRO_27 := "我 们 要 求 教 会 与 国 家 完 全 分 离 ，国 家 不 应 当 同 宗 教 发 生 关 系 ，宗 教 团 体 不 应 当 同 国 家 政 权 发 生 联 系 ，宗 教 不 得 干 预 行 政 、司 法 、教 育 等 国 家 职 能 实 施"
const INTRO_30 := "武 装 的 人 民 群 众 是 陷 敌 于 灭 顶 之 灾 的 汪 洋 大 海 ！ 革 命 战 争 是 群 众 的 战 争 ，只 有 动 员 群 众 才 能 进 行 战 争 ，只 有 依 靠 群 众 才 能 进 行 战 争 ！"
const INTRO_31 := "我 们 的 军 队 现 代 化 水 平 与 国 家 安 全 需 求 相 比 差 距 还 很 大 ，与 世 界 先 进 军 事 水 平 相 比 差 距 还 很 大 ，要 加 快 把 人 民 军 队 建 设 成 为 世 界 一 流 军 队 ！"
const INTRO_32 := "我 们 爱 好 和 平 ，但 以 斗 争 求 和 平 则 和 平 存 ，以 妥 协 求 和 平 则 和 平 亡 。 我 们 的 国 防 将 获 得 巩 固 ，不 允 许 任 何 帝 国 主 义 者 再 来 侵 略 我 们 的 国 土"
const INTRO_33 := "全 世 界 军 队 都 开 始 玩 职 业 化 改 革 ，我 们 也 得 跟 上 潮 流 — — 短 小 精 悍 才 是 劲 旅"
# modifies[6] 非激活版独有
const INTRO_N13A := "遵 循 亨 利 · 乔 治 主 张 的 混 合 发 展 模 式 ， 希 望 通 过 单 一 税 制 与 国 家 保 护 政 策 将 私 有 财 产 权 与 社 会 化 要 素 二 者 灵 活 置 于 市 场 经 济 框 架 下 ， 最 终 博 采 众 长 。"
const INTRO_N13B := "中 国 经 济 学 家 陈 云 的 创 举 。 主 张 在 在 保 留 严 格 政 府 监 管 ， 确 保 国 家 经 营 国 计 民 生 的 同 时 ， 兼 采 市 场 经 济 与 私 营 部 门 的 优 点 。 就 此 形 成 广 泛 而 深 刻 的 国 家 行 政 命 令 与 宏 观 调 控 政 策 下 主 导 的 转 型 经 济 与 管 制 市 场 模 式 。"
const INTRO_N14 := "基 于 市 场 反 应 社 会 需 求 的 原 则 安 排 国 民 经 济 发 展 方 略 ， 确 保 多 种 所 有 制 经 济 充 分 发 展 ， 并 依 法 平 等 参 与 竞 争 。 国 家 则 转 向 协 调 公 共 利 益 并 制 定 宏 观 经 济 政 策 ， 通 过 财 政 与 货 币 政 策 规 范 与 引 导 经 济 活 动 。 由 此 形 成 服 务 型 国 家 与 充 分 自 由 的 市 场 经 济 框 架 。"
const INTRO_N15 := "以 现 代 美 国 与 自 由 主 义 经 济 政 策 为 蓝 本 的 经 济 制 度 ， 充 分 发 挥 市 场 对 资 源 配 置 的 决 定 性 作 用 ： 国 家 将 在 让 渡 公 共 设 施 ， 形 成 社 会 共 治 体 系 的 同 时 ； 对 包 括 中 央 银 行 在 内 的 金 融 部 门 实 现 私 有 化 。 最 终 建 立 起 适 配 宪 政 制 度 与 自 然 秩 序 的 经 济 体 系 ： 国 家 依 法 履 职 ， 企 业 依 法 组 织 ， 两 者 相 安 无 事 。"
const INTRO_N6 := "顾 名 思 义 ， 即 由 单 一 执 政 党 垄 断 国 家 大 权 的 权 力 分 配 形 式 。 执 政 党 不 仅 控 制 了 国 内 的 主 要 政 治 部 门 ， 同 时 还 以 法 律 形 式 确 立 了 自 身 的 唯 一 核 心 地 位 。 这 意 味 着 该 国 政 治 生 活 与 发 展 方 向 将 完 全 仰 赖 于 该 党 的 组 织 方 式 与 总 路 线 。"
const INTRO_N7 := "类 似 新 加 坡 与 墨 西 哥 式 的 控 制 民 主 共 和 国 ， 在 基 本 采 纳 现 代 代 议 制 框 架 的 同 时 构 建 排 斥 竞 争 与 极 具 家 长 制 色 彩 的 体 系 ， 由 此 形 成 部 分 政 治 集 团 的 优 势 与 特 权 地 位 ， 为 一 党 独 大 的 霸 权 铺 平 道 路 ， 可 被 冠 以 “ 最 民 主 的 独 裁 ” 之 名 。"
const INTRO_N8 := "美 国 建 国 先 贤 的 政 治 理 想 ， 如 今 常 以 “ 防 御 性 民 主 ” 的 形 式 登 场 ： 即 在 引 入 多 党 制 、 自 由 化 与 竞 争 选 举 的 同 时 收 拢 法 律 控 制 并 规 范 政 治 参 与 ， 由 此 将 危 害 国 家 长 远 发 展 的 极 端 主 义 与 民 粹 主 义 势 力 剔 除 出 政 治 议 程 。"
const INTRO_N9 := "现 代 多 党 制 模 式 的 变 种 ， 相 较 于 传 统 框 架 更 强 调 贯 彻 多 元 主 义 价 值 观 。 因 此 ， 它 将 在 完 全 放 开 政 治 结 社 的 同 时 进 一 步 拓 宽 政 治 参 与 渠 道 ， 并 通 过 比 例 代 表 与 配 额 制 度 确 保 国 家 收 到 社 会 各 界 的 声 音 。"
const INTRO_N16 := "“ 谁 准 他 们 写 这 些 狗 屁 文 章 了 ？ 他 们 都 得 滚 去 伐 木 营 ： 把 国 家 在 他 们 身 上 浪 费 的 税 金 得 给 我 吐 出 来 。 ” — — 尼 基 塔 · 谢 尔 盖 耶 维 奇 · 赫 鲁 晓 夫"
const INTRO_N17 := "众 所 周 知 ， 权 利 与 义 务 从 来 对 等 。 民 主 自 由 自 然 以 不 侵 犯 他 人 的 自 由 为 前 提 ： 因 此 ， 让 人 讲 话 天 塌 不 下 来 的 潜 台 词 无 非 是 “ 天 不 会 塌 下 来 ” 。 审 查 制 度 与 宣 传 鼓 动 政 策 的 美 妙 之 处 便 在 于 此 。"
const INTRO_N19 := "人 类 各 有 各 的 思 想 ，在 生 活 的 意 识 上 便 各 有 各 的 自 由 ，把 我 们 的 思 想 从 教 条 主 义 的 思 维 方 式 中 解 放 出 来 ，建 立 绝 对 自 由，绝 对 公 开 ，绝 对 多 元"
const INTRO_N22 := "中 国 不 适 宜 于 单 一 的 国 家 组 织 ，自 清 之 亡 ，无 一 省 不 曾 宣 告 过 独 立 ，省 之 组 织 ，情 状 贫 富 不 同 ，地 势 及 人 才 互 异 ，若 强 为 一 律 ，详 细 规 定 ，事 实 不 能 ，宜 予 以 多 少 之 权 ，自 定 制 度 ，由 邦 而 必 使 成 国"
const INTRO_N23 := "为 了 应 对 复 杂 安 全 威 胁 ，赢 得 国 家 战 略 优 势 ，我 们 迫 切 需 要 将 中 华 民 族 统 合 为 一 个 能 够 确 保 外 部 地 区 安 全 ，内 部 经 济 繁 荣 ，民 族 发 展 自 由 的 政 治 、 经 济 、 军 事 联 盟 共 同 体"
const INTRO_N24 := "落 后 就 要 挨 打 ！ 如 果 还 想 将 这 个 国 家 重 新 整 顿 起 来 ， 就 必 须 竭 尽 所 能 赶 上 科 学 精 神 的 末 班 车 ！ 我 们 将 竭 尽 所 能 扫 除 堆 积 五 千 年 之 久 的 垃 圾 堆 ！               “ 欲 使 中 国 不 亡 ， 欲 使 中 国 民 族 为 二 十 世 纪 文 明 之 民 族 ， 必 以 废 孔 学 、 灭 道 教 为 根 本 之 解 决 ， 而 废 记 载 孔 门 学 说 及 道 教 妖 言 之 汉 文 ， 尤 为 根 本 解 决 之 根 本 。 ” — — 钱 玄 同"
const INTRO_N25 := "“ 蒙 昧 中 世 纪 ” 的 概 念 早 已 被 摒 弃 。 即 便 是 曾 奉 行 政 教 结 合 的 西 方 国 家 ， 牧 师 与 教 会 的 时 代 也 已 成 为 了 历 史 。 那 么 ， 我 们 为 什 么 要 让 这 些 家 伙 在 中 国 获 得 一 席 之 地 呢 ？ 更 何 况 ， 宗 教 在 古 代 便 常 作 为 民 变 的 同 义 词 — — 没 必 要 让 潜 在 对 手 掌 握 如 此 危 险 的 武 器 。"
const INTRO_N28 := "你 还 能 有 老 祖 宗 聪 明 ？ 我 们 作 为 民 族 一 切 文 化 、思 想 、道 德 的 最 优 秀 传 统 的 继 承 者 ，要 把 这 一 切 优 秀 传 统 看 成 和 自 己 血 肉 相 连 的 东 西 ，而 且 将 继 续 加 以 发 扬 光 大 ！"
const INTRO_N29 := "宗 教 领 袖 能 够 号 召 信 众 支 持 政 权 ，国 家 律 令 可 以 规 训 社 会 礼 敬 信 仰 ，双 方 完 全 没 有 必 要 分 庭 抗 礼 ，为 了 共 同 利 益 ，让 我 们 化 解 矛 盾 ，构 建 和 谐 政 教 关 系"
# modifies[6] 激活版独有
const INTRO_M13 := "“ 只 要 社 会 需 要 ， 地 下 工 厂 还 可 以 增 加 。 可 以 开 私 营 大 厂 ， 订 个 协 议 ， 十 年 、 二 十 年 不 没 收 。 华 侨 投 资 的 ， 二 十 年 、 一 百 年 不 要 没 收 。 可 以 开 投 资 公 司 ， 还 本 付 息 。 可 以 搞 国 营 ， 也 可 以 搞 私 营 。 可 以 消 灭 了 资 本 主 义 ， 又 搞 资 本 主 义 。 ” — — 毛 泽 东"
const INTRO_M14 := "<color=red>“ 党 内 党 外 都 要 分 清 是 非 。 如 何 对 待 犯 了 错 误 的 人 ， 这 是 一 个 重 要 的 问 题 。 正 确 的 态 度 应 当 是 ， 对 于 犯 错 误 的 同 志 ， 采 取 ‘ 惩 前 毖 后 ， 治 病 救 人 ’ 的 方 针 ， 帮 助 他 们 改 正 错 误 ， 允 许 他 们 继 续 革 命 。 ” — — 毛 泽 东</color>"
const INTRO_M15 := "<color=red>“ 党 内 党 外 都 要 分 清 是 非 。 如 何 对 待 犯 了 错 误 的 人 ， 这 是 一 个 重 要 的 问 题 。 正 确 的 态 度 应 当 是 ， 对 于 犯 错 误 的 同 志 ， 采 取 ‘ 惩 前 毖 后 ， 治 病 救 人 ’ 的 方 针 ， 帮 助 他 们 改 正 错 误 ， 允 许 他 们 继 续 革 命 。 ” — — 毛 泽 东</color>"
const INTRO_M6A := "无 产 阶 级 专 政 发 端 自 我 国 在 文 化 大 革 命 时 期 形 成 的 独 特 政 治 生 态 ， 并 彻 底 实 现 了 劳 动 人 民 直 接 参 加 国 家 管 理 的 创 举 ： 它 在 管 理 上 议 行 合 一 ， 决 策 上 民 主 集 中 ， 思 想 上 团 结 一 致 ， 并 充 分 贯 彻 委 员 制 与 平 等 主 义 原 则 。 我 们 将 在 共 产 党 内 革 命 派 领 导 的 基 础 上 以 类 苏 维 埃 组 织 “ 革 命 委 员 会 ” 的 形 式 充 分 发 挥 群 众 的 革 命 斗 志 、 首 倡 精 神 和 创 造 能 力 。"
const INTRO_M6B := "毛 主 义 语 境 下 的 无 产 阶 级 专 政 代 表 了 我 国 在 文 化 大 革 命 时 期 形 成 的 独 特 政 治 生 态 ： 即 在 管 理 上 议 行 合 一 ， 决 策 上 民 主 集 中 ， 思 想 上 团 结 一 致 ， 并 在 确 保 我 国 坚 定 社 会 主 义 路 线 的 基 础 上 以 三 结 合 形 式 将 党 的 领 导 落 入 实 践 中 。"
const INTRO_M7 := "即 包 括 “ 过 渡 时 期 总 路 线 ” 在 内 的 建 国 七 年 初 形 成 的 制 度 框 架 ， 其 核 心 要 义 体 现 在 《1954 年 版 宪 法 》 内 的 部 分 条 款 与 各 项 基 本 制 度 ： 即 强 势 的 国 家 主 席 与 行 政 部 门 ， 多 阶 级 联 合 专 政 的 国 体 ， 协 调 各 方 利 益 的 社 会 政 策 ， 以 及 通 过 法 律 形 式 确 立 的 一 党 领 导 制 。"
const INTRO_M8 := "源 自30 年 代 的 人 民 阵 线 理 论 ， 二 战 后 曾 在 东 欧 地 区 短 暂 实 行 。 主 张 在 多 党 制 框 架 下 组 建 民 主 派 联 盟 或 反 法 西 斯 阵 线 式 的 联 合 政 府 形 式 团 结 社 会 各 阶 级 ， 并 通 过 操 纵 部 分 关 键 部 门 争 取 实 现 社 会 主 义 者 独 大 的 政 治 格 局 。"
const INTRO_M9 := "<color=red>“ 党 内 党 外 都 要 分 清 是 非 。 如 何 对 待 犯 了 错 误 的 人 ， 这 是 一 个 重 要 的 问 题 。 正 确 的 态 度 应 当 是 ， 对 于 犯 错 误 的 同 志 ， 采 取 ‘ 惩 前 毖 后 ， 治 病 救 人 ’ 的 方 针 ， 帮 助 他 们 改 正 错 误 ， 允 许 他 们 继 续 革 命 。 ” — — 毛 泽 东</color>"
const INTRO_M16 := "不 许 反 革 命 分 子 发 表 反 革 命 意 见 ，我 们 的 制 度 就 是 不 许 一 切 反 革 命 分 子 有 言 论 自 由 ，而 只 许 人 民 内 部 有 这 种 自 由"
const INTRO_M17 := "社 会 主 义 的 纪 律 约 束 下 ，人 民 享 受 着 广 泛 的 民 主 和 自 由 ，让 人 讲 话 ，天 不 会 塌 下 来 ，自 己 也 不 会 垮 台"
const INTRO_M19A := "根 据 马 克 思 主 义 哲 学 的 观 点 ， 自 由 境 界 代 表 了 人 类 将 自 身 发 展 作 为 目 的 ， 并 充 分 掌 握 社 会 历 史 规 律 ， 积 极 行 使 自 由 权 利 的 发 展 阶 段 。 经 过 了 社 会 革 命 的 锻 炼 ： 我 们 得 以 告 别 庸 俗 的 公 民 自 由 与 宪 政 自 由 框 架 ， 并 在 彻 底 砸 碎 公 检 法 的 同 时 将 革 命 意 识 形 态 上 升 到 道 德 自 觉 ， 形 成 了 适 配 新 时 代 的 生 活 方 式 。"
const INTRO_M19B := "<color=red>“ 自 由 是 有 领 导 的 自 由 ， 民 主 是 集 中 指 导 下 的 民 主 ， 不 是 无 政 府 状 态 。 无 政 府 状 态 不 符 合 人 民 的 利 益 和 愿 望 。 ” — — 毛 泽 东</color>"
const INTRO_M22 := "<color=red>“ 社 会 科 学 ， 马 克 思 列 宁 主 义 ， 斯 大 林 讲 得 对 的 那 些 方 面 ， 我 们 一 定 要 继 续 努 力 学 习 。 我 们 要 学 的 是 属 于 普 遍 真 理 的 东 西 ， 并 且 学 习 一 定 要 与 中 国 实 际 相 结 合 。 如 果 每 句 话 ， 包 括 马 克 思 的 话 ， 都 要 照 搬 ， 那 就 不 得 了 。 我 们 的 理 论 ， 是 马 克 思 列 宁 主 义 的 普 遍 真 理 同 中 国 革 命 的 具 体 实 践 相 结 合 。 ” — — 毛 泽 东</color>"
const INTRO_M23 := "<color=red>“ 党 内 党 外 都 要 分 清 是 非 。 如 何 对 待 犯 了 错 误 的 人 ， 这 是 一 个 重 要 的 问 题 。 正 确 的 态 度 应 当 是 ， 对 于 犯 错 误 的 同 志 ， 采 取 ‘ 惩 前 毖 后 ， 治 病 救 人 ’ 的 方 针 ， 帮 助 他 们 改 正 错 误 ， 允 许 他 们 继 续 革 命 。 ” — — 毛 泽 东</color>"
const INTRO_M24A := "思 想 解 放 议 程 正 借 着 经 济 社 会 领 域 的 革 命 势 头 茁 壮 成 长 ， 并 在 劳 动 集 体 的 发 展 中 持 续 高 歌 猛 进 ： 工 厂 与 公 社 本 身 成 为 了 综 合 劳 动 与 知 识 的 学 校 ， 将 奉 行 内 部 精 英 主 义 的 旧 道 德 、 旧 思 想 与 旧 文 化 机 构 一 扫 而 空 ， 并 以 大 众 文 化 的 崛 起 空 前 丰 富 了 文 化 表 达 内 容 与 形 式 。 民 主 与 科 学 的 旗 帜 就 此 在 中 国 取 得 完 胜 。"
const INTRO_M24B := "中 国 文 化 革 命 的 历 史 可 追 溯 至20 世 纪 初 的 激 进 民 主 运 动 ， 并 在 毛 泽 东 时 代 内 得 以 发 扬 光 大 ： 旧 道 德 ， 旧 风 俗 与 旧 文 化 皆 在 社 会 革 命 内 一 扫 而 空 ， 并 被 主 人 翁 意 识 与 社 会 契 约 取 而 代 之 。                        “ 你 们 可 以 改 了 ， 从 真 心 改 起 ！ 要 晓 得 将 来 容 不 得 吃 人 的 人 ， 活 在 世 上 。 ” — — 《 狂 人 日 记 》"
const INTRO_M25 := "历 史 已 充 分 证 明 了 “ 人 民 鸦 片 ” 对 社 会 的 危 害 ！ 我 们 将 以 苏 联 组 织 战 斗 无 神 论 者 联 盟 的 经 验 全 面 开 战 ， 在 国 内 彻 底 扫 除 教 会 、 祠 堂 与 各 路 反 动 窝 点 。 确 立 科 学 精 神 在 国 内 的 主 导 地 位 ！"
const INTRO_M28 := "<color=red>“ 党 内 党 外 都 要 分 清 是 非 。 如 何 对 待 犯 了 错 误 的 人 ， 这 是 一 个 重 要 的 问 题 。 正 确 的 态 度 应 当 是 ， 对 于 犯 错 误 的 同 志 ， 采 取 ‘ 惩 前 毖 后 ， 治 病 救 人 ’ 的 方 针 ， 帮 助 他 们 改 正 错 误 ， 允 许 他 们 继 续 革 命 。 ” — — 毛 泽 东</color>"
const INTRO_M29 := "<color=red>“ 党 内 党 外 都 要 分 清 是 非 。 如 何 对 待 犯 了 错 误 的 人 ， 这 是 一 个 重 要 的 问 题 。 正 确 的 态 度 应 当 是 ， 对 于 犯 错 误 的 同 志 ， 采 取 ‘ 惩 前 毖 后 ， 治 病 救 人 ’ 的 方 针 ， 帮 助 他 们 改 正 错 误 ， 允 许 他 们 继 续 革 命 。 ” — — 毛 泽 东</color>"

## 原版 Doctrine_button_script.cs:1478-1791 中文块的选择器（modifies[6] 分支 + 事件状态分支）
func _policy_intro_raw(w: WorldState, target_val: int) -> String:
	if _mod_active(w, 6):
		match target_val:
			10: return INTRO_10A if not _mod_active(w, 11) else INTRO_10B
			11: return INTRO_11A if not _mod_active(w, 11) else INTRO_11B
			12: return INTRO_12
			13: return INTRO_M13
			14: return INTRO_M14
			15: return INTRO_M15
			6: return INTRO_M6A if _evt_result(w, 444) == 0 else INTRO_M6B
			7: return INTRO_M7
			8: return INTRO_M8
			9: return INTRO_M9
			16: return INTRO_M16
			17: return INTRO_M17
			18: return INTRO_18
			19: return INTRO_M19A if _evt_result(w, 444) == 0 else INTRO_M19B
			20: return INTRO_20
			21: return _intro_21(w)
			22: return INTRO_M22
			23: return INTRO_M23
			24: return INTRO_M24A if _evt_result(w, 444) == 0 else INTRO_M24B
			25: return INTRO_M25
			26: return INTRO_26
			27: return INTRO_27
			28: return INTRO_M28
			29: return INTRO_M29
			30: return INTRO_30
			31: return INTRO_31
			32: return INTRO_32
			33: return INTRO_33
	else:
		match target_val:
			10: return INTRO_10A if not _mod_active(w, 11) else INTRO_10B
			11: return INTRO_11A if not _mod_active(w, 11) else INTRO_11B
			12: return INTRO_12
			13: return INTRO_N13A if (_evt_done(w, 682) and _evt_result(w, 682) == 3) else INTRO_N13B
			14: return INTRO_N14
			15: return INTRO_N15
			6: return INTRO_N6
			7: return INTRO_N7
			8: return INTRO_N8
			9: return INTRO_N9
			16: return INTRO_N16
			17: return INTRO_N17
			18: return INTRO_18
			19: return INTRO_N19
			20: return INTRO_20
			21: return _intro_21(w)
			22: return INTRO_N22
			23: return INTRO_N23
			24: return INTRO_N24
			25: return INTRO_N25
			26: return INTRO_26
			27: return INTRO_27
			28: return INTRO_N28
			29: return INTRO_N29
			30: return INTRO_30
			31: return INTRO_31
			32: return INTRO_32
			33: return INTRO_33
	return ""


## 政策介绍入口：把原版 Unity 尖括号 <color=red></color> 转成 Godot BBCode [color=red][/color]
## （Godot 4.7 文档 gdd_0413：RichTextLabel 仅识别方括号标签，支持命名颜色 red）。
func _policy_intro(w: WorldState, target_val: int) -> String:
	return _policy_intro_raw(w, target_val) \
		.replace("<color=red>", "[color=red]") \
		.replace("</color>", "[/color]")


## id21 联邦制介绍：按 event_done[550] + resultOfEvents[550] 分支（原版 :1570-1585/:1726-1741）
func _intro_21(w: WorldState) -> String:
	if _evt_done(w, 550):
		var r := _evt_result(w, 550)
		if r == 2:
			return INTRO_21_R2
		if r == 0:
			return INTRO_21_R0
		if r == 1:
			return INTRO_21_R1
	return INTRO_21_DEF


# ── 当前政策名标签（doctr 名表）──
# 原版 Politic_doctr_script 读 doctr[data[idx]]；doctr[42] 基础名来自 Assets/Resources/Doctr_en.txt
# （LoadInScript.cs:64-79），再由 modifies[6].active 覆盖部分项（GameStartScript.cs:1645-1673）。
# 开局 modifies[6] 激活 → 经济11=中式计划经济、党政6=无产阶级专政、宗教24=文化革命…
const DOCTR_BASE := {
	0: "威权主义", 1: "保守社会主义", 2: "民族特色社会主义", 3: "邓式实用主义", 4: "社会民主主义", 5: "自由主义",
	6: "一党制共和国", 7: "新民主主义制度", 8: "管制民主制", 9: "西方范式民主国家",
	10: "中央计划经济", 11: "分权计划经济", 12: "国家垄断资本主义", 13: "鸟笼经济", 14: "\"社会\"市场经济", 15: "最小干预",
	16: "舆论一律", 17: "纪律约束", 18: "自然限制", 19: "多元自由",
	20: "单一制", 21: "联邦制", 22: "联省自治", 23: "自治联盟",
	24: "破除传统", 25: "无神论化", 26: "宗教管制", 27: "世俗主义", 28: "尊崇传统", 29: "政教协定",
	30: "全民皆兵", 31: "积极建军", 32: "建设国防", 33: "合同兵制",
	34: "社会主义", 35: "改良主义", 36: "实用主义", 37: "市场", 38: "威权", 39: "强硬", 40: "柔和", 41: "民主",
}
# modifies[6].active 时覆盖（GameStartScript.cs:1647-1657）
const DOCTR_MOD6 := {
	6: "无产阶级专政", 8: "人民民主制度", 9: "协和民主体制", 10: "经典计划经济", 11: "中式计划经济",
	13: "国家监护资本主义", 14: "社会主义导向市场", 15: "左翼小政府", 21: "改良区域自治制度", 22: "联邦制", 24: "文化革命",
}

# ── 状态位读取（映射 WorldState；数字事件未移植 → 恒默认）──
func _mod_active(w: WorldState, n: int) -> bool:
	return w != null and w.modifiers.size() > n and w.modifiers[n] != null and w.modifiers[n].is_active

func _dec_done(w: WorldState, n: int) -> bool:
	return w != null and w.decisions != null and w.decisions.completed.size() > n and w.decisions.completed[n]

# 数字键事件（444/502/503/550/551/682…）在本移植中未接入（completed_event_ids 用字符串键）
# → resultOfEvents 恒 -1、event_done 恒 false，与原版 GameStartScript.cs:48-51 初始态一致。
func _evt_result(w: WorldState, n: int) -> int:
	return w.completed_event_ids.get(n, -1) if w != null else -1

func _evt_done(w: WorldState, n: int) -> bool:
	return w != null and w.completed_event_ids.has(n)


## 当前政策值 id → 显示名（doctr[id]，modifies[6] 覆盖）。原版 doctr[data[idx]]。
func doctr_name(w: WorldState, id: int) -> String:
	if _mod_active(w, 6) and DOCTR_MOD6.has(id):
		return DOCTR_MOD6[id]
	return DOCTR_BASE.get(id, "未知")


## 忠实移植 Doctrine_script.cs OnMouseDown()：按 this_number 与真实状态位生成有序选项 [{id,text}]。
## 数字事件（444/503/550/551/682）未移植 → _evt_* 恒 -1/false，与原版开局初始态一致。
## 开局态 modifies[6]=true、completedDecisions/其余 modifies 全 false → 各类满编选项。
func _build_options(w: WorldState, num: int) -> Array[Dictionary]:
	var o: Array[Dictionary] = []
	match num:
		16:  # 经济
			if _mod_active(w, 11):
				o.append({"id": 10, "text": "国家信息自动化系统"})
				o.append({"id": 11, "text": "赛博协同控制工程"})
			elif _dec_done(w, 18):
				o.append({"id": 12, "text": "国家垄断资本主义"})
			elif _evt_result(w, 503) == 0:
				o.append({"id": 10, "text": "中央计划经济"})
			elif _evt_result(w, 682) == 3:
				o.append({"id": 13, "text": "新乔治主义社会"})
			elif _mod_active(w, 6):
				o.append({"id": 10, "text": "经典计划经济"})
				o.append({"id": 11, "text": "中式计划经济"})
				o.append({"id": 12, "text": "国家资本主义"})
				o.append({"id": 13, "text": "国家监护资本主义"})
				if not _dec_done(w, 13):
					o.append({"id": 14, "text": "社会主义导向市场"})
					o.append({"id": 15, "text": "左翼小政府"})
			else:
				o.append({"id": 10, "text": "中央计划经济"})
				o.append({"id": 11, "text": "分权计划经济"})
				o.append({"id": 12, "text": "国家资本主义"})
				o.append({"id": 13, "text": "鸟笼经济"})
				if not _dec_done(w, 13):
					o.append({"id": 14, "text": "混合经济"})
					o.append({"id": 15, "text": "最小干预"})
		15:  # 党政
			if _evt_done(w, 444) and _evt_result(w, 444) == 0:
				o.append({"id": 6, "text": "无产阶级专政"})
			elif _evt_result(w, 503) == 0:
				o.append({"id": 6, "text": "一党专政"})
			elif _dec_done(w, 18):
				o.append({"id": 7, "text": "新民主主义制度" if _mod_active(w, 6) else "一党独大式民主"})
			elif _mod_active(w, 6):
				o.append({"id": 6, "text": "无产阶级专政"})
				o.append({"id": 7, "text": "新民主主义制度"})
				if not _dec_done(w, 13) and not _mod_active(w, 24) and not _dec_done(w, 16):
					o.append({"id": 8, "text": "人民民主制度"})
					o.append({"id": 9, "text": "协和民主体制"})
			else:
				o.append({"id": 6, "text": "一党专政党内民主"})
				o.append({"id": 7, "text": "一党独大式民主"})
				if not _dec_done(w, 13) and not _mod_active(w, 24) and not _dec_done(w, 16):
					o.append({"id": 8, "text": "宪政民主制度"})
					o.append({"id": 9, "text": "协和民主体制"})
		17:  # 人权
			if _evt_done(w, 444) and _evt_result(w, 444) == 0:
				o.append({"id": 19, "text": "自由境界"})
			else:
				o.append({"id": 16, "text": "舆论一律"})
				if not _mod_active(w, 26) and _evt_result(w, 503) != 0:
					o.append({"id": 17, "text": "纪律约束"})
					o.append({"id": 18, "text": "自然限制"})
					o.append({"id": 19, "text": "多元自由"})
		18:  # 国家体制
			if _evt_done(w, 551) and _evt_result(w, 551) == 3:
				o.append({"id": 21, "text": _territory21_text(w)})
				o.append({"id": 22, "text": "联邦制" if _mod_active(w, 6) else "联省自治"})
				o.append({"id": 23, "text": "自治联盟"})
			elif _evt_done(w, 550) and _evt_result(w, 550) == 2:
				o.append({"id": 21, "text": "中国特色联邦制"})
			elif _evt_done(w, 550) and _evt_result(w, 550) == 3:
				o.append({"id": 20, "text": "单一制"})
			else:
				o.append({"id": 20, "text": "单一制"})
				o.append({"id": 21, "text": _territory21_text(w)})
				o.append({"id": 22, "text": "联邦制" if _mod_active(w, 6) else "联省自治"})
				o.append({"id": 23, "text": "自治联盟"})
		50:  # 传统与宗教
			if _evt_done(w, 444) and _evt_result(w, 444) == 0:
				o.append({"id": 24, "text": "文化革命"})
			elif _evt_result(w, 503) == 0 or _evt_result(w, 682) == 1:
				o.append({"id": 29, "text": "政教协定"})
			elif not _mod_active(w, 25) and not _dec_done(w, 16):
				o.append({"id": 24, "text": "文化革命" if _mod_active(w, 6) else "破除传统"})
				o.append({"id": 25, "text": "无神国家"})
				o.append({"id": 26, "text": "民宗管制"})
				o.append({"id": 27, "text": "世俗主义"})
				o.append({"id": 28, "text": "尊崇传统"})
				o.append({"id": 29, "text": "政教协定"})
			else:
				o.append({"id": 28, "text": "尊崇传统"})
				o.append({"id": 29, "text": "政教协定"})
		51:  # 军事（固定）
			o.append({"id": 30, "text": "全民皆兵"})
			o.append({"id": 31, "text": "积极建军"})
			o.append({"id": 32, "text": "建设国防"})
			o.append({"id": 33, "text": "合同兵制"})
	return o


## 国家体制 id21 文案：随 resultOfEvents[550]（原版 :233-244/198-208，均以 modifies[6] 分改良/联邦）。
func _territory21_text(w: WorldState) -> String:
	var r := _evt_result(w, 550)
	if r == 0:
		return "美国模式联邦制"
	elif r == 1:
		return "苏联模式联邦制"
	return "改良区域自治制度" if _mod_active(w, 6) else "联邦制"


const 生育政策名 := ["一胎制", "二胎制", "无限制"]

var _当前类别: String = ""


func _ready() -> void:
	if not GameManager:
		return
	# 标题 hover 文案对齐原版 Politic.unity OkoshkoScript.text_en（政体“国家体制”、路线“党的路线”、军力“军事力量”）
	for pair in [["政体类型", "国家体制"], ["政治路线类型", "党的路线"], ["军队力量", "军事力量"], ["军队力量背景图", "军事力量"]]:
		var tip_node := _find(pair[0])
		if tip_node is Control:
			tip_node.tooltip_text = pair[1]
	GameManager.world_state_loaded.connect(_refresh)
	GameManager.date_changed.connect(func(_d): _refresh())
	_ensure_pie_chart()
	for cat_name in 政策类别:
		var btn := _find(cat_name + "切换")
		if btn is Button:
			btn.pressed.connect(_on_policy_tab.bind(cat_name))
	# 选项按钮按 slot 位置接线（id/文案运行时由 _build_options 决定，点击/悬停时按位置解析）
	for cat_name in 政策类别:
		var slots: Array = 政策类别[cat_name]["slots"]
		for slot_idx in slots.size():
			var btn := _find(slots[slot_idx])
			if btn is Button:
				btn.pressed.connect(_on_policy_slot.bind(cat_name, slot_idx))
				btn.mouse_entered.connect(_on_policy_slot_hover.bind(cat_name, slot_idx))
	for i in 派系列表.size():
		var sup := _find("支持" + 派系列表[i])
		var ban := _find("禁止" + 派系列表[i])
		if sup is TextureButton:
			sup.toggled.connect(_on_faction_support.bind(i, true))
		if ban is TextureButton:
			ban.toggled.connect(_on_faction_support.bind(i, false))
	for policy_name in 生育政策名:
		var btn := _find(policy_name)
		if btn is Button:
			btn.pressed.connect(_on_birth_policy.bind(生育政策名.find(policy_name)))
	var expand_btn := _find("右栏政策介绍展开")
	var collapse_btn := _find("右栏政策介绍收回")
	if expand_btn is TextureButton:
		expand_btn.pressed.connect(func(): _set_visible("右栏政策介绍", true))
	if collapse_btn is TextureButton:
		collapse_btn.pressed.connect(func(): _set_visible("右栏政策介绍", false))
	# 原版 Politic.unity 按钮：演讲(speechscript)、选举(ElectScript)、经济/军事同盟(ElectScript is_alliance)
	var elect_btn := _find("选举")
	if elect_btn is Button:
		elect_btn.pressed.connect(_on_manual_election)
	var speech_btn := _find("演讲")
	if speech_btn is Button:
		speech_btn.pressed.connect(_on_manual_speech)
	for pair in [["经济同盟", "economic_union"], ["军事同盟", "military_alliance"]]:
		var alliance_btn := _find(pair[0])
		if alliance_btn is Button:
			alliance_btn.pressed.connect(_on_alliance_event.bind(pair[1]))
	if GameManager.world != null:
		_refresh()


func _refresh() -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	# 原版 Politic.unity "Text (10)" 挂 Show_diplomacy_data_script num=22（guid f4a6debb…），
	# Repaint() 显示 data[22]/10 + "." + data[22]%10（Show_diplomacy_data_script.cs:346-363），
	# 即内部值 ÷10 保留 1 位小数；外交条件 data[22]>=500 即“50 军事实力”。
	_label("军队力量", "%.1f" % (w.数值表[W.I_ARMY] / 10.0))
	# 政体 = doctr[data[14]]（Politic_doctr_script doctr=14，非 party_line）
	_label("政体类型", doctr_name(w, _raw(w, W.I_IDEOLOGY)))
	# 党的路线 = doctr[data[52]] + "\n" + doctr[data[54]]（doctr=52, party_line=true）
	_label("政治路线类型", "%s\n%s" % [
		doctr_name(w, _raw(w, W.I_ECON_DISPLAY)),
		doctr_name(w, _raw(w, W.I_POLITICAL_DISPLAY)),
	])
	# 派系列表标题随政党制度切换（原版 ElectScript.Repaint text_part，逐字含空格）
	var multi: bool = w.数值表[W.I_PARTY_SYSTEM] > 7
	_label("中共党内派系", " 中 共 党 内 派 系" if not multi else " 人 大 党 派 组 织")
	# 顶部按钮可用态：选举=多党制 且 本月尚未选举（原版 is_elect 月块复位）；
	# 同盟按事件自动触发条件；演讲一次性（原版 is_speech 永不复位）。
	var elect_btn := _find("选举") as Button
	if elect_btn:
		elect_btn.disabled = (not multi) or w.get_flag("manual_election_used") or GameManager.current_event_id != ""
	for pair in [["经济同盟", false], ["军事同盟", true]]:
		var alliance_btn := _find(pair[0]) as Button
		if alliance_btn:
			alliance_btn.disabled = not GameManager.can_manual_alliance(pair[1])
	var speech_btn := _find("演讲") as Button
	if speech_btn:
		speech_btn.disabled = w.get_flag("speech_done") or GameManager.current_event_id != ""
	# 满足现状者（I_SATISFIED）仅出现在饼图灰色扇区，不进左侧可互动派系列表
	for cat_name in 政策类别:
		var cat: Dictionary = 政策类别[cat_name]
		var current_val: int = _raw(w, int(cat["idx"]))
		_label(cat_name + "显示", doctr_name(w, current_val))
	for i in mini(派系列表.size(), w.factions.size()):
		var f: FactionData = w.factions[i]
		var name_text: String = FactionData.FACTION_NAMES_MULTI[i] if multi else FactionData.FACTION_NAMES[i]
		var name_tip: String = FactionData.FACTION_NAMES_MULTI_TIP[i].replace("|", "\n") if multi else FactionData.FACTION_NAMES[i]
		var name_node := _find(派系列表[i])
		if name_node is Label:
			name_node.text = name_text
			name_node.tooltip_text = name_tip
			# 多党长名逐字含空格，缩一号字避免溢出固定行宽（原版 TextMesh 无裁剪，Godot 需按布局收束）
			name_node.add_theme_font_size_override("font_size", 22 if multi else 30)
		var sup := _find("支持" + 派系列表[i]) as TextureButton
		var ban := _find("禁止" + 派系列表[i]) as TextureButton
		if sup: sup.set_pressed_no_signal(f.is_ally)
		if ban: ban.set_pressed_no_signal(not f.is_enabled)
		# 原版 Party_ally_script.OnMouseEnter 中文 text_en 逐字；Party_zapret 中文恒为场景值“禁止”
		if sup:
			sup.tooltip_text = " 支 持" if not multi else " 同 盟"
		if ban:
			ban.tooltip_text = "禁止"
	var birth_val: int = _raw(w, W.I_BIRTH_POLICY)
	for i in 生育政策名.size():
		var btn := _find(生育政策名[i]) as Button
		# 原版按钮 this_number=1/2/3，UI 槽位 0/1/2 → +1 比较（ChildScript.ChangeColour）
		if btn: btn.set_pressed_no_signal((i + 1) == birth_val)
	var pie := _find("派系饼图") as Control
	if pie:
		pie.tooltip_text = _leading_tooltip(w)
		for child in pie.get_children():
			if child is Control:
				child.queue_redraw()
		pie.queue_redraw()
	if _当前类别 != "":
		_refresh_policy_panel(_当前类别)


## 派系席位百分比 hover 文案。逐字移植原版 leading_script.cs 中文块。
## 差异：is_konst_max 未移植 → 多党“法定多数”行缺失（Godot 无该字段），其余逐字。
func _leading_tooltip(w: WorldState) -> String:
	var total := 0
	for f in w.factions:
		total += maxi(f.support, 0)
	total += maxi(w.数值表[W.I_SATISFIED], 0)
	var t := ""
	if w.数值表[W.I_PARTY_SYSTEM] > 7:
		t += " 领 导 中 ："
		t += " 我 方 党 派 联 盟\n" if w.数值表[W.I_POLITICAL_LINE] == 1 else " 反 对 派\n"
		for i in mini(5, w.factions.size()):
			var f2: FactionData = w.factions[i]
			if not f2.is_enabled:
				continue
			if i == 3:
				t += "\n"
			var pct := int(float(maxi(f2.support, 0) * 100) / float(total)) if total > 0 else 0
			t += "%s: %d%%; " % [FactionData.FACTION_NAMES_MULTI[i], pct]
	else:
		for i in mini(5, w.factions.size()):
			var f3: FactionData = w.factions[i]
			if not f3.is_enabled:
				continue
			if i == 3:
				t += "\n"
			var pct2 := int(float(maxi(f3.support, 0) * 100) / float(total)) if total > 0 else 0
			t += "%s: %d%%; " % [FactionData.FACTION_NAMES[i], pct2]
	var sat := maxi(w.数值表[W.I_SATISFIED], 0)
	var sat_pct := int(float(sat * 100) / float(total)) if (total > 0 and sat > 0) else 0
	t += " 满 意 现 秩 序 者 ：%d%%; " % sat_pct
	if w.数值表[W.I_PARTY_SYSTEM] <= 7:
		t += "\n\n 领 导 中 ："
		# 原版 :115-118 只与 party_number[1..4] 比较
		var satisfied_leads := true
		for i in range(1, mini(5, w.factions.size())):
			if sat < maxi(w.factions[i].support, 0):
				satisfied_leads = false
				break
		if satisfied_leads:
			t += " 满 意 现 秩 序 者"
		else:
			var line := clampi(w.数值表[W.I_POLITICAL_LINE], 0, 4)
			if line < w.factions.size():
				t += FactionData.FACTION_NAMES[line]
	return t


# ── 饼图（使用 _draw 避免每帧重建节点） ──

## 场景中的「派系饼图」是空 Control，需挂上可绘制的 PieChart 子节点
func _ensure_pie_chart() -> void:
	var host := _find("派系饼图") as Control
	if host == null:
		return
	for child in host.get_children():
		if child is PieChart:
			return
	var chart := PieChart.new()
	chart.name = "Chart"
	chart.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	chart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chart.colors = 派系颜色
	host.add_child(chart)


class PieChart extends Control:
	var colors: Array[Color] = []
	func _draw() -> void:
		var w: WorldState = GameManager.world if GameManager else null
		if w == null:
			return
		var slices: Array[Dictionary] = []
		for i in mini(5, w.factions.size()):
			var f: FactionData = w.factions[i]
			if not f.is_enabled:
				continue
			var s: int = maxi(f.support, 0)
			if s > 0:
				slices.append({"value": s, "color": colors[i]})
		var satisfied: int = 0
		if w.数值表.size() > WorldState.I_SATISFIED:
			satisfied = maxi(w.数值表[WorldState.I_SATISFIED], 0)
		if satisfied > 0:
			slices.append({"value": satisfied, "color": colors[5]})
		var total := 0
		for s in slices:
			total += s.value
		if total <= 0:
			return
		var center := size / 2.0
		var radius := minf(center.x, center.y) * 0.92
		if radius <= 1.0:
			return
		var start_angle := -PI / 2.0
		for s in slices:
			var sweep := float(s.value) / float(total) * TAU
			var pts := PackedVector2Array()
			pts.append(center)
			for seg in 33:
				var angle := start_angle + sweep * float(seg) / 32.0
				pts.append(center + Vector2(cos(angle), sin(angle)) * radius)
			draw_colored_polygon(pts, s.color)
			# 黑色描边：沿扇区轮廓（圆心→弧→圆心）画闭合折线，分隔相邻派系并突出外缘
			var outline := pts.duplicate()
			outline.append(pts[0])
			draw_polyline(outline, Color.BLACK, 2.0, true)
			start_angle += sweep


# ── 政策面板 ──

func _on_policy_tab(cat_name: String) -> void:
	var toggling_off := (_当前类别 == cat_name)
	_当前类别 = "" if toggling_off else cat_name
	for cn in 政策类别:
		var pn: String = 政策类别[cn]["panel"]
		_set_visible(pn, cn == _当前类别)
	_set_visible("右栏条件显示", _当前类别 != "")
	if _当前类别 != "":
		_refresh_policy_panel(_当前类别)
	音频总管.play_button_click_sound()


func _refresh_policy_panel(cat_name: String) -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	var cat: Dictionary = 政策类别[cat_name]
	var cat_idx: int = int(cat["idx"])
	var current_val: int = _raw(w, cat_idx)
	var slots: Array = cat["slots"]
	# 运行时按状态位生成有序选项，填入位置槽；多余槽隐藏（对齐原版 num+1 个可见）
	var options := _build_options(w, int(cat["num"]))
	var first_other: int = -1
	for slot_idx in slots.size():
		var btn := _find(slots[slot_idx]) as Button
		if btn == null:
			continue
		if slot_idx >= options.size():
			btn.visible = false
			continue
		btn.visible = true
		var target_val: int = int(options[slot_idx]["id"])
		btn.text = String(options[slot_idx]["text"]).replace("\n", "")
		# 权威 4 条件检查在 GameManager，UI 只读结果（避免与实际切换判定漂移）
		var chk: Dictionary = GameManager.check_policy_change(cat_idx, target_val)
		var can_select: bool = chk["can"]
		btn.disabled = not can_select
		btn.modulate = Color.WHITE if can_select else Color(0.5, 0.5, 0.5)
		if target_val == current_val:
			btn.modulate = Color(1.0, 1.0, 0.6)
		elif first_other < 0:
			first_other = target_val
	# 常驻条件面板：默认对第一个非当前选项显示 4 条件（hover 具体选项时更新）
	if first_other >= 0:
		_label("右栏条件显示", _build_condition_text(cat_idx, first_other))


## slot 位置 → 当前该槽的政策 id（运行时由 _build_options 决定）。-1 = 槽为空。
func _slot_target(w: WorldState, cat_name: String, slot_idx: int) -> int:
	var options := _build_options(w, int(政策类别[cat_name]["num"]))
	if slot_idx < 0 or slot_idx >= options.size():
		return -1
	return int(options[slot_idx]["id"])


func _on_policy_slot(cat_name: String, slot_idx: int) -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	var target_val := _slot_target(w, cat_name, slot_idx)
	if target_val < 0:
		return
	if GameManager.change_policy(int(政策类别[cat_name]["idx"]), target_val):
		_refresh()
		音频总管.play_button_click_sound()


## 常驻 4 条件文案（原版 uslovie_text[0..3] 逐字，含空格排版）。
## 原版以 If 图标表示满足与否；Godot 用 [满足]/[未满足] 文字替代图标。
## 显示口径同原作：预算 |Δ|×5、党内团结 |Δ|×30（与判定阈值 ×50/×300 不同）。
func _build_condition_text(cat_idx: int, target_val: int) -> String:
	var w: WorldState = GameManager.world
	if w == null:
		return ""
	var current_val: int = _raw(w, cat_idx)
	var diff := absi(target_val - current_val)
	if diff == 0:
		return "当前政策"
	var chk: Dictionary = GameManager.check_policy_change(cat_idx, target_val)
	var t := " 预 算 中 的 资 金 ：%d  [%s]\n\n\n" % [diff * 5, "满足" if chk["budget_ok"] else "未满足"]
	t += " 党 内 团 结 度 高 于 ：%d  [%s]\n\n\n" % [diff * 30, "满足" if chk["party_ok"] else "未满足"]
	t += "%s  [%s]\n\n\n" % [chk["leading_text"], "满足" if chk["leading_ok"] else "未满足"]
	t += "%s  [%s]\n\n" % [_mao_cond_text(w, target_val), "满足" if chk["mao_ok"] else "未满足"]
	return t


## 第4条件文案（原版 Doctrine_button_script.cs:446-461 逐字，含空格）：
## modifies[6]激活且目标∈{9,14,15,22,23,28,29} 或 (19且res[444]≠0) → "毛主席正看着你！"；
## 否则毛已死(data[38]≥100)→"尚未建立"、毛在世→"毛主席已离世，起锚！"。
func _mao_cond_text(w: WorldState, target_val: int) -> String:
	if _mod_active(w, 6) and (target_val in [9, 14, 15, 22, 23, 28, 29] \
			or (target_val == 19 and _evt_result(w, 444) != 0)):
		return " 毛 主 席 正 看 着 你 ！"
	if GameManager.is_mao_dead():
		return " 尚 未 建 立"
	return " 毛 主 席 已 离 世 ， 起 锚 ！"


func _on_policy_slot_hover(cat_name: String, slot_idx: int) -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	var target_val := _slot_target(w, cat_name, slot_idx)
	if target_val < 0:
		return
	var cat: Dictionary = 政策类别[cat_name]
	var cat_idx: int = int(cat["idx"])
	_label("右栏条件显示", _build_condition_text(cat_idx, target_val))
	_label("右栏政策介绍文案", _policy_intro(w, target_val))


# ── 派系支持/禁止 ──
# tooltip 对齐原版中文口径（OkoshkoScript text_en）：
#   支持按钮 hover：一党制“ 支 持”，多党制“ 同 盟”（Party_ally_script.cs:130-156）
#   禁止按钮 hover：恒为场景值“禁止”（Party_zapret 只改俄文 text，中文显示 text_en 不变）
func _on_faction_support(button_pressed: bool, faction_idx: int, is_support: bool) -> void:
	if is_support:
		# 原版 Party_ally_script：一党制免费 toggle；多党制由 GameManager 按占比扣费结盟
		GameManager.set_faction_ally(faction_idx, button_pressed)
	else:
		# 原版 Party_zapret：禁止/解禁与费用/转移/强制复位全部在 GameManager
		GameManager.set_faction_enabled(faction_idx, not button_pressed)
	_refresh()


# ── 生育政策 ──

func _on_birth_policy(policy_idx: int) -> void:
	GameManager.set_birth_policy(policy_idx)
	_refresh()
	音频总管.play_button_click_sound()


# ── 选举 / 演讲 / 同盟按钮（原版 ElectScript / speechscript）──

func _on_manual_election() -> void:
	if GameManager.manual_election():
		音频总管.play_button_click_sound()
		_refresh()


func _on_manual_speech() -> void:
	if GameManager.manual_speech():
		音频总管.play_button_click_sound()
		_refresh()


func _on_alliance_event(event_id: String) -> void:
	var is_military: bool = event_id == "military_alliance"
	if not GameManager.can_manual_alliance(is_military):
		return
	GameManager.start_event(event_id)
	音频总管.play_button_click_sound()
