## 顶层游戏状态 — 存档的根对象。
## data_200 是唯一权威数据源，EconomyData 只是它的显示视图。
class_name WorldState
extends Resource

## 数值表/具名字段变更通知。index=-1 表示非数值表字段（如 war_state / influence_prc）。
signal value_changed(index: int, old_value: int, new_value: int)

# ============================================================================
# 数值表索引常量 — 取代魔术数字
# ============================================================================

const I_MIL_INTERVENTION := 0   ## 军事介入点（原 data.mil_intervention）
const I_PARTY_SUPPORT := 1       ## 党内支持
const I_SOVIET_INFLUENCE := 2    ## 苏联影响力
const I_USA_INFLUENCE := 10      ## 美国影响力（empires[0].power 的种子源）
const I_PEOPLE_SUPPORT := 3     ## 民众支持
const I_THOUGHT_FREEDOM := 4    ## 思想自由 / 自由化程度
const I_LIVING := 5             ## 生活水平
const I_DIPLO := 6              ## 国际声望
const I_INFLUENCE := 7          ## 全球影响力
const I_BUDGET := 8             ## 预算余额
const I_AGENTS := 9             ## 特工网络
const I_SCIENCE := 11           ## 科研点数
const I_INDUSTRY := 12          ## 工业产值
const I_AGRICULTURE := 13       ## 农业产值
const I_IDEOLOGY := 14          ## 意识形态
const I_PARTY_SYSTEM := 15      ## 政党制度
const I_ECON_SYSTEM := 16       ## 经济体制
const I_PRESS_POLICY := 17      ## 舆论政策
const I_TERRITORY := 18         ## 领土制度
const I_DAY := 19               ## 当前日（原 data.day）
const I_MONTH := 20             ## 当前月（原 data.month）
const I_YEAR := 21              ## 当前年（原 data.year）
const I_ARMY := 22              ## 军力
const I_INCOME := 23            ## 收入
const I_IMPORT_NEEDS := 24      ## 进口需求
const I_TRADE_PARTNERS := 25    ## 贸易伙伴数
const I_CORRUPTION := 26        ## 腐败
const I_INVESTMENT_DELAY := 27  ## 改革开放后等待外资政策的月数（原 data.investment_delay）
const I_USA_RELATIONS := 28    ## 对美关系镜像（权威在 empires[0].relations）
const I_USSR_RELATIONS := 29   ## 对苏关系镜像（权威在 empires[1].relations）
const I_COMMUNICATIONS := 30   ## 外交通信结构恢复度（原 data.communications）
const I_WAR_SUPPORT := 31       ## 战争支持度
const I_NAXALITE_POWER := 32    ## 印度纳萨尔派力量（原 data.naxalite_power）
const I_ECON_OPENNESS := 33     ## 经济开放度
const I_POPULATION := 34        ## 人口(万)
const I_ENDING_ROUTE := 35      ## 待进入的结局编号（原 data.ending_route）
const I_RESERVE := 36           ## 外汇储备
const I_STABILITY := 38         ## 政治稳定
const I_WAR_PRESSURE := 39      ## 中苏战争压力
const I_INDIA_WAR_PRESSURE := 40 ## 中印边境战争攻势（原 data.india_war_pressure）
const I_IRAN_LEFT_SUPPORT := 42 ## 伊朗左翼势力（原 data.iran_left_support）
const I_IRAN_SHAH_SUPPORT := 43 ## 伊朗王室势力（原 data.iran_shah_support）
const I_IRAN_DEMOCRAT_SUPPORT := 44 ## 伊朗民主派势力（原 data.iran_democrat_support）
const I_IRAN_ISLAMIST_SUPPORT := 45 ## 伊朗伊斯兰派势力（原 data.iran_islamist_support）
const I_AFGHAN_OPPOSITION := 46 ## 阿富汗亲华/毛派反对派势力（原 data.afghan_opposition）
const I_AFGHAN_KHALQ := 48     ## 阿富汗人民派势力（原 data.afghan_khalq）
const I_AFGHAN_PARCHAM := 49   ## 阿富汗旗帜派势力（原 data.afghan_parcham）
const I_RELIGION := 50          ## 宗教政策
const I_MIL_DOCTRINE := 51      ## 军事学说
const I_ECON_DISPLAY := 52      ## 经济显示等级
const I_PARTY_BAN_COUNT := 53   ## 已禁止派系数（原 data.party_ban_count，Party_zapret 禁止计数）
const I_POLITICAL_DISPLAY := 54 ## 政治显示等级
const I_POLITICAL_OPENNESS := 55 ## 政治开放度
const I_POLITICAL_LINE := 56    ## 政治路线
const I_MANPOWER := 57          ## 兵源
const I_SOVIET_SUCCESSION := 59 ## 苏联领导层继承结果（原 data.soviet_succession，>0 表示勃列日涅夫已逝）
const I_ALBANIA_BREAK := 60     ## 中阿决裂/阿尔巴尼亚路线状态（原 data.albania_break）
const I_ARUNACHAL_STATUS := 62  ## 藏南/阿鲁纳恰尔状态（原 data.arunachal_status：0印度实控未承认、1承认、2/3已重建控制）
const I_TAIWAN_ISLANDS := 63    ## 台海岛屿控制（原 data.taiwan_islands：0国民党、1解放军）
const I_TAIWAN_STATUS := 64     ## 台湾地位（原 data.taiwan_status：0现状、1独立主权、2省级特别行政区）
const I_HK_MACAU_STATUS := 65   ## 港澳回归路线（原 data.hk_macau_status）
const I_XINJIANG_POLICY := 66   ## 新疆/维吾尔文化政策状态（原 data.xinjiang_policy）
const I_TIBET_POLICY := 67      ## 西藏文化政策状态（原 data.tibet_policy）
const I_SERVICES := 68          ## 服务业产值
const I_LOAN := 69              ## 国债
const I_EXPORT_BASE := 70       ## 出口规模基数（原 data.export_base，ExportValue 的 data.income 种子）
const I_BUDGET_ARMY := 71       ## 预算: 军费
const I_BUDGET_MGB := 72        ## 预算: 国安部
const I_BUDGET_SCIENCE := 73    ## 预算: 科研
const I_BUDGET_ADMIN := 74      ## 预算: 行政
const I_BUDGET_ENVELOPE := 75   ## 预算: 高层福利
const I_BUDGET_PROPAGANDA := 76 ## 预算: 宣传
const I_BUDGET_AGRI := 77       ## 预算: 农业
const I_BUDGET_INDUSTRY := 78   ## 预算: 工业
const I_BUDGET_SERVICES := 79   ## 预算: 服务业
const I_BUDGET_WELFARE := 80    ## 预算: 福利
const I_BUDGET_DIPLO := 81      ## 预算: 外交
const I_WAR_RESOLVE := 82       ## 待结算战争 id，<0 无（原 data.war_resolve）
const I_KOREA_RESULT := 83      ## 朝鲜战争统一方向（原 data.korea_result：1北胜、2南胜）
const I_GANG_OF_FOUR_PATH := 84 ## 四人帮处置路线（原 data.gang_of_four_path，事件25/26及后续链）
const I_PALESTINE_STATUS := 85  ## 巴以安排（原 data.palestine_status）
const I_POST_MAO_COURSE := 87   ## 毛后文革/改革路线（原 data.post_mao_course，事件24及后续链）
const I_REFORM_STAGE := 89      ## 改革阶段（原 data.reform_stage）
const I_MAO_HISTORY_LINE := 90  ## 毛泽东历史评价路线（原 data.mao_history_line）
const I_INDIA_ELECTION := 91    ## 印度大选结果（原 data.india_election）
const I_REFORM_MOMENTUM := 92   ## 政策改革方向累计值（原 data.reform_momentum）
const I_AFGHAN_POLICY := 94     ## 阿富汗策略（原 data.afghan_policy）
const I_SOVIET_SUCCESSOR_THIRD := 100 ## 苏联第三继承人权重（原 data.soviet_successor_third）
const I_MAO_MAUSOLEUM := 104    ## 毛主席纪念堂状态（原 data.mao_mausoleum）
const I_BIRTH_POLICY := 105     ## 生育政策/人口增长基数（原版 data.birth_policy：1一胎 2二胎 3无限制，开局=2）
const I_SATISFIED := 106        ## 满意现秩序者
const I_AFGHAN_WAR_PATH := 107  ## 阿富汗战争路线（原 data.afghan_war_path）
const I_OLIGARCH := 108         ## 寡头影响力
const I_SOVIET_INTERVENTIONS := 112 ## 苏联武装干涉计数（原 data.soviet_interventions）
const I_PROTEST_REPRESSION := 113 ## 抗议镇压状态（原 data.protest_repression）
const I_KILLED_PREMIER_FLAG := 114 ## 总理被刺/倒台标记（原 data.killed_premier_flag）
const I_KILLED_MILITARY_FLAG := 115 ## 军方要员被刺/倒台标记（原 data.killed_military_flag）
const I_KILLED_FOREIGN_FLAG := 116 ## 外事要员被刺/倒台标记（原 data.killed_foreign_flag）
const I_WORLD_POLITICAL_BALANCE := 131 ## 世界政治平衡（原 data.world_political_balance）
const I_OIL_PRICE := 143        ## 石油价格（原 data.oil_price）
const I_MODIFIER_58_TIMER := 153 ## 58 号修正计时（原 data.modifier_58_timer）
const I_SOMALIA_WAR_STATE := 157 ## 索马里战争状态（原 data.somalia_war_state）
const I_SOVIET_MONEY := 160     ## 苏联资金（原 data.soviet_money）
const I_USA_MONEY := 161        ## 美国资金（原 data.usa_money）
const I_ANTHEM_CHOICE := 185    ## 国歌选择（原 data.anthem_choice）
const I_FOREIGN_AID := 146     ## 外援强度（原版 data.foreign_aid，dota 消耗）
const I_INDUSTRY_BASE := 152    ## 工业基数

