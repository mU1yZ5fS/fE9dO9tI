extends "res://数据脚本/event_script_base.gd"

## 原作 Event18.cs：战争结束结算弹窗。逐字中文 + 完整效果复刻。 ## 架构说明：原版 WarResult（GameState.cs:24-4829，战争结算文案+效果）在端口由 ## GameManager._apply_war_result（简化版，覆盖 0-6+ 号战争）于事件关闭后执行； ## 本脚本负责复刻 Event18 的显示层（动态标题/描述/按钮）与结果层（result 0）。 ## 差异： ##  - 原版 result 0 先置 text="另一场战争结束了。" 再经 WarResult(ref text) 追加结算文案； ##    端口现在用 war_result_texts.json 查表复刻 WarResult 文案，数值/领土/政体效果仍由 ##    war_system.gd（事件关闭后）执行，本脚本不做数值修改。 ##  - 69/70 号战争战败 → data.ending_route=11/12 + load_scene_after_click（蒙古/海参崴结局）。 ##  - 端口触发：GameManager._check_war_endings（战争达结算条件 → start_event("war_is_over")）， ##    原版由 Event476 链触发，等价。


# ── 显示前动态文案（复刻 Event18.cs TextOfEvents + VariantsOfEvents） ──

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	d = world
	var war_id: int = d.war_resolve if d.size() > W.I_WAR_RESOLVE else -1
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
		var line: int = d.political_line if d.size() > W.I_POLITICAL_LINE else 0
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
	var war_id: int = d.war_resolve if d.size() > W.I_WAR_RESOLVE else -1
	var war := _get_war(war_id)
	# 统一从战争结束文本查找表读取。原版 WarResult 的数值/领土效果已由
	# war_system.gd 在事件关闭后执行，这里只负责文案显示。
	context["result_text"] = _lookup_war_result_text(war_id, war)
	if _is_mongol_defeat(war_id, war):
		context["result_title"] = tr("event.script.event_018_war_is_over.i0")
		# 原 Event18.cs:143：data.war_resolve==69 && ingamewars[69].infl1<1000 → data.ending_route=11 + load_scene_after_click。
		# Godot 用 queue_ending_after_event 复现「结果页确认后进结局」。
		game.queue_ending_after_event(11)
	elif _is_ussr_victory(war_id, war):
		context["result_title"] = tr("event.script.event_018_war_is_over.i1")
		# 原 Event18.cs:151：data.war_resolve==70 && ingamewars[70].infl1<1000 → data.ending_route=12 + load_scene_after_click。
		game.queue_ending_after_event(12)


# ── WarResult 文案查找表（资产/数据/war_result_texts.json） ──

const WAR_RESULT_TEXTS_PATH := "res://资产/数据/war_result_texts.json"
const WAR_RESULT_FALLBACK := "event.script.event_018_war_is_over.c1"

static var _war_result_texts: Dictionary = {}
static var _war_result_texts_loaded := false


static func _load_war_result_texts() -> Dictionary:
	if _war_result_texts_loaded:
		return _war_result_texts
	_war_result_texts_loaded = true
	if not FileAccess.file_exists(WAR_RESULT_TEXTS_PATH):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(WAR_RESULT_TEXTS_PATH))
	if parsed is Dictionary:
		_war_result_texts = parsed
	return _war_result_texts


## 从当前战争条目里取一个分支文案。
func _t(entry: Dictionary, key: String) -> String:
	if entry.has(key):
		return String(entry.get(key, ""))
	return ""


