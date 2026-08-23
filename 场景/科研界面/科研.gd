## 科研界面主控脚本
## 管理34项科技（农业9项 + 工业9项 + 军事9项 + 航天7项）的科技树UI。
## 玩家点击科技按钮启动研究，花费科研点和预算；
## 界面通过进度条、状态图标、年份标签展示每项科技的状态。
extends GameUIBase

const W = preload("res://数据脚本/world_state.gd")
const BBC = preload("res://数据脚本/bbc_tooltip.gd")

# 34项科技的名称，同时也是场景中对应 TextureButton 节点的名称。
# 必须按 Unity Science_Script.number 顺序排列（0-33）：TECH_DAYS/MONEY/YEAR/
# DEPENDENCY 与 TECH_DESC/EFFECTS 全部以 number 为下标，名称顺序错位会导致
# 文案、Buff、数值、前置全部串行（曾把“更新军队装备”错配到 19 号的文案）。
# 分组：[0-8]农业、[9-17]工业、[18-26]军事、[27-33]航天
const TECH_NAMES: Array[String] = [
	"大跃进的遗产", "巩固农业设施", "农业方法革新",
	"发展农业机械化", "选育与基因研究", "新增研究设施",
	"新型肥料与杀虫剂", "遗传修饰", "开垦处女地",
	"改良流水线生产模式", "自研工业科技", "工业设施中国化",
	"电子工业中国化", "现代制造业", "改进国内工业机械",
	"自动化生产控制", "计算机化", "中国版的OGAS",
	"加强军备开发", "情报部门新装备", "新式间谍装备",
	"发展核武器与导弹", "迎接信息化战争", "更新军队装备",
	"发展海军与空军", "现代间谍装备", "指挥链与军事组织改革",
	"通讯卫星", "导航卫星", "军事卫星",
	"载人航天", "行星际飞行器", "轨道空间站", "航天飞机",
]

const TECH_UI_COUNT := 34

# 每项科技的最早可研究年份（从 TechState.TECH_YEAR 同步）
const UNLOCK_YEARS: Array[int] = [
	1976, 1976, 1978, 1978, 1978, 1978, 1980, 1981, 1980,
	1976, 1976, 1978, 1980, 1978, 1980, 1981, 1981, 1983,
	1976, 1978, 1978, 1981, 1981, 1976, 1978, 1980, 1981,
	1976, 1976, 1976, 1976, 1976, 1976, 1976,
]

