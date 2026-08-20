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

## 对齐原作 DiffScript.cs / Savescript.cs 的中文难度显示名（逐字含原空格）。
const DIFF_NAMES_ZH := [" 牛 棚 小 酌", " 上 山 下 乡", " 斗 私 批 修", " 造 反 有 理", " 浩 荡 文 革"]
## data[14]（政体/意识形态）显示名。原作 GlobalScript.doctr[]，Godot 侧权威映射见
## 场景/派系界面/派系.gd DOCTR_BASE 的 0-5（data[14] 只取 0-5）。
const IDEOLOGY_NAMES_ZH := {
	0: "威权主义",
	1: "保守社会主义",
	2: "民族特色社会主义",
	3: "邓式实用主义",
	4: "社会民主主义",
	5: "自由主义",
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


static func format_opis(slot: int, meta: Dictionary = {}, 激活: bool = false) -> String:
	# 对齐 Savescript.cs OnMouseEnter（解锁）与 LoadInScript.cs OnMouseEnter（激活）的中文描述：
	# 首行只由槽位决定；有档再追加 体制/日期/难度/成就；空档追加「空档位」。
	if meta.is_empty():
		meta = get_slot_meta(slot)
	var head := " 可 激 活 成 就" if 激活 and slot == 0 else " 不 可 激 活 成 就"
	if not 激活:
		head = " 可 解 锁 成 就" if slot == 0 else " 不 可 解 锁 成 就"
	if not slot_exists(slot):
		return head + "\n 空 档 位"
	var y := int(meta.get("year", 0))
	var mo := int(meta.get("month", 0))
	var d := int(meta.get("day", 0))
	# 原作按 data19.data20.data21 = 日.月.年 显示
	var date_line := "%d.%d.%d" % [d, mo, y] if y > 0 else "日期：未知"
	var diff := int(meta.get("difficulty", 2))
	var diff_name: String = DIFF_NAMES_ZH[diff] if diff >= 0 and diff < DIFF_NAMES_ZH.size() else str(diff)
	var ideo := int(meta.get("ideology", 0))
	var ideo_name: String = IDEOLOGY_NAMES_ZH.get(ideo, "体制 %d" % ideo)
	var iron := bool(meta.get("is_ironman", slot == 0))
	return "%s\n体制：%s\n日期：%s\n难度：%s\n成就：%s" % [
		head, ideo_name, date_line, diff_name,
		"[color=red] 可 解 锁 [/color]" if iron else "[color=red] 不 可 解 锁 [/color]",
	]


static func delete_slot(slot: int) -> bool:
	var path := slot_path(slot)
	var ok := true
	if FileAccess.file_exists(path):
		var err := DirAccess.remove_absolute(path)
		ok = err == OK
	clear_slot_meta(slot)
	return ok
