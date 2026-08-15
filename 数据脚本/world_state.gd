## 顶层游戏状态 — 存档的根对象。
## 数值表[200] 是唯一权威数据源，EconomyData 只是它的显示视图。
class_name WorldState
extends Resource

# ============================================================================
# 数值表索引常量 — 取代魔术数字
# ============================================================================

const I_MIL_INTERVENTION := 0   ## 军事介入点（原 data[0]）
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
const I_DAY := 19               ## 当前日（原 data[19]）
const I_MONTH := 20             ## 当前月（原 data[20]）
const I_YEAR := 21              ## 当前年（原 data[21]）
const I_ARMY := 22              ## 军力
const I_INCOME := 23            ## 收入
const I_IMPORT_NEEDS := 24      ## 进口需求
const I_TRADE_PARTNERS := 25    ## 贸易伙伴数
const I_CORRUPTION := 26        ## 腐败
const I_INVESTMENT_DELAY := 27  ## 改革开放后等待外资政策的月数（原 data[27]）
const I_USA_RELATIONS := 28    ## 对美关系镜像（权威在 empires[0].relations）
const I_USSR_RELATIONS := 29   ## 对苏关系镜像（权威在 empires[1].relations）
const I_COMMUNICATIONS := 30   ## 外交通信结构恢复度（原 data[30]）
const I_WAR_SUPPORT := 31       ## 战争支持度
const I_NAXALITE_POWER := 32    ## 印度纳萨尔派力量（原 data[32]）
const I_ECON_OPENNESS := 33     ## 经济开放度
const I_POPULATION := 34        ## 人口(万)
const I_ENDING_ROUTE := 35      ## 待进入的结局编号（原 data[35]）
const I_RESERVE := 36           ## 外汇储备
const I_STABILITY := 38         ## 政治稳定
const I_WAR_PRESSURE := 39      ## 中苏战争压力
const I_INDIA_WAR_PRESSURE := 40 ## 中印边境战争攻势（原 data[40]）
const I_IRAN_LEFT_SUPPORT := 42 ## 伊朗左翼势力（原 data[42]）
const I_IRAN_SHAH_SUPPORT := 43 ## 伊朗王室势力（原 data[43]）
const I_IRAN_DEMOCRAT_SUPPORT := 44 ## 伊朗民主派势力（原 data[44]）
const I_IRAN_ISLAMIST_SUPPORT := 45 ## 伊朗伊斯兰派势力（原 data[45]）
const I_AFGHAN_OPPOSITION := 46 ## 阿富汗亲华/毛派反对派势力（原 data[46]）
const I_AFGHAN_KHALQ := 48     ## 阿富汗人民派势力（原 data[48]）
const I_AFGHAN_PARCHAM := 49   ## 阿富汗旗帜派势力（原 data[49]）
const I_RELIGION := 50          ## 宗教政策
const I_MIL_DOCTRINE := 51      ## 军事学说
const I_ECON_DISPLAY := 52      ## 经济显示等级
const I_PARTY_BAN_COUNT := 53   ## 已禁止派系数（原 data[53]，Party_zapret 禁止计数）
const I_POLITICAL_DISPLAY := 54 ## 政治显示等级
const I_POLITICAL_OPENNESS := 55 ## 政治开放度
const I_POLITICAL_LINE := 56    ## 政治路线
const I_MANPOWER := 57          ## 兵源
const I_SOVIET_SUCCESSION := 59 ## 苏联领导层继承结果（原 data[59]，>0 表示勃列日涅夫已逝）
const I_ALBANIA_BREAK := 60     ## 中阿决裂/阿尔巴尼亚路线状态（原 data[60]）
const I_ARUNACHAL_STATUS := 62  ## 藏南/阿鲁纳恰尔状态（原 data[62]：0印度实控未承认、1承认、2/3已重建控制）
const I_TAIWAN_ISLANDS := 63    ## 台海岛屿控制（原 data[63]：0国民党、1解放军）
const I_TAIWAN_STATUS := 64     ## 台湾地位（原 data[64]：0现状、1独立主权、2省级特别行政区）
const I_HK_MACAU_STATUS := 65   ## 港澳回归路线（原 data[65]）
const I_XINJIANG_POLICY := 66   ## 新疆/维吾尔文化政策状态（原 data[66]）
const I_TIBET_POLICY := 67      ## 西藏文化政策状态（原 data[67]）
const I_SERVICES := 68          ## 服务业产值
const I_LOAN := 69              ## 国债
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
const I_WAR_RESOLVE := 82       ## 待结算战争 id，<0 无（原 data[82]）
const I_KOREA_RESULT := 83      ## 朝鲜战争统一方向（原 data[83]：1北胜、2南胜）
const I_GANG_OF_FOUR_PATH := 84 ## 四人帮处置路线（原 data[84]，事件25/26及后续链）
const I_PALESTINE_STATUS := 85  ## 巴以安排（原 data[85]）
const I_POST_MAO_COURSE := 87   ## 毛后文革/改革路线（原 data[87]，事件24及后续链）
const I_REFORM_STAGE := 89      ## 改革阶段（原 data[89]）
const I_MAO_HISTORY_LINE := 90  ## 毛泽东历史评价路线（原 data[90]）
const I_INDIA_ELECTION := 91    ## 印度大选结果（原 data[91]）
const I_REFORM_MOMENTUM := 92   ## 政策改革方向累计值（原 data[92]）
const I_PROJECTION := 93        ## 投射力（原 data[93]）
const I_AFGHAN_POLICY := 94     ## 阿富汗策略（原 data[94]）
const I_SOVIET_SUCCESSOR_THIRD := 100 ## 苏联第三继承人权重（原 data[100]）
const I_MAO_MAUSOLEUM := 104    ## 毛主席纪念堂状态（原 data[104]）
const I_BIRTH_POLICY := 105     ## 生育政策/人口增长基数（原版 data[105]：1一胎 2二胎 3无限制，开局=2）
const I_SATISFIED := 106        ## 满意现秩序者
const I_AFGHAN_WAR_PATH := 107  ## 阿富汗战争路线（原 data[107]）
const I_OLIGARCH := 108         ## 寡头影响力
const I_SOVIET_INTERVENTIONS := 112 ## 苏联武装干涉计数（原 data[112]）
const I_PROTEST_REPRESSION := 113 ## 抗议镇压状态（原 data[113]）
const I_FOREIGN_AID := 146     ## 外援强度（原版 data[146]，dota 消耗）
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
	"projection": I_PROJECTION, "投射力": I_PROJECTION,
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
	"data_41": 41,   # 原 data[41]（泰国选举干预标志，无正式命名键）
	"data_124": 124, # 原 data[124]（土耳其泛突厥/蒙古事件链标志，无正式命名键）
	"data_126": 126, # 原 data[126]（土耳其海峡危机标志，无正式命名键）
	"data_127": 127, # 原 data[127]（土耳其路线结果，无正式命名键）
	"data_133": 133, # 原 data[133]（苏联重组战争前置状态，无正式命名键）
	"data_149": 149, # 原 data[149]（苏斯洛夫/安德罗波夫继任路线：事件83=1、84=2、85=3，无正式命名键）
	"data_52": I_ECON_DISPLAY,   # 原 data[52]（经济显示等级，Event999 宪法分支判定 data[52]==37）
	"data_86": 86,               # 原 data[86]（南斯拉夫/科索沃事件链状态，Event76 使用）
	"data_117": 117,             # 原 data[117]（伊拉克发展度哨兵，Event75 触发条件 data[117]!=9）
	"data_170": 170,             # 原 data[170]（Event999 触发哨兵：==999 时开火，结果里清零）
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

