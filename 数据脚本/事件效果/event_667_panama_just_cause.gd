extends "res://数据脚本/event_script_base.gd"

const T_667_0 := "“正义事业”行动"
const T_667_1 := "让我们将时间拉回到1977年9月，彼时，美国总统吉米·卡特与巴拿马的无冕之王奥马尔·托里霍斯将军签署了所谓《托里霍斯-卡特条约》：虽说该条约可被视为巴拿马回收国家主权的一大胜利，但条约内有关美国撤出巴拿马并移交各项资产的时间表暗示了美国仍主导移交议程的权限，而有关“运河联合防御”的附加条款更为该国重返巴拿马提供了可能。虽说卡特政府为保证美国在巴拿马的权益留了不少后门，可持强硬立场的共和党人依旧对此表示极其不满，并试图恢复美国对巴拿马运河区的绝对控制。\n而在共和党重返美国政坛，美国国际影响力衰退，且社会主义势力越加在中美地区站稳脚跟的大背景下。华盛顿决心采取更为果断的态度，确保巴拿马运河不落入“赤匪”手中——对托里霍斯政权的态度至此从冷战转向热斗。美国政府不仅谴责托里霍斯政权侵犯人权，庇护毒贩，支持共产主义，在1984年的大选上作弊。更千方百计寻找机会实施军事干预，很快，他们便找到了借口——借美国士兵在巴拿马运河处遇袭为名，美国总统批准了派兵“保护侨民”的指示，实质上是对主权国家的入侵。代号“正义事业”。"
const T_667_2 := "让我们将时间拉回到1977年9月，彼时，美国总统吉米·卡特与巴拿马的无冕之王奥马尔·托里霍斯将军签署了所谓《托里霍斯-卡特条约》：虽说该条约可被视为巴拿马回收国家主权的一大胜利，但条约内有关美国撤出巴拿马并移交各项资产的时间表暗示了美国仍主导移交议程的权限，而有关“运河联合防御”的附加条款更为该国重返巴拿马提供了可能。虽说卡特政府为保证美国在巴拿马的权益留了不少后门，可持强硬立场的共和党人依旧对此表示极其不满，并试图恢复美国对巴拿马运河区的绝对控制。\n而在共和党重返美国政坛，美国国际影响力衰退，且社会主义势力越加在中美地区站稳脚跟的大背景下。华盛顿决心采取更为果断的态度，确保巴拿马运河不落入“赤匪”手中——随着诺列加越加转向民族主义反美立场，他已然成为白宫的眼中刺，美国政府不仅谴责诺列加政权支持共产主义，勒索美国侨民，在1984年的大选上作弊。更千方百计寻找机会实施军事干预，很快，他们便找到了借口——借美国士兵在巴拿马运河处遇袭为名，美国总统批准了派兵“保护侨民”的指示，实质上是对主权国家的入侵。代号“正义事业”。"
const T_667_3 := "坚决支持巴拿马人民反抗美帝国主义的侵略"
const T_667_4 := "战争就这样爆发了"
const T_667_6 := "“正义事业”行动"
const T_667_7 := "外交部发言人对美国入侵巴拿马表示强烈谴责，并表示中国人民将同巴拿马人共进退，一同抵抗美国干涉军：“绝不允许侵略！美帝国主义从巴拿马滚出去！”。此后，巴拿马军内便出现以中国志愿者为主体的国际纵队，其装备从轻武器到重型装备为清一色中制武器。巴拿马的“人民战斗团”也被紧急动员，老弱妇孺皆全副武装，严阵以待。与此同时，古巴也派出了数个志愿军团参战，同美国人打成一团，战争就这样开始了……"
const T_667_8 := "美国入侵巴拿马"
const T_667_9 := "巴拿马"
const T_667_10 := "美国"
const T_667_11 := "很快，美国空军便轰炸了巴拿马城和科隆。其驻军也迅速越过运河区，在巴拿马国内圈地，计划和外海登陆部队里外策应，两面夹击。考虑到巴拿马与美国间实力悬殊。显然，美国的胜利不过时间问题……"
const T_667_12 := "美国入侵巴拿马"
const T_667_13 := "巴拿马"
const T_667_14 := "美国"
const T_667_16 := "外交部发言人对美国入侵巴拿马表示强烈谴责，并表示中国人民将同巴拿马人共进退，一同抵抗美国干涉军：“绝不允许侵略！美帝国主义从巴拿马滚出去！”。此后，巴拿马军内便出现以中国志愿者为主体的国际纵队，其装备从轻武器到重型装备为清一色中制武器。诺列加对此表示感激，并自然而然地倒向了我们一方。{1}"
const T_667_17 := "与此同时，奥乔亚也不愿意坐视自己的战友垮台，他宣布古巴将派出一支万人部队抵抗美国入侵，同美国人打成一团，战争就这样开始了……"
const T_667_18 := "美国入侵巴拿马"
const T_667_19 := "巴拿马"
const T_667_20 := "美国"
const T_667_21 := "很快，美国空军便轰炸了巴拿马城和科隆。其驻军也迅速越过运河区，在巴拿马国内圈地，计划和外海登陆部队里外策应，两面夹击。考虑到巴拿马与美国间实力悬殊。显然，美国的胜利不过时间问题……"
const T_667_22 := "美国入侵巴拿马"
const T_667_23 := "巴拿马"
const T_667_24 := "美国"


