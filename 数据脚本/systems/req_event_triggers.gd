class_name ReqEventTriggers
extends RefCounted

## 原版 ReqEventsDLC02/ReqEventForDLC02.cs 的触发轮询移植（仅覆盖此前无触发器的 63 个事件）。
## 调用点：TimeScript.cs:11154-11166 —— 无事件弹窗时按 DLC02 → DLC03 → DLC01 顺序轮询。
## Godot 调用点：game_manager.gd tick() 在 EventEngine.check_and_fire() 之后、current_event_id=="" 时调用。
## 每个分支以 `# CS L<行号>` 标注 Unity 源码出处。

const W = preload("res://数据脚本/world_state.gd")


static func poll(w: WorldState) -> bool:
	if w == null or GameManager == null or EventEngine == null:
		return false
	if w.dlc.size() > 2 and w.dlc[2] and _req_dlc02(w):
		return true
	if w.dlc.size() > 3 and w.dlc[3] and _req_dlc03(w):
		return true
	if w.dlc.size() > 1 and w.dlc[1] and _req_dlc01(w):
		return true
	return false


# ============================================================================
# RequrementsDLC02 —— 党内人物链 301-310（CS L454-499）
# ============================================================================

static func _req_dlc02(w: WorldState) -> bool:
	# CS L454-457
	if not _done(301) and _done(300) and (_res(300) == 0 or _res(300) == 1):
		return _start(301)
	# CS L459-462
	if not _done(302) and _done(301) and (_res(300) == 0 or _res(300) == 1):
		return _start(302)
	# CS L464-467
	if not _done(303) and _done(300) and _res(300) == 3:
		return _start(303)
	# CS L469-472
	if w.leader != null and w.leader.name_first == 2 and w.leader.name_last == 2 \
			and not _mod_active(w, GameConstants.Modifier.CULTURAL_REVOLUTION) and not _done(503) \
			and (_dv(w, 1) < 500 or _dv(w, 4) > 500 or _dv(w, 3) < 500 or _dv(w, 5) < 250) \
			and not _done(304) and w.date.year >= 1979:
		return _start(304)
	# CS L474-477
	if _find_politician(w, 13, 13) >= 0 and _dv(w, 1) <= 850 \
			and (_faction_leading(0) or _faction_leading(1) or _faction_leading(2)) \
			and not _done(305) and w.date.year >= 1981:
		return _start(305)
	# CS L479-482
	if _find_politician(w, 15, 15) >= 0 and w.date.year >= 1985 \
			and not _done(306) and _res(444) != 0:
		return _start(306)
	# CS L484-487
	if not _done(307) and w.date.year >= 1983:
		return _start(307)
	# CS L489-492
	if not _done(308) and w.date.year >= 1979:
		return _start(308)
	# CS L494-497
	if _find_politician(w, 16, 16) >= 0 and not _done(309) and w.date.year >= 1981 \
			and ((_dv(w, 1) <= 750 and (_faction_leading(0) or _faction_leading(1))) or _done(304)):
		return _start(309)
	# CS L499-502
	if not _done(310) and w.date.year >= 1981 \
			and (_find_politician(w, 16, 16) < 0 or _done(309)):
		return _start(310)
	return false


# ============================================================================
# RequrementsDLC03 —— 土/希/法/西/意与东欧链（按源码行序，只保留缺口事件）
# ============================================================================

