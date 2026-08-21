extends "res://数据脚本/event_script_base.gd"

## 原作 Event560.cs：我们想要大饼与自由（摩洛哥面包骚乱，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:407-409 ——
##   c54.SubGosstroy==7 && (1984.1.22 或 1984.2 或 1985+)。
## 差异：描述由 prepare 动态拼领袖姓名；level_of_dev→level_of_development；spec→special。

const TXT_DESC_A := "80年代是摩洛哥的困难岁月：债台高筑和出口导向的经济进一步加深了问题。于债务螺旋式的上升，进一步破坏了经济形势，外债从1972年的9亿美元上升到1983年的120亿美元。漫长的治安战争，支不敷出的福利项目，广为人知的腐败网络与连续多年的干旱进一步摧毁了这个国家的经济。1975年至1981间，摩洛哥决定进入国际货币组织，以寻求借款来缓解长期的金融赤字。计划无非三板斧：休克疗法，多征税和削减补贴。额外增加的税款有旅行费（针对北部想要前往修达于梅利利亚和西班牙的人征收的额外税款），黄油的最低价格上涨了67%，食糖的价格增加了18%。甚至包括学业税（学士学位需要额外支付50纳迪尔，硕士及以上则是100），并取消了大饼补贴。一石激起千层浪，而摩洛哥人民早就受够了。17日，纳多尔的铁矿工人和农民抗议新增的税款，学生也以罢课回应新的学历税。尽管安全部队已经部署完毕，且双方仍然保持相对的克制，但未来会发生什么事，就不好说了。\n"
const TXT_DESC_B := "同志，我们总要做点什么，对吧？"
const TXT_OPT0_DIS := "我们没有这个实力"
const TXT_OPT1_DIS := "社会主义和君主主义？你在开什么玩笑！"
const TXT_R0_INTRO := "在摩洛哥的王朝陷入危机的时候，我们没有忘记早日投下的棋子："
const TXT_R0_REV := "我们向摩洛哥社会主义革命党输送了武器。在我们的帮助下，摩洛哥社会主义革命党在各地发动武装反对王室政权的暴乱，并借着小册子，摄像机和播音喇叭向全摩洛哥的城市直播军队惨无人道屠杀平民的画面。在晚上，军队的直升机开始在首府和各大城市的上空盘旋。随后在拉巴特，安全部队向抗议者开枪，据信使用了达姆弹。二十人在交火中死亡。愤怒的群众包围了王宫和多个军营，“铁拳”突击队打响了反抗的第一枪。和平请愿的运动迅速演变成了低烈度的内战，得益于左派联盟扎根于军队之中，大量的军人，甚至包括王室卫队纷纷倒戈相向。“铁拳”突击队的成员兵分两路，一路前往拉巴特王宫处死王室，另一路则前往摩洛哥电视台，以便于公布革命的信息并保证摩洛哥社会主义革命党对新摩洛哥的控制。人们如往常一样打开电台收听新闻，而电台已被攻占“这里是拉巴特”播音员清了清嗓子，“摩洛哥人民共和国的广播电台”。与此同时，行刑队已经处死了阿拉维王室的全部成员，除了正在海外度假的穆罕默德六世（哈桑二世的长子），摩洛哥王朝已然绝嗣。随后本·赛义德呼吁人民走上街头支持革命，他需要群众的支持从而反抗君主制余孽。在倒戈的卫士打开王宫大门后，愤怒的群众冲进了王宫，在路上他们遇到了伪装成宫女试图出逃的王国前首相卡里姆·拉姆拉尼，在一番迅速的批斗大会后，前首相被绑住双腿、挂在自己的豪华跑车后拖拽致死，临死前的他仍然高呼着真主，众先知甚至是天使和魔鬼的名字，然而于事无补。旧政权和内阁大臣们纷纷被逮捕。
一个以摩洛哥社会主义革命党为执政党的一党制共和国被建立了起来。摩洛哥古老的君主制迎来了终结，他们迎来了红色的未来。新政府迅速开展了“人人有田种，人人有饭吃”运动，并大兴水利工程和土地再分配项目；大量的外资矿矿山也被完全国有化，要么暴力征收，要么摩洛哥人民矿业公司占股至少55%以上。新生的共和国也邀请我们和阿尔巴尼亚同志在建设社会主义上提供同志间的帮助。"
const TXT_R0_REV_WEST := "
新政府正式放弃了对西撒哈拉的宣称，西撒人阵的步战车进入了首府阿尤恩的市中心。胜利的旗帜飘扬在这座古老的城市上空，这天也被定为撒哈拉阿拉伯民主共和国的解放日。工人，游击战士和农民推着花车，举着“自由，独立，社会主义是我们的目标”之类的标语牌走过市中心，这片古老的土地焕发着前所未有的生命力。"
const TXT_R0_REV_WEST_PRO := "
新政府正式放弃了对西撒哈拉的宣称，西撒人阵的步战车攻入了首府阿尤恩的市中心。胜利的旗帜飘扬在这座古老的城市上空，这天也被定为撒哈拉阿拉伯民主共和国的解放日。工人，游击战士和农民推着画有马克思，列宁和毛泽东的画像的花车。举着“共产主义带来解放”之类的标语牌走过市中心，这片古老的土地焕发着前所未有的生命力。
国际观察家认为，西撒人阵背后的中华人民共和国又一次在国际交锋中为自己带来了战友和同志。"
const TXT_R0_LIB := "晚上，军队的直升机开始在首府和各大城市的上空盘旋。随后在拉巴特，安全部队向抗议者开枪，据信使用了达姆弹。二十人在交火中死亡。愤怒的群众包围了王宫和多个军营，王国政府一边试图保持稳定，一边寻求谈判或者武力镇压的手段。
凌晨4点30分时，部队开始从四面八方逼近王宫前的广场，随后部队在示威群众周围10米处重新部署。先是尝试说服事先知情的学生领袖接受他与部队的协议，在大约4时32分内政部长透过学生的广播表示他先行和部队达成谈判，然而许多第一次知道这次会谈的学生则气愤地指责他过于胆怯。而将以口头表决的方式决定示威学生之后的集体行动。但尽管“坚守”的声音比起“撤离”还要来得更加响亮。
奥斯曼看到了机会，借此机会，他把自己包装成民众利益的代言人，强硬的反君主制民主派。并支持工人的罢工和抗议运动，甚至在大众前说出了：“同学们，我来晚了”之类的明面偏袒抗议者的话。在摩洛哥众议院的特别会议上，各个党派就请求哈桑二世流亡海外以平稳下野的议案得到了高票通过。这位君主在登上飞机前最后一次饱含热泪的亲吻了摩洛哥的土地，并带走了一块磷酸盐矿石和一捧沙子。在记者面前，奥斯曼总理正式宣布哈桑二世被废，其子穆罕默德六世将继任王位，而全国自由人士联盟也更名为摩洛哥人民自由党，成为了新的摩洛哥共和国的执政党。新政府依旧坚持过去的立场，似乎什么变了而什么都没变……
新政府依然宣称对西撒哈拉的主权，在政权未稳之时便开始了针对西撒人阵的的军事行动。"
const TXT_R1 := "中华人民共和国驻拉巴特的大使向哈桑二世送上了我们的信件，在信中，我们提到了西班牙改革的成功：“西班牙的卡洛斯王室既能执政，又能缓解矛盾，何乐而不为呢？中华人民共和国愿意承担摩洛哥的债务，以换取摩洛哥的政治改革。”
晚上，军队的直升机开始在首府和各大城市的上空盘旋。随后在拉巴特，安全部队向抗议者开枪，据信使用了达姆弹。二十人在交火中死亡。愤怒的群众包围了王宫和多个军营，王国政府一边试图保持稳定，一边寻求谈判或者武力镇压的手段。
凌晨4点30分时，部队开始从四面八方逼近王宫前的广场，随后部队在示威群众周围10米处重新部署。先是尝试说服事先知情的学生领袖接受他与部队的协议，在大约4时32分内政部长透过学生的广播表示他先行和部队达成谈判，然而许多第一次知道这次会谈的学生则气愤地指责他过于胆怯。而将以口头表决的方式决定示威学生之后的集体行动。但尽管“坚守”的声音比起“撤离”还要来得更加响亮，不过大约在4时40分时，穿着迷彩服的士兵冲向广场上的帐篷并且破坏学生的广播设施；而其他部队则殴打数十名在大本营旁的学生，并且扣押或者破坏他们的相机和录音设备。随后士兵开始强制驱散在王宫附近的群众。
在电视台的讲话中，哈桑二世把抗议者比做疯羊和野蛮的柏柏尔人，他指控“马克思列宁主义者”和邪恶的伊斯兰原教旨主义者煽动了这场内乱。但他不得不作出一些让步用于挽回民心。他决定借鉴西班牙经验，撤换了首相之后，他任命了来自摩洛哥人民力量社会主义同盟的阿卜杜勒-拉赫曼·优素菲出任首相。他并不热衷于结束君主制。新政府开始了更多的工团主义改革，并采用了国家资本主义和“工人自治”的南斯拉夫先进经验。哈桑二世也适当的下放了一些权利。"
const TXT_R1_WEST := "出乎意料的是，新政府认为西撒哈拉应该成为摩洛哥人民联邦王国的一个组成部分。优素菲首相许诺绝对的自治权，甚至可以同步加入联合国。再三考量后，西撒人阵决定放下武器，并修改了党章中要求获得完全独立的内容。新的党政不仅删除了共产主义，甚至接纳了资本主义和多党合作制。许多同情西撒人阵的组织纷纷谴责其背弃了过去的理想。"
const TXT_R1_TAIL := "摩洛哥的未来到底会是什么样呢？"
const TXT_R2 := "凭借着美国驻军的压力，哈桑二世的安全部队用暴力驱散了抗议者。\n晚上，军队的直升机开始在首府和各大城市的上空盘旋。随后在拉巴特，安全部队向抗议者开枪，据信使用了达姆弹。二十人在交火中死亡。愤怒的群众包围了王宫和多个军营，王国政府一边试图保持稳定，一边寻求谈判或者武力镇压的手段。\n凌晨4点30分时，部队开始从四面八方逼近王宫前的广场，随后部队在示威群众周围10米处重新部署。先是尝试说服事先知情的学生领袖接受他与部队的协议，在大约4时32分内政部长透过学生的广播表示他先行和部队达成谈判，然而许多第一次知道这次会谈的学生则气愤地指责他过于胆怯。而将以口头表决的方式决定示威学生之后的集体行动。但尽管“坚守”的声音比起“撤离”还要来得更加响亮，不过大约在4时40分时，穿着迷彩服的士兵冲向广场上的帐篷并且破坏学生的广播设施；而其他部队则殴打数十名在大本营旁的学生，并且扣押或者破坏他们的相机和录音设备。随后士兵开始强制驱散在王宫附近的群众。\n在电视台的讲话中，哈桑二世把抗议者比做疯羊和野蛮的柏柏尔人，他指控“马克思列宁主义者”和邪恶的伊斯兰原教旨主义者煽动了这场内乱。但他不得不作出一些让步用于挽回民心。他决定开放党禁，并开除了首相和内务部长。摩洛哥真的进入了新时代吗？"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var n := _leader_name()
	event_def.description = TXT_DESC_A + n + TXT_DESC_B
	if event_def.options.size() < 3:
		return
	var opt := event_def.options
	var r463 := int(ws.completed_event_ids.get("event_463", 0))
	var c40 := world.get_country_by_legacy_index(40)
	var c86 := world.get_country_by_legacy_index(86)
	if r463 == 2 and ws.completed_event_ids.has("event_463") 			and (c40 == null or not c40.has_tag("亲美") or (c86 != null and c86.has_tag("对华贸易"))):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	var line := d.political_line
	if line > 1 and line < 4 and c86 != null and c86.sub_government == GameConstants.SubGovernment.TITOIST:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c18 := ws.get_country_by_legacy_index(18)
	var c54 := ws.get_country_by_legacy_index(54)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := TXT_R0_INTRO
			if c54 != null and c54.level_of_development == 1:
				text += TXT_R0_REV
				if c18 != null and not c18.内战中:
					text += TXT_R0_REV_WEST
					if c54 != null:
						c54.parts.resize(maxi(c54.parts.size(), 1))
						c54.parts[0] = false
					if c18 != null:
						c18.special = 0
						c18.government = GameConstants.Government.REFORMIST
						c18.sub_government = GameConstants.SubGovernment.PRAGMATIST
						c18.set_tag("对华贸易", true)
					ws.influence_prc += 5
				else:
					text += TXT_R0_REV_WEST_PRO
					if c54 != null:
						c54.parts.resize(maxi(c54.parts.size(), 1))
						c54.parts[0] = false
					if c18 != null:
						c18.special = 0
						c18.government = GameConstants.Government.SOCIALIST
						c18.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
						c18.set_tag("对华贸易", true)
						c18.set_tag("亲中", true)
					ws.influence_prc += 20
				if c18 != null:
					game.set_map_region_owner([54, 55, 56, 57], c18.gwcode)
				if c54 != null:
					c54.government = GameConstants.Government.SOCIALIST
					c54.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
					_leave_alliances(c54)
					c54.set_tag("亲中", true)
					c54.name = "摩洛哥人民共和国"
					c54.chinese_name = "摩洛哥人民共和国"
					c54.set_tag("对华贸易", true)
				_add_relation(EmpireData.USSR, 50)
				_add_relation(EmpireData.USA, -100)
				_add(W.I_BUDGET, -80)
				_add(W.I_AGENTS, -100)
				_add(W.I_ARMY, -100)
			else:
				text += TXT_R0_LIB
				if c54 != null:
					c54.government = GameConstants.Government.LIBERAL
					c54.sub_government = GameConstants.SubGovernment.LIBERAL
					_leave_alliances(c54)
					c54.set_tag("亲中", true)
					c54.name = "摩洛哥王国"
					c54.chinese_name = "摩洛哥王国"
					c54.set_tag("对华贸易", true)
				_add_relation(EmpireData.USSR, -50)
				_add_relation(EmpireData.USA, -150)
				_add(W.I_BUDGET, -80)
				_add(W.I_AGENTS, -100)
				_add(W.I_ARMY, -100)
			context["result_text"] = text
		1:
			var text := TXT_R1
			if c18 != null and c54 != null and ((not c18.内战中 and (c54.parts.size() == 0 or not c54.parts[0])) or (c54.parts.size() > 0 and c54.parts[0])):
				text += TXT_R1_WEST
				if c54 != null:
					c54.parts.resize(maxi(c54.parts.size(), 1))
					c54.parts[0] = true
					game.set_map_region_owner([54, 55, 56, 57], c54.gwcode)
				if c18 != null:
					_leave_alliances(c18)
			text += TXT_R1_TAIL
			_add(W.I_BUDGET, -100)
			if c54 != null:
				c54.government = GameConstants.Government.REFORMIST
				c54.sub_government = GameConstants.SubGovernment.TITOIST
				_leave_alliances(c54)
				c54.set_tag("亲中", true)
				c54.name = "摩洛哥人民联邦王国"
				c54.chinese_name = "摩洛哥人民联邦王国"
				c54.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_DIPLO, 50)
			context["result_text"] = text
		2:
			context["result_text"] = TXT_R2


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
