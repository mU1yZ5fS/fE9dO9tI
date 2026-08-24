extends "res://数据脚本/event_script_base.gd"

## 原作 Event127.cs：巴西复兴（5 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_PROPRC_YES := "event.script.event_127_brazil_revival.c0"
const TXT_PROPRC_NO := "event.script.event_127_brazil_revival.c1"
const TXT_R7 := "event.script.event_127_brazil_revival.c2"
const TXT_R8 := "event.script.event_127_brazil_revival.c3"
const TXT_R6 := "event.script.event_127_brazil_revival.c4"
const TXT_R3 := "event.script.event_127_brazil_revival.c5"




func _proprc_suffix(c: CountryData) -> String:
	return tr(TXT_PROPRC_YES) if c.has_tag("亲中") else tr(TXT_PROPRC_NO)

func _get_winner_in_america(country: CountryData, ideo: Array, sup: Array, coef: float, party: int) -> int:
	if country == null:
		return -1
	var sg := country.sub_government
	if sg >= 0 and sg < 10 and ideo[sg]:
		sup[sg] -= float(country.level_of_instability)
		sup[sg] += float(country.level_of_development)
	if sg - 1 >= 0 and sg - 1 < 10 and ideo[sg - 1]:
		sup[sg - 1] -= float(country.level_of_instability) / 4.0
		sup[sg - 1] += float(country.level_of_development) / 2.0
	if sg + 1 <= 9 and sg + 1 < 10 and ideo[sg + 1]:
		sup[sg + 1] -= float(country.level_of_instability) / 4.0
		sup[sg + 1] += float(country.level_of_development) / 2.0
	if not ideo[sg]:
		if sg >= 1 and sg <= 3:
			if ideo[1]:
				sup[1] -= float(country.level_of_instability) / 4.0
				sup[1] += float(country.level_of_development) / 2.0
			elif ideo[2]:
				sup[2] -= float(country.level_of_instability) / 4.0
				sup[2] += float(country.level_of_development) / 2.0
			elif ideo[3]:
				sup[3] -= float(country.level_of_instability) / 4.0
				sup[3] += float(country.level_of_development) / 2.0
		elif sg >= 4 and sg <= 6:
			if ideo[4]:
				sup[4] -= float(country.level_of_instability) / 4.0
				sup[4] += float(country.level_of_development) / 2.0
			elif ideo[5]:
				sup[5] -= float(country.level_of_instability) / 4.0
				sup[5] += float(country.level_of_development) / 2.0
			elif ideo[6]:
				sup[6] -= float(country.level_of_instability) / 4.0
				sup[6] += float(country.level_of_development) / 2.0
	if sg <= 3:
		if 9 - sg >= 0 and 9 - sg < 10 and ideo[9 - sg]:
			sup[9 - sg] += float(country.level_of_instability)
			sup[9 - sg] -= float(country.level_of_development)
		elif ideo[5]:
			sup[5] += float(country.level_of_instability)
			sup[5] -= float(country.level_of_development)
		elif ideo[4]:
			sup[4] -= float(country.level_of_instability) / 2.0
			sup[4] += float(country.level_of_development) / 2.0
		if 8 - sg >= 0 and 8 - sg < 10 and ideo[8 - sg]:
			sup[8 - sg] += float(country.level_of_instability) / 2.0
			sup[8 - sg] -= float(country.level_of_development) / 4.0
		if 10 - sg <= 9 and 10 - sg >= 0 and ideo[sg]:
			sup[10 - sg] += float(country.level_of_instability) / 2.0
			sup[10 - sg] -= float(country.level_of_development) / 4.0
	elif sg >= 6:
		if 9 - sg >= 0 and 9 - sg < 10 and ideo[9 - sg]:
			sup[9 - sg] += float(country.level_of_instability)
			sup[9 - sg] -= float(country.level_of_development)
		elif ideo[4]:
			sup[4] += float(country.level_of_instability)
			sup[4] -= float(country.level_of_development)
		elif ideo[5]:
			sup[5] -= float(country.level_of_instability) / 2.0
			sup[5] += float(country.level_of_development) / 2.0
		if 8 - sg >= 0 and 8 - sg < 10 and ideo[8 - sg]:
			sup[8 - sg] += float(country.level_of_instability) / 2.0
			sup[8 - sg] -= float(country.level_of_development) / 4.0
		if 10 - sg <= 9 and 10 - sg >= 0 and ideo[10 - sg]:
			sup[10 - sg] += float(country.level_of_instability) / 2.0
			sup[10 - sg] -= float(country.level_of_development) / 4.0
	elif sg == 4:
		for i in [0, 1, 2, 6, 7, 8, 9]:
			if ideo[i]:
				sup[i] += float(country.level_of_instability) / 2.0
				sup[i] -= float(country.level_of_development) / 4.0
	elif sg == 5:
		for i in [0, 1, 2, 6, 7, 8, 9]:
			if ideo[i]:
				sup[i] += float(country.level_of_instability) / 2.0
				sup[i] -= float(country.level_of_development) / 4.0
	if coef > 0.0:
		coef *= 3.0
		if party >= 0 and party < 10:
			if sup[party] > 1.0:
				sup[party] *= coef
			else:
				sup[party] += coef
	for i in sup.size():
		if i >= 0 and i < 10 and ideo[i]:
			sup[i] += 100.0
	var best := 0
	var best_val := -1e30
	for i in sup.size():
		if sup[i] > best_val:
			best_val = sup[i]
			best = i
	return best


