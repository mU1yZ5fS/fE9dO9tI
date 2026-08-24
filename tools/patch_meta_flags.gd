# ============================================================================
# patch_meta_flags.gd — 补齐 META 的 nodesc/notext 标志（一次性工具）
# ============================================================================
# 场景：部分旧 .tres 的 description / 选项文本本身就是「（结果由 xxx 动态生成）」
# 类占位说明，真实文案在脚本运行时写入。迁移器的占位识别只覆盖了 result 槽，
# 本工具补上 desc / text 槽：向 META 注入 "nodesc" / "notext"，并清理 CSV 死行。
# ============================================================================
extends SceneTree

const EVENT_DIR := "res://场景/事件界面/events/"
const MANIFEST_PATH := "res://tools/migration_manifest.json"
const CSV_PATH := "res://资产/本地化/events_zh_CN.csv"
var drop_keys: Array[String] = []


func _initialize() -> void:
	var mf := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	var manifest: Dictionary = JSON.parse_string(mf.get_as_text())
	mf.close()
	var events: Dictionary = manifest["events"]

	var patched := 0
	drop_keys.clear()

	for p in ResScan.list_files(EVENT_DIR, [".tres"]):
		var stem := String(p).get_file().get_basename()
		if not events.has(stem):
			continue
		var info: Dictionary = events[stem]
		var eid := String(info["id"])
		var def := load(p) as EventDef
		if def == null:
			continue
		var dfp := String(info["def"])

		# ── desc 占位 → nodesc ──
		if _is_placeholder(def.description):
			if _meta_inject(dfp, "\"nodesc\": true"):
				patched += 1
			drop_keys.append("event.%s.desc" % eid)

		# ── 选项文本为纯空白/空 → notext ──
		for i in def.options.size():
			var ot: String = def.options[i].text
			if ot == "" or ot.strip_edges() == "" or _is_placeholder(ot):
				if _meta_inject_option(dfp, i, "\"notext\": true"):
					patched += 1
				drop_keys.append("event.%s.option_%d.text" % [eid, i])

	var wf := FileAccess.open("res://tools/_drop_keys.txt", FileAccess.WRITE)
	for k in drop_keys:
		wf.store_line(k)
	wf.close()
	print("补丁完成：META 注入 %d 处；待删键 %d 个 -> tools/_drop_keys.txt" % [patched, drop_keys.size()])
	quit(0)


func _is_placeholder(s: String) -> bool:
	return s.contains("动态生成") and s.begins_with("（") and s.ends_with("）")


## 在 const META 的 "id": "..." 行后插入标志（幂等）
func _meta_inject(path: String, flag: String) -> bool:
	var src := _read(path)
	if src.is_empty() or src.contains(flag):
		return false
	var pat := RegEx.create_from_string("(\"id\"\\s*:\\s*\"[^\"]+\",\\s*\\n)")
	var m := pat.search(src)
	if m == null:
		return false
	var ins := m.get_string(1) + "\t" + flag + "\n"
	src = src.substr(0, m.get_start()) + ins + src.substr(m.get_end())
	return _write(path, src)


## 在第 index 个选项字典内插入 notext（按 "options": [ 计数定位）
func _meta_inject_option(path: String, index: int, flag: String) -> bool:
	var src := _read(path)
	if src.is_empty():
		return false
	var opts_at := src.find("\"options\":")
	if opts_at < 0:
		return false
	# 第 index 个 "{" 之后插 flag
	var pos := opts_at
	for n in index + 1:
		pos = src.find("{", pos + 1)
		if pos < 0:
			return false
	# 该字典若已有同键则跳过；在 "{" 后直接插
	var seg := src.substr(pos, 120)
	if seg.contains(flag):
		return false
	src = src.substr(0, pos + 1) + flag + ", " + src.substr(pos + 1)
	return _write(path, src)


func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s := f.get_as_text()
	f.close()
	return s


func _write(path: String, src: String) -> bool:
	var wf := FileAccess.open(path, FileAccess.WRITE)
	if wf == null:
		return false
	wf.store_string(src)
	wf.close()
	return true


func _load_csv() -> Dictionary:
	var out := {}
	var f := FileAccess.open(CSV_PATH, FileAccess.READ)
	if f == null:
		return out
	f.get_line()
	while not f.eof_reached():
		var l := f.get_line()
		var ci := l.find(",")
		if ci > 0:
			out[l.substr(0, ci)] = l.substr(ci + 1)
	f.close()
	return out


func _write_csv(data: Dictionary) -> void:
	var order: Array[String] = []
	for k in data.keys():
		order.append(str(k))
	order.sort()
	var lines := ["keys,zh_CN"]
	for k in order:
		lines.append("%s,%s" % [k, data[k]])
	var wf := FileAccess.open(CSV_PATH, FileAccess.WRITE)
	wf.store_string("\n".join(lines) + "\n")
	wf.close()
