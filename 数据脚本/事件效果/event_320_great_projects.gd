extends "res://数据脚本/event_script_base.gd"

## 原作 Event320.cs：大型工程（5选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:534-537 —— 日>=19 月>=10 年>=1978。
## 差异：modifies[34].active→_set_mod_active(34,true)；old_modify_desc[34] 为修正说明文案跳过。

const TXT_R0 := "event.script.event_320_great_projects.c0"
const TXT_R1 := "event.script.event_320_great_projects.c1"
const TXT_R2 := "event.script.event_320_great_projects.c2"
const TXT_R3 := "event.script.event_320_great_projects.c3"
const TXT_R4 := "event.script.event_320_great_projects.c4"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -100)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			ws.influence_prc += 5
			_set_mod_active(34, true)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -100)
			ws.influence_prc += 5
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_set_mod_active(34, true)
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_BUDGET, -150)
			ws.influence_prc += 5
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, 150)
			_set_mod_active(34, true)
			context["result_text"] = tr(TXT_R3)
		4:
			_add(W.I_BUDGET, -50)
			ws.influence_prc += 5
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, 150)
			_set_mod_active(34, true)
			context["result_text"] = tr(TXT_R4)

	


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value



## ── 原版 display-only 文案（跳过执行，仅保留供逐字校验） ──
## 三北防护林：|农业+0.7，工业+0.2，预算-0.3，统一度+0.2，人民支持度+0.1
## 南水北调工程：|农业+0.3，工业+0.5，预算-0.5，凝聚力+0.2
## 三北防护林：|农业+0.7，工业+0.2，预算-0.3，统一度+0.2，人民支持度+0.1|南水北调工程：|农业+0.3，工业+0.5，预算-0.5，凝聚力+0.2
## 江淮运河：|服务业+0.1，工业+0.1，预算+0.2



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_320_great_projects.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_320",
	"num": 320,
	"priority": 32000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_320_great_projects.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.10.19"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
