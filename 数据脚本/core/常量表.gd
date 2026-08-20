# ============================================================================
# GameConstants — 语义常量与枚举表
# ============================================================================
# 目标：消灭散落在各文件里的魔法数字。底层全部是 int，存档兼容。
# 用法：
#   GameConstants.Region.ARUNACHAL
#   GameConstants.GwCode.CHINA
#   GameConstants.WarState.INDIA
#   GameConstants.Government.SOCIALIST
# ============================================================================
class_name GameConstants
extends RefCounted


# ── 地图区域 ID（map_regions.json） ──
const Region := {
	ARUNACHAL = 43,      # 藏南/阿鲁纳恰尔
	FALKLAND = 3030,     # 福克兰/马岛
	BRUNEI = 587,        # 文莱
}

# ── G&W 国家编码（map_countries.json 主键） ──
const GwCode := {
	CHINA = 710,
	TAIWAN = 713,
	ARGENTINA = 160,
	MALAYSIA = 820,
	FRANCE = 220,
	UK = 200,
	USA = 2,
}

# ── 原版数组下标（CountryData.原版序号，事件脚本 allcountries[N]） ──
const LegacySlot := {
	NONE = -1,
	CHINA = 1,
	IRAQ = 14,
	FRANCE = 21,
	TAIWAN = 38,
	SPAIN = 85,
	SOUTH_AFRICA = 131,
	AUSTRALIA = 135,
}

# ── 战争状态（WorldState.war_state） ──
enum WarState {
	PEACE = 0,         # 无战争
	SINO_SOVIET = 1,   # 中苏边境战争
	INDIA = 2,         # 中印边境战争
}

# ── 政体（CountryData.government） ──
enum Government {
	AUTHORITARIAN = 0, # 威权主义
	SOCIALIST = 1,     # 社会主义
	REFORMIST = 2,     # 改良主义
	LIBERAL = 3,       # 自由主义
}

# ── 子意识形态（CountryData.sub_government，0-22） ──
enum SubGovernment {
	LEFT_RADICAL = 0,
	STATE_SOCIALIST = 1,
	MARXIST_LENINIST = 2,
	DEMOCRATIC_SOCIALIST = 3,
	SOCIAL_DEMOCRAT = 4,
	MODERATE = 5,
	LIBERAL = 6,
	RIGHT_AUTHORITARIAN = 7,
	LEFT_CONSERVATIVE = 8,
	NEO_FASCIST = 9,
	LEFT_NATIONALIST = 10,
	TITOIST = 11,
	NEOLIBERAL = 12,
	NEOPATRIARCHAL = 13,
	EUROCOMMUNIST = 14,
	PRAGMATIST = 15,
	SOVIET_STYLE = 16,
	MAOIST = 17,
	TROTSKYIST = 18,
	FEUDAL_SOCIALIST = 19,
	CONSTITUTIONAL_AUTHORITARIAN = 20,
	RENEWAL_SOCIALIST = 21,
	REVOLUTIONARY_NATIONALIST = 22,
}

# ── 战争阵营（WarData.usa_side / ussr_side） ──
enum WarSide {
	NONE = -1,
	SIDE1 = 0,
	SIDE2 = 1,
}

# ── 外交站位（CountryData.establish_government(kind)） ──
enum DiploStance {
	PRO_USA = 0,
	PRO_USSR = 1,
	PRO_CHINA = 2,
	NEUTRAL = 3,
}

# ── 政治家性格 traits[0]（0极左 20保守 1温和 2改革 3自由） ──
enum PoliticianPersonality {
	FAR_LEFT = 0,
	MODERATE = 1,
	REFORMIST = 2,
	LIBERAL = 3,
	CONSERVATIVE = 20,
}

# ── 政治家作风 traits[1] ──
enum PoliticianAlignment {
	HARDLINER = 4,
	PRAGMATIST = 5,
	TOLERANT = 6,
	TECH = 7,
	HEDONIST = 29,
	CONSPIRACY_THEORIST = 30,
	SUBJECTIVIST = 39,
	FENCE_SITTER = 40,
	LOCAL_WARLORD = 41,
	POLITICS_FIRST = 42,
}

# ── 政治家特殊特质 traits[2] ──
enum PoliticianSpecial {
	HARSH = 8,
	PEACE = 9,
	TYRANT = 10,
	ECONOMIST = 11,
	ARROGANT = 12,
	IDOL = 13,
	CHINA_SCHOOL = 14,
	WESTERN_SCHOOL = 15,
	ADVISER = 16,
	SHY = 17,
	CORRUPT = 18,
	SICKLY = 19,
	AGITATOR = 31,
	PEOPLES_FRIEND = 32,
	DIPLOMAT = 33,
	TROTSKYITE = 34,
	OPPORTUNIST = 35,
	MILITARY_TALENT = 36,
	AFFABLE = 37,
	INDOMITABLE = 38,
}

# ── 政治家出身 traits[3] ──
enum PoliticianBackground {
	PARTY_CADRE = 21,
	MASS_LEADER = 22,
	STUDENT_REBEL = 23,
	WORKER_MODEL = 24,
	MILITARY_GENERAL = 25,
	INTELLECTUAL = 26,
	SCIENTIST = 27,
	AMBITIOUS = 28,
	SPECIAL = 43,
}
