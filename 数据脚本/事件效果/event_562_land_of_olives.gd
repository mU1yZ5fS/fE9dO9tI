extends "res://数据脚本/event_script_base.gd"

## 原作 Event562.cs：橄榄之国，永远屹立（突尼斯面包骚乱，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:352-354 ——
##   event_done[459] && resultOfEvents[459]>=3 && event_done[561] && resultOfEvents[561]>=2
##   && (1983.12.29 或 1984+)。

const TXT_OPT0_DIS := "我们有心无力"
const TXT_OPT1_DIS := "我们不会支持所谓的民主伊斯兰主义者！"
const TXT_R0_A := "我们迅速帮助民主爱国者运动和突尼斯工人组织的强硬派组织了革命派共产主义者的联合阵线，将多个反修派组织团结在一起，组成突尼斯革命共产党，迅速将群众组织起来。骚乱最初在突尼斯南部的贫困与边缘化绿洲地区爆发，虽然面包价格的急剧上涨成为了直接的导火索，但其背后隐藏的是长期累积的社会和经济不平等。年轻人、农民、季节性工人以及失业者成为了这场运动的主力军，随着事态的升级，骚乱迅速蔓延至全国多个城市。我们将布尔吉巴企图调遣装甲部队镇压群众命令的录音公布后，愤怒的民众不再满足于和平抗议，他们在突尼斯革命共产党的帮助下组成了工人民兵，占领了警察局、政党总部、市政厅，甚至是国民警卫队总部，掀起了全民暴动。在我们的干预下，社会主义宪政党政权最终倒台，而布尔吉巴也被人民法庭处判处反人民罪，执行死刑，而他的同伙也被逮捕，或被判处劳役，或被处死。突尼斯人民共和国成立了。"
const TXT_R0_B := "我们迅速帮助人民团结运动、进步民主党等团体组织了社会主义者的联合阵线，将多个左翼反对派组织团结在一起，组成人民团结联盟，迅速将群众组织起来。骚乱最初在突尼斯南部的贫困与边缘化绿洲地区爆发，虽然面包价格的急剧上涨成为了直接的导火索，但其背后隐藏的是长期累积的社会和经济不平等。年轻人、农民、季节性工人以及失业者成为了这场运动的主力军，随着事态的升级，骚乱迅速蔓延至全国多个城市。我们将布尔吉巴企图调遣装甲部队镇压群众命令的录音公布后，愤怒的民众不再满足于和平抗议，他们在人民团结联盟的帮助下组成了人民民兵，占领了警察局、政党总部、市政厅，甚至是国民警卫队总部，掀起了全民暴动。在我们的干预下，社会主义宪政党政权最终倒台，而布尔吉巴也被人民法庭处判处反人民罪，执行死刑，而他的同伙也被逮捕，或被判处劳役，或被处死。新时代到来了。"
const TXT_R1 := "我们决定支持伊斯兰趋势运动这个势力强大的民间反对派。骚乱最初在突尼斯南部的贫困与边缘化绿洲地区爆发，虽然面包价格的急剧上涨成为了直接的导火索，但其背后隐藏的是长期累积的社会和经济不平等。年轻人、农民、季节性工人以及失业者成为了这场运动的主力军，随着事态的升级，骚乱迅速蔓延至全国多个城市。愤怒的民众不再满足于和平抗议，他们冲进警察局、政党总部、市政厅，甚至是国民警卫队总部，得到支持的伊斯兰趋势运动通过大规模的串联和社会运动向政府施压（实际上形成了低烈度的小型内战），意识到局势的严峻性，在社会主义宪政党的特别代表大会上，布尔吉巴被抛弃了，他被解除了一切职位，该党也被改组为民主宪政联盟。在国际监督的大选上，伊斯兰趋势运动赢得了大选，随即开始进行经济改革和温和的伊斯兰化。"
const TXT_R2 := "骚乱最初在突尼斯南部的贫困与边缘化绿洲地区爆发，虽然面包价格的急剧上涨成为了直接的导火索，但其背后隐藏的是长期累积的社会和经济不平等。年轻人、农民、季节性工人以及失业者成为了这场运动的主力军，他们走上街头，用愤怒和绝望的声音诉说着自己的困境。\n随着事态的升级，骚乱迅速蔓延至全国多个城市。愤怒的民众不再满足于和平抗议，他们冲进警察局、政党总部、市政厅，甚至国民警卫队总部，试图以自己的方式表达对现状的不满。然而，安全部队的暴力镇压却使得事态进一步恶化。\n学生群体在这场骚乱中扮演了重要的角色，他们通过罢课来表达对政府的抗议，并与抗议者团结一致，共同呼吁改革。在暴乱的冲击下，社会秩序陷入混乱。暴徒们抢劫和焚烧商店，破坏公共设施，袭击汽车和公共汽车。他们攻击富人社区，放火烧毁豪华汽车，表达对社会精英的不满和仇恨。\n为了平息事态，政府采取了严厉的镇压措施。宵禁被实施，所有学校被关闭，公共集会也被禁止。士兵和防暴警察被部署到街头和十字路口，坦克、装甲车和直升机也被开到了街道上，他们向一切移动的东西开火。然而，在巨大的社会压力下，布尔吉巴总统最终不得不宣布取消面包和面粉价格的上涨。这一决定虽然暂时缓解了民众的愤怒，但并未从根本上解决突尼斯所面临的社会和经济问题。\n骚乱之后，布尔吉巴谴责来自利比亚的“境外势力“煽动了国内的不满。此外，随着全球油价的持续下跌，数千名来自利比亚和其他石油国家的工人返回突尼斯，进一步加剧了该国的经济困境。\n在这场骚乱中，伊斯兰趋势运动（MTI）成为了政府眼中的“幕后黑手”。政府逮捕了许多MTI的支持者，并指责他们组织了这场骚乱。相反，对MTI的迫害反而增强了其在民众中的声誉和影响力。作为镇压反对派的一部分措施，本·阿里将军被重新任命为国家安全局局长，并随后成为内政部长。\n年迈的哈比卜·布尔吉巴还能在突尼斯的总统宝座上待多久？"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var c40 := world.get_country_by_legacy_index(40)
	var c13 := world.get_country_by_legacy_index(13)
	var line := d[W.I_POLITICAL_LINE]
	if line < 2 and c40 != null and not c40.has_tag("亲美") and c13 != null and not c13.has_tag("亲美"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line > 2 and c40 != null and c40.has_tag("对华贸易"):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c55 := ws.get_country_by_legacy_index(55)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if ws.modifiers[6].is_active:
				if c55 != null:
					c55.government = 1
					c55.sub_government = 17
					_leave_alliances(c55)
					c55.set_tag("亲中", true)
					c55.set_tag("对华贸易", true)
				context["result_text"] = TXT_R0_A
			else:
				if c55 != null:
					c55.government = 1
					c55.sub_government = 1
					_leave_alliances(c55)
					c55.set_tag("亲中", true)
					c55.set_tag("对华贸易", true)
				context["result_text"] = TXT_R0_B
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -20)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			_add(W.I_DIPLO, 50)
		1:
			_add(W.I_BUDGET, -100)
			if c55 != null:
				c55.government = 3
				c55.sub_government = 5
				_leave_alliances(c55)
				c55.set_tag("亲中", true)
				c55.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, -20)
			_add(W.I_AGENTS, -100)
			_add(W.I_DIPLO, -100)
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2
