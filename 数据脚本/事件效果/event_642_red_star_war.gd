extends "res://数据脚本/event_script_base.gd"

## 原作 Event642.cs：红星照我去战斗（伟大复兴军事决策，六选项）。
## 触发：GlobalScript.cs:57 Decision d37 → decision_catalog.gd:703 start_event(642)，手动触发。
## 差异：puppetOf→puppet_of；proprc/okb→亲中/okb；战争 70-74/90 无 WarDef → 兜底创建后补名；
##   选项5 completedDecisions[37]=false → ws.decisions.completed[37]=false。

const TXT_OPT0_DIS := "event.script.event_642_red_star_war.c0"
const TXT_OPT1_DIS := "event.script.event_642_red_star_war.c1"
const TXT_OPT2_NANYANG := "event.script.event_642_red_star_war.c2"
const TXT_OPT2_JAPAN := "event.script.event_642_red_star_war.c3"
const TXT_OPT2_DIS_0 := "event.script.event_642_red_star_war.c4"
const TXT_OPT2_DIS_1 := "event.script.event_642_red_star_war.c5"
const TXT_OPT3_DIS_0 := "event.script.event_642_red_star_war.c6"
const TXT_OPT3_DIS_1 := "event.script.event_642_red_star_war.c7"
const TXT_OPT4_DIS := "event.script.event_642_red_star_war.c8"
const TXT_WAR_TAIL := "event.script.event_642_red_star_war.c9"
const TXT_R0_PRE := "event.script.event_642_red_star_war.c10"
const TXT_R0_THAI_SOC := "event.script.event_642_red_star_war.c11"
const TXT_R0_THAI_GOV := "event.script.event_642_red_star_war.c12"
const TXT_R0_BURMA_SOC := "event.script.event_642_red_star_war.c13"
const TXT_R0_BURMA_GOV := "event.script.event_642_red_star_war.c14"
const TXT_R0_TAIL := "event.script.event_642_red_star_war.c15"
const TXT_R1 := "event.script.event_642_red_star_war.c16"
const TXT_R2_NANYANG := "event.script.event_642_red_star_war.c17"
const TXT_R2_JAPAN_PRE := "event.script.event_642_red_star_war.c18"
const TXT_R2_JAPAN_PRE_ALT := "event.script.event_642_red_star_war.c19"
const TXT_R3 := "event.script.event_642_red_star_war.c20"
const TXT_R4 := "event.script.event_642_red_star_war.c21"
const TXT_R5 := "event.script.event_642_red_star_war.c22"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 6:
		return
	var opt := event_def.options
	var vietnam := ws.get_country_by_legacy_index(11)
	var korea := ws.get_country_by_legacy_index(10)
	var philippines := ws.get_country_by_legacy_index(47)
	var indonesia := ws.get_country_by_legacy_index(50)
	var png := ws.get_country_by_legacy_index(134)
	var thailand := ws.get_country_by_legacy_index(34)
	var japan := ws.get_country_by_legacy_index(44)
	var india := ws.get_country_by_legacy_index(19)
	var pakistan := ws.get_country_by_legacy_index(31)
	if vietnam == null or vietnam.puppet_of != GameConstants.LegacySlot.CHINA:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if korea == null or korea.puppet_of != GameConstants.LegacySlot.CHINA:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	var sea_free := (philippines == null or philippines.puppet_of != GameConstants.LegacySlot.CHINA) \
		and (indonesia == null or indonesia.puppet_of != GameConstants.LegacySlot.CHINA) \
		and (png == null or png.puppet_of != GameConstants.LegacySlot.CHINA)
	var thai_ok := thailand != null and thailand.has_tag("亲中") and thailand.has_tag("okb")
	if sea_free and thai_ok:
		_enable(opt[2], tr(TXT_OPT2_NANYANG))
	elif (philippines != null and philippines.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (indonesia != null and indonesia.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (png != null and png.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (japan == null or japan.puppet_of != GameConstants.LegacySlot.CHINA):
		_enable(opt[2], tr(TXT_OPT2_JAPAN))
	elif not thai_ok:
		_disable(opt[2], tr(TXT_OPT2_DIS_0))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS_1))
	var pak_ok := pakistan != null and pakistan.has_tag("亲中")
	if (india == null or india.puppet_of != GameConstants.LegacySlot.CHINA) and pak_ok:
		_enable(opt[3], event_def.options[3].text)
	elif not pak_ok:
		_disable(opt[3], tr(TXT_OPT3_DIS_0))
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS_1))
	var china := ws.get_country_by_legacy_index(1)
	var parts_ok := china != null and not (china.parts.size() > 11 and china.parts[11])
	if (india != null and india.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (philippines != null and philippines.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (korea != null and korea.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (vietnam != null and vietnam.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (japan != null and japan.puppet_of == GameConstants.LegacySlot.CHINA) \
			and parts_ok and _res(W.I_ARMY) >= 5000:
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], tr(TXT_OPT4_DIS))
	_enable(opt[5], event_def.options[5].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var thailand := ws.get_country_by_legacy_index(34)
			var burma := ws.get_country_by_legacy_index(33)
			var text := tr(TXT_R0_PRE)
			text += tr(TXT_R0_THAI_SOC) if ws.is_socialism(thailand, true) else tr(TXT_R0_THAI_GOV)
			text += tr(TXT_R0_BURMA_SOC) if ws.is_socialism(burma, true) else tr(TXT_R0_BURMA_GOV)
			context["result_text"] = text + tr(TXT_R0_TAIL) + tr(TXT_WAR_TAIL)
			_start_war(71, "中华人民共和国", "东南亚诸国", "东南亚之征")
			_war_stats()
		1:
			context["result_text"] = tr(TXT_R1) + tr(TXT_WAR_TAIL)
			_start_war(72, "中华人民共和国", "朝鲜", "中朝之战")
			_war_stats()
		2:
			var philippines := ws.get_country_by_legacy_index(47)
			var indonesia := ws.get_country_by_legacy_index(50)
			var png := ws.get_country_by_legacy_index(134)
			var korea := ws.get_country_by_legacy_index(10)
			var sea_free := (philippines == null or philippines.puppet_of != GameConstants.LegacySlot.CHINA) \
				and (indonesia == null or indonesia.puppet_of != GameConstants.LegacySlot.CHINA) \
				and (png == null or png.puppet_of != GameConstants.LegacySlot.CHINA)
			if sea_free:
				context["result_text"] = tr(TXT_R2_NANYANG) + tr(TXT_WAR_TAIL)
				_start_war(73, "中华人民共和国", "南洋诸国", "南洋之征")
			else:
				var parts0 := korea != null and korea.parts.size() > 0 and korea.parts[0]
				if not parts0:
					context["result_text"] = tr(TXT_R2_JAPAN_PRE) + tr(TXT_WAR_TAIL)
					_start_war(90, "中国—朝鲜", "日本—韩国", "落日战争", 600, 400)
				else:
					context["result_text"] = tr(TXT_R2_JAPAN_PRE_ALT) + tr(TXT_WAR_TAIL)
					_start_war(90, "中国—朝鲜", "日本", "落日战争", 700, 300)
			_war_stats()
		3:
			context["result_text"] = tr(TXT_R3) + tr(TXT_WAR_TAIL)
			_start_war(74, "中华人民共和国", "印度及其卫星国", "南亚之征")
			_war_stats()
		4:
			context["result_text"] = tr(TXT_R4) + tr(TXT_WAR_TAIL)
			_start_war(70, "中华人民共和国", "苏联及蒙古", "雪耻之战")
			_war_stats()
		5:
			context["result_text"] = tr(TXT_R5)
			if ws.decisions != null and ws.decisions.completed.size() > 37:
				ws.decisions.completed[37] = false


func _war_stats() -> void:
	_add(W.I_PARTY_SUPPORT, 300)
	_add(W.I_PEOPLE_SUPPORT, 300)
	_add(W.I_THOUGHT_FREEDOM, -200)
	_add(W.I_DIPLO, 150)
	_add(W.I_BUDGET, -50)
	_add(W.I_AGENTS, -100)
	_add(W.I_ARMY, -200)
	_add(W.I_POPULATION, 2)
	_add_relation(EmpireData.USSR, -500)
	_add_power(EmpireData.USSR, -15)
	_add_relation(EmpireData.USA, -500)
	_add_power(EmpireData.USA, -15)
	ws.influence_prc += 15


func _start_war(war_id: int, side1: String, side2: String, war_name: String, infl1: int = 500, infl2: int = 500) -> void:
	# 原版全部为 SovietSupportDefender.AmericanSupportDefender → usa_side=2、ussr_side=2
	game.start_war(war_id, side1, side2, infl1, infl2, 2, 2)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		# Event641 的 war70 TickTime(4) 与 Event642 的 TickTime(12) 不同源；
		# WarCatalog 默认 4 对齐 Event641，这里覆盖为 Event642 的 12。
		if war_id == 70:
			ws.wars[war_id].fortnight_max = 12



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_642_red_star_war.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_642",
	"num": 642,
	"priority": 64200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_642_red_star_war.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
