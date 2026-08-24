extends "res://数据脚本/event_script_base.gd"

## 原作事件 446–449：伊朗革命后续事件链。
## 来源：Event446.cs / Event447.cs / Event448.cs / Event449.cs；
##       触发链 ReqEventsDLC02/ReqEventForDLC02.cs:357-367；
##       概览显示分支 modify_choose.cs:577-655（已由 概览.gd 实现，本脚本不改）。
##
## 触发关系：
##   446 伊朗法基赫监护（自动触发）
##   447 拯救伊朗大起义（PREV_EVENT_DONE 446 自动触发）
##   448 伊朗选举：涅槃？（447 result 0 且 data.iran_islamist_support<=300 时，由 .tres 的
##       TRIGGER_EVENT 效果在选项执行前入队，复刻原版 load_scene_after_click）
##   449 伊朗革命战争（PREV_EVENT_DONE 447 + PREV_EVENT_NOT_DONE 448 自动触发）
##
## 字段映射（Unity → Godot）：
##   allcountries[8]            → ws.get_country_by_legacy_index(8)
##   Gosstroy / SubGosstroy     → CountryData.government / sub_government
##   Vyshi / proprc / Torg / prosov → set_tag("亲美"/"亲中"/"对华贸易"/"亲苏")
##   data.iran_islamist_support                   → ws.iran_islamist_support
##   data.political_line                   → ws.political_line
##   data.get_data_by_index(6/8/9/22)             → W.I_DIPLO / W.I_BUDGET / W.I_AGENTS / W.I_ARMY
##   influencePRC               → ws.influence_prc
##   ingamewars[33]             → ws.wars[33]（world_factory 已 resize 到 34）
##   ussr_place / usa_place     → WarData.ussr_side / usa_side
##   gameState.iranrev          → 无字段，暂用 ws.set_flag("iranrev", true) 表达
##   allcountries[8].prcpower   → CountryData.prc_power


