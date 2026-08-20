extends "res://数据脚本/event_script_base.gd"

## 原作 Event551.cs：过河拆桥？（蒙古问题，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:57-59 —— 复杂条件见 evaluate()。
## 差异：ILoveSuckCocks→_china_parts_change()；SOV_PRC_PartiesConnection→I_COMMUNICATIONS。

const TXT_OPT0_DIS := "我们怎么能让煮熟的鸭子飞了？！"
const TXT_OPT1_DIS := "蒙古特别行政区？这就是给苏联人渗透开方便之门！"
const TXT_OPT2_DIS := "我们绝不能使用包办代替的做法！"
const TXT_R0 := "今天，中国与蒙古领导人共同终止了所谓《中蒙联合条约》，从而结束了短暂的中蒙联合时期：此后，蒙古将以独立主权国家的形式与中国建立外交关系与开展合作——可考虑到蒙古本身的缓冲区性质，这种合作的规模注定有限。党与人民对此感到疑惑与愤怒，毕竟，无数为合并计划准备的人力物力都白花了，竹篮打水一场空。有反对派已将现任领导层的行径同宋真宗与宋高宗相比——前者曾在对敌优势时签署了辱国不平等条约，后者则更是在割地赔款后选择对北方政权称臣......苏联则为自己对华扩张窗口的再度开放感到满意。"
const TXT_R1 := "中国领导人称，《中蒙联合条约》的法律效力高于新推行的《区域自治法》，并基于前者撰写了独立并行的法律文本《蒙古特别行政区基本法》。事实上在国内推行了混合式的区域管理制度：即对中国本部地区实行单一制，对蒙古区域则允许其自建民族联邦，实行“更高级民族自治形式”。当然，这不过是某种拆东墙补西墙：蒙古人确实对我们的慷慨表示满意，并决心以千万倍的努力回报我们的工作。但是仅在人口规模有限的蒙古实施特殊政策必然将导致其他民族区域，乃至中国内地本身的反弹与不满。有人甚至已经发明了“七万万小于两千万”的口号，愤怒地要求我们要么取消对蒙古的单独优待政策，要么则将蒙古模式在全国推广，实现全国区域间的完全平等。"
const TXT_R2 := "人力资源部与国家安全局开始履行其既有职责——收买能收买的，分化能分化的，排挤能排挤的。通过灵活运用经济与信息手段，乃至安插来自内蒙古地区的党员。我们的情报机构成功分化了原蒙古党政体系，将主张同中国实现深度一体化合作关系的亲华派转为了蒙古人民革命党主流，并通过一系列经济扶持政策稳定了民间民心。改组后的蒙古领导层没多久便自愿要求修订《中蒙联合条约》，并事实上承认了民族区域自治政策。随后举行的全蒙公投则以97.2%的高票批准了修改——我们在内蒙古的长期经营发挥了大功，他们依靠自身的体量与国家支持跨界放牧的政策进入外蒙古，并成为了我党线人。随后，我国正式启动了在外蒙古引入民族区域自治制度的历史进程。当然，如此剧烈的变化必然多少会导致人心浮动。超级大国则已开始就表决环节流程的合理性问题添油加醋，竭力否认《中蒙新联合条约》内的合法性：其试图将蒙古从我国境内萃取出的贼心不死......"
const TXT_R3 := "最终，有引入我国民族区域自治制度与地方管理制度的提案被全国人大所否决。相关的修宪计划也胎死腹中——人民对我们一贯坚持民族自决原则的革新态度表示满意。中国仍走在巩固与深化分权体系的路上，走着瞧罢......"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var dd := world.数值表
	if dd.size() <= W.I_TERRITORY:
		return false
	var c9 := world.get_country_by_legacy_index(9)
	return dd[130] == 1 and world.decisions.completed[19] and dd[W.I_TERRITORY] == 20 			and c9 != null and c9.puppet_of < 0


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var line := d[W.I_POLITICAL_LINE]
	if line == 4:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line > 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line < 4:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c1 := ws.get_country_by_legacy_index(1)
	var c9 := ws.get_country_by_legacy_index(9)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_set_data(130, 0)  # 原 data[130]
			_china_parts_change(c1)
			if c9 != null:
				c9.government = GameConstants.Government.SOCIALIST
				c9.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c9)
				c9.set_tag("亲中", true)
				_join_alliances(c9)
			_add(W.I_POPULATION, -20)
			_add(W.I_BUDGET, 50)
			_add(W.I_INDUSTRY, 10)
			_add(W.I_AGRICULTURE, 10)
			_add(W.I_SERVICES, 10)
			_add(W.I_PARTY_SUPPORT, -150)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_THOUGHT_FREEDOM, 150)
			ws.influence_prc -= 20
			_add_relation(EmpireData.USSR, 500)
			_add_power(EmpireData.USSR, 100)
			_add(W.I_DIPLO, -100)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -80)
			_add(W.I_INDUSTRY, -50)
			_add(W.I_AGRICULTURE, -50)
			_add(W.I_SERVICES, -50)
			_add(W.I_CORRUPTION, 20)
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, -150)
			_add(W.I_THOUGHT_FREEDOM, 250)
			ws.influence_prc -= 5
			_add_relation(EmpireData.USSR, 500)
			_add(W.I_DIPLO, -100)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -80)
			_add(W.I_CORRUPTION, 20)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, -20)
			_add(W.I_THOUGHT_FREEDOM, 100)
			ws.influence_prc -= 5
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -200)
			_add(W.I_DIPLO, 50)
			context["result_text"] = TXT_R2
		3:
			_set_data(W.I_TERRITORY, 21)
			_add(W.I_PARTY_SUPPORT, 20)
			_add(W.I_PEOPLE_SUPPORT, 20)
			_add(W.I_THOUGHT_FREEDOM, 100)
			ws.influence_prc -= 5
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_DIPLO, -20)
			context["result_text"] = TXT_R3


