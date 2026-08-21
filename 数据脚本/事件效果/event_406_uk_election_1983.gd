extends "res://数据脚本/event_script_base.gd"

## 原作 Event406.cs：英国大选-1983（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1276 —— DATE_AFTER 1983.5.20。
## 差异：BritLost→ws.get_flag("BritLost")；based→有驻军基地；EstablishGovernment 仅改倾向标签。

const TXT_TITLE := [
	"英国大选-1983",
]

const TXT_DESC := [
	"自上次议会选举以来，英国的政党制度发生了显著变化。以两党霸权制度为基础的体制已发生了严重的分化，而另一股显赫的势力也加入了政治游戏中。保守党的支持率因实行激进的新自由主义改革而严重受损，它在人群当中已变得不受欢迎。工党也因为党内分裂与极左倾向而遭遇重创。自由党与社会民主党则已在联合竞选上达成共识，有望在选战中超越工党。但明枪暗箭带来的结果，直到最后才会水落石出......",
]

const TXT_OPT0 := [
	"接下来将发生什么？",
]

const TXT_R := [
	"工党成功赢得本年大选。撒切尔政府的外交失败连同破产的新自由主义经济改革一起，使保守党的支持率严重下滑。泰德·格兰特则当选该国首相，并宣布英国社会即将将在“社会主义民主经济”的基础上，开启它的大转变。新政府已经在起草相关法案，旨在打破萦绕在“自然产权”的“神圣光环”，并开始实行大型企业的国有化，兴修社会住房并引入免费的社会福利保障。在外交政策方面，托洛茨基主义者宣布“大不列颠将超脱于政治集团外”，并退出了欧洲经济共同体与北约。",
	"在工党分裂，玛格丽特·撒切尔政府的外交冒险又遭遇惨败的情况下，选民们对传统政党的信心已经遭到破坏。因此，自由党与社会民主党的联盟赢下了议会选举。自由党领导人大卫·斯蒂尔成为该国首相，他已宣布将对国家现行经济制度进行修订，并宣布深化英国与欧洲经济共同体的合作。",
	"工党成功赢得本年大选。撒切尔政府的外交失败连同破产的新自由主义经济改革一起，使保守党的支持率严重下滑。迈克尔·富特则当选该国首相，并宣布英国将进行单方面核裁军并退出欧洲经济共同体。政府同时宣布开始“重建福利国家”的计划，即增加公共开支，发展公共部门，废除私有制与增加财产税在内的一揽子工程。",
	"工党成功赢得本年大选。撒切尔政府的外交失败连同破产的新自由主义经济改革一起，使保守党的支持率严重下滑。迈克尔·富特与托尼·本恩开始领导这个国家，并宣布英国社会即将在社会主义的基础上，开启它的大转变。新政府已经在起草相关法案，开始实行大型企业的国有化，推倒撒切尔夫人的改革政策，并成立协调国家经济工作的国家经济计划委员会以确保国家竞争力；一些工团主义的元素也被引入经济生活领域，工业民主被建立了，政府将在经济管理中实现民主化，工会活动得到国家鼓励，工会被允许参与到企业的生产计划乃至国家计划的管理之中；同时，改革公务员制度，让他们能够更加深刻的贯彻政府的政策；媒体政策也将改订，由政府资助媒体，让他们必须倾向工人阶级，而不是实业家和银行家。在外交政策方面，新的工党政府宣布退出北约，本恩评价道：“这是个帝国主义战争机构”；并开始将布鲁塞尔所袭夺的一切，悉数归还给威斯敏斯特宫——退出欧洲经济共同体。英国右翼和保守派对新的工党政府并不满意，他们认为工党已经成为“极权主义的特洛伊木马”。",
	"并没有政党在选举中获得稳定的多数。然而，根据协商的结果，该国建立了囊括工党、自由党与社会民主党三方的“民主联盟”。其领导人为自由党人大卫·斯蒂尔。在就任英国首相后，他已宣布将对国家现行经济制度进行修订，以此扩大社会保障网络、工会组织权利、但并不涉及国有化或私有化等产权转让政策。",
	"尽管该国的经济形式不尽如人意，但选举结果表明，政府依然得以继续连任。保守党在接下来的选举中以“微弱”优势取胜。结果表明，42.4%的选民投票给了保守党，而工党则在1983年选举内迎来了二战后的最大失败，只有27.6%的选民投票给它的候选人，让该党在下议院内仅有209人。对于联盟而言，选举结果也令人失望。25.4%的选民投票给了他们，让23位代表走入议会，其中有16人来自自由党、7人来自社会民主党。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1198 := "英国大选-1983"
const TXT_IDX_1199 := "自上次议会选举以来，英国的政党制度发生了显著变化。以两党霸权制度为基础的体制已发生了严重的分化，而另一股显赫的势力也加入了政治游戏中。保守党的支持率因实行激进的新自由主义改革而严重受损，它在人群当中已变得不受欢迎。工党也因为党内分裂与极左倾向而遭遇重创。自由党与社会民主党则已在联合竞选上达成共识，有望在选战中超越工党。但明枪暗箭带来的结果，直到最后才会水落石出......"
const TXT_IDX_1192 := "接下来将发生什么？"
const TXT_IDX_1200 := "工党成功赢得本年大选。撒切尔政府的外交失败连同破产的新自由主义经济改革一起，使保守党的支持率严重下滑。泰德·格兰特则当选该国首相，并宣布英国社会即将将在“社会主义民主经济”的基础上，开启它的大转变。新政府已经在起草相关法案，旨在打破萦绕在“自然产权”的“神圣光环”，并开始实行大型企业的国有化，兴修社会住房并引入免费的社会福利保障。在外交政策方面，托洛茨基主义者宣布“大不列颠将超脱于政治集团外”，并退出了欧洲经济共同体与北约。"
const TXT_IDX_1287 := "在工党分裂，玛格丽特·撒切尔政府的外交冒险又遭遇惨败的情况下，选民们对传统政党的信心已经遭到破坏。因此，自由党与社会民主党的联盟赢下了议会选举。自由党领导人大卫·斯蒂尔成为该国首相，他已宣布将对国家现行经济制度进行修订，并宣布深化英国与欧洲经济共同体的合作。"
const TXT_IDX_1201 := "工党成功赢得本年大选。撒切尔政府的外交失败连同破产的新自由主义经济改革一起，使保守党的支持率严重下滑。迈克尔·富特则当选该国首相，并宣布英国将进行单方面核裁军并退出欧洲经济共同体。政府同时宣布开始“重建福利国家”的计划，即增加公共开支，发展公共部门，废除私有制与增加财产税在内的一揽子工程。"
const TXT_IDX_1453 := "英国决定加入社会主义联盟。"
const TXT_IDX_1202 := "并没有政党在选举中获得稳定的多数。然而，根据协商的结果，该国建立了囊括工党、自由党与社会民主党三方的“民主联盟”。其领导人为自由党人大卫·斯蒂尔。在就任英国首相后，他已宣布将对国家现行经济制度进行修订，以此扩大社会保障网络、工会组织权利、但并不涉及国有化或私有化等产权转让政策。"
const TXT_IDX_1203 := "尽管该国的经济形式不尽如人意，但选举结果表明，政府依然得以继续连任。保守党在接下来的选举中以“微弱”优势取胜。结果表明，42.4%的选民投票给了保守党，而工党则在1983年选举内迎来了二战后的最大失败，只有27.6%的选民投票给它的候选人，让该党在下议院内仅有209人。对于联盟而言，选举结果也令人失望。25.4%的选民投票给了他们，让23位代表走入议会，其中有16人来自自由党、7人来自社会民主党。"

## 原文字符串附录（供自检）
## 工党成功赢得本年大选。撒切尔政府的外交失败连同破产的新自由主义经济改革一起，使保守党的支持率严重下滑。迈克尔·富特与托尼·本恩开始领导这个国家，并宣布英国社会即将在社会主义的基础上，开启它的大转变。新政府已经在起草相关法案，开始实行大型企业的国有化，推倒撒切尔夫人的改革政策，并成立协调国家经济工作的国家经济计划委员会以确保国家竞争力；一些工团主义的元素也被引入经济生活领域，工业民主被建立了，政府将在经济管理中实现民主化，工会活动得到国家鼓励，工会被允许参与到企业的生产计划乃至国家计划的管理之中；同时，改革公务员制度，让他们能够更加深刻的贯彻政府的政策；媒体政策也将改订，由政府资助媒体，让他们必须倾向工人阶级，而不是实业家和银行家。在外交政策方面，新的工党政府宣布退出北约，本恩评价道：“这是个帝国主义战争机构”；并开始将布鲁塞尔所袭夺的一切，悉数归还给威斯敏斯特宫——退出欧洲经济共同体。英国右翼和保守派对新的工党政府并不满意，他们认为工党已经成为“极权主义的特洛伊木马”。

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uk := ws.get_country_by_legacy_index(92)
	if 57 < ws.modifiers.size() and ws.modifiers[57] != null:
		ws.modifiers[57].is_active = false
	var num := 0
	if ws.empires.size() > 0 and ws.empires[0] != null and ws.empires[0].current_leader == 1:
		num += 1
	var flag2 := _raw(65) > 0
	var flag := ws.get_flag("BritLost")
	var c2 := ws.get_country_by_legacy_index(2)
	var c4 := ws.get_country_by_legacy_index(4)
	if (c2 == null or c2.puppet_of != 7) and (c4 == null or c4.puppet_of != 7) and not (ws.wars.size() > 5 and ws.wars[5] != null and ws.wars[5].is_going):
		num += 1
	var num2 := 0
	for cid in [21, 85, 86, 87]:
		var c := ws.get_country_by_legacy_index(cid)
		if c != null and (c.government == GameConstants.Government.REFORMIST or ws.is_socialism(c, true)):
			num2 += 1
	for cid in [85, 86, 87]:
		var c := ws.get_country_by_legacy_index(cid)
		if c != null and ws.is_authoritarian(c):
			num2 += 1
	if num2 > 1:
		num += 1
	if flag and num >= 3 and flag2 and uk != null and uk.有驻军基地:
		if uk != null:
			uk.government = GameConstants.Government.SOCIALIST
			uk.sub_government = GameConstants.SubGovernment.TROTSKYIST
			_leave_alliances(uk)
			_set_pro_neutral(uk)
		_add(147, 1)
		_add_power(EmpireData.USA, -80)
		context["result_text"] = TXT_R[0]
	elif uk != null and uk.有驻军基地 and flag and flag2:
		if uk != null:
			uk.government = GameConstants.Government.LIBERAL
			uk.sub_government = GameConstants.SubGovernment.MODERATE
		_add(147, 2)
		context["result_text"] = TXT_R[1]
	elif flag and flag2:
		if uk != null and not uk.内战中:
			if uk != null:
				uk.government = GameConstants.Government.REFORMIST
				uk.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				uk.set_tag("eu", false)
				_set_pro_neutral(uk)
			_add_power(EmpireData.USA, -50)
			_add(147, 3)
			var c86 := ws.get_country_by_legacy_index(86)
			if c86 != null and c86.has_tag("soc_eu"):
				if uk != null:
					uk.set_tag("soc_eu", true)
					uk.set_tag("nato", false)
				context["result_text"] = TXT_IDX_1201 + TXT_IDX_1453
			else:
				context["result_text"] = TXT_IDX_1201
		elif uk != null and uk.内战中:
			if uk != null:
				uk.government = GameConstants.Government.REFORMIST
				uk.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				uk.set_tag("eu", false)
				uk.set_tag("nato", false)
				_set_pro_neutral(uk)
			_add_power(EmpireData.USA, -80)
			_add(147, 6)
			context["result_text"] = TXT_R[2]
	else:
		if flag or flag2:
			if uk != null:
				uk.government = GameConstants.Government.REFORMIST
				uk.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
				_set_pro_neutral(uk)
			_add(147, 4)
			_add_power(EmpireData.USA, -20)
			context["result_text"] = TXT_R[3]
		else:
			_add(147, 5)
			_add_power(EmpireData.USA, 50)
			context["result_text"] = TXT_R[4]

func _raw(i: int) -> int:
	if d.size() > i:
		return d.get_data_by_index(i)
	return 0

func _set_pro_neutral(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", false)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)
