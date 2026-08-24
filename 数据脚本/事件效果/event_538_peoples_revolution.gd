extends "res://数据脚本/event_script_base.gd"

## 原作 Event538.cs：人民的革命！（日本革命战争，1选项）。
## 触发：无自动触发（DiploButtonScript.cs:11486 外交按钮 number_event=538）。
## 差异：ingamewars[36] → game.start_war + WarData 字段。

const TXT_R0 := "event.script.event_538_peoples_revolution.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c44 := ws.get_country_by_legacy_index(44)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		if c44 != null:
			c44.government = GameConstants.Government.AUTHORITARIAN
			c44.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		game.start_war(36, "日本政府", "日本人民革命阵线", 700, 300, 0, -1)
		if ws.wars.size() > 36 and ws.wars[36] != null:
			ws.wars[36].name_war = "日本革命战争"
			ws.wars[36].fortnight_max = 20
		context["result_text"] = tr(TXT_R0)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_538_peoples_revolution.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_538",
	"num": 538,
	"priority": 53800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_538_peoples_revolution.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
