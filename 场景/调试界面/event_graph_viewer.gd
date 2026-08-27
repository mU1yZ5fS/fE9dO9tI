extends Control

# ============================================================================
# 事件拓扑图查看器 —— 逻辑层（布局见同名 .tscn）。
# ============================================================================
# 数据：EventGraphData.load_all()（manifest → META，只读，不触发任何游戏行为）
# 交互：
#   左侧列表 = 全量事件（可按 编号/ID/标题 过滤）
#   点击列表项 / 画布节点 → 画布放置该事件节点 + 一跳邻居 + 引用边，
#                           详情栏展开 触发条件树/选项门槛/效果/静态结果
#   节点可继续点击逐跳扩展；清空画布重置。
# ============================================================================

const MAIN_MENU_SCENE := "uid://bydan4iqthbaa"
const COLOR_EDGE := Color(0.45, 0.5, 0.62)
const COLOR_NODE_TITLE := Color(0.78, 0.64, 0.34)
## 运行时探针按路径预载（新文件的全局类名要等编辑器重导入才进类缓存，
## 直接运行游戏会解析失败，故不依赖 class_name）
const LIVE := preload("res://数据脚本/systems/event_graph_live.gd")
const LAYER_W := 380.0     ## 分层布局：层间距（x）
const LAYER_H := 280.0     ## 分层布局：层内行距（y）
const MAX_DEPTH := 3       ## 列表聚焦时的展开深度（更深层点击节点继续扩展）
## 实时状态着色（仅游戏内可用；对齐 LIVE.St）
const COLOR_DONE := Color(0.55, 0.58, 0.62)
const COLOR_READY := Color(0.5, 0.82, 0.5)
const COLOR_LOCKED := Color(0.78, 0.64, 0.34)
const STATE_TEXT := {
	0: "[已触发]",   # DONE
	1: "[可触发]",   # READY
	2: "[未满足]",   # LOCKED
}
const STATE_BB := {
	0: "[color=#9aa0a6]● 已触发[/color]",
	1: "[color=#7fd17f]● 可触发[/color]",
	2: "[color=#c8a457]● 条件未满足[/color]",
}

## 叠加模式：游戏内由调试控制台 topo 命令实例化到根，ESC/关闭即销毁回游戏；
## 主菜单独立场景模式保持原有 change_scene 返回。
var overlay_mode := false

var _live := false            ## 游戏局内 = 可做运行时条件求值
var _states := {}             ## stem -> LIVE.St（每次打开/手动刷新时扫描）

@onready var _filter: LineEdit = $Root/VBox/TopBar/Filter
@onready var _gate_chk: CheckBox = $Root/VBox/TopBar/GateChk
@onready var _script_chk: CheckBox = $Root/VBox/TopBar/ScriptChk
@onready var _audit_btn: Button = $Root/VBox/TopBar/AuditBtn
@onready var _refresh_btn: Button = $Root/VBox/TopBar/RefreshBtn
@onready var _clear_btn: Button = $Root/VBox/TopBar/ClearBtn
@onready var _close_btn: Button = $Root/VBox/TopBar/CloseBtn
@onready var _list_header: Label = $Root/VBox/Main/LeftPanel/ListHeader
@onready var _list: ItemList = $Root/VBox/Main/LeftPanel/List
@onready var _graph: GraphEdit = $Root/VBox/Main/Right/Graph
@onready var _detail: RichTextLabel = $Root/VBox/Main/Right/DetailPanel/Scroll/DetailText
@onready var _status: Label = $Root/VBox/Status

var _all: Array[EventGraphData] = []
var _by_stem := {}            # stem -> EventGraphData
var _alias := {}              # id/stem/"event_<num>" -> EventGraphData（含零填充归一）
var _list_stems: Array[String] = []
var _placed := {}             # stem -> GraphNode
var _edges := {}              # "a|b" -> true（去重）
var _dangling := {}           # 悬空 ref -> 来源数（加载时全量审计一次）


