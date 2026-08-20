extends "res://数据脚本/event_script_base.gd"

## 原作 Event431.cs：西班牙加入欧洲经济共同体（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1414-1416 —— ExprNode 组合。
## 差异：Gosstroy→government；SubGosstroy→sub_government；isEU→标签 eu。

const TXT_RESULT := "54%的西班牙人在投票中支持加入欧洲经济共同体。该国就此拥抱了欧洲一体化的道路。为了加入欧洲共同体，西班牙社会党人不得不在意识形态与实践上做出妥协：退休年龄被延迟，政府减少对经济的干预，中央银行的独立权限扩大，社会支出也被减少。出于适应上述变化的需要，该党将党纲内所有与马克思主义和无产阶级有关的内容删除殆尽。"
const TXT_IDX_1450 := "西班牙加入欧洲经济共同体"
const TXT_IDX_1451 := "西班牙工人社会党对欧洲一体化的态度发生了显著转变。如果说在之前，该党还会在马克思主义意识形态的影响下，将这样的联盟称之为“隐蔽的帝国主义”，而现在，社会党人则成为了加入欧洲经济共同体的排头兵。然而对他们来说，与他们结成执政联盟的共产党人是他们在当前局势下的最大挑战。共产党人绝对不会冒这个险。因此，冈萨雷斯不得不重新召开议会选举，从而让社会党人在其中获得绝对多数。\n在此之后，该国就加入欧洲经济共同体的问题举行了一场全民公投。而许多政治力量，包括来自左翼与右翼的激进派，呼吁反对该国的一体化进程。但结果会如何呢？"
const TXT_IDX_1380 := "观察局势"
const TXT_IDX_1452 := "54%的西班牙人在投票中支持加入欧洲经济共同体。该国就此拥抱了欧洲一体化的道路。为了加入欧洲共同体，西班牙社会党人不得不在意识形态与实践上做出妥协：退休年龄被延迟，政府减少对经济的干预，中央银行的独立权限扩大，社会支出也被减少。出于适应上述变化的需要，该党将党纲内所有与马克思主义和无产阶级有关的内容删除殆尽。"



func _raw(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0






func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s





func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, war_name: String, fortnight: int) -> void:
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var spain := ws.get_country_by_legacy_index(86)
	if spain != null:
		spain.government = GameConstants.Government.LIBERAL
		spain.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		spain.set_tag("eu", true)
	context["result_text"] = TXT_RESULT
