extends "res://数据脚本/event_script_base.gd"

## 原作 Event312.cs：李先念的命运（2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:509-512 —— NumberOfPolitician(7,7)>=0 且 年>=1981 且 ((党内支持<=750 且 (路线0或1)) 或 NumberOfPolitician(17,17)<0 或 event_done[311])。
## 差异：KillPerson→GameManager.kill_politician；文本来自 Events_text_en 索引 110-115。

const TXT_R0 := "对李先念同志的指控是从边缘的极左派那里听到的。他们想通过除掉一个重要的党员来巩固他们那毫无价值的地位！我们不会允许的！"
const TXT_R1 := "显而易见，李先念是经济失败的罪魁祸首！从这份文件中便可见一斑！毛主席的昔日同僚怎会如此无能糊涂？当然没这么简单！这显然是同中国敌人勾结的阴谋！"

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world.数值表
	if data.size() <= W.I_YEAR:
		return false
	if data[W.I_YEAR] < 1981:
		return false
	if not _has_politician(world, 7, 7):
		return false
	var party_ok: bool = data[W.I_PARTY_SUPPORT] <= 750 and (GameManager.is_faction_leading(0) or GameManager.is_faction_leading(1))
	var chain_ok := (not _has_politician(world, 17, 17)) or world.completed_event_ids.has("event_311")
	return party_ok or chain_ok

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -150)
			context["result_text"] = TXT_R0
		1:
			var num := _find_politician(7, 7)
			_add(W.I_PARTY_SUPPORT, 150)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality > 1:
					p.loyalty -= 250
					p.power -= 250
			if num >= 0:
				GameManager.kill_politician(num)
			context["result_text"] = TXT_R1

	
func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null

func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n




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
