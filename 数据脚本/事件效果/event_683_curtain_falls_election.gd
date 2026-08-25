extends "res://数据脚本/event_script_base.gd"

## 原作 Event683.cs：落幕的选举（美国特别大选，六选项）。 ## 触发：ReqEventForDLC02.cs:1254-1256 —— data.year>=1985 && !c51.nato && !c0.eu ##   && (c44 亲中/亲苏) && (c140 亲中/亲苏 (gov==2 && !亲美)) && (c101 亲中/亲苏) && !c131 亲美 ##   → trigger_script evaluate。 ## 差异：OAR→ws.oar；is_gkchp→get_flag("is_gkchp")；traits[0]→ws.leader.trait_personality； ##   isRIM→rim、isSocEU→soc_eu、Torg→对华贸易、cw→内战中；now_leader→current_leader。 ## 注意：原版 option4 条件 data.budget+data.budget>=300 是双重预算加法的原作笔误，按字面移植（预算*2>=300）。
const TXT_DESC_HEAD := "event.script.event_683_curtain_falls_election.c0"
const TXT_DESC_BUSH := "event.script.event_683_curtain_falls_election.c1"
const TXT_DESC_DUKAKIS := "event.script.event_683_curtain_falls_election.c2"
const TXT_DESC_TAIL := "event.script.event_683_curtain_falls_election.c3"
const TXT_OPT0_DIS := "event.script.event_683_curtain_falls_election.c4"
const TXT_OPT1_DIS := "event.script.event_683_curtain_falls_election.c5"
const TXT_OPT2_DIS := "event.script.event_683_curtain_falls_election.c6"
const TXT_OPT3_DIS := "event.script.event_683_curtain_falls_election.c7"
const TXT_OPT4_DIS := "event.script.event_683_curtain_falls_election.c8"
const TXT_CAND_AVAKIAN := "event.script.event_683_curtain_falls_election.c9"
const TXT_CAND_NOVACK := "event.script.event_683_curtain_falls_election.c10"
const TXT_CAND_HALL := "event.script.event_683_curtain_falls_election.c11"
const TXT_CAND_FONDA := "event.script.event_683_curtain_falls_election.c12"
const TXT_CAND_GRAVEL := "event.script.event_683_curtain_falls_election.c13"
const TXT_CAND_KIM := "event.script.event_683_curtain_falls_election.c14"
const TXT_CAND_LAROUCHE := "event.script.event_683_curtain_falls_election.c15"
const TXT_WIN_BUSH := "event.script.event_683_curtain_falls_election.c16"
const TXT_WIN_DUKAKIS := "event.script.event_683_curtain_falls_election.c17"
const TXT_WIN_PEROT := "event.script.event_683_curtain_falls_election.c18"
const TXT_WIN_PAUL := "event.script.event_683_curtain_falls_election.c19"
const TXT_WIN_SANDERS := "event.script.event_683_curtain_falls_election.c20"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	var desc := tr(TXT_DESC_HEAD)
	if usa != null and usa.current_leader == 3:
		desc += tr(TXT_DESC_BUSH)
	elif usa != null and (usa.current_leader == 0 or usa.current_leader == 2):
		desc += tr(TXT_DESC_DUKAKIS)
	desc += tr(TXT_DESC_TAIL)
	event_def.description = desc
	if event_def.options.size() < 6:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var opt := event_def.options
	if line > 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line == 4:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line > 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if line > 0 and line < 4:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	var china := ws.get_country_by_legacy_index(1)
	if (china == null or china.government != GameConstants.Government.LIBERAL) and _res(W.I_BUDGET) * 2 >= 300 \
			and _res(W.I_AGENTS) >= 20:
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], tr(TXT_OPT4_DIS))
	_enable(opt[5], event_def.options[5].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var num := 0
	var num2 := 0
	var num3 := 0
	var num4 := 0
	var text := ""
	if opt == 0:
		_add(W.I_BUDGET, -150)
		_add(W.I_AGENTS, -150)
		num += 2
	elif opt == 1:
		_add(W.I_BUDGET, -150)
		_add(W.I_AGENTS, -150)
		num2 += 2
	elif opt == 2:
		_add(W.I_BUDGET, -150)
		_add(W.I_AGENTS, -150)
		num3 += 2
	elif opt == 3:
		_add(W.I_BUDGET, -150)
		_add(W.I_AGENTS, -150)
		num4 += 2
	elif opt == 4:
		_add(W.I_BUDGET, -300)
		_add(W.I_AGENTS, -200)
		ws.influence_prc += 50
		num += 1
		text += _candidate_text()
	var china := ws.get_country_by_legacy_index(1)
	var gdr := ws.get_country_by_legacy_index(7)
	var france := ws.get_country_by_legacy_index(21)
	var italy := ws.get_country_by_legacy_index(17)
	var spain := ws.get_country_by_legacy_index(85)
	var portugal := ws.get_country_by_legacy_index(86)
	var sweden := ws.get_country_by_legacy_index(131)
	var indonesia := ws.get_country_by_legacy_index(135)
	var nigeria := ws.get_country_by_legacy_index(136)
	var west_germany := ws.get_country_by_legacy_index(15)
	var usa_country := ws.get_country_by_legacy_index(51)
	var japan := ws.get_country_by_legacy_index(140)
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	var ussr := ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
	# num：建制派（原版顺序逐项）
	if gdr != null and gdr.has_tag("ovd"):
		num += 1
	if gdr != null and gdr.has_tag("sev"):
		num += 1
	if china != null and china.has_tag("econ"):
		num += 1
	if china != null and china.has_tag("okb"):
		num += 1
	if france != null and france.sub_government != GameConstants.SubGovernment.EUROCOMMUNIST and ws.is_socialism(france, false):
		num += 1
	if indonesia != null and indonesia.government == GameConstants.Government.LIBERAL:
		num += 1
	if nigeria != null and nigeria.government == GameConstants.Government.LIBERAL:
		num += 1
	if france != null and (france.has_tag("fxseu") or france.has_tag("nazimao")) \
			or ws.get_flag("is_gkchp"):
		num += 999
	# num2：自由意志党/反建制
	if gdr == null or not gdr.has_tag("ovd"):
		num2 += 1
	if gdr == null or not gdr.has_tag("sev"):
		num2 += 1
	if china != null and china.has_tag("econ"):
		num2 -= 1
	if china != null and china.has_tag("okb"):
		num2 -= 1
	if ws.oar:
		num2 -= 1
	if ws.event_done_num(500):
		num2 -= 1
	if china != null and china.has_tag("rim") and _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and _mod_active(GameConstants.Modifier.MAOIST_BULWARK) \
			and ws.is_socialism(china, true):
		num2 -= 1
	if china != null and china.government == GameConstants.Government.LIBERAL:
		num2 += 1
	if west_germany != null and west_germany.内战中:
		num2 += 1
	if usa_country != null and usa_country.has_tag("对华贸易"):
		num2 += 1
	if ussr != null and ussr.current_leader == 6:
		num2 += 1
	# num3：民粹/改革党
	if ws.leader != null and ws.leader.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
		num3 += 1
	if _mod_active(GameConstants.Modifier.CHINESE_GANGS_IN_AMERICA):
		num3 += 1
	if italy != null and italy.sub_government == GameConstants.SubGovernment.MODERATE:
		num3 += 1
	if france != null and (france.sub_government == GameConstants.SubGovernment.MODERATE or france.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN):
		num3 += 1
	if spain != null and spain.sub_government == GameConstants.SubGovernment.MODERATE:
		num3 += 1
	if china != null and china.government == GameConstants.Government.REFORMIST:
		num3 += 1
	if indonesia != null and indonesia.sub_government == GameConstants.SubGovernment.LEFT_CONSERVATIVE:
		num3 += 1
	if japan != null and (japan.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN or japan.government == GameConstants.Government.LIBERAL):
		num3 += 1
	# num4：社会民主/桑德斯
	if italy != null and italy.government == GameConstants.Government.REFORMIST:
		num4 += 1
	if france != null and france.government == GameConstants.Government.REFORMIST:
		num4 += 1
	if portugal != null and portugal.government == GameConstants.Government.REFORMIST:
		num4 += 1
	if ussr != null and ussr.current_leader == 8:
		num4 += 1
	if sweden != null and sweden.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST:
		num4 += 1
	if spain != null and spain.has_tag("soc_eu"):
		num4 += 3
	# 胜负判定（原版 if/else 顺序与 tie-break 完全一致）
	if num >= num2 and num >= num3 and num >= num4:
		if usa != null and usa.current_leader == 3:
			text += tr(TXT_WIN_BUSH)
			usa.current_leader = 2
			if usa_country != null:
				usa_country.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			context["result_text"] = text
			return
		text += tr(TXT_WIN_DUKAKIS)
		if usa != null:
			usa.current_leader = 4
		if usa_country != null:
			usa_country.sub_government = GameConstants.SubGovernment.LIBERAL
		context["result_text"] = text
		return
	if num3 >= num2 and num3 >= num and num3 >= num4:
		text += tr(TXT_WIN_PEROT)
		if usa != null:
			usa.current_leader = 6
		if usa_country != null:
			usa_country.sub_government = GameConstants.SubGovernment.MODERATE
		context["result_text"] = text
		return
	if num2 >= num3 and num2 >= num and num2 >= num4:
		text += tr(TXT_WIN_PAUL)
		if usa != null:
			usa.current_leader = 5
		if usa_country != null:
			usa_country.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		context["result_text"] = text
		return
	text += tr(TXT_WIN_SANDERS)
	if usa != null:
		usa.current_leader = 7
	if usa_country != null:
		usa_country.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
	context["result_text"] = text


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null:
		return false
	if world.size() > W.I_YEAR and world.year < 1985:
		return false
	var europe_union := world.get_country_by_legacy_index(0)
	var us := world.get_country_by_legacy_index(51)
	if us != null and us.has_tag("nato"):
		return false
	if europe_union != null and europe_union.has_tag("eu"):
		return false
	var denmark := world.get_country_by_legacy_index(44)
	var japan := world.get_country_by_legacy_index(140)
	var cuba := world.get_country_by_legacy_index(101)
	var sweden := world.get_country_by_legacy_index(131)
	if denmark == null or (not denmark.has_tag("亲中") and not denmark.has_tag("亲苏")):
		return false
	if japan == null or (not japan.has_tag("亲中") and not japan.has_tag("亲苏") \
			and not (japan.government == GameConstants.Government.REFORMIST and not japan.has_tag("亲美"))):
		return false
	if cuba == null or (not cuba.has_tag("亲中") and not cuba.has_tag("亲苏")):
		return false
	if sweden != null and sweden.has_tag("亲美"):
		return false
	return true


func _candidate_text() -> String:
	var china := ws.get_country_by_legacy_index(1)
	if ws.is_socialism(china, true) and ws.result_of_event_num(25) == 2 \
			and ws.result_of_event_num(26) == 2:
		return tr(TXT_CAND_AVAKIAN)
	if china != null and china.sub_government == GameConstants.SubGovernment.TROTSKYIST:
		return tr(TXT_CAND_NOVACK)
	if ws.is_socialism(china, true):
		return tr(TXT_CAND_HALL)
	if china != null and china.government == GameConstants.Government.REFORMIST:
		return tr(TXT_CAND_FONDA)
	if china != null and china.government == GameConstants.Government.LIBERAL:
		return tr(TXT_CAND_GRAVEL)
	if china != null and china.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		return tr(TXT_CAND_KIM)
	return tr(TXT_CAND_LAROUCHE)


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() \
		and ws.modifiers[index] != null and ws.modifiers[index].is_active



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_683_curtain_falls_election.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_683",
	"nodesc": true,
	"num": 683,
	"priority": 68300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_683_curtain_falls_election.gd",
	"trigger_script": "res://数据脚本/事件效果/event_683_curtain_falls_election.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
