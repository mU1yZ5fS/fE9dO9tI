extends "res://数据脚本/event_script_base.gd"

const S_14 := "葡萄牙1983年议会选举"
const S_15 := "葡萄牙上一次议会选举于1980年10月5日举行，弗朗西斯科·萨·卡内罗领导的民主联盟获胜。然而，1980年12月，萨·卡内罗和阿马罗·达科斯塔（国防部长）在卡马拉特的一次悲惨事故中丧生。政府两位最大人物的死亡将影响执政联盟的凝聚力。弗朗西斯科·平托·巴尔塞芒于1981年1月被任命为总理，但他从未成为两党认可的领导人，而是引起了执政联盟内部的强烈反对，这导致了政府中几位部长的辞职。此外，巴尔塞芒所遵循的右翼政策受到反对党的强烈反对，特别是葡共。1982年2月，由CGTP（隶属于共产党的工会）召集的总罢工彻底动摇了政府，部长们纷纷辞职。直到1982年12月，在当年的市政选举之后，平托·巴尔塞芒本人提交了总理辞呈——民主联盟走向了分崩离析。1983年1月，安东尼奥·拉马尔霍·埃内亚斯总统在拒绝由民主联盟重新组阁后决定提前举行选举。根据我们的分析，右翼很可能会在这次议会选举受挫，而以社会党和联合人民联盟（共产党领导的政党联盟）为代表的左翼势力有望获得大量选票。但是，考虑到中间派的社会民主党仍具有较大力量，以及社会党“把社会主义放到抽屉里“的政策，建立一个左翼政府仍然存在障碍。主席同志，我们是否要干预葡萄牙的这场大选？"
const S_23 := "为共产党送上竞选资金并挑拨社会党与社会民主党的关系"
const S_28 := "我们绝对没有那么多钱"
const S_33 := "我们没那个精力"
const S_35 := "我们为什么要陪他们玩选举游戏？"
const S_40 := "葡萄牙1983年议会选举"
const S_43 := "选举结果公布了。社会党获得了38%的选票，获得了相对多数。由共产党领导的联合人民联盟获得了20%的选票。民主联盟解散后，其中各党单独参选。社民党获得了26%的选票。而人民党获得了13%的选票，取得了糟糕的成绩。社会党起初想与社民党组成“中央集团“，但由于政见差别较大和两党的几位知名人士特别是社民党的强烈反对，社会党最终被迫选择与联合人民联盟组成社会主义联合政府。新政府将继续进行康乃馨革命后宪法规定的社会主义的改革。"
const S_52 := "选举结果公布了。社会党获得了36.1%的选票，获得了相对多数。由共产党领导的联合人民联盟获得了18.1%的选票。民主联盟解散后，其中各党单独参选。社民党获得了27.2%的选票。而人民党获得了12.6%的选票，取得了糟糕的成绩。选举标志着社会党和社民党之间的国家政治两极分化的开始。在没有明显多数的情况下，社会党领袖马里奥·苏亚雷斯决定与社民党组建政府，这个联盟后来被称为“中央集团“。联盟的两党内部对这一执政联盟都不是很满意，这样的新政府能够维持多久呢？"


## 原作 Event479.cs：葡萄牙1983年议会选举（两选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1409-1411 ——
##   event_done[419] && 日期>=1983.4.25。
## 差异：Vyshi→亲美；选项0 显隐与门槛文本按原版 if/else 链 prepare 动态改写。

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var sum := world.数值表[W.I_BUDGET] + world.数值表[W.I_RESERVE]
	if sum >= 50 and world.数值表[W.I_AGENTS] >= 50:
		_enable(opt[0], S_23)
	elif sum <= 50:
		_disable(opt[0], S_28)
	else:
		_disable(opt[0], S_33)
	_enable(opt[1], S_35)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var portugal := ws.get_country_by_legacy_index(87)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if portugal != null:
				portugal.government = 2
				portugal.sub_government = 3
				portugal.set_tag("亲美", false)
			context["result_text"] = S_43
		1:
			if portugal != null:
				portugal.government = 3
				portugal.sub_government = 5
			context["result_text"] = S_52


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n
