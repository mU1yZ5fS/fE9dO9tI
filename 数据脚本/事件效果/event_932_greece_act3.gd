extends "res://数据脚本/event_script_base.gd"

## 原作 Event932.cs：民主的故乡——第三幕（希腊大选终局，四选项）。 ## 触发：TimeScript.cs:10780-10786 —— ##   ((日>=2 且 月>=6 且 年>=1985) (月>=7 且 年>=1985) 年>=1986) ##   && c45.Gosstroy!=0。 ## 差异： ##  - num/num2/num3 计分逐项移植（含 now_leader → current_leader、 ##    isSocEU → soc_eu 标签、c20.spec → special）。 ##  - result93==0 双文本、PASOK 连任两文本、SocEU 追加文本逐字保留。

const TXT_KKE_A := "event.script.event_932_greece_act3.c0"

const TXT_KKE_B := "event.script.event_932_greece_act3.c1"

const TXT_KKE_C := "event.script.event_932_greece_act3.c2"

const TXT_KKE_D := "event.script.event_932_greece_act3.c3"

const TXT_KKE_E := "event.script.event_932_greece_act3.c4"

const TXT_LEFT_UNION := "event.script.event_932_greece_act3.c5"

const TXT_PASOK_2 := "event.script.event_932_greece_act3.c6"

const TXT_PASOK_3 := "event.script.event_932_greece_act3.c7"

const TXT_SOCEU_EXTRA := "event.script.event_932_greece_act3.c8"

const TXT_RIGHT := "event.script.event_932_greece_act3.c9"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var result93: int = world.completed_event_ids.get("event_093", -1)
	if result93 != 0:
		event_def.description = "泛希腊社会主义运动与新民主党的竞争仍在继续。PASOK仍然希望维持民主社会主义，并开始修订宪法，将希腊彻底转向议会共和制，左翼选民的壮大使得他们仍有希望执政；新民主党继续支持着他们的亲西方的自由主义政策。当然，希腊共产党的影响力较大，但希腊的左翼生态位已经被PASOK占领，他们已不具有掌权希望。国际形势的变化将会影响此次大选……"
	else:
		event_def.description = "希腊左翼联盟对左翼改革的程度产生了矛盾，内部各党对施政方针已经有了不同的见解，此前的共同执政的情况大概已经无法维持了。希腊共产党希望进行更加深入的社会主义改革，并结束中立政策，与各个社会主义国家加深合作；泛希腊社会主义运动则希望搞“民主的社会主义”，拒绝“极权主义”并维持中立；联盟中力量较小的派系，如希腊共产党（国内派）希望遵循欧洲共产主义，但是他们没有单独参选或执政的基础。当然，右翼政党也可能借助左翼分裂的背景而卷土重来。在大选的背景下，左翼联盟是否还能存续？"
	var agents := world.agents if world.size() > W.I_AGENTS else 0
	var opt := event_def.options
	if agents >= 40:
		_enable(opt[0], "支持希腊共产党")
	else:
		_disable(opt[0], "我们没有足够的力量")
	if agents >= 40:
		_enable(opt[1], "支持泛希腊社会主义运动")
	else:
		_disable(opt[1], "我们没有足够的力量")
	if agents >= 40:
		_enable(opt[2], "支持新民主党")
	else:
		_disable(opt[2], "我们没有足够的力量")
	_enable(opt[3], "不闻不问")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var _greece := ws.get_country_by_legacy_index(45)
	var result93: int = ws.completed_event_ids.get("event_093", -1)
	var num := 0
	var num2 := 0
	var num3 := 0
	if opt == 0:
		num += 1
	elif opt == 1:
		num2 += 1
	elif opt == 2:
		num3 += 1
	for idx in [21, 85, 86, 87, 92]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null and ws.is_socialism(c, true):
			num += 1
	if _ussr_power() >= _usa_power():
		num += 1
	var hungary := ws.get_country_by_legacy_index(4)
	if hungary != null and ws.is_socialism(hungary, true) and not hungary.has_tag("亲苏"):
		num += 1
	var c2 := ws.get_country_by_legacy_index(2)
	if c2 != null and c2.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
		num += 1
	if _empire_leader(0) == 0:
		num -= 1
	if _ussr_power() < _usa_power():
		num -= 1
	if _parts0(20):
		num -= 2
	var c84 := ws.get_country_by_legacy_index(84)
	if c84 != null and c84.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		num -= 1
	if ws.completed_event_ids.get("polish_crisis", -1) == 4:
		num -= 1
	if result93 == 0:
		num += 1
	for idx in [21, 85, 86, 87, 92]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null and c.government == GameConstants.Government.REFORMIST:
			num2 += 1
	if _ussr_power() >= _usa_power():
		num2 += 1
	if hungary != null and hungary.government == GameConstants.Government.REFORMIST:
		num2 += 1
	var c15 := ws.get_country_by_legacy_index(15)
	if c15 != null and c15.sub_government == GameConstants.SubGovernment.TITOIST:
		num2 += 1
	if _parts0(20):
		num2 -= 1
	var c21 := ws.get_country_by_legacy_index(21)
	if c21 != null and c21.has_tag("soc_eu"):
		num2 += 114514
	if _empire_leader(0) == 0:
		num2 -= 1
	if result93 == 0:
		num2 += 2
	for idx in [21, 85, 86, 87, 92]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null and (c.government == GameConstants.Government.LIBERAL or ws.is_authoritarian(c)):
			num3 += 1
	if _ussr_power() < _usa_power():
		num3 += 1
	if hungary != null and hungary.has_tag("亲苏"):
		num3 += 1
	if ws.completed_event_ids.get("polish_crisis", -1) == 4:
		num3 += 1
	if _parts0(20):
		num3 += 1
	if _empire_leader(0) == 0:
		num3 += 2
	if c84 != null and c84.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		num3 += 1
	if num >= num2 and num >= num3:
		_branch_kke(context, opt)
	elif num2 >= num and num2 >= num3:
		_branch_pasok(context)
	else:
		_branch_right(context)


