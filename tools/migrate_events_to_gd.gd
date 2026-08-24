# ============================================================================
# migrate_events_to_gd.gd — 事件 .tres → META 脚本 一次性迁移工具
# ============================================================================
# 运行方式（在项目根目录）：
#   Godot --headless --path . --script res://tools/migrate_events_to_gd.gd
#
# 做什么：
#   1. 扫描 场景/事件界面/events/*.tres，用 Godot 反序列化成 EventDef 对象
#      （不做文本解析，结构无损），序列化为 META 字典源码。
#   2. 文案（title/desc/选项文本/结果文本）不进代码：按 event.<id>.* 约定
#      导出为 资产/本地化/events_zh_CN.csv。
#   3. 合并策略：
#      - 事件引用的效果脚本与该事件严格 1:1、且未被其他 .gd 引用 →
#        把 const META 直接追加到那个脚本文件末尾（真·单文件）。
#      - 共享脚本 / 无脚本 → 在 数据脚本/事件定义/<同名>.gd 生成独立定义。
#   4. 输出 tools/migration_manifest.json 供校验器使用 + 控制台报告。
#
# 幂等性：已含 META 的合并目标会跳过并告警；CSV/清单全量重写。
# 回滚：git checkout 即可（工具只新增文件 / 在脚本末尾追加，不改既有行）。
# ============================================================================
extends SceneTree

const EVENT_DIR := "res://场景/事件界面/events/"
const STANDALONE_DIR := "res://数据脚本/事件定义/"
const CSV_PATH := "res://资产/本地化/events_zh_CN.csv"
const MANIFEST_PATH := "res://tools/migration_manifest.json"

var stats := {
	"total": 0, "merged": 0, "standalone": 0, "skipped": 0,
	"csv_rows": 0, "images": 0, "placeholders": 0,
}
var anomalies: Array[String] = []
var csv_rows: Array[String] = []

## 上次迁移追加的 banner 首行（清除用，保证可从脏状态幂等重跑）
const MERGE_BANNER_MARK := "# 自动迁移的事件定义"


func _initialize() -> void:
	print("=== 事件迁移开始 ===")
	# 清掉上次生成的独立定义与 CSV（本次全量重建）
	if DirAccess.dir_exists_absolute(_global(STANDALONE_DIR)):
		for f in ResScan.list_files(STANDALONE_DIR, [".gd"]):
			DirAccess.remove_absolute(_global(f))
		var uid_dir := _global(STANDALONE_DIR)
		var d := DirAccess.open(uid_dir)
		if d != null:
			d.list_dir_begin()
			var fn := d.get_next()
			while fn != "":
				if fn.ends_with(".uid"):
					d.remove(fn)
				fn = d.get_next()
			d.list_dir_end()
	var paths := ResScan.list_files(EVENT_DIR, [".tres"])
	stats["total"] = paths.size()
	if paths.is_empty():
		push_error("未找到 .tres 事件：%s" % EVENT_DIR)
		quit(1)
		return

	# ── 第一遍：收集脚本引用计数（跨全部事件） ──
	var script_users := {}          # script_path -> {event_stem: true}
	var per_event_scripts := {}     # stem -> Array[String]
	for p in paths:
		var def := load(p) as EventDef
		if def == null:
			anomalies.append("无法加载 %s" % p)
			continue
		var stem := String(p).get_file().get_basename()
		var refs := _collect_script_refs(def)
		per_event_scripts[stem] = refs
		for rp in refs:
			if not script_users.has(rp):
				script_users[rp] = {}
			script_users[rp][stem] = true

	var externally_referenced := _find_externally_referenced(script_users.keys())

	# ── 第二遍：逐事件迁移 ──
	var manifest := {"events": {}}
	for p in paths:
		var def := load(p) as EventDef
		if def == null:
			continue
		var stem := String(p).get_file().get_basename()

		# 合并候选：恰好引用一个脚本、该脚本只服务本事件、且未被外部引用
		var merge_target := ""
		var refs: Array = per_event_scripts.get(stem, [])
		if refs.size() == 1:
			var rp := String(refs[0])
			if script_users[rp].size() == 1 and not externally_referenced.has(rp):
				merge_target = rp

		# 序列化时以合并目标为宿主：指向宿主的 CUSTOM_SCRIPT 省略 script 字段
		var meta := _serialize_def(def, merge_target)

		var def_path := ""
		if merge_target != "" and _merge_meta_into(merge_target, stem, meta):
			stats["merged"] += 1
			def_path = merge_target
		else:
			def_path = _write_standalone(stem, meta, refs)
			if def_path != "":
				stats["standalone"] += 1
			else:
				stats["skipped"] += 1
				continue

		_collect_csv_rows(def, String(p))
		manifest["events"][stem] = {
			"def": def_path, "merged": merge_target != "",
			"id": def.event_id, "num": def.source_event_number,
		}

	_write_csv()
	manifest["stats"] = stats
	manifest["anomalies"] = anomalies
	var mf := FileAccess.open(MANIFEST_PATH, FileAccess.WRITE)
	mf.store_string(JSON.stringify(manifest, "\t"))
	mf.close()

	print("=== 迁移完成 ===")
	print("总计 %d | 合并 %d | 独立定义 %d | 跳过 %d" % [
		stats["total"], stats["merged"], stats["standalone"], stats["skipped"]])
	print("CSV 文案行数：%d | 含配图事件数：%d" % [stats["csv_rows"], stats["images"]])
	if not anomalies.is_empty():
		print("--- 异常 %d 条 ---" % anomalies.size())
		for a in anomalies:
			print("  ! " + a)
	quit(0)


