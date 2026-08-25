extends "res://数据脚本/event_script_base.gd"

## 原作 Event8.cs：中苏外交危机。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10083 自动触发（empires[1].relations<=0 && !event_done[8] &&
##    !event_done[473]），每半年(1月/7月1日)重置可重复（TimeScript.cs:3029）。端口 008 的
##    trigger_conditions = EMPIRE_RELATION_AT_MOST(1,0) + PREV_EVENT_NOT_DONE(event_473)，
##    473 移植说明前视为恒真。
##  - dlc[3]（DLC 购买标志）：端口无 DLC 体系 → 视为恒真（同 game_manager.gd:2225 先例）。
##  - opt3 的 data.hardline_crackdown_count++：官方版 DLL 反编译证实为 ref 真实写入
##    （data[111] 自增），旧转储 ptr 模式系反编译伪影，已恢复实装。
##  - button_text[5]=""（空按钮占位）：无实际内容，跳过。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))

	match opt:
		0:
			_opt_detente(context)
		2:
			_opt_nuke(context)
		3:
			_opt_indifferent(context)
		4:
			_opt_embargo(context)


# 选项0：我们出资缓和关系（Event8.cs result 0，diplo 扣 /20）
func _opt_detente(context: Dictionary) -> void:
	if ws.empires.size() > 1 and ws.empires[1] != null:
		ws.empires[1].relations = 400
	@warning_ignore("integer_division")
	if d.size() > W.I_DIPLO and d.diplomatic_reputation > 600:
		@warning_ignore("integer_division")
		d.diplomatic_reputation -= d.diplomatic_reputation / 20
	if d.size() > W.I_BUDGET:
		d.budget -= 100
	context["result_text"] = tr("event.script.event_008_diplo_crisis_ussr.i0")


# 选项2：向修正主义者发射核武器！（Event8.cs result 2：load_scene_after_click → 结局）
func _opt_nuke(context: Dictionary) -> void:
	context["result_text"] = tr("event.script.event_008_diplo_crisis_ussr.i1")
	game.queue_ending_after_event(3)


# 选项3：一点都不在乎（Event8.cs result 3：激活修正16「苏联禁运」+ 经互会分支）
func _opt_indifferent(context: Dictionary) -> void:
	var mod16 := _get_mod16()
	if mod16 == null or not mod16.is_active:
		if d.size() > W.I_ARMY:
			d.army -= 50
		if d.size() > W.I_AGENTS:
			d.agents -= 50
		if mod16 != null:
			mod16.is_active = true
			_set_mod16_text("苏联禁运", "我们将减少与苏联关系差额10%的收入|失去相当于与苏联关系差额5%的特工网络")
		# 官方版 DLL 反编译（tmp_Event8.cs:113-118）证实 data[111]++ 为 ref 真实写入。
		d.hardline_crackdown_count += 1
	if mod16 != null and mod16.is_active and _usa_in_sev() and d.size() > 139 and d.alliance_kickout_timer <= 0:
		d.alliance_kickout_timer = 5   # 原 data.alliance_kickout_timer（无端口命名键，数字索引直访）
	context["result_text"] = tr("event.script.event_008_diplo_crisis_ussr.i2")


# 选项4：让我们给修正主义者一点颜色瞧瞧！（Event8.cs result 4：激活修正16「禁运苏联」）
func _opt_embargo(context: Dictionary) -> void:
	var mod16 := _get_mod16()
	if mod16 != null:
		mod16.is_active = true
		_set_mod16_text("禁运苏联", "我们将增加与苏联影响差额10%的特工网络|获得相当于与苏联影响差额5%的预算|苏联将减少与中国影响差额10%的影响力|失去相当于与中国影响差额5%的收入")
	context["result_text"] = tr("event.script.event_008_diplo_crisis_ussr.i3")


func _get_mod16() -> ModifierSlot:
	if ws.modifiers.size() > 16:
		return ws.modifiers[16]
	return null


## 原 old_modify_texts[16]/old_modify_desc[16]：运行时改 ModifierDef 展示文案（与 UI 读取路径一致）
func _set_mod16_text(title: String, effect: String) -> void:
	var def := ModifierCatalog.get_def(16)
	if def != null:
		def.name_zh = title
		def.effect_zh = effect


func _usa_in_sev() -> bool:
	var usa := ws.get_country_by_legacy_index(1)
	return usa != null and usa.has_tag("sev")



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_008_diplo_crisis_ussr.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "diplomatic_crisis_ussr",
	"num": 8,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "EMPIRE_RELATION_AT_MOST", "key": "1"}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_473"}]}],
	"options": [{"disabled": true, "cond": {"t": "ANY", "c": [{"t": "RESOURCE_NOT_EQUALS", "key": "military_doctrine", "v": 30}, {"t": "RESOURCE_AT_MOST", "key": "diplo", "v": 950}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "influence_prc", "v": 50}, "fx": [{"t": "SET_EMPIRE_RELATION", "key": "1", "v": 400}, {"t": "ADD_RESOURCE", "key": "influence_prc", "v": -50}, {"t": "ADD_RESOURCE", "key": "army", "v": -50}, {"t": "ADD_RESOURCE", "key": "agents", "v": -50}]}, {"disabled": true, "cond": {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_EQUALS", "key": "political_line"}, {"t": "RESOURCE_AT_MOST", "key": "party_system", "v": 7}]}, {"t": "ALL", "c": [{"t": "COALITION_SUPPORT_AT_LEAST", "v": 67}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"cond": {"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "event_544"}, {"t": "PREV_EVENT_RESULT_IS", "v": 2, "ref": "event_544"}, {"t": "EMPIRE_POWER_DIFFERENCE_AT_LEAST", "key": "1", "v": 1}, {"t": "COUNTRY_FIELD_EQUALS", "key": "econ", "v": 1, "target": "1"}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
