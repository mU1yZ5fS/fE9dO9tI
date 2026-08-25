class_name EventGraphData
extends RefCounted

# ============================================================================
# 事件拓扑数据层（只读）—— migration_manifest → META 常量 → 图模型。
# ============================================================================
# 用途：event_graph_viewer 场景的数据源；也可供调试工具导出 JSON。
# 安全性：只 load 脚本读取 const META，绝不实例化、不调用 prepare()/execute()；
#         CUSTOM_SCRIPT 内部语义不做解析，仅记录脚本路径与头部 ## 声明。
#
# 事件间引用边（out_refs）来自三处：
#   1. 触发/门槛条件里的 PREV_EVENT_DONE / PREV_EVENT_RESULT_IS / PREV_EVENT_NOT_DONE
#   2. fx 里的 TRIGGER_EVENT（key=目标事件）
#   3. 效果脚本源码中的 start_event("xxx") 字面量（正则，尽力而为）
# ============================================================================

const LX := preload("res://数据脚本/systems/event_graph_lexicon.gd")
const MANIFEST_PATH := "res://tools/migration_manifest.json"

## 引用提取的正则：脚本内显式 start_event 调用（仅字面量参数）
const RX_START_EVENT := "start_event\\(\\s*\"([\\w]+)\""
## CUSTOM_SCRIPT 里的事件文案键（动态结果候选）
const RX_TEXT_KEY := "(?:tr|EventText\\.t|EventText\\.fmt)\\(\\s*\"(event\\.[^\"]+)\""
const RX_ANY_EVENT_KEY := "\"(event\\.[\\w\\.]+)\""
const RX_CONST_KEY := "const\\s+(\\w+)\\s*:?=?\\s*\"(event\\.[\\w\\.]+)\""
const RX_CONST_REF := "\\b(?:tr|EventText\\.t|EventText\\.fmt)\\(\\s*([A-Z_][A-Z0-9_]{2,})"
const NL_LIT := "\n"
const RX_EID_ENTRY := '^\"([\\w]+)\":\\s*(.*)$'
const RX_HELPER_CALL := "(_?[A-Za-z]\\w*)\\s*\\("
## set_map_region_owner([地块...], 国家gwcode)
const RX_REGION_GIVE := "set_map_region_owner\\(\\s*\\[([0-9,\\s]*)\\]\\s*,\\s*(\\d+)"
const RX_EFFECT_LINE := "(relations|current_leader|\\.support|loyalty|d\\.\\w+\\s*(?:\\+=|-=|=)|_add\\(|_set_data\\(|_res\\(|set_flag|add_data_by_index|set_data_by_index|queue_ending|start_war|set_map_region_owner|_disable\\(|_enable\\(|_add_relation|_add_power|_leave_alliances|_join_alliances|_swap_leader|_leader_support|_change_loyalty|completed_event_ids)"
const RX_BRANCH_IF := "^(?:el)?if\\b[^\\n]*?\\bopt\\w*\\s*==\\s*(\\d+)"
static var _scan_cache := {}

static var _src_cache := {}


## 外部文本嵌入 BBCode 前的统一转义：剥 [原样] 标记、'[' → '[lb]'。
static func esc(s: String) -> String:
	return s.replace("[原样]", "").replace("[/原样]", "").replace("[", "[lb]")


## 数值显示：tenfold 键 ÷10，保留至多 1 位小数
static func disp_value(raw: float, tenfold: bool) -> String:
	var v := raw / 10.0 if tenfold else raw
	return String.num(v, 0) if is_equal_approx(v, round(v)) else String.num(v, 1)


static func _script_src(path: String) -> String:
	if path == "":
		return ""
	if not _src_cache.has(path):
		var scr: GDScript = load(path) if path.begins_with("res://") else null
		_src_cache[path] = scr.source_code if scr != null else ""
	return _src_cache[path]


class OptRow:
	extends RefCounted
	var index := 0
	var text := ""                    ## 已翻译的选项文本（未命中则原 key）
	var disabled_text := ""           ## 已翻译的门槛提示（可为空）
	var cond_bbcode := ""             ## 条件树 BBCode（cond_to_bbcode 产物）
	var fx_lines: Array[String] = []  ## 每条效果一行的摘要
	var result_text := ""             ## 已翻译的静态结果（空=脚本动态结果）
	var refs: Array[String] = []      ## 本选项引用的事件标识


