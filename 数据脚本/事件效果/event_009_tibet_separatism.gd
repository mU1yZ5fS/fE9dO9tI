extends "res://数据脚本/event_script_base.gd"

## 原作 Event9.cs：西藏的分离主义。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10095（manpower<=400 && !completedDecisions[2] && !completedDecisions[1]
##    && tibet_policy==0 && !event_done[9] && !is_gkchp && !IndOpp）。端口：
##    manpower<=400 + DECISION_DONE 取反(1,2) + tibet_policy==0；fire_only_once=true 表达
##    !event_done[9]；is_gkchp/IndOpp 端口无对应 → 视为恒真（默认状态）。
##  - allcountries[69].dev=0：端口无 dev 字段 → 用 development 近似（原 dev 为发展度标志）。
##  - allcountries[69].prosov：端口标签体系 → set_tag("亲苏", false)。
##  - opt1 的 data.territory_policy++：官方版 DLL 反编译证实为 ref 真实写入
##    （tmp_Event9.cs:120-124），旧转储 ptr 模式系反编译伪影。选项1-3 的数值效果
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
	context["result_text"] = tr("event.script.event_009_tibet_separatism.i0")


# 选项1：给予他们更多自治权（Event9.cs case 1，官方 IL 逐条）
func _opt_autonomy(_context: Dictionary) -> void:
	d.thought_freedom += 70
	d.manpower -= 20
	d.party_support -= 200
	# 官方版 DLL 反编译（tmp_Event9.cs:120-124）证实 data[18]++ 为 ref 真实写入。
	d.territory_policy += 1


# 选项2：派部队去恢复秩序（Event9.cs case 2，官方 IL 逐条）
func _opt_crackdown(_context: Dictionary) -> void:
	d.thought_freedom += 50
	d.manpower += 30
	d.people_support -= 100
	d.army -= 100
	d.diplomatic_reputation += 50


# 选项3：顺水推舟，举行主权公投（Event9.cs case 3，官方 IL 逐条）
func _opt_referendum(_context: Dictionary) -> void:
	d.thought_freedom += 30
	d.manpower += 20
	d.people_support -= 20
	d.agents -= 50
	d.budget -= 40



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_009_tibet_separatism.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "tibet_separatism",
	"num": 9,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "manpower", "v": 400}, {"t": "NOT", "c": [{"t": "DECISION_DONE", "key": "1"}]}, {"t": "NOT", "c": [{"t": "DECISION_DONE", "key": "2"}]}, {"t": "RESOURCE_EQUALS", "key": "tibet_policy"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_MOST", "key": "territory", "v": 22}, "fx": [{"t": "ADD_RESOURCE", "key": "thought_freedom", "v": 70}, {"t": "ADD_RESOURCE", "key": "manpower", "v": -20}, {"t": "ADD_RESOURCE", "key": "party_support", "v": -200}]}, {"disabled": true, "result": true, "cond": {"t": "ANY", "c": [{"t": "RESOURCE_NOT_EQUALS", "key": "political_line", "v": 4}, {"t": "RESOURCE_AT_LEAST", "key": "army", "v": 100}]}, "fx": [{"t": "ADD_RESOURCE", "key": "thought_freedom", "v": 50}, {"t": "ADD_RESOURCE", "key": "manpower", "v": 30}, {"t": "ADD_RESOURCE", "key": "people_support", "v": -100}, {"t": "ADD_RESOURCE", "key": "army", "v": -100}, {"t": "ADD_RESOURCE", "key": "diplo", "v": 50}]}, {"disabled": true, "result": true, "cond": {"t": "ANY", "c": [{"t": "RESOURCE_SUM_AT_LEAST", "v": 40, "keys": ["money", "reserve"]}, {"t": "RESOURCE_AT_LEAST", "key": "reserve", "v": 40}, {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 50}]}, "fx": [{"t": "ADD_RESOURCE", "key": "thought_freedom", "v": 30}, {"t": "ADD_RESOURCE", "key": "manpower", "v": 20}, {"t": "ADD_RESOURCE", "key": "people_support", "v": -20}, {"t": "ADD_RESOURCE", "key": "agents", "v": -50}, {"t": "ADD_RESOURCE", "key": "money", "v": -40}]}],
}
