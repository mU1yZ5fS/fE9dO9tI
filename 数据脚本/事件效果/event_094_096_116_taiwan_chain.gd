extends "res://数据脚本/event_script_base.gd"

## 原作事件 94/95/96/116：台湾路线事件链。
## 来源：
##   Event94.cs（又 一 次 天 安 门 事 件 ？ ！）
##   Event95.cs（中 国 共 产 党 的 新 开 始）
##   Event96.cs（改 革 ！ 民 主 ！ 开 放 ！）
##   Event116.cs（两 个 中 国）
##   TimeScript.cs:10789/10796/10803/10950 触发条件
##   events[0].activeSelf UI 互斥在 Godot 由 EventEngine.check_and_fire() 单事件进行中保证，不写入 .tres。
##
## 字段映射说明：
##   data[107] 在本链中语义是「台湾路线标志」（Unity 复用阿富汗战争路线槽位），
##   因此这里直接读写 ws.数值表[107]，不依赖 WorldState.I_AFGHAN_WAR_PATH 的误导性常量名；
##   .tres 触发条件则使用 world_state 已登记的同槽键 "afghan_war_path"。
##   data[64]→W.I_TAIWAN_STATUS；data[4/3/8/1/6/21]→W.I_THOUGHT_FREEDOM/
##   W.I_PEOPLE_SUPPORT/W.I_BUDGET/W.I_PARTY_SUPPORT/W.I_DIPLO/W.I_YEAR。
##   allcountries[38]→ws.get_country_by_legacy_index(38)（台湾）；
##   Gosstroy/SubGosstroy→government/sub_government；
##   proprc→set_tag("亲中")；Torg→set_tag("对华贸易")。
##
## 中文重写：2026-08 批次8，四件套文案已按原版 Event94/95/96/116.cs 逐字重写
## （去空格、||→\n、剥 color；94 描述/结果文本动态拼接自由派领袖姓名）。
##
## 已知取舍：
##   - Unity 的 doctr[] 是显示文案表；Godot 的政体/政策名由 派系界面 按数据索引实时
##     生成，因此 Event95 的 doctr 赋值不移植，只改数据索引。
##   - Unity 的 LeaderAsset/MoneyLevel/ServeRMB 在 Godot 无对应字段，跳过并注释。
##   - Event96 的 data[17]++ 是 Unity 原码 bug（值未写回数组），Godot 按原行为保持 no-op。
##   - Event116 的 ILoveSuckCocks 是刷新中国地图 parts 的辅助方法，这里按主要分支近似移植。

