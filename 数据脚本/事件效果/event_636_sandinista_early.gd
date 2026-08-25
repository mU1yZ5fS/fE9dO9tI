extends "res://数据脚本/event_script_base.gd"

## 原作 Event636.cs：别让我失望啊，兄弟（尼加拉瓜桑解阵早期支援，二选项）。 ## 触发：ReqEventsDLC02.cs:986-989 —— DATE_AFTER 1976.5.10 ##   （原 (1976&&m>=5&&d>=10) (1976&&m>=6) y>=1977）。

const TXT_R0 := "event.script.event_636_sandinista_early.c0"
const TXT_R1 := "event.script.event_636_sandinista_early.c1"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nicaragua := ws.get_country_by_legacy_index(147)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if nicaragua != null:
				nicaragua.level_of_instability += 50
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			ws.influence_prc += 5
			_add_power(EmpireData.USA, -5)
			_add_relation(EmpireData.USA, -50)
		1:
			context["result_text"] = tr(TXT_R1)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_636_sandinista_early.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_636",
	"num": 636,
	"priority": 63600,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1976.5.10"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