# ── 数值表索引 → 语义名映射（事件/效果系统的字符串 key 查表用） ──
const 数值索引 := {
	"party_support": I_PARTY_SUPPORT, "党内支持": I_PARTY_SUPPORT,
	"soviet_influence": I_SOVIET_INFLUENCE, "苏联影响力": I_SOVIET_INFLUENCE,
	"people_support": I_PEOPLE_SUPPORT, "popular_support": I_PEOPLE_SUPPORT, "民众支持": I_PEOPLE_SUPPORT,
	"thought_freedom": I_THOUGHT_FREEDOM, "liberalization": I_THOUGHT_FREEDOM, "思想自由": I_THOUGHT_FREEDOM,
	"living_standard": I_LIVING, "living": I_LIVING, "生活水平": I_LIVING,
	"diplo": I_DIPLO, "diplomacy": I_DIPLO, "diplomatic_reputation": I_DIPLO, "国际声望": I_DIPLO,
	"global_influence": I_INFLUENCE, "influence": I_INFLUENCE, "political": I_INFLUENCE, "全球影响": I_INFLUENCE,
	"money": I_BUDGET, "budget": I_BUDGET, "预算": I_BUDGET,
	"agents": I_AGENTS, "agent": I_AGENTS, "agent_network": I_AGENTS, "特工": I_AGENTS,
	"science": I_SCIENCE, "science_points": I_SCIENCE, "科研": I_SCIENCE,
	"industry": I_INDUSTRY, "ind": I_INDUSTRY, "工业": I_INDUSTRY,
	"agriculture": I_AGRICULTURE, "food": I_AGRICULTURE, "农业": I_AGRICULTURE,
	"ideology": I_IDEOLOGY, "意识形态": I_IDEOLOGY,
	"party_system": I_PARTY_SYSTEM, "政党制度": I_PARTY_SYSTEM,
	"economy_system": I_ECON_SYSTEM, "economic_system": I_ECON_SYSTEM, "development": I_ECON_SYSTEM, "经济体制": I_ECON_SYSTEM,
	"speech_policy": I_PRESS_POLICY, "press_policy": I_PRESS_POLICY, "舆论政策": I_PRESS_POLICY,
	"territorial_policy": I_TERRITORY, "领土制度": I_TERRITORY,
	"religion_policy": I_RELIGION, "宗教政策": I_RELIGION,
	"day": I_DAY, "month": I_MONTH, "year": I_YEAR,
	"army": I_ARMY, "army_strength": I_ARMY, "military": I_ARMY, "军力": I_ARMY,
	"corruption": I_CORRUPTION, "腐败": I_CORRUPTION,
	"investment_delay": I_INVESTMENT_DELAY, "外资政策等待月数": I_INVESTMENT_DELAY,
	"mil_intervention": I_MIL_INTERVENTION, "军事介入点": I_MIL_INTERVENTION,
	"war_resolve": I_WAR_RESOLVE, "战争结算": I_WAR_RESOLVE,
	"korea_result": I_KOREA_RESULT, "朝鲜战争结果": I_KOREA_RESULT,
	"war_support": I_WAR_SUPPORT,
	"naxalite_power": I_NAXALITE_POWER, "纳萨尔派力量": I_NAXALITE_POWER,
	"population": I_POPULATION, "人口": I_POPULATION,
	"ending_route": I_ENDING_ROUTE, "结局编号": I_ENDING_ROUTE,
	"money_reserve": I_RESERVE, "reserve": I_RESERVE, "外汇": I_RESERVE,
	"political_stability": I_STABILITY, "政治稳定": I_STABILITY,
	"war_pressure": I_WAR_PRESSURE, "sino_soviet_war_pressure": I_WAR_PRESSURE,
	"india_war_pressure": I_INDIA_WAR_PRESSURE, "中印战争攻势": I_INDIA_WAR_PRESSURE,
	"military_doctrine": I_MIL_DOCTRINE, "军事学说": I_MIL_DOCTRINE,
	"political_line": I_POLITICAL_LINE, "政治路线": I_POLITICAL_LINE,
	"manpower": I_MANPOWER, "兵源": I_MANPOWER,
	"soviet_succession": I_SOVIET_SUCCESSION, "苏联继承": I_SOVIET_SUCCESSION,
	"albania_break": I_ALBANIA_BREAK, "中阿决裂": I_ALBANIA_BREAK,
	"arunachal_status": I_ARUNACHAL_STATUS, "藏南状态": I_ARUNACHAL_STATUS,
	"taiwan_islands": I_TAIWAN_ISLANDS, "台海岛屿": I_TAIWAN_ISLANDS,
	"taiwan_status": I_TAIWAN_STATUS, "台湾地位": I_TAIWAN_STATUS,
	"hk_macau_status": I_HK_MACAU_STATUS, "港澳路线": I_HK_MACAU_STATUS,
	"xinjiang_policy": I_XINJIANG_POLICY, "新疆文化政策": I_XINJIANG_POLICY,
	"tibet_policy": I_TIBET_POLICY, "西藏文化政策": I_TIBET_POLICY,
	"services": I_SERVICES, "服务业": I_SERVICES,
	"loan": I_LOAN, "debt": I_LOAN, "国债": I_LOAN,
	"budget_army": I_BUDGET_ARMY, "军费预算": I_BUDGET_ARMY,
	"budget_mgb": I_BUDGET_MGB, "国安预算": I_BUDGET_MGB,
	"budget_science": I_BUDGET_SCIENCE, "科研预算": I_BUDGET_SCIENCE,
	"budget_admin": I_BUDGET_ADMIN, "行政预算": I_BUDGET_ADMIN,
	"budget_envelope": I_BUDGET_ENVELOPE, "高层福利预算": I_BUDGET_ENVELOPE,
	"budget_propaganda": I_BUDGET_PROPAGANDA, "宣传预算": I_BUDGET_PROPAGANDA,
	"budget_agriculture": I_BUDGET_AGRI, "农业预算": I_BUDGET_AGRI,
	"budget_industry": I_BUDGET_INDUSTRY, "工业预算": I_BUDGET_INDUSTRY,
	"budget_services": I_BUDGET_SERVICES, "服务业预算": I_BUDGET_SERVICES,
	"budget_welfare": I_BUDGET_WELFARE, "福利预算": I_BUDGET_WELFARE,
	"budget_diplomacy": I_BUDGET_DIPLO, "外交预算": I_BUDGET_DIPLO,
	"data_41": 41,   # 原 data.thailand_election_intervention（泰国选举干预标志，无正式命名键）
	"data_124": 124, # 原 data.turkish_pan_turkic_chain（土耳其泛突厥/蒙古事件链标志，无正式命名键）
	"data_126": 126, # 原 data.turkish_straits_crisis（土耳其海峡危机标志，无正式命名键）
	"data_127": 127, # 原 data.turkish_route_result（土耳其路线结果，无正式命名键）
	"data_133": 133, # 原 data.soviet_reorganization_war_state（苏联重组战争前置状态，无正式命名键）
	"data_149": 149, # 原 data.soviet_successor_route（苏斯洛夫/安德罗波夫继任路线：事件83=1、84=2、85=3，无正式命名键）
	"data_52": I_ECON_DISPLAY,   # 原 data.econ_display（经济显示等级，Event999 宪法分支判定 data.econ_display==37）
	"data_86": 86,               # 原 data.yugoslavia_kosovo_chain（南斯拉夫/科索沃事件链状态，Event76 使用）
	"data_117": 117,             # 原 data.iraq_development_sentinel（伊拉克发展度哨兵，Event75 触发条件 data.iraq_development_sentinel!=9）
	"data_120": 120,             # 原 data.ally_crisis_target（盟友危机 Event107 目标国家原版序号，结果末尾置 -1）
	"data_170": 170,             # 原 data.event999_trigger_sentinel（Event999 触发哨兵：==999 时开火，结果里清零）
	"gang_of_four_path": I_GANG_OF_FOUR_PATH, "四人帮路线": I_GANG_OF_FOUR_PATH,
	"palestine_status": I_PALESTINE_STATUS, "巴以安排": I_PALESTINE_STATUS,
	"post_mao_course": I_POST_MAO_COURSE, "毛后路线": I_POST_MAO_COURSE,
	"reform_stage": I_REFORM_STAGE, "改革阶段": I_REFORM_STAGE,
	"satisfied": I_SATISFIED, "满意现秩序者": I_SATISFIED,
	"afghan_war_path": I_AFGHAN_WAR_PATH, "阿富汗战争路线": I_AFGHAN_WAR_PATH,
	"oligarch": I_OLIGARCH, "寡头": I_OLIGARCH,
	"protest_repression": I_PROTEST_REPRESSION, "抗议镇压": I_PROTEST_REPRESSION,
	"birth_policy": I_BIRTH_POLICY, "生育政策": I_BIRTH_POLICY,
	"foreign_aid": I_FOREIGN_AID, "外援": I_FOREIGN_AID,
	"usa_relations": I_USA_RELATIONS, "对美关系": I_USA_RELATIONS,
	"ussr_relations": I_USSR_RELATIONS, "对苏关系": I_USSR_RELATIONS,
	"communications": I_COMMUNICATIONS, "通信结构": I_COMMUNICATIONS,
	"iran_left_support": I_IRAN_LEFT_SUPPORT, "伊朗左翼势力": I_IRAN_LEFT_SUPPORT,
	"iran_shah_support": I_IRAN_SHAH_SUPPORT, "伊朗王室势力": I_IRAN_SHAH_SUPPORT,
	"iran_democrat_support": I_IRAN_DEMOCRAT_SUPPORT, "伊朗民主派势力": I_IRAN_DEMOCRAT_SUPPORT,
	"iran_islamist_support": I_IRAN_ISLAMIST_SUPPORT, "伊朗伊斯兰派势力": I_IRAN_ISLAMIST_SUPPORT,
	"afghan_opposition": I_AFGHAN_OPPOSITION, "阿富汗亲华反对派": I_AFGHAN_OPPOSITION,
	"afghan_khalq": I_AFGHAN_KHALQ, "阿富汗人民派": I_AFGHAN_KHALQ,
	"afghan_parcham": I_AFGHAN_PARCHAM, "阿富汗旗帜派": I_AFGHAN_PARCHAM,
	"mao_history_line": I_MAO_HISTORY_LINE, "毛泽东历史评价": I_MAO_HISTORY_LINE,
	"india_election": I_INDIA_ELECTION, "印度大选结果": I_INDIA_ELECTION,
	"reform_momentum": I_REFORM_MOMENTUM, "改革方向": I_REFORM_MOMENTUM,
	"mao_mausoleum": I_MAO_MAUSOLEUM, "毛主席纪念堂": I_MAO_MAUSOLEUM,
	"soviet_successor_third": I_SOVIET_SUCCESSOR_THIRD, "苏联第三继承人权重": I_SOVIET_SUCCESSOR_THIRD,
	"soviet_interventions": I_SOVIET_INTERVENTIONS, "苏联干涉计数": I_SOVIET_INTERVENTIONS,
}

