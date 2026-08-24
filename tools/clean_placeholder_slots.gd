# ============================================================================
# clean_placeholder_slots.gd — 清理漏网占位符槽位（一次性工具）
# ============================================================================
# 背景：迁移器的占位识别只匹配「动态生成」字样，漏掉三种变体：
#   （结果由 EVT.gd 生成）/ （选项文本由 EVT.gd 动态设置）
#   /（描述由 EVT.gd 的 prepare 动态拼接领袖姓名）
# 统一特征：整格文本以（开头、）结尾且含 ".gd"。
#
# 处理：
#   - CSV：删除这些行
#   - META：result 槽 → 摘除该选项的 "result": true 标志；
#           text 槽 → 注入 "notext": true；desc 槽 → 注入 "nodesc": true
# 运行：Godot --headless --path . --script res://tools/clean_placeholder_slots.gd
# ============================================================================
extends SceneTree

const EVENT_DIR := "res://场景/事件界面/events/"
const MANIFEST_PATH := "res://tools/migration_manifest.json"
const CSV_PATH := "res://资产/本地化/events_zh_CN.csv"


func _initialize() -> void:
	var mf := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	var manifest: Dictionary = JSON.parse_string(mf.get_as_text())
	mf.close()
	# id → def 路径（键名用的是 event_id，不是文件 stem）
	var id_to_def := {}
	for stem in manifest["events"]:
		var info: Dictionary = manifest["events"][stem]
		id_to_def[String(info["id"])] = String(info["def"])

	var csv_rows := _parse_csv(_read(CSV_PATH))
	var drop_idx: Array[int] = []
	var slot_edits := {}   # def_path -> [{opt:int, slot:String}]
	var fixed_keys := 0

	for ri in range(1, csv_rows.size()):
		var row: Array = csv_rows[ri]
		if row.size() < 2 or not _is_placeholder(String(row[1])):
			continue
		drop_idx.append(ri)
		fixed_keys += 1
		# 键形：event.<id>.<slot> 或 event.<id>.option_<n>.<slot>（id 不含点）
		var parts := String(row[0]).split(".")
		if parts.size() < 3 or parts[0] != "event":
			continue
		var def_path: String = id_to_def.get(parts[1], "")
		if def_path == "":
			push_warning("clean: 未知事件ID %s" % parts[1])
			continue
		if parts.size() == 4 and String(parts[2]).begins_with("option_"):
			setdefault(slot_edits, def_path).append({
				"opt": int(String(parts[2]).trim_prefix("option_")),
				"slot": String(parts[3]),
			})
		elif parts.size() == 3:
			setdefault(slot_edits, def_path).append({
				"opt": -1,
				"slot": String(parts[2]),
			})

	# 应用 META 手术
	var files_touched := 0
	for def_path in slot_edits.keys():
		if _apply_meta_edits(def_path, slot_edits[def_path]):
			files_touched += 1

	# 重写 CSV（保留未删除行）
	var out := ["keys,zh_CN"]
	for ri in range(1, csv_rows.size()):
		if ri in drop_idx:
			continue
		var r: Array = csv_rows[ri]
		if r.size() >= 2:
			out.append("%s,%s" % [r[0], _csv_cell(str(r[1]))])
	_write_lines(CSV_PATH, out)

	print("清理完成：%d 个键 | META 手术 %d 个文件" % [fixed_keys, files_touched])
	quit(0)


func _is_placeholder(s: String) -> bool:
	var t := s.strip_edges()
	return t.begins_with("（") and t.ends_with("）") and t.contains(".gd")


## Dictionary.setdefault：键不存在时初始化为空数组并返回
func setdefault(d: Dictionary, k: String) -> Array:
	if not d.has(k):
		d[k] = []
	return d[k]


## 在 def 文件的 META 中执行选项级手术；返回是否有改动
func _apply_meta_edits(path: String, edits: Array) -> bool:
	var src := _read(path)
	if src.is_empty():
		return false
	var changed := false
	for ed in edits:
		# ── 事件级槽位（desc）──
		if ed["opt"] == -1 and String(ed["slot"]) == "desc":
			if not src.contains("\"nodesc\""):
				var pat := RegEx.create_from_string("(\"id\"\\s*:\\s*\"[^\"]+\",\\s*\\n)")
				var m := pat.search(src)
				if m != null:
					src = src.substr(0, m.get_end()) + "\t\"nodesc\": true,\n" + src.substr(m.get_end())
					changed = true
			continue
		if ed["opt"] < 0:
			continue
		# ── 选项级槽位（text / result / disabled）──
		var slot: String = ed["slot"]
		var span := _option_span(src, ed["opt"])
		if span.is_empty():
			push_warning("clean: %s 找不到选项 %d" % [path, ed["opt"]])
			continue
		var seg := src.substr(span["s"], span["e"] - span["s"])
		var new_seg := seg
		match slot:
			"result":
				new_seg = seg.replace(", \"result\": true", "").replace("\"result\": true, ", "").replace("\"result\": true", "")
			"text":
				if not seg.contains("\"notext\""):
					new_seg = "{\"notext\": true, " + seg.substr(1)
			"disabled":
				if not seg.contains("\"disabled\""):
					new_seg = "{\"disabled\": true, " + seg.substr(1)
				else:
					new_seg = seg
			_:
				continue
		if new_seg != seg:
			src = src.substr(0, span["s"]) + new_seg + src.substr(span["e"])
			changed = true
	if not changed:
		return false
	return _write(path, src)


## 定位 "options": [ 中第 want 个顶层字典的 [start,end) 区间（字符串感知的括号匹配）
func _option_span(src: String, want: int) -> Dictionary:
	var marker := src.find("\"options\":")
	if marker < 0:
		return {}
	var arr_at := src.find("[", marker)
	if arr_at < 0:
		return {}
	var depth := 0
	var in_str := false
	var esc := false
	var dict_start := -1
	var seen := 0
	var i := arr_at + 1
	while i < src.length():
		var c := src[i]
		if in_str:
			if esc:
				esc = false
			elif c == "\\":
				esc = true
			elif c == "\"":
				in_str = false
			i += 1
			continue
		if c == "\"":
			in_str = true
		elif c == "{":
			if depth == 0:
				if seen == want:
					dict_start = i
				else:
					seen += 1
			depth += 1
		elif c == "}":
			depth -= 1
			if depth == 0 and dict_start >= 0:
				return {"s": dict_start, "e": i + 1}
		elif c == "]" and depth == 0:
			return {}
		i += 1
	return {}


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


func _write_lines(path: String, lines: Array) -> void:
	var wf := FileAccess.open(path, FileAccess.WRITE)
	wf.store_string("\n".join(lines) + "\n")
	wf.close()


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
