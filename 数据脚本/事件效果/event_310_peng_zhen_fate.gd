## 原作 Event310.cs：彭真的命运（平反/处决彭真，两选项）。
## 触发：全目录搜索无 this_num_event = 310 / Reset(310)；链外 REST 段，原版无自动条件。
## 差异：KillPerson 后原版直接改 politics[num] 字段；Godot kill_politician 会替换槽位，
##  因此先 kill 再写槽位字段以对齐；文本来自 Events_text_en 索引 98-103。
extends "res://数据脚本/event_script_base.gd"

const TXT_R0 := "event.script.event_310_peng_zhen_fate.c0"
const TXT_R1 := "event.script.event_310_peng_zhen_fate.c1"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	_enable(event_def.options[0], event_def.options[0].text)
	_enable(event_def.options[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -150)
			var num := 0
			for i in ws.politicians.size():
				var p := ws.politicians[i]
				var minp := ws.politicians[num] if ws.politicians.size() > 0 else null
				if p != null and minp != null and p.power < minp.power:
					num = i
			# 防重名：彭真已登场时不再把别的槽位覆写成彭真。
			if num >= 0 and num < ws.politicians.size() and not PoliticianSystem.has_politician("彭真", 27, 48):
				game.kill_politician(num)
				var p2 := ws.politicians[num]
				if p2 != null:
					PoliticianSystem.apply_historical_profile(
						p2, "彭真", 27, 48,
						GameConstants.PoliticianPersonality.MODERATE,
						GameConstants.PoliticianBackground.PARTY_CADRE,
						GameConstants.PoliticianAlignment.TOLERANT,
						GameConstants.PoliticianSpecial.ECONOMIST,
						d.year - 1902,
						1500, 500
					)
					# 手动从预备池拉人后必须移除同名模板，否则后续死亡补员会再生成一个彭真。
					for i in range(ws.politician_reserve.size() - 1, -1, -1):
						var rp: PoliticianData = ws.politician_reserve[i]
						if rp != null and rp.name_display == "彭真":
							ws.politician_reserve.remove_at(i)
			context["result_text"] = tr(TXT_R0)
		1:
			var num2 := _find_politician(27, 48)
			_add(W.I_ARMY, 50)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality > GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty -= 250
					p.power -= 250
			if num2 >= 0:
				game.kill_politician(num2)
			context["result_text"] = tr(TXT_R1)




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)






func _mod_active(idx: int) -> bool:
	var w: WorldState = ws
	return w != null and w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


func _set_leader_from(p: PoliticianData) -> void:
	if ws.leader == null or p == null:
		return
	ws.leader.name_display = p.name_display
	ws.leader.name_first = p.name_first
	ws.leader.name_last = p.name_last
	ws.leader.trait_personality = p.trait_personality
	ws.leader.trait_background = p.trait_background
	ws.leader.trait_alignment = p.trait_alignment
	ws.leader.trait_special = p.trait_special
	ws.leader.age = p.age
	PoliticianSystem.copy_leader_appearance(ws.leader, p)




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_310_peng_zhen_fate.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_310",
	"num": 310,
	"priority": 31000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_310_peng_zhen_fate.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
