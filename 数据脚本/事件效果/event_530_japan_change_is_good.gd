extends "res://数据脚本/event_script_base.gd"

## 原作 Event530.cs：变则善，常变则至善（3选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "没人对他们有兴趣"
const TXT_OPT1_DIS := "没人对他们有兴趣"
const TXT_R0_A := "社会党背后的靠山——日本最大的左翼工会“总评”在“劳资调和”构想盛行以及企业工人群体日益现实主义化的背景下不断向社会党施压，要求其做出“真正的改变”。同时借助亲华的佐佐木派，我们派遣人员成功说服了社会党中央的大多数委员。而公明党和民主社会党在由于先前的援助，与我们的关系已经拉近，在与两党委员长多次沟通之后，它们也同意与改革后的社会党保持步调一致。\n不久，社会党召开了一次临时党代会，并以大比例优势通过了《日本社会党的新宣言——爱、知、力的创造》这一全新纲领，正式抛弃了旧有的《日本通向社会主义之路》。新纲领强调“和平长入社会主义”以及市民与国民的概念，事实否认了“阶级性”的理念。这标志着社会党第一次完全抛弃了马克思主义，踏入到社会民主主义的行列中。\n社会党党大会后不久，其与公明党和民主社会党在东京召开了一次联合会议并达成协议：三党以“中道革新”“国民先锋”为口号，正式合并为日本社会民主党，打出了“终结自民党垄断，建立符合国民需求的革新政权”的旗帜，以社会民主主义与护宪平和主义（当然对其中的自卫队问题、朝鲜半岛问题等进行了修订）为指导思想。很快，社会民主联合也宣布加入该党。\n日本媒体对于三党合并的消息感到惊讶。对于这一联盟在接下来的选举中能取得怎样的成绩也有不同的看法。但是对市民阶层而言，一个更具新时代革新色彩，提倡福利政策且并非传统“工会斗士”的左翼政党显然还是很对他们的胃口的。一些报纸已经开始预测在下一届国会选举中，社会民主党有望打破自由民主党的垄断地位。"
const TXT_R1_A := "我们派出大量人员与共产党和社会党的中央委员进行沟通。在我们此前长期的积极行动下，绝大部分社会组织、青年活动家和工会干部都成功被我们团结了起来，借助他们的影响力以及此前与两党打下的关系基础，我们最终说服了大多数中央委员，尤其是共产党领导人宫本显治。\n不久，日本共产党与日本社会党召开了一次联合大会，会上宫本显治正式宣布将成立以两党为核心，囊括大批社会团体的“日本人民民主联合阵线”，以寻求“超越思想、信仰和政党支持的差异，汇集大多数人民的革新运动”为目标，在全国范围内树立新的创新阵线。社会党委员长飞鸟田一雄也宣布将与共产党步调一致。总的来说，该阵线的方针是以欧洲共产主义的思想为核心，并囊括了非武装中立、无核化政策等理念。\n日本媒体对于两党联盟的消息感到惊讶。对于这一联盟在接下来的选举中能取得怎样的成绩也有不同的看法。但是对市民阶层而言，一个更具新时代革新色彩，提倡福利政策且并非传统“工会斗士”的左翼联盟至少是可接受的。一些报纸已经开始预测在下一届国会选举中，日本人民民主联合阵线有望打破自由民主党的垄断地位。"
const TXT_R2_A := "社会党背后的靠山——日本最大的左翼工会“总评”在“劳资调和”构想盛行以及企业工人群体日益现实主义化的背景下不断向社会党施压，要求其做出“真正的改变”。在飞鸟田一雄的带领下，社会党也最终完全抛弃了“社共共斗”转而一心建设“社公民路线”。但在党内纷争依旧且与其他在野党摩擦不断的情况下，大部分媒体对该路线并不乐观。社会党“万年在野党”的尴尬名头还将持续下去。而随着国际局势的变化，甚至社会党能否继续维持国会第二大党都成了一个问题，特别是在工会不再单独支持社会党的情况下。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if ws.political_line == 3 and int(ws.completed_event_ids.get("event_522", 0)) == 1 and int(ws.completed_event_ids.get("event_527", 0)) == 1 and int(ws.completed_event_ids.get("event_525", 0)) != 1 and int(ws.completed_event_ids.get("event_526", 0)) != 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if ws.political_line == 2 and int(ws.completed_event_ids.get("event_522", 0)) == 1 and int(ws.completed_event_ids.get("event_527", 0)) == 2 and int(ws.completed_event_ids.get("event_525", 0)) != 1 and int(ws.completed_event_ids.get("event_526", 0)) != 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			_add(8, -(100))
			_add(9, -(100))
			_add(1, 80)
			_add(3, 50)
			_add(4, 50)
			_add(6, 5)
			ws.influence_prc += 10
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(100))
			_add(9, -(100))
			_add(1, 80)
			_add(3, 50)
			_add(4, 50)
			_add(6, 5)
			ws.influence_prc += 10
		2:
			context["result_text"] = TXT_R2_A

