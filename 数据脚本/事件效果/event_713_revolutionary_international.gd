extends "res://数据脚本/event_script_base.gd"

## 原作 Event713.cs：青出于蓝，而胜于蓝（国际毛派反华集团事件，1978.10 触发条件见 event_713_trigger.gd）。
## 触发：EventDef.trigger_script = event_713_trigger.gd（TimeScript.cs:9979-10040 的
## flag/num 循环统计 + 国家政体/修正/决策条件，ExprNode 无法表达，走尾追加钩子）。
## 差异：
##  - <color> 标签去除（UI 未开 bbcode）；字符间空格排版不保留。
##  - 原版 numberOfSpecialEnding=0 → Godot CountryData.special_ending=0。
##  - resultOfEvents[686]/[125]/[437]/[503]/[521]/[540]/[545] 用 completed_event_ids，
##    对应事件后续移植统一使用 "event_NNN" 作为 event_id（见 事件对齐台账.md）。
##  - LeaveAlliances / JoinAllOurAlliances 按 Country.cs:89-112 / 42-86 分支逐项映射
##    到 Godot tags（包含 puppetOf=-1）。
##  - ChineseSubGosstroy()（GameState.cs:4934-5028）本脚本完整移植为
##    _chinese_sub_government()，分支顺序与返回值逐字对齐。

const ARRAY_LOYALISTS := [9, 10, 11, 22, 23, 31, 32, 33, 34, 43, 47, 49, 50, 96, 97, 128]

const TXT_OPT1_A := "批判的武器当然不能代替武器的批判，当然，物质力量只能用物质力量来摧毁！"
const TXT_OPT1_B := "君子报仇，十年不晚……"
const TXT_OPT1_C := "这太疯狂了！我想我们确实活在一个公理得胜的时代"

const TXT_DESC_PRE := "曾几何时，是我们扛起了反对修正主义，争取公正合理新秩序的大旗，并借否定莫斯科的和平共处老一套在全球激进派共产主义者面前确立起毋庸置疑的领导权。所有的这一切都为为组织一个更具原则性、组织性与战斗性的社会主义阵营创造了必要基础，我们也就自然背负起作为“老大哥”的责任与负担。可如今，时代变了：或是因为自认羽翼渐丰而不满于既定的国际分工方案，或是出于纯粹的卸磨杀驴心理。总之，那些先前得到我党同志提携，谨遵我国顾问教诲，满口念叨“社会主义”的后生们已撕下含情脉脉面纱与国际主义遮羞布，彻底走上了不归路：根据外联部同志的情报，秘鲁共产党（光辉道路）主席阿维马埃尔·古斯曼、日本革命共产党主要负责人福田正义与印度共产党（毛主义）总书记卡奈·查特吉已就“无产阶级革命与叛徒"
const TXT_DESC_POST := "”问题于新德里召开国际会议，宣称将在彻底剔除对国际无产者实行贩卖政策的“现代修正主义者”，并发扬光大“马克思、列宁、毛泽东”事业的基础上重振共产主义意识形态的声誉。为此，有必要在彻底清除中华沙文主义影响的同时，呼吁所有有志于实现国际秩序革新的革命派们同自身步调一致。至此宣告了敌对政治国际“革命国际主义运动”、反华文件《致各国马克思列宁主义者、工人与被压迫者》（尝试将毛主义改造为反对我国利益的武器）与反华纲领“二十二项原则”（即在共产国际的二十一项原则基础上进行微调，并增添了争取实现中国的“再革命”相关条文）的诞生——面对这群盗用齐美尔瓦尔德左派之名，正在我们的皮子底下分裂由世界各国人民以鲜血捍卫的社会主义统一旗帜的政治流氓。我们总得做些什么！"

const TXT_R0 := "针对上述国家假革命，真反华的所作所为。我《人民日报》立即发表题为《我们的忍耐是有限度的》这一社论，文中直呼秘鲁、印度与日本三国“猖狂挑衅我国公民，肆无忌惮的地诽谤我国外交政策，忘恩负义挑起纠纷，已教人忍无可忍”。而所谓伪政治国际“革命国际主义运动”更是新时代《钢铁条约》，完全同和平发展的时代主旋律背道而驰。中方郑重声明：我国人民的忍耐和克制是有限度的，中国不欺侮任何人，也决不允许别人欺侮我们。人不犯我，我不犯人，人若犯我，我必犯人。如果上述政权得寸进尺，自认为可靠抱团取暖方式继续恣意妄为，必将受到应得惩罚。我们把话说在前面，勿谓言之不预。然而，这份通过外交部向全球范围内发出的官方照会回应寥寥：美苏两大超级大国对于中国集团的内讧“乐见其成”，而“革命国际主义运动”更将其视为“帝国主义的虚张声势”与“重弹三和两全老调”，只在我国的老朋友处获得了寥寥掌声。党内同志与我国人民也对这一表态表示不满，并宣称“小孩不听话就该打屁股”……"

