extends "res://数据脚本/event_script_base.gd"

const S_14 := "第二次五月风暴"
const S_17 := "吉斯卡尔政府不可动摇的自由主义原则并未为法国带来良好的发展，吉斯卡尔·德斯坦的绝大多数措施均没有带来显著成效，法国经济也陷入了停滞。"
const S_21 := "密特朗政府没能在国际形式与资本外流的压力前站稳脚跟，所以它选择了终结左翼凯恩斯主义改革。在随后，政府开始实行紧缩政策，实质上奉行新自由主义政策。弗朗索瓦·密特朗对社会转型的必要性已经闭口不谈了。"
const S_25 := "乔治·马歇在转型上的失败引起了再私有化以及左右翼的对抗，造成了失业和社会的撕裂。"
const S_29 := "希拉克政府实行新戴高乐主义的政策。政府对一边以福利收买工人阶级一边收拢锁链——削弱左翼的力量并打压工会，雇主的法律权力也极大扩张，法团主义也在企业中盛行；与此同时，政府在各项社会议题上相当保守压抑。为了应对赤字和社会支出，法国在西非的前殖民地推行新殖民主义，以应对高涨的开支。"
const S_31 := "西欧多国脱离自由资本主义秩序给法国带来的冲击和民众对建制各派势力的失望，法国社会这些年来存在的问题和矛盾都借此机会再度爆发。先是部分大学的发生了骚动，学生对政府举行游行抗议，他们呼吁“重新拾起1968的精神”；不久，一场有预谋的罢工便席卷了全国。鉴于1968运动的前车之鉴，各派力量开始寻求组建相似意识形态组织的统一战线，并将斗争对象直接指向国家机器。群众运动中有三股主要势力正在崛起。奉行毛主义的人民革命联盟（由法国马列主义共产党、马列主义共产主义组织——无产阶级道路和法国马列主义共产主义者联盟等毛派政党组成）、托洛茨基主义与新左派的联盟——革命工人组织（由“工人斗争”、革命共产主义同盟、统一社会党等组成）以及各类民族主义组织【如新势力党、法兰西工作党、革命民族主义运动和人民斗争组织（重建）等】。此外，法国还存在多个极左翼和极右翼的城市游击队（如“直接行动”、“人民自治武装核心”、“红色海报”、道德秩序委员会等）利用境外势力支援的武器开展城市游击战，他们虽然各自为战，但也是一方可以利用的力量。\n法国政府实在屡次尝试驱散集会和镇压运动未果后，不愿看到流血事件再度重演，宣布辞职以重新开展选举。但是官僚机构已经在运动的冲击下失去了效能，大街上，仅能看见各派势力的“武斗”以及他们同警察力量的斗争。建制势力不会因为一时的混乱而退缩或自发迎来终局，不能再等下去了，我们也许应该做点什么。"
const S_37 := "支持人民革命联盟"
const S_38 := "支持革命工人组织"
const S_39 := "支持民族主义组织"
const S_40 := "法国人关我们什么事？"
const S_43 := "荣耀归于你，太阳王！"
const S_47 := "要不要挂吉约丹医生的号？"
const S_52 := "第二次五月风暴"
const S_147 := "法国是一片充满了革命火种的土壤，同时也是自由主义者假借“革命”之名义倒行逆施的屠宰场，一个自由主义的幽灵自1793年以来就萦绕着这片土地。但是，这一切再也不会发生了，我们在法兰西的情报人员们借着“大使馆革命”的热潮，在第五共和国内部发现了一批有意思的人物。以新保王党行动中的“毛-莫拉斯主义者”热拉尔·勒克莱尔为切入点，结识到了“老大”贝特朗·雷努万；再佐以脱离自法国共产党的法兰西行动党员皮埃尔·德布雷；我们正在打入这个奇妙的政治组织。同时我们还结实了从保王派转向毛派和左翼戴高乐主义立场但仍认同莫拉斯的莫里斯·克拉维尔和前《红鸢尾》报负责人克里斯蒂安·马松，热忱的将他们邀请入我们这一代人的民族阵线。并将原先脱党的民族毛主义者克里斯蒂安·布歇安插入了DSGI巴黎大区支部，给本就脆弱的民主制度敲进了一枚锋利的楔子。新保王党行动正在“左倾”，吸纳了如“大同社会”的理想，莫拉斯的权力下放和国家工团主义经济，并将其中的强硬保王派元素和社会主义先进文化的红色基因相结合。\n一场精心谋划的政变爆发了，伪装成极左翼武装组织“直接行动”的武装分子们爆破了如凯旋门等地标性的建筑，严重挑衅了共和国的政治威信。一切都在按照事先的计划进行，接下来，军队的高级领导人宣布进行军事戒严，旨在“彻底处理左翼反政府势力的威胁”，并暂停了议会。不必怀疑，掌握了军队的当然是我们的同志们。当然，被左翼恐怖份子煽动的暴民并不是很能理解当前的政治变化。在土伦，马赛，波尔多等地爆发了大规模的暴乱。不过军队成功将其镇压，也就此暴露出了旧共和国对民族敌人的无限宽容。“毛-莫拉斯主义者”们再也不会犯这样愚蠢的错误了。人民阵线和军方——情报局一致认同，只有迎回国王，才能在莫斯科共产主义，华盛顿自由主义和野蛮的共和体系中挽救法兰西。军方委任了热拉尔·勒克莱尔为首任总理大臣，各位战友们也得到了合适的岗位。很快，他就要在巴黎庄严的为迟到的王举行加冕仪式，我们的大使也将在那个时候递交国书。大局已定，而旧制度已经土崩瓦解，为法兰西社会主义王国的王，亨利六世欢呼吧。"
const S_151 := "法兰西社会主义王国"
const S_157 := "卡纳克人民国"
const S_165 := "在各方协调下，“直接行动”、“人民自治武装核心”、“红色海报”等毛主义的城市游击队，在西欧革命国家（西欧多个左翼城市游击队都是盟友关系）的协助下，他们正式达成了和解，而各个革命国家将负责为他们提供一切支持，成为他们的后勤基地。他们被改组为正式的法兰西人民革命游击军，作为人民革命联盟附属的武装力量，并积极在学生和工人中发展潜在的成员和同情者。毛派从此作为一个统一的力量参与到这场法国的“全面内战”之中了。\n毛主义者们认识到不能再像上次一样各自为战，而是应该发起全国暴动，于是，真正的革命开始了。在意大利的帮助下，马赛成为了首义之城。随着工运和学运的蔓延，通过工人武装和城市游击队暴动很快就蔓延到全国。得益于意大利和西班牙对法国军队的渗透，法国军队经历了一次内部火并，我们的特工趁乱打开了武器库，很快，在人民革命联盟帮助下，市民军和工人武装都获得了武器，他们也被编入人民革命游击军。“为了不让皮埃尔·奥弗尼事件重演，工人们起来斗争！”成为了他们的口号。人民革命联盟领袖阿兰·巴迪欧宣布：“一切权力归法兰西公社！”在革命阵营的干预下，意大利和葡萄牙的志愿部队直接介入到小型内战中，毛主义者在他们的帮助下很快接管了法国。大局已定，革命尚未结束，曙光已经到来。"
const S_179 := "“战斗”派在英国的胜利使得全世界的托洛茨基主义者看到了曙光，而他们在法国的同志显然也抓住了第二次五月风暴动荡局势的契机。官僚化的斯大林主义显然不是能够与托洛茨基主义的真正革命派抗衡的！英国执政的工党“战斗”派决定向他们的同志发出援助。欧内斯特·曼德尔也再次来到了法国，参与和声援托派的运动。他们发出号召，邀请全世界的支持者来法国参加革命运动。托派工会被组织成赤卫队，工人通过占领大量的国家机构，并在英国特工和支援部队以及世界各地托派的国际纵队的的帮助下，革命工人组织最终控制了全国局势。"
const S_198 := "法国国家机器的瘫痪为激进主义分子活动提供了充分便利，并活化了该国少有的另类右翼：通过背靠意大利纳粹毛主义政权支持，法国境内的极右翼势力与军内民族主义者最终纷纷投靠“毛主义伞兵立场”——即试图将法国同第三世界政权整合为“民族共产主义联邦”并保全法兰西帝国的另类思维。让·蒂里亚特也趁此机会来到法国，与让-吉尔、马利亚拉基斯、伊夫·巴塔耶、克里斯蒂安·布歇等民族毛主义者顺藤摸瓜进入巴黎，将各地右翼准军事武装整合为“民族革命战斗队”。爱丽舍宫则因左右互搏而窃喜，并试图扮演“事后黄雀”。然而，他们的算盘早已被摸清局势的右翼团体提前摸清。文官政府的软弱无能只会刺激前秘密军分子实现登堂入室之梦：最终，“民族革命战斗队”的男爵们同军队内的“民族共产主义”派系一举拿下法国最高领导权，只在片刻便接管了全法国。形成了“民族毛派”活动家与“法兰西民族共产主义”军方的双头统治。第五共和国就此寿终正寝……"
const S_211 := "欧洲的革命民族主义风暴就像成吉思汗的铁骑一样踏遍整个大陆，不搅出个天翻地覆誓不罢休。这都大大助长了作为革命民族主义在法兰西的代言人的莫里斯·巴尔代什的风头，以激进的民族主义纲领给上传统右翼国族主义一左耳光的同时，再给以社会党和共产党为首的传统左翼来上一记“民族特色社会主义”的右勾拳。事实上的非法地位反而允许了他的法兰西社会主义与公社之友组织采取更为激进的行动，包括但不局限于组建自己的准军事组织“民族自卫军”，在土伦，马赛等地掀起反对阿拉伯和黑人移民的暴乱。而这一切都离不开兄弟国家们的支援，源源不断的武器正在通过各种意想不到的走私网路和羊肠小道流入该国。我们的支援更是让他没有了后顾之忧，得以安心处理那些“上尉”们。\n在左翼运动风起云涌的时代，代表秩序的政府领导人们天然就有着寻找右翼份子对冲的想法，毕竟，他们手段接近，与左翼分子是天然的死敌，并且能像切割法西斯主义者们一样处理掉他们。这也正是第五共和国的末代君主们的如意算盘：以驱虎吞狼之计彻底解决掉这两个心腹大患。可是他们错了，他们不仅低估了革命民族主义者们的强硬和对权力的野心，更低估了他们的手段。就在民族自卫军和他们的青年组织与“直接行动”、“红色海报”等组织打成一片的时候。巴尔代什和宪兵队正在赶往爱丽舍宫，第五共和国面对危险的软弱无能完完整整的展现在了他们面前。混乱的军队指挥系统和几乎完全倒戈以换取地位的队内情报总局局长们更是给了垂死的贵族们最后一击。按照协议，莫里斯·巴尔代什将和军官们效法波拿巴时期的政府，开始无限期的军事管辖。知名民族主义作家圣卢普(马克·奥吉耶)在为这一场“净化法兰西”的革命大唱赞歌之余也被吸纳进了政府。新的“民族阵线”除了法兰西社会主义与公社之友外，其他的如让·卡斯特里略的法国民族主义党，马利亚拉基斯的革命民族主义运动，阿兰·德·贝努瓦、多米尼克·韦纳、纪尧姆·费伊的欧罗巴文明研究与学习团体和蒂埃里·莫尼埃的西方研究所等组织则集体加入民族阵线。清晨照在充满着血污和肮脏的法兰西大地上，只需要一场暴雨，就能洗清她的毛孔里的每一滴罪恶……"
const S_224 := "法国国家机器的瘫痪为前秘密军分子活动提供了充分便利：他们彻底控制了军内保守派与法国国家安全机构，并将各地右翼准军事武装整合为“民族战斗队”。爱丽舍宫则因左右互搏而窃喜，并试图扮演“事后黄雀”。然而，他们的算盘早已被摸清局势的右翼团体提前摸清。文官政府的软弱无能只会刺激前秘密军分子实现登堂入室之梦：最终，“民族战斗队”领袖皮埃尔·西多斯和“报贩”首领皮埃尔·普热一举拿下法国最高领导权，并得到让·雅克·苏西尼将军的拥护。“真正的民族斗士”们只在片刻便接管了全法国，形成了极右翼活动家与民族主义军方的双头统治。第五共和国就此结束，第二“法兰西国”就此重建……"