var stem := ""                     ## manifest 键，如 event_117_five_year_funeral
var id := ""                       ## META id，如 five_year_funeral
var num := -1
var title := ""                    ## 已翻译标题（未命中回退 stem）
var def_path := ""                 ## META 所在脚本 res:// 路径
var notes: Array[String] = []      ## 头部 ## 差异/原作 声明行
var trigger_list := []             ## 触发条件原始 Dict 数组（隐含 AND，保留供导出）
var trigger_bbcode := ""           ## 触发条件树 BBCode
var options: Array[OptRow] = []
var out_refs: Array[String] = []   ## 引用的其它事件标识（去重保序）


## ── 全量构建 ──────────────────────────────────────────────────────────────
## 每处理 batch 个事件回调一次 progress(已完成, 总数)（供 UI await 刷新）。
## 返回按 num 升序（num<0 排最后）的模型数组。
static func load_all(progress: Callable = Callable(), batch := 40) -> Array[EventGraphData]:
	var out: Array[EventGraphData] = []
	var mf := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if mf == null:
		push_warning("EventGraphData: 找不到 %s" % MANIFEST_PATH)
		return out
	var parsed: Variant = JSON.parse_string(mf.get_as_text())
	var events: Dictionary = parsed.get("events", {}) if parsed is Dictionary else {}
	mf.close()
	var i := 0
	for st in events.keys():
		var node := _build_one(st, events[st])
		if node != null:  # 单事件解析失败不拖垮全量
			out.append(node)
		else:
			push_warning("EventGraphData: 解析失败 %s" % st)
		i += 1
		if i % batch == 0:
			if progress.is_valid():
				progress.call(i, events.size())
			# 静态协程：分帧让出主线程，UI 才能刷新进度
			await Engine.get_main_loop().process_frame
	if progress.is_valid():
		progress.call(events.size(), events.size())
	out.sort_custom(func(a, b): return _sort_key(a) < _sort_key(b))
	return out


static func _sort_key(n: EventGraphData) -> String:
	return "%06d|%s" % [n.num if n.num >= 0 else 999999, n.stem]


static func _build_one(p_stem: String, info: Dictionary) -> EventGraphData:
	var n := EventGraphData.new()
	n.stem = p_stem
	n.id = str(info.get("id", ""))
	n.num = int(info.get("num", -1))
	n.def_path = str(info.get("def", "")).replace("\\", "/")

	var scr: GDScript = null
	if n.def_path.begins_with("res://"):
		scr = load(n.def_path)
	var consts: Dictionary = scr.get_script_constant_map() if scr != null else {}
	var meta: Dictionary = consts.get("META", {}) if consts.has("META") else {}

	if n.id == "":
		n.id = str(meta.get("id", p_stem))
	n.title = EventText.t("event.%s.title" % n.id)
	if n.title.begins_with("event."):
		n.title = p_stem  # 未命中翻译回退
	n.trigger_list = meta.get("trigger", [])
	var trig_lines: Array[String] = []
	for cd in n.trigger_list:
		if cd is Dictionary and not (cd as Dictionary).is_empty():
			trig_lines.append(cond_to_bbcode(cd))
	n.trigger_bbcode = "\n".join(trig_lines) if trig_lines.size() > 0 \
			else "[color=#9aa0a6]（无条件）[/color]"

	for i in meta.get("options", []).size():
		n.options.append(_build_option(n.id, i, meta["options"][i], n.def_path, n))
	_collect_refs(n)

	if scr != null:  # 头部声明 + 脚本字面量引用
		for line in scr.source_code.split("\n"):
			var s := line.strip_edges()
			if s.begins_with("##"):
				var body := s.lstrip("#").strip_edges()
				if body.begins_with("差异") or body.begins_with("原作"):
					n.notes.append(body)
		var rx := RegEx.create_from_string(RX_START_EVENT)
		for m in rx.search_all(scr.source_code):
			_add_ref(n, m.get_string(1))
	return n


static func _build_option(event_id: String, idx: int, o: Dictionary,
		host_path := "", node: EventGraphData = null) -> OptRow:
	var r := OptRow.new()
	r.index = idx
	r.text = EventText.t(EventText.option_key(event_id, idx, "text"))
	if bool(o.get("disabled", false)):
		r.disabled_text = EventText.t(EventText.option_key(event_id, idx, "disabled"))
	if bool(o.get("result", false)):
		r.result_text = EventText.t(EventText.option_key(event_id, idx, "result"))
	if o.has("cond"):
		r.cond_bbcode = cond_to_bbcode(o["cond"])
	for fx in o.get("fx", []):
		r.fx_lines.append(fx_to_line(fx))
		_collect_fx_refs(r, fx)
		if str(fx.get("t", "")) == "CUSTOM_SCRIPT":
			# 未写 script 字段时宿主脚本即效果脚本
			_append_script_intel(r, str(fx.get("script", host_path)), node)
	return r


