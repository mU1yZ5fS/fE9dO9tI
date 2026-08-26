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

# ── 党制（WorldState.party_system，I_PARTY_SYSTEM=15） ──
enum PartySystem {
	ONE_PARTY_DICTATORSHIP = 6, # 一党制共和国 / 无产阶级专政
	NEW_DEMOCRACY = 7,          # 新民主主义制度（一党优势民主）
	PEOPLE_DEMOCRACY = 8,       # 人民民主制度（宪政民主，可选举结盟）
	CONSOCIATIONALISM = 9,      # 协和民主体制（寡头化）
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

# ── 原版数字事件编号（用于 event_result / event_done / completed_event_ids 的 int 键） ──
enum EventNumber {
	JANATA_CRISIS = 72,          # 印度人民党危机（event_072）
	HISTORY_RESOLUTION_1981 = 74, # 关于建国以来党的若干历史问题的决议（event_074）
	RETURN_TO_SOCIALISM = 124,   # 回归社会主义（event_124）
	RE_STALINIZATION = 380,      # 罗曼诺夫宣布实施“再斯大林化”（event_380）
	SOUTH_YEMEN_CRISIS = 437,    # 南也门事变（event_437）
	LONG_REVOLUTION = 444,       # 漫长的革命（event_444）
	TREASURE_ISLAND_RETURN = 457, # 宝岛回归！（event_457）
	FORMOSA_SPRING = 461,        # 福尔摩沙之春（event_461）
	ONE_CHINA = 462,             # 一个中国?（event_462）
	JIAOCHENG_MOUNTAINS = 503,   # 交城的山水实呀实在美（event_503）
	ETHNIC_FEDERALISM = 550,     # 朝花夕拾（event_550）
	MONGOLIA_BREAK = 551,        # 过河拆桥？（event_551）
	COUNTRYMAN = 682,            # 我实在是个乡下人……（event_682）
	REVOLUTIONARY_INTERNATIONAL = 713, # 青出于蓝，而胜于蓝（event_713）
}

# ── 字符串事件 ID（用于 completed_event_ids / _event_result 的 String 键） ──
const EventId := {
	MAKARIOS_DEATH = "event_695",  # 圣徒与罪人之国（event_695）
}

# ── 修正 ID（WorldState.modifiers 下标，对应 ModifierTextData.NAME_ZH） ──
enum Modifier {
	INEFFICIENT_INDUSTRY = 0,
	PALESTINE_DISPUTE = 1,
	SERVICE_SECTOR_DEVELOPMENT = 2,
	CULTURAL_REVOLUTION = 3,
	WIDESPREAD_POVERTY = 4,
	COMPROMISE_WITH_UNDERWORLD = 5,
	MAOIST_BULWARK = 6,
	BLACK_CAT_WHITE_CAT = 7,
	ECONOMIC_UNION = 8,
	LOSS_OF_XINJIANG = 9,
	LOSS_OF_TIBET = 10,
	AUTOMATION_AMBITION = 11,
	BACKWARD_ECONOMY = 12,
	BOOMING_SMALL_BUSINESS = 13,
	LEGACY_OF_1975_RECTIFICATION = 14,
	AGRICULTURE_DEVELOPMENT = 15,
	SOVIET_EMBARGO = 16,
	USA_EMBARGO = 17,
	TENTH_PANCHEN_LAMA = 18,
	FOURTEENTH_DALAI_LAMA = 19,
	HANBO_LAMA = 20,
	SAIFUDIN_AZIZI = 21,
	BURHAN_SHAHIDI = 22,
	ERKIN_ALPTEKIN = 23,
	FACTIONAL_ONE_PARTY_DEMOCRACY = 24,
	CONFUCIAN_VICTORY = 25,
	LEGALIST_VICTORY = 26,
	EASTERN_ROME = 27,
	CONSTITUTION_75 = 28,
	SOVIET_STYLE_CONSTITUTION = 29,
	LEFTIST_MARKET_CONSTITUTION = 30,
	WESTERN_STYLE_CONSTITUTION = 31,
	RED_GUARDS_IN_POWER = 32,
	CIVILIANS_IN_MILITARY_COMMISSION = 33,
	CHINA_NATURE_TRANSFORMATION_PLAN = 34,
	NATIONAL_RAILWAY_NETWORK = 35,
	INTERNATIONAL_PATENT_MEMBER = 36,
	HELSINKI_ACCORDS_MEMBER = 37,
	PRESIDENT_FOR_LIFE = 38,
	CHINESE_GANGS_IN_AMERICA = 39,
	RETURN_TO_AGRARIAN_CIVILIZATION = 40,
	HUNTING_CLUB_MEMBER = 41,
	FRENCH_PRESIDENT_GISCARD = 42,
	FRENCH_PRESIDENT_MITTERRAND = 43,
	FRENCH_PRESIDENT_MARCHAIS = 44,
	FRENCH_PRESIDENT_CHIRAC = 45,
	ARAB_FEDERATION = 46,
	SECRET_SERVICE_INTEGRATION = 47,
	MILITARY_INTEGRATION = 48,
	FOURTH_INTERNATIONAL = 49,
	MILITARY_DEVELOPMENT = 50,
	OIL_MONEY = 51,
	SUBSIDIZE_ALLIES = 52,
	COOPERATE_WITH_STASI = 53,
	US_PARTY_INFLUENCE = 54,
	SOVIET_FACTION_INFLUENCE = 55,
	FRENCH_CANDIDATE_MOMENTUM = 56,
	UK_LABOUR_POWER = 57,
	EAST_SIBERIA_PACIFIC_PIPELINE = 58,
	OUR_MILITARY_ALLIANCE = 59,
	DEEP_TROUBLE = 60,
	NATIONAL_SYMBOL = 61,
	ITALY_1983_ELECTION_FORECAST = 62,
	CULTURAL_LEAP_FORWARD = 63,
	MONEY_MAKING = 65,
}
