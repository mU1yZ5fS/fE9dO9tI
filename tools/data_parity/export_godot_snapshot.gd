# =============================================================================
# Godot 侧数据快照导出器（数据对齐工具链 第 2/3 步）
# =============================================================================
# 调用真实的 WorldFactory.create_world() 构建各难度下的初始世界，
# 把最终状态序列化为 JSON，供 diff_snapshots.py 与原版快照比对。
# 走真实构建管线 = 内嵌常量、JSON 数据、开局覆盖、FixSubs 全部生效。
#
# 运行（项目根目录）:
#   Godot_v4.7-stable_win64.exe --headless --path . \
#     --script res://tools/data_parity/export_godot_snapshot.gd
# =============================================================================
extends SceneTree

const OUT_DIR := "res://tools/data_parity/snapshots/godot"
const DIFFICULTIES := [0, 1, 2, 3, 4]
const PLAYER_GWCODE := 710
const DATA_DUMP_SIZE := 200


func _initialize() -> void:
	var wf: Object = load("res://数据脚本/factory/world_factory.gd")
	if wf == null:
		push_error("无法加载 world_factory.gd")
		quit(3)
		return

	DirAccess.make_dir_recursive_absolute(OUT_DIR)

	for diff: int in DIFFICULTIES:
		var ws: Resource = wf.create_world(PLAYER_GWCODE, diff)
		var dump := {
			"difficulty": diff,
			"data": _dump_data(ws),
			"countries": _dump_countries(ws),
			"politicians": _dump_politicians(ws),
			"leader": _dump_leader(ws),
			"factions": _dump_factions(ws),
			"modifiers_active": _dump_modifiers(ws),
			"positions": ws.politics_positions.duplicate(),
			"science_unlocked": ws.techs.unlocked.duplicate(),
		}
		var path := "%s/diff_%d.json" % [OUT_DIR, diff]
		var f := FileAccess.open(path, FileAccess.WRITE)
		f.store_string(JSON.stringify(dump, "\t", false))
		f.close()
		print("已写出 ", path)

	print("GODOT_SNAPSHOT_OK")
	quit(0)


func _dump_data(ws: Resource) -> Array:
	var out: Array = []
	for i in DATA_DUMP_SIZE:
		out.append(ws.get_data_by_index(i))
	return out


func _dump_countries(ws: Resource) -> Dictionary:
	var out := {}
	for c in ws.countries:
		var tags: Dictionary = {}
		for k in c.tags:
			if c.tags[k]:
				tags[str(k)] = true
		out[int(c.原版序号)] = {
			"tags": tags,
			"stab_file12": c.stability,
			"dev": c.development,
			"sovpower": c.sov_power,
			"usapower": c.usa_power,
			"prcpower": c.prc_power,
			"government": c.government,
			"sub_government": c.sub_government,
			"level_of_dev": c.level_of_development,
			"level_of_unstab": c.level_of_instability,
			"election_day": c.next_election_day,
			"election_month": c.next_election_month,
			"election_year": c.next_election_year,
			"puppet_of": c.puppet_of,
			"africa_off": c.禁用非洲机制,
			"special": c.special,
			"influence_china": c.influence_china,
			"influence_nato": c.influence_nato,
			"prc_influence": c.prc_influence,
			"social_stability": c.social_stability,
			"parts_size": c.parts.size(),
			"parts_true": _true_indices(c.parts),
			"special_ending": c.special_ending,
		}
	return out


func _true_indices(parts: Array) -> Array:
	var out: Array = []
	for i in parts.size():
		if parts[i]:
			out.append(i)
	return out


func _dump_politicians(ws: Resource) -> Array:
	var out: Array = []
	for i in ws.politicians.size():
		var p: Resource = ws.politicians[i]
		out.append({
			"slot": i,
			"name_display": p.name_display,
			"name_first": p.get("name_first"),
			"name_last": p.get("name_last"),
			"age": p.age,
			"power": p.power,
			"loyalty": p.loyalty,
			"faction": p.faction,
			"wanted_position": p.wanted_position,
			"trait_personality": p.trait_personality,
			"trait_alignment": p.trait_alignment,
			"trait_special": p.trait_special,
			"trait_background": p.trait_background,
			"entry_year": p.entry_year,
		})
	return out


func _dump_leader(ws: Resource) -> Dictionary:
	var l: Resource = ws.leader
	return {
		"name_display": l.name_display,
		"name_first": l.get("name_first"),
		"name_last": l.get("name_last"),
		"age": l.age,
		"power": l.power,
		"loyalty": l.loyalty,
		"faction": l.faction,
		"trait_personality": l.trait_personality,
		"trait_alignment": l.trait_alignment,
		"trait_special": l.trait_special,
		"trait_background": l.trait_background,
	}


func _dump_factions(ws: Resource) -> Array:
	var out: Array = []
	for fac in ws.factions:
		out.append({
			"id": fac.id,
			"is_enabled": fac.is_enabled,
			"is_ally": fac.is_ally,
			"ideology": fac.ideology,
			"support": fac.support,
			"leader_index": fac.leader_index,
		})
	return out


func _dump_modifiers(ws: Resource) -> Array:
	var out: Array = []
	for m in ws.modifiers:
		if m.is_active:
			out.append(m.id)
	out.sort()
	return out
