extends "res://数据脚本/event_script_base.gd"

## 原作 Event576.cs：我们将会获得胜利，并且我们赢得过胜利（澳大利亚风暴，三选项）。
## 触发：Event575.cs:111 —— 结果1 非欧社联分支 number_event = 576；
##   Godot 由 event_575 的 execute 调 EventEngine.enqueue_chain(["event_576"])，本事件无自动触发。
## 差异：
##  - 描述按 resultOfEvents[573] 拼接（缺省按原版 int 默认 0）；
##  - Gosstroy → government；Vyshi → 亲美；Torg → 对华贸易；puppetOf → puppet_of；
##  - LeaveAlliances 用基类 _leave_alliances。


const TXT_DESC_BASE := "澳大利亚正遭遇堪比1923年墨尔本警察罢工的动荡：学生已在大学内搭好帐篷准备持久战，各地工会也开始组织全国总罢工，人们打着“不是我的共和国！”的旗号纷纷走上街头，斗争局势愈演愈烈。"
const TXT_DESC_R2 := "|澳大利亚的一些地方甚至出现类似“红军旅”的城市游击队与针对公安部门的恐怖行动。新任总理约·比耶克·彼德森试图平息混乱的举动的举动只会给局势火上浇油：他在电视上将旧澳大利亚宪法撕成碎片，并手持猎枪宣布自己维持秩序的决心被广泛视为“独裁主义第一步”。新打着“矿工”和“农民”旗号的民兵与各地警察已得到额外授权，并开入城区压制群众运动。"
const TXT_DESC_R1 := "|我们的老朋友也借助广泛的抗议运动和城市游击队的威势建立起了工会网络，并自发夺取了悉尼与墨尔本的市政厅。启动了对资产阶级生产资料的社会化。"
const TXT_DESC_TAIL := "|主席同志，时不我待。"

const TXT_OPT0_DIS_NO := "我们没有干涉澳洲的跳板……"
const TXT_OPT0_DIS_RIOT := "骚乱不足以成事"
const TXT_OPT1_DIS := "怎能同法西斯主义狼狈为奸？！"

