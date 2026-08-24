extends "res://数据脚本/event_script_base.gd"

## 原作 Event711.cs：碾碎他们，我的兄弟们（第五次中东战争，单选项）。
## 触发：TimeScript.cs:10588-10594 —— c14.SubGosstroy==19 && c14.puppetOf<0
##   && !c51.isNATO && c37.Gosstroy==3 && c35/c93/c104.SubGosstroy==19
##   （全部由 .tres ExprNode 表达）。
## 效果：ingamewars[4] = 第五次中东战争，伊拉克(700) vs 以色列(300)，
##   TickTime(24)（→ fortnight_max=24），无美苏支持标记（usa/ussr_side = GameConstants.WarSide.SIDE1 默认）。

const TXT_RESULT := "event.script.event_711_fifth_middle_east_war.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		game.start_war(4, "伊拉克", "以色列", 700, 300, 0, 0)
		if ws.wars.size() > 4 and ws.wars[4] != null:
			ws.wars[4].name_war = "第五次中东战争"
			ws.wars[4].fortnight_max = 24  # 原版 TickTime(24)
		context["result_text"] = tr(TXT_RESULT)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_711_fifth_middle_east_war.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_711",
	"num": 711,
	"priority": 7110,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 19, "target": "14"}, {"t": "COUNTRY_FIELD_AT_MOST", "key": "puppet_of", "v": -1, "target": "14"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "51"}]}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 3, "target": "37"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 19, "target": "35"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 19, "target": "93"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 19, "target": "104"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
