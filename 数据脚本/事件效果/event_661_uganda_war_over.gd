extends "res://数据脚本/event_script_base.gd"

## 原作 Event661.cs：战争结束了（乌干达内战结算，单选项）。
## 触发：TimeScript.cs:1900-1910（event_done[659] && !war81.is_going && 乌干达 inflNATO>=1000）
##   与 TimeScript.cs:7094-7098（WarCheck(81)：war81.is_going && data[82]<0 &&
##   (fortnight_go>=fortnight_max || infl1>=1000 || infl2>=1000)）。
##   本项目 war81 未录入 WarCatalog，实际以乌干达 influence_nato 路径为主；
##   trigger_script = 本脚本 evaluate()。
## 差异：
##  - resultOfEvents[659] 用 completed_event_ids.get("event_659", 0) 对齐原版缺省 0；
##  - event_done[660]→completed_event_ids.has("event_660")；
##  - empires[1].relations=-250→clampi；LeaveAlliances→_leave_alliances；
##  - proprc/Torg/Vyshi→set_tag("亲中"/"对华贸易"/"亲美")；name→chinese_name；
##  - 死代码 result_num==5 跳过。

const TXT_DESC_1 := "在长时间的血腥冲突之后“"
const TXT_DESC_2 := "”终于结束了。我国外交部密切留意全程，并已准备好为您汇报战争的最终结果。"
const TXT_R0 := "最终，乌干达民族解放军成功镇压全国抵抗军、乌干达自由运动等反政府武装，取得了反叛乱战争的胜利。卡伊拉早在己方主力部队被击溃后就流亡美国，全国抵抗军所处的卢韦罗三角地带被彻底征服，西北部阿明残军盘踞的西尼罗河地区也大半重归政府控制之下，部分阿明余部逃往扎伊尔与苏丹。奥博特承诺“当前乌干达的主要任务——恢复法律与秩序、重建经济、并在道德与心理上重塑乌干达人民”的第一步已经完成，接下来，乌干达“将学习坦桑尼亚的自力更生精神与肯尼亚的同舟共济政策”，进行经济重建工作。然而，政府军军人在所有反政府武装活动地区的暴行在反对派武装消亡后仍未改变，不管是布干达人、西尼罗河人、安科莱人还是其他支持过反对派的部族都被统统打上了“反政府武装同情者”的标签，劫掠、酷刑、屠杀、强制迁移依旧是常态，甚至愈演愈烈。"
const TXT_R0_DONE660 := "最终，奥凯洛政府军与阿明部队出人意料地挺过了全国抵抗军的攻势，将其主力歼灭，取得了内战的胜利，全国抵抗军残部撤退回卢韦罗丛林中。然而，旷日持久的内战导致政府控制力下降到了一个极其微弱的地步，政府军军人在所有反政府武装活动地区的暴行在反对派武装消亡后仍未改变，不管是布干达人、安科莱人还是其他支持过反对派的部族都被统统打上了“反政府武装同情者”的标签，而兰戈人也“要为奥博特的暴行负责”，劫掠、酷刑、屠杀、强制迁移依旧是常态，甚至愈演愈烈。而失去了能够维系凝聚力的外敌的政府内也很快就内斗了起来，乌干达自由运动不满军队对布干达人的种族歧视，这使其在镇压全国抵抗军成功后不久遭到军政府强制解散，驻扎在坎帕拉城郊的乌干达自由运动部队被屠戮一空，而民主党很快也步其后尘。乌干达的未来会如何，只有天知道"
const TXT_R0_PRORPC := "乌干达或许是世界上最富饶的国家之一——它有着广袤的土地，充足的劳动力，丰富的自然资源，然而，殖民者与受殖民者控制的后独立时代流氓资产阶级领导人的统治将该国变成了一片充斥着独裁暴力、贪污腐败与部族主义的土地，但好在，那都已成为过去式了。随着全国抵抗军解放坎帕拉、击败逃往北部和东部地区的政府军溃部并最终占领全国，一个彻底摆脱新殖民主义控制的新乌干达诞生了。新政府以约韦里·穆塞韦尼为总统，丹尼·纳布代尔出任总理。全国抵抗运动政府宣布将以穆塞韦尼在游击战时制定的十点纲领为核心进行新民主主义建设，没收一切官僚、买办、地主的资产，将主要经济命脉与土地收归国有，以各级抵抗委员会为模板建立新的行政体系，所有民族一律平等，效仿莫桑比克模式在全国各地建立公社村与合作社，以消除部族、语言、性别、宗教与文化上的差异，消灭部族主义与新殖民主义，建立一个“与过去新旧殖民主义的统治截然不同的社会主义乌干达”。\n前政府军的残余势力在其组织起的乌干达人民民主军溃败后迅速逃窜、分裂或加入其他团体，有的甚至彻底同阿明残军合流，乌干达如雨后春笋般涌现出许多阿乔利人的半土匪式团体，不过，他们的所作所为注定了这些武装只能成为得不到支持的无根浮萍。\n旧政权给全国抵抗运动政府留下的遗产，是一个残破不堪的乌干达，经济惨淡，民生凋敝，外债累累，基础设施荒废，全国上下百废待兴。为了支援乌干达的战后重建工作，我国向该国提供了一笔无息贷款，并派驻了几批医疗队和工程队，坦桑尼亚、莫桑比克等非洲革命国家也向该国提供了援助。"
const TXT_R0_LIBERAL := "乌干达或许是世界上最富饶的国家之一——它有着广袤的土地，充足的劳动力，丰富的自然资源，然而，殖民者与受殖民者控制的后独立时代流氓资产阶级领导人的统治将该国变成了一片充斥着独裁暴力、贪污腐败与部族主义的土地，但好在，那都已成为过去式了。随着全国抵抗军解放坎帕拉、击败逃往北部和东部地区的政府军溃部并最终占领全国，一个彻底摆脱新殖民主义控制的新乌干达诞生了。约韦里·穆塞韦尼出任新总统，全国抵抗运动政府宣布将以穆塞韦尼在游击战时制定的十点纲领为核心进行民主建设，重建民主制度，保障公民安全，消除一切形式的宗派主义，捍卫和巩固国家独立，建设独立、多方面、自给自足的国民经济，恢复和改善社会服务、重建受战争破坏地区，消除腐败和滥用权力。为了杜绝独立以来乌干达长期内战、政权频繁更迭、社会动荡和党派林立的现象，实现民族和解，建立一个基础广泛的联合政府，抵运政府实行了以抵运为唯一执政团体的“无党政治”，吸纳人民大会党、民主党、乌干达自由运动等国内政治力量的代表进入参加政府。在经济政策上，该国实行了混合经济制度，向中国学习，自力更生，充分利用和开发乌干达资源，同时尽力吸引外资、争取外援，积极与各国开展贸易，促进国内民营资本发展。为了争取到布干达、布尼奥罗等南部地区的支持，抵运还恢复了乌干达内部各王国的文化地位，传统领袖只有文化上的地位，被明确禁止染指党派政治活动。\n旧政权给全国抵抗运动政府留下的遗产，是一个残破不堪的乌干达，经济惨淡，民生凋敝，外债累累，基础设施荒废，全国上下百废待兴。为了支援乌干达的战后重建工作，我国向该国提供了一笔援助，为其制定了经济发展计划，并派驻了几批医疗队和工程队，坦桑尼亚、肯尼亚、莫桑比克等国家也向该国提供了援助。"
const TXT_R0_AMIN := "令人难以置信的事情发生了！倚仗于我们的大力援助与扎伊尔的直接干涉，西尼罗河的阿明残部成功打回了坎帕拉，再次接管了乌干达。临时政府由阿明的左膀右臂、恶名昭彰的“屠夫”——艾萨克·马里亚蒙古准将领导，几天后，阿明也从沙特阿拉伯返回了乌干达，开始了自己的第二次统治。在此前攻占北方阿乔利人与兰戈人地区时，阿明部队便在当地展开了大屠杀，而在重新控制首都后，新政府立即开始了又一次对奥博特政府的清算，搜刮的财产被西尼罗河士兵瓜分，坎帕拉街头被洗劫一空，大量乌干达民族解放阵线成员被处死，有的高层干部甚至被在电视上公开处决。阿明的归来震惊了非洲，坦桑尼亚强烈谴责新阿明政府的血腥行动与扎伊尔的干涉，宣布不承认新政府，并再次资助流亡者组织起武装反攻乌干达。刚从阿明时代的灾难中蹒跚走出的乌干达被重新拖回了深渊之中……"
const TXT_R0_FEDERAL_PRE := "乌干达的血腥内战以一位出人意料的选手的胜利拉上了帷幕。由于政府军接连惨败于反对派武装，蒂托·奥凯洛与巴西里奥·奥凯洛等阿乔利人军官宣布跳反，支持乌干达自由运动一方，带领自己下属的部队从古卢出发向坎帕拉进军。最后，在两方的夹击下，以乌干达自由运动为首的布干达人武装拿下了整个布干达地区，并乘胜追击，将布尼奥罗、安科莱、托罗罗等其他南部各前王国的领土收入囊中，最终在阿乔利人军队的支持下控制了全国大部分地区。\n"
const TXT_R0_FEDERAL := "在新政府随后举行的大选中，由于有着布干达人的支持，保守党一举拨得了头筹，与乌干达自由运动组成联合政府。新政府由安德鲁·卡伊拉任总理，马扬加·恩坎吉任总统，蒂托·奥凯洛任国防部长。新政府宣布将在乌干达恢复民主、铲除腐败、结束内乱，并推行联邦化改革、复辟布干达君主制。在保守党政府上台后不久就颁布的新宪法中，乌干达国名正式改为乌干达联邦，新宪法规定了乌干达联邦是一个由南方布干达、布尼奥罗、托罗、安科莱四王国与北方各州组成的联邦制君主国，各邦王室在自己的王国内享有政治特权，最高元首在四王国君主选出，任期四年，可无限制连任。布干达先王穆特布二世的儿子穆文达·穆特比二世加冕成为布干达卡巴卡（国王）与第一任乌干达联邦最高元首。当然，这很快就使新政权遭到了北方人、非布干达的南方人、布干达天主教徒与穆斯林的激烈反对，而阿乔利人军队内部也由于利益分配、军队合并问题和新政府政策而产生了分歧，部分阿乔利军官与阿明残部联合成立了乌干达人民民主军，掀起了对新政府的叛乱。总之，新政权总归比奥博特好……大概？"
const TXT_UGANDA_FEDERATION := "乌干达联邦"
const TXT_R0_DEMOCRAT := "在新政府随后举行的大选中，由于有着阿乔利人（绝大部分是天主教徒）主导的前政府军与布干达人的支持，民主党一举拨得了头筹，与乌干达自由运动组成联合政府。新政府由安德鲁·卡伊拉任总理，保罗·塞莫格雷雷任总统，蒂托·奥凯洛任国防部长。新政府宣布将在乌干达恢复民主、铲除腐败、结束内乱，并维护乌干达作为单一制统一国家的身份。民主党政府还加大了经济私有化与引入外国资本的力度，积极鼓励外国投资，很快便与IMF与世界银行签订了几份合同。当然，北方新教徒、非布干达的南方人与穆斯林并不乐意布干达人主导国政，而许多布干达人也对这个与过去历届政府一样反对布干达自治且反君主制的政府心怀不满。总之，新政权总归比奥博特好……大概？"
const TXT_R0_ELSE := "乌干达或许是世界上最富饶的国家之一——它有着广袤的土地，充足的劳动力，丰富的自然资源，然而，殖民者与受殖民者控制的后独立时代流氓资产阶级领导人的统治将该国变成了一片充斥着独裁暴力、贪污腐败与部族主义的土地，但好在，那都已成为过去式了。随着全国抵抗军解放坎帕拉、击败逃往北部和东部地区的政府军溃部并最终占领全国，一个彻底摆脱新殖民主义控制的新乌干达诞生了。约韦里·穆塞韦尼出任新总统，全国抵抗运动政府宣布将以穆塞韦尼在游击战时制定的十点纲领为核心进行民主建设，重建民主制度，保障公民安全，消除一切形式的宗派主义，捍卫和巩固国家独立，建设独立、多方面、自给自足的国民经济，恢复和改善社会服务、重建受战争破坏地区，消除腐败和滥用权力。为了杜绝独立以来乌干达长期内战、政权频繁更迭、社会动荡和党派林立的现象，实现民族和解，建立一个基础广泛的联合政府，抵运政府实行了以抵运为唯一执政团体的“无党政治”，吸纳人民大会党、民主党、乌干达自由运动等国内政治力量的代表进入参加政府。在经济政策上，该国实行了混合经济制度，自力更生，充分利用和开发乌干达资源，同时尽力吸引外资、争取外援，积极与各国开展贸易，促进国内民营资本发展。为了争取到布干达、布尼奥罗等南部地区的支持，抵运还恢复了乌干达内部各王国的文化地位，传统领袖只有文化上的地位，被明确禁止染指党派政治活动。\n旧政权给全国抵抗运动政府留下的遗产，是一个残破不堪的乌干达，经济惨淡，民生凋敝，外债累累，基础设施荒废，全国上下百废待兴。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var war := _get_war(world, 81)
	var war_name := war.name_war if (war != null and war.name_war != "") else "乌干达内战"
	event_def.description = TXT_DESC_1 + war_name + TXT_DESC_2


