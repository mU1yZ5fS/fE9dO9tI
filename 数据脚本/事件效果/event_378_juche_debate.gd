extends "res://数据脚本/event_script_base.gd"

## 原作 Event378.cs：肝胆相照（朝鲜主体思想争论，六选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - 选项显隐 prepare 动态改写；
##  - 原版 politics 循环 → ws.politicians，traits[0] → trait_personality；
##  - 原版 guns 字段端口建模说明，按 ws.get_flag("guns") 处理（默认 false）。

const TXT_DIS_IDEOLOGY := "event.script.event_378_juche_debate.c0"
const TXT_DIS_NO_ALLIANCE := "event.script.event_378_juche_debate.c1"
const TXT_DIS_NK_ALLIANCE := "event.script.event_378_juche_debate.c2"
const TXT_DIS_ARMY := "event.script.event_378_juche_debate.c3"
const TXT_LABEL_BUDGET := "event.script.event_378_juche_debate.c4"
const TXT_LABEL_AGENTS := "event.script.event_378_juche_debate.c5"
const TXT_LABEL_ARMY := "event.script.event_378_juche_debate.c6"
const TXT_DIS_NO_MOD := "event.script.event_378_juche_debate.c7"
const TXT_DIS_NOT_FACTION := "event.script.event_378_juche_debate.c8"
const TXT_DIS_DOCTRINE := "event.script.event_378_juche_debate.c9"
const TXT_DIS_GOV := "event.script.event_378_juche_debate.c10"
const TXT_DIS_KOREA_TRADE := "event.script.event_378_juche_debate.c11"
const TXT_DIS_ECON := "event.script.event_378_juche_debate.c12"
const TXT_DIS_GOV2 := "event.script.event_378_juche_debate.c13"
const TXT_DIS_SEV := "event.script.event_378_juche_debate.c14"
const TXT_DIS_SUB := "event.script.event_378_juche_debate.c15"
const TXT_DIS_AGENTS := "event.script.event_378_juche_debate.c16"
const TXT_R0 := "event.script.event_378_juche_debate.c17"
const TXT_R1 := "event.script.event_378_juche_debate.c18"
const TXT_R2 := "event.script.event_378_juche_debate.c19"
const TXT_R3 := "event.script.event_378_juche_debate.c20"
const TXT_R4 := "event.script.event_378_juche_debate.c21"
const TXT_R5 := "event.script.event_378_juche_debate.c22"
const TXT_WAR_NAME := "event.script.event_378_juche_debate.c23"
const TXT_WAR_ATT := "event.script.event_378_juche_debate.c24"
const TXT_WAR_DEF := "event.script.event_378_juche_debate.c25"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 6:
		return
	var china := world.get_country_by_legacy_index(1)
	var nkorea := world.get_country_by_legacy_index(10)
	var skorea := world.get_country_by_legacy_index(46)
	var opt := event_def.options
	if _d(W.I_IDEOLOGY) < 4:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_DIS_IDEOLOGY))
	if _d(W.I_IDEOLOGY) < 4:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_DIS_IDEOLOGY))
	var mod6: bool = ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	if china != null and (china.has_tag("okb") or china.has_tag("seato")) 			and nkorea != null and not nkorea.has_tag("okb") and _d(W.I_ARMY) >= 250 			and (mod6 and game.is_faction_leading(0) or (china != null and china.government == GameConstants.Government.LIBERAL)):
		_enable(opt[2], event_def.options[2].text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif china == null or (not china.has_tag("okb") and not china.has_tag("seato")):
		_disable(opt[2], tr(TXT_DIS_NO_ALLIANCE))
	elif nkorea != null and nkorea.has_tag("okb"):
		_disable(opt[2], tr(TXT_DIS_NK_ALLIANCE))
	elif _d(W.I_ARMY) < 250:
		_disable(opt[2], tr(TXT_DIS_ARMY).format([25]))
	elif not mod6 or not game.is_faction_leading(0):
		if not mod6:
			_disable(opt[2], tr(TXT_DIS_NO_MOD))
		else:
			_disable(opt[2], tr(TXT_DIS_NOT_FACTION))
	elif _d(W.I_MIL_DOCTRINE) >= 32 and china != null and china.government != GameConstants.Government.LIBERAL:
		_disable(opt[2], tr(TXT_DIS_DOCTRINE))
	else:
		_disable(opt[2], tr(TXT_DIS_GOV))
	if skorea != null and not skorea.has_tag("对华贸易") and (_d(W.I_ECON_SYSTEM) > 13 or _d(W.I_IDEOLOGY) >= 4):
		_enable(opt[3], event_def.options[3].text)
	elif skorea != null and skorea.has_tag("对华贸易"):
		_disable(opt[3], tr(TXT_DIS_KOREA_TRADE))
	elif _d(W.I_ECON_SYSTEM) <= 13:
		_disable(opt[3], tr(TXT_DIS_ECON))
	else:
		_disable(opt[3], tr(TXT_DIS_GOV2))
	if china != null and china.has_tag("sev") and _d(W.I_AGENTS) >= 100:
		_enable(opt[4], event_def.options[4].text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif china == null or not china.has_tag("sev"):
		_disable(opt[4], tr(TXT_DIS_SEV))
	elif china != null and china.sub_government != GameConstants.SubGovernment.SOVIET_STYLE:
		_disable(opt[4], tr(TXT_DIS_SUB))
	else:
		_disable(opt[4], tr(TXT_DIS_AGENTS).format([15]))
	_enable(opt[5], event_def.options[5].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nkorea := ws.get_country_by_legacy_index(10)
	if nkorea != null:
		nkorea.government = GameConstants.Government.AUTHORITARIAN
		nkorea.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
	if game.is_faction_leading(0):
		_add(W.I_PARTY_SUPPORT, 100)
	else:
		_add(W.I_PARTY_SUPPORT, -200)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_DIPLO, 50)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					pol.loyalty -= 250
				elif pol != null and pol.trait_personality > GameConstants.PoliticianPersonality.MODERATE:
					pol.loyalty -= 200
		1:
			context["result_text"] = tr(TXT_R1)
			if game.is_faction_leading(0):
				_add(W.I_PARTY_SUPPORT, 300)
			else:
				_add(W.I_PARTY_SUPPORT, 200)
			_add(W.I_DIPLO, -30)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, 50)
			if nkorea != null:
				nkorea.set_tag("对华贸易", false)
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					pol.loyalty += 50
				elif pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					pol.loyalty += 200
				elif pol != null:
					pol.loyalty -= 50
		2:
			context["result_text"] = tr(TXT_R2)
			var num := 0
			if ws.get_flag("guns"):
				num += 100
			_add(W.I_DIPLO, 70)
			_add(W.I_PARTY_SUPPORT, -300)
			ws.influence_prc -= 100
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, -250)
			if nkorea != null:
				nkorea.set_tag("对华贸易", false)
			_add_power(EmpireData.USSR, 20)
			if nkorea != null:
				_establish_government(nkorea, "prosov")
				nkorea.influence_nato = 1
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					pol.power += 300
					pol.loyalty += 250
				elif pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					pol.loyalty += 250
				elif pol != null:
					pol.loyalty -= 100
			_start_war_378(700 - num, 300 + num)
		3:
			context["result_text"] = tr(TXT_R3)
			if game.is_faction_leading(0):
				_add(W.I_PARTY_SUPPORT, -300)
			elif game.is_faction_leading(1):
				_add(W.I_PARTY_SUPPORT, 50)
			else:
				_add(W.I_PARTY_SUPPORT, 200)
			_add(W.I_DIPLO, -70)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, -100)
			if skorea_country() != null:
				skorea_country().set_tag("对华贸易", true)
			_add(W.I_SCIENCE, 1000)
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					pol.power -= 500
				elif pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					pol.loyalty -= 100
				elif pol != null:
					pol.loyalty += 100
		4:
			context["result_text"] = tr(TXT_R4)
			if nkorea != null:
				nkorea.government = GameConstants.Government.SOCIALIST
				nkorea.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				nkorea.set_tag("sev", true)
			_add(W.I_DIPLO, -20)
			_add_relation(EmpireData.USSR, 100)
			if game.is_faction_leading(0):
				_add(W.I_PARTY_SUPPORT, -300)
			elif game.is_faction_leading(1):
				_add(W.I_PARTY_SUPPORT, 50)
			else:
				_add(W.I_PARTY_SUPPORT, 200)
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					pol.power -= 150
				elif pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					pol.loyalty += 100
		_:
			context["result_text"] = tr(TXT_R5)


func skorea_country() -> CountryData:
	return ws.get_country_by_legacy_index(46)


func _start_war_378(infl1: int, infl2: int) -> void:
	game.start_war(16, tr(TXT_WAR_ATT), tr(TXT_WAR_DEF), infl1, infl2, -1, 1)
	if ws.wars.size() > 16 and ws.wars[16] != null:
		ws.wars[16].name_war = tr(TXT_WAR_NAME)
		ws.wars[16].fortnight_max = 40


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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_378_juche_debate.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_378",
	"num": 378,
	"priority": 37800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_378_juche_debate.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