static func _req_dlc03(w: WorldState) -> bool:
	# CS L1041-1044（380）
	if not _done(380) and _emp_leader(w, 1) == 4 and _ge(w, 1985, 3, 16):
		return _start(380)
	# CS L1051-1054（376）
	if not _done(376) and _ge(w, 1977, 7, 14):
		return _start(376)
	# CS L1056-1059（377）
	if not _done(377) and not _tag(w, 1, "asean") and _gov(w, 7) != 2 \
			and _ge(w, 1985, 4, 1) and not _tag(w, 1, "ovd") and not _tag(w, 1, "sev") \
			and _emp_leader(w, 1) == 4 and _emp_power(w, 1) > 100 \
			and not _tag(w, 4, "亲苏") and not _tag(w, 5, "亲苏") and not _tag(w, 2, "亲苏") \
			and not _war_going(w, 22) and _dv(w, 133) == 0:
		return _start(377)
	# CS L1061-1064（378）
	if not _done(378) and _ge(w, 1982, 6, 1) \
			and not _tag(w, 10, "亲苏") and not _tag(w, 10, "okb") and not _tag(w, 10, "econ") \
			and (not _dec_done(w, 0) or not _done(539)) and not _tag(w, 10, "ovd") \
			and not _tag(w, 10, "sev") and not _done(29) and not _tag(w, 10, "rim"):
		return _start(378)
	# CS L1066-1069（379）
	if not _done(379) and _dv(w, 130) != 1 and _tag(w, 9, "sev") and _dv(w, W.I_INFLUENCE) > 500 \
			and w.date.year == 1983 and w.date.month > 3 and w.date.year < 1984 \
			and _emp_leader(w, 1) == 1 and _emp_leader(w, 0) == 1 \
			and _emp_power(w, 1) + _emp_power(w, 0) < 300 and not _tag(w, 1, "ovd") \
			and _tag(w, 51, "nato") and not _tag(w, 1, "sev") and not _tag(w, 1, "asean") \
			and _tag(w, 12, "亲苏") and _war_going(w, 5) \
			and (_war_diplo_done(w, 5, 1) or _res(52) == 3 or _res(50) == 3):
		return _start(379)
	# CS L1071-1074（381）
	if not _done(381) and _emp_leader(w, 1) == 7 and _ge(w, 1985, 1, 1) \
			and _tag(w, 17, "nato") and _tag(w, 17, "eu"):
		return _start(381)
	# CS L1081-1084（382）
	if not _done(382) and _ge(w, 1981, 6, 1) and _res(76) == 3 \
			and not _tag(w, 1, "eu") and not _tag(w, 1, "nato") and not _tag(w, 1, "sev") and not _tag(w, 1, "ovd"):
		return _start(382)
	# CS L1086-1089（383）
	if not _done(383) and _ge(w, 1985, 5, 1) and _parts(w, 20, 0) \
			and not _tag(w, 45, "econ") and not _tag(w, 45, "sev") and not _tag(w, 45, "nato") \
			and _dv(w, 60) == 3:
		return _start(383)
	# CS L1091-1094（384）
	if not _done(384) and _ge(w, 1981, 2, 1):
		return _start(384)
	# CS L1096-1099（385）
	if not _done(385) and _ge(w, 1981, 5, 11):
		return _start(385)
	# CS L1101-1104（387）
	if not _done(387) and _ge(w, 1979, 2, 21):
		return _start(387)
	# CS L1111-1114（389；原版笔误 `a.data.year > 15` 按日期语义移植为日>15）
	if not _done(389) and _ge(w, 1983, 6, 16) and _dv(w, 131) == 1:
		return _start(389)
	# CS L1116-1119（390）
	if not _done(390) and _ge(w, 1983, 5, 1) and _dv(w, 131) == 2:
		return _start(390)
	# CS L1126-1129（291）
	if not _done(291) and _ge(w, 1977, 3, 1):
		return _start(291)
	# CS L1131-1134（391）
	if not _done(391) and _ge(w, 1977, 12, 1):
		return _start(391)
	# CS L1136-1139（392）
	if not _done(393) and not _done(392) and _ge(w, 1978, 3, 20) \
			and _res(391) != 3 and not _done(556) and not _done(396):
		return _start(392)
	# CS L1141-1144（393）
	if not _done(393) and not _done(392) and _ge(w, 1978, 3, 20) \
			and _res(391) == 3 and not _done(556) and not _done(396):
		return _start(393)
	# CS L1151-1154（394）
	if (_res(393) > 0 or _done(392)) and not _done(394) and _ge(w, 1979, 6, 21) \
			and not _done(556) and not _done(396) and _sub(w, 85) != 20:
		return _start(394)
	# CS L1146-1149（292）
	if (_res(393) > 0 or _done(392)) and not _done(292) and _ge(w, 1978, 8, 20) \
			and not _done(556) and not _done(396) and _sub(w, 85) != 20:
		return _start(292)
	# CS L1156-1159（293）
	if (_res(393) > 0 or _done(392)) and not _done(293) and not _done(401) \
			and _infl_ch(w, 85) > 0 and _sub(w, 85) != 8 and _ge(w, 1980, 2, 20) \
			and not _done(556) and not _done(399) and not _done(396) and _sub(w, 85) != 20:
		return _start(293)
	# CS L1161-1164（294）
	if not _done(294) and _perevorot(w, 85) and _ge(w, 1980, 8, 20) \
			and not _done(556) and not _done(396):
		return _start(294)
	# CS L1166-1169（295）
	if not _done(295) and w.get_flag("VasilyisGay") and _ge(w, 1980, 10, 1) \
			and not _done(556) and not _done(396) and _sub(w, 85) != 20:
		return _start(295)
	# CS L1171-1174（296）
	if (_res(393) > 0 or _done(392)) and not _done(296) and not w.is_authoritarian(_c(w, 85)) \
			and not _done(556) and not _done(396) and _ge(w, 1981, 3, 20) and _sub(w, 85) != 20:
		return _start(296)
	# CS L1196-1199（297）
	if not _done(297) and _dv(w, 182) > 6 \
			and (_infl_ch(w, 85) > 0 or w.get_flag("VasilyisGay") or _sub(w, 85) == 5) \
			and _ge(w, 1980, 9, 11) and not _done(556) and not _done(396) and _sub(w, 85) != 20:
		return _start(297)
	# CS L1201-1204（298）
	if not _done(298) and _res(297) == 3 and _dv(w, 183) == 0 \
			and not _done(556) and not _done(396) and _sub(w, 85) != 20:
		return _start(298)
	# CS L1206-1209（299）
	if not _done(299) and _infl_ch(w, 85) <= 0 and _done(298) \
			and not _done(556) and not _done(396) and _sub(w, 85) != 20:
		return _start(299)
	# CS L1226-1229（395）
	if not _done(395) and _sub(w, 85) == 20 and _perevorot(w, 85) and _dv(w, 134) > 140 \
			and _res(391) <= 2 and not _done(556) and not _done(396):
		return _start(395)
	return false