const POLITICAL_TRANSITION = preload("res://数据脚本/事件效果/event_024_026_political_transition.gd")
# ============================================================================
# 原版逐字中文文案（Event94/95/96/116.cs 去空格、||→\n、剥 color）
# ============================================================================
const TXT94_TITLE := "又一次天安门事件？！"
const TXT94_DESC_1 := "对各个涉及人民生活领域的大规模改革政策、日益猖獗的腐败、中国共产党与商界的勾结以及权贵与商人之间秘密的腐败联系，导致资产阶级自由化思想在相当一部分的中国知识分子和青年中广泛传播，他们要求更激进的改革，反对“共产主义传染病”。因此他们组织了一场由持不同政见的天体物理学家方励之（在西方被称为“中国的萨哈罗夫”）所领导的“退党”运动，运动的主张是宣布中国共产党为“犯罪组织”，并剥夺党的一切权力、要求国家的自由化和西方化、打击腐败和消灭官僚的特权。利用了政府内部的混乱，十万“退党”支持者聚集在北京天安门广场举行群众活动。他们要求“自由”、“民主”、“打击腐败官僚”和“打倒腐败的党的领导”，而其他包括工人在内的对我们的改革不满的人，每天都在加入他们的行列。中国共产党党内的自由派领导人"
const TXT94_DESC_3 := "，倾向于对抗议者妥协让步，希望通过抗议活动执掌党政大权。国内局势极不稳定，但现在仍有机会进行干预——在动乱蔓延到其他城市之前..."
const TXT94_OPT_0 := "这是一场反革命动乱，叛徒会为此负责的！给我拨通总参谋部的电话…"
const TXT94_OPT_1 := "让武警封锁广场，尝试劝说抗议者散去"
const TXT94_OPT_2 := "退休。在这个困难时期，让党决定谁应该领导国家"
const TXT94_OPT_3 := "满足抗议者的要求"
const TXT94_R0_A := "在中共中央特别全会上，事件被称为“受美国和台湾特务机关指使的反革命叛乱”，随后对运动进行镇压的投票以大多数通过。根据中国人民解放军总参谋长杨得志将军的命令，部队在北京得到了坦克和装甲运兵车的增援，但当他们向广场推进时被路障所阻拦以及遭遇到了手持燃烧弹的歹徒的顽强抵抗。在装甲部队的支援下，路障被摧毁，之后解放军摧毁了抗议者的大本营，并对天安门广场进行了清理，对工人和学生宿舍的清理工作持续了几天。也因此，局势得到了控制。“退党”运动被宣布为非法组织，"
const TXT94_R0_B := "和他的支持者被免除其职位，开除出中国共产党，改革开放的反对者开始被逮捕，方励之逃到美国。西方国家指责我们的政权为“血腥的暴政”，苏联及其盟国保持沉默。有组织的抗议运动被镇压，不满者转入地下。"
const TXT94_R1_OK := "由于害怕抢劫事件发生，北京市市长下令引入人民武装警察的装甲部队，用警戒线封锁天安门广场，将抗议者从邻近的街道赶走（同时遭受了“莫洛托夫鸡尾酒”燃烧瓶袭击，造成严重损失）此后，主席同志亲自对示威者讲话，劝说他们散去。其中很大一部分人离开了广场，其余的人被警察用催泪瓦斯和空包弹驱散。首都的秩序恢复了，但骚乱蔓延到上海、宁波和其他几个城市……"
const TXT94_R1_FAIL_A := "由于害怕抢劫事件发生，北京市市长下令引入人民武装警察的装甲部队，封锁了天安门广场，将抗议者赶出了广场及邻近的街道（同时遭到了“莫洛托夫鸡尾酒”的袭击，造成重大损失）。人们用嘘声和辱骂迎接主席的到来，他仓皇而逃。在中共中央特别全会上，中央决定向示威者做出让步，并要求党的领导层辞职。"
const TXT94_R1_FAIL_B := "同志成为新的总书记，他宣布了深化改革和国家大规模民主化的政策。对此感到满意的大多数抗议者都散去了，其余的人被武警赶走了。中国正在等待变革…"
const TXT94_R2_A := "在中共中央特别全会上，爆发了激烈的争论——保守派要求使用武力镇压（尤其是王震对此直言不讳），自由派想要做出让步，改革派则举棋不定。最终，自由派胜利了——中共领导层集体辞职。"
const TXT94_R2_B := "同志成为新的总书记，他宣布了深化改革和国家大规模民主化的政策。对此感到满意的大多数抗议者都散去了，其余的人被武警赶走了。中国正在等待变革…"
const TXT94_R3 := "同志成为新的总书记，他宣布了进一步深化改革和大规模民主化的政策。然而，“退党”运动的领导者认为这是中国领导层软弱无能的证明，并在全国各地组织了大规模示威，最终导致政府下台，中国进入了过渡时期。共产党失去了权力，其命运已经掌握在了他人手里……"
const TXT95_TITLE := "中国共产党的新开始"
const TXT95_DESC_1 := "因此，北京的形势得到了控制，国家的权力移交给了以"
const TXT95_DESC_3 := "为首的中国共产党内的自由派。议事日程上的问题是大规模深化“改革开放”政策以及向西式民主和自由市场的过渡。然而，我们现在不得不考虑“退党”运动要求在改革进程中考虑到使中国社会和执政党去共产主义化的必要性。原则上，现在中国共产党很难称之为“共产党”，但现在我们被要求完全抛弃马克思列宁主义。那么？…"
const TXT95_OPT_0 := "我们拒绝马克思主义-毛泽东主义-邓小平主义，效仿日本共产党，改为支持欧洲共产主义"
const TXT95_OPT_1 := "按照陈独秀的规范回归具有中国特色的社会民主主义"
const TXT95_OPT_2 := "接受伟大的孙中山遗赠的中国左翼民族主义"
const TXT95_OPT_3 := "为什么我们必须接受一些街头恶霸的要求？"
const TXT95_R0 := "在中共中央特别全会上，以多数票决定放弃马克思列宁主义、毛泽东主义和邓小平主义，转而支持以法国、意大利、西班牙和日本共产党为代表的现代欧洲共产主义。对党的纲领性文件作了相应的修改。这引起了大多数党内保守派的某种不满，但总的来说，党采取了一种新的思想，认识到了变革的必要性。"
const TXT95_R1 := "在中共中央特别全会上，经过长期的争论，最终决定回到陈独秀、张国焘的训诫上来，承认党的社会民主主义性质。对党的纲领性文件作了相应的修改。这导致了部分保守派党阀的强烈不满，中国共产党存在一定的分裂危险。时间会告诉你是否做了正确的事…"
const TXT95_R2 := "在中共中央特别全会上，建议回到中国革命运动的始源——孙中山和他第二版的“三民主义”（反对封建主义和资本主义、国家和社会制度民主化、改善工人生活和限制垄断资本）的一群党员占了上风。对党的纲领性文件作了相应的修改。中国共产党开始与民革和左翼民族主义团体合流，虽然这在人民中很受欢迎，但也引起了党员的强烈不满。"
const TXT95_R3 := "在中共中央特别全会上，支持维护马克思主义、毛泽东主义和邓小平主义的人士取得了胜利。“退党”运动愈演愈烈，对中国共产党的攻击也愈发猛烈，党已经失去了人民群众的支持，失去了政权的根基。在中国似乎没有它的立足之地了……"
const TXT96_TITLE := "改革！民主！开放！"
const TXT96_DESC := "现在，党组织上问题结束了，我们需要履行我们对人民关于按照西方模式对国家民主化的诺言。人民要求停止对宗教和教士施压，基于西方国家模式扩大民权和自由，更重要的是，解散“爱国统一战线”，进行人大内和各地方的自由选举。如果我们不能避免选举的到来，只要我们满足了人民其他的要求，就能使他们得到我们所需要的“自由选举”。"
const TXT96_OPT_0 := "我们正在筹备全国人大的自由选举，所以我们要尽可能限制其他政党，同时还必须满足人民的要求"
const TXT96_OPT_1 := "选举并没有让资产阶级“自由”那么可怕。不用理它"
const TXT96_OPT_2 := "选举并没有让宗教自由那么可怕。不用管它"
const TXT96_OPT_3 := "如果我们想让人们爱我们，我们必须满足它的所有要求"
const TXT96_R0 := "爱国统一战线及其统战机构已被解散，各地正在建立大选机关，但我们的选举法将会有效的为那些想要谋朝篡位的宵小之徒提供足够的阻碍——选举法对执政方有着天然优势，我们已经禁止了一切可能威胁国体的政党，剩下的合法政党也有着一大堆程序要走才能和我们同台竞技。不过过去的严格媒体审核和无情镇压则被一种新的公开性和自由所冲淡。"
const TXT96_R1 := "爱国统一战线及其统战机构已被解散，各地正在建立大选机关，我们将起草全世界最自由，最公正的《选举法》！但另一方面，这种大选临近的狂热的情绪使得我们可以不必进行大规模自由化，尽管我们不得不放松了对宗教的压力。"
const TXT96_R2 := "爱国统一战线及其统战机构已被解散，各地正在建立大选机关，我们将起草全世界最自由，最公正的《选举法》！但另一方面，这种大选临近的狂热的情绪和公共生活的自由化有助于我们延续我们的宗教政策——的确，虽然对宗教组织的管理名义上简化了，但是各类宗教机构仍然被地方政府和国安部牢牢地盯着。"
const TXT96_R3 := "一切放缓经济重组和民主化的提案都被我们的领导人狠狠地反驳了回去。爱国统一战线和统战组织已经被解散，各地正在建立大选机关，我们将起草全世界最自由，最公正的《选举法》！同时公共生活的逐步自由化也使得大众欢庆鼓舞，但是这能持续多久呢？"
const TXT116_TITLE := "两个中国"
const TXT116_DESC := "如你所知，解放战争胜利后，国民党败逃到台湾岛，西方社会长期认为他们是中国的合法政府。由于美国在台湾的基地和舰队，我们无法解放它，就像国民党无法反攻大陆一样，随着时间的推移，越来越多的国家承认中华人民共和国为中国唯一合法政府，尽管中华人民共和国和台湾政府都没有正式拒绝对全中国的主张。当然，我们之间的关系一直很糟糕，但是最近自由化和中国共产党结束了对权力的垄断之后，我们之间的关系明显升温。现在双方高层都在谈论期待已久的国家统一的可能性。但是，在这种情况下，台湾会旗帜鲜明地要求自治，我们需要在他们的根据地地位上与美国达成一致，而台湾人民成功地发展了他们的文化认同，这将如何影响这个国家已经不稳定的局势，目前还不知道。因此，有人建议我们与台湾相互承认对方为独立国家，建立睦邻友好关系。既然在这种情况下，美国的基地将继续存在，西方公司将免于官僚主义的大惊小怪，那就很好地暗示美国，年轻的民主需要钱……"
const TXT116_OPT_0 := "保持原样"
const TXT116_OPT_1 := "期待已久的统一时刻到了！"
const TXT116_OPT_1_DISABLED := "他们不准备同意这样的协议"
const TXT116_OPT_2 := "承认彼此，结束敌意！"
const TXT116_R0 := "一切顺其自然。"
const TXT116_R1 := "今天，我国领袖率领代表团对台北进行了历史性的访问，在此期间，经过闭门谈判后，决定成立一个委员会，制定台湾和中国大陆逐步统一的原则。当然，外国投资者将保留他们的所有权利，而台湾省将获得广泛的长期经济和政治自治权。所有与美军有关的事情都将由已经签订的条约来决定，然后由联合政府决定美军是否继续留在台湾。虽然所有这些都还只是纸上谈兵，需要在广泛考虑共同利益的基础上制定出来，台湾回归中国的时间还没有确定，但我们的人民热情地接受了这个消息，边境控制被大大削弱了。所有这一切的结果是，自由主义思想更容易从台湾渗透到我们中间，美国人担心他们对台湾的影响被削弱了，但我们的人民非常高兴。"
const TXT116_R2 := "今天，我国领袖率领代表团对台北进行了历史性的访问，谈判双方决定相互承认对方。从现在起，中华人民共和国和台湾共和国（根据该协定的条款，中华民国改名为台湾共和国）将作为两个独立的国家存在。它也结束了多年来关于领土和合法政府的争端，使我们的关系达到了一个新的水平。美国对我们的行动表示欢迎，并提供了大量的财政援助以支持我们的政策。然而，许多人明显对两个中国的永久分裂感到不满。"