const TXT_R1_PRE := "既然那帮教条主义者喜欢给我们扣修正主义者、沙文主义者与最坏的走资派帽子，并拿前代领导人的名字要挟我国领导核心，玩“好沙皇，坏波雅尔”的把戏。那我们就如他们所愿，让他们开开眼界，用实力告诉这帮幼稚病患者们坏波雅尔有多坏：谨遵"
const TXT_R1_MID := "主席“惩前毖后，治病救人”的最高指示，一心效力我国伟大事业的8341小将们连同武装到牙齿的第15军决定再次拿起武器，踏上战场，学习苏联老大哥以快打慢，强势改组的做法，用铁血手段好好给这些红小鬼打屁股。考虑到集体安全条约的约束尚在，党间关系亦不可同国际关系一般相提并论（至少，我国外交使团同印度在边界勘定问题上尚未有如此浓郁的火药味），且我国在亚太地区内部的长久经营切实为奉行有中国特色的门罗主义或有限主权论奠定了基础。将作战部队部署至待定地点，并在此后拔出该死的杂草确实可说是轻而易举：仅在伪政治国际“革命国际主义运动”宣布成立的数日后，在新德里城区阅兵的59式坦克与燃烧的日本国会议事堂便登上国际新闻头条（当然，我们亦对尝试同激进毛派看齐的其他角色们亮了肌肉，从而换来了刺刀下的忠诚）。此后则是得到了我国背书与特别筛选的好同志们对叛徒们的拨乱反正环节。当然，即便我们已经拿出了如此铁血手段，可终究是有漏网之鱼：虽说空输将士得以一举粉碎囊括以卡奈·查特吉与福田正义为首的反革命司令部，并通过将德钦巴登顶与陈平等角色“隔离审查”的手段重新确立了对当地社会主义运动的领导权。可派赴秘鲁的特别行动小组却在缉捕国际毛派运动的核心阿维马埃尔·古斯曼上不幸折戟，且来自前欧洲盟友的反戈一击更为出师不利的“革命国际主义运动”打了强心针。从此确认了国际共运再次发生大分裂的事实。而在控制区内的抵抗依旧继续：残存的印共（毛）伪党在年轻军官巴萨瓦拉吉与贾纳帕蒂的旗下整合，尝试重启游击战。而日本革命共产党的残存干部更是开始组织起新时代的赤军运动，完全朝红色恐怖看齐。接下来就得面临你死我活的斗争了……"


## 显示前动态钩子：插入领导人姓名；按原版 VariantsOfEvents 三段条件设选项1文案与门槛。
## 注意 resultOfEvents[] 未触发时原版为 int 默认 0；Godot completed_event_ids 缺省 -1，
## 故 540 用 get("event_540", 0) 对齐原版缺省语义，545/521 需真值 2 不受影响。
func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var leader_name := _leader_name(world)
	event_def.description = TXT_DESC_PRE + leader_name + TXT_DESC_POST
	if event_def.options.size() > 1:
		var opt: EventOption = event_def.options[1]
		var available := _option1_available(world)
		if available:
			opt.text = TXT_OPT1_A
			opt.disabled_text = ""
			opt.enable_condition = null
		elif world.completed_event_ids.has("event_503") \
				and world.completed_event_ids.get("event_503", -1) == 0:
			opt.text = TXT_OPT1_B
			opt.disabled_text = TXT_OPT1_B
			opt.enable_condition = _never_node()
		else:
			opt.text = TXT_OPT1_C
			opt.disabled_text = TXT_OPT1_C
			opt.enable_condition = _never_node()


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_common_effects()
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		_add(W.I_PARTY_SUPPORT, -250)
		_add(W.I_PEOPLE_SUPPORT, -250)
		context["result_text"] = TXT_R0
	elif opt == 1:
		_add(W.I_BUDGET, -1000)
		_add(W.I_AGENTS, -1000)
		_add(W.I_ARMY, -1000)
		_add(W.I_PARTY_SUPPORT, -50)
		_add(W.I_PEOPLE_SUPPORT, -100)
		_add_relation(EmpireData.USSR, -800)
		_add_relation(EmpireData.USA, -400)
		_subdue_country(19, "印度")
		_subdue_country(44, "日本")
		for legacy_index in ARRAY_LOYALISTS:
			var c := ws.get_country_by_legacy_index(legacy_index)
			if c == null or not ws.is_socialism(c, true):
				continue
			if c.sub_government == GameConstants.SubGovernment.SOVIET_STYLE or c.sub_government == GameConstants.SubGovernment.TROTSKYIST:
				continue
			_leave_alliances(c)
			var china := ws.get_country_by_legacy_index(1)
			if china != null:
				c.government = china.government
				c.sub_government = _chinese_sub_government()
			c.puppet_of = GameConstants.LegacySlot.CHINA
			c.set_tag("亲中", true)
			c.set_tag("对华贸易", true)
			_join_our_alliances(c)
		context["result_text"] = TXT_R1_PRE + _leader_name(ws) + TXT_R1_MID


