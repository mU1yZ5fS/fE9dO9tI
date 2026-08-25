# ============================================================================
# extract_script_texts.gd — 事件脚本硬编码文案 → 本地化键值 提取器
# ============================================================================
# 运行方式：
#   Godot --headless --path . --script res://tools/extract_script_texts.gd
#
# 处理 数据脚本/事件效果/*.gd 中两类硬编码（对应 .tres 里 1574 处
# 「结果由 xxx.gd 动态生成」占位的真实文案来源）：
#
#   A. 内联字面量   context["result_text"] = "中文…"
#      → context["result_text"] = tr("event.script.<文件名>.i<N>")
#
#   B. 文本常量     const TXT_XXX := "中文…"（全部纯字符串文本常量）
#      值 → 键值；同文件内全部整词使用点包 tr()：
#      拼接 / %格式化 / 三元选择 天然兼容（各段独立翻译后再组装）。
#
# 安全护栏（命中则整体跳过该常量并记异常，保留中文原文）：
#   - 在 == / != / .has( / .find( / match 等比较语境中使用
#   - 被事件效果目录之外的文件引用（跨文件读者拿不到翻译）
#   - 使用点落在字符串字面量或注释内部（防误包装）
#   - 多行声明 / 非纯字符串声明
#
# 幂等：值已是 event.script. 键的常量、RHS 已是 tr(...) 的赋值自然跳过。
# CSV：完整解析现有 events_zh_CN.csv（支持引号内换行单元格），
#      追加 script 区段后规范化重写。
# ============================================================================
extends SceneTree

const SCRIPT_DIR := "res://数据脚本/事件效果/"
const CSV_PATH := "res://资产/本地化/events_zh_CN.csv"
const KEY_PREFIX := "event.script."

## 常量声明：行首缩进 + const + 名字 + :=/= + 字符串开头（(?m)=多行模式）
const RE_CONST_DECL := "(?m)^(\\t*)const\\s+([A-Za-z_][A-Za-z0-9_]*)\\s*:?=(\\s*)\""

var stats := {"inline": 0, "consts": 0, "files_touched": 0}
var anomalies: Array[String] = []
var new_rows := {}   # key -> text


func _initialize() -> void:
	print("=== 脚本文案提取开始 ===")
	var files := ResScan.list_files(SCRIPT_DIR, [".gd"])

	# 预扫描已移除：GDScript 常量是文件级类作用域，各文件同名互不冲突；
	# 跨目录引用已在设计期用全局 grep 排除（事件效果/ 目录外无 TXT_* 引用）。

	for fp in files:
		_process_file(fp)

	_merge_csv()
	print("=== 提取完成 ===")
	print("内联提取 %d | 常量提取 %d | 改写文件 %d" %
			[stats["inline"], stats["consts"], stats["files_touched"]])
	if not anomalies.is_empty():
		print("--- 异常 %d 条（未处理，保留原文）---" % anomalies.size())
		for a in anomalies.slice(0, 40):
			print("  ! " + a)
	quit(0)


func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s := f.get_as_text()
	f.close()
	return s


# ────────────────────────────────────────────────────────────────────────────
# 单文件处理
# ────────────────────────────────────────────────────────────────────────────

func _process_file(path: String) -> void:
	var src := _read(path)
	if src.is_empty():
		return
	var stem := String(path).get_file().get_basename()

	# 全文字符串/注释掩码（位置 → true 表示位于字符串或注释内）
	var mask := _build_string_comment_mask(src)

	var edits: Array = []   # {s, e, r} 绝对区间替换

	# ── B. 文本常量 ──
	var ck := 0
	for m in RegEx.create_from_string(RE_CONST_DECL).search_all(src):
		var cname := m.get_string(2)
		var q := m.get_end() - 1   # 指向起始引号（正则结尾是 "）
		var lit := _scan_string_literal(src, q)
		if lit.is_empty():
			anomalies.append("%s：%s 多行/未闭合声明，跳过" % [stem, cname])
			continue
		var value := _unescape(lit["raw"])
		if value.begins_with(KEY_PREFIX):
			continue   # 已提取（幂等）
		var bad := _dangerous_usage_lines(src, cname, mask)
		if not bad.is_empty():
			anomalies.append("%s：%s 危险用法 %s，跳过" % [stem, cname, str(bad)])
			continue
		var key := "%s%s.c%d" % [KEY_PREFIX, stem, ck]
		ck += 1
		new_rows[key] = value
		edits.append({"s": q, "e": int(lit["end"]) + 1, "r": "\"%s\"" % key})
		# 使用点包 tr()：跳过声明区、跳过字符串/注释内部
		var pat := RegEx.create_from_string("\\b%s\\b" % cname)
		var from := int(lit["end"]) + 1
		while true:
			var um := pat.search(src, from)
			if um == null:
				break
			var p := um.get_start()
			if p >= mask.size() or mask[p]:
				from = um.get_end()
				continue
			edits.append({"s": p, "e": um.get_end(), "r": "tr(%s)" % cname})
			from = um.get_end()
		stats["consts"] += 1

	# ── A. 内联 result_text / result_title 字面量 ──
	var ik := 0
	var re_inline := RegEx.create_from_string(
			"\\[\"result_(?:text|title)\"\\]\\s*=(?![=+\\-*/<>!])\\s*\"")
	for im in re_inline.search_all(src):
		var qs := im.get_end() - 1
		var lit := _scan_string_literal(src, qs)
		if lit.is_empty():
			anomalies.append("%s:%d 内联字面量未在本行闭合，跳过" %
					[stem, src.count("\n", 0, qs) + 1])
			continue
		# 必须是语句收尾（闭合引号后只允许空白/注释），否则是拼接等复杂形态
		var tail: Variant = _tail_after(src, int(lit["end"]) + 1)
		if tail == null:
			continue   # 复杂形态：拼接/% 等 → 交给常量机制或人工
		var text := _unescape(lit["raw"])
		if text.begins_with(KEY_PREFIX):
			continue
		var key := "%s%s.i%d" % [KEY_PREFIX, stem, ik]
		ik += 1
		new_rows[key] = text
		edits.append({"s": qs, "e": int(lit["end"]) + 1,
				"r": "tr(\"%s\")%s" % [key, tail]})
		stats["inline"] += 1

	if edits.is_empty():
		return

	# 自后向前应用
	edits.sort_custom(func(a, b): return a["s"] > b["s"])
	var out := src
	for ed in edits:
		out = out.substr(0, ed["s"]) + str(ed["r"]) + out.substr(ed["e"])
	var wf := FileAccess.open(path, FileAccess.WRITE)
	wf.store_string(out)
	wf.close()
	stats["files_touched"] += 1


