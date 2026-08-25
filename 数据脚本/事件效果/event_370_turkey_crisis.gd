extends "res://数据脚本/event_script_base.gd"

const TXT_370_644 := "event.script.event_370_turkey_crisis.c0"
const TXT_370_645 := "event.script.event_370_turkey_crisis.c1"
const TXT_370_674 := "event.script.turkey_crisis.txt_370_674"
const TXT_370_675 := "event.script.turkey_crisis.txt_370_675"
const TXT_370_646 := "event.script.event_370_turkey_crisis.c2"
const TXT_370_592 := "event.script.event_370_turkey_crisis.c3"
const TXT_370_593 := "event.script.event_370_turkey_crisis.c4"
const TXT_370_594 := "event.script.event_370_turkey_crisis.c5"
const TXT_370_566 := "event.script.event_370_turkey_crisis.c6"
const TXT_370_567 := "event.script.event_370_turkey_crisis.c7"
const TXT_370_608 := "event.script.event_370_turkey_crisis.c8"
const TXT_370_647 := "event.script.event_370_turkey_crisis.c9"
const TXT_370_658 := "event.script.event_370_turkey_crisis.c10"
const TXT_370_659 := "event.script.event_370_turkey_crisis.c11"
const TXT_370_648 := "event.script.event_370_turkey_crisis.c12"
const TXT_370_649 := "event.script.event_370_turkey_crisis.c13"
const TXT_370_661 := "event.script.event_370_turkey_crisis.c14"
const TXT_370_660 := "event.script.event_370_turkey_crisis.c15"
const TXT_370_650 := "event.script.event_370_turkey_crisis.c16"
const TXT_370_681 := "event.script.event_370_turkey_crisis.c17"
const TXT_370_662 := "event.script.event_370_turkey_crisis.c18"
const TXT_370_651 := "event.script.event_370_turkey_crisis.c19"
const TXT_370_676 := "event.script.event_370_turkey_crisis.c20"
const TXT_370_677 := "event.script.event_370_turkey_crisis.c21"
const TXT_370_663 := "event.script.event_370_turkey_crisis.c22"
const TXT_370_664 := "event.script.event_370_turkey_crisis.c23"
const TXT_370_665 := "event.script.event_370_turkey_crisis.c24"
const TXT_370_666 := "event.script.event_370_turkey_crisis.c25"
const TXT_370_667 := "event.script.event_370_turkey_crisis.c26"
const TXT_370_668 := "event.script.event_370_turkey_crisis.c27"
const TXT_370_669 := "event.script.event_370_turkey_crisis.c28"
const TXT_370_652 := "event.script.event_370_turkey_crisis.c29"
const TXT_370_653 := "event.script.event_370_turkey_crisis.c30"
const TXT_370_654 := "event.script.event_370_turkey_crisis.c31"
const TXT_370_655 := "event.script.event_370_turkey_crisis.c32"
const TXT_370_680 := "event.script.event_370_turkey_crisis.c33"
const TXT_370_679 := "event.script.event_370_turkey_crisis.c34"
const TXT_370_656 := "event.script.event_370_turkey_crisis.c35"
const TXT_370_657 := "event.script.event_370_turkey_crisis.c36"
const TXT_370_673 := "event.script.event_370_turkey_crisis.c37"
const TXT_370_670 := "event.script.event_370_turkey_crisis.c38"
const TXT_370_671 := "event.script.event_370_turkey_crisis.c39"
const TXT_370_672 := "event.script.event_370_turkey_crisis.c40"


