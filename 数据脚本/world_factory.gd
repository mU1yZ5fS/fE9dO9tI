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


# ============================================================================
# 国名别名表 -- 原版英文国名（规范化后）→ 新地图国名 的映射
# ============================================================================
const NAME_ALIASES := {
	"usa": "unitedstatesofamerica",
	"gdr": "germandemocraticrepublic",
	"frg": "germanfederalrepublic",
	"northkorea": "koreapeoplesrepublicof",
	"southkorea": "korearepublicof",
	"northyemen": "yemenarabrepublicofyemen",
	"southyemen": "yemenpeoplesrepublicof",
	"luxemburg": "luxembourg",
	"greatbritain": "unitedkingdom",
	"burma": "myanmar",
}


# ============================================================================
# 国家数据字段 1-10 对应的标签名
# ============================================================================
const TAG_FIELDS: Array[String] = [
	"", "sev", "ovd", "亲美", "亲中", "亲苏",
	"okb", "econ", "对华贸易", "美国盟友", "苏联盟友",
]


# ============================================================================
# 数值表 -- 150 个全局整数值（索引 0-149）
# ============================================================================
const DATA_VALUES := [
	#  0       1       2       3       4       5       6       7       8       9
	   0,    800,    300,    600,    100,    250,    830,     50,     30,     20,  # 0-9
	 280,      0,    350,    450,      1,      6,     12,     16,     20,      4,  # 10-19
	   2,   1976,     50,     96,    100,      0,    150,     50,    700,    300,  # 20-29
	  30,    500,    100,    200,   9307,    300,     50,    500,      5,      5,  # 30-39
	   5,      0,    100,    120,    100,    180,     30,     20,    200,    150,  # 40-49
	  24,     31,     34,      1,     38,    100,      1,    650,    -10,      0,  # 50-59
	   0,      0,      0,      0,      0,      0,      0,      0,    240,      0,  # 60-69
	  86,    100,    100,     70,    160,     60,     90,    140,    100,     60,  # 70-79
	  90,     70,    -10,      0,      0,      0,      0,      0,      0,      0,  # 80-89
	   0,      0,      0,      0,      0,      0,      0,      0,      0,      0,  # 90-99
	   0,      0,      0,      0,      0,      0,      0,      0,      0,      0,  # 100-109
	   0,      0,      0,      0,      0,      0,      0,      0,      0,      0,  # 110-119
	   0,      0,      0,      0,      0,      0,      0,      0,      0,      0,  # 120-129
	   0,      0,      0,      0,      0,      0,      0,      0,      0,      0,  # 130-139
	   0,      0,      0,      0,      0,      0,      0,      0,      0,      0,  # 140-149
]


