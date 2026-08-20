extends "res://数据脚本/event_script_base.gd"

## 原作 Event422.cs：欧洲日落（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1364-1366 —— ExprNode 组合。
## 差异：isEU→标签 eu；power 直接。

const TXT_RESULT := "欧洲的局势更类似于20世纪初的情况......"
const TXT_IDX_1368 := "欧洲日落"
const TXT_IDX_1369 := "显然，在欧洲经济共同体的基础上打造单一经济空间，并构建邦联国家架构的尝试已经落空。因此，实现全面的欧洲一体化的计划已经失败。该组织的主要成员纷纷抛弃了欧洲经济共同体。\n因此，其他仍留在欧共体的国家纷纷宣布取消绝大多数旨在建立单一的政治、货币、经济与关税空间的协定。\n欧洲共同市场实际上已不复存在。"
const TXT_IDX_1370 := "全球主义计划的落幕！"
const TXT_IDX_1371 := "欧洲的局势更类似于20世纪初的情况......"



func _raw(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0






func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s





func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, war_name: String, fortnight: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight

## 原作 Event422.cs:18-21：TextOfEvents 显示时 event_done[421] && iron_and_blood → Set(141)
func prepare(_event_def: EventDef, world: WorldState) -> void:
	if world != null and world.completed_event_ids.has("event_421"):
		Achievements.set_achievement(141)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	if usa != null and usa.power > 0:
		usa.power = 0
	for c in ws.countries:
		if c != null:
			c.set_tag("eu", false)
	context["result_text"] = TXT_RESULT
