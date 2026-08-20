extends "res://数据脚本/event_script_base.gd"

## 原作 Event675.cs：霍比特之春（欧罗巴解放阵线成立，三选项）。
## 触发：ReqEventsDLC02.cs:1471 —— 核心条件同 674，且 sub22 国家计数 num>=3。
## 差异：isNAZIMAO→nazimao 标签；result2 中国 gov0/sub22、全非威权国清亲中/贸易/okb/econ。

const TXT_OPT2_DIS := "你没发烧吧？"
const TXT_R0_FMT := "中国外交部紧跟世界主要国家步伐，严正谴责了革命民族主义者的所作所为。对此，欧罗巴解放阵线对外发言人弗朗哥·弗雷达则回以一句：“背叛毛主席的民族革命事业、跟美苏两大帝国主义站在一起而背叛欧亚非拉四大洲被压迫人民的中国修正主义者{0}{1}去死吧，觉醒的欧罗巴人民万岁，无产阶级民族大革命万岁，战无不胜的民族毛主义万岁！”。\n不论如何，欧罗巴解放阵线的成立都为世界各地的革命民族主义者与多边主义派系打了强心针。国际局势预计将在相当一段时间内保持“沸腾”。"
const TXT_R1 := "天知道这些莫名其妙把法西斯主义和社会主义缝在一起做招牌的疯子是从哪里的精神病院中跑出来的……\n不论如何，欧罗巴解放阵线的成立都为世界各地的革命民族主义者与多边主义派系打了强心针。国际局势预计将在相当一段时间内保持“沸腾”。"
const TXT_R2_FMT := "由于美国的暗中作梗（如独占日本与长期扶持台湾伪政权），中国只能长期扮演雅尔塔体系内的“有名无实”大国，直到70年代初才取得突破。因此，我们为何要支持这样一个将中国事实上置于边缘的体系，并让我们充当超级大国的附庸或类似法兰西共和国式的怨妇呢？很快，我国外交部便向全世界刊载了{0}{1}亲笔所写雄文《太阳从西方升起：民族革命万岁》，文中称“中国人民的伟大导师、中华民族的民族英雄毛主席早就预料到会有这样一天的到来”“中国人民热烈欢迎欧洲人民的民族革命事业”“中-欧要携起手来，共同为欧罗巴民族伟大复兴与中华民族伟大复兴而斗争”，并将欧罗巴解放阵线视为“打倒美苏帝国主义制造的雅尔塔殖民体系，实现欧亚非拉四大洲解放”的第一步。此后便是中国外交官和欧罗巴解放阵线外交官进行全面接触并签署合作协定。在一次欧罗巴解放阵线对外发言人弗朗哥·弗雷达对我国的国事访问中，{0}{1}同志风趣的对他说道“我们赞成你们啊，你们的经验比我们好，中国没有资格批评你们”。\n不论如何，欧罗巴解放阵线的成立都为世界各地的革命民族主义者与多边主义派系打了强心针。国际局势预计将在相当一段时间内保持“沸腾”。"
const TXT_GDR_9 := "\n意识到美苏再也无力主宰欧洲大局，民族欧洲则蒸蒸日上。德国领导人奥托·恩斯特·雷默终于可以彻底露出真面目并带领德国选择新秩序，轴心国的“头领”就此在新世界内找到了自己的位置。"
const TXT_GDR_22 := "\n意识到美苏再也无力主宰欧洲大局，民族欧洲则蒸蒸日上。德国领导人亨宁·艾希伯格选择带领德国加入了泛欧革命大家庭的新秩序，轴心国的“头领”就此在新世界内找到了自己的位置。"
const TXT_FRG_10 := "\n意识到美苏再也无力主宰欧洲大局，民族欧洲则蒸蒸日上。德国领导人埃里希·米尔克终于可以彻底露出真面目并带领德国选择新秩序。轴心国的“头领”就此在新世界内找到了自己的位置。"
const TXT_ROMANIA := "\n欧罗巴解放阵线的成立意外在苏东国家中的罗马尼亚取得了热烈反响，齐奥塞斯库称赞其使“欧洲人民从此有了主心骨”，而欧洲革命民族主义者则将齐奥塞斯库的著作也纳入了其意识形态万神殿之中。有传言称罗马尼亚已于近期平反了铁卫团创始人科德里亚努，将他尊为“被帝国主义傀儡杀害的民族英雄”。"
const TXT_YUGOSLAVIA := "\n得知欧罗巴解放阵线成立的消息后，南斯拉夫领导人斯洛博丹·米洛舍维奇立即与其展开了合作，并宣布开展“南斯拉夫民族文化革命”以“保卫铁托同志缔造的南斯拉夫不受分离主义阴谋家和霍查修正主义者的侵扰”。"
const TXT_LIBYA := "\n多年来一直受到欧洲激进右翼拉拢、被其视为民族革命代表人物、意大利革命民族主义者口中的“真主的圣殿骑士”穆阿迈尔·卡扎菲上校也在与克劳迪奥·穆蒂会晤后对欧罗巴解放阵线转向积极态度，宣布将与其全面合作。"
const TXT_ZAIRE := "\n在同让·蒂里亚特派遣的特使吕克·米歇尔会谈后，意识到机会到来的“民族革命领袖”蒙博托果断选择再续刚果危机时代之缘，同老东家站在了一起，并邀请欧洲佣兵协助镇压游击队，在真实性运动中纳入了一些来自欧洲的革命民族主义色彩。欧罗巴解放阵线也将迈出向非洲扩张的第一步。"
const TXT_RWANDA := "\n卢旺达的胡图人政权也紧随亲密战友的脚步，成为欧罗巴解放阵线的观察员国。该国有意识地借用了欧洲极右翼的宣传叙事模板，将历史描绘为“勤劳善良的农耕民族胡图人”被“卑劣野蛮的君主主义殖民者图西人”奴役千年，最终通过胡图民族革命重获自由的故事，图西人也因此被与犹太复国主义画上了等号。"
const TXT_EQ_GUINEA := "\n看到欧洲在民族革命大旗下团结一致的风采，赤道几内亚总统马西埃选择在马克思-希特勒主义上更进一步地接纳革命民族主义话语，在马拉博城头竖起了德里维拉、莱德斯马与马西埃本人的画像，并以与西班牙的全面和解为条件换取到了欧罗巴解放阵线的投资与财政援助。"
const TXT_FRANCE_PUPPETS := "\n与此同时，欧罗巴解放阵线同那些仍与法兰西保持着“法非特殊关系”的非洲国家签订了《欧-非一体化条约》，将其国防、外交、经济与文化等大权收归欧洲，诸多亲法独裁者也纷纷转向，宣布效忠于革命民族主义事业，与其欧罗巴战友们一道“为打倒美苏新殖民主义而战”。"
const TXT_ITALY_PUPPETS := "\n意大利的总督们紧跟宗主国的步伐，为新的国际秩序三呼万岁，意大利在组织内的话语权大大加强了。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var china := ws.get_country_by_legacy_index(1)
	if china != null and (china.sub_government == GameConstants.SubGovernment.NEO_FASCIST \
			or (ws.is_authoritarian(china) and _res(W.I_WAR_SUPPORT) >= 700)) \
			and china.sub_government != GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_enable(event_def.options[2], event_def.options[2].text)
	else:
		_disable(event_def.options[2], TXT_OPT2_DIS)
	_enable(event_def.options[0], event_def.options[0].text)
	_enable(event_def.options[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var text := ""
	match opt:
		0: text = TXT_R0_FMT.replace("{0}{1}", _leader_name())
		1: text = TXT_R1
		2: text = TXT_R2_FMT.replace("{0}{1}", _leader_name())
	text += _chain_text(opt)
	_apply_chain(opt)
	if opt == 0:
		_add_relation(EmpireData.USA, 50)
		_add_relation(EmpireData.USSR, 50)
		_add_power(EmpireData.USA, -50)
		_add_power(EmpireData.USSR, -50)
		ws.influence_prc -= 50
	elif opt == 1:
		_add_power(EmpireData.USA, -50)
		_add_power(EmpireData.USSR, -50)
		ws.influence_prc -= 50
	else:
		var china := ws.get_country_by_legacy_index(1)
		if china != null:
			china.set_tag("nazimao", true)
			china.government = GameConstants.Government.AUTHORITARIAN
			china.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
		for c in ws.countries:
			if c == null:
				continue
			if not ws.is_authoritarian(c):
				c.set_tag("亲中", false)
				c.set_tag("对华贸易", false)
				c.set_tag("okb", false)
				c.set_tag("econ", false)
		_set_data(W.I_DIPLO, 1100)
		_add_relation(EmpireData.USA, -750)
		_add_relation(EmpireData.USSR, -750)
		_add_power(EmpireData.USA, -50)
		_add_power(EmpireData.USSR, -50)
		ws.influence_prc += 50
	context["result_text"] = text


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19851101:
		return false
	var france := world.get_country_by_legacy_index(21)
	var uk := world.get_country_by_legacy_index(92)
	var spain := world.get_country_by_legacy_index(85)
	var portugal := world.get_country_by_legacy_index(86)
	var italy := world.get_country_by_legacy_index(87)
	if france == null or uk == null or spain == null or portugal == null or italy == null:
		return false
	if (france.sub_government != GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST and france.sub_government != GameConstants.SubGovernment.NEO_FASCIST) \
			or (uk.sub_government != GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST and uk.sub_government != GameConstants.SubGovernment.NEO_FASCIST) \
			or (spain.sub_government != GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST and spain.sub_government != GameConstants.SubGovernment.NEO_FASCIST):
		return false
	if not world.is_authoritarian(portugal):
		return false
	if italy.sub_government != GameConstants.SubGovernment.RIGHT_AUTHORITARIAN and italy.sub_government != GameConstants.SubGovernment.NEO_FASCIST:
		return false
	return _sub22_count(world) >= 3


func _chain_text(opt: int) -> String:
	var s := ""
	var gdr := ws.get_country_by_legacy_index(17)
	if gdr != null and gdr.parts.size() > 0 and gdr.parts[0]:
		if gdr.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
			s += TXT_GDR_9
		elif gdr.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
			s += TXT_GDR_22
	var frg := ws.get_country_by_legacy_index(16)
	if frg != null and frg.parts.size() > 0 and frg.parts[0] and frg.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		s += TXT_FRG_10
	var romania := ws.get_country_by_legacy_index(5)
	if romania != null and romania.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		s += TXT_ROMANIA
	var yugoslavia := ws.get_country_by_legacy_index(15)
	if yugoslavia != null and yugoslavia.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		s += TXT_YUGOSLAVIA
	var libya := ws.get_country_by_legacy_index(13)
	var libya_ok := libya != null and libya.puppet_of < 0 \
		and (libya.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or libya.sub_government == GameConstants.SubGovernment.PRAGMATIST)
	if libya_ok and (opt != 0 or (libya != null and not (libya.parts.size() > 0 and libya.parts[0]))):
		s += TXT_LIBYA
	var zaire := ws.get_country_by_legacy_index(117)
	var usa_power := ws.empires[EmpireData.USA].power if ws.empires.size() > EmpireData.USA \
		and ws.empires[EmpireData.USA] != null else 0
	if zaire != null and zaire.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN and usa_power <= 0:
		s += TXT_ZAIRE
	var rwanda := ws.get_country_by_legacy_index(120)
	if rwanda != null and (rwanda.sub_government == GameConstants.SubGovernment.NEO_FASCIST or rwanda.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN):
		s += TXT_RWANDA
	var eq_guinea := ws.get_country_by_legacy_index(115)
	if eq_guinea != null and eq_guinea.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		s += TXT_EQ_GUINEA
	var france := ws.get_country_by_legacy_index(21)
	if france != null and france.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST and _has_puppet_of(21):
		s += TXT_FRANCE_PUPPETS
	var spain := ws.get_country_by_legacy_index(85)
	if spain != null and spain.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST and _has_puppet_of(85):
		s += TXT_ITALY_PUPPETS
	return s


func _apply_chain(opt: int) -> void:
	var gdr := ws.get_country_by_legacy_index(17)
	if gdr != null and gdr.parts.size() > 0 and gdr.parts[0] and gdr.sub_government in [9, 22]:
		_join_nazimao(17)
	var frg := ws.get_country_by_legacy_index(16)
	if frg != null and frg.parts.size() > 0 and frg.parts[0] and frg.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		_join_nazimao(16)
	var romania := ws.get_country_by_legacy_index(5)
	if romania != null and romania.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		_join_nazimao(5)
	var yugoslavia := ws.get_country_by_legacy_index(15)
	if yugoslavia != null and yugoslavia.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		_join_nazimao(15)
	var libya := ws.get_country_by_legacy_index(13)
	var libya_ok := libya != null and libya.puppet_of < 0 \
		and (libya.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or libya.sub_government == GameConstants.SubGovernment.PRAGMATIST)
	if libya_ok and (opt != 0 or (libya != null and not (libya.parts.size() > 0 and libya.parts[0]))):
		_join_nazimao(13)
	var zaire := ws.get_country_by_legacy_index(117)
	var usa_power := ws.empires[EmpireData.USA].power if ws.empires.size() > EmpireData.USA \
		and ws.empires[EmpireData.USA] != null else 0
	if zaire != null and zaire.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN and usa_power <= 0:
		_join_nazimao(117)
	var rwanda := ws.get_country_by_legacy_index(120)
	if rwanda != null and (rwanda.sub_government == GameConstants.SubGovernment.NEO_FASCIST or rwanda.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN):
		_join_nazimao(120)
	var eq_guinea := ws.get_country_by_legacy_index(115)
	if eq_guinea != null and eq_guinea.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		_join_nazimao(115)
	if _has_puppet_of(21):
		for c in ws.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.FRANCE:
				c.set_tag("nazimao", true)
	if _has_puppet_of(85):
		for c in ws.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.SPAIN:
				c.set_tag("nazimao", true)
	for idx in [92, 85, 86, 87]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null:
			_leave_alliances(c)
			c.set_tag("nazimao", true)
			c.set_tag("对华贸易", true)
	var france := ws.get_country_by_legacy_index(21)
	if france != null:
		_leave_alliances(france)
		if opt == 2:
			france.set_tag("亲中", true)
		france.set_tag("nazimao", true)
		france.set_tag("对华贸易", true)


func _join_nazimao(idx: int) -> void:
	var c := ws.get_country_by_legacy_index(idx)
	if c != null:
		_leave_alliances(c)
		c.set_tag("nazimao", true)


func _has_puppet_of(overlord: int) -> bool:
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			return true
	return false


func _sub22_count(world: WorldState) -> int:
	var count := 0
	for idx in [21, 85, 86, 87, 92]:
		var c := world.get_country_by_legacy_index(idx)
		if c != null and c.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
			count += 1
	return count


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
