extends "res://数据脚本/event_script_base.gd"

## 原作 Event572.cs：赎罪之旅（法国赎罪行动，单选项）。
## 触发：ReqEventForDLC02.cs:1119-1122 —— !event_done[572] && event_done[390]
##   && c21.Gosstroy==1 && flag(任意国家 puppetOf==21) && YugAgree && data[131]==2。
##   复杂条件（flag 循环 + raw data[131]）→ trigger_script evaluate。
## 差异：
##  - event_done[572] 由 fire_only_once 覆盖；event_done[390] 在 evaluate 中检查；
##  - YugAgree → ws flag "YugAgree"；data[131] 无命名键 raw；
##  - relres → ws flag "relres"；isSEV → 标签 sev；Torg → 对华贸易；
##  - LeaveAlliances 用基类 _leave_alliances；JoinECON 只置 econ 标签。

const TXT_TITLE := "赎罪之旅"

const TXT_DESC := "在过去，同其他帝国主义国家一样，法国积极在非洲支持新殖民主义，在非洲同许多国家保持着“特殊关系”，扶持了大量买办和独裁者——如纳辛贝·埃亚德马、乌弗埃·博瓦尼以及让-贝德尔·博卡萨——以打压革命者，保证列强在当地的利益。这一切和法国总统勒罗伊的理念完全不合。在法国通过“和平革命”转向社会主义和苏东阵营后，他决定同苏联合作，在法国外籍兵团和古巴军队的帮助下，亲自推翻法国在本地扶持的独裁者，并为社会主义阵营提供新的伙伴。这一行动的代号为“赎罪行动”。"

const TXT_OPT0 := "这是新殖民主义的终结还是社会帝国主义的开始？"

