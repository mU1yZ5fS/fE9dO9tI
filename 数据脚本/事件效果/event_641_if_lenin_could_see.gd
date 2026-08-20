extends "res://数据脚本/event_script_base.gd"

## 原作 Event641.cs：若列宁可见今日（苏联改革危机，三选项）。
## 触发：ReqEventsDLC02.cs:1076 —— 复合条件（ev640、苏联 now_leader==7、资源/科技/parts/三盟国），
##   无单一 ExprNode → trigger_script evaluate。
## 差异：science[26]/[22]→techs.unlocked；data[130] 无命名常量，按原版 raw index 读写；
##   proprc/okb→亲中/okb 标签；ingamewars[70] 建模说明 WarDef → 兜底创建后补名。

const TXT_DESC := "同志，我们似乎获得了削弱那该死的安德罗波夫-卡特协定的良机：由于苏联向西看齐的政策完全是权宜之计，内部自有许多不足之处。雅科夫列夫的改革与对苏共内部的果断清洗只会让问题进一步激化：保守派的离任导致许多官僚机构内青黄不接，对民族地区的洗牌也自然导致了本地利益集团的抗议，而向市场社会主义转型的尝试则开始持续破坏计划经济框架，并为西方投资、多种合营管理与地下交易形式开了绿灯：苏联业已成为匈牙利模式的大型试验田。其欧洲部分也正因近水楼台，接受主要西方国家支持而通过经济特区与自贸区形式快速崛起；但其疏远发达地带，且同时作为冷战前线的中亚与远东则是另一派光景：自筹资金改革与放权政策只会让当地直面破产风险与经济萧条，并不得不仰仗更加竭泽而渔的开发政策——这便是苏联亚洲部分内人口流动频繁，边界管控松懈，且大量苏联侨民开始越过苏联边界口岸逃往我国的原因。我们当然可利用这一状况，一雪伊塔事件之耻，一面用弃暗投明的前苏联公民充实我边疆建设事业，一面则向全世界展示苏联改革政策的失败。不过，我们也可以更进一步——考虑到苏联边界防御事实上趋于松懈，为何不试着对列宁时代的“否认中俄间一切不平等条约”故事重提，并以“保护”我国在苏联侨胞为由，直接让曾被沙俄侵占的外东北和外西北地区回归我中华民族大家庭呢？"
const TXT_OPT0_DIS := "我们可没本钱安置这么多人"
const TXT_OPT1_DIS := "我们真做好了同有核国家开战的打算？"
const TXT_R0 := "依托位于阿拉木图、伏龙芝与杜尚别的使馆和代办处，我们很快便向西亚地区分发了大量的中国“侨胞证”与有关中苏社会与生活对比的发放材料，并揭露了苏联政府肆意抓捕少数民族成员用以做秘密实验；以当地民族协会，中苏友好协会和文化协会等组织为掩护输送线人，在中亚的少数民族内做有利于我方的工作。位于伊犁与哈尔滨的广播电台都已全力开动，以俄语，哈萨克语，吉尔吉斯语等多语言形式对中亚与远东地区的苏联人民“晓之以情，动之以理”：并将雅科夫列夫描绘为“大俄罗斯沙文主义者”，“冷战时代的斯托雷平”，“试图以民主与经济改革为旗摧毁当地传统生活方式”。很快，我们的工作便取得了成效：中苏西北与东北边界乱作一团，部分地区的地方政府在混乱内遗失了机密文件与政府公章，海参崴政府大楼更是被高举“回黑龙江去”横幅的队伍给焚为废墟。而边界的人民解放军部队则为起义者们提供了方便：借着混乱局势，我们动用了相当人力为中华民族带回了新一批同胞，并在苏联安插了又一批线人，相关事宜在国内被视为同土尔扈特部东归般的大事。狠狠地给全国人民出了口恶气：当然，这只会让苏联人不满。以雅科夫列夫为首的苏共领导核心对东方表示“极度愤慨”，并怒斥我国事实上奉行“社会帝国主义政策”。"
const TXT_R1_PRE := "依托位于阿拉木图、伏龙芝与杜尚别的使馆，我们很快便向西亚地区分发了大量的中国“侨胞证”与有关中苏社会与生活对比的发放材料，并以当地民族协会、文化协会等组织为掩护输送线人，在中亚的少数民族内做有利于我方的工作。位于伊犁与哈尔滨的广播电台都已全力开动，以俄语，哈萨克语，吉尔吉斯语等多语言形式对中亚与远东地区的苏联人民“晓之以情，动之以理”：并将雅科夫列夫描绘为“大俄罗斯沙文主义者”，“冷战时代的斯托雷平”，“试图以民主与经济改革为旗摧毁当地传统生活方式”。很快，我们的工作便取得了成效：中苏西北与东北边界乱作一团，部分地区的地方政府在混战内遗失了机密文件与政府公章，海参崴政府大楼更是被高举“回黑龙江去”横幅的队伍给焚为废墟。而边界的人民解放军部队则为起义者们提供了方便：借着混乱局势，我们成功将一名中国边防士兵伪造死亡，并由此彻底引爆了国内爱国主义情绪。"
const TXT_R1_POST := "同志就此顺藤摸瓜，以绝对优势批准了对苏特别军事行动“击毁T62”计划：预计将在短时间内基本捣毁苏联亚洲防线，以原清代版图为原型建立外东北、外西北安全区并彻底终结沙俄时代签署的不平等条约：新疆地区的解放军部队将同伊朗与阿富汗的同志一道压制苏联中亚军区，远东地区的中日联合舰队则将在击溃苏联远东边防的同时策应海军陆战队对远东军区进行去军事化，与此同时，我们还将调动蒙古地区的武装力量直取贝加尔湖地区的重镇伊尔库茨克并筹备武装布里亚特蒙古人，旨在以最快速度终结苏方抵抗。中国龙的复仇就此开始……"
const TXT_R2 := "无事发生，除却时不时出现的中亚人口外流问题外，苏联的红色资本主义发展照常：不久后，雅科夫列夫的办公室洗牌也跟着来到了这些地区，改革春风就此不可阻挡……"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	event_def.description = _leader_name() + TXT_DESC
	if event_def.options.size() < 3:
		return
	var opt := event_def.options
	if _res(W.I_BUDGET) + _res(W.I_RESERVE) >= 100 and _res(W.I_LIVING) >= 800:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if _res(W.I_ARMY) >= 2000 and _res(W.I_AGENTS) >= 750 and _res(W.I_WAR_SUPPORT) >= 700 \
			and _res(W.I_MANPOWER) >= 700 and _res(W.I_DIPLO) >= 1000 \
			and _tech(26) and _tech(22) and d.size() > 130 and d[130] == 1 \
			and _part(1, 0) and not _part(1, 9) and not _part(1, 7) and not _part(1, 8) \
			and _pro_okb(8) and _pro_okb(12) and _pro_okb(44):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, -100)
			_add(W.I_DIPLO, 10)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			_add(W.I_POPULATION, 2)
			_add_relation(EmpireData.USSR, -200)
			_add_power(EmpireData.USSR, -15)
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, -15)
			ws.influence_prc += 15
		1:
			context["result_text"] = TXT_R1_PRE + _leader_name() + TXT_R1_POST
			# 原版 ingamewars[70]：雪耻之战，中国(500) vs 苏联(500)，AmericanSupportDefender、SovietSupportDefender
			GameManager.start_war(70, "中华人民共和国", "苏联", 500, 500, 2, 2)
			if ws.wars.size() > 70 and ws.wars[70] != null:
				ws.wars[70].name_war = "雪耻之战"
			_add(W.I_PARTY_SUPPORT, 300)
			_add(W.I_PEOPLE_SUPPORT, 300)
			_add(W.I_THOUGHT_FREEDOM, -200)
			_set_data(W.I_DIPLO, 1100)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -750)
			_add(W.I_ARMY, -2000)
			_add(W.I_POPULATION, 2)
			_add_relation(EmpireData.USSR, -500)
			_add_power(EmpireData.USSR, -15)
			_add_relation(EmpireData.USA, -500)
			_add_power(EmpireData.USA, -15)
			ws.influence_prc += 15
		2:
			context["result_text"] = TXT_R2


