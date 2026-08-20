extends "res://数据脚本/event_script_base.gd"

## 原作 Event450.cs：永恒之光（伊朗反神权武装，三选项）。
## 触发：ReqEventForDLC02.cs:372-374 —— event_done[447] && !event_done[448] && !iranrev
##   && ingamewars[3].is_going && DATE_AFTER 1982.5.1；fire_only_once 承担 !event_done[450]。
## 差异：iranrev→global_flags；战争3为既有两伊战争；结果0按 SubGosstroy 动态插入领袖名。

const TXT_DESC_NCRI := "自伊朗——伊拉克爆发大规模冲突以来，拉贾维和前总统巴尼萨德尔的伊朗全国抵抗委员会NCRI，已融入了包括人民圣战者，库尔德斯坦民主党，民族阵线、共产主义者联盟等倒霍力量。虽然其人数众多，但缺少强有力的支持。而伊拉克同时也陷入了和伊朗的堑壕战中，如果能得到NCRI，那么对于快速结束两伊战争也会有很大帮助。而随着伊拉克倒向我们，也许组建一支伊朗人自己的反神权武装力量或许也是可行的？"
const TXT_DESC_BAZARGAN := "自伊朗——伊拉克爆发大规模冲突以来，普兰·巴扎尔甘和前总统巴尼萨德尔的伊朗人民革命阵线，已融入了包括人民敢死游击队（德赫加尼派），伊朗人民敢死游击队组织（少数派），工人阶级解放斗争组织（佩卡尔），伊朗共产主义者联盟，伊朗劳动者党，伊朗劳动党（风暴）等组织和其他小型共产主义团体，以及库尔德民主党和俾路支解放阵线等力量。虽然其人数众多，但缺少强有力的支持。而伊拉克同时也陷入了和伊朗的堑壕战中，如果能得到革命阵线，那么对于快速结束两伊战争也会有很大帮助。而随着伊拉克倒向我们，也许组建一支伊朗人自己的反神权武装力量或许也是可行的？"
const TXT_DESC_HAVARI := "自伊朗——伊拉克爆发大规模冲突以来，阿里·哈瓦里和前总统巴尼萨德尔的伊朗人民革命阵线，已融入了伊朗人民党，人民敢死游击队组织（多数派），库尔德抵抗运动等力量。虽然其人数众多，但缺少强有力的支持。而伊拉克同时也陷入了和伊朗的堑壕战中，如果能得到革命阵线，那么对于快速结束两伊战争也会有很大帮助。而随着伊拉克倒向我们，也许组建一支伊朗人自己的反神权武装力量或许也是可行的？"
const TXT_OPT0_DIS := "这是否太激进了？"
const TXT_OPT1_DIS_A := "为什么我们要把自己变得像帝国主义者一样？"
const TXT_OPT1_DIS_B := "没有人会支持我们把轰炸机开到伊朗上空去！"
const TXT_R0_NAME_NCRI := "拉贾维"
const TXT_R0_NAME_BAZARGAN := "普兰·巴扎尔甘"
const TXT_R0_NAME_OTHER := "阿里·哈瓦里"
const TXT_R0_FMT := "在我国驻巴格达领事的安排下，{0}和伊拉克领导人就展开合作达成了协定。中国将通过伊拉克为伊朗民族解放军提供武器，而伊拉克领导人则负责提供营地。很快，在建筑工人和中国教官的帮助下，阿什拉夫营地——一个有上万人的大型社区兼军事基地拔地而起。伊朗民族解放军宣布不再躲藏，是时候夺回属于人民的伊朗了！"
const TXT_R1_FMT := "在巴基斯坦和伊拉克方面的支持下，中国人民解放军的轰-6和强-5型攻击机对伊朗的数个战略目标展开了战略轰炸。德黑兰，设拉子，大不里士等城市受损的尤为严重。{0}的战士们从四面八方攻入伊朗国内。尤其是在胡齐斯坦省，驻扎于此的伊朗第77师几乎被全歼，11000名伊朗陆军和革命卫队成员被杀，2000名被俘虏，而{0}方面受损不超过300人。取得了超越伊拉克军队的战绩，伊朗也因此元气大伤，看起来战争马上就要结束了。但与此同时，美国方面对我们的“暴行”表示了强烈不满，可他们在轰炸越南的时候为什么不多些怜悯？帝国主义者的双重标准真是令人作呕！"
const TXT_ARG_NCRI := "NCRI"
const TXT_ARG_OTHER := "伊朗人民革命阵线"
const TXT_R2 := "直接和伊朗人闹翻实在是太不必要了，让别人头痛去吧，别烦我！"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	var iran := world.get_country_by_legacy_index(14)
	if event_def == null or iran == null or event_def.options.size() < 3:
		return
	var line56 := 0
	if world.数值表.size() > W.I_POLITICAL_LINE:
		line56 = world.数值表[W.I_POLITICAL_LINE]
	var opt := event_def.options
	if line56 <= 1 and iran.has_tag("亲中"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	var pak := world.get_country_by_legacy_index(31)
	var china := world.get_country_by_legacy_index(1)
	if line56 < 1 and pak != null and pak.has_tag("亲中") and iran.has_tag("亲中") and china != null and china.has_tag("okb"):
		_enable(opt[1], event_def.options[1].text)
	elif line56 > 1:
		_disable(opt[1], TXT_OPT1_DIS_A)
	else:
		_disable(opt[1], TXT_OPT1_DIS_B)
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var iran := _country(14)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var leader := TXT_R0_NAME_OTHER
			if iran != null and iran.sub_government == 10:
				leader = TXT_R0_NAME_NCRI
			elif iran != null and iran.sub_government == 2:
				leader = TXT_R0_NAME_BAZARGAN
			context["result_text"] = TXT_R0_FMT.format([leader])
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -50)
			_add(W.I_ARMY, -100)
			_add(W.I_DIPLO, 50)
			_add_relation(EmpireData.USA, -150)
			ws.set_flag("iranrev", true)
		1:
			var arg := TXT_ARG_OTHER
			if iran != null and iran.sub_government == 10:
				arg = TXT_ARG_NCRI
			context["result_text"] = TXT_R1_FMT.format([arg, arg])
			_add(W.I_ARMY, -200)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -200)
			_add(W.I_DIPLO, 80)
			ws.influence_prc += 80
			_add_relation(EmpireData.USA, -300)
			var war := _get_war(3)
			if war != null:
				war.infl1 += 300
				war.infl2 -= 300
		2:
			context["result_text"] = TXT_R2




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)


func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