# ────────────────────────────────────────────────────────────────────────────
# 引用收集
# ────────────────────────────────────────────────────────────────────────────

func _collect_script_refs(def: EventDef) -> Array[String]:
	var out := {}
	if def.display_script != null and def.display_script.resource_path != "":
		out[def.display_script.resource_path] = true
	if def.trigger_script != null and def.trigger_script.resource_path != "":
		out[def.trigger_script.resource_path] = true
	for opt in def.options:
		if opt == null:
			continue
		for fx in opt.effects:
			if fx != null and fx.custom_script != null and fx.custom_script.resource_path != "":
				out[fx.custom_script.resource_path] = true
	var arr: Array[String] = []
	for k in out.keys():
		arr.append(String(k))
	return arr


## 检查脚本是否被事件资源之外的可执行代码 preload/load（命中则不可作为合并目标）。
## 只看非注释行里的 preload(/load( 调用；自身文件不计。
func _find_externally_referenced(script_paths: Array) -> Dictionary:
	var result := {}
	var needles := {}
	for rp in script_paths:
		needles[String(rp)] = String(rp).get_file()
	var gd_paths := ResScan.list_files("res://数据脚本/", [".gd"])
	for gp in gd_paths:
		var f := FileAccess.open(gp, FileAccess.READ)
		if f == null:
			continue
		var src := f.get_as_text()
		f.close()
		for rp in needles.keys():
			if result.has(rp) or gp == rp:
				continue
			var fname: String = needles[rp]
			for line in src.split("\n"):
				var t := line.strip_edges()
				if t.begins_with("#") or t.begins_with("//"):
					continue
				if (t.contains("preload(") or t.contains("load(")) and t.contains(fname):
					result[rp] = gp
					break
	return result


# ────────────────────────────────────────────────────────────────────────────
# 序列化：EventDef → META 字典
# ────────────────────────────────────────────────────────────────────────────

func _serialize_def(def: EventDef, host_path: String) -> Dictionary:
	var m := {"id": def.event_id}
	if def.source_event_number >= 0:
		m["num"] = def.source_event_number
	if def.trigger_priority >= 0:
		m["priority"] = def.trigger_priority
	if not def.show_notification:
		m["notify"] = false
	if def.notification_days != 13:
		m["notify_days"] = def.notification_days
	if def.timeout_agents_penalty != 20:
		m["timeout_agents"] = def.timeout_agents_penalty
	if def.timeout_budget_penalty != 5:
		m["timeout_budget"] = def.timeout_budget_penalty
	if not def.fire_only_once:
		m["once"] = false
	if def.dlc != "":
		m["dlc"] = def.dlc
	if def.image != null:
		m["image"] = def.image.resource_path
		stats["images"] += 1
	if not def.triggers_on_complete.is_empty():
		var chain := []
		for cid in def.triggers_on_complete:
			chain.append(cid)
		m["chain"] = chain
	if def.title == "":
		m["notitle"] = true
	if def.description == "":
		m["nodesc"] = true
	if def.display_script != null:
		m["display_script"] = def.display_script.resource_path
	if def.trigger_script != null:
		m["trigger_script"] = def.trigger_script.resource_path

	var trig := []
	for c in def.trigger_conditions:
		trig.append(_expr_dict(c))
	if not trig.is_empty():
		m["trigger"] = trig

	var opts := []
	for i in def.options.size():
		opts.append(_option_dict(def.options[i], i, host_path))
	if not opts.is_empty():
		m["options"] = opts
	return m