# 悬停提示：科技介绍（原版 other_text[356+编号]，出处 other_text_en.txt 357-390 行）
const TECH_DESC: Array[String] = [
	" 大 跃 进 时 期 的 无 数 惨 剧 已 经 证 明 ， 浮 夸 风 、 官 僚 包 办 、 好 大 喜 功 ， 都 是 农 业 生 产 的 大 敌 。 若 不 想 让 昔 日 毁 灭 性 的 农 业 危 机 重 现 ， 我 们 就 得 让 农 民 与 干 部 们 树 立 起 这 么 一 种 观 念 — — 粮 食 产 量 指 标 的 订 出 与 作 物 具 体 密 度 的 确 定 等 ， 都 绝 不 能 离 开 当 地 农 民 的 指 导 。 毕 竟 ， 农 民 才 是 真 正 和 土 地 打 交 道 的 人 。",
	" 耕 种 不 能 没 有 工 具 ， 作 物 也 需 要 灌 溉 。 对 于 贫 农 而 言 ， 工 具 上 的 短 缺 是 个 难 跨 的 坎 ， 部 分 地 区 水 利 工 程 的 缺 位 也 很 难 在 农 民 单 打 独 斗 的 现 状 下 得 到 解 决 。 而 通 过 农 民 再 合 作 化 运 动 与 建 立 大 型 农 场 ， 让 农 民 们 共 享 如 锄 头 这 一 类 的 生 产 资 料 ， 并 联 合 起 来 参 与 水 利 工 程 的 建 设 ， 我 们 就 能 为 我 国 的 农 业 生 产 插 上 翅 膀 。",
	" 实 施 新 式 耕 作 方 法 有 助 于 我 国 农 业 复 兴 。",
	" 拖 拉 机 、 收 割 机 与 其 他 各 类 机 器 是 现 代 农 业 的 支 柱 。 我 们 必 须 用 先 进 技 术 武 装 农 民 。",
	" 培 育 新 型 农 作 物 ， 并 推 动 对 基 因 的 进 一 步 研 究 。 将 利 于 我 国 农 业 与 医 学 事 业 的 进 步 。",
	" 基 因 研 究 的 最 新 成 就 为 我 们 提 供 了 大 有 作 为 的 可 能 。 我 们 必 须 深 入 研 究 ， 建 设 更 多 的 研 究 设 施。",
	" 农 业 化 学 的 最 新 成 果 可 以 促 进 作 物 提 产 增 质 ， 并 有 效 抵 抗 害 虫 。",
	" 引 入 转 基 因 技 术 将 帮 助 我 们 实 现 农 业 产 品 的 提 质 增 效 。",
	" 掌 握 了 在 贫 瘠 土 壤 上 耕 种 的 新 技 术 后 ， 我 们 的 农 业 产 量 必 将 节 节 攀 升 。",
	" 如 果 愿 意 做 调 查 ， 就 不 难 发 现 目 前 我 国 工 厂 的 流 水 线 仍 存 在 着 一 些 问 题 与 挑 战 ， 如 生 产 过 程 中 的 浪 费 、 效 率 低 下 、 产 品 质 量 差 等 等 。 若 不 想 让 落 后 的 制 造 业 继 续 拖 累 国 民 经 济 发 展 的 话 ， 改 良 流 水 线 生 产 模 式 是 必 须 走 的 一 步 。",
	" 长 期 以 来 ， 我 国 的 工 业 不 过 是 立 足 于 苏 联 技 术 与 进 口 机 械 的 二 手 货 。 如 果 我 们 要 实 现 自 力 更 生 ， 走 出 中 国 特 色 的 工 业 化 道 路 ， 就 有 必 要 结 束 这 种 依 附 性 。 ",
	" 当 我 们 实 现 工 业 设 备 的 中 国 化 ， 并 实 现 各 类 工 厂 的 现 代 化 后 。 我 们 终 于 可 以 彻 底 改 变 我 国 工 业 的 落 后 现 状 了 。 ",
	" 为 了 避 免 受 制 于 人 ， 被 外 国 人 卡 脖 子 ， 越 来 越 多 的 亚 洲 国 家 开 始 注 重 发 展 高 新 技 术 制 造 业 。 我 们 也 得 跟 上 步 伐 ， 发 展 我 们 民 族 的 电 子 工 业 。 ",
	" 通 过 使 用 最 新 的 工 业 机 械 与 建 筑 方 法 ， 我 们 将 最 终 建 立 一 套 行 之 有 效 的 建 设 系 统 。 ",
	" 我 们 已 经 几 乎 告 别 了 土 法 炼 钢 的 落 后 时 代 ， 但 我 国 产 业 仍 有 很 大 的 进 步 空 间 。 通 过 改 进 我 国 工 业 设 备 ， 我 们 将 显 著 提 升 工 业 水 平 。 ",
	" 引 入 自 动 化 技 术 将 帮 助 我 们 降 低 各 类 支 出 ， 并 摆 脱 官 僚 主 义 的 繁 文 缛 节 。 ",
	" 一 些 已 配 备 先 进 计 算 机 的 工 业 部 门 已 经 在 经 营 效 率 上 远 超 同 类 。 我 们 有 必 要 打 造 中 国 自 己 的 计 算 机 制 造 业 。 ",
	" 通 过 将 我 们 的 设 备 整 合 进 可 计 算 上 百 万 参 数 的 单 一 自 动 化 系 统 网 络 种 ， 我 们 将 真 正 建 立 起 属 于 未 来 的 经 济 。",
	" 我 们 必 须 大 力 发 展 我 国 兵 器 工 业 ， 不 能 再 照 搬 照 抄 苏 械 武 器 了 。 ",
	" 隐 秘 战 线 总 是 扮 演 举 足 轻 重 的 作 用 。 所 以 ， 我 们 有 必 要 保 证 我 们 的 情 报 部 门 配 备 现 代 的 电 子 社 会 ， 特 工 们 个 人 的 武 器 也 要 被 武 装 到 牙 齿 。 ",
	" 我 们 必 须 改 进 情 报 搜 集 与 执 行 特 种 任 务 的 方 法 ， 确 保 我 国 情 报 部 门 不 落 克 格 勃 与 中 情 局 的 下 风 。 ",
	" 尽 管 我 们 并 非 军 备 竞 赛 的 一 员 ， 我 们 必 须 坚 持 发 展 我 国 核 武 器 与 核 导 弹 以 保 证 国 防 安 全 。 ",
	" 随 着 新 型 信 息 技 术 的 发 展 ， 我 们 必 须 为 一 种 新 的 战 场 形 式 做 好 准 备 。 在 这 一 时 代 ， 信 息 将 成 为 决 定 战 争 成 败 的 胜 负 手 。 ",
	" 局 部 战 争 频 发 的 年 代 内 ， 质 量 显 然 优 于 数 量 。 我 们 需 要 给 我 国 军 队 配 备 最 新 的 电 子 设 备 与 武 器 系 统 。 ",
	" 我 们 的 陆 军 在 陆 地 上 鲜 有 敌 人 。 但 为 了 祖 国 的 安 定 ， 我 们 必 须 组 建 一 支 足 够 强 大 的 海 军 和 空 军 部 队 。 ",
	" 一 个 秘 密 的 军 工 网 络 将 为 我 们 的 特 工 与 总 部 提 供 最 先 进 的 设 备 ： 包 括 窃 听 器 、 摄 像 头 、 通 讯 设 备 与 武 器 。 ",
	" 根 据 时 代 实 施 军 区 改 革 ， 改 组 部 队 组 织 结 构 与 指 挥 链 ， 将 使 我 国 军 队 的 作 战 能 力 实 现 显 著 提 升 ， 指 战 员 的 命 令 也 将 更 快 传 达 给 基 层 将 士 们。",
	" 长 期 以 来 ， 西 方 国 家 一 直 在 使 用 轨 道 卫 星 作 为 中 继 器 ， 以 此 沟 通 各 地 ， 实 现 全 国 范 围 间 的 通 信 。 中 国 也 应 该 开 发 自 己 的 此 类 卫 星 技 术 ， 以 跟 上 世 界 的 步 伐 。  新 技 术 将 使 我 们 能 够 更 快 、 更 好 地 与 国 内 的 任 何 地 方 ， 以 及 与 我 们 在 世 界 上 任 意 地 方 的 船 只 进 行 通 信 。 最 后 ， 电 视 信 号 将 覆 盖 整 个 中 国 ！ 这 将 推 动 中 国 的 经 济 发 展 ， 并 大 大 促 进 我 国 经 济 、 生 活 水 平 和 人 民 信 心 的 提 升 。",
	" 我 们 的 科 学 家 和 工 程 师 提 出 了 一 个 概 念 ： 以 高 轨 道 上 的 几 颗 卫 星 为 基 础 ， 组 成 导 航 系 统 ， 以 实 现 对 地 球 表 面 的 导 航 。 通 过 计 算 几 颗 卫 星 的 距 离 ， 我 们 将 能 够 找 到 球 体 的 交 点 ， 也 就 是 定 位 点 。 这 项 技 术 将 允 许 中 国 实 现 更 好 的 导 航 ， 不 论 是 在 陆 地 ， 还 是 海 洋 ， 一 切 都 将 拨 云 见 日 。",
	" 不 幸 的 是 ， 大 部 分 对 中 国 领 土 对 弹 道 导 弹 攻 击 的 防 御 效 果 很 差 。 而 建 立 地 面 导 弹 防 御 系 统 并 不 容 易 ， 尤 其 是 在 山 区 。 但 我 们 可 以 在 轨 道 上 建 造 卫 星 ， 让 携 带 由 核 反 应 堆 驱 动 的 强 大 激 光 器 保 障 我 国 的 安 全 。 这 项 技 术 将 使 我 们 能 够 击 落 所 有 飞 向 我 们 的 导 弹 ， 并 通 过 激 光 照 射 使 敌 人 的 卫 星 失 去 作 用 。",
	" 苏 联 和 美 国 将 人 送 入 太 空 已 经 是 1 5 年 多 以 前 的 事 了 。 最 初 的 技 术 并 不 复 杂 — — 基 本 上 是 一 个 有 厚 壁 的 密 封 飞 行 器 和 一 个 自 动 降 落 还 有 导 航 系 统 。 我 们 已 经 有 重 返 大 气 层 的 飞 行 器 ， 所 以 我 们 已 经 为 这 类 项 目 做 好 了 部 分 准 备 。 但 是 如 果 我 们 行 动 不 够 果 断 ， 那 我 们 将 会 成 为 第 四 ， 而 非 第 三 个 将 人 送 入 太 空 的 国 家 。",
	" 许 多 年 来 ， 苏 联 与 美 国 一 直 向 其 他 的 星 球 发 射 自 己 的 探 测 器 。 第 一 款 成 功 落 地 的 探 测 器 位 于 金 星 ， 而 第 一 款 可 以 成 功 返 航 的 探 测 器 则 在 月 球 立 威 ...... 尽 管 在 目 前 ， 中 国 并 不 会 有 这 样 的 头 条 新 闻 。 但 没 有 什 么 能 能 阻 止 我 们 开 始 探 索 太 阳 系 其 他 天 体 的 计 划 。 不 过 ， 在 我 国 第 一 艘 航 天 器 并 没 有 多 少 科 学 有 效 载 荷 的 情 况 下 ， 我 们 仍 要 努 力 。",
	" 中 国 宇 航 员 以 前 曾 进 入 太 空 轨 道 ， 但 从 未 能 在 那 里 站 稳 脚 跟 。 尽 管 如 此 ， 在 一 个 几 乎 不 能 伸 展 完 全 的 小 太 空 船 里 ， 要 实 现 这 一 目 标 是 很 困 难 的 。 我 们 需 要 空 间 站 ， 在 那 里 乘 员 可 以 定 期 固 定 下 来 ， 进 行 多 种 科 学 研 究 。 并 还 要 与 其 他 国 家 进 行 联 合 考 察 。",
	" 目 前 航 天 器 的 主 要 缺 点 是 ， 它 们 是 一 次 性 的 ， 并 且 是 以 极 其 危 险 的 方 式 返 回 的 。 我 们 早 已 完 善 了 滑 翔 机 着 陆 技 术 ， 那 么 为 什 么 不 把 它 应 用 于 航 天 器 呢 ？ 这 将 使 发 射 更 多 的 载 人 任 务 成 为 可 能 ， 并 大 大 增 加 向 我 们 的 空 间 站 运 送 货 物 的 频 率 。 更 不 用 说 ， 这 将 使 我 们 有 可 能 从 轨 道 上 返 回 卫 星 进 行 维 修 ， 或 偷 窃 敌 人 的 卫 星 。",
]

