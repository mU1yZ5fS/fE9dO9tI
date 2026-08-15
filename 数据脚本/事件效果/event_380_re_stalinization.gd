extends "res://数据脚本/event_script_base.gd"

## 原作 Event380.cs：罗曼诺夫宣布实施“再斯大林化”（三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - SOV_PRC_PartiesConnection → I_COMMUNICATIONS（见 event_435 约定）；
##  - 选项全部常开，无 prepare 动态改文案。

const TXT_TITLE := "罗曼诺夫宣布实施“再斯大林化”"
const TXT_DESC := "新近掌权的苏联领导人格里戈里·罗曼诺夫对国内人事进行了变动，提拔了曾任《共产党人》杂志主编的著名斯大林主义者理查德·科索拉波夫作为自己的第二书记（即苏共中央宣传鼓动部部长）\n随后，科索拉波夫立即开始对1957年遭遇镇压的斯大林主义团体实现完全平反。并在20世纪60年代后，对已定调的斯大林的个人崇拜问题再度重提。并得出了“苏共20大所发表的秘密报告犯了大错，相关指控均不存在，必须对其进行重新审视”。\n这会是新一轮的“再斯大林化”吗？"
const TXT_OPT0 := "支持苏联启动“再斯大林化”"
const TXT_OPT1 := "谴责斯大林主义的回归"
const TXT_OPT2 := "好吧......"
const TXT_R0 := "中国外交部对苏联实施“再斯大林化”的立场如下：“我们支持苏联领导层对约瑟夫·维萨里昂诺维奇·斯大林同志评价的拨乱反正。对斯大林同志在马克思主义理论上的贡献，以及他在社会主义实践中的创举应当有新研究。对斯大林同志的人生轨迹也应当实现根本的、客观的评价。”\n{1}\n{2}"
const TXT_R1 := "中国外交部对苏联实施“再斯大林化”的立场如下：“苏联领导层把历史变成了面向过去的政策，他们将一个已死去30余年的领导人又是‘打入冷宫’，又让他‘登堂入室’的行为不过是自娱自乐，不会取得任何显著成就。”\n{1}\n{2}"
const TXT_R2 := "让我们等着瞧新消息吧！\n{1}\n{2}"
const TXT_ALBANIA := "阿尔巴尼亚领导层庆祝苏联领导层彻底战胜了社会帝国主义分子与赫鲁晓夫集团，并已开始申请回归经互会与华沙条约。"
const TXT_YUGO := "在此背景下，南斯拉夫军政府领导层庆祝苏联领导层迈入了“新时代”，并寻求加入经互会与华沙条约。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var albania := ws.get_country_by_legacy_index(20)
	var yugo := ws.get_country_by_legacy_index(15)
	var china := ws.get_country_by_legacy_index(1)
	var mod6: bool = ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	if not ws.get_flag("relres") and (china != null and china.sub_government == 16 or mod6):
		d[W.I_COMMUNICATIONS] += 100
	var flag_albania := false
	if albania != null and not albania.has_tag("亲中") and albania.government != 2:
		albania.set_tag("sev", true)
		albania.set_tag("ovd", true)
		albania.set_tag("亲苏", true)
		_add(W.I_INFLUENCE, -15)
		_add_power(EmpireData.USSR, 50)
		flag_albania = true
	var flag_yugo := false
	if yugo != null and yugo.government == 0 and not yugo.has_tag("fxseu") and not yugo.has_tag("nazimao"):
		yugo.set_tag("sev", true)
		yugo.set_tag("ovd", true)
		yugo.set_tag("亲苏", true)
		if yugo.sub_government == 0:
			yugo.sub_government = 16
		_add(W.I_INFLUENCE, -15)
		_add_power(EmpireData.USSR, 50)
		flag_yugo = true
	_add_power(EmpireData.USSR, 10)
	var t_albania: String = TXT_ALBANIA if flag_albania else ""
	var t_yugo: String = TXT_YUGO if flag_yugo else ""
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0.format(["\n", t_albania, t_yugo])
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == 0:
					pol.power += 500
				elif pol != null and pol.trait_personality == 1:
					pol.loyalty -= 50
				elif pol != null and pol.trait_personality == 2:
					pol.loyalty -= 200
				elif pol != null:
					pol.loyalty -= 350
			if GameManager.is_faction_leading(0):
				_add(W.I_PARTY_SUPPORT, 300)
			else:
				_add(W.I_PARTY_SUPPORT, -300)
			_add_relation(EmpireData.USSR, 200)
			if china != null and china.has_tag("sev"):
				_add_relation(EmpireData.USSR, 200)
		1:
			context["result_text"] = TXT_R1.format(["\n", t_albania, t_yugo])
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == 0:
					pol.power -= 500
				elif pol != null and pol.trait_personality == 1:
					pol.loyalty += 50
				elif pol != null and pol.trait_personality == 2:
					pol.loyalty += 200
				elif pol != null:
					pol.loyalty += 350
			if GameManager.is_faction_leading(0):
				_add(W.I_PARTY_SUPPORT, -300)
			else:
				_add(W.I_PARTY_SUPPORT, 150)
		_:
			context["result_text"] = TXT_R2.format(["\n", t_albania, t_yugo])
			if china != null and china.has_tag("sev"):
				_add_relation(EmpireData.USSR, 200)


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta
