extends "res://数据脚本/event_script_base.gd"

## 原作 Event134.cs：进一步，退两步（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_PROPRC_YES := "event.script.event_134_chile_step_back.c0"
const TXT_PROPRC_NO := "event.script.event_134_chile_step_back.c1"
const TXT_OPT0_DIS := "event.script.event_134_chile_step_back.c2"
const TXT_OPT1_DIS := "event.script.event_134_chile_step_back.c3"
const TXT_R0 := "event.script.event_134_chile_step_back.c4"
const TXT_R1 := "event.script.event_134_chile_step_back.c5"
const TXT_R2 := "event.script.event_134_chile_step_back.c6"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var ev133 := int(world.completed_event_ids.get("event_133", 0))
	var ussr_rel := 0
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null:
		ussr_rel = world.empires[EmpireData.USSR].relations
	if ev133 == 1 and (world.get_flag("relres") or ussr_rel >= 800):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if ev133 < 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)





func _want_to_leave(c: CountryData) -> void:
	if c == null:
		return
	var flag := true
	var sub := c.sub_government
	if sub == 0:
		if _res(W.I_IDEOLOGY) > 2 or _res(W.I_ECON_SYSTEM) >= 13 or _res(W.I_DIPLO) < 700 or _res(W.I_PARTY_SYSTEM) >= 8:
			flag = false
	elif (sub >= 1 and sub <= 3) or sub == 8 or sub == 17:
		if _res(W.I_IDEOLOGY) > 3 or _res(W.I_ECON_SYSTEM) > 13 or _res(W.I_DIPLO) < 500:
			flag = false
	elif sub >= 4 and sub <= 6:
		var china := ws.get_country_by_legacy_index(1)
		if _res(W.I_IDEOLOGY) < 2 or _res(W.I_ECON_SYSTEM) < 13 or _res(W.I_DIPLO) > 700 or _res(W.I_PARTY_SYSTEM) < 8 or _res(W.I_PRESS_POLICY) < 18 or (china != null and china.has_tag("ovd")):
			flag = false
	elif sub >= 7:
		var china2 := ws.get_country_by_legacy_index(1)
		if _res(W.I_IDEOLOGY) == 1 or _res(W.I_ECON_SYSTEM) <= 11 or _res(W.I_DIPLO) < 300 or (china2 != null and china2.has_tag("sev")):
			flag = false
	if c.has_tag("亲中"):
		c.set_tag("对华贸易", flag)
		c.set_tag("亲中", flag)
		if c.has_tag("亲美"):
			c.set_tag("亲美", not flag)


func _proprc_suffix(c: CountryData) -> String:
	return tr(TXT_PROPRC_YES) if c.has_tag("亲中") else tr(TXT_PROPRC_NO)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var chile := ws.get_country_by_legacy_index(74)
	if chile == null:
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			chile.level_of_instability -= 5
			chile.level_of_development += 10
			chile.government = GameConstants.Government.SOCIALIST
			chile.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
			chile.set_tag("亲中", true)
			_want_to_leave(chile)
			# 原作 Event134.cs:54：iron_and_blood → achievements.Set(91)
			Achievements.set_achievement(91)
			context["result_text"] = tr(TXT_R0) + _proprc_suffix(chile)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			chile.level_of_instability -= 15
			chile.sub_government = GameConstants.SubGovernment.LIBERAL
			chile.set_tag("亲中", true)
			_want_to_leave(chile)
			context["result_text"] = tr(TXT_R1) + _proprc_suffix(chile)
		_:
			chile.level_of_instability -= 20
			chile.level_of_development -= 5
			context["result_text"] = tr(TXT_R2) + _proprc_suffix(chile)
	chile.next_election_year = 1989
	chile.next_election_month = 12
	chile.next_election_day = 14




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_134_chile_step_back.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_134",
	"num": 134,
	"priority": 13400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_134_chile_step_back.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