## 原作 Event483.cs：第二次五月风暴（五选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1494-1496 ——
##   c21.Gosstroy==3 且 c85/c86/c87/c92/c45.Gosstroy!=3 且 年>=1984 且 月==5。
##   月相等 ExprNode 无法表达，走 trigger_script。
## 差异：
##  - modifies[42..45].active → ws.modifiers[i].is_active；
##  - EstablishGovernment(ProAmerican) → 仅清亲中/亲苏、置亲美（不动 government/sub）；
##  - LeaveAlliances / JoinAllOurAlliances 按项目惯例映射；puppetOf→puppet_of；econ→has_tag("econ")。

func evaluate(world: WorldState) -> bool:
	if world == null or world.date.year < 1984 or world.date.month != 5:
		return false
	var c21 := world.get_country_by_legacy_index(21)
	if c21 == null or c21.government != GameConstants.Government.LIBERAL:
		return false
	for idx in [85, 86, 87, 92, 45]:
		var c := world.get_country_by_legacy_index(idx)
		if c != null and c.government == GameConstants.Government.LIBERAL:
			return false
	return true


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var text := ""
	if _mod_active(world, 42):
		text = S_17
	elif _mod_active(world, 43):
		text = S_21
	elif _mod_active(world, 44):
		text = S_25
	elif _mod_active(world, 45):
		text = S_29
	event_def.description = text + S_31
	var opt := event_def.options
	_enable(opt[0], S_37)
	_enable(opt[1], S_38)
	_enable(opt[2], S_39)
	_enable(opt[3], S_40)
	var c1 := world.get_country_by_legacy_index(1)
	if c1 != null and c1.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_enable(opt[4], S_43)
	else:
		_disable(opt[4], S_47)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_set_mod_active(42, false)
	_set_mod_active(43, false)
	_set_mod_active(44, false)
	_set_mod_active(45, false)
	var france := ws.get_country_by_legacy_index(21)
	var opt := int(context.get("option_index", -1))
	var num := 0
	var num2 := 0
	var num3 := 0
	if opt == 0:
		num += 1
		_add(W.I_AGENTS, -150)
		_add(W.I_BUDGET, -150)
		_add(W.I_ARMY, -150)
	if opt == 1:
		num2 += 1
		_add(W.I_AGENTS, -150)
		_add(W.I_BUDGET, -150)
		_add(W.I_ARMY, -150)
	if opt == 2:
		num3 += 1
		_add(W.I_AGENTS, -150)
		_add(W.I_BUDGET, -150)
		_add(W.I_ARMY, -150)
	for idx in [86, 87]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null and ws.is_socialism(c, true):
			num += 1
	var c85 := ws.get_country_by_legacy_index(85)
	var c92 := ws.get_country_by_legacy_index(92)
	var c86 := ws.get_country_by_legacy_index(86)
	var c87 := ws.get_country_by_legacy_index(87)
	if (c85 != null and ws.is_socialism(c85, true)) or (c85 != null and c85.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST):
		num += 1
	if c92 != null and ws.is_socialism(c92, true):
		num += 1
	if c92 != null and c92.sub_government == GameConstants.SubGovernment.TROTSKYIST:
		num2 += 2
	if _sub(44) == 18:
		num2 += 2
	if _sub(1) == 18:
		num2 += 2
	if c92 != null and c92.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		num3 += 1
	if c86 != null and c86.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		num3 += 1
	if c86 != null and c86.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		num3 += 1
	if c85 != null and c85.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		num3 += 1
	if c85 != null and c85.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		num3 += 1
	if c87 != null and c87.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		num3 += 1
	if c85 != null and c85.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
		num3 += 3
	var num4 := 0
	for c in ws.countries:
		if c != null and c.原版序号 != 0 and c.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
			num4 += 1
	if num4 >= 7 and opt == 4:
		if france != null:
			france.government = GameConstants.Government.AUTHORITARIAN
			france.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
			_leave_alliances(france)
			france.name = S_151
			france.set_tag("亲中", true)
			france.set_tag("对华贸易", true)
		var c154 := ws.get_country_by_legacy_index(154)
		if c154 != null:
			c154.government = GameConstants.Government.AUTHORITARIAN
			c154.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
			_leave_alliances(c154)
			c154.name = S_157
			c154.set_tag("亲中", true)
			c154.puppet_of = GameConstants.LegacySlot.FRANCE
			c154.set_tag("对华贸易", true)
		ws.influence_prc += 50
		context["result_text"] = S_147
	elif num >= num2 and num >= num3:
		if france != null:
			france.government = GameConstants.Government.SOCIALIST
			france.sub_government = GameConstants.SubGovernment.MAOIST
			_leave_alliances(france)
			if opt == 0:
				france.set_tag("对华贸易", true)
				france.set_tag("亲中", true)
				_join_our_alliances(france)
				ws.influence_prc += 50
		context["result_text"] = S_165
	elif num2 >= num and num2 >= num3:
		if france != null:
			france.government = GameConstants.Government.SOCIALIST
			france.sub_government = GameConstants.SubGovernment.TROTSKYIST
			_leave_alliances(france)
			if opt == 1:
				france.set_tag("对华贸易", true)
				france.set_tag("亲中", true)
				ws.influence_prc += 50
				if _sub(1) == 18:
					_join_our_alliances(france)
		context["result_text"] = S_179
	elif (c86 != null and c86.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST) or (c92 != null and c92.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST):
		if c85 != null and c85.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
			if france != null:
				france.government = GameConstants.Government.AUTHORITARIAN
				france.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
				_leave_alliances(france)
				if opt == 2:
					ws.influence_prc += 50
					france.set_tag("对华贸易", true)
					france.set_tag("亲中", true)
			context["result_text"] = S_198
		else:
			if france != null:
				france.government = GameConstants.Government.AUTHORITARIAN
				france.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
				_leave_alliances(france)
				if opt == 2:
					ws.influence_prc += 50
					france.set_tag("对华贸易", true)
			context["result_text"] = S_211
	else:
		if france != null:
			france.government = GameConstants.Government.AUTHORITARIAN
			france.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			_leave_alliances(france)
			if opt == 2:
				france.set_tag("对华贸易", true)
				france.set_tag("亲中", true)
				ws.influence_prc += 50
		context["result_text"] = S_224
	if france == null:
		return
	if france.sub_government != GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST and france.sub_government != GameConstants.SubGovernment.NEO_FASCIST and france.sub_government != GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		for c in ws.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.FRANCE:
				c.puppet_of = GameConstants.LegacySlot.NONE
				_leave_alliances(c)
				c.set_tag("亲中", false)
				c.set_tag("亲苏", false)
				c.set_tag("亲美", true)
		return
	if france.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST and _sub_has_econ(1):
		for c in ws.countries:
			if c != null and c.puppet_of == GameConstants.LegacySlot.FRANCE:
				c.set_tag("econ", true)


func _sub(idx: int) -> int:
	var c := ws.get_country_by_legacy_index(idx)
	return c.sub_government if c != null else -1


func _sub_has_econ(idx: int) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag("econ")


func _mod_active(world: WorldState, idx: int) -> bool:
	return world != null and idx >= 0 and idx < world.modifiers.size() \
			and world.modifiers[idx] != null and world.modifiers[idx].is_active


func _set_mod_active(idx: int, active: bool) -> void:
	if idx >= 0 and idx < ws.modifiers.size() and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = active






func _join_our_alliances(c: CountryData) -> void:
	var player := ws.get_country_by_legacy_index(1)
	if player == null:
		return
	if player.has_tag("okb"):
		c.set_tag("okb", true)
	elif player.has_tag("ovd"):
		c.set_tag("ovd", true)
	elif player.has_tag("seato"):
		c.set_tag("seato", true)
	if player.has_tag("econ"):
		c.set_tag("econ", true)
	elif player.has_tag("sev"):
		c.set_tag("sev", true)
	elif player.has_tag("asean"):
		c.set_tag("asean", true)



