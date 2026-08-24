extends "res://数据脚本/event_script_base.gd"

## 原作 Event132.cs：主爱圣三一（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_PROPRC_YES := "event.script.event_132_bolivia_democratic.c0"
const TXT_PROPRC_NO := "event.script.event_132_bolivia_democratic.c1"
const TXT_R0 := "event.script.event_132_bolivia_democratic.c2"
const TXT_R1 := "event.script.event_132_bolivia_democratic.c3"
const TXT_R2 := "event.script.event_132_bolivia_democratic.c4"




func _proprc_suffix(c: CountryData) -> String:
	return tr(TXT_PROPRC_YES) if c.has_tag("亲中") else tr(TXT_PROPRC_NO)


func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0


## Country.WantToLeave() 逐行移植（GameState.cs:7370-7394）。
## 原版 Event132 设 proprc=true 后调 WantToLeave，不是 LeaveAlliances。
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
		if _d(W.I_IDEOLOGY) < 2 or _d(W.I_ECON_SYSTEM) < 13 or _d(W.I_DIPLO) > 700 \
				or _d(W.I_PARTY_SYSTEM) < 8 or _d(W.I_PRESS_POLICY) < 18 \
				or (china != null and china.has_tag("ovd")):
			flag = false
	elif sub >= 7:
		var china2 := ws.get_country_by_legacy_index(1)
		if _d(W.I_IDEOLOGY) == 1 or _d(W.I_ECON_SYSTEM) <= 11 or _d(W.I_DIPLO) < 300 \
				or (china2 != null and china2.has_tag("sev")):
			flag = false
	if c.has_tag("亲中"):
		c.set_tag("对华贸易", flag)
		c.set_tag("亲中", flag)
		if c.has_tag("亲美"):
			c.set_tag("亲美", not flag)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var bolivia := ws.get_country_by_legacy_index(72)
	if bolivia == null:
		return
	var ev130 := int(ws.completed_event_ids.get("event_130", 0))
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if ev130 == 1 and bolivia.sub_government == GameConstants.SubGovernment.SOCIAL_DEMOCRAT:
				_add(W.I_BUDGET, -25)
				_add(W.I_AGENTS, -25)
				bolivia.level_of_instability -= 5
				bolivia.level_of_development += 10
				bolivia.set_tag("亲中", true)
				bolivia.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				_want_to_leave(bolivia)
				# 原作 Event132.cs:37：iron_and_blood → achievements.Set(90)
				Achievements.set_achievement(90)
				context["result_text"] = tr(TXT_R0) + _proprc_suffix(bolivia)
			else:
				bolivia.level_of_instability -= 15
				bolivia.set_tag("亲中", false)
				bolivia.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				context["result_text"] = tr(TXT_R2) + _proprc_suffix(bolivia)
		1:
			if ev130 == 0 and bolivia.sub_government == GameConstants.SubGovernment.MODERATE:
				_add(W.I_BUDGET, -25)
				_add(W.I_AGENTS, -25)
				bolivia.level_of_instability -= 25
				bolivia.level_of_development -= 10
				bolivia.set_tag("亲中", true)
				bolivia.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				_want_to_leave(bolivia)
				context["result_text"] = tr(TXT_R1) + _proprc_suffix(bolivia)
			else:
				bolivia.level_of_instability -= 15
				bolivia.set_tag("亲中", false)
				bolivia.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				context["result_text"] = tr(TXT_R2) + _proprc_suffix(bolivia)
		_:
			bolivia.level_of_instability -= 15
			bolivia.set_tag("亲中", false)
			bolivia.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			context["result_text"] = tr(TXT_R2) + _proprc_suffix(bolivia)
	bolivia.government = GameConstants.Government.LIBERAL
	bolivia.next_election_year = 1986
	bolivia.next_election_month = 8
	bolivia.next_election_day = 6




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_132_bolivia_democratic.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_132",
	"num": 132,
	"priority": 13200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_132_bolivia_democratic.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