## 原作 Event370.cs：土耳其危机（1984.12）。启动 ingamewars 10/11/12，
## 战争 12 结算会写伊朗 puppet_of=84（GameState.cs:676-695）。
## 结果文案按项目英文风格写摘要；数值效果逐项对齐 ResultsOfEvents。


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	if event_def.event_id != "event_370":
		return
	var d2 := p_ws
	var syria := p_ws.get_country_by_legacy_index(35)
	var iraq := p_ws.get_country_by_legacy_index(14)
	var iran := p_ws.get_country_by_legacy_index(8)
	var syria_neutral := syria != null and not syria.has_tag("亲苏") and not syria.has_tag("oar") \
		and not syria.has_tag("亲美") and not syria.has_tag("okb") and not syria.has_tag("seato")
	var iraq_neutral := iraq != null and not iraq.has_tag("亲苏") and not iraq.has_tag("oar") \
		and not iraq.has_tag("okb") and not iraq.has_tag("ovd") and not iraq.has_tag("seato")
	var iran_neutral := iran != null and not iran.has_tag("亲美") and not iran.has_tag("okb") \
		and not iran.has_tag("ovd") and not iran.has_tag("seato")
	var neutral_count := 0
	if syria_neutral:
		neutral_count += 1
	if iraq_neutral:
		neutral_count += 1
	if iran_neutral:
		neutral_count += 1
	var war3_going := p_ws.wars.size() > 3 and p_ws.wars[3] != null and p_ws.wars[3].is_going
	var desc := tr(TXT_370_645)
	desc = desc.replace("{1}", tr(TXT_370_670) if syria_neutral else "")
	desc = desc.replace("{2}", tr(TXT_370_671) if iraq_neutral else "")
	desc = desc.replace("{3}", tr(TXT_370_672) if iran_neutral else "")
	desc = desc.replace("{4}", tr(TXT_370_673) if war3_going else "")
	desc = desc.replace("{5}", tr(TXT_370_674) if neutral_count == 1 else tr(TXT_370_675))
	event_def.description = desc
	if event_def.options.size() < 5:
		return
	var budget_sum: int = d2.budget + d2.reserve
	var agents: int = d2.agents
	var army: int = d2.army
	var usa := p_ws.get_country_by_legacy_index(51)
	var greece := p_ws.get_country_by_legacy_index(45)
	var opt := event_def.options
	# 选项 0
	opt[0].text = tr(TXT_370_646).replace("{0}", tr(TXT_370_592)).replace("{1}", tr(TXT_370_593)).replace("{2}", tr(TXT_370_594))
	if budget_sum >= 250 and agents >= 150 and army >= 400:
		opt[0].disabled_text = ""
	elif budget_sum < 200:
		opt[0].disabled_text = tr(TXT_370_566).replace("{0}", "20")
	elif agents < 150:
		opt[0].disabled_text = tr(TXT_370_567).replace("{0}", "15")
	else:
		opt[0].disabled_text = tr(TXT_370_608).replace("{0}", "40")
	# 选项 1
	opt[1].text = tr(TXT_370_647)
	if usa != null and usa.has_tag("对华贸易") and usa.development > 0:
		opt[1].disabled_text = ""
	elif usa == null or not usa.has_tag("对华贸易"):
		opt[1].disabled_text = tr(TXT_370_658)
	else:
		opt[1].disabled_text = tr(TXT_370_659)
	# 选项 2
	opt[2].text = tr(TXT_370_648)
	# 选项 3
	opt[3].text = tr(TXT_370_649).replace("{0}", tr(TXT_370_592)).replace("{2}", tr(TXT_370_594))
	var xinjiang := d2.xinjiang_policy > 0 if d2.size() > W.I_XINJIANG_POLICY else false
	var tibet := d2.tibet_policy > 0 if d2.size() > W.I_TIBET_POLICY else false
	if (xinjiang or tibet) and budget_sum >= 150 and army >= 200 and d2.territory_policy == 20:
		opt[3].disabled_text = ""
	elif not xinjiang and not tibet:
		opt[3].disabled_text = tr(TXT_370_661)
	elif d2.territory_policy == 20:
		opt[3].disabled_text = tr(TXT_370_660)
	elif budget_sum < 150:
		opt[3].disabled_text = tr(TXT_370_566).replace("{0}", "15")
	else:
		opt[3].disabled_text = tr(TXT_370_608).replace("{0}", "20")
	# 选项 4
	opt[4].text = tr(TXT_370_650)
	if d2.diplomatic_reputation < 800 and greece != null and greece.has_tag("nato"):
		opt[4].disabled_text = ""
	elif greece == null or not greece.has_tag("nato"):
		opt[4].disabled_text = tr(TXT_370_681)
	else:
		opt[4].disabled_text = tr(TXT_370_662)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	_event_370(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_370(option_index: int, context: Dictionary) -> void:
	# Event370.cs:112-113：两伊战争(war3)若进行中则停战。
	if ws.wars.size() > 3 and ws.wars[3] != null:
		ws.wars[3].is_going = false
	# Event370.cs:114-126：中立国判定与 data.oil_price 增量。
	var syria_neutral := _syria_neutral()
	var iraq_neutral := _iraq_neutral()
	var iran_neutral := _iran_neutral()
	if iraq_neutral and d.size() > 143:
		d.oil_price += 3
	if iran_neutral and d.size() > 143:
		d.oil_price += 3
	var war3_bonus := 0
	if ws.wars.size() > 3 and ws.wars[3] != null and ws.wars[3].is_going:
		war3_bonus = 150

	match option_index:
		0:
			_result_0(context, syria_neutral, iraq_neutral, iran_neutral, war3_bonus)
		1:
			_result_1(context, syria_neutral, iraq_neutral, iran_neutral, war3_bonus)
		2:
			_result_2(context, syria_neutral, iraq_neutral, iran_neutral, war3_bonus)
		3:
			_result_3(context, syria_neutral, iraq_neutral, iran_neutral, war3_bonus)
		4:
			_result_4(context, syria_neutral, iraq_neutral, iran_neutral, war3_bonus)


func _result_0(
		context: Dictionary, syria_neutral: bool, iraq_neutral: bool,
		iran_neutral: bool, war3_bonus: int
) -> void:
	_turkey_torg_false()
	_add_data(W.I_DIPLO, 20)
	_add_data(W.I_THOUGHT_FREEDOM, -50)
	_add_empire_relation(EmpireData.USA, -300)
	_add_empire_relation(EmpireData.USSR, 100)
	_add_data(W.I_BUDGET, -250)
	_add_data(W.I_AGENTS, -150)
	_add_data(W.I_ARMY, -400)
	_add_data(W.I_PARTY_SUPPORT, 50 if _faction_0_1_2_leading() else -50)
	_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, false, 0)
	context["result_text"] = tr(TXT_370_651)


