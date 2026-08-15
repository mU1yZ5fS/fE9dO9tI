extends "res://数据脚本/event_script_base.gd"

## 原作 Event121.cs：新喇嘛（3 选项）。
## 触发：由 Decision(GlobalScript.cs:21) 手动触发（西藏自治路线），原版无自动条件；
## 故 trigger_conditions 为空，本脚本按原版复刻选项显隐与结果效果。

const TXT_TITLE := "新喇嘛"
const TXT_DESC := "既然已经决定做出准许西藏拥有特别自治权这样的历史性妥协，我们就得好好挑选西藏的政教领袖，确立其地位。如依照藏传佛教教规教义，我们可从三个候选人中择一而取：十世班禅，处于控制下的喇嘛人选，他被我们软禁过一段时间，后来娶了位汉族妻子；流亡的十四世达赖，老反贼了，逃亡印度的他于政治上十分活跃，长久以来也一直觊觎着这个位置；最后一位，苏维埃化的韩波喇嘛，苏联佛教徒的精神领袖，积极致力于佛学院组织的和平发展。第一位人选我们无需过多担心，第三位人选风险在于其可能倒向苏联，而最冒险的是第二位人选——尽管达赖喇嘛声称他只主张自治而不是分裂主义，但他与某些政治异见者甚至美国政客都有着长期的接触。一切选择都取决于你。"
const TXT_OPT0 := "我们的十世班禅"
const TXT_OPT1 := "流亡海外的十四世达赖"
const TXT_OPT2 := "苏维埃的韩波喇嘛"
const TXT_OPT0_DIS := "已达成协定或已平反确吉坚赞"
const TXT_OPT1_DIS := "没有毛主义，没有文化大革命，国际声誉＜40.0"
const TXT_OPT2_DIS := "是经互会的观察国或成员国"
const TXT_R0 := "第十世班禅喇嘛早先得到了周恩来夫人和邓小平夫人的特别支持，她们尤为看重这样一个绝佳的政治机遇，可以促进藏族喇嘛和汉族姑娘联姻。坚赞随后成为全国人大代表，并升任全国人大常委会委员。他确实是领导西藏自治政府最安全的选择。他完全忠于政府，且潜心于修缮老旧佛寺、安葬佛教僧侣和扩大佛学院规模。总而言之，西藏的一切都很平静。"
const TXT_R1 := "十四世达赖在潜逃欧洲后，试图将自己塑造成纳粹政府治下的逃脱者，他背井离乡，很快就成了西藏流亡政府的一块狗头招牌。尽管如此，作为一名反华异见分子，他也只主张过西藏未来应当实行自治。我党代表的接触意向让他惊骇不已，但通过冗长而坎坷的谈判，我们设法达成了妥协：他将解散流亡政府，并承认中央政府，与之相应，他可以作为西藏自治区的政教领袖而存在，并让其口无遮拦或公然支持分裂的所谓盟友一直流亡下去。新的地方政府虽不忠于我们，但足够温和，我们可以试着利用这玩意儿达成一些其他目的。"
const TXT_R2_BEFORE := "我们一致认为第十九世班智达·韩波喇嘛，占布拉·多吉·贡布耶夫是最合适西藏的精神领袖。他在卫国战争期间曾英勇作战，是亚洲佛教和平会议的创始人之一，推动建立了乌兰巴托佛教大学，也主要负责建设了伊沃尔金喇嘛寺建筑群，还曾为恢复修缮被毁寺庙向苏联政府请愿。在成为西藏的精神与政治领袖后，他在擢拔了一批信仰平和，同时思想开明的当地藏人，并开始实施一项计划，在西藏各地发展宗教和教育机构。新的喇嘛尤为注重同贫困、愚昧，以及与旧西藏的封建残余作斗争。"
const TXT_R2_AFTER := "我们一致认为第二十世班智达·韩波喇嘛，占巴·扎木苏·额尔敦涅夫是西藏最合适的精神领袖。在经历了斯大林时代的镇压后，他没有成为反苏派或持不同政见者，而是去做了图书馆管理员，自行精进宗教与世俗理念的学习。作为新的韩波喇嘛，他因其博学和对宗教论著的出色理解而受到广泛尊重，他积极参加亚洲佛教和平会议，加入了苏联和平委员会。作为西藏的精神和政治领袖，他不仅积极帮助该地区的宗教和教育机构发展，还吸引藏人参加苏联和平基金会，特别是在西藏境内为来自世界各地的战争和冲突的受害者建立了慈善总部。中国领导人可以为自己对拯救人文的贡献感到自豪。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var tibet := world.get_country_by_legacy_index(69)
	var soviet := world.get_country_by_legacy_index(7)
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	var num := 0
	if tibet != null and tibet.special_ending == 33:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
		num += 1
	if world.数值表[W.I_DIPLO] <= 400 and not _modifier_active(6) and not _modifier_active(3):
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
		num += 1
	if (soviet != null and soviet.has_tag("对华贸易")) or (china != null and china.has_tag("sev")) or num >= 2:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int, active: bool) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var tibet := ws.get_country_by_legacy_index(69)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if tibet != null:
				tibet.special_ending = 0
			_set_modifier_active(18, true)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_AGENTS, -50)
			_add(W.I_WAR_SUPPORT, -250)
			_add(W.I_INFLUENCE, 15)
			_add_relation(EmpireData.USA, 500)
			_add_power(EmpireData.USA, 25)
			_set_modifier_active(19, true)
			if tibet != null:
				tibet.special_ending = 1
			context["result_text"] = TXT_R1
		2:
			if d[W.I_YEAR] < 1982:
				_add_power(EmpireData.USSR, 25)
				_add(W.I_LIVING, 25)
				context["result_text"] = TXT_R2_BEFORE
			else:
				_add_power(EmpireData.USSR, 50)
				_add(W.I_INFLUENCE, 5)
				context["result_text"] = TXT_R2_AFTER
			_add(W.I_ARMY, -50)
			_add(W.I_WAR_SUPPORT, -50)
			_add(W.I_AGENTS, 25)
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, 500)
			_set_modifier_active(20, true)
			if tibet != null:
				tibet.special_ending = 2

