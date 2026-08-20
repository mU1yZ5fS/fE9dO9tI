extends "res://数据脚本/event_script_base.gd"

## 原作 Event621.cs：一个独裁者将会被另一个独裁者杀死（赤道几内亚政变，四选项）。
## 触发：ReqEventForDLC02.cs:934-936 —— IsAuthoritarianism(115) && DATE_AFTER 1979.8.1。
## 差异：Torg→对华贸易、proprc→亲中；puppetOf=21 照抄。

const TXT_OPT0_DIS := "为什么要帮助独裁者的亲戚？"
const TXT_OPT1_DIS := "为什么要协助这个疯子？"
const TXT_OPT2_DIS := "我们为何要帮助帝国主义者进行侵略？"
const TXT_R0 := "我们决定帮助他们解决马西埃这个疯子，8月3日，听命于奥比昂的军队占领了首都马拉博并宣告马西埃被推翻，但是与此同时仍然发电报给马西埃要求其投降。在马西埃拒绝之后，由涂成黑脸的中国特勤和一些奥比昂的士兵将马西埃进行秘密绑架并送回了政变军所控制的地区，听闻马西埃被捕的消息，剩余原本支持马西埃的军队放下武器投降，奥比昂最终政变成功。在审判之前由于赤道几内亚根本没有宪法，不得不使用西班牙的军事法律对其进行审判。最终以种族灭绝罪，大规模谋杀等罪名判处马西埃等高层死刑。奥比昂很感激我们，选择扩大与我们的合作。之后在全民公投中通过了新宪法，以奥比昂为主的“民选”政府代替了政变时期的军事委员会，赤道几内亚终于恢复正常了……吗？"
const TXT_R1 := "我们将我们获悉的情报转交给了马西埃。8月2日，马西埃提前动手，以邀请聚餐为由把试图发动政变的军官聚集起来，正当聚餐达到高潮之际，马西埃以上厕所为由离开了，随后总统卫队闯了进来，将在场所有军官全部扫成了马蜂窝。在第二天，马西埃宣布破获了以奥比昂为首的反对马西埃的势力，并宣布由于其叛国而被枪决。在此之后，马西埃很感激我们的行动，开始扩大与我们的合作。"
const TXT_R2 := "在我们与爱丽舍宫的协商之后，两国就解决赤道几内亚人道主义问题一事达成共识：出兵解决马西埃。第二天，从利伯维尔国际机场出发的法军空降兵空降到赤几首都马拉博，宣布法军正式接管赤道几内亚并开始将赤道几内亚从混乱中拯救出来。在老家别墅的马西埃知道消息后立刻向法军投降，法军兵不血刃的拿下了整个赤道几内亚。前赤道几内亚驻加篷大使克莱门特·阿特巴成为了赤道几内亚的新总统。国防副部长则奥比昂宣布对阿巴特总统和法军保持忠诚，马西埃则被送到法国接受法国军事法庭审判，最终以种族灭绝罪，大规模谋杀等罪名判处马西埃死刑。在此次行动后，赤道几内亚宣布扩大与我们和法国的合作，法军继续驻扎在马拉博。"
const TXT_R3 := "8月3日，听命于奥比昂的军队占领了首都马拉博并宣告马西埃被推翻，但是与此同时仍然发电报给马西埃要求其投降。在马西埃拒绝之后奥比昂的政变军开始释放监狱里的囚犯并将其武装起来，奥比昂的政变军很快便在巴塔附近包围并俘虏了马西埃。奥比昂最终政变成功。在审判之前由于赤道几内亚根本没有宪法，不得不使用西班牙的军事法律对其进行审判。最终以种族灭绝罪，大规模谋杀等罪名判处马西埃等高层死刑。之后在全民公投中通过了新宪法，以奥比昂为主的“民选”政府代替了政变时期的军事委员会，赤道几内亚终于恢复正常了……吗？"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 3
	var war_support := d[W.I_WAR_SUPPORT] if d.size() > W.I_WAR_SUPPORT else 0
	var france := world.get_country_by_legacy_index(21)
	var cameroon := world.get_country_by_legacy_index(66)
	var gabon := world.get_country_by_legacy_index(116)
	var opt := event_def.options
	if line > 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line > 0 and war_support >= 700:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if france != null and france.has_tag("对华贸易") \
			and cameroon != null and cameroon.puppet_of == 21 \
			and gabon != null and gabon.puppet_of == 21:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var eq_guinea := _country(115)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if eq_guinea != null:
				eq_guinea.government = GameConstants.Government.AUTHORITARIAN
				eq_guinea.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(eq_guinea)
				eq_guinea.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add(W.I_ARMY, -50)
			_add(W.I_AGENTS, -50)
		1:
			context["result_text"] = TXT_R1
			if eq_guinea != null:
				_leave_alliances(eq_guinea)
				eq_guinea.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add(W.I_ARMY, -70)
			_add(W.I_AGENTS, -50)
		2:
			context["result_text"] = TXT_R2
			if eq_guinea != null:
				eq_guinea.government = GameConstants.Government.AUTHORITARIAN
				eq_guinea.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(eq_guinea)
				eq_guinea.set_tag("对华贸易", true)
				eq_guinea.puppet_of = 21
			_add(W.I_AGENTS, -50)
		3:
			context["result_text"] = TXT_R3
			if eq_guinea != null:
				eq_guinea.government = GameConstants.Government.AUTHORITARIAN
				eq_guinea.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN






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

func _foreign_minister_name() -> String:
	if ws != null and ws.politics_positions.size() > 2:
		var idx: int = ws.politics_positions[2]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
				and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return "黄华"

func _war_going(war_id: int) -> bool:
	var war := _get_war(war_id)
	return war != null and war.is_going

func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)

func _establish_prosoviet(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲苏", true)
	c.set_tag("亲中", false)
	c.set_tag("亲美", false)

func _start_war(war_id: int, war_name: String, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, tick_time: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	var war := _get_war(war_id)
	if war != null:
		war.name_war = war_name
		war.fortnight_max = tick_time

func _free_puppets(overlord: int) -> void:
	if ws == null:
		return
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			c.puppet_of = -1


