extends "res://数据脚本/event_script_base.gd"

## 原作 Event318.cs：我们的势力会在日本掌权吗？（3选项）。
## 触发：全目录搜索无 this_num_event = 318 / Reset(318) / StartEvent(318)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：选项显隐 prepare 动态改写；Gosstroy/SubGosstroy→government/sub_government；name→chinese_name；proprc/Vyshi→亲中/亲美标签。

const TXT_NAME_EMPIRE := "日本帝国"
const TXT_NAME_RED := "赤色日本"
const TXT_OPT1_DIS := "和解不可接受。"
const TXT_OPT2_DIS := "和解不可接受。"
const TXT_R0 := "当然，日本领导层的更迭对我们有用，但不幸的是，此举会使该地区的局势不稳定，也肯定不会有什么好事发生，美国还将做出极其消极的反应。"
const TXT_R1 := "借助我们大笔的经济援助，日共成功赢得竞选，并组建了一党政府。起初，一切都非常不稳定——党派分裂，资产阶级问题，美国不愿撤军。但如今，日本正在建设社会主义，往昔日本国旗旁飘扬着星条旗的地方，现已升起了我们的红旗。"
const TXT_R2 := "夜间，日本坦克进入了东京及各大城市。第二天早上，全体日本政府成员在电视直播中被枪决。美军基地被封锁，美军也被迫撤离。受害者的人数尚未公布，但据我们的情报，受害者至多两三千。当然，新政府宣称要走向民族主义和独立，但在被国际孤立的背景下，他们被迫与我们合作，即使这对他们来说不是很愉快。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	if data.size() <= W.I_RELIGION:
		return
	var opt := event_def.options
	var japan := world.get_country_by_legacy_index(44)
	_enable(opt[0], event_def.options[0].text)
	if japan != null and japan.government < 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if data.war_support >= 700 or (data.ideology <= 0 and data.religion_policy > 27 and data.econ_system > 11):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_DIPLO, 100)
			_add(W.I_INFLUENCE, 100)
			_add_power(0, -100)
			_add_relation(0, -500)
			var japan := ws.get_country_by_legacy_index(44)
			if japan != null:
				japan.government = GameConstants.Government.SOCIALIST
				japan.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				japan.chinese_name = TXT_NAME_RED
				japan.set_tag("亲中", true)
				japan.set_tag("亲美", false)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -150)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_DIPLO, 50)
			_add(W.I_INFLUENCE, 100)
			_add_power(0, -100)
			_add_relation(0, -500)
			var japan := ws.get_country_by_legacy_index(44)
			if japan != null:
				japan.government = GameConstants.Government.AUTHORITARIAN
				japan.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				japan.chinese_name = TXT_NAME_EMPIRE
				japan.set_tag("亲中", true)
				japan.set_tag("亲美", false)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -150)
			context["result_text"] = TXT_R2

	