func _branch_kke(context: Dictionary, opt: int) -> void:
	var greece := ws.get_country_by_legacy_index(45)
	var ussr_leader := _empire_leader(1)
	if ussr_leader != 6 and ussr_leader != 7:
		_greece_to(1, 2)
		if greece != null:
			greece.set_tag("亲苏", true)
		_ussr_leader_add(4, 1)
		_add_power(EmpireData.USA, -50)
		_add_power(EmpireData.USSR, 50)
		if greece != null:
			greece.内战中 = false
		context["result_text"] = tr(TXT_KKE_A)
	elif ussr_leader == 6 and opt == 0:
		_greece_to(1, 2)
		if greece != null:
			greece.set_tag("亲中", true)
			var cyprus := ws.get_country_by_legacy_index(94)
			if cyprus == null or not cyprus.内战中:
				greece.set_tag("对华贸易", true)
		var albania := ws.get_country_by_legacy_index(20)
		if albania != null and albania.special == 1 and greece != null:
			greece.set_tag("balecon", true)
		_add_power(EmpireData.USA, -50)
		if greece != null:
			greece.内战中 = false
		ws.influence_prc += 50
		context["result_text"] = tr(TXT_KKE_B)
	elif ussr_leader == 7 and opt == 0:
		_greece_to(1, 2)
		var cyprus := ws.get_country_by_legacy_index(94)
		if greece != null and (cyprus == null or not cyprus.内战中):
			greece.set_tag("亲中", true)
			greece.set_tag("对华贸易", true)
		var albania := ws.get_country_by_legacy_index(20)
		if albania != null and albania.special == 1 and greece != null:
			greece.set_tag("balecon", true)
		_add_power(EmpireData.USA, -50)
		if greece != null:
			greece.内战中 = false
		ws.influence_prc += 50
		context["result_text"] = tr(TXT_KKE_C)
	elif ussr_leader == 6:
		_greece_to(1, 2)
		_add_power(EmpireData.USA, -50)
		if greece != null:
			greece.内战中 = false
		context["result_text"] = tr(TXT_KKE_D)
	elif ussr_leader == 7:
		_greece_to(1, 2)
		_add_power(EmpireData.USA, -50)
		if greece != null:
			greece.内战中 = false
		context["result_text"] = tr(TXT_KKE_E)


func _branch_pasok(context: Dictionary) -> void:
	var greece := ws.get_country_by_legacy_index(45)
	var result93: int = ws.completed_event_ids.get("event_093", -1)
	if result93 == 0:
		_greece_to(2, 3)
		context["result_text"] = tr(TXT_LEFT_UNION)
	else:
		var text := tr(TXT_PASOK_2)
		if greece != null and greece.government == GameConstants.Government.LIBERAL:
			text = tr(TXT_PASOK_3)
		_greece_to(2, 3)
		if greece != null:
			greece.内战中 = false
		var c21 := ws.get_country_by_legacy_index(21)
		if c21 != null and c21.has_tag("soc_eu"):
			text += tr(TXT_SOCEU_EXTRA)
			if greece != null:
				greece.set_tag("soc_eu", true)
		context["result_text"] = text


func _branch_right(context: Dictionary) -> void:
	var greece := ws.get_country_by_legacy_index(45)
	if greece != null:
		greece.government = GameConstants.Government.LIBERAL
		greece.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		_leave_alliances(greece)
		greece.内战中 = false
		greece.set_tag("亲美", true)
		var france := ws.get_country_by_legacy_index(0)
		if france != null and france.has_tag("eu"):
			greece.set_tag("eu", true)
		if france != null and france.has_tag("nato"):
			greece.set_tag("nato", true)
	context["result_text"] = tr(TXT_RIGHT)


func _greece_to(government: int, sub: int) -> void:
	var greece := ws.get_country_by_legacy_index(45)
	if greece != null:
		greece.government = government
		greece.sub_government = sub
		_leave_alliances(greece)



func _parts0(legacy_index: int) -> bool:
	var c := ws.get_country_by_legacy_index(legacy_index)
	return c != null and c.parts.size() > 0 and c.parts[0]


func _empire_leader(empire_index: int) -> int:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		return ws.empires[empire_index].current_leader
	return -1


func _usa_power() -> int:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		return ws.empires[EmpireData.USA].power
	return 0


func _ussr_power() -> int:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		return ws.empires[EmpireData.USSR].power
	return 0


func _ussr_leader_add(index: int, delta: int) -> void:
	if ws.empires.size() <= EmpireData.USSR or ws.empires[EmpireData.USSR] == null:
		return
	var leaders: Array[EmpireLeader] = ws.empires[EmpireData.USSR].leaders
	if index >= 0 and index < leaders.size() and leaders[index] != null:
		leaders[index].support += delta






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_932_greece_act3.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_932",
	"nodesc": true,
	"num": 932,
	"priority": 9320,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_932_greece_act3.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1985.6.2"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "government", "target": "45"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
