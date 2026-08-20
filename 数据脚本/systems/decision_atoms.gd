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

## 跨系统注入（GameManager 设置）。
static var current_world: WorldState = null
static var event_engine: Node = null
static var _is_faction_leading_cb: Callable = Callable()
static var _kill_politician_cb: Callable = Callable()
static var _start_event_cb: Callable = Callable()


# ── 内部访问器 ──

static func _ws() -> WorldState:
	return current_world


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
	var engine: Node = event_engine
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
	return (_is_faction_leading_cb.is_valid() and _is_faction_leading_cb.call(faction))


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
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT and ((p.name_first == 0 and p.name_last == 0)
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
			and china != null and china.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST)
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
	var v := ws != null and ws.leader != null and ws.leader.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT
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
			and china != null and china.government != GameConstants.Government.LIBERAL)
		or (ussr != null and ussr.sub_government == GameConstants.SubGovernment.RENEWAL_SOCIALIST))
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
		var v := c.government == gos or c.government == GameConstants.Government.SOCIALIST
		return v if yes else not v
	if country == 10:
		var korea := _country(46)
		var v := (c.puppet_of != GameConstants.LegacySlot.CHINA and c.parts.size() > 0 and c.parts[0] and c.development == 1) \
			or (c.puppet_of != GameConstants.LegacySlot.CHINA and korea != null and korea.government == GameConstants.Government.SOCIALIST)
		return v if yes else not v
	if country == 30:
		var v := c.government == GameConstants.Government.REFORMIST
		return v if yes else not v
	if country == 33:
		var c19 := _country(19)
		var c34 := _country(34)
		var v := c34 != null and c34.sub_government == GameConstants.SubGovernment.MAOIST and c.sub_government == GameConstants.SubGovernment.MAOIST \
			and c19 != null and c19.sub_government == GameConstants.SubGovernment.MAOIST
		return v if yes else not v
	if country == 80:
		var v := c.sub_government == GameConstants.SubGovernment.MAOIST
		return v if yes else not v
	if country == 58:
		var found := false
		var ws := _ws()
		for cc: CountryData in ws.countries:
			var i := cc.原版序号
			if ((i >= 52 and i <= 68) or (i >= 106 and i <= 108) or (i >= 112 and i <= 133)
					or i == 13 or i == 18 or i == 40 or i == 41 or i == 42 or i == 99 or i == 100) \
					and i != 128 and cc.sub_government == GameConstants.SubGovernment.MAOIST:
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
		if _kill_politician_cb.is_valid():
			_kill_politician_cb.call(idx)


## GetLinBiao — 逐字对齐 QueryDecisions GetLinBiao（L2994 之后效果区）。
## 差异声明：NewPolitician[5..7] 开关 Godot 政治家池无对应（项目建模说明），
## 按项目先例（原版字段建模说明 → 跳过并注明）省略该标记，其余照抄。
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
		if p != null and p.power < ws.politicians[num].power and p.trait_personality != GameConstants.PoliticianPersonality.CONSERVATIVE:
			num = i
	if _kill_politician_cb.is_valid():
		_kill_politician_cb.call(num)
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
	if _start_event_cb.is_valid():
		_start_event_cb.call(id)


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


## HasLeader — 领袖六属性全等（QueryDecisions L1624-1644）
static func has_leader(name1: int, name2: int, t0: int, t3: int, t1: int, t2: int) -> bool:
	var ws := _ws()
	if ws == null or ws.leader == null:
		return false
	var l: PoliticianData = ws.leader
	return l.trait_background == t3 and l.trait_special == t2 and l.trait_alignment == t1 \
		and l.trait_personality == t0 and l.name_last == name2 and l.name_first == name1