# 悬停提示：影响Buff（原版 other_text[390+编号]，出处 other_text_en.txt 391-424 行）
const TECH_EFFECTS: Array[String] = [
	"影 响: <color=#006400>生 活 水 平+0.2, 农 业+0.1</color>",
	"影 响: <color=#006400>农 业+0.2</color>",
	"影 响: <color=#006400>生 活 水 平+0.1, 农 业+0.1, 财 政 预 算+0.1</color>",
	"影 响: <color=#006400>生 活 水 平+0.2, 农 业+0.1</color>",
	"影 响: <color=#006400>生 活 水 平+0.4, 农 业+0.5</color>",
	"影 响: <color=#006400>生 活 水 平+0.2, 科 学 点 数+1.0</color>",
	"影 响: <color=#006400>生 活 水 平+0.2, 农 业+0.1</color>",
	"影 响: <color=#006400>生 活 水 平+0.2, 财 政 预 算+0.1</color>",
	"影 响: <color=#006400>农 业+0.2</color>",
	"影 响: <color=#006400>财 政 预 算+0.1, 工 业+0.2</color>",
	"影 响: <color=#006400>财 政 预 算+0.1, 工 业+0.2, 军 事 实 力+0.4</color>, <color=red>移 除 “ 低 效 的 工 业 ” 修 正</color>",
	"影 响: <color=#006400>生 活 水 平+0.2</color>",
	"影 响: <color=#006400>财 政 预 算+0.2, 工 业+0.1</color>",
	"影 响: <color=#006400>生 活 水 平+0.3</color>",
	"影 响: <color=#006400>生 活 水 平+0.2, 财 政 预 算+0.1, 工 业+0.2</color>",
	"影 响: <color=#006400>生 活 水 平+0.2, 财 政 预 算+0.1, 工 业+0.1, 农 业+0.1</color>",
	"影 响: <color=#006400>生 活 水 平+0.3, 财 政 预 算+0.2, 科 学 点 数+0.5, 国 内 团 结 度+0.4</color>",
	"影 响: <color=#006400>生 活 水 平+0.3, 财 政 预 算+0.3</color>",
	"影 响: <color=#006400>军 事 实 力+0.2</color>",
	"影 响: <color=#006400>特 工 网 络+0.3, 思 想 自 由 化-0.3</color>",
	"影 响: <color=#006400>特 工 网 络+0.2, 思 想 自 由 化-0.2, 人 民 支 持 度+0.2</color>",
	"影 响: <color=#006400>军 事 实 力+0.2, 党 内 支 持 度+0.3, 人 民 支 持 度+0.3</color>",
	"影 响: <color=#006400>人 民 支 持 度+0.3, 思 想 自 由 化-0.2, 党 内 支 持 度+0.2</color>",
	"影 响: <color=#006400>军 事 实 力+0.4</color>",
	"影 响: <color=#006400>军 事 实 力+0.4, 人 民 支 持 度+0.2</color>",
	"影 响: <color=#006400>特 工 网 络+0.2, 思 想 自 由 化-0.2, 党 内 支 持 度+0.3</color>",
	"影 响: <color=#006400>军 事 实 力+0.4, 思 想 自 由 化-0.2</color>",
	"影 响: <color=#006400>财 政 预 算+0.2, 生 活 水 平+0.2, 人 民 支 持 度+0.2</color>",
	"影 响: <color=#006400>军 事 实 力+0.5, 特 工 网 络+0.5</color>",
	"影 响: <color=#006400>军 事 实 力+1.0, </color><color=red>与 美 苏 的 关 系-0.5</color>",
	"影 响: <color=#006400>人 民 支 持 度+0.3, 美 苏 全 球 影 响 力-0.1</color>",
	"影 响: <color=#006400>军 事 实 力+0.5, 科 学 点 数+0.5</color>",
	"影 响: <color=#006400>农 业+0.5, 生 活 水 平+0.5</color>",
	"影 响: <color=#006400>军 事 实 力+0.5, 工 业+0.5, </color><color=red>与 美 苏 的 关 系-0.5</color>",
]

