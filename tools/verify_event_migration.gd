# ============================================================================
# verify_event_migration.gd — .tres ↔ META 脚本 双路径全量对比校验
# ============================================================================
# 运行方式：
#   Godot --headless --path . --script res://tools/verify_event_migration.gd
#
# 对每个事件：旧路径 load(.tres) 得 EventDef A；新路径按清单加载定义脚本，
# 经 EventDefBuilder 构建 EventDef B；递归对比两棵对象树的全部字段。
# 任何不一致 → 打印差异并以非零码退出。文案字段按约定特殊处理：
#   A.title = 中文原文，B.title = "event.<id>.title" key —— 校验"空/非空一致性
#   + key 拼写正确"，实际译文由 CSV 导入链路保证。
# ============================================================================
extends SceneTree

const EVENT_DIR := "res://场景/事件界面/events/"
const MANIFEST_PATH := "res://tools/migration_manifest.json"

var checked := 0
var failures := 0


func _initialize() -> void:
	var mf := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if mf == null:
		push_error("缺少清单 %s（先运行 migrate_events_to_gd.gd）" % MANIFEST_PATH)
		quit(1)
		return
	var manifest: Dictionary = JSON.parse_string(mf.get_as_text())
	mf.close()
	var events: Dictionary = manifest.get("events", {})

	var tres_paths := ResScan.list_files(EVENT_DIR, [".tres"])
	if tres_paths.size() != events.size():
		print("!! 清单事件数 %d ≠ .tres 数 %d" % [events.size(), tres_paths.size()])

	for p in tres_paths:
		var stem := String(p).get_file().get_basename()
		if not events.has(stem):
			_fail(stem, "清单中缺失")
			continue
		var old_def := load(p) as EventDef
		var info: Dictionary = events[stem]
		var scr := load(String(info["def"])) as GDScript
		if old_def == null or scr == null:
			_fail(stem, "加载失败 old=%s script=%s" % [old_def != null, scr != null])
			continue
		var new_def := EventDefBuilder.build_from_script(scr)
		if new_def == null:
			_fail(stem, "META 构建失败")
			continue
		var diffs := _compare_defs(old_def, new_def)
		checked += 1
		for d in diffs:
			_fail(stem, d)

	print("==========================================")
	print("校验完成：%d 个事件，%d 个不一致" % [checked, failures])
	print("==========================================")
	quit(0 if failures == 0 else 1)


func _fail(stem: String, msg: String) -> void:
	failures += 1
	if failures <= 60:
		print("✗ %s: %s" % [stem, msg])


# ────────────────────────────────────────────────────────────────────────────
# 结构化深度对比
# ────────────────────────────────────────────────────────────────────────────

func _compare_defs(a: EventDef, b: EventDef) -> Array[String]:
	var out: Array[String] = []
	_eq(out, a.event_id, b.event_id, "event_id")
	_eq(out, a.source_event_number, b.source_event_number, "source_event_number")
	_eq(out, a.trigger_priority, b.trigger_priority, "trigger_priority")
	_eq(out, a.show_notification, b.show_notification, "show_notification")
	_eq(out, a.notification_days, b.notification_days, "notification_days")
	_eq(out, a.timeout_agents_penalty, b.timeout_agents_penalty, "timeout_agents_penalty")
	_eq(out, a.timeout_budget_penalty, b.timeout_budget_penalty, "timeout_budget_penalty")
	_eq(out, a.fire_only_once, b.fire_only_once, "fire_only_once")
	_eq(out, a.dlc, b.dlc, "dlc")
	# 文案：空/非空奇偶一致 + key 约定正确
	_text_slot(out, a.title, b.title, "title", EventText.event_key(b.event_id, "title"))
	_text_slot(out, a.description, b.description, "desc", EventText.event_key(b.event_id, "desc"))
	_res_ref(out, a.image, b.image, "image")
	_res_ref(out, a.display_script, b.display_script, "display_script")
	_res_ref(out, a.trigger_script, b.trigger_script, "trigger_script")
	_str_arr(out, a.triggers_on_complete, b.triggers_on_complete, "triggers_on_complete")

	if a.trigger_conditions.size() != b.trigger_conditions.size():
		out.append("trigger_conditions 数量 %d≠%d" % [a.trigger_conditions.size(), b.trigger_conditions.size()])
	else:
		for i in a.trigger_conditions.size():
			_cmp_expr(out, a.trigger_conditions[i], b.trigger_conditions[i], "trigger[%d]" % i)

	if a.options.size() != b.options.size():
		out.append("options 数量 %d≠%d" % [a.options.size(), b.options.size()])
	else:
		for i in a.options.size():
			_cmp_option(out, a.options[i], b.options[i], i, b.event_id)
	return out


