# ============================================================================
# DecisionAtoms — 决议条件/效果原子库（第一批：version=1 决议所需）
# ============================================================================
# 对齐原版：
#   - KGEvent/QueryDecisions`1 where T.cs（6002 行，条件/效果 lambda 链）
#   - GameState.cs 相关字段（data 数值表 / empires / modifies / politics）
#   - GlobalScript.CreateDecisions()（Assets/Scripts/GlobalScript.cs:20-34）
#
# 命名约定：原版 PascalCase 方法 → GDScript snake_case；每个函数注释给出
# 原版文件与表达式，便于逐字核对。yes 参数的布尔翻转语义照抄原版。
#
# 本批覆盖 version=1 决议（下标 0-14）的 85 个原子；version=2/3 的
# 原子在后续批次尾追加（不得改动已有签名）。
# ============================================================================
class_name DecisionAtoms
extends RefCounted

const W = preload("res://数据脚本/world_state.gd")


# ── 内部访问器 ──

static func _ws() -> WorldState:
	return GameManager.world


static func _d() -> Array[int]:
	var ws := _ws()
	return ws.数值表 if ws != null else []


static func _country(legacy_index: int) -> CountryData:
	var ws := _ws()
	return ws.get_country_by_legacy_index(legacy_index) if ws != null else null


static func _empire(i: int) -> EmpireData:
	var ws := _ws()
	if ws == null or i < 0 or i >= ws.empires.size():
		return null
	return ws.empires[i]


static func _mod(i: int) -> ModifierSlot:
	var ws := _ws()
	if ws == null or i < 0 or i >= ws.modifiers.size():
		return null
	return ws.modifiers[i]


static func _mod_active(i: int) -> bool:
	var m := _mod(i)
	return m != null and m.is_active


## 原版 event_done[n] / resultOfEvents[n] 的 Godot 映射：
## completed_event_ids 以 event_id 字符串为键，需按 source_event_number 反查。
## 懒缓存一次（决议执行频次低，可接受）。
static var _legacy_event_cache: Dictionary = {}
static var _legacy_event_cache_built: bool = false


static func _build_event_cache() -> void:
	_legacy_event_cache.clear()
	_legacy_event_cache_built = true
	var engine: Node = null
	if GameManager != null:
		engine = GameManager.get_node_or_null("/root/EventEngine")
	if engine == null:
		push_warning("DecisionAtoms: EventEngine 未就绪，event_done 查询降级为 false")
		return
	for ev: EventDef in engine._event_order:
		if ev != null and ev.source_event_number >= 0:
			_legacy_event_cache[int(ev.source_event_number)] = ev.event_id


static func _event_id(legacy_number: int) -> String:
	if not _legacy_event_cache_built:
		_build_event_cache()
	return _legacy_event_cache.get(legacy_number, "")


static func _event_done(legacy_number: int) -> bool:
	var ws := _ws()
	if ws == null:
		return false
	var id := _event_id(legacy_number)
	if id == "":
		return false
	return ws.completed_event_ids.has(id)


static func _event_result(legacy_number: int, option: int) -> bool:
	var ws := _ws()
	if ws == null:
		return false
	var id := _event_id(legacy_number)
	if id == "":
		return false
	return int(ws.completed_event_ids.get(id, -1)) == option


static func _completed(decision_index: int) -> bool:
	var ws := _ws()
	if ws == null or ws.decisions == null or decision_index < 0 or decision_index >= ws.decisions.completed.size():
		return false
	return ws.decisions.completed[decision_index]


static func _set_completed(decision_index: int) -> void:
	var ws := _ws()
	if ws == null or ws.decisions == null:
		return
	while ws.decisions.completed.size() <= decision_index:
		ws.decisions.completed.append(false)
	ws.decisions.completed[decision_index] = true


static func _faction_leading(faction: int) -> bool:
	return GameManager.is_faction_leading(faction)


static func _faction_enabled(faction: int) -> bool:
	var ws := _ws()
	if ws == null or faction < 0 or faction >= ws.factions.size():
		return false
	return ws.factions[faction].is_enabled


# ============================================================================
# 条件原子（QueryDecisions`1 where T.cs 的 CreateCondition lambda 直译）
# ============================================================================

## TheyAreOurs — 原版: (okb && econ) || (isSEV && isOVD && allcountries[1].isOVD)
##                        || (isSEATO && allcountries[1].isSEATO)   （L17-40）
static func they_are_ours(country: int) -> bool:
	var c := _country(country)
	var china := _country(1)
	if c == null or china == null:
		return false
	if c.has_tag("okb") and c.has_tag("econ"):
		return true
	if c.has_tag("sev") and c.has_tag("ovd") and china.has_tag("ovd"):
		return true
	if c.has_tag("seato") and china.has_tag("seato"):
		return true
	return false


## ProChinese — 原版: allcountries[country].proprc  （L57-76）
static func pro_chinese(country: int) -> bool:
	var c := _country(country)
	return c != null and c.has_tag("亲中")


