extends "res://数据脚本/event_script_base.gd"

## 原作 Event118.cs：“和平之国达鲁萨兰”的再回（文莱独立，单选项）。
## 触发：TimeScript.cs:10836-10842 ——
##   ((日>=9 且 月>=1 且 年>=1984) || (月>=2 且 年>=1984) || 年>=1985)
##   && !c49.parts[0]（端口未建模，默认空数组视为 false → 恒真，沿用事件91注释）。
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
			brunei.government = 0
			brunei.sub_government = 13
		if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
			ws.empires[EmpireData.USA].power += 20
		context["result_text"] = TXT_RESULT
