extends "res://数据脚本/event_script_base.gd"

## 原作事件 42–47：伊朗革命、越南经互会、改革派夺权、改革开放、匈牙利与北京之春。
## 来源：TimeScript.cs:3793-3837，doneventscript.cs:1102-1244，
##       Results_text.cs:3667-4170。
const POLITICAL_TRANSITION = preload("res://数据脚本/事件效果/event_024_026_political_transition.gd")

## 原版 Event42 选项1 的第二种禁用文案（agents>=50 但 political_line>1）。
const TXT_42_OPT1_DIS_USA := "美国人会怎么想？他们会勃然大怒的！"

## 原版 Event43 描述（越南是否社会主义两分支）。
const TXT_43_DESC_COMMON := "长期以来，越南一直试图在我们和苏联之间取得平衡，因为尽管我们与苏联存在分歧，但我们的志愿者们在印度支那战争中与社会主义越南并肩作战。但随着战争结束和越南统一，越南逐渐变得越来越亲苏联，越来越疏远我们。|"
const TXT_43_DESC_SOCIALIST := "黎笋1977年访问莫斯科后，越南与苏联又开始了一次友好关系，他日复一日地希望加入经互会。然而，该国部分领导人反对与苏联建立如此热烈的友好关系，因为越南没有特别的威胁，特别是在柬埔寨的波尔布特政权被推翻后。这是我们干预和制止苏联霸权扩散的机会。"
const TXT_43_DESC_NOT_SOCIALIST := "黎笋1977年访问莫斯科后，越南与苏联又开始了一次友好关系，他日复一日地希望加入经互会。我们显然无法阻止此事，尤其是越南希望在对抗亲中柬埔寨的波尔布特时得到苏联支持。"

## 原版 Event44 动态文案（TextOfEvents / VariantsOfEvents）。
const TXT_44_TITLE_DENG := "不管黑猫白猫…"
const TXT_44_TITLE_YE := "吕端大事不糊涂…"
const TXT_44_TITLE_REFORM := "不改革就下台！"
const TXT_44_DESC_A1 := "国内的债务高企与缺乏根本改观的糜烂经济局势已让既定方针难以为继，而党内改革派与实用主义政客的做大更是使得"
const TXT_44_DESC_A2 := "力行的保守政策丧失了社会基础。最近中央召开的工作会议更使这种趋势趋于公开化，斗争就此走向白热化：不满于"
const TXT_44_DESC_A3_DENG := "的政客已经团结在党内“经济专家”，曾在“文化大革命”期间主持国内全面整顿的老主管邓小平周围。他们将纯粹的经济问题探讨变成了算政治账的法庭，并对“彭德怀案”、“四五运动”、“文革余毒”乃至“六十一人叛徒集团”等故事重提，甚至将目前的经济失败与往日的所谓“唯意志论”等挂钩在一起。由此要求"
const TXT_44_DESC_A4_DENG := "对此做出交代——他们的要求显而易见，不换思想就换人。邓小平更是趁机撮合起所谓“求是派”圈子，在平反冤假错案，确立科学发展路线的旗下玩起经济核算、自筹资金与拓展市场要素的把戏，从而描摹起不同于既定路线的所谓“恢宏蓝图”，大有当中国版卡达尔·亚诺什的野心。出席会议的绝大多数角色基本上成了他的盟友。倘若你不想失去权力的话，总得做些什么！"
const TXT_44_DESC_A3_YE := "的政客已经团结在“中国的朱可夫元帅”，毛泽东主席临终前委托的政治元老，同时也是“走资派”邓小平挚友的叶剑英周围。他们将纯粹的经济问题探讨变成了算政治账的法庭，并对“批邓”、“彭德怀案”、“四五运动”、“文革余毒”乃至“六十一人叛徒集团”等故事重提，甚至将目前的经济失败与往日的所谓“唯意志论”等挂钩在一起。由此要求"
const TXT_44_DESC_A4_YE := "对此做出交代——他们的要求显而易见，不换思想就隔离审查。叶剑英更是纠结起自己在人民解放军中的圈子，一面将张爱萍、秦基伟与迟浩田等军方强力角色安插进会议内，一面则调动转机运输亲近自身立场的党员代表并试图封锁会议现场。打算以更加听话顺从的老干部取代您的地位，从而描摹起不同于既定路线的所谓“恢宏蓝图”，大有当现代版周公的野心。出席会议的绝大多数角色基本上成了他的盟友。倘若你不想失去权力的话，总得做些什么！"
const TXT_44_DESC_A3_REF := "的政客已经团结在党内的改革派头面人物，以南斯拉夫与匈牙利模式为模范的"
const TXT_44_DESC_A4_REF := "周围。他们将纯粹的经济问题探讨变成了算政治账的法庭，并对“批邓”、“彭德怀案”、“四五运动”、“文革余毒”乃至“六十一人叛徒集团”等故事重提，甚至将目前的经济失败与往日的所谓“唯意志论”等挂钩在一起。由此要求"
const TXT_44_DESC_A5_REF := "对此做出交代——他们的要求显而易见，不换思想就换人。"
const TXT_44_DESC_A6_REF := "更是趁机撮合起所谓“求是派”圈子，在平反冤假错案，确立科学发展路线的旗下玩起经济核算、自筹资金与拓展市场要素的把戏，从而描摹起不同于既定路线的所谓“恢宏蓝图”，大有当中国版卡达尔·亚诺什的野心。出席会议的绝大多数角色基本上成了他的盟友。倘若你不想失去权力的话，总得做些什么！"
const TXT_44_OPT0_DENG := "同意改革派的要求，以体面退场交换邓小平主持国政"
const TXT_44_OPT0_YE := "同意改革派的要求，以体面退场交换叶剑英主持国政"
const TXT_44_OPT0_REF_PREFIX := "同意改革派的要求，以体面退场交换"
const TXT_44_OPT0_REF_SUFFIX := "主持国政"

