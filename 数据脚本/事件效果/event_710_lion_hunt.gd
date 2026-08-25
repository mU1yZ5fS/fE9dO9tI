extends "res://数据脚本/event_script_base.gd"

## 原作 Event710.cs：“猎狮”行动（伊拉克入侵叙利亚，两选项）。
## 触发：event_710_trigger.gd（TimeScript.cs:10580-10586）。
## 效果：c35.parts[1]=true；ingamewars[89] 叙利亚-伊拉克战争：
##   选项0 AttackerInfluence 350/Defender 650；选项1 250/750；
##   均 AmericanSupportAttacker + SovietSupportDefender（→ usa_side = GameConstants.WarSide.SIDE1, ussr_side = GameConstants.WarSide.SIDE2）
##   且 TickTime(24)（→ fortnight_max=24）。
## 差异：描述按 c35.SubGosstroy==15||10 分支；else 分支 {0}=c35.name
##   （Godot 用 name，空则 chinese_name）。

const TXT_DESC_A := "event.script.event_710_lion_hunt.txt_desc_a"

const TXT_DESC_B := "event.script.event_710_lion_hunt.txt_desc_b"

const TXT_DESC_TAIL := "event.script.event_710_lion_hunt.txt_desc_tail"

const TXT_R0 := "event.script.event_710_lion_hunt.txt_r0"

const TXT_R1_PRE := "event.script.event_710_lion_hunt.txt_r1_pre"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var syria := world.get_country_by_legacy_index(35)
	if syria != null and (syria.sub_government == GameConstants.SubGovernment.PRAGMATIST or syria.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST):
		event_def.description = tr(TXT_DESC_A) + tr(TXT_DESC_TAIL)
	else:
		var syria_name := ""
		if syria != null:
			syria_name = syria.name if syria.name != "" else syria.chinese_name
		event_def.description = tr(TXT_DESC_B) + syria_name + tr(TXT_DESC_TAIL)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var syria := ws.get_country_by_legacy_index(35)
	if syria != null:
		_syria_parts_set(syria, 1, true)
	var opt := int(context.get("option_index", -1))
	var leader_name := _leader_name()
	if opt == 0:
		_start_war(350, 650)
		context["result_text"] = tr(TXT_R0)
	elif opt == 1:
		_start_war(250, 750)
		context["result_text"] = tr(TXT_R1_PRE).replace("{0}{1}", leader_name) + "\n" + tr(TXT_R0)


func _start_war(infl1: int, infl2: int) -> void:
	# Event710.cs：AmericanSupportAttacker.SovietSupportDefender.TickTime(24)
	game.start_war(89, "叙利亚", "伊拉克", infl1, infl2, 0, 1)
	if ws.wars.size() > 89 and ws.wars[89] != null:
		ws.wars[89].name_war = "叙利亚-伊拉克战争"
		ws.wars[89].fortnight_max = 24


func _syria_parts_set(syria: CountryData, index: int, value: bool) -> void:
	while syria.parts.size() <= index:
		syria.parts.append(false)
	syria.parts[index] = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