# 悬停提示：modifies[51] 激活时的额外石油消耗行（原版 other_text[433+编号]）
# 注：modifies[51] 尚建模说明（world_factory.gd:1445），恒不显示；保留映射便于日后补。
const TECH_OIL_LINES: Dictionary = {
	2: "<color=red>石 油 消 费 +35</color>",
	3: "<color=red>石 油 消 费 +30</color>",
	6: "<color=red>石 油 消 费 +20</color>",
	7: "<color=red>石 油 消 费 +40</color>",
	8: "<color=red>石 油 消 费 +25</color>",
	10: "<color=#006400>石 油 消 费 -20</color>",
	11: "<color=#006400>石 油 消 费 -35</color>",
	13: "<color=#006400>石 油 消 费 -60</color>",
	14: "<color=#006400>石 油 消 费 -60</color>",
}

# 鼠标滚轮滚动参数
const SCROLL_STEP := 80.0    # 每次滚动移动的像素距离
const CAMERA_Y_MIN := 540.0  # 摄像机Y轴上限（最上方）
const CAMERA_Y_MAX := 2400.0 # 摄像机Y轴下限（最下方）

var _tex_yes: Texture2D       # "可研究"状态图标
var _tex_no: Texture2D        # "不可研究"状态图标
var _camera: Camera2D          # 用于上下滚动界面的摄像机
var _refresh_counter: int = 0  # 帧计数器，每10帧刷新一次UI
var _hover_index: int = -1     # 当前悬停的科技编号，-1=无


