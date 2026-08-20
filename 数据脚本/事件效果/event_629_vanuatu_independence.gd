extends "res://数据脚本/event_script_base.gd"

## 原作 Event629.cs：你我，咱们，瓦努阿图人（瓦努阿图独立，三选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:956-959 ——
##   日期>=1980.7.30（原 (1980&&m>=7&&d>=30)||(1980&&m>=8)||y>=1981）
##   且 allcountries[21].SubGosstroy != 19（法国非特定路线）。
## 差异：原版选项2 Destroy(button[2])；Godot _disable 灰显同义。
##   Vyshi→亲美、proprc→亲中、Torg→对华贸易、cw→内战中、Gosstroy/SubGosstroy→government/sub_government。

const TXT_OPT0_PASSIVE := "然后发生了什么？"
const TXT_OPT0_SUPPORT := "我全押利尼神甫！"
const TXT_R0_STEVENS := "出乎意料的是，绰号“摩西”的吉米·斯蒂文斯获得了大选的胜利，他的纳格利亚梅尔党凭借着稳健的经济发展方针和对西方国家的“友好态度”获得了大多数国家的支持。但也有传闻称他获得了美国的凤凰基金会和法国人的支持。他宣布将稳步在瓦努阿图建立稳定的市场经济，从而改善民生。"
const TXT_R0_LINI := "不出所料，利尼阁下大获全胜。凭借在镇压分离主义者的“椰子战争”中的苦劳，积极争取独立的过程中的大费口舌，更重要的是我们的口头与物质支持。利尼的瓦努阿库党获得了漂亮的成绩。他正式当选总理一职（因为该国的总统事实上是总督的延续）。随后，他借鉴了尼雷尔，我国和毕晓普的经验。他宣布要在瓦努阿图建成一个没有人剥削人的社会，并在原先的美拉尼西亚社会主义的基础中加入了社会主义元素。上台数天后，该国宣布废除继承自威斯敏斯特的议会制。转而采用“村社制”，即直接设立村一级别的“议院”，只要是瓦努阿图公民，均有随时随地参政议政的权力（这也得益于该国国小民寡），新的一篇《瓦努阿图社会变革宪章》甚至获得了20000人次的参与编写。我们高度赞扬了利尼的为政举措，并派出了大量的教员和赤脚医生用来提供帮助。利尼也感谢了我们为了第三世界国家的共同进步而作出的努力。\n在外交事务方面，利尼加入了不结盟运动，反对南非的种族隔离和一切形式的殖民主义，与利比亚和古巴建立了联系，并反对法国在新喀里多尼亚的存在和法属波利尼西亚的核试验。他们有底气，因为他们的背后是8亿人民！"
const TXT_R0_MODERATE := "不出所料，利尼阁下赢得了选举。凭借在镇压分离主义者的“椰子战争”中的苦劳，和积极争取独立的过程中的大费口舌。利尼的瓦努阿库党获得了漂亮的成绩。他正式当选总理一职（因为该国的总统事实上是总督的延续）。他也试着依靠坦桑尼亚经验组织了公社村，试点了直接民主和农业改革；在外交事务方面，利尼加入了不结盟运动，反对南非的种族隔离和一切形式的殖民主义，与利比亚和古巴建立了联系，并反对法国在新喀里多尼亚的存在和法属波利尼西亚的核试验。但对于一个弹丸小国来说，维持独立已经是想当可贵的了。"
const TXT_R1_STEVENS := "出乎意料的是，绰号“摩西”的吉米·斯蒂文斯获得了大选的胜利，他的纳格利亚梅尔党凭借着稳健的经济发展方针和对西方国家的“友好态度”获得了大多数国家的支持。但也有传闻称他获得了美国的凤凰基金会和法国人的支持。他宣布将稳步在瓦努阿图建立稳定的市场经济，从而改善民生。我们也没有落俗，吉米亲切的会见了我国代表团，并和我们建立了外交关系。"
const TXT_R1_LINI := "不出所料，利尼阁下大获全胜。凭借在镇压分离主义者的“椰子战争”中的苦劳，积极争取独立的过程中的大费口舌，更重要的是我们的口头与物质支持。利尼的瓦努阿库党获得了漂亮的成绩。他正式当选总理一职（因为该国的总统事实上是总督的延续）。随后，他借鉴了尼雷尔，我国和毕晓普的经验。他宣布要在瓦努阿图建成一个没有人剥削人的社会，并在原先的美拉尼西亚社会主义的基础中加入了社会主义元素。上台数天后，该国宣布废除继承自威斯敏斯特的议会制。转而采用“村社制”，即直接设立村一级别的“议院”，只要是瓦努阿图公民，均有随时随地参政议政的权力（这也得益于该国国小民寡），新的一篇《瓦努阿图社会变革宪章》甚至获得了20000人次的参与编写。我们高度赞扬了利尼的为政举措，并派出了大量的教员和赤脚医生用来提供帮助。利尼也感谢了我们为了第三世界国家的共同进步而作出的努力。\n在外交事务方面，利尼加入了不结盟运动，反对南非的种族隔离和一切形式的殖民主义，与利比亚和古巴建立了联系，并反对法国在新喀里多尼亚的存在和法属波利尼西亚的核试验。他们有底气，因为他们的背后是8亿人民！"
const TXT_R1_MODERATE := "不出所料，利尼阁下赢得了选举。凭借在镇压分离主义者的“椰子战争”中的苦劳，和积极争取独立的过程中的大费口舌。利尼的瓦努阿库党获得了漂亮的成绩。他正式当选总理一职（因为该国的总统事实上是总督的延续）。他也试着依靠坦桑尼亚经验组织了公社村，试点了直接民主和农业改革；在外交事务方面，利尼加入了不结盟运动，反对南非的种族隔离和一切形式的殖民主义，与利比亚和古巴建立了联系，并反对法国在新喀里多尼亚的存在和法属波利尼西亚的核试验。我们高度赞扬了利尼的新政府，并派出了大量的教员和赤脚医生用于提供帮助。利尼也感谢了我们为了第三世界国家的共同进步而作出的努力。但对于一个弹丸小国来说，维持独立已经是想当可贵的了。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var vanuatu := ws.get_country_by_legacy_index(159)
	var china := ws.get_country_by_legacy_index(1)
	var usa_power := ws.empires[0].power if ws.empires.size() > 0 and ws.empires[0] != null else 0
	var sov_power := ws.empires[1].power if ws.empires.size() > 1 and ws.empires[1] != null else 0
	var passive := (vanuatu != null and vanuatu.level_of_instability <= 0) \
		or ws.is_socialism(china, false) \
		or (sov_power < usa_power and china != null and china.has_tag("asean"))
	var opt := event_def.options
	if passive:
		_enable(opt[0], TXT_OPT0_PASSIVE)
	else:
		_enable(opt[0], TXT_OPT0_SUPPORT)
	_enable(opt[1], event_def.options[1].text)
	_disable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var vanuatu := ws.get_country_by_legacy_index(159)
	var china := ws.get_country_by_legacy_index(1)
	var opt := int(context.get("option_index", -1))
	if vanuatu == null:
		return
	# 原版 :37：ResultsOfEvents 开头统一改名
	vanuatu.chinese_name = "瓦努阿图"
	var usa_power := ws.empires[0].power if ws.empires.size() > 0 and ws.empires[0] != null else 0
	var sov_power := ws.empires[1].power if ws.empires.size() > 1 and ws.empires[1] != null else 0
	var stevens := sov_power < usa_power and china != null and china.has_tag("asean")
	var lini := (not stevens) and vanuatu.level_of_instability > 0 and ws.is_socialism(china, true)
	match opt:
		0:
			_apply_result(context, vanuatu, stevens, lini)
		1:
			_apply_result(context, vanuatu, stevens, lini)
			_add(W.I_BUDGET, -30)
			vanuatu.set_tag("对华贸易", true)