# ============================================================================
# prepare — 显示前动态文案（原版 TextOfEvents / VariantsOfEvents）
# ============================================================================

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	match event_def.event_id:
		"event_094":
			_prepare_94(event_def, world)
		"event_095":
			_prepare_95(event_def, world)
		"event_096":
			_prepare_96(event_def)
		"event_116":
			_prepare_116(event_def)


func _prepare_94(event_def: EventDef, world: WorldState) -> void:
	event_def.title = TXT94_TITLE
	var leader := _liberal_leader_name(world)
	event_def.description = TXT94_DESC_1 + leader + TXT94_DESC_3
	if event_def.options.size() < 4:
		return
	event_def.options[0].text = TXT94_OPT_0
	event_def.options[1].text = TXT94_OPT_1
	event_def.options[2].text = TXT94_OPT_2
	event_def.options[3].text = TXT94_OPT_3


func _prepare_95(event_def: EventDef, world: WorldState) -> void:
	event_def.title = TXT95_TITLE
	var leader := _current_leader_name(world)
	event_def.description = TXT95_DESC_1 + leader + TXT95_DESC_3
	if event_def.options.size() < 4:
		return
	event_def.options[0].text = TXT95_OPT_0
	event_def.options[1].text = TXT95_OPT_1
	event_def.options[2].text = TXT95_OPT_2
	event_def.options[3].text = TXT95_OPT_3


