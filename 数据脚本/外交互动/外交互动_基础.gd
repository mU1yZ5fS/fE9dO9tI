## 外交互动公共翻译层 — DiploButtonScript.cs → GDScript 的公共字段/方法镜像。
## 本脚本不直接实例化，由 外交互动_批X.gd extends 后使用。
## 约定：
##   - 原版 this.a = GlobalScript.inst.gameState → 参数 w: WorldState
##   - 原版 this.selected_country = allcountries[N] 数组下标 → country.原版序号
##   - 原版 data[i] → w.数值表[i]（下标越界读 0，与原版未初始化 int 默认一致）
##   - 原版 event_done[N]/resultOfEvents[N] → w.event_done_num/w.result_of_event_num
##   - 原版 modifies[i].active → w.modifier_active(i)
##   - 原版 ingamewars[i].is_going → w.war_going(i)
##   - 原版散落 bool（relres/guns/...）→ w.get_flag("名字")，缺省 false 与原版默认一致
extends RefCounted


# ── 数据表/状态 ──

## data[idx]，越界按 0（GameState.data 固定 150 槽，未初始化 int 默认 0）。
func d(w: WorldState, idx: int) -> int:
	if idx >= 0 and idx < w.数值表.size():
		return w.数值表[idx]
	return 0


## data[idx] 直接写入；数组按需扩展。
func set_d(w: WorldState, idx: int, value: int) -> void:
	if idx >= 0:
		while w.数值表.size() <= idx:
			w.数值表.append(0)
		w.数值表[idx] = value


## data[idx] += delta（原版 `this.a.data[i] += n`）。
func _add_d(w: WorldState, idx: int, delta: int) -> void:
	set_d(w, idx, d(w, idx) + delta)


## 便捷：allcountries[idx].has_tag(tag)。
func _has(w: WorldState, idx: int, tag: String) -> bool:
	var cc := c(w, idx)
	return cc != null and cc.has_tag(tag)


## allcountries[idx].level_of_dev / level_of_unstab。
func _lvl_dev(w: WorldState, idx: int) -> int:
	var cc := c(w, idx)
	return cc.level_of_development if cc != null else 0


func _lvl_inst(w: WorldState, idx: int) -> int:
	var cc := c(w, idx)
	return cc.level_of_instability if cc != null else 0


## allcountries[idx].level_of_unstab 的十进制定点显示（原版 `x/10 + "." + x%10`）。
func _ctrl(w: WorldState, idx: int) -> String:
	var v := _lvl_inst(w, idx)
	@warning_ignore("integer_division")
	return "%d.%d" % [v / 10, absi(v % 10)]


## 原版 GameState.science[i] → TechState.unlocked[i]。
func _sci(w: WorldState, idx: int) -> bool:
	if w == null or w.techs == null or idx < 0 or idx >= w.techs.unlocked.size():
		return false
	return w.techs.unlocked[idx]


func _set_sci(w: WorldState, idx: int, value: bool) -> void:
	if w == null or w.techs == null or idx < 0:
		return
	while w.techs.unlocked.size() <= idx:
		w.techs.unlocked.append(false)
	w.techs.unlocked[idx] = value


func ev(w: WorldState, num: int) -> bool:
	return w.event_done_num(num)


func res(w: WorldState, num: int) -> int:
	return w.result_of_event_num(num)


func set_ev(w: WorldState, num: int, value: bool) -> void:
	w.set_event_done_num(num, value)


func set_res(w: WorldState, num: int, value: int) -> void:
	w.set_result_of_event_num(num, value)


func war(w: WorldState, idx: int) -> bool:
	return w.war_going(idx)


func mod(w: WorldState, idx: int) -> bool:
	return w.modifier_active(idx)


func fl(w: WorldState, flag_name: String) -> bool:
	return w.get_flag(flag_name)


## 原版 completedDecisions[i]。
func dec(w: WorldState, idx: int) -> bool:
	if w == null or w.decisions == null or idx < 0 or idx >= w.decisions.completed.size():
		return false
	return w.decisions.completed[idx]


