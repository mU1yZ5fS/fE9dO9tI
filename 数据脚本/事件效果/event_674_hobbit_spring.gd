extends "res://数据脚本/event_script_base.gd"

## 原作 Event674.cs：霍比特之春（欧洲社会国家组织成立，三选项）。
## 触发：ReqEventsDLC02.cs:1476 —— c21/c92/c85.sub∈{22,9} && IsAuthoritarianism(86)
##   && c87.sub∈{7,9} && 1985.11 起 && num(sub22计数)<3（num>=3 走 675）→ trigger_script evaluate。
## 差异：isFXSEU→fxseu 标签；LeaveAlliances→_leave_alliances；result2 中国转 gov0/sub9。

const TXT_TITLE := "霍比特之春"
const TXT_DESC := "由于极右翼政治势力在欧洲主要国家内的崛起，我们所熟知的雅尔塔-波茨南体系已摇摇欲坠，世界似乎退回到了20世纪30年代的模样：今天，英国，法国，意大利，西班牙与葡萄牙五国代表齐聚马德里，商讨欧洲统一事宜。此后，上述国家便以法国在五十年代提出的《欧洲防务共同体》计划为蓝本建立了堪称二代《钢铁条约》的所谓“欧洲社会国家组织”：该组织将为各国提供“充分保障国家主权的平台”，并确保其成员可在经济、政治与军事上共进退；且所有加入“欧洲社会国家组织”的政权都需遵守1962年3月1日奥斯瓦尔德·莫斯利、让·蒂里亚特等人签署的《威尼斯宣言》：即认同罗马传统，具有共同历史纽带，要求选举产生欧洲议会、彻底清算战后世界秩序（即终结美苏政治集团并瓦解联合国）与清除美国与苏联在欧洲的军事存在。最后，欧洲极右翼政客们以号召欧洲各国“回归文明怀抱，痛打洋基尼格罗人和苏维埃野蛮人”的演讲结束了会议。雅尔塔体系迎来了一个对手，我们又该如何回应？"
const TXT_OPT0 := "强烈谴责这一声明"
const TXT_OPT1 := "今昔是何年？"
const TXT_OPT2 := "热烈欢迎政治多极化时代的到来！并向欧洲极右翼表达合作意愿！"
const TXT_OPT2_DIS := "你没发烧吧？"
const TXT_R0 := "中国外交部紧跟世界主要国家步伐，严正谴责了新法西斯主义者的所作所为。对此，欧洲社会国家组织对外发言人皮埃尔·西多斯只是以一句：“亚洲人依然没有看清历史并选对（右）边，如有必要，重提开化使命旧事也并非不可。”草草回应。\n不论如何，欧洲社会国家组织的成立都为世界各地的新法西斯主义者与多边主义派系打了强心针。国际局势预计将在相当一段时间内保持“沸腾”。"
const TXT_R1 := "看起来，法西斯主义确实还没有完全成为“历史名词”……\n不论如何，欧洲社会国家组织的成立都为世界各地的新法西斯主义者与多边主义派系打了强心针。国际局势预计将在相当一段时间内保持“沸腾”。"
const TXT_R2_FMT := "由于美国的暗中作梗（如独占日本与长期扶持台湾伪政权），中国只能长期扮演雅尔塔体系内的“有名无实”大国，直到70年代初才取得突破。因此，我们为何要支持这样一个将中国事实上置于边缘的体系，并让我们充当超级大国的附庸或类似法兰西共和国式的怨妇呢？很快，我国外交部便向全世界刊载了{0}{1}亲笔所写雄文《西方重亮：论世界新秩序》，并将欧洲社会国家组织视为“建构多极世界，彻底革新不合理国际关系”的第一步。此后便是中国外交官和欧洲社会国家组织外交官进行全面接触并签署合作协定。我们当然清楚鸡蛋放在多个篮子内的道理，因此我们只达成了经济协定与口头上的相互承认，以此最大限度地保证了我国仍忠于“联合国为主要舞台的旧秩序”并绕开了“欧洲文明优等论”。对此，对方则以“文明互鉴，相互尊重，互利共赢”的漂亮话予我们以高度评价。因此，我们多少赚到了。此后，我们更是同欧洲社会国家组织签署了一份备忘录与类似百分比协定的文件，确定了现代版本的教皇子午线：当然，基础包括乌拉尔山等在内的地理界线……\n不论如何，欧洲社会国家组织的成立都为世界各地的新法西斯主义者与多边主义派系打了强心针。国际局势预计将在相当一段时间内保持“沸腾”。"
const TXT_IRAN_13 := "\n狐狸般狡黠的巴列维王朝决定从“国际孤儿抱团取暖”和“联合围堵苏联帝国主义”的角度押注新秩序，而欧洲社会国家组织自对此“甘之如饴”。现代版“法土不圣联盟”就此诞生。"
const TXT_IRAN_9 := "\n新的伊朗帝国自诩为雅利安-白人秩序在亚洲的前锋，与欧洲的法西斯主义盟友的高强度互动，自然，渴望获得波斯湾石油的欧洲社会国家组织欣然将其吸纳为成员。"
const TXT_GDR_9 := "\n意识到美苏再也无力主宰欧洲大局，主权欧洲则蒸蒸日上。德国领导人奥托·恩斯特·雷默终于可以彻底露出真面目并带领德国选择新秩序，轴心国的“头领”就此在新世界内找到了自己的位置。"
const TXT_GDR_22 := "\n意识到美苏再也无力主宰欧洲大局，民族欧洲则蒸蒸日上。德国领导人亨宁·艾希伯格选择带领德国加入了泛欧革命大家庭的新秩序，轴心国的“头领”就此在新世界内找到了自己的位置。"
const TXT_FRG_10 := "\n意识到美苏再也无力主宰欧洲大局，主权欧洲则蒸蒸日上。德国领导人埃里希·米尔克终于可以彻底露出真面目并带领德国选择新秩序，并在同时切断了同我国的联系。轴心国的“头领”就此在新世界内找到了自己的位置。"
const TXT_GREECE := "\n被复仇主义情绪笼罩的希腊新上校政权自然搭上了所谓“基督教文明”快车，并迫切要求欧洲社会国家组织拿出铁腕对付“阿尔巴尼亚无神论匪徒”与“突厥穆斯林”，渴望用鲜血启动新一轮十字军东征。"
const TXT_AUSTRALIA := "\n得知欧洲的新消息后，澳大利亚的彼德森政府立即回想起了“与不列颠母国的历史联系”，并借助英联邦框架转向了欧洲社会国家组织。"
const TXT_SOUTH_AFRICA := "\n作为白人文明的“海外孤忠”。南非白人政权则相当欢迎这一巨变，很快便同欧洲社会国家组织的主要成员达成共识。该组织也将迈出向非洲扩张的第一步。"
const TXT_MEXICO := "\n墨西哥天主教徒以该国同西班牙保守主义与法西斯主义的联系而闻名遐迩，欧洲社会国家组织的成立则给了其借题发挥，甚至让某些理想主义者重弹“欧化墨西哥”老调的空间。看来巴斯孔塞洛斯之梦将在不久后成真……"
const TXT_LEBANON := "\n随着欧洲社会回到正路，他们的子嗣、十字军的残余也将目光投到这个生机勃勃的新欧洲。以马龙派为主的黎巴嫩长枪党主动联系上欧洲社会国家组织，并争取到了观察员的身份。然而，社会国家组织无法衡量他们对“事业”的忠诚度，毕竟，这些狡诈成性的坞堡领主压根不忠诚于任何一种意识形态——谁知道他们背后有没有跟某些大鼻子犹太猪或者穿着长袍、娶小女孩的圣战恐怖分子勾勾搭搭！"
const TXT_FRANCE_PUPPETS := "\n与此同时，欧洲社会国家组织同那些仍与法兰西保持着“法非特殊关系”的非洲国家签订了《欧-非一体化条约》，将其国防、外交、经济与文化等大权收归欧洲，进而“纠正”其“历史错误”，以新的法兰西联邦形式重建了殖民帝国，并开始推行同化政策和白人-同化精英与混血儿-普通黑人的三阶等级制，重弹“文明开化”的老调……"
const TXT_ITALY_PUPPETS := "\n意大利的总督们紧跟宗主国的步伐，为新的国际秩序三呼万岁，意大利在组织内的话语权大大加强了。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var china := ws.get_country_by_legacy_index(1)
	if china != null and (china.sub_government == 9 \
			or (ws.is_authoritarian(china) and _res(W.I_WAR_SUPPORT) >= 700)) \
			and china.sub_government != 19:
		_enable(event_def.options[2], TXT_OPT2)
	else:
		_disable(event_def.options[2], TXT_OPT2_DIS)
	_enable(event_def.options[0], TXT_OPT0)
	_enable(event_def.options[1], TXT_OPT1)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var trade := opt == 2
	var text := ""
	match opt:
		0: text = TXT_R0
		1: text = TXT_R1
		2: text = TXT_R2_FMT.replace("{0}{1}", _leader_name())
	text += _chain_text(trade)
	_apply_chain(trade)
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
			china.government = 0
			china.sub_government = 9
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
	if (france.sub_government != 22 and france.sub_government != 9) \
			or (uk.sub_government != 22 and uk.sub_government != 9) \
			or (spain.sub_government != 22 and spain.sub_government != 9):
		return false
	if not world.is_authoritarian(portugal):
		return false
	if italy.sub_government != 7 and italy.sub_government != 9:
		return false
	return _sub22_count(world) < 3


