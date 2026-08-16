extends "res://数据脚本/event_script_base.gd"

## 原作 Event671.cs：朋友来了有美酒（中欧823计划，四选项）。
## 触发：DiploButtonScript.cs:12361 —— 外交按钮 1063，手动触发。
## 差异：prcinfl→prc_influence；science[12]→techs.unlocked[12]；选项3 event_done[671]=false→skip_mark_done。

const TXT_TITLE := "朋友来了有美酒"
const TXT_DESC := "主席同志，好消息！随着我们的经济联盟进一步扩张，欧洲阶级兄弟们愿意同我们在多个部门展开联合合作。目前本项项目暂且定名为“823计划”，其中的一些分支如下。法国同志愿意在核电技术等方面同我国展开密切合作。如您所知晓的那样，法国拥有全欧洲最为先进的核电站技术，和他们的合作能进一步推动我国对外国资源的依赖，并能为我们国家的城市居民提供便宜高效的电能。而德国同志主动提出帮助我国军工产业进一步现代化，前些日子被公有化的戴姆勒奔驰公司过去是该国最大的军事工程复合体，和德国展开合作将能进一步现代化我国的军事产业。或者，我们可以进一步扩大我们和欧洲国家的经济往来。这样将有利于我国的经济发展，更多的财政盈余也有利于我们的投资。"
const TXT_OPT0 := "和法国同志展开合作"
const TXT_OPT0_DIS_DONE := "我们已经和法国合作"
const TXT_OPT0_DIS_NO := "我们的工业还不支持更深的合作！"
const TXT_OPT1 := "和德国同志展开合作"
const TXT_OPT1_DIS_DONE := "我们已和德国合作"
const TXT_OPT1_DIS_NO := "德国尚未统一……"
const TXT_OPT2 := "扩大我们和欧洲国家的贸易额"
const TXT_OPT2_DIS := "我们已经扩大了合作"
const TXT_OPT3 := "暂时什么都不做"
const TXT_R0_FMT := "中国政府决定签署《核能合作与电子产业协同发展框架协议》，宣布共同启动新一代核电站建设项目，并加强在电子信息技术领域的深度合作。{0}{1}同志在广州白云会所亲切接见了法国领导人和随行代表，双方就工业合作达成了一揽子协议，其中还包括了在秦山和大亚湾建设两组欧洲标准的核电站。项目将聚焦安全性提升、核废料处理及智能化运维，打造全球核电技术合作标杆。中国国家能源局负责人表示，法国在核能领域的技术的陷阱经验将加速实现“双碳”目标，为全球提供稳，低碳的能源解决方案。这还会为我国提供更多的就业岗位以及更为便宜的电力。\n合作不仅限于能源领域。中国科技大学和法国巴黎高等师范学院以民间团体的身份决定建立“中法数字创新实验室”，在半导体材料，自动化工业及新一代芯片等关键领域展开联合攻关。法国驻华大使指出：“中国电子产业的蓬勃生态与法国在高端制造，基础研究上的优势深度融合，将重塑这一产业的国际格局。而新型的跨国合作更能彰显友好国家间的友谊，进一步促进马克思先生理想中没有国界的世界”。\n这将会带来丰厚的回报，我们只消等待……"
const TXT_R1_FMT := "近日，中国与德国新一任领导层正式签署《军事工业技术合作与联合研发框架协议》，双方宣布在装备现代化，技术创新及人员培训等领域展开全方位协作。{0}{1}同志在广州白云会所亲切接见了德国领导人和随行代表，双方就工业合作达成了一揽子协议。这一合作标志着两国在推动防御性国防能力建设方面迈出重要步伐，彰显了社会主义国家间互信互助的深厚情谊。\n根据协议，中德将聚焦陆军主战装备升级和防空系统智能化，共同开发新一代机械化部队及模块化防空导弹平台。德方在机械精密制造，装甲材料工艺上的优势能弥补，打造适应现代防御需求的“高性价比”装备体系。军事委员会代表表示，此次合作遵循“非攻性，非排他”原则，旨在通过技术互通提升两国自主防卫能力，为全球安全治理提供新范式。德国的步兵战车，单兵防空系统和野战防空车也将填补我国在此处的空白。进一步构建现代化的军事体系，争取赶上超级大国做准备。\n合作不仅限于装备制造，双方将共建“中德军事技术联合学院”，围绕未来的电子对抗系统，无人作战平台，电子化指挥与战术分析系统等前沿领域开展联合攻关，并互派技术骨干参与研发项目。德国国防工业部负责人指出：“中国在国防科技产业化方面的经验，为提升装备实战效能提供了宝贵借鉴。”从实验室到生产线，中德军事工业合作始终秉持“平等协商、共同进步”理念。这一合作理念正是反对美帝国主义和苏联社会帝国主义集团鼓动世界大战的生动实践。正如{0}{1}同志在招待酒会上的发言那样：“中国历来不希望战争，正因如此，我们将以技术合作消弭隔阂，以共同发展取代零和博弈，为构建均衡，有效，可持续的国际安全架构注入正能量。中德两国正以务实行动诠释“止戈为武”的东方智慧，为世界和平与发展贡献社会主义国家的战略担当。”\n中德友谊万岁！没有常备军的世界万岁！"
const TXT_R2_FMT := "我们决定进一步扩大我国和欧洲国家的跨国贸易，这将会为我们带来额外的外汇收入，并在一定程度上补齐我国内部的不足。近日，中国与德国，法国，意大利等欧洲主要国家联合发布《深化经济合作联合声明》，根据声明，中方将扩大精密机床，光刻机等高附加值产品对欧出口，同时新增15类欧洲优质农产品、医疗器械和精密仪器进口零关税清单。英国贸易代表表示：“中国与欧洲技术产业的互补性，正转化为实实在在的增长动能。这真的让小伙子们都提起干劲了，我们的工厂又一次充满了订单。”\n正如{0}{1}同志在招待酒会所言：“中欧不仅仅是意识形态盟友，也是发展伙伴。扩大贸易非但不会稀释彼此特色，反而能以差异化竞争锻造更高水平合作。”从亚得里亚海畔的风机到上海的高精度机床，中欧正以行动证明：开放包容的经贸纽带，最终会为一个没有剥削的共同发展的世界开辟新航向。"
const TXT_R3 := "又是平静的一天。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var france := ws.get_country_by_legacy_index(21)
	var west_germany := ws.get_country_by_legacy_index(16)
	var east_germany := ws.get_country_by_legacy_index(17)
	var luxemburg := ws.get_country_by_legacy_index(0)
	if _tech(12) and _res(W.I_INDUSTRY) >= 800 and france != null and france.prc_influence == 0:
		_enable(opt[0], TXT_OPT0)
	elif france != null and france.prc_influence != 0:
		_disable(opt[0], TXT_OPT0_DIS_DONE)
	else:
		_disable(opt[0], TXT_OPT0_DIS_NO)
	var germany_unified := (west_germany != null and west_germany.parts.size() > 0 and west_germany.parts[0]) \
		or (east_germany != null and east_germany.parts.size() > 0 and east_germany.parts[0])
	if germany_unified and west_germany != null and west_germany.prc_influence == 0:
		_enable(opt[1], TXT_OPT1)
	elif west_germany != null and west_germany.prc_influence != 0:
		_disable(opt[1], TXT_OPT1_DIS_DONE)
	else:
		_disable(opt[1], TXT_OPT1_DIS_NO)
	if luxemburg == null or luxemburg.prc_influence == 0:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var france := ws.get_country_by_legacy_index(21)
	var west_germany := ws.get_country_by_legacy_index(16)
	var luxemburg := ws.get_country_by_legacy_index(0)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = _fmt(TXT_R0_FMT)
			_add(W.I_BUDGET, -150)
			if france != null:
				france.prc_influence = 1
		1:
			context["result_text"] = _fmt(TXT_R1_FMT)
			_add(W.I_BUDGET, -300)
			_add(W.I_INDUSTRY, -400)
			if west_germany != null:
				west_germany.prc_influence = 1
		2:
			context["result_text"] = _fmt(TXT_R2_FMT)
			_add(W.I_BUDGET, -150)
			if luxemburg != null:
				luxemburg.prc_influence = 12
		3:
			context["result_text"] = TXT_R3
			# 原版 :101 event_done[671]=false → 跳过完成标记
			context["skip_mark_done"] = true


func _fmt(s: String) -> String:
	return s.replace("{0}{1}", _leader_name())


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _tech(idx: int) -> bool:
	return ws.techs != null and idx >= 0 and idx < ws.techs.unlocked.size() and ws.techs.unlocked[idx]