func set_dec(w: WorldState, idx: int, value: bool) -> void:
	if w == null or w.decisions == null or idx < 0:
		return
	while w.decisions.completed.size() <= idx:
		w.decisions.completed.append(false)
	w.decisions.completed[idx] = value


func set_fl(w: WorldState, flag_name: String, value: bool) -> void:
	w.set_flag(flag_name, value)


## 原版 GlobalScript.inst.gameState.number_event → Godot 用 GameManager.start_event 语义。
func start_event(event_id: String) -> void:
	if GameManager != null:
		GameManager.start_event(event_id)


## 原版 `number_event = N; LoadScene("Event")` 的语义：按原版事件编号触发。
func start_event_num(_w: WorldState, num: int) -> void:
	if EventEngine != null:
		var event_def: EventDef = EventEngine.get_event_by_number(num)
		if event_def != null:
			start_event(event_def.event_id)
			return
	start_event("event_%d" % num)


# ── 国家字段 ──

func c(w: WorldState, idx: int) -> CountryData:
	return w.get_country_by_legacy_index(idx)


func gov(country: CountryData) -> int:
	return country.government if country != null else -1


## 便捷：allcountries[idx] 的 Gosstroy/SubGosstroy/puppetOf/cw。
func _gov(w: WorldState, idx: int) -> int:
	return gov(c(w, idx))


func _sub(w: WorldState, idx: int) -> int:
	return sub(c(w, idx))


func _pup(w: WorldState, idx: int) -> int:
	return pup(c(w, idx))


func _cw(w: WorldState, idx: int) -> bool:
	var cc := c(w, idx)
	return cc != null and cc.内战中


## 确保 wars 数组到 idx 槽并返回该槽（缺失槽用空 WarData 占位）。
func _ensure_war(w: WorldState, idx: int) -> WarData:
	while w.wars.size() <= idx:
		w.wars.append(WarData.new())
	return w.wars[idx]


## 统计若干 allcountries 下标中 proprc（亲中）的个数。
func _count_proprc(w: WorldState, indices: Array) -> int:
	var count := 0
	for idx in indices:
		if _has(w, int(idx), "亲中"):
			count += 1
	return count


## 统计闭区间 [from_idx, to_idx] 中 proprc 的个数（原版 for 循环语义）。
func _count_proprc_range(w: WorldState, from_idx: int, to_idx: int) -> int:
	var count := 0
	for i in range(from_idx, to_idx + 1):
		if _has(w, i, "亲中"):
			count += 1
	return count


func sub(country: CountryData) -> int:
	return country.sub_government if country != null else -1


func pup(country: CountryData) -> int:
	return country.puppet_of if country != null else -1


func has(country: CountryData, tag: String) -> bool:
	return country != null and country.has_tag(tag)


func set_tag(country: CountryData, tag: String, value: bool) -> void:
	if country != null:
		country.set_tag(tag, value)


func parts(country: CountryData, idx: int) -> bool:
	if country == null or idx < 0 or idx >= country.parts.size():
		return false
	return country.parts[idx]


func set_parts(country: CountryData, idx: int, value: bool) -> void:
	if country == null or idx < 0:
		return
	while country.parts.size() <= idx:
		country.parts.append(false)
	country.parts[idx] = value


