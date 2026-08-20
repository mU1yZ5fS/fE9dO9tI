extends "res://数据脚本/event_script_base.gd"

## 原作 Event563.cs：“拯救”的悲剧（阿尔及利亚内战，3选项）。
## 触发：无自动触发（DiploButtonScript.cs:11527 外交按钮 number_event=563）。
## 差异：ingamewars[40] → GameManager.start_war。

const TXT_OPT0_DIS := "宗教分子的统治和FLN有很大区别吗？"
const TXT_OPT1_DIS := "我们不能把运动交给资产阶级！"
const TXT_OPT2_DIS := "这是不是另一个布迈丁？"
const TXT_R0 := "得益于本·杰迪德的伊斯兰化政策，我们利用民众的不满和部分极端保守的情绪，让伊斯兰救世阵线在运动中迅速获得了主导权。救世阵线开始将积极参与群众运动的民众组织成民兵，并将其与此前组织的伊斯兰主义的地下武装一起改编为伊斯兰救世军，向FLN发动“圣战”。阿尔及利亚内战开始了。"
const TXT_R1 := "出于运动中并未出现一个合格的统一自由派组织的现状，我们决定帮助早在FLN建国初期就反对建立一党制而出走另建新党社会主义革命党而被迫害流亡的民主社会主义者和建国元勋——穆罕默德·布迪亚夫，他成功将支持多党制的柏柏尔人温和左翼社会主义力量阵线和各个分散的泛自由派团体联合起来，组成了全国民主联盟。全国民主联盟打出了“面包和自由”的口号，将运动中的人民聚集到它的周围。武装的民兵开始与FLN交战。阿尔及利亚内战开始了。"
const TXT_R2 := "我们帮助社会主义先锋党、阿尔及利亚民主运动和社会主义力量阵线组成了阿尔及利亚人民民主爱国阵线。得益于大量的工人阶级对运动的参与，通过阿尔及利亚社会主义先锋党的工会组织网络和本·贝拉的阿尔及利亚民主运动发起的重建FLN早期的社会主义形式的口号，左翼得以动员大批同情马克思主义的知识分子和怀念社会主义的民众，并且争取了同为左翼的柏柏尔人的社会主义力量阵线，动员了反对FLN压迫的持左翼立场的柏柏尔人，组织起民兵与FLN交战。革命开始了。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var line := d.political_line
	if line > 0 and d.religion_policy == 29 and d.war_support >= 700:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line >= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line < 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c40 := ws.get_country_by_legacy_index(40)
	if c40 != null:
		c40.government = GameConstants.Government.AUTHORITARIAN
		c40.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
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