func _chain_text(_trade: bool) -> String:
	var s := ""
	var iran := ws.get_country_by_legacy_index(8)
	if iran != null:
		if iran.sub_government == 13:
			s += TXT_IRAN_13
		elif iran.sub_government == 9 and iran.puppet_of < 0:
			s += TXT_IRAN_9
	var gdr := ws.get_country_by_legacy_index(17)
	if gdr != null and gdr.parts.size() > 0 and gdr.parts[0]:
		if gdr.sub_government == 9:
			s += TXT_GDR_9
		elif gdr.sub_government == 22:
			s += TXT_GDR_22
	var frg := ws.get_country_by_legacy_index(16)
	if frg != null and frg.parts.size() > 0 and frg.parts[0] and frg.sub_government == 10:
		s += TXT_FRG_10
	var greece := ws.get_country_by_legacy_index(45)
	if greece != null and greece.sub_government == 7:
		s += TXT_GREECE
	var australia := ws.get_country_by_legacy_index(135)
	if ws.is_authoritarian(australia):
		s += TXT_AUSTRALIA
	var south_africa := ws.get_country_by_legacy_index(131)
	if ws.is_authoritarian(south_africa):
		s += TXT_SOUTH_AFRICA
	var mexico := ws.get_country_by_legacy_index(140)
	if mexico != null and mexico.sub_government == 9:
		s += TXT_MEXICO
	var lebanon := ws.get_country_by_legacy_index(93)
	if ws.is_authoritarian(lebanon):
		s += TXT_LEBANON
	var france := ws.get_country_by_legacy_index(21)
	if france != null and france.sub_government == 9 and _has_puppet_of(21):
		s += TXT_FRANCE_PUPPETS
	var spain := ws.get_country_by_legacy_index(85)
	if spain != null and spain.sub_government == 9 and _has_puppet_of(85):
		s += TXT_ITALY_PUPPETS
	return s


