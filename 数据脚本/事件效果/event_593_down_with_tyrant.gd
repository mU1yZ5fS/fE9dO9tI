extends "res://数据脚本/event_script_base.gd"

## 原作 Event593.cs：打倒暴君才有自由和平（多哥革命，单选项）。
## 触发：DiploButtonScript.cs:11720 —— number_event = 593（外交按钮手动触发），无自动触发。
## 差异：
##  - event_done[500] → ws.completed_event_ids.has("event_500")；
##  - name → chinese_name；EstablishGovernment(ProChina) → 亲中 true、亲苏/亲美 false；
##  - Torg → 对华贸易；soc_stab → social_stability；
##  - JoinAllOurAlliances(true) → 基类 _join_alliances。




const TXT_R0_A := "他们的行动是成功的。凌晨，一小伙工人民兵和空降部队越过加纳边境，借道攻进了洛美。他们和总统卫队发生了交火，埃亚德马在试图逃离总统府的路上被击毙。一枚火箭弹打中了他的座驾，烈火瞬间吞噬了他。多哥人民联盟的总书记也在袭击中遇刺身亡。很快，一场夺权运动在多哥共产党的领导下展开了。多亏了先前的布局，基层士兵拒绝对人民开火，而工人武装很快就建立了起来。在贝宁和加纳武装部队的帮助下，内战得以幸免。多哥共产党正式宣布多哥为“以马克思列宁主义，毛泽东思想为指导的人民共和国”，并宣布在多哥开展一场民族民主革命。泛非社会主义党的左派被吸纳入多哥共产党的预备党员，其余则被改组为多哥爱国主义阵线，成为了官方的统战组织。革命的内容包括彻底清算埃亚德马的毒草，同时大量的强制征收了外国资本的实业公司。以及更为公平的农村—城市发展计划。\n该国宣布对我国友好，"
const TXT_R0_DONE := "并积极宣布将投身于非洲的革命斗争与解放"
const TXT_R0_NOT := "并愿意深化与我们的合作关系。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c108 := ws.get_country_by_legacy_index(108)
	var text := TXT_R0_A
	if ws.completed_event_ids.has("event_500"):
		text += TXT_R0_DONE
	else:
		text += TXT_R0_NOT
	_add(W.I_BUDGET, -80)
	_add(W.I_AGENTS, -80)
	if c108 != null:
		c108.government = GameConstants.Government.SOCIALIST
		c108.sub_government = GameConstants.SubGovernment.MAOIST
		c108.chinese_name = "多哥人民共和国"
		_leave_alliances(c108)
		_establish_prochina(c108)
		c108.set_tag("对华贸易", true)
		c108.social_stability = 1000
		_join_alliances(c108)
	context["result_text"] = text


func _establish_prochina(c: CountryData) -> void:
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)
