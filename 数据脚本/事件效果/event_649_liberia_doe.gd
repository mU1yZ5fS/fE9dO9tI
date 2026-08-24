extends "res://数据脚本/event_script_base.gd"

## 原作 Event649.cs：从应许之地到应许之地（利比里亚多伊政变，二选项）。
## 触发：TimeScript.cs:11013-11019 —— 日>=12 且 月>=4 且 年>=1980
##   （或 月>=5 年>=1980 / 年>=1981）。
## 差异：Vyshi→亲美；c67=利比里亚。




const TXT_R0 := "event.script.event_649_liberia_doe.c0"

const TXT_R1 := "event.script.event_649_liberia_doe.c1"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var liberia := ws.get_country_by_legacy_index(67)
	if liberia != null:
		liberia.government = GameConstants.Government.AUTHORITARIAN
		liberia.sub_government = GameConstants.SubGovernment.NEOPATRIARCHAL
		liberia.set_tag("亲美", true)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, 10)
			if liberia != null:
				liberia.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_649_liberia_doe.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_649",
	"num": 649,
	"priority": 64900,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1980.4.12"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