func _apply_chain(trade: bool) -> void:
	_join_fxseu(8, false)
	var gdr := ws.get_country_by_legacy_index(17)
	if gdr != null and gdr.parts.size() > 0 and gdr.parts[0] and gdr.sub_government in [9, 22]:
		_join_fxseu(17, trade)
	var frg := ws.get_country_by_legacy_index(16)
	if frg != null and frg.parts.size() > 0 and frg.parts[0] and frg.sub_government == 10:
		_join_fxseu(16, trade)
	var greece := ws.get_country_by_legacy_index(45)
	if greece != null and greece.sub_government == 7:
		_join_fxseu(45, trade)
	var australia := ws.get_country_by_legacy_index(135)
	if ws.is_authoritarian(australia):
		_join_fxseu(135, trade)
	var south_africa := ws.get_country_by_legacy_index(131)
	if ws.is_authoritarian(south_africa):
		_join_fxseu(131, trade)
	var mexico := ws.get_country_by_legacy_index(140)
	if mexico != null and mexico.sub_government == 9:
		_join_fxseu(140, trade)
	var lebanon := ws.get_country_by_legacy_index(93)
	if ws.is_authoritarian(lebanon):
		_join_fxseu(93, trade)
	if _has_puppet_of(21):
		for c in ws.countries:
			if c != null and c.puppet_of == 21:
				c.set_tag("fxseu", true)
	if _has_puppet_of(85):
		for c in ws.countries:
			if c != null and c.puppet_of == 85:
				c.set_tag("fxseu", true)
	for idx in [92, 85, 86, 87, 21]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null:
			_leave_alliances(c)
			c.set_tag("fxseu", true)
			if trade:
				c.set_tag("对华贸易", true)


func _join_fxseu(idx: int, trade: bool) -> void:
	var c := ws.get_country_by_legacy_index(idx)
	if c == null:
		return
	if idx == 8:
		# 伊朗只在 sub==13 或 (sub==9 && puppet<0) 时加入
		if c.sub_government == 13 or (c.sub_government == 9 and c.puppet_of < 0):
			_leave_alliances(c)
			c.set_tag("fxseu", true)
			if trade:
				c.set_tag("对华贸易", true)
		return
	_leave_alliances(c)
	c.set_tag("fxseu", true)
	if trade:
		c.set_tag("对华贸易", true)


func _has_puppet_of(overlord: int) -> bool:
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			return true
	return false


func _sub22_count(world: WorldState) -> int:
	var count := 0
	for idx in [21, 85, 86, 87, 92]:
		var c := world.get_country_by_legacy_index(idx)
		if c != null and c.sub_government == 22:
			count += 1
	return count


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
