extends "res://数据脚本/event_script_base.gd"

const TXT_372_698 := "新版色佛尔条约？"
const TXT_372_699 := "在土耳其于{1}战败后，世界的命运将直接取决于中东地区的局势。就解决这一问题，外交顾问提供了下述方案。第一项方案是建立独立的库尔德人国家，从而一劳永逸地解决当地的分离主义问题，并让当地人民自己决定其命运。然而，这将导致一个显著的问题——新库尔德国范围多大，其边界该如何划定？库尔德人分散居住在四个中东国家中，并且，这些国家并不想同库尔德人分享自己的领土。第二项方案则是建立民族自治区。是的，在部分国家内，这一制度已经得到了贯彻实行，但库尔德人依然受到当局的系统性同化。可即便是这样，也依然存在问题——谁的势力将主导这一进程，并控制未来世界的局势？此时，任何结果都在可预料的范畴中......"
const TXT_372_700 := "库尔德斯坦必须获得完全独立！"
const TXT_372_701 := "必须保证库尔德人的民族自治权！"
const TXT_372_1012 := "忽略"
const TXT_372_706 := "和平会议将在美国、苏联与中国三方的参与下在瑞士举行。其公布的结果如下：
{1}
{2}
{3}
{4}"
const TXT_372_707 := "中东的四处库尔德人聚居区——即土耳其属库尔德斯坦、伊拉克属库尔德斯坦、叙利亚属库尔德斯坦与伊朗属库尔德斯坦，将被统一为单一的库尔德斯坦共和国。该国已经开始重建一个两院制的议会，而人民议会已经建立。在该国局势稳定以前（即2000年前），该国都将实行有限的多党制。到目前为止，只有已经存在的地区性政党才有资格参与议会选举：即位于土耳其的库尔德斯坦工人党、位于叙利亚的民主联盟党、位于伊朗的库尔德斯坦自由生活党、位于伊拉克的库尔德斯坦爱国联盟与库尔德斯坦民主党。因此，囊括左翼与民主党派政治力量的库尔德斯坦临时政府已经建立。"
const TXT_372_708 := "由于土耳其国内爆发的大规模抗议运动，国家安全委员会政府最终倒台。在随后举行的选举中，土耳其工人党与共和人民党获得的选票旗鼓相当。因此，他们不得不达成协定，并建立由社会民主党人比伦特·埃杰维特领导的联合政府。"
const TXT_372_709 := "根据相关协定，美苏两国的维和部队将在未来的两年内驻扎在土耳其。"
const TXT_372_710 := "中东的三处库尔德人聚居区——即伊拉克属库尔德斯坦、叙利亚属库尔德斯坦与伊朗属库尔德斯坦，将被统一为单一的库尔德斯坦共和国。该国已经开始重建一个两院制的议会，而人民议会已经建立。在该国局势稳定以前（即2000年前），该国都将实行有限的多党制。到目前为止，只有已经存在的地区性政党才有资格参与议会选举：即位于叙利亚的民主联盟党、位于伊朗的库尔德斯坦自由生活党、位于伊拉克的库尔德斯坦爱国联盟与库尔德斯坦民主党。因此，囊括左翼与民主党派政治力量的库尔德斯坦临时政府已经建立。"
const TXT_372_711 := "中东的两处库尔德人聚居区——即伊拉克属库尔德斯坦与伊朗属库尔德斯坦，将被统一为单一的库尔德斯坦共和国。该国已经开始重建一个两院制的议会，而人民议会已经建立。在该国局势稳定以前（即2000年前），该国都将实行有限的多党制。到目前为止，只有已经存在的地区性政党才有资格参与议会选举：即位于伊朗的库尔德斯坦自由生活党、位于伊拉克的库尔德斯坦爱国联盟与库尔德斯坦民主党。因此，囊括左翼与民主党派政治力量的库尔德斯坦临时政府已经建立。"
const TXT_372_712 := "中东的两处库尔德人聚居区——即伊拉克属库尔德斯坦与叙利亚属库尔德斯坦，将被统一为单一的库尔德斯坦共和国。该国已经开始重建一个两院制的议会，而人民议会已经建立。在该国局势稳定以前（即2000年前），该国都将实行有限的多党制。到目前为止，只有已经存在的地区性政党才有资格参与议会选举：即位于叙利亚的民主联盟党和位于伊拉克的库尔德斯坦爱国联盟与库尔德斯坦民主党。因此，囊括左翼与民主党派政治力量的库尔德斯坦临时政府已经建立。"
const TXT_372_713 := "国家安全委员会与民族运动党的联合政府驱散了大规模抗议，得以保住政权。所以，尽管所有人都呼吁建立一个清算土耳其军政府罪行的法庭，但土耳其的原法西斯威权主义制度还是延续了下去。"
const TXT_372_714 := "伊拉克属库尔德斯坦将被改组库尔德斯坦共和国。该国已经开始重建一个两院制的议会，而人民议会已经建立。在该国局势稳定以前（即2000年前），该国都将实行有限的多党制。到目前为止，只有已经存在的地区性政党才有资格参与议会选举：即位于伊拉克的库尔德斯坦爱国联盟与库尔德斯坦民主党。因此，囊括左翼与民主党派政治力量的库尔德斯坦临时政府已经建立。"
const TXT_372_715 := "伊朗属库尔德斯坦将被改组库尔德斯坦共和国。该国已经开始重建一个两院制的议会，而人民议会已经建立。在该国局势稳定以前（即2000年前），该国都将实行有限的多党制。到目前为止，只有已经存在的地区性政党才有资格参与议会选举：即位于伊朗的库尔德斯坦自由生活党。因此，库尔德斯坦临时政府已经建立。"
const TXT_372_716 := "叙利亚属库尔德斯坦将被改组库尔德斯坦共和国。该国已经开始重建一个两院制的议会，而人民议会已经建立。在该国局势稳定以前（即2000年前），该国都将实行有限的多党制。到目前为止，只有已经存在的地区性政党才有资格参与议会选举：即位于叙利亚的民主联盟党。因此，库尔德斯坦临时政府已经建立。"
const TXT_372_717 := "协商完全失败——美国与苏联拒绝参与其中。也许下次，情况会更好一些......"
const TXT_372_718 := "我们将稍后再议......"
const TXT_372_719 := "在国际社会的压力下，由国家安全委员会与民族运动党组成的联合军政府不得不引咎下台。尽管得到了豁免权，但许多前政府成员因策划对库尔德人的种族灭绝而被捕定罪。在随后举行的选举中，自由派的正义党赢得选举，该国则由苏莱曼·德米雷尔领导。"
const TXT_372_720 := "合约通过了在伊拉克、伊朗与叙利亚三国境内建立库尔德民族自治区的方案。显然，由于中华人民共和国在上述国家对土耳其的战争中提供了援助，所以条款将由前者监督实行。"
const TXT_372_721 := "合约通过了在伊拉克与伊朗两国境内建立库尔德民族自治区方案。显然，由于中华人民共和国在上述国家对土耳其的战争中提供了援助，所以条款将由前者监督实行。"
const TXT_372_722 := "合约通过了在伊拉克与叙利亚两国境内建立库尔德民族自治区方案。显然，由于中华人民共和国在上述国家对土耳其的战争中提供了援助，所以条款将由前者监督实行。"
const TXT_372_723 := "合约通过了在伊朗与叙利亚两国境内建立库尔德民族自治区方案。显然，由于中华人民共和国在上述国家对土耳其的战争中提供了援助，所以条款将由前者监督实行。"
const TXT_372_724 := "合约通过了在伊拉克境内建立库尔德民族自治区的方案。显然，由于中华人民共和国在上述国家对土耳其的战争中提供了援助，所以条款将由前者监督实行。"
const TXT_372_725 := "合约通过了在伊朗境内建立库尔德民族自治区的方案。显然，由于中华人民共和国在上述国家对土耳其的战争中提供了援助，所以条款将由前者监督实行。"
const TXT_372_726 := "合约通过了在叙利亚境内建立库尔德民族自治区的方案。显然，由于中华人民共和国在上述国家对土耳其的战争中提供了援助，所以条款将由前者监督实行。"
const TXT_372_748 := "尽管直接受到土耳其进攻的恐怖威胁，但伊朗和伊拉克的边界冲突仍在继续。"
const TXT_372_702 := "近日爆发的军事冲突中"
const TXT_372_703 := "近日爆发的军事冲突中"
const TXT_372_704 := "近日爆发的两场军事冲突中"
const TXT_372_705 := "近日爆发的三场军事冲突中"


