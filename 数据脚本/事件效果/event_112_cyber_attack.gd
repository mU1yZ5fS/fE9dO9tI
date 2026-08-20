extends "res://数据脚本/event_script_base.gd"

## 原作 Event112.cs：来自0和1的冲击（IECS 网络攻击，三选项）。
## 触发：TimeScript.cs:10971-10977 —— modifies[11].active && c1.okb
##   && 年>=1984 && event_done[110]。
## 差异：
##  - 文案与选项按 event_done[494] && resultOfEvents[494]==0 双分支（prepare/结果）。
##  - r2 的 load_scene_after_click → Ending6：Godot 设 d[I_ENDING_ROUTE]=6。
##  - relres → global flag；modifies[3]/[11] → modifiers 槽 active。
##  - data12/13/68 → 工业/农业/服务业产值。


const TXT_DESC_494 := "主席同志，预料之中的大规模计算机网络攻击来临了!全国各地的部门间组织都收到了影响。基层企业之间的信息被破坏，食品被运送到有中断的地区，商店里的队伍越来越长。根据管理者们的保证，我们的设备遭到了来自外部的计算机攻击。情报机构认为，这些人是我们的外部对手，担心我们在世界舞台上的影响力不可避免地增长，所以他们与自动化的敌人合谋，试图通过破坏IECS来打击我们的经济。\n然而，考虑到我们之前已经建立了关于IECS系统的初步防护，也提前准备了关于IECS网络被攻击的应急预案，并在攻击来临时及时的执行了预案，这些攻击者攻击造成的损失没有预想中的那么大。专家建议继续升级规划系统的特殊保护防火墙，但这需要一些时间。但是，我们可以请求苏联专家的支持，这将使我们能够迅速地使设备恢复运作。还是……自动化真的只是乌托邦吗?"

const TXT_DESC_OTHER := "主席同志，怪事发生了!全国各地的部门间组织都失败了。基层企业之间的信息被破坏，食品被运送到有中断的地区，商店里的队伍越来越长。根据管理者们的保证，我们的设备遭到了来自外部的计算机攻击。情报机构认为，这些人是我们的外部对手，担心我们在世界舞台上的影响力不可避免地增长，所以他们与自动化的敌人合谋，他试图通过破坏IECS来打击我们的经济。如果我们仍然无所作为，这将导致我们国家的崩溃。专家建议为我们的规划系统开发特殊保护，但这需要一些时间。但是，我们可以请求苏联专家的支持，这将使我们能够迅速地使设备恢复运作。还是……自动化真的只是乌托邦吗?"

const TXT_OPT0_494 := "拨款发展一套保障制度（需要25百万预算）"
const TXT_OPT0_OTHER := "继续升级我们的自动化系统的防护系统"
const TXT_OPT1_494 := "为发展提供资金，并要求苏联专家提供援助(需要25百万预算)"
const TXT_OPT1_OTHER := "继续升级我们的自动化系统的防护系统，并要求苏联科学家提供援助"
const TXT_OPT1_DIS := "苏维埃不会帮助我们"
const TXT_OPT2_DIS := "我们不能放弃我们的成就!"

