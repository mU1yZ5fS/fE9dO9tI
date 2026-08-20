extends "res://数据脚本/event_script_base.gd"

## 原作 Event630.cs：新喀里多尼亚起义（单选项，按 event_done[483] 双文案双效果）。
## 触发：
##   - 自动：ReqEventsDLC02.cs:961-963 —— event_done[483] && c21.SubGosstroy!=19（.tres ExprNode）
##   - 手动：DiploButtonScript.cs:12139（1046，前置已扣 data[22]/data[9] 各 100）
## 差异：原版 TextOfEvents/ResultsOfEvents 按 !event_done[483] 走“风暴”线，
##   483 已完成走“只消轻轻扇动翅膀”线；Godot prepare/execute 同判定。
##   Vyshi→亲美、proprc→亲中、Torg→对华贸易、puppetOf→puppet_of、name→chinese_name。

const TXT_TITLE_STORM := "让风暴来的更猛烈些吧"
const TXT_DESC_STORM := "随着诸多国家进一步脱离法兰西帝国的魔爪，远在天边的新喀里多尼亚进入了一个被称为“多事之秋”的时代。政治暴力，抗议，游行日渐增多。作为当前政治骚乱的主要爆点，新喀里多尼亚的族裔冲突自进入二十世纪以来就一直发酵。卡纳克人作为本地土著，1862年前还没有财产权，1946年前还没有法国公民身份，1957年才有投票权。\n为了抓紧新喀里多尼亚，从而维持在太平洋地区的存在，法国政府大推移边徙民之策，同时停止了在新喀推行类似其他法属非洲殖民地的逐步自治政策。从1963年的人口普查开始，卡纳克人就成为少数派，始终仅有40%左右的人数。时任总理梅斯梅尔1972年公开呼吁法国公民从法国本土或其他海外领土大规模移民，摆明了打人口战压制独立诉求。\n面对收紧的自治空间和周边太平洋岛国的独立潮，卡纳克独派针锋相对地提出了独立公投和投票权要求，这就是当前局势的直接爆点。最近，新喀独派、亲法派和法国政府举行圆桌会议，法国政府被迫承认新喀可能的独立权。这一成就大大鼓舞了新喀独派。卡纳克社会主义民族解放阵线则作为一个大帐篷机构统合各类反法派组织。同年，民解阵抵制了11月的地方选举，并攻占了当地的一座矿山城镇。针锋相对地，亲法派组织也袭击了民阵，杀害了11人，包括其领导人吉巴乌的两个兄弟。自此，新喀陷入了彻底的内战状态，保派和独派组织不断发生武装冲突，互相暗杀对方的政治领导人。而借此机会，我们应该大力的支持我们的战友争取自由。"
const TXT_OPT_STORM := "“因为海燕正翱翔其间”"
const TXT_R_STORM_OK := "随着我们对反叛军武装对进一步支持，大量的轻重武器得以通过瓦努阿图的渔船送抵该国。解放阵线的战士在充足的准备下攻入了努美阿，一切正如法国在阿尔及利亚所遭遇的那样。意识到抵抗无果，驻留的法国宪兵宣布举手投降，尽管保卫喀里多尼亚在共和国内联盟继续抵抗，但孤立无援的他们定会失败。卡纳克人民共和国就此建立了起来，该国宣布实行“科学的美拉尼西亚社会主义”，“充分尊重原住民和移民者后裔的权利”，以及在平等的旗帜下进行外交活动，长期受法国镍业公司控制的镍矿也被收归国有化。法国不得不宣布承认该地的独立，并决定在其他南太平洋殖民地放松管制。"
const TXT_R_STORM_FAIL := "出乎意料又意料之中，革命者的东风竟被西风压过。彼得森总统出于对一个独立且亲红色阵营的政权的担忧，同时也是为了转移国内的矛盾。澳大利亚宣布对新喀里多尼亚发动特别维护和平行动。接近3000人的大军坐着登陆艇和直升机从努美阿登陆，几乎可以被形容为是“乌合之众”的分离主义份子在澳大利亚的攻势下一触即溃。最终，“卡纳克人民共和国临时政府”也被废除。在澳大利亚军队的支持下，保卫喀里多尼亚在（澳大利亚）共和国内联盟的新政府得以被建立起来。\n只不过是从一个暴君的手上滑走，落入另一个暴君的怀里罢了。"

