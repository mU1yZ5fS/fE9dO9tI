# ============================================================================
# test_format_layout.gd — _apply_layout 排版逻辑临时测试（一次性）
# 运行：Godot --headless --path . --script res://tools/test_format_layout.gd
# ============================================================================
extends SceneTree

const INDENT := "[color=#00000000]中中[/color]"
var fails := 0


func _initialize() -> void:
	var script := load("res://场景/事件界面/事件.gd")
	var f: Callable = Callable(script, "_apply_layout")

	# 1. 无标记 + 间距开：与旧算法等价（非空行缩进、\n\n 连接）
	var r1: String = f.call("第一段。\n第二段。\n\n第三段。", true, true)
	_expect(r1, INDENT + "第一段。\n\n" + INDENT + "第二段。\n\n" + INDENT + "第三段。", "无标记/间距开")

	# 2. 无标记 + 全关：原样返回路径（_format_event_text 快速返回；这里直接测纯函数）
	var r2: String = f.call("甲。\n乙。", false, false)
	_expect(r2, "甲。\n乙。", "无标记/全关")

	# 3. 诗歌块 + 间距开：诗行紧凑无缩进，块边界保留一个段距
	var poem := "正文开头。\n[原样]\n床前明月光\n疑是地上霜\n[/原样]\n正文结尾。"
	var r3: String = f.call(poem, true, true)
	_expect(r3,
		INDENT + "正文开头。\n\n床前明月光\n疑是地上霜\n\n" + INDENT + "正文结尾。",
		"诗歌夹心/间距开缩进开")

	# 4. 设置全关但有标记：标记剥除、诗行保持、边界单换行
	var r4: String = f.call(poem, false, false)
	_expect(r4, "正文开头。\n床前明月光\n疑是地上霜\n正文结尾。", "诗歌夹心/全关")

	# 5. 未闭合标记：剥掉 [原样]，剩余按原样处理到文末（间距开 → 边界保留段距）
	var r5: String = f.call("引子。\n[原样]\n独行\n潭底影", false, true)
	_expect(r5, "引子。\n\n独行\n潭底影", "未闭合标记")

	# 6. 标记在文首 / 连续两块
	var r6: String = f.call("[原样]\n其一\n其二\n[/原样]\n[原样]\n其三\n[/原样]\n跋。", false, true)
	_expect(r6, "其一\n其二\n\n其三\n\n跋。", "文首双块+尾段")

	# 7. 诗内部空行保留（作者自控 stanza 间距），不受设置影响
	var r7: String = f.call("[原样]\n上句\n\n下句\n[/原样]", true, false)
	_expect(r7, "上句\n\n下句", "诗内空行保留")

	print("=========================================")
	if fails == 0:
		print("全部通过")
	else:
		print("失败 %d 例" % fails)
	quit(0 if fails == 0 else 1)


func _expect(got: String, want: String, tag: String) -> void:
	if got == want:
		print("✓ " + tag)
	else:
		fails += 1
		print("✗ " + tag)
		print("   期望: " + want.replace("\n", "␤"))
		print("   实际: " + got.replace("\n", "␤"))