## 统一入口：按 war_id 分派到 JSON 分支；找不到时安全回退通用文案。
func _lookup_war_result_text(war_id: int, war: WarData) -> String:
	if war == null or d == null:
		return tr(WAR_RESULT_FALLBACK)
	var table := _load_war_result_texts()
	var entry := {}
	if table.has(str(war_id)) and table.get(str(war_id)) is Dictionary:
		entry = table.get(str(war_id))
	if entry.is_empty():
		return tr(WAR_RESULT_FALLBACK)
	var txt := ""
	match war_id:
		0:
			if war.infl1 >= 900:
				txt = _t(entry, "a")
			elif war.infl2 >= 900:
				txt = _t(entry, "b")
			else:
				txt = _t(entry, "draw")
		1:
			# 原版还有 gameState.war==1 的全套越南解放子分支；端口暂无该独立状态， # 先用主胜负分支（结果页不再显示通用“另一场战争结束了”）。
			if war.infl1 >= 900:
				txt = _t(entry, "a")
			elif war.infl2 >= 900:
				txt = _t(entry, "b")
			else:
				txt = _t(entry, "draw")
		2:
			txt = _t(entry, "a") if war.infl1 >= 750 else _t(entry, "b")
		3:
			txt = _war3_result_text_from_table(entry, war)
		4:
			txt = _war4_result_text_from_table(entry, war)
		6:
			txt = _t(entry, "a") if war.infl1 >= 400 else _t(entry, "b")
		7:
			txt = _war7_result_text_from_table(entry, war)
		8:
			if war.infl1 >= 500:
				txt = _t(entry, "a")
			elif war.infl2 >= 800:
				txt = _t(entry, "b")
			else:
				txt = _t(entry, "draw")
		9:
			if war.infl1 >= 600:
				txt = _t(entry, "a")
			elif war.infl2 >= 800:
				txt = _t(entry, "b")
			else:
				txt = _t(entry, "draw")
		10:
			txt = _t(entry, "a") if war.infl1 >= 700 else _t(entry, "b")
		11:
			txt = _t(entry, "a") if war.infl1 >= 700 else _t(entry, "b")
		12:
			txt = _t(entry, "a") if war.infl1 >= 700 else _t(entry, "b")
		17:
			txt = _t(entry, "a") if war.infl1 >= 850 else _t(entry, "b")
		18:
			txt = _t(entry, "a") if war.infl1 >= 900 else _t(entry, "b")
		24:
			txt = _t(entry, "a") if war.infl2 >= 900 else _t(entry, "b")
		25:
			txt = _t(entry, "a") if war.infl2 >= 900 else _t(entry, "b")
		26:
			txt = _t(entry, "a") if war.infl2 >= 900 else _t(entry, "b")
		27:
			txt = _war27_result_text_from_table(entry, war)
		29:
			txt = _war29_result_text_from_table(entry, war)
		31:
			txt = _t(entry, "a") if war.infl1 >= 900 else _t(entry, "b")
		32:
			txt = _t(entry, "a") if war.infl1 >= 900 else _t(entry, "b")
		15:
			txt = _war15_result_text_from_table(entry, war)
		16:
			txt = _war16_result_text_from_table(entry, war)
		22:
			txt = _t(entry, "a") if war.infl1 >= 900 else _t(entry, "b")
		23:
			# 意大利战争（原版 GameState.cs:1247-1338）：两个阶段共用一个 war23 槽。
			# 新阶段区分：event_556（意大利内战/激进派起义）→ 起义 a/b；
			# event_396（第二次复兴运动）→ 复兴 rev_win/rev_lose。
			txt = _war23_result_text_from_table(entry, war)
		34:
			txt = _t(entry, "a") if war.infl1 >= 850 else _t(entry, "b")
		35:
			txt = _t(entry, "a") if war.infl1 >= 850 else _t(entry, "b")
		39:
			txt = _war39_result_text(war)
		43:
			# 阿拉伯湾革命：side1=海湾政府方、side2=阿湾人阵起义军（Event568 开战）。
			# 表内 a=人阵解放文案、b/draw=革命被绞杀文案——与默认 a/b 方向相反。
			if war.infl1 >= 900:
				txt = _t(entry, "b")
			elif war.infl2 >= 900:
				txt = _t(entry, "a")
			else:
				txt = _t(entry, "draw")
		45, 46, 47:
			# 墨西哥起义/统一战争：原版以 side2（南方解放军/教权派）胜利显示 a，否则 b。
			txt = _t(entry, "a") if war.infl2 >= 900 else _t(entry, "b")
		69:
			# 保留现有战败结局：infl1 < 1000 时走蒙古战败文案。
			txt = _t(entry, "b") if _is_mongol_defeat(war_id, war) else _t(entry, "a")
		70:
			# 原版按 event_done[642] 区分两条获胜/失败路线；端口保留两条文案。
			if d.event_done_num(642):
				txt = _t(entry, "win_b") if war.infl1 >= 950 else _t(entry, "defeat_b")
			else:
				txt = _t(entry, "win_a") if war.infl1 >= 950 else _t(entry, "defeat_a")
		86:
			txt = _war86_result_text_from_table(entry, war)
		87:
			# 爱尔兰统一战争：side1=北爱尔兰、side2=爱尔兰共和国。 # a=南方（爱尔兰共和国）吞并北方；b=北方空降都柏林获胜；draw=北方反推成功。 # 不能走默认 a/b 顺序，否则北胜会显示南胜文案。
			if war.infl1 >= 900:
				txt = _t(entry, "b")
			elif war.infl2 >= 900:
				txt = _t(entry, "a")
			else:
				txt = _t(entry, "draw")
		_:
			# 未精细接线的战争：若表里有 a/b/draw，按通用胜负阈值取一条。
			if entry.has("a") and entry.has("b"):
				if war.infl1 >= 900:
					txt = _t(entry, "a")
				elif war.infl2 >= 900:
					txt = _t(entry, "b")
				else:
					txt = _t(entry, "draw") if entry.has("draw") else _t(entry, "b")
			elif entry.has("a"):
				txt = _t(entry, "a")
	if txt.is_empty():
		return tr(WAR_RESULT_FALLBACK)
	return txt


