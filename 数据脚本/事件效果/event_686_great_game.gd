extends "res://数据脚本/event_script_base.gd"

## 原作 Event686.cs：大博弈（西欧影响力机制激活，三选项）。 ## 触发：ReqEventsDLC02.cs:1369-1371 —— !c0.eu && !c51.nato ##   && ((c7.sev && c7.ovd) is_gkchp) && !c85.soc_eu && !c21.fxseu && !c21.nazimao ##   && !ev713 && (!ev548 china.rim) → trigger_script evaluate。 ## 差异：sovpower/prcpower→sov_power/prc_power；spec→special；based→有驻军基地； ##   isSEV→sev、isOVD→ovd、Torg→对华贸易、prosov→亲苏、isRIM→rim； ##   politics_dolshnost[2]<100 用外长姓名，否则用领袖姓名；relres→get_flag("relres")。

const TXT_OPT0_FMT := "event.script.event_686_great_game.c0"
const TXT_OPT0_DIS_A := "event.script.event_686_great_game.c1"
const TXT_OPT0_DIS_B := "event.script.event_686_great_game.c2"
const TXT_OPT1_DIS_A := "event.script.event_686_great_game.c3"
const TXT_OPT1_DIS_B := "event.script.event_686_great_game.c4"
const TXT_R0_FM_FMT := "event.script.event_686_great_game.c5"
const TXT_R0_LEADER_FMT := "event.script.event_686_great_game.c6"
const TXT_R1 := "event.script.event_686_great_game.c7"
const TXT_R2 := "event.script.event_686_great_game.c8"

const PROPRC_LIST := [92, 21, 85, 86, 87, 29, 17]
const NEUTRAL_LIST := [0, 27, 28, 88, 89, 90, 91]


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var china := ws.get_country_by_legacy_index(1)
	var opt := event_def.options
	var proprc_count := _count_proprc()
	var can_contain := china != null and china.has_tag("econ") and china.has_tag("okb") \
		and ws.influence_prc >= 1000 and _res(W.I_RESERVE) >= 250 and proprc_count >= 3
	if can_contain:
		_enable(opt[0], tr(TXT_OPT0_FMT).replace("{0}{1}", _plan_author_name()))
	elif china == null or not china.has_tag("econ") or not china.has_tag("okb"):
		_disable(opt[0], tr(TXT_OPT0_DIS_A))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS_B))
	if china != null and china.government != GameConstants.Government.LIBERAL and ws.get_flag("relres") \
			and china.has_tag("sev"):
		_enable(opt[1], event_def.options[1].text)
	elif china != null and china.government == GameConstants.Government.LIBERAL:
		_disable(opt[1], tr(TXT_OPT1_DIS_A))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_B))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	# 公共前奏：所有结果先重置中立国势力并处理 c26（奥地利? 按原版序号 26）。
	for idx in NEUTRAL_LIST:
		var c := ws.get_country_by_legacy_index(idx)
		if c == null:
			continue
		c.stab = 0
		c.special = 0
		c.sov_power = 300
		c.prc_power = 0
	var finland := ws.get_country_by_legacy_index(26)
	if finland != null and finland.has_tag("亲苏"):
		for idx in [28, 90, 91]:
			var c := ws.get_country_by_legacy_index(idx)
			if c != null:
				c.sov_power += 100
	else:
		if finland != null:
			finland.set_tag("亲苏", true)
			finland.government = GameConstants.Government.REFORMIST
			finland.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
	if opt == 0:
		var leader := _leader_name()
		var plan_author := _plan_author_name()
		if _has_foreign_minister():
			context["result_text"] = tr(TXT_R0_FM_FMT).replace("{0}{1}", leader) \
				.replace("{2}{3}", plan_author)
		else:
			context["result_text"] = tr(TXT_R0_LEADER_FMT).replace("{0}{1}", leader)
		_add(W.I_BUDGET, -250)
		_add(W.I_AGENTS, -250)
		_add(W.I_ARMY, -50)
		_add(W.I_DIPLO, 50)
		_add_relation(EmpireData.USA, -250)
		_add_relation(EmpireData.USSR, -250)
		var proprc_count := _count_proprc()
		for idx in NEUTRAL_LIST:
			var c := ws.get_country_by_legacy_index(idx)
			if c != null:
				c.prc_power = 250 + 50 * proprc_count
		return
	if opt == 1:
		context["result_text"] = tr(TXT_R1)
		_add(W.I_BUDGET, -100)
		_add_relation(EmpireData.USA, 500)
		_add_relation(EmpireData.USSR, -250)
		_add_power(EmpireData.USSR, 50)
		ws.influence_prc += 25
		var ussr := ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
		for idx in NEUTRAL_LIST:
			var c := ws.get_country_by_legacy_index(idx)
			if c == null:
				continue
			_apply_soviet_turn(c, ussr)
		if finland != null:
			# 原版 c26 单独块：只改政体/标签/based，不动 sovpower/prcpower。
			_apply_finland_turn(finland, ussr)
		return
	if opt == 2:
		context["result_text"] = tr(TXT_R2)


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var eu_holder := world.get_country_by_legacy_index(0)
	var usa_country := world.get_country_by_legacy_index(51)
	var gdr := world.get_country_by_legacy_index(7)
	var spain := world.get_country_by_legacy_index(85)
	var france := world.get_country_by_legacy_index(21)
	var china := world.get_country_by_legacy_index(1)
	if eu_holder != null and eu_holder.has_tag("eu"):
		return false
	if usa_country != null and usa_country.has_tag("nato"):
		return false
	var both_blocks := gdr != null and gdr.has_tag("sev") and gdr.has_tag("ovd")
	if not both_blocks and not world.get_flag("is_gkchp"):
		return false
	if spain != null and spain.has_tag("soc_eu"):
		return false
	if france != null and (france.has_tag("fxseu") or france.has_tag("nazimao")):
		return false
	if world.event_done_num(713):
		return false
	if not world.event_done_num(548) and (china == null or not china.has_tag("rim")):
		return false
	return true


