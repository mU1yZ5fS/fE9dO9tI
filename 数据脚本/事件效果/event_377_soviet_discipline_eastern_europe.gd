extends "res://数据脚本/event_script_base.gd"

## 原作 Event377.cs：苏联“老大哥”教训“小弟”（苏联干预东欧，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - 描述按 c9.proprc/okb、data.soviet_eastern_europe_intervention、c6.proprc 三态动态改写；
##  - SOV_PRC_PartiesConnection → I_COMMUNICATIONS（见 event_435 约定）；
##  - 成就 Set(142) 已接 Achievements；
##  - ingamewars[22].usa_place → WarData.usa_side（c51 对华贸易时置 0）；
##  - war 22 覆盖 name_war/fortnight_max。

const TXT_DESC_FMT := "event.script.event_377_soviet_discipline_eastern_europe.c0"
const TXT_LIST_5 := "event.script.event_377_soviet_discipline_eastern_europe.c1"
const TXT_LIST_5B := "event.script.event_377_soviet_discipline_eastern_europe.c2"
const TXT_LIST_4 := "event.script.event_377_soviet_discipline_eastern_europe.c3"
const TXT_LIST_4B := "event.script.event_377_soviet_discipline_eastern_europe.c4"
const TXT_OPT2_RELRES := "event.script.event_377_soviet_discipline_eastern_europe.c5"
const TXT_OPT2_NORELRES := "event.script.event_377_soviet_discipline_eastern_europe.c6"
const TXT_DIS_INFLUENCE := "event.script.event_377_soviet_discipline_eastern_europe.c7"
const TXT_DIS_ARMY := "event.script.event_377_soviet_discipline_eastern_europe.c8"
const TXT_LABEL_BUDGET := "event.script.event_377_soviet_discipline_eastern_europe.c9"
const TXT_LABEL_AGENTS := "event.script.event_377_soviet_discipline_eastern_europe.c10"
const TXT_LABEL_ARMY := "event.script.event_377_soviet_discipline_eastern_europe.c11"
const TXT_DIS_WAR := "event.script.event_377_soviet_discipline_eastern_europe.c12"
const TXT_DIS_ISLANDS := "event.script.event_377_soviet_discipline_eastern_europe.c13"
const TXT_DIS_FACTION := "event.script.event_377_soviet_discipline_eastern_europe.c14"
const TXT_R0A_FMT := "event.script.event_377_soviet_discipline_eastern_europe.c15"
const TXT_R0B := "event.script.event_377_soviet_discipline_eastern_europe.c16"
const TXT_R1A_FMT := "event.script.event_377_soviet_discipline_eastern_europe.c17"
const TXT_R1B := "event.script.event_377_soviet_discipline_eastern_europe.c18"
const TXT_R2_FMT := "event.script.event_377_soviet_discipline_eastern_europe.c19"
const TXT_RELRES := "event.script.event_377_soviet_discipline_eastern_europe.c20"
const TXT_MONGOLIA := "event.script.event_377_soviet_discipline_eastern_europe.c21"
const TXT_WAR_NAME := "event.script.event_377_soviet_discipline_eastern_europe.c22"
const TXT_WAR_ATT := "event.script.event_377_soviet_discipline_eastern_europe.c23"
const TXT_WAR_DEF := "event.script.event_377_soviet_discipline_eastern_europe.c24"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var mongolia := world.get_country_by_legacy_index(9)
	var bulgaria := world.get_country_by_legacy_index(6)
	var opt := event_def.options
	var cond5: bool = mongolia != null and mongolia.has_tag("亲中") and not mongolia.has_tag("okb") 			and _d(132) <= 0 and bulgaria != null and bulgaria.has_tag("亲中")  # 原版 data.soviet_eastern_europe_intervention
	var cond4: bool = mongolia != null and mongolia.has_tag("亲中") and not mongolia.has_tag("okb") and _d(132) <= 0  # 原版 data.soviet_eastern_europe_intervention
	if cond5:
		event_def.description = tr(TXT_DESC_FMT).format(["\n", tr(TXT_LIST_5B)])
	elif cond4:
		event_def.description = tr(TXT_DESC_FMT).format(["\n", tr(TXT_LIST_5)])
	elif bulgaria != null and bulgaria.has_tag("亲中"):
		event_def.description = tr(TXT_DESC_FMT).format(["\n", tr(TXT_LIST_4B)])
	else:
		event_def.description = tr(TXT_DESC_FMT).format(["\n", tr(TXT_LIST_4)])
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	var relres: bool = world.get_flag("relres")
	var war22 := world.wars[22] if world.wars.size() > 22 else null
	if relres and world.influence_prc >= 750 and _d(W.I_ARMY) >= 750 			and game.is_faction_leading(0) 			and (war22 == null or not war22.is_going) and _d(133) == 0:  # 原版 data.soviet_reorganization_war_state
		_enable(opt[2], tr(TXT_OPT2_RELRES).format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif not relres and world.influence_prc >= 950 and _d(W.I_ARMY) >= 750:
		_enable(opt[2], tr(TXT_OPT2_NORELRES).format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif world.influence_prc < 750:
		_disable(opt[2], tr(TXT_DIS_INFLUENCE).format([95]))
	elif _d(W.I_ARMY) < 750:
		_disable(opt[2], tr(TXT_DIS_ARMY).format([75]))
	elif war22 != null and war22.is_going:
		_disable(opt[2], tr(TXT_DIS_WAR))
	elif _d(133) != 0:  # 原版 data.soviet_reorganization_war_state
		_disable(opt[2], tr(TXT_DIS_ISLANDS))
	else:
		_disable(opt[2], tr(TXT_DIS_FACTION))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var mongolia := ws.get_country_by_legacy_index(9)
	var bulgaria := ws.get_country_by_legacy_index(6)
	var poland := ws.get_country_by_legacy_index(2)
	var hungary := ws.get_country_by_legacy_index(4)
	var romania := ws.get_country_by_legacy_index(5)
	var ussr := ws.get_country_by_legacy_index(7)
	var opt := int(context.get("option_index", -1))
	var cond5: bool = mongolia != null and mongolia.has_tag("亲中") and not mongolia.has_tag("okb") 			and _d(132) <= 0 and bulgaria != null and bulgaria.has_tag("亲中")  # 原版 data.soviet_eastern_europe_intervention
	if opt == 0:
		if bulgaria == null or not bulgaria.has_tag("亲中"):
			context["result_text"] = tr(TXT_R0A_FMT).format(["\n", tr(TXT_MONGOLIA) if cond5 else ""])
			_add(W.I_PARTY_SUPPORT, -550)
		else:
			context["result_text"] = tr(TXT_R0B).format(["\n", tr(TXT_MONGOLIA) if cond5 else ""])
			_add(W.I_PARTY_SUPPORT, -600)
	elif opt == 1:
		if bulgaria == null or not bulgaria.has_tag("亲中"):
			context["result_text"] = tr(TXT_R1A_FMT).format(["\n", tr(TXT_MONGOLIA) if cond5 else ""])
			_add(W.I_PARTY_SUPPORT, -250)
			_add_relation(EmpireData.USSR, -500)
			_add_relation(EmpireData.USA, 100)
			_add(W.I_DIPLO, -50)
		else:
			context["result_text"] = tr(TXT_R1B).format(["\n", tr(TXT_MONGOLIA) if cond5 else ""])
			_add(W.I_PARTY_SUPPORT, -250)
			_add_relation(EmpireData.USSR, -500)
			_add_relation(EmpireData.USA, 100)
			_add(W.I_DIPLO, -50)
	else:
		context["result_text"] = tr(TXT_R2_FMT).format(["\n", tr(TXT_RELRES) if ws.get_flag("relres") else ""])
		ws.empires[EmpireData.USSR].relations = 0
		# 原作 Event377.cs:121：iron_and_blood → achievements.Set(142)
		Achievements.set_achievement(142)
		_start_war_377()
		var usa377 := ws.get_country_by_legacy_index(51)
		if ws.wars.size() > 22 and ws.wars[22] != null and usa377 != null and usa377.has_tag("对华贸易"):
			ws.wars[22].usa_side = GameConstants.WarSide.SIDE1
		if bulgaria != null:
			bulgaria.set_tag("对华贸易", false)
		_add(W.I_PARTY_SUPPORT, 300)
		_add(W.I_ARMY, -750)
	# 公共尾部（原版 ResultsOfEvents 在所有分支后执行）
	if poland != null:
		_leave_alliances(poland)
		_establish_government(poland, "prosov")
	if hungary != null:
		_leave_alliances(hungary)
		_establish_government(hungary, "prosov")
	if romania != null:
		_leave_alliances(romania)
		_establish_government(romania, "prosov")
	if bulgaria != null:
		_leave_alliances(bulgaria)
		_establish_government(bulgaria, "prosov")
		bulgaria.set_tag("sev", true)
		bulgaria.set_tag("ovd", true)
	if cond5 and mongolia != null and ussr != null:
		mongolia.government = ussr.government
		_establish_government(mongolia, "prosov")
		mongolia.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
		mongolia.puppet_of = 7
		ws.influence_prc -= 50
		mongolia.set_tag("对华贸易", false)
	if ussr != null:
		for c in [poland, hungary, romania, bulgaria]:
			if c != null:
				c.government = ussr.government
				c.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				c.set_tag("对华贸易", false)
				c.puppet_of = 7
	ws.influence_prc -= 150
	_add_power(EmpireData.USSR, 200)


func _start_war_377() -> void:
	game.start_war(22, tr(TXT_WAR_ATT), tr(TXT_WAR_DEF), 250, 750, -1, -1)
	if ws.wars.size() > 22 and ws.wars[22] != null:
		ws.wars[22].name_war = tr(TXT_WAR_NAME)
		ws.wars[22].fortnight_max = 500



func _establish_government(c: CountryData, kind: String) -> void:
	if kind == "prosov":
		c.set_tag("亲中", false)
		c.set_tag("亲苏", true)
		c.set_tag("亲美", false)




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0










# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_377_soviet_discipline_eastern_europe.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_377",
	"num": 377,
	"priority": 37700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_377_soviet_discipline_eastern_europe.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
