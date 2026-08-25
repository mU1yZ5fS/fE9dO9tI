extends "res://数据脚本/event_script_base.gd"

## 原作 Event7.cs：中美外交危机。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10076 自动触发（empires[0].relations<=0 && !event_done[7] &&
##    !event_done[421]），每半年(1月/7月1日)重置可重复（TimeScript.cs:3029）；另有
##    Event705「冠礼」结果链入口（Event705.cs:63）。端口 007 的 trigger_conditions =
##    EMPIRE_RELATION_AT_MOST(0,0) + PREV_EVENT_NOT_DONE(event_421)，421 移植说明前视为恒真。
##  - 海地覆盖（SubGosstroy==19 && !cw 时替换 opt0/opt1 文案并 Destroy 按钮）：依赖
##    705 链后的海地状态，端口 UI 静态文案无法动态替换 → 仅复刻结果末尾的 cw=true 置位，
##    文案覆盖部分在 705 移植时补（届时海地状态恒不成立，行为一致）。
##  - dlc[3]（DLC 购买标志）：端口无 DLC 体系 → 视为恒真（同 game_manager.gd:2225 先例）。
##  - opt3 的 data.hardline_crackdown_count++：官方版 DLL 反编译证实为 ref 真实写入
##    （data[111] 自增），旧转储 ptr 模式系反编译伪影，已恢复实装。


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
	# 海地覆盖（Event7.cs ResultsOfEvents 末尾，所有结果都执行）
	_haiti_aftermath()

	# 无自定义效果时（opt1 声明式），保持 .tres 静态 result_text


# 选项0：我们出资缓和关系（Event7.cs result 0）
func _opt_detente(context: Dictionary) -> void:
	if ws.empires.size() > 0 and ws.empires[0] != null:
		ws.empires[0].relations = 400
	@warning_ignore("integer_division")
	if d.size() > W.I_DIPLO and d.diplomatic_reputation > 600:
		@warning_ignore("integer_division")
		d.diplomatic_reputation -= d.diplomatic_reputation / 50
	if d.size() > W.I_BUDGET:
		d.budget -= 100
	context["result_text"] = tr("event.script.event_007_diplo_crisis_usa.i0")


# 选项2：向帝国主义者发射核武器！（Event7.cs result 2：load_scene_after_click → 结局）
func _opt_nuke(context: Dictionary) -> void:
	context["result_text"] = tr("event.script.event_007_diplo_crisis_usa.i1")
	game.queue_ending_after_event(3)


# 选项3：一点都不在乎（Event7.cs result 3：激活修正17「美国禁运」+ 东盟分支）
func _opt_indifferent(context: Dictionary) -> void:
	var mod17 := _get_mod17()
	if mod17 == null or not mod17.is_active:
		if d.size() > W.I_ARMY:
			d.army -= 50
		if d.size() > W.I_AGENTS:
			d.agents -= 50
		if mod17 != null:
			mod17.is_active = true
			_set_mod17_text("美国禁运", "我们将减少与美国关系差额10%的收入|失去相当于与美国关系差额5%的特工网络")
		# 官方版 DLL 反编译（tmp_Event7.cs:114-119）证实 data[111]++ 为 ref 真实写入。
		d.hardline_crackdown_count += 1
	if mod17 != null and mod17.is_active and _usa_in_asean() and d.size() > 139 and d.alliance_kickout_timer <= 0:
		d.alliance_kickout_timer = 5   # 原 data.alliance_kickout_timer（无端口命名键，数字索引直访）
	context["result_text"] = tr("event.script.event_007_diplo_crisis_usa.i2")


# 选项4：让我们给帝国主义者一点颜色瞧瞧！（Event7.cs result 4：激活修正17「禁运美国」）
func _opt_embargo(context: Dictionary) -> void:
	var mod17 := _get_mod17()
	if mod17 != null:
		mod17.is_active = true
		_set_mod17_text("禁运美国", "我们将增加与美国影响差额10%的特工网络|获得相当于与美国影响差额5%的预算|美国将减少与中国影响差额10%的影响力|失去相当于与中国影响差额5%的收入")
	context["result_text"] = tr("event.script.event_007_diplo_crisis_usa.i3")


# 海地后果（Event7.cs 末尾：SubGosstroy==19 && !cw → cw=true）
func _haiti_aftermath() -> void:
	var haiti := ws.get_country_by_legacy_index(139)
	if haiti != null and haiti.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST and not haiti.内战中:
		haiti.内战中 = true


func _get_mod17() -> ModifierSlot:
	if ws.modifiers.size() > 17:
		return ws.modifiers[17]
	return null


## 原 old_modify_texts[17]/old_modify_desc[17]：运行时改 ModifierDef 展示文案（与 UI 读取路径一致）
func _set_mod17_text(title: String, effect: String) -> void:
	var def := ModifierCatalog.get_def(17)
	if def != null:
		def.name_zh = title
		def.effect_zh = effect


func _usa_in_asean() -> bool:
	var usa := ws.get_country_by_legacy_index(1)
	return usa != null and usa.has_tag("asean")



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_007_diplo_crisis_usa.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "diplomatic_crisis_usa",
	"num": 7,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "EMPIRE_RELATION_AT_MOST", "key": "0"}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_421"}]}],
	"options": [{"disabled": true, "cond": {"t": "ANY", "c": [{"t": "RESOURCE_NOT_EQUALS", "key": "military_doctrine", "v": 30}, {"t": "RESOURCE_AT_MOST", "key": "diplo", "v": 950}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "influence_prc", "v": 50}, "fx": [{"t": "SET_EMPIRE_RELATION", "key": "0", "v": 400}, {"t": "ADD_RESOURCE", "key": "influence_prc", "v": -50}, {"t": "ADD_RESOURCE", "key": "army", "v": -50}, {"t": "ADD_RESOURCE", "key": "agents", "v": -50}]}, {"disabled": true, "cond": {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_EQUALS", "key": "political_line"}, {"t": "RESOURCE_AT_MOST", "key": "party_system", "v": 7}]}, {"t": "ALL", "c": [{"t": "COALITION_SUPPORT_AT_LEAST", "v": 67}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"cond": {"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "event_544"}, {"t": "PREV_EVENT_RESULT_IS", "v": 2, "ref": "event_544"}, {"t": "EMPIRE_POWER_DIFFERENCE_AT_LEAST", "key": "0", "v": 1}, {"t": "COUNTRY_FIELD_EQUALS", "key": "econ", "v": 1, "target": "1"}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