func _ready() -> void:
	_tex_yes = preload("res://资产/UI/科研/是否可科研状态_是.png")
	_tex_no = preload("res://资产/UI/科研/是否可科研状态_否.png")
	_camera = _find("移动视角摄像机") as Camera2D
	if GameManager:
		UISettings.apply_font_scale(self, GameManager.ui_font_scale)

	# 将所有 Control 节点设为鼠标穿透，避免遮挡按钮点击
	_make_mouse_transparent(self)

	# 为每个科技条目绑定点击回调，将科技索引作为参数传入
	# （2026-08 条目已组件化：科技名 = 科技条目.tscn 实例根，按钮/图标/进度/年份为其子节点）
	for i in TECH_UI_COUNT:
		var entry := find_child(TECH_NAMES[i], true, false) as Control
		if entry == null:
			continue
		var btn := entry.get_node_or_null("按钮") as TextureButton
		if btn:
			btn.mouse_filter = Control.MOUSE_FILTER_STOP  # 按钮自身保留鼠标事件
			btn.pressed.connect(_on_tech_pressed.bind(i))
			# 原版 Science_Script.OnMouseEnter/OnMouseExit：悬停显示 Plashka 提示板
			btn.mouse_entered.connect(_on_tech_hover.bind(i))
			btn.mouse_exited.connect(_on_tech_hover_end)

	_refresh()


