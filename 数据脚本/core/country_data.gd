## 国家数据模型 — 移植自原版 Country.cs。
## 每个国家实例在 WorldState.countries 数组中。
class_name CountryData
extends Resource

# ── 意识形态体系 ──
# 4 种政体 (government/Gosstroy) → 23 种子意识形态 (sub_government/SubGosstroy)
# 名称严格对齐改版逆向主线资源 other_text_en.txt + CountryScript.cs:50-98：
#   sub 0-9  → other_text[sub+13]
#   sub 10-17 → other_text[sub+82]
#   sub 18  → other_text[182]（原版 162 号国硬编码为"托洛茨基外星红军"）
#   sub 19-22 → CountryScript.cs 硬编码

const GOV_NAME := {0: "威权主义", 1: "社会主义", 2: "改良主义", 3: "自由主义"}
const GOV_COLOR_NAME := {0: "灰色", 1: "红色", 2: "绿色", 3: "蓝色"}

## 政府地图模式黑色桶：仅 22 革命民族主义。
## 依据：
##   - 开局截图（用户实测）球内无黑国，故 7 右翼独裁 / 9 新法西斯 仍按 gov0 显示为威权灰；
##   - 22 只由后期事件产生（Event481.cs 结果2：Gosstroy=0, SubGosstroy=22
##     建立“民族革命先锋队”极右政权），此时才用黑色。
const EXTREMIST_SUBS := [22]

const IDEOLOGY := {
	0:  "左翼激进主义",   # other_text_en.txt idx13
	1:  "国控社会主义",   # idx14
	2:  "马列主义",       # idx15
	3:  "民主社会主义",   # idx16
	4:  "社会民主主义",   # idx17
	5:  "温和主义",       # idx18
	6:  "自由主义",       # idx19
	7:  "右翼独裁主义",   # idx20
	8:  "左倾保守主义",   # idx21
	9:  "新法西斯主义",   # idx22
	10: "左翼民族主义",   # idx92
	11: "铁托主义",       # idx93
	12: "新自由主义",     # idx94
	13: "新父权主义",     # idx95
	14: "欧洲共产主义",   # idx96
	15: "政治实用主义",   # idx97
	16: "苏式社会主义",   # idx98
	17: "毛主义",         # idx99
	18: "托洛茨基主义",   # idx182
	19: "封建社会主义",   # CountryScript.cs:75 硬编码
	20: "宪政威权主义",   # CountryScript.cs:81 硬编码
	21: "革新社会主义",   # CountryScript.cs:87 硬编码
	22: "革命民族主义",   # CountryScript.cs:93 硬编码
}

# 注意：原版没有 "SubGosstroy → government" 的唯一归属映射表。
# CountryScript 只把 Gosstroy（政体）与 SubGosstroy（子意识形态）独立显示，
# 且同一 sub 可配不同 gov（如 sub0：Event113.cs 配 0/0，GameState.cs 配 1/0）。
# 判断国家性质时直接比较 government / sub_government 本身，不要凭空造归属表。

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
## 联盟标签: nato, ovd, sev, eu, soc_eu, asean, sento, seato, okb, econ, oil, sc, fez, sto, oar, eaf, rim, au
## 外交倾向: 亲美, 亲中, 亲苏, 亲法, 对华贸易, 贸易同盟, 美国盟友, 苏联盟友, 法国盟友
@export var tags: Dictionary = {}

# ── 国内状态 ──
@export_category("国内状态")
@export var 内战中: bool = false       # 原 cw
@export var 政变中: bool = false       # 原 perevorot
@export var 有驻军基地: bool = false   # 原 based
@export var 君主制: bool = false       # 原 isMonatchy
@export var 禁用非洲机制: bool = false # 原 africaOff
@export var stab: int = 0              # 原 stab（C# int 默认 0；部分玩法按 0/1 标志，部分按稳定度数值）

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
## 原版 Country.soc_stab：GameStartScript.cs:208-228 构造时未赋值，C# int 默认 0；
## 仅事件/外交按钮显式写值（如 DiploButtonScript.cs:8852 =1000）。Godot 原默认 50 是自造初值，已对齐回 0。
@export var social_stability: int = 0
@export var development: int = 20
@export var level_of_development: int = 0
@export var level_of_instability: int = 0
@export var special: int = 0
@export var special_ending: int = -1