## 原版 Event44 结果文案（ResultsOfEvents）。
const TXT_44_R_LEADER_PREFIX := "意识到大势已去的"
const TXT_44_R_DENG_ACCEPT := "决定放弃挣扎，立刻便答应了邓小平等改革派头面人物开出的条件。不久后召开的又一场全会只是将先前讨论的结果给落到实处：党的领导集体决定加快冤假错案平反速度，并要求迅速解决自“文革”以来的一系列历史遗留问题（当然也包括借着这一政治风波扶摇直上的"
const TXT_44_R_COMMON_2 := "）。接下来便是通过人事改组，安置新部门与平反老干部的三板斧将“两个凡是”与其主要设计者给边缘化，"
const TXT_44_R_COMMON_3 := "的左膀右臂纷纷去了清水衙门，人事、理论与党政的要职也纷纷落入了邓小平与其盟友手中。"
const TXT_44_R_COMMON_4_DENG := "虽说没有丢掉自己的宝贵头衔，可丢了利爪的他处处受掣，其退休也不过时间问题。现在，全党全军已在邓小平的号令下就位，并形成了一个聚拢党内主要元老的精英政治圈子主持国政。而他已准备好带领国家走向一条史无前例的全面整顿，并在全新基础上建设有中国特色的社会主义之路。日后人们会将这天作为所谓“改革开放”的开端铭记，尽管当事人都清楚这只是又一场心血来潮的不流血政变与扫除杂草的例行公事而已。"
const TXT_44_R_YE_ACCEPT := "决定放弃挣扎，立刻便答应了叶剑英等改革派头面人物开出的条件。不久后召开的又一场全会只是将先前讨论的结果给落到实处：党的领导集体决定加快冤假错案平反速度，并要求迅速解决自“文革”以来的一系列历史遗留问题（当然也包括借着这一政治风波扶摇直上的"
const TXT_44_R_COMMON_3_YE := "的左膀右臂纷纷去了清水衙门，人事、理论与党政的要职也纷纷落入了叶剑英专门挑选的人士手中。"
const TXT_44_R_COMMON_4_YE := "虽说没有丢掉自己的宝贵头衔，可丢了利爪的他处处受掣，其退休也不过时间问题。现在，全党全军已在叶剑英的号令下就位，并形成了一个聚拢人民解放军内精英与党内主要元老的精英政治圈子主持国政。而他已准备好带领国家走向一条史无前例的全面整顿，并在全新基础上建设有中国特色的社会主义之路。日后人们会将这天作为所谓“改革开放”的开端铭记，尽管当事人都清楚这只是又一场心血来潮的不流血政变与扫除杂草的例行公事而已。叶剑英承诺将在人民解放军的监督下捍卫革命理想，并根据经济核算逻辑与力行“中国特色社会主义路线”，首先便是在全面平反冤假错案的基础上力行清算“三种人”与严打政策，彻底清理新版总路线外的异见。"
const TXT_44_R_REF_ACCEPT_PREFIX := "决定放弃挣扎，立刻便答应了"
const TXT_44_R_REF_ACCEPT_SUFFIX := "等改革派头面人物开出的条件。不久后召开的又一场全会只是将先前讨论的结果给落到实处：党的领导集体决定加快冤假错案平反速度，并要求迅速解决自“文革”以来的一系列历史遗留问题（当然也包括借着这一政治风波扶摇直上的"
const TXT_44_R_REF_COMMON_3 := "的左膀右臂纷纷去了清水衙门，人事、理论与党政的要职也纷纷落入了"
const TXT_44_R_REF_COMMON_4 := "与其盟友手中。"
const TXT_44_R_REF_COMMON_5 := "虽说没有丢掉自己的宝贵头衔，可丢了利爪的他处处受掣，其退休也不过时间问题。现在，全党全军已在"
const TXT_44_R_REF_COMMON_6 := "的号令下就位，而他已准备好带领国家走向一条史无前例的全面整顿，并在全新基础上建设有中国特色的社会主义之路。日后人们会将这天作为所谓“改革开放”的开端铭记，尽管当事人都清楚这只是又一场心血来潮的不流血政变与扫除杂草的例行公事而已。"
const TXT_44_R2_COMMON_4_DENG := "虽说没有丢掉自己的宝贵头衔，可丢了利爪的他处处受掣，其权势已不如往昔。不过，由于他能够及时选择站在改革派一方，并为国内政治转型开了盖子。所以他多少能加入到中国的元老圈子内同邓小平等人共治。而后者已准备好带领国家走向一条史无前例的全面整顿，并在全新基础上建设有中国特色的社会主义之路。日后人们会将这天视为所谓“改革开放”的开端铭记，尽管当事人都清楚这只是又一场心血来潮的不流血政变与扫除杂草的例行公事而已。"
const TXT_44_R2_COMMON_4_YE := "虽说没有丢掉自己的宝贵头衔，可丢了利爪的他处处受掣，其权势已不如往昔。不过，由于他能够及时选择站在改革派一方，并为国内政治转型开了盖子。所以他多少能加入到中国的元老圈子内同叶剑英等人共治。叶剑英则承诺将在人民解放军的监督下捍卫革命理想，并根据经济核算逻辑与力行“中国特色社会主义路线”，首先便是在全面平反冤假错案的基础上力行清算“三种人”与严打政策，彻底清理新版总路线外的异见。"
const TXT_44_R2_COMMON_5 := "虽说没有丢掉自己的宝贵头衔，可丢了利爪的他处处受掣，其权势已不如往昔。不过，由于他能够及时选择站在改革派一方，并为国内政治转型开了盖子。所以他多少能加入到中国的元老圈子内同"
const TXT_44_R2_COMMON_6 := "等人共治。而后者已准备好带领国家走向一条史无前例的全面整顿，并在全新基础上建设有中国特色的社会主义之路。日后人们会将这天作为所谓“改革开放”的开端铭记，尽管当事人都清楚这只是又一场心血来潮的不流血政变与扫除杂草的例行公事而已。"
const TXT_44_R1_A := "决定与起事的改革派党员打持久战，在打口水仗与拖延会议的的同时秘密聚拢兵力，一面通过国家安全机构的联系将忠诚派党员加紧带往北京，一面则通过中央警备团与北京当地组织的联系持续扩充无力，并准备隔离与封锁国内的主要部门。靠着不计人力的劳动密集型办法与好不容易积攒起的局部优势，"
const TXT_44_R1_B := "终于得以在漫长而艰难的混战中将改革派给一网打尽。不久后，"
const TXT_44_R1_C := "便对怀仁堂事变与苏联的“反党集团”实践按图索骥，将参与本次会议的主要角色纷纷送去“隔离审查”并开除党籍——从而再度巩固了自己的地位。不过，如此大规模的逮捕多少造成了一定范围的恐慌与社会动荡。知识界已将其同四清运动相提并论。"


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	ws = p_ws
	match str(event_def.event_id):
		"iranian_revolution":
			_prepare_42(event_def)
		"vietnam_cmea":
			_prepare_43(event_def)
		"reformers_take_power":
			_prepare_44(event_def)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"iranian_revolution": _event_42(option_index)
		"vietnam_cmea": _event_43(option_index)
		"reformers_take_power": _event_44(option_index, context)
		"reform_and_openness": _event_45()
		"hungarian_crisis": _event_46(option_index)
		"beijing_spring": _event_47(option_index)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _prepare_42(event_def: EventDef) -> void:
	if event_def == null or event_def.options.size() < 2:
		return
	var opt := event_def.options[1]
	if ws.数值表[W.I_AGENTS] < 50:
		opt.disabled_text = "我们爱莫能助"
	elif ws.数值表[W.I_POLITICAL_LINE] > 1:
		opt.disabled_text = TXT_42_OPT1_DIS_USA
	else:
		opt.disabled_text = ""