func _prepare_96(event_def: EventDef) -> void:
	event_def.title = TXT96_TITLE
	event_def.description = TXT96_DESC
	if event_def.options.size() < 4:
		return
	event_def.options[0].text = TXT96_OPT_0
	event_def.options[1].text = TXT96_OPT_1
	event_def.options[2].text = TXT96_OPT_2
	event_def.options[3].text = TXT96_OPT_3


func _prepare_116(event_def: EventDef) -> void:
	event_def.title = TXT116_TITLE
	event_def.description = TXT116_DESC
	if event_def.options.size() < 3:
		return
	event_def.options[0].text = TXT116_OPT_0
	event_def.options[1].text = TXT116_OPT_1
	event_def.options[1].disabled_text = TXT116_OPT_1_DISABLED
	event_def.options[2].text = TXT116_OPT_2


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"event_094":
			_event_94(option_index, context)
		"event_095":
			_event_95(option_index, context)
		"event_096":
			_event_96(option_index, context)
		"event_116":
			_event_116(option_index, context)
	_sync_empire_mirrors()


# ============================================================================
# Event94 — 又一次天安门事件？！
# ============================================================================

func _event_94(option_index: int, context: Dictionary) -> void:
	# TextOfEvents 的自由派领袖兜底（Event94.cs:28-38）：faction_leader[4]==200
	# 时选 power 最高的 traits[0]==3 政客。Godot 用 faction.leader_index=-1/-2 表示空缺，
	# _liberal_leader_index() 在无效时执行同一兜底。
	match option_index:
		0:
			_event_94_result_0(context)
		1:
			_event_94_result_1(context)
		2:
			_event_94_result_2(context)
		3:
			_event_94_result_3(context)


func _event_94_result_0(context: Dictionary) -> void:
	# Event94.cs:64-78
	var leader := _liberal_leader_name()
	context["result_text"] = TXT94_R0_A + leader + TXT94_R0_B
	_add_empire_relation(EmpireData.USA, -150)
	_add_data({W.I_MANPOWER: -150, W.I_PEOPLE_SUPPORT: -100,
		W.I_THOUGHT_FREEDOM: -250, W.I_DIPLO: 80})


