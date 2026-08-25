extends "res://数据脚本/event_script_base.gd"

const S_14 := "event.script.event_482_france_orthodox_return.c0"
const S_15 := "event.script.event_482_france_orthodox_return.c1"
const S_21 := "event.script.event_482_france_orthodox_return.c2"
const S_22 := "event.script.event_482_france_orthodox_return.c3"
const S_27 := "event.script.event_482_france_orthodox_return.c4"
const S_30 := "event.script.event_482_france_orthodox_return.c5"
const S_34 := "event.script.event_482_france_orthodox_return.c6"
const S_38 := "event.script.event_482_france_orthodox_return.c7"
const S_39 := "event.script.event_482_france_orthodox_return.c8"
const S_40 := "event.script.event_482_france_orthodox_return.c9"


## 原作 Event482.cs：回归正统（两选项）。
## 触发：无自动触发点——原版由 DiploButtonScript.cs:11443（this_type==1010）手动
##   number_event=482 进入；Godot 侧 trigger_conditions=[]。
## 差异：
##  - YugAgree→ws.set_flag("YugAgree")；
##  - old_modify_texts[44]/old_modify_desc[44]/old_modify_desc[56] 为运行时修正展示文案，
##    Godot 由 ModifierCatalog 动态生成，这里仅保留原文字符串常量（S_38/S_39/S_40）备查，不写入修正系统。

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(S_30)
		1:
			ws.set_flag("YugAgree", true)
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -100)
			context["result_text"] = tr(S_34)





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_482_france_orthodox_return.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_482",
	"num": 482,
	"priority": 48200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_482_france_orthodox_return.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