func _prepare_43(event_def: EventDef) -> void:
	var vietnam := ws.get_country_by_legacy_index(23)
	if vietnam != null and vietnam.government == 1:
		event_def.description = TXT_43_DESC_COMMON + TXT_43_DESC_SOCIALIST
	else:
		event_def.description = TXT_43_DESC_COMMON + TXT_43_DESC_NOT_SOCIALIST


func _prepare_44(event_def: EventDef) -> void:
	var deng := _find_politician(13, 13)
	var ye := _find_politician(8, 8)
	if deng >= 0:
		event_def.title = TXT_44_TITLE_DENG
		event_def.description = TXT_44_DESC_A1 + _leader_name() + TXT_44_DESC_A2 + _leader_name() + TXT_44_DESC_A3_DENG + _leader_name() + TXT_44_DESC_A4_DENG
		if event_def.options.size() > 0:
			event_def.options[0].text = TXT_44_OPT0_DENG
	elif ye >= 0:
		event_def.title = TXT_44_TITLE_YE
		event_def.description = TXT_44_DESC_A1 + _leader_name() + TXT_44_DESC_A2 + _leader_name() + TXT_44_DESC_A3_YE + _leader_name() + TXT_44_DESC_A4_YE
		if event_def.options.size() > 0:
			event_def.options[0].text = TXT_44_OPT0_YE
	else:
		var ref_leader := _faction_leader_name(FactionData.REFORMIST)
		event_def.title = TXT_44_TITLE_REFORM
		event_def.description = TXT_44_DESC_A1 + _leader_name() + TXT_44_DESC_A2 + _leader_name() + TXT_44_DESC_A3_REF + ref_leader + TXT_44_DESC_A4_REF + _leader_name() + TXT_44_DESC_A5_REF + ref_leader + TXT_44_DESC_A6_REF
		if event_def.options.size() > 0:
			event_def.options[0].text = TXT_44_OPT0_REF_PREFIX + ref_leader + TXT_44_OPT0_REF_SUFFIX


