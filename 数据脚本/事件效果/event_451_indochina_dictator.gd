extends "res://数据脚本/event_script_base.gd"

## 原作 Event451.cs：中南半岛的独裁者（柬埔寨波尔布特，二选项）。
## 触发：ReqEventForDLC02.cs:377-379 —— allcountries[23].SubGosstroy==10
##   && DATE_AFTER 1977.3.1；fire_only_once 承担 !event_done[451]。

const TXT_TITLE := "中南半岛的独裁者"
const TXT_DESC := "尽管柬埔寨共产党掌权的波尔布特集团和我们保持了良好的关系，但是他们并不太听取我们的建议。他们在柬埔寨革命后一直采取偏激的政策——宣扬大高棉主义，迫害柬埔寨的各个少数民族（包括华人），在柬越边境制造摩擦，拒绝使用货币，将人民粗暴地划分为新人和旧人，对柬共的党组织进行保密以及在国内扩大化清洗制造恐怖——这引起了党内干部和群众的不满。根据我们的情报，军队内部分军官对波尔布特集团的暴虐感到担忧；而同时，北部大区书记贵敦和东部大区书记索平正在各自组建密谋团体反对波尔布特集团，或许我们可以尝试串联他们反对波尔布特集团？"
const TXT_OPT0 := "让我们推翻波尔布特集团！"
const TXT_OPT0_DIS := "波尔布特是我们的老朋友！"
const TXT_OPT1 := "我们有波尔布特就够了。"
const TXT_OPT1_DIS := "我们不能支持独裁者！"
const TXT_R0 := "在我们的特工的帮助下，两个密谋集团实现了串联，扩大后的密谋网络联系了其他大区中对波尔布特不满的温和派干部、亲华派党员和军方反对派的成员。最后，在我们的特工从金边接出亲华派和温和派的高层干部后，柬埔寨革命共产党成立了。该组织以“结束少数民族迫害，放松政治经济控制，恢复国民经济，结束饥荒”为口号发起了一场全国大起义，起义伊始，组织就获得了大批民众、少数民族和部分干部甚至是军人的支持。在我们和越南的支援下，柬埔寨革命共产党赢得了内战。毛派分子符宁和蒲才在我们的支持下分别当选为改组后的柬共总书记和新的政府总理，并开始大规模调整国家政策。波尔布特集团被改组后的中央委员会设立的特别法庭在金边公审后枪决。由于新的柬埔寨政府有不少成员与越南方面有良好关系，也许在这种情况下，越南和柬埔寨的关系能够达成缓和？"
const TXT_R1 := "索平和贵敦各自的密谋都失败了，他们谋划的起义甚至都没有成功发动，大量被怀疑涉及此案的党员和军官都被安全部队逮捕。不满的军官多次试图暗杀波尔布特，但阴谋都被挫败了。不久后，就连以符宁为首的柬共中意识形态最接近我们的毛派分子也被清洗。波尔布特集团消灭了他们所认为的一切敌人，真正树立了他们的统治地位。柬共仍然维持着他们的偏激政策。柬埔寨领导人继续担心他们所认为的越南扩张主义；但同时，柬埔寨共产党掌权的波尔布特集团也持有大高棉主义的思想。1977年4月30日，他们对越南发动了另一次重大军事进攻。越南对柬埔寨的袭击感到震惊，于1977年底发动报复性打击，试图迫使柬埔寨政府进行谈判。越南军队于1978年1月撤出，尽管其政治目标尚未实现；柬埔寨仍然不愿意认真谈判。越南方面多次试图交流，但柬埔寨方面仍然不愿意认真谈判。我们试图开展调解双方之间关系的和平谈判，然而，两国政府未能达成妥协，双方关系仍在恶化。柬埔寨未来的命运如何，仍未可知。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or event_def.options.size() < 2:
		return
	var line56 := 0
	if world.数值表.size() > W.I_POLITICAL_LINE:
		line56 = world.数值表[W.I_POLITICAL_LINE]
	var opt := event_def.options
	if line56 < 2 or line56 > 3:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line56 == 1 or line56 == 2 or line56 == 3:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var kampuchea := _country(23)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_AGENTS, -30)
			_add(W.I_BUDGET, -30)
			if kampuchea != null:
				kampuchea.government = 1
				kampuchea.sub_government = 17
				kampuchea.stab = 1
				kampuchea.prc_power = 1000
			ws.influence_prc += 50
		1:
			context["result_text"] = TXT_R1



func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta

func _set(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta

func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"

func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null

func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n