# ── 数值表：具名字段 ──
## 0 军事介入点
@export var mil_intervention: int = 0

## 1 党内支持
@export var party_support: int = 0

## 2 苏联影响力
@export var soviet_influence: int = 0

## 3 民众支持
@export var people_support: int = 0

## 4 思想自由/自由化
@export var thought_freedom: int = 0

## 5 生活水平
@export var living_standard: int = 0

## 6 国际声望
@export var diplomatic_reputation: int = 0

## 7 全球影响力（Godot 独立字段）。
## 注意：原版 TimeScript.KumihaRepaint 会把 data[7] 刷成 gameState.influencePRC，
## 即顶栏“全球影响力/国际影响力”实际应读 influence_prc；本字段保留给内部 data[7] 语义。
@export var global_influence: int = 0

## 8 预算余额
@export var budget: int = 0

## 9 特工网络
@export var agents: int = 0

## 10 美国影响力
@export var usa_influence: int = 0

## 11 科研点数
@export var science: int = 0

## 12 工业产值
@export var industry: int = 0

## 13 农业产值
@export var agriculture: int = 0

## 14 意识形态(离散)
@export var ideology: int = 0

## 15 政党制度(离散)
@export var party_system: int = 0

## 16 经济体制(离散)
@export var econ_system: int = 0

## 17 舆论政策(离散)
@export var press_policy: int = 0

## 18 领土制度(离散)
@export var territory_policy: int = 0

## 19 日
@export var day: int = 0

## 20 月
@export var month: int = 0

## 21 年
@export var year: int = 0

## 22 军力
@export var army: int = 0

## 23 收入
@export var income: int = 0

## 24 进口需求
@export var import_needs: int = 0

## 25 贸易伙伴数
@export var trade_partners: int = 0

## 26 腐败
@export var corruption: int = 0

## 27 改革开放后等待外资政策月数
@export var investment_delay: int = 0

## 28 对美关系(镜像, 待消除)
@export var usa_relations: int = 0

## 29 对苏关系(镜像, 待消除)
@export var ussr_relations: int = 0

## 30 外交通信结构恢复度
@export var communications: int = 0

## 31 战争支持度
@export var war_support: int = 0

## 32 印度纳萨尔派力量
@export var naxalite_power: int = 0

## 33 经济开放度
@export var econ_openness: int = 0

## 34 人口(万)
@export var population: int = 0

## 35 待进入结局编号
@export var ending_route: int = 0

## 36 外汇储备
@export var reserve: int = 0

## 37 菲律宾毛派力量
@export var philippines_maoist_power: int = 0

## 38 政治稳定
@export var stability: int = 0

## 39 中苏战争压力
@export var war_pressure: int = 0

## 40 中印边境战争攻势
@export var india_war_pressure: int = 0

## 41 泰国选举干预标志
@export var thailand_election_intervention: int = 0

## 42 伊朗左翼势力
@export var iran_left_support: int = 0

## 43 伊朗王室势力
@export var iran_shah_support: int = 0

## 44 伊朗民主派势力
@export var iran_democrat_support: int = 0

## 45 伊朗伊斯兰派势力
@export var iran_islamist_support: int = 0

## 46 阿富汗亲华/毛派反对派势力
@export var afghan_opposition: int = 0

## 47 随机外交参数(开局1-4)
@export var random_diplo_param: int = 0

## 48 阿富汗人民派势力
@export var afghan_khalq: int = 0

## 49 阿富汗旗帜派势力
@export var afghan_parcham: int = 0

## 50 宗教政策(离散)
@export var religion_policy: int = 0

## 51 军事学说(离散)
@export var military_doctrine: int = 0

## 52 经济显示等级(离散)
@export var econ_display: int = 0

## 53 已禁止派系数
@export var party_ban_count: int = 0

## 54 政治显示等级(离散)
@export var political_display: int = 0

## 55 政治开放度
@export var political_openness: int = 0

## 56 政治路线(离散)
@export var political_line: int = 0

## 57 兵源
@export var manpower: int = 0

## 58 未使用/保留槽
@export var data_58: int = 0

## 59 苏联领导层继承结果(离散)
@export var soviet_succession: int = 0

## 60 中阿决裂/阿尔巴尼亚路线状态(离散)
@export var albania_break: int = 0

## 61 未使用/保留槽
@export var data_61: int = 0

## 62 藏南/阿鲁纳恰尔状态(离散)
@export var arunachal_status: int = 0

## 63 台海岛屿控制(离散)
@export var taiwan_islands: int = 0

## 64 台湾地位(离散)
@export var taiwan_status: int = 0

## 65 港澳回归路线(离散)
@export var hk_macau_status: int = 0

## 66 新疆/维吾尔文化政策状态(离散)
@export var xinjiang_policy: int = 0

## 67 西藏文化政策状态(离散)
@export var tibet_policy: int = 0

## 68 服务业产值
@export var services: int = 0

## 69 国债
@export var loan: int = 0

## 70 出口规模基数
@export var export_base: int = 0

## 71 预算:军费
@export var budget_army: int = 0

## 72 预算:国安部
@export var budget_mgb: int = 0

## 73 预算:科研
@export var budget_science: int = 0

## 74 预算:行政
@export var budget_admin: int = 0

## 75 预算:高层福利
@export var budget_envelope: int = 0

## 76 预算:宣传
@export var budget_propaganda: int = 0

## 77 预算:农业
@export var budget_agri: int = 0

## 78 预算:工业
@export var budget_industry: int = 0

## 79 预算:服务业
@export var budget_services: int = 0