func _event_42(option_index: int) -> void:
	var iran := ws.get_country_by_legacy_index(8)
	ws.set_flag("iran_revolution_started", true)
	match option_index:
		0:
			if iran != null: iran.development = 4
		1:
			_add_data({W.I_IRAN_LEFT_SUPPORT: 70, W.I_AGENTS: -50, W.I_DIPLO: 20})
			if iran != null: iran.development = 1
		2:
			_add_data({W.I_IRAN_SHAH_SUPPORT: 70, W.I_AGENTS: -50, W.I_DIPLO: -10})
			if iran != null:
				iran.development = 0
				iran.set_tag("对华贸易", true)
		# 原版 Event42.cs 只有 3 个选项：0=不干涉、1=左翼、2=沙阿。
		# 旧 Godot 实现自造的伊斯兰/民主派分支（result 3~5）已删除。


func _event_43(option_index: int) -> void:
	var vietnam := ws.get_country_by_legacy_index(11)
	match option_index:
		0:
			ws.数值表[W.I_PARTY_SUPPORT] -= 50
			_add_empire_power(EmpireData.USSR, 30)
			if vietnam != null: vietnam.set_tag("sev", true)
		1:
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_AGENTS: -30})
			_add_empire_relation(EmpireData.USSR, -70)


func _event_44(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			# 原版 result0 共同效果：LeaderAsset/MoneyLevel/ServeRMB 未建模，跳过。
			_set_modifier_active(3, false)
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: -20,
				W.I_THOUGHT_FREEDOM: 70, W.I_PEOPLE_SUPPORT: 60, W.I_DIPLO: -20})
			ws.数值表[W.I_REFORM_STAGE] = 1
			_add_empire_relation(EmpireData.USA, 100)
			_subtract_faction_fraction(FactionData.MAOIST, 0.15)
			_subtract_faction_fraction(FactionData.CONSERVATIVE, 0.15)
			var deng := _find_politician(13, 13)
			var ye := _find_politician(8, 8)
			if deng >= 0:
				ws.factions[FactionData.REFORMIST].leader_index = deng
				context["result_text"] = _build_44_result0_deng()
			elif ye >= 0:
				ws.factions[FactionData.REFORMIST].leader_index = ye
				ws.数值表[17] = 16
				context["result_text"] = _build_44_result0_ye()
			else:
				context["result_text"] = _build_44_result0_generic()
			_kill_politician_if_exists(11, 11)
			_kill_politician_if_exists(6, 6)
			ws.数值表[W.I_PARTY_SYSTEM] = 7
			_change_politicians({0: [-500, -200], 1: [-100, 100], 2: [200, 200], 3: [70, 80]})
			var reform_leader := _faction_leader_index(FactionData.REFORMIST)
			if reform_leader >= 0:
				var transition = POLITICAL_TRANSITION.new()
				transition._swap_leader_with_politician(reform_leader, FactionData.REFORMIST)
			PoliticianSystem.sync_in_power_flags(ws)
		1:
			_add_data({W.I_PARTY_SUPPORT: -150, W.I_PEOPLE_SUPPORT: -120,
				W.I_AGENTS: -150, W.I_THOUGHT_FREEDOM: 150, W.I_DIPLO: 30})
			_kill_faction_leader(FactionData.REFORMIST)
			_kill_politician_if_exists(13, 13)
			_kill_politician_if_exists(8, 8)
			context["result_text"] = _leader_name() + TXT_44_R1_A + _leader_name() + TXT_44_R1_B + _leader_name() + TXT_44_R1_C
		2:
			_set_modifier_active(3, false)
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: -20,
				W.I_THOUGHT_FREEDOM: 70, W.I_PEOPLE_SUPPORT: 60, W.I_DIPLO: -20})
			ws.数值表[W.I_REFORM_STAGE] = 1
			_add_empire_relation(EmpireData.USA, 100)
			_subtract_faction_fraction(FactionData.MAOIST, 0.15)
			_subtract_faction_fraction(FactionData.CONSERVATIVE, 0.15)
			_change_politicians({0: [-500, -200], 1: [-100, 100], 2: [200, 200], 3: [70, 80]})
			var deng2 := _find_politician(13, 13)
			var ye2 := _find_politician(8, 8)
			if deng2 > 0:
				ws.factions[FactionData.REFORMIST].leader_index = deng2
				context["result_text"] = _build_44_result2_deng()
			elif ye2 > 0:
				ws.factions[FactionData.REFORMIST].leader_index = ye2
				ws.数值表[17] = 16
				context["result_text"] = _build_44_result2_ye()
			else:
				context["result_text"] = _build_44_result2_generic()
			_kill_politician_if_exists(11, 11)
			_kill_politician_if_exists(6, 6)
			ws.数值表[W.I_PARTY_SYSTEM] = 7
			PoliticianSystem.sync_in_power_flags(ws)
	# 原版 NewPolitician[4]=false / party_change[] 仅 UI 缓冲，未建模。


