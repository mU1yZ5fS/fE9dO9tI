# ============================================================================
# WorldFactory -- 嵌入式游戏数据 + WorldState 构建器
# ============================================================================
# 替代 DataLoader 的 .txt 文件解析方式，所有游戏初始数据直接内嵌为 const。
# 唯一的文件 I/O 是加载 map_countries.json（地图元数据，非原版游戏数据）。
#
# 用法：
#   var ws := WorldFactory.create_world(710, 2)
# ============================================================================
class_name WorldFactory
extends RefCounted


# ============================================================================
# 地图数据路径（gwcode 权威源）
# ============================================================================
const MAP_DIR: String = "res://资产/地图"
const INITIAL_DATA_DIR: String = "res://资产/数据/初始/"


# ============================================================================
# 国名别名表 -- 原版英文国名（规范化后）→ 新地图国名 的映射
# ============================================================================
## 地图上不存在的虚构/分离实体## 地图上不存在的虚构/分离实体：不得占用 G&W 真实 gwcode（否则点墨西哥会命中维吾尔斯坦）
## 统一映射到 9000+ 原版序号，避免与 map_countries 0~960 冲突
const FICTIONAL_COUNTRY_OFFSET := 9000

## 9000+ 实体的中文名## 9000+ 实体的中文名（逐行取自逆向 Assets/Resources/Country_en.txt 的 id 行）。
const OFFSET_COUNTRY_NAMES_ZH := {
	18: "西撒哈拉",
	69: "西藏", 70: "维吾尔斯坦",
	95: "库尔德斯坦",
	145: "格陵兰岛", 150: "南苏丹", 151: "达尔富尔",
	153: "纳米比亚", 155: "塞舌尔", 156: "阿扎瓦德",
	157: "库尔德斯坦二号", 159: "瓦努阿图", 162: "南极洲",
	163: "加丹加", 164: "安哥拉独", 165: "尼日利亚独", 166: "北爱尔兰",
	167: "魁北克", 168: "南墨西哥",
}


# ============================================================================
# 国家与派系原始数据行字段索引常量
# ============================================================================
enum CountryRowField {
	GWCODE = 0,
	# 1-10 对应联盟/外交标签
	STABILITY = 12,
	DEVELOPMENT = 13,
	SOV_POWER = 14,
	USA_POWER = 15,
	PRC_POWER = 16,
	GOVERNMENT = 17,
	SUB_GOVERNMENT = 18,
	# 以下 5 个字段只存在于 South_data.txt（原版 DLC00 补载，GameStartScript.cs:1719-1731）
	LEVEL_OF_DEV = 19,
	LEVEL_OF_UNSTAB = 20,
	ELECTION_DAY = 21,
	ELECTION_MONTH = 22,
	ELECTION_YEAR = 23
}

enum FactionRowField {
	ENABLED = 0,
	ALLY = 1,
	IDEOLOGY = 2,
	SUPPORT = 3
}


# ============================================================================
# 国家数据字段 1-10 对应的标签名
# ============================================================================
const TAG_FIELDS: Array[String] = [
	"", "sev", "ovd", "亲美", "亲中", "亲苏",
	"okb", "econ", "对华贸易", "美国盟友", "苏联盟友",
]

## Country.LeaveAlliances()（Country.cs:89-115）清除的联盟/外交标签，开局覆盖用
const START_CLEAR_TAGS: Array[String] = [
	"nato", "ovd", "sev", "eu", "soc_eu", "asean", "sento", "seato",
	"okb", "econ", "oil", "oar", "eaf", "rim", "au",
	"亲美", "亲苏", "亲中", "对华贸易", "美国盟友", "苏联盟友",
]


# ============================================================================
# 数值表 -- 150 个全局整数值（索引 0-149）
# ============================================================================
const DATA_VALUES := [
	#  0       1       2       3       4       5       6       7       8       9
	   0,    800,    300,    600,    100,    250,    830,     50,     30,     20,  # 0-9
	 280,      0,    350,    450,      1,      6,     11,     16,     20,      4,  # 10-19（[16]经济体制=11 中式计划，对齐 Data1.txt，原作 GameStartScript 只读不写）
	   2,   1976,     50,    480,    500,     14,    150,     50,    700,    300,  # 20-29（[23]收入480/[24]进口500/[25]贸易伙伴14：改回 Data1.txt 原值，原 96/100/0 系 Data1_d1 混入）
	  30,    500,    100,    200,   9307,    300,     50,    500,      5,      5,  # 30-39
	   5,      0,    100,    120,    100,    180,     30,     20,    200,    150,  # 40-49
	  24,     31,     34,      1,     38,    100,      1,    650,    -10,      0,  # 50-59
	   0,      0,      0,      0,      0,      0,      0,      0,    240,      0,  # 60-69
	 430,    100,    100,     70,    160,     60,     90,    140,    100,     60,  # 70-79（[70]预算军费=430：改回 Data1.txt 原值，原 86 系 Data1_d1 混入）
	  90,     70,    -10,      0,      0,      0,      0,      0,      0,      0,  # 80-89
	   0,      0,      0,      0,      0,      0,      0,      0,      0,      0,  # 90-99
	   0,      0,      0,      0,      0,      0,      0,      0,      0,      0,  # 100-109
	   0,      0,      0,      0,      0,      0,      0,      0,      0,      0,  # 110-119
	   0,      0,      0,      0,      0,      0,      0,      0,      0,      0,  # 120-129
	   0,      0,      0,      0,      0,      0,      0,      0,      0,      0,  # 130-139
	   0,      0,      0,      0,      0,      0,      0,      0,      0,      0,  # 140-149
]