const TXT_TITLE_WINGS := "只消轻轻扇动翅膀……"
const TXT_DESC_WINGS := "香榭丽舍大道的危机和暴乱彻底引爆了法国海外领地脆弱的平衡，远在天边的新喀里多尼亚进入了一个被称为“多事之秋”的时代。政治暴力，抗议，游行日渐增多。作为当前政治骚乱的主要爆点，新喀里多尼亚的族裔冲突自进入二十世纪以来就一直发酵。卡纳克人作为本地土著，1862年前还没有财产权，1946年前还没有法国公民身份，1957年才有投票权。\n为了抓紧新喀里多尼亚，从而维持在太平洋地区的存在，法国政府大推移边徙民之策，同时停止了在新喀推行类似其他法属非洲殖民地的逐步自治政策。从1963年的人口普查开始，卡纳克人就成为少数派，始终仅有40%左右的人数。时任总理梅斯梅尔1972年公开呼吁法国公民从法国本土或其他海外领土大规模移民，摆明了打人口战压制独立诉求。\n面对收紧的自治空间和周边太平洋岛国的独立潮，卡纳克独派针锋相对地提出了独立公投和投票权要求，这就是当前局势的直接爆点。最近，新喀独派就组建完全的联盟，在法国陷入危机时展开起义达成了一只，这一成就大大鼓舞了新喀独派。卡纳克社会主义民族解放阵线则作为一个大帐篷机构统合各类反法派组织。同年，民解阵抵制了11月的地方选举，并攻占了当地的一座矿山城镇。针锋相对地，亲法派组织也袭击了民阵，杀害了11人，包括其领导人吉巴乌的两个兄弟。自此，新喀陷入了彻底的内战状态，而这就是前线记者和线人从努美阿发来的快讯……"
const TXT_OPT_WINGS := "谁赢了？"
const TXT_R_WINGS_BASE := "解放阵线的战士在充足的准备下攻入了努美阿，一切正如法国在阿尔及利亚所遭遇的那样。意识到抵抗无果，驻留的法国宪兵宣布举手投降，尽管保卫喀里多尼亚在共和国内联盟继续抵抗，但孤立无援的他们定会失败。卡纳克人民共和国就此建立了起来，该国宣布实行“科学的美拉尼西亚社会主义”，“充分尊重原住民和移民者后裔的权利”，以及在平等的旗帜下进行外交活动，长期受法国镍业公司控制的镍矿也被收归国有化。"
const TXT_R_WINGS_SOC_TAIL := "新生的红色法国不仅就殖民时期的恶果向卡纳克人民共和国表示了歉意，并决定提供力所能及的帮助，同时宣布从余下的南太平洋，非洲和加勒比海的海外领地逐步撤出"
const TXT_R_WINGS_FR22 := "新生的法国政权提出了奇怪的解决方案，宣称为了第三世界的彻底革命，法国将与其余的海外领地达成联邦关系，一切都依托于奇特的民族毛主义理论。同时，新喀也获得了来自本土的更多投资。"
const TXT_R_WINGS_FR_AUTH := "涅槃重生的法兰西当然拒绝了彻底撤出的方案，不仅对独立的共和国展开了禁运，并在其余的海外领土彻底镇压分离主义分子。"
const TXT_R_WINGS_AUS := "出乎意料又意料之中，革命者的东风竟被西风压过。彼得森总统出于对一个独立且亲红色阵营的政权的担忧，同时也是为了转移国内的矛盾。澳大利亚宣布对新喀里多尼亚发动特别维护和平行动。接近3000人的大军坐着登陆艇和直升机从努美阿登陆，几乎可以被形容为是“乌合之众”的分离主义份子在澳大利亚的攻势下一触即溃。最终，“卡纳克人民共和国临时政府”也被废除。在澳大利亚军队的支持下，保卫喀里多尼亚在（澳大利亚）共和国内联盟的新政府得以被建立起来。\n只不过是从一个暴君的手上滑走，落入另一个暴君的怀里罢了。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.is_empty():
		return
	if ws.completed_event_ids.has("event_483"):
		event_def.title = TXT_TITLE_WINGS
		event_def.description = TXT_DESC_WINGS
		_enable(event_def.options[0], TXT_OPT_WINGS)
	else:
		event_def.title = TXT_TITLE_STORM
		event_def.description = TXT_DESC_STORM
		_enable(event_def.options[0], TXT_OPT_STORM)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var new_caledonia := ws.get_country_by_legacy_index(154)
	var france := ws.get_country_by_legacy_index(21)
	var australia := ws.get_country_by_legacy_index(135)
	if ws.completed_event_ids.has("event_483"):
		# 原版 :66-115：法国危机后路线分支
		var text := TXT_R_WINGS_BASE
		if ws.is_socialism(france, true):
			text += TXT_R_WINGS_SOC_TAIL
			if new_caledonia != null:
				new_caledonia.government = GameConstants.Government.SOCIALIST
				new_caledonia.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(new_caledonia)
				new_caledonia.chinese_name = "卡纳克人民共和国"
				new_caledonia.set_tag("亲中", true)
				new_caledonia.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add_power(EmpireData.USA, -10)
			_add_relation(EmpireData.USA, -70)
		elif france != null and france.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
			text = TXT_R_WINGS_FR22
			if new_caledonia != null:
				new_caledonia.government = GameConstants.Government.AUTHORITARIAN
				new_caledonia.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
				_leave_alliances(new_caledonia)
				new_caledonia.puppet_of = GameConstants.LegacySlot.FRANCE
				new_caledonia.chinese_name = "卡纳克人民国"
			_add_power(EmpireData.USA, 10)
		elif ws.is_authoritarian(france):
			text = TXT_R_WINGS_FR_AUTH
			if new_caledonia != null:
				new_caledonia.government = GameConstants.Government.REFORMIST
				new_caledonia.sub_government = GameConstants.SubGovernment.PRAGMATIST
				_leave_alliances(new_caledonia)
				new_caledonia.chinese_name = "卡纳克共和国"
			_add_power(EmpireData.USA, -10)
		if ws.is_authoritarian(australia):
			text = TXT_R_WINGS_AUS
			if new_caledonia != null:
				new_caledonia.government = GameConstants.Government.AUTHORITARIAN
				new_caledonia.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(new_caledonia)
				new_caledonia.puppet_of = GameConstants.LegacySlot.AUSTRALIA
				new_caledonia.chinese_name = "“卡纳克共和国”"
			_add_power(EmpireData.USA, 10)
		context["result_text"] = text
		return
	# 原版 :37-64：483 未完成的武装支援线
	if australia != null and australia.government != GameConstants.Government.AUTHORITARIAN:
		context["result_text"] = TXT_R_STORM_OK
		if new_caledonia != null:
			new_caledonia.government = GameConstants.Government.SOCIALIST
			new_caledonia.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			_leave_alliances(new_caledonia)
			new_caledonia.chinese_name = "卡纳克人民共和国"
			new_caledonia.set_tag("亲中", true)
			new_caledonia.set_tag("对华贸易", true)
		ws.influence_prc += 10
		_add_power(EmpireData.USA, -10)
		_add_relation(EmpireData.USA, -70)
		return
	context["result_text"] = TXT_R_STORM_FAIL
	if new_caledonia != null:
		new_caledonia.government = GameConstants.Government.AUTHORITARIAN
		new_caledonia.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		_leave_alliances(new_caledonia)
		new_caledonia.puppet_of = GameConstants.LegacySlot.AUSTRALIA
		new_caledonia.chinese_name = "卡纳克共和国"
	_add_power(EmpireData.USA, 10)