func _event_94_result_1(context: Dictionary) -> void:
	# Event94.cs:80-185
	if d[W.I_PEOPLE_SUPPORT] >= 600 and d[W.I_THOUGHT_FREEDOM] < 500:
		# 成功劝说（Event94.cs:82-88）
		context["result_text"] = TXT94_R1_OK
		_add_data({W.I_THOUGHT_FREEDOM: 250, W.I_PEOPLE_SUPPORT: -100,
			W.I_MANPOWER: -250})
	else:
		# 劝说失败，自由派接权并开启台湾路线（Event94.cs:89-184）
		var leader := _liberal_leader_name()
		context["result_text"] = TXT94_R1_FAIL_A + leader + TXT94_R1_FAIL_B
		_add_data({W.I_PEOPLE_SUPPORT: 90, W.I_DIPLO: -50,
			W.I_MANPOWER: -350, W.I_THOUGHT_FREEDOM: 100})
		# data[107] 在本链中为台湾路线标志（双用途槽位，勿依赖 I_AFGHAN_WAR_PATH 常量名）
		ws.数值表[107] = 1
		_swap_leader_with_liberal()
		# LeaderAsset=0 / MoneyLevel=0 / ServeRMB=false 在 Godot 无对应字段，跳过。
		_set_modifier_active(65, false)


func _event_94_result_2(context: Dictionary) -> void:
	# Event94.cs:186-280
	var leader := _liberal_leader_name()
	context["result_text"] = TXT94_R2_A + leader + TXT94_R2_B
	_add_data({W.I_PEOPLE_SUPPORT: 90, W.I_DIPLO: -50,
		W.I_MANPOWER: -350, W.I_THOUGHT_FREEDOM: 100})
	ws.数值表[107] = 1
	# LeaderAsset=0 / MoneyLevel=0 / ServeRMB=false 在 Godot 无对应字段，跳过。
	_swap_leader_with_liberal()


func _event_94_result_3(context: Dictionary) -> void:
	# Event94.cs:281-351
	context["result_text"] = _liberal_leader_name() + TXT94_R3
	d[W.I_THOUGHT_FREEDOM] = 1000
	_swap_leader_with_liberal()
	d[W.I_PARTY_SUPPORT] = 0
	d[W.I_PEOPLE_SUPPORT] = 0
	# LeaderAsset=0 / MoneyLevel=0 / ServeRMB=false 在 Godot 无对应字段，跳过。
	# 原版 data[35]=1 → load_scene_after_click → SceneManager.LoadScene("Ending")
	# 项目语义映射：结局 1（人民的选择）。见 event_001/event_005 同类迁移。
	d[W.I_ENDING_ROUTE] = 1
	GameManager.queue_ending_after_event(1)


## 当前国家领袖显示名（Event95 描述插姓名时兜底；94 成功后领袖已换为自由派）。
func _current_leader_name(p_ws: WorldState = null) -> String:
	var world := p_ws if p_ws != null else ws
	if world != null and world.leader != null and world.leader.name_display != "":
		return world.leader.name_display
	return "自由派领袖"


## 自由派领袖显示名（Event94 描述/结果文本插姓名）。
func _liberal_leader_name(p_ws: WorldState = null) -> String:
	var world := p_ws if p_ws != null else ws
	var idx := _liberal_leader_index(world)
	if idx >= 0 and world != null and world.politicians.size() > idx \
			and world.politicians[idx] != null and world.politicians[idx].name_display != "":
		return world.politicians[idx].name_display
	return "自由派领袖"


## Event94.cs:28-38 的自由派领袖兜底：faction_leader[4]==200 时选 power 最高的 traits[0]==3 政客。
func _liberal_leader_index(p_ws: WorldState = null) -> int:
	var world := p_ws if p_ws != null else ws
	if world == null:
		return -1
	if world.factions.size() > FactionData.LIBERAL and world.factions[FactionData.LIBERAL] != null:
		var current := world.factions[FactionData.LIBERAL].leader_index
		if current >= 0 and current < world.politicians.size() and world.politicians[current] != null:
			return current
	var best := -1
	var best_power := -1000000000
	for i in world.politicians.size():
		var p := world.politicians[i]
		if p != null and p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL and p.power > best_power:
			best = i
			best_power = p.power
	return best


func _swap_leader_with_liberal() -> void:
	var liberal_idx := _liberal_leader_index()
	if liberal_idx < 0:
		return
	var transition = POLITICAL_TRANSITION.new()
	# transition 是新建实例，必须先用基类 _bind_world 绑定世界状态。
	if not transition._bind_world():
		return
	transition._swap_leader_with_politician(liberal_idx, FactionData.LIBERAL)
	PoliticianSystem.sync_in_power_flags(ws)


# ============================================================================
# Event95 — 中国共产党的新开始
# ============================================================================

