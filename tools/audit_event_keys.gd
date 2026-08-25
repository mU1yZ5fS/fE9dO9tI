# ============================================================================
# audit_event_keys.gd — 事件本地化键完整性审计（可持续运行的 linter）
# ============================================================================
# 运行：Godot --headless --path . --script res://tools/audit_event_keys.gd
#
# 检查三类键是否都能在 资产/本地化/events_zh_CN.csv 命中：
#   A. 结构键：构建全部 META 得到的 title/desc/option_N.text/disabled/result/result_title
#   B. 脚本常量：效果脚本里 const TXT_* := "event.script.…"
#   C. 脚本内联：代码里 tr("event.script.…") / EventText.fmt("…") 字面量
# 缺失键会在玩家界面显示为原始键名，必须清零。
# ============================================================================
extends SceneTree

const SCRIPT_DIR := "res://数据脚本/事件效果/"
const STANDALONE_DIR := "res://数据脚本/事件定义/"
const MANIFEST_PATH := "res://tools/migration_manifest.json"
const CSV_PATH := "res://资产/本地化/events_zh_CN.csv"
const RE_SCRIPT_KEY := "\"(event\\.script\\.[^\"]+)\""


func _initialize() -> void:
	var mf := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	var manifest: Dictionary = JSON.parse_string(mf.get_as_text())
	mf.close()
	var events: Dictionary = manifest["events"]

	# CSV 键集合
	var csv := {}
	var f := FileAccess.open(CSV_PATH, FileAccess.READ)
	f.get_line()
	while not f.eof_reached():
		var line := f.get_line()
		var ci := line.find(",")
		if ci > 0:
			csv[line.substr(0, ci)] = true
	f.close()

	var missing := {}
	var total := 0

	# ── A. 结构键 ──
	for stem in events:
		var info: Dictionary = events[stem]
		var scr := load(String(info["def"])) as GDScript
		if scr == null:
			missing["[构建失败] " + String(info["def"])] = true
			continue
		var def := EventDefBuilder.build_from_script(scr)
		if def == null:
			missing["[META缺失] " + String(info["def"])] = true
			continue
		total += 1
		if not bool(scr.get_script_constant_map()["META"].get("notitle", false)):
			_check(csv, missing, EventText.event_key(def.event_id, "title"))
		if not bool(scr.get_script_constant_map()["META"].get("nodesc", false)):
			_check(csv, missing, EventText.event_key(def.event_id, "desc"))
		for i in def.options.size():
			if def.options[i] == null:
				continue
			if def.options[i].text != "":
				_check(csv, missing, EventText.option_key(def.event_id, i, "text"))
			if def.options[i].disabled_text != "":
				_check(csv, missing, EventText.option_key(def.event_id, i, "disabled"))
			if def.options[i].result_text != "":
				_check(csv, missing, EventText.option_key(def.event_id, i, "result"))
			if def.options[i].result_title != "":
				_check(csv, missing, EventText.option_key(def.event_id, i, "result_title"))

	# ── B/C. 脚本键 ──
	var re := RegEx.create_from_string(RE_SCRIPT_KEY)
	var re_const := RegEx.create_from_string("(?m)^\\t*const\\s+[A-Za-z_][A-Za-z0-9_]*\\s*:?=(\\s*)\"(event\\.[^\"]+)\"")
	for dir_path in [SCRIPT_DIR, STANDALONE_DIR]:
		for fp in ResScan.list_files(dir_path, [".gd"]):
			var ff := FileAccess.open(fp, FileAccess.READ)
			if ff == null:
				continue
			var src := ff.get_as_text()
			ff.close()
			for m in re.search_all(src):
				_check(csv, missing, m.get_string(1))

	print("=========================================")
	print("审计完成：%d 个事件，%d 个缺失键" % [total, missing.size()])
	for k in missing.keys():
		print("  ✗ 缺失: " + str(k))
	quit(0 if missing.is_empty() else 1)


func _check(csv: Dictionary, missing: Dictionary, key: String) -> void:
	if not csv.has(key):
		missing[key] = true
