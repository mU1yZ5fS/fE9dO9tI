extends "res://数据脚本/event_script_base.gd"

## 原作 Event440.cs：黎巴嫩，你可还好（4选项）。
## 触发：无自动触发点（trigger_conditions=[]）。DiploButtonScript.cs:11396-11399 this_type==1002 手动 number_event=440；3669 为外交按钮条件引用。
## 差异：选项显隐 prepare 动态改写；result 3 的 event_done[440]=false → completed_event_ids.erase("event_440")
##   （引擎会在选项执行后重新 _mark_done 当前事件，此重置仅作源码等价标记；手动触发走 can_trigger 不受影响）。



const TXT_OPT0_DIS := "巴勒斯坦人不会离开"
const TXT_OPT1_DIS_0 := "黎巴嫩人民的幸福不能依赖于一帮军阀"
const TXT_OPT1_DIS_ELSE := "你说，最初是哪个国家最先干涉黎巴嫩内战呢？"
const TXT_OPT2_DIS := "这场战争不就是左派挑起的？"

const TXT_R0 := "最终，疲惫的内战各方达成在我们和叙利亚的协调下达成了和解共识，并签署了各民族和平条约。马龙派为主的黎巴嫩阵线作出了更多的妥协，修改了原本55：45的议会席位分配，穆斯林群体得以享有和基督徒平等的政治权利。原本受总统任命的穆斯林总理拥有了更大权力，且只对立法机关负责。真主党、亚美尼亚革命同盟一系列少数群体反对派得到了席位配额，而阿迈勒运动与进步社会党更是在国民议会和部长会议中与黎巴嫩力量三分天下。少数极端组织——如雪松卫士相当不满意于这种妥协，但总体上各个势力满意于这种贝鲁特精神和谢哈布政策的进一步发展。总统阿明杰马耶勒、议会议长纳比贝里还有德鲁兹人首领小琼布拉特被诺贝尔和平奖提名，“东方瑞士”继续走在摒弃宗派分歧、道阻且长的阿拉伯团结之路上，而象征宁静的瑞雪已然映照在这片紫色发源地。应该吧？"
const TXT_R1 := "受复兴党人、巴解组织还有部分共产主义者支持的黎巴嫩全国抵抗阵线凭借着相比黎巴嫩阵线数倍的武装力量，在我们的支持下一鼓作气地打进了马龙斯坦，东贝鲁特的马龙派民兵由于以色列支持很快兵败如山倒，被全国运动的人民解放军和巴解组织尽数屠杀。而随着基督徒总部的沦陷，大部分马龙派民兵放下武器选择投降。\n最终，新政府以德鲁兹人的进步社会党、逊尼派的独立纳赛尔运动和什叶派的阿迈勒运动为三柱石，宣布黎巴嫩将成为一个更加“阿拉伯”和宗教宽容的地区。腓尼基概念将不再留存于黎巴嫩之国家构建，而马龙派也必须从高高在上的地位下来，向什叶派、德鲁兹派甚至是亚美尼亚人交出权力。以“新腓尼基人”为代表的马龙派商业精英纷纷落马，其资产和金融机构被执行强行国有化。新总统琼布拉特领导着有史以来第一个非基督徒主导的内阁，着手于打击传统政治势力——祖阿玛以及推行温和的土改政策，以求尽可能地转变先前新自由主义的马龙派政策。进步社会党是否真能给这个“只有政治商人”的腐朽国家带来新生，让我们拭目以待……"
const TXT_R2 := "自卡迈佩·琼布拉特被暗杀后，接手黎巴嫩全国运动的卡迈佩之子瓦利德·琼布拉特对左翼思想以及处于贫困中的什叶派群体并不感兴趣，实际上由于其狭隘的德鲁兹至上情结，将大量的什叶派远离了抵抗阵线而转向阿迈勒运动和真主党，使得全国运动名存实亡。而整个进步社会党和人民解放军更是变成琼布拉特家族一人的资产。显然，德不配位的小琼布拉特压根不该坐在黎巴嫩左翼抵抗派的领袖席上，是时候清除这个背叛父辈与信仰的投机政客了！\n在我们特勤的运作下，党内的左翼和纳赛尔主义者发起了一场政变，瓦利德由于“保守、不思进取、豢养私兵”等错误被开除出党，而他父亲的老朋友、更为坚定的纳赛尔主义者法耶兹法吉赫被推举出作党的领导。恢复左翼立场的进步社会党很快加强了与黎巴嫩共产党、阿拉伯社会主义行动党、共产主义行动组织以及巴勒斯坦方人阵民阵的合作。重新团结一致的左翼力量很快将马龙派“双头同盟”及盟友打倒在地，社会主义的红旗高高挂在巴卜达宫,宣告着将近十年的内战以共产主义者的胜利而结束。"
const TXT_R3 := "“你要上黎巴嫩哀号，在巴珊扬声，从亚巴琳哀号，因为你所亲爱的都毁灭了。”——耶利米书22:20"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var syria := world.get_country_by_legacy_index(35)
	var opt := event_def.options
	if data[W.I_PALESTINE_STATUS] >= 2 and syria != null and syria.has_tag("亲中"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if data[W.I_POLITICAL_LINE] >= 1 and data[W.I_POLITICAL_LINE] <= 2:
		_enable(opt[1], event_def.options[1].text)
	elif data[W.I_POLITICAL_LINE] == 0:
		_disable(opt[1], TXT_OPT1_DIS_0)
	else:
		_disable(opt[1], TXT_OPT1_DIS_ELSE)
	if data[W.I_POLITICAL_LINE] <= 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var lebanon := ws.get_country_by_legacy_index(93)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			ws.influence_prc += 20
			_add(W.I_AGENTS, -30)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -100)
			_add_power(EmpireData.USA, 20)
			_add_power(EmpireData.USSR, -20)
			if lebanon != null:
				lebanon.set_tag("对华贸易", true)
				lebanon.government = GameConstants.Government.LIBERAL
				lebanon.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			context["result_text"] = TXT_R0
		1:
			_add(W.I_AGENTS, -50)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			_add_power(EmpireData.USA, -20)
			_add_power(EmpireData.USSR, -20)
			if lebanon != null:
				lebanon.set_tag("对华贸易", true)
				lebanon.government = GameConstants.Government.REFORMIST
				lebanon.sub_government = GameConstants.SubGovernment.PRAGMATIST
			context["result_text"] = TXT_R1
		2:
			_add(W.I_AGENTS, -50)
			ws.influence_prc += 50
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
			_add_power(EmpireData.USA, -50)
			_add_power(EmpireData.USSR, -50)
			if lebanon != null:
				lebanon.set_tag("对华贸易", true)
				lebanon.set_tag("亲中", true)
				lebanon.government = GameConstants.Government.SOCIALIST
				lebanon.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
			context["result_text"] = TXT_R2
		3:
			ws.completed_event_ids.erase("event_440")
			context["result_text"] = TXT_R3




func _disable_blank(opt: EventOption) -> void:
	opt.text = ""
	opt.disabled_text = ""
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n








func _modifier_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active


func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)
