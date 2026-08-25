extends "res://数据脚本/event_script_base.gd"

## 原作 Event444.cs：漫长的革命（2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:442-445 —— modifies[3] 且 modifies[6] 且 modifies[11] 且 年>=1985 且 !is_gkchp（.tres ExprNode 表达）。
## 差异：doctr[] 显示文案表建模说明，跳过；traits[0]→trait_personality、traits[1]→trait_alignment；
##   loyality→loyalty；KillPerson→PoliticianSystem.kill_politician（同槽补员，先收集下标再杀）。




const TXT_R0 := "event.script.event_444_long_revolution.c0"
const TXT_R1 := "event.script.event_444_long_revolution.c1"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var data := world
	var opt := event_def.options
	var cond := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active \
			and data.political_line < 1 \
			and int(world.completed_event_ids.get("event_307", -1)) == 2 \
			and int(world.completed_event_ids.get("event_111", -1)) == 1
	if cond:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable_blank(opt[0])
	_enable(opt[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# 原版 doctr[6]/doctr[19]/doctr[24] 为显示文案表赋值，Godot 建模说明，跳过。
			d.people_support = 1000
			d.party_system = 6
			d.press_policy = 19
			d.religion_policy = 24
			_add(W.I_PARTY_SUPPORT, 300)
			ws.influence_prc += 100
			var kill_list: Array[int] = []
			for i in ws.politicians.size():
				var p: PoliticianData = ws.politicians[i]
				if p != null and (p.trait_alignment == GameConstants.PoliticianAlignment.FENCE_SITTER or p.trait_alignment == GameConstants.PoliticianAlignment.LOCAL_WARLORD):
					kill_list.append(i)
			for i in kill_list:
				PoliticianSystem.kill_politician(i)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty += 1000
				elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty -= 300
				elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
					p.loyalty -= 700
				elif p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL:
					p.loyalty -= 1000
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_PEOPLE_SUPPORT, -200)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 1000
				elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty += 300
			context["result_text"] = tr(TXT_R1)




func _disable_blank(opt: EventOption) -> void:
	opt.disabled_text = ""
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n








func _modifier_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active


func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_444_long_revolution.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_444",
	"num": 444,
	"priority": 44400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_444_long_revolution.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "MODIFIER_ACTIVE", "key": "3"}, {"t": "MODIFIER_ACTIVE", "key": "6"}, {"t": "MODIFIER_ACTIVE", "key": "11"}, {"t": "RESOURCE_AT_LEAST", "key": "year", "v": 1985}, {"t": "NOT_HAS_FLAG", "key": "is_gkchp"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