## Event713.cs ResultsOfEvents 开头共同效果（result_num 分支之前）。
func _common_effects() -> void:
	# event_done[686] = false（重置，允许 686 再触发）
	ws.completed_event_ids.erase("event_686")
	# 秘鲁(62)：SubGosstroy==17 或 proprc → Gosstroy=2, SubGosstroy=15
	var peru := ws.get_country_by_legacy_index(62)
	if peru != null and (peru.sub_government == GameConstants.SubGovernment.MAOIST or peru.has_tag("亲中")):
		peru.government = GameConstants.Government.REFORMIST
		peru.sub_government = GameConstants.SubGovernment.PRAGMATIST
	# 全国家循环：i!=1、非中国附庸、IsSocialism(true)、SubGosstroy!=16/18、
	# 非亲苏/亲美、不在经互会/华约 → 影响-20、断亲中/对华贸易/econ/okb；
	# 符合条件者转 rim。
	for c in ws.countries:
		if c == null or c.原版序号 == GameConstants.LegacySlot.CHINA:
			continue
		if c.puppet_of == GameConstants.LegacySlot.CHINA:
			continue
		if not ws.is_socialism(c, true):
			continue
		if c.sub_government == GameConstants.SubGovernment.SOVIET_STYLE or c.sub_government == GameConstants.SubGovernment.TROTSKYIST:
			continue
		if c.has_tag("亲苏") or c.has_tag("亲美") or c.has_tag("sev") or c.has_tag("ovd"):
			continue
		ws.influence_prc -= 20
		c.set_tag("亲中", false)
		c.set_tag("对华贸易", false)
		c.set_tag("econ", false)
		c.set_tag("okb", false)
		if c.sub_government == GameConstants.SubGovernment.MAOIST or c.sub_government == GameConstants.SubGovernment.MARXIST_LENINIST \
				or (c.原版序号 == 24 and ws.completed_event_ids.get("event_437", 0) == 0 \
				and not _parts_0(25)):
			c.set_tag("rim", true)
	# 印度(19)：Gosstroy=0, SubGosstroy=0, numberOfSpecialEnding=0, 非亲美
	var india := ws.get_country_by_legacy_index(19)
	if india != null:
		india.government = GameConstants.Government.AUTHORITARIAN
		india.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
		india.special_ending = 0
		india.set_tag("亲美", false)
		india.set_tag("rim", true)
	# resultOfEvents[125] = 0（后续移植约定 event_id="event_125"）
	ws.completed_event_ids["event_125"] = 0
	var c80 := ws.get_country_by_legacy_index(80)
	if c80 != null:
		c80.set_tag("rim", true)
	var c44 := ws.get_country_by_legacy_index(44)
	if c44 != null:
		c44.set_tag("rim", true)


## 印度(19)/日本(44)：LeaveAlliances → 改名、Gosstroy=2、SubGosstroy=15、
## puppetOf=1、亲中+对华贸易、JoinAllOurAlliances。
func _subdue_country(legacy_index: int, new_name: String) -> void:
	var c := ws.get_country_by_legacy_index(legacy_index)
	if c == null:
		return
	_leave_alliances(c)
	c.name = new_name
	c.chinese_name = new_name
	c.government = GameConstants.Government.REFORMIST
	c.sub_government = GameConstants.SubGovernment.PRAGMATIST
	c.puppet_of = GameConstants.LegacySlot.CHINA
	c.set_tag("亲中", true)
	c.set_tag("对华贸易", true)
	_join_our_alliances(c)


## Country.cs:89-112 LeaveAlliances（联盟/倾向清空 + puppetOf=-1）。

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






func _leader_name(world: WorldState) -> String:
	if world.leader != null and world.leader.name_display != "":
		return world.leader.name_display
	return "华国锋"