# ── 外交 ──
@export_category("外交")
@export var puppet_of: int = -1        # 宗主国 slot，-1=独立
## 原版 Country.next_elections = new DateTime(2222, 2, 22)
@export var next_election_year: int = 2222
@export var next_election_month: int = 2
@export var next_election_day: int = 22

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


# ── 势力圈返回码（与 国家面板.gd INFLUENCE_ICONS 的 key 一致）──
const SPHERE_USA := 0
const SPHERE_USSR := 1
const SPHERE_CHINA := 2
const SPHERE_NEUTRAL := 3
const SPHERE_FRANCE := 4
const SPHERE_SOUTH_AFRICA := 5
const SPHERE_AUSTRALIA := 6

## 原版地图影响模式/国家面板的法国判定（CountryScript.cs:302-305, 5150-5153）：
## puppetOf == 21，或法国自身保持中立（不亲中/不亲苏/不亲美）时显示法国势力。
func is_french_influence() -> bool:
	if has_tag("亲法") or has_tag("法国盟友"):
		return true
	if puppet_of == 21:
		return true
	return 原版序号 == 21 and not has_tag("亲中") and not has_tag("亲苏") and not has_tag("亲美")


## 原版澳大利亚势力（CountryScript.cs:379）：puppetOf == 135 时显示澳大利亚影响。
func is_australian_influence() -> bool:
	return puppet_of == 135


## 原版南非判定（CountryScript.cs:391-395, 5155-5158）：
## puppetOf == 131，或南非自身为 7 右翼独裁 / 9 新法西斯且中立时显示南非势力。
func is_south_african_influence() -> bool:
	if puppet_of == 131:
		return true
	return 原版序号 == 131 and not has_tag("亲中") and not has_tag("亲苏") \
		and not has_tag("亲美") and (sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN or sub_government == GameConstants.SubGovernment.NEO_FASCIST)


## 原版伊拉克势力（CountryScript.cs:5159-5162）：
## 被伊拉克傀儡，或伊拉克自身为 10 左翼民族主义 / 19 封建社会主义且中立。
func is_iraqi_influence() -> bool:
	if puppet_of == 14:
		return true
	return 原版序号 == 14 and not has_tag("亲中") and not has_tag("亲苏") \
		and not has_tag("亲美") and (sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST)


## 原版西班牙(85)势力（CountryScript.cs:5163-5166）：
## 被西班牙傀儡，或西班牙自身 sub==9、不亲中、不亲苏、不亲美。
func is_spanish_influence() -> bool:
	if puppet_of == 85:
		return true
	return 原版序号 == 85 and not has_tag("亲中") and sub_government == GameConstants.SubGovernment.NEO_FASCIST \
		and not has_tag("亲苏") and not has_tag("亲美")


## 原版联盟旗标生效区（CountryScript.cs:5167-5174）：
## 美国盟友/苏联盟友只在 id<53 或 id>=69 且 id!=61 的国家参与影响着色。
func alliance_zone_counts() -> bool:
	var sid := int(原版序号)
	return (sid < 53 or sid >= 69) and sid != 61


## 国家面板"在某国影响下"单槽判定。
## 原版分两个槽：Znach(4)=法国→美国→苏联→中国（:302-339），
## Znach(5)=南非等傀儡（:391-395）。Godot 合并为一个槽：
## 法国 → 南非 → 美国 → 苏联 → 中国，其余中立。
func in_sphere_of_influence() -> int:
	if is_french_influence(): return SPHERE_FRANCE
	if is_australian_influence(): return SPHERE_AUSTRALIA
	if is_south_african_influence(): return SPHERE_SOUTH_AFRICA
	if has_tag("亲美") or (alliance_zone_counts() and has_tag("美国盟友")): return SPHERE_USA
	if has_tag("亲苏") or (alliance_zone_counts() and has_tag("苏联盟友")): return SPHERE_USSR
	if has_tag("亲中"): return SPHERE_CHINA
	return SPHERE_NEUTRAL