## 复杂触发钩子（EventDef.trigger_script 调用）。
func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var war81 := _get_war(world, 81)
	var uganda := world.get_country_by_legacy_index(118)
	# TimeScript.cs:1900-1910：乌干达北约影响>=1000 提前触发（原版同时写 data[82]=81）
	if world.completed_event_ids.has("event_659") and (war81 == null or not war81.is_going) and uganda != null and uganda.influence_nato >= 1000:
		return true
	# TimeScript.cs:7094-7098 / GameState.WarCheck(81)
	if war81 != null and war81.is_going and world.数值表.size() > W.I_WAR_RESOLVE and world.数值表[W.I_WAR_RESOLVE] < 0:
		if war81.fortnight_elapsed >= war81.fortnight_max or war81.infl1 >= 1000 or war81.infl2 >= 1000:
			return true
	return false


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uganda := ws.get_country_by_legacy_index(118)
	var war81 := _get_war(ws, 81)
	# 原版 ResultsOfEvents 顶部公共效果
	if war81 != null:
		war81.is_going = false
	if uganda != null:
		_set_parts0(uganda, false)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		if war81 != null and war81.infl2 >= 900:
			if not ws.completed_event_ids.has("event_660"):
				context["result_text"] = TXT_R0
				if ws.completed_event_ids.get("event_659", 0) == 1 and uganda != null:
					uganda.set_tag("亲中", true)
			else:
				context["result_text"] = TXT_R0_DONE660
				if uganda != null:
					uganda.government = GameConstants.Government.AUTHORITARIAN
					uganda.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
					_leave_alliances(uganda)
					uganda.set_tag("亲美", true)
		elif ws.completed_event_ids.get("event_659", 0) == 2:
			if uganda != null:
				_leave_alliances(uganda)
				uganda.set_tag("亲中", true)
				uganda.set_tag("对华贸易", true)
			if _mod_active(ws, 6):
				context["result_text"] = TXT_R0_PRORPC
				if uganda != null:
					uganda.government = GameConstants.Government.SOCIALIST
					uganda.sub_government = GameConstants.SubGovernment.MAOIST
			else:
				context["result_text"] = TXT_R0_LIBERAL
				if uganda != null:
					uganda.government = GameConstants.Government.REFORMIST
					uganda.sub_government = GameConstants.SubGovernment.PRAGMATIST
		elif ws.completed_event_ids.get("event_659", 0) == 3:
			context["result_text"] = TXT_R0_AMIN
			if uganda != null:
				_leave_alliances(uganda)
				uganda.puppet_of = 117
				uganda.set_tag("对华贸易", true)
				uganda.government = GameConstants.Government.AUTHORITARIAN
				uganda.sub_government = GameConstants.SubGovernment.NEO_FASCIST
		elif ws.completed_event_ids.get("event_659", 0) == 4:
			var num := 0
			num += _count_liberal_or_auth(127)
			num += _count_liberal_or_auth(126)
			num += _count_liberal_or_auth(123)
			num += _count_liberal_or_auth(122)
			num += _count_liberal_or_auth(124)
			var text := TXT_R0_FEDERAL_PRE
			if num >= 2:
				text += TXT_R0_FEDERAL
				if uganda != null:
					_leave_alliances(uganda)
					uganda.set_tag("亲美", true)
					uganda.set_tag("对华贸易", true)
					uganda.government = GameConstants.Government.LIBERAL
					uganda.sub_government = GameConstants.SubGovernment.NEOLIBERAL
					uganda.chinese_name = TXT_UGANDA_FEDERATION
			else:
				text += TXT_R0_DEMOCRAT
				if uganda != null:
					_leave_alliances(uganda)
					uganda.set_tag("对华贸易", true)
					uganda.government = GameConstants.Government.LIBERAL
					uganda.sub_government = GameConstants.SubGovernment.MODERATE
			context["result_text"] = text
		else:
			context["result_text"] = TXT_R0_ELSE
			if uganda != null:
				uganda.government = GameConstants.Government.REFORMIST
				uganda.sub_government = GameConstants.SubGovernment.PRAGMATIST


func _get_war(world: WorldState, war_id: int) -> WarData:
	if world == null or war_id < 0 or war_id >= world.wars.size():
		return null
	return world.wars[war_id]


func _count_liberal_or_auth(legacy_index: int) -> int:
	var c := ws.get_country_by_legacy_index(legacy_index)
	if c == null:
		return 0
	return 1 if (c.government == GameConstants.Government.LIBERAL or ws.is_authoritarian(c)) else 0


func _set_parts0(c: CountryData, value: bool) -> void:
	if c == null:
		return
	if c.parts.size() == 0:
		c.parts.resize(1)
	c.parts[0] = value


## Country.LeaveAlliances() 逐项映射（同 Event713 约定）。

func _mod_active(world: WorldState, index: int) -> bool:
	return world.modifiers.size() > index and world.modifiers[index] != null and world.modifiers[index].is_active
