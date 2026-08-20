extends "res://数据脚本/event_script_base.gd"

## 原作 Event673.cs：乞丐死时不会有彗星出现……（英国国防政府，五选项）。
## 触发：DiploButtonScript.cs:12369 —— 外交按钮 1064，入口扣预算100/特工200后手动触发。
## 差异：Vyshi→亲美、isEU/isNATO→eu/nato、Torg→对华贸易；now_leader→empires[0].current_leader。

const TXT_OPT0_DIS := "ACAB，所有警察都是混蛋……"
const TXT_OPT1_DIS := "无论犯了什么错误，都要为英国能拥有这样的未来而欢呼"
const TXT_OPT2_DIS := "极右翼？谁？从地狱里把莫斯利爵士请回来吗？"
const TXT_OPT3_DIS := "对，亲爱的，资本主义正值危机，但街垒又在哪呢？"
const TXT_R0 := "来自保守党内强硬派利益集团“星期一俱乐部”的退伍将军沃尔特·沃克爵士最终被推举为国防政府的首相。在就职仪式上，这位老将军宣誓要让“爱尔兰恐怖分子”与“莫斯科的提线木偶们”“血债血偿”，“为玛吉（即玛格丽特·撒切尔）复仇”。\n很快，工党便被加以“共产主义者的特洛伊木马”罪名强制解散，其成员纷纷被捕，哈罗德·威尔逊、迈克尔·富特等历史性领导人被逮捕入狱。沃克首相亲自主持了“清查战斗派”与“挖硬左派红线，肃共产党流毒”运动，工党基层党员和左派干部被大批以“英奸”“莫斯科特务”“共产党分子”罪名逮捕（据称，在战斗派执政的利物浦市，工作小组共从当地议会的五十余名工党议员中揪出了四十名战斗派分子）。该国各类共产主义团体与工会组织的下场也不言自明，试图以罢工和武装起义螳臂当车的工人们则有幸成为了挑战者一式坦克的首个实战对象。而酿成惨剧的“罪魁祸首”爱尔兰共和军更是招致武装部队的全面镇压，北爱尔兰六郡被彻底军管，周边海域也遭到皇家海军的封锁，当局毫不避讳地将本国在肯尼亚与马来亚“紧急状态”的残酷镇压经验引入北爱尔兰，天主教社区被以带刺铁丝网围栏构成的“和平线”物理分割，散居在乡下的北爱尔兰人则被迁至新村集中管辖，由军警与阿尔斯特效忠派准军事组织直接负责各社区的管理，任何被怀疑与爱尔兰共和军有联系者都将被赏赐一颗子弹。\n看来光荣革命后的英国议会传统终究还是被扫进了历史的垃圾堆之中……"
const TXT_R1 := "来自保守党内强硬派利益集团“星期一俱乐部”的朱利安·阿默里最终被推举为国防政府的首相。在就职仪式上，这位惯常批评撒切尔政府“将罗得西亚出卖给黑人”和其经济自由主义施政的政治家一反常态地宣誓要从“爱尔兰恐怖分子”手中拯救“帝国的自由与民主”，“为玛吉（即玛格丽特·撒切尔）复仇”。\n很快，工党便被加以“共产主义者的特洛伊木马”罪名进行了清洗，哈罗德·威尔逊、迈克尔·富特等历史性人物被“隔离审查”。阿默里首相亲自主持了“清查战斗派”与“挖硬左派红线，肃共产党流毒”运动，工党基层党员和左派干部被大批以“英奸”“莫斯科特务”“共产党分子”罪名逮捕（据称，在战斗派执政的利物浦市，工作小组共从当地议会的五十余名工党议员中揪出了三十名战斗派分子）。该国各类共产主义团体与工会组织的下场也不言自明，试图以罢工进行抵抗的工人们则有幸体验到骑马与砍杀的乐趣，成为了不列颠最后一场骑兵冲锋的主角。而酿成惨剧的“罪魁祸首”爱尔兰共和军更是招致武装部队的全面镇压，北爱尔兰六郡被彻底军管，周边海域也遭到皇家海军的封锁，当局毫不避讳地将本国在肯尼亚与马来亚“紧急状态”的残酷镇压经验引入北爱尔兰，天主教社区被以带刺铁丝网围栏构成的“和平线”物理分割，散居在乡下的爱尔兰人则被迁至新村集中管辖，由军警与阿尔斯特效忠派准军事组织直接负责各社区的管理，任何被怀疑与爱尔兰共和军有联系者都将被赏赐一颗子弹。\n在完成了这一系列行动后，将军们事了拂衣去，宣布解散国防政府（但保留了一个能够无条件否决议会通过的政策、全部由职业军人构成的不列颠防卫委员会），恢复议会（当然不包括北爱尔兰地区）与选举。阿默里首相与保守党在大选中取得超过500席的绝对多数席位。英国的新时代就此到来。"
const TXT_R2 := "来自保守党内强硬派利益集团“星期一俱乐部”的伊诺克·鲍威尔最终被推举为国防部长的首相。在就职仪式上，这位英国右翼的灵魂人物宣誓要从“爱尔兰恐怖分子”与“莫斯科的提线木偶们”手中拯救“帝国的光荣与希望”，“为玛吉（即玛格丽特·撒切尔）复仇”。\n很快，工党便被加以“共产主义者的特洛伊木马”罪名强制解散，其成员纷纷被捕，哈罗德·威尔逊、迈克尔·富特等历史性领导人被逮捕入狱。鲍威尔首相亲自主持了“清查战斗派”与“挖硬左派红线，肃共产党流毒”运动，工党基层党员和左派干部被大批以“英奸”“莫斯科特务”“共产党分子”罪名逮捕（据称，在战斗派执政的利物浦市，工作小组共从当地议会的五十余名工党议员中揪出了五十名战斗派分子）。该国各类共产主义团体与工会组织的下场也不言自明，试图以罢工和武装起义螳臂当车的工人们则有幸成为了挑战者一式坦克的首个实战对象。而酿成惨剧的“罪魁祸首”爱尔兰共和军更是招致武装部队的全面镇压，北爱尔兰六郡被彻底军管，周边海域也遭到皇家海军的封锁，当局毫不避讳地将本国在肯尼亚与马来亚“紧急状态”的残酷镇压经验引入北爱尔兰，天主教社区被以带刺铁丝网围栏构成的“和平线”物理分割，散居在乡下的北爱尔兰人则被迁至新村集中管辖，由军警与阿尔斯特效忠派准军事组织直接负责各社区的管理，任何被怀疑与爱尔兰共和军有联系者都将被赏赐一颗子弹。"
const TXT_R2_STRASSER := "英帝国的每况愈下已使鲍威尔逐渐相信右翼理论家A·K·切斯特顿有关“美苏联合反英阵线，威胁主权英国”的理论，因此他将民族阵线内倾向施特拉瑟主义与革命民族主义的政治战士派头领德里克·霍兰、帕特里克·哈灵顿、尼克·格里芬、另类阿尔斯特民族主义者大卫·克尔和在切斯特顿逝世后负责帝国忠诚者联盟期刊《坦诚》杂志的罗西娜·德·布内维亚尔纳入了内阁中，而首相本人抱恙的身体情况则使得政府的实际运作越发仰赖这些第三位置部长与幕僚们。奥斯瓦尔德·莫斯利爵士的英国“社会主义帝国主义”之梦以一种完全出乎所有人意料的方式变成了现实……"
const TXT_R2_FASCIST := "英帝国的每况愈下已使鲍威尔逐渐相信右翼理论家A·K·切斯特顿有关“美苏联合反英阵线，威胁主权英国”的理论，因此他将英国民族党领袖约翰·延德尔、英国最具影响力的新纳粹活动家科林·乔丹、民族阵线内倾向传统法西斯主义的旗帜集团派头领安德鲁·布朗斯和臭名昭著的极右翼种族主义者简·博德伍德女男爵纳入了内阁中，而首相本人抱恙的身体情况则使得政府的实际运作越发仰赖这些极右翼部长与幕僚们。奥斯瓦尔德·莫斯利爵士的英国法西斯主义之梦以一种完全出乎所有人意料的方式变成了现实……"
const TXT_R3 := "我们发送给英国左翼与爱尔兰共和军的电报不幸成为真正的“季诺维也夫书信”，被国防政府所截获，其全文被直接刊登于《每日邮报》《金融时报》《太阳报》等媒体上，成为了国防政府打击左翼势力的借口。\n来自保守党内强硬派利益集团“星期一俱乐部”的退伍将军沃尔特·沃克爵士最终被推举为国防政府的首相。在就职仪式上，这位老将军宣誓要让“爱尔兰恐怖分子”与“北京的提线木偶们”“血债血偿”，“为玛吉（即玛格丽特·撒切尔）复仇”。\n很快，工党便被加以“共产主义者的特洛伊木马”罪名强制解散，其成员纷纷被捕，哈罗德·威尔逊、迈克尔·富特等历史性领导人被逮捕入狱。沃克首相亲自主持了“清查战斗派”与“挖硬左派红线，肃共产党流毒”运动，工党基层党员和左派干部被大批以“英奸”“中国特务”“共产党分子”罪名逮捕（据称，在战斗派执政的利物浦市，工作小组共从当地议会的五十余名工党议员中揪出了六十名战斗派分子）。该国各类共产主义团体与工会组织的下场也不言自明，试图以罢工和武装起义螳臂当车的工人们则有幸成为了挑战者一式坦克的首个实战对象。而酿成惨剧的“罪魁祸首”爱尔兰共和军更是招致武装部队的全面镇压，北爱尔兰六郡被彻底军管，周边海域也遭到皇家海军的封锁，当局毫不避讳地将本国在肯尼亚与马来亚“紧急状态”的残酷镇压经验引入北爱尔兰，天主教社区被以带刺铁丝网围栏构成的“和平线”物理分割，散居在乡下的北爱尔兰人则被迁至新村集中管辖，由军警与阿尔斯特效忠派准军事组织直接负责各社区的管理，任何被怀疑与爱尔兰共和军有联系者都将被赏赐一颗子弹。\n看来光荣革命后的英国议会传统终究还是被扫进了历史的垃圾堆之中……"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 5:
		return
	var opt := event_def.options
	var usa_leader := ws.empires[EmpireData.USA].current_leader if ws.empires.size() > EmpireData.USA \
		and ws.empires[EmpireData.USA] != null else 0
	var usa_rel := ws.empires[EmpireData.USA].relations if ws.empires.size() > EmpireData.USA \
		and ws.empires[EmpireData.USA] != null else 0
	var france := ws.get_country_by_legacy_index(21)
	var spain := ws.get_country_by_legacy_index(85)
	if _res(W.I_POLITICAL_LINE) >= 3 and usa_rel >= 500:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if usa_leader == 3 or (usa_leader == 1 and france != null and france.government == 3 \
			and spain != null and spain.government == 3):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if _auth_count() >= 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if _res(W.I_POLITICAL_LINE) < 2:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uk := ws.get_country_by_legacy_index(92)
	if uk == null:
		return
	var usa_leader := ws.empires[EmpireData.USA].current_leader if ws.empires.size() > EmpireData.USA \
		and ws.empires[EmpireData.USA] != null else 0
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			uk.government = 0
			uk.sub_government = 7
			uk.set_tag("亲美", true)
			uk.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 20)
		1:
			context["result_text"] = TXT_R1
			uk.government = 0
			uk.sub_government = 20
			uk.set_tag("亲美", true)
			uk.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 20)
		2:
			var num := _sub22_count()
			if num >= 1:
				context["result_text"] = TXT_R2 + TXT_R2_STRASSER
				uk.government = 0
				uk.sub_government = 22
			else:
				context["result_text"] = TXT_R2 + TXT_R2_FASCIST
				uk.government = 0
				uk.sub_government = 9
			uk.set_tag("亲美", false)
			uk.set_tag("eu", false)
			uk.set_tag("nato", false)
			uk.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, -20)
		3:
			context["result_text"] = TXT_R3
			uk.government = 0
			uk.sub_government = 7
			uk.set_tag("亲美", true)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 20)
		4:
			var france := ws.get_country_by_legacy_index(21)
			var spain := ws.get_country_by_legacy_index(85)
			if (usa_leader == 3 or usa_leader == 1) and france != null and france.government == 3 \
					and spain != null and spain.government == 3:
				context["result_text"] = TXT_R1
				uk.government = 0
				uk.sub_government = 20
				uk.set_tag("亲美", true)
				_add_power(EmpireData.USA, 20)
			elif _auth_count() >= 2:
				var num3 := _sub22_count()
				if num3 >= 2:
					context["result_text"] = TXT_R2 + TXT_R2_STRASSER
					uk.government = 0
					uk.sub_government = 22
				else:
					context["result_text"] = TXT_R2 + TXT_R2_FASCIST
					uk.government = 0
					uk.sub_government = 9
				uk.set_tag("亲美", false)
				uk.set_tag("eu", false)
				uk.set_tag("nato", false)
				_add_power(EmpireData.USA, -20)
			else:
				context["result_text"] = TXT_R0
				uk.government = 0
				uk.sub_government = 7
				uk.set_tag("亲美", true)
				_add_power(EmpireData.USA, 20)


func _auth_count() -> int:
	var count := 0
	for idx in [21, 85, 86]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null and ws.is_authoritarian(c) and c.sub_government != 10 and c.sub_government != 20:
			count += 1
	return count


func _sub22_count() -> int:
	var count := 0
	for idx in [21, 85, 86]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null and c.sub_government == 22:
			count += 1
	return count