## CUSTOM_SCRIPT 里的事件文案键：先抓 tr()/fmt() 实参，再兜底全文 event.* 字面量
## （大量脚本用 const S0 := "event.script..." 常量承载结果键）
## 统一情报入口：候选文案 / 地块移交 / 效果扫描 三者互不阻断。
static func _append_script_intel(r: OptRow, script_path: String, node: EventGraphData) -> void:
	var scan := _scan_script(script_path, node)
	if scan.is_empty():
		return
	_append_script_hints(r, scan)
	_append_region_give(r, _script_src(script_path))
	_append_script_effects(r, scan)


static func _append_script_hints(r: OptRow, scan: Dictionary) -> void:
	if r.result_text != "":
		return  # 静态结果优先，不重复堆候选
	var b: Dictionary = scan.get(r.index, {})
	var com: Dictionary = scan.get(-1, {})
	var seen := {}
	var ordered: Array[String] = []   # 分支专属优先，公共段带 [共] 标记
	for k in b.get("keys", []):
		if not seen.has(k):
			seen[k] = true
			ordered.append(k)
	for k in com.get("keys", []):
		if not seen.has(k):
			seen[k] = true
			ordered.append("[共]" + k)
	for entry in ordered:
		var shared: bool = entry.begins_with("[共]")
		var key := entry.trim_prefix("[共]")
		var txt := EventText.t(key)
		if txt.begins_with("event."):
			continue  # CSV 未命中不展示
		r.fx_lines.append("[color=#9aa0a6]↳ 结果文案%s：%s[/color]"
				% ["[共]" if shared else "", humanize(txt)])


## 把效果行里的 W.I_XXX 常量名换成中文资源名
static func _pretty_const_line(ln: String) -> String:
	var M := {
		"I_PARTY_SUPPORT": "党内支持", "I_PEOPLE_SUPPORT": "民众支持",
		"I_THOUGHT_FREEDOM": "思想自由", "I_BUDGET": "预算",
		"I_PRESS_POLICY": "舆论政策", "I_DIPLO": "国际声望",
		"I_AGENTS": "特工网络", "I_ARMY": "军力", "I_SCIENCE": "科研点数",
		"I_INDUSTRY": "工业产值", "I_AGRICULTURE": "农业产值",
		"I_INFLUENCE": "全球影响力", "I_SOVIET_INFLUENCE": "苏联影响力",
		"I_USA_INFLUENCE": "美国影响力", "I_WAR_SUPPORT": "战争支持度",
		"LIVING_STANDARD": "生活水平", "I_STABILITY": "政治稳定",
	}
	var out := ln
	for k in M.keys():
		out = out.replace("W." + k, M[k])
	return out


static func _append_script_effects(r: OptRow, scan: Dictionary) -> void:
	var lines: Array[String] = []
	var common_fx: Array = scan.get(-1, {}).get("fx", [])
	for l in common_fx:
		lines.append("[共] " + str(l))
	var branch_fx: Array = scan.get(r.index, {}).get("fx", [])
	for l in branch_fx:
		lines.append(str(l))
	if lines.is_empty():
		return
	r.fx_lines.append("[color=#7fd17f]⚙ 脚本效果（静态扫描）：[/color]")
	for ln in lines:
		r.fx_lines.append("　⚙ %s" % esc(_pretty_const_line(ln)))


