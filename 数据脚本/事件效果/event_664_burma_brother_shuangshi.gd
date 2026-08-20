extends "res://数据脚本/event_script_base.gd"

const T_664_0 := "我的哥哥叫双狮牌，我的妈妈是死去的孔雀"
const T_664_1 := "看来历史确实是个圈：缅甸的第二次“彬龙会议”也正处于多事之秋。原本打算前往勃生参与多方联合会谈的巴登顶同志和数位缅甸共产党高层领导人在恐怖袭击内惨遭刺杀，缅甸共产党在会议期间的“缺席”只会让其他派系抓紧机会发起进攻：克伦民族联盟的代表要求继续召开会议以稳定政局，并试图在此基础上彻底排除政府内的共产主义残余。而未参会的缅甸共产党代表则团结在东北军区的首长彭家声的旗下严厉抗议恐怖袭击，并呼吁推翻政府！我们得赶在覆水难收前做些什么！"
const T_664_2 := "这就是缘……"
const T_664_3 := "派出调查员，绝不能让昂山悲剧重演！"
const T_664_4 := "我们没有理由不支持我们华人兄弟！"
const T_664_5 := "我们怎么能支持所谓云南黄埔军校的人？"
const T_664_7 := "我的哥哥叫双狮牌，我的妈妈是死去的孔雀"
const T_664_8 := "很快，克伦民族联盟领导人波妙便同老牌反共人士，曾因亲美倾向停职，后投诚转向统一战线的缅族将军基貌结盟，以“政府无力控制局势”之名迅速发动政变，逮捕了巴瑞博士和丁吴将军。中央政府的崩溃导致缅甸陷入新一轮内战：东北军区的首长彭家声已在反对“克伦人沙文主义”与“背信弃义”的基础上组建缅甸民主同盟军（即不满于克伦人及其民族地方武装的大帐篷），并向克伦民族联盟牵头的全联邦联盟军发起了全面进攻。"
const T_664_9 := "第二次缅甸内战"
const T_664_10 := "缅甸民主同盟军"
const T_664_11 := "全联邦民主军"
const T_664_12 := "我们决定紧急干预议程，在搜查凶手的情况下要求缅甸各方保持克制。多亏了巴瑞博士，丁吴将军和亲联邦的克伦人温貌先生能够及时做出决策，我们得以将冲突扼杀在摇篮内。克伦民族联盟军事强人波妙坚持推进协议签署的提议被其亲密盟友，如克钦独立组织与若开解放军等团体抵制。而另一边的恐怖袭击调查也稳住了缅甸共产党方的立场——凶手为前澳大利亚特种空降团成员，雇佣兵澳大利亚人戴夫·艾弗特。这只会让澳大利亚与缅甸的关系眼中恶化。上述结论得到了彭家声等地方军官的满意。该国终于不至于重蹈覆辙。而缅甸各大民族也不会忘记我们的慷慨帮助。"
const T_664_13 := "第二次缅甸内战"
const T_664_14 := "缅甸民主同盟军"
const T_664_15 := "全联邦民主军"
const T_664_16 := "很快，克伦民族联盟领导人波妙便同老牌反共人士，曾因亲美倾向停职，后投诚转向统一战线的缅族将军基貌结盟，以“政府无力控制局势”之名迅速发动政变，逮捕了巴瑞博士和丁吴将军。中央政府的崩溃导致缅甸陷入新一轮内战：东北军区的首长彭家声已在反对“克伦人沙文主义”与“背信弃义”的基础上组建缅甸民主同盟军（即不满于克伦人及其民族地方武装的大帐篷），并向克伦民族联盟牵头的全联邦联盟军发起了全面进攻。\n与此同时，在腊戎，老街，邦康等地，历史可上溯至二战时期被修建的机场灯火通明，一架架“航班”飞行起降，持续不断地运送中国志愿军与其装备。雨林里也开始冒出我们最新军事成果——伙计们，这是我们彻底拿下缅甸的的好机会！"


## 原作 Event664.cs：我的哥哥叫双狮牌，我的妈妈是死去的孔雀（缅甸，三选项）。
## 触发：TimeScript.cs:11121-11126 —— (日>=1 且 月>=6 且 年>=1985) || (月>=6 且 年>=1985) || 年>=1986
##   && 缅甸 SubGosstroy==11。
## 差异：
##  - 死代码 result_num==5 跳过。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	event_def.title = T_664_0
	event_def.description = T_664_1
	var opt := event_def.options
	_enable(opt[0], T_664_2)
	_enable(opt[1], T_664_3)
	if line > 0 and line < 4:
		_enable(opt[2], T_664_4)
	else:
		_disable(opt[2], T_664_5)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var burma := ws.get_country_by_legacy_index(33)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_set_part(burma, 0, true)
			_set_part(burma, 1, true)
			_start_war(83, T_664_10, T_664_11, 400, 600, 0, 0, T_664_9)
			context["result_text"] = T_664_8
		1:
			if burma != null:
				burma.sub_government = 11
			_set_part(burma, 1, true)
			if burma != null:
				burma.set_tag("亲中", true)
			ws.influence_prc += 10
			_add(W.I_AGENTS, -50)
			context["result_text"] = T_664_12
		2:
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_DIPLO, 30)
			_set_part(burma, 0, true)
			_set_part(burma, 1, true)
			_start_war(83, T_664_14, T_664_15, 700, 300, 0, 0, T_664_13)
			context["result_text"] = T_664_16




func _set_part(country: CountryData, index: int, value: bool) -> void:
	if country == null:
		return
	while country.parts.size() <= index:
		country.parts.append(false)
	country.parts[index] = value


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, war_name: String, fortnight: int = -1) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		if fortnight >= 0:
			ws.wars[war_id].fortnight_max = fortnight
