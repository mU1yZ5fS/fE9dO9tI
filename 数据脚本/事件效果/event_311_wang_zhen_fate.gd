extends "res://数据脚本/event_script_base.gd"

## 原作 Event311.cs：王震的命运（2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:504-507 —— NumberOfPolitician(17,17)>=0 且 年>=1981 且 ((党内支持<=750 且 (路线0或1)) 或 event_done[310])。
## 差异：KillPerson→GameManager.kill_politician；文本来自 Events_text_en 索引 104-109。

const TXT_R0 := "关于王震的不利材料被送往档案馆，但在那里它们意外丢失了。"
const TXT_R1 := "你下令开始对王震提起刑事诉讼。面对一切证据确凿的指控，一位前军人，现在的前党员，站在法庭上，疾呼他的敌人捏造了所有案件。但这只不过是为自己徒劳地开脱罢了，因此，王震很快便因与毒贩有牵连和犯下叛国罪而被枪决。"

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world.数值表
	if data.size() <= W.I_YEAR:
		return false
	if data[W.I_YEAR] < 1981:
		return false
	if not _has_politician(world, 17, 17):
		return false
	var party_ok: bool = data[W.I_PARTY_SUPPORT] <= 750 and (GameManager.is_faction_leading(0) or GameManager.is_faction_leading(1))
	return party_ok or world.completed_event_ids.has("event_310")

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_THOUGHT_FREEDOM, 150)
			_add(W.I_ARMY, 150)
			context["result_text"] = TXT_R0
		1:
			var num := _find_politician(17, 17)
			_add(W.I_ARMY, -150)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality > GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty -= 250
					p.power -= 250
			if num >= 0:
				GameManager.kill_politician(num)
			context["result_text"] = TXT_R1

	


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1

func _has_politician(world: WorldState, name1: int, name2: int) -> bool:
	if world == null:
		return false
	for p in world.politicians:
		if p != null and p.name_first == name1 and p.name_last == name2:
			return true
	return false
