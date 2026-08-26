class_name EventGraphLexicon
extends RefCounted

# ============================================================================
# 事件拓扑图 —— 具义化词典：把 META 里的裸键翻译成玩家可读名称。
# ============================================================================
# 全部为静态懒加载目录，主菜单（无活动世界）下也可用：
#   资源键   → 中文名（含 ×10 缩放标记，渲染时自动 ÷10）
#   帝国编号 → 美国/苏联
#   国家原版序号 → country_identity.json → gwcode → map_countries 的 name_zh
#              （事件条件 target 数字一律是【原版序号】，与 EventEngine._resolve_country
#                同语义；直接当 gwcode 查会张冠李戴，如 66=喀麦隆 ≠ gw66=马提尼克）
#   地块 id  → 资产/地图/map_regions.json 的 name_zh
#   修正索引 → ModifierCatalog.name_zh
#   派系编号 → FactionData.FACTION_NAMES
#   战争 id  → 资产/数据/战争/war_NN.tres 的 name_zh
#   决议编号 → DecisionCatalog.get_def(idx).title
#   科技编号 → TECH_NAMES（与 科研.gd 同序）
#   联盟标签 / 国家字段 / 政治家性格 → 中文名与枚举值具意化
# ============================================================================

const MAP_COUNTRIES := "res://资产/地图/map_countries.json"
const MAP_REGIONS := "res://资产/地图/map_regions.json"
const WAR_DIR := "res://资产/数据/战争/"
const COUNTRY_IDENTITY := "res://资产/数据/初始/country_identity.json"
const DECISION_CATALOG_SRC := "res://数据脚本/decision_catalog.gd"
const CD := preload("res://数据脚本/core/country_data.gd")

## 与 WorldFactory.FICTIONAL_COUNTRY_OFFSET 对齐：9000+ = 地图上不存在的虚构实体
const FICTIONAL_GW_OFFSET := 9000

## 虚构实体中文名（对齐 WorldFactory.OFFSET_COUNTRY_NAMES_ZH，key=原版序号）
const FICTIONAL_NAMES_ZH := {
	18: "西撒哈拉",
	69: "西藏", 70: "维吾尔斯坦",
	95: "库尔德斯坦",
	145: "格陵兰岛", 150: "南苏丹", 151: "达尔富尔",
	153: "纳米比亚", 155: "塞舌尔", 156: "阿扎瓦德",
	157: "库尔德斯坦二号", 159: "瓦努阿图", 162: "南极洲",
	163: "加丹加", 164: "安哥拉独", 165: "尼日利亚独", 166: "北爱尔兰",
	167: "魁北克", 168: "南墨西哥",
}

## 资源键 → 中文名；value[1]=true 表示内部 ×10 存储（显示 ÷10）
const RESOURCES := {
	"mil_intervention": ["军事介入点", true],
	"party_support": ["党内支持", true],
	"people_support": ["民众支持", true],
	"soviet_influence": ["苏联影响力", false],
	"usa_influence": ["美国影响力", false],
	"thought_freedom": ["思想自由", false],
	"living_standard": ["生活水平", false],
	"diplo": ["国际声望", true],
	"influence_prc": ["全球影响力", false],
	"budget": ["预算", true],
	"money": ["预算", true],
	"agents": ["特工网络", false],
	"science": ["科研点数", false],
	"industry": ["工业产值", false],
	"agriculture": ["农业产值", false],
	"ideology": ["意识形态", false],
	"party_system": ["政党制度", false],
	"econ_system": ["经济体制", false],
	"press_policy": ["舆论政策", false],
	"territory": ["领土制度", false],
	"army": ["军力", true],
	"income": ["收入", true],
	"trade_partners": ["贸易伙伴数", false],
	"corruption": ["腐败", false],
	"war_support": ["战争支持度", false],
	"naxalite_power": ["纳萨尔派力量", false],
	"econ_openness": ["经济开放度", false],
	"population": ["人口(万)", false],
	"reserve": ["外汇储备", false],
	"stability": ["政治稳定", false],
	"war_pressure": ["中苏战争压力", false],
	"india_war_pressure": ["中印边境攻势", false],
	"reform_stage": ["改革阶段", false],
	"political_line": ["政治路线", false],
}

const FD := preload("res://数据脚本/core/faction_data.gd")

