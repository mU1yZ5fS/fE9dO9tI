extends "res://数据脚本/event_script_base.gd"

## 原作 Event99.cs：黄蝎（阿尔及利亚布迈丁继承危机，四选项）。
## 触发：TimeScript.cs:10843-10849 ——
##   ((日>=10 且 月>=12 且 年>=1978) || 年>=1979)。
## 差异：选项显隐 prepare 动态改写；r1 的 data.oil_price++ 为局部指针死代码，跳过。

const TXT_R0 := "多亏了我们的支持，正统布迈丁主义者穆罕默德·雅伊奥维能够打击反对派并且使民族解放阵线任命他为总书记，全国人民议会也任命他为阿尔及利亚代理总统。提前选举定于1979年2月8日举行，然而，作为一个一党制国家内举行并且没有其他选项的选举的结果是可想而知的。新政府宣布将外交政策转向亲中方向，并邀请我们签署一项非常有利可图的贸易合同。苏联对中国干涉阿尔及利亚内政作出了消极的反应。雅伊奥维上校坚持了布迈丁总统的社会主义与泛阿拉伯主义理念，继续在全国推行“民族主义、社会主义与伊斯兰教相结合”的阿拉伯-伊斯兰化，不过，布迈丁时期工业化的快速推进与石油红利带来的快速发展导致的弊病也开始显现出来，对农业建设的忽视与失败的土地改革使阿尔及利亚农业发展相当低效。阿拉伯民族主义的政策也引起了同样在阿尔及利亚革命中作出过很大贡献的民族——柏柏尔人的不满，他们举行了要求废除对柏柏尔文化的歧视性政策的抗议，而这并没有掀起什么风浪。在夺权进程中支持了雅伊奥维的社会主义先锋党也顺利拿到了投名状，解散后被吸纳进了政府，而这当然是以他们放弃阶级斗争和马克思列宁主义为前提的，但谁会在乎这些呢。"

const TXT_R1 := "在我们特工的帮助下，长期以来被视为布迈丁政权的二号人物的外交部长布特弗利卡镇压了党内反对派，民族解放阵线紧急会议选举他为总书记；全国人民议会任命他为阿尔及利亚代理总统，提前选举定于1979年2月8日举行，然而，作为一个一党制国家内举行并且没有其他选项的选举的结果是可想而知的。布特弗利卡感谢我们的支持，并提供了一个非常有利可图的合同。在完成了个人权力的巩固后，布特弗利卡便引入了一定的经济自由主义，放松了对私营企业和外国投资的限制，并加深了与巴黎和华盛顿的关系。尽管这样温和的改革不能取悦任何人，但至少乌季达帮的地位得到了巩固，不是吗？"

const TXT_R2 := "我们支持革命委员会挑选出的沙德利·本·杰迪德，结果成功击败了布迈丁选定的继承人雅伊奥维，与布迈丁总统关系密切的布特弗利卡也被免去外交部长职务，转任次要职务。民族解放阵线紧急会议任命本·杰迪德为总书记，全国人民议会任命他为阿尔及利亚代理总统，提前选举定于1979年2月8日举行，然而，作为一个一党制国家内举行并且没有其他选项的选举的结果是可想而知的。新政府进行了静悄悄的“去布迈丁化”，开始了肢解国有资本、向市场经济转变的进程，乌季达帮也被排挤出权力核心之外。过去激进的外交政策也转向缓和，在维持与非洲国家的关系的同时与法国和西方建立了新联系。内阁、人民议会和军队中都进行了重大的人事变动，布迈丁主义者们逐渐被新总统的东部老乡所取代。通过不断的政治清洗，本·杰迪德清除了与布迈丁时代有关联的任何潜在竞争对手。经济自由化带来了一系列问题（诸如侵吞国有资产、严重的贪污腐败、物价上涨），这引起了人民的普遍不满，再加上统治集团内部的矛盾与政府控制力的下降，很多反对派开始在地下活跃起来。"

const TXT_R3 := "民族解放阵线紧急会议任命改革派领袖沙德利·本·杰迪德为“妥协”总书记，全国人民议会任命他为阿尔及利亚代理总统，提前选举定于1979年2月8日举行，然而，作为一个一党制国家内举行并且没有其他选项的选举的结果是可想而知的。新政府进行了静悄悄的“去布迈丁化”，开始了肢解国有资本、向市场经济转变的进程，乌季达帮也被排挤出权力核心之外。过去激进的外交政策也转向缓和，在维持与非洲国家的关系的同时与法国和西方建立了新联系。内阁、人民议会和军队中都进行了重大的人事变动，布迈丁主义者们逐渐被新总统的东部老乡所取代。通过不断的政治清洗，本·杰迪德清除了与布迈丁时代有关联的任何潜在竞争对手，经济自由化带来了一系列问题（诸如侵吞国有资产、严重的贪污腐败、物价上涨），这引起了人民的普遍不满。再加上统治集团内部的矛盾与政府控制力的下降，很多反对派开始在地下活跃起来。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var agents := data.agents if data.size() > W.I_AGENTS else 0
	var coal := _coalition_percent(world)
	var left_party := party < 8
	var opt := event_def.options
	if (line < 3 and left_party) or (coal > 66 and party > 7):
		_enable(opt[0], "我们将帮助正统派反对修正主义")
	else:
		_disable(opt[0], "我看布迈丁的遗产也应该扬弃了")
	if (line > 1 and line < 4 and left_party) or (coal > 66 and party > 7):
		_enable(opt[1], "帮助乌季达帮的“自由派”崛起")
	else:
		_disable(opt[1], "布特弗利卡？祝他好运")
	if agents >= 60 and ((line >= 3 and left_party) or (coal > 66 and party > 7)):
		_enable(opt[2], "支持军队推出的改革者进行去布迈丁化")
	else:
		_disable(opt[2], "乌季达帮坐的时间有点太长了")
	_enable(opt[3], "袖手旁观")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var algeria := ws.get_country_by_legacy_index(40)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -60)
			_add(W.I_DIPLO, 10)
			ws.influence_prc += 10
			_add_power(EmpireData.USSR, -30)
			_add_relation(EmpireData.USSR, -100)
			if algeria != null:
				algeria.set_tag("亲苏", false)
				algeria.set_tag("亲中", true)
				algeria.set_tag("对华贸易", true)
			context["result_text"] = TXT_R0
		1:
			_add_power(EmpireData.USSR, 10)
			_add(W.I_AGENTS, -40)
			_add_relation(EmpireData.USA, -30)
			_add_relation(EmpireData.USSR, 50)
			if algeria != null:
				algeria.set_tag("对华贸易", true)
				algeria.set_tag("亲苏", false)
			# data.oil_price++ 局部指针死代码，跳过
			context["result_text"] = TXT_R1
		2:
			_add_power(EmpireData.USSR, -30)
			_add(W.I_AGENTS, -60)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -300)
			_add_power(EmpireData.USA, 30)
			if algeria != null:
				algeria.set_tag("对华贸易", true)
				algeria.government = GameConstants.Government.AUTHORITARIAN
				algeria.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				algeria.set_tag("亲苏", false)
				algeria.set_tag("亲美", true)
			if d.size() > 143:
				d.oil_price -= 3
			context["result_text"] = TXT_R2
		3:
			if algeria != null:
				algeria.government = GameConstants.Government.AUTHORITARIAN
				algeria.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			context["result_text"] = TXT_R3


func _coalition_percent(world: WorldState) -> int:
	var data := world
	if data.size() <= W.I_PARTY_SYSTEM or data.party_system <= 7:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total