const TXT_R0_INTRO := "我们的临门一脚给了彼德森政府致命一击：由于澳洲社会主义者愈加倾向于从亚红色政权获取支持，而包括美国在内的盟友均处于“天高皇帝远”的状态。他很快便辞去总理一职并流亡美国，军队也因领导层的混乱而只得接受最近发出的命令：待在自己的兵营里以避免“无望的血腥冲突”。澳大利亚社会主义者的胜利已成定局："
const TXT_R0_TROT := "最终，“革命马克思主义”元老汤姆·O·林肯得以执掌澳洲大权，并以澳洲托派组织和抗议期间的革命阵线为蓝本合并各派社会主义组织，形成了大洋洲版本的德国统一社会党。基于澳大利亚“工会强，党却弱而杂”的客观特点，试图在大洋洲扮演二号列宁的林肯很快便碰上了自己的“工人反对派”……"
const TXT_R0_HILL := "最终，我们的老友E·F·“泰德·”希尔得以执掌澳洲大权，并以澳共（马列）和抗议期间的革命阵线为蓝本合并各派社会主义组织，形成了大洋洲版本的德国统一社会党。基于澳大利亚“工会强，党却弱而杂”的客观特点，希尔试图在澳大利亚工联主义与马列毛主义间寻求调和，开辟民族特色社会主义道路。"
const TXT_R0_CLANCY := "最终，亲苏的社会党领导人兼建筑工人产业工会领袖帕特·克兰西得以执掌澳洲大权，并以社会党和抗议期间的革命阵线为蓝本合并各派社会主义组织，形成了大洋洲版本的德国统一社会党。基于澳大利亚“工会强，党却弱而杂”的客观特点，他开始将工会按功能界别纳入国家管理体制，并越加向“社会主义兄弟们”看齐。"
const TXT_R0_TAIL := "剩余的反动派则躲藏在沙漠与森林中，靠偷袭交通要道和荒漠小镇的方式表达对红色政权的抗议。不过对新政府而言，这群“白色凯利”不过是注定碰壁的小小苍蝇而已。现在是享受南半球阳光的时候了！"
const TXT_R1 := "我们立即联系了约·比耶克·彼德森总理，并表示中国将在“非意识形态外交”的基础上帮助该国维持秩序。得到东方大国援助的彼德森很快便有了底气，并重新运用他在昆士兰州长时期“一手补贴一手大棒”的策略，从而平息了全国暴动。大多数工会领袖对《产业协调法》表示满意，残存的反对派则被国家安全局、保守工会与“农民雇佣兵”围堵消灭。目前的澳大利亚秩序尽然，并开始通过有趣的“经济政策”形成稳固支持群体：政府公务员开始在大街小巷分发“信用券”，以鼓励消费主义的方式基本拴牢了该国各大城市。"
const TXT_R2_A := "持续数月的全国混乱最终迫使澳大利亚军方入局干涉，彼德森就此从军队处取得许可并颁布了军法戒严。坦克开入堪培拉联邦区的街道及该国主要城市。澳大利亚全国近乎卷入了迷你内战：被示威者用作据点的悉尼海港大桥被海军开火炸毁，墨尔本大学的百年建筑也因变为街垒而难逃喷火器淫威。纯粹的暴力自然为其带来了胜利，而报复政策只会愈演愈烈。政府对军警宪特赋予额外授权，要求准军事组织和士兵竭尽所能搜捕“外国间谍”和社会主义者。出于对付境外势力的需要，澳大利亚又对巴布亚新几内亚发出了“联合行动”邀请，并将其“自愿”拉入“反共阵营”：原住民协会被严厉封杀，原住民活动家则和白人社会主义者一道被被隔离在似曾相识的“营地”里。澳大利亚封锁边界与遣送间谍的行为只会让人想到白澳政策的卷土重来。红色的土地上，流着红色的血……"
const TXT_R2_B := "\n出于防范共产主义渗透的务实需要，澳大利亚政府宣布将承担起“协同防御南太平洋友邦的责任”。事实上入侵了瓦努阿图和其他南太平洋群岛。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var r573 := int(world.completed_event_ids.get("event_573", 0))
	var c50 := world.get_country_by_legacy_index(50)
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 0
	var desc := TXT_DESC_BASE
	if r573 == 2:
		desc += TXT_DESC_R2
	elif r573 == 1:
		desc += TXT_DESC_R1
	desc += TXT_DESC_TAIL
	event_def.description = desc
	var opt := event_def.options
	if line < 2 and (r573 == 1 or r573 == 2) and c50 != null and c50.government == GameConstants.Government.SOCIALIST:
		_enable(opt[0], event_def.options[0].text)
	elif c50 == null or c50.government != GameConstants.Government.SOCIALIST:
		_disable(opt[0], TXT_OPT0_DIS_NO)
	else:
		_disable(opt[0], TXT_OPT0_DIS_RIOT)
	if line > 1 and r573 == 0:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c135 := ws.get_country_by_legacy_index(135)
	var c134 := ws.get_country_by_legacy_index(134)
	var c159 := ws.get_country_by_legacy_index(159)
	var c92 := ws.get_country_by_legacy_index(92)
	var r573 := int(ws.completed_event_ids.get("event_573", 0))
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
			_add(W.I_ARMY, -200)
			var text := TXT_R0_INTRO
			if c92 != null and c92.sub_government == GameConstants.SubGovernment.TROTSKYIST:
				text += TXT_R0_TROT
				if c135 != null:
					c135.government = GameConstants.Government.SOCIALIST
					c135.sub_government = GameConstants.SubGovernment.TROTSKYIST
					_leave_alliances(c135)
					c135.set_tag("对华贸易", true)
				if c134 != null:
					c134.puppet_of = -1
			elif r573 == 2:
				text += TXT_R0_HILL
				if c135 != null:
					c135.government = GameConstants.Government.SOCIALIST
					c135.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					_leave_alliances(c135)
					c135.set_tag("对华贸易", true)
					c135.set_tag("亲中", true)
				if c134 != null:
					c134.puppet_of = -1
				ws.influence_prc += 50
			elif r573 == 1:
				text += TXT_R0_CLANCY
				if c135 != null:
					c135.government = GameConstants.Government.SOCIALIST
					c135.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
					_leave_alliances(c135)
					c135.set_tag("对华贸易", true)
					c135.set_tag("亲苏", true)
				if c134 != null:
					c134.puppet_of = -1
				_add_power(EmpireData.USSR, 100)
			text += TXT_R0_TAIL
			_add_relation(EmpireData.USA, -300)
			_add_power(EmpireData.USA, -100)
			context["result_text"] = text
		1:
			_add(W.I_BUDGET, -180)
			_add(W.I_AGENTS, -150)
			if c135 != null:
				c135.government = GameConstants.Government.REFORMIST
				c135.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
				_leave_alliances(c135)
				c135.set_tag("对华贸易", true)
				c135.set_tag("亲中", true)
			context["result_text"] = TXT_R1
		2:
			var text := TXT_R2_A
			if c135 != null:
				c135.government = GameConstants.Government.AUTHORITARIAN
				c135.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(c135)
				c135.set_tag("亲美", true)
			text += TXT_R2_B
			if c159 != null:
				c159.government = GameConstants.Government.AUTHORITARIAN
				c159.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(c159)
				c159.puppet_of = 135
			context["result_text"] = text