func _china_parts_change(c1: CountryData) -> void:
	if c1 == null:
		return
	if c1.parts.size() < 16:
		c1.parts.resize(16)
	var c19 := ws.get_country_by_legacy_index(19)
	var c33 := ws.get_country_by_legacy_index(33)
	var is_gk := ws.get_flag("is_gkchp")
	if ws.get_flag("IndOpp"):
		_clear_parts(c1)
		c1.parts[15] = true
	elif c19 != null and c33 != null and c19.puppet_of == 1 and c19.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST 			and c33.puppet_of == 1 and c33.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_clear_parts(c1)
		c1.parts[14] = true
	elif c33 != null and c33.puppet_of == 1 and c33.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_clear_parts(c1)
		c1.parts[13] = true
	elif c19 != null and c19.puppet_of == 1 and c19.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_clear_parts(c1)
		c1.parts[12] = true
	elif is_gk:
		_clear_parts(c1)
		c1.parts[11] = true
	elif d[130] == 1 and d[W.I_ARUNACHAL_STATUS] >= 2 and (d[W.I_TAIWAN_STATUS] == 2 or ws.decisions.completed[7]):
		_clear_parts_range(c1)
		c1.parts[0] = true
	elif d[130] == 1 and (d[W.I_ARUNACHAL_STATUS] == 2 or d[W.I_ARUNACHAL_STATUS] == 3):
		_clear_parts_range(c1)
		c1.parts[2] = true
	elif d[W.I_ARUNACHAL_STATUS] >= 2 and (d[W.I_TAIWAN_STATUS] == 2 or ws.decisions.completed[7]):
		_clear_parts_range(c1)
		c1.parts[6] = true


func _clear_parts(c1: CountryData) -> void:
	for i in c1.parts.size():
		c1.parts[i] = false


func _clear_parts_range(c1: CountryData) -> void:
	for i in 12:
		if i < 7 or i > 9:
			if i < c1.parts.size():
				c1.parts[i] = false
