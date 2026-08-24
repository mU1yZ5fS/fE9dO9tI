extends "res://数据脚本/event_script_base.gd"

## 原作 Event500.cs：非洲的新生（非洲联盟建立）。
## 触发：原版走 Decision 系统（GlobalScript.cs:56 的 HasRevolutionaryLeader/HasMoney/
## HasArmy/IsChineseInfluenceLessThan/IsAfricanProprc/IsAfricanSocialism/AfricanAlliance 链）。
## Godot 决议界面移植说明，事件本体按手动事件（trigger_conditions 空）移植；
## 入口暂由外交面板对原版序号 61（上沃尔特/布基纳法索）的 story action 调用
## game.start_event("african_union")，条件与上述 Decision 链逐项一致。
## 效果逐字对齐 Event500.cs ResultsOfEvents(result_num==0)。
## result_num==5 为空结果，Godot 不建无效果选项。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", 0))
	if opt != 0:
		return

	# 创始成员国（Event500.cs:125-132）
	for legacy_idx in [68, 63, 127, 114, 122, 124, 61]:
		var founder := ws.get_country_by_legacy_index(legacy_idx)
		if founder != null:
			founder.set_tag("au", true)

	# 符合社会主义/亲中/范围条件的国家全部加入（Event500.cs:133-140）
	for c in ws.countries:
		if c == null or c.has_tag("ovd") or c.has_tag("sev"):
			continue
		if not ws.is_socialism(c, true):
			continue
		if c.sub_government == GameConstants.SubGovernment.SOVIET_STYLE or c.sub_government == GameConstants.SubGovernment.TROTSKYIST:
			continue
		if not c.has_tag("亲中"):
			continue
		if not _in_au_range(c.原版序号, c):
			continue
		c.set_tag("au", true)

	# 代价与全局影响（Event500.cs:141-148）
	if d.size() > W.I_BUDGET:
		d.budget -= 300
	if d.size() > W.I_ARMY:
		d.army -= 300
	if ws.empires.size() > EmpireData.USA:
		ws.empires[EmpireData.USA].relations -= 100
		ws.empires[EmpireData.USA].power = clampi(ws.empires[EmpireData.USA].power - 200, 0, 1000)
	if ws.empires.size() > EmpireData.USSR:
		ws.empires[EmpireData.USSR].relations -= 100
		ws.empires[EmpireData.USSR].power = clampi(ws.empires[EmpireData.USSR].power - 200, 0, 1000)
	ws.influence_prc += 100

	# 项目惯例：概览/国家面板读 global_flags.event_done_500（国家面板.gd:983 等）。
	ws.set_flag("event_done_500", true)
	ws.set_flag("result_500", 0)

	context["result_title"] = tr("event.script.event_500_african_union.i0")
	context["result_text"] = tr("event.script.event_500_african_union.i1")


## Event500.cs:138 的 id 范围：41/42/52/56-68/99(parts[0])/100(parts[0])/106-108/112-133(!=128)/150/153/155/158
func _in_au_range(legacy_idx: int, c: CountryData) -> bool:
	if legacy_idx == 41 or legacy_idx == 42 or legacy_idx == 52:
		return true
	if legacy_idx >= 56 and legacy_idx <= 68:
		return true
	if legacy_idx == 99 or legacy_idx == 100:
		return c.parts.size() > 0 and c.parts[0]
	if legacy_idx >= 106 and legacy_idx <= 108:
		return true
	if legacy_idx >= 112 and legacy_idx <= 133 and legacy_idx != 128:
		return true
	if legacy_idx == 150 or legacy_idx == 153 or legacy_idx == 155 or legacy_idx == 158:
		return true
	return false



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_500_african_union.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "african_union",
	"num": 500,
	"priority": 50000,
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