## 原作 Event372.cs：土耳其大国梦（手动事件，入口 DBS this_type==94）。
## 结果文案用英文摘要；数值/国家状态效果逐项对齐 ResultsOfEvents 的
## result 0 / result 1 / result 2（原版 result2 只写 data.turkish_pan_turkic_chain=1，Event372.cs:630）。


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	if event_def.event_id != "event_372":
		return
	var syria := p_ws.get_country_by_legacy_index(35)
	var iran := p_ws.get_country_by_legacy_index(8)
	var iraq := p_ws.get_country_by_legacy_index(14)
	var num := 0
	if syria != null and syria.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		num += 1
	if iran != null and iran.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		num += 1
	if iraq != null and iraq.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		num += 1
	var lead := TXT_372_702
	if num == 1:
		lead = TXT_372_703
	elif num == 2:
		lead = TXT_372_704
	elif num >= 3:
		lead = TXT_372_705
	event_def.description = TXT_372_699.replace("{1}", lead)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	_event_372(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_372(option_index: int, context: Dictionary) -> void:
	var syria := ws.get_country_by_legacy_index(35)
	var iraq := ws.get_country_by_legacy_index(14)
	var iran := ws.get_country_by_legacy_index(8)
	var flag := true
	var flag2 := true
	var flag3 := true
	var num := 0
	if syria != null and (syria.sub_government == GameConstants.SubGovernment.NEO_FASCIST or syria.has_tag("亲中")):
		flag = false
		num += 1
	if iran != null and (iran.sub_government == GameConstants.SubGovernment.NEO_FASCIST or iran.has_tag("亲中")):
		flag3 = false
		num += 1
	if iraq != null and (iraq.sub_government == GameConstants.SubGovernment.NEO_FASCIST or iraq.has_tag("亲中")):
		flag2 = false
		num += 1

	match option_index:
		0:
			_result_0(context, num, flag, flag2, flag3)
		1:
			_result_1(context, num, flag, flag2, flag3)
		_:
			# Event372.cs:630
			_set_data124(1)
			context["result_text"] = TXT_372_718




## Event372.cs:72-78/96-102/123-129 的 string.Format(new_events_text[706], ...) 拼接。
func _fmt372(main: String, second: String, third: String, fourth: String) -> String:
	return TXT_372_706.replace("{1}", main).replace("{2}", second).replace("{3}", third).replace("{4}", fourth)


func _t372_709(flag: bool) -> String:
	return TXT_372_709 if flag else ""


func _t372_748(flag: int) -> String:
	return TXT_372_748 if flag > 0 else ""


## Event372.cs:123-129 的 num3（708/719/713）选择。
func _t372_num3(num: int, turkey: CountryData) -> String:
	if num == 3 and turkey != null and not turkey.has_tag("nato"):
		return TXT_372_708
	if ws.influence_prc >= 800:
		return TXT_372_719
	return TXT_372_713


## Event372.cs:123-129 的 {2}：d126>0 且土耳其非北约 → 708，否则 713。
func _t372_708_or_713() -> String:
	var turkey := ws.get_country_by_legacy_index(84)
	if d.size() > 126 and d.turkish_straits_crisis > 0 and turkey != null and not turkey.has_tag("nato"):
		return TXT_372_708
	return TXT_372_713

func _result_0(context: Dictionary, num: int, flag: bool, flag2: bool, flag3: bool) -> void:
	_add_data143(-7)
	_set_data124(100)
	if d.size() > 128 and d.turkish_straits_state == 1:
		var iraq := ws.get_country_by_legacy_index(14)
		var iran := ws.get_country_by_legacy_index(8)
		if (iraq == null or (not iraq.has_tag("ovd") and not iraq.has_tag("okb"))) \
			and (iran == null or (not iran.has_tag("ovd") and not iran.has_tag("okb"))):
			if ws.wars.size() <= 3:
				ws.wars.resize(4)
			if ws.wars[3] != null:
				ws.wars[3].is_going = true

	var turkey := ws.get_country_by_legacy_index(84)
	if ws.influence_prc >= 800 and num == 3 and turkey != null \
		and not turkey.has_tag("亲美") and not turkey.has_tag("nato"):
		# Event372.cs:70-89
		_turkey_gov2_sub8()
		Achievements.set_achievement(136)  # 原作 Event372.cs:84 iron_and_blood → achievements.Set(136)
		ws.influence_prc += 100
		_set_data124(100)
		_set_part(turkey, 1)
		_turkish_client_sub3(95)
		_add_data143(3)
		_activate_kurdistan(MapService.KURDISTAN_SCOPE_FULL)
		context["result_text"] = _fmt372(TXT_372_707, TXT_372_708, _t372_709(false), _t372_748(0))
	elif ws.influence_prc >= 600 and num >= 3:
		# Event372.cs:93-113
		_turkey_gov2_sub8()
		ws.influence_prc += 70
		_set_part(ws.get_country_by_legacy_index(14), 1)
		_turkish_client_sub3(95)
		_add_data143(3)
		_activate_kurdistan(MapService.KURDISTAN_SCOPE_IRAQ_SYRIA_IRAN)
		context["result_text"] = _fmt372(TXT_372_710, TXT_372_708, _t372_709(true), _t372_748(0))
	elif ws.influence_prc >= 500 and num >= 2 and flag2:
		# Event372.cs:117-157
		ws.influence_prc += 50
		_set_data124(100)
		var iraq := ws.get_country_by_legacy_index(14)
		var kurd_scope := MapService.KURDISTAN_SCOPE_IRAQ_IRAN
		if flag2 and flag3:
			_set_part(iraq, 2)
			_turkish_client_sub3(95)
			_add_data143(3)
		else:
			kurd_scope = MapService.KURDISTAN_SCOPE_IRAQ_SYRIA
			_set_part(iraq, 3)
			_turkish_client_sub3(95)
		if d.size() > 126 and d.turkish_straits_crisis > 0 and turkey != null and not turkey.has_tag("nato"):
			_turkey_gov2_sub8()
		var second372 := _t372_708_or_713()
		var main372 := TXT_372_711 if (flag2 and flag3) else TXT_372_712
		_activate_kurdistan(kurd_scope)
		context["result_text"] = _fmt372(main372, second372, _t372_709(true), _t372_748(0))
	else:
		if ws.influence_prc < 400 or num < 1:
			# Event372.cs:159-165
			ws.influence_prc -= 100
			_set_data124(1)
			_add_data(W.I_PARTY_SUPPORT, -500)
			context["result_text"] = TXT_372_717
		else:
			# Event372.cs:168-281
			ws.influence_prc += 30
			_set_data124(100)
			if d.size() > 126 and d.turkish_straits_crisis > 0 and turkey != null and not turkey.has_tag("nato"):
				_turkey_gov2_sub8()
				_release_turkey_puppets()
			var main372b := TXT_372_714
			var kurd_scope := MapService.KURDISTAN_SCOPE_IRAQ
			if num >= 1 and num < 3:
				if d.size() > 126 and d.turkish_straits_crisis > 0 and turkey != null and not turkey.has_tag("nato"):
					_turkey_gov2_sub8()
					_release_turkey_puppets()
				if flag2:
					_set_part(ws.get_country_by_legacy_index(14), 0)
					_add_data143(3)
					main372b = TXT_372_714
				elif flag3:
					kurd_scope = MapService.KURDISTAN_SCOPE_IRAN
					_set_part(ws.get_country_by_legacy_index(8), 0)
					main372b = TXT_372_715
				else:
					kurd_scope = MapService.KURDISTAN_SCOPE_SYRIA
					_set_part(ws.get_country_by_legacy_index(35), 0)
					main372b = TXT_372_716
			elif num == 3:
				var r372 := randi() % 4
				if r372 == 1:
					kurd_scope = MapService.KURDISTAN_SCOPE_SYRIA
					_set_part(ws.get_country_by_legacy_index(35), 0)
					main372b = TXT_372_716
				elif r372 == 2:
					_set_part(ws.get_country_by_legacy_index(14), 0)
					_add_data143(3)
					main372b = TXT_372_714
				else:
					kurd_scope = MapService.KURDISTAN_SCOPE_IRAN
					_set_part(ws.get_country_by_legacy_index(8), 0)
					main372b = TXT_372_715
			_upgrade_turkish_puppets(flag, flag2, flag3)
			_activate_kurdistan(kurd_scope)
			var second372b := _t372_708_or_713()
			context["result_text"] = _fmt372(main372b, second372b, _t372_709(true), _t372_748(0))


func _result_1(context: Dictionary, num: int, flag: bool, flag2: bool, flag3: bool) -> void:
	_set_data124(100)
	_add_data143(-5)
	var turkey := ws.get_country_by_legacy_index(84)
	if num == 3 and turkey != null and not turkey.has_tag("nato"):
		# Event372.cs:289-294
		_turkey_gov2_sub8()
	elif ws.influence_prc >= 800:
		# Event372.cs:295-300
		if turkey != null:
			turkey.government = GameConstants.Government.LIBERAL
			turkey.sub_government = GameConstants.SubGovernment.MODERATE
	var num3_372 := _t372_num3(num, turkey)
	if ws.influence_prc >= 600 and num == 3:
		# Event372.cs:305-320
		_make_pro_china_copy(35)
		_make_pro_china_copy(8)
		_make_pro_china_copy(14)
		if d.size() > 128 and d.turkish_straits_state == 1:
			var iraq := ws.get_country_by_legacy_index(14)
			var iran := ws.get_country_by_legacy_index(8)
			if (iraq == null or not iraq.has_tag("亲中")) and (iran == null or not iran.has_tag("亲中")):
				d.turkish_straits_state = 2
				if ws.wars.size() <= 3:
					ws.wars.resize(4)
				if ws.wars[3] != null:
					ws.wars[3].is_going = true
		ws.influence_prc += 70
		context["result_text"] = _fmt372(TXT_372_720, num3_372, _t372_709(false), _t372_748(1))
	elif ws.influence_prc >= 500 and num >= 2:
		# Event372.cs:336-450
		ws.influence_prc += 50
		_make_pro_china_copy(14)
		_make_pro_china_copy(8)
		_make_pro_china_copy(35)
		if d.size() > 128 and d.turkish_straits_state == 1:
			var iraq := ws.get_country_by_legacy_index(14)
			var iran := ws.get_country_by_legacy_index(8)
			if (iraq == null or not iraq.has_tag("亲中")) and (iran == null or not iran.has_tag("亲中")):
				d.turkish_straits_state = 2
				if ws.wars.size() <= 3:
					ws.wars.resize(4)
				if ws.wars[3] != null:
					ws.wars[3].is_going = true
		_upgrade_turkish_puppets(flag, flag2, flag3)
		context["result_text"] = _fmt372(TXT_372_723, num3_372, _t372_709(false), _t372_748(1))
	else:
		if ws.influence_prc < 400 or num < 1:
			# Event372.cs:473-480
			ws.influence_prc -= 100
			_set_data124(1)
			_add_data(W.I_PARTY_SUPPORT, -500)
			context["result_text"] = TXT_372_717
		else:
			# Event372.cs:482-630
			ws.influence_prc += 30
			if num >= 1:
				_make_pro_china_copy(14)
				_make_pro_china_copy(8)
				if d.size() > 128 and d.turkish_straits_state == 1:
					var iraq := ws.get_country_by_legacy_index(14)
					var iran := ws.get_country_by_legacy_index(8)
					if (iraq == null or not iraq.has_tag("亲中")) and (iran == null or not iran.has_tag("亲中")):
						d.turkish_straits_state = 2
						if ws.wars.size() <= 3:
							ws.wars.resize(4)
						if ws.wars[3] != null:
							ws.wars[3].is_going = true
			_upgrade_turkish_puppets(flag, flag2, flag3)
			context["result_text"] = _fmt372(TXT_372_725, num3_372, _t372_709(false), _t372_748(1))


func _turkey_gov2_sub8() -> void:
	var turkey := ws.get_country_by_legacy_index(84)
	if turkey != null:
		turkey.government = GameConstants.Government.REFORMIST
		turkey.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE


func _turkish_client_sub3(legacy_idx: int) -> void:
	var c := ws.get_country_by_legacy_index(legacy_idx)
	if c != null:
		c.government = GameConstants.Government.REFORMIST
		c.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST


## 事件372 独立建国分支：激活“库尔德斯坦二号”(157)，使地图/外交能识别库尔德国家。
## scope_part 决定建国范围（0=最大边界，3/4/5/6/7/8=对应国家组合，9=土耳其战场）。
func _activate_kurdistan(scope_part: int = 0) -> void: # 0 = 最大边界
	var c := ws.get_country_by_legacy_index(157)
	if c == null:
		return
	# 先清掉旧的库尔德范围位，避免存档/重复触发时叠加出“超范围”领土。
	for idx in [0, 2, 3, 4, 5, 6, 7, 8, 9]:
		c.set_part(idx, false)
	c.set_part(scope_part, true)
	c.name = "库尔德斯坦共和国"
	c.chinese_name = "库尔德斯坦共和国"
	c.leave_alliances()
	c.government = GameConstants.Government.REFORMIST
	c.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
	c.puppet_of = GameConstants.LegacySlot.NONE
	if MapService.instance != null:
		MapService.instance.sync_map_merges()


func _set_part(c: CountryData, index: int) -> void:
	if c == null:
		return
	if c.parts.size() <= index:
		c.parts.resize(index + 1)
	c.parts[index] = true


func _release_turkey_puppets() -> void:
	for legacy_idx in [35, 8, 14]:
		var c := ws.get_country_by_legacy_index(legacy_idx)
		if c != null:
			c.puppet_of = GameConstants.LegacySlot.NONE


func _make_pro_china_copy(legacy_idx: int) -> void:
	var c := ws.get_country_by_legacy_index(legacy_idx)
	var china := ws.get_country_by_legacy_index(1)
	if c == null or china == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲美", false)
	c.set_tag("亲苏", false)
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	if china.has_tag("okb"):
		c.set_tag("okb", true)
	if china.has_tag("sev"):
		c.set_tag("sev", true)
	if china.has_tag("ovd"):
		c.set_tag("ovd", true)
	c.puppet_of = GameConstants.LegacySlot.NONE
	c.government = china.government
	c.sub_government = china.sub_government


func _upgrade_turkish_puppets(flag: bool, flag2: bool, flag3: bool) -> void:
	var turkey := ws.get_country_by_legacy_index(84)
	if turkey == null or turkey.government != GameConstants.Government.REFORMIST:
		return
	if flag2:
		var iraq := ws.get_country_by_legacy_index(14)
		if iraq != null and iraq.puppet_of == 84:
			iraq.government = GameConstants.Government.REFORMIST
			iraq.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
	if flag:
		var syria := ws.get_country_by_legacy_index(35)
		if syria != null and syria.puppet_of == 84:
			syria.government = GameConstants.Government.REFORMIST
			syria.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
	if flag3:
		var iran := ws.get_country_by_legacy_index(8)
		if iran != null and iran.puppet_of == 84:
			iran.government = GameConstants.Government.REFORMIST
			iran.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE


func _set_data124(v: int) -> void:
	if d.size() > 124:
		d.turkish_pan_turkic_chain = v


func _add_data143(delta: int) -> void:
	if d.size() > 143:
		d.oil_price += delta


func _add_data(index: int, delta: int) -> void:
	if index >= 0 and index < d.size():
		d.add_data_by_index(index, delta)


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		d.usa_relations = ws.empires[EmpireData.USA].relations
		d.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		d.ussr_relations = ws.empires[EmpireData.USSR].relations
		d.soviet_influence = ws.empires[EmpireData.USSR].power
