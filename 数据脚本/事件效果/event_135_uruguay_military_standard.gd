extends "res://数据脚本/event_script_base.gd"

## 原作 Event135.cs：军事标准（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_PROPRC_YES := "event.script.event_135_uruguay_military_standard.c0"
const TXT_PROPRC_NO := "event.script.event_135_uruguay_military_standard.c1"
const TXT_R0 := "event.script.event_135_uruguay_military_standard.c2"
const TXT_R1 := "event.script.event_135_uruguay_military_standard.c3"




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0


## Country.WantToLeave() 逐行移植（GameState.cs:7370-7394）。
## 只调整亲中/对华贸易/亲美，不整体清空联盟。
func _want_to_leave(c: CountryData) -> void:
	if c == null:
		return
	var flag := true
	var sub := c.sub_government
	if sub == 0:
		if _d(W.I_IDEOLOGY) > 2 or _d(W.I_ECON_SYSTEM) >= 13 or _d(W.I_DIPLO) < 700 or _d(W.I_PARTY_SYSTEM) >= 8:
			flag = false
	elif (sub >= 1 and sub <= 3) or sub == 8 or sub == 17:
		if _d(W.I_IDEOLOGY) > 3 or _d(W.I_ECON_SYSTEM) > 13 or _d(W.I_DIPLO) < 500:
			flag = false
	elif sub >= 4 and sub <= 6:
		var china := ws.get_country_by_legacy_index(1)
		if _d(W.I_IDEOLOGY) < 2 or _d(W.I_ECON_SYSTEM) < 13 or _d(W.I_DIPLO) > 700 or _d(W.I_PARTY_SYSTEM) < 8 or _d(W.I_PRESS_POLICY) < 18 or (china != null and china.has_tag("ovd")):
			flag = false
	elif sub >= 7:
		var china2 := ws.get_country_by_legacy_index(1)
		if _d(W.I_IDEOLOGY) == 1 or _d(W.I_ECON_SYSTEM) <= 11 or _d(W.I_DIPLO) < 300 or (china2 != null and china2.has_tag("sev")):
			flag = false
	if c.has_tag("亲中"):
		c.set_tag("对华贸易", flag)
		c.set_tag("亲中", flag)
		if c.has_tag("亲美"):
			c.set_tag("亲美", not flag)


func _proprc_suffix(c: CountryData) -> String:
	return tr(TXT_PROPRC_YES) if c.has_tag("亲中") else tr(TXT_PROPRC_NO)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uruguay := ws.get_country_by_legacy_index(82)
	if uruguay == null:
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			uruguay.next_election_year = 1980
			uruguay.next_election_month = 10
			uruguay.next_election_day = 12
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			uruguay.level_of_instability -= 10
			uruguay.level_of_development += 5
			uruguay.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			uruguay.set_tag("亲中", true)
			_want_to_leave(uruguay)
			context["result_text"] = tr(TXT_R0) + _proprc_suffix(uruguay)
		1:
			uruguay.next_election_year = 1981
			uruguay.next_election_month = 9
			uruguay.next_election_day = 1
			_add(W.I_BUDGET, -5)
			_add(W.I_AGENTS, -5)
			uruguay.level_of_instability -= 15
			uruguay.set_tag("对华贸易", true)
			_want_to_leave(uruguay)
			context["result_text"] = tr(TXT_R1) + _proprc_suffix(uruguay)
		_:
			uruguay.next_election_year = 1981
			uruguay.next_election_month = 9
			uruguay.next_election_day = 1
			uruguay.level_of_instability -= 15
			context["result_text"] = tr(TXT_R1) + _proprc_suffix(uruguay)




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_135_uruguay_military_standard.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_135",
	"num": 135,
	"priority": 13500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_135_uruguay_military_standard.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
