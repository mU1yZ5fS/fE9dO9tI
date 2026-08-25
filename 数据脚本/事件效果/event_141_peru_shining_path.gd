extends "res://数据脚本/event_script_base.gd"

## 原作 Event141.cs：光辉乍现。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - iron_and_blood 成就已接 Achievements（Set 编号见 execute 内注释）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_OPT2_DIS := "event.script.event_141_peru_shining_path.c0"
const TXT_R5 := "event.script.event_141_peru_shining_path.c1"
const TXT_R3 := "event.script.event_141_peru_shining_path.c2"
const TXT_R_FALLBACK := "event.script.event_141_peru_shining_path.c3"
const TXT_R17 := "event.script.event_141_peru_shining_path.c4"
const TXT_FRIEND := "event.script.event_141_peru_shining_path.c5"
const TXT_ENEMY := "event.script.event_141_peru_shining_path.c6"



func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0






func _set_next_election(c: CountryData, year: int, month: int, day: int) -> void:
	if c == null:
		return
	c.next_election_year = year
	c.next_election_month = month
	c.next_election_day = day




func _friend_suffix(c: CountryData) -> String:
	if c != null and c.has_tag("亲中"):
		return tr(TXT_FRIEND)
	return tr(TXT_ENEMY)


## Country.WantToLeave() 逐行移植。
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


func _idiv(a: int, b: int) -> int:
	return int(float(a) / float(b))


## GameState.GetWinnerInAmerica 逐行移植（C# int 除法向零截断）。
func _get_winner_in_america(c: CountryData, allowed: Array, coef: float, party: int) -> int:
	if c == null:
		return 0
	var sup: Array = []
	sup.resize(10)
	sup.fill(0.0)
	var sub := c.sub_government
	var unstab := c.level_of_instability
	var dev := c.level_of_development
	if allowed[sub]:
		sup[sub] = sup[sub] - unstab + dev
	if sub - 1 >= 0 and allowed[sub - 1]:
		sup[sub - 1] = sup[sub - 1] - _idiv(unstab, 4) + _idiv(dev, 2)
	if sub + 1 <= 9 and allowed[sub + 1]:
		sup[sub + 1] = sup[sub + 1] - _idiv(unstab, 4) + _idiv(dev, 2)
	if not allowed[sub]:
		if sub >= 1 and sub <= 3:
			if allowed[1]:
				sup[1] = sup[1] - _idiv(unstab, 4) + _idiv(dev, 2)
			elif allowed[2]:
				sup[2] = sup[2] - _idiv(unstab, 4) + _idiv(dev, 2)
			elif allowed[3]:
				sup[3] = sup[3] - _idiv(unstab, 4) + _idiv(dev, 2)
		elif sub >= 4 and sub <= 6:
			if allowed[4]:
				sup[4] = sup[4] - _idiv(unstab, 4) + _idiv(dev, 2)
			elif allowed[5]:
				sup[5] = sup[5] - _idiv(unstab, 4) + _idiv(dev, 2)
			elif allowed[6]:
				sup[6] = sup[6] - _idiv(unstab, 4) + _idiv(dev, 2)
	if sub <= 3:
		if allowed[9 - sub]:
			sup[9 - sub] = sup[9 - sub] + unstab - dev
		elif allowed[5]:
			sup[5] = sup[5] + unstab - dev
		elif allowed[4]:
			sup[4] = sup[4] - _idiv(unstab, 2) + _idiv(dev, 2)
		if 8 - sub >= 0 and allowed[8 - sub]:
			sup[8 - sub] = sup[8 - sub] + _idiv(unstab, 2) - _idiv(dev, 4)
		if 10 - sub <= 9 and allowed[sub]:
			sup[10 - sub] = sup[10 - sub] + _idiv(unstab, 2) - _idiv(dev, 4)
	elif sub >= 6:
		if allowed[9 - sub]:
			sup[9 - sub] = sup[9 - sub] + unstab - dev
		elif allowed[4]:
			sup[4] = sup[4] + unstab - dev
		elif allowed[5]:
			sup[5] = sup[5] - _idiv(unstab, 2) + _idiv(dev, 2)
		if 8 - sub >= 0 and allowed[8 - sub]:
			sup[8 - sub] = sup[8 - sub] + _idiv(unstab, 2) - _idiv(dev, 4)
		if 10 - sub <= 9 and allowed[10 - sub]:
			sup[10 - sub] = sup[10 - sub] + _idiv(unstab, 2) - _idiv(dev, 4)
	elif sub == 4:
		if allowed[0]:
			sup[0] = sup[0] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[1]:
			sup[1] = sup[1] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[2]:
			sup[2] = sup[2] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[6]:
			sup[6] = sup[6] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[7]:
			sup[7] = sup[7] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[8]:
			sup[8] = sup[8] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[9]:
			sup[9] = sup[9] + _idiv(unstab, 2) - _idiv(dev, 4)
	elif sub == 5:
		if allowed[0]:
			sup[0] = sup[0] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[1]:
			sup[1] = sup[1] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[2]:
			sup[2] = sup[2] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[3]:
			sup[6] = sup[6] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[7]:
			sup[7] = sup[7] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[8]:
			sup[8] = sup[8] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[9]:
			sup[9] = sup[9] + _idiv(unstab, 2) - _idiv(dev, 4)
	if coef > 0.0:
		coef *= 3.0
		if sup[party] > 1.0:
			sup[party] = sup[party] * coef
		else:
			sup[party] = sup[party] + coef
	for i in range(10):
		if allowed[i]:
			sup[i] = sup[i] + 100.0
	var best := 0
	var best_val := -1.0e30
	for i in range(10):
		var v := float(sup[i])
		if v > best_val:
			best_val = v
			best = i
	return best


