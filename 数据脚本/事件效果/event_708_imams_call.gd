extends "res://数据脚本/event_script_base.gd"

## 原作 Event708.cs：伊玛目的召唤（伊拉克什叶派起义，分支 2/4 选项）。
## 触发：TimeScript.cs:10566-10573 ——
##   ((done36 && result36==3 && c14.prcpower>=150) || (年>=1982 月>=7 日>=8)
##    || (年>=1982 月>=8) || 年>=1983) && c14.SubGosstroy==10 && c14.puppetOf<0
##   && !wars[29].is_going && !event_done[417]（.tres ExprNode 表达）。
## 差异：
##  - 特殊分支（done36 && result36==3 && prcpower>=80）只有 2 个选项：
##    prepare 动态替换 options 数组（静态备份 4 选项，普通分支还原）。
##  - 战争 88：TickTime(100) → fortnight_max=100；infl 调整逐字保留。

const TXT_DESC_SPECIAL := "随着萨达姆·侯赛因的崛起，伊拉克加大了对于潜在风险的管控。萨达姆有四大心头患：伊拉克共产党，库尔德民主党，库尔德爱国同盟与伊斯兰达瓦党。邻国因为伊斯兰主义者而掀起的暴乱既让萨达姆看到了机会，更让其恐慌。在1980年，伊斯兰达瓦党由于其强烈的反复兴主义倾向而被勒令解散，但在我们的支援下，巴克尔·萨德尔博士得以幸存并坚定了武装斗争的意志。由此，达瓦党的支持者们组建了圣城旅，号召全国什叶派教徒们展开圣战，推翻暴虐无道的复兴党政府。在萨达姆·侯赛因前往杜贾尔地区视察的时候，一伙什叶派民兵袭击了萨达姆的车队。两名萨达姆的保镖当场死亡，在其余民兵逃亡之前，萨达姆的卫队逮捕了大多数的枪手。随后，萨达姆以革命指挥委员会的名义要求伊拉克农业部收编当地的果园，随后将其铲平，以防止游击队藏匿于当地。他还下令逮捕当地的居民，不找出藏匿的凶手誓不罢休。大多数国家谴责了这次恐怖袭击。随即，伊拉克军队在强行进驻杰夫纳的清真寺时与当地居民产生了冲突，军队的机枪走火而酿成了血案，一场内战爆发了！"

const TXT_DESC_NORMAL_PRE := "随着萨达姆·侯赛因的崛起，伊拉克加大了对于潜在风险的管控。萨达姆有四大心头患：伊拉克共产党，库尔德民主党，库尔德爱国同盟与伊斯兰达瓦党。邻国因为伊斯兰主义者而掀起的暴乱既让萨达姆看到了机会，更让其恐慌。在1980年，伊斯兰达瓦党由于其强烈的反复兴主义倾向而被勒令解散，其领导人也被萨达姆政府处死。由此，达瓦党的支持者们组建了萨德尔烈士旅，号召全国什叶派教徒们展开圣战，推翻暴虐无道的复兴党政府。在萨达姆·侯赛因前往杜贾尔地区视察的时候，一伙什叶派民兵袭击了萨达姆的车队。两名萨达姆的保镖当场死亡，在其余民兵逃亡之前，萨达姆的卫队逮捕了大多数的枪手。随后，萨达姆以革命指挥委员会的名义要求伊拉克农业部收编当地的果园，随后将其铲平，以防止游击队藏匿于当地。他还下令逮捕当地的居民，不找出藏匿的凶手誓不罢休。大多数国家谴责了这次恐怖袭击，"

const TXT_DESC_NORMAL_POST := "同志，我们要做什么？"

const TXT_R_SPECIAL0 := "我们为达瓦党的起义者们提供了充足的武装和资金支持，蛰伏于南部的什叶派教众区的什叶派民兵高高举起了伊玛目阿里的旗帜，沿着两河一路北上。萨达姆加速调兵镇压，其最精锐的共和国卫队和两个库尔德人师团正在加速南下平叛，只有天晓得这场战争会怎样收场……"

const TXT_R_SPECIAL1 := "蛰伏于南部的什叶派教众区的什叶派民兵高高举起了伊玛目阿里的旗帜，沿着两河一路北上。萨达姆加速调兵镇压，其最精锐的共和国卫队和两个库尔德人师团正在加速南下平叛，只有天晓得这场战争会怎样收场……"

const TXT_R0 := "我们强烈谴责了伊斯兰主义者们针对一国元首的恐怖袭击，{0}{1}同志亲自向萨达姆·侯赛因总统致以慰问电。出于对于西北和西南部份地区的类似行径的担忧，我们必然不能选择为他们撑腰。甚至一部分保守派党员建议我们加大对当地的监控力度。\n随后，萨达姆在当地展开了堪称屠杀的清洗政策，整个村庄被夷为平地，其中还投放了化学武器。其中的居民大多被带往了臭名昭著的阿布·格莱布监狱。大多数国家选择谴责该国过激的手段。萨德尔烈士旅则以新的一轮袭击作为回敬，看起来伊拉克的局势不太妙……"

const TXT_R1 := "我们强烈谴责了伊拉克政府对其居民所开展的迫害，而萨达姆也以新的一轮谴责该国过激的手段。制裁予以回击。萨达姆决定与我国断交，并公开与蒋匪政权眉来眼去。\n随后，萨达姆在当地展开了堪称屠杀的清洗政策，整个村庄被夷为平地，其中还投放了化学武器。其中的居民大多被带往了臭名昭著的阿布·格莱布监狱。大多数国家选择谴责该国过激的手段。萨德尔烈士旅则以新的一轮袭击作为回敬，看起来伊拉克的局势不太妙……"

