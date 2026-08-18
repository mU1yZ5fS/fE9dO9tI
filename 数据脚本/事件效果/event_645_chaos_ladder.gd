extends "res://数据脚本/event_script_base.gd"

## 原作 Event645.cs：混乱即阶梯（罗马尼亚脱离苏东，单选项）。
## 触发：ReqEventsDLC02.cs:94-96 —— c5.SubGosstroy==19 && IndOpp → trigger_script evaluate。
## 差异：ingamewars[76] 建模说明 WarDef → 兜底创建后补名；
##   isSEV/isOVD→sev/ovd 标签；JoinAllOurAlliances(true)→_join_alliances。

const TXT_TITLE := "混乱即阶梯"
const TXT_DESC := "中国在远东地区决定性的军事行动不仅空前削弱了苏联的影响力，将其影响力基本逐出亚洲。同时还为其治下的东欧盟国做了“表率”——考虑到苏东集团事实上可被视为围绕苏联建立的“恒星系”结构，其前途命运与苏联国力息息相关。那么，在战后摇摇欲坠的显然不只有苏联：东欧诸国的政客已从苏联削减补贴，调整军事部署，事实上削弱军事存在（显然是为了维持国内稳定的需要）的举动中嗅出了不妙气息，并已开始为此做准备。他们或是增强与邻国的多边合作，或是越加转向发展同欧美国家与第三世界的关系。华约与经济互助委员会两大体系已开始逐步变性，苏联在其中的话语权以肉眼可见的速率降低：也就在这敏感时刻，早和中国、法国等强权勾肩搭背的罗马尼亚则看准苏联衰微、东欧多国自顾不暇的时机直接跳船，彻底脱离了苏东集团的一体化架构，转而决定选择加入“更有前途”的集团内。考虑到齐奥塞斯库的行事风格，他只有可能应用“中国式方案”，并打算将其应用到治国理政与解决比萨拉比亚地区的“历史遗留问题”上。不过，多瑙河的天才显然还是低估了苏东集团这具尸体内潜藏的力量——虽说苏联老大哥荣光不再，可苏东体系的最后捍卫者们仍保留了原汁原味的尾巴摇狗习俗，决定对这个试图推倒东欧多米诺骨牌的叛逆政权一点颜色瞧瞧。毕竟，坐在坦克上的东欧保守派集团们依然需要保护伞彰显自身权威。如果苏东体系彻底解体，这些在国内缺乏根基的伪群众党必然难以应付早在境内打出风头的民粹主义分子：于是我们可说，争夺苏联遗产的战争已经开始……"
const TXT_OPT0 := "火药桶已经引爆……"
const TXT_R0 := "国际观察员认为。虽说苏东社会主义阵营内已生嫌隙，且力量不复往昔；可对付一个孤立无援，且扎根华约腹地的罗马尼亚仍是绰绰有余。以美国为首的西方国家已开始控诉华约对罗马尼亚的入侵，并大力渲染所谓“邪恶帝国余毒尚存”。显然，他们只能重弹1956年匈牙利事件与1968年捷克事件时的老调，只能用舆论给罗马尼亚拉些“同情”。而苏联则在标榜中立的同时悄然对罗马尼亚引入了封锁与制裁。现在，唯有我们才能够保护弃暗投明的好朋友！"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	context["result_text"] = TXT_R0
	# 原版 ingamewars[76]：喀尔巴阡行动，罗马尼亚(300) vs 华沙条约(700)，
	#   AmericanSupportAttacker → usa_side=1、SovietSupportDefender → ussr_side=2
	GameManager.start_war(76, "罗马尼亚", "华沙条约", 300, 700, 1, 2)
	if ws.wars.size() > 76 and ws.wars[76] != null:
		ws.wars[76].name_war = "喀尔巴阡行动"
	_add(W.I_PARTY_SUPPORT, 300)
	_add(W.I_PEOPLE_SUPPORT, 300)
	_add(W.I_THOUGHT_FREEDOM, -200)
	_add(W.I_DIPLO, 150)
	var romania := ws.get_country_by_legacy_index(5)
	if romania != null:
		romania.set_tag("sev", false)
		romania.set_tag("ovd", false)
		_join_alliances(romania)
	_add_relation(EmpireData.USSR, -250)
	_add_power(EmpireData.USSR, -15)
	ws.influence_prc += 15


func evaluate(world: WorldState) -> bool:
	if world == null or not world.ind_opp:
		return false
	var romania := world.get_country_by_legacy_index(5)
	return romania != null and romania.sub_government == 19
