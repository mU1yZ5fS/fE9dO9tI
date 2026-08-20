extends "res://数据脚本/event_script_base.gd"

## 原作 Event463.cs：卡萨布兰卡一夜（摩洛哥干预四选项）。
## 触发：ReqEventForDLC02.cs:402-404 —— DATE_AFTER 1981.6.1；fire_only_once 承担 !event_done[463]。
## 差异：level_of_dev→level_of_development；开战按项目约定 GameManager.start_war(39,...)
##   后覆盖 name_war/fortnight_max（TickTime 20）；AmericanSupportAttacker→usa_side = GameConstants.WarSide.SIDE1，
##   relres→ussr_side = GameConstants.WarSide.SIDE2。

const TXT_OPT0_DIS := "推翻国王，有谁有这个胆子？"
const TXT_OPT1_DIS := "我们没有能力做这种事"
const TXT_OPT2_DIS := "摩洛哥人不想听我们的话！"
const TXT_R0 := "在我们特工的帮助下，运动迅速从卡萨布兰卡蔓延到了全国各大城市。摩洛哥人民力量社会主义同盟没有错过这次机会，在运动中迅速确认了自己的领导地位。随着斗争愈演愈烈，王室感受到了自己时日无多，哈桑二世快速完成了退位并请求新政府的宽恕。然而作为又一位昏庸无能的君主，他的请求被置之不理。在拉巴特的一间地下室里，迟来的保王党人只找到了被打成筛子一般的几具尸体。就这样，统治了摩洛哥数十载的阿拉维王室如风般飘散了。在王室的尸体上，摩洛哥民主共和国从中涅槃，并开始着手收回外企的垄断公司。\n新生的摩洛哥政府决定和西撒哈拉展开谈判，在一系列激烈的辩论和让步后，西撒人阵同意以联邦实体的身份加入摩洛哥。西撒人阵将作为西撒哈拉地区唯一合法的政党，直接统治西撒哈拉地区而不必听从摩洛哥方面的指示。摩洛哥宣布停止沙墙的建设，双方也确定了新的“摩洛哥人”身份。尽管相当多的人谴责西撒人阵背叛了过去的理想，但撒哈拉的局势或多或少稳定下来了。"
const TXT_NAME_FED := "摩洛哥西撒哈拉民主联邦"
const TXT_R1 := "我们在西撒哈拉的布局为我们带来了介入混乱局势的机会。趁着摩洛哥本土陷入混乱的时机，西撒人阵总书记在廷杜夫发表了《告被占领的撒哈拉阿拉伯同胞的信》。其中声泪俱下的控诉了摩洛哥王室在西撒哈拉的暴行，如：强制驱逐原住民，强迫劳役和不公正对待。“但是这一切就要结束了”，RASD的电台如是说道，“在我们阿拉伯兄弟们的帮助下，阵线已经重整旗鼓，做好了为1975年复仇的准备。”在广播结束后的半天内，大量的土制火箭弹从阿尔及利亚和尚未被占领的西撒哈拉领土射向北部。阿尤恩的损失尤为严重。西撒人阵的战士们乘着bmp步战车和皮卡车攻入北部和沿海的城市。摩洛哥政府宣布进入紧急状态，开始调兵遣将准备镇压新的一轮叛乱。"
const TXT_WAR_NAME := "第二次西撒哈拉独立战争"
const TXT_WAR_SIDE1 := "摩洛哥王国"
const TXT_WAR_SIDE2 := "西撒哈拉"
const TXT_R2 := "我们的外交部公开谴责了摩洛哥王室对于进步人士的镇压。“这种残酷的法西斯主义暴行，丝毫不亚于墨索里尼的意大利和佛朗哥的西班牙！”许多非洲和第三世界国家也纷纷支持我们的决定，他们呼吁对摩洛哥实施一轮制裁。非洲统一组织正在考虑是否要对摩洛哥采取“特别行动”。\n多说无益，我们决定借助混乱的局势开始下一盘大棋。"
const TXT_R2_A := "\n通过拉巴特的线人，我们设法组织了Tanzim（全国人民力量联盟的激进派）、摩洛哥人民力量社会主义同盟的民族政治委员会派，68运动时期的“前进”组织，“三月二十三日运动”与进步与社会主义党左翼的联合阵线。各派就打入摩洛哥总工会和陆军达成了一致，正式确定了马克思，列宁和毛泽东思想为核心的纲领。四个党派就组建摩洛哥社会主义革命党达成了协议，外号“老战士”的穆罕默德·本·赛义德被推举为第一书记，而下辖的武装团体—“铁拳突击队”和摩洛哥人民解放阵线也在组建中，尽管他们现在力量极弱，但假以时日，和一点火花，他们定能大有作为。"
const TXT_R2_B := "\n看到哈桑二世的政局出现了问题，我们决定押宝于艾哈迈德·奥斯曼的全国自由人士联盟。这是一个对君主制抱有中立态度，但愿意开放党禁和经济大幅度自由化的组织。作为该国的首相，他能够轻松的介入局势。很快，宪政联盟，，民主独立党和自由联盟就组建人民阵线达成了一致。奥斯曼还在隐忍，只是还没到和自己姑姑撕破脸的时候，至少现在不行。"
const TXT_R2_C := "\n卡萨布兰卡的军人收到了行动指令。一瞬间，军队对手无寸铁的平民扣下了板机，一条又一条鲜活的生命就此倒在了曾发誓过保护他们的人的枪口下。涉嫌挑战政府的摩洛哥人民力量社会主义同盟也遭到了沉重打击，一批骨干成员被当众处死。\n大幅削弱了反对派的国王政府将自己确定为美国鹰犬，越发的和其紧密相连。"
const TXT_R3 := "卡萨布兰卡的军人收到了行动指令。一瞬间，军队对手无寸铁的平民扣下了板机，一条又一条鲜活的生命就此倒在了曾发誓过保护他们的人的枪口下。涉嫌挑战政府的摩洛哥人民力量社会主义同盟也遭到了沉重打击，一批骨干成员被当众处死。\n大幅削弱了反对派的国王政府将自己确定为美国鹰犬，越发的和其紧密相连。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line56 := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
	var morocco := world.get_country_by_legacy_index(54)
	var opt := event_def.options
	if morocco != null and morocco.内战中 and line56 < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line56 <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line56 != 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var morocco := _country(54)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if morocco != null:
				morocco.government = GameConstants.Government.REFORMIST
				morocco.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				morocco.set_tag("亲美", false)
				morocco.set_tag("对华贸易", true)
				morocco.set_tag("亲中", true)
				morocco.chinese_name = TXT_NAME_FED
			_add_relation(EmpireData.USA, -100)
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
		1:
			context["result_text"] = TXT_R1
			_add(W.I_BUDGET, -30)
			_add(W.I_ARMY, -80)
			_add_relation(EmpireData.USA, -80)
			_add(W.I_DIPLO, -50)
			var num := 0
			for idx in [40, 55, 13, 14, 35, 42, 104, 93]:
				var c := _country(idx)
				if c != null and (c.has_tag("亲中") or c.government == GameConstants.Government.SOCIALIST):
					num += 20
			var c25 := _country(25)
			var c24 := _country(24)
			if (c25 != null and (c25.has_tag("亲中") or c25.government == GameConstants.Government.SOCIALIST)) or (c24 != null and (c24.has_tag("亲中") or c24.government == GameConstants.Government.SOCIALIST)):
				num += 20
			var c18 := _country(18)
			if c18 != null and c18.内战中:
				num += 50
			var c86 := _country(86)
			if c86 != null and c86.sub_government != GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
				num += 30
			GameManager.start_war(39, TXT_WAR_SIDE1, TXT_WAR_SIDE2, 700 - num, 300 + num, 0)
			var war := _get_war(39)
			if war != null:
				war.name_war = TXT_WAR_NAME
				war.fortnight_max = 20
				if ws.get_flag("relres"):
					war.ussr_side = GameConstants.WarSide.SIDE2
		2:
			var line56 := _res(W.I_POLITICAL_LINE)
			if line56 <= 1:
				context["result_text"] = TXT_R2 + TXT_R2_A + TXT_R2_C
				if morocco != null:
					morocco.level_of_development = 1
			else:
				context["result_text"] = TXT_R2 + TXT_R2_B + TXT_R2_C
				if morocco != null:
					morocco.level_of_development = 3
			_add_relation(EmpireData.USA, -80)
			_add(W.I_DIPLO, -50)
		3:
			context["result_text"] = TXT_R3
			_add_power(EmpireData.USA, -20)




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)


func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


