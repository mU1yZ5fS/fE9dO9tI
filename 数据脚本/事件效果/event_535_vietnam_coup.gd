extends "res://数据脚本/event_script_base.gd"

## 原作 Event535.cs：君子报仇，十年不晚（越南亲华派政变，2选项）。
## 触发：无自动触发（DiploButtonScript.cs:11380 外交按钮 number_event=535）。

const TXT_R0 := "一场准备不充分的政变可能会破坏我们和越南刚刚稳定的关系，更有可能彻底激怒苏联，因此，我们最好还是小心再小心......"
const TXT_R1 := "在我们的特工帮助下，越南国内的亲华派很快与越南国安部门以及军方取得了联系并制定了详细的计划，在一个平平无奇的夜晚，由我们的人组织的特别行动小组突袭了黎笋的住所。几乎没有起任何冲突，衣衫不整的黎笋就被押出自己的别墅。次日，政治局委员长征、武元甲、范文同和黎德英等人迅速召开了临时中央全会，会议以篡改胡志明主席的政治遗嘱，制造种族灭绝事件，与西方资本主义世界间谍勾结破坏社会主义建设等理由罢免了黎笋的总书记职位，而长征则被选举为新的越共中央总书记，他宣布将进一步加深与中国的合作，加快开展社会主义建设。然而，越南彻底倒向中国破坏了苏联对我国的南北合围策略，因此莫斯科方面对这场政变感到不满。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c1 := ws.get_country_by_legacy_index(1)
	var c11 := ws.get_country_by_legacy_index(11)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add_power(EmpireData.USSR, -30)
			_add_relation(EmpireData.USSR, -200)
			_set_data(171, 0)  # 原 data[171]
			if c11 != null:
				_leave_alliances(c11)
				c11.set_tag("亲中", true)
				c11.set_tag("对华贸易", true)
				_join_alliances(c11)
				if c1 != null:
					c11.sub_government = c1.sub_government
					c11.government = c1.government
				c11.prc_power = 1000
				c11.social_stability = 1000
			for c in ws.countries:
				if c.puppet_of == 11:
					c.puppet_of = GameConstants.LegacySlot.NONE
			_add(W.I_BUDGET, -40)
			_add(W.I_AGENTS, -40)
			_add(W.I_INFLUENCE, 50)
			context["result_text"] = TXT_R1