const TXT_R0_494 := "我们着手于继续升级并完善我们的“中国长城”防火墙系统，以提高IECS应对外部攻击的能力。得以于之前的防护系统，我们的经济所遭到的损失并不算严重。"
const TXT_R0_OTHER := "政府紧急拨款开发了一个工作代号为“中国长城”的系统，以保护IECS免受外部攻击。人们认为，保护措施将在八个月内准备就绪并投入使用，但就目前而言，我们的经济不会一帆风顺。"
const TXT_R1_494 := "我们着手于继续升级并完善我们的“中国长城”防火墙系统，以提高IECS应对外部攻击的能力，与此同时，我们寻求苏联科学家与工程师的帮助，他们将帮助我们迅速消除系统中的漏洞并升级防护系统。得以于之前的防护系统，我们的经济所遭到的损失并不算严重。"
const TXT_R1_OTHER := "政府紧急拨款开发了一个工作代号为“中国长城”的系统，以保护IECS免受外部攻击。此外，我们请求苏联专家和工程师的帮助，他们将帮助我们迅速消除系统中的漏洞并使其恢复运行。人们认为，保护措施将在六个月内准备就绪并投入使用，但就目前而言，我们的经济不会一帆风顺。"
const TXT_R2 := "你在自动化经济方面近乎开玩笑的态度惹毛了大多数党员——先是一厢情愿的宣布中国将全面施行自动化，又通过各种手段清除掉与你关系最不好的反对派头头，现在却又说中国没有准备好应对这种变化；党受够了你的领导，密谋者暗中组织了一场政变，将你解职并踢出中央委员会，丢到了一个偏远的清水衙门。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var is_494 := _is_494_route(world)
	event_def.description = TXT_DESC_494 if is_494 else TXT_DESC_OTHER

	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 1
	var party := data[W.I_PARTY_SYSTEM] if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var ussr_rel := world.empires[EmpireData.USSR].relations if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null else 0
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0_494 if is_494 else TXT_OPT0_OTHER)
	if ussr_rel >= 800 and world.get_flag("relres") and mod3:
		_enable(opt[1], TXT_OPT1_494 if is_494 else TXT_OPT1_OTHER)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if (line > 0 and party < 8) or (coal > 66 and party > 7):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var is_494 := _is_494_route(ws)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if is_494:
				_add(W.I_BUDGET, -10)
				_add(W.I_PEOPLE_SUPPORT, -50)
				_add(W.I_THOUGHT_FREEDOM, 100)
				_add(W.I_PARTY_SUPPORT, -300)
				_add(W.I_LIVING, -30)
				_add(W.I_INDUSTRY, -50)
				_add(W.I_AGRICULTURE, -50)
				_add(W.I_SERVICES, -50)
				context["result_text"] = TXT_R0_494
			else:
				_add(W.I_BUDGET, -250)
				_add(W.I_PEOPLE_SUPPORT, -150)
				_add(W.I_THOUGHT_FREEDOM, 300)
				_add(W.I_PARTY_SUPPORT, -300)
				_add(W.I_LIVING, -100)
				_add(W.I_INDUSTRY, -200)
				_add(W.I_AGRICULTURE, -200)
				_add(W.I_SERVICES, -200)
				context["result_text"] = TXT_R0_OTHER
		1:
			if is_494:
				_add(W.I_BUDGET, -10)
				_add(W.I_PEOPLE_SUPPORT, -50)
				_add(W.I_THOUGHT_FREEDOM, 100)
				_add(W.I_PARTY_SUPPORT, -300)
				_add(W.I_LIVING, -30)
				context["result_text"] = TXT_R1_494
			else:
				_add(W.I_BUDGET, -250)
				_add(W.I_PEOPLE_SUPPORT, -150)
				_add(W.I_THOUGHT_FREEDOM, 300)
				_add(W.I_PARTY_SUPPORT, -300)
				_add(W.I_LIVING, -100)
				context["result_text"] = TXT_R1_OTHER
		2:
			_add(W.I_BUDGET, -250)
			_add(W.I_PEOPLE_SUPPORT, -300)
			_add(W.I_THOUGHT_FREEDOM, 500)
			if d.size() > W.I_ECON_SYSTEM:
				d[W.I_ECON_SYSTEM] = 10
			_add(W.I_LIVING, -100)
			_add(W.I_INDUSTRY, -200)
			_add(W.I_AGRICULTURE, -200)
			_add(W.I_SERVICES, -200)
			if ws.modifiers.size() > 11 and ws.modifiers[11] != null:
				ws.modifiers[11].is_active = false
			if d.size() > W.I_PARTY_SUPPORT:
				d[W.I_PARTY_SUPPORT] = 0
			if d.size() > W.I_PEOPLE_SUPPORT:
				d[W.I_PEOPLE_SUPPORT] = 0
			if d.size() > W.I_ENDING_ROUTE:
				d[W.I_ENDING_ROUTE] = 6
			# 原 Event112.cs:164：data[35]=6 + load_scene_after_click。
			GameManager.queue_ending_after_event(6)
			context["result_text"] = TXT_R2


func _is_494_route(world: WorldState) -> bool:
	if world == null:
		return false
	return world.completed_event_ids.has("event_494") and int(world.completed_event_ids.get("event_494", -1)) == 0


func _coalition_percent(world: WorldState) -> int:
	var data := world.数值表
	if data.size() <= W.I_PARTY_SYSTEM or data[W.I_PARTY_SYSTEM] <= 7:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total


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