## 原版 Country.ILoveSuckCocks()（Country.cs L286-420）的 Godot 等价实现：
## 按 IndOpp/GKChP/藏南/台湾地位等刷新中国地图 parts。
func _refresh_china_map_parts(w: WorldState, china: CountryData) -> void:
	if china == null:
		return
	if china.parts.size() < 16:
		china.parts.resize(16)
	var data := w.数值表
	var d62 := data[62] if data.size() > 62 else 0
	var d64 := data[64] if data.size() > 64 else 0
	var d130 := data[130] if data.size() > 130 else 0
	var dec7 := false
	if w.decisions != null and w.decisions.completed.size() > 7:
		dec7 = w.decisions.completed[7]
	var c19 := c(w, 19)
	var c33 := c(w, 33)
	if w.get_flag("IndOpp"):
		_clear_china_parts(china, true)
		china.parts[15] = true
	elif c19 != null and c19.puppet_of == 1 and c19.sub_government == 19 \
			and c33 != null and c33.puppet_of == 1 and c33.sub_government == 19:
		_clear_china_parts(china, true)
		china.parts[14] = true
	elif c33 != null and c33.puppet_of == 1 and c33.sub_government == 19:
		_clear_china_parts(china, true)
		china.parts[13] = true
	elif c19 != null and c19.puppet_of == 1 and c19.sub_government == 19:
		_clear_china_parts(china, true)
		china.parts[12] = true
	elif w.get_flag("is_gkchp"):
		_clear_china_parts(china, true)
		china.parts[11] = true
	elif d130 == 1 and d62 >= 2 and (d64 == 2 or dec7):
		_clear_china_parts(china, false)
		china.parts[0] = true
	elif d130 == 1 and (d62 == 2 or d62 == 3):
		_clear_china_parts(china, false)
		china.parts[2] = true
	elif d62 >= 2 and (d64 == 2 or dec7):
		_clear_china_parts(china, false)
		china.parts[6] = true
	elif d130 == 1 and (d64 == 2 or dec7):
		_clear_china_parts(china, false)
		china.parts[3] = true
	elif d130 == 1:
		_clear_china_parts(china, false)
		china.parts[4] = true
	elif d64 == 2 or dec7:
		_clear_china_parts(china, false)
		china.parts[5] = true
	elif d62 >= 2:
		_clear_china_parts(china, false)
		china.parts[1] = true
	else:
		_clear_china_parts(china, false)
		china.parts[10] = true


func _clear_china_parts(china: CountryData, clear_all: bool) -> void:
	for i in china.parts.size():
		if clear_all or i < 7 or i > 9:
			china.parts[i] = false


func soc(w: WorldState, country: CountryData, strict: bool) -> bool:
	return w.is_socialism(country, strict)


func auth(w: WorldState, country: CountryData) -> bool:
	return w.is_authoritarian(country)


# ── 帝国 ──

func emp(w: WorldState, idx: int) -> EmpireData:
	if idx >= 0 and idx < w.empires.size():
		return w.empires[idx]
	return null


func rel(w: WorldState, idx: int) -> int:
	var e := emp(w, idx)
	return e.relations if e != null else 0


func power(w: WorldState, idx: int) -> int:
	var e := emp(w, idx)
	return e.power if e != null else 0


func add_rel(w: WorldState, idx: int, delta: int) -> void:
	var e := emp(w, idx)
	if e != null:
		e.relations += delta


func set_rel(w: WorldState, idx: int, value: int) -> void:
	var e := emp(w, idx)
	if e != null:
		e.relations = value


func add_power(w: WorldState, idx: int, delta: int) -> void:
	var e := emp(w, idx)
	if e != null:
		e.power += delta


func set_power(w: WorldState, idx: int, value: int) -> void:
	var e := emp(w, idx)
	if e != null:
		e.power = value


# ── Country.cs 复杂方法镜像 ──

## Country.JoinAllOurAlliances（Country.cs:42-87）
func join_all_our_alliances(w: WorldState, country: CountryData, yes: bool) -> void:
	if country == null:
		return
	var player := w.get_player_country()
	if player == null:
		return
	var sid := country.原版序号
	var flag_a: bool = sid == 41 or sid == 42 or sid == 52 \
		or (sid >= 56 and sid <= 68) \
		or (sid == 99 and parts(country, 0)) or (sid == 100 and parts(country, 0)) \
		or (sid >= 106 and sid <= 108) \
		or (sid >= 112 and sid <= 133 and sid != 128) \
		or sid == 150 or sid == 153 or sid == 155 or sid == 158
	var flag_b: bool = sid == 48 or (sid >= 71 and sid <= 83) \
		or (sid >= 138 and sid <= 149) or sid == 152
	if player.has_tag("okb") and not flag_a and not flag_b:
		country.set_tag("okb", yes)
	elif player.has_tag("ovd") and not flag_a and not flag_b:
		country.set_tag("ovd", yes)
	elif player.has_tag("seato"):
		country.set_tag("seato", yes)
	if player.has_tag("econ"):
		country.set_tag("econ", yes)
	elif player.has_tag("sev"):
		country.set_tag("sev", yes)
	elif player.has_tag("asean"):
		country.set_tag("asean", yes)
	var gkchp := fl(w, "is_gkchp")
	if ev(w, 548) and player.has_tag("rim") \
			and (((country.government == 1 or country.sub_government == 0) and not gkchp)
			or (gkchp and (country.sub_government == 0 or country.sub_government == 2
				or country.sub_government == 17 or country.sub_government == 10))) \
			and country.sub_government != 16 and country.sub_government != 18 \
			and not country.has_tag("sev") and not country.has_tag("ovd") \
			and country.has_tag("亲中") and country.puppet_of < 0:
		country.set_tag("rim", yes)
	if flag_a and (country.government == 1 or country.sub_government == 0) and ev(w, 500):
		country.set_tag("au", true)