func _result_1(
		context: Dictionary, syria_neutral: bool, iraq_neutral: bool,
		iran_neutral: bool, war3_bonus: int
) -> void:
	_turkey_torg_false()
	if ws.influence_prc > _usa_power():
		# Event370.cs:169-180
		_turkey_leave_nato_and_usa()
		_add_data(W.I_PARTY_SUPPORT, 100)
		_add_empire_relation(EmpireData.USA, -100)
		_add_empire_relation(EmpireData.USSR, -100)
		_add_data(W.I_DIPLO, -20)
		_add_empire_power(EmpireData.USA, -50)
		ws.influence_prc += 20
		_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, true, 0)
		context["result_text"] = tr(TXT_370_652)
	else:
		# Event370.cs:184-198
		_add_data(W.I_PARTY_SUPPORT, -300)
		_add_empire_relation(EmpireData.USA, -500)
		_add_empire_relation(EmpireData.USSR, -100)
		_add_data(W.I_DIPLO, 20)
		_add_empire_power(EmpireData.USA, 50)
		ws.influence_prc -= 80
		_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, false, 0)
		context["result_text"] = tr(TXT_370_653)


func _result_2(
		context: Dictionary, syria_neutral: bool, iraq_neutral: bool,
		iran_neutral: bool, war3_bonus: int
) -> void:
	_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, false, 1)
	context["result_text"] = tr(TXT_370_654)


func _result_3(
		context: Dictionary, syria_neutral: bool, iraq_neutral: bool,
		iran_neutral: bool, war3_bonus: int
) -> void:
	_add_data(W.I_BUDGET, -150)
	_add_data(W.I_ARMY, -200)
	_add_data(W.I_PARTY_SUPPORT, 350)
	_add_empire_relation(EmpireData.USA, -250)
	_add_empire_relation(EmpireData.USSR, -250)
	ws.influence_prc -= 50
	_add_data(W.I_DIPLO, 100)
	_reward_separatist_states()
	_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, false, 1)
	var region := tr(TXT_370_680)
	if d.size() > W.I_XINJIANG_POLICY and d.size() > W.I_TIBET_POLICY:
		if d.xinjiang_policy > 0 and d.tibet_policy > 0:
			region = tr(TXT_370_680)
		elif d.tibet_policy > 0:
			region = tr(TXT_370_679)
		else:
			region = tr(TXT_370_680)
	context["result_text"] = tr(TXT_370_655).replace("{1}", region)


