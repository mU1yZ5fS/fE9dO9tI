extends "res://数据脚本/event_script_base.gd"

## 原作 Event675.cs：霍比特之春（欧罗巴解放阵线成立，三选项）。
## 触发：ReqEventsDLC02.cs:1471 —— 核心条件同 674，且 sub22 国家计数 num>=3。
## 差异：isNAZIMAO→nazimao 标签；result2 中国 gov0/sub22、全非威权国清亲中/贸易/okb/econ。

const TXT_OPT2_DIS := "event.script.event_675_hobbit_spring_nazimao.c0"
const TXT_R0_FMT := "event.script.event_675_hobbit_spring_nazimao.c1"
const TXT_R1 := "event.script.event_675_hobbit_spring_nazimao.c2"
const TXT_R2_FMT := "event.script.event_675_hobbit_spring_nazimao.c3"
const TXT_GDR_9 := "event.script.event_675_hobbit_spring_nazimao.c4"
const TXT_GDR_22 := "event.script.event_675_hobbit_spring_nazimao.c5"
const TXT_FRG_10 := "event.script.event_675_hobbit_spring_nazimao.c6"
const TXT_ROMANIA := "event.script.event_675_hobbit_spring_nazimao.c7"
const TXT_YUGOSLAVIA := "event.script.event_675_hobbit_spring_nazimao.c8"
const TXT_LIBYA := "event.script.event_675_hobbit_spring_nazimao.c9"
const TXT_ZAIRE := "event.script.event_675_hobbit_spring_nazimao.c10"
const TXT_RWANDA := "event.script.event_675_hobbit_spring_nazimao.c11"
const TXT_EQ_GUINEA := "event.script.event_675_hobbit_spring_nazimao.c12"
const TXT_FRANCE_PUPPETS := "event.script.event_675_hobbit_spring_nazimao.c13"
const TXT_ITALY_PUPPETS := "event.script.event_675_hobbit_spring_nazimao.c14"


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
	var text := ""
	match opt:
		0: text = tr(TXT_R0_FMT).replace("{0}{1}", _leader_name())
		1: text = tr(TXT_R1)
		2: text = tr(TXT_R2_FMT).replace("{0}{1}", _leader_name())
	text += _chain_text(opt)
	_apply_chain(opt)
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
			china.set_tag("nazimao", true)
			china.government = GameConstants.Government.AUTHORITARIAN
			china.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
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
	return _sub22_count(world) >= 3


func _chain_text(opt: int) -> String:
	var s := ""
	var gdr := ws.get_country_by_legacy_index(17)
	if gdr != null and gdr.parts.size() > 0 and gdr.parts[0]:
		if gdr.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
			s += tr(TXT_GDR_9)
		elif gdr.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
			s += tr(TXT_GDR_22)
	var frg := ws.get_country_by_legacy_index(16)
	if frg != null and frg.parts.size() > 0 and frg.parts[0] and frg.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		s += tr(TXT_FRG_10)
	var romania := ws.get_country_by_legacy_index(5)
	if romania != null and romania.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		s += tr(TXT_ROMANIA)
	var yugoslavia := ws.get_country_by_legacy_index(15)
	if yugoslavia != null and yugoslavia.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		s += tr(TXT_YUGOSLAVIA)
	var libya := ws.get_country_by_legacy_index(13)
	var libya_ok := libya != null and libya.puppet_of < 0 \
		and (libya.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or libya.sub_government == GameConstants.SubGovernment.PRAGMATIST)
	if libya_ok and (opt != 0 or (libya != null and not (libya.parts.size() > 0 and libya.parts[0]))):
		s += tr(TXT_LIBYA)
	var zaire := ws.get_country_by_legacy_index(117)
	var usa_power := ws.empires[EmpireData.USA].power if ws.empires.size() > EmpireData.USA \
		and ws.empires[EmpireData.USA] != null else 0
	if zaire != null and zaire.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN and usa_power <= 0:
		s += tr(TXT_ZAIRE)
	var rwanda := ws.get_country_by_legacy_index(120)
	if rwanda != null and (rwanda.sub_government == GameConstants.SubGovernment.NEO_FASCIST or rwanda.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN):
		s += tr(TXT_RWANDA)
	var eq_guinea := ws.get_country_by_legacy_index(115)
	if eq_guinea != null and eq_guinea.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		s += tr(TXT_EQ_GUINEA)
	var france := ws.get_country_by_legacy_index(21)
	if france != null and france.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST and _has_puppet_of(21):
		s += tr(TXT_FRANCE_PUPPETS)
	var spain := ws.get_country_by_legacy_index(85)
	if spain != null and spain.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST and _has_puppet_of(85):
		s += tr(TXT_ITALY_PUPPETS)
	return s


func _apply_chain(opt: int) -> void:
	var gdr := ws.get_country_by_legacy_index(17)
	if gdr != null and gdr.parts.size() > 0 and gdr.parts[0] and gdr.sub_government in [9, 22]:
		_join_nazimao(17)
	var frg := ws.get_country_by_legacy_index(16)
	if frg != null and frg.parts.size() > 0 and frg.parts[0] and frg.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		_join_nazimao(16)
	var romania := ws.get_country_by_legacy_index(5)
	if romania != null and romania.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		_join_nazimao(5)
	var yugoslavia := ws.get_country_by_legacy_index(15)
	if yugoslavia != null and yugoslavia.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		_join_nazimao(15)
	var libya := ws.get_country_by_legacy_index(13)
	var libya_ok := libya != null and libya.puppet_of < 0 \
		and (libya.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or libya.sub_government == GameConstants.SubGovernment.PRAGMATIST)
	if libya_ok and (opt != 0 or (libya != null and not (libya.parts.size() > 0 and libya.parts[0]))):
		_join_nazimao(13)
	var zaire := ws.get_country_by_legacy_index(117)
	var usa_power := ws.empires[EmpireData.USA].power if ws.empires.size() > EmpireData.USA \
		and ws.empires[EmpireData.USA] != null else 0
	if zaire != null and zaire.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN and usa_power <= 0:
		_join_nazimao(117)
	var rwanda := ws.get_country_by_legacy_index(120)
	if rwanda != null and (rwanda.sub_government == GameConstants.SubGovernment.NEO_FASCIST or rwanda.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN):
		_join_nazimao(120)
	var eq_guinea := ws.get_country_by_legacy_index(115)
	if eq_guinea != null and eq_guinea.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		_join_nazimao(115)
	if _has_puppet_of(21):
		for c in ws.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.FRANCE:
				c.set_tag("nazimao", true)
	if _has_puppet_of(85):
		for c in ws.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.SPAIN:
				c.set_tag("nazimao", true)
	for idx in [92, 85, 86, 87]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null:
			_leave_alliances(c)
			c.set_tag("nazimao", true)
			c.set_tag("对华贸易", true)
	var france := ws.get_country_by_legacy_index(21)
	if france != null:
		_leave_alliances(france)
		if opt == 2:
			france.set_tag("亲中", true)
		france.set_tag("nazimao", true)
		france.set_tag("对华贸易", true)


func _join_nazimao(idx: int) -> void:
	var c := ws.get_country_by_legacy_index(idx)
	if c != null:
		_leave_alliances(c)
		c.set_tag("nazimao", true)


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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_675_hobbit_spring_nazimao.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_675",
	"num": 675,
	"priority": 67500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_675_hobbit_spring_nazimao.gd",
	"trigger_script": "res://数据脚本/事件效果/event_675_hobbit_spring_nazimao.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