# ── 全局标记（替代原版散落 bool） ──
@export var global_flags: Dictionary = {}

# ── 事件完成追踪（event_id → option_index：键存在=已完成，值=所选选项编号） ──
@export var completed_event_ids: Dictionary = {}

# ── 事件引擎运行时（随 WorldState 存档） ──
@export var event_pending_id: String = ""
## GameDate.tick_count 截止值（旧存档的 YYYYMMDD 由 EventEngine 读档时迁移）
@export var event_pending_deadline: int = -1
@export var event_chain_queue: Array[String] = []

# ── 政治家职位（dolshnost[8]，每槽记录持有人在 politicians 中的索引，-1=空缺） ──
# 0=总理 1=军委主席 2=外交部长 3=首都 4=北方 5=西方 6=南方 7=东方
@export var politics_positions: Array[int] = []

# ── 数值表：唯一权威数据源 ──
@export var 数值表: Array[int] = []

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
## 注：原版由 TimeScript 周期把它转化为各国 prc_power，此转化未移植 → 目前只累计。TODO
@export var influence_prc: int = 0
## 扶持极左派冷却：[0]=西欧、[1]=东欧（原版 war_active[0]/[1]）。
## 注：原版每年重置一次（TimeScript），年度重置未移植 → 目前只置位不重置。TODO
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
	数值表.resize(200)
	politics_positions.resize(8)
	politics_positions.fill(-1)


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