## 递归地将所有非按钮 Control 设为 MOUSE_FILTER_IGNORE（鼠标穿透），
## 只保留 TextureButton 可点击。CanvasLayer 不是 Control 的子类，跳过。
func _make_mouse_transparent(node: Node) -> void:
	if node is CanvasLayer:
		return
	if node is TextureButton:
		return
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_make_mouse_transparent(child)


## 刷新整个科研界面：顶部预算/科研点数值 + 每项科技的进度条、状态图标、年份标签
func _refresh() -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	var ts := w.techs
	if ts == null:
		return

	var budget := _raw(w, W.I_BUDGET)
	var science := _raw(w, W.I_SCIENCE)

	# 预算内部以×10存储，显示时除以10还原为实际值
	_label("预算数值", "%.1f" % (float(budget) / 10.0))
	_label("科研点数数值", str(science))

	for i in TECH_UI_COUNT:
		var tech_name := TECH_NAMES[i]
		var entry := _find(tech_name) as Control
		if entry == null:
			continue

		# --- 进度条：显示剩余研究时间 ---
		var bar := entry.get_node_or_null("科研进度") as ProgressBar
		if bar:
			if ts.in_progress[i]:
				# 正在研究：显示剩余时间（总时间 - 已用时间）
				bar.visible = true
				var req := maxi(ts.required_time[i], 1)
				bar.max_value = req
				bar.value = req - ts.elapsed_time[i]
			elif ts.unlocked[i]:
				# 已完成：进度条清空（value=0）表示已研究完毕
				bar.visible = true
				bar.max_value = 1
				bar.value = 0
			else:
				# 未开始：进度条填满（value=1）表示尚未开始
				bar.visible = true
				bar.max_value = 1
				bar.value = 1

		# --- 状态图标：原版 Repaint() 只按“前置依赖”判定（Science_Script.cs:53-61），
		#     不检查年份/预算/科研点；超前年份会在悬停提示里显示惩罚，而不是红叉。
		var icon := entry.get_node_or_null("是否可科研状态") as TextureRect
		if icon:
			if ts.unlocked[i]:
				icon.visible = false             # 已完成，不显示图标
			else:
				icon.visible = true
				var dep: int = ts.TECH_DEPENDENCY[i] if i < ts.TECH_DEPENDENCY.size() else -1
				if dep == -1 or (dep < ts.unlocked.size() and ts.unlocked[dep]):
					icon.texture = _tex_yes      # 前置满足（或无需前置）
				else:
					icon.texture = _tex_no       # 前置未完成

		# --- 年份标签：显示解锁年份或当前研究状态 ---
		var lbl := entry.get_node_or_null("解锁年份") as Label
		if lbl:
			# 年份/研究中/已完成统一水平居中，配合科研.tscn 中 130 宽的年份标签。
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			if ts.unlocked[i]:
				lbl.text = "已完成"
			elif ts.in_progress[i]:
				lbl.text = "研究中"
			else:
				lbl.text = str(UNLOCK_YEARS[i])  # 显示最早可研究年份

	# 悬停提示若正显示，随 10 帧刷新同步“科研点进度/研究中”等动态数字
	if _hover_index >= 0:
		_update_tooltip()