func _ready() -> void:
	_filter.text_changed.connect(func(_t): _repopulate_list())
	_gate_chk.toggled.connect(func(_t): _repopulate_list())
	_script_chk.toggled.connect(func(_t): _repopulate_list())
	_audit_btn.pressed.connect(_show_audit)
	_refresh_btn.pressed.connect(_refresh_live)
	_clear_btn.pressed.connect(_clear_canvas)
	_close_btn.pressed.connect(_close)
	_list.item_selected.connect(_on_list_selected)
	_graph.node_selected.connect(_on_node_selected)
	_detail.meta_clicked.connect(_on_meta_clicked)
	if overlay_mode:
		_close_btn.text = "关闭拓扑图"
	_build_async()


## 详情栏/节点摘要里的 [url=引用] 点击 → 聚焦对应事件（导航闭环）
func _on_meta_clicked(meta: Variant) -> void:
	var key := str(meta)
	var n: EventGraphData = EventGraphData.resolve_ref(_alias, key)
	if n == null:
		n = _by_stem.get(key)
	if n != null:
		_focus(n)
		_sync_list_selection(n.stem)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()   # 叠加模式：别让 ESC 穿透到游戏界面
		_close()


func _close() -> void:
	if overlay_mode:
		queue_free()   # 叠加模式：销毁即回到游戏现场
		return
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


## ── 数据构建（分帧加载，保持 UI 响应）─────────────────────────────────────
func _build_async() -> void:
	_status.text = "正在解析事件定义…"
	await get_tree().process_frame
	_all = await EventGraphData.load_all(_on_progress)
	for n in _all:
		_by_stem[n.stem] = n
	_alias = EventGraphData.make_alias(_all)
	_dangling = EventGraphData.audit_dangling(_all)
	var edge_count := 0
	for n in _all:
		edge_count += n.out_refs.size()
	_repopulate_list()
	_live = LIVE.available()
	_states = LIVE.scan_all(_all) if _live else {}
	if _live:
		var done_n := 0
		var ready_n := 0
		for st in _states.values():
			match int(st):
				LIVE.St.DONE: done_n += 1
				LIVE.St.READY: ready_n += 1
		_status.text = "实时模式 · 共 %d 事件 · 引用边 %d · 可触发 %d · 已触发 %d · 悬空 %d。ESC 关闭。" \
				% [_all.size(), edge_count, ready_n, done_n, _dangling.size()]
	else:
		_status.text = "共 %d 个事件 · 引用边 %d · 悬空引用 %d%s。点击左侧列表探索。" \
				% [_all.size(), edge_count, _dangling.size(),
				"（点「审计」看明细）" if not _dangling.is_empty() else ""]
	print("TOPO_BUILD_OK events=%d edges=%d alias=%d dangling=%d live=%s"
			% [_all.size(), edge_count, _alias.size(), _dangling.size(), str(_live)])
	if not _dangling.is_empty():
		print("TOPO_DANGLING: ", _dangling.keys())


## 手动刷新实时判定（世界在推进，状态会过期）
func _refresh_live() -> void:
	if not LIVE.available():
		return
	_states = LIVE.scan_all(_all)
	_repopulate_list()
	_status.text = "已刷新实时判定（%d 事件）。" % _all.size()


func _on_progress(done: int, total: int) -> void:
	_status.text = "正在解析事件定义… %d/%d" % [done, total]


## ── 左侧列表 ──────────────────────────────────────────────────────────────
func _repopulate_list() -> void:
	_list.clear()
	_list_stems.clear()
	var kw := _filter.text.strip_edges().to_lower()
	for n in _all:
		if _gate_chk.button_pressed and not n.has_gates:
			continue
		if _script_chk.button_pressed and not n.has_custom_script:
			continue
		if kw != "" and not n.search_blob.contains(kw):
			continue
		var label := "%d · %s" % [n.num, n.title] if n.num >= 0 else n.title
		var i := _list.add_item(label)
		if _live:   # 实时模式：状态词缀 + 着色
			var st := int(_states.get(n.stem, LIVE.St.LOCKED))
			_list.set_item_text(i, "%s %s" % [STATE_TEXT[st], label])
			match st:
				LIVE.St.DONE: _list.set_item_custom_fg_color(i, COLOR_DONE)
				LIVE.St.READY: _list.set_item_custom_fg_color(i, COLOR_READY)
				_: _list.set_item_custom_fg_color(i, COLOR_LOCKED)
		_list_stems.append(n.stem)
	_list_header.text = "全部事件（%d）" % _list_stems.size()


