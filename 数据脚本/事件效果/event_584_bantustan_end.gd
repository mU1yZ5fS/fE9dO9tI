extends "res://数据脚本/event_script_base.gd"

## 原作 Event584.cs：班达斯坦的终结（马拉维，单选项）。
## 触发：DiploButtonScript.cs:11708 —— number_event = 584（外交按钮手动触发），无自动触发。
## 差异：
##  - Gosstroy → government；completedDecisions[7] → ws.decisions.completed[7]；
##  - Torg → 对华贸易；proprc → 亲中。




const TXT_R0_A := "在非盟的协调下，莫桑比克，赞比亚和坦桑尼亚地区开始对马拉维进行军事行动。这一次，没有了罗德西亚的帮助，"
const TXT_R0_SA := "就算是白人南非部队都无法帮助马拉维。"
const TXT_R0_OTHER := "谁都无法帮助被包围的马拉维。"
const TXT_R0_MID_A := "很快，三国联军便将马拉维全境彻底占领，马拉维民主共和国成立，由LESOMA担任执政党。LESOMA上台之后，便宣布实行泛非的、马列主义的社会主义，加入非盟并实行类似乌贾马的合作化运动和工厂国有化运动，"
const TXT_R0_BREAK := "与台湾当局断交并"
const TXT_R0_MID_B := "与我们重新建交，将马拉维大会党及其准军事组织马拉维少先队进行强制解散，高层被关入大牢，班达本人则以反革命罪，叛国罪，镇压反对派等罪名被处以死刑，其私人财产则被充公。由于马拉维经济发展落后，非盟和我国开始为马拉维提供一笔发展资金，用以建造发电厂，发展教育等。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c131 := ws.get_country_by_legacy_index(131)
	var c38 := ws.get_country_by_legacy_index(38)
	var c125 := ws.get_country_by_legacy_index(125)
	var text := TXT_R0_A
	if c131 != null and c131.government == GameConstants.Government.AUTHORITARIAN:
		text += TXT_R0_SA
	else:
		text += TXT_R0_OTHER
	text += TXT_R0_MID_A
	var break_cond := c38 != null and c38.government == GameConstants.Government.AUTHORITARIAN and ws.decisions != null \
			and ws.decisions.completed.size() > 7 and not ws.decisions.completed[7]
	if break_cond:
		text += TXT_R0_BREAK
	text += TXT_R0_MID_B
	_add(W.I_BUDGET, -50)
	if c125 != null:
		c125.government = GameConstants.Government.SOCIALIST
		c125.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		_leave_alliances(c125)
		c125.set_tag("亲中", true)
		c125.set_tag("对华贸易", true)
	ws.influence_prc += 20
	_add(W.I_DIPLO, 15)
	context["result_text"] = text