## ── 核心扫描（v3：共享宿主脚本按 event_id 守卫切片）───────────────────────
## 共享脚本惯用法：
##   match str(context.get("event_id", "")):
##       "afghan_amin_coup": _event_48(option_index)
## 扫描器只取【本事件 token 对应的函数体】做选项归属；其余事件内容一律丢弃，
## 公共尾行（如 clamp_empire_relations）归 out[-1]。
static func _scan_script(path: String, node: EventGraphData) -> Dictionary:
	var ckey := path + "::" + node.id
	if _scan_cache.has(ckey):
		return _scan_cache[ckey]
	var src := _script_src(path)
	var out := {}
	if src == "":
		_scan_cache[ckey] = out
		return out

	var consts := {}
	for m in RegEx.create_from_string(RX_CONST_KEY).search_all(src):
		consts[m.get_string(1)] = m.get_string(2)

	var exec_lines := _extract_execute_lines(src)
	if exec_lines.is_empty():
		_scan_cache[ckey] = out
		return out

	var aliases := {node.id: true, node.stem: true,
			("event_" + str(node.num)) if node.num >= 0 else "": true,
			str(node.num): true}

	# ── 定位 event_id 分派头 ──
	var hdr := -1
	for i in exec_lines.size():
		var raw: String = exec_lines[i][0]
		if raw.begins_with("match ") and raw.contains("event_id"):
			hdr = i
			break

	if hdr == -1:
		# 单事件脚本：整体扫描
		out = _scan_slice(exec_lines, consts, rx_engine())
	else:
		var rx_entry := RegEx.create_from_string(RX_EID_ENTRY)
		var mine_seg: Array[String] = []
		var common_tail: Array[String] = []
		var in_dispatch := false
		var dispatch_indent := 0
		var helper := ""
		var inline_mine := false
		for i in range(hdr, exec_lines.size()):
			var raw: String = exec_lines[i][0]
			var ind: int = exec_lines[i][1]
			if i > hdr and raw.begins_with("match ") :
				break
			if raw.begins_with("match "):
				in_dispatch = true
				dispatch_indent = ind
				continue
			if not in_dispatch:
				continue
			if ind <= dispatch_indent and i > hdr:
				in_dispatch = false   # 分派块结束，其后是公共尾
				common_tail.append(raw)
				continue
			var em := rx_entry.search(raw)
			if em != null:
				var tok := em.get_string(1)
				var body := em.get_string(2).strip_edges()
				var ours: bool = aliases.has(tok) or node.stem.contains(tok) or tok == str(node.num)
				helper = ""
				inline_mine = false
				if ours:
					var hm := RegEx.create_from_string(RX_HELPER_CALL).search(body)
					if hm != null:
						helper = hm.get_string(1)
					elif body != "":
						inline_mine = true
						mine_seg.append(body)
				continue
			if helper != "" and ind > dispatch_indent:
				mine_seg.append(raw)      # 委托调用行内的续行（少见）
			elif inline_mine and ind > dispatch_indent:
				mine_seg.append(raw)
			elif not in_dispatch:
				common_tail.append(raw)

		if helper != "":
			out = _scan_slice(_extract_func_lines(src, helper), consts, rx_engine())
		elif inline_mine:
			out = _scan_slice(mine_seg, consts, rx_engine())
		else:
			out = _scan_slice([], consts, rx_engine())
		for cl in common_tail:
			var bcom: Dictionary = mk_out(out, -1)
			if RX_EFFECT_LINE != "" and RegEx.create_from_string(RX_EFFECT_LINE).search(cl) != null:
				bcom["fx"].append(cl)
			for m in RegEx.create_from_string(RX_ANY_EVENT_KEY).search_all(cl):
				if not (bcom["keys"] as Array).has(m.get_string(1)):
					bcom["keys"].append(m.get_string(1))

	_scan_cache[ckey] = out
	return out


static var _rx_cache := {}


static func rx_engine() -> Dictionary:
	if _rx_cache.is_empty():
		_rx_cache = {
			"effect": RegEx.create_from_string(RX_EFFECT_LINE),
			"label": RegEx.create_from_string("^(\\d+):$"),
			"ifbr": RegEx.create_from_string(RX_BRANCH_IF),
			"lit": RegEx.create_from_string(RX_ANY_EVENT_KEY),
			"cref": RegEx.create_from_string(RX_CONST_REF),
		}
	return _rx_cache


static func mk_out(out: Dictionary, idx: int) -> Dictionary:
	if not out.has(idx):
		out[idx] = {"fx": [], "keys": []}
	return out[idx]


## execute() 体抽取：[[去缩进行, 缩进], ...]
static func _extract_execute_lines(src: String) -> Array:
	return _extract_func_lines(src, "execute")


