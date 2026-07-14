## 国家数据模型 — 移植自原版 Country.cs。
## 每个国家实例在 WorldState.countries 数组中。
class_name CountryData
extends Resource

# ── 意识形态体系 ──
# 4 种政体 (government/Gosstroy) → 23 种子意识形态 (sub_government/SubGosstroy)

const GOV_NAME := {0: "威权主义", 1: "社会主义", 2: "改良主义", 3: "自由主义"}
const GOV_COLOR_NAME := {0: "灰色", 1: "红色", 2: "绿色", 3: "蓝色"}

const IDEOLOGY := {
	# 威权主义 (government=0) — 灰色
	0:  "右翼独裁主义",
	7:  "新法西斯主义",
	9:  "左翼民族主义",
	10: "新父权主义",
	13: "封建社会主义",
	17: "宪政威权主义",
	# 原版无独立编号的"革命民族主义"，用保留值
	19: "革命民族主义",
	# 社会主义 (government=1) — 红色
	1:  "左翼激进主义",
	2:  "国控社会主义",
	16: "马列主义",
	18: "苏式社会主义",
	# 毛主义与托洛茨基主义在原版SubGosstroy中无独立编号，复用保留值
	20: "毛主义",
	21: "托洛茨基主义",
	# 改良主义 (government=2) — 绿色
	3:  "民主社会主义",
	8:  "左倾保守主义",
	11: "铁托主义",
	14: "欧洲共产主义",
	15: "政治实用主义",
	22: "革新社会主义",
	# 自由主义 (government=3) — 蓝色
	4:  "社会民主主义",
	5:  "温和主义",
	6:  "自由主义",
	12: "新自由主义",
}

# SubGosstroy → 所属 government 映射
const IDEOLOGY_TO_GOV := {
	0:0, 7:0, 9:0, 10:0, 13:0, 17:0, 19:0,
	1:1, 2:1, 16:1, 18:1, 20:1, 21:1,
	3:2, 8:2, 11:2, 14:2, 15:2, 22:2,
	4:3, 5:3, 6:3, 12:3,
}

# ── 标识 ──
@export_category("标识")
@export var slot: int = 0
## G&W 国家编码（国际标准，如 710=中国）
@export var gwcode: int = 0
## 原版数组下标（事件脚本通过 allcountries[N] 引用国家）
@export var 原版序号: int = -1
@export var name: String = ""
@export var chinese_name: String = ""
## 按政体区分的国名 {government_int → "国名"}，没设置的政体回退 chinese_name
@export var gov_names: Dictionary = {}

# ── 政体 ──
@export_category("政体")
## 政体类型：0=威权 1=社会主义 2=改良 3=自由
@export var government: int = 0
## 政体子类型（子意识形态编号）
@export var sub_government: int = 0

# ── 多边组织 + 外交倾向（统一 Dictionary 存储） ──
## 所有联盟/外交标签统一存储。key=标签名(String), value=true/false。
## 联盟标签: nato, ovd, sev, eu, soc_eu, asean, sento, seato, okb, econ, oil, sc, fez, sto, oar, eaf
## 外交倾向: 亲美, 亲中, 亲苏, 亲法, 对华贸易, 贸易同盟, 美国盟友, 苏联盟友, 法国盟友
@export var tags: Dictionary = {}

# ── 国内状态 ──
@export_category("国内状态")
@export var 内战中: bool = false       # 原 cw
@export var 政变中: bool = false       # 原 perevorot
@export var 有驻军基地: bool = false   # 原 based
@export var 君主制: bool = false       # 原 isMonatchy
@export var 禁用非洲机制: bool = false # 原 africaOff

# ── 大国影响力 ──
@export_category("大国影响力")
@export var sov_power: int = 0         # 苏联势力
@export var usa_power: int = 0         # 美国势力
@export var prc_power: int = 0         # 中国势力
@export var fre_power: int = 0         # 法国势力
@export var sov_influence: int = 0
@export var usa_influence: int = 0
@export var prc_influence: int = 0
@export var fre_influence: int = 0
@export var influence_china: int = 0   # 对华影响力阈值
@export var influence_nato: int = 0    # 对北约影响力阈值

# ── 数值属性 ──
@export_category("数值属性")
@export var stability: int = 50
@export var social_stability: int = 50
@export var development: int = 20
@export var level_of_development: int = 0
@export var level_of_instability: int = 0
@export var special: int = 0
@export var special_ending: int = -1

# ── 外交 ──
@export_category("外交")
@export var puppet_of: int = -1        # 宗主国 slot，-1=独立
@export var next_election_year: int = 2222
@export var next_election_month: int = 2

# ── 扩展 ──
@export_category("扩展数据")
@export var parts: Array[bool] = []
## 只给玩家国家分配，其他国家保持 null 以节省序列化体积
@export var economy: EconomyData
@export var politicians: Array[PoliticianData] = []
## 原版 Country_data 的 19 个原始字段（调试用）
@export var 原始字段: Array[int] = []


func _init(p_slot: int = 0, p_gwcode: int = 0, p_name: String = "") -> void:
	slot = p_slot
	gwcode = p_gwcode
	name = p_name


## 动态国名：按当前政体查 gov_names，没有则回退 chinese_name → name
func display_name() -> String:
	var gn: String = gov_names.get(government, "")
	if gn != "":
		return gn
	if chinese_name != "":
		return chinese_name
	return name


## 当前子意识形态名称
func ideology_name() -> String:
	return IDEOLOGY.get(sub_government, "未知")


func is_communist_bloc() -> bool:
	return has_tag("sev") or has_tag("ovd")


func in_sphere_of_influence() -> int:
	if has_tag("亲苏") or has_tag("苏联盟友"): return 1
	if has_tag("亲美") or has_tag("美国盟友"): return 0
	if has_tag("亲中"): return 2
	if has_tag("亲法") or has_tag("法国盟友"): return 4
	return 3


# 兼容旧名 → 规范标签名映射
const TAG_ALIASES := {
	"is_nato": "nato", "is_ovd": "ovd", "is_sev": "sev", "is_eu": "eu",
	"is_soc_eu": "soc_eu", "is_asean": "asean", "is_sento": "sento",
	"is_seato": "seato", "is_okb": "okb", "is_econ": "econ", "is_oil": "oil",
	"is_sc": "sc", "is_fez": "fez", "is_sto": "sto", "is_oar": "oar",
	"is_eaf": "eaf",
	"is_vyshi": "亲美", "is_proprc": "亲中", "is_prosov": "亲苏",
	"is_profre": "亲法", "is_torg": "对华贸易", "is_dota": "贸易同盟",
	"is_usalliance": "美国盟友",
}


## 标签查询（事件条件/联盟检查统一入口）
func has_tag(tag: String) -> bool:
	var canonical: String = TAG_ALIASES.get(tag, tag)
	return tags.get(canonical, false)


## 设置标签
func set_tag(tag: String, value: bool) -> void:
	var canonical: String = TAG_ALIASES.get(tag, tag)
	if value:
		tags[canonical] = true
	else:
		tags.erase(canonical)
