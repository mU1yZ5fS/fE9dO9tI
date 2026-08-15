## 原作 Event295.cs：复仇女神（莫罗新政府，三选项）。
## 触发：全目录搜索无 this_num_event = 295 / Reset(295)；链外 REST 段，原版无自动条件。
## 差异：结果前全局 allcountries[85].Vyshi=false 已复刻；resultOfEvents[291] 缺省按原版 int 0 处理。
extends "res://数据脚本/event_script_base.gd"

const TXT_TITLE := "复仇女神"
const TXT_DESC := "踢开了老东家天主教民主党，并在新一届选举内大胜，成功确立新领导班子的总理阿尔多·莫罗终于得以大显身手，并按照自身愿景重塑该国政治生态：基于“民主替代”的社会天主教立场与亲中左翼态度，以及意大利社会党的“左翼替代”招牌与人道的、民主的欧洲社会主义路线。对于意大利国家性质的“再定义”很快便被提上日程。显然，阿尔多·莫罗仍记得60年代初次带领“中左翼公式”执掌意大利的屈辱：彼时出于抵制一切左翼政治势力在意大利“失控”（亦或掌权）的可能，该国前总统安东尼奥·塞尼曾特别召见亲君主派人士兼卡宾枪骑兵总指挥乔瓦尼·德·洛伦佐共商“大事”。计划一旦作为预备政治方案的“中左翼政府”走向崩溃，那便是该国军方出场恢复秩序，并在总统的背书下确立威权戒严配民选形式新格局的时刻。如此做法自然导致初代莫罗政府不得不在同塞尼总统的相处期间束手束脚，并冻结了相当数量的社会改革方案，亲改革派天主教组织的参政渠道亦被人为限制。如今也是时候扭转这种偏差——对“莫罗案”的反思与深入调查很快便转化为了有限社会解冻：在“庇护国民比先发制人更重要”的口号下，意大利安全部门的特权被系数收回：因滥用紧急状态，有架空总理之势而闻名，并开创“铁腕权臣”时代的前部长弗朗切斯科·科西加与其体制正逐步遭到清算。其工作重心则不得不转向对已知恐怖组织的清剿上，由此确立了“自由之敌无自由”的基本模式。与此同时，该国在莫罗案中的戏剧性新发现使其不得不同传统盟友靠边——相关证据表明，20世纪70年代的政治混乱同美国密切相关：后者通过制造混乱与紧张局势，并激化意大利社会内的政治暴力获利。在莫罗绑架事件从酝酿到执行期间，与美国情报机构不仅积极同天主教民主党内部的异见分子对接，计划边缘化莫罗；更以提供情报、渗透组织与激化局势等系列做法为“红色旅”与“革命武装核心”等对当局有显著敌意的活动家开了便车——这便是北约在意大利预留的军事情报网络未能在绑架事件期间发挥效力的缘故。为的就是除掉一个准备同意大利共产党结盟的棘手政治家。上述曝光的结果引起了意大利公众的共鸣，阿尔多·莫罗借此继续炮轰其老对手天主教民主党，指控美国干涉意大利内政，并宣布意大利将减少在北约组织内的参与程度。考虑到意大利国内政治力量此消彼长，似乎正是我们入局之时？"
const TXT_OPT0 := "我们将静观其变"
const TXT_OPT1 := "我们将浑水摸鱼，借机渗透意大利安全机构"
const TXT_OPT1_DIS := "我们力不从心"
const TXT_OPT2 := "我们将借力打力，为该国的激进分子提供助力"
const TXT_OPT2_DIS := "我们力不从心"
const TXT_R0 := "意大利国内局势仍按照阿尔多·莫罗的指挥棒旋转起舞，并越发屈服于这位冉冉升起的政治偶像：卡宾枪骑兵对于激进主义团体的挤压进程只是以总理-政府主导的修正式继续存在，而曾经的主流政党或成为新一届莫罗政府的台前宾，或在莫罗的中左翼格局设计下被迫靠边：其中最受伤害的当属试图同天主教选民调情，并借此在1976年选举取得大胜的意大利共产党——意识到“民主替代”足以从更为官方且正统的角度推进其议程，那么也就没有选择具有类似生态位的反对派之必要……曾作为该国政治巨头的天主教民主党则事实上走向脑死亡，并被对莫罗按图索骥的一系列新版“新党运动”取而代之。然而不论是从规模还是成绩来看，所有的这些继业者都无法同莫罗相提并论。显然，至少在未来的近十年内，莫罗的霸权将屹立不倒。"
const TXT_R1 := "意大利政治局势的巨变与莫罗案调查的持续推进自然导致了对该国安全部门的职能调整与人事变动，而这恰是1977年情报系统改革的延续：出于巩固意大利民选文官政府的需要。彼时统管国内军情，挂靠国防部，向内务部述职的巨无霸国防情报局被解体，并在随后拆解为拆解为分别作为内务部与国防部下属的民情与安全局（SISDE）与军情与安全局（SISMI）。而莫罗案的特殊性质又导致了前者被越加委以重任，并开始大量引入来自非军方系统新人以推进有限度政治解冻。与此同时，莫罗试图以办公室清洗模式逐步削弱，乃至铲除同该国保守派如胶似漆的顽固军方人士，并终结相关组织内的寡头治理模式——毕竟自第一共和国诞生以来，军方内部的保守乃至亲法西斯态度便不是秘密。而这便为我们浑水摸鱼提供了机会：中左翼政府同保守派的长期角力使得各方必须争取一切政治赞助以求最终胜利，而北约集团对意大利事务影响力的衰退则更让该国建制派们极力寻求一种重构国防安全体系的替代方案。得到我国资金与情报资源背书的政治说课、安全顾问与间谍至此轻易渗入意大利国内政局，并在双方间腾挪自如，游刃有余。不仅大大扩充了我国在意大利的后备力量，摸清了该国底细，更揪出对弈双方的各种黑料与意大利国内“深层政府”的决策机制——以阿尔多·莫罗、贝蒂诺·克拉克西等为代表的民主政党领导者们极度仰赖同国内企业、外国独裁者、甚至来自黑手党方的政治献金与同其相关的利益团体支撑其选战活动，并由此确立政治领导权。与之相关的政治内幕交易涉案资金巨大，足以引爆空前危机；而作为其对立面的军方则同共济会地下社团“宣讲二号”存在密切往来，情报机构的部分成员兼有后者身份。这种双重格局足以让“宣讲二号”头目，资深反共分子利西奥·盖利利用军方人士插手政务，更在国内犯罪调查（如金融案件与帮派火并）中为其提供各种有利论据，使其完美隐身。除此之外，军方更借助深度参与北约组织的反苏后卫计划“短剑行动”之机渗透该国的激进主义政治运动，并借此引爆政治暴力。倒逼该国公民转而选择更健康的“民主制度”——显然，我们钓上大鱼了，接下来就是如何利用它……"
const TXT_R2 := "意识到意大利的政治解冻与对安全机构的清洗将创造战略进攻窗口，而中左翼政府的形成与最终巩固必然导致意大利激进主义的彻底退潮。因此，我们决定抓住这一机会进行施压。早已同中国牵线搭桥的极左翼群众运动与各地自管社会中心已准备接收新一批物资支持，为保卫社区生活与扩充势力范围蓄势；激进主义活动家们也开始标榜同“红色旅”、“前线”等直接表态敌视国家机器，并在莫罗案后成为众矢之的城市游击队运动分道扬镳，并转而加入更不受“拘束”的野猫罢工、政治占领与游行示威活动内，以此持续挑衅莫罗政府权威。社会气氛的骤然升温导致阿尔多·莫罗不得不选择战略退却，并转而采取更适应“民主主义”生态的政治手段予以遏制：卡宾枪骑兵与内务部得到了特别审批与调查权，作为中左翼政府重要支撑的意大利社会党开始活跃，旨在拉拢中间派选民的社会福利议程亦得以进一步推进。意大利当局显然清楚，只要自己能抢先在激进主义者前推进系统性替代议程，那么议会外激进派也只能作为不可能执政的在野党充当起安保体制的“合理性”补充。最终的结果便是左翼阵营的普遍冷却与“回归日常”的潮流泛起（而这恰是“1977年运动”后得到国家机器鼓励的新一波潮流：要求公民放弃一切宏大叙事与社会运动，安心退回个人生活并享受现代消费主义）。希望我们能赶在一切无可挽回前完成早该降临的革命。不过，中左翼政府的对策并非十全十美——毕竟，这些新党运动在推行政治议程期间切实采取了“无中生有”方式聚拢资金与政治资本。显然，深层国家的秘密决策机制正与之相伴而行……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var budget := world.数值表[W.I_BUDGET] if world.数值表.size() > W.I_BUDGET else 0
	var reserve := world.数值表[W.I_RESERVE] if world.数值表.size() > W.I_RESERVE else 0
	var agents := world.数值表[W.I_AGENTS] if world.数值表.size() > W.I_AGENTS else 0
	var army := world.数值表[W.I_ARMY] if world.数值表.size() > W.I_ARMY else 0
	var italy := world.get_country_by_legacy_index(85)
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	if budget + reserve >= 80 and agents >= 50:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if budget + reserve >= 40 and army >= 35 and italy != null and italy.内战中:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	if italy != null:
		italy.set_tag("亲美", false)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -50)
			_add(182, 2)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_AGENTS, -40)
			_add(W.I_ARMY, -35)
			if italy != null:
				italy.level_of_development -= 5
			_add(134, 15)
			var res291 := int(ws.completed_event_ids.get("event_291", 0))
			if ws.completed_event_ids.has("event_291") and res291 < 3:
				_add(172 + res291, 1)
				if res291 == 0:
					_add(172 + res291, 1)
			_add(182, 1)
			context["result_text"] = TXT_R2


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _mod_active(idx: int) -> bool:
	var w := ws if ws != null else GameManager.world
	return w != null and w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


func _set_leader_from(p: PoliticianData) -> void:
	if ws.leader == null or p == null:
		return
	ws.leader.name_display = p.name_display
	ws.leader.name_first = p.name_first
	ws.leader.name_last = p.name_last
	ws.leader.trait_personality = p.trait_personality
	ws.leader.trait_background = p.trait_background
	ws.leader.trait_alignment = p.trait_alignment
	ws.leader.trait_special = p.trait_special
	ws.leader.age = p.age
	ws.leader.face_type = p.face_type
	if p.face_parts.size() >= 8:
		ws.leader.face_parts = p.face_parts.duplicate()
	ws.leader.jacket = p.jacket

