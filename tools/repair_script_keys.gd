# ============================================================================
# repair_script_keys.gd — 修复多轮提取造成的键值撞号（一次性工具）
# ============================================================================
# 背景：extract_script_texts 分两次运行且中途改了跳过规则，两轮独立从
# c0/i0 起编号，同一文件内不同常量可能拿到同一个键，部分文本在 CSV 合并时
# 被先到者覆盖丢失。
#
# 修复策略：
#   1. 全量扫描当前文件的已键值常量与内联 tr() 键 → 所有权表；
#   2. 文本解析：单主键用 CSV 现值；撞号键用 git HEAD 快照里同名常量的原文
#      （提取只替换过值、没动过名字，快照即原始中文）；
#   3. 按文件内【声明顺序】重新连续编号 c0..cN / i0..iM，重写文件与 CSV。
#
# 运行：Godot --headless --path . --script res://tools/repair_script_keys.gd
# ============================================================================
extends SceneTree

const SCRIPT_DIR := "res://数据脚本/事件效果/"
const SNAPSHOT_DIR := "res://tools/_head_snapshot/"
const CSV_PATH := "res://资产/本地化/events_zh_CN.csv"
const KEY_PREFIX := "event.script."
const RE_CONST_DECL := "(?m)^(\\t*)const\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*:?=(\\s*)\""
const RE_INLINE := "\\[\"result_(?:text|title)\"\\]\\s*=\\s*tr\\(\"(event\\.script\\.[^\"]+)\"\\)"

var anomalies: Array[String] = []


func _initialize() -> void:
	print("=== 键值修复开始 ===")
	var files := ResScan.list_files(SCRIPT_DIR, [".gd"])
	var csv := _load_csv()

	# ── 收集每个文件的已键值项 ──
	var repairs := {}   # file -> {consts:[{name,s,e,key,text}], inlines:[{ks,ke,key,text}]}
	var owners := {}    # key -> count
	for fp in files:
		var src := _read(fp)
		if src.is_empty():
			continue
		var item := {"consts": [], "inlines": []}
		for m in RegEx.create_from_string(RE_CONST_DECL).search_all(src):
			var q := m.get_end() - 1
			var lit := _scan_string_literal(src, q)
			if lit.is_empty():
				continue
			var val := _unescape(lit["raw"])
			if not val.begins_with(KEY_PREFIX):
				continue
			var cname := m.get_string(2)
			item["consts"].append({
				"name": cname, "s": q, "e": int(lit["end"]) + 1,
				"key": val, "src": src,
			})
			owners[val] = int(owners.get(val, 0)) + 1
		for m in RegEx.create_from_string(RE_INLINE).search_all(src):
			var key := m.get_string(1)
			item["inlines"].append({
				"ks": m.get_start(1), "ke": m.get_end(1), "key": key,
			})
			owners[key] = int(owners.get(key, 0)) + 1
		repairs[fp] = item

	# ── 解析真文本并重编号 ──
	var new_rows := {}
	for fp in files:
		if not repairs.has(fp):
			continue
		var item: Dictionary = repairs[fp]
		if item["consts"].is_empty() and item["inlines"].is_empty():
			continue
		var stem := String(fp).get_file().get_basename()
		var snap_src := _read(SNAPSHOT_DIR.path_join(stem + ".gd"))
		var edits: Array = []
		var ck := 0
		for c in item["consts"]:
			var text := _resolve_text(c, owners, csv, snap_src, stem)
			var nkey := "%s%s.c%d" % [KEY_PREFIX, stem, ck]
			ck += 1
			new_rows[nkey] = text
			edits.append({"s": c["s"], "e": c["e"], "r": "\"%s\"" % nkey})
		var ik := 0
		for it in item["inlines"]:
			var text2: String = csv.get(it["key"], "")
			if owners[it["key"]] > 1 and text2 == "":
				anomalies.append("%s 内联键 %s 撞号且无法恢复" % [stem, it["key"]])
				continue
			var nkey2 := "%s%s.i%d" % [KEY_PREFIX, stem, ik]
			ik += 1
			new_rows[nkey2] = text2
			edits.append({"s": it["ks"], "e": it["ke"], "r": nkey2})
		# 应用
		edits.sort_custom(func(a, b): return a["s"] > b["s"])
		var out := _read(fp)
		for ed in edits:
			out = out.substr(0, ed["s"]) + str(ed["r"]) + out.substr(ed["e"])
		var wf := FileAccess.open(fp, FileAccess.WRITE)
		wf.store_string(out)
		wf.close()

	_rebuild_csv(csv, new_rows)
	print("=== 修复完成：%d 个脚本键值 ===" % new_rows.size())
	if not anomalies.is_empty():
		print("--- 异常 %d 条 ---" % anomalies.size())
		for a in anomalies.slice(0, 30):
			print("  ! " + a)
	quit(0)


## 单主键 → CSV；撞号 → HEAD 同名常量原文
func _resolve_text(c: Dictionary, owners: Dictionary, csv: Dictionary,
		snap_src: String, stem: String) -> String:
	if int(owners[c["key"]]) == 1:
		return str(csv.get(c["key"], ""))
	# 撞号：从 HEAD 快照按常量名取原值
	if not snap_src.is_empty():
		for m in RegEx.create_from_string(RE_CONST_DECL).search_all(snap_src):
			if m.get_string(2) == c["name"]:
				var lit := _scan_string_literal(snap_src, m.get_end() - 1)
				if not lit.is_empty():
					return _unescape(lit["raw"])
	anomalies.append("%s：%s 撞号且快照无原文" % [stem, c["name"]])
	return str(csv.get(c["key"], ""))


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


# ── CSV 完整解析 / 重建 ──

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


func _csv_cell(s: String) -> String:
	if s.contains(",") or s.contains("\"") or s.contains("\n") or s.contains("\r"):
		return "\"%s\"" % s.replace("\"", "\"\"")
	return s


func _load_csv() -> Dictionary:
	var out := {}
	var parsed := _parse_csv(_read(CSV_PATH))
	for ri in range(1, parsed.size()):
		var row: Array = parsed[ri]
		if row.size() >= 2:
			out[str(row[0])] = str(row[1])
	return out


func _rebuild_csv(old_all: Dictionary, script_rows: Dictionary) -> void:
	var keep := {}
	var order: Array[String] = []
	for k in old_all.keys():
		if not str(k).begins_with(KEY_PREFIX):
			order.append(str(k))
			keep[str(k)] = old_all[k]
	for k in script_rows.keys():
		order.append(str(k))
		keep[str(k)] = script_rows[k]
	order.sort()
	var lines := ["keys,zh_CN"]
	for k in order:
		lines.append("%s,%s" % [k, _csv_cell(keep[k])])
	var wf := FileAccess.open(CSV_PATH, FileAccess.WRITE)
	wf.store_string("\n".join(lines) + "\n")
	wf.close()
	print("CSV 重建：非脚本文案 %d + 脚本文案 %d = %d 键" %
			[order.size() - script_rows.size(), script_rows.size(), order.size()])
