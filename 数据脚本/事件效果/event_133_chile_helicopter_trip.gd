extends "res://数据脚本/event_script_base.gd"

## 原作 Event133.cs：直升机之旅（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_PROPRC_YES := "[color=red]新政府决心和我们做朋友。[/color]"
const TXT_PROPRC_NO := "[color=red]新政府不想和我们做朋友。[/color]"
const TXT_R0 := "从我国外交部与解放军的报告中可以毫不费力地看出，皮诺切特和他最亲密的支持者、政变计划的制定者、空军司令古斯塔沃·李之间的矛盾正在不断激化。作为一名新法西斯主义者与法团主义者，李对“芝加哥男孩”的新自由主义改革与皮诺切特日益想要独揽大权耿耿于怀。我们让皮诺切特相信他有必要和法西斯组织“祖国与自由”（PIL）的领导人罗伯托·蒂姆保持亲密，并向皮诺切特保证公众对他的支持，以防止民众试图将他驱逐出军政府。解放军同智利军队的积极合作使我们拉拢了许多中层军官，甚至一些将领，使我们能够及时了解独裁者的最新动向。在一次军政府会议上，皮诺切特逼迫李辞职，但后者拒绝下台，转而向我方及他本人的支持者寻求帮助。祖国与自由准军事组织封锁了圣地亚哥驻军，中国武官发出了“中式警告”，最终迫使皮诺切特退让。经过此事，我国在智利的影响作用得到空前的增强。"
const TXT_R1 := "从反修分子到右翼民族主义者，智利的反对派是各种政治力量的大杂烩。由于我们在当地几乎没剩下任何联系途径，如果我们想要和民主联盟（AD）及人民民主运动（MDP）联系，就必须经由皮诺切特政权的内政部长塞尔吉奥·哈尔帕，他曾经为我们和基督教民主联盟（CDA）的领导人爱德华多·弗雷与帕特里西奥·艾尔温牵线搭桥。多亏了古巴朋友的协助，我们得以恢复同智共流亡领袖路易斯·科瓦兰和革命左翼运动（MIR）领袖帕斯卡尔·阿连德的联系。尽管1973年以后他们对我们的信任已无需赘述，但这两个组织的确急需外部援助，尤其在皮诺切特在美国的帮助下有效镇压了反对党活动，并且同独裁者的谈判毫无成果的形势下。经过紧张的谈判，中国同民盟及民运达成合作协议，反对党同意在中国与苏联的影响下成立智利协调委员会，其成员有：共产党人路易斯·科瓦兰、博洛迪亚·泰特尔鲍姆和格拉迪斯·马林；社会党人卡洛斯·阿尔塔米拉诺、里卡多·拉戈斯、克洛多米罗·阿尔和梅达劳尔·亚姆普埃罗；基督教民主党人爱德华多·弗雷、拉多米尔·托米克、埃德加多·布宁格和贝尔纳多·莱顿；激进党人安塞尔莫·苏尔和阿尼巴尔·帕尔马；革左运成员尼尔森·古铁雷斯和反修正主义者爱德华多·阿特斯。随着反对势力的逐步加强，皮诺切特政权断绝了同我们的一切往来，并开始着手准备新一轮的恐怖浪潮，包括清洗整个国家民政部门以及加强对国有企业的管控审查。"
const TXT_R2 := "皮诺切特政权残酷镇压了反对势力，并且压制了政权内部的分歧：持新法西斯立场的空军司令古斯塔沃·李因为批评皮诺切特改革被迫离开军政府，祖国与自由（PIL）组织被肢解并逐出政界。此后，皮诺切特通过设立新宪法而非1925年被废除的宪法实现其合法性。他的改革计划巩固了经济领域的新自由主义路线，并为军政府独裁打下了物质基础。在1988年之后，全民将依法举行一次对奥古斯托·皮诺切特政府的信任公投。这次公投不设选民名单，不保证最低限度的投票透明度、对媒体严格审查、迫害投“不信任”的反对者并镇压和平示威，新宪法规定的全民公决原则被严重破坏了。公投的最终结果是，政府获得了78%的信任率。在这些阴谋诡计、瞒哄欺诈、鼓吹宣传与大肆迫害的手段下，皮诺切特暂时让他的权力披上了合法的外衣。"




func _proprc_suffix(c: CountryData) -> String:
	return TXT_PROPRC_YES if c.has_tag("亲中") else TXT_PROPRC_NO

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var chile := ws.get_country_by_legacy_index(74)
	if chile == null:
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			chile.level_of_instability -= 15
			chile.set_tag("对华贸易", true)
			context["result_text"] = TXT_R0 + _proprc_suffix(chile)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			chile.level_of_instability -= 15
			chile.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			chile.set_tag("对华贸易", false)
			chile.set_tag("亲中", false)
			context["result_text"] = TXT_R1 + _proprc_suffix(chile)
		_:
			chile.level_of_instability -= 15
			context["result_text"] = TXT_R2 + _proprc_suffix(chile)
	chile.next_election_year = 1980
	chile.next_election_month = 9
	chile.next_election_day = 11

