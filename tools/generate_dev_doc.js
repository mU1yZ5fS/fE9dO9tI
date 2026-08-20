const fs = require('fs');
const path = require('path');

const root = process.cwd();
let md = '';

// ============ Header ============
md += `# 开发帮助文档 — 中国:毛的遗产[Godot重制版]

> 本文件面向调试与开发，汇总当前项目的主要状态字段、常量、枚举、条件/效果节点、全局标记与调试入口。
> 最后生成时间：${new Date().toISOString().slice(0,10)}

## 目录
1. [项目结构速览](#1-项目结构速览)
2. [WorldState 状态字段](#2-worldstate-状态字段)
3. [GameConstants 常量与枚举](#3-gameconstants-常量与枚举)
4. [WorldState 索引常量 I_*](#4-worldstate-索引常量-i)
5. [事件 DSL：ExprNode 条件类型](#5-事件-dslexprnode-条件类型)
6. [事件 DSL：EffectNode 效果类型](#6-事件-dsleffectnode-效果类型)
7. [派系常量](#7-派系常量)
8. [全局标记 global_flags](#8-全局标记-global_flags)
9. [GameManager 常用命令方法](#9-gamemanager-常用命令方法)
10. [调试与开发入口](#10-调试与开发入口)

---

## 1. 项目结构速览

| 路径 | 作用 |
|---|---|
| \`数据脚本/world_state.gd\` | 存档根状态，所有玩家数值/领域对象的权威源 |
| \`数据脚本/core/常量表.gd\` | GameConstants 全局枚举/常量 |
| \`数据脚本/core/*.gd\` | 领域模型：CountryData、WarData、PoliticianData、FactionData、TechState、DecisionState 等 |
| \`数据脚本/systems/\` | 系统逻辑：EventEngine、WarSystem、PoliticianSystem、DecisionSystem 等 |
| \`数据脚本/services/\` | 服务：EconomyService、FortnightSimulator、PolicyService、SaveService、GameService |
| \`数据脚本/factory/\` | 世界/事件/存档构建 |
| \`数据脚本/事件效果/\` | 事件自定义脚本（CUSTOM_SCRIPT） |
| \`场景/\` | 各 UI 场景 |
| \`资产/数据/\` | 事件/战争/修正等 .tres 与 JSON |

---

## 2. WorldState 状态字段

### 2.1 玩家数值表字段（原 data[0..186]，已具名化）

| 原索引 | 字段名 | 类型 | 说明 |
|---|---|---|---|
`;

// Read mapping
const mapping = JSON.parse(fs.readFileSync(path.join(root, 'tools', 'numeric_table_mapping.json'), 'utf8'));
for (let i = 0; i <= 186; i++) {
  const e = mapping[String(i)];
  if (!e) continue;
  const type = e.type === 'bool' ? 'bool' : 'int';
  md += `| ${i} | \`${e.name}\` | ${type} | ${e.comment} |\n`;
}

// 2.2 Other WorldState exported fields
md += `
### 2.2 其他 WorldState 字段（非数值表）

| 字段 | 类型 | 说明 |
|---|---|---|
| \`date\` | GameDate | 当前日期 |
| \`countries\` | Array[CountryData] | 全部国家 |
| \`politicians\` | Array[PoliticianData] | 全部政治家 |
| \`leader\` | PoliticianData | 当前实权领袖 |
| \`leader_politician_index\` | int | 实权领袖对应 politicians 槽 |
| \`politician_reserve\` | Array[PoliticianData] | 预备政治家池 |
| \`factions\` | Array[FactionData] | 5 个派系 |
| \`empires\` | Array[EmpireData] | 美苏两个超级大国 |
| \`wars\` | Array[WarData] | 战争槽 |
| \`modifiers\` | Array[ModifierSlot] | 修正槽 |
| \`war_state\` | int | 当前战争状态，见 GameConstants.WarState |
| \`techs\` | TechState | 科技状态 |
| \`decisions\` | DecisionState | 决议状态 |
| \`player_country_gwcode\` | int | 玩家国家 G&W 编码，默认 710 |
| \`difficulty\` | int | 难度 0-3 |
| \`is_ironman\` | bool | 铁人模式 |
| \`dlc\` | Array[bool] | DLC 开关 |
| \`desnull\` | Array[int] | 原版决议计时器 |
| \`oil_prod / oil_eat\` | float | 石油生产/消耗 |
| \`army_power\` | int | 军队总力量 |
| \`new_politician\` | Array[bool] | 新政治家开关 |
| \`anthem_cooldown_time\` | int | 国歌冷却 |
| \`ind_opp / oar / serve_rmb\` | bool | 特殊全局标志 |
| \`leader_property\` | Array[bool] | 领导人属性 |
| \`global_flags\` | Dictionary | 全局标记 |
| \`map_owner_overrides\` | Dictionary | 地图归属覆盖 |
| \`event_done_overrides\` | Dictionary | 事件完成覆盖 |
| \`result_of_event_overrides\` | Dictionary | 事件结果覆盖 |
| \`completed_event_ids\` | Dictionary | 已完成事件 |
| \`event_pending_id\` | String | 待处理事件 |
| \`event_pending_deadline\` | int | 待处理截止 |
| \`event_chain_queue\` | Array[String] | 事件链队列 |
| \`event_pending_queue\` | Array[String] | 事件通知队列 |
| \`politics_positions\` | Array[int] | 8 个政治职位槽 |
| \`上期变化\` | Array[int] | 双周变化（经济悬浮提示） |
| \`上期关系变化\` | Array[int] | 双周关系变化 |
| \`上期影响变化\` | int | 双周影响力变化 |
| \`influence_prc\` | int | 中国全球影响力累计 |
| \`war_active\` | Array[bool] | 西欧/东欧极左冷却 |
| \`玩家经济\` | EconomyData | 经济显示视图 |
| \`rng_seed / rng_state\` | int | 随机数种子/状态 |
`;

