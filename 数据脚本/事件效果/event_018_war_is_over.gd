extends "res://数据脚本/event_script_base.gd"

## 原作 Event18.cs：战争结束结算弹窗。逐字中文 + 完整效果复刻。
## 架构说明：原版 WarResult（GameState.cs:24-4829，战争结算文案+效果）在端口由
## GameManager._apply_war_result（简化版，覆盖 0-6+ 号战争）于事件关闭后执行；
## 本脚本负责复刻 Event18 的显示层（动态标题/描述/按钮）与结果层（result 0）。
## 差异：
##  - 原版 result 0 先置 text="另一场战争结束了。" 再经 WarResult(ref text) 追加结算文案；
##    端口结算文案无（_apply_war_result 无文案），result_text 仅保留首句，结算效果由引擎执行。
##  - 69/70 号战争战败 → data[35]=11/12 + load_scene_after_click（蒙古/海参崴结局）：
##    端口 ENDINGS 表仅 0-7 → 差异注释，不触发结局（69/70 号战争端口也不存在）。
##  - 端口触发：GameManager._check_war_endings（战争达结算条件 → start_event("war_is_over")），
##    原版由 Event476 链触发，等价。


# ── 显示前动态文案（复刻 Event18.cs TextOfEvents + VariantsOfEvents） ──

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	d = world.数值表
	var war_id: int = d[W.I_WAR_RESOLVE] if d.size() > W.I_WAR_RESOLVE else -1
	var war := _get_war(war_id)
	var war_name := war.name_war if war != null else ""

	# TextOfEvents 分支
	if _is_mongol_defeat(war_id, war):
		event_def.title = "真该死！"
		event_def.description = "在长时间的血腥冲突之后“%s”终于结束了。\n前线的状态并不乐观……" % war_name
	elif _is_japan_revolution(war_id, war):
		event_def.title = "日本革命的胜利！"
		event_def.description = "在长时间的血腥冲突之后“%s”终于结束了。\n在得到了大量的人力物力支援后，日本人民革命阵线迅速夺取了九州、四国、北海道等地的地方政权。得益于此前党员们的积极活动，革命阵线早在起义之前便已秘密组织了一批工人赤卫队。得到帮助的革命队伍很快便控制了当地的警局、自卫队基地等关键点。战士们迅速收缴武器、归拢被俘人员，并对政府的通信线路进行了彻底的破坏。等到日本政府费尽心机好不容易勉强恢复通讯的时候，革命军的主力已经完成了集结，队伍由缴获的坦克和装甲车带头，加紧向东京进发。收到政府求救消息的美军基地试图行动，但是革命军在起义的第一时间就对基地进行了全面封锁，切断物资供给的同时派出受过特训的小分队秘密潜入基地对补给仓库进行破坏，这让基地内美军的日子越来越不好过。正如一位革命军中层指挥官所说：“就算是一只鸟也不许飞进基地。”此外，革命军还通过传单、喇叭、电台、电视录像带等渠道对自卫队成员展开了宣传攻势，指出革命洪流不可阻挡的同时也点明了自卫队成员自身的困境，呼吁他们“同日本人民站在一起”。一部分自卫队人员被成功策反，向革命军提供了许多情报，这让战斗变得更加顺利了。\n处于混乱和绝望中的日本政府妄图动员一切能动员的力量，指派首都地区自卫队保卫城市的同时与北约成员国联系，希望借它们的力量平息革命。但在人民的支持下，这种负隅顽抗是毫无意义的。同时我们对革命军提供了全方位的军事技术指导，并且向他们提供了自卫队的完整武器装备情况。有了我们的支持，在革命军的多重攻势下，东京被成功攻克。自卫队残余成员放下了武器，而前政府部分成员则匆忙乘飞机逃往威克岛。那些未来得及逃走的人则和天皇家族的成员一起被革命军俘虏。等待着他们的将是日本人民的审判。" % war_name
	elif _is_kefir_doom(war_id, war):
		event_def.title = "凯菲尔的末日"
		event_def.description = "同志，巴格达传来了灾难性的消息，伊拉克政权在两伊战争中遭到了灾难性的战败。\n新生的革命政权被伊朗的庞大榨干了最后一丝热血。在巴士拉艰苦卓绝的拉锯战中，双方最优秀的儿女纷纷殒命沙场，但伊朗的人数远远多于伊拉克人。在一次又一次的自杀式袭击后，巴士拉被攻破。伊朗军队士气大张，下一个目标一直在变，先是纳西里耶，再是萨马沃，到纳杰夫……而伊拉克内部的派系矛盾也被伊朗所利用，库尔德和阿拉伯人，逊尼派和什叶派的，甚至是革命者和前政府官员的矛盾。在库尔德人宣布脱离共和国独立的时候，伊朗人已经攻入了伊斯坎德里耶，而巴格达也已经不远了。终于，革命政府宣布投降，伊拉克社会主义工农党也宣布解散。"
	elif war_id > 7:
		event_def.title = "战争结束了"
		event_def.description = "在长时间的血腥冲突之后“%s”终于结束了。我国外交部密切留意全程，并已准备好为您汇报战争的最终结果。" % war_name
	else:
		event_def.title = "战争结束了"
		event_def.description = "在长时间的血腥冲突之后“%s”终于结束了。" % war_name
		# 6/2 特判与通用胜负追加（Event18.cs TextOfEvents 尾部）
		if war_id == 6 and war != null:
			if war.infl1 >= 400:
				event_def.description += " 最终，胜利属于 %s  一方，他们得以通过战争中实现其目标。" % war.side1
			else:
				event_def.description += " 最终，胜利属于 %s  一方，他们得以通过战争中实现其目标。" % war.side2
		elif war_id == 2 and war != null:
			if war.infl1 >= 750:
				event_def.description += " 最终，胜利属于 %s  一方，他们得以通过战争中实现其目标。" % war.side1
			else:
				event_def.description += " 最终，胜利属于 %s  一方，他们得以通过战争中实现其目标。" % war.side2
		elif war != null and (war.infl1 >= 900 or war.infl2 >= 900):
			var winner := war.side1 if war.infl1 > war.infl2 else war.side2
			event_def.description += " 最终，胜利属于 %s  一方，他们得以通过战争中实现其目标。" % winner
		elif war_id == 2 or war_id == 4:
			event_def.description += " 最终，胜利属于 %s  一方，他们得以通过战争中实现其目标。" % war.side2
		else:
			event_def.description += " 双方都没有取得决定性的胜利，因此无条件和平协议得以签署，使边界恢复到战前状态。"

	# VariantsOfEvents 分支（唯一按钮文案）
	var button_text := ""
	if war_id < 8:
		button_text = "和平万岁！"
	elif _is_mongol_defeat(war_id, war):
		button_text = "发生什么了？"
	elif _is_japan_revolution(war_id, war):
		button_text = "为我们日本同志的胜利敬一杯！"
	elif _is_kefir_doom(war_id, war):
		var line: int = d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
		if line == 0:
			button_text = "他们没能建成地上天国"
		elif line > 0 and line < 3:
			button_text = "真主还是对扎利姆降下了惩罚"
		else:
			button_text = "绿色共匪战胜了红色法西斯"
	elif war_id >= 8:
		button_text = "结果不得不看！"
	if event_def.options.size() > 0:
		event_def.options[0].text = button_text


