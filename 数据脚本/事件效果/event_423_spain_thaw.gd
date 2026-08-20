extends "res://数据脚本/event_script_base.gd"

## 原作 Event423.cs：西班牙解冻（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1374-1376 —— DATE_AFTER。
## 差异：Gosstroy→government；SubGosstroy→sub_government。

const TXT_RESULT := "首次民主选举光是竞选活动便进行的非常激烈。\n占据西班牙政治光谱“中间派”位置的现任首相苏亚雷斯拒绝参与选举，但他并没有遭遇意料之中的失败——因为每位西班牙妇女都受到了由苏亚雷斯亲笔署名的一封信，并附上了保障家庭的承诺。出于对“佛朗哥主义余毒”的防范，两大左翼政党均将矛头对准了国民联盟。这就让苏亚雷斯占了大便宜。\n因此，选举结果平平无奇：苏亚雷斯得票35%；工人社会党则自信地保住了其作为最大反对党的位置，获票29%；随后则是共产党与保守派。长枪党人则没有获得进入议会的机会。\n激进派在选举中遭遇大败：弗拉加高估了资产阶级、农民与城市中间阶层内的保守主义情绪；而卡里略的西班牙共产党也对该国工人的左翼情绪过于乐观。\n到目前为之，该国的一切实权均属于支持民主党派的选民们。但今天，这种消极多数能够战胜积极少数吗。"
const TXT_IDX_1372 := "西班牙解冻"
const TXT_IDX_1373 := "在任命胡安·卡洛斯一世作为其继承人与西班牙国王后，独裁者佛朗哥便草草去世。随后，胡安·卡洛斯一世加冕为西班牙国王。1976年，新国王任命阿道弗·苏亚雷斯作为西班牙首相，后者隶属于佛朗哥主义改革派。在这数年间，新首相推动了对政治体制的自由化：西班牙重建了议会（Cortes·Generales），政党均被合法化，并开始实行对政治犯的赦免。\n当然，对长枪党政体如此尖锐的挑战引起了保守派传统据点，即军队的不满情绪。军中的“堡垒”派持强硬派佛朗哥主义立场，并坚决反对首相推行的自由民主转型。尤其反对新政府将圣地亚哥·卡里略领导的西班牙共产党合法化。\n在今年年初，苏亚雷斯宣布将举行制宪会议选举，并制定一份宪法。因此，取代西班牙长枪党的新政党民主中间派联盟得以形成，并整合了前者内部的一切改革派势力。此外，西班牙共产党与年轻律师费利佩·冈萨雷斯领导的西班牙工人社会党也将结束地下活动时代，参与此次选举。\n而扮演西班牙的右翼一方的势力主要是两大党：即由曼努埃尔·弗拉加领导的保守派组织国民联盟与极右翼组织真西班牙长枪党。\n该国的政治力量如此多样，让人不得不质疑新执政党无条件取得胜利的可能。因此，几乎无法预测摆脱数十年极权统治下的首次民主选举的结果会如何。"
const TXT_IDX_1374 := "谁将拔得头筹......？"
const TXT_IDX_1375 := "首次民主选举光是竞选活动便进行的非常激烈。\n占据西班牙政治光谱“中间派”位置的现任首相苏亚雷斯拒绝参与选举，但他并没有遭遇意料之中的失败——因为每位西班牙妇女都受到了由苏亚雷斯亲笔署名的一封信，并附上了保障家庭的承诺。出于对“佛朗哥主义余毒”的防范，两大左翼政党均将矛头对准了国民联盟。这就让苏亚雷斯占了大便宜。\n因此，选举结果平平无奇：苏亚雷斯得票35%；工人社会党则自信地保住了其作为最大反对党的位置，获票29%；随后则是共产党与保守派。长枪党人则没有获得进入议会的机会。\n激进派在选举中遭遇大败：弗拉加高估了资产阶级、农民与城市中间阶层内的保守主义情绪；而卡里略的西班牙共产党也对该国工人的左翼情绪过于乐观。\n到目前为之，该国的一切实权均属于支持民主党派的选民们。但今天，这种消极多数能够战胜积极少数吗。"



func _raw(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0






func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s


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


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, war_name: String, fortnight: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var spain := ws.get_country_by_legacy_index(86)
	if spain != null:
		spain.government = 3
		spain.sub_government = 6
	context["result_text"] = TXT_RESULT