## 两伊战争（war3）分支：按原版 GameState.cs:216-351 的政体/战争态势拆文本。
func _war3_result_text_from_table(entry: Dictionary, war: WarData) -> String:
	var iraq := ws.get_country_by_legacy_index(14) if ws != null else null
	var iran := ws.get_country_by_legacy_index(8) if ws != null else null
	if iraq != null and (iraq.sub_government == 4 or iraq.sub_government == 20) \
			and iraq.puppet_of < 0:
		return _t(entry, "peace")
	var iraq_soc: bool = iraq != null and ws.is_socialism(iraq, true)
	var iran_soc: bool = iran != null and ws.is_socialism(iran, true)
	if war.infl1 >= 900:
		if iran_soc:
			return _t(entry, "both_socialist") if iraq_soc else _t(entry, "iran_socialist_only")
		if iraq != null and iraq.sub_government == 2:
			return _t(entry, "iran_mao_revolution")
		if iraq != null and iraq.sub_government == 16:
			return _t(entry, "iran_other_revolution")
		return _t(entry, "iraq_meks_win")
	if iran_soc:
		return _t(entry, "both_socialist") if iraq_soc else _t(entry, "iran_socialist_only")
	if iraq_soc:
		return _t(entry, "iraq_islamic_puppet")
	return _t(entry, "china_aid_iran")


## 黎巴嫩/中东战争（war4）：按 event711/event371 分支取文本。
func _war4_result_text_from_table(entry: Dictionary, war: WarData) -> String:
	if d.event_done_num(711):
		return _t(entry, "r0") if war.infl1 >= 900 else _t(entry, "r1")
	if not d.event_done_num(371):
		return _t(entry, "r2") if war.infl1 >= 900 else _t(entry, "r3")
	if war.infl1 >= 700:
		return _t(entry, "r4")
	if war.infl2 >= 500:
		return _t(entry, "r5")
	return _t(entry, "r6")


## 印度内战（war7）：原版 GameState.cs:505-571，按 infl1 与 resultOfEvents[125] 分四支。
func _war7_result_text_from_table(entry: Dictionary, war: WarData) -> String:
	var result125 := d.result_of_event_num(125) if d != null else 0
	if war.infl1 >= 900:
		return _t(entry, "win_125_0") if result125 == 0 else _t(entry, "win_125_1")
	return _t(entry, "lose_125_1") if result125 == 1 else _t(entry, "lose_125_0")


## 老挝内战（war27）：infl1>=500 政府胜，否则叛军胜（原版 1241 模板无占位符，proprc 后缀实际不参与）。
func _war27_result_text_from_table(entry: Dictionary, war: WarData) -> String:
	return _t(entry, "a") if war.infl1 >= 500 else _t(entry, "b")


