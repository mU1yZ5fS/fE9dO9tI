extends "res://数据脚本/event_script_base.gd"

## 原作 Event701.cs：大白色北方（加拿大布局，五选项）。
## 触发：ReqEventsDLC02.cs:1561-1563 —— DATE_AFTER 1979.5.22 → trigger_script evaluate。
## 差异：Torg→对华贸易、proprc→亲中；c137=加拿大。

const TXT_OPT0_DIS := "和这种人建交？简直让让白求恩蒙羞！"
const TXT_OPT1_DIS := "幸运的是，生活中总有些事情不会变……"
const TXT_OPT2_DIS := "我们明明有更好的选择，为什么要去做费力不讨好的事情？"
const TXT_OPT3_DIS := "他们已经把我们看作叛徒了！"
const TXT_R0_OK := "我国大使试图深化合作的建议正好撞上了加拿大国内的政局变动：面对失业率、通胀和政府赤字三高的局面，特鲁多决定以解散国会的方式豪赌。然而大选最终却将进步保守党推向前台。而该党恰恰决定调整外交姿态，并对我国的建议漠不关心。不过，此时的进步保守党政府充其量不过是个短命的少数派政权，很快便被卷土重来的特鲁多清算。二进宫的特鲁多察觉到了我们递来的橄榄枝，相当爽快地批准了与我国的一揽子协定。让我们为棕熊朋友们干杯！"
const TXT_R0_FAIL := "然而，中国试图同加拿大政府深化合作关系的政策吃了闭门羹。我国大使试图深化合作的建议正好撞上了加拿大国内的政局变动：面对失业率、通胀和政府赤字三高的局面，特鲁多决定以解散国会的方式豪赌。然而大选最终却将进步保守党推向前台。而该党恰恰决定调整外交姿态，并对我国的建议漠不关心。虽说此时的进步保守党政府充其量不过是个短命的少数派政权，特鲁多很快便会卷土重来。可我们的外交努力着实打了水漂。"
const TXT_R1 := "虽说成本不菲，但我们的手确实能够伸得够长，并为中国物色到大洋彼岸的朋友。虽说复活主张武装斗争的魁北克解放阵线已无多大可能，但我们仍可以通过开设皮包公司与伞状组织的方式操纵媒体并提供竞选资金，支持那些走“正规路线”的魁北克分离主义者。当然，这一切都要绕开在当地实力雄厚的美国中情局的眼线：意味着我们在当地不可能实现四两拨千斤，只能在相当有限的范围内影响局势。这些投入很可能会打水漂，党内大多数同志也无法断定这种押注分离主义者的策略能比直接援助反修正主义政党高明到哪去……\n目前，加拿大国内的局势仍未出现明显改观。面对失业率、通胀和政府赤字三高的局面，特鲁多决定以解散国会的方式豪赌。然而大选最终却将进步保守党推向前台。而该党恰恰决定调整外交姿态，并对我国的建议漠不关心。不过，此时的进步保守党政府充其量不过是个短命的少数派政权，很快便会被卷土重来的特鲁多清算。"
const TXT_R2 := "我们成功与新民主党内部的“左翼核心小组”牵线搭桥，它们是华夫派的继承团体，主张工业国有化并谴责“折衷的混合经济政策”。不过在其他方面则有所退行。我们向该小组的主要领导人约翰·罗德里格斯提供了竞选资金，并帮助该派成员在党内扩大影响力、扩充成员，并加强他们同党外左翼和工会运动的联系。试图将其打造为新民主党内的党中之党兼举足轻重的派阀。不过，他们的表现仍在很大程度上取决于新民主党能在加拿大民主制下有多大发挥……\n目前，加拿大国内的局势仍未出现明显改观。面对失业率、通胀和政府赤字三高的局面，特鲁多决定以解散国会的方式豪赌。然而大选最终却将进步保守党推向前台。而该党恰恰决定调整外交姿态，并对我国的建议漠不关心。不过，此时的进步保守党政府充其量不过是个短命的少数派政权，很快便会被卷土重来的特鲁多清算。"
const TXT_R3 := "世界革命怎能有例外论？如果艰难险阻能够吓倒革命者的话，中国革命早就失败了！因此，我们决定直接支持加拿大人民的正义事业。通过外联部的同志，我们得以同阿尔巴尼亚劳动党牵线搭桥，并希望共同帮助加拿大的革命力量放下分歧，整合力量，为争取独立的社会主义加拿大而战。在我们的共同努力下，我们成功促成加拿大共产党（马克思列宁主义）、加拿大工人共产党和“斗争！”团体等反修正主义组织达成协议，最终将上述组织合并为加拿大革命共产党，新生的革命共产党在我们的巨量援助下蓬勃成长，并开始掌握工会运动。我们相信，加拿大人民的正义事业一定会成功！\n目前，加拿大国内的局势仍未出现明显改观。面对失业率、通胀和政府赤字三高的局面，特鲁多决定以解散国会的方式豪赌。然而大选最终却将进步保守党推向前台。而该党恰恰决定调整外交姿态，并对我国的建议漠不关心。不过，此时的进步保守党政府充其量不过是个短命的少数派政权，很快便会被卷土重来的特鲁多清算。"
const TXT_R4 := "显然，至少在美帝毁灭前加拿大都会保持既定航线，而至于前者什么时候发生，估计也不在我们的考虑当中了。毕竟加拿大的邻居可不会自毁长城：总不可能有美国总统疯到要和加拿大打贸易战乃至想要变成第五十一个州的吧？\n面对失业率、通胀和政府赤字三高的局面，特鲁多决定以解散国会的方式豪赌。然而大选最终却将进步保守党推向前台。而该党恰恰决定调整外交姿态，并对我国的建议漠不关心。不过，此时的进步保守党政府充其量不过是个短命的少数派政权，很快便会被卷土重来的特鲁多清算。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 5:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var opt := event_def.options
	if line > 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line <= 2 and ws.influence_prc >= 300:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line <= 2 and ws.influence_prc >= 300:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	var albania := ws.get_country_by_legacy_index(20)
	if line < 2 and ws.influence_prc >= 500 and albania != null and albania.has_tag("亲中"):
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if _res(W.I_DIPLO) < 500 or (ws.get_country_by_legacy_index(1) != null \
					and ws.get_country_by_legacy_index(1).government >= 2):
				context["result_text"] = TXT_R0_OK
				var canada := ws.get_country_by_legacy_index(137)
				if canada != null:
					canada.set_tag("对华贸易", true)
				_add(W.I_DIPLO, -10)
				_add(W.I_BUDGET, 30)
			else:
				context["result_text"] = TXT_R0_FAIL
				_add(W.I_PARTY_SUPPORT, -20)
		1:
			context["result_text"] = TXT_R1
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -200)
		2:
			context["result_text"] = TXT_R2
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -150)
		3:
			context["result_text"] = TXT_R3
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -20)
		4:
			context["result_text"] = TXT_R4


func evaluate(world: WorldState) -> bool:
	return world != null and world.date != null and world.date.to_int() >= 19790522
