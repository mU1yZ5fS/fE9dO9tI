extends "res://数据脚本/event_script_base.gd"

const T_660_0 := "七丘之城的新狄克推多"
const T_660_1 := "经过艰苦的武装斗争，乌干达的人民战争已经从游击战转入了运动战阶段，全国抵抗军不仅控制了卢韦罗三角地带解放区，发展到数千名游击队员的规模，还在弗雷德·鲁维吉耶马指挥官的带领下在乌干达西部的鲁文佐里山地区开辟了第二战场。与之相反，政府军则是遭遇了多次重大失败，且由于奥博特对全国抵抗军的西征行动作出的错误判断导致主力部队在围剿时受到重创。精锐部队的失败给政府军带来了巨大的心理打击，至此，政府军彻底军心涣散，无力再组织起对全国抵抗军的围剿。\n令人始料未及的是，在接连惨败于全国抵抗军后，由于军事失败、政治前景黯淡，与政府军内部的兰戈派和阿乔利派矛盾，最终引爆了奥博特集团的内部分裂，以乌干达民族解放军司令蒂托·奥凯洛将军与另一名阿乔利人高级军官、精锐的第十旅旅长巴西里奥·奥凯洛准将联手阿明旧部，从阿乔利人的大本营古卢向首都坎帕拉进军，在经过了数日激烈交战后，政变军人彻底控制了这座乌干达的七丘之城，奥博特又一次被迫流亡。政变成功后，军事委员会暂停了宪法，解散了议会，并罢免了所有政府部长。新政府以蒂托·奥凯洛为总统，巴西里奥·奥凯洛为总参谋长。为了改变被动的军事局面，巩固自己岌岌可危的地位，新的军政府呼吁各反政府武装停火，同他们一道共商国是。"
const T_660_2 := "对政变不予置评"
const T_660_3 := "发动战略反攻，一股作气，打到坎帕拉去！"
const T_660_4 := "我们没必要支持他们"
const T_660_6 := "七丘之城的新狄克推多"
const T_660_7 := "乌干达内战"
const T_660_8 := "全国抵抗军"
const T_660_9 := "政府军"
const T_660_10 := "乌干达似乎没有比政变前更接近和平。发出和谈呼吁后，政变集团成功借助自己反奥博特的立场笼络到了其他政治与军事势力，组建起了自己的政治同盟。协助奥凯洛发动政变的阿明残军自然加盟其中，而民主党、卡伊拉的乌干达自由运动和从其中分裂出来的联邦民主运动也在枪杆子的威逼和高官厚禄的利诱下再次同压迫者站在了一起。然而，政府内部各派在意识形态、宗教、部族等层面都存在严重分歧，蒂托·奥凯洛也并不是一个能够将各方力量凝聚在一起的强力领袖，这导致新政权依旧软弱无能、效率低下。政府军的军纪也并没有比奥博特时代好多少，甚至有增无减，步入了失控状态。\n对于与全国抵抗军在肯尼亚首都内罗毕进行的和谈，奥凯洛政府也并不热衷，在一方面与穆塞韦尼于内罗毕展开会谈的同时，政府军仍旧在对全国抵抗军进行攻击，这种出尔反尔的行为与奥凯洛吸纳阿明旧部的行径在政府军内引起了普遍不满，再加上许多其他部族的军人被夹在了阿乔利派与兰戈派的冲突中，越来越多的军队向全国抵抗军投诚。而在卡塞塞地区的守军也宣布效忠全国抵抗军后，该组织已一举控制三大解放区，终于有能力发动全国解放战争，乌干达的人民战争进入了最后阶段——阵地战。"
const T_660_11 := "乌干达内战"
const T_660_12 := "全国抵抗军"
const T_660_13 := "政府军"
const T_660_14 := "乌干达似乎没有比政变前更接近和平。发出和谈呼吁后，政变集团成功借助自己反奥博特的立场笼络到了其他政治与军事势力，组建起了自己的政治同盟。协助奥凯洛发动政变的阿明残军自然加盟其中，而民主党、卡伊拉的乌干达自由运动和从其中分裂出来的联邦民主运动也在枪杆子的威逼和高官厚禄的利诱下再次同压迫者站在了一起。然而，政府内部各派在意识形态、宗教、部族等层面都存在严重分歧，蒂托·奥凯洛也并不是一个能够将各方力量凝聚在一起的强力领袖，这导致新政权依旧软弱无能、效率低下。政府军的军纪也并没有比奥博特时代好多少，甚至有增无减，步入了失控状态。\n对于与全国抵抗军在肯尼亚首都内罗毕进行的和谈，奥凯洛政府也并不热衷，在一方面与穆塞韦尼于内罗毕展开会谈的同时，政府军仍旧在对全国抵抗军进行攻击，这种出尔反尔的行为与奥凯洛吸纳阿明旧部的行径在政府军内引起了普遍不满，再加上许多其他部族的军人被夹在了阿乔利派与兰戈派的冲突中，越来越多的军队向全国抵抗军投诚。而在卡塞塞地区的守军也宣布效忠全国抵抗军后，该组织已一举控制三大解放区，终于有能力发动全国解放战争，乌干达的人民战争进入了最后阶段——阵地战。"


## 原作 Event660.cs：七丘之城的新狄克推多（乌干达，两选项）。
## 触发：TimeScript.cs:11100-11105 —— 日期(>=1985.7.30)&&resultOfEvents[659]<3
##   || (乌干达 inflCh>800 && !event_done[661])。
## 差异：
##  - inflCh 字段（原版 Country.inflCh → CountryData.influence_china）ExprNode 暂不支持，
##    触发条件走 EventDef.trigger_script（本脚本 evaluate）。
##  - 死代码 result_num==5 跳过。

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world
	if data.size() <= W.I_YEAR:
		return false
	var date_ok := (data.year >= 1985 and data.month >= 7 and data.day >= 30) \
			or (data.year >= 1985 and data.month >= 8) \
			or data.year >= 1986
	var r659 := int(world.completed_event_ids.get("event_659", 0))
	if date_ok and r659 < 3:
		return true
	var uganda := world.get_country_by_legacy_index(118)
	if uganda != null and uganda.influence_china > 800 and not world.completed_event_ids.has("event_661"):
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	event_def.title = T_660_0
	event_def.description = T_660_1
	var r659 := int(world.completed_event_ids.get("event_659", 0))
	var opt := event_def.options
	_enable(opt[0], T_660_2)
	if r659 == 2:
		_enable(opt[1], T_660_3)
	else:
		_disable(opt[1], T_660_4)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uganda := ws.get_country_by_legacy_index(118)
	_set_part(uganda, 0, true)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_start_war(81, T_660_8, T_660_9, 700, 300, 0, 0, T_660_7)
			context["result_text"] = T_660_10
		1:
			_start_war(81, T_660_12, T_660_13, 800, 200, 0, 0, T_660_11)
			context["result_text"] = T_660_14




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