# ============================================================================
# RequrementsDLC01 —— 拉美选举链 126-151（CS L1591-1716）
# ============================================================================

static func _req_dlc01(w: WorldState) -> bool:
	if _south_america_election_due(w, 73) and (not _tag(w, 73, "亲中") or _gov(w, 73) == 3) and not _done(126):
		return _start(126)
	if _south_america_election_due(w, 73) and (not _tag(w, 73, "亲中") or _gov(w, 73) == 3) and _done(126) and not _done(127):
		return _start(127)
	if _south_america_election_due(w, 71) and (not _tag(w, 71, "亲中") or _gov(w, 71) == 3) and not _done(128):
		return _start(128)
	if _south_america_election_due(w, 71) and (not _tag(w, 71, "亲中") or _gov(w, 71) == 3) and _done(128) and not _done(129):
		return _start(129)
	if _south_america_election_due(w, 72) and (not _tag(w, 72, "亲中") or _gov(w, 72) == 3) and not _done(130):
		return _start(130)
	if _south_america_election_due(w, 72) and (not _tag(w, 72, "亲中") or _gov(w, 72) == 3) and _done(130) and not _done(131):
		return _start(131)
	if _south_america_election_due(w, 72) and (not _tag(w, 72, "亲中") or _gov(w, 72) == 3) and _done(131) and not _done(132):
		return _start(132)
	if _south_america_election_due(w, 74) and (not _tag(w, 74, "亲中") or _gov(w, 74) == 3) and not _done(133):
		return _start(133)
	if _south_america_election_due(w, 74) and (not _tag(w, 74, "亲中") or _gov(w, 74) == 3) and _done(133) and not _done(134):
		return _start(134)
	if _south_america_election_due(w, 82) and (not _tag(w, 82, "亲中") or _gov(w, 82) == 3) and not _done(135):
		return _start(135)
	if _south_america_election_due(w, 82) and (not _tag(w, 82, "亲中") or _gov(w, 82) == 3) and _done(135) and not _done(136):
		return _start(136)
	if _south_america_election_due(w, 82) and (not _tag(w, 82, "亲中") or _gov(w, 82) == 3) and _done(136) and not _done(137):
		return _start(137)
	if _south_america_election_due(w, 79) and (not _tag(w, 79, "亲中") or _gov(w, 79) == 3) and not _done(138):
		return _start(138)
	if _south_america_election_due(w, 79) and (not _tag(w, 79, "亲中") or _gov(w, 79) == 3) and _res(138) == 0 and _done(138) and not _done(139):
		return _start(139)
	if _south_america_election_due(w, 79) and (not _tag(w, 79, "亲中") or _gov(w, 79) == 3) and _res(138) != 0 and _done(138) and not _done(140):
		return _start(140)
	if _south_america_election_due(w, 80) and (not _tag(w, 80, "亲中") or _gov(w, 80) == 3) and not _done(141):
		return _start(141)
	if _south_america_election_due(w, 80) and (not _tag(w, 80, "亲中") or _gov(w, 80) == 3) and _done(141) and not _done(142):
		return _start(142)
	if _south_america_election_due(w, 76) and (not _tag(w, 76, "亲中") or _gov(w, 76) == 3) and not _done(143):
		return _start(143)
	if _south_america_election_due(w, 76) and (not _tag(w, 76, "亲中") or _gov(w, 76) == 3) and _done(143) and not _done(144):
		return _start(144)
	if _south_america_election_due(w, 75) and (not _tag(w, 75, "亲中") or _gov(w, 75) == 3) and not _done(145):
		return _start(145)
	if _south_america_election_due(w, 75) and (not _tag(w, 75, "亲中") or _gov(w, 75) == 3) and _done(145) and not _done(146):
		return _start(146)
	if _south_america_election_due(w, 83) and (not _tag(w, 83, "亲中") or _gov(w, 83) == 3) and not _done(147):
		return _start(147)
	if _south_america_election_due(w, 83) and (not _tag(w, 83, "亲中") or _gov(w, 83) == 3) and _done(147) and not _done(148):
		return _start(148)
	if _south_america_election_due(w, 77) and (not _tag(w, 77, "亲中") or _gov(w, 77) == 3) and not _done(149):
		return _start(149)
	if _south_america_election_due(w, 77) and (not _tag(w, 77, "亲中") or _gov(w, 77) == 3) and _done(149) and not _done(150):
		return _start(150)
	if _south_america_election_due(w, 81) and (not _tag(w, 81, "亲中") or _gov(w, 81) == 3) and not _done(151):
		return _start(151)
	return false


