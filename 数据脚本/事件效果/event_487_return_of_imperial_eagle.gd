extends "res://数据脚本/event_script_base.gd"

## 原作 Event487.cs：帝国鹰的回归（西德极右翼，四选项，opt3 恒禁用）。
## 触发：ReqEventForDLC02.cs:1504-1506 ——
##   ((年>=1980 月>=9 日>=26) || (年>=1980 月>=10) || 年>=1981)。
## 差异：
##  - data[31] 战争支持 → W.I_WAR_SUPPORT；data[56] 政治路线 → W.I_POLITICAL_LINE；
##  - result1 的领袖姓名拼接 → _leader_name()（names1+names2 → name_display）。



const TXT_OPT1_DIS := "己所不欲，勿施于人"
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
	_enable(opt[0], event_def.options[0].text)
	if war_support >= 700 and not mod3 and line != 4:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if res395 == 0:
		_enable(opt[2], event_def.options[2].text)
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