## 80 预算:福利
@export var budget_welfare: int = 0

## 81 预算:外交
@export var budget_diplo: int = 0

## 82 待结算战争id, <0无
@export var war_resolve: int = 0

## 83 朝鲜战争统一方向(离散)
@export var korea_result: int = 0

## 84 四人帮处置路线(离散)
@export var gang_of_four_path: int = 0

## 85 巴以安排(离散)
@export var palestine_status: int = 0

## 86 南斯拉夫/科索沃事件链状态(离散)
@export var yugoslavia_kosovo_chain: int = 0

## 87 毛后文革/改革路线(离散)
@export var post_mao_course: int = 0

## 88 民主运动/天安门事件链计数
@export var democracy_movement: int = 0

## 89 改革阶段(离散)
@export var reform_stage: int = 0

## 90 毛泽东历史评价路线(离散)
@export var mao_history_line: int = 0

## 91 印度大选结果(离散)
@export var india_election: int = 0

## 92 政策改革方向累计值
@export var reform_momentum: int = 0

## 93 未使用/保留槽
@export var data_93: int = 0

## 94 阿富汗策略(离散)
@export var afghan_policy: int = 0

## 95 苏领导人契尔年科支持
@export var soviet_leader_chernenko: int = 0

## 96 苏领导人安德罗波夫支持
@export var soviet_leader_andropov: int = 0

## 97 苏领导人谢尔比茨基支持
@export var soviet_leader_shcherbitsky: int = 0

## 98 苏领导人罗曼诺夫支持
@export var soviet_leader_romanov: int = 0

## 99 苏领导人格里申支持
@export var soviet_leader_grishin: int = 0

## 100 苏联第三继承人权重
@export var soviet_successor_third: int = 0

## 101 未使用/保留槽
@export var data_101: int = 0

## 102 五年计划重点(1-5)
@export var five_year_plan_focus: int = 0

## 103 非洲政变路线(15=布基纳法索)
@export var africa_coup_route: int = 0

## 104 毛主席纪念堂状态(离散)
@export var mao_mausoleum: int = 0

## 105 生育政策/人口增长基数(离散)
@export var birth_policy: int = 0

## 106 满意现秩序者
@export var satisfied: int = 0

## 107 阿富汗战争路线(离散)
@export var afghan_war_path: int = 0

## 108 寡头影响力
@export var oligarch: int = 0

## 109 未使用/保留槽
@export var data_109: int = 0

## 110 政治清洗/铁血计数
@export var political_repression_count: int = 0

## 111 强硬镇压计数
@export var hardline_crackdown_count: int = 0

## 112 苏联武装干涉计数
@export var soviet_interventions: int = 0

## 113 抗议镇压状态(离散)
@export var protest_repression: int = 0

## 114 总理被杀标志(=9)
@export var killed_premier_flag: int = 0

## 115 军委主席被杀标志(=9)
@export var killed_military_flag: int = 0

## 116 外交部长被杀标志(=9)
@export var killed_foreign_flag: int = 0

## 117 伊拉克发展度哨兵(Event75)
@export var iraq_development_sentinel: int = 0

## 118 全面自动化建设宣告标志
@export var automation_progress: int = 0

## 119 选举月1(1-6)
@export var election_month_first: int = 0

## 120 盟友危机目标国家原版序号
@export var ally_crisis_target: int = 0

## 121 选举月2(7-12)
@export var election_month_second: int = 0

## 122 未使用/保留槽
@export var data_122: int = 0

## 123 未使用/保留槽
@export var data_123: int = 0

## 124 土耳其泛突厥/蒙古事件链标志
@export var turkish_pan_turkic_chain: int = 0

## 125 选举计时/余波
@export var election_timer: int = 0

## 126 土耳其海峡危机标志
@export var turkish_straits_crisis: int = 0

## 127 土耳其路线结果
@export var turkish_route_result: int = 0

## 128 土耳其海峡状态(1/2)
@export var turkish_straits_state: int = 0

## 129 塞浦路斯希腊方胜利标志
@export var cyprus_greek_victory_flag: int = 0

## 130 蒙古亲华/中国路线(0/1)
@export var mongolia_china_route: int = 0

## 131 世界政治局势(0-3)
@export var world_political_balance: int = 0

## 132 苏联东欧干涉状态(0/1/2)
@export var soviet_eastern_europe_intervention: int = 0

## 133 苏联重组战争前置状态(离散)
@export var soviet_reorganization_war_state: int = 0

## 134 意大利激进左翼/恐怖组织实力
@export var italian_radical_left_power: int = 0

## 135 被逐出后恢复特工修正47
@export var restore_agent_mod_47: bool = false

## 136 被逐出后恢复特工修正48
@export var restore_agent_mod_48: bool = false

## 137 被逐出后恢复经互会
@export var restore_econ_alliance: bool = false

## 138 被逐出后恢复华约
@export var restore_okb_alliance: bool = false

## 139 被逐出联盟倒计时
@export var alliance_kickout_timer: int = 0

## 140 被逐出联盟类型(1=SEV,2=ASEAN)
@export var alliance_kickout_type: int = 0

## 141 联盟胁迫目标国家原版序号
@export var alliance_coercion_target: int = 0

## 142 联盟胁迫进度
@export var alliance_coercion_progress: int = 0

## 143 油价
@export var oil_price: int = 0

## 144 未使用/保留槽
@export var data_144: int = 0

## 145 未使用/保留槽
@export var data_145: int = 0

## 146 外援强度
@export var foreign_aid: int = 0

## 147 英国政治路线(1-9)
@export var britain_political_route: int = 0

## 148 未使用/保留槽
@export var data_148: int = 0

## 149 苏斯洛夫/安德罗波夫继任路线(1-3)
@export var soviet_successor_route: int = 0

## 150 苏联干涉冷却月数
@export var soviet_intervention_cooldown: int = 0

## 151 美国干涉冷却月数
@export var usa_intervention_cooldown: int = 0

## 152 工业基数
@export var industry_base: int = 0

## 153 修正58计时
@export var modifier_58_timer: int = 0

## 154 未使用/保留槽
@export var data_154: int = 0

## 155 法国社会党得票率
@export var france_socialist_vote: int = 0

## 156 法国共产党得票率
@export var france_communist_vote: int = 0

## 157 索马里战争结果标志
@export var somalia_war_state: int = 0

## 158 索马里亲华路线标志
@export var somalia_china_route: int = 0

## 159 未使用/保留槽
@export var data_159: int = 0

## 160 苏联资金(结局配置)
@export var soviet_money: int = 0

## 161 美国资金(结局配置)
@export var usa_money: int = 0

## 162 其他组织力量1
@export var org_strength_1: int = 0

## 163 其他组织力量2
@export var org_strength_2: int = 0

## 164 其他组织力量3
@export var org_strength_3: int = 0

## 165 其他组织力量4
@export var org_strength_4: int = 0

## 166 BICO力量
@export var bico_strength: int = 0

## 167 未使用/保留槽(原版有递减)
@export var data_167: int = 0

## 168 支援已派出标志
@export var support_sent_flag: bool = false

## 169 爱尔兰统一路线(离散)
@export var ireland_unification_route: int = 0

## 170 Event999触发哨兵(==999)
@export var event999_trigger_sentinel: int = 0

## 171 越南亲华政变可用标志(0/1)
@export var vietnam_pro_china_coup_available: int = 0

## 172 意大利政局力量172
@export var italy_power_172: int = 0

## 173 意大利政局力量173
@export var italy_power_173: int = 0

## 174 意大利政局力量174
@export var italy_power_174: int = 0

## 175 意大利政局力量175
@export var italy_power_175: int = 0

## 176 意大利政局力量176
@export var italy_power_176: int = 0

## 177 意大利政局力量177
@export var italy_power_177: int = 0

## 178 意大利政局力量178
@export var italy_power_178: int = 0

## 179 意大利政局力量179
@export var italy_power_179: int = 0

## 180 意大利政局力量180
@export var italy_power_180: int = 0

## 181 意大利政局力量181
@export var italy_power_181: int = 0

## 182 短剑力量
@export var short_sword_power: int = 0

## 183 意大利事件计时
@export var italy_event_timer: int = 0

## 184 意大利热秋路线(1-3)
@export var italy_hot_autumn_route: int = 0

## 185 国歌选择(1-6)
@export var anthem_choice: int = 0

## 186 伊拉克革命计时
@export var iraq_revolution_timer: int = 0

# ── 时间 ──
@export var date: GameDate

# ── 核心数据 ──
@export var countries: Array[CountryData] = []
@export var politicians: Array[PoliticianData] = []
@export var leader: PoliticianData
## 实权领袖肖像对应的 politicians 槽（仅作回退/对照）
@export var leader_politician_index: int = -1
## 运行时预备池（开局从 政治家池/预备 装入，Kill 补员时消耗）
@export var politician_reserve: Array[PoliticianData] = []
@export var factions: Array[FactionData] = []
@export var empires: Array[EmpireData] = []

