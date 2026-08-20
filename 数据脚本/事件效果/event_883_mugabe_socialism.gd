extends "res://数据脚本/event_script_base.gd"

## 原作 Event883.cs：潮水如此涨涨落落（穆加贝社会主义建设，两选项）。
## 触发：全目录 grep 仅见 DiploButtonScript.cs:10806 外交界面 selected_country==127
##   手动 number_event=883，原版无自动条件（外交按钮手动触发），故 trigger_conditions=[]。
## 差异：
##  - 结果0 插入领袖姓名用 name_display（names1/names2 组合）；
##  - JoinAllOurAlliances(true)→_join_our_alliances；soc_stab→social_stability；
##  - 原版 event_done[883]=false（允许再触发）在 Godot 中 _mark_done 于 execute 后写回，
##    无法以同样方式复位，仅注释保留差异。

const TXT_R0_PRE := "在近日，我们邀请罗伯特·穆加贝同志来到我国，展开为期一周的国事访问。在访问的路上，穆加贝主席参观了革命军事博物馆，山西交城县，韶山毛主席故居等诸多带有“红色基因”特色的建筑。他拜访了毛泽东主席的纪念馆和纪念碑，亲自送上了插有嘉兰的花环，他还参观了1969年珍宝岛战争纪念碑。在人民大会堂的招待宴席上，穆加贝总理高度赞扬了"
const TXT_R0_POST := "同志的社会主义建设和个人崇拜。再喝了几杯后，不知道是失态还是刻意的，他说了这样一番话：“这确实是个人崇拜，但谁让英雄本来如此呢！”\n在回国后，他开展了一系列激进的改革。ZANU-PF，ZAPU，津巴布韦民主党均被整合为津巴布韦统一社会主义运动，联合非洲民族委员会和罗得西亚阵线党作为花瓶，成为了这个国家民主的最后一块遮羞布。穆加贝和他的亲戚战友们身居高位，他年仅13岁的儿子，仅仅是对篮球有兴趣，就被任命为津巴布韦奥委会主席。面对敌人，他也毫不手软。他开始了代号细雨行动的政治迫害。针对的不是白人而是另一个土著族群，马塔贝莱人，这次清洗人口损失超过两万，致使ZANU—PF内部最大反对派被连根拔起，同时也有已经丧失权力的前津巴布韦非洲人民革命军军官。并把一切嫁祸于阵线党，伊安·史密斯被秘密处决。他在事实上扫清了政治敌人，这是一切都是由他手下最精锐的，由我国装备武装起来的国民军第五旅所造成的。而我们为他在政治上的越发冷酷感到了一丝担忧。\n同时，他也展开了一项名为“快车道”的疯狂计划。这个计划和朝鲜的“千里马运动”，我国曾经的“大跃进”颇有几分相似。副总统约瑟夫·姆西卡在宣布开展“快车道”土地改革的时候，表示将立即将获取4558个总面积880万公顷的农场用于重新安置，几乎占了全国耕地的三分之一。许多大地主要么束手就擒，要么就做好被第五旅武装征收的准备。大量地主不顾阻拦的逃往邻国（主要是南非），这也表明了穆加贝总统正式向白人开战，意图用民族主义的大旗来巩固自己的统治。他甚至雇佣了无业青年人来进行暴力的打砸抢，用来进行“一场触及人民灵魂的革命”。但穆加贝的民族斗士形象无比拔高，他的理论也正式被列为毛泽东之后的又一个开创性理论“毛泽东-穆加贝主义”。\n有些时候，革命必须沐浴鲜血。"
const TXT_R1 := "说笑了，主席同志，他不过是津巴布韦又一个普通的不能再普通的黑人领袖罢了。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var zimbabwe := ws.get_country_by_legacy_index(127)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var leader_name := _leader_name()
			context["result_text"] = TXT_R0_PRE + leader_name + TXT_R0_POST
			if zimbabwe != null:
				zimbabwe.government = 0
				zimbabwe.sub_government = 19
				zimbabwe.social_stability = 1000
				_join_our_alliances(zimbabwe)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			ws.influence_prc += 50
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
		1:
			context["result_text"] = TXT_R1
			# 原版 event_done[883]=false；本系统 fire_only_once=true 且完成后写标记，
			# 此分支无法真正复位，保留注释。


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


## JoinAllOurAlliances(true) 核心联盟跟随逻辑（同 Event713 约定）。
func _join_our_alliances(c: CountryData) -> void:
	if c == null:
		return
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