func _event_45() -> void:
	_add_data({W.I_INFLUENCE: -20, W.I_THOUGHT_FREEDOM: 50,
		W.I_REFORM_MOMENTUM: 20, W.I_DIPLO: -30})
	if ws.数值表[W.I_ECON_SYSTEM] == 10:
		ws.数值表[W.I_ECON_SYSTEM] = 12
	elif ws.数值表[W.I_ECON_SYSTEM] <= 14:
		ws.数值表[W.I_ECON_SYSTEM] += 1
	ws.数值表[W.I_REFORM_STAGE] = 2
	_add_empire_relation(EmpireData.USA, 100)
	var albania := ws.get_country_by_legacy_index(20)
	if albania != null:
		albania.set_tag("对华贸易", false)
		albania.set_tag("亲中", false)
	_change_politicians({1: [0, 50], 2: [0, 100], 3: [0, 50]})


func _event_46(option_index: int) -> void:
	var hungary := ws.get_country_by_legacy_index(4)
	match option_index:
		0:
			_add_empire_power(EmpireData.USSR, -10)
		1:
			_add_data({W.I_INFLUENCE: 20, W.I_AGENTS: -80, W.I_DIPLO: 20})
			_add_empire_power(EmpireData.USSR, -20)
			_add_empire_relation(EmpireData.USSR, -300)
			_add_ussr_leader_support(6, -1)
			if hungary != null:
				hungary.government = 1
				hungary.sub_government = 1
				hungary.set_tag("对华贸易", true)
				hungary.set_tag("亲苏", false)
		2:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_INFLUENCE: -15,
				W.I_AGENTS: -30, W.I_ARMY: -10, W.I_DIPLO: 40,
				W.I_SOVIET_INTERVENTIONS: 1})
			_add_empire_relation(EmpireData.USSR, -150)
			_add_empire_power(EmpireData.USSR, 10)
			_add_empire_power(EmpireData.USA, -10)
			_add_ussr_leader_support(6, -2)
			if hungary != null:
				hungary.government = 1
				hungary.sub_government = 16
				hungary.puppet_of = 7
		3:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_INFLUENCE: 10,
				W.I_DIPLO: 20, W.I_THOUGHT_FREEDOM: -40})
			_add_empire_relation(EmpireData.USSR, -80)
			_add_empire_power(EmpireData.USSR, -10)