## 意大利战争（war23）两个阶段（原版 GameState.cs:1247-1338）： ## 事件556（意大利内战/激进派起义）→ 起义文本 a/b； ## 事件396（第二次复兴运动）→ 复兴文本 rev_win/rev_lose。 ## 原文以 event_done[556] 区分；之前端口把两段都命中了 a/b/draw， ## 导致“第二次复兴运动”结算显示起义文本（搞混），此处按原版分派。
func _war23_result_text_from_table(entry: Dictionary, war: WarData) -> String:
	if d != null and d.event_done_num(556):
		return _t(entry, "rev_win") if war.infl1 >= 900 else _t(entry, "rev_lose")
	return _t(entry, "a") if war.infl1 >= 900 else _t(entry, "b")


## 伊拉克-科威特战争（war29）：原版 GameState.cs:1532-1626，按中国阵营/影响力分多支。
func _war29_result_text_from_table(entry: Dictionary, war: WarData) -> String:
	var china := ws.get_country_by_legacy_index(1) if ws != null else null
	var is_ovd: bool = china != null and china.has_tag("ovd")
	var is_seato: bool = china != null and china.has_tag("seato")
	var prc_influence: int = d.influence_prc if d != null else 0
	var ussr_power: int = 0
	var usa_power: int = 0
	if d != null and d.empires.size() > EmpireData.USSR and d.empires[EmpireData.USSR] != null:
		ussr_power = d.empires[EmpireData.USSR].power
	if d != null and d.empires.size() > EmpireData.USA and d.empires[EmpireData.USA] != null:
		usa_power = d.empires[EmpireData.USA].power
	if war.infl1 >= 900:
		if is_ovd:
			return _t(entry, "a_ovd_prc") if prc_influence >= ussr_power else _t(entry, "a_ovd_sov")
		if is_seato:
			return _t(entry, "a_seato_prc") if prc_influence >= usa_power else _t(entry, "a_seato_usa")
		return _t(entry, "a_neutral")
	if war.infl2 >= 500:
		if is_ovd:
			return _t(entry, "b_ovd")
		if is_seato:
			return _t(entry, "b_seato")
		return _t(entry, "b_neutral")
	if is_ovd:
		return _t(entry, "draw_ovd")
	if is_seato:
		return _t(entry, "draw_seato")
	return _t(entry, "draw_neutral")


## 欧加登战争（war15）：按是否已触发 event588 分两阶段。
func _war15_result_text_from_table(entry: Dictionary, war: WarData) -> String:
	if not d.event_done_num(588):
		return _t(entry, "a") if war.infl1 >= 850 else _t(entry, "b")
	if war.infl1 >= 900:
		return _t(entry, "a2")
	if war.infl2 >= 900:
		return _t(entry, "b2")
	return _t(entry, "draw2")


## 朝鲜统一战争（war16）：动态模板填充国号/执政党，第三段按北朝鲜 SubGosstroy 分支。 ## 原版 GameState.cs:928-1012：0-17 → new_events_text[983+sub]；18 → [1187]； ## 19（孔镇泰/红儒）与 20/21/22 为内联文案，已全部转录进 war_result_texts.json 的 third_*。
func _war16_result_text_from_table(entry: Dictionary, war: WarData) -> String:
	if war.infl1 < 950:
		return _t(entry, "defeat")
	var china := ws.get_country_by_legacy_index(1) if ws != null else null
	var num := 2
	if china != null:
		match china.government:
			GameConstants.Government.AUTHORITARIAN:
				num = 1
			GameConstants.Government.SOCIALIST:
				num = 2
			GameConstants.Government.REFORMIST:
				num = 3
			_:
				num = 4
	var tpl := _t(entry, "victory_template")
	var north := ws.get_country_by_legacy_index(10) if ws != null else null
	var sub := int(north.sub_government) if north != null else -1
	var third := _t(entry, "third_%d" % sub) if sub >= 0 else ""
	if third == "":
		third = _t(entry, "third_default")
	return tpl \
		.replace("{1}", _t(entry, "country_%d" % num)) \
		.replace("{2}", _t(entry, "party_%d" % num)) \
		.replace("{3}", third)


