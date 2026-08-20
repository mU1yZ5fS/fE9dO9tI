extends "res://数据脚本/event_script_base.gd"

const S_14 := "日耳曼之春"
const S_15 := "随着欧共体的解散，德意志联邦共和国在欧洲的情况愈发不稳。长期的游击队活动，分裂的苦楚和对美帝的仇恨在这一刻达到了极点。而军事管制更是狠狠的将联邦德国引以为傲的民主制踩在脚下。随着我们的禁运，联邦德国不得不采取了配给制和宵禁。人们不敢言而敢怒，只要我们轻轻煽动，西德就会陷入崩溃。"
const S_23 := "年轻的布尔塞维克向前进！"
const S_28 := "共产主义者不愿意听从我们的意见"
const S_32 := "这是意志的胜利！"
const S_37 := "我们不能支持一个法西斯！"
const S_41 := "这是交错阵线的胜利！"
const S_46 := "我们不能支持一个混血怪胎！"
const S_48 := "还没这个必要，再等等……"
const S_53 := "日耳曼之春"
const S_56_0 := "多亏了我们的层层布局，以及对社会主义诸国，尤其是我国的向往。西德的激进学生选择拥抱特里尔的传统。在波恩，工人对于新的劳动定额和强制加班的政策感到十分不满。先是三百多名工厂工人举着横幅，向着政府大楼进发，一路上不断有工人加入他们，其中甚至包括一些警察。等到了目的地时，他们已经拉起了一支上万人的队伍。在这时，他们的要求已经不是简单的要求增加福利和减少工时，转而改成了大量的政治性标语如：“工人们团结起来！”“我们要面包与和平”之类的。工人们大喊着要求军事委员会主席发话，而只有一些基层干愿意作答。政府调集了大量的军人，意图让人群克制下来。在紧张对峙中，一个慌张的新兵扣下了板机，这也让一切彻底失控。\n德国马列主义革命党一直在工人中发展自己的支持者，在流血冲突发生的时候，他们积极鼓动其他地区的工人相应波恩的事态。德意志人民武装力量积极组建了工人赤卫队，打入军队的各级干部也纷纷打开弹药库。在波恩的街头，迪克胡特同志发表了一番讲话，积极的鼓动工人和下层军人把枪口对准真正应该打倒的敌人——也就是他们的领导人。一场小型内战在西德爆发了。不过在我们的特勤和直接干涉下，战争很快就结束了。民主德国也乘机占领了西柏林。\n新政府宣布将和中华人民共和国发展更为巩固和友好的关系，我们的大使在波恩会见了迪克胡特主席。"
const S_56_1 := "同志也接见了德意志人民共和国的特使。"
const S_59 := "美国惊恐的看着自己在西欧的最后一颗棋子被拔除，骄傲的白头鹰再也不能翱翔了。"
const S_71 := "德意志人民共和国"
const S_78 := "愈演愈烈的社会动荡使西德将希望寄予所谓“德意志的古老传统”。各个新纳粹、新法西斯团体和光头党等右翼民族主义组织就此得到自由活动授权。自由德意志运动趁势将更多的极右翼团体纳入麾下，同时把下属的准军事组织和其招揽的一批持民族主义观念的国防军组建成自己的武装力量“风暴冲锋队”，无差别攻击德国境内的左翼、犹太人、波兰劳工和有色人种群体。而下一个目标则是新版魏玛共和国——临时军事委员会决定召集“风暴冲锋队”进京救驾的举动被雷默借题发挥，由此复刻了墨索里尼的“罗马进军”经验。自由德意志运动以“维持秩序”名义趁机接管机场，广播中心和明斯特广场，施压西德临时军事委员会，声称“要么选择雷默，要么选择死亡”。最终雷默如愿以偿入主西德当局，并和民族主义领导人们一同掏空了临时军事委员会。东德也借混乱局势从柏林墙全线出击，假扮成救火员的国家人民军一举拿下了西柏林。\n雷默将自由德意志运动下属各党合并改组为德意志国家工人党，废除孱弱不堪的议会，由此粉碎了西德民主体制。作为德意志国家工人党主席的雷默随即被拥戴为该国“元首”。上述举措立即招致了汉堡地区左翼的反法西斯起义，而这很快便成为了新政府操练马蹄铁的舞台：“波恩是一个几百万人口的大城市，前政府的首都，应杀的共产主义者不止几千人”，“汉堡杀人太少，应在汉堡多杀。”雷默元首在《对汉堡镇压共产主义者工作的指示》，德国国家工人党的第一号法令中如是说道。\n彻底稳定该国秩序后，雷默元首开始预备建立“强大民族工业”：全体国民将强制参与军事训练，社会充斥着“大炮胜过黄油”的宣传。生产军工产品的企业更是能够得到独立于国家统制外的自主经营授权——德国正变为一座军营，其目的不言而喻……"
const S_88 := "\n意识到美苏再也无力主宰欧洲大局，主权欧洲则蒸蒸日上。德国领导人奥托·恩斯特·雷默终于可以彻底露出真面目。这家伙出卖了我们的投资并带领德国选择新秩序，轴心国的“头领”就此在新世界内找到了自己的位置。"
const S_103 := "在西德的局势已经陷入政治与经济动荡的情况下，亨宁·艾希伯格等同志意识到属于民族革命的机会来了。德意志民族解放阵线趁势将更多的极右翼团体与转向的共产党和绿党人士纳入麾下，同时把下属的准军事组织和其招揽的一批持民族主义观念的国防军组建成自己的武装力量“武装人民党卫军”。而此前渗透工人运动与学生运动的成果也在此时派上了用场，工人与学生很快被动员起来对军事当局进行罢工，要求结束军管，甚至是接管企业与工厂，进行民族自治。人民党卫军则被派去配合工人和学生接管企业与占领地方当局，建立民族自治的“民族解放区”。这一场运动很快便升级成全国性的“近内战状态”，接连不断的接管运动和城市游击小组对联邦德国政要和政府机关的“精确击杀”与武力爆破，使得联邦国防军疲于应付，西德进入了近乎无政府的状态。最终，艾希伯格宣布将向“寄生在德意志民族身上的资产阶级毒瘤总司令部”——波恩发起进军，以保卫工农权利。他将人民党卫军分为四路军团，沿途占领各重要设施，而此前在全国各地镇压“民族自治”运动的军警部队难以及时回防首都，使得人民党卫军在只面对些许抵抗后便接管了机场、广播中心和明斯特广场。临时军事委员会在孤立无援的情况下决定放弃无谓流血，并最终选择屈服，其全体成员在得到不会遭遇清算保证的情况下集体“自愿辞职”。最终，民族解放阵线得以如愿以偿入主西德当局。东德也借混乱局势从柏林墙全线出击，假扮成救火员的国家人民军一举拿下了西柏林。\n艾希伯格将德意志民族解放阵线下属各组织合并改组为德意志民族革命工人党，建立起一党专政的制度。随后，亨宁·艾希伯格被选举为该国的“人民元首”，霍斯特·马勒成为副人民元首，迈克尔·科斯当选为人民事业委员会主席，亚历山大·爱泼斯坦成为副主席。尽管存在“收了东德五十万马克”的极权主义共产党人企图发动所谓的“反法西斯起义”，但是在当局拉拢了其中的“爱国者”后，这一企图很快被亲当局的工人武装一举粉碎。\n彻底稳定该国秩序后，艾希伯格人民元首开始推行“具有德意志民族特色的社会主义”，正式开展合作化、国有化和制度化民族自治的革命进程，并不断抨击民主德国是极权主义者、修正主义者和傀儡政权。"
const S_113 := "\n意识到美苏再也无力主宰欧洲大局，民族欧洲则蒸蒸日上。德国领导人亨宁·艾希伯格选择带领德国加入了泛欧革命大家庭的新秩序，轴心国的“头领”就此在新世界内找到了自己的位置。"
const S_134 := "我们会在下一次会议上提出这个问题的……我发誓！"


