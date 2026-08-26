class_name PolityProfile
extends RefCounted

## 体制档案（P4 数据层）。键 = GameConstants.PartySystem。
## 五维：领袖称谓 / 职位名变体 / 灰显职位（机构虚化）/ 行动规则 / 职位特质乘数。
## 原则：不动 _political_system_recalc 计分因果链，只在消费端查本表。
## 未列出的体制回退一党制档案。

## 行动规则字段：
##   open_kill        明杀是否可用
##   reeducation      再教育是否可用（8/9 体制由 UI 换弹劾文案，语义同"免职退库"）
##   investigate_cost 隔离审查特工费用乘数（基准 20）
##   surveil_cost     监视特工费用乘数（基准 30）

const PROFILES := {
	GameConstants.PartySystem.ONE_PARTY_DICTATORSHIP: {
		"leader_title": "党主席",
		"post_names": {},
		"grey_posts": [],
		"actions": {"open_kill": true, "reeducation": true, "investigate_cost": 1.0, "surveil_cost": 1.0},
		"trait_mult": {},
	},
	GameConstants.PartySystem.NEW_DEMOCRACY: {
		"leader_title": "国家主席",
		"post_names": {},
		"grey_posts": [],
		"actions": {"open_kill": true, "reeducation": true, "investigate_cost": 1.0, "surveil_cost": 1.0},
		"trait_mult": {18: 1.5},  # 统战部效果 ×1.5（民主党派主场）
	},
	GameConstants.PartySystem.PEOPLE_DEMOCRACY: {
		"leader_title": "国家主席",
		"post_names": {16: "书记处组织书记", 17: "新闻署长"},
		"grey_posts": [],
		"actions": {"open_kill": false, "reeducation": true, "investigate_cost": 2.0, "surveil_cost": 1.0},
		"trait_mult": {},
	},
	GameConstants.PartySystem.CONSOCIATIONALISM: {
		"leader_title": "总统",
		"post_names": {1: "武装部队总司令", 16: "内务部长", 17: "新闻署长", 19: "情报总监"},
		"grey_posts": [16, 17, 18, 19, 28],  # 党务机构虚化（灰显+效果归零）
		"actions": {"open_kill": false, "reeducation": true, "investigate_cost": 3.0, "surveil_cost": 1.5},
		"trait_mult": {},
	},
}

const DEFAULT_ID := GameConstants.PartySystem.ONE_PARTY_DICTATORSHIP


static func current(w: WorldState) -> Dictionary:
	if w == null:
		return PROFILES[DEFAULT_ID]
	return PROFILES.get(w.party_system, PROFILES[DEFAULT_ID])


static func leader_title(w: WorldState) -> String:
	return current(w).get("leader_title", "党主席")


## 职位显示名（体制变体优先，回退目录名）
static func post_display_name(w: WorldState, id: int) -> String:
	var override: String = current(w).get("post_names", {}).get(id, "")
	return override if override != "" else PositionCatalog.name(id)


## 机构虚化判定（灰显 + 效果归零）
static func is_post_greyed(w: WorldState, id: int) -> bool:
	return id in current(w).get("grey_posts", [])


## 行动许可（明杀等）
static func action_allowed(w: WorldState, action_id: String) -> bool:
	var rules: Dictionary = current(w).get("actions", {})
	match action_id:
		"open_kill":
			return bool(rules.get("open_kill", true))
		"reeducate":
			return bool(rules.get("reeducation", true))
	return true


## 行动特工费用乘数
static func action_cost_multiplier(w: WorldState, action_id: String) -> float:
	var rules: Dictionary = current(w).get("actions", {})
	match action_id:
		"investigate":
			return float(rules.get("investigate_cost", 1.0))
		"surveil":
			return float(rules.get("surveil_cost", 1.0))
	return 1.0


## 职位特质乘数（效果域统一出口处查表；键=职位 id）
static func post_trait_multiplier(w: WorldState, post_id: int) -> float:
	return float(current(w).get("trait_mult", {}).get(post_id, 1.0))
