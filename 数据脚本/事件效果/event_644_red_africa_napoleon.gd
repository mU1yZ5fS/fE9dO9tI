extends "res://数据脚本/event_script_base.gd"

## 原作 Event644.cs：红色非洲拿破仑（中非博卡萨路线，二选项）。
## 触发：DiploButtonScript.cs:10800 —— 外交按钮 70，selected_country==65（中非），手动触发。
## 差异：原版选项1 event_done[644]=false → Godot context["skip_mark_done"]；
##   JoinAllOurAlliances(true)→_join_alliances；soc_stab→social_stability。

const TXT_R0 := "近日，我们邀请了中非人民帝国皇帝让-贝德尔·博卡萨陛下同志访问我国，展开为期一周的国事访问与理论进修活动。途中，博卡萨同志对我国革命的运动式的组织方式异常感兴趣。在对群众的即兴演讲上，他对极大地赞扬了人民的领袖华主席，他说：“华国锋同志是毛主席之后当之无愧的第三世界领袖、百年难遇的智者和世界人民革命的主心骨。”访问期间，两国的关系极大地深化了，在不久后，中非便出现了中国的军事基地。访问结束后，博卡萨陛下同志很快在国内宣布要“将博卡萨运动进行到底”，一系列新政很快被颁布下来。首先是执政党黑非洲社会发展运动被改组为“中非博卡萨革命运动先锋党”，该党在其章程中写道：“中非博卡萨革命运动先锋党是由博卡萨家族领导的，以波拿巴主义、科学社会主义、华国锋思想和博卡萨理论为指导思想的全体中非臣民的先锋队。”博卡萨、拿破仑和华国锋同志三人的画像很快在中非各种场合被并列摆放，陛下同志的雕像更是成为了全国各处可见的景观。在班吉的一场重要讲话上，博卡萨宣布发起文化大革命——当然，没有“造反”运动，只有实际上的军管。名义上独立但实际上是由博卡萨组建的“博卡萨革命突击队”利用文化革命的名义在国内横冲直撞，对各界的反对派开展大清洗。《博卡萨陛下同志谈治国理政》更是成为了中小学生、公务员和党员的必背书目，甚至是考驾照也需要通过有关《博卡萨陛下同志谈治国理政》的笔试。对博卡萨画像进行“早请示，晚汇报”更是成为了每个中非臣民的日常。当然诸如“波拿巴主义的永恒堡垒”、“布班基的天才”等称号也必不可少的部分。博卡萨二世在未来将留学中国，进行有关继承人的进修……\n尽管帝国主义者及其走狗不断抹黑中非人民如火如荼的革命，但无论他们是否喜欢，我们站在历史正确的一边，我们的不断胜利将埋葬他们！"
const TXT_R1 := "说笑了，主席同志，他不过是津巴布韦又一个普通的不能再普通的黑人领袖罢了。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var car := ws.get_country_by_legacy_index(65)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if car != null:
				car.government = 0
				car.sub_government = 19
				car.set_tag("亲中", true)
				_join_alliances(car)
				car.social_stability = 1000
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			ws.influence_prc += 50
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
		1:
			context["result_text"] = TXT_R1
			# 原版 :59 event_done[644]=false → 跳过完成标记，按钮可再次选择
			context["skip_mark_done"] = true