# ============================================================================
# 公共辅助（语义与原版一致）
# ============================================================================

static func _start(num: int) -> bool:
	# 原版 ReqEventForDLC02/TimeScript 轮询命中后走 events[0] 地图标记（EventScript.Reset），
	# 因此这里不能直接 start_event，必须 queue_pending 让外交界面先出现提示图标。
	var def: EventDef = EventEngine.get_event_by_number(num)
	var eid := def.event_id if def != null else "event_%d" % num
	EventEngine.queue_pending(eid)
	return true


static func _done(num: int) -> bool:
	return EventEngine.event_done_by_number(num)


static func _res(num: int) -> int:
	return EventEngine.result_of_event_by_number(num)


static func _dv(w: WorldState, idx: int) -> int:
	if w.size() > idx:
		return w.get_data_by_index(idx)
	return 0


static func _c(w: WorldState, idx: int) -> CountryData:
	return w.get_country_by_legacy_index(idx)


static func _gov(w: WorldState, idx: int) -> int:
	var c := _c(w, idx)
	return c.government if c != null else 0


static func _sub(w: WorldState, idx: int) -> int:
	var c := _c(w, idx)
	return c.sub_government if c != null else 0


static func _tag(w: WorldState, idx: int, tag: String) -> bool:
	var c := _c(w, idx)
	return c != null and c.has_tag(tag)


