extends "res://数据脚本/event_script_base.gd"

## 原作 Event10.cs：新疆的分离主义。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10089（manpower<=300 && !completedDecisions[4] && !completedDecisions[3]
##    && xinjiang_policy==0 && !event_done[10] && !is_gkchp && !IndOpp）。端口：
##    manpower<=300 + DECISION_DONE 取反(3,4) + xinjiang_policy==0；fire_only_once=true 表达
##    !event_done[10]；is_gkchp/IndOpp 端口无对应 → 视为恒真（默认状态）。
##  - allcountries[70].dev=0：端口无 dev 字段 → 用 development 近似。
##  - allcountries[12].proprc / allcountries[70].prosov：端口标签体系 → has_tag("亲中")/set_tag("亲苏")。
##  - allcountries[12].proprc / allcountries[70].prosov：端口标签体系 → has_tag("亲中")/set_tag("亲苏")。
##  - opt1 的 data.territory_policy++：官方版 DLL 反编译证实为 ref 真实写入
##    （tmp_Event10.cs:107-111），旧转储 ptr 模式系反编译伪影。选项1-3 的数值效果
##    此前整块缺失，已按官方 IL（case1/2/3）逐条补齐。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	match int(context.get("option_index", -1)):
		0:
			_opt_independent(context)
		1:
			_opt_autonomy(context)
		2:
			_opt_crackdown(context)
		3:
			_opt_referendum(context)


# 选项0：我们管不着啊（Event10.cs result 0：新疆独立）
func _opt_independent(context: Dictionary) -> void:
	ws.influence_prc -= 250
	if d.size() > W.I_POPULATION:
		d.population -= 218
	if d.size() > W.I_AGRICULTURE:
		d.agriculture -= 50
	if d.size() > W.I_INDUSTRY:
		d.industry -= 10
	if d.size() > W.I_MANPOWER:
		d.manpower -= 50
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support -= 200
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 200
	if d.size() > W.I_POPULATION:
		d.population -= 218   # 原版重复两次 -=218，逐字复刻
	var xinjiang := ws.get_country_by_legacy_index(70)
	if xinjiang != null:
		xinjiang.development = 0    # 差异：原 dev=0
	var usa := ws.get_country_by_legacy_index(1)
	var soviet_puppet_mongolia: bool = _mongolia_condition()
	if d.size() > W.I_XINJIANG_POLICY:
		d.xinjiang_policy = 1 if soviet_puppet_mongolia else 2
	if usa != null:
		usa.parts.resize(10)
		usa.parts[9] = true
	if xinjiang != null:
		if soviet_puppet_mongolia:
			xinjiang.government = GameConstants.Government.SOCIALIST
			xinjiang.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			xinjiang.set_tag("亲苏", true)    # 差异：原 prosov=true
		else:
			xinjiang.set_tag("亲苏", false)   # 差异：原 prosov=false
	context["result_text"] = "新疆维吾尔自治区正式宣布独立。这对我们来说是一个巨大的打击，对苏联和美国来说却是一个巨大的机遇。"


# 选项1：给予他们更多自治权（Event10.cs case 1，官方 IL 逐条）
func _opt_autonomy(_context: Dictionary) -> void:
	d.thought_freedom += 70
	d.manpower -= 20
	d.party_support -= 200
	# 官方版 DLL 反编译（tmp_Event10.cs:107-111）证实 data[18]++ 为 ref 真实写入。
	d.territory_policy += 1


# 选项2：派部队去恢复秩序（Event10.cs case 2，官方 IL 逐条）
func _opt_crackdown(_context: Dictionary) -> void:
	d.thought_freedom += 50
	d.manpower += 30
	d.people_support -= 100
	d.army -= 100
	d.diplomatic_reputation += 50


# 选项3：顺水推舟，举行主权公投（Event10.cs case 3，官方 IL 逐条）
func _opt_referendum(_context: Dictionary) -> void:
	d.thought_freedom += 30
	d.manpower += 20
	d.people_support -= 20
	d.agents -= 50
	d.budget -= 40


# Event10.cs result 0 分支条件：!allcountries[12].proprc && !ingamewars[5].is_going && Gosstroy!=0
func _mongolia_condition() -> bool:
	var mongolia := ws.get_country_by_legacy_index(12)
	if mongolia == null:
		return false
	if mongolia.has_tag("亲中"):
		return false
	if ws.wars.size() > 5 and ws.wars[5].is_going:
		return false
	return mongolia.government != GameConstants.Government.AUTHORITARIAN