## TibetIsOurs — yes: data[67]<=0；!yes: data[67]>0  （L77-108）
static func tibet_is_ours(yes: bool) -> bool:
	var v: int = _d()[W.I_TIBET_POLICY] if _d().size() > W.I_TIBET_POLICY else 0
	return v <= 0 if yes else v > 0


## UyghurIsOurs — yes: data[66]<=0；!yes: data[66]>0  （L109-140）
static func uyghur_is_ours(yes: bool) -> bool:
	var v: int = _d()[W.I_XINJIANG_POLICY] if _d().size() > W.I_XINJIANG_POLICY else 0
	return v <= 0 if yes else v > 0


## HasAgents — data[9] >= num  （L141-160）
static func has_agents(num: int) -> bool:
	return _d().size() > W.I_AGENTS and _d()[W.I_AGENTS] >= num


## HasMoney — data[8] + data[36] >= num  （L161-180）
static func has_money(num: int) -> bool:
	var d := _d()
	return d.size() > W.I_BUDGET and d.size() > W.I_RESERVE and d[W.I_BUDGET] + d[W.I_RESERVE] >= num


## HasReserve — data[36] >= num  （L181-200）
static func has_reserve(num: int) -> bool:
	return _d().size() > W.I_RESERVE and _d()[W.I_RESERVE] >= num


## HasArmy — data[22] >= num  （L221-240）
static func has_army(num: int) -> bool:
	return _d().size() > W.I_ARMY and _d()[W.I_ARMY] >= num


## IsUnitarism — yes: data[18]==20；!yes: !=20  （L273-304）
static func is_unitarism(yes: bool) -> bool:
	var v: int = _d()[W.I_TERRITORY] if _d().size() > W.I_TERRITORY else 0
	return v == 20 if yes else v != 20


## IsLiberal — yes: IsFactionLeadeng(4) || (data[52]>=36 && data[54]>=40)
##           !yes: 取反                                          （L305-336）
static func is_liberal(yes: bool) -> bool:
	var d := _d()
	var v := _faction_leading(4) or (d.size() > W.I_ECON_DISPLAY and d.size() > W.I_POLITICAL_DISPLAY
		and d[W.I_ECON_DISPLAY] >= 36 and d[W.I_POLITICAL_DISPLAY] >= 40)
	return v if yes else not v


## IsAutoritharian — yes: IsFactionLeadeng(0)||IsFactionLeadeng(3)||(data[15]>=8 && data[54]<=38)
##                  !yes: 取反                                    （L337-368）
static func is_autoritharian(yes: bool) -> bool:
	var d := _d()
	var v := _faction_leading(0) or _faction_leading(3) or (d.size() > W.I_PARTY_SYSTEM and d.size() > W.I_POLITICAL_DISPLAY
		and d[W.I_PARTY_SYSTEM] >= 8 and d[W.I_POLITICAL_DISPLAY] <= 38)
	return v if yes else not v


## IsTraditional — yes: data[50]>=28；!yes: <28  （L369-400）
static func is_traditional(yes: bool) -> bool:
	var v: int = _d()[W.I_RELIGION] if _d().size() > W.I_RELIGION else 0
	return v >= 28 if yes else v < 28


## IsRadicalTradition — yes: data[50]<=24；!yes: >24  （L401-432）
static func is_radical_tradition(yes: bool) -> bool:
	var v: int = _d()[W.I_RELIGION] if _d().size() > W.I_RELIGION else 0
	return v <= 24 if yes else v > 24


## IsPartyEnabled — yes: is_party_enabled[num]；!yes: 取反  （L433-465）
## Godot: FactionData.is_enabled（改版字段，对应原版 is_party_enabled）
static func is_party_enabled(yes: bool, num: int) -> bool:
	var v := _faction_enabled(num)
	return v if yes else not v


## HasOnePartyMechanic — yes: data[15]<=7；!yes: >7  （L466-497）
static func has_one_party_mechanic(yes: bool) -> bool:
	var v: int = _d()[W.I_PARTY_SYSTEM] if _d().size() > W.I_PARTY_SYSTEM else 0
	return v <= 7 if yes else v > 7


## IsNewDemocracy — yes: data[15]==7；!yes: !=7  （L498-529）
static func is_new_democracy(yes: bool) -> bool:
	var v: int = _d()[W.I_PARTY_SYSTEM] if _d().size() > W.I_PARTY_SYSTEM else 0
	return v == 7 if yes else v != 7


## IsConsociationalDemocracy — yes: data[15]==9  （L530-561）
static func is_consociational_democracy(yes: bool) -> bool:
	var v: int = _d()[W.I_PARTY_SYSTEM] if _d().size() > W.I_PARTY_SYSTEM else 0
	return v == 9 if yes else v != 9


