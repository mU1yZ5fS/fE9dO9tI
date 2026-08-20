extends "res://数据脚本/event_script_base.gd"

## 原作 Event592.cs：再无“非洲奇迹”（科特迪瓦革命，单选项）。
## 触发：DiploButtonScript.cs:11726 —— number_event = 592（外交按钮手动触发），无自动触发。
## 差异：
##  - EstablishGovernment(ProChina) → 亲中 true、亲苏/亲美 false；Torg → 对华贸易；
##  - JoinAllOurAlliances(true) → 基类 _join_alliances。




const TXT_R0 := "三国组建了一支统一调度的武装部队，代号“象牙”的行动一触即发。在得到阿比让的信息之后，三军从北，西和东方攻入了这个小国。加纳人民军迅速开入了阿比让内，在科国内的象牙海岸革命共产党的帮助下顺利攻占了首都总统府和广播电台，号召全体人民起义，夺权，彻底革命。与此同时几内亚和布基纳法索的武装力量攻入了亚穆克苏罗，来不及为城中的巨大教堂感到震惊，他们还需要快速的南下和加纳会师。而法国和美国拒绝武装介入这一问题。仅仅是谴责了三国的暴力行为，提供了除干涉外的一切帮助。\n随后，博瓦尼被宣判有战争罪，蓄意谋杀罪，种族灭绝罪而被判处死刑。象牙海岸革命共产党正式成为了该国的领导力量。不久以后该党便出台了执政纲领“社会主义与科特迪瓦”。宣布要以马克思列宁主义的为指导，毛泽东思想为武器，建立巩固和保卫社会主义科特迪瓦。大量的种植园从私人名义被转为公有，而一直被打压的工会也得到了一定的自主权。同时大量的法国和美国矿冶企业也被查收。在偏远的地区，建立新首都的工程也被暂时叫停，和平圣母大教堂中的宗教元素则被摘除。该建筑则被用于作为集会和纪念馆。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c64 := ws.get_country_by_legacy_index(64)
	_add(W.I_BUDGET, -80)
	_add(W.I_AGENTS, -80)
	if c64 != null:
		c64.government = GameConstants.Government.SOCIALIST
		c64.sub_government = GameConstants.SubGovernment.MAOIST
		_leave_alliances(c64)
		_establish_prochina(c64)
		c64.set_tag("对华贸易", true)
		_join_alliances(c64)
	context["result_text"] = TXT_R0


func _establish_prochina(c: CountryData) -> void:
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)
