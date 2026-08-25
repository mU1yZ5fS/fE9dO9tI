class_name EventGraphLexicon
extends RefCounted

# ============================================================================
# 事件拓扑图 —— 具义化词典：把 META 里的裸键翻译成玩家可读名称。
# ============================================================================
# 全部为静态懒加载目录，主菜单（无活动世界）下也可用：
#   资源键   → 中文名（含 ×10 缩放标记，渲染时自动 ÷10）
#   帝国编号 → 美国/苏联
#   国家 gwcode → 资产/地图/map_countries.json 的 name_zh（回退英文名）
#   地块 id  → 资产/地图/map_regions.json 的 name_zh
#   修正索引 → ModifierCatalog.name_zh
#   派系编号 → FactionData.FACTION_NAMES
#   战争 id  → 资产/数据/战争/war_NN.tres 的 name_zh
# ============================================================================

const MAP_COUNTRIES := "res://资产/地图/map_countries.json"
const MAP_REGIONS := "res://资产/地图/map_regions.json"
const WAR_DIR := "res://资产/数据/战争/"

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

static var _countries := {}
static var _regions := {}
static var _wars := {}


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


## ── 懒加载 ────────────────────────────────────────────────────────────────
static func _ensure_geo() -> void:
	if _countries.is_empty():
		_countries = _load_json(MAP_COUNTRIES)
	if _regions.is_empty():
		_regions = _load_json(MAP_REGIONS)


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