## Country.EstablishGosstroy（Country.cs:35-40）
func establish_gosstroy(w: WorldState, country: CountryData, state_idx: int) -> void:
	var src := c(w, state_idx)
	if country == null or src == null:
		return
	country.government = src.government
	country.sub_government = src.sub_government


## GameState.IsSocialism / IsAuthoritarianism 已由 WorldState 提供，这里只做便捷包装。

## GameState.ChineseSubGosstroy（GameState.cs:4934-5054，逐分支忠实镜像）。
func chinese_sub_gosstroy(w: WorldState) -> int:
	var player := w.get_player_country()
	if player == null:
		return -1
	if player.government == 0:
		if res(w, 674) == 2:
			return 9
		if player.has_tag("nazimao"):
			return 22
		if ev(w, 912) and res(w, 912) == 0:
			return 19
		if d(w, 15) == 8:
			return 20
		if ev(w, 503) and res(w, 503) == 0:
			return 10
		if d(w, 14) <= 2 and d(w, 16) < 13 and d(w, 6) >= 700 \
				and d(w, 15) < 8 and mod(w, 6) and mod(w, 3):
			return 0
		if (d(w, 16) >= 13 and d(w, 31) >= 700 and not mod(w, 6)) or mod(w, 38):
			return 9
		if d(w, 16) <= 13 and d(w, 31) >= 700 and d(w, 6) >= 700 \
				and (mod(w, 6) or mod(w, 3)):
			return 10
		if d(w, 16) >= 13 and not mod(w, 6):
			return 7
		return 13
	if player.government == 1:
		if mod(w, 49):
			return 18
		if mod(w, 6) and mod(w, 3) and d(w, 15) <= 7 \
				and d(w, 16) <= 12 and d(w, 50) <= 25:
			return 17
		if d(w, 14) == 1 and not mod(w, 6) and d(w, 50) <= 26:
			return 16
		if d(w, 16) < 13 and d(w, 17) >= 17 and d(w, 14) == 1 and d(w, 50) <= 26:
			return 2
		return 1
	if player.government == 2:
		if mod(w, 40):
			return 8
		if d(w, 14) >= 2 and d(w, 16) >= 13 and d(w, 6) <= 700 \
				and d(w, 15) >= 8 and d(w, 17) >= 18 and not player.has_tag("ovd"):
			return 14
		if d(w, 14) <= 3 and d(w, 16) >= 12 and d(w, 16) <= 13 \
				and d(w, 6) >= 300 and d(w, 18) > 21 and d(w, 31) >= 700:
			return 11
		if d(w, 14) <= 3 and d(w, 16) <= 14 and d(w, 6) >= 500 \
				and d(w, 16) > 11 and d(w, 31) >= 400:
			return 8
		if d(w, 14) <= 3 and d(w, 16) <= 13 and d(w, 17) > 17:
			return 3
		if d(w, 15) <= 8 and (d(w, 16) == 13 or d(w, 16) == 12) \
				and d(w, 31) < 700 and not mod(w, 3) and d(w, 17) >= 17:
			return 21
		return 15
	if player.government != 3:
		return 13
	if d(w, 16) <= 13 and d(w, 6) >= 500:
		return 4
	if (d(w, 15) <= 8 and d(w, 17) <= 18) or d(w, 31) >= 700:
		return 12
	if d(w, 16) > 13 and d(w, 6) < 700:
		return 6
	return 5