## 原作 Event667.cs：“正义事业”行动（巴拿马，两选项）。
## 触发：TimeScript.cs:11135-11140 —— 年>=1985 && (美国 now_leader==0 || ==2) && !巴拿马 isSEV。
## 差异：
##  - 描述按 resultOfEvents[665]==0 动态二选一。
##  - 结果里 proprc 计数 138..149 + 152；num2 看古巴(138) SubGosstroy==10。
##  - 死代码 result_num==5 跳过。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	event_def.title = T_667_0
	var r665 := int(world.completed_event_ids.get("event_665", 0))
	event_def.description = T_667_1 if r665 == 0 else T_667_2
	var opt := event_def.options
	_enable(opt[0], T_667_3)
	_enable(opt[1], T_667_4)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var panama := ws.get_country_by_legacy_index(141)
	_set_part(panama, 0, true)
	var num := 0
	for i in range(138, 150):
		var c := ws.get_country_by_legacy_index(i)
		if c != null and c.has_tag("亲中"):
			num += 1
	var c152 := ws.get_country_by_legacy_index(152)
	if c152 != null and c152.has_tag("亲中"):
		num += 1
	var r665 := int(ws.completed_event_ids.get("event_665", 0))
	var opt := int(context.get("option_index", -1))
	if r665 == 0:
		if opt == 0:
			_add_relation(EmpireData.USA, -100)
			_start_war(84, T_667_9, T_667_10, 150 + num * 20, 850 - num * 20, 1, 0, T_667_8)
			context["result_text"] = T_667_7
		elif opt == 1:
			_start_war(84, T_667_13, T_667_14, 50 + num * 20, 950 - num * 20, 1, 0, T_667_12)
			context["result_text"] = T_667_11
	else:
		var num2 := 0
		var cuba := ws.get_country_by_legacy_index(138)
		if cuba != null and cuba.sub_government == 10:
			num2 = 100
		if opt == 0:
			if panama != null:
				panama.government = 0
				panama.sub_government = 10
				panama.set_tag("对华贸易", true)
				panama.set_tag("亲中", true)
			_start_war(84, T_667_19, T_667_20, 150 + num * 20 + num2, 850 - num * 20 - num2, 1, 0, T_667_18, 4)
			var text := T_667_16
			if cuba != null and cuba.sub_government == 10:
				text = text.replace("{1}", T_667_17)
			else:
				text = text.replace("{1}", "")
			context["result_text"] = text
		elif opt == 1:
			if panama != null:
				panama.government = 0
				panama.sub_government = 10
				panama.set_tag("对华贸易", true)
				panama.set_tag("亲中", true)
			_start_war(84, T_667_23, T_667_24, 50 + num * 20 + num2, 950 - num * 20 - num2, 1, 0, T_667_22, 4)
			context["result_text"] = T_667_21


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _set_part(country: CountryData, index: int, value: bool) -> void:
	if country == null:
		return
	while country.parts.size() <= index:
		country.parts.append(false)
	country.parts[index] = value


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, war_name: String, fortnight: int = -1) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		if fortnight >= 0:
			ws.wars[war_id].fortnight_max = fortnight
