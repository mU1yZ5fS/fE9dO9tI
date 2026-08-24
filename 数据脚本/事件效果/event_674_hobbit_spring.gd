extends "res://数据脚本/event_script_base.gd"

## 原作 Event674.cs：霍比特之春（欧洲社会国家组织成立，三选项）。
## 触发：ReqEventsDLC02.cs:1476 —— c21/c92/c85.sub∈{22,9} && IsAuthoritarianism(86)
##   && c87.sub∈{7,9} && 1985.11 起 && num(sub22计数)<3（num>=3 走 675）→ trigger_script evaluate。
## 差异：isFXSEU→fxseu 标签；LeaveAlliances→_leave_alliances；result2 中国转 gov0/sub9。

const TXT_OPT2_DIS := "event.script.event_674_hobbit_spring.c0"
const TXT_R0 := "event.script.event_674_hobbit_spring.c1"
const TXT_R1 := "event.script.event_674_hobbit_spring.c2"
const TXT_R2_FMT := "event.script.event_674_hobbit_spring.c3"
const TXT_IRAN_13 := "event.script.event_674_hobbit_spring.c4"
const TXT_IRAN_9 := "event.script.event_674_hobbit_spring.c5"
const TXT_GDR_9 := "event.script.event_674_hobbit_spring.c6"
const TXT_GDR_22 := "event.script.event_674_hobbit_spring.c7"
const TXT_FRG_10 := "event.script.event_674_hobbit_spring.c8"
const TXT_GREECE := "event.script.event_674_hobbit_spring.c9"
const TXT_AUSTRALIA := "event.script.event_674_hobbit_spring.c10"
const TXT_SOUTH_AFRICA := "event.script.event_674_hobbit_spring.c11"
const TXT_MEXICO := "event.script.event_674_hobbit_spring.c12"
const TXT_LEBANON := "event.script.event_674_hobbit_spring.c13"
const TXT_FRANCE_PUPPETS := "event.script.event_674_hobbit_spring.c14"
const TXT_ITALY_PUPPETS := "event.script.event_674_hobbit_spring.c15"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var china := ws.get_country_by_legacy_index(1)
	if china != null and (china.sub_government == GameConstants.SubGovernment.NEO_FASCIST \
			or (ws.is_authoritarian(china) and _res(W.I_WAR_SUPPORT) >= 700)) \
			and china.sub_government != GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_enable(event_def.options[2], event_def.options[2].text)
	else:
		_disable(event_def.options[2], tr(TXT_OPT2_DIS))
	_enable(event_def.options[0], event_def.options[0].text)
	_enable(event_def.options[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var trade := opt == 2
	var text := ""
	match opt:
		0: text = tr(TXT_R0)
		1: text = tr(TXT_R1)
		2: text = tr(TXT_R2_FMT).replace("{0}{1}", _leader_name())
	text += _chain_text(trade)
	_apply_chain(trade)
	if opt == 0:
		_add_relation(EmpireData.USA, 50)
		_add_relation(EmpireData.USSR, 50)
		_add_power(EmpireData.USA, -50)
		_add_power(EmpireData.USSR, -50)
		ws.influence_prc -= 50
	elif opt == 1:
		_add_power(EmpireData.USA, -50)
		_add_power(EmpireData.USSR, -50)
		ws.influence_prc -= 50
	else:
		var china := ws.get_country_by_legacy_index(1)
		if china != null:
			china.government = GameConstants.Government.AUTHORITARIAN
			china.sub_government = GameConstants.SubGovernment.NEO_FASCIST
		for c in ws.countries:
			if c == null:
				continue
			if not ws.is_authoritarian(c):
				c.set_tag("亲中", false)
				c.set_tag("对华贸易", false)
				c.set_tag("okb", false)
				c.set_tag("econ", false)
		_set_data(W.I_DIPLO, 1100)
		_add_relation(EmpireData.USA, -750)
		_add_relation(EmpireData.USSR, -750)
		_add_power(EmpireData.USA, -50)
		_add_power(EmpireData.USSR, -50)
		ws.influence_prc += 50
	context["result_text"] = text


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19851101:
		return false
	var france := world.get_country_by_legacy_index(21)
	var uk := world.get_country_by_legacy_index(92)
	var spain := world.get_country_by_legacy_index(85)
	var portugal := world.get_country_by_legacy_index(86)
	var italy := world.get_country_by_legacy_index(87)
	if france == null or uk == null or spain == null or portugal == null or italy == null:
		return false
	if (france.sub_government != GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST and france.sub_government != GameConstants.SubGovernment.NEO_FASCIST) \
			or (uk.sub_government != GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST and uk.sub_government != GameConstants.SubGovernment.NEO_FASCIST) \
			or (spain.sub_government != GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST and spain.sub_government != GameConstants.SubGovernment.NEO_FASCIST):
		return false
	if not world.is_authoritarian(portugal):
		return false
	if italy.sub_government != GameConstants.SubGovernment.RIGHT_AUTHORITARIAN and italy.sub_government != GameConstants.SubGovernment.NEO_FASCIST:
		return false
	return _sub22_count(world) < 3


func _chain_text(_trade: bool) -> String:
	var s := ""
	var iran := ws.get_country_by_legacy_index(8)
	if iran != null:
		if iran.sub_government == GameConstants.SubGovernment.NEOPATRIARCHAL:
			s += tr(TXT_IRAN_13)
		elif iran.sub_government == GameConstants.SubGovernment.NEO_FASCIST and iran.puppet_of < 0:
			s += tr(TXT_IRAN_9)
	var gdr := ws.get_country_by_legacy_index(17)
	if gdr != null and gdr.parts.size() > 0 and gdr.parts[0]:
		if gdr.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
			s += tr(TXT_GDR_9)
		elif gdr.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
			s += tr(TXT_GDR_22)
	var frg := ws.get_country_by_legacy_index(16)
	if frg != null and frg.parts.size() > 0 and frg.parts[0] and frg.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		s += tr(TXT_FRG_10)
	var greece := ws.get_country_by_legacy_index(45)
	if greece != null and greece.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		s += tr(TXT_GREECE)
	var australia := ws.get_country_by_legacy_index(135)
	if ws.is_authoritarian(australia):
		s += tr(TXT_AUSTRALIA)
	var south_africa := ws.get_country_by_legacy_index(131)
	if ws.is_authoritarian(south_africa):
		s += tr(TXT_SOUTH_AFRICA)
	var mexico := ws.get_country_by_legacy_index(140)
	if mexico != null and mexico.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		s += tr(TXT_MEXICO)
	var lebanon := ws.get_country_by_legacy_index(93)
	if ws.is_authoritarian(lebanon):
		s += tr(TXT_LEBANON)
	var france := ws.get_country_by_legacy_index(21)
	if france != null and france.sub_government == GameConstants.SubGovernment.NEO_FASCIST and _has_puppet_of(21):
		s += tr(TXT_FRANCE_PUPPETS)
	var spain := ws.get_country_by_legacy_index(85)
	if spain != null and spain.sub_government == GameConstants.SubGovernment.NEO_FASCIST and _has_puppet_of(85):
		s += tr(TXT_ITALY_PUPPETS)
	return s


func _apply_chain(trade: bool) -> void:
	_join_fxseu(8, false)
	var gdr := ws.get_country_by_legacy_index(17)
	if gdr != null and gdr.parts.size() > 0 and gdr.parts[0] and gdr.sub_government in [9, 22]:
		_join_fxseu(17, trade)
	var frg := ws.get_country_by_legacy_index(16)
	if frg != null and frg.parts.size() > 0 and frg.parts[0] and frg.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		_join_fxseu(16, trade)
	var greece := ws.get_country_by_legacy_index(45)
	if greece != null and greece.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		_join_fxseu(45, trade)
	var australia := ws.get_country_by_legacy_index(135)
	if ws.is_authoritarian(australia):
		_join_fxseu(135, trade)
	var south_africa := ws.get_country_by_legacy_index(131)
	if ws.is_authoritarian(south_africa):
		_join_fxseu(131, trade)
	var mexico := ws.get_country_by_legacy_index(140)
	if mexico != null and mexico.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		_join_fxseu(140, trade)
	var lebanon := ws.get_country_by_legacy_index(93)
	if ws.is_authoritarian(lebanon):
		_join_fxseu(93, trade)
	if _has_puppet_of(21):
		for c in ws.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.FRANCE:
				c.set_tag("fxseu", true)
	if _has_puppet_of(85):
		for c in ws.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.SPAIN:
				c.set_tag("fxseu", true)
	for idx in [92, 85, 86, 87, 21]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null:
			_leave_alliances(c)
			c.set_tag("fxseu", true)
			if trade:
				c.set_tag("对华贸易", true)


func _join_fxseu(idx: int, trade: bool) -> void:
	var c := ws.get_country_by_legacy_index(idx)
	if c == null:
		return
	if idx == 8:
		# 伊朗只在 sub==13 或 (sub==9 && puppet<0) 时加入
		if c.sub_government == GameConstants.SubGovernment.NEOPATRIARCHAL or (c.sub_government == GameConstants.SubGovernment.NEO_FASCIST and c.puppet_of < 0):
			_leave_alliances(c)
			c.set_tag("fxseu", true)
			if trade:
				c.set_tag("对华贸易", true)
		return
	_leave_alliances(c)
	c.set_tag("fxseu", true)
	if trade:
		c.set_tag("对华贸易", true)


func _has_puppet_of(overlord: int) -> bool:
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			return true
	return false


func _sub22_count(world: WorldState) -> int:
	var count := 0
	for idx in [21, 85, 86, 87, 92]:
		var c := world.get_country_by_legacy_index(idx)
		if c != null and c.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
			count += 1
	return count


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_674_hobbit_spring.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_674",
	"num": 674,
	"priority": 67400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_674_hobbit_spring.gd",
	"trigger_script": "res://数据脚本/事件效果/event_674_hobbit_spring.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