func _expr_dict(n: ExprNode) -> Dictionary:
	var d := {"t": ExprNode.Type.keys()[n.type]}
	if n.key != "":
		d["key"] = n.key
	if n.value != 0.0:
		d["v"] = n.value
	if n.target != "":
		d["target"] = n.target
	if not n.keys.is_empty():
		d["keys"] = n.keys
	if n.ref_event_id != "":
		d["ref"] = n.ref_event_id
	if n.overlord_tag != "":
		d["overlord"] = n.overlord_tag
	if not n.children.is_empty():
		var ch := []
		for c in n.children:
			ch.append(_expr_dict(c))
		d["c"] = ch
	return d


func _fx_dict(n: EffectNode, host_path: String) -> Dictionary:
	var d := {"t": EffectNode.Type.keys()[n.type]}
	if n.key != "":
		d["key"] = n.key
	if n.value != 0.0:
		d["v"] = n.value
	if n.target != "ROOT":
		d["target"] = n.target
	if n.type == EffectNode.Type.CUSTOM_SCRIPT:
		if n.custom_script == null:
			anomalies.append("%s：CUSTOM_SCRIPT 效果缺少脚本引用" % host_path)
		elif host_path == "" or n.custom_script.resource_path != host_path:
			d["script"] = n.custom_script.resource_path
		# 指向宿主自身 → 省略，构建器解析为宿主脚本
	if n.condition != null:
		d["if"] = _expr_dict(n.condition)
	return d


## 「结果由 xxx.gd 动态生成」类占位文本：真实文案在脚本里，不进 META 也不进 CSV
func _is_placeholder_result(s: String) -> bool:
	return s.contains("动态生成") and s.begins_with("（") and s.ends_with("）")


func _option_dict(opt: EventOption, index: int, host_path: String) -> Dictionary:
	var d := {}
	if opt.text == "":
		d["notext"] = true
	if opt.disabled_text != "":
		d["disabled"] = true
	if opt.result_text != "":
		if _is_placeholder_result(opt.result_text):
			stats["placeholders"] += 1
		else:
			d["result"] = true
	if opt.result_title != "":
		d["result_title"] = true
	if opt.enable_condition != null:
		d["cond"] = _expr_dict(opt.enable_condition)
	var fxs := []
	for fx in opt.effects:
		fxs.append(_fx_dict(fx, host_path))
	if not fxs.is_empty():
		d["fx"] = fxs
	return d


# ────────────────────────────────────────────────────────────────────────────
# 代码发射
# ────────────────────────────────────────────────────────────────────────────

func _meta_source(meta: Dictionary) -> String:
	var lines := ["const META := {"]
	for k in meta.keys():
		lines.append("\t%s: %s," % [_gd_string(str(k)), _gd_value(meta[k])])
	lines.append("}")
	return "\n".join(lines)


func _gd_value(v) -> String:
	if v is Dictionary:
		var inner := []
		for k in v.keys():
			inner.append("%s: %s" % [_gd_string(str(k)), _gd_value(v[k])])
		return "{%s}" % ", ".join(inner)
	if v is Array:
		var items := []
		for item in v:
			items.append(_gd_value(item))
		return "[%s]" % ", ".join(items)
	if v is float or v is int:
		var fv := float(v)
		if is_equal_approx(fv, roundf(fv)) and absf(fv) < 9e15:
			return str(int(fv))
		return str(fv)
	if v is bool:
		return "true" if v else "false"
	return _gd_string(str(v))


func _gd_string(s: String) -> String:
	var out := s
	out = out.replace("\\", "\\\\")
	out = out.replace("\"", "\\\"")
	out = out.replace("\r", "")
	out = out.replace("\n", "\\n")
	out = out.replace("\t", "\\t")
	return "\"%s\"" % out