func _event_47(option_index: int) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -80, W.I_THOUGHT_FREEDOM: 100,
				W.I_PEOPLE_SUPPORT: -80, W.I_DIPLO: 10})
			_subtract_faction_fraction(FactionData.REFORMIST, 0.05)
			_change_politicians({2: [-100, -100]})
		1:
			_add_data({W.I_PARTY_SUPPORT: 30, W.I_THOUGHT_FREEDOM: 80,
				W.I_PEOPLE_SUPPORT: -50, W.I_DIPLO: -10})
			_change_politicians({2: [50, 50]})
		2:
			_add_data({W.I_PARTY_SUPPORT: -80, W.I_THOUGHT_FREEDOM: 120,
				W.I_PEOPLE_SUPPORT: -60})
			# 原版 party_change[3]=1f 仅 UI 缓冲，端口无等价，跳过。
			_change_politicians({2: [50, 150]})


# ── Event44 文案组装 ──

func _build_44_result0_deng() -> String:
	return (TXT_44_R_LEADER_PREFIX + _leader_name() + TXT_44_R_DENG_ACCEPT
			+ _leader_name() + TXT_44_R_COMMON_2 + _leader_name()
			+ TXT_44_R_COMMON_3 + _leader_name() + TXT_44_R_COMMON_4_DENG)


func _build_44_result0_ye() -> String:
	return (TXT_44_R_LEADER_PREFIX + _leader_name() + TXT_44_R_YE_ACCEPT
			+ _leader_name() + TXT_44_R_COMMON_2 + _leader_name()
			+ TXT_44_R_COMMON_3_YE + _leader_name() + TXT_44_R_COMMON_4_YE)


func _build_44_result0_generic() -> String:
	var ref_leader := _faction_leader_name(FactionData.REFORMIST)
	return (TXT_44_R_LEADER_PREFIX + _leader_name() + TXT_44_R_REF_ACCEPT_PREFIX
			+ ref_leader + TXT_44_R_REF_ACCEPT_SUFFIX + _leader_name()
			+ TXT_44_R_COMMON_2 + _leader_name() + TXT_44_R_REF_COMMON_3
			+ ref_leader + TXT_44_R_REF_COMMON_4 + _leader_name()
			+ TXT_44_R_REF_COMMON_5 + ref_leader + TXT_44_R_REF_COMMON_6)