const TXT_R2 := "通过叙利亚和伊朗的渠道，我国训练的武装人员纷纷在各地就位，当萨达姆的武装人员将当地人押往臭名昭著的阿布·格莱布监狱之时，萨德尔烈士旅的摩托骑手强行逼停了车队，就地释放了所有囚犯。远在德黑兰的达瓦党领导层通过秘密的电台和伊朗的边境小道，号召全体民众参与到此次“圣战”当中去，萨达姆也开始调兵镇压起义。一场内战爆发了！"

const TXT_R3 := "随后，萨达姆在当地展开了堪称屠杀的清洗政策，整个村庄被夷为平地，其中还投放了化学武器。其中的居民大多被带往了臭名昭著的阿布·格莱布监狱。大多数国家选择谴责该国过激的手段。萨德尔烈士旅则以新的一轮袭击作为回敬，看起来伊拉克的局势不太妙……"

static var _opts_full: Array[EventOption] = []


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	if _opts_full.is_empty():
		for o in event_def.options:
			_opts_full.append(o)
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 1
	var done36: bool = world.completed_event_ids.has("iraqi_coalition")
	var result36: int = world.completed_event_ids.get("iraqi_coalition", -1)
	var iraq := world.get_country_by_legacy_index(14)
	var special := done36 and result36 == 3 and iraq != null and iraq.prc_power >= 80
	if special:
		event_def.description = TXT_DESC_SPECIAL
		var arr_special: Array[EventOption] = []
		arr_special.append(_opts_full[0])
		arr_special.append(_opts_full[1])
		event_def.options = arr_special
		_enable(event_def.options[0], "我们将坚定的支持伊拉克人民的斗争！")
		_enable(event_def.options[1], "尝试置身事外")
		return
	var arr: Array[EventOption] = []
	for o in _opts_full:
		arr.append(o)
	event_def.options = arr
	event_def.description = TXT_DESC_NORMAL_PRE + _leader_name(world) + TXT_DESC_NORMAL_POST
	var opt := event_def.options
	if line != 4:
		_enable(opt[0], "强烈谴责伊斯兰主义者的恐怖袭击")
	else:
		_disable(opt[0], "萨达姆可好不到哪里去")
	if line != 4:
		_enable(opt[1], "谴责伊拉克政府的国家恐怖主义行径")
	else:
		_disable(opt[1], "不要和那群大胡子走那么近！")
	var c8 := world.get_country_by_legacy_index(8)
	if c8 == null or c8.sub_government != GameConstants.SubGovernment.NEOPATRIARCHAL:
		_enable(opt[2], "我们将支持伊拉克人民的起义！")
	else:
		_disable(opt[2], "达瓦党已经孤立无援")
	_enable(opt[3], "不要干涉错综复杂的教派纠纷")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var done36: bool = ws.completed_event_ids.has("iraqi_coalition")
	var result36: int = ws.completed_event_ids.get("iraqi_coalition", -1)
	var iraq := ws.get_country_by_legacy_index(14)
	var special := done36 and result36 == 3 and iraq != null and iraq.prc_power >= 80
	var opt := int(context.get("option_index", -1))
	if special:
		# Event708.cs：特殊分支开战在 result_num 分支之前
		_start_war88(500, 500)
		if opt == 0:
			if ws.wars.size() > 88 and ws.wars[88] != null:
				ws.wars[88].infl1 += 100
				ws.wars[88].infl2 -= 100
			context["result_text"] = TXT_R_SPECIAL0
		elif opt == 1:
			context["result_text"] = TXT_R_SPECIAL1
		return
	match opt:
		0:
			_add(W.I_DIPLO, 20)
			_add_relation(EmpireData.USA, 20)
			_add_relation(EmpireData.USSR, 20)
			context["result_text"] = TXT_R0.replace("{0}{1}", _leader_name(ws))
		1:
			_add(W.I_DIPLO, 50)
			_add_relation(EmpireData.USA, -70)
			_add_relation(EmpireData.USSR, -70)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -20)
			_add(W.I_AGENTS, -20)
			_add(W.I_ARMY, -20)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			_start_war88(500, 500)
			if ws.wars.size() > 88 and ws.wars[88] != null:
				if done36 and result36 == 3 and iraq != null and iraq.prc_power < 80:
					var num := (80 - iraq.prc_power) * 5
					ws.wars[88].infl1 -= num
					ws.wars[88].infl2 += num
				else:
					ws.wars[88].infl1 = 50
					ws.wars[88].infl2 = 950
			context["result_text"] = TXT_R2
		3:
			context["result_text"] = TXT_R3


func _start_war88(infl1: int, infl2: int) -> void:
	GameManager.start_war(88, "什叶派武装", "伊拉克", infl1, infl2, 0, 0)
	if ws.wars.size() > 88 and ws.wars[88] != null:
		ws.wars[88].name_war = "伊拉克什叶派起义"
		ws.wars[88].fortnight_max = 100  # 原版 TickTime(100)




func _leader_name(world: WorldState) -> String:
	if world.leader != null and world.leader.name_display != "":
		return world.leader.name_display
	return "华国锋"
