extends "res://数据脚本/event_script_base.gd"

## 占位：原版逆向中 Event691.cs 缺失，仅 DiploButtonScript 1073 会触发 number_event=691。
## 这里先提供可运行的数据入口；后续拿到原版 Event691 完整演出后可替换。

const TXT_R0 := "托洛茨基流散海外的遗产被运回国内。暂不公开，仅作为内部档案封存。"
const TXT_R1 := "我们决定吸收托洛茨基的遗产，为中国的托派路线提供理论与历史养分。"
const TXT_R2 := "我们邀请苏联共同研究这批档案，并推动苏方重新评价托洛茨基。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2
		_:
			context["result_text"] = TXT_R0
