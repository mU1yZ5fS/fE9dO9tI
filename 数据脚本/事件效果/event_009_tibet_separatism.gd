extends "res://数据脚本/event_script_base.gd"

## 原作 Event9.cs：西藏的分离主义。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10095（manpower<=400 && !completedDecisions[2] && !completedDecisions[1]
##    && tibet_policy==0 && !event_done[9] && !is_gkchp && !IndOpp）。端口：
##    manpower<=400 + DECISION_DONE 取反(1,2) + tibet_policy==0；fire_only_once=true 表达
##    !event_done[9]；is_gkchp/IndOpp 端口无对应 → 视为恒真（默认状态）。
##  - allcountries[69].dev=0：端口无 dev 字段 → 用 development 近似（原 dev 为发展度标志）。
##  - allcountries[69].prosov：端口标签体系 → set_tag("亲苏", false)。
##  - opt1 的 data.territory_policy++：反编译为死代码（ptr 局部自增未写回 data），跳过。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if int(context.get("option_index", -1)) != 0:
		return
	_opt_independent(context)


# 选项0：我们管不着啊（Event9.cs result 0：西藏独立）
func _opt_independent(context: Dictionary) -> void:
	ws.influence_prc -= 250
	if d.size() > W.I_POPULATION:
		d.population -= 31
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
		d.population -= 31   # 原版重复两次 -=31，逐字复刻
	var tibet := ws.get_country_by_legacy_index(69)
	if tibet != null:
		tibet.development = 0      # 差异：原 dev=0
		tibet.set_tag("亲苏", false)  # 差异：原 prosov=false
	var usa := ws.get_country_by_legacy_index(1)
	var low_ideology: bool = d.size() > W.I_IDEOLOGY and d.ideology <= 3
	if d.size() > W.I_TIBET_POLICY:
		d.tibet_policy = 1 if low_ideology else 2
	var use_part8: bool = d.size() > W.I_ARUNACHAL_STATUS and d.arunachal_status >= 2   # 原 data.arunachal_status
	if usa != null:
		if use_part8:
			usa.parts.resize(9)
			usa.parts[8] = true
		else:
			usa.parts.resize(8)
			usa.parts[7] = true
	if low_ideology and tibet != null:
		tibet.government = GameConstants.Government.LIBERAL
		tibet.sub_government = GameConstants.SubGovernment.LIBERAL
	context["result_text"] = "西藏自治区正式宣布以它1950年的边界独立。这对我们来说是一个巨大的打击，对苏联和美国来说却是一个巨大的机遇。"