## 原作 Event485.cs：日耳曼之春（四选项）。
## 触发：无自动触发点——原版由 DiploButtonScript.cs:10928（this_type==138）手动
##   number_event=485 进入；Godot 侧 trigger_conditions=[]。
## 差异：
##  - resultOfEvents[486]/[487] 缺省按原版 int 默认 0 处理；
##  - names1/names2 姓名拼接→ws.leader.name_display；
##  - isFXSEU→fxseu、isNAZIMAO→nazimao、Torg→对华贸易、proprc→亲中、cw→内战中；
##  - JoinAllOurAlliances→_join_our_alliances。

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	if int(world.completed_event_ids.get("event_486", 0)) == 0 \
			and _mod_active(world, 6) and world.ideology < 3:
		_enable(opt[0], S_23)
	else:
		_disable(opt[0], S_28)
	if int(world.completed_event_ids.get("event_487", 0)) == 1:
		_enable(opt[1], S_32)
	else:
		_disable(opt[1], S_37)
	if int(world.completed_event_ids.get("event_487", 0)) == 2:
		_enable(opt[2], S_41)
	else:
		_disable(opt[2], S_46)
	_enable(opt[3], S_48)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c17 := ws.get_country_by_legacy_index(17)
	var c21 := ws.get_country_by_legacy_index(21)
	var c1 := ws.get_country_by_legacy_index(1)
	var c0 := ws.get_country_by_legacy_index(0)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := S_56_0 + _leader_name() + S_56_1
			if c0 != null and not c0.has_tag("nato") and not c0.has_tag("eu"):
				text += S_59
			_add(W.I_BUDGET, -200)
			_add(W.I_ARMY, -200)
			_add(W.I_AGENTS, -200)
			if c17 != null:
				c17.government = GameConstants.Government.SOCIALIST
				c17.sub_government = GameConstants.SubGovernment.MAOIST
				_leave_alliances(c17)
				c17.set_tag("对华贸易", true)
				c17.set_tag("亲中", true)
				_join_our_alliances(c17)
				c17.内战中 = false
				c17.name = S_71
			_add_power(EmpireData.USA, -50)
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 80
			context["result_text"] = text
		1:
			var text := S_78
			_add(W.I_BUDGET, -200)
			_add(W.I_ARMY, -200)
			_add(W.I_AGENTS, -200)
			if c17 != null:
				c17.government = GameConstants.Government.AUTHORITARIAN
				c17.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				_leave_alliances(c17)
				c17.内战中 = false
				if c21 != null and c21.has_tag("fxseu"):
					text += S_88
					c17.set_tag("fxseu", true)
				elif c1 != null and ws.is_authoritarian(c1) and d.econ_system >= 13:
					c17.set_tag("对华贸易", true)
					c17.set_tag("亲中", true)
					_join_our_alliances(c17)
			_add_power(EmpireData.USA, -50)
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 80
			context["result_text"] = text
		2:
			var text := S_103
			_add(W.I_BUDGET, -200)
			_add(W.I_ARMY, -200)
			_add(W.I_AGENTS, -200)
			if c17 != null:
				c17.government = GameConstants.Government.AUTHORITARIAN
				c17.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
				_leave_alliances(c17)
				c17.内战中 = false
				if c21 != null and c21.has_tag("nazimao"):
					text += S_113
					c17.set_tag("nazimao", true)
					if c1 != null and c1.has_tag("nazimao"):
						c17.set_tag("对华贸易", true)
						c17.set_tag("亲中", true)
						_join_our_alliances(c17)
				else:
					c17.set_tag("对华贸易", true)
					c17.set_tag("亲中", true)
					_join_our_alliances(c17)
			_add_power(EmpireData.USA, -50)
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 80
			context["result_text"] = text
		3:
			context["result_text"] = S_134


func _mod_active(world: WorldState, idx: int) -> bool:
	return world != null and idx >= 0 and idx < world.modifiers.size() \
			and world.modifiers[idx] != null and world.modifiers[idx].is_active


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"






func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)




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