// ============ GameConstants ============
md += `
---

## 3. GameConstants 常量与枚举

### 3.1 Region / GwCode / LegacySlot

| 常量 | 值 | 说明 |
|---|---|---|
| \`Region.ARUNACHAL\` | 43 | 藏南 |
| \`Region.FALKLAND\` | 3030 | 马岛 |
| \`Region.BRUNEI\` | 587 | 文莱 |
| \`GwCode.CHINA\` | 710 | 中国 |
| \`GwCode.TAIWAN\` | 713 | 台湾 |
| \`GwCode.ARGENTINA\` | 160 | 阿根廷 |
| \`GwCode.MALAYSIA\` | 820 | 马来西亚 |
| \`GwCode.FRANCE\` | 220 | 法国 |
| \`GwCode.UK\` | 200 | 英国 |
| \`GwCode.USA\` | 2 | 美国 |
| \`LegacySlot.NONE\` | -1 | 无 |
| \`LegacySlot.CHINA\` | 1 | 中国原版序号 |
| \`LegacySlot.IRAQ\` | 14 | 伊拉克 |
| \`LegacySlot.FRANCE\` | 21 | 法国 |
| \`LegacySlot.TAIWAN\` | 38 | 台湾 |
| \`LegacySlot.SPAIN\` | 85 | 西班牙 |
| \`LegacySlot.SOUTH_AFRICA\` | 131 | 南非 |
| \`LegacySlot.AUSTRALIA\` | 135 | 澳大利亚 |

### 3.2 WarState（WorldState.war_state）

| 枚举 | 值 | 含义 |
|---|---|---|
| \`WarState.PEACE\` | 0 | 无战争 |
| \`WarState.SINO_SOVIET\` | 1 | 中苏边境战争 |
| \`WarState.INDIA\` | 2 | 中印边境战争 |

### 3.3 Government（CountryData.government）

| 枚举 | 值 | 含义 |
|---|---|---|
| \`Government.AUTHORITARIAN\` | 0 | 威权主义 |
| \`Government.SOCIALIST\` | 1 | 社会主义 |
| \`Government.REFORMIST\` | 2 | 改良主义 |
| \`Government.LIBERAL\` | 3 | 自由主义 |

### 3.4 SubGovernment（CountryData.sub_government，0-22）

| 枚举 | 值 | 中文 |
|---|---|---|
| \`SubGovernment.LEFT_RADICAL\` | 0 | 左翼激进主义 |
| \`SubGovernment.STATE_SOCIALIST\` | 1 | 国控社会主义 |
| \`SubGovernment.MARXIST_LENINIST\` | 2 | 马列主义 |
| \`SubGovernment.DEMOCRATIC_SOCIALIST\` | 3 | 民主社会主义 |
| \`SubGovernment.SOCIAL_DEMOCRAT\` | 4 | 社会民主主义 |
| \`SubGovernment.MODERATE\` | 5 | 温和主义 |
| \`SubGovernment.LIBERAL\` | 6 | 自由主义 |
| \`SubGovernment.RIGHT_AUTHORITARIAN\` | 7 | 右翼独裁主义 |
| \`SubGovernment.LEFT_CONSERVATIVE\` | 8 | 左倾保守主义 |
| \`SubGovernment.NEO_FASCIST\` | 9 | 新法西斯主义 |
| \`SubGovernment.LEFT_NATIONALIST\` | 10 | 左翼民族主义 |
| \`SubGovernment.TITOIST\` | 11 | 铁托主义 |
| \`SubGovernment.NEOLIBERAL\` | 12 | 新自由主义 |
| \`SubGovernment.NEOPATRIARCHAL\` | 13 | 新父权主义 |
| \`SubGovernment.EUROCOMMUNIST\` | 14 | 欧洲共产主义 |
| \`SubGovernment.PRAGMATIST\` | 15 | 政治实用主义 |
| \`SubGovernment.SOVIET_STYLE\` | 16 | 苏式社会主义 |
| \`SubGovernment.MAOIST\` | 17 | 毛主义 |
| \`SubGovernment.TROTSKYIST\` | 18 | 托洛茨基主义 |
| \`SubGovernment.FEUDAL_SOCIALIST\` | 19 | 封建社会主义 |
| \`SubGovernment.CONSTITUTIONAL_AUTHORITARIAN\` | 20 | 宪政威权主义 |
| \`SubGovernment.RENEWAL_SOCIALIST\` | 21 | 革新社会主义 |
| \`SubGovernment.REVOLUTIONARY_NATIONALIST\` | 22 | 革命民族主义 |

### 3.5 WarSide / DiploStance

| 枚举 | 值 | 含义 |
|---|---|---|
| \`WarSide.NONE\` | -1 | 无 |
| \`WarSide.SIDE1\` | 0 | 第一方 |
| \`WarSide.SIDE2\` | 1 | 第二方 |
| \`DiploStance.PRO_USA\` | 0 | 亲美 |
| \`DiploStance.PRO_USSR\` | 1 | 亲苏 |
| \`DiploStance.PRO_CHINA\` | 2 | 亲中 |
| \`DiploStance.NEUTRAL\` | 3 | 中立 |

### 3.6 政治家特质枚举

| 枚举 | 值 | 说明 |
|---|---|---|
| \`PoliticianPersonality.FAR_LEFT\` | 0 | 极左 |
| \`PoliticianPersonality.MODERATE\` | 1 | 温和 |
| \`PoliticianPersonality.REFORMIST\` | 2 | 改革 |
| \`PoliticianPersonality.LIBERAL\` | 3 | 自由 |
| \`PoliticianPersonality.CONSERVATIVE\` | 20 | 保守 |
| \`PoliticianAlignment.HARDLINER\` | 4 | 硬汉 |
| \`PoliticianAlignment.PRAGMATIST\` | 5 | 实用主义 |
| \`PoliticianAlignment.TOLERANT\` | 6 | 宽容 |
| \`PoliticianAlignment.TECH\` | 7 | 重视技术 |
| \`PoliticianSpecial.HARSH\` | 8 | 苛刻 |
| \`PoliticianSpecial.PEACE\` | 9 | 和平 |
| \`PoliticianSpecial.TYRANT\` | 10 | 小暴君 |
| \`PoliticianSpecial.ECONOMIST\` | 11 | 经管学家 |
| \`PoliticianSpecial.ARROGANT\` | 12 | 傲慢 |
| \`PoliticianSpecial.IDOL\` | 13 | 偶像 |
| \`PoliticianSpecial.CHINA_SCHOOL\` | 14 | 中华派 |
| \`PoliticianSpecial.WESTERN_SCHOOL\` | 15 | 西渐派 |
| \`PoliticianSpecial.ADVISER\` | 16 | 谋士 |
| \`PoliticianSpecial.SHY\` | 17 | 羞怯 |
| \`PoliticianSpecial.CORRUPT\` | 18 | 贪污 |
| \`PoliticianSpecial.SICKLY\` | 19 | 病弱 |
| \`PoliticianBackground.PARTY_CADRE\` | 21 | 党务干部 |
| \`PoliticianBackground.MASS_LEADER\` | 22 | 群众领袖 |
| \`PoliticianBackground.STUDENT_REBEL\` | 23 | 学生小将 |
| \`PoliticianBackground.WORKER_MODEL\` | 24 | 工农劳模 |
| \`PoliticianBackground.MILITARY_GENERAL\` | 25 | 军队将领 |
| \`PoliticianBackground.INTELLECTUAL\` | 26 | 知识分子 |
| \`PoliticianBackground.SCIENTIST\` | 27 | 科学家 |
| \`PoliticianBackground.AMBITIOUS\` | 28 | 野心家 |
| \`PoliticianBackground.SPECIAL\` | 43 | 特殊 |
`;

fs.writeFileSync(path.join(root, '开发帮助文档.md'), md);
console.log('part 1 written, length', md.length);