func _result_4(
		context: Dictionary, syria_neutral: bool, iraq_neutral: bool,
		iran_neutral: bool, war3_bonus: int
) -> void:
	_turkey_torg_false()
	if ws.influence_prc > _usa_power() + _ussr_power() or ws.influence_prc > 800:
		# Event370.cs:306-317
		ws.influence_prc += 50
		_add_data(W.I_DIPLO, -50)
		_add_data(W.I_PARTY_SUPPORT, -300)
		_add_empire_relation(EmpireData.USA, -100)
		_add_empire_relation(EmpireData.USSR, -100)
		if d.size() > 126:
			d.turkish_straits_crisis = 1
		_turkey_leave_nato_and_usa()
		_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, true, 2)
		context["result_text"] = tr(TXT_370_656)
	else:
		# Event370.cs:327-340
		ws.influence_prc -= 10
		_add_empire_power(EmpireData.USA, 50)
		_add_empire_power(EmpireData.USSR, 50)
		_add_data(W.I_PARTY_SUPPORT, -300)
		_add_empire_relation(EmpireData.USA, -100)
		_add_empire_relation(EmpireData.USSR, -100)
		_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, false, 1)
		context["result_text"] = tr(TXT_370_657)


func _syria_neutral() -> bool:
	var syria := ws.get_country_by_legacy_index(35)
	if syria == null:
		return false
	return not syria.has_tag("亲苏") and not syria.has_tag("oar") \
		and not syria.has_tag("亲美") and not syria.has_tag("okb") \
		and not syria.has_tag("seato")


func _iraq_neutral() -> bool:
	var iraq := ws.get_country_by_legacy_index(14)
	if iraq == null:
		return false
	return not iraq.has_tag("亲苏") and not iraq.has_tag("oar") \
		and not iraq.has_tag("okb") and not iraq.has_tag("ovd") \
		and not iraq.has_tag("seato")


func _iran_neutral() -> bool:
	var iran := ws.get_country_by_legacy_index(8)
	if iran == null:
		return false
	return not iran.has_tag("亲美") and not iran.has_tag("okb") \
		and not iran.has_tag("ovd") and not iran.has_tag("seato")


func _faction_0_1_2_leading() -> bool:
	if ws.factions == null:
		return false
	for i in range(3):
		if i >= ws.factions.size() or ws.factions[i] == null:
			continue
		var leader_index: int = ws.factions[i].leader_index
		if leader_index == WorldFactory.LEADER_POSITION_SENTINEL:
			return true
		if leader_index >= 0 and leader_index < ws.politicians.size() \
				and ws.politicians[leader_index] != null:
			return true
	return false


## 启动中立国战争。style:
##   0 = Event370 result0/1 美国支持土耳其，非亲中胜利（infl 组合按分支传入 base）
##   1 = 美国支持土耳其的常规进攻档
##   2 = 美苏共同支持防守方
func _start_neutral_wars(
		syria_neutral: bool, iraq_neutral: bool, iran_neutral: bool,
		war3_bonus: int, _soviet_only: bool, style: int
) -> void:
	var infl_base := 500
	match style:
		0:
			infl_base = 400 if _soviet_only else 500
		1:
			infl_base = 600
		2:
			infl_base = 300
	var usa_side := 0
	if style == 2:
		usa_side = GameConstants.WarSide.SIDE2          # Event370 result4 分支：AmericanSupportDefender
	elif style == 0 and _soviet_only:
		usa_side = GameConstants.WarSide.NONE         # Event370 result1 亲中胜利分支：仅 SovietSupportDefender
	var ussr_side := 1
	if syria_neutral:
		game.start_war(10, tr(TXT_370_664), tr(TXT_370_665), infl_base, 1000 - infl_base, usa_side, ussr_side)
	if iraq_neutral:
		var infl1 := infl_base + war3_bonus
		game.start_war(11, tr(TXT_370_664), tr(TXT_370_667), infl1, 1000 - infl1, usa_side, ussr_side)
	if iran_neutral:
		var infl1 := infl_base + war3_bonus
		game.start_war(12, tr(TXT_370_664), tr(TXT_370_669), infl1, 1000 - infl1, usa_side, ussr_side)


