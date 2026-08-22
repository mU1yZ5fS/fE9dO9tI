extends "res://数据脚本/event_script_base.gd"

## 福尔摩沙之冬 / 福尔摩沙之春（Formosa Winter / Formosa Spring）
## 移植自 Unity 原作：
##   Event460.cs  — 福尔摩沙之冬（ResultsOfEvents :51-75）
##   Event461.cs  — 福尔摩沙之春（ResultsOfEvents :33-101）
## 触发入口：
##   event_460_formosa_winter.tres（ReqEventForDLC02.cs:392-395 的自动触发条件）
##   event_461_formosa_spring.tres（DiploButtonScript.cs:11411-11415 的外交入口手动触发）
##
## 入口契约：EventEngine.apply_event_option 对本脚本生成的 CUSTOM_SCRIPT 效果
## 调用 execute(context)；context.event_id / context.option_index / context.result_text。


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	if event_def.event_id != "formosa_winter" or event_def.options.size() < 3:
		return
	var line: int = p_ws.political_line if p_ws.size() > W.I_POLITICAL_LINE else 0
	if line > 1:
		event_def.options[0].disabled_text = "支持左派？我们连自己党里的左派都不放心！"
	else:
		event_def.options[0].disabled_text = "我们有心无力！"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"formosa_winter":
			match option_index:
				0:
					_winter_result_0(context)
				1:
					_winter_result_1(context)
				2:
					_winter_result_2(context)
		"formosa_spring":
			# Event461.cs:36 —— 两个结果分支之前统一执行 LeaveAlliances()。
			_spring_leave_alliances()
			match option_index:
				0:
					_spring_result_0(context)
				1:
					_spring_result_1(context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()
	# 项目惯例：国家面板/概览 仍读 global_flags.event_done_XXX / result_XXX
	# （国家面板.gd 台湾分支、概览.gd:497；同 event_500_african_union.gd:53-54）。
	match str(context.get("event_id", "")):
		"formosa_winter":
			ws.set_flag("event_done_460", true)
			ws.set_flag("result_460", option_index)
		"formosa_spring":
			ws.set_flag("event_done_461", true)
			ws.set_flag("result_461", option_index)


# ============================================================================
# Event460.cs — 福尔摩沙之冬
# ============================================================================

## Event460.cs:51-61（result_num == 0）
func _winter_result_0(context: Dictionary) -> void:
	var taiwan := _taiwan()
	if taiwan != null:
		taiwan.stab = 1                       # Event460.cs:54  allcountries[38].stab = 1
	_add_data(W.I_AGENTS, -50)                # Event460.cs:55  data.agents -= 50
	_add_data(W.I_ARMY, -100)                 # Event460.cs:56  data.army -= 100
	_add_data(W.I_DIPLO, 10)                  # Event460.cs:57  data.diplomatic_reputation += 10
	ws.influence_prc += 20                    # Event460.cs:58  influencePRC += 20
	_add_empire_relation(EmpireData.USA, -50) # Event460.cs:59  empires[0].relations -= 50
	_add_empire_power(EmpireData.USA, -10)    # Event460.cs:60  empires[0].power -= 10
	context["result_text"] = "我们秘密联络了“夏潮派”，他们对于得到来着海峡对岸的支持和援助感到又惊又喜。通过“渔船”，一批又一批的手枪和防毒面具被“意外”冲上海峡对岸。该派的领袖吴荣元表示愿意重建中国共产党台湾支部。12月10日当天中午，蒋伪政府全面动员，进行交通管制并封锁举办集会的预定地扶轮公园；晚上6点，游行队伍出发，现场开始分配布条、火把、棍棒、自制燃烧瓶，常持琇与黄信介随即抵达现场，而常持琇却被不明人士攻击，连帽子都打掉，常持琇拒绝出借场地，并下令出动镇暴部队。由于原定集会地点“扶轮公园”已经被封锁，游行队伍只能临时改变集会地点，施明德、姚嘉文等人率领数百名民众，从《美丽岛》杂志社高雄市服务处出发，前往今新兴分局前中山一路与中正四路路口的大圆环，同时民众多人手持“火把”，象征普世人权的光环。在抵达大圆环后，民众熄灭火把、席地而坐，由黄信介于宣传车上首先发表谈话，但很快整个大圆环就被镇暴部队、宪兵、警察包围；晚上8点半，镇暴车上冒出几缕白烟，镇暴警察开始在游行现场施放催泪瓦斯，现场民众开始骚动，并由大圆环移向中正四路，在南台路口的封锁线前方与宪兵、警察爆发严重冲突，双方均受伤惨重。当民众冲破第一道封锁线时，施明德要求群众撤回服务处，但现场已经完全失控，群众继续冲撞高雄市第一分局，当时人数粗估约10万人。后来民众退回服务处，张俊宏见现场气氛稍息，站上宣传车要求迅速解散，但众人仍留在现场倾听吕秀莲演讲。黄越钦立即与常持琇交涉，要求先行撤离镇暴部队以劝退民众解散，但常持琇坚持先行驱离民众，谈判陷入僵局；晚间10时左右，装甲车及警队聚集于中山一路，释放催泪瓦斯，镇暴部队同时手持盾牌配合镇暴车逼近游行队伍。在这时，一声枪响打破了宁静，一名警察的手枪走火打伤了一位无辜市民。顿时抗议就朝着不可控的方面发展，得到武装支援的“夏潮”派以美丽岛报社为街垒，和军警发生了交火。双方均有受伤事后官方宣称军警约有183人受伤，15人遇害，而民众无人受伤，受到质疑后又改称有50多人死亡。事件之后，国民党政府指挥新闻媒体一面倒地指责参与活动的民众。不断播放宪警住院，以及发动社会各界关怀及声援宪警的情况。国民党政府一味将宪警塑造成受害者，并铺天盖地批评党外人士为“共匪”，间谍，等称号。这使得伪政府当局或多或少陷入了被动。"


## Event460.cs:63-70（result_num == 1）
func _winter_result_1(context: Dictionary) -> void:
	var taiwan := _taiwan()
	if taiwan != null:
		taiwan.stab = 2                       # Event460.cs:66  allcountries[38].stab = 2
	_add_data(W.I_DIPLO, 5)                   # Event460.cs:67  data.diplomatic_reputation += 5
	_add_empire_relation(EmpireData.USA, -25) # Event460.cs:68  empires[0].relations -= 25
	_add_empire_power(EmpireData.USA, -5)     # Event460.cs:69  empires[0].power -= 5
	context["result_text"] = "中华人民共和国台湾事务处对美丽岛组织发去了慰问电，称他们是：“对抗法西斯主义的英雄，一切有良知的人的榜样。”12月10日当天中午，蒋伪政府全面动员，进行交通管制并封锁举办集会的预定地扶轮公园；晚上6点，游行队伍出发，现场开始分配布条、火把、棍棒、自制燃烧瓶，常持琇与黄信介随即抵达现场，而常持琇却被不明人士攻击，连帽子都打掉，常持琇拒绝出借场地，并下令出动镇暴部队。由于原定集会地点“扶轮公园”已经被封锁，游行队伍只能临时改变集会地点，施明德、姚嘉文等人率领数百名民众，从《美丽岛》杂志社高雄市服务处出发，前往今新兴分局前中山一路与中正四路路口的大圆环，同时民众多人手持“火把”，象征普世人权的光环。在抵达大圆环后，民众熄灭火把、席地而坐，由黄信介于宣传车上首先发表谈话，但很快整个大圆环就被镇暴部队、宪兵、警察包围。演讲完毕，黄信介同总指挥施明德与姚嘉文出面与警方谈判，要求警方允许他们在原定地点集会到晚上11点，并要求撤回镇暴部队、出让一个进出口，条件为让警察可以到现场维护秩序；但经副司令张墨林请示的结果，谈判要求全部被驳回；晚上8点半，镇暴车上冒出几缕白烟，镇暴警察开始在游行现场施放催泪瓦斯，现场民众开始骚动，并由大圆环移向中正四路，在南台路口的封锁线前方与宪兵、警察爆发严重冲突，双方均受伤惨重。当民众冲破第一道封锁线时，施明德要求群众撤回服务处，但现场已经完全失控，群众继续冲撞高雄市第一分局，当时人数粗估约10万人。后来民众退回服务处，张俊宏见现场气氛稍息，站上宣传车要求迅速解散，但众人仍留在现场倾听吕秀莲演讲。黄越钦立即与常持琇交涉，要求先行撤离镇暴部队以劝退民众解散，但常持琇坚持先行驱离民众，谈判陷入僵局；晚间10时左右，装甲车及警队聚集于中山一路，释放催泪瓦斯，镇暴部队同时手持盾牌配合镇暴车逼近游行队伍，在场民众还以石块及棍棒攻击，双方更发生更大规模的冲突，同时有“不明人士”攻击民宅，直至半夜民众才逐渐解散。事后官方宣称军警约有183人受伤，而民众无人受伤，受到质疑后又改称有50多人受伤。事件之后，国民党政府指挥新闻媒体一面倒地指责参与活动的民众，电视台不断播放宪警住院，以及发动社会各界关怀及声援宪警的情况。国民党政府一味将宪警塑造成受害者，并铺天盖地批评党外人士为“共匪”，间谍，等称号。这使得伪政府当局或多或少陷入了被动。"


## Event460.cs:72-76（result_num == 2）
func _winter_result_2(context: Dictionary) -> void:
	_add_empire_power(EmpireData.USA, -5)     # Event460.cs:75  empires[0].power -= 5
	context["result_text"] = "12月10日当天中午，蒋伪政府全面动员，进行交通管制并封锁举办集会的预定地扶轮公园；晚上6点，游行队伍出发，现场开始分配布条、火把、棍棒、自制燃烧瓶，常持琇与黄信介随即抵达现场，而常持琇却被不明人士攻击，连帽子都打掉，常持琇拒绝出借场地，并下令出动镇暴部队。由于原定集会地点“扶轮公园”已经被封锁，游行队伍只能临时改变集会地点，施明德、姚嘉文等人率领数百名民众，从《美丽岛》杂志社高雄市服务处出发，前往今新兴分局前中山一路与中正四路路口的大圆环，同时民众多人手持“火把”，象征普世人权的光环。在抵达大圆环后，民众熄灭火把、席地而坐，由黄信介于宣传车上首先发表谈话，但很快整个大圆环就被镇暴部队、宪兵、警察包围。演讲完毕，黄信介同总指挥施明德与姚嘉文出面与警方谈判，要求警方允许他们在原定地点集会到晚上11点，并要求撤回镇暴部队、出让一个进出口，条件为让警察可以到现场维护秩序；但经副司令张墨林请示的结果，谈判要求全部被驳回；晚上8点半，镇暴车上冒出几缕白烟，镇暴警察开始在游行现场施放催泪瓦斯，现场民众开始骚动，并由大圆环移向中正四路，在南台路口的封锁线前方与宪兵、警察爆发严重冲突，双方均受伤惨重。当民众冲破第一道封锁线时，施明德要求群众撤回服务处，但现场已经完全失控，群众继续冲撞高雄市第一分局，当时人数粗估约10万人。后来民众退回服务处，张俊宏见现场气氛稍息，站上宣传车要求迅速解散，但众人仍留在现场倾听吕秀莲演讲。黄越钦立即与常持琇交涉，要求先行撤离镇暴部队以劝退民众解散，但常持琇坚持先行驱离民众，谈判陷入僵局；晚间10时左右，装甲车及警队聚集于中山一路，释放催泪瓦斯，镇暴部队同时手持盾牌配合镇暴车逼近游行队伍，在场民众还以石块及棍棒攻击，双方更发生更大规模的冲突，同时有“不明人士”攻击民宅，直至半夜民众才逐渐解散。事后官方宣称军警约有183人受伤，而民众无人受伤，受到质疑后又改称有50多人受伤。事件之后，国民党政府指挥新闻媒体一面倒地指责参与活动的民众，电视台不断播放宪警住院，以及发动社会各界关怀及声援宪警的情况。国民党政府一味将宪警塑造成受害者，并铺天盖地批评党外人士为“共匪”，间谍，等称号。这使得伪政府当局或多或少陷入了被动。"


# ============================================================================
# Event461.cs — 福尔摩沙之春
# ============================================================================

## Event461.cs:36 + Country.cs:89-115（LeaveAlliances）
## Godot 侧标签集合与 world_factory.gd:112-116 START_CLEAR_TAGS 保持一致；
## 同时按 Country.cs:113 清 puppetOf = -1。
func _spring_leave_alliances() -> void:
	var taiwan := _taiwan()
	if taiwan == null:
		return
	for tag in WorldFactory.START_CLEAR_TAGS:
		taiwan.set_tag(tag, false)
	taiwan.puppet_of = GameConstants.LegacySlot.NONE


## Event461.cs:37-71（result_num == 0）
func _spring_result_0(context: Dictionary) -> void:
	var taiwan := _taiwan()
	var china := _china()
	if taiwan != null:
		taiwan.government = GameConstants.Government.SOCIALIST                 # Event461.cs:40  Gosstroy = 1
		taiwan.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST             # Event461.cs:41  SubGosstroy = 2
		taiwan.set_tag("亲中", true)          # Event461.cs:42  proprc = true
		taiwan.set_tag("对华贸易", true)      # Event461.cs:43  Torg = true
		taiwan.puppet_of = GameConstants.LegacySlot.CHINA                  # Event461.cs:44  puppetOf = 1
		taiwan.chinese_name = "台湾特别行政区"  # Event461.cs:45  name = "台湾特别行政区"
		if china != null:
			if china.has_tag("econ"):          # Event461.cs:46-49
				taiwan.set_tag("econ", true)
			if china.has_tag("okb"):           # Event461.cs:50-53
				taiwan.set_tag("okb", true)
			if china.has_tag("sev"):           # Event461.cs:54-57
				taiwan.set_tag("sev", true)
			if china.has_tag("ovd"):           # Event461.cs:58-61
				taiwan.set_tag("ovd", true)
			if china.has_tag("rim"):           # Event461.cs:62-65
				taiwan.set_tag("rim", true)
	_add_empire_relation(EmpireData.USA, -500) # Event461.cs:66  empires[0].relations -= 500
	_add_data(W.I_PARTY_SUPPORT, 300)          # Event461.cs:67  data.party_support += 300
	_add_data(W.I_PEOPLE_SUPPORT, 300)         # Event461.cs:68  data.people_support += 300
	_add_data(W.I_BUDGET, -100)                # Event461.cs:69  data.budget -= 100
	_add_data(W.I_AGENTS, -100)                # Event461.cs:70  data.agents -= 100
	context["result_text"] = "随着我们对台湾当局施加了巨大的压力，制裁和禁运迅速压垮了这个本就没有什么自给能力的小岛。在一次对抗政府的示威中。我们的特务借机煽风点火，在“你可听见人民的呼声”的歌声中，军警拒绝了接受蒋经国总统关于对人民开枪的指令，事实上发生了哗变。感到自己时日无多的蒋经国收拾了细软，逃往美国檀香山。我们的努力得到了回报，由吴荣元组建的“红统”派台湾劳动党事实上夺取了台湾的政治权利。作为推翻蒋氏暴政的英雄，以及对大陆美好生活的向往，台湾迅速决定了接受中华人民共和国管理的决定。外企被悉数收回，美国军队也悉数撤回。而和大陆之间的隔阂也被消除。尽管名义上台湾组建了自己的，独立于北京的政府，但是谁都知道，台湾和大陆再也不会分开了。"


## Event461.cs:72-101（result_num == 1）
func _spring_result_1(context: Dictionary) -> void:
	var taiwan := _taiwan()
	var china := _china()
	if taiwan != null:
		taiwan.government = GameConstants.Government.REFORMIST                 # Event461.cs:75  Gosstroy = 2
		taiwan.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST             # Event461.cs:76  SubGosstroy = 3
		taiwan.set_tag("亲中", true)          # Event461.cs:77  proprc = true
		taiwan.set_tag("对华贸易", true)      # Event461.cs:78  Torg = true
		_add_empire_relation(EmpireData.USA, -300) # Event461.cs:79  empires[0].relations -= 300
		taiwan.chinese_name = "台湾特别行政区"  # Event461.cs:80  name = "台湾特别行政区"
		if china != null:
			if china.has_tag("econ"):          # Event461.cs:81-84
				taiwan.set_tag("econ", true)
			if china.has_tag("okb"):           # Event461.cs:85-88
				taiwan.set_tag("okb", true)
			if china.has_tag("sev"):           # Event461.cs:89-92
				taiwan.set_tag("sev", true)
			if china.has_tag("ovd"):           # Event461.cs:93-96
				taiwan.set_tag("ovd", true)
	_add_data(W.I_PARTY_SUPPORT, 200)          # Event461.cs:97  data.party_support += 200
	_add_data(W.I_PEOPLE_SUPPORT, 100)         # Event461.cs:98  data.people_support += 100
	_add_data(W.I_BUDGET, -50)                 # Event461.cs:99  data.budget -= 50
	_add_data(W.I_AGENTS, -50)                 # Event461.cs:100 data.agents -= 50
	context["result_text"] = "随着我们对台湾当局施加了巨大的压力，制裁和禁运迅速压垮了这个本就没有什么自给能力的小岛。在一次对抗政府的示威中。我们的特务借机煽风点火，在“你可听见人民的呼声”的歌声中，军警拒绝了接受蒋经国总统关于对人民开枪的指令，事实上发生了哗变。感到自己时日无多的蒋经国收拾了细软，逃往美国檀香山。由倒蒋集团组成的大帐篷式政党“民主进步党”在大选中击溃了国民党。新他们立刻宣布将和“中华人民共和国展开深入的合作”。新政府立即着手驱赶美军士兵，并放弃了对于大陆的宣称。我们决定在和平对等的基础上吸纳台湾。他们会和祖国母亲团结在一起，直到永远。"


# ============================================================================
# 工具方法
# ============================================================================

func _taiwan() -> CountryData:
	return ws.get_country_by_legacy_index(38)


func _china() -> CountryData:
	return ws.get_country_by_legacy_index(1)


func _add_data(index: int, delta: int) -> void:
	if index >= 0 and index < d.size():
		d.add_data_by_index(index, delta)


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		d.usa_relations = ws.empires[EmpireData.USA].relations
		d.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		d.ussr_relations = ws.empires[EmpireData.USSR].relations
		d.soviet_influence = ws.empires[EmpireData.USSR].power
