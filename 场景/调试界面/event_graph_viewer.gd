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

@onready var _filter: LineEdit = $Root/VBox/TopBar/Filter
@onready var _clear_btn: Button = $Root/VBox/TopBar/ClearBtn
@onready var _close_btn: Button = $Root/VBox/TopBar/CloseBtn
@onready var _list_header: Label = $Root/VBox/Main/LeftPanel/ListHeader
@onready var _list: ItemList = $Root/VBox/Main/LeftPanel/List
@onready var _graph: GraphEdit = $Root/VBox/Main/Right/Graph
@onready var _detail: RichTextLabel = $Root/VBox/Main/Right/DetailPanel/Scroll/DetailText
@onready var _status: Label = $Root/VBox/Status

var _all: Array[EventGraphData] = []
var _by_stem := {}            # stem -> EventGraphData
var _alias := {}              # id/stem/"event_<num>" -> EventGraphData
var _list_stems: Array[String] = []
var _placed := {}             # stem -> GraphNode
var _edges := {}              # "a|b" -> true（去重）


func _ready() -> void:
	_filter.text_changed.connect(func(_t): _repopulate_list())
	_clear_btn.pressed.connect(_clear_canvas)
	_close_btn.pressed.connect(_close)
	_list.item_selected.connect(_on_list_selected)
	_graph.node_selected.connect(_on_node_selected)
	_build_async()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close()


func _close() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


## ── 数据构建（分帧加载，保持 UI 响应）─────────────────────────────────────
func _build_async() -> void:
	_status.text = "正在解析事件定义…"
	await get_tree().process_frame
	_all = await EventGraphData.load_all(_on_progress)
	for n in _all:
		_by_stem[n.stem] = n
		_alias[n.id] = n
		_alias[n.stem] = n
		if n.num >= 0:
			_alias["event_%d" % n.num] = n
	_repopulate_list()
	_status.text = "共 %d 个事件。点击左侧列表开始探索。" % _all.size()
	print("TOPO_BUILD_OK count=", _all.size(), " refs=", _alias.size())


func _on_progress(done: int, total: int) -> void:
	_status.text = "正在解析事件定义… %d/%d" % [done, total]


## ── 左侧列表 ──────────────────────────────────────────────────────────────
func _repopulate_list() -> void:
	_list.clear()
	_list_stems.clear()
	var kw := _filter.text.strip_edges().to_lower()
	for n in _all:
		if kw != "" and not _match(n, kw):
			continue
		_list.add_item("%d · %s" % [n.num, n.title] if n.num >= 0 else n.title)
		_list_stems.append(n.stem)
	_list_header.text = "全部事件（%d）" % _list_stems.size()


func _match(n: EventGraphData, kw: String) -> bool:
	return str(n.num).contains(kw) or n.stem.to_lower().contains(kw) \
			or n.id.to_lower().contains(kw) or n.title.to_lower().contains(kw)


func _on_list_selected(idx: int) -> void:
	if idx >= 0 and idx < _list_stems.size():
		_focus(_by_stem.get(_list_stems[idx]))


## ── 画布节点 ──────────────────────────────────────────────────────────────
func _focus(n: EventGraphData) -> void:
	if n == null:
		return
	_place(n)
	_expand_neighbors(n)
	_detail.text = _detail_bbcode(n)  # 列表点击也同步详情栏


func _place(n: EventGraphData) -> GraphNode:
	if _placed.has(n.stem):
		return _placed[n.stem]
	var gn := GraphNode.new()
	gn.name = n.stem
	gn.title = "%s · %s" % [n.num, n.title]
	var col := len(_placed) % 6
	var row := floori(len(_placed) / 6.0) % 8
	gn.position_offset = Vector2(col * 340.0 + randf_range(0, 40), row * 240.0)

	var body := RichTextLabel.new()
	body.bbcode_enabled = true
	body.fit_content = true
	body.custom_minimum_size = Vector2(380, 0)
	body.add_theme_font_size_override("normal_font_size", 16)
	body.add_theme_font_size_override("bold_font_size", 16)
	body.text = _node_summary_bbcode(n)
	gn.add_child(body)
	gn.add_theme_font_size_override("title_font_size", 17)
	gn.set_slot(0, true, 0, COLOR_EDGE, true, 0, COLOR_EDGE)
	_graph.add_child(gn)
	_placed[n.stem] = gn
	return gn


## 节点上的摘要：触发一行 + 各选项文本 + 每选项前 2 条脚本效果
func _node_summary_bbcode(n: EventGraphData) -> String:
	var lines: Array[String] = []
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
func _expand_neighbors(n: EventGraphData) -> void:
	for ref in n.out_refs:
		var other: EventGraphData = _alias.get(ref)
		if other == null:
			_place_dangling(ref)
			_edge(n.stem, _dangling_name(ref))
		else:
			_place(other)
			_edge(n.stem, other.stem)
	# 反向边：谁引用了我（在已放置节点里找）
	for stem in _placed:
		var other2: EventGraphData = _by_stem.get(stem)
		if other2 == null or other2 == n:
			continue
		for ref in other2.out_refs:
			if _alias.get(ref) == n:
				_edge(other2.stem, n.stem)


func _dangling_name(ref: String) -> String:
	return "@missing:" + ref


func _place_dangling(ref: String) -> void:
	var dname := _dangling_name(ref)
	if _placed.has(dname):
		return
	var gn := GraphNode.new()
	gn.name = dname
	gn.title = "? " + ref
	var lb := Label.new()
	lb.text = "(未解析的事件标识)"
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
func _on_node_selected(node: Node) -> void:
	var data: EventGraphData = _by_stem.get(node.name)
	if data == null:
		return
	_detail.text = _detail_bbcode(data)


func _detail_bbcode(n: EventGraphData) -> String:
	var L: Array[String] = []
	L.append("[b][color=#c8a457]%d · %s[/color][/b]   [color=#9aa0a6]%s (id=%s)[/color]"
			% [n.num, EventGraphData.esc(n.title), n.stem, n.id])
	L.append("")
	L.append("[b]触发条件[/b]")
	L.append(n.trigger_bbcode)
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
	if not n.out_refs.is_empty():
		L.append("")
		L.append("[b]引用事件[/b]：" + ", ".join(n.out_refs))
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