# ── 数值表读写 ──

func get_data_index(key: String) -> int:
	return 数值索引.get(key.to_lower(), -1)


func get_data_value(key: String) -> int:
	if key.to_lower() in ["war", "war_state"]:
		return war_state
	if key.to_lower() == "influence_prc":
		return influence_prc
	var idx := get_data_index(key)
	if idx >= 0 and idx < 数值表.size():
		return 数值表[idx]
	return 0


func set_data_value(key: String, value: int) -> void:
	if key.to_lower() in ["war", "war_state"]:
		war_state = value
		return
	if key.to_lower() == "influence_prc":
		influence_prc = value
		return
	var idx := get_data_index(key)
	if idx >= 0 and idx < 数值表.size():
		数值表[idx] = value
		_economy_dirty = true


func add_data_value(key: String, delta: int) -> void:
	if key.to_lower() in ["war", "war_state"]:
		war_state += delta
		return
	if key.to_lower() == "influence_prc":
		influence_prc += delta
		return
	var idx := get_data_index(key)
	if idx >= 0 and idx < 数值表.size():
		数值表[idx] += delta
		_economy_dirty = true


## 指定国家的资源查询。玩家国家走数值表，非玩家国家查 CountryData 字段。
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


# ── 经济同步（轻量版，无数组拷贝） ──

## 原版 GameState.ImportChange（GameState.cs:11-16）：按生活水平×人口与三产差计算
## 进口需求年度增量；TimeScript.cs:514 每年 data[20]==13 时 data[24] += ImportChange。
func import_change() -> int:
	var d := 数值表
	var pop: float = float(mini(d[I_POPULATION] if d.size() > I_POPULATION else 0, 1500))
	var living := d[I_LIVING] if d.size() > I_LIVING else 0
	var industry := d[I_INDUSTRY] if d.size() > I_INDUSTRY else 0
	var agri := d[I_AGRICULTURE] if d.size() > I_AGRICULTURE else 0
	var services := d[I_SERVICES] if d.size() > I_SERVICES else 0
	var num := living * 2.0 / 1000.0 * pop - industry / 1000.0 * pop
	var num2 := living / 1000.0 * pop - agri * 2.0 / 1000.0 * pop
	var num3 := living / 1000.0 * pop - services / 1000.0 * pop
	return int((num + num2 + num3) / 200.0)


## 每 tick 结束后由 GameManager 调用一次，合并多次修改。
func flush_economy() -> void:
	if _economy_dirty:
		_economy_dirty = false
		_sync_economy()


func _sync_economy() -> void:
	if 玩家经济 == null:
		玩家经济 = EconomyData.new()
	玩家经济.sync(数值表)
	# 同步到玩家国家的 economy 引用（如果已分配）
	var player := get_player_country()
	if player != null and player.economy != null:
		player.economy = 玩家经济


## 在双周 tick 入口记录当前状态快照。
## 原版 TimeScript 在每 14 天周期开始时保存 array9，周期末写 data_old = 当前值 - array9；
## 这里改为开始时记录、悬浮提示读取时按需做差，结果等价。
func 记录入口快照() -> void:
	入口快照 = 数值表.duplicate()
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
	上期变化 = 数值表.duplicate()
	for i in range(上期变化.size()):
		if i < 入口快照.size():
			上期变化[i] = 数值表[i] - 入口快照[i]
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