## 34 项科技名（与 场景/科研界面/科研.gd TECH_NAMES 同序，勿改动顺序）
const TECH_NAMES: Array[String] = [
	"大跃进的遗产", "巩固农业设施", "农业方法革新",
	"发展农业机械化", "选育与基因研究", "新增研究设施",
	"新型肥料与杀虫剂", "遗传修饰", "开垦处女地",
	"改良流水线生产模式", "自研工业科技", "工业设施中国化",
	"电子工业中国化", "现代制造业", "改进国内工业机械",
	"自动化生产控制", "计算机化", "中国版的OGAS",
	"加强军备开发", "情报部门新装备", "新式间谍装备",
	"发展核武器与导弹", "迎接信息化战争", "更新军队装备",
	"发展海军与空军", "现代间谍装备", "指挥链与军事组织改革",
	"通讯卫星", "导航卫星", "军事卫星",
	"载人航天", "行星际飞行器", "轨道空间站", "航天飞机",
]

## 联盟标签 → 中文名（与 国家面板.gd MIL/ECON_ALLIANCE_NAMES 一致；
## 已是中文的标签（亲美/亲中/对华贸易…）由 tag_name 原样返回）
const TAG_NAMES := {
	"nazimao": "欧罗巴解放阵线", "fxseu": "欧洲社会国家组织",
	"ovd": "华约组织", "rim": "革命国际",
	"okb": "集体安全条约", "nato": "北约", "seato": "东约组织",
	"sento": "中央条约组织",
	"sev": "经互会", "econ": "经济合作组织", "oil": "海湾合作委员会",
	"soc_eu": "社会主义联盟", "eu": "欧洲经济共同体", "asean": "东盟",
}

## 国家字段 key → 中文名（对齐 EventEngine._get_country_field 支持的字段）
const FIELD_LABELS := {
	"government": "政体", "gosstroy": "政体",
	"sub_government": "子意识形态", "subgosstroy": "子意识形态",
	"stability": "稳定度", "social_stability": "社会稳定度",
	"development": "发展度", "level_of_development": "开发等级",
	"level_of_instability": "不稳定度",
	"special": "特殊状态号", "special_ending": "特殊结局号",
	"sov_power": "苏联势力", "usa_power": "美国势力",
	"prc_power": "中国势力", "fre_power": "法国势力",
	"puppet_of": "宗主国",
	"cw": "内战中", "civil_war": "内战中",
	"perevorot": "政变中", "based": "有驻军基地",
	"stab": "稳定标志", "econ": "经济合作组织成员",
}

## 0/1 布尔型国家字段
const BOOL_FIELDS := ["cw", "civil_war", "perevorot", "based", "econ"]

## 战争字段 key → 中文名（WAR_FIELD_EQUALS 的 key）
const WAR_FIELD_LABELS := {
	"usa_side": "美国阵营", "ussr_side": "苏联阵营",
}

## 政治家性格 traits[0]（对齐 GameConstants.PoliticianPersonality）
const PERSONALITY_NAMES := {
	0: "极左派", 1: "温和派", 2: "改革派", 3: "自由派", 20: "保守派",
}

static var _countries := {}
static var _regions := {}
static var _wars := {}
static var _identity := {}
static var _decision_titles: Array[String] = []


## ── 资源 ──────────────────────────────────────────────────────────────────
static func resource_entry(key: String) -> Array:
	var k := key.to_lower()
	if RESOURCES.has(k):
		return RESOURCES[k]
	return []


static func resource_label(key: String) -> String:
	var e := resource_entry(key)
	return e[0] if not e.is_empty() else key


static func resource_tenfold(key: String) -> bool:
	var e := resource_entry(key)
	return (not e.is_empty()) and bool(e[1])


## ── 帝国 ──────────────────────────────────────────────────────────────────
static func empire_name(idx: int) -> String:
	match idx:
		0: return "美国"
		1: return "苏联"
		_: return "帝国%d" % idx


## ── 国家 / 地块 / 修正 / 派系 / 战争 ─────────────────────────────────────
## 事件条件 target 数字 = 原版序号（与 EventEngine._resolve_country 同语义）。
## 链路：country_identity.json（原版序号→gwcode）→ map_countries name_zh；
##       gw≥9000 的虚构实体走 FICTIONAL_NAMES_ZH；身份表查不到再按 gwcode 兜底。
static func country_name_by_legacy(legacy_idx: int) -> String:
	if legacy_idx < 0:
		return ""
	_ensure_geo()
	_ensure_identity()
	var gw := int(_identity.get(legacy_idx, -1))
	if gw >= FICTIONAL_GW_OFFSET:
		return str(FICTIONAL_NAMES_ZH.get(legacy_idx, ""))
	if gw > 0:
		var nm := country_name(gw)
		if nm != "":
			return nm
	return country_name(legacy_idx)


static func country_name(gwcode: int) -> String:
	_ensure_geo()
	var c: Dictionary = _countries.get(str(gwcode), {})
	if c.is_empty():
		return ""
	return str(c.get("name_zh", c.get("name_1976", "")))