func evaluate(world: WorldState) -> bool:
	if world == null or not world.completed_event_ids.has("event_640"):
		return false
	if world.empires.size() <= EmpireData.USSR or world.empires[EmpireData.USSR] == null \
			or world.empires[EmpireData.USSR].current_leader != 7:
		return false
	var dd := world.数值表
	if dd.size() <= W.I_MANPOWER or dd.size() <= 130:
		return false
	if dd[W.I_WAR_SUPPORT] < 700 or dd[W.I_MANPOWER] < 700 or dd[W.I_DIPLO] < 1000:
		return false
	if not _tech_on(world, 26) or not _tech_on(world, 22):
		return false
	if dd[130] != 1:
		return false
	if not _part_on(world, 1, 0) or _part_on(world, 1, 9) or _part_on(world, 1, 7) or _part_on(world, 1, 8):
		return false
	return _pro_okb_on(world, 8) and _pro_okb_on(world, 12) and _pro_okb_on(world, 44)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _tech(idx: int) -> bool:
	return ws.techs != null and idx >= 0 and idx < ws.techs.unlocked.size() and ws.techs.unlocked[idx]


func _tech_on(world: WorldState, idx: int) -> bool:
	return world.techs != null and idx >= 0 and idx < world.techs.unlocked.size() and world.techs.unlocked[idx]


func _part(idx: int, part: int) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.parts.size() > part and c.parts[part]


func _part_on(world: WorldState, idx: int, part: int) -> bool:
	var c := world.get_country_by_legacy_index(idx)
	return c != null and c.parts.size() > part and c.parts[part]


func _pro_okb(idx: int) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag("亲中") and c.has_tag("okb")


func _pro_okb_on(world: WorldState, idx: int) -> bool:
	var c := world.get_country_by_legacy_index(idx)
	return c != null and c.has_tag("亲中") and c.has_tag("okb")
