# ============================================================================
# SaveCatalog — 槽位存档路径与元数据（user://saves）
# ============================================================================
# 原作：SaveStorage + SaveMetadata（.save + .smeta + saves.json）
# Godot 简化：save_XX.res（WorldState）+ meta.json（槽位摘要，供 UI 显示）
# ============================================================================
class_name SaveCatalog
extends RefCounted

const SAVE_DIR := "user://saves"
const META_PATH := "user://saves/meta.json"
## 界面 5 槽：0=成就位（顶部），1–4=无成就位
const UI_SLOT_COUNT := 5
const MAX_SLOTS := 10

const DIFF_NAMES_ZH := ["沙盒", "简单", "标准", "困难", "文革"]
const IDEOLOGY_NAMES_ZH := {
	0: "马列主义",
	1: "毛主义",
	2: "修正主义",
	3: "市场社会主义",
	4: "其它",
}


static func ensure_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


static func slot_path(slot: int) -> String:
	return "%s/save_%02d.res" % [SAVE_DIR, slot]


static func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(slot_path(slot))


static func load_meta_all() -> Dictionary:
	ensure_dir()
	if not FileAccess.file_exists(META_PATH):
		return {}
	var f := FileAccess.open(META_PATH, FileAccess.READ)
	if f == null:
		return {}
	var text := f.get_as_text()
	f.close()
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	var slots = data.get("slots", {})
	if typeof(slots) != TYPE_DICTIONARY:
		return {}
	return slots


static func save_meta_all(slots: Dictionary) -> void:
	ensure_dir()
	var f := FileAccess.open(META_PATH, FileAccess.WRITE)
	if f == null:
		push_error("SaveCatalog: 无法写入 meta.json")
		return
	f.store_string(JSON.stringify({"slots": slots}, "\t"))
	f.close()


static func write_slot_meta(slot: int, meta: Dictionary) -> void:
	var all := load_meta_all()
	all[str(slot)] = meta
	save_meta_all(all)


static func clear_slot_meta(slot: int) -> void:
	var all := load_meta_all()
	all.erase(str(slot))
	save_meta_all(all)


static func get_slot_meta(slot: int) -> Dictionary:
	var all := load_meta_all()
	var m = all.get(str(slot), {})
	if typeof(m) != TYPE_DICTIONARY:
		return {}
	return m


static func meta_from_world(w: WorldState) -> Dictionary:
	if w == null or w.date == null:
		return {}
	var ideology := 0
	if w.数值表.size() > WorldState.I_IDEOLOGY:
		ideology = w.数值表[WorldState.I_IDEOLOGY]
	return {
		"year": w.date.year,
		"month": w.date.month,
		"day": w.date.day,
		"difficulty": w.difficulty,
		"is_ironman": w.is_ironman,
		"ideology": ideology,
		"player_gwcode": w.player_country_gwcode,
		"updated": Time.get_datetime_string_from_system(false, true),
	}


static func format_opis(slot: int, meta: Dictionary = {}) -> String:
	if meta.is_empty():
		meta = get_slot_meta(slot)
	var exists := slot_exists(slot)
	if not exists and meta.is_empty():
		return "槽位 %d\n（空）" % (slot + 1)
	var iron := bool(meta.get("is_ironman", false))
	var iron_line := "成就：可用" if iron else "成就：不可用"
	var y := int(meta.get("year", 0))
	var mo := int(meta.get("month", 0))
	var d := int(meta.get("day", 0))
	var date_line := "日期：%d年%d月%d日" % [y, mo, d] if y > 0 else "日期：未知"
	var diff := int(meta.get("difficulty", 2))
	var diff_name: String = DIFF_NAMES_ZH[diff] if diff >= 0 and diff < DIFF_NAMES_ZH.size() else str(diff)
	var ideo := int(meta.get("ideology", 0))
	var ideo_name: String = IDEOLOGY_NAMES_ZH.get(ideo, "意识形态 %d" % ideo)
	var head := "槽位 %d · %s" % [slot + 1, "铁人" if iron else "普通"]
	if not exists:
		head += "\n（文件缺失）"
	return "%s\n%s\n%s\n难度：%s\n%s" % [head, date_line, "体制参考：%s" % ideo_name, diff_name, iron_line]


static func delete_slot(slot: int) -> bool:
	var path := slot_path(slot)
	var ok := true
	if FileAccess.file_exists(path):
		var err := DirAccess.remove_absolute(path)
		ok = err == OK
	clear_slot_meta(slot)
	return ok
