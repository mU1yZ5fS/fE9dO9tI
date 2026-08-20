class_name WarQueries
extends RefCounted

## WarSystem 的查询与内部小工具（2026-08 门面拆分）。
## 只做纯查询/纯函数，不持有 current_world 等跨系统状态。

const W = preload("res://数据脚本/world_state.gd")

static func get_active_wars(w: WorldState) -> Array[WarData]:
	var out: Array[WarData] = []
	if w == null:
		return out
	for war in w.wars:
		if war != null and war.is_going:
			out.append(war)
	return out


static func get_mil_intervention_display(w: WorldState) -> String:
	if w == null:
		return "0.0"
	return "%.1f" % (float(w.数值表[W.I_MIL_INTERVENTION]) / 10.0)


static func wc(w: WorldState, idx: int) -> CountryData:
	return w.get_country_by_legacy_index(idx)


static func wc_name(w: WorldState, idx: int, new_name: String) -> void:
	var c := wc(w, idx)
	if c != null:
		c.name = new_name


static func clamp_war_infl(war: WarData) -> void:
	if war.infl1 > 1000 or war.infl2 < 0:
		war.infl1 = 1000
		war.infl2 = 0
	elif war.infl2 > 1000 or war.infl1 < 0:
		war.infl2 = 1000
		war.infl1 = 0
	war.infl1 = clampi(war.infl1, 0, 1000)
	war.infl2 = clampi(war.infl2, 0, 1000)
