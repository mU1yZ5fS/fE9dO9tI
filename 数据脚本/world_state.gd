## 顶层游戏状态 — 存档的根对象。
## 数值表[200] 是唯一权威数据源，EconomyData 只是它的显示视图。
class_name WorldState
extends Resource

# ============================================================================
# 数值表索引常量 — 取代魔术数字
# ============================================================================

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
const I_ARMY := 22              ## 军力
const I_INCOME := 23            ## 收入
const I_IMPORT_NEEDS := 24      ## 进口需求
const I_TRADE_PARTNERS := 25    ## 贸易伙伴数
const I_CORRUPTION := 26        ## 腐败
const I_WAR_SUPPORT := 31       ## 战争支持度
const I_ECON_OPENNESS := 33     ## 经济开放度
const I_POPULATION := 34        ## 人口(万)
const I_RESERVE := 36           ## 外汇储备
const I_STABILITY := 38         ## 政治稳定
const I_WAR_PRESSURE := 39      ## 中苏战争压力
const I_RELIGION := 50          ## 宗教政策
const I_MIL_DOCTRINE := 51      ## 军事学说
const I_ECON_DISPLAY := 52      ## 经济显示等级
const I_POLITICAL_DISPLAY := 54 ## 政治显示等级
const I_POLITICAL_OPENNESS := 55 ## 政治开放度
const I_POLITICAL_LINE := 56    ## 政治路线
const I_MANPOWER := 57          ## 兵源
const I_BIRTH_POLICY := 105     ## 生育政策/人口增长基数（原版 data[105]：0一胎 1二胎 2无限制）
const I_FOREIGN_AID := 146     ## 外援强度（原版 data[146]，dota 消耗）
const I_USA_RELATIONS := 28    ## 对美关系镜像（权威在 empires[0].relations）
const I_USSR_RELATIONS := 29   ## 对苏关系镜像（权威在 empires[1].relations）
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
const I_SATISFIED := 106        ## 满意现秩序者
const I_OLIGARCH := 108         ## 寡头影响力
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
	"economy_system": I_ECON_SYSTEM, "economic_system": I_ECON_SYSTEM, "经济体制": I_ECON_SYSTEM,
	"speech_policy": I_PRESS_POLICY, "press_policy": I_PRESS_POLICY, "舆论政策": I_PRESS_POLICY,
	"territorial_policy": I_TERRITORY, "领土制度": I_TERRITORY,
	"religion_policy": I_RELIGION, "宗教政策": I_RELIGION,
	"day": 19, "month": 20, "year": 21,
	"army": I_ARMY, "army_strength": I_ARMY, "military": I_ARMY, "军力": I_ARMY,
	"corruption": I_CORRUPTION, "腐败": I_CORRUPTION,
	"war_support": I_WAR_SUPPORT,
	"population": I_POPULATION, "人口": I_POPULATION,
	"money_reserve": I_RESERVE, "reserve": I_RESERVE, "外汇": I_RESERVE,
	"political_stability": I_STABILITY, "政治稳定": I_STABILITY,
	"war_pressure": I_WAR_PRESSURE, "sino_soviet_war_pressure": I_WAR_PRESSURE,
	"military_doctrine": I_MIL_DOCTRINE, "军事学说": I_MIL_DOCTRINE,
	"political_line": I_POLITICAL_LINE, "政治路线": I_POLITICAL_LINE,
	"manpower": I_MANPOWER, "兵源": I_MANPOWER,
	"services": I_SERVICES, "服务业": I_SERVICES,
	"loan": I_LOAN, "debt": I_LOAN, "国债": I_LOAN,
	"satisfied": I_SATISFIED, "满意现秩序者": I_SATISFIED,
	"oligarch": I_OLIGARCH, "寡头": I_OLIGARCH,
	"birth_policy": I_BIRTH_POLICY, "生育政策": I_BIRTH_POLICY,
	"foreign_aid": I_FOREIGN_AID, "外援": I_FOREIGN_AID,
	"usa_relations": I_USA_RELATIONS, "对美关系": I_USA_RELATIONS,
	"ussr_relations": I_USSR_RELATIONS, "对苏关系": I_USSR_RELATIONS,
}

# ── 时间 ──
@export var date: GameDate

# ── 核心数据 ──
@export var countries: Array[CountryData] = []
@export var politicians: Array[PoliticianData] = []
@export var leader: PoliticianData
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

# ── 数值表：唯一权威数据源 ──
@export var 数值表: Array[int] = []

# ── 玩家经济显示视图（只读镜像，非独立数据） ──
@export var 玩家经济: EconomyData