static func region_name(region_id: int) -> String:
	_ensure_geo()
	var r: Dictionary = _regions.get(str(region_id), {})
	if r.is_empty():
		return ""
	return str(r.get("name_zh", r.get("name", "")))


static func modifier_name(id: int) -> String:
	var nm := ModifierCatalog.name_zh(id)
	return nm if nm != "" else "修正%d" % id


static func faction_name(idx: int) -> String:
	var names: Array[String] = FD.FACTION_NAMES
	return names[idx] if idx >= 0 and idx < names.size() else "派系%d" % idx


static func war_name(war_id: int) -> String:
	_ensure_wars()
	return str(_wars.get(war_id, "战争%d" % war_id))


## ── 标签 / 国家字段 / 科技 / 决议 / 性格 ─────────────────────────────────
static func tag_name(tag: String) -> String:
	return TAG_NAMES.get(tag, tag)


static func tech_name(idx: int) -> String:
	return TECH_NAMES[idx] if idx >= 0 and idx < TECH_NAMES.size() else ""


## 决议标题：静态扫描 decision_catalog.gd 源码的 _new(N, _s("标题")) 声明序。
## 刻意不走 DecisionCatalog.build()——它在无活动世界时构建 req 会执行条件
## lambda 并刷屏报错（_build_req 逐条 e[1].call()），拓扑图在主菜单也要可用。
## 下标 = completed[] 决议编号（源码顺序即 _defs 追加顺序）。
static func decision_name(idx: int) -> String:
	if _decision_titles.is_empty():
		var rx := RegEx.create_from_string("_new\\(\\d+,\\s*_s\\(\"([^\"]+)\"")
		for m in rx.search_all(_source_text(DECISION_CATALOG_SRC)):
			_decision_titles.append(m.get_string(1).replace(" ", ""))
	return _decision_titles[idx] if idx >= 0 and idx < _decision_titles.size() \
			else "决议%d" % idx


static var _src_cache := {}

static func _source_text(path: String) -> String:
	if not _src_cache.has(path):
		var f := FileAccess.open(path, FileAccess.READ)
		_src_cache[path] = f.get_as_text() if f != null else ""
		if f != null:
			f.close()
	return _src_cache[path]


static func personality_name(idx: int) -> String:
	return PERSONALITY_NAMES.get(idx, "性格%d" % idx)


## WAR_FIELD_EQUALS 的字段名 → 中文
static func war_field_label(key: String) -> String:
	return WAR_FIELD_LABELS.get(key.to_lower(), key)


## 战争阵营值 → 具意（对齐 GameConstants.WarSide：-1未参战 0第一阵营 1第二阵营）
static func war_side_label(v: float) -> String:
	match int(v):
		-1: return "未参战"
		0: return "第一阵营"
		1: return "第二阵营"
		_: return String.num(v, 0)


## 国家字段 key → 中文名（未知键原样返回，便于发现新字段）
static func field_label(key: String) -> String:
	return FIELD_LABELS.get(key.to_lower(), key)


## 国家字段值 → 具意文本：枚举字段译名，布尔字段 是/否，其余数值
static func field_value(key: String, v: float) -> String:
	var k := key.to_lower()
	match k:
		"government", "gosstroy":
			return str(CD.GOV_NAME.get(int(v), String.num(v, 0)))
		"sub_government", "subgosstroy":
			var nm: String = CD.IDEOLOGY.get(int(v), "")
			return nm if nm != "" else "%s（未知编号）" % String.num(v, 0)
		"puppet_of":
			if int(v) < 0:
				return "独立"
			var on := country_name_by_legacy(int(v))
			return on if on != "" else "原版序号%s" % String.num(v, 0)
	if k in BOOL_FIELDS:
		return "是" if int(v) != 0 else "否"
	return String.num(v, 0)


## ── 懒加载 ────────────────────────────────────────────────────────────────
static func _ensure_geo() -> void:
	if _countries.is_empty():
		_countries = _load_json(MAP_COUNTRIES)
	if _regions.is_empty():
		_regions = _load_json(MAP_REGIONS)


static func _ensure_identity() -> void:
	if _identity.is_empty():
		var raw := _load_json(COUNTRY_IDENTITY)
		for k in raw:
			_identity[int(k)] = int(raw[k])


static func _ensure_wars() -> void:
	if not _wars.is_empty():
		return
	var da := DirAccess.open(WAR_DIR)
	if da == null:
		return
	da.list_dir_begin()
	var f := da.get_next()
	while f != "":
		if f.ends_with(".tres"):
			var def = load(WAR_DIR + f)
			if def != null and "name_zh" in def:
				_wars[int(def.id)] = def.name_zh
		f = da.get_next()


static func _load_json(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("EventGraphLexicon: 打不开 %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	return parsed if parsed is Dictionary else {}