func _count_proprc() -> int:
	var count := 0
	for idx in PROPRC_LIST:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null and c.has_tag("亲中"):
			count += 1
	var belgium := ws.get_country_by_legacy_index(16)
	if belgium != null and belgium.parts.size() > 0 and belgium.parts[0] \
			and belgium.has_tag("亲中"):
		count += 1
	return count


## 原版 politics_dolshnost[2]<100 用外长，否则领袖（哨兵 150/200 走领袖）。
func _plan_author_name() -> String:
	if ws.politics_positions.size() > 2:
		var idx := ws.politics_positions[2]
		if idx >= 0 and idx < 100 and idx < ws.politicians.size() \
				and ws.politicians[idx] != null and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return _leader_name()


func _has_foreign_minister() -> bool:
	if ws.politics_positions.size() <= 2:
		return false
	var idx := ws.politics_positions[2]
	return idx >= 0 and idx < 100 and idx < ws.politicians.size() \
		and ws.politicians[idx] != null and ws.politicians[idx].name_display != ""


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


## 原版 result1 对中立国/芬兰的苏维埃转向：戈尔巴乔夫在位走 gov2/sub14，否则 gov1/sub1。
func _apply_soviet_turn(c: CountryData, ussr: EmpireData) -> void:
	c.有驻军基地 = true
	c.prc_power = 0
	c.sov_power = 1000
	if ussr != null and ussr.current_leader == 6:
		c.government = GameConstants.Government.REFORMIST
		c.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
	else:
		c.government = GameConstants.Government.SOCIALIST
		c.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
	c.set_tag("亲苏", true)
	c.set_tag("对华贸易", true)
	c.set_tag("sev", true)
	c.set_tag("ovd", true)


## 原版 result1 的 c26 单独块（不动势力值）。
func _apply_finland_turn(c: CountryData, ussr: EmpireData) -> void:
	if ussr != null and ussr.current_leader == 6:
		c.government = GameConstants.Government.REFORMIST
		c.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
	else:
		c.government = GameConstants.Government.SOCIALIST
		c.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
	c.set_tag("亲苏", true)
	c.set_tag("对华贸易", true)
	c.set_tag("sev", true)
	c.set_tag("ovd", true)
	c.有驻军基地 = true



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_686_great_game.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_686",
	"num": 686,
	"priority": 68600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_686_great_game.gd",
	"trigger_script": "res://数据脚本/事件效果/event_686_great_game.gd",
	"options": [{"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