## 原版 :40-72 与 :76-108 的公共分支（opt1 额外扣预算+建交）。
func _apply_result(context: Dictionary, vanuatu: CountryData, stevens: bool, lini: bool) -> void:
	if stevens:
		context["result_text"] = TXT_R0_STEVENS if int(context.get("option_index", -1)) == 0 else TXT_R1_STEVENS
		vanuatu.government = 3
		vanuatu.sub_government = 6
		_leave_alliances(vanuatu)
		vanuatu.set_tag("亲美", true)
		_add_power(EmpireData.USA, 10)
	elif lini:
		context["result_text"] = TXT_R0_LINI if int(context.get("option_index", -1)) == 0 else TXT_R1_LINI
		vanuatu.government = 1
		vanuatu.sub_government = 1
		_leave_alliances(vanuatu)
		vanuatu.set_tag("亲中", true)
		vanuatu.set_tag("对华贸易", true)
		ws.influence_prc += 10
		_add_power(EmpireData.USA, -10)
		_add_relation(EmpireData.USA, -70)
	else:
		context["result_text"] = TXT_R0_MODERATE if int(context.get("option_index", -1)) == 0 else TXT_R1_MODERATE
		vanuatu.government = 2
		vanuatu.sub_government = 3
		_leave_alliances(vanuatu)
		_add_power(EmpireData.USA, -10)
		if vanuatu.内战中:
			vanuatu.set_tag("亲中", true)
