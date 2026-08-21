extends "res://数据脚本/event_script_base.gd"

## 原作 Event460.cs：福尔摩沙之冬（美丽岛事件三选项）。
## 触发：ReqEventForDLC02.cs:392-394 —— DATE_AFTER 1979.12.10；fire_only_once 承担 !event_done[460]。
## 差异：allcountries[38].stab→CountryData.stab；原 button_text[3]="" 为死代码跳过。

const TXT_DESC := "在国民党治理下没有组个人党的自由，所谓的“党外”，指的就是一群非属国民党、进行反对国民党独裁统治、争取民主、自由运动的政治组织或个人。在早期，党外人士主要是通过创办杂志来宣传自己的政治主张。\n1979年5月中，黄信介申请创办一个新的杂志，杂志名称之由来，为周清玉提议取李双泽编曲，杨祖珺演唱的歌曲－《美丽岛》为名。6月2日，《美丽岛》杂志社以“形成没有党名的政党，主张实行国会全面改选与地方首长改选”为目的在台北市正式挂牌成立。在7月9日的会议上，该社正式确定许信良为社长，吕秀莲、黄天福担任副社长，张俊宏为总编辑，施明德为总经理。当时《美丽岛》旗下网罗了各派的党外人士，包括了当时倾向统一的社会主义团体“夏潮”、以及以康宁祥为代表的稳健派，但是主要还是以施明德等激进派为骨干。\n11月20日，“美丽岛政团”在台中市太平国小举办“美丽岛之夜”，会中开始筹划在世界人权日当天在高雄举行游行。而伪政府也正准备磨刀霍霍，给这群人一个下马威。12月9日，国民党政府紧急通过电视宣布将于高雄举行冬令宵禁演习，以避免“妨碍交通与社会秩序”为由，将在次日禁止任何示威游行活动，实为针对《美丽岛》可能举办的游行活动进行监控，高雄市政府警察局随即调集大批优势警力包围《美丽岛》杂志社高雄市服务处，阻挡其宣传车宣传游行。当日，两名《美丽岛》的义工姚国建和邱胜雄突破包围，驾驶两辆由“发财车”改装的宣传车行驶至高雄市街头进行宣传，在发传单告示次日活动时于鼓山分局附近被警察拦下，抢走扩音器、录音带等宣传工具，并逮捕两人施以殴打及刑求。《美丽岛》杂志社工作人员在得知消息后立即前往警察局要求放人，聚集群众于警局外，警察紧急封锁陆桥，避免更多民众进入，一直到次日凌晨，两人才被释放。这次的“鼓山事件”引起公愤，《美丽岛》杂志社高雄市服务处紧急动员各地党外人士前来声援。\n主席同志，我们该干什么？名义上我们应该做点什么，毕竟台湾是我们的一部分，对吧？"
const TXT_OPT0_DIS_A := "支持左派？我们连自己党里的左派都不放心！"
const TXT_OPT0_DIS_B := "我们有心无力！"
const TXT_OPT1_DIS := "支持他们干什么？"
const TXT_R0 := "我们秘密联络了“夏潮派”，他们对于得到来着海峡对岸的支持和援助感到又惊又喜。通过“渔船”，一批又一批的手枪和防毒面具被“意外”冲上海峡对岸。该派的领袖吴荣元表示愿意重建中国共产党台湾支部。\n12月10日当天中午，蒋伪政府全面动员，进行交通管制并封锁举办集会的预定地扶轮公园；晚上6点，游行队伍出发，现场开始分配布条、火把、棍棒、自制燃烧瓶，常持琇与黄信介随即抵达现场，而常持琇却被不明人士攻击，连帽子都打掉，常持琇拒绝出借场地，并下令出动镇暴部队。由于原定集会地点“扶轮公园”已经被封锁，游行队伍只能临时改变集会地点，施明德、姚嘉文等人率领数百名民众，从《美丽岛》杂志社高雄市服务处出发，前往今新兴分局前中山一路与中正四路路口的大圆环，同时民众多人手持“火把”，象征普世人权的光环。在抵达大圆环后，民众熄灭火把、席地而坐，由黄信介于宣传车上首先发表谈话，但很快整个大圆环就被镇暴部队、宪兵、警察包围；晚上8点半，镇暴车上冒出几缕白烟，镇暴警察开始在游行现场施放催泪瓦斯，现场民众开始骚动，并由大圆环移向中正四路，在南台路口的封锁线前方与宪兵、警察爆发严重冲突，双方均受伤惨重。当民众冲破第一道封锁线时，施明德要求群众撤回服务处，但现场已经完全失控，群众继续冲撞高雄市第一分局，当时人数粗估约10万人。后来民众退回服务处，张俊宏见现场气氛稍息，站上宣传车要求迅速解散，但众人仍留在现场倾听吕秀莲演讲。黄越钦立即与常持琇交涉，要求先行撤离镇暴部队以劝退民众解散，但常持琇坚持先行驱离民众，谈判陷入僵局；晚间10时左右，装甲车及警队聚集于中山一路，释放催泪瓦斯，镇暴部队同时手持盾牌配合镇暴车逼近游行队伍。在这时，一声枪响打破了宁静，一名警察的手枪走火打伤了一位无辜市民。顿时抗议就朝着不可控的方面发展，得到武装支援的“夏潮”派以美丽岛报社为街垒，和军警发生了交火。双方均有受伤事后官方宣称军警约有183人受伤，15人遇害，而民众无人受伤，受到质疑后又改称有50多人死亡。事件之后，国民党政府指挥新闻媒体一面倒地指责参与活动的民众。不断播放宪警住院，以及发动社会各界关怀及声援宪警的情况。国民党政府一味将宪警塑造成受害者，并铺天盖地批评党外人士为“共匪”，间谍，等称号。这使得伪政府当局或多或少陷入了被动。"
const TXT_R1 := "中华人民共和国台湾事务处对美丽岛组织发去了慰问电，称他们是：“对抗法西斯主义的英雄，一切有良知的人的榜样。”\n12月10日当天中午，蒋伪政府全面动员，进行交通管制并封锁举办集会的预定地扶轮公园；晚上6点，游行队伍出发，现场开始分配布条、火把、棍棒、自制燃烧瓶，常持琇与黄信介随即抵达现场，而常持琇却被不明人士攻击，连帽子都打掉，常持琇拒绝出借场地，并下令出动镇暴部队。由于原定集会地点“扶轮公园”已经被封锁，游行队伍只能临时改变集会地点，施明德、姚嘉文等人率领数百名民众，从《美丽岛》杂志社高雄市服务处出发，前往今新兴分局前中山一路与中正四路路口的大圆环，同时民众多人手持“火把”，象征普世人权的光环。在抵达大圆环后，民众熄灭火把、席地而坐，由黄信介于宣传车上首先发表谈话，但很快整个大圆环就被镇暴部队、宪兵、警察包围。演讲完毕，黄信介同总指挥施明德与姚嘉文出面与警方谈判，要求警方允许他们在原定地点集会到晚上11点，并要求撤回镇暴部队、出让一个进出口，条件为让警察可以到现场维护秩序；但经副司令张墨林请示的结果，谈判要求全部被驳回；晚上8点半，镇暴车上冒出几缕白烟，镇暴警察开始在游行现场施放催泪瓦斯，现场民众开始骚动，并由大圆环移向中正四路，在南台路口的封锁线前方与宪兵、警察爆发严重冲突，双方均受伤惨重。当民众冲破第一道封锁线时，施明德要求群众撤回服务处，但现场已经完全失控，群众继续冲撞高雄市第一分局，当时人数粗估约10万人。后来民众退回服务处，张俊宏见现场气氛稍息，站上宣传车要求迅速解散，但众人仍留在现场倾听吕秀莲演讲。黄越钦立即与常持琇交涉，要求先行撤离镇暴部队以劝退民众解散，但常持琇坚持先行驱离民众，谈判陷入僵局；晚间10时左右，装甲车及警队聚集于中山一路，释放催泪瓦斯，镇暴部队同时手持盾牌配合镇暴车逼近游行队伍，在场民众还以石块及棍棒攻击，双方更发生更大规模的冲突，同时有“不明人士”攻击民宅，直至半夜民众才逐渐解散。事后官方宣称军警约有183人受伤，而民众无人受伤，受到质疑后又改称有50多人受伤。事件之后，国民党政府指挥新闻媒体一面倒地指责参与活动的民众，电视台不断播放宪警住院，以及发动社会各界关怀及声援宪警的情况。国民党政府一味将宪警塑造成受害者，并铺天盖地批评党外人士为“共匪”，间谍，等称号。这使得伪政府当局或多或少陷入了被动。"
const TXT_R2 := "12月10日当天中午，蒋伪政府全面动员，进行交通管制并封锁举办集会的预定地扶轮公园；晚上6点，游行队伍出发，现场开始分配布条、火把、棍棒、自制燃烧瓶，常持琇与黄信介随即抵达现场，而常持琇却被不明人士攻击，连帽子都打掉，常持琇拒绝出借场地，并下令出动镇暴部队。由于原定集会地点“扶轮公园”已经被封锁，游行队伍只能临时改变集会地点，施明德、姚嘉文等人率领数百名民众，从《美丽岛》杂志社高雄市服务处出发，前往今新兴分局前中山一路与中正四路路口的大圆环，同时民众多人手持“火把”，象征普世人权的光环。在抵达大圆环后，民众熄灭火把、席地而坐，由黄信介于宣传车上首先发表谈话，但很快整个大圆环就被镇暴部队、宪兵、警察包围。演讲完毕，黄信介同总指挥施明德与姚嘉文出面与警方谈判，要求警方允许他们在原定地点集会到晚上11点，并要求撤回镇暴部队、出让一个进出口，条件为让警察可以到现场维护秩序；但经副司令张墨林请示的结果，谈判要求全部被驳回；晚上8点半，镇暴车上冒出几缕白烟，镇暴警察开始在游行现场施放催泪瓦斯，现场民众开始骚动，并由大圆环移向中正四路，在南台路口的封锁线前方与宪兵、警察爆发严重冲突，双方均受伤惨重。当民众冲破第一道封锁线时，施明德要求群众撤回服务处，但现场已经完全失控，群众继续冲撞高雄市第一分局，当时人数粗估约10万人。后来民众退回服务处，张俊宏见现场气氛稍息，站上宣传车要求迅速解散，但众人仍留在现场倾听吕秀莲演讲。黄越钦立即与常持琇交涉，要求先行撤离镇暴部队以劝退民众解散，但常持琇坚持先行驱离民众，谈判陷入僵局；晚间10时左右，装甲车及警队聚集于中山一路，释放催泪瓦斯，镇暴部队同时手持盾牌配合镇暴车逼近游行队伍，在场民众还以石块及棍棒攻击，双方更发生更大规模的冲突，同时有“不明人士”攻击民宅，直至半夜民众才逐渐解散。事后官方宣称军警约有183人受伤，而民众无人受伤，受到质疑后又改称有50多人受伤。事件之后，国民党政府指挥新闻媒体一面倒地指责参与活动的民众，电视台不断播放宪警住院，以及发动社会各界关怀及声援宪警的情况。国民党政府一味将宪警塑造成受害者，并铺天盖地批评党外人士为“共匪”，间谍，等称号。这使得伪政府当局或多或少陷入了被动。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line56 := d.political_line if d.size() > W.I_POLITICAL_LINE else 0
	var agents := d.agents if d.size() > W.I_AGENTS else 0
	var army := d.army if d.size() > W.I_ARMY else 0
	var opt := event_def.options
	if line56 <= 1 and agents >= 50 and army >= 100:
		_enable(opt[0], event_def.options[0].text)
	elif line56 > 1:
		_disable(opt[0], TXT_OPT0_DIS_A)
	else:
		_disable(opt[0], TXT_OPT0_DIS_B)
	if line56 <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var taiwan := _country(38)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if taiwan != null:
				taiwan.stab = 1
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
			_add(W.I_DIPLO, 10)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, -10)
		1:
			context["result_text"] = TXT_R1
			if taiwan != null:
				taiwan.stab = 2
			_add(W.I_DIPLO, 5)
			_add_relation(EmpireData.USA, -25)
			_add_power(EmpireData.USA, -5)
		2:
			context["result_text"] = TXT_R2
			_add_power(EmpireData.USA, -5)




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)


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