# ── 战争/修正 ──
@export var wars: Array[WarData] = []
@export var modifiers: Array[ModifierSlot] = []
@export var war_state: int = 0

# ── 科技/决策 ──
@export var techs: TechState
@export var decisions: DecisionState

# ── 玩家设置 ──
@export var player_country_gwcode: int = 710
@export var difficulty: int = 2
@export var is_ironman: bool = false

# ── DLC 开关（原版 GlobalScript.dlc: bool[5]，默认全 false）──
# 裁决（2026-08-16）：Focus 默认开启 → dlc[0]=true；
# 决议 45 条默认全部显示 → dlc[1..3]=true；dlc[4] 预留。
# 旧存档缺字段时 Godot 取本默认值，自动获得全部决议（与裁决一致）。
@export var dlc: Array[bool] = [true, true, true, true, false]

# ── 中苏党际关系（原版 GameState.SOV_PRC_PartiesConnection）──
# 统一以 data.communications（I_COMMUNICATIONS）为唯一权威，不再保留镜像字段。
# 原版开局 GameStartScript.cs:934 = gameState.data.communications；Focus 焦点可增减。

# ── 决议系统原版字段（GameState.cs:7862-7984，决策原子直读直写）──
# 旧存档缺字段时取声明默认值（与原版默认 0/false 一致）。
@export var desnull: Array[int] = []          # 原版 int[50]，Oncein/DoTimer 计时器
@export var oil_prod: float = 0.0             # 原版 OilProd（开局 GameStartScript:90 = 850）
@export var oil_eat: float = 0.0              # 原版 OilEat（开局按 GameStartScript:824 公式）
@export var army_power: int = 0               # 原版 ArmyPower
@export var has_coupon_system_phase_out: bool = false
@export var planned_price_reduction: int = 0
@export var austerity: int = 0
@export var developed_consumerism: int = 0
@export var new_era_commune_member: int = 0
@export var party_means_party: int = 0
@export var party_subsidy: int = 0
@export var arms_purchase_agreement: int = 0
@export var pmc: int = 0
@export var military_service: int = 0
@export var leader_asset: int = 0
@export var money_level: int = 0
@export var new_politician: Array[bool] = []  # 原版 bool[8]（GetLinBiao 开关；Godot 政治家池已简化为直接换人）
@export var anthem_cooldown_time: int = 0     # 原版 AnthemCooldownTime（HasAnthemConfirmed 用）
@export var ind_opp: bool = false             # 原版 IndOpp（HasntJueQi 用）
@export var oar: bool = false                 # 原版 OAR（阿拉伯革命社会主义共和国联盟已成立）
@export var serve_rmb: bool = false            # 原版 ServeRMB（CreateNewLeader 清零）
@export var leader_property: Array[bool] = []  # 原版 LeaderProperty[4]（决议 idx51 效果动态读）

# ── 全局标记（替代原版散落 bool） ──
@export var global_flags: Dictionary = {}
## 地图归属运行时覆盖（region_id -> gwcode）。地图本身不随 WorldState 序列化，
## 事件/外交改变地图归属后写这里，读档/重进场景时恢复，避免独立领土又变回原宗主国。
@export var map_owner_overrides: Dictionary = {}

# ── 老系统数字事件状态覆盖（替代原版 event_done[]/resultOfEvents[] 直接写）──
# 读取时优先于 EventEngine.completed_event_ids；旧存档缺字段取空字典（原版默认 false/0）。
@export var event_done_overrides: Dictionary = {}
@export var result_of_event_overrides: Dictionary = {}

# ── 事件完成追踪（event_id → option_index：键存在=已完成，值=所选选项编号） ──
@export var completed_event_ids: Dictionary = {}

# ── 事件引擎运行时（随 WorldState 存档） ──
@export var event_pending_id: String = ""
## GameDate.tick_count 截止值（旧存档的 YYYYMMDD 由 EventEngine 读档时迁移）
@export var event_pending_deadline: int = -1
@export var event_chain_queue: Array[String] = []
## 待显示通知队列（被 pending 挡住、稍后仍需出现提示图标的事件）
@export var event_pending_queue: Array[String] = []

# ── 政治家职位（dolshnost[8]，每槽记录持有人在 politicians 中的索引，-1=空缺） ──
# 0=总理 1=军委主席 2=外交部长 3=首都 4=北方 5=西方 6=南方 7=东方
@export var politics_positions: Array[int] = []

# ── 数值表已拆分为具名字段（见上方） ──

# ── 双周入口快照（运行时，不序列化；对齐原版 TimeScript.cs:1224-1228 的 array9）──
var 入口快照: Array[int] = []
var 入口快照关系: Array[int] = [0, 0]
var 入口快照影响: int = 0

# ── 双周结算的 ±变化（对齐原版 data_old，序列化；仅用于经济界面悬浮提示） ──
@export var 上期变化: Array[int] = []
@export var 上期关系变化: Array[int] = [0, 0]
@export var 上期影响变化: int = 0

# ── 外交互动全局状态 ──
## 中国全球影响力累计值（原版 gameState.influencePRC）。
## 注：原版由 TimeScript 周期把它转化为各国 prc_power，此转化移植说明 → 目前只累计。注
@export var influence_prc: int = 0
## 扶持极左派冷却：[0]=西欧、[1]=东欧（原版 war_active[0]/[1]）。
## 每年由 GameManager._on_year_changed 重置（TimeScript.cs:946-947）。
@export var war_active: Array[bool] = [false, false]

# ── 玩家经济显示视图（只读镜像，非独立数据） ──
@export var 玩家经济: EconomyData

# ── 玩法随机源（暗杀等）：种子+流位置存档 → 行为真随机且回放可复现 ──
# RandomNumberGenerator 是 RefCounted 不能 @export，用两个 int 持久化后运行时重建。
@export var rng_seed: int = 0
@export var rng_state: int = 0

# ── 运行时缓存（不序列化） ──
var _gwcode_cache: Dictionary = {}
var _gwcode_cache_built: bool = false
var _tag_cache: Dictionary = {}
var _tag_cache_built: bool = false
var _slot_cache: Dictionary = {}
var _slot_cache_built: bool = false
var _economy_dirty: bool = false
var _rng: RandomNumberGenerator = null


func _init() -> void:
	date = GameDate.new()
	techs = TechState.new()
	decisions = DecisionState.new()
	玩家经济 = EconomyData.new()
	politics_positions.resize(8)
	politics_positions.fill(-1)
	desnull.resize(50)
	desnull.fill(0)
	new_politician.resize(8)
	new_politician.fill(false)
	leader_property.resize(4)
	leader_property.fill(false)


# ── 玩法随机源 ──

## 懒构造种子 RNG；从 rng_seed + rng_state 恢复流位置（读档后调用）。
func ensure_rng() -> RandomNumberGenerator:
	if _rng == null:
		_rng = RandomNumberGenerator.new()
		_rng.seed = rng_seed
		if rng_state != 0:
			_rng.state = rng_state
	return _rng


## 把当前 RNG 流位置镜像回 rng_state（存档前调用，保证读档精确续流）。
func sync_rng_state() -> void:
	if _rng != null:
		rng_state = _rng.state


# ── 国家查询 ──

func get_country_by_slot(slot: int) -> CountryData:
	if not _slot_cache_built:
		rebuild_gwcode_index()
	return _slot_cache.get(slot)


func get_country_by_gwcode(gwcode: int) -> CountryData:
	if not _gwcode_cache_built:
		rebuild_gwcode_index()
	return _gwcode_cache.get(gwcode)


func get_country_by_real_gwcode(gwcode: int) -> CountryData:
	return get_country_by_gwcode(gwcode)


func rebuild_gwcode_index() -> void:
	_gwcode_cache.clear()
	_tag_cache.clear()
	_slot_cache.clear()
	for c in countries:
		if c.gwcode > 0:
			_gwcode_cache[c.gwcode] = c
		if c.name != "":
			_tag_cache[c.name] = c
		if c.slot >= 0:
			_slot_cache[c.slot] = c
	_gwcode_cache_built = true
	_tag_cache_built = true
	_slot_cache_built = true


func get_country_by_legacy_index(idx: int) -> CountryData:
	for c in countries:
		if c.原版序号 == idx:
			return c
	return null


func get_player_country() -> CountryData:
	return get_country_by_gwcode(player_country_gwcode)


func get_country_by_tag(tag: String) -> CountryData:
	if tag == "ROOT" or tag == "":
		return get_player_country()
	if not _tag_cache_built:
		rebuild_gwcode_index()
	return _tag_cache.get(tag)


