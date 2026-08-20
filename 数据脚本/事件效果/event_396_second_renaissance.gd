extends "res://数据脚本/event_script_base.gd"

## 原作 Event396.cs：第二次“复兴运动”（意大利全面内战，一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1231 —— 复杂条件用 evaluate（data.italian_radical_left_power>200 无命名键）。
## 差异：KGWar 开战映射 game.start_war；AmericanSupportDefender→usa_side = GameConstants.WarSide.SIDE1；
##  - 若 c1 非 sev 则 ussr_side = GameConstants.WarSide.SIDE2；TickTime(30)→fortnight_max=30。

const TXT_TITLE := [
	"第二次“复兴运动”",
]

const TXT_DESC := [
	"激进派恐怖组织的壮大与左右两侧对意大利当局的联合夹击终于推倒了支撑意大利体制的最后一根稻草。该国公务员体系已因接连不断的恐怖袭击而走向瘫痪，导致无政府状态事实上席卷全国。而警方和卡宾枪骑兵亦在城市游击队挥出的狂风骤雨重拳前难以招架，不得不从军方内借调精华以充实自身队伍。先前气势汹汹的弗朗切斯科·科西加政权事实上被恐怖组织的持续打击蛀成了“蜂窝”，仅能依靠本土军事设施和北约驻军基地两类据点实施坚守政策，并将战略重心放在保卫主要城市与经济发达地区上。如此局势让激进派群体们得以乘胜追击——他们不仅利用了作为该国老生常谈的“南方问题”，成功将两西西里王国的故土与黑手党故乡改造为了恐怖主义的司令部；更在北方的中小城市内启动占领社会运动，直截了当地掏空了当地政府并筹建新国家机关。当前的意大利已然朝着往日神圣罗马帝国时代的碎片化格局持续狂奔，至此陷入全面内战当中。起义者们已经打出“不破不立，复兴加里波第遗志，实现民族完全统一”的大旗。对此，作为该国铁腕人物的弗朗切斯科·科西加决定立即引入动员令，并在调动各地武装力量平叛的同时呼吁国际支持。而这自然引来了超级大国的特别关注：美国与其盟友显然选择直截了当地支持当局，在派出支援部队、增强自身驻地中海军事存在的同时建议科西加立即采取麦克阿瑟在首都教训顽童们的老一套。苏联则在谴责恐怖主义运动同时对科西加政权旁敲侧击，宣称只有在成立囊括该国所有政党的统一政府并以恢复民主制度的方式重振政府合法性时，意大利才可能在重建政治共识的基础上铲除滋生恐怖主义的温床。不论如何，这个欧洲大国都已陷入混战泥潭而万劫不复。",
]

const TXT_OPT0 := [
	"战争即地狱？",
]

const TXT_R := [
	"“风云突变，军阀重开战。洒向人间都是怨，一枕黄粱再现。”——毛泽东",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1107 := "战争即地狱？"
const TXT_IDX_1110 := "激进派"
const TXT_IDX_1111 := "政府军"

## 原文字符串附录（供自检）
## 第二次“复兴运动”
## 激进派恐怖组织的壮大与左右两侧对意大利当局的联合夹击终于推倒了支撑意大利体制的最后一根稻草。该国公务员体系已因接连不断的恐怖袭击而走向瘫痪，导致无政府状态事实上席卷全国。而警方和卡宾枪骑兵亦在城市游击队挥出的狂风骤雨重拳前难以招架，不得不从军方内借调精华以充实自身队伍。先前气势汹汹的弗朗切斯科·科西加政权事实上被恐怖组织的持续打击蛀成了“蜂窝”，仅能依靠本土军事设施和北约驻军基地两类据点实施坚守政策，并将战略重心放在保卫主要城市与经济发达地区上。如此局势让激进派群体们得以乘胜追击——他们不仅利用了作为该国老生常谈的“南方问题”，成功将两西西里王国的故土与黑手党故乡改造为了恐怖主义的司令部；更在北方的中小城市内启动占领社会运动，直截了当地掏空了当地政府并筹建新国家机关。当前的意大利已然朝着往日神圣罗马帝国时代的碎片化格局持续狂奔，至此陷入全面内战当中。起义者们已经打出“不破不立，复兴加里波第遗志，实现民族完全统一”的大旗。对此，作为该国铁腕人物的弗朗切斯科·科西加决定立即引入动员令，并在调动各地武装力量平叛的同时呼吁国际支持。而这自然引来了超级大国的特别关注：美国与其盟友显然选择直截了当地支持当局，在派出支援部队、增强自身驻地中海军事存在的同时建议科西加立即采取麦克阿瑟在首都教训顽童们的老一套。苏联则在谴责恐怖主义运动同时对科西加政权旁敲侧击，宣称只有在成立囊括该国所有政党的统一政府并以恢复民主制度的方式重振政府合法性时，意大利才可能在重建政治共识的基础上铲除滋生恐怖主义的温床。不论如何，这个欧洲大国都已陷入混战泥潭而万劫不复。
## “风云突变，军阀重开战。洒向人间都是怨，一枕黄粱再现。”——毛泽东
## “第二次复兴运动”

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() <= 134:
		return false
	if world.completed_event_ids.has("event_396"):
		return false
	if int(world.completed_event_ids.get("event_395", 0)) == 2:
		return false
	if world.completed_event_ids.has("event_556"):
		return false
	var italy := world.get_country_by_legacy_index(85)
	if italy == null:
		return false
	if not italy.政变中:
		return false
	if italy.内战中:
		return false
	if italy.level_of_development >= 20:
		return false
	return d.italian_radical_left_power > 200

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	_add_power(EmpireData.USA, -10)
	var num := 0
	for cid in [21, 86, 87, 17, 92]:
		var c := ws.get_country_by_legacy_index(cid)
		if c == null:
			continue
		if c.has_tag("eu"):
			num += 20
		if c.has_tag("nato"):
			num += 100
	if ws.is_socialism(ws.get_country_by_legacy_index(30), false) and ws.get_flag("oar"):
		num -= 100
	num -= (_raw(134) - 200) * 5
	game.start_war(23, "激进派", "政府军", 200 - num, 800 + num, 0, -1)
	if ws.wars.size() > 23 and ws.wars[23] != null:
		ws.wars[23].name_war = "“第二次复兴运动”"
		ws.wars[23].fortnight_max = 30
	var china := ws.get_country_by_legacy_index(1)
	if china != null and not china.has_tag("sev"):
		if ws.wars.size() > 23 and ws.wars[23] != null:
			ws.wars[23].ussr_side = GameConstants.WarSide.SIDE2
	if italy != null:
		italy.special -= 15
	context["result_text"] = TXT_R[0]

func _raw(i: int) -> int:
	if d.size() > i:
		return d.get_data_by_index(i)
	return 0
