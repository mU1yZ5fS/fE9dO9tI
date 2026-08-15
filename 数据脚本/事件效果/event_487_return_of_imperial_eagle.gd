extends "res://数据脚本/event_script_base.gd"

## 原作 Event487.cs：帝国鹰的回归（西德极右翼，四选项，opt3 恒禁用）。
## 触发：ReqEventForDLC02.cs:1504-1506 ——
##   ((年>=1980 月>=9 日>=26) || (年>=1980 月>=10) || 年>=1981)。
## 差异：
##  - data[31] 战争支持 → W.I_WAR_SUPPORT；data[56] 政治路线 → W.I_POLITICAL_LINE；
##  - result1 的领袖姓名拼接 → _leader_name()（names1+names2 → name_display）。

const TXT_TITLE := "帝国鹰的回归"

const TXT_DESC := "来自西德的消息，慕尼黑特雷津维泽的啤酒节展览场发生了一场爆炸，造成12人死亡，200多人受伤。死者包括涉嫌爆炸案的冈多夫·科勒，他与极右翼圈子关系密切，是新纳粹准军事组织“霍夫曼国防运动团体”的成员。据了解，这是二战结束以来新纳粹在该国实施的最致命袭击。我们是否可以趁此介入西德的局势，给他们来一些火上浇油？因此，请容我借此机会向您介绍一下西德极右翼运动的状况。\n1949年，奥托·恩斯特·雷默成立了社会主义帝国党，它很快就变成了一个新纳粹组织，从各个方面阻碍了波恩与西方阵营的关系，甚至苏联国家安全部也曾资助过该党。这位曾在东线作战并镇压1944年阴谋的前纳粹少将全心全意主张泛欧罗巴运动，反对“英美帝国主义和犹太复国主义”。社会主义帝国党本可能成为联邦德国的第三大党，但在1952年被强制解散，成为了联邦宪法法院的第一个受害者（第二个则是德国共产党），雷默被拘留，之后他移居海外活动。雷默一直希望能回到祖国，试图在那里恢复他的新纳粹活动。\n在此之后填补极右翼生态位空缺的则先后是德意志帝国党与德国国家民主党。国家民主党的许多年轻成员希望与该党系统性关联的民族社会主义延续者形象保持距离，试图以此开创一种能够对抗新左派学生运动的新动力。而1969年国家民主党未能在联邦选举中进入议会的惨败结果也给了青年派推动其结构、教条与话语向革命民族主义方向更新的机会。这导致了青年派与固守极右翼传统立场的领导层之间的冲突，最终使其于1972年分裂。\n社会学家亨宁·艾希伯格在国家民主党陷入分裂后成立了“新右翼行动”组织。受法国与意大利的革命民族主义者与六八运动的新左翼影响，该组织宣称“旧右翼的策略已经失败了”，提出了一套以反美反苏和“第三世界”民族主义为核心的“超越左右翼的民族革命”的“反帝解放民族主义”新右翼纲领，将德国称为第三世界被殖民国家，要求将占领国驱逐出两德，最终实现“德意志的重生与统一”，这使其成立两年后便因保守派出走而解体，剩余的多数成员则在亚历山大·爱泼斯坦领导下重组成了人民事业-民族革命建设组织（SdV-NRAO），该党决定打倒“苏帝走狗”民主德国与“美帝傀儡”黑红金三党的“伪爱国主义”，与这些“内部敌人”作斗争，在国际事务中打出中国牌。\n或许，我们应该利用这个机会尝试支持他们之中的某些势力⋯？"

const TXT_OPT0 := "为什么要支持一群法西斯余孽？"
const TXT_OPT1 := "帮雷默同志一把。这是组建反帝统一战线的必由之路！"
const TXT_OPT1_DIS := "己所不欲，勿施于人"
const TXT_OPT2 := "支持纳粹主义者干什么，还不如选德国的纳粹-毛主义者"
const TXT_OPT2_DIS := "不管披上什么外衣，纳粹就是纳粹"
const TXT_OPT3_DIS := "我们永远做不到这种事！"

const TXT_R0 := "我们既然不喜欢别的国家庇护日本军国主义者，为什么要支持一个德国纳粹？叫他滚的越远越好！"

const TXT_R1_PRE := "我们成功联络到雷默同志，帮助他联系到国家民主党、德国人民联盟、维京青年团等极右翼团体以及霍夫曼国防运动团体、民族社会主义者行动阵线、德意志行动小组等极右翼准军事组织，乃至光头党和足球流氓，组建了一个名为“自由德意志运动”的极右翼统战组织，雷默被选为该组织的主席。该组织将对西德社会进行广泛渗透，并继续吸纳新的右翼团体。我们将为其提供资金、武器和训练。希望这些组织能够在西德起到我们想要的作用吧……\n与此同时，我们秘密和雷默达成了协定，邀请他以访问学者的身份秘密居住在中国。第二天，"

const TXT_R1_POST := "同志在自己的办公室里接待了这位“法西斯余毒”。雷默高度赞扬了中国的革命氛围，对扫清地主的赞美和全国人民团结一致建设祖国的翼赞。“我看中国搞的不错，反革命基本被扫清，生活也极大富裕，民族同志和民族斗争的概念也深入人心。如果再加上纳粹党执政，中国就是我们理想的民族社会主义社会。”让我们暂且把这番话当成恭维吧……"

const TXT_R2 := "通过我们的支持，人民事业组织得以将团结人民运动、民族革命协调委员会，施特拉瑟主义的独立工人党（德国社会主义者）、自由德国工人党等另类右翼团体，霍夫曼国防运动团体、德意志人民社会主义运动/劳动党、民族社会主义者行动阵线、德意志行动小组等极右翼准军事组织团结在统战组织“德意志民族解放阵线”之下，艾希伯格被选为该组织的主席。阵线将对工人运动、学生运动、绿色运动、左翼和极右翼进行广泛渗透。令人意外的是，RAF创始人之一、德共（重建组织）的支持者霍斯特·马勒，以及来自德国共产党/马列的迈克尔·科斯也带领着他的“民族共产主义”派加入了其中。我们将为德意志民族解放阵线提供资金、武器和训练。希望这些组织能够在西德起到我们想要的作用吧……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var war_support := world.数值表[W.I_WAR_SUPPORT] if world.数值表.size() > W.I_WAR_SUPPORT else 0
	var line := world.数值表[W.I_POLITICAL_LINE] if world.数值表.size() > W.I_POLITICAL_LINE else 1
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var res395 := int(world.completed_event_ids.get("event_395", -1))
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	if war_support >= 700 and not mod3 and line != 4:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if res395 == 0:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_disable(opt[3], TXT_OPT3_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			ws.influence_prc += 5
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
			context["result_text"] = TXT_R1_PRE + _leader_name() + TXT_R1_POST
		2:
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			ws.influence_prc += 5
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
			context["result_text"] = TXT_R2
		3:
			context["result_text"] = TXT_R0


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)