## GameState.GetSubGosstory（GameState.cs:7409-7433）。
func get_sub_gosstory(w: WorldState) -> int:
	if d(w, 14) <= 2 and d(w, 16) < 13 and d(w, 6) >= 700 and d(w, 15) < 8:
		return 0
	if d(w, 14) <= 3 and d(w, 16) <= 13 and d(w, 6) >= 500:
		return _rng(w, 1, 4)
	if d(w, 14) >= 2 and d(w, 16) >= 13 and d(w, 6) <= 700 \
			and d(w, 15) >= 8 and d(w, 17) >= 18 \
			and not has(c(w, 1), "ovd"):
		return _rng(w, 4, 7)
	if not has(c(w, 1), "sev"):
		return 7
	return 8


## GameState.AfricanSubGosstroy（GameState.cs:5057-5140+；末尾缺省 13）。
func african_sub_gosstroy(w: WorldState, gov_type: int) -> int:
	if gov_type != 0:
		if gov_type == 1:
			var n := _rng(w, 0, 3)
			if n == 0: return 1
			if n == 1: return 2
			if n == 2: return 16
		elif gov_type == 2:
			var n2 := _rng(w, 0, 5)
			if n2 == 0: return 3
			if n2 == 1: return 8
			if n2 == 2: return 11
			if n2 == 3: return 14
			if n2 == 4: return 15
		elif gov_type == 3:
			var n3 := _rng(w, 0, 4)
			if n3 == 0: return 4
			if n3 == 1: return 5
			if n3 == 2: return 6
			if n3 == 3: return 12
		return 13
	var n4 := _rng(w, 0, 6)
	if n4 == 0: return 0
	if n4 == 1: return 7
	if n4 == 2: return 9
	if n4 == 3: return 10
	return 13


## GameState.WhatToDevelop（GameState.cs:7435-7490 精确版）。
func what_to_develop(_w: WorldState, country: CountryData) -> void:
	if country == null:
		return
	var sub_id := country.sub_government
	if sub_id <= 9:
		var n := absi(4 - sub_id)
		if country.level_of_instability > (6 - n) * 20:
			@warning_ignore("integer_division")
			country.level_of_instability -= country.level_of_instability / 25
			country.level_of_development -= 1
		else:
			@warning_ignore("integer_division")
			country.level_of_instability += ((6 - n) * 20 - country.level_of_instability) / 5
			country.level_of_development += 1
	else:
		var n2 := absi(13 - sub_id)
		if country.level_of_instability > (6 - n2) * 20:
			@warning_ignore("integer_division")
			country.level_of_instability -= country.level_of_instability / 25
			country.level_of_development -= 1
		else:
			@warning_ignore("integer_division")
			country.level_of_instability += ((6 - n2) * 20 - country.level_of_instability) / 5
			country.level_of_development += 1
	if country.level_of_instability > 100:
		country.level_of_instability = 100
	elif country.level_of_instability < 0:
		country.level_of_instability = 0
	elif country.level_of_instability < 10:
		country.level_of_instability += 1
	if country.level_of_development > 100:
		country.level_of_development = 100
	elif country.level_of_development < 0:
		country.level_of_development = 0
	elif country.level_of_development > 90:
		country.level_of_development -= 1
	country.level_of_instability -= country.government


# ── 通用工具 ──

## 原版 UnityEngine.Random.Range(min, max)（max 不含）。
func _rng(w: WorldState, min_value: int, max_value: int) -> int:
	var rng := w.ensure_rng()
	if max_value <= min_value:
		return min_value
	return rng.randi_range(min_value, max_value - 1)


## 工厂：条件字典（与 国家面板.gd 的 _cond 同构）。
func cond(desc: String, check: Callable) -> Dictionary:
	return {"desc": desc, "check": check}


## 工厂：动作定义统一出口。
func make_def(action_caption: String, opis: String, conditions: Array, effect: Callable) -> Dictionary:
	return {
		"caption": action_caption,
		"opis": opis,
		"conditions": conditions,
		"effect": effect,
		"dormant": false,
	}
