extends "res://数据脚本/event_script_base.gd"

## 原作 Event652.cs：非洲大逃杀（塞拉利昂莫莫改革，四选项）。
## 触发：TimeScript.cs 11035-11039 —— (月>=4 且 年>=1985 或 年>=1986) && c107.sub_government != 12。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线 / c107 对华贸易 / c107 内战 / c13 利比亚对华贸易 / c51 美国发展度与美领导人）。
##  - War 78：GameManager.start_war(78,...) + fortnight_max=40（TickTime(40)）；
##    AmericanSupportDefender.SovietSupportAttacker → usa_side=1 / ussr_side=0；
##    仅 AmericanSupportDefender 的分支 usa_side=1 / ussr_side=-1（原版 War 默认 -1）。
##  - 死代码 result 5 测试分支跳过；result 3 是实际选项（充耳不闻），效果已复刻。

const TXT_TITLE := "非洲大逃杀"
const TXT_DESC := "进入20世纪80年代后，塞拉利昂的经济便持续下行，深受恶性通货膨胀与缺乏社会保障设施的困扰。也就在1985年内，塞拉利昂的通货膨胀率便高达76.6%。失业潮与国内经济长期缺乏有效投资的情况使该国大量青年沦为无业游民，并自发结成黑社会性质的组织谋求生计。糜烂的局势甚至让斯蒂文森都无法泰然处之，不得不在“蝗虫般的17年后”引咎辞职。大会党准备寄希望于来自强力机关的候选人约瑟夫·赛义杜·莫莫重振局势，并为经济改革做好了计划：出于平抑物价的需要，政府对投机倒把、囤积居奇、哄抬物价等行为严惩不贷；并决定改组缉私队伍，惩办走私者和驱逐违法的外商。可考虑到塞拉利昂国内利益团体早已在多年腐败统治下根深蒂固，如此改革仍显得浮于表面：且斯蒂文森的亲信们也不满于莫莫的“专断行径”。看起来塞拉利昂已来到了其历史拐点。"

const TXT_OPT0 := "帮助莫莫深化改革，并扫除塞拉利昂政坛的保守派！"
const TXT_OPT0_DIS := "我们无能为力"
const TXT_OPT1 := "是时候结束全国大会党政权的闹剧了！"
const TXT_OPT1_DIS_BACKSTAB := "我们可不能背刺合作伙伴"
const TXT_OPT1_DIS_NOONE := "我们没找到合适的人选"
const TXT_OPT1_DIS_INTERFERE := "这是对外国内政的激进干涉！"
const TXT_OPT2 := "与美国一起，支持强力手段稳定西非局势。"
const TXT_OPT2_DIS_BACKSTAB := "我们可不能背刺合作伙伴"
const TXT_OPT2_DIS_BUSY := "美国可没有闲心多管闲事"
const TXT_OPT2_DIS_IMPERIAL := "绝不能支持美帝国主义代理人"
const TXT_OPT3 := "充耳不闻"

