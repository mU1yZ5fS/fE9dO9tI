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
	"holland": "netherlands",
	"uae": "unitedarabemirates",
	"cotedivoire": "cotedivoire",
	"ctedivoire": "cotedivoire",  # Côte → c + te（ô 被剥掉）
	"uppervolta": "burkinafasouppervolta",
	"car": "centralafricanrepublic",
	"suriname": "surinam",
	"kampuchea": "cambodiakampuchea",
	"jordania": "jordan",
	"sovietunion": "russiasovietunion",
	"dividedcyprus": "cyprus",
	"romania": "rumania",
	"vietnam": "vietnamdemocraticrepublicof",
	"turkey": "turkeyottomanempire",
	"iran": "iranpersia",
	"italy": "italysardinia",
	"srilanka": "srilankaceylon",
}

## 地图上不存在的虚构/分离实体：不得占用 G&W 真实 gwcode（否则点墨西哥会命中维吾尔斯坦）
## 统一映射到 9000+ 原版序号，避免与 map_countries 0~960 冲突
const FICTIONAL_COUNTRY_OFFSET := 9000


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
# 特质中文名 — 对齐原版 Traits1_en + 中文版 level13 用词
# 重要：traits[0] 用 Traits 表，不是 Party 派系表！
#   Traits[0..3]: 0极左 1温和 2改革 3自由
#   Party[0..4]:  0极左 1保守 2温和 3改革 4自由  （多一个「保守」，且 1 起错位）
#   traits[0]→Party 槽：0→0，>0→traits[0]+1（见 Button_Pol_Script 指定派系领袖）
# traits[1]: 4硬汉 5实用主义 6宽容 7科学家
# traits[2]: 8苛刻 9和平 10小暴君 11经管学家 12傲慢 13偶像 14中华派 15西渐派 16谋士 17胆怯 18贪腐 19病弱
const TRAIT_LABELS_ZH := {
	0: "极左派", 1: "温和派", 2: "改革派", 3: "自由派",
	4: "硬汉", 5: "实用主义", 6: "宽容", 7: "科学家",
	8: "苛刻", 9: "和平", 10: "小暴君", 11: "经管学家", 12: "傲慢", 13: "偶像",
	14: "中华派", 15: "西渐派", 16: "谋士", 17: "胆怯", 18: "贪腐", 19: "病弱",
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

# 派系领袖 politician 索引（Party 槽 0..4，非 traits[0] 直映）
# 0极左=江青(1) 1保守=吴德(10) 2温和=陈云(15) 3改革=邓小平(12) 4自由=赵紫阳(13)
const FACTION_LEADERS := [1, 10, 15, 12, 13]


# ============================================================================
# 领导人初始设定（原版 Politics_leader1: 2;2;1;5;16;55 = 华国锋）
# 领袖是独立实体（UI 选中码 150），不在 politics[18] 数组里
# politics[0]=毛泽东（power 后改 99999），politics[1]=江青
# leader.traits[0]=1 → Traits 表「温和派」（不是 Party「保守派」）
# ============================================================================
const LEADER_NAME := "华国锋"
const LEADER_AGE := 55
const LEADER_TRAITS := [1, 5, 16]  # Traits: 温和 / 实用主义 / 谋士
const LEADER_PORTRAIT_PATH := "res://资产/政治家/华国锋.png"
## 职位槽中表示「实权领袖本人」（原版 politics_dolshnost 值 150）
const LEADER_POSITION_SENTINEL := -2


# ============================================================================
# 初始修正 ID 列表
# ============================================================================
const START_MODIFIER_IDS := [0, 1, 3, 6, 14, 15, 54, 55, 59]


# ============================================================================
# 科技初始解锁状态（10 个槽位）
# ============================================================================
const SCIENCE_UNLOCKED := [
	false, false, false, false, false,
	false, false, false, false, false,
]


# ============================================================================
# 主入口 -- 创建新游戏世界状态
# ============================================================================

static func create_world(player_gwcode: int = 710, difficulty: int = 2) -> WorldState:
	var ws := WorldState.new()
	ws.date = GameDate.new(4, 2, 1976)
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
			# 前缀唯一匹配兜底（仅 begins_with，避免 slovakia⊂czechoslovakia、oman⊂romania）
			var best_len := 0
			var best_gw := 0
			var best_count := 0
			for map_name in name_to_gwcode.keys():
				var mn: String = String(map_name)
				if mn.length() < 4 or hr_name.length() < 4:
					continue
				var hit := mn.begins_with(hr_name) or hr_name.begins_with(mn)
				if not hit:
					continue
				var L: int = mini(mn.length(), hr_name.length())
				if L > best_len:
					best_len = L
					best_gw = int(name_to_gwcode[map_name])
					best_count = 1
				elif L == best_len and int(name_to_gwcode[map_name]) != best_gw:
					best_count += 1
			if best_count == 1 and best_gw > 0:
				gw = best_gw
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
			# 关键：内部序号 70/100 与 G&W 墨西哥/哥伦比亚冲突 → 挪到 9000+
			c.gwcode = FICTIONAL_COUNTRY_OFFSET + int(c.原版序号)
			unmatched_log.append("%s(idx=%d→gw=%d)" % [c.name, c.原版序号, c.gwcode])

	print("WorldFactory: gwcode 修正完成 %d/%d 匹配" % [matched, ws.countries.size()])
	if unmatched_log.size() > 0 and unmatched_log.size() <= 40:
		print("  未匹配(虚构/无区域，已偏移到 9000+): %s" % str(unmatched_log))


# ============================================================================
# 数值表 -- 从嵌入数组填充 WorldState.数值表[200]
# ============================================================================

static func _fill_data_array(ws: WorldState) -> void:
	ws.数值表.resize(200)
	for i in DATA_VALUES.size():
		ws.数值表[i] = DATA_VALUES[i]
	print("WorldFactory: 数值表[150] 加载完成")


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
		fd.influence = row[2]    # influence = ideology（原版逻辑）
		fd.support = row[3]      # ≡ party_number
		fd.points = 0
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
	leader.trait_personality = LEADER_TRAITS[0]
	leader.trait_alignment = LEADER_TRAITS[1]
	leader.trait_special = LEADER_TRAITS[2]
	# 独立新游戏：华国锋显示为保守派（Party=1）；traits[0] 仍保留原版 1 供逻辑
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

const INITIAL_POSITIONS := [-2, 0, 17, 10, 9, 15, 13, 3]

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
		var score := 0
		if other.trait_personality == target.trait_personality:
			score += 500
		match target.trait_personality:
			0:
				match other.trait_personality:
					1: score += 50
					2: score -= 150
					3: score -= 300
			1:
				match other.trait_personality:
					0: score += 50
					2: score -= 50
					3: score -= 150
			2:
				match other.trait_personality:
					0: score -= 150
					1: score += 50
					3: score += 100
			3:
				match other.trait_personality:
					0: score -= 300
					1: score -= 150
					2: score += 100
		match target.trait_alignment:
			4:
				if other.trait_alignment == 6:
					score -= 250
				elif other.trait_alignment == 4:
					score += 100
				else:
					score -= 100
			6:
				if other.trait_alignment == 4:
					score -= 300
				elif other.trait_alignment == 6:
					score += 100
				else:
					score += 100
			5:
				if other.trait_alignment != 5:
					score += 100
			7:
				if other.trait_alignment == 6:
					score += 50
		match target.trait_special:
			8:
				match other.trait_special:
					9: score -= 250
					8: score += 100
					10: score += 50
					14: score += 50
			9:
				if other.trait_special == 16:
					score -= 250
				elif other.trait_special != 9:
					score += 50
			10:
				if other.trait_special == 12:
					score += 50
				elif other.trait_special == 10:
					score += 300
				else:
					score -= 100
			11:
				if other.trait_special == 10 or other.trait_special == 12:
					score -= 100
				else:
					score += 100
			12:
				score -= 50
			13:
				score += 100
			14:
				if other.trait_special == 15:
					score -= 300
				elif other.trait_special == 14:
					score += 150
				else:
					score += 50
			15:
				if other.trait_special == 15:
					score += 200
				elif other.trait_special == 14:
					score -= 300
			16:
				if other.trait_special == 9:
					score -= 250
				elif other.trait_special == 14:
					score += 50
			17:
				if other.trait_special == 8:
					score -= 250
				elif other.trait_special == 17:
					score += 300
				else:
					score -= 50
			18:
				if other.trait_special == 11:
					score -= 300
				else:
					score += 10
		# 职位野心冲突
		if _is_holder(ws, 0, num):
			if other.wanted_position == 0:
				score -= 400
		elif _is_holder(ws, 1, num) or _is_holder(ws, 2, num):
			if not _is_holder(ws, 0, i) and (other.wanted_position == 1 or other.wanted_position == 2):
				score -= 400
		elif (
			_is_holder(ws, 3, num) or _is_holder(ws, 4, num) or _is_holder(ws, 5, num)
			or _is_holder(ws, 6, num) or _is_holder(ws, 7, num)
		):
			if (
				not _is_holder(ws, 0, i) and not _is_holder(ws, 1, i) and not _is_holder(ws, 2, i)
				and other.wanted_position >= 3
			):
				score -= 400
		if other.loyalty_matrix.size() <= num:
			other.loyalty_matrix.resize(18)
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
		var score := 0
		if self_pol.trait_personality == other.trait_personality:
			score += 500
		# 以 other 为参照的 traits 差（对齐 CalcRel2 循环变量 i 侧）
		match other.trait_personality:
			0:
				match self_pol.trait_personality:
					1: score += 50
					2: score -= 150
					3: score -= 300
			1:
				match self_pol.trait_personality:
					0: score += 50
					2: score -= 50
					3: score -= 150
			2:
				match self_pol.trait_personality:
					0: score -= 150
					1: score += 50
					3: score += 100
			3:
				match self_pol.trait_personality:
					0: score -= 300
					1: score -= 150
					2: score += 100
		match other.trait_alignment:
			4:
				if self_pol.trait_alignment == 6:
					score -= 250
				elif self_pol.trait_alignment == 4:
					score += 100
				else:
					score -= 100
			6:
				if self_pol.trait_alignment == 4:
					score -= 300
				elif self_pol.trait_alignment == 6:
					score += 100
				else:
					score += 100
			5:
				if self_pol.trait_alignment != 5:
					score += 100
			7:
				if self_pol.trait_alignment == 6:
					score += 50
		# 职位野心：若 i 在职且 num 想要该职
		if _is_holder(ws, 0, i):
			if self_pol.wanted_position == 0:
				score -= 400
		elif _is_holder(ws, 1, i) or _is_holder(ws, 2, i):
			if not _is_holder(ws, 0, num) and (self_pol.wanted_position == 1 or self_pol.wanted_position == 2):
				score -= 400
		elif (
			_is_holder(ws, 3, i) or _is_holder(ws, 4, i) or _is_holder(ws, 5, i)
			or _is_holder(ws, 6, i) or _is_holder(ws, 7, i)
		):
			if (
				not _is_holder(ws, 0, num) and not _is_holder(ws, 1, num) and not _is_holder(ws, 2, num)
				and self_pol.wanted_position >= 3
			):
				score -= 400
		self_pol.loyalty_matrix[i] = score


static func _calc_rel_leader(ws: WorldState, num: int) -> void:
	## 原版 CalcRelLeader：politics[num].loyality 对领袖的忠诚
	if num < 0 or num >= ws.politicians.size() or ws.leader == null:
		return
	var pol: PoliticianData = ws.politicians[num]
	var leader: PoliticianData = ws.leader
	var d := ws.数值表
	var score := 100
	# data[52] 经济显示档 / data[54] 政治显示档 / data[14] 意识形态 — 开局常量
	match d[WorldState.I_ECON_DISPLAY] if d.size() > WorldState.I_ECON_DISPLAY else 0:
		34:
			match pol.trait_personality:
				0: score += 250
				1: score += 150
				2: score -= 100
				3: score -= 150
		35:
			match pol.trait_personality:
				0: score += 100
				1: score += 250
				2: score += 150
				3: score -= 100
		36:
			match pol.trait_personality:
				0: score -= 100
				1: score += 150
				2: score += 250
				3: score += 50
		37:
			match pol.trait_personality:
				0: score -= 150
				1: score -= 100
				2: score += 150
				3: score += 250
	match d[WorldState.I_POLITICAL_DISPLAY] if d.size() > WorldState.I_POLITICAL_DISPLAY else 0:
		38:
			match pol.trait_personality:
				0: score += 150
				1: score -= 150
				2: score -= 200
				3: score += 250
		39:
			match pol.trait_personality:
				0: score += 100
				1: score -= 50
				2: score -= 100
				3: score += 50
		40:
			match pol.trait_personality:
				0: score -= 100
				1: score += 100
				2: score += 150
		41:
			match pol.trait_personality:
				0: score -= 150
				1: score -= 50
				2: score += 150
				3: score += 100
	match d[WorldState.I_IDEOLOGY] if d.size() > WorldState.I_IDEOLOGY else 0:
		0:
			if pol.trait_alignment == 4:
				score += 250
			elif pol.trait_alignment == 6:
				score -= 150
		1:
			if pol.trait_alignment == 4:
				score += 250
			elif pol.trait_alignment == 5:
				score -= 150
			elif pol.trait_alignment == 7:
				score -= 150
		2:
			if pol.trait_alignment == 4:
				score += 100
			elif pol.trait_alignment == 5:
				score += 150
			elif pol.trait_alignment == 7:
				score -= 100
		3:
			if pol.trait_alignment == 4:
				score += 100
			elif pol.trait_alignment == 5:
				score += 250
			elif pol.trait_alignment == 7:
				score -= 100
		4:
			if pol.trait_alignment == 4:
				score -= 150
			elif pol.trait_alignment == 6:
				score += 200
			elif pol.trait_alignment == 5:
				score += 50
			elif pol.trait_alignment == 7:
				score += 100
		5:
			if pol.trait_alignment == 4:
				score -= 250
			elif pol.trait_alignment == 6:
				score += 300
			elif pol.trait_alignment == 5:
				score -= 150
			elif pol.trait_alignment == 7:
				score += 250
	if leader.trait_personality == pol.trait_personality:
		score += 300
	match leader.trait_alignment:
		4:
			if pol.trait_alignment == 6:
				score -= 150
			elif pol.trait_alignment == 4:
				score += 100
			else:
				score -= 100
		6:
			if pol.trait_alignment == 4:
				score -= 200
			elif pol.trait_alignment == 6:
				score += 100
			else:
				score += 100
		5:
			if pol.trait_alignment != 5:
				score += 100
		7:
			if pol.trait_alignment == 6:
				score += 50
	match leader.trait_special:
		8:
			match pol.trait_special:
				9: score -= 150
				8: score += 100
				10: score += 50
				14: score += 50
		9:
			if pol.trait_special == 16:
				score -= 150
			elif pol.trait_special != 9:
				score += 50
		10:
			if pol.trait_special == 12:
				score += 50
			elif pol.trait_special == 10:
				score += 300
			else:
				score -= 100
		11:
			if pol.trait_special == 10 or pol.trait_special == 12:
				score -= 100
			else:
				score += 100
		12:
			score -= 50
		13:
			score += 100
		14:
			if pol.trait_special == 15:
				score -= 200
			elif pol.trait_special == 14:
				score += 150
			else:
				score += 50
		15:
			if pol.trait_special == 15:
				score += 200
			elif pol.trait_special == 14:
				score -= 200
		16:
			if pol.trait_special == 9:
				score -= 150
			elif pol.trait_special == 14:
				score += 50
		17:
			if pol.trait_special == 8:
				score -= 150
			elif pol.trait_special == 17:
				score += 300
			else:
				score -= 50
		18:
			if pol.trait_special == 11:
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
	usa.power = ws.数值表[WorldState.I_USA_INFLUENCE]      # 原版 empires[0].power = data[10] = 280
	usa.relations = ws.数值表[28]                            # 原版 empires[0].relations = data[28] = 700
	usa.leaders = [EmpireLeader.new("Gerald Ford", 60)]

	var ussr := EmpireData.new(EmpireData.USSR)
	ussr.money = 800
	ussr.power = ws.数值表[WorldState.I_SOVIET_INFLUENCE]   # 原版 empires[1].power = data[2] = 300
	ussr.relations = ws.数值表[29]                           # 原版 empires[1].relations = data[29] = 300
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
	ws.数值表[WorldState.I_WAR_RESOLVE] = -1
	ws.数值表[WorldState.I_MIL_INTERVENTION] = 0

	# 随机外交参数
	ws.数值表[47] = randi_range(1, 4)
	ws.数值表[48] = randi_range(1, 4)
	ws.数值表[49] = randi_range(1, 4)

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
# 代理战争槽 -- 按 WarCatalog 生成
# ============================================================================

static func _init_wars(ws: WorldState) -> void:
	ws.wars.clear()
	var ids: Array = WarCatalog.all_ids()
	if ids.is_empty():
		for i in 7:
			var empty := WarData.new()
			empty.name_war = "战争 #%d" % i
			empty.fortnight_max = 48
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
		w.fortnight_max = def.fortnight_max if def else 48
		w.fortnight_elapsed = 0
		w.diplo_done = [false, false]
		ws.wars[iid] = w
	print("WorldFactory: 加载了 %d 个战争槽" % ws.wars.size())


# ============================================================================
# 工具函数
# ============================================================================

# 规范化国名：小写 + 去重音 + 去除空格/标点/连字符，便于跨数据源匹配
static func _normalize_country_name(s: String) -> String:
	var t := s.to_lower().replace("&", "and")
	# 常见西欧重音 → ASCII（Côte / São 等）
	const FROM := "àáâãäåāăąèéêëēĕėęěìíîïĩīĭįıòóôõöøōŏőùúûüũūŭůűýÿçñśźż"
	const TO := "aaaaaaaaaeeeeeeeeeeiiiiiiiiiooooooooouuuuuuuuuyycnszz"
	for i in mini(FROM.length(), TO.length()):
		t = t.replace(FROM[i], TO[i])
	var out := ""
	for i in t.length():
		var ch := t[i]
		var code := ch.unicode_at(0)
		if (code >= 97 and code <= 122) or (code >= 48 and code <= 57):
			out += ch
	return out


# 加载 JSON 文件为 Dictionary（失败返回空字典）
static func _load_json_as_dict(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}
