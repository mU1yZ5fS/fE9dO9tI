# ============================================================================
# EventDefBuilder — META 字典 → EventDef 运行时构建器
# ============================================================================
# 迁移后每个事件是一个带 `const META` 的 GDScript（合并进事件效果脚本，
# 或 独立定义文件），本构建器把 META 解释为 EventDef 对象树。
#
# META 结构（全部键可选除 id；省略即用 EventDef 默认值）：
#   {
#     "id": "death_of_mao",            # 必填，event_id
#     "num": 3,                        # 原版编号 → source_event_number
#     "priority": 10,                  # → trigger_priority（缺省 -1）
#     "notify": false,                 # → show_notification（缺省 true）
#     "notify_days": 13,               # 缺省 13
#     "timeout_agents": 20, "timeout_budget": 5,   # 缺省 20 / 5
#     "once": false,                   # → fire_only_once（缺省 true）
#     "dlc": "02",                     # 缺省 ""
#     "image": "res://资产/....png",   # 配图路径
#     "chain": ["event_id_a"],         # → triggers_on_complete
#     "display_script": "res://...",   # 显示前钩子（指向别的脚本时才写）
#     "trigger_script": "res://...",   # 复合触发钩子（同上）
#     "notext": true,                  # 极少数无标题文案的事件
#     "trigger": [ <条件字典>, ... ],  # AND 关系
#     "options": [ <选项字典>, ... ],
#   }
#
# 条件字典（ExprNode）—— t=枚举名，其余字段仅在与默认值不同时写出：
#   {"t": "date_after", "key": "1976.9.9"}
#   {"t": "all"/"any"/"not", "c": [子条件...]}
#   字段：key / v(数值) / target / keys(数组) / ref(事件ID) / overlord(宗主标签)
#
# 效果字典（EffectNode）：
#   {"t": "add_resource", "key": "money", "v": -30}
#   {"t": "custom"}                    # 宿主脚本自身（单文件事件的常规写法）
#   {"t": "custom", "script": "res://数据脚本/事件效果/xxx.gd"}  # 共享脚本
#   {"t": "start_war", ...}            # 条件效果统一用 "if": <条件字典>
#
# 选项字典（EventOption）：
#   { "cond": <条件>, "fx": [<效果>...],
#     "disabled": true,       # 原 .tres 有门槛文案 → 构建 disabled 的 key
#     "result": true,         # 原 .tres 有结果文本 → 构建 result 的 key
#     "result_title": true }  # 原 .tres 有结果标题 → 同理
#   选项文本 key 恒生成：event.<id>.option_<i>.text
#
# 文案本体不在 META 里 —— 全部落 资产/本地化/events_zh_CN.csv，
# 显示时经 EventText.t() 在渲染前翻译。
# ============================================================================
class_name EventDefBuilder
extends RefCounted

## 枚举名 → 值 映射（从枚举反射构建；尾追加新类型自动可用）
static var _expr_map: Dictionary = {}
static var _effect_map: Dictionary = {}


static func _ensure_maps() -> void:
	if _expr_map.is_empty():
		for k in ExprNode.Type.keys():
			_expr_map[k] = ExprNode.Type[k]
	if _effect_map.is_empty():
		for k in EffectNode.Type.keys():
			_effect_map[k] = EffectNode.Type[k]


## 从脚本提取 META 并构建。非事件脚本返回 null。
static func build_from_script(script: GDScript) -> EventDef:
	if script == null:
		return null
	var cmap: Dictionary = script.get_script_constant_map()
	if not cmap.has("META"):
		return null
	var meta: Variant = cmap["META"]
	if meta is Dictionary:
		return build(meta, script)
	return null


static func build(meta: Dictionary, host_script: GDScript) -> EventDef:
	_ensure_maps()
	var ev := EventDef.new()
	ev.event_id = str(meta.get("id", ""))
	ev.source_event_number = int(meta.get("num", -1))
	ev.trigger_priority = int(meta.get("priority", -1))
	ev.show_notification = bool(meta.get("notify", true))
	ev.notification_days = int(meta.get("notify_days", 13))
	ev.timeout_agents_penalty = int(meta.get("timeout_agents", 20))
	ev.timeout_budget_penalty = int(meta.get("timeout_budget", 5))
	ev.fire_only_once = bool(meta.get("once", true))
	ev.dlc = str(meta.get("dlc", ""))
	if not bool(meta.get("notitle", false)):
		ev.title = EventText.event_key(ev.event_id, "title")
	if not bool(meta.get("nodesc", false)):
		ev.description = EventText.event_key(ev.event_id, "desc")
	var img := str(meta.get("image", ""))
	if img != "":
		ev.image = load(img) as Texture2D
	for cid in meta.get("chain", []):
		ev.triggers_on_complete.append(str(cid))
	var ds := str(meta.get("display_script", ""))
	if ds != "":
		ev.display_script = load(ds) as GDScript
	var ts := str(meta.get("trigger_script", ""))
	if ts != "":
		ev.trigger_script = load(ts) as GDScript
	for cd in meta.get("trigger", []):
		ev.trigger_conditions.append(build_expr(cd))
	var opts: Array[EventOption] = []
	var opt_dicts: Array = meta.get("options", [])
	for i in opt_dicts.size():
		opts.append(build_option(opt_dicts[i], ev.event_id, i, host_script))
	ev.options = opts
	return ev


static func build_expr(d: Dictionary) -> ExprNode:
	_ensure_maps()
	var n := ExprNode.new()
	n.type = _expr_map[str(d.get("t", ""))]
	if d.has("key"):
		n.key = str(d["key"])
	if d.has("v"):
		n.value = float(d["v"])
	if d.has("target"):
		n.target = str(d["target"])
	if d.has("keys"):
		for k in d["keys"]:
			n.keys.append(str(k))
	if d.has("ref"):
		n.ref_event_id = str(d["ref"])
	if d.has("overlord"):
		n.overlord_tag = str(d["overlord"])
	for c in d.get("c", []):
		n.children.append(build_expr(c))
	return n


static func build_effect(d: Dictionary, host_script: GDScript) -> EffectNode:
	_ensure_maps()
	var n := EffectNode.new()
	n.type = _effect_map[str(d.get("t", ""))]
	if d.has("key"):
		n.key = str(d["key"])
	if d.has("v"):
		n.value = float(d["v"])
	if d.has("target"):
		n.target = str(d["target"])
	if n.type == EffectNode.Type.CUSTOM_SCRIPT:
		var sp := str(d.get("script", ""))
		n.custom_script = load(sp) as GDScript if sp != "" else host_script
	if d.has("if"):
		n.condition = build_expr(d["if"])
	return n


static func build_option(o: Dictionary, event_id: String, index: int,
		host_script: GDScript) -> EventOption:
	var opt := EventOption.new()
	if not bool(o.get("notext", false)):
		opt.text = EventText.option_key(event_id, index, "text")
	if bool(o.get("disabled", false)):
		opt.disabled_text = EventText.option_key(event_id, index, "disabled")
	if bool(o.get("result", false)):
		opt.result_text = EventText.option_key(event_id, index, "result")
	if bool(o.get("result_title", false)):
		opt.result_title = EventText.option_key(event_id, index, "result_title")
	if o.has("cond"):
		opt.enable_condition = build_expr(o["cond"])
	for fd in o.get("fx", []):
		opt.effects.append(build_effect(fd, host_script))
	return opt