func _event_95(option_index: int, context: Dictionary) -> void:
	# Event95.cs:51 先停用 modifies[6]，随后 :52 立即判断 active——恒为 false，
	# 所以 :53-65 的 if 分支是死代码，永远走 :66-79 的 else。doctr 是显示文案表，
	# Godot 的政体/政策名由 派系界面 按数据索引实时生成，故这里只改数据索引。
	_set_modifier_active(6, false)
	_set_modifier_active(3, false)
	match option_index:
		0:
			_event_95_result_0(context)
		1:
			_event_95_result_1(context)
		2:
			_event_95_result_2(context)
		3:
			_event_95_result_3(context)


func _event_95_result_0(context: Dictionary) -> void:
	# Event95.cs:82-114（欧洲共产主义）
	context["result_text"] = TXT95_R0
	_add_data({W.I_PARTY_SUPPORT: -150, W.I_PEOPLE_SUPPORT: 50,
		W.I_MANPOWER: -50, W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: -30})
	d[W.I_IDEOLOGY] = 3
	d[W.I_ECON_SYSTEM] = 13
	d[W.I_PARTY_SYSTEM] = 8
	d[W.I_PRESS_POLICY] = 18
	if d[W.I_DIPLO] > 699:
		d[W.I_DIPLO] = 699
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		china.government = GameConstants.Government.REFORMIST
		china.sub_government = _chinese_sub_government_after_95_option0(china)
	_change_loyalty_by_personality({0: -400, 3: 300})


func _event_95_result_1(context: Dictionary) -> void:
	# Event95.cs:115-180（陈独秀式社会民主主义）
	context["result_text"] = TXT95_R1
	_add_data({W.I_PARTY_SUPPORT: -300, W.I_PEOPLE_SUPPORT: 80,
		W.I_MANPOWER: -50, W.I_THOUGHT_FREEDOM: 50, W.I_DIPLO: -50})
	# Event95.cs:123-130 经济体制钳制：>=13 → 13；<12 → 12；12 保持。
	if d[W.I_ECON_SYSTEM] >= 13:
		d[W.I_ECON_SYSTEM] = 13
	if d[W.I_ECON_SYSTEM] < 12:
		d[W.I_ECON_SYSTEM] = 12
	if d[W.I_DIPLO] < 500:
		d[W.I_DIPLO] = 700
	if d[W.I_IDEOLOGY] < 4:
		# Event95.cs:135-159
		d[W.I_PARTY_SYSTEM] = 9
		if d[W.I_PRESS_POLICY] < 19:
			d[W.I_PRESS_POLICY] = 19
		if d[W.I_RELIGION] < 26:
			d[W.I_RELIGION] = 26
		elif d[W.I_RELIGION] > 27:
			d[W.I_RELIGION] = 27
		if d[W.I_TERRITORY] < 23:
			d[W.I_TERRITORY] += 1
		if d[W.I_MIL_DOCTRINE] < 33:
			d[W.I_MIL_DOCTRINE] += 1
		d[W.I_IDEOLOGY] = 4
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		china.government = GameConstants.Government.LIBERAL
		china.sub_government = _chinese_sub_government_after_95_option1(china)
	_change_loyalty_by_personality({0: -500, 1: -300, 3: 500})


func _event_95_result_2(context: Dictionary) -> void:
	# Event95.cs:181-210（孙中山式左翼民族主义）
	context["result_text"] = TXT95_R2
	_add_data({W.I_PARTY_SUPPORT: -250, W.I_PEOPLE_SUPPORT: 50,
		W.I_THOUGHT_FREEDOM: -80, W.I_DIPLO: -10})
	_change_loyalty_by_personality({0: -400, 1: -100, 2: 100, 3: 400})


func _event_95_result_3(context: Dictionary) -> void:
	# Event95.cs:211-216（拒绝退党要求）
	context["result_text"] = TXT95_R3
	_add_data({W.I_THOUGHT_FREEDOM: 500, W.I_PEOPLE_SUPPORT: -500})


## 在 Event95 option0 设定数据后调用 ChineseSubGosstroy（Gosstroy==2）。
## 移植 GameState.cs:4934-5070 中与该状态相关的分支；其余移植说明分支在 Godot 中恒不命中。
func _chinese_sub_government_after_95_option0(china: CountryData) -> int:
	# Unity 此时 data[14]=3, data[16]=13, data[6]<=699, data[15]=8, data[17]=18。
	if d[W.I_IDEOLOGY] >= 2 and d[W.I_ECON_SYSTEM] >= 13 and d[W.I_DIPLO] <= 700 \
			and d[W.I_PARTY_SYSTEM] >= 8 and d[W.I_PRESS_POLICY] >= 18 \
			and not china.has_tag("ovd"):
		return 14  # 欧洲共产主义
	if d[W.I_IDEOLOGY] <= 3 and d[W.I_ECON_SYSTEM] >= 12 and d[W.I_ECON_SYSTEM] <= 13 \
			and d[W.I_DIPLO] >= 300 and d[W.I_TERRITORY] > 21 and d[W.I_WAR_SUPPORT] >= 700:
		return 11  # 铁托主义
	if d[W.I_IDEOLOGY] <= 3 and d[W.I_ECON_SYSTEM] <= 14 and d[W.I_DIPLO] >= 500 \
			and d[W.I_ECON_SYSTEM] > 11 and d[W.I_WAR_SUPPORT] >= 400:
		return 8  # 左倾保守主义
	if d[W.I_IDEOLOGY] <= 3 and d[W.I_ECON_SYSTEM] <= 13 and d[W.I_PRESS_POLICY] > 17:
		return 3  # 民主社会主义
	return 15  # 政治实用主义


