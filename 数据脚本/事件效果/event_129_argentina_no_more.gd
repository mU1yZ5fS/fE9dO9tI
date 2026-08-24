extends "res://数据脚本/event_script_base.gd"

## 原作 Event129.cs：我们不能再忍受了（5 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_PROPRC_YES := "event.script.event_129_argentina_no_more.c0"
const TXT_PROPRC_NO := "event.script.event_129_argentina_no_more.c1"
const TXT_OPT3_DIS := "event.script.event_129_argentina_no_more.c2"
const TXT_R4 := "event.script.event_129_argentina_no_more.c3"
const TXT_R5 := "event.script.event_129_argentina_no_more.c4"
const TXT_R3 := "event.script.event_129_argentina_no_more.c5"
const TXT_R1 := "event.script.event_129_argentina_no_more.c6"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var argentina := world.get_country_by_legacy_index(71)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	_enable(opt[2], event_def.options[2].text)
	if argentina != null and argentina.government == GameConstants.Government.LIBERAL:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	_enable(opt[4], event_def.options[4].text)




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0


## Country.WantToLeave() 逐行移植（GameState.cs:7370-7394）。
## 原版 Event129 结局调 WantToLeave，不是 LeaveAlliances——不能把亲中/对华贸易一锅清掉。
func _want_to_leave(c: CountryData) -> void:
	if c == null:
		return
	var flag := true
	var sub := c.sub_government
	if sub == 0:
		if _d(W.I_IDEOLOGY) > 2 or _d(W.I_ECON_SYSTEM) >= 13 or _d(W.I_DIPLO) < 700 or _d(W.I_PARTY_SYSTEM) >= 8:
			flag = false
	elif (sub >= 1 and sub <= 3) or sub == 8 or sub == 17:
		if _d(W.I_IDEOLOGY) > 3 or _d(W.I_ECON_SYSTEM) > 13 or _d(W.I_DIPLO) < 500:
			flag = false
	elif sub >= 4 and sub <= 6:
		var china := ws.get_country_by_legacy_index(1)
		if _d(W.I_IDEOLOGY) < 2 or _d(W.I_ECON_SYSTEM) < 13 or _d(W.I_DIPLO) > 700 or _d(W.I_PARTY_SYSTEM) < 8 or _d(W.I_PRESS_POLICY) < 18 or (china != null and china.has_tag("ovd")):
			flag = false
	elif sub >= 7:
		var china2 := ws.get_country_by_legacy_index(1)
		if _d(W.I_IDEOLOGY) == 1 or _d(W.I_ECON_SYSTEM) <= 11 or _d(W.I_DIPLO) < 300 or (china2 != null and china2.has_tag("sev")):
			flag = false
	if c.has_tag("亲中"):
		c.set_tag("对华贸易", flag)
		c.set_tag("亲中", flag)
		if c.has_tag("亲美"):
			c.set_tag("亲美", not flag)


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
	var argentina := ws.get_country_by_legacy_index(71)
	if argentina == null:
		return
	var opt := int(context.get("option_index", -1))
	var ideo := _make_ideo([4, 5, 3, 1])
	var sup := _make_sup()
	var winner := -1
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(argentina, ideo, sup, 2.0 if argentina.government == GameConstants.Government.LIBERAL else 1.5, 4)
			argentina.set_tag("亲中", winner == 4)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(argentina, ideo, sup, 2.0 if argentina.government == GameConstants.Government.LIBERAL else 1.5, 5)
			argentina.set_tag("亲中", winner == 5)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(argentina, ideo, sup, 2.0 if argentina.government == GameConstants.Government.LIBERAL else 1.5, 3)
			argentina.set_tag("亲中", winner == 3)
		3:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(argentina, ideo, sup, 2.0 if argentina.government == GameConstants.Government.LIBERAL else 1.5, 1)
			argentina.set_tag("亲中", winner == 1)
		_:
			winner = _get_winner_in_america(argentina, ideo, sup, 0.0, -1)
			if winner != argentina.sub_government:
				argentina.set_tag("亲中", false)
	argentina.government = GameConstants.Government.LIBERAL
	argentina.sub_government = winner
	_want_to_leave(argentina)
	argentina.next_election_year = 1989
	argentina.next_election_month = 7
	argentina.next_election_day = 8
	if winner == 4:
		argentina.level_of_instability -= 20
		argentina.level_of_development -= 5
		_add_power(EmpireData.USA, -5)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = tr(TXT_R4) + " <color=red>" + _proprc_suffix(argentina) + "</color>"
	elif winner == 5:
		argentina.level_of_instability -= 15
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = tr(TXT_R5) + " <color=red>" + _proprc_suffix(argentina) + "</color>"
	elif winner == 3:
		argentina.level_of_instability -= 5
		argentina.level_of_development += 10
		_add_power(EmpireData.USA, -10)
		argentina.set_tag("亲美", false)
		context["result_text"] = tr(TXT_R3) + " <color=red>" + _proprc_suffix(argentina) + "</color>"
	elif winner == 1:
		argentina.level_of_instability -= 10
		argentina.level_of_development += 5
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, 5)
		argentina.set_tag("亲美", false)
		context["result_text"] = tr(TXT_R1) + " <color=red>" + _proprc_suffix(argentina) + "</color>"




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_129_argentina_no_more.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_129",
	"num": 129,
	"priority": 12900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_129_argentina_no_more.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