const TXT_TUNISIA := "|法军直接从驻军基地出发，逮捕了本·阿里，并解散了他的反动政府，将突尼斯共产党同人民团结运动等左翼政党合并为突尼斯劳动党，组织了以穆罕默德·哈梅尔（突共第一书记）为总统、本·萨拉赫为总理的新政府。"
const TXT_LIBYA := "|法国外籍兵团自突尼斯空降的黎波里，推翻了王国政府，由于当地缺乏完整的共产主义组织，他们选择将左翼反对派——马克思主义的利比亚民族民主阵线、复兴主义的利比亚民族运动和利比亚共产党的残余组织合并为利比亚人民民主党，乌姆兰·卜尔维斯则被选举为新政府的首脑，阿杜拉希姆·萨利赫博士出任人民民主党总书记。"
const TXT_CAR := "|古巴军人同反对当局的中非人民解放阵线和当地愿意合作的弗朗索瓦·博齐泽将军进行里应外合，成功推翻了科林巴的军政府。中非人民解放阵线领袖昂热-菲利克斯·帕塔塞领导新的中非政府。在名义上持民主社会主义态度的帕塔塞当即摇身一变，宣布自己“将作为一个马克思列宁主义者，同法国和苏联一起，在非洲进行人民革命”。"
const TXT_CAMEROON := "|法国国家人民军在苏联的支持下进行跨国专政，推翻了喀麦隆旧政权。新政权由UPC的亲PCF分子沙普谢·恩金加·让·马丁和UPC温和派的西奥多·马伊·马蒂普与亚伯拉罕·恩根坎领导，UPC中忠于他们的人员将组织改组为喀麦隆人民革命党作为执政党，领导新生的喀麦隆民主共和国。新政权宣布将国家向类似法国和东欧的模式改造，并成为了经互会观察员国。"
const TXT_CAMEROON_NAME := "喀麦隆民主共和国"
const TXT_MALI := "|鉴于穆萨·特拉奥雷领导的马里人民民主联盟一党制政府同法国和苏东阵营保持了较好的关系，且其主张泛非主义，在苏东和法国的压力下，特拉奥雷决定摇身一变，以一个进步军人的姿态，从马里苏丹民主联盟等地下左翼异见组织中吸收愿意合作的成员，以马里人民民主联盟为基础组织了以马克思列宁主义为指导思想的马里人民民主党，马里正式倒向了苏东阵营。"
const TXT_GUINEA := "|法国空降兵团和古巴士兵共同行动，推翻了法国旧政府扶持的孔戴政府，在曼巴·萨诺这位亲法的几内亚左翼分子很快获得了法国的青睐，而他也一转过去的反共立场，把自己包装为“法国和苏联最亲密的同志”，很快，他组织起愿意合作的左翼分子，成立了以马克思列宁主义为指导思想的几内亚人民革命党，新政府宣布重建几内亚人民革命共和国。"
const TXT_CIV := "|外籍兵团和古巴士兵快速攻入了阿比让，在黑洞洞的枪口下，乌弗埃·博瓦尼宣布辞去一切总统职位，其被带回法国审判。在法国的大手之下，佛朗西斯·伍迪（科特迪瓦劳动党），洛朗·巴洛（科特迪瓦人民阵线）和亨利·图胡（人民社会主义联盟）组织的社会主义革命运动-80得以登台执政。但这个政府充满了争议和内部矛盾：暂且不谈如此之多的主义主义，哪怕是在如何实现“社会主义理念”上三方都能吵个不停。为此法国不得不亲自出面斡旋三方的矛盾。新政府极度依赖法国的援助和古巴的驻军来保障其独立。在北部，分离主义者的力量大大增强了，似乎埃塞俄比亚的悲剧马上就要在“非洲橱窗”再度上演……"
const TXT_TOGO := "|政变的消息便从洛美传来，法国外籍兵团和空降兵亲自前往多哥抓获了纳辛贝·埃亚德马。并判处他以叛国罪，贪污，谋杀，谋杀未遂四项罪名带回法国审判。随后，由马克斯·门萨·艾森（贝宁社会主义革命党-多哥支部）和塔维奥·阿莫林（泛非社会主义党）组织的人民阵线政府取缔了多哥人民联盟，组建了多哥民主共和国。"
const TXT_BENIN := "|在古巴士兵的帮助下，法国人推翻了他们自己扶持的专制政府，取而代之的则是由泰奥菲尔·贝昂赞的贝宁社会主义革命党-贝宁支部领导的新政府，他们宣布重建贝宁人民共和国，并将马蒂厄·克雷库奉为“革命烈士”。"
const TXT_GABON := "|在法国、苏联的大力支持下，法国国家人民军推翻了邦戈政权，在他们的支持下，全国复兴运动“原始派”、加蓬人民联盟、加蓬进步党、加蓬争取社会主义协会（本为亲邦戈的中左翼政党，在人民军到来后宣布自己支持科学社会主义）、加蓬社会主义党和加蓬社会主义联盟等左翼力量合并为加蓬统一社会党，宣布将按照法国、东欧以及苏联的模式进行人民民主化。"
const TXT_MADAGASCAR := "|在法国的施压下,拉贝马南贾拉被迫解禁独立大会党等左翼政党并重新举行大选,不出所料，拉齐拉卡再次登上了总统宝座。此后，他将独立大会党、革命先锋等数个左翼政党合并为以马列主义和福科诺洛纳社会主义为指导思想的马尔加什统一社会党，并重建了马达加斯加民主共和国。"
const TXT_TAIL := "\n新政府在法国和苏联的资助下，开始了缓慢而稳定的工业化和仿照苏东的社会主义改革。作为交换，苏东阵营得以在这些国家布置新的军事基地，并以极低的价格开采当地的资源。新政府也宣布将对社会主义阵营国家保持友好，并建立“革命同志般的”联系。但也有观察家对“赎罪行动”提出质疑——这究竟是解放非洲还是为他们换了一个新主子？"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if not world.completed_event_ids.has("event_390"):
		return false
	var c21 := world.get_country_by_legacy_index(21)
	if c21 == null or c21.government != 1:
		return false
	var flag := false
	for c in world.countries:
		if c != null and c.puppet_of == 21:
			flag = true
			break
	if not flag:
		return false
	if not world.get_flag("YugAgree"):
		return false
	if world.数值表.size() <= 131 or world.数值表[131] != 2:   # 原 data[131]（无命名键）
		return false
	return true


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var text := ""
	if ws.get_country_by_legacy_index(55) != null and ws.get_country_by_legacy_index(55).puppet_of == 21:
		text += TXT_TUNISIA
	if ws.get_country_by_legacy_index(13) != null and ws.get_country_by_legacy_index(13).puppet_of == 21:
		text += TXT_LIBYA
	if ws.get_country_by_legacy_index(65) != null and ws.get_country_by_legacy_index(65).puppet_of == 21:
		text += TXT_CAR
	if ws.get_country_by_legacy_index(66) != null and ws.get_country_by_legacy_index(66).puppet_of == 21:
		text += TXT_CAMEROON
		var c66 := ws.get_country_by_legacy_index(66)
		if c66 != null:
			c66.chinese_name = TXT_CAMEROON_NAME
	if ws.get_country_by_legacy_index(58) != null and ws.get_country_by_legacy_index(58).puppet_of == 21:
		text += TXT_MALI
	if ws.get_country_by_legacy_index(68) != null and ws.get_country_by_legacy_index(68).puppet_of == 21:
		text += TXT_GUINEA
	if ws.get_country_by_legacy_index(64) != null and ws.get_country_by_legacy_index(64).puppet_of == 21:
		text += TXT_CIV
	if ws.get_country_by_legacy_index(108) != null and ws.get_country_by_legacy_index(108).puppet_of == 21:
		text += TXT_TOGO
	if ws.get_country_by_legacy_index(62) != null and ws.get_country_by_legacy_index(62).puppet_of == 21:
		text += TXT_BENIN
	if ws.get_country_by_legacy_index(116) != null and ws.get_country_by_legacy_index(116).puppet_of == 21:
		text += TXT_GABON
	if ws.get_country_by_legacy_index(133) != null and ws.get_country_by_legacy_index(133).puppet_of == 21:
		text += TXT_MADAGASCAR
	var num := 0
	var china := ws.get_country_by_legacy_index(1)
	for c in ws.countries:
		if c == null:
			continue
		if c.puppet_of == 21:
			c.puppet_of = -1
			_leave_alliances(c)
			c.set_tag("亲苏", true)
			c.government = 1
			c.sub_government = 16
			if ws.get_flag("relres") or (china != null and china.has_tag("sev")):
				c.set_tag("对华贸易", true)
			num += 1
	_add_power(EmpireData.USSR, 5 * num)
	text += TXT_TAIL
	context["result_text"] = text