func _on_list_selected(idx: int) -> void:
	if idx >= 0 and idx < _list_stems.size():
		_focus(_by_stem.get(_list_stems[idx]))


## ── 画布节点 ──────────────────────────────────────────────────────────────
func _focus(n: EventGraphData) -> void:
	if n == null:
		return
	_place(n)
	_layout_component(n)
	_frame_all()
	_detail.text = _detail_bbcode(n)


func _place(n: EventGraphData) -> GraphNode:
	if _placed.has(n.stem):
		return _placed[n.stem]
	var gn := GraphNode.new()
	gn.name = n.stem
	gn.title = "%s · %s" % [n.num, n.title]
	gn.position_offset = Vector2(randf_range(0, 40), randf_range(0, 40))

	var body := RichTextLabel.new()
	body.bbcode_enabled = true
	body.fit_content = true
	body.custom_minimum_size = Vector2(380, 0)
	body.add_theme_font_size_override("normal_font_size", 16)
	body.add_theme_font_size_override("bold_font_size", 16)
	body.text = _node_summary_bbcode(n)
	body.meta_clicked.connect(_on_meta_clicked)
	gn.add_child(body)
	gn.add_theme_font_size_override("title_font_size", 17)
	gn.set_slot(0, true, 0, COLOR_EDGE, true, 0, COLOR_EDGE)
	_graph.add_child(gn)
	_placed[n.stem] = gn
	return gn


## 节点上的摘要：实时状态（如有）+ 触发一行 + 各选项文本 + 脚本效果行
func _node_summary_bbcode(n: EventGraphData) -> String:
	var lines: Array[String] = []
	if _live:
		lines.append("%s" % STATE_BB.get(int(_states.get(n.stem, 2)), ""))
	lines.append("[color=#9aa0a6]%s[/color]" % _cond_oneline(n.trigger_bbcode))
	for o in n.options:
		var lock := "🔒" if o.disabled_text != "" else ""
		lines.append("%d.%s %s" % [o.index + 1, lock, EventGraphData.humanize(o.text)])
		for fl in o.fx_lines:
			if fl.begins_with("　⚙") or fl.contains("🗺") or fl.contains("↳"):
				lines.append("[color=#8fbf92]%s[/color]" % fl.strip_edges())
	return "\n".join(lines)


## 去标签后截断——严禁切进 BBCode 标签内部（会漏出 [/color] 之类的残骸）
func _cond_oneline(tree_bbcode: String) -> String:
	var plain := RegEx.create_from_string("\\[[^\\]]*\\]").sub(tree_bbcode, "", true)
	plain = plain.replace("\n", " ").replace("    ", " ").strip_edges()
	return "[color=#9aa0a6]%s[/color]" % (plain if plain.length() <= 70 else plain.substr(0, 70) + "…")


## ── 邻居与边 ──────────────────────────────────────────────────────────────
## 画布单击节点：就地扩展一跳（正向引用 + 反向索引），不打乱整体布局。
func _expand_neighbors(n: EventGraphData) -> void:
	for ref in n.out_refs:
		var other: EventGraphData = EventGraphData.resolve_ref(_alias, ref)
		if other == null:
			_place_dangling(ref)
			_edge(n.stem, _dangling_name(ref))
		else:
			_place(other)
			_edge(n.stem, other.stem)
	for src_stem in n.in_refs:  # 谁引用我：只连已放置的，避免画布爆炸
		if _placed.has(src_stem):
			_edge(src_stem, n.stem)