# 兼容旧名 → 规范标签名映射
const TAG_ALIASES := {
	"is_nato": "nato", "is_ovd": "ovd", "is_sev": "sev", "is_eu": "eu",
	"is_soc_eu": "soc_eu", "is_asean": "asean", "is_sento": "sento",
	"is_seato": "seato", "is_okb": "okb", "is_econ": "econ", "is_oil": "oil",
	"is_sc": "sc", "is_fez": "fez", "is_sto": "sto", "is_oar": "oar",
	"is_eaf": "eaf", "is_rim": "rim", "is_au": "au",
	"is_fxseu": "fxseu", "is_nazimao": "nazimao", "is_balecon": "balecon",
	"is_olas": "olas",
	"is_vyshi": "亲美", "vyshi": "亲美",
	"is_proprc": "亲中", "proprc": "亲中",
	"is_prosov": "亲苏", "prosov": "亲苏",
	"is_profre": "亲法", "profre": "亲法",
	"is_torg": "对华贸易", "torg": "对华贸易",
	"is_dota": "贸易同盟", "dota": "贸易同盟",
	"is_usalliance": "美国盟友", "usalliance": "美国盟友",
	"is_sovalliance": "苏联盟友", "sovalliance": "苏联盟友",
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


# ── 原版 Country.cs 外交方法镜像 ──

## Country.EstablishGovernment（Country.cs:6-33）
## kind：0=亲美 1=亲苏 2=亲中 3=中立。
func establish_government(kind: int) -> void:
	set_tag("亲中", kind == 2)
	set_tag("亲苏", kind == 1)
	set_tag("亲美", kind == 0)


## Country.LeaveAlliances（Country.cs:89-115）
func leave_alliances() -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "asean",
			"seato", "oar", "oil", "sento", "fxseu", "nazimao", "balecon",
			"rim", "au", "olas"]:
		set_tag(tag, false)
	set_tag("亲苏", false)
	set_tag("亲美", false)
	set_tag("亲中", false)
	set_tag("对华贸易", false)
	puppet_of = -1


## Country.JoinASEAN / JoinSEATO / JoinSENTO / JoinEU / JoinOKB / JoinECON / JoinComecon / JoinWP
func join_asean() -> void: set_tag("asean", true)
func leave_asean() -> void: set_tag("asean", false)
func join_seato() -> void: set_tag("seato", true)
func leave_seato() -> void: set_tag("seato", false)
func join_sento() -> void: set_tag("sento", true)
func leave_sento() -> void: set_tag("sento", false)
func join_eu() -> void: set_tag("eu", true)
func leave_eu() -> void: set_tag("eu", false)
func join_okb() -> void: set_tag("okb", true)
func leave_okb() -> void: set_tag("okb", false)
func join_econ() -> void: set_tag("econ", true)
func leave_econ() -> void: set_tag("econ", false)
func join_comecon() -> void: set_tag("sev", true)
func leave_comecon() -> void: set_tag("sev", false)
func join_wp() -> void: set_tag("ovd", true)
func leave_wp() -> void: set_tag("ovd", false)
func join_nato() -> void: set_tag("nato", true)
func leave_nato() -> void: set_tag("nato", false)
func join_oar() -> void: set_tag("oar", true)
func leave_oar() -> void: set_tag("oar", false)


## Country.AddAmericanInfluence / AddSovietInfluence / AddChineseInfluence
func add_american_influence(delta: int) -> void: usa_power += delta
func add_soviet_influence(delta: int) -> void: sov_power += delta
func add_chinese_influence(delta: int) -> void: prc_power += delta


## Country.SetSystem / AddStability / AddEconomicPotential（注意原版 AddEconomicPotential 是赋值不是加）
func set_system(gov: int) -> void: government = gov
func add_stability(delta: int) -> void: stab += delta
func set_development(value: int) -> void: development = value