# ── 运行时缓存（不序列化） ──
var _gwcode_cache: Dictionary = {}
var _gwcode_cache_built: bool = false
var _tag_cache: Dictionary = {}
var _tag_cache_built: bool = false
var _slot_cache: Dictionary = {}
var _slot_cache_built: bool = false
var _economy_dirty: bool = false


func _init() -> void:
	date = GameDate.new()
	techs = TechState.new()
	decisions = DecisionState.new()
	玩家经济 = EconomyData.new()
	数值表.resize(200)


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
	var idx := get_data_index(key)
	if idx >= 0 and idx < 数值表.size():
		return 数值表[idx]
	return 0


func set_data_value(key: String, value: int) -> void:
	if key.to_lower() in ["war", "war_state"]:
		war_state = value
		return
	var idx := get_data_index(key)
	if idx >= 0 and idx < 数值表.size():
		数值表[idx] = value
		_economy_dirty = true


func add_data_value(key: String, delta: int) -> void:
	if key.to_lower() in ["war", "war_state"]:
		war_state += delta
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


## 外部调用入口（WorldFactory / GameManager.load_game 后调用一次）
func sync_economy() -> void:
	_sync_economy()


# ── 数值边界保护（移植自原版 TimeScript.BoundsOfVariables 5943-6046）──

## 注意：原版只钳制以下项。Godot 早期版本额外钳制了 data[2/9/22/34/36/38/57/71-81]，
## 这些原版都不钳制（如 data[9] 特工允许为负，是合法显示状态）。已按原版对齐。

## 连续指标显示：内部 ×10 → "80.0"；预算/特工等同规则
func display_meter(raw: int) -> String:
	var sign := "-" if raw < 0 else ""
	var v: int = absi(raw)
	var whole: int = v / 10
	var frac: int = v % 10
	return "%s%d.%d" % [sign, whole, frac]


## 关系显示：内部 ×10 → 整数 0~100
func display_relation(raw: int) -> String:
	return str(raw / 10)


func clamp_values() -> void:
	var mod1_active: bool = modifiers.size() > 1 and modifiers[1] != null and modifiers[1].is_active
	# data[12] 工业：modifier[1] 激活时上限 500，否则 1000
	if 数值表[I_INDUSTRY] > 1000 and not mod1_active:
		数值表[I_INDUSTRY] = 1000
	elif 数值表[I_INDUSTRY] > 500 and mod1_active:
		数值表[I_INDUSTRY] = 500
	if 数值表[I_AGRICULTURE] > 1000:
		数值表[I_AGRICULTURE] = 1000
	if 数值表[I_SERVICES] > 1000:
		数值表[I_SERVICES] = 1000
	if 数值表[I_PEOPLE_SUPPORT] > 1000:
		数值表[I_PEOPLE_SUPPORT] = 1000
	if 数值表[I_THOUGHT_FREEDOM] > 1000:
		数值表[I_THOUGHT_FREEDOM] = 1000
	if 数值表[I_PARTY_SUPPORT] > 1000:
		数值表[I_PARTY_SUPPORT] = 1000
	if 数值表[I_THOUGHT_FREEDOM] < 0:
		数值表[I_THOUGHT_FREEDOM] = 0
	if 数值表[I_CORRUPTION] < 0:
		数值表[I_CORRUPTION] = 0   # 原版仅下限 0，无上限
	if 数值表[I_LIVING] < 0:
		数值表[I_LIVING] = 0
	elif 数值表[I_LIVING] > 1000:
		数值表[I_LIVING] = 1000
	if 数值表[I_INFLUENCE] < 0:
		数值表[I_INFLUENCE] = 0
	elif 数值表[I_INFLUENCE] > 1000:
		数值表[I_INFLUENCE] = 1000
	if 数值表[I_OLIGARCH] < 0:
		数值表[I_OLIGARCH] = 0
	elif 数值表[I_OLIGARCH] > 100:
		数值表[I_OLIGARCH] = 100
	if 数值表[I_DIPLO] < -50:
		数值表[I_DIPLO] = -50
		return  # 原版此处直接 return，跳过 >1100 钳制
	if 数值表[I_DIPLO] > 1100:
		数值表[I_DIPLO] = 1100


# ── 超级大国关系与力量边界保护（BoundsOfVariables 5973-6028）──

## 关系值内部以 ×10 存储（0~1000 对应显示 0~100）。力量值同样 0~1000。
func clamp_empire_relations() -> void:
	for e in empires:
		if e != null:
			e.relations = clampi(e.relations, 0, 1000)
			e.power = clampi(e.power, 0, 1000)