## 列表聚焦：以该事件为根做 BFS 分层布局（x=因果深度，y=层内序），
## 悬空引用挂到源节点右侧。更深层保持未放置，点画布节点继续逐跳扩展。
func _layout_component(root: EventGraphData, max_depth := MAX_DEPTH) -> void:
	var depth := {root.stem: 0}
	var queue: Array[EventGraphData] = [root]
	while not queue.is_empty():
		var cur: EventGraphData = queue.pop_front()
		var d := int(depth[cur.stem])
		if d >= max_depth:
			continue
		for ref in cur.out_refs:
			var other: EventGraphData = EventGraphData.resolve_ref(_alias, ref)
			var key := cur.stem if other != null else _dangling_name(ref)
			if other == null:
				_place_dangling(ref)
			else:
				_place(other)
				key = other.stem
			_edge(cur.stem, key)
			if not depth.has(key):
				depth[key] = d + 1
				if other != null:
					queue.append(other)
		for src_stem in cur.in_refs:  # 反向边（源已放置才连线）
			if _placed.has(src_stem):
				_edge(src_stem, cur.stem)
	# 按层重排位置
	var row_at := {}
	for stem in depth:
		var gn: GraphNode = _placed.get(stem)
		if gn == null:
			continue
		var d := int(depth[stem])
		var i := int(row_at.get(d, 0))
		row_at[d] = i + 1
		gn.position_offset = Vector2(80.0 + d * LAYER_W, 80.0 + i * LAYER_H)


## 取景：缩放并平移让全部已放置节点入画。
func _frame_all() -> void:
	await get_tree().process_frame  # 等 GraphNode 完成一帧尺寸测量
	if _placed.is_empty():
		return
	var rect := Rect2()
	for gn in _placed.values():
		var g := gn as GraphNode
		rect = rect.merge(Rect2(g.position_offset, g.size))
	var view: Vector2 = _graph.size - Vector2(80, 80)
	if view.x <= 0 or view.y <= 0:
		return
	var z: float = minf(view.x / maxf(rect.size.x, 1), view.y / maxf(rect.size.y, 1))
	_graph.zoom = clampf(z, _graph.zoom_min, 1.0)
	_graph.scroll_offset = rect.position - Vector2(40, 40)


func _dangling_name(ref: String) -> String:
	return "@missing:" + ref


func _place_dangling(ref: String) -> void:
	var dname := _dangling_name(ref)
	if _placed.has(dname):
		return
	var gn := GraphNode.new()
	gn.name = dname
	var t := EventGraphData.ref_title(ref)
	gn.title = "? %s" % t   # 能查到标题就显示标题，查不到 ref_title 原样回退
	var lb := Label.new()
	lb.text = "%s\n(未解析的事件标识)" % ref
	gn.add_child(lb)
	gn.set_slot(0, true, 0, COLOR_EDGE, true, 0, COLOR_EDGE)
	_graph.add_child(gn)
	_placed[dname] = gn


func _edge(from_stem: String, to_stem: String) -> void:
	if from_stem == to_stem:
		return
	var key := "%s|%s" % [from_stem, to_stem]
	if _edges.has(key):
		return
	_edges[key] = true
	_graph.connect_node(from_stem, 0, to_stem, 0)


## ── 详情栏 ────────────────────────────────────────────────────────────────
## 点击画布节点 = 继续逐跳扩展 + 同步左侧列表高亮 + 刷新详情栏。
func _on_node_selected(node: Node) -> void:
	var data: EventGraphData = _by_stem.get(node.name)
	if data == null:
		return  # 悬空占位节点（@missing:*）无详情
	_expand_neighbors(data)
	_sync_list_selection(str(node.name))
	_detail.text = _detail_bbcode(data)


## ── 悬空引用审计 ──────────────────────────────────────────────────────────
## 迁移 QA：列出全项目解析失败的事件引用及其来源，写入详情栏。
func _show_audit() -> void:
	if _dangling.is_empty():
		_detail.text = "[b][color=#7fd17f]悬空引用审计[/color][/b]\n全部 %d 个事件的引用均可解析，无悬空。" % _all.size()
		return
	var sources := {}   # ref -> [来源标题]
	for n in _all:
		for ref in n.out_refs:
			if _dangling.has(ref):
				if not sources.has(ref):
					sources[ref] = []
				(sources[ref] as Array).append("%s·%s" % [n.num, n.title])
	var L: Array[String] = []
	L.append("[b][color=#e06c5a]悬空引用审计[/color][/b] 共 %d 个坏标识" % _dangling.size())
	L.append("[color=#9aa0a6]这些引用在 manifest/META id/stem/编号 别名里都找不到——[/color]")
	L.append("[color=#9aa0a6]要么是迁移笔误（如零填充不一致），要么是测试残留。[/color]")
	for ref in _dangling:
		L.append("· [color=#e06c5a]%s[/color] ← %s" % [EventGraphData.ref_title(ref), "、".join(sources[ref])])
	_detail.text = "\n".join(L)
	_status.text = "审计完成：%d 个悬空引用，明细见下方详情栏。" % _dangling.size()