## 在 Event95 option1 设定数据后调用 ChineseSubGosstroy（Gosstroy==3）。
## 移植 GameState.cs:4934-5070 中 Gosstroy==3 分支。
func _chinese_sub_government_after_95_option1(_china: CountryData) -> int:
	if d[W.I_ECON_SYSTEM] <= 13 and d[W.I_DIPLO] >= 500:
		return 4  # 社会民主主义
	if (d[W.I_PARTY_SYSTEM] <= 8 and d[W.I_PRESS_POLICY] <= 18) or d[W.I_WAR_SUPPORT] >= 700:
		return 12  # 新自由主义
	if d[W.I_ECON_SYSTEM] > 13 and d[W.I_DIPLO] < 700:
		return 6  # 自由主义
	return 5  # 温和主义


# ============================================================================
# Event96 — 改革！民主！开放！
# ============================================================================

func _event_96(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_event_96_result_0(context)
		1:
			_event_96_result_1(context)
		2:
			_event_96_result_2(context)
		3:
			_event_96_result_3(context)


func _event_96_result_0(context: Dictionary) -> void:
	# Event96.cs:44-61
	context["result_text"] = TXT96_R0
	d[W.I_PARTY_SYSTEM] = 8
	d[W.I_RELIGION] = 27
	_add_data({W.I_MANPOWER: -80})
	# Event96.cs:50-57 data[17]++ 是 Unity 原码 bug（算出的新值未写回数组），按原行为保持 no-op。
	_add_data({W.I_DIPLO: -10, W.I_PEOPLE_SUPPORT: 30, W.I_THOUGHT_FREEDOM: 80})


func _event_96_result_1(context: Dictionary) -> void:
	# Event96.cs:62-71
	context["result_text"] = TXT96_R1
	d[W.I_PARTY_SYSTEM] = 9
	_add_data({W.I_PEOPLE_SUPPORT: 50, W.I_MANPOWER: -50})
	d[W.I_RELIGION] = 27
	_add_data({W.I_THOUGHT_FREEDOM: 80, W.I_DIPLO: -20})


func _event_96_result_2(context: Dictionary) -> void:
	# Event96.cs:72-88
	context["result_text"] = TXT96_R2
	d[W.I_PARTY_SYSTEM] = 9
	_add_data({W.I_PEOPLE_SUPPORT: 50, W.I_MANPOWER: -70})
	# Event96.cs:78-85 data[17]++ 同样是未写回 no-op，见 result_0 注释。
	_add_data({W.I_THOUGHT_FREEDOM: 50, W.I_DIPLO: -20})


func _event_96_result_3(context: Dictionary) -> void:
	# Event96.cs:89-106
	context["result_text"] = TXT96_R3
	d[W.I_PARTY_SYSTEM] = 9
	_add_data({W.I_PEOPLE_SUPPORT: 80, W.I_MANPOWER: -120})
	# Event96.cs:95-102 data[17]++ 同样是未写回 no-op，见 result_0 注释。
	_add_data({W.I_THOUGHT_FREEDOM: 120, W.I_DIPLO: -40})
	d[W.I_RELIGION] = 27


# ============================================================================
# Event116 — 两个中国
# ============================================================================

func _event_116(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			# Event116.cs:51-54（无效果）
			context["result_text"] = TXT116_R0
		1:
			_event_116_result_1(context)
		2:
			_event_116_result_2(context)


func _event_116_result_1(context: Dictionary) -> void:
	# Event116.cs:55-66（统一路线）
	context["result_text"] = TXT116_R1
	_add_empire_relation(EmpireData.USA, -70)
	_add_data({W.I_THOUGHT_FREEDOM: 80, W.I_PEOPLE_SUPPORT: 120})
	var taiwan := ws.get_country_by_legacy_index(38)
	if taiwan != null:
		taiwan.set_tag("亲中", true)  # 原版 proprc = true
		taiwan.government = GameConstants.Government.LIBERAL         # 原版 Gosstroy = 3
		taiwan.sub_government = GameConstants.SubGovernment.MODERATE     # 原版 SubGosstroy = 5
	d[W.I_TAIWAN_STATUS] = 2
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		_china_map_parts(china)  # 原版 allcountries[1].ILoveSuckCocks() 近似


func _event_116_result_2(context: Dictionary) -> void:
	# Event116.cs:67-79（两个中国路线）
	context["result_text"] = TXT116_R2
	_add_data({W.I_BUDGET: 70})
	_add_empire_relation(EmpireData.USA, 100)
	_add_data({W.I_PEOPLE_SUPPORT: -80, W.I_THOUGHT_FREEDOM: 50,
		W.I_PARTY_SUPPORT: -100})
	var taiwan := ws.get_country_by_legacy_index(38)
	if taiwan != null:
		taiwan.set_tag("对华贸易", true)  # 原版 Torg = true
		taiwan.government = GameConstants.Government.LIBERAL            # 原版 Gosstroy = 3
		taiwan.sub_government = GameConstants.SubGovernment.MODERATE        # 原版 SubGosstroy = 5
	d[W.I_TAIWAN_STATUS] = 1


## Event116.cs:65 allcountries[1].ILoveSuckCocks()。
## Country.cs:286-420 依据 IndOpp/GKChP/藏南/台湾地位等刷新中国地图 parts。
## Godot 移植说明 IndOpp/is_gkchp 字段，这里用 global_flags 同名键近似；其余按原版分支。
func _china_map_parts(china: CountryData) -> void:
	if china.parts.size() < 16:
		china.parts.resize(16)
	var d62 := d[W.I_ARUNACHAL_STATUS] if d.size() > W.I_ARUNACHAL_STATUS else 0
	var d64 := d[W.I_TAIWAN_STATUS] if d.size() > W.I_TAIWAN_STATUS else 0
	var d130 := d[130] if d.size() > 130 else 0
	var dec7 := false
	if ws.decisions != null and ws.decisions.completed.size() > 7:
		dec7 = ws.decisions.completed[7]
	var c19 := ws.get_country_by_legacy_index(19)
	var c33 := ws.get_country_by_legacy_index(33)

	if ws.get_flag("IndOpp"):
		_clear_china_parts(china, true)
		china.parts[15] = true
	elif c19 != null and c19.puppet_of == GameConstants.LegacySlot.CHINA and c19.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST \
			and c33 != null and c33.puppet_of == GameConstants.LegacySlot.CHINA and c33.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_clear_china_parts(china, true)
		china.parts[14] = true
	elif c33 != null and c33.puppet_of == GameConstants.LegacySlot.CHINA and c33.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_clear_china_parts(china, true)
		china.parts[13] = true
	elif c19 != null and c19.puppet_of == GameConstants.LegacySlot.CHINA and c19.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_clear_china_parts(china, true)
		china.parts[12] = true
	elif ws.get_flag("is_gkchp"):
		_clear_china_parts(china, true)
		china.parts[11] = true
	elif d130 == 1 and d62 >= 2 and (d64 == 2 or dec7):
		_clear_china_parts(china, false)
		china.parts[0] = true
	elif d130 == 1 and (d62 == 2 or d62 == 3):
		_clear_china_parts(china, false)
		china.parts[2] = true
	elif d62 >= 2 and (d64 == 2 or dec7):
		_clear_china_parts(china, false)
		china.parts[6] = true
	elif d130 == 1 and (d64 == 2 or dec7):
		_clear_china_parts(china, false)
		china.parts[3] = true
	elif d130 == 1:
		_clear_china_parts(china, false)
		china.parts[4] = true
	elif d64 == 2 or dec7:
		_clear_china_parts(china, false)
		china.parts[5] = true
	elif d62 >= 2:
		_clear_china_parts(china, false)
		china.parts[1] = true
	else:
		_clear_china_parts(china, false)
		china.parts[10] = true


func _clear_china_parts(china: CountryData, clear_all: bool) -> void:
	for i in china.parts.size():
		if clear_all or i < 7 or i > 9:
			china.parts[i] = false


# ============================================================================
# 通用辅助
# ============================================================================

func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < d.size():
			d[index] += int(changes[raw_index])


func _set_modifier_active(modifier_index: int, active: bool) -> void:
	if modifier_index >= 0 and modifier_index < ws.modifiers.size() \
			and ws.modifiers[modifier_index] != null:
		ws.modifiers[modifier_index].is_active = active


func _change_loyalty_by_personality(changes: Dictionary) -> void:
	for politician in ws.politicians:
		if politician != null and changes.has(politician.trait_personality):
			politician.loyalty += int(changes[politician.trait_personality])


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index < 0 or empire_index >= ws.empires.size() or ws.empires[empire_index] == null:
		return
	ws.empires[empire_index].relations = clampi(
		ws.empires[empire_index].relations + delta, 0, 1000)


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		d[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		d[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		d[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		d[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power