func _turkey_torg_false() -> void:
	var turkey := ws.get_country_by_legacy_index(84)
	if turkey != null:
		turkey.set_tag("对华贸易", false)


func _turkey_leave_nato_and_usa() -> void:
	var turkey := ws.get_country_by_legacy_index(84)
	if turkey == null:
		return
	turkey.set_tag("亲美", false)
	turkey.set_tag("nato", false)


func _reward_separatist_states() -> void:
	if d.size() > W.I_XINJIANG_POLICY and d.xinjiang_policy > 0:
		var uyghuristan := ws.get_country_by_legacy_index(70)
		if uyghuristan != null:
			uyghuristan.development = 100
			uyghuristan.set_tag("对华贸易", true)
			uyghuristan.set_tag("亲中", true)
			uyghuristan.set_tag("亲美", false)
			uyghuristan.set_tag("亲苏", false)
	if d.size() > W.I_TIBET_POLICY and d.tibet_policy > 0:
		var tibet := ws.get_country_by_legacy_index(69)
		if tibet != null:
			tibet.development = 100
			tibet.set_tag("对华贸易", true)
			tibet.set_tag("亲中", true)
			tibet.set_tag("亲美", false)
			tibet.set_tag("亲苏", false)


func _usa_power() -> int:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		return ws.empires[EmpireData.USA].power
	return 0


func _ussr_power() -> int:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		return ws.empires[EmpireData.USSR].power
	return 0


func _add_data(index: int, delta: int) -> void:
	if index >= 0 and index < d.size():
		d.add_data_by_index(index, delta)


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		d.usa_relations = ws.empires[EmpireData.USA].relations
		d.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		d.ussr_relations = ws.empires[EmpireData.USSR].relations
		d.soviet_influence = ws.empires[EmpireData.USSR].power



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_370_turkish_crisis_1984.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_370",
	"num": 370,
	"priority": 182,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_370_turkey_crisis.gd",
	"trigger": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 9, "target": "84"}, {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "35"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "oar", "target": "35"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲美", "target": "35"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "okb", "target": "35"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "seato", "target": "35"}]}]}, {"t": "ALL", "c": [{"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "14"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "oar", "target": "14"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "okb", "target": "14"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "ovd", "target": "14"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "seato", "target": "14"}]}]}, {"t": "ALL", "c": [{"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲美", "target": "8"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "okb", "target": "8"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "ovd", "target": "8"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "seato", "target": "8"}]}]}]}, {"t": "NOT", "c": [{"t": "WAR_ACTIVE", "v": 9}]}, {"t": "DATE_AFTER", "key": "1984.12.21"}],
	"options": [{"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_SUM_AT_LEAST", "v": 250, "keys": ["budget", "money_reserve"]}, {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 150}, {"t": "RESOURCE_AT_LEAST", "key": "army", "v": 400}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "COUNTRY_HAS_TAG", "key": "对华贸易", "target": "51"}, {"t": "COUNTRY_FIELD_AT_LEAST", "key": "development", "v": 1, "target": "51"}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "ANY", "c": [{"t": "RESOURCE_AT_LEAST", "key": "xinjiang_policy", "v": 1}, {"t": "RESOURCE_AT_LEAST", "key": "tibet_policy", "v": 1}]}, {"t": "RESOURCE_SUM_AT_LEAST", "v": 150, "keys": ["budget", "money_reserve"]}, {"t": "RESOURCE_AT_LEAST", "key": "army", "v": 200}, {"t": "RESOURCE_EQUALS", "key": "territorial_policy", "v": 20}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "diplo", "v": 799}, {"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "45"}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
