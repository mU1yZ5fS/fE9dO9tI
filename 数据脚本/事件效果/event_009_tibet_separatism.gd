extends "res://数据脚本/event_script_base.gd"

## 原作 Event9.cs：西藏的分离主义。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10095（manpower<=400 && !completedDecisions[2] && !completedDecisions[1]
##    && tibet_policy==0 && !event_done[9] && !is_gkchp && !IndOpp）。端口：
##    manpower<=400 + DECISION_DONE 取反(1,2) + tibet_policy==0；fire_only_once=true 表达
##    !event_done[9]；is_gkchp/IndOpp 端口无对应 → 视为恒真（默认状态）。
##  - allcountries[69].dev=0：端口无 dev 字段 → 用 development 近似（原 dev 为发展度标志）。
##  - allcountries[69].prosov：端口标签体系 → set_tag("亲苏", false)。
##  - opt1 的 data[18]++：反编译为死代码（ptr 局部自增未写回 data），跳过。


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
		d[W.I_POPULATION] -= 31
	if d.size() > W.I_AGRICULTURE:
		d[W.I_AGRICULTURE] -= 50
	if d.size() > W.I_INDUSTRY:
		d[W.I_INDUSTRY] -= 10
	if d.size() > W.I_MANPOWER:
		d[W.I_MANPOWER] -= 50
	if d.size() > W.I_PARTY_SUPPORT:
		d[W.I_PARTY_SUPPORT] -= 200
	if d.size() > W.I_PEOPLE_SUPPORT:
		d[W.I_PEOPLE_SUPPORT] -= 200
	if d.size() > W.I_POPULATION:
		d[W.I_POPULATION] -= 31   # 原版重复两次 -=31，逐字复刻
	var tibet := ws.get_country_by_legacy_index(69)
	if tibet != null:
		tibet.development = 0      # 差异：原 dev=0
		tibet.set_tag("亲苏", false)  # 差异：原 prosov=false
	var usa := ws.get_country_by_legacy_index(1)
	var low_ideology: bool = d.size() > W.I_IDEOLOGY and d[W.I_IDEOLOGY] <= 3
	if d.size() > W.I_TIBET_POLICY:
		d[W.I_TIBET_POLICY] = 1 if low_ideology else 2
	var use_part8: bool = d.size() > 62 and d[62] >= 2   # 原 data[62]（无端口命名键）
	if usa != null:
		if use_part8:
			usa.parts.resize(9)
			usa.parts[8] = true
		else:
			usa.parts.resize(8)
			usa.parts[7] = true
	if low_ideology and tibet != null:
		tibet.government = 3
		tibet.sub_government = 6
	context["result_text"] = "西藏自治区正式宣布以它1950年的边界独立。这对我们来说是一个巨大的打击，对苏联和美国来说却是一个巨大的机遇。"