# ── 结果（复刻 Event18.cs ResultsOfEvents result 0） ──

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var war_id: int = d[W.I_WAR_RESOLVE] if d.size() > W.I_WAR_RESOLVE else -1
	var war := _get_war(war_id)
	context["result_text"] = "另一场战争结束了。"
	# 差异：原版此处追加 WarResult 结算文案；端口结算效果由 GameManager.resolve_war_finished
	# （事件关闭后）执行，无结算文案。
	if _is_mongol_defeat(war_id, war):
		context["result_title"] = "真该死！"
		context["result_text"] = "出乎我们的意料，孱弱的蒙古军队设法逼退了中国人民解放军。由于战争初期的失误指挥，我们的先遣部队在乌兰巴托残酷的巷战中损失惨痛。而蒙古民众也并不相信我们能为他们带来解放。纷纷拿起苏制装备躲进山区里，或是骑在马上把我们的巡逻队员绞杀至死。极端民族主义组织“白色十字”甚至成功的暗杀了我们指挥对蒙作战的军事首长。苏联以自愿报名为由派遣了成建制的“志愿军”，古巴和法国的雇佣兵也通过苏联来到蒙古，在各个地方运用他们在非洲学到的知识，打击我们的战士。在惨痛的绞肉战后，这场军事冒险在丢下几万具尸体后惨败收场。最耻辱的莫过于蒙古甚至设法攻克了二连浩特，当着我们全体电视观众的面把我们的国旗扯下并点燃。在各国的斡旋和美国的武力威胁下，我们只得灰溜溜的撤出蒙古。蒙古政府把这次胜利比做二十一世纪的土木堡之战。他们增加了军费，甚至采购了导弹。等等，门口的敲门声是？"
		# 差异：原 data[35]=11（蒙古胜利结局）+ load_scene_after_click；端口 ENDINGS 无 11 → 跳过。
	elif _is_ussr_victory(war_id, war):
		context["result_title"] = "真该死！"
		context["result_text"] = "苏联通过背靠北约盟友，将亚洲大战变为了不亚于日俄战争的残酷绞肉机。虽然我们的海军得以封锁库页岛，并将苏联的海军困死在港口内；但我们的陆军并没能在各个方向取得进展，他们只能困守海参崴和伯力。此后，苏联人更是借助美方导弹平台轰炸我核心工业区与关键城市，甚至让北京也陷入威胁当中。在付出数十万人的伤亡后，我们不得不回到谈判桌上同苏联达成妥协，而作为战争的发起者的你定没有好下场……"
		# 差异：原 data[35]=12（海参崴结局）+ load_scene_after_click；端口 ENDINGS 无 12 → 跳过。


# ── 分支判定辅助（逐字复刻 Event18.cs 条件） ──

func _get_war(war_id: int) -> WarData:
	if war_id >= 0 and war_id < ws.wars.size():
		return ws.wars[war_id]
	return null


func _is_mongol_defeat(war_id: int, war: WarData) -> bool:
	if war_id != 69 and war_id != 70:
		return false
	return war != null and war.infl1 < 1000


func _is_japan_revolution(war_id: int, war: WarData) -> bool:
	return war_id == 36 and war != null and war.infl2 >= 1000


func _is_kefir_doom(war_id: int, war: WarData) -> bool:
	if war_id != 3 or war == null or war.infl1 >= 900:
		return false
	var iraq := ws.get_country_by_legacy_index(14)
	return iraq != null and iraq.government == 1


func _is_ussr_victory(war_id: int, war: WarData) -> bool:
	return war_id == 70 and war != null and war.infl1 < 1000