const TXT_R0 := "您决定亲自致电莫莫，表示中国将拨付低息贷款解决塞拉利昂目前的经济问题。莫莫对此则表示无比感激，顺势深化了先前早已建立的中-塞友好关系：仰仗中国的经济援助与政治支持，莫莫政府得以全面推进其改革政策并剔除保守派。资金的流入缓解了长期缺乏有效投资的问题，让该国得以逐步解决社保，教育与水电供应问题。塞拉利昂全国大会党政权就此稳定了下来，不至跌入暴力深渊。"
const TXT_R1_INTRO := "如今全国大会党政权已是风雨飘摇，正是入局的好机会——受够了斯蒂文森集团腐败统治的中国决定借题发挥，通过扶持塞拉利昂境内革命者的方式彻底终结这一盗贼体制。"
const TXT_R1_CW := "通过非洲社会主义者的渠道与塞拉利昂境内的左翼网络，我们将塞拉利昂泛非联盟（持革命泛非主义，由克莱奥·汉西莱等人创建）等革命左翼组织和马克思主义者易布拉辛·阿卜杜拉（他曾在莫桑比克内战期间积极参与莫桑比克解放阵线的工作，并深刻领会了非洲革命斗争模式）的队伍整合起来，并筹备一场革命，不久后，他们便成立了塞拉利昂人民民主阵线，并迅速吸纳了大量对弗里敦政府不满的青年与失业工人，对全国各地发起了进攻。塞拉利昂全国就此进入紧急状态。也就在混乱期间，原总统莫莫被前总统府警卫副总监与国民警察副局长加布里埃尔·卡伊卡伊所谋害，后者借机组建了一个奉行实用主义的军政府“镇压革命”。塞拉利昂起义就此爆发。"
const TXT_WAR78_NAME := "塞拉利昂内战"
const TXT_WAR78_CW_ATTACKER := "塞人阵"
const TXT_WAR78_CW_DEFENDER := "政府军"
const TXT_R1_NO_CW := "得益于我们和利比亚的良好关系，我们决定押宝曾在利比亚接受革命民族主义训练并以组织未遂政变反对斯蒂文森政权而闻名遐迩的福迪·桑科。他的履历足以作为我们彻底改变塞拉利昂局势的最佳王牌。不久后，桑科便以“革命联合阵线”之名纠结起该国主要反对派对全国各地发起了进攻。塞拉利昂全国就此进入紧急状态。也就在混乱期间，原总统莫莫被前总统府警卫副总监与国民警察副局长加布里埃尔·卡伊卡伊所谋害，后者借机组建了一个奉行实用主义的军政府“镇压革命”。塞拉利昂起义就此爆发。"
const TXT_WAR78_NO_CW_ATTACKER := "革联阵"
const TXT_WAR78_NO_CW_DEFENDER := "政府军"
const TXT_R2 := "我们决定同美国人一道解决塞拉利昂问题——考虑到塞拉利昂国内局势的复杂性，以及其可能成为第二个安哥拉或莫桑比克的可能。有必要赶在局势待定前迅速出手稳定政局。最终我们联合敲定了行动方案：通过已被驱逐出境的黎巴嫩籍巨富米勒·穆罕默德提供的巨额资金，前总统府警卫副总监与国民警察副局长加布里埃尔·卡伊卡伊得以秘密武装起一只私兵队伍筹备政变，并在总统府附近的公路桥炸毁了莫莫亲自乘坐的专车。接下来便是借机引入紧急状态并扭转外交路线，由此组织起奉行实用主义的军政府“维持国家秩序”。塞拉利昂的皮诺切特就此待命，谁知道接下来会如何？"
const TXT_R3 := "莫莫与斯蒂文森集团的斗争仍在继续，并试图在此期间将后者边缘化。然而，目前塞拉利昂的处境可等不了太久……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	event_def.title = TXT_TITLE
	event_def.description = TXT_DESC
	var sierra := world.get_country_by_legacy_index(107)
	var libya := world.get_country_by_legacy_index(13)
	var usa_country := world.get_country_by_legacy_index(51)
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	var opt := event_def.options
	var sierra_torg := sierra != null and sierra.has_tag("对华贸易")
	if sierra_torg:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	var sierra_cw := sierra != null and sierra.内战中
	var libya_torg := libya != null and libya.has_tag("对华贸易")
	if line <= 2 and (sierra_cw or libya_torg) and not sierra_torg:
		_enable(opt[1], TXT_OPT1)
	elif sierra_torg:
		_disable(opt[1], TXT_OPT1_DIS_BACKSTAB)
	elif not sierra_cw and not libya_torg:
		_disable(opt[1], TXT_OPT1_DIS_NOONE)
	else:
		_disable(opt[1], TXT_OPT1_DIS_INTERFERE)
	var usa_dev_ok := usa_country != null and usa_country.development == 1
	var usa_leader := 0
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null:
		usa_leader = world.empires[EmpireData.USA].current_leader
	var usa_leader_ok := usa_leader == 0 or usa_leader == 2
	if line >= 3 and usa_dev_ok and usa_leader_ok and not sierra_torg:
		_enable(opt[2], TXT_OPT2)
	elif sierra_torg:
		_disable(opt[2], TXT_OPT2_DIS_BACKSTAB)
	elif not usa_dev_ok or not usa_leader_ok:
		_disable(opt[2], TXT_OPT2_DIS_BUSY)
	else:
		_disable(opt[2], TXT_OPT2_DIS_IMPERIAL)
	_enable(opt[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var sierra := ws.get_country_by_legacy_index(107)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if sierra != null:
				_leave_alliances(sierra)
				sierra.set_tag("对华贸易", true)
				sierra.government = 2
				sierra.sub_government = 15
				sierra.set_tag("亲中", true)
			_add(W.I_BUDGET, -80)
			ws.influence_prc += 10
			context["result_text"] = TXT_R0
		1:
			if sierra != null:
				sierra.government = 0
				sierra.sub_government = 7
				_leave_alliances(sierra)
				sierra.set_tag("亲美", true)
				_set_parts(sierra, 0, true)
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -30)
			_add_relation(EmpireData.USA, -50)
			var text := TXT_R1_INTRO
			if sierra != null and sierra.内战中:
				GameManager.start_war(78, TXT_WAR78_CW_ATTACKER, TXT_WAR78_CW_DEFENDER, 200, 800, 1, 0)
				text += TXT_R1_CW
			else:
				GameManager.start_war(78, TXT_WAR78_NO_CW_ATTACKER, TXT_WAR78_NO_CW_DEFENDER, 200, 800, 1, -1)
				if ws.wars.size() > 78 and ws.wars[78] != null:
					ws.wars[78].ussr_side = -1
				text += TXT_R1_NO_CW
			if ws.wars.size() > 78 and ws.wars[78] != null:
				ws.wars[78].name_war = TXT_WAR78_NAME
				ws.wars[78].fortnight_max = 40
			context["result_text"] = text
		2:
			if sierra != null:
				_leave_alliances(sierra)
				sierra.government = 0
				sierra.sub_government = 7
				sierra.set_tag("亲美", true)
				sierra.set_tag("对华贸易", true)
			context["result_text"] = TXT_R2
		3:
			if sierra != null:
				sierra.government = 2
				sierra.sub_government = 15
			context["result_text"] = TXT_R3


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _set_parts(c: CountryData, index: int, value: bool) -> void:
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)