## 悬停进入：记录悬停目标并刷新提示板（原版 OnMouseEnter）
func _on_tech_hover(tech_index: int) -> void:
	_hover_index = tech_index
	_update_tooltip()


## 悬停离开：隐藏提示板（原版 OnMouseExit）
func _on_tech_hover_end() -> void:
	_hover_index = -1
	_set_tooltip_visible(false)


## 提示板四个节点是 CanvasLayer 下的兄弟节点，统一开关避免只藏底板露文字。
func _set_tooltip_visible(vis: bool) -> void:
	for node_name in ["科研提示板", "提示标题", "提示状态", "提示描述"]:
		var node := _find(node_name)
		if node is Control:
			node.visible = vis


## 刷新悬停提示板：T1=科技名，T2=花费+状态，T3=介绍+影响Buff
## 状态优先级严格按原版 Science_Script.RepaintPlashka（:107-144）。
func _update_tooltip() -> void:
	if _hover_index < 0 or _hover_index >= TECH_UI_COUNT:
		return
	var w: WorldState = GameManager.world
	if w == null or w.techs == null:
		return
	var ts := w.techs
	var i := _hover_index
	if i >= ts.unlocked.size():
		return

	_set_tooltip_visible(true)
	_label("提示标题", TECH_NAMES[i])
	_label("提示状态", _tooltip_status(ts, i).replace(" ", ""))
	_label("提示描述", _tooltip_desc(w, ts, i))