func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _office_name(pos: int) -> String:
	if ws != null and ws.politics_positions.size() > pos:
		var pi: int = ws.politics_positions[pos]
		if pi >= 0 and pi < ws.politicians.size():
			var p: PoliticianData = ws.politicians[pi]
			if p != null and p.name_display != "":
				return p.name_display
	return "华国锋"


func _event_result(event_id: String) -> int:
	return ws.completed_event_ids.get(event_id, -1)


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() 		and ws.modifiers[index] != null and ws.modifiers[index].is_active


## GameState.cs:4934-5028 ChineseSubGosstroy 完整移植（同 Event713）。
func _chinese_sub_government() -> int:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return 13
	if d.size() <= W.I_TERRITORY:
		return 13
	var data := d
	var result := 13
	if china.government == GameConstants.Government.AUTHORITARIAN:
		if _event_result("event_674") == 2:
			result = 9
		elif china.has_tag("nazimao"):
			result = 22
		elif ws.completed_event_ids.has("event_912") and _event_result("event_912") == 0:
			result = 19
		elif data.party_system == 8:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif data.ideology <= 2 and data.econ_system < 13 				and data.diplomatic_reputation >= 700 and data.party_system < 8 				and _mod_active(6) and _mod_active(3):
			result = 0
		elif (data.econ_system >= 13 and data.war_support >= 700 and not _mod_active(6)) 				or _mod_active(38):
			result = 9
		elif data.econ_system <= 13 and data.war_support >= 700 				and data.diplomatic_reputation >= 700 and (_mod_active(6) or _mod_active(3)):
			result = 10
		elif data.econ_system >= 13 and not _mod_active(6):
			result = 7
		else:
			result = 13
	elif china.government == GameConstants.Government.SOCIALIST:
		if _mod_active(49):
			result = 18
		elif _mod_active(6) and _mod_active(3) and data.party_system <= 7 				and data.econ_system <= 12 and data.religion_policy <= 25:
			result = 17
		elif data.ideology == 1 and not _mod_active(6) and data.religion_policy <= 26:
			result = 16
		elif data.econ_system < 13 and data.press_policy >= 17 				and data.ideology == 1 and data.religion_policy <= 26:
			result = 2
		else:
			result = 1
	elif china.government == GameConstants.Government.REFORMIST:
		if _mod_active(40):
			result = 8
		elif data.ideology >= 2 and data.econ_system >= 13 				and data.diplomatic_reputation <= 700 and data.party_system >= 8 				and data.press_policy >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data.ideology <= 3 and data.econ_system >= 12 				and data.econ_system <= 13 and data.diplomatic_reputation >= 300 				and data.territory_policy > 21 and data.war_support >= 700:
			result = 11
		elif data.ideology <= 3 and data.econ_system <= 14 				and data.diplomatic_reputation >= 500 and data.econ_system > 11 				and data.war_support >= 400:
			result = 8
		elif data.ideology <= 3 and data.econ_system <= 13 				and data.press_policy > 17:
			result = 3
		elif data.party_system <= 8 				and (data.econ_system == 13 or data.econ_system == 12) 				and data.war_support < 700 and not _mod_active(3) 				and data.press_policy >= 17:
			result = 21
		else:
			result = 15
	elif china.government != GameConstants.Government.LIBERAL:
		result = 13
	elif data.econ_system <= 13 and data.diplomatic_reputation >= 500:
		result = 4
	elif (data.party_system <= 8 and data.press_policy <= 18) 			or data.war_support >= 700:
		result = 12
	elif data.econ_system > 13 and data.diplomatic_reputation < 700:
		result = 6
	else:
		result = 5
	return result


func _tech(idx: int) -> bool:
	return ws != null and ws.techs != null and idx >= 0 and idx < ws.techs.unlocked.size() and ws.techs.unlocked[idx]


func _mod(idx: int) -> bool:
	return ws != null and idx >= 0 and idx < ws.modifiers.size() and ws.modifiers[idx].is_active


func _empire_rel(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].relations
	return 0


func _empire_power(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0


func _cf(idx: int, field: String) -> int:
	var c := ws.get_country_by_legacy_index(idx)
	if c == null:
		return 0
	match field:
		"Gosstroy": return c.government
		"SubGosstroy": return c.sub_government
		"dev": return c.development
		"spec": return c.special
		"soc_stab": return c.social_stability
		"stab": return c.stab
		"puppetOf": return c.puppet_of
		"prcpower": return c.prc_power
		"prcinfl": return c.prc_influence
	return 0


func _tag(idx: int, tag: String) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)