## 北爱尔兰（war86）：简化按 infl1/infl2 取分支；原版 data[147]/data[166] 细节暂未接线。
func _war86_result_text_from_table(entry: Dictionary, war: WarData) -> String:
	if war.infl1 >= 900:
		return _t(entry, "rebel_win")
	if war.infl2 >= 900:
		return _t(entry, "britain_win")
	return _t(entry, "peaceful_withdrawal")


# ── 分支判定辅助（逐字复刻 Event18.cs 条件） ──

## 西撒哈拉战争（war39）结算文案：GameState.cs:1969-2007 三分支。 ## 注意：人阵可能是 side2（tres 默认：side1=摩洛哥）也可能是 side1 ## （其他事件以自定义顺序开战），按交战方名字动态判边，防止胜负文案颠倒。
func _war39_result_text(war: WarData) -> String:
	var polisario := ws.get_country_by_legacy_index(18) if ws != null else null
	var is_cw: bool = polisario != null and polisario.内战中
	var polisario_is_side1: bool = String(war.side1).contains("西撒") \
			or String(war.side1).contains("人阵") or String(war.side1).contains("波利萨里奥")
	var polisario_win: bool = (war.infl1 >= 900) if polisario_is_side1 else (war.infl2 >= 900)
	if polisario_win:
		if is_cw:
			return "在艰苦奋斗后，西撒人阵的步战车攻入了首府阿尤恩的市中心。胜利的旗帜飘扬在这座古老的城市上空，这天也被定为撒哈拉阿拉伯民主共和国的解放日。工人，游击战士和农民推着画有马克思，列宁和毛泽东的画像的花车。举着“共产主义带来大饼与和平”之类的标语牌走过市中心，这片古老的土地焕发着前所未有的生命力。而摩洛哥不得不打碎牙齿往嘴里吞，苦涩的承认了西撒哈拉的独立地位。\n国际观察家认为，西撒人阵背后的中华人民共和国又一次在国际交锋中为自己带来了战友和同志。"
		return "在艰苦奋斗后，西撒人阵的步战车攻入了首府阿尤恩的市中心。胜利的旗帜飘扬在这座古老的城市上空，这天也被定为撒哈拉阿拉伯民主共和国的解放日。工人，游击战士和农民推着花车，举着“自由，独立，社会主义是我们的目标”之类的标语牌走过市中心，这片古老的土地焕发着前所未有的生命力。而摩洛哥不得不打碎牙齿往嘴里吞，苦涩的承认了西撒哈拉的独立地位。"
	return "毫不意外的说，摩洛哥以碾压性的优势击败了西撒人阵。在丢下了一地尸体和各式辎重与战车后，他们灰溜溜的离开了自己的祖国，逃往了阿尔及利亚或毛里塔尼亚北部的弱国家地区。摩洛哥王国卫队趾高气扬的在阿尤恩展开了阅兵，哈桑二世在庆功演讲时说道：“只要阿拉维王朝屹立不倒，西撒哈拉的分离主义者就永无明日！”\n美国加大了和摩洛哥王室的合作，并在卡萨布兰卡开始了一个新的监听站。"


func _get_war(war_id: int) -> WarData:
	if war_id >= 0 and war_id < ws.wars.size():
		return ws.wars[war_id]
	return null


func _is_mongol_defeat(war_id: int, war: WarData) -> bool:
	# 原 Event18.cs:140 只判 69 号战争；70 号属于苏联胜利分支（Event18.cs:149）。
	return war_id == 69 and war != null and war.infl1 < 1000


func _is_japan_revolution(war_id: int, war: WarData) -> bool:
	return war_id == 36 and war != null and war.infl2 >= 1000


func _is_kefir_doom(war_id: int, war: WarData) -> bool:
	if war_id != 3 or war == null or war.infl1 >= 900:
		return false
	var iraq := ws.get_country_by_legacy_index(14)
	return iraq != null and iraq.government == GameConstants.Government.SOCIALIST


func _is_ussr_victory(war_id: int, war: WarData) -> bool:
	return war_id == 70 and war != null and war.infl1 < 1000



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_018_war_is_over.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "war_is_over",
	"num": 18,
	"notify": false,
	"once": false,
	"display_script": "res://数据脚本/事件效果/event_018_war_is_over.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