static func _extract_func_lines(src: String, fname: String) -> Array:
	var out: Array = []
	var on := false
	for line in src.split("
"):
		var s := line.strip_edges()
		if not on:
			if s.begins_with("func " + fname + "("):
				on = true
			continue
		if s.begins_with("func ") or s.begins_with("const ") or s.begins_with("# ═"):
			break
		if s == "":
			out.append(["", 0])
			continue
		var indent := line.length() - line.strip_edges(true, false).length()
		out.append([s, indent])
	return out


## 分支归属扫描核心：lines 为 [[文本, 缩进], ...]
static func _scan_slice(pairs: Array, consts: Dictionary, rx: Dictionary) -> Dictionary:
	var out := {}
	var cur := -2
	for pair in pairs:
		var raw: String = str(pair[0])
		var ind: int = int(pair[1])
		if raw == "" or raw.begins_with("#") or raw.begins_with("match "):
			continue
		var bm: RegExMatch = rx["label"].search(raw)
		var bi: RegExMatch = rx["ifbr"].search(raw)
		if bm != null and ind <= 2:
			cur = int(bm.get_string(1))
			mk_out(out, cur)
			continue
		if bi != null and ind <= 2:
			cur = int(bi.get_string(1))
			mk_out(out, cur)
			continue
		if raw.begins_with("else:") and ind <= 2:
			cur = 99
			mk_out(out, 99)
			continue
		var clean := raw.split("#")[0].strip_edges()
		if clean == "":
			continue
		var bucket := mk_out(out, cur if cur >= 0 else -1)
		if rx["effect"].search(clean) != null:
			bucket["fx"].append(clean)
		var bkeys: Array = bucket["keys"]
		for m in rx["lit"].search_all(clean):
			var k: String = m.get_string(1)
			if not bkeys.has(k):
				bkeys.append(k)
		for m in rx["cref"].search_all(clean):
			var cname: String = m.get_string(1)
			if consts.has(cname) and not bkeys.has(consts[cname]):
				bkeys.append(consts[cname])
	return out


## 外部叙事文本的展示化：转义 → 诗行分隔符 | 转真换行 → 连续占位符归并。
## （原版惯例："|" 即诗行换行；"{0}{1}"连写为人名对。）
static func humanize(s: String) -> String:
	var out := esc(s)
	out = out.replace("|", NL_LIT)
	var rx_ph := RegEx.create_from_string("\\{(\\d+)\\}")
	var parts := rx_ph.search_all(out)
	if parts.is_empty():
		return out
	# 连续（中间仅夹标点/无汉字间隔）≥2 个占位符 → 〔人名〕；孤者 → 〔参数N〕
	var groups: Array = []          # [[match,...], ...] 连续占位符分组
	var cur_grp: Array = []
	var gend := -1
	for m in parts:
		if cur_grp.is_empty() or m.get_start() - gend <= 2:
			cur_grp.append(m)
		else:
			groups.append(cur_grp)
			cur_grp = [m]
		gend = m.get_end()
	if not cur_grp.is_empty():
		groups.append(cur_grp)
	# 分段一次性重建（正向拼接，杜绝位置漂移）
	var built := ""
	var copied := 0
	for grp in groups:
		var first: RegExMatch = grp[0]
		var g_last: RegExMatch = grp[grp.size() - 1]
		built += out.substr(copied, first.get_start() - copied)
		if grp.size() >= 2:
			built += "[color=#6f7480]〔人名〕[/color]"
		else:
			built += "[color=#6f7480]〔参数" + first.get_string(1) + "〕[/color]"
		copied = g_last.get_end()
	built += out.substr(copied)
	out = built
	return out


## 地块移交明细（set_map_region_owner([ids], gwcode)）
static func _append_region_give(r: OptRow, src: String) -> void:
	var id_tokens := PackedStringArray()
	for m in RegEx.create_from_string(RX_REGION_GIVE).search_all(src):
		id_tokens.append_array(m.get_string(1).replace(" ", "").split(",", false))
		var to_gw := int(m.get_string(2))
		var names: Array[String] = []
		for tok in m.get_string(1).replace(" ", "").split(",", false):
			var nm := LX.region_name(int(tok))
			names.append(nm if nm != "" else "#" + tok)
			if names.size() >= 6:
				break
		var to_c := LX.country_name(to_gw)
		var to_label := to_c if to_c != "" else "gw%d" % to_gw
		var suffix := "" if id_tokens.size() <= 6 else " 等%d块" % id_tokens.size()
		r.fx_lines.append("[color=#7fd17f]🗺 移交地块 %s → %s%s[/color]"
				% [", ".join(names), to_label, suffix])
		break  # 多次调用合并展示首批即可


## ── 条件树 → BBCode（美化打印）───────────────────────────────────────────
## 组合节点金色、叶子绿色、事件引用红色；未知类型橙色原样展示便于发现遗漏。
static func cond_to_bbcode(d: Dictionary, indent := 0) -> String:
	if d.is_empty():
		return "[color=#9aa0a6]（无条件 / 仅日期等引擎隐含条件）[/color]"
	return _cond_impl(d, indent)


static func _pad(indent: int) -> String:
	return "    ".repeat(indent)


static func _cond_impl(d: Dictionary, indent: int) -> String:
	var t := str(d.get("t", "?"))
	match t:
		"ALL", "ANY":
			var lines: Array[String] = []
			lines.append("%s[color=#c8a457]【%s】[/color]" % [_pad(indent), "且" if t == "ALL" else "或"])
			for c in d.get("c", []):
				lines.append(_cond_impl(c, indent + 1))
			return "\n".join(lines)
		"NOT":
			var kids: Array = d.get("c", [])
			var inner: Dictionary = kids[0] if kids.size() > 0 else {}
			return "%s[color=#c8a457]【非】[/color]%s" % [_pad(indent), _cond_impl(inner, 0)]
		_:
			return "%s%s" % [_pad(indent), _leaf_bbcode(d)]


static func _fmt_v(d: Dictionary) -> String:
	var v: float = float(d.get("v", 0.0))
	return String.num(v, 0) if is_equal_approx(v, round(v)) else String.num(v, 2)


static func _leaf_bbcode(d: Dictionary) -> String:
	var t := str(d.get("t", "?"))
	var key := str(d.get("key", ""))
	var tgt := str(d.get("target", ""))
	var ref := str(d.get("ref", d.get("ref_event_id", "")))
	var who := "玩家" if tgt == "" or tgt == "ROOT" else _country_disp(tgt)
	match t:
		"RESOURCE_AT_LEAST": return "[color=#7fd17f]%s ≥ %s[/color]" % [_res_disp(key), _v(d, key)]
		"RESOURCE_AT_MOST": return "[color=#7fd17f]%s ≤ %s[/color]" % [_res_disp(key), _v(d, key)]
		"RESOURCE_EQUALS": return "[color=#7fd17f]%s = %s[/color]" % [_res_disp(key), _v(d, key)]
		"RESOURCE_NOT_EQUALS": return "[color=#7fd17f]%s ≠ %s[/color]" % [_res_disp(key), _v(d, key)]
		"RESOURCE_SUM_AT_LEAST": return "[color=#7fd17f]%s 合计 ≥ %s[/color]" % [str(d.get("keys", [])), _fmt_v(d)]
		"RESOURCE_SUM_AT_MOST": return "[color=#7fd17f]%s 合计 ≤ %s[/color]" % [str(d.get("keys", [])), _fmt_v(d)]
		"MODIFIER_ACTIVE": return "[color=#7fd17f]修正[%s]生效[/color]" % esc(LX.modifier_name(int(key) if key.is_valid_int() else -1))
		"MODIFIER_INACTIVE": return "[color=#7fd17f]修正[%s]未生效[/color]" % esc(LX.modifier_name(int(key) if key.is_valid_int() else -1))
		"PREV_EVENT_DONE": return "[color=#e06c5a]前置事件[%s]已完成[/color]" % ref
		"PREV_EVENT_NOT_DONE": return "[color=#e06c5a]前置事件[%s]未完成[/color]" % ref
		"PREV_EVENT_RESULT_IS": return "[color=#e06c5a]前置事件[%s]结果=%s[/color]" % [ref, _fmt_v(d)]
		"EMPIRE_RELATION_AT_LEAST": return "[color=#7fd17f]对%s关系 ≥ %s[/color]" % [LX.empire_name(int(key)), disp_value(float(d.get("v", 0)), true)]
		"EMPIRE_RELATION_AT_MOST": return "[color=#7fd17f]对%s关系 ≤ %s[/color]" % [LX.empire_name(int(key)), disp_value(float(d.get("v", 0)), true)]
		"EMPIRE_POWER_DIFFERENCE_AT_LEAST": return "[color=#7fd17f]影响力-帝国%s力量 ≥ %s[/color]" % [LX.empire_name(int(key)), _fmt_v(d)]
		"EMPIRE_LEADER_IS": return "[color=#7fd17f]%s现任领导人=%s[/color]" % [LX.empire_name(int(key)), _fmt_v(d)]
		"EMPIRE_LEADER_SUPPORT_AT_LEAST": return "[color=#7fd17f]%s领袖#%s支持度 ≥ %s[/color]" % [LX.empire_name(int(key)), tgt, _fmt_v(d)]
		"EMPIRE_LEADER_SUPPORT_AT_MOST": return "[color=#7fd17f]%s领袖#%s支持度 ≤ %s[/color]" % [LX.empire_name(int(key)), tgt, _fmt_v(d)]
		"COUNTRY_HAS_TAG": return "[color=#7fd17f]%s有标签[%s][/color]" % [who, key]
		"COUNTRY_IS_SUBJECT_OF": return "[color=#7fd17f]%s是[%s]附庸[/color]" % [who, d.get("overlord", key)]
		"COUNTRY_EXISTS": return "[color=#7fd17f]国家[%s]存在[/color]" % key
		"COUNTRY_FIELD_EQUALS": return "[color=#7fd17f]%s.%s = %s[/color]" % [who, key, _fmt_v(d)]
		"COUNTRY_FIELD_NOT_EQUALS": return "[color=#7fd17f]%s.%s ≠ %s[/color]" % [who, key, _fmt_v(d)]
		"COUNTRY_FIELD_AT_LEAST": return "[color=#7fd17f]%s.%s ≥ %s[/color]" % [who, key, _fmt_v(d)]
		"COUNTRY_FIELD_AT_MOST": return "[color=#7fd17f]%s.%s ≤ %s[/color]" % [who, key, _fmt_v(d)]
		"DATE_AFTER": return "[color=#7fd17f]日期 ≥ %s[/color]" % key
		"DATE_BEFORE": return "[color=#7fd17f]日期 ≤ %s[/color]" % key
		"HAS_FLAG": return "[color=#7fd17f]标记[%s]为真[/color]" % key
		"NOT_HAS_FLAG": return "[color=#7fd17f]标记[%s]为假[/color]" % key
		"IS_FACTION_LEADER": return "[color=#7fd17f]派系[%s]执政[/color]" % esc(LX.faction_name(int(d.get("v", -1))))
		"COALITION_SUPPORT_AT_LEAST": return "[color=#7fd17f]联盟支持率 ≥ %s%%[/color]" % _fmt_v(d)
		"TECH_UNLOCKED": return "[color=#7fd17f]科技%s已解锁[/color]" % _fmt_v(d)
		"WAR_ACTIVE": return "[color=#7fd17f]%s进行中[/color]" % esc(LX.war_name(int(d.get("v", -1))))
		"WAR_FIELD_EQUALS": return "[color=#7fd17f]战争%s.%s = %s[/color]" % [tgt, key, _fmt_v(d)]
		"SOCIALIST_COUNT_AT_LEAST": return "[color=#7fd17f]社会主义国家数 ≥ %s[/color]" % _fmt_v(d)
		"DECISION_DONE": return "[color=#7fd17f]决策[%s]已完成[/color]" % key
		"POLITICIAN_POWER_DIFFERENCE_AT_LEAST": return "[color=#7fd17f]性格%s权力-性格%s ≥ %s[/color]" % [key, tgt, _fmt_v(d)]
		_: return "[color=#ff9944]<未知:%s> %s[/color]" % [t, key]


## 资源键 → 中文名（未知键原样）
static func _res_disp(key: String) -> String:
	return esc(LX.resource_label(key))


## 条件值：tenfold 资源按显示口径 ÷10，其余原值
static func _v(d: Dictionary, key: String) -> String:
	return disp_value(float(d.get("v", 0.0)), LX.resource_tenfold(key))


## 国家 target（原版序号字符串）→ 中文名；无法解析回退原串
static func _country_disp(tgt: String) -> String:
	if tgt == "" or tgt == "ROOT":
		return "玩家"
	if tgt.is_valid_int():
		var nm := LX.country_name(int(tgt))
		if nm != "":
			return esc(nm)
	return "国家%s" % tgt


## ── 单条效果 → 摘要行 ────────────────────────────────────────────────────
static func fx_to_line(fx: Dictionary) -> String:
	var t := str(fx.get("t", "?"))
	var key := str(fx.get("key", ""))
	var tgt := str(fx.get("target", ""))
	match t:
		"CUSTOM_SCRIPT":
			var sp := str(fx.get("script", ""))
			return "📜 脚本 · %s" % (sp.get_file() if sp != "" else "宿主脚本")
		"TRIGGER_EVENT":
			return "[color=#e06c5a]▶ 触发事件 [%s][/color]" % key
		"ADD_RESOURCE":
			return "%s +%s" % [_res_disp(key), disp_value(float(fx.get("v", 0)), LX.resource_tenfold(key))]
		"SET_RESOURCE":
			return "%s = %s" % [_res_disp(key), disp_value(float(fx.get("v", 0)), LX.resource_tenfold(key))]
		"SET_FLAG": return "置标记[%s]" % key
		"CLEAR_FLAG": return "清标记[%s]" % key
		"SET_MODIFIER_ACTIVE":
			return "修正[%s]%s" % [esc(LX.modifier_name(int(key) if key.is_valid_int() else -1)),
					"生效" if float(fx.get("v", 0)) >= 0.5 else "关闭"]
		"SET_MODIFIER_AVAILABLE":
			return "修正[%s]%s" % [esc(LX.modifier_name(int(key) if key.is_valid_int() else -1)),
					"可用" if float(fx.get("v", 0)) >= 0.5 else "禁用"]
		"START_WAR": return "⚔ 开战：%s" % esc(LX.war_name(int(fx.get("value", -1))))
		"SET_WAR_STATE": return "战争%s状态=%s" % [tgt, _fmt_v(fx)]
		"JOIN_ALLIANCE", "LEAVE_ALLIANCE", "JOIN_ALL_ALLIANCES", "JOIN_ECONOMIC_ALLIANCE":
			return "%s 加入同盟[%s]" % [_country_disp(tgt), key] if t != "LEAVE_ALLIANCE" \
					else "%s 退出同盟[%s]" % [_country_disp(tgt), key]
		"SET_COUNTRY_VAR", "ADD_COUNTRY_VAR":
			return "%s 变量 %s %s%s" % [_country_disp(tgt), key,
					"=" if t.begins_with("SET") else "±", _fmt_v(fx)]
		"ADD_EMPIRE_RELATION":
			return "对%s关系 +%s（显示口径）" % [LX.empire_name(int(key) if key.is_valid_int() else -1),
					disp_value(float(fx.get("v", 0)), true)]
		"SET_EMPIRE_RELATION":
			return "对%s关系 = %s（显示口径）" % [LX.empire_name(int(key) if key.is_valid_int() else -1),
					disp_value(float(fx.get("v", 0)), true)]
		"ADD_EMPIRE_POWER":
			return "%s力量+%s" % [LX.empire_name(int(key) if key.is_valid_int() else -1), _fmt_v(fx)]
		"ADD_FACTION_SUPPORT":
			return "派系[%s]支持±%s" % [esc(LX.faction_name(int(key) if key.is_valid_int() else -1)), _fmt_v(fx)]
		"ADD_ALL_POLITICIAN_LOYALTY": return "全体政治家忠诚+%s" % _fmt_v(fx)
		"ADD_POLITICIAN_LOYALTY_BY_PERSONALITY": return "按性格(%s)加忠诚" % key
		_: return "%s %s" % [t, key]


## ── 引用收集 ──────────────────────────────────────────────────────────────
static func _collect_fx_refs(r: OptRow, fx: Dictionary) -> void:
	if str(fx.get("t", "")) == "TRIGGER_EVENT":
		_push_ref(r.refs, str(fx.get("key", "")))
	if fx.has("if"):
		_walk_cond_refs(fx["if"], r)


static func _walk_cond_refs(d: Dictionary, r: OptRow) -> void:
	if d.is_empty():
		return
	var t := str(d.get("t", ""))
	if t in ["PREV_EVENT_DONE", "PREV_EVENT_RESULT_IS", "PREV_EVENT_NOT_DONE"]:
		_push_ref(r.refs, str(d.get("ref", d.get("ref_event_id", ""))))
	for c in d.get("c", []):
		_walk_cond_refs(c, r)


static func _walk_trigger_refs(d: Dictionary, n: EventGraphData) -> void:
	if d.is_empty():
		return
	var t := str(d.get("t", ""))
	if t in ["PREV_EVENT_DONE", "PREV_EVENT_RESULT_IS", "PREV_EVENT_NOT_DONE"]:
		_add_ref(n, str(d.get("ref", d.get("ref_event_id", ""))))
	for c in d.get("c", []):
		_walk_trigger_refs(c, n)


static func _collect_refs(n: EventGraphData) -> void:
	for cd in n.trigger_list:
		_walk_trigger_refs(cd, n)


static func _add_ref(n: EventGraphData, target: String) -> void:
	if target != "" and not n.out_refs.has(target):
		n.out_refs.append(target)


static func _push_ref(arr: Array[String], target: String) -> void:
	if target != "" and not arr.has(target):
		arr.append(target)