## Event713.cs VariantsOfEvents 选项1 三态判定（原版条件逐字）。
func _option1_available(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world.数值表
	if data.size() <= W.I_ARMY:
		return false
	var d503_done: bool = world.completed_event_ids.has("event_503")
	var d503_result: int = world.completed_event_ids.get("event_503", -1)
	return world.influence_prc >= 1000 \
		and data[W.I_DIPLO] > 900 \
		and data[W.I_BUDGET] + data[W.I_RESERVE] >= 1000 \
		and data[W.I_AGENTS] >= 1000 \
		and data[W.I_ARMY] >= 1000 \
		and world.completed_event_ids.get("event_540", 0) == 0 \
		and world.completed_event_ids.get("event_545", -1) == 2 \
		and world.completed_event_ids.get("event_521", -1) == 2 \
		and (not d503_done or d503_result != 0)


## 不可达 ExprNode（prepare 动态禁用选项时使用，与原版 SetActive(false) 等价）。
func _never_node() -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	return n


func _event_result(event_id: String) -> int:
	return ws.completed_event_ids.get(event_id, -1)


func _parts_0(legacy_index: int) -> bool:
	var c := ws.get_country_by_legacy_index(legacy_index)
	return c != null and c.parts.size() > 0 and c.parts[0]


## GameState.cs:4934-5028 ChineseSubGosstroy 完整移植（分支顺序逐字）。
func _chinese_sub_government() -> int:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return 13
	if d.size() <= W.I_TERRITORY:
		return 13
	var data := d
	var result := 13
	if china.government == GameConstants.Government.AUTHORITARIAN:
		if _event_result("event_674") == 2:
			result = 9
		elif china.has_tag("nazimao"):
			result = 22
		elif ws.completed_event_ids.has("event_912") and _event_result("event_912") == 0:
			result = 19
		elif data[W.I_PARTY_SYSTEM] == 8:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif data[W.I_IDEOLOGY] <= 2 and data[W.I_ECON_SYSTEM] < 13 \
				and data[W.I_DIPLO] >= 700 and data[W.I_PARTY_SYSTEM] < 8 \
				and _mod_active(6) and _mod_active(3):
			result = 0
		elif (data[W.I_ECON_SYSTEM] >= 13 and data[W.I_WAR_SUPPORT] >= 700 and not _mod_active(6)) \
				or _mod_active(38):
			result = 9
		elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_WAR_SUPPORT] >= 700 \
				and data[W.I_DIPLO] >= 700 and (_mod_active(6) or _mod_active(3)):
			result = 10
		elif data[W.I_ECON_SYSTEM] >= 13 and not _mod_active(6):
			result = 7
		else:
			result = 13
	elif china.government == GameConstants.Government.SOCIALIST:
		if _mod_active(49):
			result = 18
		elif _mod_active(6) and _mod_active(3) and data[W.I_PARTY_SYSTEM] <= 7 \
				and data[W.I_ECON_SYSTEM] <= 12 and data[W.I_RELIGION] <= 25:
			result = 17
		elif data[W.I_IDEOLOGY] == 1 and not _mod_active(6) and data[W.I_RELIGION] <= 26:
			result = 16
		elif data[W.I_ECON_SYSTEM] < 13 and data[W.I_PRESS_POLICY] >= 17 \
				and data[W.I_IDEOLOGY] == 1 and data[W.I_RELIGION] <= 26:
			result = 2
		else:
			result = 1
	elif china.government == GameConstants.Government.REFORMIST:
		if _mod_active(40):
			result = 8
		elif data[W.I_IDEOLOGY] >= 2 and data[W.I_ECON_SYSTEM] >= 13 \
				and data[W.I_DIPLO] <= 700 and data[W.I_PARTY_SYSTEM] >= 8 \
				and data[W.I_PRESS_POLICY] >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] >= 12 \
				and data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 300 \
				and data[W.I_TERRITORY] > 21 and data[W.I_WAR_SUPPORT] >= 700:
			result = 11
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 14 \
				and data[W.I_DIPLO] >= 500 and data[W.I_ECON_SYSTEM] > 11 \
				and data[W.I_WAR_SUPPORT] >= 400:
			result = 8
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 13 \
				and data[W.I_PRESS_POLICY] > 17:
			result = 3
		elif data[W.I_PARTY_SYSTEM] <= 8 \
				and (data[W.I_ECON_SYSTEM] == 13 or data[W.I_ECON_SYSTEM] == 12) \
				and data[W.I_WAR_SUPPORT] < 700 and not _mod_active(3) \
				and data[W.I_PRESS_POLICY] >= 17:
			result = 21
		else:
			result = 15
	elif china.government != GameConstants.Government.LIBERAL:
		result = 13
	elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 500:
		result = 4
	elif (data[W.I_PARTY_SYSTEM] <= 8 and data[W.I_PRESS_POLICY] <= 18) \
			or data[W.I_WAR_SUPPORT] >= 700:
		result = 12
	elif data[W.I_ECON_SYSTEM] > 13 and data[W.I_DIPLO] < 700:
		result = 6
	else:
		result = 5
	return result


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() \
		and ws.modifiers[index] != null and ws.modifiers[index].is_active