## HasCorruptLeader — yes: leader.traits[2]==18
static func has_corrupt_leader(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.leader != null and ws.leader.trait_special == GameConstants.PoliticianSpecial.CORRUPT
	return v if yes else not v


## AddLoyalityToAllPoliticians — 全体政治家 loyalty += num
static func add_loyality_to_all_politicians(num: int) -> void:
	var ws := _ws()
	if ws == null:
		return
	for p: PoliticianData in ws.politicians:
		if p != null:
			p.loyalty += num


# ============================================================================
# 第二批：version=2/3 决议原子（尾追加，不改第一批签名）
# 字段依赖已在 WorldState 补齐（desnull/oil_prod/oil_eat/austerity/...）。
# ============================================================================

## CanCouponSystemPhaseOut — yes: (data[16]<14 && data[12]+data[13]>=1500) || data[16]>=14
static func can_coupon_system_phase_out(yes: bool) -> bool:
	var d := _d()
	var v := (d.size() > W.I_ECON_SYSTEM and d[W.I_ECON_SYSTEM] < 14
			and d.size() > W.I_INDUSTRY and d.size() > W.I_AGRICULTURE
			and d[W.I_INDUSTRY] + d[W.I_AGRICULTURE] >= 1500) \
		or (d.size() > W.I_ECON_SYSTEM and d[W.I_ECON_SYSTEM] >= 14)
	return v if yes else not v


## HasAnthemConfirmed — yes: AnthemCooldownTime<=0（4 年一次的国歌事件冷却）
static func has_anthem_confirmed(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.anthem_cooldown_time <= 0
	return v if yes else not v


## HasAusterity / HasDevelopedConsumerism / HasNewEraCommuneMember /
## HasPartyMeansParty / HasPartySubsidy / HasPlannedPriceReduction / HasT72 / HasPMC
## — 原版统一模式：字段 > 0 为 true。
static func has_austerity(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.austerity > 0
	return v if yes else not v


static func has_developed_consumerism(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.developed_consumerism > 0
	return v if yes else not v


static func has_new_era_commune_member(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.new_era_commune_member > 0
	return v if yes else not v


static func has_party_means_party(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.party_means_party > 0
	return v if yes else not v


static func has_party_subsidy(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.party_subsidy > 0
	return v if yes else not v


static func has_planned_price_reduction(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.planned_price_reduction > 0
	return v if yes else not v


static func has_t72(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.arms_purchase_agreement > 0
	return v if yes else not v


static func has_pmc(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.pmc > 0
	return v if yes else not v


## HasLeaderAsset — LeaderAsset >= num
static func has_leader_asset(num: int) -> bool:
	var ws := _ws()
	return ws != null and ws.leader_asset >= num


## HasOilEat — OilEat >= num（float）
static func has_oil_eat(num: int) -> bool:
	var ws := _ws()
	return ws != null and ws.oil_eat >= float(num)


## HasRevolutionaryLeader — yes: traits[0]==0 || (traits[0]==20 && data[56]==0 && country1.SubGosstroy==2)
static func has_revolutionary_leader(yes: bool) -> bool:
	var ws := _ws()
	var china := _country(1)
	var d := _d()
	var t := ws.leader.trait_personality if (ws != null and ws.leader != null) else -1
	var v := t == 0 or (t == 20 and d.size() > W.I_POLITICAL_LINE and d[W.I_POLITICAL_LINE] == 0
			and china != null and china.sub_government == GameConstants.SubGovernment.MARXIST_LENINIST)
	return v if yes else not v


## HasSomeoneWonInTheWar — side!=0 → infl2>=900；side==0 → infl1>=900
static func has_someone_won_in_the_war(war: int, side: int) -> bool:
	var ws := _ws()
	if ws == null or war < 0 or war >= ws.wars.size():
		return false
	if side != 0:
		return ws.wars[war].infl2 >= 900
	return ws.wars[war].infl1 >= 900


## HasntJueQi — yes: !IndOpp
static func hasnt_jue_qi(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and not ws.ind_opp
	return v if yes else not v


## HaveBeenZhuTi — yes: country1.SubGosstroy==19（主体思想）
static func have_been_zhu_ti(yes: bool) -> bool:
	var china := _country(1)
	var v := china != null and china.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST
	return v if yes else not v


## HaveFullChina — yes: data[62]>=2 && (data[64]==2 || completedDecisions[7])
static func have_full_china(yes: bool) -> bool:
	var d := _d()
	var v := d.size() > W.I_ARUNACHAL_STATUS and d[W.I_ARUNACHAL_STATUS] >= 2 \
		and d.size() > W.I_TAIWAN_STATUS and (d[W.I_TAIWAN_STATUS] == 2 or _completed(7))
	return v if yes else not v


## ISCIA — yes: country51.dev > 0（美国 CIA 政变状态）
static func is_cia(yes: bool) -> bool:
	var usa := _country(51)
	var v := usa != null and usa.development > 0
	return v if yes else not v


## IsAfricanProprc — yes: 63/61/114/122/127/124 亲中且社会主义，且 68 有对华贸易且社会主义
static func is_african_proprc(yes: bool) -> bool:
	var ws := _ws()
	var v := true
	for idx in [63, 61, 114, 122, 127, 124]:
		var c := _country(idx)
		if c == null or not c.has_tag("亲中") or (ws != null and not ws.is_socialism(c, true)):
			v = false
			break
	if v:
		var c68 := _country(68)
		if c68 == null or not c68.has_tag("对华贸易") or (ws != null and not ws.is_socialism(c68, true)):
			v = false
	return v if yes else not v


## IsAfricanSocialism — 原版只统计区间内国家总数 >=6（名字 misleading，照抄）
static func is_african_socialism(yes: bool) -> bool:
	var ws := _ws()
	if ws == null:
		return false
	var num := 0
	for c: CountryData in ws.countries:
		var i := c.原版序号
		if ((i > 51 and i < 69) or (i > 105 and i < 109) or (i > 111 and i < 133)
				or i == 41 or i == 42 or i == 99 or i == 100) and i != 128:
			num += 1
	var v := num >= 6
	return v if yes else not v


## IsAfterTheDay — yes: (y>=year && m>=month && d>=day) || (y>=year && m>=month+1) || y>=year+1
static func is_after_the_day(yes: bool, year: int, month: int, day: int) -> bool:
	var d := _d()
	var yy := d[W.I_YEAR] if d.size() > W.I_YEAR else 0
	var mm := d[W.I_MONTH] if d.size() > W.I_MONTH else 0
	var dd := d[W.I_DAY] if d.size() > W.I_DAY else 0
	var v := (yy >= year and mm >= month and dd >= day) \
		or (yy >= year and mm >= month + 1) or yy >= year + 1
	return v if yes else not v


## IsChinaWarAliance — yes: country1.okb
static func is_china_war_aliance(yes: bool) -> bool:
	var china := _country(1)
	var v := china != null and china.has_tag("okb")
	return v if yes else not v


## IsCorruptionLessThan / IsDebtLessThan / IsEnvelopeLessThan — 原版统一 yes→< num，!yes→> num
static func is_corruption_less_than(yes: bool, num: int) -> bool:
	var v: int = _d()[W.I_CORRUPTION] if _d().size() > W.I_CORRUPTION else 0
	return v < num if yes else v > num


static func is_debt_less_than(yes: bool, num: int) -> bool:
	var v: int = _d()[W.I_LOAN] if _d().size() > W.I_LOAN else 0
	return v < num if yes else v > num


static func is_envelope_less_than(yes: bool, num: int) -> bool:
	var v: int = _d()[W.I_BUDGET_ENVELOPE] if _d().size() > W.I_BUDGET_ENVELOPE else 0
	return v < num if yes else v > num


## IsReserveLessThan — yes: data[36] < num；!yes: > num
static func is_reserve_less_than(yes: bool, num: int) -> bool:
	var v: int = _d()[W.I_RESERVE] if _d().size() > W.I_RESERVE else 0
	return v < num if yes else v > num


## IsCouponSystemPhasedOut — yes: HasCouponSystemPhaseOut
static func is_coupon_system_phased_out(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.has_coupon_system_phase_out
	return v if yes else not v


## IsIndustry — yes: data[12] >= how；!yes: < how
static func is_industry(how: int, yes: bool) -> bool:
	var v: int = _d()[W.I_INDUSTRY] if _d().size() > W.I_INDUSTRY else 0
	return v >= how if yes else v < how


## IsNoWars — yes: ingamewars[3,4,8,9,10,11,12,40,41,42] 全不进行
static func is_no_wars(yes: bool) -> bool:
	var ws := _ws()
	var any_going := false
	if ws != null:
		for war_id in [3, 4, 8, 9, 10, 11, 12, 40, 41, 42]:
			if war_id < ws.wars.size() and ws.wars[war_id].is_going:
				any_going = true
				break
	var v := not any_going
	return v if yes else not v


## IsOARCreated — yes: GameState.OAR
static func is_oar_created(yes: bool) -> bool:
	var ws := _ws()
	var v := ws != null and ws.oar
	return v if yes else not v


## IsOARfull — yes: 30/14/35/40/13 全 oar 且 13 无 parts[0/1]，且
## ((18.oar && 54.oar && !54.parts[0]) || (54.parts[0] && 54.oar))，且 55.oar
static func is_oar_full(yes: bool) -> bool:
	var c13 := _country(13)
	var c14 := _country(14)
	var c18 := _country(18)
	var c30 := _country(30)
	var c35 := _country(35)
	var c40 := _country(40)
	var c54 := _country(54)
	var c55 := _country(55)
	var v := _oar_tag(c30) and _oar_tag(c14) and _oar_tag(c35) and _oar_tag(c40) \
		and _oar_tag(c13) and c13 != null and c13.parts.size() > 1 and not c13.parts[0] and not c13.parts[1] \
		and ((_oar_tag(c18) and _oar_tag(c54) and c54 != null and c54.parts.size() > 0 and not c54.parts[0])
			or (c54 != null and c54.parts.size() > 0 and c54.parts[0] and _oar_tag(c54))) \
		and _oar_tag(c55)
	return v if yes else not v


static func _oar_tag(c: CountryData) -> bool:
	return c != null and c.has_tag("oar")


## IsRael — yes: country37 亲中且非亲美
static func is_rael(yes: bool) -> bool:
	var c := _country(37)
	var v := c != null and c.has_tag("亲中") and not c.has_tag("亲美")
	return v if yes else not v


## IsRealtions — yes: empires[empire].relations >= how；!yes: < how
static func is_realtions(how: int, empire: int, yes: bool) -> bool:
	var e := _empire(empire)
	var v := e.relations if e != null else 0
	return v >= how if yes else v < how


## IsRevotionaryOARfull — yes: 16 国全部社会主义、非亲苏、SubGosstroy!=16、oar；
## 且 101/105 SubGosstroy==17；且 resultOfEvents[437]!=1
static func is_revotionary_oar_full(yes: bool) -> bool:
	var ws := _ws()
	var flag := true
	if ws != null:
		for num in [13, 14, 35, 36, 37, 40, 53, 54, 55, 93, 101, 102, 103, 104, 105, 24]:
			var c := _country(num)
			if c == null or not ws.is_socialism(c, true) or c.has_tag("亲苏") \
					or c.sub_government == GameConstants.SubGovernment.SOVIET_STYLE or not c.has_tag("oar"):
				flag = false
				break
		var c101 := _country(101)
		var c105 := _country(105)
		if c101 == null or c101.sub_government != GameConstants.SubGovernment.MAOIST or c105 == null or c105.sub_government != GameConstants.SubGovernment.MAOIST:
			flag = false
		if _event_result(437, 1):
			flag = false
	return flag if yes else not flag


## NoZhuTiWar — yes: ingamewars[70..75] 无进行
static func no_zhu_ti_war(yes: bool) -> bool:
	var ws := _ws()
	var num := 0
	if ws != null:
		for war_id in range(70, 76):
			if war_id < ws.wars.size() and ws.wars[war_id].is_going:
				num += 1
	var v := num == 0
	return v if yes else not v


## OnceAMonth — 恒 yes（原版就是传回参数）
static func once_a_month(yes: bool) -> bool:
	return yes


## Oncein — yes: desnull[cock] <= 0（month 参数原版仅用于门槛文本）
static func oncein(cock: int, yes: bool) -> bool:
	var ws := _ws()
	if ws == null or cock < 0 or cock >= ws.desnull.size():
		return false
	var v := ws.desnull[cock] <= 0
	return v if yes else not v


# ── 第二批效果原子 ──

## AddAllAfrique — cum 1→sovpower 2→usapower 3→prcpower，区间 53..108，
## 跳过 (69..105) 与 africaOff
static func add_all_afrique(num: int, cum: int) -> void:
	var ws := _ws()
	if ws == null:
		return
	for c: CountryData in ws.countries:
		var i := c.原版序号
		if i < 53 or i > 108:
			continue
		if (i < 69 or i > 105) and not c.禁用非洲机制:
			if cum == 1:
				c.sov_power += num
			elif cum == 2:
				c.usa_power += num
			elif cum == 3:
				c.prc_power += num


## AddImport — data[6] += num（原版与 AddDiplo 同字段，照抄）
static func add_import(num: int) -> void:
	add_diplo(num)


## AddLeaderAsset — 原版 delegate 实为 data[6] += num（方法名 misleading，照抄）
static func add_leader_asset(num: int) -> void:
	add_diplo(num)


## AddNewModify — modifies[num].active = true
static func add_new_modify(num: int) -> void:
	var m := _mod(num)
	if m != null:
		m.is_active = true


## AddOilEat — ArmyPower += num；OilEat > 200 时照加，否则钳到 200
static func add_oil_eat(num: int) -> void:
	var ws := _ws()
	if ws == null:
		return
	ws.army_power += num
	if ws.oil_eat > 200.0:
		ws.oil_eat += float(num)
	else:
		ws.oil_eat = 200.0


## AddOilPrice — data[143]（油价）>=10 才加，否则 =10
static func add_oil_price(num: int) -> void:
	var d := _d()
	if d.size() <= 143:
		return
	if d[143] + num >= 10:
		d[143] += num
	else:
		d[143] = 10


## AddOilPrud — OilProd += num；data[152]<1500 → +50（>1500 则 1450）
static func add_oil_prud(num: int) -> void:
	var ws := _ws()
	if ws == null:
		return
	ws.oil_prod += float(num)
	var d := _d()
	if d.size() > W.I_INDUSTRY_BASE and d[W.I_INDUSTRY_BASE] < 1500:
		d[W.I_INDUSTRY_BASE] += 50
		if d[W.I_INDUSTRY_BASE] > 1500:
			d[W.I_INDUSTRY_BASE] = 1450


## AddOldModify — modifies[num].active=true；num==58 → data[153]=12
static func add_old_modify(num: int) -> void:
	var m := _mod(num)
	if m != null:
		m.is_active = true
	if num == 58:
		var d := _d()
		if d.size() > 153:
			d[153] = 12


## AddStabilityAfrique — 区间 53..108、跳过 (69..105) 与 africaOff → stab += num
static func add_stability_afrique(num: int) -> void:
	var ws := _ws()
	if ws == null:
		return
	for c: CountryData in ws.countries:
		var i := c.原版序号
		if i >= 53 and i <= 108 and (i < 69 or i > 105) and not c.禁用非洲机制:
			c.stab += num


## AddinflAlliance — cum 1/2/3 分别加 sovinfl / usainfl / prcinfl
static func add_infl_alliance(num: int, cum: int) -> void:
	var ws := _ws()
	if ws == null:
		return
	var china := _country(1)
	if cum == 1:
		for c: CountryData in ws.countries:
			if c.has_tag("ovd") and _in_ovd_infl_list(c.原版序号):
				c.sov_influence += num
	elif cum == 2:
		for c: CountryData in ws.countries:
			if c.has_tag("seato"):
				c.usa_influence += num
	else:
		for c: CountryData in ws.countries:
			var k := c.原版序号
			if c.has_tag("ovd") and china != null and china.has_tag("ovd"):
				if _in_ovd_infl_list(k):
					c.prc_influence += num
			elif c.has_tag("seato"):
				c.prc_influence += num


static func _in_ovd_infl_list(i: int) -> bool:
	return i == 8 or i == 11 or i == 14 or i == 12 or i == 31 or i == 32 or i == 22 \
		or i == 33 or i == 37 or i == 43 or i == 42 or i == 23 or i == 35 \
		or i == 96 or i == 97 or i == 98 or i == 95 or i == 49 or i == 50


## AfricanAlliance — completedDecisions[36] = true
static func african_alliance(_yes: bool = true) -> void:
	_set_completed(36)


## AllyWithOtherParties — factions 2..4 启用者全部 is_ally=true
static func ally_with_other_parties(_yes: bool = true) -> void:
	var ws := _ws()
	if ws == null:
		return
	for i in range(2, ws.factions.size()):
		if ws.factions[i].is_enabled:
			ws.factions[i].is_ally = true


## BlockForNewDemocracy — data[15]=7
static func block_for_new_democracy(_num: int) -> void:
	var d := _d()
	if d.size() > W.I_PARTY_SYSTEM:
		d[W.I_PARTY_SYSTEM] = 7


## BlockForStatemoncap — data[16]=12
static func block_for_statemoncap(_num: int) -> void:
	var d := _d()
	if d.size() > W.I_ECON_SYSTEM:
		d[W.I_ECON_SYSTEM] = 12


## BlockFreedom — completedDecisions[num]=true（原版 delegate 仅完成标记）
static func block_freedom(num: int) -> void:
	_set_completed(num)


## CouponSystemWillPhaseOut — HasCouponSystemPhaseOut = true
static func coupon_system_will_phase_out(_yes: bool = true) -> void:
	var ws := _ws()
	if ws != null:
		ws.has_coupon_system_phase_out = true


## CreateBigOAR — 逐字对齐 QueryDecisions CreateBigOAR（other_text[6]=阿拉伯联合共和国）
static func create_big_oar(_yes: bool = true) -> void:
	var ws := _ws()
	if ws == null:
		return
	var china := _country(1)
	var c30 := _country(30)
	for i in [13, 14, 30, 35, 40]:
		var c := _country(i)
		if c == null:
			continue
		for tag in ["亲苏", "亲美", "亲中", "sev", "ovd", "okb", "econ", "对华贸易", "oar"]:
			c.set_tag(tag, false)
	var c14 := _country(14)
	if c14 != null and c14.parts.size() > 4 and c14.parts[4]:
		c14.parts[4] = false
		if c30 != null and c30.parts.size() > 1:
			c30.parts[1] = true
	elif c30 != null and c30.parts.size() > 0:
		c30.parts[0] = true
	if c30 != null:
		c30.set_tag("对华贸易", true)
		c30.set_tag("亲中", true)
		c30.name = "阿拉伯联合共和国"
		c30.government = GameConstants.Government.REFORMIST
		c30.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
	_mod(46).is_active = true
	if china != null:
		if china.has_tag("okb"):
			if c30 != null:
				c30.set_tag("okb", true)
				c30.set_tag("econ", true)
		elif china.has_tag("ovd"):
			if c30 != null:
				c30.set_tag("ovd", true)
				c30.set_tag("sev", true)
		elif china.has_tag("sev"):
			if c30 != null:
				c30.set_tag("sev", true)
		elif china.has_tag("econ"):
			if c30 != null:
				c30.set_tag("econ", true)


## CreateNewLeader — 直接改写领袖字段 + LeaderAsset/MoneyLevel/modifies[65]/ServeRMB 清零
static func create_new_leader(name1: int, name2: int, t0: int, t3: int, t1: int, t2: int, age: int) -> void:
	var ws := _ws()
	if ws == null or ws.leader == null:
		return
	ws.leader.name_first = name1
	ws.leader.name_last = name2
	ws.leader.trait_personality = t0
	ws.leader.trait_background = t3
	ws.leader.trait_alignment = t1
	ws.leader.trait_special = t2
	ws.leader.age = age
	ws.leader_asset = 0
	ws.money_level = 0
	var m65 := _mod(65)
	if m65 != null:
		m65.is_active = false
	ws.serve_rmb = false


## CreateNewPolitician — 替换 power 最低且 traits[0]!=trait0 的槽位
static func create_new_politician(name1: int, name2: int, t0: int, t3: int, t1: int, t2: int, age: int) -> void:
	var ws := _ws()
	if ws == null or ws.politicians.is_empty():
		return
	var num := 0
	for i in ws.politicians.size():
		var p: PoliticianData = ws.politicians[i]
		if p != null and p.power < ws.politicians[num].power and p.trait_personality != t0:
			num = i
	if _kill_politician_cb.is_valid():
		_kill_politician_cb.call(num)
	if num < ws.politicians.size() and ws.politicians[num] != null:
		var p2: PoliticianData = ws.politicians[num]
		p2.name_first = name1
		p2.name_last = name2
		p2.age = age
		p2.trait_personality = t0
		p2.trait_background = t3
		p2.trait_alignment = t1
		p2.trait_special = t2
		p2.power = 800
		p2.loyalty = 800


## DoTimer — desnull[cock] = month
static func do_timer(cock: int, month: int) -> void:
	var ws := _ws()
	if ws != null and cock >= 0 and cock < ws.desnull.size():
		ws.desnull[cock] = month


## EliminateCorruptElements — traits[2]==18 的政治家全部 KillPerson
static func eliminate_corrupt_elements(_yes: bool = true) -> void:
	var ws := _ws()
	if ws == null:
		return
	var targets: Array[int] = []
	for i in ws.politicians.size():
		var p: PoliticianData = ws.politicians[i]
		if p != null and p.trait_special == GameConstants.PoliticianSpecial.CORRUPT:
			targets.append(i)
	for i in targets:
		if _kill_politician_cb.is_valid():
			_kill_politician_cb.call(i)


## Get* — 原版固定值置位（值即持续月数/等级）
static func get_austerity(_yes: bool = true) -> void:
	var ws := _ws()
	if ws != null:
		ws.austerity = 12


static func get_developed_consumerism(_yes: bool = true) -> void:
	var ws := _ws()
	if ws != null:
		ws.developed_consumerism = 12


static func get_mongolia(num: int) -> void:
	_set_completed(num)


static func get_new_era_commune_member(_yes: bool = true) -> void:
	var ws := _ws()
	if ws != null:
		ws.new_era_commune_member = 6


static func get_pmc(_yes: bool = true) -> void:
	var ws := _ws()
	if ws != null:
		ws.pmc = 6


static func get_party_means_party(_yes: bool = true) -> void:
	var ws := _ws()
	if ws != null:
		ws.party_means_party = 6


static func get_party_subsidy(_yes: bool = true) -> void:
	var ws := _ws()
	if ws != null:
		ws.party_subsidy = 6


static func get_planned_price_reduction(_yes: bool = true) -> void:
	var ws := _ws()
	if ws != null:
		ws.planned_price_reduction = 12


static func get_t72(_yes: bool = true) -> void:
	var ws := _ws()
	if ws != null:
		ws.arms_purchase_agreement = 3


## MakeInWPO — allcountries[country].isOVD = yes
static func make_in_wpo(yes: bool, country: int) -> void:
	var c := _country(country)
	if c != null:
		c.set_tag("ovd", yes)


## MercenaryRebellion — MilitaryService++；>=3 且 rng(0..3)==1 → 触发事件 692
static func mercenary_rebellion(_yes: bool = true) -> void:
	var ws := _ws()
	if ws == null:
		return
	ws.military_service += 1
	if ws.military_service >= 3 and ws.ensure_rng().randi_range(0, 3) == 1:
		start_event(692)


## OnAgentModif / OnArmyModif — 激活 modifies[47]/[48]
static func on_agent_modif(_yes: bool = true) -> void:
	var m := _mod(47)
	if m != null:
		m.is_active = true


static func on_army_modif(_yes: bool = true) -> void:
	var m := _mod(48)
	if m != null:
		m.is_active = true


## OnSEATO — country51.cw=true；所有 SENTO 成员 LeaveSENTO().JoinASEAN()
static func on_seato(_yes: bool = true) -> void:
	var ws := _ws()
	if ws == null:
		return
	var c51 := _country(51)
	if c51 != null:
		c51.内战中 = true
	for c: CountryData in ws.countries:
		if c.has_tag("sento"):
			c.set_tag("sento", false)
			c.set_tag("asean", true)


## UniteArab — 逐字对齐 QueryDecisions UniteArab
static func unite_arab() -> void:
	var ws := _ws()
	if ws == null:
		return
	var c54 := _country(54)
	var c30 := _country(30)
	if c54 != null and c54.parts.size() > 0:
		c54.parts[0] = false
	if c30 == null:
		return
	if c30.parts.size() > 2:
		c30.parts[2] = true
	c30.name = "阿拉伯革命社会主义\n联邦共和国"
	c30.government = GameConstants.Government.SOCIALIST
	c30.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
	_leave_all_legacy(c30)
	c30.set_tag("对华贸易", true)
	c30.set_tag("亲中", true)
	c30.set_tag("oar", true)
	_join_all_legacy(c30)


## LeaveAlliances 等价（对齐 event_script_base._leave_alliances 的标签清单）
static func _leave_all_legacy(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = GameConstants.LegacySlot.NONE


## JoinAllOurAlliances(true) 等价（中国 econ→econ；否则 sev→sev）
static func _join_all_legacy(c: CountryData) -> void:
	var china := _country(1)
	if china == null or c == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)
