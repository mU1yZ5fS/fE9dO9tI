extends EventScriptBase

# ============================================================================
# 本地化与排版测试事件（手动触发：调试控制台 start_event("test_localization")）
# ============================================================================
# 覆盖能力清单：
#   - BBCode 全样式：[b][i][u][s][color][code][center]（描述/结果为 RichTextLabel 生效；
#     标题与选项按钮是 Label，样式标签不解析——这是平台约束不是缺陷）
#   - [原样]…[/原样] 块：内部换行不受玩家缩进/段距设置影响
#   - 动态变量：EventText.fmt(key, vars) 填充 {0}{1}… 占位
#   - 当前领袖 / 五派系领袖 / 政治家字段实时读取
#   - 门槛选项：enable_condition 不满足时的禁用文案
#   - 结果页动态文案：execute 里组装、无静态 result 键的路径
#
# 文案本体在 资产/本地化/events_zh_CN.csv 的 event.test_localization.* / tpl_* 键下。
# ============================================================================

const SELF_PATH := "res://数据脚本/事件效果/event_test_localization.gd"

## 颜色样例（原版风格）
const C_GOLD := "#C8A457"
const C_GREEN := "#7FD17F"
const C_RED := "#E06C5A"
const C_GREY := "#9AA0A6"


## 显示前组装描述：所有动态内容在这里落到 event_def.description
func prepare(_event_def: EventDef, _p_ws: WorldState) -> void:
	if not _bind_world():
		return
	var lines: Array[String] = []

	lines.append("[center][b][color=%s]★ 本地化与排版测试场 ★[/color][/b][/center]" % C_GOLD)
	lines.append("本页集中验证样式与变量。[b]粗体[/b]、[i]斜体[/i]、[u]下划线[/u]、[s]删除线[/s]、[color=%s]自定义颜色[/color]、[code]等宽 Code[/code] 混排。" % C_GREEN)
	lines.append(tr("event.test_localization.intro"))

	# ── 当前领袖 ──
	var ln := "——"
	var age := 0
	if ws.leader != null:
		ln = ws.leader.name_display
		age = ws.leader.age
	lines.append(EventText.fmt("event.test_localization.tpl_leader",
			{"0": "[b][color=%s]%s[/color][/b]" % [C_RED, ln], "1": age,
			"2": _safe_leader_power(), "3": _leader_faction_name()}))

	# ── 五大派系与其领袖 ──
	lines.append(tr("event.test_localization.faction_header"))
	for fi in ws.factions.size():
		var fa = ws.factions[fi]
		if fa == null or not fa.is_enabled:
			continue
		var ltext := ""
		if fa.leader_index == -2:
			ltext = ln
		elif fa.leader_index >= 0 and fa.leader_index < ws.politicians.size() \
				and ws.politicians[fa.leader_index] != null:
			ltext = ws.politicians[fa.leader_index].name_display
		if ltext == "":
			lines.append(EventText.fmt("event.test_localization.tpl_faction_empty",
					{"0": fa.name}))
		else:
			var ally_mark := " [color=%s][盟][/color]" % C_GREEN if fa.is_ally else ""
			lines.append(EventText.fmt("event.test_localization.tpl_faction",
					{"0": fa.name, "1": fa.support, "2": ltext}) + ally_mark)

	# ── 数值变量 ──
	# 预算/党内支持/民众支持/军力内部按 ×10 存储，显示时 ÷10
	lines.append(EventText.fmt("event.test_localization.tpl_vars",
			{"0": _disp(d.budget), "1": _disp(d.party_support),
			"2": _disp(d.people_support), "3": _disp(d.army),
			"4": "%d-%d-%d" % [d.year, d.month, d.day]}))

	# ── 原样块：诗行不受排版设置影响 ──
	lines.append(tr("event.test_localization.poem_intro"))
	lines.append("[原样]\n北国风光，\n千里冰封，\n万里雪飘。\n[/原样]")
	lines.append(tr("event.test_localization.outro"))

	_event_def.description = "\n".join(lines)


## 内部 ×10 数值的显示换算
func _disp(v: int) -> int:
	return int(round(v / 10.0))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	match int(context.get("option_index", -1)):
		1:
			# 动态结果：无静态 result 键，完全由脚本填充
			context["result_text"] = EventText.fmt(
					"event.test_localization.opt1_result",
					{"0": d.year, "1": d.month, "2": _disp(d.budget),
					"3": ws.leader.name_display if ws.leader != null else "——"})
		3:
			# 样式全开的结果页 + 原样诗块
			context["result_text"] = tr("event.test_localization.opt3_result")


func _safe_leader_power() -> int:
	return ws.leader.power if ws.leader != null else 0


## 领袖所属派系名（politician.faction → factions[i].name；无效时返回破折号）
func _leader_faction_name() -> String:
	if ws.leader == null:
		return "——"
	var fi: int = ws.leader.faction
	if fi >= 0 and fi < ws.factions.size() and ws.factions[fi] != null 			and ws.factions[fi].name != "":
		return ws.factions[fi].name
	return "——"


# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 手写测试事件（非 .tres 迁移产物）
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "test_localization",
	"nodesc": true,
	"display_script": "res://数据脚本/事件效果/event_test_localization.gd",
	"options": [
		{"result": true},
		{"fx": [{"t": "CUSTOM_SCRIPT"}]},
		{"disabled": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "money", "v": 100000000}},
		{"fx": [{"t": "CUSTOM_SCRIPT"}]},
	],
}
