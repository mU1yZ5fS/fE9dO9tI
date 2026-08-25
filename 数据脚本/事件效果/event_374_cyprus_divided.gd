extends "res://数据脚本/event_script_base.gd"

const TXT_374_DESC := "event.script.event_374_cyprus_divided.c0"
const TXT_374_OPT0 := "event.script.event_374_cyprus_divided.c1"
const TXT_374_OPT1 := "event.script.event_374_cyprus_divided.c2"
const TXT_374_OPT1_DIS := "event.script.event_374_cyprus_divided.c3"
const TXT_374_OPT2 := "event.script.event_374_cyprus_divided.c4"
const TXT_374_OPT2_DIS := "event.script.event_374_cyprus_divided.c5"
const TXT_374_OPT3 := "event.script.event_374_cyprus_divided.c6"
const TXT_374_OPT3_DIS := "event.script.event_374_cyprus_divided.c7"
const TXT_374_OPT4 := "event.script.event_374_cyprus_divided.c8"
const TXT_374_R1_FAIL := "event.script.event_374_cyprus_divided.c9"
const TXT_374_R1_OK := "event.script.event_374_cyprus_divided.c10"
const TXT_374_R1_UK := "event.script.event_374_cyprus_divided.c11"
const TXT_374_R1_OK2 := "event.script.event_374_cyprus_divided.c12"
const TXT_374_R2_OK := "event.script.event_374_cyprus_divided.c13"
const TXT_374_R2_LEAVE := "event.script.event_374_cyprus_divided.c14"
const TXT_374_R2_WTO := "event.script.event_374_cyprus_divided.c15"
const TXT_374_R2_NATO := "event.script.event_374_cyprus_divided.c16"
const TXT_374_R2_DOT := "event.script.event_374_cyprus_divided.c17"
const TXT_374_R2_EMPIRE := "event.script.event_374_cyprus_divided.c18"
const TXT_374_R2_FAIL := "event.script.event_374_cyprus_divided.c19"
const TXT_374_R2_WTO2 := "event.script.event_374_cyprus_divided.c20"
const TXT_374_R2_NATO2 := "event.script.event_374_cyprus_divided.c21"
const TXT_374_R2_FAIL2 := "event.script.event_374_cyprus_divided.c22"
const TXT_374_R3_OK := "event.script.event_374_cyprus_divided.c23"
const TXT_374_R3_FAIL := "event.script.event_374_cyprus_divided.c24"
const TXT_374_R4 := "event.script.event_374_cyprus_divided.c25"
const TXT_374_R0_OK_LEFT := "event.script.event_374_cyprus_divided.c26"
const TXT_374_R0_OK_RIGHT := "event.script.event_374_cyprus_divided.c27"
const TXT_374_R0_UK_LEFT := "event.script.event_374_cyprus_divided.c28"
const TXT_374_R0_UK_RIGHT := "event.script.event_374_cyprus_divided.c29"
const TXT_374_R0_UK_OTHER := "event.script.event_374_cyprus_divided.c30"
const TXT_374_R0_FAIL_GREAT_IDEAL := "event.script.event_374_cyprus_divided.c31"
const TXT_374_R0_FAIL_AUTH := "event.script.event_374_cyprus_divided.c32"
const TXT_374_R0_FAIL_OTHER := "event.script.event_374_cyprus_divided.c33"


## 原作 Event374.cs：一分为二的苦柠檬（塞浦路斯问题）。
## 只移植数值/国家状态效果；长文本用英文摘要。
## 关键联锁：result2 在伊拉克(14)/伊朗(8)/叙利亚(35) 均 puppet_of==84 时
## 置 allcountries[84].parts[5]（概览.gd 伊朗页「大土耳其的一部分」分支）。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	_event_374(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_374(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_result_0(context)
		1:
			_result_1(context)
		2:
			_result_2(context)
		3:
			_result_3(context)
		4:
			_result_4(context)


