extends "res://数据脚本/event_script_base.gd"

## 原作 Event556.cs：“火热之秋”的重临（意大利内战，1选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1219-1221 —— 复杂条件见 evaluate()。
## 差异：ingamewars[23] → GameManager.start_war；inflNATO→usa_influence；
##   YugAgree→ws.get_flag("YugAgree")；spec→special；IsSocialism→is_socialism。

const TXT_R0_WORKER := "正如风云激荡的20世纪60年代那般，工人主义的旗帜再度成为意大利极左翼活动家们的首选：借助“火热之秋”时期打出的声望与70年代的苦心经营，以及意大利成气候的极左翼社会运动事实上皆汇入主张自治、反科层与反国家的“工人主义”系组织的社会基础。这一政治倾向自然而然地成为了意大利极左翼运动的主流。而意大利共产党在推进社会主义议程层面的惨痛失败，将自身降格为现代社会民主党与该党在起义期间成为资产阶级国家傀儡的事实更给“正统派社会主义者”们以致命一击，导致激进主义者们直接涌入推崇工人自发性，试图采取新组织形式策动革命的新平台。于是，继承“持续斗争”、“工人自主”等团体衣钵的新兴组织工人联盟“自主”得以借各地自管社会中心的拥护迅速取得左翼阵营内部领导权，并同时将回归“政治路线为主，武装斗争为辅”观点的“前线”、共产主义战斗队与争取共产主义的武装无产者等一系列亲工人主义武装组织收入麾下。其对外发言人安东尼奥·奈格里已以博洛尼亚苏维埃为中心宣布成立意大利苏维埃联邦，表示将彻底纠正“斯大林-陶里亚蒂主义路线”下压制工人自主，事实上将共产主义降为党政官僚下政治附庸的公式与历史错误；并以“列宁、法农与毛泽东”，“十月起义同文化大革命”的名义开启意大利无产者作为自为阶级的全新征程。"
const TXT_R0_ORTHO := "自采纳自发性原则，并争取在扬弃传统政党框架基础上重建革命主体的“工人主义”系组织因政治内耗与外部打压而不可避免地走向衰退后，重建极左翼阵营领导权的重任便被交予了“传统手段”的信奉者，即早已同意大利共产党、意大利社会党等“工人的代表”分道扬镳的强硬派社会主义者们：他们对于新左翼政治议题与群众运动开门态度，以及同“工人主义”系组织发展的广泛合作关系足以使自身在摒弃建制派政党改良习气的同时，为筹备的大众化革命组织赋予其应具有的革命色彩。借助数场针对建制派的反围剿并主导多处“红色据点”的整合，以“宣言派”成员为主体的意大利重建共产党成功整合了支离破碎的“工人主义”系组织，并在取得多数自管社会中心的领导权后从废墟中崛起，在米兰宣布了意大利苏维埃共和国的正式建立。各地城市游击队与松散的工人运动亦开始在“赤卫队”与“基层工会联盟”旗下挂靠重建共产党领导，积极推进对建制派的政治替代。其领导人卢西奥·马格里更在首届代表大会上展示其政治议程：“摒弃考茨基，回到葛兰西；在全新的红两年中建立名副其实的共产党与苏维埃共和国。”"
const TXT_R0_MAO := "由于采纳自发性原则，并争取在扬弃传统政党框架基础上重建革命主体的“工人主义”系组织早因政治内耗与外部打压而不可避免地走向衰退与碎片化，而同意大利共产党、意大利社会党等国内“工人代表”分道扬镳的强硬派社会主义-变节者群体亦未能抓住局势实现整合。在意大利建立左翼领导权的重任自然被委以了新时代“共产国际”之手：中国社会主义者的决定性支持得以使其老友意大利共产党（马列）在这混战局势中迅速扩充组织，发展武装并建设根据地，逐步成为左翼起义者内的领头羊。而建制派试图根除一切反对派而草率引入的紧急状态更使其成为国内活动家眼中的众矢之的，至此让意大利共产党（马列）取得同其他左翼活动家进一步合流的良机，并促成了参照反法西斯起义时代“民族解放委员会”与三三制民主原则（即囊括意大利共产党（马列）代表、其他共产主义组织成员与以工人主义者为主体的激进左翼活动家合议）的统一战线组织人民解放委员会成立。各派游击队宣称将在保持独立性的基础上遵循毛主义政治公式，坚决走在“人民战争，政治革命与文化大革命”三面红旗下创立意大利社会主义共和国的光辉道路。"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var c85 := world.get_country_by_legacy_index(85)
	if c85 == null:
		return false
	if c85.level_of_development >= 20:
		return false
	var dd := world
	if dd.size() <= 134:
		return false
	if dd.italian_radical_left_power < 200:
		return false
	if c85.influence_china > 0:
		return false
	return c85.内战中


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c1 := ws.get_country_by_legacy_index(1)
	var c20 := ws.get_country_by_legacy_index(20)
	var c85 := ws.get_country_by_legacy_index(85)
	var c87 := ws.get_country_by_legacy_index(87)
	if d.press_policy > 17:
		d.italy_power_172 += 1
	if not ws.modifiers[3].is_active:
		d.italy_power_172 -= 1
		d.italy_power_174 -= 999
	if d.mao_history_line == 0 and ws.completed_event_ids.has("event_74"):
		d.italy_power_174 -= 1
	elif d.mao_history_line != 0:
		d.italy_power_174 -= 999
	if ws.modifiers[28].is_active:
		d.italy_power_172 += 1
		d.italy_power_174 += 1
	if c85 != null and c85.usa_influence > 0:
		d.italy_power_173 += 2
	if c87 != null and c87.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST:
		d.italy_power_173 += 1
	elif c87 != null and c87.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
		d.italy_power_172 += 1
	if ws.modifiers[43].is_active:
		d.italy_power_172 += 1
	if ws.modifiers[44].is_active and ws.get_flag("YugAgree"):
		d.italy_power_173 += 1
	elif ws.modifiers[44].is_active:
		d.italy_power_172 -= 2
		d.italy_power_173 -= 1
	if ws.modifiers[49].is_active:
		d.italy_power_173 += 2
	if c1 != null and c1.has_tag("rim") and ws.modifiers[3].is_active and ws.modifiers[6].is_active 			and ws.is_socialism(c1, true):
		d.italy_power_174 += 2
	if ws.completed_event_ids.has("event_500"):
		d.italy_power_174 += 2
	if c20 != null and c20.has_tag("亲中"):
		d.italy_power_174 += 1
	if c20 != null and c20.special == 1:
		d.italy_power_174 += 1
	if ws.influence_prc > 800:
		d.italy_power_174 += 1
	var num := 0
	for idx in [21, 86, 87, 17, 92]:
		var cc := ws.get_country_by_legacy_index(idx)
		if cc != null and cc.has_tag("eu"):
			num += 20
	for idx in [21, 86, 87, 17, 92]:
		var cc := ws.get_country_by_legacy_index(idx)
		if cc != null and cc.has_tag("nato"):
			num += 100
	for idx in [92, 17, 87, 86, 21]:
		var cc := ws.get_country_by_legacy_index(idx)
		if cc != null and ws.is_socialism(cc, true):
			num -= 50
	num -= (d.italian_radical_left_power - 200) * 5
	if c87 != null:
		c87.special -= 15
	var ussr_side := -1
	if c1 == null or not c1.has_tag("sev"):
		ussr_side = GameConstants.WarSide.SIDE2
	if d.italy_power_172 >= d.italy_power_173 and d.italy_power_172 >= d.italy_power_174:
		d.italy_hot_autumn_route = 1
		_add_power(EmpireData.USA, -10)
		_start_war23(num, ussr_side)
		context["result_text"] = TXT_R0_WORKER
	elif d.italy_power_173 >= d.italy_power_172 and d.italy_power_173 >= d.italy_power_174:
		d.italy_hot_autumn_route = 2
		_add_power(EmpireData.USA, -10)
		_start_war23(num, ussr_side)
		context["result_text"] = TXT_R0_ORTHO
	else:
		d.italy_hot_autumn_route = 3
		_add_power(EmpireData.USA, -10)
		_start_war23(num, ussr_side)
		context["result_text"] = TXT_R0_MAO


func _start_war23(num: int, ussr_side: int) -> void:
	GameManager.start_war(23, "左翼激进派", "民族团结政府", 300 - num, 700 + num, 1, ussr_side)
	if ws.wars.size() > 23 and ws.wars[23] != null:
		ws.wars[23].name_war = "意大利内战"
		ws.wars[23].fortnight_max = 30