# ============================================================================
# 国家原始数据 -- 99 个国家，每个 19 字段
# [gwcode, sev, ovd, 亲美, 亲中, 亲苏, okb, econ, 对华贸易,
#  美国盟友, 苏联盟友, unused, stability, development,
#  sov_power, usa_power, prc_power, government, sub_government]
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
	[11, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],         # Vietnam
	[12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],        # Afghanistan
	[13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 15],        # Libya
	[14, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],         # Iraq
	[15, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 11],        # Yugoslavia
	[16, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 16],        # GDR
	[17, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5],         # FRG
	[18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 15],        # Western Sahara
	[19, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 15],        # India
	[20, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],         # Albania
	[21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # France
	[22, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],         # Laos
	[23, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17],        # Kampuchea
	[24, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],         # South Yemen
	[25, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],        # North Yemen
	[26, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 15],        # Finland
	[27, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5],         # Austria
	[28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 3],         # Sweden
	[29, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # Ireland
	[30, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5],         # Egypt
	[31, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # Pakistan
	[32, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13],        # Bangladesh
	[33, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10],        # Burma
	[34, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 6],         # Thailand
	[35, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],         # Syria
	[36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7],         # Kuwait
	[37, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5],         # Israel
	[38, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7],         # Taiwan
	[39, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 5],         # Switzerland
	[40, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 500, 400, 90, 20, 0, 1, 1],   # Algeria
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
	[52, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7],         # Singapore
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
	[1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1],          # China
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
# 国家英文名 -- 按内部 gwcode 索引（0-111）
# ============================================================================
const COUNTRY_NAMES := {
	0: "Luxemburg", 1: "China", 2: "Poland", 3: "Czechoslovakia",
	4: "Hungary", 5: "Romania", 6: "Bulgaria", 7: "Soviet Union",
	8: "Iran", 9: "Mongolia", 10: "North Korea", 11: "Vietnam",
	12: "Afghanistan", 13: "Libya", 14: "Iraq", 15: "Yugoslavia",
	16: "GDR", 17: "FRG", 18: "Western Sahara", 19: "India",
	20: "Albania", 21: "France", 22: "Laos", 23: "Kampuchea",
	24: "South Yemen", 25: "North Yemen", 26: "Finland", 27: "Austria",
	28: "Sweden", 29: "Ireland", 30: "Egypt", 31: "Pakistan",
	32: "Bangladesh", 33: "Burma", 34: "Thailand", 35: "Syria",
	36: "Kuwait", 37: "Israel", 38: "Taiwan", 39: "Switzerland",
	40: "Algeria", 41: "Ethiopia", 42: "Somalia", 43: "Nepal",
	44: "Japan", 45: "Greece", 46: "South Korea", 47: "Philippines",
	48: "Grenada", 49: "Malaysia", 50: "Indonesia", 51: "USA",
	52: "Singapore", 53: "Sudan", 54: "Morocco", 55: "Tunisia",
	56: "Niger", 57: "Chad", 58: "Mali", 59: "Mauritania",
	60: "Nigeria", 61: "Upper Volta", 62: "Benin", 63: "Ghana",
	64: "Côte d'Ivoire", 65: "CAR", 66: "Cameroon", 67: "Liberia",
	68: "Guinea", 69: "Tibet", 70: "Uyghuristan",
	71: "Argentina", 72: "Bolivia", 73: "Brazil", 74: "Chile",
	75: "Colombia", 76: "Ecuador", 77: "Guyana", 78: "Guiana",
	79: "Paraguay", 80: "Peru", 81: "Suriname", 82: "Uruguay",
	83: "Venezuela",
	84: "Turkey", 85: "Italy", 86: "Spain", 87: "Portugal",
	88: "Belgium", 89: "Holland", 90: "Denmark", 91: "Norway",
	92: "Great Britain", 93: "Lebanon", 94: "Divided Cyprus",
	95: "Kurdistan", 96: "Sri Lanka", 97: "Bhutan", 98: "Slovakia",
	99: "Eritrea", 100: "Tigray", 101: "Saudi Arabia", 102: "UAE",
	103: "Qatar", 104: "Jordania", 105: "Oman", 106: "Djibouti",
	107: "Sierra Leone", 108: "Togo", 109: "Basque Country",
	110: "Catalonia", 111: "Ainu Utari",
}


# ============================================================================
# 政治家数据 -- 18 人，每人 7 字段
# [polit_id, faction, trait_personality, experience, age, loyalty, power]
# ============================================================================
const POLITICIAN_ROWS := [
	[1,  1,  0, 4, 19, 83, 100],  # Jiang Qing
	[0,  0,  0, 4,  8, 61,  85],  # Jiang Zedong (Mao's record)
	[3,  3,  0, 4, 16, 41,  80],  # Jiang Guofeng (Hua Guofeng)
	[4,  4,  0, 4, 16, 59,  70],  # Wang Hongwen
	[5,  5,  0, 4, 12, 45,  65],  # Zhang Chunqiao
	[6,  6,  0, 4,  9, 60,  70],  # Yao Wenyuan
	[7,  7,  1, 4, 11, 67,  65],  # Wang Dongxing
	[8,  8,  2, 7, 16, 79,  60],  # Li Xiannian
	[9,  9,  0, 5, 11, 53,  60],  # Ye Jianying
	[10, 10, 0, 5, 16, 61,  55],  # Ji Dengkui
	[11, 11, 0, 4,  8, 63,  55],  # Cheng Xilian
	[12, 12, 1, 4, 10, 67,  50],  # Wu De
	[13, 13, 2, 5, 11, 72,  40],  # Huang Hua (Deng Xiaoping record)
	[14, 14, 3, 6, 15, 57,  45],  # Deng Xiaoping (Zhao Ziyang record)
	[15, 15, 3, 6, 13, 61,  40],  # Zhao Yaobang (Hu Yaobang record)
	[16, 16, 2, 5, 11, 71,  35],  # Hu Yun (Chen Yun record)
	[17, 17, 1, 4, 14, 68,  40],  # Chen Zhen (Wang Zhen record)
	[18, 18, 2, 6, 17, 74,  25],  # Wang Qiao (Qiao Guanhua record)
]

# 名（按 trait_personality 索引）
const GIVEN_NAMES := [
	"Jiang", "Mao", "Hua", "Wang", "Zhang", "Yao", "Wang",
	"Li", "Ye", "Ji", "Cheng", "Wu", "Huang", "Deng",
	"Zhao", "Hu", "Chen", "Wang", "Qiao",
]

# 姓（按政治家顺序索引）
const SURNAMES := [
	"Qing", "Zedong", "Guofeng", "Hongwen", "Chunqiao", "Wenyuan",
	"Dongxing", "Xiannian", "Jianying", "Dengkui", "Xilian", "De",
	"Hua", "Xiaoping", "Ziyang", "Yaobang", "Yun", "Zhen",
]


# ============================================================================
# 派系数据 -- 5 个派系，每个 4 字段 [enabled, ally, ideology, seats]
# ============================================================================
const FACTION_ROWS := [
	[1, 0, 600, 600],   # 0 = 极左派
	[1, 0, 900, 900],   # 1 = 保守派
	[1, 0, 300, 300],   # 2 = 温和派
	[1, 0, 160, 200],   # 3 = 改良派
	[0, 0,  40,   0],   # 4 = 自由派
]

# 派系领袖对应的 politician 索引
const FACTION_LEADERS := [1, 10, 15, 12, 13]


# ============================================================================
# 领导人初始设定
# ============================================================================
const LEADER_INDEX := 2      # politicians 数组索引
const LEADER_AGE := 55        # 华国锋 1976 年实际年龄
const LEADER_LOYALTY := 16


# ============================================================================
# 初始修正 ID 列表
# ============================================================================
const START_MODIFIER_IDS := [0, 1, 3, 6, 14, 15, 54, 55, 59]


# ============================================================================
# 科技初始解锁状态（10 个槽位）
# ============================================================================
const SCIENCE_UNLOCKED := [
	false, false, false, true, false,
	false, true, false, false, false,
]


# ============================================================================
# 主入口 -- 创建新游戏世界状态
# ============================================================================

static func create_world(player_gwcode: int = 710, difficulty: int = 2) -> WorldState:
	var ws := WorldState.new()
	ws.date = GameDate.new(1, 1, 1976)
	ws.player_country_gwcode = player_gwcode
	ws.difficulty = difficulty

	_build_countries(ws)
	_assign_country_names(ws)
	_assign_real_gwcodes(ws)
	ws.rebuild_gwcode_index()
	_fill_data_array(ws)
	_build_politicians(ws)
	_build_factions(ws)
	_set_leader(ws)
	_init_modifiers(ws)
	_init_science(ws)
	_init_empires(ws)
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

static func _build_countries(ws: WorldState) -> void:
	for row in COUNTRY_ROWS:
		var cd := CountryData.new()
		cd.gwcode = row[0]
		cd.原版序号 = row[0]

		# 保存原始字段（调试/兼容用）
		cd.原始字段.resize(19)
		for i in 19:
			cd.原始字段[i] = row[i]

		# 联盟/外交标签（字段 1-10）
		for i in range(1, 11):
			if row[i] == 1:
				cd.tags[TAG_FIELDS[i]] = true

		# 数值属性（字段 12-13）
		cd.stability = row[12]
		cd.development = row[13]

		# 大国影响力（字段 14-16）
		cd.sov_power = row[14]
		cd.usa_power = row[15]
		cd.prc_power = row[16]

		# 政体（字段 17-18）
		cd.government = row[17]
		cd.sub_government = row[18]

		ws.countries.append(cd)

	print("WorldFactory: 构建了 %d 个国家" % ws.countries.size())


# ============================================================================
# 国家名称 -- 从嵌入字典按 gwcode 赋值
# ============================================================================

static func _assign_country_names(ws: WorldState) -> void:
	for c in ws.countries:
		if COUNTRY_NAMES.has(c.gwcode):
			c.name = COUNTRY_NAMES[c.gwcode]


# ============================================================================
# gwcode 修正 -- 用 map_countries.json 建立内部索引→真实 gwcode 映射
# ============================================================================
# 匹配策略（按可靠性递减）：
#   1. 别名表 NAME_ALIASES
#   2. 规范化名精确匹配
#   3. 规范化名双向 contains 兜底

static func _assign_real_gwcodes(ws: WorldState) -> void:
	var map_countries := _load_json_as_dict(MAP_DIR + "/map_countries.json")
	if map_countries.is_empty():
		push_warning("WorldFactory: map_countries.json 缺失，CountryData.gwcode 未修正")
		return

	# 构建 规范化国名 → 真实 gwcode
	var name_to_gwcode: Dictionary = {}
	for gw_key in map_countries.keys():
		var entry: Dictionary = map_countries[gw_key]
		var nm := _normalize_country_name(String(entry.get("name_1976", "")))
		if nm != "":
			name_to_gwcode[nm] = int(gw_key)

	var matched := 0
	var unmatched_log: Array[String] = []
	for c in ws.countries:
		var hr_name := _normalize_country_name(c.name)
		if NAME_ALIASES.has(hr_name):
			hr_name = String(NAME_ALIASES[hr_name])
		var gw := 0
		if name_to_gwcode.has(hr_name):
			gw = int(name_to_gwcode[hr_name])
		else:
			# contains 双向兜底
			for map_name in name_to_gwcode.keys():
				if map_name in hr_name or hr_name in map_name:
					gw = int(name_to_gwcode[map_name])
					break
		if gw > 0:
			c.gwcode = gw
			var gw_str := str(gw)
			if map_countries.has(gw_str):
				var entry: Dictionary = map_countries[gw_str]
				var zh_name: String = entry.get("name_zh", "")
				if zh_name != "":
					c.chinese_name = zh_name
				var gn = entry.get("gov_names", null)
				if gn is Dictionary:
					for k in gn:
						c.gov_names[int(k)] = String(gn[k])
			matched += 1
		else:
			unmatched_log.append("%s(idx=%d)" % [c.name, c.原版序号])

	print("WorldFactory: gwcode 修正完成 %d/%d 匹配" % [matched, ws.countries.size()])
	if unmatched_log.size() > 0 and unmatched_log.size() <= 40:
		print("  未匹配(无真实gwcode，地图上无区域): %s" % str(unmatched_log))


# ============================================================================
# 数值表 -- 从嵌入数组填充 WorldState.数值表[200]
# ============================================================================

static func _fill_data_array(ws: WorldState) -> void:
	ws.数值表.resize(200)
	for i in DATA_VALUES.size():
		ws.数值表[i] = DATA_VALUES[i]
	print("WorldFactory: 数值表[150] 加载完成")


# ============================================================================
# 政治家 -- 从嵌入数据创建 PoliticianData 对象
# ============================================================================

static func _build_politicians(ws: WorldState) -> void:
	for row in POLITICIAN_ROWS:
		var pd := PoliticianData.new()
		pd.trait_personality = row[2]   # trait_id
		pd.faction = row[1]             # party_id
		pd.experience = row[3]
		pd.age = row[4]
		pd.loyalty = row[5]
		pd.power = row[6]
		ws.politicians.append(pd)

	# 组装显示名称
	for i in ws.politicians.size():
		var pd := ws.politicians[i]
		var fn: String = GIVEN_NAMES[pd.trait_personality] \
			if pd.trait_personality < GIVEN_NAMES.size() else "?"
		var ln: String = SURNAMES[i] if i < SURNAMES.size() else "?"
		pd.name_display = fn + " " + ln

	print("WorldFactory: 加载了 %d 位政治家" % ws.politicians.size())


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
		fd.influence = row[2]    # influence = ideology（原版逻辑）
		fd.support = row[3]
		fd.seats = row[3]
		ws.factions.append(fd)

	# 派系领袖
	for i in mini(FACTION_LEADERS.size(), ws.factions.size()):
		ws.factions[i].leader_index = FACTION_LEADERS[i]

	print("WorldFactory: 加载了 %d 个派系" % ws.factions.size())


# ============================================================================
# 领导人 -- 从 politicians 数组指定索引取出并覆盖属性
# ============================================================================

static func _set_leader(ws: WorldState) -> void:
	if LEADER_INDEX >= 0 and LEADER_INDEX < ws.politicians.size():
		ws.leader = ws.politicians[LEADER_INDEX]
	else:
		ws.leader = PoliticianData.new()
	ws.leader.age = LEADER_AGE
	ws.leader.loyalty = LEADER_LOYALTY


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
	usa.power = 1000
	usa.relations = 70
	usa.leaders = [EmpireLeader.new("Gerald Ford", 60)]

	var ussr := EmpireData.new(EmpireData.USSR)
	ussr.money = 800
	ussr.power = 900
	ussr.relations = 30
	ussr.leaders = [EmpireLeader.new("Leonid Brezhnev", 75)]

	ws.empires = [usa, ussr]
	print("WorldFactory: 超级大国加载完成")


# ============================================================================
# 后处理覆盖 -- 原版 GameStartScript 硬编码的初始化修正
# ============================================================================

static func _apply_post_load_overrides(ws: WorldState, difficulty: int) -> void:
	# 清零区间（原版 lines 627-645）
	for i in range(111, 126):
		ws.数值表[i] = 0
	ws.数值表[105] = 2
	ws.数值表[WorldState.I_SATISFIED] = 0       # 满意现秩序者开局为 0
	ws.数值表[WorldState.I_OLIGARCH] = 0        # 寡头影响力
	if ws.数值表.size() > WorldState.I_INDUSTRY_BASE:
		ws.数值表[WorldState.I_INDUSTRY_BASE] = 350
	ws.数值表[27] = 0
	ws.数值表[0] = 0
	ws.数值表[85] = 0

	# 随机外交参数
	ws.数值表[47] = randi_range(1, 5)
	ws.数值表[48] = randi_range(1, 5)
	ws.数值表[49] = randi_range(1, 5)

	# 难度调整
	match difficulty:
		0:  # 沙盒
			ws.数值表[WorldState.I_PARTY_SUPPORT] = 1000
			ws.数值表[WorldState.I_PEOPLE_SUPPORT] = 1000
			ws.数值表[WorldState.I_THOUGHT_FREEDOM] = 0
			ws.数值表[WorldState.I_BUDGET] += 500
			ws.数值表[WorldState.I_SCIENCE] = 700
		1:  # 简单
			ws.数值表[WorldState.I_BUDGET] += 100
			ws.数值表[WorldState.I_SCIENCE] = 300
		2:  # 普通
			ws.数值表[WorldState.I_SCIENCE] = 0
		3:  # 困难
			ws.数值表[WorldState.I_SCIENCE] = 0


# ============================================================================
# 工具函数
# ============================================================================

# 规范化国名：小写 + 去除空格/标点/连字符，便于跨数据源匹配
static func _normalize_country_name(s: String) -> String:
	return s.to_lower().replace("&", "and").replace(" ", "").replace("-", "") \
		.replace("_", "").replace(",", "").replace(".", "").replace("(", "") \
		.replace(")", "").strip_edges()


# 加载 JSON 文件为 Dictionary（失败返回空字典）
static func _load_json_as_dict(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}
