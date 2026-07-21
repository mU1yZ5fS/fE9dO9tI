class_name ModifierCatalog
extends RefCounted

## 概览/修正 UI 只读文案。id 对齐原版 modifies[0..17] 与分析文档 §5.2。
## 不写 WorldState；effect_zh 可选用 w 做简单动态句。

const NAMES_ZH := {
	0: "工业技术依赖",
	1: "工业产能上限",
	2: "社会动荡",
	3: "后毛时代效应",
	4: "人口与工业压力",
	5: "市场改革冲击",
	6: "意识形态动员",
	7: "五年计划",
	8: "外交攻势",
	9: "边疆文化政策（新）",
	10: "边疆文化政策（藏）",
	11: "经济整顿",
	12: "政治危机",
	13: "工业创收",
	14: "改革派声势",
	15: "农业产能上限",
	16: "对苏关系受损",
	17: "对美关系受损",
}

const EFFECTS_ZH := {
	0: "每两周工业 -0.5\n解除：自主工业技术",
	1: "工业不升至超过 50.0\n解除：全面工业换装",
	2: "每两周：人民支持 -1.0，思想自由 +2.0",
	3: "每两周：预算 +0.6，特工 +0.2，军力 +0.5\n毛逝世后另有支持/自由化/生活/对美关系变化",
	4: "生活水平偏低或改革超前时压制工业，并影响自由化与团结",
	5: "每两周：人民支持 -0.2，思想自由 +1.0，预算 +0.2",
	6: "每两周：党内支持 +0.5，思想自由 -0.2，团结相关 +0.1\n声望 +0.2；对苏 -0.4，对美 -0.2",
	7: "五年计划动态：条件满足时减腐败/自由化、增工业等；否则显示「一切按计划进行」类效果",
	8: "每两周：对美 +0.2，对苏 +0.2，思想自由 -1.0",
	9: "团结 -1.0；人民支持增长减半，思想自由增长相关削弱",
	10: "团结 -1.0；人民支持与思想自由增长进一步削弱（四分之一档）",
	11: "每两周：工业 +2，农业 +2，预算 +5，生活 +0.2，腐败 -0.1，党内支持 -5.0",
	12: "每两周：预算 -1.0，特工 -1.0，团结 -0.3",
	13: "按生活水平与经济体制增加预算收入",
	14: "增强改革派与自由派声势",
	15: "农业不升至超过 70.0\n解除：农业方法研究",
	16: "对苏关系差时削减预算与特工",
	17: "对美关系差时削减预算与特工",
}


static func name_zh(id: int) -> String:
	if NAMES_ZH.has(id):
		return str(NAMES_ZH[id])
	return "修正 #%d" % id


static func effect_zh(id: int, w: WorldState = null) -> String:
	# 可选动态：13 号随经济体制变化一句摘要
	if id == 13 and w != null and w.数值表.size() > WorldState.I_ECON_SYSTEM:
		var living: int = w.数值表[WorldState.I_LIVING]
		var econ: int = w.数值表[WorldState.I_ECON_SYSTEM]
		var denom := 500
		if econ == 14:
			denom = 330
		elif econ == 15:
			denom = 250
		elif econ == 13:
			denom = 500
		else:
			return EFFECTS_ZH.get(id, "效果未录入")
		var whole := living / (denom * 10)
		var frac := absi(living / denom % 10)
		return "预算收入约 +%d.%d（随生活水平）" % [whole, frac]
	if EFFECTS_ZH.has(id):
		return str(EFFECTS_ZH[id])
	return "效果未录入"


static func is_known(id: int) -> bool:
	return NAMES_ZH.has(id)
