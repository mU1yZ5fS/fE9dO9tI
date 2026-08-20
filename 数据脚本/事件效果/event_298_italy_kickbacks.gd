## 原作 Event298.cs：回扣之国（意大利净手行动，单选项）。
## 触发：全目录搜索无 this_num_event = 298 / Reset(298)；链外 REST 段，原版无自动条件。
## 差异：VasilyisGay→ws.get_flag("VasilyisGay")；load_scene_after_click+number_event=299
##  改为 EventEngine.enqueue_chain(["event_299"])；spec→special；inflCh→influence_china。
extends "res://数据脚本/event_script_base.gd"

const TXT_R0_BASE := "正如我们所料，对于基耶萨的调查切实成为了推倒多米诺骨牌的第一步：意识到自己已无可能在当地企业、司法部门、乃至境外势力联合编织的天罗地网内脱身，亦无可能在短时间内轻易洗清或销毁贪污巨款：基耶萨只得举手投降，并在对自身犯罪事实供认不讳的同时积极寻求将功补过机会。而这更是以大量揭发材料与深层人脉网络的形式直接牵扯出第一共和国各主要政党的地下交易黑线——相关证据表明，除意大利共产党外的所有议会主要政党皆采用了接受企业资助，并向前者提供政治便利的方式以扩充自身势力。作为对竞选资金的回报，主要由天主教民主党、意大利社会党与意大利民主社会党等中间派政治力量共同构成的建制派不仅在政治议程中采取毫不掩饰的亲资方政策，更是热心同秘密社团，跨国企业，乃至黑手党犯罪集团等打成一团，自觉扮演起前者的利益说客。也就在20世纪70年代期间：主持公共设施建设的民社党政治家便在石油价格危机期间深度参与了碳氢化合物与其制成品的走私案；而掌管国防事务的天民党更因“政治赞助”而为洛克希德公司的产品推广大开绿灯，直接导致意大利公民对当局信任跌落谷底，间接促成共产党与其他激进派竞选名单在1976年大选的显著胜利。这一政治大案迅速掀起了场空前规模的政治风暴，其目标正是构成该国政治生态基底的老牌政客们：丑闻导致了不计其数的检查、逮捕与起诉，上千位政客被牵连其中。主要政党的议会代表与热心权力寻租的企业家纷纷落马。并因此遭遇刑事指控。纵使该国的“人权斗士”，同样深陷回扣之国囹圄的贝蒂诺·克拉克西试图以“基耶萨家里发光的不一定都是金子”，“怎么总挑这些事报道”与“一切都是司法部门试图借肃清政敌，取消民主的政治阴谋”等话术策划抵制。可在他“颇有家资”的现实面前，一切自白都显得极其苍白无力。不论如何，空前绝后的清查已导致现存政党制度无以为继。政局也将随之发生巨变。\n"
const TXT_R0_INFL := "在天民党、社会党等老牌政党均因群龙无首与身败名裂而走向自我解散，其幸存成员则纷纷逃蹿到尚未卷入腐败丑闻的现存政党中的大势下。目前主宰政府与议会，以进步主义思潮支配社会，又正热心反腐与社会正义事业的意大利共产党已然在合法政治背景下成功排除所有政治对手，成为“净手行动”内的最大赢家。预计在接下来的数年中，共产党的政治霸权将随反腐清洗发展而实现空前稳固。显然，有趣的事正等待着共和国——由于恩里科·贝林格试图团结多数派并孤立独裁者的政治构想得以用另类方式最终实现；且作为该党内不可忽视势力的社会民主潮流“改进派”亦主张在51%绝对多数的基础上确立本党政治霸权。至此事实上否认了“历史性妥协”、“与社会党联合建立左翼替代”等老改良主义方针的存在必要性。意味着共产党自然有了更加自由的选择……第一步便是重新审视其内外立场与政治路线……"
const TXT_R0_VASILY := "于70年代末兴起的新党运动“民主替代”显然无法置身事外：该党不仅靠着政治回扣和非法赞助在短时间内形成以莫罗为核心的班底，更是在莫罗执政期间以扩充公共部门与国家庇护网络的形式为腐败势力提供了相当便利。于是，为解决裙带交易与政治腐败问题而发起的“净手行动”特别调查事实上宣判了“中左翼公式”的死刑。让“民主替代”、社会党两大执政党均因群龙无首与身败名裂而走向自我解散，其幸存成员则纷纷逃蹿到尚未卷入腐败丑闻的现存政党中的大势下。当前政府已然无法维系，议会亦要在澄清政治的大背景下进行全面改选。而这便给予了曾游离于该国主流外的政党们以机会：其中的最大赢家当属意大利共产党与意大利社会运动。前者得以借反腐议程与早已打出的革新招牌彻底确立自身该国政治良心的身份，并在社会党的尸体上垄断左翼政治议程；后者则因温和左翼-改革议程名誉扫地而导致的保守死刑回潮与党魁乔治·阿尔米兰特实施的“议会法西斯主义”实用政策而直接夺过天民党的社会基础与残存班底，成为该国保守主义者、民族主义者与反共人士的仅有选择。党势实现空前扩张，事实上取得了争取政权的入场券。"
const TXT_R0_NEUTRAL := "在天民党、社会党等执政党均因群龙无首与身败名裂而走向自我解散，其幸存成员则纷纷逃蹿到尚未卷入腐败丑闻的现存政党中的大势下。当前政府已然无法维系，议会亦要在澄清政治的大背景下进行全面改选。而这便给予了曾游离于该国主流外的政党们以机会：其中的最大赢家当属意大利共产党与意大利社会运动。前者得以借反腐议程与早已打出的革新招牌彻底确立自身该国政治良心的身份，并在社会党的尸体上垄断左翼政治议程；后者则因自身的亲传统主义意识形态与党魁乔治·阿尔米兰特实施的“议会法西斯主义”实用政策而直接夺过天民党的社会基础与残存班底，成为该国保守主义者、民族主义者与反共人士的仅有选择。党势实现空前扩张，事实上取得了争取政权的入场券。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 1:
		return
	_enable(event_def.options[0], event_def.options[0].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var portugal := ws.get_country_by_legacy_index(87)
	if portugal != null:
		portugal.special -= 5
	_add(175, -999)
	var text := TXT_R0_BASE
	if italy != null and italy.influence_china > 0:
		text += TXT_R0_INFL
		if italy != null:
			italy.government = GameConstants.Government.REFORMIST
			italy.sub_government = GameConstants.SubGovernment.PRAGMATIST
			italy.set_tag("亲美", false)
			italy.set_tag("eu", false)
			italy.set_tag("nato", false)
	elif ws.get_flag("VasilyisGay"):
		text += TXT_R0_VASILY
		_add(177, 3)
		EventEngine.enqueue_chain(["event_299"])
	else:
		text += TXT_R0_NEUTRAL
		_add(177, 3)
		EventEngine.enqueue_chain(["event_299"])
	context["result_text"] = text




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value






func _mod_active(idx: int) -> bool:
	var w: WorldState = ws
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
	PoliticianSystem.copy_leader_appearance(ws.leader, p)