## 统一国家身份解析：自动识别 gwcode / 原版序号 / slot / 标签字符串。
## 这是国家-地图-战争共用的唯一入口，避免各系统混用编号。
func resolve_country(id) -> CountryData:
	if id is String:
		var sid := String(id)
		if sid.is_valid_int():
			return resolve_country(int(sid))
		return get_country_by_tag(sid)
	if id is int or id is float:
		var iid := int(id)
		var c := get_country_by_gwcode(iid)
		if c != null:
			return c
		c = get_country_by_legacy_index(iid)
		if c != null:
			return c
		return get_country_by_slot(iid)
	return null


## 每日镜像：empires 权威 → 数值表[28/29/10/2]（原版 KumihaRepaint）。
## 原为 GameManager._mirror_empires_to_data，迁到 WorldState 后 WarSystem 可直接调用。
func mirror_empires_to_data() -> void:
	if size() <= 29:
		return
	var d := self
	if empires.size() > 0 and empires[0] != null:
		d.usa_relations = empires[0].relations
		d.usa_influence = empires[0].power
	if empires.size() > 1 and empires[1] != null:
		d.ussr_relations = empires[1].relations
		d.soviet_influence = empires[1].power


# ── 数值表读写 ──

func get_data_index(key: String) -> int:
	return 数值索引.get(key.to_lower(), -1)


func get_data_value(key: String) -> int:
	if key.to_lower() in ["war", "war_state"]:
		return war_state
	if key.to_lower() == "influence_prc":
		return influence_prc
	var idx := get_data_index(key)
	if idx >= 0 and idx < size():
		return get_data_by_index(idx)
	return 0


func set_data_value(key: String, value: int) -> void:
	if key.to_lower() in ["war", "war_state"]:
		var old_war := war_state
		war_state = value
		value_changed.emit(-1, old_war, war_state)
		return
	if key.to_lower() == "influence_prc":
		var old_inf := influence_prc
		influence_prc = value
		value_changed.emit(-1, old_inf, influence_prc)
		return
	var idx := get_data_index(key)
	if idx >= 0 and idx < size():
		var old := get_data_by_index(idx)
		if old != value:
			set_data_by_index(idx, value)
			_economy_dirty = true
			value_changed.emit(idx, old, value)


func add_data_value(key: String, delta: int) -> void:
	if key.to_lower() in ["war", "war_state"]:
		var old_war := war_state
		war_state += delta
		value_changed.emit(-1, old_war, war_state)
		return
	if key.to_lower() == "influence_prc":
		var old_inf := influence_prc
		influence_prc += delta
		value_changed.emit(-1, old_inf, influence_prc)
		return
	var idx := get_data_index(key)
	if idx >= 0 and idx < size():
		var old := get_data_by_index(idx)
		var new_value := old + delta
		set_data_by_index(idx, new_value)
		_economy_dirty = true
		value_changed.emit(idx, old, new_value)


## 具名门面：与 get_data_value 等价，后续新代码优先使用短名。
func get_value(key: String) -> int:
	return get_data_value(key)


func set_value(key: String, value: int) -> void:
	set_data_value(key, value)


func add_value(key: String, delta: int) -> void:
	add_data_value(key, delta)



## 动态下标兼容入口：新代码应使用具名字段，这里仅用于尚未迁移完的旧调用。
func get_data_by_index(idx: int) -> int:
	var field: String = FIELD_BY_INDEX.get(idx, "")
	if field == "":
		return 0
	return int(get(field))


func set_data_by_index(idx: int, value: int) -> void:
	var field: String = FIELD_BY_INDEX.get(idx, "")
	if field == "":
		return
	set(field, value)


func add_data_by_index(idx: int, delta: int) -> void:
	set_data_by_index(idx, get_data_by_index(idx) + delta)


func size() -> int:
	return FIELD_NAMES.size()


func _collect_values() -> Array[int]:
	var arr: Array[int] = []
	arr.resize(FIELD_NAMES.size())
	for i in FIELD_NAMES.size():
		arr[i] = int(get(FIELD_NAMES[i]))
	return arr


const FIELD_NAMES: Array[String] = [
"mil_intervention", "party_support", "soviet_influence", "people_support", "thought_freedom", "living_standard", "diplomatic_reputation", "global_influence", "budget", "agents", "usa_influence", "science", "industry", "agriculture", "ideology", "party_system", "econ_system", "press_policy", "territory_policy", "day", "month", "year", "army", "income", "import_needs", "trade_partners", "corruption", "investment_delay", "usa_relations", "ussr_relations", "communications", "war_support", "naxalite_power", "econ_openness", "population", "ending_route", "reserve", "philippines_maoist_power", "stability", "war_pressure", "india_war_pressure", "thailand_election_intervention", "iran_left_support", "iran_shah_support", "iran_democrat_support", "iran_islamist_support", "afghan_opposition", "random_diplo_param", "afghan_khalq", "afghan_parcham", "religion_policy", "military_doctrine", "econ_display", "party_ban_count", "political_display", "political_openness", "political_line", "manpower", "data_58", "soviet_succession", "albania_break", "data_61", "arunachal_status", "taiwan_islands", "taiwan_status", "hk_macau_status", "xinjiang_policy", "tibet_policy", "services", "loan", "export_base", "budget_army", "budget_mgb", "budget_science", "budget_admin", "budget_envelope", "budget_propaganda", "budget_agri", "budget_industry", "budget_services", "budget_welfare", "budget_diplo", "war_resolve", "korea_result", "gang_of_four_path", "palestine_status", "yugoslavia_kosovo_chain", "post_mao_course", "democracy_movement", "reform_stage", "mao_history_line", "india_election", "reform_momentum", "data_93", "afghan_policy", "soviet_leader_chernenko", "soviet_leader_andropov", "soviet_leader_shcherbitsky", "soviet_leader_romanov", "soviet_leader_grishin", "soviet_successor_third", "data_101", "five_year_plan_focus", "africa_coup_route", "mao_mausoleum", "birth_policy", "satisfied", "afghan_war_path", "oligarch", "data_109", "political_repression_count", "hardline_crackdown_count", "soviet_interventions", "protest_repression", "killed_premier_flag", "killed_military_flag", "killed_foreign_flag", "iraq_development_sentinel", "automation_progress", "election_month_first", "ally_crisis_target", "election_month_second", "data_122", "data_123", "turkish_pan_turkic_chain", "election_timer", "turkish_straits_crisis", "turkish_route_result", "turkish_straits_state", "cyprus_greek_victory_flag", "mongolia_china_route", "world_political_balance", "soviet_eastern_europe_intervention", "soviet_reorganization_war_state", "italian_radical_left_power", "restore_agent_mod_47", "restore_agent_mod_48", "restore_econ_alliance", "restore_okb_alliance", "alliance_kickout_timer", "alliance_kickout_type", "alliance_coercion_target", "alliance_coercion_progress", "oil_price", "data_144", "data_145", "foreign_aid", "britain_political_route", "data_148", "soviet_successor_route", "soviet_intervention_cooldown", "usa_intervention_cooldown", "industry_base", "modifier_58_timer", "data_154", "france_socialist_vote", "france_communist_vote", "somalia_war_state", "somalia_china_route", "data_159", "soviet_money", "usa_money", "org_strength_1", "org_strength_2", "org_strength_3", "org_strength_4", "bico_strength", "data_167", "support_sent_flag", "ireland_unification_route", "event999_trigger_sentinel", "vietnam_pro_china_coup_available", "italy_power_172", "italy_power_173", "italy_power_174", "italy_power_175", "italy_power_176", "italy_power_177", "italy_power_178", "italy_power_179", "italy_power_180", "italy_power_181", "short_sword_power", "italy_event_timer", "italy_hot_autumn_route", "anthem_choice", "iraq_revolution_timer"
]