## 447 选项 0 的原版 Destroy 按钮文案有两个分支：
##   influencePRC < 300 且 data.political_line > 1 → “我们为什么要帮他们？”
##   influencePRC < 300 且 data.political_line <= 1 → “他们不会信任我们的”
## .tres 只能存一个静态 disabled_text，因此在显示前按原版条件动态覆写。
func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def.event_id == "event_449":
		var iraq := p_ws.get_country_by_legacy_index(14)
		var arg := ""
		if iraq != null and iraq.puppet_of < 0:
			if iraq.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
				arg = "以及对于萨达姆政权的犹豫不决，"
			elif iraq.sub_government == GameConstants.SubGovernment.PRAGMATIST:
				arg = "以及对于伊拉克的复兴党政权的犹豫不决，"
			elif p_ws.is_socialism(iraq, true):
				arg = "以及对于伊拉克的“卡菲勒”政权的犹豫不决，"
		event_def.description = "由于伊朗总统阿布·哈桑·巴尼萨德尔在伊朗人质事件上有着比霍梅尼及其党徒更温和的立场，{0}加之对于神学家的传统立场，霍梅尼最终认定其“作为大地上的腐化者”而罢黜了他，转而让新伊斯兰共和党秘书、霍梅尼最得力的亲信之一——贝赫什蒂负责国内全权事务。革命卫队占领了总统府和花园，并查封了一家与巴尼萨德尔关系密切的报社。在接下来的几天里，他们处决了他几个最亲密的朋友，包括侯赛因·纳瓦布、拉希德·萨德罗赫法齐和马努切赫尔·马苏迪。阿亚图拉·侯赛因·阿里·蒙塔泽里是政府中为数不多的仍然支持巴尼萨德尔的人之一，但他很快就被剥夺了权力。大部分左派乐于看见自由主义的知识分子被霍梅尼清洗，因此初期大力支持霍梅尼的政策，人民党主席基亚努里甚至公然宣布自己永远忠诚于伊玛目的路线，他也是伊朗革命中少数没有被清算的左派。仅仅有少数左翼势力选择了作壁上观，不随便站队法基赫政权。“红色什叶派”早已在链接两个派别的桥梁——阿亚图拉·塔莱加尼病逝后就与霍梅尼主义者的关系不断恶化，最终以马苏德·拉贾维为首的人民圣战者也选择了和巴尼萨德尔一起出走。反对派的活动规模虽庞大，但仍缺乏统一领导。根据我们的信息，政府正准备严厉镇压反对派的活动。我们该怎么办？".replace("{0}", arg)
		return
	if event_def.event_id != "event_447":
		return

	if p_ws == null or event_def.options.is_empty():
		return
	if p_ws.influence_prc >= 300:
		return
	# Event447.cs:26-35
	var line: int = p_ws.political_line if p_ws.size() > W.I_POLITICAL_LINE else 0
	if line > 1:
		event_def.options[0].disabled_text = "我们为什么要帮他们？"
	else:
		event_def.options[0].disabled_text = "他们不会信任我们的"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"event_446":
			_event_446(option_index, context)
		"event_447":
			_event_447(option_index, context)
		"event_448":
			_event_448(option_index, context)
		"event_449":
			_event_449(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _iran() -> CountryData:
	return ws.get_country_by_legacy_index(8)


func _event_446(option_index: int, context: Dictionary) -> void:
	var iran := _iran()
	match option_index:
		0:
			# Event446.cs:58-64
			d.agents -= 50
			d.budget -= 50
			d.diplomatic_reputation += 30
			ws.influence_prc -= 15
			if iran != null:
				iran.government = GameConstants.Government.AUTHORITARIAN
				iran.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			d.iran_islamist_support -= 100
			context["result_text"] = tr("event.script.event_446_449_iran_chain.i0")
		1:
			# Event446.cs:70-76
			d.agents -= 100
			d.budget -= 100
			d.diplomatic_reputation += 50
			ws.influence_prc += 80
			if iran != null:
				iran.government = GameConstants.Government.AUTHORITARIAN
				iran.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			d.iran_islamist_support -= 300
			context["result_text"] = tr("event.script.event_446_449_iran_chain.i1")
		2:
			# Event446.cs:82-88
			d.agents -= 50
			d.budget -= 50
			d.diplomatic_reputation += 30
			if iran != null:
				iran.government = GameConstants.Government.AUTHORITARIAN
				iran.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			ws.influence_prc += 30
			d.iran_islamist_support -= 200
			context["result_text"] = tr("event.script.event_446_449_iran_chain.i2")
		3:
			# Event446.cs:94-96
			d.diplomatic_reputation -= 50
			if iran != null:
				iran.government = GameConstants.Government.AUTHORITARIAN
				iran.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			context["result_text"] = "“我国不会允许这种对人民开火的暴行，”外交部长" + _foreign_minister_name() + "同志如是说道，“但同时，我们也呼吁伊朗方面冷静下来，不要在自己人身上浪费弹药，让伊朗人的子弹去杀伊朗人！”但霍梅尼显然没有听我们的，他决定派出伊朗革命卫队前去镇压，大不里士西北的伊朗空军宣布支持人民。在双方紧张对峙之时，左派学生会产生了分裂，一部分机会主义者倒戈支持霍梅尼。随着革命卫队的坦克开进了大不里士，运动也渐渐消停。随后，大阿亚图拉沙里亚特马达里被软禁。伊朗的未来，似乎走向了一个不可控的地步……"
		4:
			# Event446.cs:102-103
			if iran != null:
				iran.government = GameConstants.Government.AUTHORITARIAN
				iran.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			context["result_text"] = tr("event.script.event_446_449_iran_chain.i3")


func _event_447(option_index: int, context: Dictionary) -> void:
	var iran := _iran()
	match option_index:
		0:
			# Event447.cs:53-55（两个分支共同的前置消耗）
			d.agents -= 200
			d.army -= 200
			d.budget -= 100
			if d.iran_islamist_support > 300:
				# Event447.cs:56-66：伊斯兰势力尚强，政变后君主派雅利安纳夺权
				d.diplomatic_reputation += 30
				if iran != null:
					iran.government = GameConstants.Government.AUTHORITARIAN
					iran.sub_government = GameConstants.SubGovernment.NEO_FASCIST
					iran.set_tag("亲美", true)
				ws.influence_prc += 10
				d.iran_islamist_support -= 1000
				context["result_text"] = tr("event.script.event_446_449_iran_chain.i4")
			else:
				# Event447.cs:68-74：左翼总起义路线，448 由 .tres 的 TRIGGER_EVENT 入队
				d.diplomatic_reputation += 30
				if iran != null:
					iran.government = GameConstants.Government.REFORMIST
					iran.sub_government = GameConstants.SubGovernment.PRAGMATIST
				ws.influence_prc += 50
				d.iran_islamist_support -= 1000
				context["result_text"] = tr("event.script.event_446_449_iran_chain.i5")
		1:
			# Event447.cs:82-88：向伊朗当局告密
			d.agents -= 30
			d.diplomatic_reputation -= 50
			ws.influence_prc += 50
			d.iran_islamist_support += 300
			if iran != null:
				iran.government = GameConstants.Government.AUTHORITARIAN
				iran.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				iran.set_tag("对华贸易", true)
			context["result_text"] = tr("event.script.event_446_449_iran_chain.i6")
		2:
			# Event447.cs:94-96：不介入，人民党自行告密
			if iran != null:
				iran.government = GameConstants.Government.AUTHORITARIAN
				iran.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			d.iran_islamist_support += 300
			context["result_text"] = tr("event.script.event_446_449_iran_chain.i7")


func _event_448(option_index: int, context: Dictionary) -> void:
	var iran := _iran()
	match option_index:
		0:
			# Event448.cs:48-56：支持伊朗人民联盟（左翼）
			d.agents -= 80
			d.budget -= 20
			d.diplomatic_reputation += 50
			ws.influence_prc += 50
			if iran != null:
				iran.government = GameConstants.Government.REFORMIST
				iran.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				iran.set_tag("亲中", true)
				iran.set_tag("对华贸易", true)
				iran.prc_power = 1000
			context["result_text"] = tr("event.script.event_446_449_iran_chain.i8")
		1:
			# Event448.cs:61-69：支持伊朗解放阵线（右翼）
			d.agents -= 80
			d.budget -= 20
			d.diplomatic_reputation -= 50
			ws.influence_prc += 30
			if iran != null:
				iran.government = GameConstants.Government.LIBERAL
				iran.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				iran.set_tag("亲中", true)
				iran.set_tag("对华贸易", true)
				iran.prc_power = 1000
			context["result_text"] = tr("event.script.event_446_449_iran_chain.i9")
		2:
			# Event448.cs:72-87：不介入，由美苏影响力决定选举结果
			var ussr_power := 0
			var usa_power := 0
			if ws.empires.size() > 0 and ws.empires[0] != null:
				usa_power = ws.empires[0].power
			if ws.empires.size() > 1 and ws.empires[1] != null:
				ussr_power = ws.empires[1].power
			if ussr_power >= usa_power:
				# Event448.cs:77-80
				if iran != null:
					iran.government = GameConstants.Government.REFORMIST
					iran.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					iran.set_tag("对华贸易", false)
					iran.set_tag("亲苏", true)
				context["result_text"] = tr("event.script.event_446_449_iran_chain.i10")
			else:
				# Event448.cs:84-87
				if iran != null:
					iran.government = GameConstants.Government.LIBERAL
					iran.sub_government = GameConstants.SubGovernment.NEOLIBERAL
					iran.set_tag("对华贸易", false)
					iran.set_tag("亲美", true)
				context["result_text"] = tr("event.script.event_446_449_iran_chain.i11")


func _event_449(option_index: int, context: Dictionary) -> void:
	var iran := _iran()
	match option_index:
		0:
			# Event449.cs:52-65：支持反对派武装总起义，开启伊朗革命战争
			d.agents -= 100
			d.budget -= 100
			d.diplomatic_reputation += 100
			if ws.wars.size() <= 33:
				ws.wars.resize(34)
			var war := ws.wars[33]
			if war == null:
				war = WarData.new()
				ws.wars[33] = war
			# Event449.cs:55-63
			war.name_war = "伊朗革命战争"
			war.is_going = true
			war.side1 = "伊朗人民革命阵线"
			war.side2 = "伊朗伊斯兰共和国"
			war.ussr_side = GameConstants.WarSide.NONE
			war.usa_side = GameConstants.WarSide.NONE
			war.infl1 = 300
			war.infl2 = 700
			war.fortnight_max = 20
			# Event449.cs:64：原版 gameState.iranrev = true；Godot 无此字段，
			# 暂写入全局标记供后续 450 等事件移植时读取。
			ws.set_flag("iranrev", true)
			# Event449.cs:65
			if iran != null:
				iran.set_tag("对华贸易", false)
			context["result_text"] = tr("event.script.event_446_449_iran_chain.i12")
		1:
			# Event449.cs:71-74：不干涉，伊斯兰共和国稳住阵脚
			if iran != null:
				iran.government = GameConstants.Government.AUTHORITARIAN
				iran.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				iran.set_tag("亲中", false)
				iran.set_tag("对华贸易", false)
			context["result_text"] = tr("event.script.event_446_449_iran_chain.i13")


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.usa_relations = ws.empires[EmpireData.USA].relations
		ws.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.ussr_relations = ws.empires[EmpireData.USSR].relations
		ws.soviet_influence = ws.empires[EmpireData.USSR].power


## 外交部长姓名（politics_positions[2]），缺失回退"黄华"。
func _foreign_minister_name() -> String:
	if ws != null and ws.politics_positions.size() > 2:
		var idx: int = ws.politics_positions[2]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
				and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return "黄华"