func _allowed10(a: Array) -> Array:
	var arr := [false, false, false, false, false, false, false, false, false, false]
	for i in a:
		arr[int(i)] = true
	return arr

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var cond := false
	if world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active:
		@warning_ignore("shadowed_variable_base_class")
		var d := world
		if d.size() > W.I_ECON_SYSTEM and d.ideology <= 3 and d.econ_system <= 12 and world.influence_prc >= 150:
			cond = true
	if cond:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(80)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([5, 3])
	var winner := 0
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 5)
			c.government = GameConstants.Government.LIBERAL
			_set_next_election(c, 1985, 4, 14)
			if winner == 5:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 3)
			c.government = GameConstants.Government.LIBERAL
			_set_next_election(c, 1985, 4, 14)
			if winner == 3:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = 17
		_:
			c.government = GameConstants.Government.LIBERAL
			_set_next_election(c, 1985, 4, 14)
			winner = _get_winner_in_america(c, allowed, 0.0, -1)
			if winner != c.sub_government:
				c.set_tag("亲中", false)
	c.sub_government = winner
	_want_to_leave(c)
	if c.sub_government == GameConstants.SubGovernment.MODERATE:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, 15)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = tr(TXT_R5) + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST:
		c.level_of_instability += 10
		c.level_of_development += 25
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = tr(TXT_R3) + _friend_suffix(c)
		return
	var c72 := ws.get_country_by_legacy_index(72)
	var c73 := ws.get_country_by_legacy_index(73)
	var c74 := ws.get_country_by_legacy_index(74)
	if (c72 != null and c72.sub_government < 6) or (c73 != null and c73.sub_government < 6) or (c74 != null and c74.sub_government < 6):
		c.government = GameConstants.Government.SOCIALIST
		c.set_tag("亲中", true)
		_set_next_election(c, 2222, 2, 22)
		c.level_of_instability -= 30
		c.level_of_development -= 15
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, -15)
		ws.influence_prc += 15
		# 原作 Event141.cs:120：iron_and_blood → achievements.Set(94)
		Achievements.set_achievement(94)
		context["result_text"] = tr(TXT_R17) + _friend_suffix(c)
		return
	c.sub_government = GameConstants.SubGovernment.MODERATE
	c.government = GameConstants.Government.LIBERAL
	c.set_tag("亲中", false)
	_set_next_election(c, 1985, 4, 14)
	c.level_of_instability -= 20
	c.level_of_development -= 5
	_add_power(EmpireData.USA, 15)
	ws.influence_prc -= 15
	context["result_text"] = tr(TXT_R_FALLBACK) + _friend_suffix(c)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_141_peru_shining_path.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_141",
	"num": 141,
	"priority": 14100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_141_peru_shining_path.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