const FIELD_BY_INDEX := {
	0: "mil_intervention",
	1: "party_support",
	2: "soviet_influence",
	3: "people_support",
	4: "thought_freedom",
	5: "living_standard",
	6: "diplomatic_reputation",
	7: "global_influence",
	8: "budget",
	9: "agents",
	10: "usa_influence",
	11: "science",
	12: "industry",
	13: "agriculture",
	14: "ideology",
	15: "party_system",
	16: "econ_system",
	17: "press_policy",
	18: "territory_policy",
	19: "day",
	20: "month",
	21: "year",
	22: "army",
	23: "income",
	24: "import_needs",
	25: "trade_partners",
	26: "corruption",
	27: "investment_delay",
	28: "usa_relations",
	29: "ussr_relations",
	30: "communications",
	31: "war_support",
	32: "naxalite_power",
	33: "econ_openness",
	34: "population",
	35: "ending_route",
	36: "reserve",
	37: "philippines_maoist_power",
	38: "stability",
	39: "war_pressure",
	40: "india_war_pressure",
	41: "thailand_election_intervention",
	42: "iran_left_support",
	43: "iran_shah_support",
	44: "iran_democrat_support",
	45: "iran_islamist_support",
	46: "afghan_opposition",
	47: "random_diplo_param",
	48: "afghan_khalq",
	49: "afghan_parcham",
	50: "religion_policy",
	51: "military_doctrine",
	52: "econ_display",
	53: "party_ban_count",
	54: "political_display",
	55: "political_openness",
	56: "political_line",
	57: "manpower",
	58: "data_58",
	59: "soviet_succession",
	60: "albania_break",
	61: "data_61",
	62: "arunachal_status",
	63: "taiwan_islands",
	64: "taiwan_status",
	65: "hk_macau_status",
	66: "xinjiang_policy",
	67: "tibet_policy",
	68: "services",
	69: "loan",
	70: "export_base",
	71: "budget_army",
	72: "budget_mgb",
	73: "budget_science",
	74: "budget_admin",
	75: "budget_envelope",
	76: "budget_propaganda",
	77: "budget_agri",
	78: "budget_industry",
	79: "budget_services",
	80: "budget_welfare",
	81: "budget_diplo",
	82: "war_resolve",
	83: "korea_result",
	84: "gang_of_four_path",
	85: "palestine_status",
	86: "yugoslavia_kosovo_chain",
	87: "post_mao_course",
	88: "democracy_movement",
	89: "reform_stage",
	90: "mao_history_line",
	91: "india_election",
	92: "reform_momentum",
	93: "data_93",
	94: "afghan_policy",
	95: "soviet_leader_chernenko",
	96: "soviet_leader_andropov",
	97: "soviet_leader_shcherbitsky",
	98: "soviet_leader_romanov",
	99: "soviet_leader_grishin",
	100: "soviet_successor_third",
	101: "data_101",
	102: "five_year_plan_focus",
	103: "africa_coup_route",
	104: "mao_mausoleum",
	105: "birth_policy",
	106: "satisfied",
	107: "afghan_war_path",
	108: "oligarch",
	109: "data_109",
	110: "political_repression_count",
	111: "hardline_crackdown_count",
	112: "soviet_interventions",
	113: "protest_repression",
	114: "killed_premier_flag",
	115: "killed_military_flag",
	116: "killed_foreign_flag",
	117: "iraq_development_sentinel",
	118: "automation_progress",
	119: "election_month_first",
	120: "ally_crisis_target",
	121: "election_month_second",
	122: "data_122",
	123: "data_123",
	124: "turkish_pan_turkic_chain",
	125: "election_timer",
	126: "turkish_straits_crisis",
	127: "turkish_route_result",
	128: "turkish_straits_state",
	129: "cyprus_greek_victory_flag",
	130: "mongolia_china_route",
	131: "world_political_balance",
	132: "soviet_eastern_europe_intervention",
	133: "soviet_reorganization_war_state",
	134: "italian_radical_left_power",
	135: "restore_agent_mod_47",
	136: "restore_agent_mod_48",
	137: "restore_econ_alliance",
	138: "restore_okb_alliance",
	139: "alliance_kickout_timer",
	140: "alliance_kickout_type",
	141: "alliance_coercion_target",
	142: "alliance_coercion_progress",
	143: "oil_price",
	144: "data_144",
	145: "data_145",
	146: "foreign_aid",
	147: "britain_political_route",
	148: "data_148",
	149: "soviet_successor_route",
	150: "soviet_intervention_cooldown",
	151: "usa_intervention_cooldown",
	152: "industry_base",
	153: "modifier_58_timer",
	154: "data_154",
	155: "france_socialist_vote",
	156: "france_communist_vote",
	157: "somalia_war_state",
	158: "somalia_china_route",
	159: "data_159",
	160: "soviet_money",
	161: "usa_money",
	162: "org_strength_1",
	163: "org_strength_2",
	164: "org_strength_3",
	165: "org_strength_4",
	166: "bico_strength",
	167: "data_167",
	168: "support_sent_flag",
	169: "ireland_unification_route",
	170: "event999_trigger_sentinel",
	171: "vietnam_pro_china_coup_available",
	172: "italy_power_172",
	173: "italy_power_173",
	174: "italy_power_174",
	175: "italy_power_175",
	176: "italy_power_176",
	177: "italy_power_177",
	178: "italy_power_178",
	179: "italy_power_179",
	180: "italy_power_180",
	181: "italy_power_181",
	182: "short_sword_power",
	183: "italy_event_timer",
	184: "italy_hot_autumn_route",
	185: "anthem_choice",
	186: "iraq_revolution_timer",
}

## 指定国家的资源查询。玩家国家走具名字段，非玩家国家查 CountryData 字段。
func get_data_value_for_country(tag: String, key: String) -> int:
	if tag == "ROOT" or tag == "":
		return get_data_value(key)
	var country := get_country_by_tag(tag)
	if country == null:
		push_warning("WorldState: 国家 %s 不存在" % tag)
		return 0
	match key.to_lower():
		"stability", "政治稳定": return country.stability
		"development", "发展": return country.development
		"sov_power": return country.sov_power
		"usa_power": return country.usa_power
		"prc_power": return country.prc_power
		_:
			push_warning("WorldState: 非玩家国家 %s 不支持资源查询 %s" % [tag, key])
			return 0


# ── 标记 ──

func set_flag(flag_name: String, value: bool) -> void:
	global_flags[flag_name] = value

func get_flag(flag_name: String) -> bool:
	return global_flags.get(flag_name, false)


# ── 原版数字事件状态查询（外交按钮老系统入口用） ──

## 原版 event_done[N]：N 事件已完成。覆盖表 > 旧 flag > EventEngine 注册表。
func event_done_num(num: int) -> bool:
	if event_done_overrides.has(num):
		return bool(event_done_overrides[num])
	if global_flags.get("event_done_%d" % num, false):
		return true
	if EventEngine != null:
		return EventEngine.event_done_by_number(num)
	return false


## 原版 resultOfEvents[N]：已完成事件的选项编号；未完成=0（原版 int 默认）。
func result_of_event_num(num: int) -> int:
	if result_of_event_overrides.has(num):
		return int(result_of_event_overrides[num])
	if EventEngine != null:
		return EventEngine.result_of_event_by_number(num)
	return 0


func set_event_done_num(num: int, value: bool) -> void:
	event_done_overrides[num] = value
	if not value:
		global_flags.erase("event_done_%d" % num)


func set_result_of_event_num(num: int, value: int) -> void:
	result_of_event_overrides[num] = value


## 原版 ingamewars[i]（wars 数组即按战争 id 槽位存放）。
func get_war(idx: int) -> WarData:
	if idx >= 0 and idx < wars.size():
		return wars[idx]
	return null


func war_going(idx: int) -> bool:
	var war := get_war(idx)
	return war != null and war.is_going


## 原版 modifies[i].active。
func modifier_active(mod_id: int) -> bool:
	if mod_id >= 0 and mod_id < modifiers.size():
		var slot := modifiers[mod_id]
		return slot != null and slot.is_active
	return false


# ── 经济同步（轻量版，无数组拷贝） ──

## 原版 GameState.ImportChange（GameState.cs:11-16）：按生活水平×人口与三产差计算
## 进口需求年度增量；TimeScript.cs:514 每年 data.month==13 时 data.import_needs += ImportChange。
func import_change() -> int:
	var d := self
	var pop: float = float(mini(d.population if d.size() > I_POPULATION else 0, 1500))
	var living: int = d.living_standard if d.size() > I_LIVING else 0
	var industry_val: int = d.industry if d.size() > I_INDUSTRY else 0
	var agri: int = d.agriculture if d.size() > I_AGRICULTURE else 0
	var services_val: int = d.services if d.size() > I_SERVICES else 0
	var num := living * 2.0 / 1000.0 * pop - industry_val / 1000.0 * pop
	var num2 := living / 1000.0 * pop - agri * 2.0 / 1000.0 * pop
	var num3 := living / 1000.0 * pop - services_val / 1000.0 * pop
	return int((num + num2 + num3) / 200.0)


## 每 tick 结束后由 GameManager 调用一次，合并多次修改。
func flush_economy() -> void:
	if _economy_dirty:
		_economy_dirty = false
		_sync_economy()


func _sync_economy() -> void:
	if 玩家经济 == null:
		玩家经济 = EconomyData.new()
	玩家经济.sync_from_world(self)
	# 同步到玩家国家的 economy 引用（如果已分配）
	var player := get_player_country()
	if player != null and player.economy != null:
		player.economy = 玩家经济


## 在双周 tick 入口记录当前状态快照。
## 原版 TimeScript 在每 14 天周期开始时保存 array9，周期末写 data_old = 当前值 - array9；
## 这里改为开始时记录、悬浮提示读取时按需做差，结果等价。
func 记录入口快照() -> void:
	入口快照 = _collect_values()
	入口快照关系.clear()
	for e in empires:
		入口快照关系.append(e.relations)
	while 入口快照关系.size() < 2:
		入口快照关系.append(0)
	入口快照影响 = influence_prc