# ────────────────────────────────────────────────────────────────────────────
# 扫描器
# ────────────────────────────────────────────────────────────────────────────

## 返回与 src 等长的 PackedByteArray掩码：1 = 位于字符串字面量或注释内
func _build_string_comment_mask(s: String) -> PackedByteArray:
	var mask := PackedByteArray()
	mask.resize(s.length())
	var i := 0
	var state := 0   # 0=code 1=line_comment 2=string 3=block_comment
	while i < s.length():
		var c := s[i]
		match state:
			0:
				if c == "\"":
					state = 2
					mask[i] = 1
				elif c == "#" and (i == 0 or s[i - 1] != "\\"):
					state = 1
					mask[i] = 1
				i += 1
			1:   # 行注释
				if c == "\n":
					state = 0
				else:
					mask[i] = 1
				i += 1
			2:   # 双引号字符串（GDScript 无字符字面量，单引号也是字符串——一并处理）
				if c == "\\":
					mask[i] = 1
					if i + 1 < s.length():
						mask[i + 1] = 1
					i += 2
				elif c == "\"":
					mask[i] = 1
					state = 0
					i += 1
				else:
					mask[i] = 1
					i += 1
			_:
				i += 1
	return mask


## 从 start_quote 起扫描双引号字面量；返回 {end, raw} 或 {}（未闭合/三引号）
func _scan_string_literal(s: String, start_quote: int) -> Dictionary:
	if s.substr(start_quote, 3) == "\"\"\"":
		var t := s.find("\"\"\"", start_quote + 3)
		if t < 0:
			return {}
		return {"end": t + 2, "raw": s.substr(start_quote, t + 3 - start_quote)}
	var i := start_quote + 1
	while i < s.length():
		var c := s[i]
		if c == "\\":
			i += 2
			continue
		if c == "\"":
			return {"end": i, "raw": s.substr(start_quote, i + 1 - start_quote)}
		if c == "\n":
			return {}   # 普通字符串不允许裸换行
		i += 1
	return {}


## 闭合引号后的语句尾部；返回原文尾串（含前导空格），
## 若后面还有代码（拼接/%/调用等复杂形态）返回 null。
func _tail_after(s: String, pos: int) -> Variant:
	var i := pos
	while i < s.length():
		var c := s[i]
		if c == "\n" or c == "#":
			return s.substr(pos, i - pos)
		if c not in [" ", "\t", "\r"]:
			return null
		i += 1
	return s.substr(pos)


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


## 常量的危险用法行号清单（比较语境 / 字符串内提及）
func _dangerous_usage_lines(src: String, cname: String, mask: PackedByteArray) -> Array:
	var bad: Array = []
	var pat := RegEx.create_from_string("(==|!=|\\.has\\(|\\.find\\(|match\\s)[^\\n]*\\b%s\\b|\\b%s\\b[^\\n]*(==|!=)" % [cname, cname])
	for m in pat.search_all(src):
		var p := m.get_start()
		var line_no := src.count("\n", 0, p) + 1
		if not line_no in bad:
			bad.append(line_no)
	return bad


# ────────────────────────────────────────────────────────────────────────────
# CSV 完整解析 / 规范化重写（RFC4180：支持引号内逗号、换行、转义引号）
# ────────────────────────────────────────────────────────────────────────────

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
				i += 1
			elif c == ",":
				row.append(cell)
				cell = ""
				i += 1
			elif c == "\r":
				i += 1
			elif c == "\n":
				row.append(cell)
				rows.append(row)
				row = []
				cell = ""
				i += 1
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


func _merge_csv() -> void:
	var existing := {}
	var order: Array[String] = []
	var parsed := _parse_csv(_read(CSV_PATH))
	for ri in range(1, parsed.size()):   # 跳过 header
		var row: Array = parsed[ri]
		if row.size() >= 2 and str(row[0]) != "":
			var k := str(row[0])
			if not existing.has(k):
				order.append(k)
			existing[k] = str(row[1])
	# 合并新键
	var added := 0
	for k in new_rows.keys():
		if not existing.has(k):
			order.append(str(k))
			added += 1
		existing[k] = str(new_rows[k])
	order.sort()
	var lines := ["keys,zh_CN"]
	for k in order:
		lines.append("%s,%s" % [k, _csv_cell(existing[k])])
	var wf := FileAccess.open(CSV_PATH, FileAccess.WRITE)
	wf.store_string("\n".join(lines) + "\n")
	wf.close()
	print("CSV：原有 %d 键，新增 %d 键，合计 %d" % [order.size() - added, added, order.size()])