func _make_ideo(active: Array) -> Array:
	var ideo: Array[bool] = []
	ideo.resize(10)
	for i in active:
		if i >= 0 and i < 10:
			ideo[i] = true
	return ideo


func _make_sup() -> Array:
	var sup: Array[float] = []
	sup.resize(10)
	for i in sup.size():
		sup[i] = 0.0
	return sup

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var brazil := ws.get_country_by_legacy_index(73)
	if brazil == null:
		return
	var opt := int(context.get("option_index", -1))
	var ideo := _make_ideo([7, 8, 6, 3])
	var sup := _make_sup()
	var winner := -1
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(brazil, ideo, sup, 2.0, 7)
			brazil.set_tag("亲中", winner == 7)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(brazil, ideo, sup, 2.0, 8)
			brazil.set_tag("亲中", winner == 8)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(brazil, ideo, sup, 2.0, 6)
			brazil.set_tag("亲中", winner == 6)
		3:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			if brazil.sub_government == GameConstants.SubGovernment.MODERATE:
				winner = _get_winner_in_america(brazil, ideo, sup, 2.0, 3)
			else:
				winner = _get_winner_in_america(brazil, ideo, sup, 1.5, 3)
			brazil.set_tag("亲中", winner == 3)
		_:
			winner = _get_winner_in_america(brazil, ideo, sup, 0.0, -1)
			if winner != brazil.sub_government:
				brazil.set_tag("亲中", false)
	brazil.government = GameConstants.Government.LIBERAL
	brazil.sub_government = winner
	_leave_alliances(brazil)
	brazil.next_election_year = 1989
	brazil.next_election_month = 11
	brazil.next_election_day = 15
	if winner == 7:
		brazil.level_of_instability -= 15
		context["result_text"] = tr(TXT_R7) + _proprc_suffix(brazil)
	elif winner == 8:
		brazil.level_of_development += 15
		_add_power(EmpireData.USA, -5)
		context["result_text"] = tr(TXT_R8) + _proprc_suffix(brazil)
	elif winner == 6:
		brazil.level_of_instability -= 10
		brazil.level_of_development += 5
		context["result_text"] = tr(TXT_R6) + _proprc_suffix(brazil)
	elif winner == 3:
		brazil.level_of_instability -= 5
		brazil.level_of_development += 10
		_add_power(EmpireData.USA, -25)
		var argentina := ws.get_country_by_legacy_index(71)
		if argentina != null:
			argentina.set_tag("亲美", false)
		context["result_text"] = tr(TXT_R3) + _proprc_suffix(brazil)




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_127_brazil_revival.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_127",
	"num": 127,
	"priority": 12700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_127_brazil_revival.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
