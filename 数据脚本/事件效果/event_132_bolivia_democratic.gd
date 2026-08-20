extends "res://数据脚本/event_script_base.gd"

## 原作 Event132.cs：主爱圣三一（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_PROPRC_YES := "新政府决心和我们做朋友。"
const TXT_PROPRC_NO := "新政府不想和我们做朋友。"
const TXT_R0 := "上台后，脆弱的玻利维亚民主政权发现自己处于非常困难的社会、经济和政治局势中。在经济上，玻利维亚破产了。此外，恶性通货膨胀（高达27.000%）一飞冲天，破坏了雇员们的购买力，国家因此陷入无政府状态。这种情况要归功于18年来的政变和军事暴力。幸运的是，议会的大力支持让赛卢斯找到了解决问题的答案，因为赛卢斯一直反对暴力，并且从根本上准备只诉诸民主政府的方法。首先，必需品的临时定价机制得以建立，针对工会组织组织群众集会的意图，工会的权利也得到扩大，工人们必须加入工会，并禁止工人在没有工会参与的情况下订立雇佣合同。尽管右翼民族保守派试图阻拦法律通过，新领导层还是实施了这些政策，提高了最低工资，为穷人引入了最低限度的食物保障，政府合约的数量也增多了，以图创造新的就业机会，并发展该国的基础设施。在人民的全力支持下，逃亡的纳粹分子被逮捕，军队中也发生了清洗，包括乌戈·班塞尔在内的先前军事政变的发起者、参与者和共犯都被受到了打击，之后，同谋政变或支持政变的一切政党与运动都被取缔，其本人对过去任何军事政变的支持都等同于刑事犯罪。在国会、人民与工会的支持下，西莱斯开始实施他构建温和的社会主义民主国家的计划。"
const TXT_R1 := "上台后，脆弱的玻利维亚民主政权发现自己处于非常困难的社会、经济和政治局势中。在经济上，玻利维亚破产了。此外，恶性通货膨胀（高达27.000%）一飞冲天，破坏了雇员们的购买力，国家因此陷入无政府状态。这种情况要归功于18年来的政变和军事暴力。为解决这种情况，班塞尔制定了“前进”计划，该计划包括两点：打击古柯毒品和私有化。其旨在显著减少政府支出（从而减少通货膨胀），并杜绝使用古柯叶制作古柯糊并贩毒。这次行动得到了美国政府的支持，但也引发了骚乱、罢工与游行，其中许多行动是由古柯叶工会领袖埃沃·莫拉莱斯领导的。苏亚雷斯很快宣布国家进入戒严状态，以制止在所谓的“水战”中反对城市饮用水与污水处理服务私有化的社会抗议浪潮，这场战争只会愈演愈烈。通货膨胀放缓，经济开始增长，但伴随着这一切的是人民陷入贫困、美洲原住民权利也大不如前，例如武装恐怖分子便正在针对其活动家。"
const TXT_R2 := "1980年7月17日，路易斯·加西亚·梅萨领导的一群与贩毒组织关系密切的士兵发动了又一场血腥政变，推翻了民主政府，埃尔南的就职典礼也被迫中止。新政权的镇压行径与腐败行为引发了一场大罢工，国家濒临内战边缘。军事独裁政权最终瓦解，权力被移交给在1980年组成的国民大会。国民大会决定承认1980年的选举有效，并任命埃尔南·西莱斯·祖阿索为总统。上台后，脆弱的玻利维亚民主政权发现自己处于非常困难的社会、经济和政治局势中。在经济上，玻利维亚破产了。此外，恶性通货膨胀（高达27.000%）一飞冲天，破坏了雇员们的购买力，国家因此陷入无政府状态。这种情况要归功于18年来的政变和军事暴力。西莱斯无法解决经济问题，局势几近不可控，他也争取不到国会的支持。工会主席胡安·莱钦领导的在野党更是通过罢工使政府陷入瘫痪。又由于玻利维亚工人中央本部、各私营企业、国会中占多数的右翼与自由派政党的压力，价格调控政策失败了。但是，他拒绝采取违反宪法的措施，认为民主价值观及其成就不能与金钱划等号。应当指出，他设法维护并发展该国的民主，玻利维亚因此成为了重建南锥体民主的名义领袖，政府也因此受益匪浅。面对无法摆脱经济危机与政治僵局的局面，西莱斯总统决定开始绝食，但由于绝食毫无成效，因此天主教会出面，在政府与任何在议会中有代表的政党的谈判中担任调停角色，以期达成妥协。身心俱疲的埃尔南·西莱斯·祖阿索退出了政坛。"




func _proprc_suffix(c: CountryData) -> String:
	return TXT_PROPRC_YES if c.has_tag("亲中") else TXT_PROPRC_NO

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var bolivia := ws.get_country_by_legacy_index(72)
	if bolivia == null:
		return
	var ev130 := int(ws.completed_event_ids.get("event_130", 0))
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if ev130 == 1 and bolivia.sub_government == 4:
				_add(W.I_BUDGET, -25)
				_add(W.I_AGENTS, -25)
				bolivia.level_of_instability -= 5
				bolivia.level_of_development += 10
				bolivia.set_tag("亲中", true)
				bolivia.sub_government = 3
				_leave_alliances(bolivia)
				# 原作 Event132.cs:37：iron_and_blood → achievements.Set(90)
				Achievements.set_achievement(90)
				context["result_text"] = TXT_R0 + _proprc_suffix(bolivia)
			else:
				bolivia.level_of_instability -= 15
				bolivia.set_tag("亲中", false)
				bolivia.sub_government = 4
				context["result_text"] = TXT_R2 + _proprc_suffix(bolivia)
		1:
			if ev130 == 0 and bolivia.sub_government == 5:
				_add(W.I_BUDGET, -25)
				_add(W.I_AGENTS, -25)
				bolivia.level_of_instability -= 25
				bolivia.level_of_development -= 10
				bolivia.set_tag("亲中", true)
				bolivia.sub_government = 9
				_leave_alliances(bolivia)
				context["result_text"] = TXT_R1 + _proprc_suffix(bolivia)
			else:
				bolivia.level_of_instability -= 15
				bolivia.set_tag("亲中", false)
				bolivia.sub_government = 4
				context["result_text"] = TXT_R2 + _proprc_suffix(bolivia)
		_:
			bolivia.level_of_instability -= 15
			bolivia.set_tag("亲中", false)
			bolivia.sub_government = 4
			context["result_text"] = TXT_R2 + _proprc_suffix(bolivia)
	bolivia.government = 3
	bolivia.next_election_year = 1986
	bolivia.next_election_month = 8
	bolivia.next_election_day = 6

