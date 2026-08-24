# ============================================================================
# EventText — 事件文案翻译助手
# ============================================================================
# 迁移后的事件定义（META）不存任何文案，只存按约定派生的本地化 key：
#   event.<id>.title            事件标题
#   event.<id>.desc             事件描述
#   event.<id>.option_<i>.text          选项按钮文本（构建器恒生成）
#   event.<id>.option_<i>.disabled      选项门槛提示（原 .tres 有才生成）
#   event.<id>.option_<i>.result        结果页文本（原 .tres 有才生成）
#   event.<id>.option_<i>.result_title  结果标题（原 .tres 有才生成）
#
# 文案全部落在 资产/本地化/events_zh_CN.csv（Godot CSV 翻译导入），
# 加新语言 = 加一列。
#
# t() 的识别规则：以 "event." 开头的字符串视为 key 查 TranslationServer；
# 其余原样返回。这样 prepare() 脚本动态写入选项/结果的中文常量、以及
# context["result_text"] 的运行时文案都不受影响，无需逐个改造。
# ============================================================================
class_name EventText
extends RefCounted

## 本地化 key 前缀（与 event_engine 的 text_library 约定一致）
const KEY_PREFIX := "event."


## 显示前最后一刻翻译：key → 当前语言文本；字面量 / 未命中 → 原样返回。
## 注意：绝不要把 t() 的结果写回共享的 EventDef 字段——EventDef 是全局共享
## 资源，写回会导致切语言后显示陈旧译文（参见 event_script_base._disable 注释）。
static func t(s: String) -> String:
	if s == "" or not s.begins_with(KEY_PREFIX):
		return s
	# TranslationServer.translate 返回 String（未命中返回原 key），显式收窄避免
	# 三元分支 StringName/String 推断不兼容的告警。
	var translated := String(TranslationServer.translate(s))
	if translated.is_empty() or translated == s:
		return s
	return translated


## 按约定拼 key（供引擎/调试工具使用，避免散落字符串拼接）
static func event_key(event_id: String, slot: String) -> String:
	return "event.%s.%s" % [event_id, slot]


## 翻译并填充变量：CSV 文案里写 {0}{1}…（或命名键），脚本传值。
## 例：EventText.fmt("event.xxx.desc", {"0": 姓, "1": 名})
static func fmt(key: String, vars: Dictionary) -> String:
	return t(key).format(vars, "{_}")


static func option_key(event_id: String, option_index: int, slot: String) -> String:
	return "event.%s.option_%d.%s" % [event_id, option_index, slot]
