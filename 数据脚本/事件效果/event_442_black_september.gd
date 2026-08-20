extends "res://数据脚本/event_script_base.gd"

## 原作 Event442.cs：黑色九月所带来的（4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:527-530 —— Israellost 且（伊拉克/叙利亚 各满足 严格社会主义 或 SubGosstroy==10 或 Gosstroy==2）且 年>=1983（trigger_script 表达）。
## 差异：Israellost 同时认 israellost / israel_lost_lebanon_war 两个旗标；Gosstroy/SubGosstroy→government/sub_government；
##   Torg→对华贸易、proprc→亲中；选项显隐 prepare 动态改写。



const TXT_OPT0_DIS := "我们怎么能相信一个暴君？"
const TXT_OPT1_DIS_0 := "我们怎么能让小资产阶级破坏这场革命呢？"
const TXT_OPT1_DIS_ELSE := "侯赛因的力量太过于强大了"
const TXT_OPT2_DIS := "这又是什么名不见经传的小组织？"

const TXT_R0 := "在戒严状态越加不可持续的情况下，侯赛因最终接受了我们的条件，由我们的特勤机关协助他稳定国内局势。而作为交换，侯赛因逐步实施了我们提出的改革要求。首先，王室结束了长达二十多年的戒严令，恢复了国内政治势力组建政党的权利。然而，这引发了新的问题：由于长期的戒严，除了巴勒斯坦残余势力和穆兄会分子外，几乎没有来自其他派别的具有声望或影响力的反对派政治家，更不用说形成规模较大的政党了。对于约旦政府来说，前两派势力显然需要被排除在政治之外。于是，建立健康的民主政治体系的重任落在了首相及文官政府的肩上：他们成立了一个名为“国家宪章集团”的政党，并在第一次大选前作为执政党行使权力。\n接下来的改革步骤是将国王的立法权尽可能转移给立法机构，推动政党政治的发展，以实现国家事务的高效运作和政治体系现代化。为此，“国家宪章集团”提出了一系列改革措施，包括扩大地区比例选票、减少王室代表的比例，旨在促进该国政治中心的转移。不过，党内熟悉中东事务的专家指出，增加地区比例可能会导致农村地区的宗族因素更为深入地影响政治领域，从而使民主政治成为家族裙带关系的代名词。但无论如何，该国已经迈出了民主进程的第一步，至于其未来发展如何，我们拭目以待……"
const TXT_R1 := "埃米尔的空头支票毫无诚意，要实现该国民主化，唯有复兴党人和泛阿主义才是未来之正途。因此，我们的特勤人员迅速联系到了残余的复兴党地下网络，并积极帮助他们的重建与再武装。不久后，地下复兴党人便源源不断地获得许多来源不明的枪支，屡禁不止的共和派传单从小巷一路张贴到广场，激烈抨击王室的独裁统治。在日益躁动的社会气氛中，安曼大街小巷的游击运动重新燃起。另一方面，JNM（约旦民族运动）和爱国社会主义党留下的政治遗产为复兴党提供了良好的突破口，革命分子凭借“流亡民选政府”的名义迅速建立了不同于哈希姆王室的合法性，以此招揽了大批爱国军人和城市居民进入自己的队伍。显然，外国入主的哈希姆家族本就无法承担起所谓“人民之心”的美誉。\n最终，日益壮大的武装反对派逐步蚕食，并最终击溃了约旦皇家军队，这成为了压垮侯赛因统治的最后一根稻草。连最精锐的王室卫队也四散奔逃，将国王置于彻底的孤立地位。走投无路的侯赛因不得不行詹姆斯二世旧事，在拉格丹宫与反对派武装签订协议，于嘘声和臭鸡蛋中屈辱地宣布退位。随后，掌权的复兴党和部分自由军官成立了全国革命委员会，并选择暂时维持了一种仪式性君主制——扶持年幼的阿里·侯赛因为虚君来争取农村地区支持。随后，复兴党人以1956年的名义，准备大展宏图，重新启动未完成的大规模社会改革：土地改革、工业化建设、现代化文化精神、去殖民化等一系列工程，决心在这片土地上建立起又一个“统一、自由、社会主义”的反以色列堡垒。"
const TXT_R2 := "巴勒斯坦人在约旦所留下的激进政治力量如同一抹鲜亮的红色，誓要将君主制和部族主义葬于阿拉伯民族之潮下。其中，由人阵成员组成的革命人民党和民阵成员主导的人民民主党及民族民主阵线毅然接过了约旦共产党的历史接力棒，肩负起了实现民族解放和民主独立的重任。随着外部援助的到来，这些长期受压制的左翼力量获得了扭转局势的契机。\n在我方特勤的建议下，以人民民主党为核心的社会主义者们迅速行动起来，积极寻求与其他可合作势力的联合。他们成功地将复兴党和民族民主派纳入了自己的阵营。并借鉴70年代初人民阵线的框架，构建了一个地下的“全国民主政府”。这个新成立的政府机构宣称自己是民选政府的合法继承者，并邀请了一些前约旦自由军官作为象征性领袖。很快，借助于广泛的社会阶层影响力以及来自我国特勤部门的秘密帮助，“全国民主政府”的组织网络迅速从几个小镇扩展到全国各地。尚未壮大的工人阶级、与组织失去联系的巴解战士以及对现政权不满的城市居民被组织起来，进行着不声不响的军事准备。\n而面对基层控制力被反对派抢走的事实，王室最终决定采取措施消除这一威胁，试图在全国范围内部署军队来防止任何潜在的叛乱活动。然而，这种做法却产生了适得其反的效果——“全国民主政府”立刻发动了革命，被渗透成筛子的政府军几乎溃不成军，在起义军官、工人纠察队和城市游击队的联合攻击下兵败如山倒。在轰轰烈烈的大起义前，国王及内阁成员匆忙逃往西方国家避难，只有少数忠诚部队和当地部族坚守偏僻地区，誓要与新兴政权抗争到底。\n总的来说，全国民主政府目前已经控制了约旦大部分领土，这或许标志着一个属于约旦人民的新时代即将开启。"
const TXT_R3 := "约旦河，那是啥？约旦不是在两河流域或者尼罗河吗？"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world.数值表
	if data.size() <= W.I_YEAR:
		return false
	if data[W.I_YEAR] < 1983:
		return false
	if not (world.get_flag("israellost") or world.get_flag("israel_lost_lebanon_war")):
		return false
	var iraq := world.get_country_by_legacy_index(14)
	var syria := world.get_country_by_legacy_index(35)
	if iraq == null or syria == null:
		return false
	var iraq_ok := world.is_socialism(iraq, true) or iraq.sub_government == 10 or iraq.government == 2
	var syria_ok := world.is_socialism(syria, true) or syria.sub_government == 10 or syria.government == 2
	return iraq_ok and syria_ok


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var iraq := world.get_country_by_legacy_index(14)
	var syria := world.get_country_by_legacy_index(35)
	var ethiopia := world.get_country_by_legacy_index(41)
	var opt := event_def.options
	if data[W.I_POLITICAL_LINE] >= 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if data[W.I_POLITICAL_LINE] >= 1 and data[W.I_POLITICAL_LINE] < 3 \
			and ((iraq != null and iraq.government == 2) or (syria != null and syria.government == 2)):
		_enable(opt[1], event_def.options[1].text)
	elif data[W.I_POLITICAL_LINE] == 0:
		_disable(opt[1], TXT_OPT1_DIS_0)
	else:
		_disable(opt[1], TXT_OPT1_DIS_ELSE)
	if data[W.I_POLITICAL_LINE] < 2 \
			and (world.is_socialism(iraq, true) or world.is_socialism(syria, true) or world.is_socialism(ethiopia, true)):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var jordan := ws.get_country_by_legacy_index(104)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -30)
			if jordan != null:
				jordan.government = 3
				jordan.sub_government = 5
				jordan.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -150)
			_add_power(EmpireData.USA, -5)
			ws.influence_prc += 10
			context["result_text"] = TXT_R0
		1:
			if jordan != null:
				jordan.government = 2
				jordan.sub_government = 15
				jordan.set_tag("对华贸易", true)
			ws.influence_prc += 20
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -50)
			if jordan != null:
				jordan.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, -5)
			context["result_text"] = TXT_R1
		2:
			if jordan != null:
				jordan.government = 1
				if _modifier_active(6):
					jordan.sub_government = 0
				else:
					jordan.sub_government = 1
				jordan.set_tag("对华贸易", true)
				jordan.set_tag("亲中", true)
			ws.influence_prc += 25
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -50)
			_add_relation(EmpireData.USA, -150)
			_add_power(EmpireData.USA, -20)
			context["result_text"] = TXT_R2
		3:
			context["result_text"] = TXT_R3




func _disable_blank(opt: EventOption) -> void:
	opt.text = ""
	opt.disabled_text = ""
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n








func _modifier_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active


func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)
