extends "res://数据脚本/event_script_base.gd"

## 原作 Event16.cs：泰国大选。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10155（日期>=1976.4 且 !event_done[16]）。
##  - data.thailand_election_intervention=100（泰国选举干预标志）：端口无命名键 → 数字索引直访。
##  - party_change[0]=0.5f / party_change[2]=1f（派系支持缓冲）：端口无等价 → 跳过。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 1:
		_opt_support_cpt(context)
	elif opt == 2:
		_opt_arms(context)


# 选项1：支持泰国共产党（Event16.cs result 1）
func _opt_support_cpt(context: Dictionary) -> void:
	if d.size() > W.I_AGENTS:
		d.agents -= 20
	if d.size() > W.I_BUDGET:
		d.budget -= 10
	ws.influence_prc += 5
	if d.size() > 41:
		d.thailand_election_intervention = 100   # 原 data.thailand_election_intervention（泰国选举干预标志，无端口命名键）
	context["result_text"] = tr("event.script.event_016_thailand_elections.i0")


# 选项2：让选举见鬼去吧！（Event16.cs result 2）
func _opt_arms(context: Dictionary) -> void:
	if d.size() > W.I_ARMY:
		d.army -= 20
	ws.influence_prc += 10
	context["result_text"] = tr("event.script.event_016_thailand_elections.i1")



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_016_thailand_elections.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "thailand_elections",
	"num": 16,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1976.4"}],
	"options": [{"result": true, "fx": [{"t": "ADD_EMPIRE_POWER", "key": "0", "v": 5}]}, {"disabled": true, "cond": {"t": "ANY", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 20}, {"t": "COUNTRY_FIELD_EQUALS", "key": "stab", "v": 1, "target": "34"}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "army", "v": 20}, {"t": "RESOURCE_NOT_EQUALS", "key": "political_line", "v": 4}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
