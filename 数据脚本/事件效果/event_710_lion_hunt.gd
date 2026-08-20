extends "res://数据脚本/event_script_base.gd"

## 原作 Event710.cs：“猎狮”行动（伊拉克入侵叙利亚，两选项）。
## 触发：event_710_trigger.gd（TimeScript.cs:10580-10586）。
## 效果：c35.parts[1]=true；ingamewars[89] 叙利亚-伊拉克战争：
##   选项0 AttackerInfluence 350/Defender 650；选项1 250/750；
##   均 AmericanSupportAttacker + SovietSupportDefender（→ usa_side=0, ussr_side=1）
##   且 TickTime(24)（→ fortnight_max=24）。
## 差异：描述按 c35.SubGosstroy==15||10 分支；else 分支 {0}=c35.name
##   （Godot 用 name，空则 chinese_name）。

const TXT_DESC_A := "在萨达姆·侯赛因彻底扫清自己的政治对手，在外战上击溃了长期以来的强敌伊朗，粉碎了埃米尔们的抵抗并让圣地的捍卫者臣服后，伊拉克的复兴主义者就开始打起了自己一贯的老对手，复兴党叙利亚支部的主意。自两伊战争爆发以来，不，自阿萨德上台以来，两国的关系便迅速降温。尤其是在和伊朗的战争期间，叙利亚多次暗戳戳的表示对伊斯兰共和国的支持。其于美国的良好关系更是让一贯以反美战士自居的萨达姆恨的牙痒痒。但现在，一切都不一样了。"

const TXT_DESC_B := "在萨达姆·侯赛因彻底扫清自己的政治对手，在外战上击溃了长期以来的强敌伊朗后，伊拉克共和国决定将目光放在自己的邻国，政治动荡而混乱的"

const TXT_DESC_TAIL := "上。在惨痛的内战结束后，大批前政府军害怕遭到新政府的清算从而跨过了幼发拉底河，来到了该国与伊拉克的边境线并投诚。同时，萨达姆也希望复刻在伊朗的赫赫战果，一句击碎这个刺头。考虑到叙利亚更为弱小且并没有伊朗同等级的战略纵深，弱小的叙利亚似乎没有什么胜算。共和国卫队，萨达姆敢死队和伊拉克陆军正在加速往两国的边境调动。战略侦察机和军事卫星监视着伊拉克军队和导弹部队加速向该国北部的重要城市调动。战争已经只是时间问题了。"

const TXT_R0 := "共和国总统，革命委员会主席，兄弟萨达姆侯赛因在宣战节目上如是说道：“叙利亚领导层事实上就是一群伙通外国的贼人。在伊拉克人民加入到全体阿拉伯人民抗击锡安主义者侵略的时候，叙利亚人无动于衷；在伊拉克人民誓死保卫自己的领土的时候，叙利亚人在我们背后捅刀子；在我们抗击美帝国主义者侵略半岛的先锋的时候，叙利亚人再次辜负了我们。现在，是时候了难道这不正是令我们感到自豪的一件事吗？成千上万的伊拉克人在与波斯人的战斗中壮烈牺牲，我们为捍卫叙利亚的领土损失了大量英雄；而叙利亚在1967年只失去了137名叙利亚烈士，但叙利亚却失去了戈兰高地。我们不只会付出成干上万，而是会付出数百万的代价，我的兄弟们，因为这是我们的「骄傲」。最惨痛的损失不是失去烈士的鲜血，而是失去领土，失去国家主权和尊严。如果这场战争能够唤醒叙利亚人民的抵抗，那也好，向我们证明叙利亚人还有勇士吧！”\n伊朗总统，马苏德·拉贾维公开谴责了叙利亚的不作为，并公开站队萨达姆。巴勒斯坦人和约旦人则态度暧昧，黎巴嫩政府强烈谴责了叙利亚的干涉主义，并呼吁萨达姆·侯赛因为其主持正义。\n伊拉克的战斗机携带着机炮和炸弹飞向大马士革，代尔祖尔和阿勒颇等地，坦克和步战车越过防线，战争开始了。"

const TXT_R1_PRE := "在战争开始前，我们紧急通过巴基斯坦—伊朗方面为伊拉克共和国提供了我国最新型的坦克，战斗机和大批的军事教官与志愿军。旨在检验这些大家伙们的第一次实战演习，我们也以优惠的价格向伊拉克提供与苏联品质相当的军火。随着伊拉克被美苏双方禁运，他们将更需要我们的武器。萨达姆·侯赛因公开称呼{0}{1}主席为“我最亲爱的朋友{0}{1}”，并答应了在战争结束后为我国提供低价的原油。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var syria := world.get_country_by_legacy_index(35)
	if syria != null and (syria.sub_government == GameConstants.SubGovernment.PRAGMATIST or syria.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST):
		event_def.description = TXT_DESC_A + TXT_DESC_TAIL
	else:
		var syria_name := ""
		if syria != null:
			syria_name = syria.name if syria.name != "" else syria.chinese_name
		event_def.description = TXT_DESC_B + syria_name + TXT_DESC_TAIL


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var syria := ws.get_country_by_legacy_index(35)
	if syria != null:
		_syria_parts_set(syria, 1, true)
	var opt := int(context.get("option_index", -1))
	var leader_name := _leader_name()
	if opt == 0:
		_start_war(350, 650)
		context["result_text"] = TXT_R0
	elif opt == 1:
		_start_war(250, 750)
		context["result_text"] = TXT_R1_PRE.replace("{0}{1}", leader_name) + "\n" + TXT_R0


func _start_war(infl1: int, infl2: int) -> void:
	# Event710.cs：AmericanSupportAttacker.SovietSupportDefender.TickTime(24)
	GameManager.start_war(89, "叙利亚", "伊拉克", infl1, infl2, 0, 1)
	if ws.wars.size() > 89 and ws.wars[89] != null:
		ws.wars[89].name_war = "叙利亚-伊拉克战争"
		ws.wars[89].fortnight_max = 24


func _syria_parts_set(syria: CountryData, index: int, value: bool) -> void:
	while syria.parts.size() <= index:
		syria.parts.append(false)
	syria.parts[index] = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
