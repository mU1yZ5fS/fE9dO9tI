extends "res://数据脚本/event_script_base.gd"

## 原作 Event2000.cs：测试事件（6 选项，各把中国 SubGosstroy 设为 0-5）。
## 触发：全目录 grep 无任何自动触发点，原版无自动条件（测试事件，手动触发），
##   故 trigger_conditions=[]。

const TXT_OPT := "测试"
const TXT_R := "测试"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var china := ws.get_country_by_legacy_index(1)
	var opt := int(context.get("option_index", -1))
	context["result_text"] = TXT_R
	if china != null and opt >= 0 and opt <= 5:
		china.sub_government = opt