# ============================================================================
# 国家原始数据 -- 主线 Country_data_1.txt（GameStartScript.cs:193-230，number=1）
# 99 个国家，每个 19 字段；South_data.txt 的 71-83 见 SOUTH_COUNTRY_ROWS（24 字段）
# [gwcode, sev, ovd, 亲美, 亲中, 亲苏, okb, econ, 对华贸易,
#  美国盟友, 苏联盟友, unused, stability, development,
#  sov_power, usa_power, prc_power, government, sub_government]
# 注意：严禁抄 Country_data_1_d1.txt —— 原版运行时代码没有任何 _d1 引用。
# ============================================================================
const COUNTRY_ROWS := [
	[0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],          # Luxemburg
	[2, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],          # Poland
	[3, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 16],         # Czechoslovakia
	[4, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 3],          # Hungary
	[5, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],          # Romania
	[6, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 16],         # Bulgaria
	[7, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 16],         # Soviet Union
	[8, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],         # Iran
	[9, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 16],         # Mongolia
	[10, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],         # North Korea
	[11, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10],         # Vietnam（0/10 左翼民族主义，主线 Country_data_1.txt:21；旧 1/1 系 d1 混入）
	[12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 15],        # Afghanistan（2/15 政治实用主义，主线 :23；旧 0/13 系 d1）
	[13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 15],        # Libya
	[14, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],         # Iraq
	[15, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 11],        # Yugoslavia
	[16, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 16],        # GDR
	[17, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5],         # FRG
	[18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 15],        # Western Sahara
	[19, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 15],        # India
	[20, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],         # Albania
	[21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # France
	[22, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10],         # Laos（亲苏+对华贸易，0/10 左翼民族主义，主线 :43；旧 1/1 系 d1）
	[23, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10],        # Kampuchea（0/10 左翼民族主义，主线 :45；旧 sub17 系 d1）
	[24, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],         # South Yemen（对华贸易，主线 :47；旧 亲苏 系 d1）
	[25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 8],         # North Yemen（2/8 左倾保守主义，主线 :49；旧 0/13 系 d1）
	[26, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 15],        # Finland
	[27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5],         # Austria
	[28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 3],         # Sweden
	[29, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # Ireland
	[30, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5],         # Egypt
	[31, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 8],         # Pakistan（2/8 左倾保守主义，主线 :61；旧 3/6 系 d1）
	[32, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],        # Bangladesh
	[33, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10],        # Burma
	[34, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # Thailand
	[35, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],         # Syria
	[36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7],         # Kuwait
	[37, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5],         # Israel
	[38, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7],         # Taiwan
	[39, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5],         # Switzerland
	[40, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 500, 400, 90, 20, 0, 0, 10],  # Algeria（政体 gov/sub=0/10 对齐 Country_data_1.txt；旧值 1/1 系误抄）
	[41, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 400, 300, 700, 200, 100, 0, 10], # Ethiopia
	[42, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 400, 250, 200, 100, 0, 1, 1], # Somalia
	[43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],        # Nepal
	[44, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # Japan
	[45, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # Greece
	[46, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7],         # South Korea
	[47, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7],         # Philippines
	[48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 8],         # Grenada
	[49, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 15],        # Malaysia
	[50, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7],         # Indonesia
	[51, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # USA
	[52, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],         # Congo (Brazzaville)（主线 52=刚果（布），:103；开局覆盖加对华贸易）
	[53, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 600, 300, 400, 200, 50, 0, 13], # Sudan
	[54, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 550, 400, 300, 0, 0, 0, 7],   # Morocco
	[55, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 400, 300, 0, 0, 0, 0, 7],     # Tunisia
	[56, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 500, 400, 0, 0, 0, 0, 13],    # Niger
	[57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 200, 100, 0, 0, 0, 0, 13],    # Chad
	[58, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 400, 250, 100, 200, 0, 0, 10], # Mali
	[59, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 300, 100, 0, 0, 0, 3, 12],    # Mauritania
	[60, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 200, 200, 0, 0, 0, 0, 13],    # Nigeria
	[61, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 400, 250, 0, 0, 0, 0, 13],    # Upper Volta
	[62, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 500, 300, 0, 0, 0, 1, 1],     # Benin
	[63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 300, 200, 0, 0, 0, 0, 13],    # Ghana
	[64, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 400, 400, 0, 0, 0, 0, 13],    # Côte d'Ivoire
	[65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 300, 100, 0, 0, 0, 0, 13],    # CAR
	[66, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 300, 200, 0, 0, 0, 0, 13],    # Cameroon
	[67, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 400, 300, 0, 0, 0, 3, 12],    # Liberia
	[68, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 400, 300, 0, 0, 0, 2, 15],    # Guinea
	[69, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 400, 300, 0, 0, 0, 0, 13],    # Tibet
	[70, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 400, 300, 0, 0, 0, 0, 13],    # Uyghuristan
	[1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 17],          # China（1/17 毛主义，主线 :141；旧 sub1 系 d1）
	[84, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # Turkey
	[85, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # Italy
	[86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7],         # Spain
	[87, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 15],        # Portugal
	[88, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5],         # Belgium
	[89, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5],         # Holland
	[90, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 4],         # Denmark
	[91, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 4],         # Norway
	[92, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # Great Britain
	[93, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],        # Lebanon
	[94, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # Divided Cyprus
	[95, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # Kurdistan
	[96, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 4],         # Sri Lanka
	[97, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],        # Bhutan
	[98, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10],        # Slovakia
	[99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10],        # Eritrea
	[100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10],       # Tigray
	[101, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],       # Saudi Arabia
	[102, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],       # UAE
	[103, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],       # Qatar
	[104, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],       # Jordania
	[105, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],       # Oman
	[106, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],       # Djibouti
	[107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],       # Sierra Leone
	[108, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],       # Togo
	[109, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],       # Basque Country
	[110, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],       # Catalonia
	[111, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],       # Ainu Utari
]


# ============================================================================
# South_data.txt（原版 GameStartScript.DLC00 补载，:1693-1731）— 南美 71-83
# 24 字段：19 基础字段 + level_of_dev / level_of_unstab / 选举日 / 月 / 年
# 注意：South_data 的 stab/dev/sov/usa/prc 字段（12-16）原值全为 0。
# ============================================================================
const SOUTH_COUNTRY_ROWS := [
	[71, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 9, 60, 50, 24, 3, 1976],  # Argentina 阿根廷
	[72, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 50, 50, 9, 7, 1978],   # Bolivia 玻利维亚
	[73, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 65, 50, 15, 10, 1978],  # Brazil 巴西
	[74, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 50, 50, 4, 1, 1978],   # Chile 智利
	[75, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6, 60, 50, 4, 6, 1978],   # Colombia 哥伦比亚
	[76, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 55, 50, 16, 7, 1978],  # Ecuador 厄瓜多尔
	[77, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 3, 50, 50, 15, 12, 1980], # Guyana 圭亚那
	[78, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 70, 50, 22, 2, 2222],  # French Guyana 法属圭亚那
	[79, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 50, 50, 12, 2, 1978],  # Paraguay 巴拉圭
	[80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 8, 60, 50, 18, 5, 1980],  # Peru 秘鲁
	[81, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 4, 50, 50, 25, 2, 1980],  # Surinam 苏里南
	[82, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 9, 55, 50, 1, 9, 1976],   # Uruguay 乌拉圭
	[83, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 4, 60, 50, 3, 12, 1978],  # Venezuela 委内瑞拉
]


# ============================================================================
# 国家英文名 -- 按原版 id 索引（0-166）
# ============================================================================
# ============================================================================
# 特质中文名# ============================================================================
# 特质中文名 — 逐字对齐原版 traits_en[44]（Stat.unity:55629 起 Politic_Manager.traits_en）。
# 7/17/18 按原版为「重视技术/羞怯/贪污」（旧值 科学家/胆怯/贪腐 已修正）。
# 重要：traits[0] 用 Traits 表（0-3/20），不是 Party 派系表！
#   Traits[0]: 0极左 1温和 2改革 3自由 / 20保守（Button_Pol_Script num14 特殊映射）
#   Party[0..4]: 0极左 1保守 2温和 3改革 4自由（改版显式 faction 字段）
# traits[1]: 4硬汉 5实用主义 6宽容 7重视技术 21-25 等扩展
# traits[2]: 8-19 特殊 / 30-43 扩展（34 托派已移入 traits[3]，随机池不再产出）
# traits[3]: 21-28/34/43 出身背景（34 托派：仅第四国际在线时可刷出）
# ============================================================================
const TRAIT_LABELS_ZH := {
	0: "极左派", 1: "温和派", 2: "改革派", 3: "自由派",
	4: "硬汉", 5: "实用主义", 6: "宽容", 7: "重视技术",
	8: "苛刻", 9: "和平", 10: "小暴君", 11: "经管学家", 12: "傲慢", 13: "偶像",
	14: "中华派", 15: "西渐派", 16: "谋士", 17: "羞怯", 18: "贪污", 19: "病弱",
	20: "保守派", 21: "党务干部", 22: "群众领袖", 23: "学生小将", 24: "工农劳模",
	25: "军队将领", 26: "知识分子", 27: "科学家", 28: "野心家", 29: "享乐主义",
	30: "阴谋论者", 31: "鼓动者", 32: "人民之友", 33: "外交人才", 34: "托派",
	35: "投机分子", 36: "治军有方", 37: "平易近人", 38: "不屈不挠", 39: "主观主义",
	40: "墙头草", 41: "一方诸侯", 42: "政治挂帅", 43: "特异人士",
}

## Party 派系显示名（faction_leader / 派系界面用，与 traits[0] 不同表）
const PARTY_LABELS_ZH := {
	0: "极左派", 1: "保守派", 2: "温和派", 3: "改革派", 4: "自由派",
}


# ============================================================================
# 派系数据 -- 5 个派系，每个 4 字段 [enabled, ally, ideology, seats]
# ============================================================================
const FACTION_ROWS := [
	[1, 0, 600, 600],   # 0 = 极左派
	[1, 0, 900, 900],   # 1 = 保守派
	[1, 0, 300, 300],   # 2 = 温和派
	[1, 0, 160, 200],   # 3 = 改革派
	[0, 0,  40,   0],   # 4 = 自由派
]

# 派系领袖 politician 索引，逐字对齐 GameStartScript.cs:535-539：
# faction_leader[0]=1(江青) [1]=10(吴德) [2]=6(李先念) [3]=12(邓小平) [4]=13(赵紫阳)
const FACTION_LEADERS := [1, 10, 6, 12, 13]


# ============================================================================
# 领导人初始设定 — 逐字对齐 Resources/Politics_leader.txt: "2;2;20;21;5;16;1921"
# = name_1=2; name_2=2; traits[0]=20; traits[1]=21; traits[2]=5; traits[3]=16; birth=1921
# 领袖是独立实体（UI 选中码 150），不在 politics[18] 数组里
# politics[0]=毛泽东（power 后改 99999），politics[1]=江青
# traits 显示按 traits_en：20=保守派 21=党务干部 5=实用主义 16=谋士
# ============================================================================
const LEADER_NAME := "华国锋"
const LEADER_AGE := 55
const LEADER_TRAITS := [20, 21, 5, 16]
const LEADER_NAME_FIRST := 2
const LEADER_NAME_LAST := 2
const LEADER_PORTRAIT_PATH := "res://资产/政治家/华国锋.png"
## 职位槽中表示「实权领袖本人」（原版 politics_dolshnost 值 150）
const LEADER_POSITION_SENTINEL := -2


# ============================================================================
# 初始修正 ID 列表
# ============================================================================
# 对齐 GameStartScript.cs:72-84：0,1,2,3,6,14,15,28,54,55,61,62,64；
# 另按 dlc[3] 恒真（Godot 改版全 DLC 免费可玩）补 42/50/56（GameStartScript.cs:87-89）。
# 51 号「黑金/OIL_MONEY」在原版也是 dlc[3] 环境下开局激活（GameStartScript.cs:829），
# 缺失会导致石油决议、石油经济、event_418 全部死锁；旧值未含 51，已补齐。
const START_MODIFIER_IDS := [0, 1, 2, 3, 6, 14, 15, 28, 42, 50, 51, 54, 55, 56, 61, 62, 64]


# ============================================================================
# 科技初始解锁状态（与 TechState.TECH_COUNT=34 对齐）
# ============================================================================
const SCIENCE_UNLOCKED := [
	false, false, false, false, false,
	false, false, false, false, false,
	false, false, false, false, false,
	false, false, false, false, false,
	false, false, false, false, false,
	false, false, false, false, false,
	false, false, false, false,
]


# ============================================================================
# 主入口 -- 创建新游戏世界状态
# ============================================================================

static func create_world(player_gwcode: int = 710, difficulty: int = 2) -> WorldState:
	var ws := WorldState.new()
	ws.date = GameDate.new(4, 2, 1976)
	ws.player_country_gwcode = player_gwcode
	ws.difficulty = difficulty
	# 铁人 = 难度 >= 2（GameStartScript.cs:120: iron_and_blood = diff >= 2；
	# 本端口 0沙盒/1简单/2普通/3困难）
	# 原版 GameStartScript.cs:1886-1888 若 gamerules 含 >1 则 iron_and_blood=false；
	# gamerules 移植说明，跳过（politician_system.gd:228 有移植说明读取口）。
	ws.is_ironman = difficulty >= 2
	# 玩法随机源种子：开局取系统时间，暗杀等真随机；rng_state 随存档续流
	ws.rng_seed = int(Time.get_unix_time_from_system())
	ws.rng_state = 0
	ws.ensure_rng()

	_build_countries(ws)
	_assign_real_gwcodes(ws)
	ws.rebuild_gwcode_index()
	_fill_data_array(ws)
	# 开局中国国际影响力 = 原版 Data1.txt data[7] = 50（顶栏 /10 显示 5.0），
	# 原版 GameStartScript.cs:304 influencePRC = data[7]；KumihaRepaint 每周期回写 data[7]。
	ws.influence_prc = 50
	# 原版 GameStartScript.cs:90：开局 OilProd=850；OilEat 由 modifier51/经济计算按公式生成。
	ws.oil_prod = 850.0
	_build_politicians(ws)
	_build_factions(ws)
	_set_leader(ws)
	_init_positions(ws)
	_init_politician_relations(ws)
	_init_modifiers(ws)
	_init_science(ws)
	_init_empires(ws)
	_init_wars(ws)
	_apply_post_load_overrides(ws, difficulty)

	# 为玩家国家分配经济显示视图
	var player := ws.get_player_country()
	if player != null:
		player.economy = ws.玩家经济
	ws.sync_economy()

	return ws


# ============================================================================
# 国家构建 -- 从嵌入数据创建 CountryData 对象
# ============================================================================

## 初始国家行数据：优先读 JSON，缺失时回退到内嵌常量。
static func _load_country_rows() -> Array:
	var path := INITIAL_DATA_DIR + "country_rows.json"
	if FileAccess.file_exists(path):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Array:
			return parsed
	return COUNTRY_ROWS


static func _load_south_country_rows() -> Array:
	var path := INITIAL_DATA_DIR + "south_country_rows.json"
	if FileAccess.file_exists(path):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Array:
			return parsed
	return SOUTH_COUNTRY_ROWS


# ============================================================================
# gwcode 修正 -- 用 country_identity.json 建立内部索引→真实 gwcode 映射
# ============================================================================

static func _apply_offset_name(c: CountryData) -> void:
	## 9000+ 实体没有 map_countries 条目，回退到逆向 Country_en.txt 的中文名
	if OFFSET_COUNTRY_NAMES_ZH.has(int(c.原版序号)):
		c.chinese_name = String(OFFSET_COUNTRY_NAMES_ZH[int(c.原版序号)])
		c.name = c.chinese_name


static func _load_country_identity() -> Dictionary:
	var path := INITIAL_DATA_DIR + "country_identity.json"
	var raw := _load_json_as_dict(path)
	var result := {}
	for k in raw:
		result[int(k)] = int(raw[k])
	return result


static func _apply_map_country_meta(c: CountryData, map_countries: Dictionary) -> void:
	if c == null or c.gwcode <= 0 or c.gwcode >= FICTIONAL_COUNTRY_OFFSET:
		return
	var gw_str := str(c.gwcode)
	if not map_countries.has(gw_str):
		return
	var entry: Dictionary = map_countries[gw_str]
	c.name = String(entry.get("name_1976", c.name))
	var zh_name: String = entry.get("name_zh", "")
	if zh_name != "":
		c.chinese_name = zh_name
	var gn = entry.get("gov_names", null)
	if gn is Dictionary:
		for k in gn:
			c.gov_names[int(k)] = String(gn[k])


static func _assign_real_gwcodes(ws: WorldState) -> void:
	var map_countries := _load_json_as_dict(MAP_DIR + "/map_countries.json")
	if map_countries.is_empty():
		push_warning("WorldFactory: map_countries.json 缺失，CountryData.gwcode 未修正")
		return

	# 国家身份唯一权威源：country_identity.json（legacy_id → gwcode），不再做英文名模糊匹配。
	var identity := _load_country_identity()
	if identity.is_empty():
		push_error("WorldFactory: country_identity.json 缺失，无法建立国家身份")
		for c in ws.countries:
			c.gwcode = FICTIONAL_COUNTRY_OFFSET + int(c.原版序号)
			_apply_offset_name(c)
		return

	var matched := 0
	for c in ws.countries:
		var sid := int(c.原版序号)
		if identity.has(sid):
			c.gwcode = int(identity[sid])
			_apply_map_country_meta(c, map_countries)
			if c.gwcode < FICTIONAL_COUNTRY_OFFSET:
				matched += 1
			else:
				# 9000+ 为地图上不存在的虚构/分离实体，map_countries 中没有中文名，
				# 必须用 OFFSET_COUNTRY_NAMES_ZH 补齐，否则加丹加等国不显示国名。
				_apply_offset_name(c)
		else:
			c.gwcode = FICTIONAL_COUNTRY_OFFSET + sid
			_apply_offset_name(c)
	print("WorldFactory: gwcode 按 country_identity.json 直查完成 %d/%d" % [matched, ws.countries.size()])


# ============================================================================
# 数值表 -- 从嵌入数组填充 WorldState.data_200
# ============================================================================

static func _fill_data_array(ws: WorldState) -> void:
	for i in DATA_VALUES.size():
		ws.set_data_by_index(i, DATA_VALUES[i])
	print("WorldFactory: soviet_intervention_cooldown 加载完成")


static func _build_countries(ws: WorldState) -> void:
	# 行来源（与逆向加载顺序一致）：
	#   1. Country_data_1.txt 主表（0-70、1、84-111 已在 COUNTRY_ROWS 中）
	#   2. South_data.txt 南美 71-83（DLC00 补载）
	#   3. Country_data_1.txt 112-166：原版 55 行字段完全同构，批量生成
	#     167/168 为项目补建的魁北克/南墨西哥虚拟国（原版事件引用但原版不生成独立国家）
	var rows: Array = []
	rows.append_array(_load_country_rows())
	rows.append_array(_load_south_country_rows())
	for i in range(112, 169):
		rows.append([i, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13])

	for row in rows:
		var cd := CountryData.new()
		cd.gwcode = row[CountryRowField.GWCODE]
		cd.原版序号 = row[CountryRowField.GWCODE]

		# 保存原始字段（调试/兼容用，只保留前 19 个原版基础字段）
		cd.原始字段.resize(19)
		for i in 19:
			cd.原始字段[i] = row[i]

		# 联盟/外交标签（字段 1-10）
		for i in range(1, 11):
			if row[i] == 1:
				cd.tags[TAG_FIELDS[i]] = true

		# 数值属性
		cd.stability = row[CountryRowField.STABILITY]
		cd.development = row[CountryRowField.DEVELOPMENT]

		# 大国影响力
		cd.sov_power = row[CountryRowField.SOV_POWER]
		cd.usa_power = row[CountryRowField.USA_POWER]
		cd.prc_power = row[CountryRowField.PRC_POWER]

		# 政体
		cd.government = row[CountryRowField.GOVERNMENT]
		cd.sub_government = row[CountryRowField.SUB_GOVERNMENT]

		# South_data 专属扩展字段（原版 DLC00，GameStartScript.cs:1729-1731）
		if row.size() >= 24:
			cd.level_of_development = row[CountryRowField.LEVEL_OF_DEV]
			cd.level_of_instability = row[CountryRowField.LEVEL_OF_UNSTAB]
			cd.next_election_day = row[CountryRowField.ELECTION_DAY]
			cd.next_election_month = row[CountryRowField.ELECTION_MONTH]
			cd.next_election_year = row[CountryRowField.ELECTION_YEAR]

		cd.slot = ws.countries.size()
		ws.countries.append(cd)

	print("WorldFactory: 构建了 %d 个国家" % ws.countries.size())


## 旧档兼容：补建魁北克(167)/南墨西哥(168)两个虚拟国。
## 新档由 _build_countries 直接生成；旧档序列化时可能缺失。
static func ensure_fictional_countries(ws: WorldState) -> void:
	if ws == null:
		return
	for sid in [167, 168]:
		if ws.get_country_by_legacy_index(sid) != null:
			continue
		var cd := CountryData.new()
		cd.gwcode = FICTIONAL_COUNTRY_OFFSET + sid
		cd.原版序号 = sid
		cd.slot = ws.countries.size()
		cd.stability = 0
		cd.development = 13
		cd.government = 0
		cd.sub_government = 0
		_apply_offset_name(cd)
		ws.countries.append(cd)
	ws.rebuild_gwcode_index()


# ============================================================================
# 政治家 -- 从 .tres 人物池加载 PoliticianData 对象
# ============================================================================

static func _build_politicians(ws: WorldState) -> void:
	var initial := PoliticianPool.load_initial()
	for pd in initial:
		ws.politicians.append(pd.make_instance())
	ws.politician_reserve.clear()
	for pd in PoliticianPool.load_reserve():
		ws.politician_reserve.append(pd)
	print(
		"WorldFactory: 从人物池加载了 %d 位政治家，预备 %d"
		% [ws.politicians.size(), ws.politician_reserve.size()]
	)


# ============================================================================
# 派系 -- 从嵌入数据创建 FactionData 对象
# ============================================================================

static func _build_factions(ws: WorldState) -> void:
	for i in FACTION_ROWS.size():
		var row: Array = FACTION_ROWS[i]
		var fd := FactionData.new(i)
		fd.is_enabled = row[0] != 0
		fd.is_ally = row[1] != 0
		fd.ideology = row[2]
		fd.support = row[3]      # ≡ party_number
		ws.factions.append(fd)

	# 派系领袖
	for i in mini(FACTION_LEADERS.size(), ws.factions.size()):
		ws.factions[i].leader_index = FACTION_LEADERS[i]

	print("WorldFactory: 加载了 %d 个派系" % ws.factions.size())



# ============================================================================
# 领导人 -- 独立对象（原版 leader ≠ politics[i]），肖像用华国锋
# ============================================================================

static func _set_leader(ws: WorldState) -> void:
	var leader := PoliticianData.new()
	leader.name_display = LEADER_NAME
	leader.age = LEADER_AGE
	# Politics_leader.txt 文件字段序: name1;name2;traits[0];traits[3];traits[1];traits[2];birth
	# （原版 GameStartScript.cs:383-388 逐字段读取），因此：
	#   LEADER_TRAITS[0]=20 → 保守派   LEADER_TRAITS[1]=21 → 党务干部(background)
	#   LEADER_TRAITS[2]=5  → 实用主义(alignment)  LEADER_TRAITS[3]=16 → 谋士(special)
	leader.trait_personality = LEADER_TRAITS[0]
	leader.trait_background = LEADER_TRAITS[1]
	leader.trait_alignment = LEADER_TRAITS[2]
	leader.trait_special = LEADER_TRAITS[3]
	leader.name_first = LEADER_NAME_FIRST
	leader.name_last = LEADER_NAME_LAST
	# 改版中文界面沿用真实姓名+照片；faction=1 仅作 Party 槽显示
	leader.faction = 1
	leader.power = 9999
	leader.loyalty = 1000
	if ResourceLoader.exists(LEADER_PORTRAIT_PATH):
		leader.portrait = load(LEADER_PORTRAIT_PATH) as Texture2D
	ws.leader_politician_index = -1  # 领袖不在 politicians 数组内
	ws.leader = leader


# ============================================================================
# 职位初始化 -- 原版 GameStartScript politics_dolshnost
# 0=总理(150=领袖本人) 1=军委 2=外交 3=首都 4=北方 5=西方 6=南方 7=东方
# 我们用 -2 表示「实权领袖本人」担任该职
# ============================================================================

# 逐字对齐 GameStartScript.cs:509-517：
# dolshnost[0]=150(领袖) [1]=0(毛泽东) [2]=17(乔冠华) [3]=10(吴德)
# [4]=9(陈锡联·北方) [5]=13(赵紫阳·西方) [6]=15(韦国清·南方) [7]=3(张春桥·东方)
# 我们用 -2 表示「实权领袖本人」（原版 150）
## 职位槽 v2（下标=PositionCatalog id）：
## 0 总理=领袖华兼(-2) 1 军委=毛泽东 2 外交=乔冠华 8 党主席=毛泽东
## 3-7 五大区=修改前原班（吴德/陈锡联/赵紫阳/韦国清/张春桥）
## 9 财贸=李先念；待用户 .tres 就绪后补：
## 10 工业=余秋里 11 农业=陈永贵 12 服务=王震(16) 15 民政=谷牧
## 16 组织=郭玉峰 19 中调=罗青长 28 组宣=姚文元(4，解锁后)
## 职位（原版 8 槽）：0 总理=领袖华兼(-2) 1 军委=毛泽东 2 外交=乔冠华
## 3 京畿=吴德 4 华北=陈锡联 5 华西=赵紫阳 6 华南=韦国清 7 华东=张春桥
const INITIAL_POSITIONS := [-2, 0, 17, 10, 9, 13, 15, 3]

static func _init_positions(ws: WorldState) -> void:
	ws.politics_positions.resize(8)
	for i in INITIAL_POSITIONS.size():
		ws.politics_positions[i] = INITIAL_POSITIONS[i]
	print("WorldFactory: 职位初始化完成")


# ============================================================================
# 政客间忠诚 / 对领袖忠诚 — 移植自 GameState.CalcRel / CalcRelLeader
# 开局后按特质与职位生成，再应用原版硬编码覆盖
# ============================================================================

static func _init_politician_relations(ws: WorldState) -> void:
	var n := ws.politicians.size()
	for i in n:
		_calc_rel(ws, i)
		_calc_rel_leader(ws, i)
	# 原版开局硬编码（politics[0]=毛泽东）：
	# 1..4 对毛 10000；四人帮内部互信 10000；另有若干忠诚修正
	if n > 4:
		for a in [1, 2, 3, 4]:
			ws.politicians[a].loyalty_matrix[0] = 10000
		for a in [1, 2, 3, 4]:
			for b in [1, 2, 3, 4]:
				if a != b:
					ws.politicians[a].loyalty_matrix[b] = 10000
		ws.politicians[1].loyalty_matrix[12] -= 1000
		ws.politicians[0].loyalty_matrix[12] += 500
		ws.politicians[0].loyalty += 500
		ws.politicians[5].loyalty += 400
		ws.politicians[8].loyalty += 600
		ws.politicians[9].loyalty += 800
		ws.politicians[10].loyalty += 100
	print("WorldFactory: 政客忠诚矩阵初始化完成")


static func _is_holder(ws: WorldState, position_id: int, pol_index: int) -> bool:
	if position_id < 0 or position_id >= ws.politics_positions.size():
		return false
	return ws.politics_positions[position_id] == pol_index


# 计算两个政客之间的基础关系忠诚得分 (100% 还原原版匹配逻辑值)
static func _compute_relation_score(source: PoliticianData, target: PoliticianData, include_special: bool, ws: WorldState, source_index: int, target_index: int) -> int:
	var score := 0
	if source.trait_personality == target.trait_personality:
		score += 500
	# traits[0] 五派系矩阵（内部值 = 显示×10；0极左 20保守 1温和 2改革 3自由）
	# 逐字对齐 GameState.CalcRel（GameState.cs:5801-5895）
	match target.trait_personality:
		0:
			match source.trait_personality:
				20: score += 80
				1: score += 50
				2: score -= 150
				3: score -= 300
		20:
			match source.trait_personality:
				0: score += 80
				1: score += 25
				2: score -= 80
				3: score -= 200
		1:
			match source.trait_personality:
				0: score += 50
				20: score += 25
				2: score -= 50
				3: score -= 150
		2:
			match source.trait_personality:
				0: score -= 150
				20: score -= 50
				1: score += 50
				3: score += 100
		3:
			match source.trait_personality:
				0: score -= 300
				20: score -= 200
				1: score -= 150
				2: score += 100

	match target.trait_alignment:
		4:
			if source.trait_alignment == GameConstants.PoliticianAlignment.TOLERANT:
				score -= 250
			elif source.trait_alignment == GameConstants.PoliticianAlignment.HARDLINER:
				score += 100
			else:
				score -= 100
		6:
			if source.trait_alignment == GameConstants.PoliticianAlignment.HARDLINER:
				score -= 300
			elif source.trait_alignment == GameConstants.PoliticianAlignment.TOLERANT:
				score += 100
			else:
				score += 100
		5:
			if source.trait_alignment != GameConstants.PoliticianAlignment.PRAGMATIST:
				score += 100
		7:
			if source.trait_alignment == GameConstants.PoliticianAlignment.TOLERANT:
				score += 50

	if include_special:
		match target.trait_special:
			8:
				match source.trait_special:
					9: score -= 250
					8: score += 100
					10: score += 50
					14: score += 50
			9:
				if source.trait_special == GameConstants.PoliticianSpecial.ADVISER:
					score -= 250
				elif source.trait_special != GameConstants.PoliticianSpecial.PEACE:
					score += 50
			10:
				if source.trait_special == GameConstants.PoliticianSpecial.ARROGANT:
					score += 50
				elif source.trait_special == GameConstants.PoliticianSpecial.TYRANT:
					score += 300
				else:
					score -= 100
			11:
				if source.trait_special == GameConstants.PoliticianSpecial.TYRANT or source.trait_special == GameConstants.PoliticianSpecial.ARROGANT:
					score -= 100
				else:
					score += 100
			12:
				score -= 50
			13:
				score += 100
			14:
				if source.trait_special == GameConstants.PoliticianSpecial.WESTERN_SCHOOL:
					score -= 300
				elif source.trait_special == GameConstants.PoliticianSpecial.CHINA_SCHOOL:
					score += 150
				else:
					score += 50
			15:
				if source.trait_special == GameConstants.PoliticianSpecial.WESTERN_SCHOOL:
					score += 200
				elif source.trait_special == GameConstants.PoliticianSpecial.CHINA_SCHOOL:
					score -= 300
			16:
				if source.trait_special == GameConstants.PoliticianSpecial.PEACE:
					score -= 250
				elif source.trait_special == GameConstants.PoliticianSpecial.CHINA_SCHOOL:
					score += 50
			17:
				if source.trait_special == GameConstants.PoliticianSpecial.HARSH:
					score -= 250
				elif source.trait_special == GameConstants.PoliticianSpecial.SHY:
					score += 300
				else:
					score -= 50
			18:
				if source.trait_special == GameConstants.PoliticianSpecial.ECONOMIST:
					score -= 300
				else:
					score += 10

	# 职位野心冲突：若 target_index 担任某职且 source_index 想要该职
	if _is_holder(ws, 0, target_index):
		if source.wanted_position == 0:
			score -= 400
	elif _is_holder(ws, 1, target_index) or _is_holder(ws, 2, target_index):
		if not _is_holder(ws, 0, source_index) and (source.wanted_position == 1 or source.wanted_position == 2):
			score -= 400
	elif (
		_is_holder(ws, 3, target_index) or _is_holder(ws, 4, target_index) or _is_holder(ws, 5, target_index)
		or _is_holder(ws, 6, target_index) or _is_holder(ws, 7, target_index)
	):
		if (
			not _is_holder(ws, 0, source_index) and not _is_holder(ws, 1, source_index) and not _is_holder(ws, 2, source_index)
			and source.wanted_position >= 3
		):
			score -= 400

	return score


static func _calc_rel(ws: WorldState, num: int) -> void:
	## 原版 CalcRel：写入 politics[i].loyality_to_other[num] = i 对 num 的忠诚
	var pols := ws.politicians
	if num < 0 or num >= pols.size():
		return
	var target: PoliticianData = pols[num]
	for i in pols.size():
		if i == num:
			pols[i].loyalty_matrix[i] = 1000
			continue
		var other: PoliticianData = pols[i]
		var score := _compute_relation_score(other, target, true, ws, i, num)
		if other.loyalty_matrix.size() <= num:
			other.loyalty_matrix.resize(pols.size())
		other.loyalty_matrix[num] = score


## 原版 CalcRel2：写入 politics[num].loyality_to_other[i]（num 对他人的忠诚）
## 与 _calc_rel 对称，供任命/换领袖后双向刷新（POL-20）
static func _calc_rel2(ws: WorldState, num: int) -> void:
	var pols := ws.politicians
	if num < 0 or num >= pols.size():
		return
	var self_pol: PoliticianData = pols[num]
	if self_pol.loyalty_matrix.size() < pols.size():
		self_pol.loyalty_matrix.resize(pols.size())
	for i in pols.size():
		if i == num:
			self_pol.loyalty_matrix[i] = 1000
			continue
		var other: PoliticianData = pols[i]
		var score := _compute_relation_score(self_pol, other, false, ws, num, i)
		self_pol.loyalty_matrix[i] = score


static func _calc_rel_leader(ws: WorldState, num: int) -> void:
	## 原版 CalcRelLeader：politics[num].loyality 对领袖的忠诚
	if num < 0 or num >= ws.politicians.size() or ws.leader == null:
		return
	var pol: PoliticianData = ws.politicians[num]
	var leader: PoliticianData = ws.leader
	var d := ws
	var score := 100

	# 提前提取开局状态参数以消除冗余的安全越界校验
	var econ_display := d.econ_display if d.size() > WorldState.I_ECON_DISPLAY else 0
	var political_display := d.political_display if d.size() > WorldState.I_POLITICAL_DISPLAY else 0
	var ideology := d.ideology if d.size() > WorldState.I_IDEOLOGY else 0

	# data.econ_display 经济显示档 / data.political_display 政治显示档 / data.ideology 意识形态 — 开局常量
	match econ_display:
		34:  # 社会主义：显示值 [+25 +20 +15 -10 -15]，内部×10；20=保守
			match pol.trait_personality:
				0: score += 250
				20: score += 200
				1: score += 150
				2: score -= 100
				3: score -= 150
		35:  # 改良主义：[+10 +15 +25 +15 -10]
			match pol.trait_personality:
				0: score += 100
				20: score += 150
				1: score += 250
				2: score += 150
				3: score -= 100
		36:  # 实用主义：[-10 0 +5 +25 +5]；保守=0 不加分支（对齐 GameState.cs:5390-5408）
			match pol.trait_personality:
				0: score -= 100
				1: score += 50
				2: score += 250
				3: score += 50
		37:  # 市场：[-15 -10 -12.5 +15 +25]；保守-10 按用户意图值口径补（原版无 20 分支）
			match pol.trait_personality:
				0: score -= 150
				20: score -= 100
				1: score -= 125
				2: score += 150
				3: score += 250
	match political_display:
		38:  # 威权：[+15 +8 -15 -20 +25]；20=保守（意图值口径，原版 20 分支反编译成重复 ==1）
			match pol.trait_personality:
				0: score += 150
				20: score += 80
				1: score -= 150
				2: score -= 200
				3: score += 250
		39:  # 强硬：[+10 +5 -5 -10 +5]
			match pol.trait_personality:
				0: score += 100
				20: score += 50
				1: score -= 50
				2: score -= 100
				3: score += 50
		40:  # 柔和：[-10 -5 +10 +15 0]
			match pol.trait_personality:
				0: score -= 100
				20: score -= 50
				1: score += 100
				2: score += 150
		41:  # 民主：[-15 -10 -5 +15 +10]
			match pol.trait_personality:
				0: score -= 150
				20: score -= 100
				1: score -= 50
				2: score += 150
				3: score += 100
	match ideology:
		0:
			if pol.trait_alignment == GameConstants.PoliticianAlignment.HARDLINER:
				score += 250
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.TOLERANT:
				score -= 150
		1:
			if pol.trait_alignment == GameConstants.PoliticianAlignment.HARDLINER:
				score += 250
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.PRAGMATIST:
				score -= 150
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.TECH:
				score -= 150
		2:
			if pol.trait_alignment == GameConstants.PoliticianAlignment.HARDLINER:
				score += 100
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.PRAGMATIST:
				score += 150
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.TECH:
				score -= 100
		3:
			if pol.trait_alignment == GameConstants.PoliticianAlignment.HARDLINER:
				score += 100
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.PRAGMATIST:
				score += 250
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.TECH:
				score -= 100
		4:
			if pol.trait_alignment == GameConstants.PoliticianAlignment.HARDLINER:
				score -= 150
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.TOLERANT:
				score += 200
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.PRAGMATIST:
				score += 50
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.TECH:
				score += 100
		5:
			if pol.trait_alignment == GameConstants.PoliticianAlignment.HARDLINER:
				score -= 250
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.TOLERANT:
				score += 300
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.PRAGMATIST:
				score -= 150
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.TECH:
				score += 250
	if leader.trait_personality == pol.trait_personality:
		score += 300
	match leader.trait_alignment:
		4:
			if pol.trait_alignment == GameConstants.PoliticianAlignment.TOLERANT:
				score -= 150
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.HARDLINER:
				score += 100
			else:
				score -= 100
		6:
			if pol.trait_alignment == GameConstants.PoliticianAlignment.HARDLINER:
				score -= 200
			elif pol.trait_alignment == GameConstants.PoliticianAlignment.TOLERANT:
				score += 100
			else:
				score += 100
		5:
			if pol.trait_alignment != GameConstants.PoliticianAlignment.PRAGMATIST:
				score += 100
		7:
			if pol.trait_alignment == GameConstants.PoliticianAlignment.TOLERANT:
				score += 50
	match leader.trait_special:
		8:
			match pol.trait_special:
				9: score -= 150
				8: score += 100
				10: score += 50
				14: score += 50
		9:
			if pol.trait_special == GameConstants.PoliticianSpecial.ADVISER:
				score -= 150
			elif pol.trait_special != GameConstants.PoliticianSpecial.PEACE:
				score += 50
		10:
			if pol.trait_special == GameConstants.PoliticianSpecial.ARROGANT:
				score += 50
			elif pol.trait_special == GameConstants.PoliticianSpecial.TYRANT:
				score += 300
			else:
				score -= 100
		11:
			if pol.trait_special == GameConstants.PoliticianSpecial.TYRANT or pol.trait_special == GameConstants.PoliticianSpecial.ARROGANT:
				score -= 100
			else:
				score += 100
		12:
			score -= 50
		13:
			score += 100
		14:
			if pol.trait_special == GameConstants.PoliticianSpecial.WESTERN_SCHOOL:
				score -= 200
			elif pol.trait_special == GameConstants.PoliticianSpecial.CHINA_SCHOOL:
				score += 150
			else:
				score += 50
		15:
			if pol.trait_special == GameConstants.PoliticianSpecial.WESTERN_SCHOOL:
				score += 200
			elif pol.trait_special == GameConstants.PoliticianSpecial.CHINA_SCHOOL:
				score -= 200
		16:
			if pol.trait_special == GameConstants.PoliticianSpecial.PEACE:
				score -= 150
			elif pol.trait_special == GameConstants.PoliticianSpecial.CHINA_SCHOOL:
				score += 50
		17:
			if pol.trait_special == GameConstants.PoliticianSpecial.HARSH:
				score -= 150
			elif pol.trait_special == GameConstants.PoliticianSpecial.SHY:
				score += 300
			else:
				score -= 50
		18:
			if pol.trait_special == GameConstants.PoliticianSpecial.ECONOMIST:
				score -= 200
			else:
				score += 10
	pol.loyalty = score


# ============================================================================
# 初始修正 -- 预创建 250 个槽位并激活指定 ID
# ============================================================================

static func _init_modifiers(ws: WorldState) -> void:
	ws.modifiers.resize(250)
	for i in 250:
		ws.modifiers[i] = ModifierSlot.new(i)
	for idx in START_MODIFIER_IDS:
		if idx >= 0 and idx < 250:
			ws.modifiers[idx].is_active = true
			ws.modifiers[idx].level = 1
	print("WorldFactory: 加载了 %d 个初始修正" % START_MODIFIER_IDS.size())


# ============================================================================
# 科技状态 -- 设置初始解锁
# ============================================================================

static func _init_science(ws: WorldState) -> void:
	ws.techs = TechState.new()
	for i in mini(SCIENCE_UNLOCKED.size(), ws.techs.TECH_COUNT):
		ws.techs.unlocked[i] = SCIENCE_UNLOCKED[i]
	print("WorldFactory: 科技状态加载完成")


# ============================================================================
# 超级大国 -- 硬编码 USA 和 USSR
# ============================================================================

static func _init_empires(ws: WorldState) -> void:
	var usa := EmpireData.new(EmpireData.USA)
	usa.money = 1000
	usa.power = ws.usa_influence      # 原版 empires[0].power = data.usa_influence = 280
	usa.relations = ws.usa_relations                            # 原版 empires[0].relations = data.usa_relations = 700
	# 美国 8 位领导人（索引 = now_leader，modify_choose.cs:676-716 显示分支）。
	# 开局 support 对齐 GameStartScript.cs:938-944（new_texts[0..3] 固定 5/4/3/2，4-7 无初始值）。
	# 注：原版 1977 前显示"福特"、1977-1981 显示"卡特"是按日期的显示分支（modify_choose.cs:678-686），
	# 不在 leaders 表内；1981 后按 now_leader 显示。current_leader 初始 0 = 里根。
	usa.leaders = [
		EmpireLeader.new("Ronald Reagan", 5),            # 0 罗纳德·里根（1981 后显示）
		EmpireLeader.new("Jimmy Carter", 4),             # 1 吉米·卡特（1980 大选连任后）
		EmpireLeader.new("George Bush", 3),              # 2 乔治·布什（1984 大选败者/继任）
		EmpireLeader.new("Walter Mondale", 2),           # 3 沃尔特·蒙代尔（1984 大选胜者）
		EmpireLeader.new("Michael Dukakis", 0),          # 4 迈克尔·杜卡基斯
		EmpireLeader.new("Ron Paul", 0),                 # 5 罗纳德·欧内斯特·保罗
		EmpireLeader.new("Ross Perot", 0),               # 6 罗斯·佩罗
		EmpireLeader.new("Bernie Sanders", 0),           # 7 伯尼·桑德斯
	]

	var ussr := EmpireData.new(EmpireData.USSR)
	ussr.money = 800
	ussr.power = ws.soviet_influence   # 原版 empires[1].power = data.soviet_influence = 300
	ussr.relations = ws.ussr_relations                           # 原版 empires[1].relations = data.ussr_relations = 300
	# 苏联 9 位领导人（索引 = now_leader，modify_choose.cs:154-212 显示分支）。
	# 开局 support 按 GameStartScript.cs:963-970 公式：data.get_data_by_index(95..100) 开局 0（GameState.cs:7850
	# data=new int[150]），GameStartScript.cs:958-959 增量 data.soviet_leader_chernenko++ / data.soviet_leader_andropov+=4，dlc[0]=true。
	# 索引语义以 Event89.cs 判定为准（安德罗波夫胜→now_leader=1、谢尔比茨基胜→now_leader=3）：
	#   leaders[1]=谢尔比茨基（data.soviet_leader_shcherbitsky+3）、leaders[3]=安德罗波夫（data.soviet_leader_andropov），
	#   与 modify_choose 显示分支（1=安德罗波夫、3=谢尔比茨基）自洽。
	# 雅科夫列夫(7)/利加乔夫(8) 无开局公式，取预留合理值（显示分支与未来事件用）。
	ussr.leaders = [
		EmpireLeader.new("Leonid Brezhnev", 20),         # 0 列昂尼德·勃列日涅夫（GameStartScript support=20）
		EmpireLeader.new("Vladimir Shcherbitsky", 3),    # 1 弗拉基米尔·谢尔比茨基（data.soviet_leader_shcherbitsky+3）
		EmpireLeader.new("Konstantin Chernenko", 3),     # 2 康斯坦丁·契尔年科（data.soviet_leader_chernenko*3）
		EmpireLeader.new("Yuri Andropov", 4),            # 3 尤里·安德罗波夫（data.soviet_leader_andropov）
		EmpireLeader.new("Grigory Romanov", 0),          # 4 格里戈里·罗曼诺夫（data.soviet_leader_romanov）
		EmpireLeader.new("Viktor Grishin", 1),           # 5 维克托·格里申（data.soviet_leader_grishin+1）
		EmpireLeader.new("Mikhail Gorbachev", 0),        # 6 米哈伊尔·戈尔巴乔夫（data.soviet_successor_third）
		EmpireLeader.new("Alexander Yakovlev", 30),      # 7 亚历山大·雅科夫列夫（Event117 北约分支）
		EmpireLeader.new("Yegor Ligachev", 25),          # 8 叶戈尔·利加乔夫（预留）
	]

	ws.empires = [usa, ussr]
	print("WorldFactory: 超级大国加载完成")


# ============================================================================
# 后处理覆盖 -- 原版 GameStartScript 硬编码的初始化修正
# ============================================================================

static func _apply_post_load_overrides(ws: WorldState, difficulty: int) -> void:
	# 清零区间（原版 lines 627-645）
	for i in range(111, 126):
		ws.set_data_by_index(i, 0)
	ws.birth_policy = 2
	ws.satisfied = 0       # 满意现秩序者开局为 0
	ws.oligarch = 0        # 寡头影响力
	if ws.size() > WorldState.I_INDUSTRY_BASE:
		ws.industry_base = 350
	ws.investment_delay = 0
	ws.mil_intervention = 0
	ws.palestine_status = 0
	ws.war_resolve = -1
	ws.mil_intervention = 0

	# 原版 GameStartScript.cs:92-93：开局 is_elect=true、is_speech=true。
	# Godot 映射：speech_done=true → 演讲按钮一次性锁定（原版 is_speech 永不复位）；
	# manual_election_used=true → 选举按钮开局禁用，首个自然月切后由
	# GameManager._on_month_changed 复位（对齐 TimeScript.cs:505-512）。
	ws.set_flag("speech_done", true)
	ws.set_flag("manual_election_used", true)

	# 结局/配置区（原版 GameStartScript.cs:874-898 硬编码，data.get_data_by_index(160-184)）
	# 主控 2026-08-14 亲读原版逐值核对；此前 Godot 全未初始化（全 0），已补齐。
	ws.soviet_money = 5500   # 苏联资金（原版 :874）
	ws.usa_money = -1500  # 美国资金（:875）
	ws.org_strength_1 = 12     # （:876）
	ws.org_strength_2 = 20     # （:877）
	ws.org_strength_3 = 8      # （:878）
	ws.org_strength_4 = 8      # （:879）
	ws.bico_strength = 0      # （:880）
	ws.data_167 = -1     # （:881）
	ws.support_sent_flag = false      # （:882）
	ws.ireland_unification_route = 0      # （:883）
	ws.event999_trigger_sentinel = 0      # （:884）
	ws.vietnam_pro_china_coup_available = 1      # （:885）
	ws.italy_power_172 = 6      # （:886）
	ws.italy_power_173 = 3      # （:887）
	ws.italy_power_174 = 1      # （:888）
	ws.italy_power_175 = 3      # （:889）
	ws.italy_power_176 = 2      # （:890）
	ws.italy_power_177 = 0      # （:891）
	ws.italy_power_178 = 0      # （:892）
	ws.italy_power_179 = 1      # （:893）
	ws.italy_power_180 = 2      # （:894）
	ws.italy_power_181 = 2      # （:895）
	ws.short_sword_power = 0      # （:896）
	ws.italy_event_timer = 0      # （:897）
	ws.italy_hot_autumn_route = 0      # （:898）

	# 随机外交参数
	ws.random_diplo_param = randi_range(1, 4)
	ws.afghan_khalq = randi_range(1, 4)
	ws.afghan_parcham = randi_range(1, 4)

	# 国家开局硬编码覆盖（GameStartScript.cs:574-814, 1020-1090，数据文件之后的最终开局值）
	_apply_country_start_overrides(ws)
	# 原版 GameState.FixSubs()（GameStartScript.cs:1682 调用，GameState.cs:4831-4856）
	_fix_subs(ws)

	# 难度调整
	match difficulty:
		0:  # 沙盒
			ws.party_support = 1000
			ws.people_support = 1000
			ws.thought_freedom = 0
			ws.budget += 500
			ws.science = 700
		1:  # 简单
			ws.budget += 100
			ws.science = 300
		2:  # 普通
			ws.science = 0
		3:  # 困难
			ws.science = 0


# ============================================================================
# 国家开局硬编码覆盖 -- GameStartScript.cs:574-814 整段移植
# ============================================================================
# 原版流程：先读 Country_data_1.txt / South_data.txt，随后无条件逐国覆盖
# 政体/子意识形态/标签/傀儡。Godot 此前只搬了数值表 data.get_data_by_index(160-184)，
# 缺这一段导致马来西亚、大洋洲、非洲、古巴等大量国家开局政体不符。
# 说明：原版的国名覆盖（如 "扎 伊 尔 共 和 国"）移植说明——Godot 的显示名
# 走 map_countries 中文名/9000+ 中文回退，已优先于 c.name。
# ============================================================================

static func _legacy(ws: WorldState, id: int) -> CountryData:
	var c := ws.get_country_by_legacy_index(id)
	if c == null:
		push_warning("WorldFactory: 开局覆盖找不到国家 id=%d" % id)
	return c


static func _set_gs(ws: WorldState, id: int, gov: int, sub: int) -> void:
	var c := _legacy(ws, id)
	if c != null:
		c.government = gov
		c.sub_government = sub


static func _copy_gs(ws: WorldState, id: int, from_id: int) -> void:
	var c := _legacy(ws, id)
	var src := _legacy(ws, from_id)
	if c != null and src != null:
		c.government = src.government
		c.sub_government = src.sub_government


static func _set_tag(ws: WorldState, id: int, tag: String, value: bool) -> void:
	var c := _legacy(ws, id)
	if c != null:
		c.set_tag(tag, value)


static func _set_puppet(ws: WorldState, id: int, overlord_id: int) -> void:
	var c := _legacy(ws, id)
	if c != null:
		c.puppet_of = overlord_id


static func _clear_alliance_tags(c: CountryData) -> void:
	## 对应原版 Country.LeaveAlliances()（Country.cs:89-115）
	for t in START_CLEAR_TAGS:
		c.tags.erase(t)
	c.puppet_of = GameConstants.LegacySlot.NONE


static func _leave_and_gs(ws: WorldState, id: int, gov: int, sub: int) -> void:
	var c := _legacy(ws, id)
	if c == null:
		return
	_clear_alliance_tags(c)
	c.government = gov
	c.sub_government = sub


static func _apply_country_start_overrides(ws: WorldState) -> void:
	# —— 无条件覆盖（GameStartScript.cs:574-814）——
	_set_gs(ws, 11, 1, 16)                        # 越南 → 苏式社会主义（:574-575）
	_set_gs(ws, 22, 1, 1)                         # 老挝 → 国控社会主义（:577-578）
	_set_tag(ws, 25, "对华贸易", true)             # 北也门（:579）
	_set_gs(ws, 27, 3, 4)                         # 奥地利 → 社会民主主义（:580-581）
	_set_gs(ws, 30, 0, 20)                        # 埃及 → 宪政威权主义（:582-583）
	_set_gs(ws, 31, 2, 15)                        # 巴基斯坦 → 政治实用主义（:584-585）
	_set_gs(ws, 41, 2, 15)                        # 埃塞俄比亚（:587-588）
	_set_gs(ws, 42, 0, 10)                        # 索马里 → 左翼民族主义（:590-591）
	_set_gs(ws, 49, 0, 20)                        # 马来西亚 → 宪政威权主义（:592-593）
	_set_tag(ws, 49, "亲美", false)               # 马来西亚清除亲美（GameStartScript.cs:232 allcountries[49].Vyshi = false）
	_set_tag(ws, 52, "对华贸易", true)             # 刚果（布）（:595）
	_leave_and_gs(ws, 56, 0, 7)                   # 尼日尔，清联盟（:596-598）
	_set_puppet(ws, 56, 21)
	_leave_and_gs(ws, 59, 0, 10)                  # 毛里塔尼亚，清联盟+对华贸易（:600-603）
	_set_tag(ws, 59, "对华贸易", true)
	_leave_and_gs(ws, 60, 2, 8)                   # 尼日利亚，清联盟（:605-607）
	_leave_and_gs(ws, 61, 0, 7)                   # 上沃尔特，清联盟+傀儡法国（:609-612）
	_set_puppet(ws, 61, 21)
	_leave_and_gs(ws, 64, 0, 7)                   # 科特迪瓦，清联盟+傀儡法国（:613-616）
	_set_puppet(ws, 64, 21)
	var c66 := _legacy(ws, 66)                    # 喀麦隆 sub7+傀儡法国（:617-618）
	if c66 != null:
		c66.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		c66.puppet_of = GameConstants.LegacySlot.FRANCE
	_set_gs(ws, 67, 0, 20)                        # 利比里亚（:620-621）
	_set_tag(ws, 68, "亲苏", false)               # 几内亚（:622-623）
	_set_tag(ws, 68, "对华贸易", true)
	_set_gs(ws, 92, 3, 4)                         # 英国 → 社会民主主义（:624-625）
	_set_gs(ws, 94, 2, 8)                         # 塞浦路斯（:626-627）
	_set_puppet(ws, 97, 19)                       # 不丹（:628）
	_leave_and_gs(ws, 107, 0, 7)                  # 塞拉利昂（:629-631）
	_set_puppet(ws, 108, 21)                      # 多哥（:632）
	_set_gs(ws, 111, 3, 4)                        # 文莱，归属英国（原代码误写 112 且设为法国，已修正）
	_set_puppet(ws, 111, 92)
	_set_gs(ws, 112, 3, 4)                        # 塞内加尔 → 社会民主主义 + 傀儡法国（:634-636）
	_set_puppet(ws, 112, 21)
	_set_gs(ws, 113, 0, 20)                       # 冈比亚 + 亲美（:637-639）
	_set_tag(ws, 113, "亲美", true)
	_set_gs(ws, 114, 1, 1)                        # 几内亚比绍 + 对华贸易（:640-642）
	_set_tag(ws, 114, "对华贸易", true)
	_set_gs(ws, 115, 0, 9)                        # 赤道几内亚（:643-644）
	_set_gs(ws, 116, 0, 7)                        # 加蓬，傀儡法国（:645-647）
	_set_puppet(ws, 116, 21)
	_set_gs(ws, 117, 0, 7)                        # 扎伊尔 + 对华贸易（:649-651）
	_set_tag(ws, 117, "对华贸易", true)
	_set_gs(ws, 118, 0, 7)                        # 乌干达 + 亲苏（:653-655）
	_set_tag(ws, 118, "亲苏", true)
	_set_gs(ws, 119, 0, 20)                       # 肯尼亚 + 亲美（:656-658）
	_set_tag(ws, 119, "亲美", true)
	_set_gs(ws, 120, 0, 9)                        # 卢旺达（:659-660）
	_set_gs(ws, 121, 0, 9)                        # 布隆迪（:661-662）
	_set_gs(ws, 122, 1, 1)                        # 坦桑尼亚 + 亲中+对华贸易（:663-666）
	_set_tag(ws, 122, "亲中", true)
	_set_tag(ws, 122, "对华贸易", true)
	_set_gs(ws, 123, 1, 1)                        # 安哥拉 + 亲苏（:667-669）
	_set_tag(ws, 123, "亲苏", true)
	_set_gs(ws, 124, 2, 15)                       # 赞比亚 + 亲中+对华贸易（:670-673）
	_set_tag(ws, 124, "亲中", true)
	_set_tag(ws, 124, "对华贸易", true)
	# 125 马拉维：0/13 原值不变（:674-675）
	_set_gs(ws, 126, 1, 1)                        # 莫桑比克 + 对华贸易（:676-678）
	_set_tag(ws, 126, "对华贸易", true)
	_set_gs(ws, 127, 0, 7)                        # 罗得西亚（津巴布韦），傀儡南非（:679-682）
	_set_puppet(ws, 127, 131)
	# 128 纳米比亚：被南非吞并（傀儡南非；地图归属见 map_regions.json）
	_set_puppet(ws, 128, 131)
	_set_gs(ws, 129, 0, 20)                       # 博茨瓦纳（:683-684）
	_set_puppet(ws, 130, 131)                     # 斯威士兰：0/13 不变，傀儡南非（:685-688）
	_set_gs(ws, 131, 0, 7)                        # 白人南非（:689-691）
	_set_gs(ws, 132, 0, 7)                        # 莱索托，傀儡南非（:692-695）
	_set_puppet(ws, 132, 131)
	_set_gs(ws, 133, 2, 3)                        # 马达加斯加（:696-698）
	_set_gs(ws, 134, 3, 5)                        # 巴新，傀儡澳大利亚+亲美（:699-702）
	_set_puppet(ws, 134, 135)
	_set_tag(ws, 134, "亲美", true)
	_set_gs(ws, 135, 3, 6)                        # 澳大利亚 + 亲美（:703-705）
	_set_tag(ws, 135, "亲美", true)
	_set_gs(ws, 136, 3, 4)                        # 新西兰 + 亲美（:706-708）
	_set_tag(ws, 136, "亲美", true)
	_set_gs(ws, 137, 3, 6)                        # 加拿大 + 亲美+NATO（:709-712）
	_set_tag(ws, 137, "亲美", true)
	_set_tag(ws, 137, "nato", true)
	_set_gs(ws, 138, 1, 2)                        # 古巴 → 马列主义 + 亲苏+经互会（:713-716）
	_set_tag(ws, 138, "亲苏", true)
	_set_tag(ws, 138, "sev", true)
	_set_tag(ws, 139, "亲美", true)               # 海地：0/13 不变 + 亲美（:717-720）
	_set_gs(ws, 140, 0, 20)                       # 墨西哥 + 亲美（:721-723）
	_set_tag(ws, 140, "亲美", true)
	_set_gs(ws, 141, 2, 3)                        # 巴拿马（:724-725）
	_copy_gs(ws, 142, 92)                         # 伯利兹随英国（:726-727）
	_set_puppet(ws, 142, 92)
	_set_gs(ws, 143, 0, 20)                       # 多米尼加 + 亲美（:728-730）
	_set_tag(ws, 143, "亲美", true)
	_set_gs(ws, 144, 3, 4)                        # 哥斯达黎加（:731-732）
	_set_gs(ws, 145, 1, 1)                        # 格陵兰（:733-735；原版国名覆盖不移植）
	_set_gs(ws, 146, 0, 7)                        # 洪都拉斯 + 亲美（:736-738）
	_set_tag(ws, 146, "亲美", true)
	_set_gs(ws, 147, 0, 7)                        # 尼加拉瓜 + 亲美（:739-741）
	_set_tag(ws, 147, "亲美", true)
	_set_gs(ws, 148, 0, 7)                        # 萨尔瓦多 + 亲美（:742-744）
	_set_tag(ws, 148, "亲美", true)
	_set_gs(ws, 149, 0, 7)                        # 危地马拉 + 亲美（:745-747）
	_set_tag(ws, 149, "亲美", true)
	# 150 南苏丹 / 151 达尔富尔：0/13 原值不变
	_set_gs(ws, 152, 2, 3)                        # 牙买加（:748-749）
	# 153 纳米比亚二号：0/13 原值不变
	_copy_gs(ws, 154, 21)                         # 新喀里多尼亚随法国（:750-752）
	_set_puppet(ws, 154, 21)
	_set_gs(ws, 155, 3, 6)                        # 塞舌尔 + 亲美（:754-756）
	_set_tag(ws, 155, "亲美", true)
	# 156 阿扎瓦德 / 157 库尔德斯坦二号：0/13 原值不变
	_set_gs(ws, 158, 2, 15)                       # 科摩罗（:757-758）
	_copy_gs(ws, 159, 21)                         # 新赫布里底（瓦努阿图）随法国（:760-762）
	_set_puppet(ws, 159, 21)
	_set_gs(ws, 160, 3, 6)                        # 斐济（:764-765）
	_copy_gs(ws, 161, 92)                         # 所罗门随英国（:767-768）
	_set_puppet(ws, 161, 92)
	var c162 := _legacy(ws, 162)                  # 南极洲 → 托洛茨基主义（:769）
	if c162 != null:
		c162.sub_government = GameConstants.SubGovernment.TROTSKYIST
	# 167/168 原版解析不产生独立国家，不移植（:770-775）
	_set_tag(ws, 15, "对华贸易", false)           # 南斯拉夫（:776）
	var c5 := _legacy(ws, 5)                      # spec 归零（:777-779）
	if c5 != null: c5.special = 0
	var c21a := _legacy(ws, 21)
	if c21a != null:
		c21a.special = 0
		c21a.social_stability = 0                  # （:780）
	var c92a := _legacy(ws, 92)
	if c92a != null: c92a.special = 0

	# 北约（:781-793）
	for nato_id in [0, 51, 92, 21, 87, 88, 89, 17, 84, 85, 45, 90, 91, 137]:
		_set_tag(ws, nato_id, "nato", true)
	# 欧共体（:794-802）
	for eu_id in [0, 92, 21, 88, 89, 17, 85, 90, 29]:
		_set_tag(ws, eu_id, "eu", true)

	var c87 := _legacy(ws, 87)                    # 葡萄牙 spec/infl（:804-806）
	if c87 != null:
		c87.special = 40
		c87.influence_china = 10
		c87.influence_nato = 20
	var c1 := _legacy(ws, 1)                      # 中国影响力/不稳定（:807-808）
	if c1 != null:
		c1.prc_influence = 0
		c1.level_of_instability = 10
	var c149 := _legacy(ws, 149)                  # 危地马拉/尼加拉瓜不稳定（:809-810）
	if c149 != null: c149.level_of_instability = 200
	var c147 := _legacy(ws, 147)
	if c147 != null: c147.level_of_instability = 250
	var c20 := _legacy(ws, 20)                    # 阿尔巴尼亚 → 马列主义（:814）
	if c20 != null: c20.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST

	# dlc[3] 条件块（:815-831）。项目惯例：无 DLC 体系 → dlc[3] 视为恒真
	# （见 event_007_diplo_crisis_usa.gd:12 注释）。OilProd 已在 create_world 设置，
	# OilEat 由 _apply_modifier51_oil / modifier_catalog 按原版公式动态计算。
	for asean_id in [50, 49, 34, 47]:
		_set_tag(ws, asean_id, "asean", true)
	for sento_id in [31, 8]:
		_set_tag(ws, sento_id, "sento", true)
	_set_puppet(ws, 22, 11)
	ws.oil_price = 12

	var c92b := _legacy(ws, 92)                   # （:871-872）
	if c92b != null: c92b.influence_nato = 10
	var c85 := _legacy(ws, 85)
	if c85 != null: c85.level_of_development = 75

	# —— 第二段无条件覆盖（GameStartScript.cs:1020-1090）——
	# 原版在第一段之后、进入场景前还有这一段；上一轮漏移植导致
	# 伊拉克/叙利亚/波兰/匈牙利/苏丹/乍得/马里/加纳等开局政体不符。
	for africa_off_id in [53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68,
			106, 107, 108, 112, 113, 114, 115, 116, 117, 118, 119, 122, 123, 124,
			125, 126, 127, 128, 129, 130, 131, 132, 133]:
		var ca := _legacy(ws, africa_off_id)
		if ca != null: ca.禁用非洲机制 = true
	var c33 := _legacy(ws, 33)                    # 缅甸（:1022）
	if c33 != null: c33.influence_china = 50
	_set_tag(ws, 53, "对华贸易", true)             # 苏丹（:1065）
	_set_gs(ws, 58, 0, 7)                         # 马里 + 傀儡法国（:1066-1068）
	_set_puppet(ws, 58, 21)
	var c65 := _legacy(ws, 65)                    # 中非：sub13 + 傀儡法国（:1069-1071）
	if c65 != null:
		c65.sub_government = GameConstants.SubGovernment.NEOPATRIARCHAL
		c65.puppet_of = GameConstants.LegacySlot.FRANCE
	_set_tag(ws, 42, "对华贸易", true)             # 索马里（:1072）
	var c53 := _legacy(ws, 53)                    # 苏丹 sub10（:1073）
	if c53 != null: c53.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
	_set_gs(ws, 57, 0, 7)                         # 乍得 + 傀儡法国（:1074-1076）
	_set_puppet(ws, 57, 21)
	var c63 := _legacy(ws, 63)                    # 加纳 sub7 + 亲美（:1077/:1087）
	if c63 != null: c63.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
	_set_tag(ws, 63, "亲美", true)
	_set_gs(ws, 2, 2, 21)                         # 波兰 → 革新社会主义（:1078-1079）
	_set_gs(ws, 4, 2, 21)                         # 匈牙利 → 革新社会主义（:1080-1081）
	_set_tag(ws, 35, "对华贸易", true)             # 叙利亚（:1082）
	_set_gs(ws, 35, 2, 15)                        # 叙利亚 → 政治实用主义（:1083-1084）
	_set_gs(ws, 14, 2, 15)                        # 伊拉克 → 政治实用主义（:1085-1086）
	_set_gs(ws, 107, 2, 15)                       # 塞拉利昂 → 政治实用主义（:1088-1089）

	# —— 项目增量（用户确认，2026-08-15）：开局吉布提属法国领土 ——
	# 106 吉布提：原版地图在事件585前按法国着色（CountryScript.cs:4926-4933
	#   this_number 106 → 21），本项目同时把 map_regions.json 的 522 区域归属法国，
	#   这里补数据侧 puppet_of 对齐法国；事件585触发后转移地图归属。
	# 77 圭亚那：已按原版独立（Guyana 1966），map_regions.json 的圭亚那区域归属 110，
	#   法属圭亚那区域 47 仍属法国 220，不再把 77 设为法国傀儡。
	_set_puppet(ws, 106, 21)

	print("WorldFactory: 国家开局硬编码覆盖完成（GameStartScript.cs:574-814, 1020-1090）")


## 原版 GameState.FixSubs()（GameState.cs:4831-4856）：
## 按子意识形态把政体归位；原版显式跳过南美 71-83。
static func _fix_subs(ws: WorldState) -> void:
	for c in ws.countries:
		var sid := int(c.原版序号)
		if sid >= 71 and sid <= 83:
			continue
		var sub := c.sub_government
		if c.government != GameConstants.Government.AUTHORITARIAN and sub in [0, 7, 9, 10, 13, 19, 20, 22]:
			c.government = GameConstants.Government.AUTHORITARIAN
		elif c.government != GameConstants.Government.SOCIALIST and sub in [1, 2, 16, 17, 18]:
			c.government = GameConstants.Government.SOCIALIST
		elif c.government != GameConstants.Government.REFORMIST and sub in [3, 8, 11, 15, 14, 21]:
			c.government = GameConstants.Government.REFORMIST
		elif c.government != GameConstants.Government.LIBERAL and sub in [4, 5, 6, 12]:
			c.government = GameConstants.Government.LIBERAL


# ============================================================================
# 代理战争槽 -- 按 WarCatalog 生成
# ============================================================================

static func _init_wars(ws: WorldState) -> void:
	ws.wars.clear()
	var ids: Array = WarCatalog.all_ids()
	if ids.is_empty():
		for i in 7:
			var empty := WarData.new()
			empty.name_war = "战争 #%d" % i
			empty.fortnight_max = 999
			ws.wars.append(empty)
		print("WorldFactory: WarCatalog 空，创建 %d 个占位战争槽" % ws.wars.size())
		return
	var max_id := 0
	for i in ids:
		max_id = maxi(max_id, int(i))
	ws.wars.resize(max_id + 1)
	for id in ids:
		var iid := int(id)
		var def := WarCatalog.get_def(iid)
		var w := WarData.new()
		w.is_going = false
		w.name_war = def.name_zh if def else ("战争 #%d" % iid)
		w.fortnight_max = def.fortnight_max if def else 999
		w.fortnight_elapsed = 0
		w.diplo_done = [false, false]
		ws.wars[iid] = w
	# 原版 ingamewars 是 200 槽（GameState.cs:7824）。
	# WarCatalog 只定义有静态规则/漂移的战争；其余槽保留 null，
	# 运行时事件按原版直接写入对应槽（如 Event449→33、Event369→9、Event538→36）。
	ws.wars.resize(maxi(max_id + 1, 200))
	print("WorldFactory: 加载了 %d 个战争槽" % ws.wars.size())


# ============================================================================
# 工具函数
# ============================================================================

# 规范化国名：小写 + 去重音 + 去除空格/标点/连字符，便于跨数据源匹配
# 加载 JSON 文件为 Dictionary# 加载 JSON 文件为 Dictionary（失败返回空字典）
static func _load_json_as_dict(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}
