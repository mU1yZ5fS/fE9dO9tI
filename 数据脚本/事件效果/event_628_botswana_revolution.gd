extends "res://数据脚本/event_script_base.gd"

## 原作 Event628.cs：保佑这高尚的土地（博茨瓦纳革命，单选项）。
## 触发：DiploButtonScript.cs:12117 —— 外交按钮 1032，selected_country==129（博茨瓦纳），
##   入口扣 data.agents-=100（在 _def_1032 中已移植），随后 StartEvent(628)。
## 本 .tres trigger_conditions 为空：仅由外交按钮手动触发。
## 差异：原版按 politics_dolshnost[0]（150/200 哨兵）选择总理槽姓名或领袖姓名；
##   Godot politics_positions[0] 同哨兵语义（150/200），姓名用 PoliticianData.name_display 全文。

const TXT_R_FAIL := "在市中心被攻克之后，博茨瓦纳民族民主解放军并没有按照预定计划中的迅速控制主要交通要道和城市，而是迅速开始了争权夺利的内斗。而这一糟糕的决定给了该国政府一丝喘息的机会。在迅速流亡南非并呼唤了南非的军事干涉后，这一“保守主义的金牌打手”果然没有让人失望。很快，博茨瓦纳民主党便在南非的步战车的帮助下迅速打回了哈伯罗内，废除了短命的“博茨瓦纳人民共和国”。但作为代价，南非将在博茨瓦纳保留足够的军事存在，用于“对抗黑人布尔什维克威胁”，“维护友邦安全”。同时在意识到非洲国家根本不适合共和制之后，南非帮助博茨瓦纳确定了新的政治体制——酋长合众邦。该制度类似于阿联酋和马来西亚的制度，进一步削弱了该国潜在的反政府组织。\n但南非的进军几乎将“博茨瓦纳奇迹”付之一炬，战争的伤痕在该国四处可见，作为该国经济命脉的畜牧业更是惨遭“平暴用无污染”芥子气的打击，这只会让该国本就被荒漠化挑战的经济雪上加霜。"
const TXT_SUCCESS_PRE_PM := "很快，示威游行很快升级为了展现“警民鱼水情”的现场直播。更别提一向标榜“中立客观”的CNN记者也被雇佣过来的帮派分子打倒在地时更能让国际社会谴责该国的了。很明显，津巴布韦的雨林中磨练的民族解放军士兵们远比警察们的战斗力更强。在市中心被完全攻克后，奎特·马西雷爵士宣布“不愿再看到更多流血”，他决定辞职并流亡美国。随后，黑黄绿的三色旗和解放的红旗高高的在哈伯罗内街头升起。\n在左翼大帐篷合作的时期中，年轻而富有魅力的克里斯托弗·帕什威得以组建了一支以他为核心的革命队伍。他们高举马克思，列宁，斯大林和毛泽东的旗帜，这也就是他们的派系被称为MELS（取马克思，恩格斯，列宁，斯大林四人的首字母之意）的原因。在革命结束后，博茨瓦纳争取社会主义运动被改组为博茨瓦纳劳动党，毛泽东主义也被写入了该党的党章。博茨瓦纳共和国正式改名为博茨瓦纳民主共和国，新政府获得了相当多的非洲进步国家的承认，国务院总理"
const TXT_SUCCESS_PRE_CHAIRMAN := "很快，示威游行很快升级为了展现“警民鱼水情”的现场直播。更别提一向标榜“中立客观”的CNN记者也被雇佣过来的帮派分子打倒在地时更能让国际社会谴责该国的了。很明显，津巴布韦的雨林中磨练的民族解放军士兵们远比警察们的战斗力更强。在市中心被完全攻克后，奎特·马西雷爵士宣布“不愿再看到更多流血”，他决定辞职并流亡美国。随后，黑黄绿的三色旗和解放的红旗高高的在哈伯罗内街头升起。\n在左翼大帐篷合作的时期中，年轻而富有魅力的克里斯托弗·帕什威得以组建了一支以他为核心的革命队伍。他们高举马克思，列宁，斯大林和毛泽东的旗帜，这也就是他们的派系被称为MELS（取马克思，恩格斯，列宁，斯大林四人的首字母之意）的原因。在革命结束后，博茨瓦纳争取社会主义运动被改组为博茨瓦纳劳动党，毛泽东主义也被写入了该党的党章。博茨瓦纳共和国正式改名为博茨瓦纳民主共和国，新政府获得了相当多的非洲进步国家的承认，国家主席"
const TXT_SUCCESS_PRE_PM_LEADER := "很快，示威游行很快升级为了展现“警民鱼水情”的现场直播。更别提一向标榜“中立客观”的CNN记者也被雇佣过来的帮派分子打倒在地时更能让国际社会谴责该国的了。很明显，津巴布韦的雨林中磨练的民族解放军士兵们远比警察们的战斗力更强。在市中心被完全攻克后，奎特·马西雷爵士宣布“不愿再看到更多流血”，他决定辞职并流亡美国。随后，黑黄绿的三色旗和解放的红旗高高的在哈伯罗内街头升起。\n在左翼大帐篷合作的时期中，年轻而富有魅力的克里斯托弗·帕什威得以组建了一支以他为核心的革命队伍。他们高举马克思，列宁，斯大林和毛泽东的旗帜，这也就是他们的派系被称为MELS（取马克思，恩格斯，列宁，斯大林四人的首字母之意）的原因。在革命结束后，博茨瓦纳争取社会主义运动被改组为博茨瓦纳劳动党，毛泽东主义也被写入了该党的党章。博茨瓦纳共和国正式改名为博茨瓦纳民主共和国，新政府获得了相当多的非洲进步国家的承认，国务院总理"
const TXT_SUCCESS_POST := "也前去会见了新政府首脑。至少，又一个非洲国家投入了社会主义的怀抱。"
const TXT_R_NEUTRAL := "很快，示威游行很快升级为了展现“警民鱼水情”的现场直播。更别提一向标榜“中立客观”的CNN记者也被雇佣过来的帮派分子打倒在地时更能让国际社会谴责该国的了。很明显，津巴布韦的雨林中磨练的民族解放军士兵们远比警察们的战斗力更强。在市中心被完全攻克后，奎特·马西雷爵士宣布“不愿再看到更多流血”，他决定辞职并流亡美国。随后，黑黄绿的三色旗和解放的红旗高高的在哈伯罗内街头升起。\n在我们和苏联的通力帮助下，贝松·加塞兹韦阁下率领的“民族阵线”派确保了自己的领先地位，在贝专兰形成了一个左翼的民族社会主义大帐篷————博茨瓦纳人民革命党。尽管不少革命者和内部的反对派谴责他的诸多政策。例如承认酋长制，不触及土地改革，但极度敌视南非政府且组织集体牧场。但在我们和苏联的帮助下，他定会率领博茨瓦纳人民革命党走向光辉的未来。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var botswana := ws.get_country_by_legacy_index(129)  # 博茨瓦纳
	var south_africa := ws.get_country_by_legacy_index(131)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# 原版 :29-40：南非 SubGosstroy==7/9 → 失败分支
			if south_africa != null and (south_africa.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN or south_africa.sub_government == GameConstants.SubGovernment.NEO_FASCIST):
				context["result_text"] = TXT_R_FAIL
				if botswana != null:
					botswana.government = GameConstants.Government.AUTHORITARIAN
					botswana.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
					_leave_alliances(botswana)
					botswana.chinese_name = "贝专兰合众邦"
					botswana.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
				ws.influence_prc -= 20
				_add_power(EmpireData.USA, 20)
				return
			# 原版 :41-65：level_of_unstab==200 && modifies[6] && cw → 左翼夺权
			var mod6 := ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
			if botswana != null and botswana.level_of_instability == 200 and mod6 and botswana.内战中:
				context["result_text"] = _success_text()
				if botswana != null:
					botswana.government = GameConstants.Government.SOCIALIST
					botswana.sub_government = GameConstants.SubGovernment.MAOIST
					_leave_alliances(botswana)
					botswana.set_tag("亲中", true)
					botswana.set_tag("对华贸易", true)
					botswana.chinese_name = "博茨瓦纳民主共和国"
				ws.influence_prc += 20
				_add_relation(EmpireData.USA, -100)
				_add_power(EmpireData.USA, -20)
				return
			# 原版 :66-77：其余 → 亲苏左翼大帐篷
			context["result_text"] = TXT_R_NEUTRAL
			if botswana != null:
				botswana.government = GameConstants.Government.SOCIALIST
				botswana.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				_leave_alliances(botswana)
				botswana.set_tag("亲苏", true)
				botswana.set_tag("对华贸易", true)
				botswana.chinese_name = "博茨瓦纳社会主义共和国"
			ws.influence_prc += 10
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -20)
			_add_relation(EmpireData.USSR, 100)
			_add_power(EmpireData.USSR, 15)


## 原版 :43-54 的国务院总理/国家主席分支。
func _success_text() -> String:
	if ws.politics_positions.size() > 0:
		var idx := ws.politics_positions[0]
		if idx != 150 and idx != 200:
			return TXT_SUCCESS_PRE_PM + _slot_name(idx) + TXT_SUCCESS_POST
		if idx == 200:
			return TXT_SUCCESS_PRE_CHAIRMAN + _leader_name() + TXT_SUCCESS_POST
		return TXT_SUCCESS_PRE_PM_LEADER + _leader_name() + TXT_SUCCESS_POST
	return TXT_SUCCESS_PRE_PM_LEADER + _leader_name() + TXT_SUCCESS_POST


func _slot_name(politician_index: int) -> String:
	if politician_index >= 0 and politician_index < ws.politicians.size():
		var p: PoliticianData = ws.politicians[politician_index]
		if p != null and p.name_display != "":
			return p.name_display
	return _leader_name()


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