func _build_44_result2_deng() -> String:
	return (TXT_44_R_LEADER_PREFIX + _leader_name() + TXT_44_R_DENG_ACCEPT
			+ _leader_name() + TXT_44_R_COMMON_2 + _leader_name()
			+ TXT_44_R_COMMON_3 + _leader_name() + TXT_44_R2_COMMON_4_DENG)


func _build_44_result2_ye() -> String:
	return (TXT_44_R_LEADER_PREFIX + _leader_name() + TXT_44_R_YE_ACCEPT
			+ _leader_name() + TXT_44_R_COMMON_2 + _leader_name()
			+ TXT_44_R_COMMON_3_YE + _leader_name() + TXT_44_R2_COMMON_4_YE)


func _build_44_result2_generic() -> String:
	var ref_leader := _faction_leader_name(FactionData.REFORMIST)
	return (TXT_44_R_LEADER_PREFIX + _leader_name() + TXT_44_R_REF_ACCEPT_PREFIX
			+ ref_leader + TXT_44_R_REF_ACCEPT_SUFFIX + _leader_name()
			+ TXT_44_R_COMMON_2 + _leader_name() + TXT_44_R_REF_COMMON_3
			+ ref_leader + TXT_44_R_REF_COMMON_4 + _leader_name()
			+ TXT_44_R2_COMMON_5 + ref_leader + TXT_44_R2_COMMON_6)


func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _faction_leader_name(faction_index: int) -> String:
	if faction_index < 0 or faction_index >= ws.factions.size():
		return "改革派领袖"
	var faction: FactionData = ws.factions[faction_index]
	if faction == null:
		return "改革派领袖"
	var idx := faction.leader_index
	if idx < 0 or idx >= ws.politicians.size() or ws.politicians[idx] == null:
		return "改革派领袖"
	var p: PoliticianData = ws.politicians[idx]
	if p.name_display != "":
		return p.name_display
	return "改革派领袖"


func _find_politician(name_first: int, name_last: int) -> int:
	for i in ws.politicians.size():
		var p: PoliticianData = ws.politicians[i]
		if p != null and p.name_first == name_first and p.name_last == name_last:
			return i
	return -1


func _kill_politician_if_exists(name_first: int, name_last: int) -> void:
	var idx := _find_politician(name_first, name_last)
	if idx >= 0:
		GameManager.kill_politician(idx)


func _kill_faction_leader(faction_index: int) -> void:
	var idx := _faction_leader_index(faction_index)
	if idx >= 0:
		GameManager.kill_politician(idx)


func _faction_leader_index(faction_index: int) -> int:
	if faction_index < 0 or faction_index >= ws.factions.size() or ws.factions[faction_index] == null:
		return -1
	var index := ws.factions[faction_index].leader_index
	return index if index >= 0 and index < ws.politicians.size() else -1


func _set_modifier_active(modifier_index: int, active: bool) -> void:
	if modifier_index >= 0 and modifier_index < ws.modifiers.size() and ws.modifiers[modifier_index] != null:
		ws.modifiers[modifier_index].is_active = active


func _add_ussr_leader_support(leader_index: int, delta: int) -> void:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		var ussr = ws.empires[EmpireData.USSR]
		if leader_index >= 0 and leader_index < ussr.leaders.size() and ussr.leaders[leader_index] != null:
			ussr.leaders[leader_index].support += delta


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.数值表.size():
			ws.数值表[index] += int(changes[raw_index])


func _change_politicians(changes: Dictionary) -> void:
	for politician in ws.politicians:
		if politician != null and changes.has(politician.trait_personality):
			var pair: Array = changes[politician.trait_personality]
			politician.loyalty += int(pair[0])
			politician.power += int(pair[1])


func _add_faction_ideology(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.factions.size() and ws.factions[index] != null:
			ws.factions[index].ideology += int(changes[raw_index])


func _subtract_faction_fraction(faction_index: int, fraction: float) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		var current := ws.factions[faction_index].ideology
		ws.factions[faction_index].ideology = current - int(float(current) * fraction)


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.数值表[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		ws.数值表[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.数值表[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		ws.数值表[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power