func _result_0(context: Dictionary) -> void:
	var cyprus := _cyprus()
	if _greece_progressive() and _turkey_progressive() and ws.influence_prc >= 500 \
		and cyprus != null and (cyprus.government == GameConstants.Government.REFORMIST or cyprus.government == GameConstants.Government.LIBERAL or cyprus.sub_government == GameConstants.SubGovernment.SOVIET_STYLE):
		# Event374.cs:192-274 成功联邦路径
		_set_data127(100)
		if cyprus != null:
			cyprus.parts.resize(1)
			cyprus.parts[0] = true
			if cyprus.government == GameConstants.Government.REFORMIST or cyprus.sub_government == GameConstants.SubGovernment.SOVIET_STYLE:
				_leave_alliances(cyprus)
				cyprus.sub_government = GameConstants.SubGovernment.PRAGMATIST
				_copy_soc_eu_from_spain(cyprus)
			else:
				cyprus.sub_government = GameConstants.SubGovernment.MODERATE
			if not cyprus.内战中:
				cyprus.set_tag("对华贸易", true)
		ws.influence_prc += 30
		if cyprus != null and (cyprus.government == GameConstants.Government.REFORMIST or cyprus.sub_government == GameConstants.SubGovernment.SOVIET_STYLE):
			context["result_text"] = tr(TXT_374_R0_OK_LEFT) + _uk_append_text()
		else:
			context["result_text"] = tr(TXT_374_R0_OK_RIGHT) + _uk_append_text()
	else:
		_set_data127(1)
		if cyprus != null and cyprus.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST:
			context["result_text"] = tr(TXT_374_R0_FAIL_GREAT_IDEAL)
		elif cyprus != null and ws.is_authoritarian(cyprus):
			context["result_text"] = tr(TXT_374_R0_FAIL_AUTH)
		else:
			context["result_text"] = tr(TXT_374_R0_FAIL_OTHER)


func _result_1(context: Dictionary) -> void:
	var turkey := _turkey()
	if not _is_socialism_or_gov2(turkey) and (turkey == null or turkey.government != GameConstants.Government.REFORMIST):
		# Event374.cs:64-67
		_set_data127(1)
		context["result_text"] = tr(TXT_374_R1_FAIL)
		return
	# Event374.cs:68-91
	_set_data127(100)
	var greece := _greece()
	if greece != null:
		greece.parts.resize(1)
		greece.parts[0] = true
	var cyprus := _cyprus()
	if cyprus != null and not cyprus.内战中:
		cyprus.set_tag("对华贸易", true)
		if greece != null:
			greece.set_tag("对华贸易", true)
	ws.influence_prc += 10
	var uk := _uk()
	var r1 := tr(TXT_374_R1_OK)
	if uk != null and ws.is_socialism(uk, false) and uk.government != GameConstants.Government.REFORMIST:
		r1 += tr(TXT_374_R1_UK)
	r1 += tr(TXT_374_R1_OK2)
	context["result_text"] = r1


func _result_2(context: Dictionary) -> void:
	var cyprus := _cyprus()
	if cyprus != null and cyprus.puppet_of == 84:
		# Event374.cs:75-120 土耳其并岛路径
		_set_data127(100)
		cyprus.parts.resize(1)
		cyprus.parts[0] = true
		cyprus.chinese_name = "塞浦路斯土耳其联邦"
		_leave_alliances(cyprus)
		cyprus.government = GameConstants.Government.LIBERAL
		cyprus.sub_government = GameConstants.SubGovernment.MODERATE
		cyprus.puppet_of = 84
		ws.influence_prc += 10
		_greece_reaction_to_turkish_cyprus()
		var iraq := ws.get_country_by_legacy_index(14)
		var iran := ws.get_country_by_legacy_index(8)
		var syria := ws.get_country_by_legacy_index(35)
		var all_turkish := iraq != null and iraq.puppet_of == 84 \
			and iran != null and iran.puppet_of == 84 \
			and syria != null and syria.puppet_of == 84
		if all_turkish:
			var turkey := _turkey()
			if turkey != null:
				turkey.parts.resize(6)
				turkey.parts[5] = true
				turkey.chinese_name = "大土耳其"
		var r2 := tr(TXT_374_R2_OK)
		var greece2 := _greece()
		if greece2 != null and (greece2.has_tag("econ") or greece2.has_tag("okb") or greece2.has_tag("亲中")):
			r2 += tr(TXT_374_R2_LEAVE)
			if _greece_progressive() and _ussr_ovd():
				r2 += tr(TXT_374_R2_WTO)
			elif greece2 != null and (ws.is_authoritarian(greece2) or greece2.government == GameConstants.Government.LIBERAL) and _usa_nato():
				r2 += tr(TXT_374_R2_NATO)
			r2 += tr(TXT_374_R2_DOT)
		if all_turkish:
			r2 += tr(TXT_374_R2_EMPIRE)
		context["result_text"] = r2
	else:
		# Event374.cs:122-144 未并岛
		_set_data127(1)
		if cyprus != null:
			cyprus.set_tag("亲中", false)
			cyprus.set_tag("对华贸易", false)
		_greece_reaction_to_turkish_cyprus(cyprus)
		var r2c := tr(TXT_374_R2_FAIL)
		if _greece_progressive():
			r2c += tr(TXT_374_R2_WTO2)
		else:
			r2c += tr(TXT_374_R2_NATO2)
		r2c += tr(TXT_374_R2_FAIL2)
		context["result_text"] = r2c