## T2：花费 + 状态（原版 RepaintPlashka 的 T2.text 分支顺序）
func _tooltip_status(ts: TechState, i: int) -> String:
	var money: int = ts.TECH_MONEY[i] if i < ts.TECH_MONEY.size() else 3
	var days: int = ts.TECH_DAYS[i] if i < ts.TECH_DAYS.size() else 300
	var elapsed: int = ts.elapsed_time[i] if i < ts.elapsed_time.size() else 0
	var money_s: String = "%.1f" % (float(money) / 10.0)
	var s: String

	if ts.unlocked[i]:
		s = "[color=red]%s[/color] 资金 | [color=#006400] 研究完成 [/color]" % money_s
	elif ts.in_progress[i]:
		s = "[color=red]%s[/color] 资金 | [color=blue]%d[/color]/%d 科研点 | [color=#006400] 研究中... [/color]" % [money_s, elapsed, days]
	elif ts.is_researching():
		s = "[color=red]%s[/color] 资金 | [color=blue]%d[/color]/%d 科研点 | [color=red] 只能研究单个项目 [/color]" % [money_s, elapsed, days]
	else:
		# 原版对 17 号（中国版OGAS）有 data.automation_progress==0 的“尚未宣告建设全面自动化”门，
		# 由 Event110 写入 data.automation_progress=1 后解锁；Event110 尚移植说明，本端口保持可研究，不显示该门。
		var dep: int = ts.TECH_DEPENDENCY[i] if i < ts.TECH_DEPENDENCY.size() else -1
		if dep != -1 and (dep >= ts.unlocked.size() or not ts.unlocked[dep]):
			s = "[color=red]%s[/color] 资金 | [color=blue]%d[/color]/%d 科研点 | [color=red] 不可研究 [/color]" % [money_s, elapsed, days]
		else:
			var w: WorldState = GameManager.world
			var req_year: int = ts.TECH_YEAR[i] if i < ts.TECH_YEAR.size() else 1976
			var year: int = w.date.year if w.date else 1976
			if year >= req_year:
				s = "[color=red]%s[/color] 资金 | [color=blue]%d[/color]/%d 科研点 | [color=red] 可研究 [/color]" % [money_s, elapsed, days]
			else:
				# 原版超前惩罚（Science_Script.cs:139）：days*(data-year) - month*(days/12)
				var month: int = w.date.month if w.date else 1
				@warning_ignore("integer_division")
				var penalty: int = days * (req_year - year) - month * (days / 12)
				s = "[color=red]%s[/color] 资金 | [color=blue]%d[/color]/%d 科研点 | [color=red] 超前惩罚：+%d 科研点 [/color]" % [money_s, elapsed, days, penalty]
	return "[center]" + s + "[/center]"


## T3：介绍文案 + 影响Buff（原版 RepaintPlashka 的 T3.text）
## 原版 modifies[51] 激活时追加“石油消费”行；该修正尚建模说明（world_factory.gd:1445），
## 保留检查点，恒为 false。
func _tooltip_desc(w: WorldState, _ts: TechState, i: int) -> String:
	var text: String = TECH_DESC[i] if i < TECH_DESC.size() else ""
	if i < TECH_EFFECTS.size():
		text += "\n" + TECH_EFFECTS[i]
	if w.modifiers.size() > 51 and w.modifiers[51] != null and w.modifiers[51].is_active \
			and TECH_OIL_LINES.has(i):
		text += ", " + TECH_OIL_LINES[i]
	# Unity <color=> → Godot [color=]；按项目提示板惯例去掉空格（bbc_tooltip.gd）
	return BBC.unity_color_to_bbcode(text).replace(" ", "")


## 科技按钮点击回调：消耗科研点和预算，启动研究
func _on_tech_pressed(tech_index: int) -> void:
	var w: WorldState = GameManager.world
	if w == null or w.techs == null:
		return
	var ts := w.techs

	# 已解锁或不满足前置/占用条件则忽略点击（原版不检查年份与资源）
	if ts.unlocked[tech_index] or not ts.can_start(tech_index):
		return

	var d := w
	# start_research 返回花费的预算金额；年份超前时内部施加原版超前惩罚
	var money_cost: int = ts.start_research(tech_index, d.science, w.date.year, w.date.month)
	if money_cost > 0:
		GameManager.apply_research_cost(money_cost)
		GameManager.notify_stats_changed()
	_refresh()


## "返回"按钮：切换回外交界面
func _on_返回外交_pressed() -> void:
	get_tree().change_scene_to_file("uid://vq6jexkk5tru")


## 每10帧刷新一次UI，避免每帧都遍历34项科技的开销
func _process(_delta: float) -> void:
	_refresh_counter += 1
	if _refresh_counter >= 10:
		_refresh_counter = 0
		_refresh()


## 鼠标滚轮滚动：上下移动摄像机实现界面纵向滚动
func _unhandled_input(event: InputEvent) -> void:
	if _camera == null:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_camera.position.y = maxf(_camera.position.y - SCROLL_STEP, CAMERA_Y_MIN)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_camera.position.y = minf(_camera.position.y + SCROLL_STEP, CAMERA_Y_MAX)
			get_viewport().set_input_as_handled()
