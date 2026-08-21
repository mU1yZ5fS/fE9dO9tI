extends "res://数据脚本/event_script_base.gd"

## 原作 Event591.cs：祖国或死亡（古巴，三选项）。
## 触发：DiploButtonScript.cs:11793 —— number_event = 591（外交按钮手动触发），无自动触发。
## 差异：
##  - 选项2 显隐 prepare 动态改写（now_leader → current_leader）；Torg → 对华贸易；
##  - modifies[3]/[6].active → ws.modifiers[3]/[6].is_active；
##  - EstablishGovernment(ProChina) → 亲中 true、亲苏/亲美 false；
##  - JoinAllOurAlliances(true) → 基类 _join_alliances；
##  - c141.SubGosstroy==20 分支文本拼接。



const TXT_OPT2_DIS := ""

const TXT_R0_A := "菲德尔·卡斯特罗欣然同意了我们邀请他前来观看本年国庆游行的邀请。在为他接风洗尘的招待宴上，"
const TXT_R0_B := "同志赞扬了古巴革命以来取得的成果与在美帝封锁下坚强不屈的革命精神，并隐晦地批评了该国受苏修影响所酿成的恶果，讲话最后以一声“要古巴不要美国佬！”结尾。在随后的商谈中，"
const TXT_R0_C := "承诺将尽己所能为古巴提供支持。\n很快，来自中国的工程队与大米便启程送往古巴。不过，我们当然不可能像苏联人一样，将古巴简单作为“糖罐”绑定于经互会的国际分工体系中，而在经过此前的教训后，卡斯特罗也决定扭转该国经济结构单一的现状。为此，在经过我国专家的实地考察后，我们为他们制定了全新的经济发展计划。卡斯特罗宣布开展第二次“革命攻势”，以使该国能够实现经济多元化和自给自足。大量的甘蔗地改种了水稻、马铃薯等粮食作物，和热带水果、咖啡等作物，近一半的制糖厂被逐步关闭，其将被改造为其他工厂，因此而失业的制糖工人也将经受培训后于新岗位再就业。尽管经济结构的转型会带来很多问题，但这些只是暂时的。\n卡斯特罗感谢我们的支持，他邀请"
const TXT_R0_D := "参加古巴共产党的新一届大会，在会议中，卡斯特罗宣布“古巴将与中国同进退”，并授予了"
const TXT_R0_E := "同志古巴共和国英雄勋章和何塞·马蒂勋章。两位亲华派：第一任保卫革命委员会全国总协调员何塞·马塔尔和前统一革命组织（古共的前身）中央委员弗朗西斯科·卡尔辛斯也在这场会议中被纳入政治局。"
const TXT_R1_A := "通过哥伦比亚卡特尔的巴勃罗·埃斯科瓦尔的关系网，我们秘密与对卡斯特罗不满、曾先后参与了在戈兰高地、安哥拉和欧加登地区的作战、功勋卓著的阿纳尔多·奥乔亚·桑切斯中将取得了联系，一场政变拉开了帷幕。\n在古巴共产党的一次例行会议期间，一队士兵闯入会议室，使用冲锋枪向其中扫射，卡斯特罗——这位曾躲过CIA无数次刺杀的革命家终究还是一命呜呼，栽在了自己人手里。随后，奥乔亚将军发动政变接管了古巴政府，在广播中，他宣布“苏联新殖民主义的代理人、新修正主义者菲德尔·卡斯特罗背叛了古巴革命事业，将古巴绑到了苏修社会帝国主义的战车之上”，并公布了一系列卡斯特罗的罪行，其中包括：向美国出卖古巴主权、年轻时阅读过长枪党书籍，与西班牙法西斯分子佛朗哥所勾结、将国家从美国的糖罐变为了经互会的糖罐，“而现在，这一切都结束了”。新政府由奥乔亚和他的密友狄奥克莱斯·托拉尔瓦、女婿托尼·德拉瓜迪亚等亲信领导。奥乔亚刚一上台便开始与哥伦比亚的麦德林帮、墨西哥的瓜达哈拉集团"
const TXT_R1_NORIEGA := "、巴拿马的诺列加政府"
const TXT_R1_B := "等贩毒集团展开了亲密合作，并宣布将使古柯种植合法化，在他的治下，古巴迅速成为拉美毒品走私的中心，腐败与政治贿赂也在该国蔓延。"
const TXT_R2 := "我国政府与苏联向古巴施加了外交压力，要求古巴进行政治改革，否则就彻底断绝援助。以换取援助为条件，菲德尔·卡斯特罗不得不辞去部长会议主席和古巴共产党总书记等职务，随后，素有“经济沙皇”称号的部长会议副主席卡洛斯·拉斐尔·罗德里格斯接替了这些职位。新任总书记上任后便进行了大刀阔斧的变革，他任命了在苏联就学过的新一代经济学家、国家计划委员会主任温贝托·佩雷斯·冈萨雷斯主持经济改革，在扩大企业自主权，进一步利用物质刺激的同时，开放了对外国与私人投资的限制，大力提倡国有企业变为与外国合资，合法化美元交易。面对社会主义古巴的惊人变革，就连近在咫尺的宿敌也选择了撤销对该国的经济封锁，接纳其进入泛美体系与美洲国家组织之内，古巴也由此承诺不干涉他国内政，停止革命输出，断绝了对一切美洲左翼游击队的援助，并向拉美各个亲美政权移交了躲藏在古巴的左翼异见者和游击队员。外资的涌入使该国迅速进入了经济繁荣，合法的餐馆、商店、小商贩与私人企业再次步入古巴的经济舞台，来自美国的新颖消费品出现在了哈瓦那、圣地亚哥、巴亚莫等城市的货架上，配给制也终于得以结束，这会是个好兆头吗？"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var c7 := world.get_country_by_legacy_index(7)
	var ussr := world.empires[EmpireData.USSR] if world.empires.size() > EmpireData.USSR else null
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	if ussr != null and ussr.current_leader == 6 and c7 != null and c7.has_tag("对华贸易") and line >= 3:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c138 := ws.get_country_by_legacy_index(138)
	var c141 := ws.get_country_by_legacy_index(141)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var tname := _leader_name()
			var text := TXT_R0_A + tname + TXT_R0_B + tname + TXT_R0_C + tname + TXT_R0_D + tname + TXT_R0_E
			_add(W.I_BUDGET, -150)
			if c138 != null:
				if _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and _mod_active(GameConstants.Modifier.MAOIST_BULWARK):
					c138.government = GameConstants.Government.SOCIALIST
					c138.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				else:
					c138.government = GameConstants.Government.REFORMIST
					c138.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
				_establish_prochina(c138)
				c138.set_tag("对华贸易", true)
				_join_alliances(c138)
			context["result_text"] = text
		1:
			var text := TXT_R1_A
			if c141 != null and c141.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN:
				text += TXT_R1_NORIEGA
			text += TXT_R1_B
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			if c138 != null:
				c138.government = GameConstants.Government.AUTHORITARIAN
				c138.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				_establish_prochina(c138)
				c138.set_tag("对华贸易", true)
				_join_alliances(c138)
			context["result_text"] = text
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			if c138 != null:
				c138.government = GameConstants.Government.REFORMIST
				c138.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
				_establish_prochina(c138)
				c138.set_tag("对华贸易", true)
			context["result_text"] = TXT_R2


func _establish_prochina(c: CountryData) -> void:
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)


func _mod_active(id: int) -> bool:
	return ws.modifiers.size() > id and ws.modifiers[id] != null and ws.modifiers[id].is_active


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