## 外部调用入口（WorldFactory / GameManager.load_game 后调用一次）
func sync_economy() -> void:
	_sync_economy()


# ── 数值边界保护（移植自原版 TimeScript.BoundsOfVariables 6103-6199，调用点 6014）──

## 注意：原版只钳制以下项。Godot 早期版本额外钳制了 data[2/9/22/34/36/38/57/71-81]，
## 这些原版都不钳制（如 data[9] 特工允许为负，是合法显示状态）。已按原版对齐。
## 2026-08 经济审计：三产/生活上限应为 1500（Godot 曾写成 1000/500，导致 >=1100 衰减档不可达），
## data[7] influence 原版不钳制，已移除。

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
	# data[12]/[13]/[68] 工业/农业/服务业：上限 1500
	if 数值表[I_INDUSTRY] > 1500:
		数值表[I_INDUSTRY] = 1500
	if 数值表[I_AGRICULTURE] > 1500:
		数值表[I_AGRICULTURE] = 1500
	if 数值表[I_SERVICES] > 1500:
		数值表[I_SERVICES] = 1500
	# data[3]/[4]/[1] 民众支持/思想自由/党支持：上限 1000
	if 数值表[I_PEOPLE_SUPPORT] > 1000:
		数值表[I_PEOPLE_SUPPORT] = 1000
	if 数值表[I_THOUGHT_FREEDOM] > 1000:
		数值表[I_THOUGHT_FREEDOM] = 1000
	if 数值表[I_PARTY_SUPPORT] > 1000:
		数值表[I_PARTY_SUPPORT] = 1000
	# data[4] 思想自由下限 0
	if 数值表[I_THOUGHT_FREEDOM] < 0:
		数值表[I_THOUGHT_FREEDOM] = 0
	# data[26] 腐败下限 0，无上限
	if 数值表[I_CORRUPTION] < 0:
		数值表[I_CORRUPTION] = 0
	# data[5] 生活水平：0-1500
	if 数值表[I_LIVING] < 0:
		数值表[I_LIVING] = 0
	elif 数值表[I_LIVING] > 1500:
		数值表[I_LIVING] = 1500
	# data[108] 寡头 0-100
	if 数值表[I_OLIGARCH] < 0:
		数值表[I_OLIGARCH] = 0
	elif 数值表[I_OLIGARCH] > 100:
		数值表[I_OLIGARCH] = 100
	# data[6] 外交声誉下限 -50，随后原版直接 return（因此 >1100 的钳制不可达）
	if 数值表[I_DIPLO] < -50:
		数值表[I_DIPLO] = -50
		return
	if 数值表[I_DIPLO] > 1100:
		数值表[I_DIPLO] = 1100


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
		return country.government == 1 or country.sub_government == 0
	return country.government != 1 and country.sub_government != 0


## 原版 IsAuthoritarianism(country)：Gosstroy==0 且 SubGosstroy!=0
func is_authoritarian(country: CountryData) -> bool:
	if country == null:
		return false
	return country.government == 0 and country.sub_government != 0


# ── 非洲联盟决议谓词（GlobalScript.cs:56 的 Decision 条件链） ──
## 原版入口在 Decision 系统（Godot 决议界面未移植），目前由外交面板故事行动调用
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
	if leader.trait_personality == 0:
		return true
	var player := get_player_country()
	return leader.trait_personality == 20 \
		and 数值表[I_POLITICAL_LINE] == 0 \
		and player != null and player.sub_government == 2


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
	if 数值表.size() <= I_BUDGET or 数值表.size() <= I_RESERVE or 数值表.size() <= I_ARMY:
		return false
	return has_revolutionary_leader() \
		and 数值表[I_BUDGET] + 数值表[I_RESERVE] >= 200 \
		and 数值表[I_ARMY] >= 300 \
		and influence_prc > 500 \
		and african_proprc_ready() \
		and african_socialism_count() >= 6
