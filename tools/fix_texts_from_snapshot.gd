# ============================================================================
# fix_texts_from_snapshot.gd — 用 HEAD 快照校正脚本文案（一次性工具）
# ============================================================================
# 前置状态：repair_script_keys 已把所有键值唯一化（文件不再有撞号），
# 但部分条目的 CSV 文本在撞号期间被先到者覆盖成了错误内容。
# 本工具逐常量对照 HEAD 快照里的同名常量原文，不一致则以快照为准回填 CSV。
# 文件本身不动（键引用已正确）。
# ============================================================================
extends SceneTree

const SCRIPT_DIR := "res://数据脚本/事件效果/"
const SNAPSHOT_SUB := "res://tools/_head_snapshot/数据脚本/事件效果/"
const CSV_PATH := "res://资产/本地化/events_zh_CN.csv"
const KEY_PREFIX := "event.script."
const RE_CONST_DECL := "(?m)^(\\t*)const\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*:?=(\\s*)\""

var anomalies: Array[String] = []


func _initialize() -> void:
	print("=== 快照文本校正开始 ===")
	var files := ResScan.list_files(SCRIPT_DIR, [".gd"])
	var csv := _load_csv()
	var fixed := 0
	var checked := 0

	for fp in files:
		var src := _read(fp)
		if src.is_empty():
			continue
		var stem := String(fp).get_file().get_basename()
		var snap_src := _read(SNAPSHOT_SUB.path_join(stem + ".gd"))
		if snap_src.is_empty():
			continue   # HEAD 后新增的文件：无快照，信任现值
		var head_map := {}
		for m in RegEx.create_from_string(RE_CONST_DECL).search_all(snap_src):
			var lit := _scan_string_literal(snap_src, m.get_end() - 1)
			if not lit.is_empty():
				head_map[m.get_string(2)] = _unescape(lit["raw"])

		for m in RegEx.create_from_string(RE_CONST_DECL).search_all(src):
			var q := m.get_end() - 1
			var lit := _scan_string_literal(src, q)
			if lit.is_empty():
				continue
			var val := _unescape(lit["raw"])
			if not val.begins_with(KEY_PREFIX):
				continue
			checked += 1
			var cname := m.get_string(2)
			if not head_map.has(cname):
				anomalies.append("%s：%s 快照中不存在（HEAD后新增？），保留现值" % [stem, cname])
				continue
			if str(csv.get(val, "")) != str(head_map[cname]):
				csv[val] = head_map[cname]
				fixed += 1

	_write_csv(csv)
	print("=== 校正完成：检查 %d，纠正 %d ===" % [checked, fixed])
	if not anomalies.is_empty():
		print("--- 异常 %d 条 ---" % anomalies.size())
		for a in anomalies.slice(0, 20):
			print("  ! " + a)
	quit(0)


func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s := f.get_as_text()
	f.close()
	return s


func _scan_string_literal(s: String, start_quote: int) -> Dictionary:
	var i := start_quote + 1
	while i < s.length():
		var c := s[i]
		if c == "\\":
			i += 2
			continue
		if c == "\"":
			return {"end": i, "raw": s.substr(start_quote, i + 1 - start_quote)}
		if c == "\n":
			return {}
		i += 1
	return {}


func _unescape(raw_with_quotes: String) -> String:
	var body := raw_with_quotes.trim_prefix("\"").trim_suffix("\"")
	var out := ""
	var i := 0
	while i < body.length():
		var c := body[i]
		if c == "\\" and i + 1 < body.length():
			var n := body[i + 1]
			match n:
				"n": out += "\n"
				"t": out += "\t"
				"\"": out += "\""
				"\\": out += "\\"
				_: out += n
			i += 2
		else:
			out += c
			i += 1
	return out


func _parse_csv(text: String) -> Array:
	var rows: Array = []
	var cell := ""
	var row: Array = []
	var in_q := false
	var i := 0
	while i < text.length():
		var c := text[i]
		if in_q:
			if c == "\"":
				if i + 1 < text.length() and text[i + 1] == "\"":
					cell += "\""
					i += 2
					continue
				in_q = false
			else:
				cell += c
			i += 1
		else:
			if c == "\"" and cell == "":
				in_q = true
			elif c == ",":
				row.append(cell)
				cell = ""
			elif c == "\r":
				pass
			elif c == "\n":
				row.append(cell)
				rows.append(row)
				row = []
				cell = ""
			else:
				cell += c
			i += 1
	if cell != "" or not row.is_empty():
		row.append(cell)
		rows.append(row)
	return rows


func _load_csv() -> Dictionary:
	var out := {}
	var parsed := _parse_csv(_read(CSV_PATH))
	for ri in range(1, parsed.size()):
		var row: Array = parsed[ri]
		if row.size() >= 2:
			out[str(row[0])] = str(row[1])
	return out


func _csv_cell(s: String) -> String:
	if s.contains(",") or s.contains("\"") or s.contains("\n") or s.contains("\r"):
		return "\"%s\"" % s.replace("\"", "\"\"")
	return s


func _write_csv(data: Dictionary) -> void:
	var order: Array[String] = []
	for k in data.keys():
		order.append(str(k))
	order.sort()
	var lines := ["keys,zh_CN"]
	for k in order:
		lines.append("%s,%s" % [k, _csv_cell(data[k])])
	var wf := FileAccess.open(CSV_PATH, FileAccess.WRITE)
	wf.store_string("\n".join(lines) + "\n")
	wf.close()