func _sync_list_selection(stem: String) -> void:
	var idx := _list_stems.find(stem)
	if idx >= 0:
		_list.select(idx)
		_list.ensure_current_is_visible()


func _detail_bbcode(n: EventGraphData) -> String:
	var L: Array[String] = []
	L.append("[b][color=#c8a457]%d · %s[/color][/b]   [color=#9aa0a6]%s (id=%s)[/color]"
			% [n.num, EventGraphData.esc(n.title), n.stem, n.id])
	L.append("[color=#9aa0a6]%s[/color]" % EventGraphData.esc(n.meta_line))
	var pr := {}
	if _live:
		pr = LIVE.probe(n)
		L.append("%s　[color=#9aa0a6]（世界在推进，「刷新状态」可重判）[/color]" % STATE_BB.get(int(pr.state), ""))
	L.append("")
	if pr.is_empty():
		L.append("[b]触发条件[/b]")
		L.append(n.trigger_bbcode)
	else:
		L.append("[b]触发条件（实时判定）[/b]")
		if (pr.trigger_lines as Array[String]).is_empty():
			L.append("[color=#7fd17f]✓ 无条件，随时满足[/color]")
		for l in pr.trigger_lines:
			L.append(l)
	L.append("")
	for o in n.options:
		L.append("[b]选项 %d[/b] · %s" % [o.index + 1, EventGraphData.humanize(o.text)])
		if o.disabled_text != "":
			L.append("　🔒 禁用提示：%s" % EventGraphData.esc(o.disabled_text))
		if o.cond_bbcode != "":
			L.append("　[b]门槛[/b]")
			L.append(o.cond_bbcode.replace("\n", "\n　"))
		for fl in o.fx_lines:
			L.append("　→ " + fl)
		if o.result_text != "":
			L.append("　[color=#7fd17f]结果：%s[/color]" % EventGraphData.humanize(o.result_text))
		elif o.fx_lines.any(func(s): return s.begins_with("📜")):
			L.append("　[color=#9aa0a6]结果由脚本动态组装，见上方“可能结果文案”[/color]")
	if _live and not pr.is_empty() and not (pr.gate_lines as Array[String]).is_empty():
		L.append("")
		L.append("[b]选项门槛（实时）[/b]")
		for gl in pr.gate_lines:
			L.append(gl)
	if not n.out_refs.is_empty():
		L.append("")
		L.append("[b]引用事件[/b]：" + ", ".join(n.out_refs.map(
				func(r): return "[url=%s]%s[/url]" % [r, EventGraphData.ref_title(r)])))
	if not n.in_refs.is_empty():
		L.append("")
		L.append("[b]被引用（它们的前置含本事件）[/b]：" + ", ".join(n.in_refs.map(
				func(stem):
					var src: EventGraphData = _by_stem.get(stem)
					var label: String = EventGraphData.esc(src.title) if src != null else str(stem)
					return "[url=%s]%s[/url]" % [stem, label])))
	if not n.notes.is_empty():
		L.append("")
		L.append("[b][color=#e06c5a]已声明差异[/color][/b]")
		for note in n.notes:
			L.append("· " + EventGraphData.esc(note))
	return "\n".join(L)


## ── 清空 ──────────────────────────────────────────────────────────────────
func _clear_canvas() -> void:
	_graph.clear_connections()
	for stem in _placed:
		_placed[stem].queue_free()
	_placed.clear()
	_edges.clear()
	_detail.text = ""
