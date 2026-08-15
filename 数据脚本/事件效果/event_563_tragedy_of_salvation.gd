extends "res://数据脚本/event_script_base.gd"

## 原作 Event563.cs：“拯救”的悲剧（阿尔及利亚内战，3选项）。
## 触发：无自动触发（DiploButtonScript.cs:11527 外交按钮 number_event=563）。
## 差异：ingamewars[40] → GameManager.start_war。

const TXT_TITLE := "“拯救”的悲剧"
const TXT_DESC := "自本·杰迪德接任布迈丁成为阿尔及利亚新总统后，阿尔及利亚便开始进行一系列去布迈丁化的改革，但是随着解冻带来的并不是经济的腾飞亦或者民生的改善，而是腐败、国有资产流失、通货膨胀和社会福利的下降，阿尔及利亚民族解放阵线（FLN）的一党制政府所做的已经离他们口中奉行的“社会主义”越来越远了。\n本·杰迪德失败的改革带来了一系列社会问题，随着碳氢化合物的价格的下降，维持着FLN最后一点“社会主义”牌面的福利政策无法持续，民众生活成本上升、工人阶级的失业以及FLN的寡头政治让人民越来越不满，使得80年代的阿尔及利亚并不太平——1980年、1982年和1984年该国就已爆发过多次地方性的骚乱，而反对派也随之崛起，社会正走向撕裂。在我们的特工秘密散发了关于阿尔及利亚将进行新一轮改革削减福利和社会投入的传单后，随后引发了小型的示威，在军队维持秩序时，一名士兵失火击伤了群众，使得局势一发不可收拾。动乱从各大高校和工人阶级社区为起点，向外蔓延，群众运动的火焰烧遍了该国北部的各大主要城市，人们借鉴前几次运动的经验，筑起街垒，占领各大重要的公共建筑同FLN当局进行对抗，并喊着各种口号——“本·贝拉”、“布迈丁”、“社会主义革命”以及“圣战”——反对派并未形成一派核心，其主要以近期崛起的伊斯兰救世阵线、松散的各类泛自由派团体、共产主义的社会主义先锋党和本·贝拉的左翼政党阿尔及利亚民主运动以及柏柏尔人的温和左翼政党社会主义力量阵线为首。\n与此同时，由于局势混乱，军队内的不满本·杰迪德的异见者同FLN保守派的乌季达帮的残余分子串联起来，希望用乌季达帮的布迈丁象征平息骚乱，遂发动了一场政变，但很快，本·杰迪德便带领忠于他的军队进行了一场反政变，并在随后宣布国家进入紧急状态，开始镇压民众起义。改变的最后希望已经消失了，而反对派开始各自将群众组织起来，对抗政府的镇压一场内战开始了！我们将可以干预其中，帮助其中的某一派成为反对派的主导力量。"
const TXT_OPT0 := "我们将支持伊斯兰救世阵线的伟大圣战！"
const TXT_OPT0_DIS := "宗教分子的统治和FLN有很大区别吗？"
const TXT_OPT1 := "我们将支持阿尔及利亚人民追求真正的自由！"
const TXT_OPT1_DIS := "我们不能把运动交给资产阶级！"
const TXT_OPT2 := "我们将支持阿尔及利亚人民重新开展人民革命！"
const TXT_OPT2_DIS := "这是不是另一个布迈丁？"
const TXT_R0 := "得益于本·杰迪德的伊斯兰化政策，我们利用民众的不满和部分极端保守的情绪，让伊斯兰救世阵线在运动中迅速获得了主导权。救世阵线开始将积极参与群众运动的民众组织成民兵，并将其与此前组织的伊斯兰主义的地下武装一起改编为伊斯兰救世军，向FLN发动“圣战”。阿尔及利亚内战开始了。"
const TXT_R1 := "出于运动中并未出现一个合格的统一自由派组织的现状，我们决定帮助早在FLN建国初期就反对建立一党制而出走另建新党社会主义革命党而被迫害流亡的民主社会主义者和建国元勋——穆罕默德·布迪亚夫，他成功将支持多党制的柏柏尔人温和左翼社会主义力量阵线和各个分散的泛自由派团体联合起来，组成了全国民主联盟。全国民主联盟打出了“面包和自由”的口号，将运动中的人民聚集到它的周围。武装的民兵开始与FLN交战。阿尔及利亚内战开始了。"
const TXT_R2 := "我们帮助社会主义先锋党、阿尔及利亚民主运动和社会主义力量阵线组成了阿尔及利亚人民民主爱国阵线。得益于大量的工人阶级对运动的参与，通过阿尔及利亚社会主义先锋党的工会组织网络和本·贝拉的阿尔及利亚民主运动发起的重建FLN早期的社会主义形式的口号，左翼得以动员大批同情马克思主义的知识分子和怀念社会主义的民众，并且争取了同为左翼的柏柏尔人的社会主义力量阵线，动员了反对FLN压迫的持左翼立场的柏柏尔人，组织起民兵与FLN交战。革命开始了。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var line := d[W.I_POLITICAL_LINE]
	if line > 0 and d[W.I_RELIGION] == 29 and d[W.I_WAR_SUPPORT] >= 700:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line >= 2:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line < 2:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c40 := ws.get_country_by_legacy_index(40)
	if c40 != null:
		c40.government = 0
		c40.sub_government = 7
		c40.set_tag("对华贸易", false)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_start_war40("伊斯兰救世阵线", 0, 0)
			_add_relation(EmpireData.USA, -500)
			_add_relation(EmpireData.USSR, -500)
			context["result_text"] = TXT_R0
		1:
			_start_war40("全国民主联盟", 1, 0)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, -500)
			context["result_text"] = TXT_R1
		2:
			_start_war40("人民民主爱国阵线", 0, 1)
			_add_relation(EmpireData.USSR, 150)
			_add_relation(EmpireData.USA, -500)
			context["result_text"] = TXT_R2


func _start_war40(side2: String, usa_side: int, ussr_side: int) -> void:
	GameManager.start_war(40, "FLN", side2, 700, 300, usa_side, ussr_side)
	if ws.wars.size() > 40 and ws.wars[40] != null:
		ws.wars[40].name_war = "阿尔及利亚内战"
		ws.wars[40].fortnight_max = 20
