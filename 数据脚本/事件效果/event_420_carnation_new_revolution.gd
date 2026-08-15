extends "res://数据脚本/event_script_base.gd"

## 原作 Event420.cs：康乃“新”革命？（三选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1356 —— ExprNode 组合。
## 差异：spec→special；data[131] raw；Vyshi→亲美；prosov→亲苏；proprc→亲中。

const TXT_TITLE := [
	"康乃“新”革命？",
]

const TXT_DESC := [
	"六年时间过去了，葡萄牙的民主体制依然活在动荡之中。中左翼政府与中右翼政府如走马灯般频繁更迭，然而他们都不足以解决该国自旧体制下延续的社会经济问题，以及最终完成去殖民化的任务。政治不稳定为该国局势火上浇油——激进左右翼势力频繁发动恐怖袭击与各类反政府行动，从而严重打击了现政府在人民眼中的人气。民主派政治家设法激起公众对革命委员会的不满，并宣称后者“高居于民主政体之上，阻碍政治现代化”。然而，尽管其权力受到限制，但军方还是成功抵挡住了对自己的进攻。议会内的激进政党也越加强势。在他们的压力下，新加入葡萄牙革命委员会的军官均是极端反对当局自由主义政策的成员。以贡萨尔维斯与萨赖瓦·德卡瓦略为代表的极左翼政治家们纷纷回归。同时登场的还有极右翼反共产主义组织的领导人阿尔波因·卡尔万与斯皮诺拉。革命委员会正变得日益撕裂且激进化，政治家相互指责对方背叛了康乃馨革命。社会内也传出了军方将再度接管政权，重建国家秩序的流言。但这次，我们将如何干预葡萄牙？",
]

const TXT_OPT0 := [
	"支持左翼团体（需要20.0百万预算与25.0点特工网络）",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......",
]

const TXT_OPT1 := [
	"支持右翼团体（需要20.0百万预算与25.0点特工网络）",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......",
]

const TXT_OPT2 := [
	"保持观望",
]