func _cmp_option(out: Array[String], a: EventOption, b: EventOption, i: int, eid: String) -> void:
	var tag := "opt%d" % i
	_text_slot(out, a.text, b.text, tag + ".text", EventText.option_key(eid, i, "text"))
	_text_slot(out, a.disabled_text, b.disabled_text, tag + ".disabled",
			EventText.option_key(eid, i, "disabled"))
	_text_slot(out, a.result_text, b.result_text, tag + ".result",
			EventText.option_key(eid, i, "result"))
	_text_slot(out, a.result_title, b.result_title, tag + ".result_title",
			EventText.option_key(eid, i, "result_title"))
	if (a.enable_condition == null) != (b.enable_condition == null):
		out.append(tag + ".cond null 性不一致")
	elif a.enable_condition != null:
		_cmp_expr(out, a.enable_condition, b.enable_condition, tag + ".cond")
	if a.effects.size() != b.effects.size():
		out.append("%s.fx 数量 %d≠%d" % [tag, a.effects.size(), b.effects.size()])
	else:
		for k in a.effects.size():
			_cmp_fx(out, a.effects[k], b.effects[k], "%s.fx[%d]" % [tag, k])


func _cmp_expr(out: Array[String], a: ExprNode, b: ExprNode, tag: String) -> void:
	if a == null or b == null:
		_eq(out, a != null, b != null, tag + ".null")
		return
	_eq(out, a.type, b.type, tag + ".type")
	_eq(out, a.key, b.key, tag + ".key")
	_eq(out, a.value, b.value, tag + ".value")
	_eq(out, a.target, b.target, tag + ".target")
	_eq(out, a.ref_event_id, b.ref_event_id, tag + ".ref")
	_eq(out, a.overlord_tag, b.overlord_tag, tag + ".overlord")
	_str_arr(out, a.keys, b.keys, tag + ".keys")
	if a.children.size() != b.children.size():
		out.append("%s.c 数量 %d≠%d" % [tag, a.children.size(), b.children.size()])
	else:
		for i in a.children.size():
			_cmp_expr(out, a.children[i], b.children[i], "%s.c[%d]" % [tag, i])


func _cmp_fx(out: Array[String], a: EffectNode, b: EffectNode, tag: String) -> void:
	_eq(out, a.type, b.type, tag + ".type")
	_eq(out, a.key, b.key, tag + ".key")
	_eq(out, a.value, b.value, tag + ".value")
	_eq(out, a.target, b.target, tag + ".target")
	_res_ref(out, a.custom_script, b.custom_script, tag + ".script")
	if (a.condition == null) != (b.condition == null):
		out.append(tag + ".if null 性不一致")
	elif a.condition != null:
		_cmp_expr(out, a.condition, b.condition, tag + ".if")


# ── 基础比较助手 ──

func _eq(out: Array[String], a, b, tag: String) -> void:
	if a is float or b is float:
		if not is_equal_approx(float(a), float(b)):
			out.append("%s: %s ≠ %s" % [tag, a, b])
		return
	if a != b:
		out.append("%s: %s ≠ %s" % [tag, a, b])


## 文案槽位：空/非空奇偶必须一致；非空时 B 必须等于约定 key。
## 「（…xxx.gd…）」类开发占位（结果由/选项文本由/描述由 … 生成、动态设置等）
## 一律视同为空——真实文案在脚本里，见提取器与 clean_placeholder_slots 工具。
func _text_slot(out: Array[String], src_text: String, key_text: String,
		tag: String, expect_key: String) -> void:
	var t := src_text.strip_edges()
	if t.begins_with("（") and t.ends_with("）") and t.contains(".gd"):
		src_text = ""
	if (src_text == "") != (key_text == ""):
		out.append("%s 空/非空不一致（原文 %d 字）" % [tag, src_text.length()])
	elif key_text != "" and key_text != expect_key:
		out.append("%s key 不符：%s ≠ %s" % [tag, key_text, expect_key])


func _res_ref(out: Array[String], a: Resource, b: Resource, tag: String) -> void:
	var ap := a.resource_path if a != null else ""
	var bp := b.resource_path if b != null else ""
	if ap != bp:
		out.append("%s: '%s' ≠ '%s'" % [tag, ap, bp])


func _str_arr(out: Array[String], a, b, tag: String) -> void:
	var aa: Array = a
	var bb: Array = b
	if aa.size() != bb.size():
		out.append("%s 数量 %d≠%d" % [tag, aa.size(), bb.size()])
		return
	for i in aa.size():
		if str(aa[i]) != str(bb[i]):
			out.append("%s[%d]: %s ≠ %s" % [tag, i, aa[i], bb[i]])