static func _parts(w: WorldState, idx: int, part: int) -> bool:
	var c := _c(w, idx)
	return c != null and part >= 0 and part < c.parts.size() and c.parts[part]


static func _infl_ch(w: WorldState, idx: int) -> int:
	var c := _c(w, idx)
	return c.influence_china if c != null else 0


static func _perevorot(w: WorldState, idx: int) -> bool:
	var c := _c(w, idx)
	return c != null and c.政变中


static func _emp(w: WorldState, idx: int) -> EmpireData:
	if w.empires.size() > idx:
		return w.empires[idx]
	return null


static func _emp_leader(w: WorldState, idx: int) -> int:
	var e := _emp(w, idx)
	return e.current_leader if e != null else -1


static func _emp_power(w: WorldState, idx: int) -> int:
	var e := _emp(w, idx)
	return e.power if e != null else 0


static func _war_going(w: WorldState, idx: int) -> bool:
	if idx < 0 or idx >= w.wars.size():
		return false
	var war: WarData = w.wars[idx]
	return war != null and war.is_going


static func _war_diplo_done(w: WorldState, idx: int, side: int) -> bool:
	if idx < 0 or idx >= w.wars.size():
		return false
	var war: WarData = w.wars[idx]
	return war != null and side >= 0 and side < war.diplo_done.size() and war.diplo_done[side]


static func _mod_active(w: WorldState, idx: int) -> bool:
	return idx >= 0 and idx < w.modifiers.size() and w.modifiers[idx] != null and w.modifiers[idx].is_active


static func _find_politician(w: WorldState, name1: int, name2: int) -> int:
	for i in w.politicians.size():
		var p: PoliticianData = w.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


static func _faction_leading(faction_index: int) -> bool:
	return GameManager.is_faction_leading(faction_index)


static func _dec_done(w: WorldState, idx: int) -> bool:
	return w.decisions != null and idx >= 0 and idx < w.decisions.completed.size() and w.decisions.completed[idx]


## 日期 >= y/m/d（等价原版多段 year/month/day 组合判断）。
static func _ge(w: WorldState, y: int, m: int, d: int) -> bool:
	var dt: GameDate = w.date
	if dt.year != y:
		return dt.year > y
	if dt.month != m:
		return dt.month > m
	return dt.day >= d


## 原版 `next.Month<=month && next.Year<=year || next.Year<year`。
static func _election_due(w: WorldState, idx: int) -> bool:
	var c := _c(w, idx)
	if c == null:
		return false
	var dt: GameDate = w.date
	return (c.next_election_month <= dt.month and c.next_election_year <= dt.year) \
		or c.next_election_year < dt.year


## 南美选举链的“选举到期且未被手动颠覆”判定（用户需求：外交动作 1036
## 煽动当地推翻政府 等手动颠覆后，该国不再按历史时间线触发选举剧情）。
static func _south_america_election_due(w: WorldState, idx: int) -> bool:
	var c := _c(w, idx)
	if c == null or c.has_tag("手动颠覆"):
		return false
	return _election_due(w, idx)