## IsMajorInElection — yes: party_number[1]>1500（Godot factions[1].support）  （L562-593）
static func is_major_in_election(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.factions.size() > 1 and ws.factions[1].support > 1500
	return v if yes else not v


## AllLeadersAreDead — 四人帮(0,0)(3,3)(4,4)(5,5) trait0==0 + (2,2)/(13,13) 均不存在  （L594-629）
static func all_leaders_are_dead() -> bool:
	var ws := _ws()
	if ws == null:
		return false
	for p: PoliticianData in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == 0 and ((p.name_first == 0 and p.name_last == 0)
				or (p.name_first == 3 and p.name_last == 3)
				or (p.name_first == 4 and p.name_last == 4)
				or (p.name_first == 5 and p.name_last == 5)):
			return false
		if (p.name_first == 2 and p.name_last == 2) or (p.name_first == 13 and p.name_last == 13):
			return false
	return true


## 原版 FindPerson(name1, name2, t0, t3, t1, t2)：
## Godot 字段顺序 = (name_first, name_last, trait_personality,
##                     trait_background[t3], trait_alignment[t1], trait_special[t2])
static func _find_person(name1: int, name2: int, t0: int, t3: int, t1: int, t2: int) -> int:
	var ws := _ws()
	if ws == null:
		return -1
	for i in ws.politicians.size():
		var p: PoliticianData = ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2 \
				and p.trait_personality == t0 and p.trait_background == t3 \
				and p.trait_alignment == t1 and p.trait_special == t2:
			return i
	return -1


## IsPoliticianAlive — FindPerson(...) >= 0  （L630-650）
static func is_politician_alive(name1: int, name2: int, t0: int, t3: int, t1: int, t2: int) -> bool:
	return _find_person(name1, name2, t0, t3, t1, t2) >= 0


## HasAutonomyForMacao — yes: data[65]==1  （L651-682）
static func has_autonomy_for_macao(yes: bool) -> bool:
	var v: int = _d()[W.I_HK_MACAU_STATUS] if _d().size() > W.I_HK_MACAU_STATUS else 0
	return v == 1 if yes else v != 1


## HasAnnexedMacao — yes: data[65]==2  （L683-714）
static func has_annexed_macao(yes: bool) -> bool:
	var v: int = _d()[W.I_HK_MACAU_STATUS] if _d().size() > W.I_HK_MACAU_STATUS else 0
	return v == 2 if yes else v != 2


## IsTaiwanAttacked — yes: allcountries[38].dev != 0  （L715-746）
static func is_taiwan_attacked(yes: bool) -> bool:
	var tw := _country(38)
	var v := tw != null and tw.development != 0
	return v if yes else not v


## IsTaiwanReturn — 原文（L747-778）：yes 分支为
## event_done[461] || (38.proprc && data[6]<700 && data[16]>=13 && !1.isSEV && !modifies[17].active)
##   || event_done[462] || event_done[457] || (data[64]==2 && 1.SubGosstroy==19)
static func is_taiwan_return(yes: bool) -> bool:
	var d := _d()
	var tw := _country(38)
	var china := _country(1)
	var inner := _event_done(461) \
		or (tw != null and tw.has_tag("亲中") and d.size() > W.I_DIPLO and d[W.I_DIPLO] < 700
			and d.size() > W.I_ECON_SYSTEM and d[W.I_ECON_SYSTEM] >= 13
			and not (china != null and china.has_tag("sev")) and not _mod_active(17)) \
		or _event_done(462) or _event_done(457) \
		or (d.size() > W.I_TAIWAN_STATUS and d[W.I_TAIWAN_STATUS] == 2
			and china != null and china.sub_government == 19)
	return inner if yes else not inner


## IsInTheOVD — yes: country.isOVD  （L779-811）
static func is_in_the_ovd(yes: bool, country: int) -> bool:
	var c := _country(country)
	var v := c != null and c.has_tag("ovd")
	return v if yes else not v


## IsInTheSEV — yes: country.isSEV  （L812-844）
static func is_in_the_sev(yes: bool, country: int) -> bool:
	var c := _country(country)
	var v := c != null and c.has_tag("sev")
	return v if yes else not v


## IsInTheWP — 原版同 isOVD（L877-908）
static func is_in_the_wp(yes: bool, country: int) -> bool:
	return is_in_the_ovd(yes, country)


## IsInTheSEATO — yes: country.isSEATO  （L909-940）
static func is_in_the_seato(yes: bool, country: int) -> bool:
	var c := _country(country)
	var v := c != null and c.has_tag("seato")
	return v if yes else not v


## IsInTheSENTO — yes: country.isSENTO  （L941-972）
static func is_in_the_sento(yes: bool, country: int) -> bool:
	var c := _country(country)
	var v := c != null and c.has_tag("sento")
	return v if yes else not v


## HasCulturalRevolution — yes: modifies[3].active  （L973-1004）
static func has_cultural_revolution(yes: bool) -> bool:
	var v := _mod_active(3)
	return v if yes else not v


## HasOil — yes: modifies[51].active  （L1005-1036）
static func has_oil(yes: bool) -> bool:
	var v := _mod_active(51)
	return v if yes else not v


## HasMaoismus — yes: modifies[6].active  （L1037-1068）
static func has_maoismus(yes: bool) -> bool:
	var v := _mod_active(6)
	return v if yes else not v


## HasEasternRome — yes: modifies[27].active  （L1069-1100）
static func has_eastern_rome(yes: bool) -> bool:
	var v := _mod_active(27)
	return v if yes else not v


## HasFourthInternational — yes: modifies[49].active  （L1101-1132）
static func has_fourth_international(yes: bool) -> bool:
	var v := _mod_active(49)
	return v if yes else not v


## HasNongU — yes: modifies[40].active  （L1133-1164）
static func has_nong_u(yes: bool) -> bool:
	var v := _mod_active(40)
	return v if yes else not v


## HasMoneyLevel — yes: modifies[65].active  （L1165-1196）
static func has_money_level(yes: bool) -> bool:
	var v := _mod_active(65)
	return v if yes else not v


## IsPartySupportLessThan — yes: data[1]<num；!yes: data[1]>num  （L1197-1229）
static func is_party_support_less_than(yes: bool, num: int) -> bool:
	var v: int = _d()[W.I_PARTY_SUPPORT] if _d().size() > W.I_PARTY_SUPPORT else 0
	return v < num if yes else v > num


## IsDipRepLessThan — yes: data[6]<num；!yes: >num  （L1362-1394）
static func is_dip_rep_less_than(yes: bool, num: int) -> bool:
	var v: int = _d()[W.I_DIPLO] if _d().size() > W.I_DIPLO else 0
	return v < num if yes else v > num


## IsUnityLessThan — yes: data[57]<num；!yes: >=num  （L1395-1427）
static func is_unity_less_than(yes: bool, num: int) -> bool:
	var v: int = _d()[W.I_MANPOWER] if _d().size() > W.I_MANPOWER else 0
	return v < num if yes else v >= num


## IsAmericanInfluenceLessThan — yes: empires[0].power<num；!yes: >num  （L1428-1460）
static func is_american_influence_less_than(yes: bool, num: int) -> bool:
	var e := _empire(0)
	var v := e.power if e != null else 0
	return v < num if yes else v > num


## IsSovietInfluenceLessThan — yes: empires[1].power<num  （L1461-1493）
static func is_soviet_influence_less_than(yes: bool, num: int) -> bool:
	var e := _empire(1)
	var v := e.power if e != null else 0
	return v < num if yes else v > num


## IsChineseInfluenceLessThan — yes: influencePRC<num  （L1494-1526）
static func is_chinese_influence_less_than(yes: bool, num: int) -> bool:
	var ws := _ws()
	var v := ws.influence_prc if ws != null else 0
	return v < num if yes else v > num


## IsChiSovInfluenceLessThan — yes: influencePRC + (china.isOVD ? empires[1].power : 0) < num  （L1527-1559）
static func is_chi_sov_influence_less_than(yes: bool, num: int) -> bool:
	var ws := _ws()
	var china := _country(1)
	var e := _empire(1)
	var base := ws.influence_prc if ws != null else 0
	var v := base + ((e.power if e != null else 0) if (china != null and china.has_tag("ovd")) else 0)
	return v < num if yes else v > num


## HasAgressiveMilitaryDoctrine — yes: data[51]<=31；!yes: >31  （L1560-1591）
static func has_agressive_military_doctrine(yes: bool) -> bool:
	var v: int = _d()[W.I_MIL_DOCTRINE] if _d().size() > W.I_MIL_DOCTRINE else 0
	return v <= 31 if yes else v > 31


## HasMercenary — yes: data[51]==33  （L1592-1623）
static func has_mercenary(yes: bool) -> bool:
	var v: int = _d()[W.I_MIL_DOCTRINE] if _d().size() > W.I_MIL_DOCTRINE else 0
	return v == 33 if yes else v != 33


## HasLeftRadicalLeader — yes: leader.traits[0]==0  （L1645-1676）
static func has_left_radical_leader(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.leader != null and ws.leader.trait_personality == 0
	return v if yes else not v


## HasCommunistLeader — yes: traits[0]∈{0,1,20}  （L1755-1786）
static func has_communist_leader(yes: bool) -> bool:
	var ws := _ws()
	var t := ws.leader.trait_personality if (ws != null and ws.leader != null) else -1
	var v := t == 0 or t == 1 or t == 20
	return v if yes else not v


## HasSovietFriendship — yes: relres  （L1787-1818）
## Godot: ws.get_flag("relres")（game_manager.gd:2912 同源）
static func has_soviet_friendship(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.get_flag("relres")
	return v if yes else not v


## IsSocialism — 原版 GameState.IsSocialism(yes, num)  （L1819-1850）
static func is_socialism(yes: bool, num: int) -> bool:
	var ws := _ws()
	if ws == null:
		return false
	var v := ws.is_socialism(_country(num), yes)
	return v


## HasSovietCooperation — yes: (relres && country7.Torg && country1.Gosstroy!=3) || country7.SubGosstroy==21  （L1851-1882）
static func has_soviet_cooperation(yes: bool) -> bool:
	var ws := _ws()
	var ussr := _country(7)
	var china := _country(1)
	var v := ((ws != null and ws.get_flag("relres") and ussr != null and ussr.has_tag("对华贸易")
			and china != null and china.government != 3)
		or (ussr != null and ussr.sub_government == 21))
	return v if yes else not v


## HasSovietInNATO — yes: country7.isNATO  （L1883-1914）
static func has_soviet_in_nato(yes: bool) -> bool:
	var ussr := _country(7)
	var v := ussr != null and ussr.has_tag("nato")
	return v if yes else not v


## HasTradeWithUSA — yes: country51.Torg  （L1915-1946）
static func has_trade_with_usa(yes: bool) -> bool:
	var c := _country(51)
	var v := c != null and c.has_tag("对华贸易")
	return v if yes else not v


## HasEuropeansPuppets — country2.proprc && country5.proprc && !country4.prosov  （L1947-1960）
static func has_europeans_puppets() -> bool:
	var c2 := _country(2)
	var c4 := _country(4)
	var c5 := _country(5)
	return c2 != null and c2.has_tag("亲中") and c5 != null and c5.has_tag("亲中") \
		and (c4 == null or not c4.has_tag("亲苏"))


## HasGorbachev — empires[1].now_leader == 6  （L1961-1974）
static func has_gorbachev() -> bool:
	var e := _empire(1)
	return e != null and e.current_leader == 6


## IsYearLess — yes: data[21]<num；!yes: >num  （L1975-2007）
static func is_year_less(yes: bool, num: int) -> bool:
	var v: int = _d()[W.I_YEAR] if _d().size() > W.I_YEAR else 0
	return v < num if yes else v > num


## HasChosenInTheEvent — resultOfEvents[eventNum] == answerNum  （L2106-2139）
static func has_chosen_in_the_event(event_num: int, answer_num: int) -> bool:
	return _event_result(event_num, answer_num)


## HasModerateFaction — yes: IsFactionLeadeng(2)  （L2140-2171）
static func has_moderate_faction(yes: bool) -> bool:
	var v := _faction_leading(2)
	return v if yes else not v


## HasRealModerateLeader — yes: traits[0]∈{1,20}  （L2172-2203）
static func has_real_moderate_leader(yes: bool) -> bool:
	var ws := _ws()
	var t := ws.leader.trait_personality if (ws != null and ws.leader != null) else -1
	var v := t == 1 or t == 20
	return v if yes else not v


## HasModerateLeader — yes: traits[0]∈{1,2,20}  （L2204-2235）
static func has_moderate_leader(yes: bool) -> bool:
	var ws := _ws()
	var t := ws.leader.trait_personality if (ws != null and ws.leader != null) else -1
	var v := t == 1 or t == 2 or t == 20
	return v if yes else not v


## IsLeftRadBanned — !is_party_enabled[0]  （L2236-2249）
static func is_left_rad_banned() -> bool:
	return not _faction_enabled(0)


## IsFactionBanned — !is_party_enabled[num]  （L2250-2269）
static func is_faction_banned(num: int) -> bool:
	return not _faction_enabled(num)


## HasCapitalistEconomy — yes: data[16]>13；!yes: <=13  （L2270-2301）
static func has_capitalist_economy(yes: bool) -> bool:
	var v: int = _d()[W.I_ECON_SYSTEM] if _d().size() > W.I_ECON_SYSTEM else 0
	return v > 13 if yes else v <= 13


## HasPlannedEconomy — yes: data[16]<=11；!yes: >11  （L2302-2333）
static func has_planned_economy(yes: bool) -> bool:
	var v: int = _d()[W.I_ECON_SYSTEM] if _d().size() > W.I_ECON_SYSTEM else 0
	return v <= 11 if yes else v > 11


## HasOligarchyPowerLess — yes: data[108]<num；!yes: >num  （L2334-2366）
static func has_oligarchy_power_less(yes: bool, num: int) -> bool:
	var v: int = _d()[W.I_OLIGARCH] if _d().size() > W.I_OLIGARCH else 0
	return v < num if yes else v > num


## IsMaoDemaoised — yes: !modifies[6].active && data[90]==2  （L2367-2398）
static func is_mao_demaoised(yes: bool) -> bool:
	var v := (not _mod_active(6)) and _d().size() > W.I_MAO_HISTORY_LINE and _d()[W.I_MAO_HISTORY_LINE] == 2
	return v if yes else not v


## IsDeadJanataInIndia — yes: data[91]==1 && resultOfEvents[72]==0  （L2399-2430）
static func is_dead_janata_in_india(yes: bool) -> bool:
	var v := _d().size() > W.I_INDIA_ELECTION and _d()[W.I_INDIA_ELECTION] == 1 and _event_result(72, 0)
	return v if yes else not v


## HasNaxalitsPowerLess — yes: data[32]<num；!yes: >num  （L2431-2463）
static func has_naxalits_power_less(yes: bool, num: int) -> bool:
	var v: int = _d()[W.I_NAXALITE_POWER] if _d().size() > W.I_NAXALITE_POWER else 0
	return v < num if yes else v > num


## LeftInMajor — yes: data[56]<=2；!yes: >2  （L2494-2524）
static func left_in_major(yes: bool) -> bool:
	var v: int = _d()[W.I_POLITICAL_LINE] if _d().size() > W.I_POLITICAL_LINE else 0
	return v <= 2 if yes else v > 2


## IsSectorsWell — yes: data[12]>800 && data[13]>800 && data[68]>800  （L2525-2554）
static func is_sectors_well(yes: bool) -> bool:
	var d := _d()
	var v := d.size() > W.I_INDUSTRY and d.size() > W.I_AGRICULTURE and d.size() > W.I_SERVICES \
		and d[W.I_INDUSTRY] > 800 and d[W.I_AGRICULTURE] > 800 and d[W.I_SERVICES] > 800
	return v if yes else not v


## HasArrestGOF — yes: 四人帮(0,0)(3,3)(4,4)(5,5)均无 且 领袖不是(3,3)  （L2834-2864）
static func has_arrest_gof(yes: bool) -> bool:
	var ws := _ws()
	if ws == null:
		return false
	for p: PoliticianData in ws.politicians:
		if p != null and (p.name_first == 0 and p.name_last == 0
				or p.name_first == 3 and p.name_last == 3
				or p.name_first == 4 and p.name_last == 4
				or p.name_first == 5 and p.name_last == 5):
			return not yes
	var leader_bad := ws.leader != null and ws.leader.name_first == 3 and ws.leader.name_last == 3
	var v := not leader_bad
	return v if yes else not v


## HasConservativeModerateLeading — yes: traits[0]∈{20,1}  （L2865-2895）
static func has_conservative_moderate_leading(yes: bool) -> bool:
	var ws := _ws()
	var t := ws.leader.trait_personality if (ws != null and ws.leader != null) else -1
	var v := t == 20 or t == 1
	return v if yes else not v


## HasLinBiao — yes: (event_done[74] && data[90]==0 && modifies[6].active)
##                   || country1.isOVD || event_done[124]                  （L2896-2926）
static func has_lin_biao(yes: bool) -> bool:
	var china := _country(1)
	var v := (_event_done(74) and _d().size() > W.I_MAO_HISTORY_LINE and _d()[W.I_MAO_HISTORY_LINE] == 0
			and _mod_active(6)) \
		or (china != null and china.has_tag("ovd")) or _event_done(124)
	return v if yes else not v


## IsNotRevisionist — yes 分支：!event_done[713] && IsSocialism(true,1) && modifies[6].active
##   && !country51.Torg && country51.dev!=1 && !country1.isSEATO
##   && ((!country1.isSEV && !country1.isOVD) || event_done[380])           （L2927-2957）
static func is_not_revisionist(yes: bool) -> bool:
	var ws := _ws()
	var china := _country(1)
	var usa := _country(51)
	var v := (not _event_done(713)) and (ws != null and ws.is_socialism(china, true)) \
		and _mod_active(6) \
		and (usa == null or not usa.has_tag("对华贸易")) \
		and (usa == null or usa.development != 1) \
		and (china == null or not china.has_tag("seato")) \
		and ((china == null or (not china.has_tag("sev") and not china.has_tag("ovd"))) or _event_done(380))
	return v if yes else not v


## QuelleGosstroy — 原版按 country 分 6 个特殊分支（L4585-4710 提取）。
## v1 决议只用 country ∈ {10, 30, 33, 58, 80, 84}，yes/no 两向均照抄。
static func quelle_gosstroy(country: int, gos: int, yes: bool) -> bool:
	var c := _country(country)
	if c == null:
		return false
	if country == 84:
		var v := c.government == gos or c.government == 1
		return v if yes else not v
	if country == 10:
		var korea := _country(46)
		var v := (c.puppet_of != 1 and c.parts.size() > 0 and c.parts[0] and c.development == 1) \
			or (c.puppet_of != 1 and korea != null and korea.government == 1)
		return v if yes else not v
	if country == 30:
		var v := c.government == 2
		return v if yes else not v
	if country == 33:
		var c19 := _country(19)
		var c34 := _country(34)
		var v := c34 != null and c34.sub_government == 17 and c.sub_government == 17 \
			and c19 != null and c19.sub_government == 17
		return v if yes else not v
	if country == 80:
		var v := c.sub_government == 17
		return v if yes else not v
	if country == 58:
		var found := false
		var ws := _ws()
		for cc: CountryData in ws.countries:
			var i := cc.原版序号
			if ((i >= 52 and i <= 68) or (i >= 106 and i <= 108) or (i >= 112 and i <= 133)
					or i == 13 or i == 18 or i == 40 or i == 41 or i == 42 or i == 99 or i == 100) \
					and i != 128 and cc.sub_government == 17:
				found = true
				break
		return found if yes else not found
	return false


# ============================================================================
# 效果原子（CreateActive delegate 直译）
# ============================================================================

## AddAgents — data[9] += num
static func add_agents(num: int) -> void:
	var d := _d()
	if d.size() > W.I_AGENTS:
		d[W.I_AGENTS] += num


## AddAmericanInfluence — empires[0].power += num
static func add_american_influence(num: int) -> void:
	var e := _empire(0)
	if e != null:
		e.power += num


## AddSovietInfluence — empires[1].power += num
static func add_soviet_influence(num: int) -> void:
	var e := _empire(1)
	if e != null:
		e.power += num


## AddChineseInfluence — influencePRC += num
static func add_chinese_influence(num: int) -> void:
	var ws := _ws()
	if ws != null:
		ws.influence_prc += num


## AddRelations — empires[power].relations += num（原版无钳制，照抄）
static func add_relations(empire_index: int, num: int) -> void:
	var e := _empire(empire_index)
	if e != null:
		e.relations += num


## AddMoney — data[8] += num
static func add_money(num: int) -> void:
	var d := _d()
	if d.size() > W.I_BUDGET:
		d[W.I_BUDGET] += num


## AddArmy — data[22] += num
static func add_army(num: int) -> void:
	var d := _d()
	if d.size() > W.I_ARMY:
		d[W.I_ARMY] += num


## AddDiplo — data[6] += num
static func add_diplo(num: int) -> void:
	var d := _d()
	if d.size() > W.I_DIPLO:
		d[W.I_DIPLO] += num


## AddLiberalization — data[4] += num
static func add_liberalization(num: int) -> void:
	var d := _d()
	if d.size() > W.I_THOUGHT_FREEDOM:
		d[W.I_THOUGHT_FREEDOM] += num


## AddPopulation — data[34] += num
static func add_population(num: int) -> void:
	var d := _d()
	if d.size() > W.I_POPULATION:
		d[W.I_POPULATION] += num


## AddSupport — data[3] += num
static func add_support(num: int) -> void:
	var d := _d()
	if d.size() > W.I_PEOPLE_SUPPORT:
		d[W.I_PEOPLE_SUPPORT] += num


## AddPartySupport — data[1] += num
static func add_party_support(num: int) -> void:
	var d := _d()
	if d.size() > W.I_PARTY_SUPPORT:
		d[W.I_PARTY_SUPPORT] += num


## AddStandardOfLiving — data[5] += num
static func add_standard_of_living(num: int) -> void:
	var d := _d()
	if d.size() > W.I_LIVING:
		d[W.I_LIVING] += num


## AddNationalism — data[31] += num
static func add_nationalism(num: int) -> void:
	var d := _d()
	if d.size() > W.I_WAR_SUPPORT:
		d[W.I_WAR_SUPPORT] += num


## AddLoyalityToAllPoliticiansInTheFaction — 原版按 traits[0]==faction；
## 本移植按改版 faction 显式字段（faction_data.gd 注释：faction 是改版口径）。
static func add_loyality_to_all_politicians_in_the_faction(faction: int, num: int) -> void:
	var ws := _ws()
	if ws == null:
		return
	for p: PoliticianData in ws.politicians:
		if p != null and p.faction == faction:
			p.loyalty += num


## AddPowerToLeaderFaction — 原版按 traits[0]==leader.traits[0]；
## Godot 用 trait_personality 对照（原版语义），不动改版 faction 字段。
static func add_power_to_leader_faction(num: int) -> void:
	var ws := _ws()
	if ws == null or ws.leader == null:
		return
	var t := ws.leader.trait_personality
	for p: PoliticianData in ws.politicians:
		if p != null and p.trait_personality == t:
			p.power += num


## AgreeToOligarchy — completedDecisions[num] = true（原版 QueryDecisions 效果区）
static func agree_to_oligarchy(num: int) -> void:
	_set_completed(num)


## AnnexationInfo — completedDecisions[num]=true；
## !modifies[6].active → event_done[457]=true
static func annexation_info(num: int, _annexed: int, _country_by: int) -> void:
	_set_completed(num)
	if not _mod_active(6):
		var ws := _ws()
		if ws != null:
			var id := _event_id(457)
			if id != "":
				ws.completed_event_ids[id] = 0


## BlockMarket — completedDecisions[num]=true
static func block_market(num: int) -> void:
	_set_completed(num)


## TibetMustStay — completedDecisions[num]=true（L3208-3226 提取：仅完成标记）
static func tibet_must_stay(num: int) -> void:
	_set_completed(num)


## UyghurMustStay — completedDecisions[num]=true（L3528-3546 同款）
static func uyghur_must_stay(num: int) -> void:
	_set_completed(num)


## ChangeBotSystem — allcountries[country].Gosstroy = num
static func change_bot_system(num: int, country: int) -> void:
	var c := _country(country)
	if c != null:
		c.government = num


## ChangeSpecialEndingForTheCountry — numberOfSpecialEnding = num
static func change_special_ending_for_the_country(country: int, num: int) -> void:
	var c := _country(country)
	if c != null:
		c.special_ending = num


## EastEuropeAbandonSOV — countries 2/4/5 退出 OVD + SEV
static func east_europe_abandon_sov(_yes: bool = true) -> void:
	for i in [2, 4, 5]:
		var c := _country(i)
		if c != null:
			c.set_tag("ovd", false)
			c.set_tag("sev", false)


## MakeEastEuropaProChina — countries 2/4/5 加入 okb + econ
static func make_east_europa_pro_china(_yes: bool = true) -> void:
	for i in [2, 4, 5]:
		var c := _country(i)
		if c != null:
			c.set_tag("okb", true)
			c.set_tag("econ", true)


## MakeProChinese — allcountries[country].proprc = yes
static func make_pro_chinese(yes: bool, country: int) -> void:
	var c := _country(country)
	if c != null:
		c.set_tag("亲中", yes)


## MakeProUSA — allcountries[country].Vyshi = yes
static func make_pro_usa(yes: bool, country: int) -> void:
	var c := _country(country)
	if c != null:
		c.set_tag("亲美", yes)


## MaoismIsBetter / MaoismSOVIsBetter — completedDecisions[num]=true
static func maoism_is_better(num: int) -> void:
	_set_completed(num)


static func maoism_sov_is_better(num: int) -> void:
	_set_completed(num)


## MakeHimLeader — 原版 GameState.MakeNewLeader(FindPerson(...))
static func make_him_leader(name1: int, name2: int, t0: int, t3: int, t1: int, t2: int) -> void:
	var idx := _find_person(name1, name2, t0, t3, t1, t2)
	var ws := _ws()
	if idx < 0 or ws == null or idx >= ws.politicians.size():
		return
	ws.leader = ws.politicians[idx]
	ws.leader_politician_index = idx


## KillTheLeaderOfTheFaction — faction_leader[num]<100 → KillPerson(...)
## Godot: FactionData.leader_index（-1=空缺）→ GameManager.kill_politician
static func kill_the_leader_of_the_faction(num: int) -> void:
	var ws := _ws()
	if ws == null or num < 0 or num >= ws.factions.size():
		return
	var idx := ws.factions[num].leader_index
	if idx >= 0 and idx < ws.politicians.size():
		GameManager.kill_politician(idx)


## GetLinBiao — 逐字对齐 QueryDecisions GetLinBiao（L2994 之后效果区）。
## 差异声明：NewPolitician[5..7] 开关 Godot 政治家池无对应（项目未建模），
## 按项目先例（原版字段未建模 → 跳过并注明）省略该标记，其余照抄。
static func get_lin_biao(_yes: bool = true) -> void:
	var ws := _ws()
	if ws == null:
		return
	var d := ws.数值表
	var year := d[W.I_YEAR] if d.size() > W.I_YEAR else 1976
	var month := d[W.I_MONTH] if d.size() > W.I_MONTH else 1
	var day := d[W.I_DAY] if d.size() > W.I_DAY else 1
	# 第一位：林彪（10,69），出身 1904，traits(20,26,7,31)
	_replace_lowest_politician(10, 69, year - 1904, 20, 26, 7, 31)
	# 日期早于 1983-4-26 时再造第二位（12,70），出身 1910，traits(20,25,4,36)
	if (year < 1983 or (year == 1983 and (month < 4 or (month == 4 and day < 26)))) \
			and (year < 1983 or month < 5) and year < 1984:
		_replace_lowest_politician(12, 70, year - 1910, 20, 25, 4, 36)


static func _replace_lowest_politician(n1: int, n2: int, age: int, t0: int, t3: int, t1: int, t2: int) -> void:
	var ws := _ws()
	if ws == null or ws.politicians.is_empty():
		return
	var num := 0
	for i in ws.politicians.size():
		var p: PoliticianData = ws.politicians[i]
		if p != null and p.power < ws.politicians[num].power and p.trait_personality != 20:
			num = i
	GameManager.kill_politician(num)
	if num < ws.politicians.size() and ws.politicians[num] != null:
		var p2: PoliticianData = ws.politicians[num]
		p2.name_first = n1
		p2.name_last = n2
		p2.age = age
		p2.trait_personality = t0
		p2.trait_background = t3
		p2.trait_alignment = t1
		p2.trait_special = t2
		p2.power = 800
		p2.loyalty = 800


## StartEvent — 原版 number_event=num + LoadScene("Event")
## Godot: 经 EventEngine 按原版编号触发（事件链/界面由引擎接管）
static func start_event(num: int) -> void:
	var id := _event_id(num)
	if id == "":
		push_warning("DecisionAtoms: 原版事件 %d 在 Godot 无对应事件，StartEvent 跳过" % num)
		return
	GameManager.start_event(id)


## IsLeftradicalLead — yes: IsFactionLeadeng(0)（QueryDecisions L5438-5460）
static func is_leftradical_lead(yes: bool) -> bool:
	var v := _faction_leading(0)
	return v if yes else not v


## IsScienceDone — yes: science[cock]（QueryDecisions 条件区；Godot TechState.unlocked）
static func is_science_done(cock: int, yes: bool) -> bool:
	var ws := _ws()
	if ws == null or ws.techs == null:
		return false
	var v := ws.techs.unlocked.size() > cock and ws.techs.unlocked[cock]
	return v if yes else not v
