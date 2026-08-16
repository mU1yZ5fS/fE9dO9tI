extends "res://数据脚本/event_script_base.gd"

## 原作 Event703.cs：选举：自愿消费降级（魁北克新国家走向，单选项）。
## 触发：ReqEventsDLC02.cs:1571-1573 —— c167.parts[0] && DATE_AFTER 1984.5.20 → trigger_script。
## 差异：LeaveAlliances→_leave_alliances、Vyshi→亲美、puppetOf→puppet_of、isNATO/isSocEU→标签。

const TXT_TITLE := "选举：自愿消费降级"
const TXT_DESC := "魁北克的事情注定不会就此收场：自该国脱离加拿大的经济空间后，魁北克便陷入了漫长而痛苦的转型期，本就不发达的产业体系为持续性的衰退所困。而这恰为外国资本介入提供了便利。只要点小火花，便能驱动那些渴望变革的魁北克人将其小世界颠倒成操盘者们所乐见的样子。现在便是静待结果的时候——分析人士估计，作为魁北克最大金主的美、法两方在该问题上具有说一不二的发言权。"
const TXT_OPT0 := "我们正静待结果"
const TXT_R_USA := "魁北克人党建制派得以勉力支撑，并用尽浑身解数保持了一个相对多数政府——多亏了美国在经济、政治上的鼎力支持与华盛顿对该国民主程序的“善意忽视”，这个国家才不至于在引入配给制度与选举资格法的同时被判定为国际社会内的弃民。越来越多的人已经发现，魁北克大有成为“说法语的小美国”，“西伯利亚版海地”之势。显然全球自由主义的恩惠并未光顾这片土地……即便如此，魁北克也只能抓住仅有的救命稻草，进一步嵌入美国主导的区域合作体系内。"
const TXT_R_USA_APPEND := "即便有诸多不如意，至少，对于那些不得不抛弃故土的法国异议者和其他法语区的难民来说，这里足以作为新家。"
const TXT_R_FRANCE := "结果，魁北克民族联盟在全新的政治环境中如鱼得水，并通过统合境内所有民族主义右翼运动组建大联盟的方式涅槃重生，最终取得大胜。新政府从法兰西老牌民族主义者戴高乐总统的“魁北克万岁！”口号处获得启发，决心进一步靠拢法国与主权欧洲。并以社会保守主义价值观为根基，全心全意打造北美版本“小法国”。"
const TXT_R_FRANCE_MOD := "对此，一些批评家指控魁北克新当局持“反民主价值观”。不过，这在那些只关心眼前一亩三分地的魁北克人眼中也不过是无聊的自说自话。与此同时，政府同时开始准备着手同北美防空司令部等体系做切割，这自然遭到了美国的抗议。"
const TXT_R_FRANCE_SUB := "结果，魁北克民族联盟在全新的政治环境中如鱼得水，并通过统合境内所有民族主义右翼运动组建大联盟的方式涅槃重生，最终取得大胜。新政府从法兰西老牌民族主义者戴高乐总统的“魁北克万岁！”口号处获得启发，决心进一步靠拢法国与主权欧洲。并以社会保守主义价值观为根基，全心全意打造北美版本“小法国”。"
const TXT_R_SOCDEM := "和平长入社会主义的风还是吹到了大洋彼岸，并助力魁北克多重左翼力量团结形成的“进步力量联盟”得以上台掌权。新政府在上台伊始便抛出中立，环保主义，和平主义与社会主义四项方针，最终打造“北美瑞典”的议程。因此，与美国谈判解除美魁合作机制的问题很快便提上了日程。"
const TXT_R_SOCDEM_APPEND := "与此同时，新政府还从欧洲共产主义实践内获得了启发，决心加入目前正蒸蒸日上的社会主义联盟，以此重启魁北克经济。"
const TXT_R_COUP_FMT := "显然，在这个完全无法正常运转的国家内举行场正常选举是奢望。由于暖气涨价，蒙特利尔地区已被示威与罢工潮攻陷；莫霍克人和政府间的土地争端也愈演愈烈，双方在奥卡镇的对峙更是导致魁北克当局基本停摆。借此混乱局势，皮埃尔·“PK”·瓦列利斯等人重组的魁北克解放阵线和{0}得以发起联合政变夺取政权。此后，他们更是就此清算了魁人党的保守社会民主主义与基于天主教法语认同的魁北克民族主义两条歪路，转而拥抱基于法农主义，“白色黑鬼与第一民族”的社会主义共和国认同。考虑到新政府没过多久便得到了法国与社会主义阵营在安全保障层面的背书，美国与加拿大只能惊恐地看着共产主义者和左翼民族主义者的联盟在“穷山恶水”赢得胜利。"
const TXT_R_EXILE := "考虑到法国政坛巨变导致的连锁反应，如今，吸纳了旧法国一切异见者的魁北克俨然成为了不成文的“法兰西第六共和国”，并在相当程度上受流亡者游说群体的影响。出于对国家安全的考量和对极端主义的恐惧，魁北克人与他们的法国同胞最终共同押注主打“纯粹外交议题”的“魁北克党派联盟”——而该党也是不负众望，卷起了右翼民粹主义旋风。通过背靠法国流亡财团的金库支持，魁北克党派联盟决心将魁北克打造为专门容纳离法迷途之子的北美版德兰士瓦共和国，旋即就在高举绝对中立与经济实用主义两面旗帜的同时与法国断交。魁北克毫不顾忌在苏联，中国，美国，甚至老东家加拿大处找到同变质的父亲对抗的力量……即便在自由主义观察者的眼中，这只是两个反民主政权间的狗斗而已，但是那又如何呢……？"
const TXT_R_CANADA := "最终，魁北克选举不过是对加拿大两党交接模式的再版：倾向同加拿大重建经济联系以缓解独立冲击的魁北克自由党得以背靠英裔人口与“恢复经济”的诉求赢得选举。考虑到魁北克自由党不过是加拿大自由党的分支，我们只能说历史确实是个圈。一些媒体借此判断，魁北克的极端时代已经过去，民主转型就此完成。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	var quebec := ws.get_country_by_legacy_index(167)
	var france := ws.get_country_by_legacy_index(21)
	var spain := ws.get_country_by_legacy_index(85)
	var china := ws.get_country_by_legacy_index(1)
	if usa != null and usa.power > 400:
		context["result_text"] = TXT_R_USA
		if quebec != null:
			_leave_alliances(quebec)
			quebec.set_tag("亲美", true)
			if ws.get_country_by_legacy_index(51) != null \
					and ws.get_country_by_legacy_index(51).has_tag("nato"):
				quebec.set_tag("nato", true)
		if france != null and france.government < 2:
			context["result_text"] = TXT_R_USA + TXT_R_USA_APPEND
		return
	var mod45 := ws.modifiers.size() > 45 and ws.modifiers[45] != null and ws.modifiers[45].is_active
	if mod45 or (france != null and (france.sub_government == 20 or france.sub_government == 9)):
		var text := TXT_R_FRANCE
		if quebec != null:
			_leave_alliances(quebec)
		if mod45:
			text += TXT_R_FRANCE_MOD
			if quebec != null:
				quebec.government = 3
				quebec.sub_government = 5
				quebec.puppet_of = 21
			context["result_text"] = text
			return
		text += TXT_R_FRANCE_SUB
		if quebec != null:
			quebec.government = 0
			quebec.sub_government = 20
			quebec.puppet_of = 21
		context["result_text"] = text
		return
	if france != null and france.government == 2:
		var text2 := TXT_R_SOCDEM
		if quebec != null:
			_leave_alliances(quebec)
			quebec.government = 2
			quebec.sub_government = 3
		if spain != null and spain.has_tag("soc_eu"):
			text2 += TXT_R_SOCDEM_APPEND
			if quebec != null:
				quebec.set_tag("soc_eu", true)
		context["result_text"] = text2
		return
	if ws.is_socialism(france, true):
		var faction := "和平与民主联盟"
		if france.sub_government == 1:
			faction = "魁北克共产党"
		elif france.sub_government == 17:
			faction = "魁北克马列主义党"
		context["result_text"] = TXT_R_COUP_FMT.replace("{0}", faction)
		if quebec != null:
			_leave_alliances(quebec)
			quebec.government = 1
			quebec.sub_government = 1
			if france.sub_government == 1:
				quebec.set_tag("亲苏", true)
			elif france.sub_government == 17:
				quebec.set_tag("亲中", true)
			elif france.sub_government == 18 and china != null and china.sub_government == 18:
				quebec.set_tag("亲中", true)
		return
	if france != null and (france.sub_government == 19 or france.sub_government == 22):
		context["result_text"] = TXT_R_EXILE
		if quebec != null:
			_leave_alliances(quebec)
			quebec.government = 2
			quebec.sub_government = 8
		return
	context["result_text"] = TXT_R_CANADA
	if quebec != null:
		_leave_alliances(quebec)
		quebec.government = 3
		quebec.sub_government = 6
		quebec.set_tag("亲美", true)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19840520:
		return false
	var quebec := world.get_country_by_legacy_index(167)
	return quebec != null and quebec.parts.size() > 0 and quebec.parts[0]
