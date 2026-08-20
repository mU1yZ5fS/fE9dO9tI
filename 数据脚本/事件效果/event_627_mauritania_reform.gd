extends "res://数据脚本/event_script_base.gd"

## 原作 Event627.cs：伊斯兰、民族、宪政和社会主义民主！（毛里塔尼亚社会改造，单选项）。
## 触发：DiploButtonScript.cs:11770 —— 外交按钮 1032，selected_country==59（毛里塔尼亚），
##   入口扣 data.budget-=150、data.agents-=100（在 _def_1032 中已移植），随后 StartEvent(627)。
## 本 .tres trigger_conditions 为空：仅由外交按钮手动触发，不进自动扫描。

const TXT_R0 := "在西非各人民民主的泛非政权和非洲革命联盟的支持及我们的压力下，达达赫开始着手改组毛里塔尼亚人民党——在剔除党内右派和保守势力后，人民党同毛里塔尼亚劳动党和进步工人联盟等左翼力量合并为毛里塔尼亚劳动人民党，新的党章中写入了科学社会主义和泛非主义的内容，并保留了来自劳动党的部分涉及马列主义和毛泽东思想的词条。来自劳动党的易卜拉希马·莫克塔尔·萨尔当选为总书记，莫克塔尔·乌尔德·达达赫当选为党主席。\n改组后的执政党和政府开始在非洲革命联盟的帮助下对奴隶制和部族主义政治进行改革，并动员激进的学生和工人参与政治，以对社会上的保守势力进行打击。在经济上，毛塔政府决定对外资（特别是来自法国的）进行国有化，并开展土地改革和农业合作化试点。在非革盟的积极运作下，毛塔和萨赫勒各国也开始组织萨赫勒荒漠化共同对策委员会，来改善萨赫勒地区的环境。非革盟和我们的援助在进入这个国家，助力其工业化和社会改造。属于毛塔的摩尔人和黑人的将是平等而美好的未来！"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(59)  # 毛里塔尼亚
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if c != null:
				c.government = GameConstants.Government.SOCIALIST
				c.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c)
				c.set_tag("对华贸易", true)
				c.set_tag("亲中", true)
				c.chinese_name = "毛里塔尼亚民主共和国"
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -100)  # 原 :38-39 两次 -50
			_add_power(EmpireData.USA, -20)
