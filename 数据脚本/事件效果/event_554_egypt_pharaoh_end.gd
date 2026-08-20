extends "res://数据脚本/event_script_base.gd"

## 原作 Event554.cs：埃及法老的终结（萨达特遇刺，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1554-1556 ——
##   event_done[37] && IsAuthoritarianism(30) && c30.Vyshi && (1981.10.6 或 1982+)。
## 差异：isSEV/isASEAN→has_tag；spec→special；Vyshi→亲美。

const TXT_OPT0_DIS := "我们不想要这样的国家"
const TXT_OPT1_DIS := "我们没法和起义者取得联络"
const TXT_OPT2_DIS := "我们没必要为了萨达特这么做"
const TXT_R0 := "在我们的干预下，穆斯林兄弟会、埃及伊斯兰教大会和埃及伊斯兰圣战组织等伊斯兰团体组成了革命联盟，上埃及的阿斯尤特省的起义，得益于萨达特的对伊斯兰力量的扶持，他们得以迅速通过组织网络将起义扩散到全国。通过民族主义和伊斯兰主义宣传，革命联盟动员城市平民组成民兵，在伊斯兰派军官带领军队倒戈并发起政变的情况下，民族民主党政权很快在围攻中倒台，革命联盟组织起基于伊斯兰神权统治的政府……"
const TXT_R1_A := "很快，埃及人民民主革命阵线得以组织起民兵，利用萨达特去世后的混乱，发起大规模的起义。革命阵线组织的民兵冲入位于开罗的政府机构，强行解除了萨达特的亲信们的职务，在我们的特工的帮助下，动员起来的力量迅速将各地政治机构和重要政要逮捕。埃及军队也在我们的干预下陷入了混乱，无法被当局动员起来，在此前渗透中被发展起来的左翼军人掌控。埃及人民民主革命阵线很快夺取了权力，阵线被改组为埃及人民革命党，阿拉伯埃及共和国也被改为埃及人民共和国。在新政权的领导下，埃及开始进行社会主义革命。"
const TXT_R1_B := "很快，埃及民族自由联盟得以动员民众抗议，组织起民兵，利用萨达特去世后的混乱，发起大规模的起义。联盟组织的民兵冲入位于开罗的政府机构，强行解除了萨达特的亲信们的职务，在我们的特工的帮助下，动员起来的力量迅速将各地政治机构和重要政要逮捕。埃及军队也在联盟的渗透和我们的干预下陷入了混乱，意识到对抗毫无意义的军人和文官组织政变，在谈判后，埃及宣布组织真正民主的选举。"
const TXT_R2 := "我们的外交部谴责了伊斯兰极端主义者对萨达特总统的刺杀，并派遣代表参加了萨达特的葬礼，随后，同埃及领导人达成了一些新的合作协定。\n在暗杀的同时，伊斯兰主义者在上埃及的阿斯尤特省组织了一场起义，叛军控制了安全部门总部一天，并又拖延了政府军一天。6名袭击者和68名警察和士兵在战斗中丧生。直到来自开罗的伞兵抵达后，空军出动两架喷气式飞机恐吓武装分子，政府才恢复了对该地的控制。\n伊斯兰世界政府普遍对这次暗杀表示热烈欢迎，他们将萨达特视为叛徒。叙利亚官报的标题是“今日埃及告别终极叛徒”，而伊朗则以伊斯兰布利的名字命名了德黑兰的一条街道。来自世界各地的政要出席了萨达特的葬礼，人数创下历史新高，其中，三位美国前总统——杰拉尔德·福特、吉米·卡特和理查德·尼克松同时出席。苏丹总统加法尔·尼迈里是唯一出席葬礼的阿拉伯国家元首。在阿拉伯联盟的24个国家中，只有3个国家——阿曼、索马里和苏丹——派出了代表。以色列总理梅纳赫姆·贝京将萨达特视为私人朋友，坚持参加葬礼。\n萨达特最初由人民议会议长苏菲·阿布·塔勒布继任，他就任代理总统并立即宣布进入紧急状态。八天后，即1981年10月14日，萨达特的副总统胡斯尼·穆巴拉克宣誓就任埃及新总统，开启了埃及在紧急状态法下长期统治的时代。穆巴拉克采取了更为多边的外交方式，寻求与阿拉伯国家的恢复关系。\n伊斯兰布利和其他刺客受到审判、定罪并被判处死刑。他们于1982年4月15日被处决，两名军人被行刑队处决，三名平民被绞死。"
const TXT_R3 := "在暗杀的同时，伊斯兰主义者在上埃及的阿斯尤特省组织了一场起义，叛军控制了安全部门总部一天，并又拖延了政府军一天。6名袭击者和68名警察和士兵在战斗中丧生。直到来自开罗的伞兵抵达后，空军出动两架喷气式飞机恐吓武装分子，政府才恢复了对该地的控制。\n伊斯兰世界政府普遍对这次暗杀表示热烈欢迎，他们将萨达特视为叛徒。叙利亚官报的标题是“今日埃及告别终极叛徒”，而伊朗则以伊斯兰布利的名字命名了德黑兰的一条街道。来自世界各地的政要出席了萨达特的葬礼，人数创下历史新高，其中，三位美国前总统——杰拉尔德·福特、吉米·卡特和理查德·尼克松同时出席。苏丹总统加法尔·尼迈里是唯一出席葬礼的阿拉伯国家元首。在阿拉伯联盟的24个国家中，只有3个国家——阿曼、索马里和苏丹——派出了代表。以色列总理梅纳赫姆·贝京将萨达特视为私人朋友，坚持参加葬礼。\n萨达特最初由人民议会议长苏菲·阿布·塔勒布继任，他就任代理总统并立即宣布进入紧急状态。八天后，即1981年10月14日，萨达特的副总统胡斯尼·穆巴拉克宣誓就任埃及新总统，开启了埃及在紧急状态法下长期统治的时代。穆巴拉克采取了更为多边的外交方式，寻求与阿拉伯国家的恢复关系。\n伊斯兰布利和其他刺客受到审判、定罪并被判处死刑。他们于1982年4月15日被处决，两名军人被行刑队处决，三名平民被绞死。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var c8 := world.get_country_by_legacy_index(8)
	var r37 := int(ws.completed_event_ids.get("egyptian_unrest", 0))
	if ws.influence_prc >= 500 and d[W.I_WAR_SUPPORT] >= 600 and not ws.modifiers[3].is_active 			and c8 != null and c8.sub_government != 13:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if (d[W.I_POLITICAL_LINE] < 2 and r37 == 2) or (d[W.I_POLITICAL_LINE] > 2 and r37 == 3):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if d[W.I_POLITICAL_LINE] > 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c1 := ws.get_country_by_legacy_index(1)
	var c30 := ws.get_country_by_legacy_index(30)
	var c51 := ws.get_country_by_legacy_index(51)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if c30 != null:
				c30.sub_government = 9
				c30.government = 0
				_leave_alliances(c30)
				c30.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 150)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			context["result_text"] = TXT_R0
		1:
			var r37 := int(ws.completed_event_ids.get("egyptian_unrest", 0))
			if r37 == 2:
				_add(W.I_BUDGET, -150)
				_add(W.I_AGENTS, -150)
				_add(W.I_ARMY, -150)
				if c30 != null:
					c30.sub_government = 1
					c30.government = 1
					_leave_alliances(c30)
					c30.set_tag("亲中", true)
					c30.set_tag("对华贸易", true)
					if c1 != null and c1.has_tag("sev"):
						_leave_alliances(c30)
						c30.set_tag("sev", true)
						c30.set_tag("亲苏", true)
					if c1 != null and c1.has_tag("sev"):
						_add_relation(EmpireData.USSR, 50)
				_add(W.I_PARTY_SUPPORT, 100)
				_add(W.I_PEOPLE_SUPPORT, 150)
				ws.influence_prc += 25
				_add_relation(EmpireData.USSR, 150)
				_add_relation(EmpireData.USA, -250)
				_add(W.I_DIPLO, 50)
				context["result_text"] = TXT_R1_A
			else:
				_add(W.I_BUDGET, -150)
				_add(W.I_AGENTS, -150)
				_add(W.I_ARMY, -150)
				if c30 != null:
					c30.government = 3
					c30.sub_government = 6
					c30.set_tag("对华贸易", true)
					_leave_alliances(c30)
					c30.set_tag("亲中", true)
					if c1 != null and c1.has_tag("asean"):
						_leave_alliances(c30)
						if c51 != null and c51.内战中:
							c30.set_tag("asean", true)
							c30.set_tag("seato", true)
						else:
							c30.set_tag("sento", true)
						_add_relation(EmpireData.USA, 50)
						c30.set_tag("亲美", true)
				_add(W.I_PARTY_SUPPORT, 100)
				_add(W.I_PEOPLE_SUPPORT, 150)
				ws.influence_prc += 25
				_add_relation(EmpireData.USSR, -250)
				_add_relation(EmpireData.USA, 150)
				_add(W.I_DIPLO, -50)
				context["result_text"] = TXT_R1_B
		2:
			if c30 != null:
				c30.sub_government = 7
				c30.government = 0
				_leave_alliances(c30)
				c30.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_DIPLO, 50)
			context["result_text"] = TXT_R2
		3:
			if c30 != null:
				c30.sub_government = 7
				c30.government = 0
				_leave_alliances(c30)
				c30.set_tag("对华贸易", true)
			context["result_text"] = TXT_R3
