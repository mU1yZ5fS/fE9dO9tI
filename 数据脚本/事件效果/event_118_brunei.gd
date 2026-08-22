extends "res://数据脚本/event_script_base.gd"

## 原作 Event118.cs：“和平之国达鲁萨兰”的再回（文莱独立，单选项）。
## 触发：TimeScript.cs:10836-10842 ——
##   ((日>=9 且 月>=1 且 年>=1984) || (月>=2 且 年>=1984) || 年>=1985)
##   && !c49.parts[0]（已由本脚本 evaluate 实现，见文件底部；c49=马来西亚原版序号）。
## 效果：c111.isASEAN=true（→ set_tag("asean", true)）、Gosstroy=0、SubGosstroy=13、
##   USA power+=20。选项文本取自 new_events_text[1433]“密切关注......”。

const TXT_RESULT := "独立以后，苏丹政府大力推行“马来化、伊斯兰化和君主制”政策，巩固王室统治，重点扶持马来族等土著人的经济，在进行现代化建设的同时严格维护伊斯兰教义。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var brunei := ws.get_country_by_legacy_index(111)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		if brunei != null:
			brunei.set_tag("asean", true)
			brunei.government = GameConstants.Government.AUTHORITARIAN
			brunei.sub_government = GameConstants.SubGovernment.NEOPATRIARCHAL
		if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
			ws.empires[EmpireData.USA].power = clampi(ws.empires[EmpireData.USA].power + 20, 0, 1000)
		context["result_text"] = TXT_RESULT


## TimeScript.cs:10838 触发守卫：!(c49.parts[0])。
## c49=马来西亚（原版序号49）。parts 为空时 parts[0] 视为 false，事件照常触发。
func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null:
		return false
	var y := world.date.year
	var m := world.date.month
	var day := world.date.day
	if not ((day >= 9 and m >= 1 and y >= 1984) or (m >= 2 and y >= 1984) or y >= 1985):
		return false
	var malaya := world.get_country_by_legacy_index(49)
	if malaya != null and malaya.parts.size() > 0 and malaya.parts[0]:
		return false
	return true
