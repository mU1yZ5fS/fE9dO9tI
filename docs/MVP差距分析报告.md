# MVP 差距分析报告

> 生成日期: 2026-07-14
> 原版数据源: F:\毛的遗产改版逆向工程测试\HR\Assets\Scripts (428 个 C# 文件)
> Godot 项目: f:\work\中国-毛的遗产[dh-4591] (52 个 GDScript + 17 场景 + 23 事件)

---

## 一、总体进度

| 指标 | 原版 | 当前 Godot | 覆盖率 |
|------|------|-----------|--------|
| 核心模拟 (TimeScript.cs) | 9,278 行 | 649 行 | ~15% |
| 事件内容 | 184 个编号事件 | 23 个 .tres | 12.5% |
| 结局 | 43 个结局脚本 | 空桩 | 0% |
| 决策 | 38 个决策定义 | 空桩 | 0% |
| 战争系统 | 7+ 文件 | 仅数据模型 | 5% |
| 超级大国 AI | 10+ 文件 | 仅数据模型 | 5% |
| UI 场景 | 17 个功能界面 | 10 个可用 | 59% |

**整体 MVP 完成度估算: ~20%**

---

## 二、已完成系统 (DONE)

### 2.1 项目基础架构
- Godot 4.7 项目配置 (1920x1080, Mobile 渲染, Jolt 物理)
- 3 个 Autoload: GameManager / EventEngine / 音频总管
- Resource 树式存档系统 (ResourceSaver/Loader 一行存读)

### 2.2 数据层
- WorldState: 200 槽数值表 + 40 个语义常量 (`I_BUDGET`, `I_ARMY` 等)
- WorldFactory: 99 国 / 18 政治家 / 5 派系 / 250 修正槽 / 科技 / 超级大国，全部内嵌
- CountryData: 19 字段完整解码 + gwcode 标准化 (84/99 匹配地图)
- EconomyData: 数值表的只读显示视图
- GameDate: 日期推进与格式化

### 2.3 事件系统框架
- ExprNode: 17 种条件原子 + AND/OR/NOT 组合 (P 社级别表达力)
- EffectNode: 18 种效果类型 + CUSTOM_SCRIPT 扩展
- EventEngine: MTTH 延迟 / 即时触发 / pending 通知 / 事件链 / 文本库
- EventFactory: 流畅构建器 DSL
- **23 个事件已迁移为 .tres 数据** (Event1-23 + Event120/121/300)

### 2.4 月度/年度模拟
- 11 项预算月度效果 (军费/国安/科研/行政/福利/宣传/农业/工业/服务/外交/信封)
- 月度收入/支出/赤字储备吸收/赤字党支持惩罚
- 政治体制自动重算
- 半年度: 生活水平漂移 / 派系支持漂移 / 兵源重算 / 经济体制效果
- 年度: 人口增长(按生育政策) / 派系席位衰减 / 满意度衰减
- 数值边界保护 (clamp_values)

### 2.5 3D 地球渲染
- GPU 调色板渲染: 8K/16K 区域编码位图 + 256x256 调色板纹理 (O(1) per region)
- 4 种地图着色模式 (政体/影响力/军事联盟/经济联盟)
- 轨道摄像机 (Google Earth 风格)
- 星空渲染 shader + 昼夜分界线
- 东方红卫星装饰 (开普勒轨道)

### 2.6 UI 界面
- 主菜单 (开始/加载/设置/关于/退出)
- 外交主界面 (3D 地球 + 状态栏 + 时间控制 + ESC 菜单 + 事件通知)
- 经济界面 (11 项预算 +/- 调整 + 贷款 + 储蓄金 + 概览)
- 派系界面 (6 政策类别 + 5 派系支持/禁止 + 饼图 + 生育政策)
- 事件界面 (INTRO → OPTIONS → RESULT 三页状态机)
- 科研界面 (34 项科技树)
- 保存/加载/设置/关于
- 音频系统 (12 专辑点唱机 + 音效)

### 2.7 数据写入架构 (本次重构完成)
- GameManager 为唯一写入者，7 个 API: adjust_budget/loan/reserve, change_policy, set_birth_policy, set_faction_ally/enabled
- UI 只读 + 调用 API
- GameUIBase 基类: 节点缓存查找 + 共享工具方法

---

## 三、部分完成系统 (PARTIAL)

### 3.1 月度模拟 — 缺失部分 (~85% 未移植)
TimeScript.cs 共 9,278 行，当前只移植了约 1,400 行。缺失:

| 函数 | 行数 | 说明 |
|------|------|------|
| MutualRelationsChange() | 106 行 | 美苏中三角关系漂移 |
| EventsRequirements() | 850+ 行 | 事件触发条件检查 (大量硬编码) |
| WorldWarsDone() | 236 行 | 战争结算 (半月 tick) |
| WorldWarsInfluenceChanges() | 1,135 行 | 战时影响力变化 |
| DirectWars() | 200+ 行 | 中苏边境战争模拟 |
| AfricanBotSupport() | 234 行 | 非洲国家 AI (逐国稳定性/影响力漂移) |
| AfricanCoups() | 94 行 | 非洲政变模拟 |
| DaysInSouthAmerica() | 100+ 行 | 南美政治动态 |
| EmpireModifiesChanges() | 200+ 行 | 超级大国修正效果 |
| FocusesResearching() | 100+ 行 | 焦点树执行 |
| FocusesAIMethod() | 100+ 行 | AI 焦点选择 |
| PlotPlayer/PlotPolitics() | 200+ 行 | 政变/阴谋/密谋 |
| DeathPolitics() | 100+ 行 | 政治家死亡 (年龄/暗杀) |
| Reelect() | 50+ 行 | 选举触发 |
| BoundsOfVariables() | 80 行 | 完整的数值 clamp |

### 3.2 外交界面 — 缺失外交动作
- 有: 3D 地球 + 国家面板信息显示 + 4 种地图模式
- 缺: 外交行动按钮 (援助/贸易/影响力操作/情报行动)
- 缺: 按超级大国区分的外交选项 (SovietDiplo.cs / FrenchDiplo.cs)

### 3.3 存档系统
- 有: ResourceSaver/Loader 基本存读
- 缺: 自动存档 / 铁人模式 / 存档列表 UI / 存档元数据

---

## 四、未实现系统 (MISSING)

### 4.1 [P0] 事件内容 — 161 个事件未迁移
原版 184 个编号事件 (Event120~Event456)，当前仅 23 个。
**这是 MVP 最大的内容缺口。** 事件框架已完备，缺的纯粹是数据迁移工作。

### 4.2 [P0] 结局系统 — 43 个结局
原版 Ending1.cs~Ending43.cs 定义了 43 种结局场景，涵盖:
- 好结局/坏结局分支
- 国家特定结局 (东方赛博朋克、一脚踏入共产主义 等)
- 基于 data[] 数组的复杂判定条件
当前仅有空桩场景。

### 4.3 [P1] 战争系统
原版文件: War.cs (建造者模式) / WarManager.cs / Wars.cs (预定义战争) / warinwars.cs
- 战争创建 (攻防双方/影响力/半月 tick/超级大国支持)
- 战争结算 (WorldWarsDone)
- 中苏边境冲突 (DirectWars)
- 阿富汗战争等预定义冲突
- 战争列表 UI
当前仅有 war_data.gd 数据模型 (33 行)。

### 4.4 [P1] 决策系统 — 38 个决策
GlobalScript.cs 定义了 38 个决策 (西藏自治/新疆/文化革命/OGAS 计算机网络/寡头/蒙古合并/加入 SEATO/非洲行动/石油 等)，每个有复杂的条件链和效果。
当前 decision_state.gd 仅有追踪数组，无决策定义。

### 4.5 [P1] 超级大国 AI
- USSR 焦点树: USSRFocuses.cs 定义了 9 层 ~20 个焦点，带复杂条件
- 领袖更替: 勃列日涅夫→安德罗波夫→契尔年科→戈尔巴乔夫
- USA 领袖: 福特→卡特→里根→布什
- 外交 AI: SovietDiplo.cs (8+ 种按国家类型的外交行动)
当前仅有静态数据模型。

### 4.6 [P1] 政治密谋与选举
- 阴谋 (PlotPlayer): 高级官员密谋推翻玩家
- 政治家死亡 (DeathPolitics): 年龄/暗杀触发
- 选举 (Reelect/ElectScript): 党制度 >7 时触发选举事件

### 4.7 [P2] 国家 AI (非洲/南美)
- AfricanBotSupport: 逐国稳定性漂移、影响力变化、阵营转换
- AfricanCoups: 政变模拟
- DaysInSouthAmerica: 拉美政治动态

### 4.8 [P2] 焦点树系统
Focus.cs / FocusTree.cs / FocusManager.cs — 层级式焦点树 (类似 HOI4)
当前无任何实现。

### 4.9 [P3] 非 MVP 内容
- DLC 内容 (9 个 DLC): 合作多人/公民系统/特殊事件
- 成就系统 (60+ Steam 成就)
- 合作多人 (5 玩家派系控制)
- Mod 支持 (MoonSharp 脚本引擎)

---

## 五、MVP 路线图建议

### 第一阶段: 核心循环可玩 (当前 → 可游玩)
1. **批量迁移事件** — 184 个事件中优先迁移触发条件最简单的 50 个
2. **完善月度模拟** — 移植 MutualRelationsChange + BoundsOfVariables + EventsRequirements
3. **实现选举触发** — ElectScript 逻辑简单，与已有事件系统对接
4. **实现政治家死亡** — DeathPolitics，影响游戏进程的关键机制

### 第二阶段: 核心系统完整
5. **战争系统** — War 建造者 + 预定义战争 + WorldWarsDone 结算
6. **决策系统** — 38 个决策定义 + 决策 UI
7. **结局系统** — 43 个结局判定 + 结局展示
8. **超级大国 AI** — USSR 焦点树 + 领袖更替 + 外交 AI

### 第三阶段: 世界模拟丰满
9. **国家 AI** — 非洲/南美政治动态
10. **外交动作** — 援助/贸易/影响力操作 UI
11. **焦点树 UI** — 层级式焦点选择界面
12. **剩余事件** — 迁移全部 184 个事件

---

## 六、关键参考文件

| 原版文件 | 行数 | 对应 Godot | 说明 |
|---------|------|-----------|------|
| TimeScript.cs | 9,278 | game_manager.gd (649) | 核心模拟，移植了 ~15% |
| GameState.cs | 3,593 | world_state.gd (300) | 数据模型，已重构 |
| GlobalScript.cs | 266 | — | 38 个决策定义，未移植 |
| EndingScript.cs | ~500 | 结局.gd (空桩) | 结局评估，未移植 |
| USSRFocuses.cs | ~300 | — | USSR 焦点树，未移植 |
| Event120~456 (×184) | ~15,000 | event_factory.gd (×23) | 事件内容，12.5% |
| War.cs + Wars.cs | ~400 | war_data.gd (33) | 战争系统，仅数据模型 |
| Decision.cs | ~200 | decision_state.gd (41) | 决策系统，仅追踪 |
| Country.cs | ~300 | country_data.gd (200) | 国家模型，基本完成 |
