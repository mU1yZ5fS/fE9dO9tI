# ============================================================================
# test_color_dynamic.gd — 颜色还原 + 动态变量链路验证（临时测试）
# 运行：Godot --headless --path . --script res://tools/test_color_dynamic.gd
# ============================================================================
extends SceneTree

var fails := 0


func _initialize() -> void:
	# ── 1. 动态变量：tr() 解析出含 {0}{1} 占位的模板（领袖名后填）──
	var key := "event.script.event_053_062_reform_and_alliances.c2"
	var tpl := tr(key)
	_ok(not tpl.begins_with("event."), "tr 命中译文（不回显键）")
	_ok(tpl.contains("{0}") and tpl.contains("{1}"), "模板保留 {0}{1} 占位")
	# 模拟 _fmt_leader：占位替换后仍是纯文本
	var filled: String = tpl.format({"0": "吴", "1": "努"}, "{_}")
	_ok(not filled.contains("{0}"), "format 后占位被领袖名替换")

	# ── 2. EventText.t 双向行为 ──
	_ok(EventText.t("普通中文句子。") == "普通中文句子。", "字面量透传不被翻译")
	_ok(EventText.t(key) == tpl, "键经 EventText.t 正常解析")

	# ── 3. 颜色还原：JSON 片段子串匹配在译文字符串上仍然生效 ──
	var frag := _first_fragment()
	_ok(frag != "", "颜色片段 JSON 加载成功")
	if frag != "":
		var restored := BbcTooltip.event_text_to_bbcode(frag, "1000")
		_ok(restored.contains("[color="), "UI 全管线：片段命中并注入 [color=] BBCode")

	# ── 4. 端到端：CSV 标题键 → tr → 事件文本 BBCode 管线 ──
	var title := EventText.t(tr("event.death_of_mao.title"))
	_ok(title == "舵手逝世", "事件标题端到端解析（death_of_mao）")

	print("=========================================")
	if fails == 0:
		print("全部通过")
	else:
		print("失败 %d 例" % fails)
	quit(0 if fails == 0 else 1)


func _first_fragment() -> String:
	var f := FileAccess.open("res://资产/数据/event_color_fragments.json", FileAccess.READ)
	if f == null:
		return ""
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if data is Dictionary and data.has("1000"):
		var arr: Array = data["1000"]
		if arr.size() > 0 and arr[0].has("plain"):
			return String(arr[0]["plain"])
	return ""


func _ok(cond: bool, tag: String) -> void:
	if cond:
		print("✓ " + tag)
	else:
		fails += 1
		print("✗ " + tag)