const TXT_R := [
	"里斯本爆发政变！根据《1976年宪法》，在革命委员会有权宣布一切法案违宪的情况下。为了应对政府颁布的有关解散革命委员会的法令。委员会宣称“政府长期向激进左派让步妥协，并将国家带到了内战的边缘”。军方拿下了首都的主要行政建筑，宣布推翻政府，并逮捕了那些没能逃出本国的行政部长们。右翼激进派与反共产主义势力纷纷支持政变。该国建立了由阿尔波因·卡尔万领导，斯皮诺拉任总统的新政府。葡萄牙新当局宣布将修改《1976年宪法》、对被没收财产进行再分配并奉行独立外交政策。第一步便是完全退出北大西洋公约组织的军事与政治框架。",
	"里斯本爆发政变！根据《1976年宪法》，在革命委员会有权宣布一切法案违宪的情况下。为了应对政府颁布的有关解散革命委员会的法令。委员会宣称“政府背叛了1974年革命的理想，站在反革命营垒中，试图摧毁革命为该国带来的社会主义成就”。在共产党领导的工会和军队内左翼的支持下，军方拿下了首都的主要行政建筑，宣布推翻政府，并逮捕了那些没能逃出本国的行政部长们。军队内左翼最终与葡萄牙共产党合并改组成了新的葡萄牙共产党，该国军队开始改组为人民军，并将彻底清洗右翼分子。新的革命政府则由瓦斯科·贡萨尔维斯和葡共总书记阿尔瓦罗·库尼亚尔共同领导。葡萄牙新当局宣布将在国内建设社会主义、实行民主改革并加强与苏东阵营的合作。第一步便是完全退出北大西洋公约组织的军事与政治框架。",
	"里斯本爆发政变！根据《1976年宪法》，在革命委员会有权宣布一切法案违宪的情况下。为了应对政府颁布的有关解散革命委员会的法令。委员会宣称“政府背叛了1974年革命的理想，站在反革命营垒中，试图摧毁革命为该国带来的社会主义成就”。在“全球项目”领导的城市游击队和工会以及军队内左翼的支持下，军方拿下了首都的主要行政建筑，宣布推翻政府，并逮捕了那些没能逃出本国的行政部长们。军队内左翼最终与“全球项目”合并改组成了新的葡萄牙革命共产党，该国军队开始改组为人民军，并将彻底清洗右翼分子。新的革命政府则由萨赖瓦·德·卡瓦略和葡萄牙反修派资深理论家弗朗西斯科·马丁斯共同领导。葡萄牙新当局宣布将在国内建设社会主义、实行民主改革。第一步便是完全退出北大西洋公约组织的军事与政治框架。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1357 := "康乃“新”革命？"
const TXT_IDX_1358 := "六年时间过去了，葡萄牙的民主体制依然活在动荡之中。中左翼政府与中右翼政府如走马灯般频繁更迭，然而他们都不足以解决该国自旧体制下延续的社会经济问题，以及最终完成去殖民化的任务。政治不稳定为该国局势火上浇油——激进左右翼势力频繁发动恐怖袭击与各类反政府行动，从而严重打击了现政府在人民眼中的人气。民主派政治家设法激起公众对革命委员会的不满，并宣称后者“高居于民主政体之上，阻碍政治现代化”。然而，尽管其权力受到限制，但军方还是成功抵挡住了对自己的进攻。议会内的激进政党也越加强势。在他们的压力下，新加入葡萄牙革命委员会的军官均是极端反对当局自由主义政策的成员。以贡萨尔维斯与萨赖瓦·德卡瓦略为代表的极左翼政治家们纷纷回归。同时登场的还有极右翼反共产主义组织的领导人阿尔波因·卡尔万与斯皮诺拉。革命委员会正变得日益撕裂且激进化，政治家相互指责对方背叛了康乃馨革命。社会内也传出了军方将再度接管政权，重建国家秩序的流言。但这次，我们将如何干预葡萄牙？"
const TXT_IDX_1359 := "支持左翼团体（需要20.0百万{0}与25.0点{1}）"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_567 := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_IDX_1360 := "支持右翼团体（需要20.0百万{0}与25.0点{1}）"
const TXT_IDX_1361 := "保持观望"
const TXT_IDX_1363 := "里斯本爆发政变！根据《1976年宪法》，在革命委员会有权宣布一切法案违宪的情况下。为了应对政府颁布的有关解散革命委员会的法令。委员会宣称“政府长期向激进左派让步妥协，并将国家带到了内战的边缘”。军方拿下了首都的主要行政建筑，宣布推翻政府，并逮捕了那些没能逃出本国的行政部长们。右翼激进派与反共产主义势力纷纷支持政变。该国建立了由阿尔波因·卡尔万领导，斯皮诺拉任总统的新政府。葡萄牙新当局宣布将修改《1976年宪法》、对被没收财产进行再分配并奉行独立外交政策。第一步便是完全退出北大西洋公约组织的军事与政治框架。"

## 原文字符串附录（供自检）
## 里斯本爆发政变！根据《1976年宪法》，在革命委员会有权宣布一切法案违宪的情况下。为了应对政府颁布的有关解散革命委员会的法令。委员会宣称“政府背叛了1974年革命的理想，站在反革命营垒中，试图摧毁革命为该国带来的社会主义成就”。在共产党领导的工会和军队内左翼的支持下，军方拿下了首都的主要行政建筑，宣布推翻政府，并逮捕了那些没能逃出本国的行政部长们。军队内左翼最终与葡萄牙共产党合并改组成了新的葡萄牙共产党，该国军队开始改组为人民军，并将彻底清洗右翼分子。新的革命政府则由瓦斯科·贡萨尔维斯和葡共总书记阿尔瓦罗·库尼亚尔共同领导。葡萄牙新当局宣布将在国内建设社会主义、实行民主改革并加强与苏东阵营的合作。第一步便是完全退出北大西洋公约组织的军事与政治框架。
## 里斯本爆发政变！根据《1976年宪法》，在革命委员会有权宣布一切法案违宪的情况下。为了应对政府颁布的有关解散革命委员会的法令。委员会宣称“政府背叛了1974年革命的理想，站在反革命营垒中，试图摧毁革命为该国带来的社会主义成就”。在“全球项目”领导的城市游击队和工会以及军队内左翼的支持下，军方拿下了首都的主要行政建筑，宣布推翻政府，并逮捕了那些没能逃出本国的行政部长们。军队内左翼最终与“全球项目”合并改组成了新的葡萄牙革命共产党，该国军队开始改组为人民军，并将彻底清洗右翼分子。新的革命政府则由萨赖瓦·德·卡瓦略和葡萄牙反修派资深理论家弗朗西斯科·马丁斯共同领导。葡萄牙新当局宣布将在国内建设社会主义、实行民主改革。第一步便是完全退出北大西洋公约组织的军事与政治框架。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var d := world.数值表
	var portugal := world.get_country_by_legacy_index(87)
	var num := 100 - (portugal.special if portugal != null else 0)
	num = int(num / 2)
	var budget_reserve := d[W.I_BUDGET] + (d[W.I_RESERVE] if d.size() > W.I_RESERVE else 0)
	if budget_reserve >= 200 - num and d[W.I_AGENTS] >= 250 - num:
		_enable(event_def.options[0], TXT_OPT0[0])
		_enable(event_def.options[1], TXT_OPT1[0])
	elif budget_reserve < 200:
		_disable(event_def.options[0], TXT_OPT0[1])
		_disable(event_def.options[1], TXT_OPT1[1])
	else:
		_disable(event_def.options[0], TXT_OPT0[2])
		_disable(event_def.options[1], TXT_OPT1[2])
	_enable(event_def.options[2], TXT_OPT2[0])

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var portugal := ws.get_country_by_legacy_index(87)
	var opt := int(context.get("option_index", -1))
	var num := 0
	var num2 := 0
	var num3 := 100 - (portugal.special if portugal != null else 0)
	num3 = int(num3 / 2)
	if opt == 0:
		num += 2
		_add(W.I_BUDGET, -(200 - num3))
		_add(W.I_AGENTS, -(250 - num3))
	elif opt == 1:
		num2 += 2
		_add(W.I_BUDGET, -(200 - num3))
		_add(W.I_AGENTS, -(250 - num3))
	if int(ws.completed_event_ids.get("event_478", 0)) == 2:
		num2 += 1
	elif ws.completed_event_ids.has("event_478") and int(ws.completed_event_ids.get("event_478", 0)) != 3:
		num += 1
	if _raw(131) == 2:
		num += 2
	elif _raw(131) == 1:
		num += 1
	elif _raw(131) == 3:
		num2 += 2
	else:
		num2 += 1
	var c45 := ws.get_country_by_legacy_index(45)
	if c45 != null and c45.has_tag("nato"):
		num2 += 1
	else:
		num += 1
	var c85 := ws.get_country_by_legacy_index(85)
	if c85 != null and c85.government == 2:
		num += 1
	elif c85 != null and ws.is_authoritarian(c85):
		num2 += 1
	var c84 := ws.get_country_by_legacy_index(84)
	if c84 != null and c84.government == 2:
		num += 1
	elif c84 != null and ws.is_authoritarian(c84):
		num2 += 1
	var c86 := ws.get_country_by_legacy_index(86)
	if c86 != null and c86.government == 2:
		num += 1
	elif c86 != null and ws.is_authoritarian(c86):
		num2 += 2
	if ws.empires.size() > 1 and ws.empires[1] != null and ws.empires[0] != null and ws.empires[1].power >= ws.empires[0].power:
		num += 2
	else:
		num2 += 2
	if num < num2:
		if portugal != null:
			portugal.government = 0
			if int(ws.completed_event_ids.get("event_478", 0)) == 2:
				portugal.set_tag("亲美", false)
			portugal.sub_government = 7
			portugal.set_tag("nato", false)
		context["result_text"] = TXT_R[0]
	elif int(ws.completed_event_ids.get("event_478", 0)) != 1:
		if portugal != null:
			portugal.government = 1
			portugal.set_tag("亲美", false)
			portugal.sub_government = 1
			portugal.set_tag("亲苏", true)
			portugal.set_tag("nato", false)
		context["result_text"] = TXT_R[1]
	else:
		if portugal != null:
			portugal.government = 0
			portugal.set_tag("亲美", false)
			portugal.set_tag("亲中", true)
			portugal.sub_government = 0
			portugal.set_tag("nato", false)
		context["result_text"] = TXT_R[2]

func _raw(i: int) -> int:
	if d.size() > i:
		return d[i]
	return 0