## 原版 data_old[idx] 的按需等价：自本双周入口以来的变化量。
## 关系(28/29)与全球影响力(7)的原版取值来源不是 data 数组，单独处理。
func 结算两周变化() -> void:
	if 入口快照.size() == 0:
		return
	上期变化 = _collect_values()
	for i in range(上期变化.size()):
		if i < 入口快照.size():
			上期变化[i] = get_data_by_index(i) - 入口快照[i]
	上期关系变化.clear()
	for i in range(2):
		var cur := 0
		var before := 0
		if empires.size() > i:
			cur = empires[i].relations
		if 入口快照关系.size() > i:
			before = 入口快照关系[i]
		上期关系变化.append(cur - before)
	上期影响变化 = influence_prc - 入口快照影响


## 原版 data_old[idx] 的等价读取；新游戏/读档缺失时返回 0（原版初值全 0）。
## 关系(28/29)与全球影响力(7)的原版取值来源不是 data 数组，单独处理。
func 两周变化(idx: int) -> int:
	if idx == I_USA_RELATIONS or idx == I_USSR_RELATIONS:
		var ei := 0 if idx == I_USA_RELATIONS else 1
		if 上期关系变化.size() > ei:
			return 上期关系变化[ei]
		return 0
	if idx == I_INFLUENCE:
		return 上期影响变化
	if idx >= 0 and idx < 上期变化.size():
		return 上期变化[idx]
	return 0


## 即时双周变化：直接用当前值减入口快照，供悬浮提示在鼠标悬停时立刻刷新，
## 不等待“结算两周变化”写入 上期变化。
func 即时两周变化(idx: int) -> int:
	if 入口快照.size() == 0:
		return 0
	if idx == I_USA_RELATIONS or idx == I_USSR_RELATIONS:
		var ei := 0 if idx == I_USA_RELATIONS else 1
		var before := 入口快照关系[ei] if ei < 入口快照关系.size() else 0
		var cur := empires[ei].relations if ei < empires.size() and empires[ei] != null else 0
		return cur - before
	if idx == I_INFLUENCE:
		return influence_prc - 入口快照影响
	if idx >= 0 and idx < 入口快照.size():
		return get_data_by_index(idx) - 入口快照[idx]
	return 0


## 外部调用入口（WorldFactory / GameManager.load_game 后调用一次）
func sync_economy() -> void:
	_sync_economy()


# ── 数值边界保护（移植自原版 TimeScript.BoundsOfVariables 6103-6199，调用点 6014）──

## 注意：原版只钳制以下项。Godot 早期版本额外钳制了 data.get_data_by_index(2/9/22/34/36/38/57/71-81)，
## 这些原版都不钳制（如 data.agents 特工允许为负，是合法显示状态）。已按原版对齐。
## 2026-08 经济审计：三产/生活上限应为 1500（Godot 曾写成 1000/500，导致 >=1100 衰减档不可达），
## data.global_influence influence 原版不钳制，已移除。

## 连续指标显示：内部 ×10 → "80.0"；预算/特工等同规则
func display_meter(raw: int) -> String:
	var prefix := "-" if raw < 0 else ""
	var v: int = absi(raw)
	var whole: int = int(v / 10.0)
	var frac: int = v % 10
	return "%s%d.%d" % [prefix, whole, frac]


## 关系显示：内部 ×10 → 整数 0~100
func display_relation(raw: int) -> String:
	return str(int(raw / 10.0))


func clamp_values() -> void:
	# data.industry/[13]/[68] 工业/农业/服务业：上限 1500
	if industry > 1500:
		industry = 1500
	if agriculture > 1500:
		agriculture = 1500
	if services > 1500:
		services = 1500
	# data.people_support/[4]/[1] 民众支持/思想自由/党支持：上限 1000
	if people_support > 1000:
		people_support = 1000
	if thought_freedom > 1000:
		thought_freedom = 1000
	if party_support > 1000:
		party_support = 1000
	# data.thought_freedom 思想自由下限 0
	if thought_freedom < 0:
		thought_freedom = 0
	# data.corruption 腐败下限 0，无上限
	if corruption < 0:
		corruption = 0
	# data.living_standard 生活水平：0-1500
	if living_standard < 0:
		living_standard = 0
	elif living_standard > 1500:
		living_standard = 1500
	# data.oligarch 寡头 0-100
	if oligarch < 0:
		oligarch = 0
	elif oligarch > 100:
		oligarch = 100
	# data.diplomatic_reputation 外交声誉下限 -50，随后原版直接 return（因此 >1100 的钳制不可达）
	if diplomatic_reputation < -50:
		diplomatic_reputation = -50
		return
	if diplomatic_reputation > 1100:
		diplomatic_reputation = 1100


# ── 超级大国关系与力量边界保护（BoundsOfVariables 5973-6028）──

## 关系值内部以 ×10 存储（0~1000 对应显示 0~100）。力量值同样 0~1000。
func clamp_empire_relations() -> void:
	for e in empires:
		if e != null:
			e.relations = clampi(e.relations, 0, 1000)
			e.power = clampi(e.power, 0, 1000)


# ── 政体谓词（移植自 GameState.cs:IsSocialism/IsAuthoritarianism）──

## 原版 IsSocialism(yes, country)。strict=true 对应 yes=true。
## yes=true : Gosstroy==1 或 SubGosstroy==0
## yes=false: Gosstroy!=1 且 SubGosstroy!=0
func is_socialism(country: CountryData, strict: bool) -> bool:
	if country == null:
		return false
	if strict:
		return country.government == GameConstants.Government.SOCIALIST or country.sub_government == GameConstants.SubGovernment.LEFT_RADICAL
	return country.government != GameConstants.Government.SOCIALIST and country.sub_government != GameConstants.SubGovernment.LEFT_RADICAL


## 原版 IsAuthoritarianism(country)：Gosstroy==0 且 SubGosstroy!=0
func is_authoritarian(country: CountryData) -> bool:
	if country == null:
		return false
	return country.government == GameConstants.Government.AUTHORITARIAN and country.sub_government != GameConstants.SubGovernment.LEFT_RADICAL


# ── 非洲联盟决议谓词（GlobalScript.cs:56 的 Decision 条件链） ──
## 原版入口在 Decision 系统（Godot 决议界面移植说明），目前由外交面板故事行动调用
## can_found_african_union() 作为同一条件链，然后 start_event("african_union")。
## 各谓词逐项对应 QueryDecisions:
##   HasRevolutionaryLeader(true)            → QueryDecisions.cs:1677-1696
##   HasMoney(200) / HasArmy(300)            → QueryDecisions.cs:161-177 / 221-237
##   IsChineseInfluenceLessThan(false, 500)  → QueryDecisions.cs:1494-1515
##   IsAfricanProprc(true)                   → QueryDecisions.cs:5470-5499
##   IsAfricanSocialism(true)                → QueryDecisions.cs:5502-5540

func has_revolutionary_leader() -> bool:
	if leader == null:
		return false
	if leader.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
		return true
	var player := get_player_country()
	return leader.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE \
		and political_line == 0 \
		and player != null and player.sub_government == GameConstants.SubGovernment.MARXIST_LENINIST


## 原版 IsAfricanProprc(true)：几内亚(68)为社会主义且有对华贸易，
## 加纳(63)/上沃尔特-布基纳法索(61)/几内亚比绍(114)/坦桑尼亚(122)/赞比亚(124)/津巴布韦(127)
## 为社会主义且亲中（Country_en 与 world_factory COUNTRY_NAMES 的 id 映射一致）。
func african_proprc_ready() -> bool:
	for legacy_idx in [63, 61, 114, 122, 127, 124]:
		var c := get_country_by_legacy_index(legacy_idx)
		if c == null or not c.has_tag("亲中") or not is_socialism(c, true):
			return false
	var guinea := get_country_by_legacy_index(68)
	return guinea != null and guinea.has_tag("对华贸易") and is_socialism(guinea, true)


## 原版 IsAfricanSocialism(true)：只数国家 id 落在范围集合内的数量，要求 >=6。
func african_socialism_count() -> int:
	var count := 0
	for c in countries:
		if c == null:
			continue
		var i := c.原版序号
		if i == 41 or i == 42 or i == 52 \
				or (i >= 56 and i <= 68) \
				or (i >= 106 and i <= 108) \
				or (i >= 112 and i <= 133 and i != 128) \
				or i == 99 or i == 100:
			count += 1
	return count


func can_found_african_union() -> bool:
	if size() <= I_BUDGET or size() <= I_RESERVE or size() <= I_ARMY:
		return false
	return has_revolutionary_leader() \
		and budget + reserve >= 200 \
		and army >= 300 \
		and influence_prc > 500 \
		and african_proprc_ready() \
		and african_socialism_count() >= 6