func _result_3(context: Dictionary) -> void:
	if _greece_progressive() and _turkey_progressive():
		# Event374.cs:147-169
		var cyprus := _cyprus()
		if cyprus != null:
			if not cyprus.内战中:
				cyprus.set_tag("对华贸易", true)
			cyprus.parts.resize(1)
			cyprus.parts[0] = true
			_leave_alliances(cyprus)
			cyprus.government = GameConstants.Government.REFORMIST
			cyprus.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
			_copy_soc_eu_from_spain(cyprus)
		_set_data127(100)
		ws.influence_prc += 10
		context["result_text"] = tr(TXT_374_R3_OK)
	else:
		_set_data127(1)
		context["result_text"] = tr(TXT_374_R3_FAIL)


func _result_4(context: Dictionary) -> void:
	_set_data127(1)
	context["result_text"] = tr(TXT_374_R4)


func _greece_reaction_to_turkish_cyprus(cyprus_for_join: CountryData = null) -> void:
	var greece := _greece()
	var ussr := ws.get_country_by_legacy_index(7)
	var usa := ws.get_country_by_legacy_index(51)
	if greece != null and (greece.has_tag("econ") or greece.has_tag("okb") or greece.has_tag("亲中")):
		_leave_alliances(greece)
	if _greece_progressive() and ussr != null and ussr.has_tag("ovd"):
		var target := cyprus_for_join if cyprus_for_join != null else greece
		if target != null:
			target.set_tag("sev", true)
			target.set_tag("ovd", true)
	elif greece != null and (ws.is_authoritarian(greece) or greece.government == GameConstants.Government.LIBERAL) \
			and usa != null and usa.has_tag("nato"):
		var target := cyprus_for_join if cyprus_for_join != null else greece
		if target != null:
			target.set_tag("nato", true)


func _greece_progressive() -> bool:
	var greece := _greece()
	if greece == null:
		return false
	return ws.is_socialism(greece, true) or greece.government == GameConstants.Government.REFORMIST


func _turkey_progressive() -> bool:
	var turkey := _turkey()
	if turkey == null:
		return false
	return ws.is_socialism(turkey, true) or turkey.government == GameConstants.Government.REFORMIST


func _is_socialism_or_gov2(c: CountryData) -> bool:
	if c == null:
		return false
	return ws.is_socialism(c, true) or c.government == GameConstants.Government.REFORMIST


func _copy_soc_eu_from_spain(cyprus: CountryData) -> void:
	var spain := ws.get_country_by_legacy_index(85)
	if spain != null and spain.has_tag("soc_eu"):
		cyprus.set_tag("soc_eu", true)


func _set_data127(v: int) -> void:
	if d.size() > 127:
		d.turkish_route_result = v



func _cyprus() -> CountryData:
	return ws.get_country_by_legacy_index(94)


func _greece() -> CountryData:
	return ws.get_country_by_legacy_index(45)


func _turkey() -> CountryData:
	return ws.get_country_by_legacy_index(84)


func _uk() -> CountryData:
	return ws.get_country_by_legacy_index(92)


func _uk_append_text() -> String:
	var uk := _uk()
	if uk == null:
		return "\n" + tr(TXT_374_R0_UK_OTHER)
	if ws.is_socialism(uk, true) or uk.government == GameConstants.Government.REFORMIST:
		return "\n" + tr(TXT_374_R0_UK_LEFT)
	if uk.government == GameConstants.Government.LIBERAL:
		return "\n" + tr(TXT_374_R0_UK_RIGHT)
	return "\n" + tr(TXT_374_R0_UK_OTHER)

func _ussr_ovd() -> bool:
	var ussr := ws.get_country_by_legacy_index(7)
	return ussr != null and ussr.has_tag("ovd")


func _usa_nato() -> bool:
	var usa := ws.get_country_by_legacy_index(51)
	return usa != null and usa.has_tag("nato")


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		d.usa_relations = ws.empires[EmpireData.USA].relations
		d.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		d.ussr_relations = ws.empires[EmpireData.USSR].relations
		d.soviet_influence = ws.empires[EmpireData.USSR].power



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_374_cyprus_divided_again.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_374",
	"num": 374,
	"priority": 188,
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "COUNTRY_FIELD_EQUALS", "key": "cw", "target": "94"}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "COUNTRY_FIELD_EQUALS", "key": "cw", "v": 1, "target": "94"}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_EQUALS", "key": "political_line", "v": 2}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
