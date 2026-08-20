extends "res://数据脚本/event_script_base.gd"

## 原作 Event419.cs：正常化（二选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1351 —— ExprNode 组合。
## 差异：spec→special；Vyshi→亲美。

const TXT_TITLE := [
	"正常化",
]

const TXT_DESC := [
	"葡萄牙的局势终于稳定了下来。尽管面临长期的经济下行，通货膨胀，失业高企与频繁的政府更迭，人们对激进政治势力的热情还是走到了尽头。对葡萄牙革命委员会的压力也与日俱增——民主政党与政府已发起支持解散委员会的群众运动。毕竟，革命委员会是一个凌驾于民主体制的部门，并阻碍了该国深化改革。葡萄牙的新任民主主义政府选择加入欧洲经济共同体，并启动与其他欧洲国家的一体化进程。",
]

const TXT_OPT0 := [
	"与葡萄牙建交并发展经贸关系",
]

const TXT_OPT1 := [
	"不闻不问",
]

const TXT_R := [
	"人们还记得当年毛主席的指示：“大国从严，小国从宽，葡萄牙是小国，可以宽大处理”。然而时代变了，中国居然和这样的一个小国确立了经贸与外交往来。",
	"康乃馨革命结束了。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1351 := "正常化"
const TXT_IDX_1352 := "葡萄牙的局势终于稳定了下来。尽管面临长期的经济下行，通货膨胀，失业高企与频繁的政府更迭，人们对激进政治势力的热情还是走到了尽头。对葡萄牙革命委员会的压力也与日俱增——民主政党与政府已发起支持解散委员会的群众运动。毕竟，革命委员会是一个凌驾于民主体制的部门，并阻碍了该国深化改革。葡萄牙的新任民主主义政府选择加入欧洲经济共同体，并启动与其他欧洲国家的一体化进程。"
const TXT_IDX_1353 := "与葡萄牙建交并发展经贸关系"
const TXT_IDX_1354 := "不闻不问"
const TXT_IDX_1355 := "人们还记得当年毛主席的指示：“大国从严，小国从宽，葡萄牙是小国，可以宽大处理”。然而时代变了，中国居然和这样的一个小国确立了经贸与外交往来。"
const TXT_IDX_1356 := "康乃馨革命结束了。"

## 原文字符串附录（供自检）

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var portugal := ws.get_country_by_legacy_index(87)
	if portugal != null:
		portugal.special = 100
		portugal.government = GameConstants.Government.LIBERAL
		portugal.sub_government = GameConstants.SubGovernment.LIBERAL
		portugal.set_tag("亲美", true)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		if portugal != null:
			portugal.set_tag("对华贸易", true)
		context["result_text"] = TXT_R[0]
	else:
		context["result_text"] = TXT_R[1]