func _global(p: String) -> String:
	return ProjectSettings.globalize_path(p)


func _merge_meta_into(script_path: String, stem: String, meta: Dictionary) -> bool:
	var f := FileAccess.open(_global(script_path), FileAccess.READ)
	if f == null:
		anomalies.append("%s：合并目标不可读" % script_path)
		return false
	var src := f.get_as_text()
	f.close()
	# 幂等：先剥掉上次追加的 META 块（从 banner 的 "# ═" 首行到文件尾）
	var mark_at := src.rfind(MERGE_BANNER_MARK)
	if mark_at >= 0:
		var banner_start := src.rfind("\n# ═", mark_at)
		if banner_start < 0:
			anomalies.append("%s：发现残留 META 块但无法定位边界，拒绝处理" % script_path)
			return false
		src = src.substr(0, banner_start)
	if src.contains("const META"):
		anomalies.append("%s：存在非本工具生成的 const META，拒绝覆盖" % script_path)
		return false
	var banner := "\n\n# ══════════════════════════════════════════════════════════\n"
	banner += "# 自动迁移的事件定义 —— 源： 场景/事件界面/events/%s.tres\n" % stem
	banner += "# 文案不在本文件，见 资产/本地化/events_zh_CN.csv\n"
	banner += "# ══════════════════════════════════════════════════════════\n"
	var wf := FileAccess.open(_global(script_path), FileAccess.WRITE)
	if wf == null:
		anomalies.append("%s：合并目标不可写" % script_path)
		return false
	wf.store_string(src.trim_suffix("\n") + "\n" + banner + _meta_source(meta) + "\n")
	wf.close()
	return true


func _write_standalone(stem: String, meta: Dictionary, refs: Array) -> String:
	DirAccess.make_dir_recursive_absolute(_global(STANDALONE_DIR))
	var path := STANDALONE_DIR + stem + ".gd"
	var note := ""
	if not refs.is_empty():
		note += "## 共享效果脚本（未合并进本文件）：\n"
		for r in refs:
			note += "##   %s\n" % str(r)
	var src := "extends EventScriptBase\n\n"
	src += "## 自动迁移自 场景/事件界面/events/%s.tres\n" % stem
	src += note
	src += "## 文案见 资产/本地化/events_zh_CN.csv\n\n"
	src += _meta_source(meta) + "\n"
	var wf := FileAccess.open(_global(path), FileAccess.WRITE)
	if wf == null:
		anomalies.append("无法写入 %s" % path)
		return ""
	wf.store_string(src)
	wf.close()
	return path


# ────────────────────────────────────────────────────────────────────────────
# CSV 导出
# ────────────────────────────────────────────────────────────────────────────

func _collect_csv_rows(def: EventDef, source: String) -> void:
	var eid := def.event_id
	if eid == "":
		anomalies.append("事件缺少 id：%s" % source)
		return
	if def.title != "":
		_row(EventText.event_key(eid, "title"), def.title)
	if def.description != "":
		_row(EventText.event_key(eid, "desc"), def.description)
	for i in def.options.size():
		var o := def.options[i]
		if o.text != "":
			_row(EventText.option_key(eid, i, "text"), o.text)
		if o.disabled_text != "":
			_row(EventText.option_key(eid, i, "disabled"), o.disabled_text)
		if o.result_text != "" and not _is_placeholder_result(o.result_text):
			_row(EventText.option_key(eid, i, "result"), o.result_text)
		if o.result_title != "":
			_row(EventText.option_key(eid, i, "result_title"), o.result_title)


func _row(key: String, text: String) -> void:
	csv_rows.append("%s,%s" % [key, _csv_cell(text)])
	stats["csv_rows"] += 1


func _csv_cell(s: String) -> String:
	if s.contains(",") or s.contains("\"") or s.contains("\n") or s.contains("\r"):
		return "\"%s\"" % s.replace("\"", "\"\"")
	return s


func _write_csv() -> void:
	DirAccess.make_dir_recursive_absolute(_global("res://资产/本地化/"))
	var f := FileAccess.open(CSV_PATH, FileAccess.WRITE)
	f.store_line("keys,zh_CN")
	for r in csv_rows:
		f.store_line(r)
	f.close()
