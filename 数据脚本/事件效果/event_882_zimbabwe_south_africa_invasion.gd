extends "res://数据脚本/event_script_base.gd"

## 原作 Event882.cs：罗德斯与伊安的土地（南非入侵津巴布韦，单选项）。
## 触发：原版无自动条件；由 Event881.cs 结果后 load_scene_after_click →
##   number_event=882。项目已由 event_881_zimbabwe_election.gd 的
##   EventEngine.enqueue_chain(["event_882"]) 承接，故 trigger_conditions=[]。
## 差异：
##  - level_of_unstab→level_of_instability；resultOfEvents[609]==0 缺省按原版 0；
##  - War().Name(...).Attacker(...).Defender(...).TickTime(24)
##    .AmericanSupportAttacker.SovietSupportDefender → game.start_war()
##    后覆盖 name_war/fortnight_max。

const TXT_R0 := "event.script.event_882_zimbabwe_south_africa_invasion.c0"
const WAR_NAME := "event.script.event_882_zimbabwe_south_africa_invasion.c1"
const WAR_SIDE1 := "event.script.event_882_zimbabwe_south_africa_invasion.c2"
const WAR_SIDE2 := "event.script.event_882_zimbabwe_south_africa_invasion.c3"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var zimbabwe := ws.get_country_by_legacy_index(127)
	var zambia := ws.get_country_by_legacy_index(126)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		context["result_text"] = tr(TXT_R0)
		if zimbabwe != null:
			if zimbabwe.parts.size() == 0:
				zimbabwe.parts.resize(1)
			zimbabwe.parts[0] = true
		if zambia != null:
			zambia.level_of_instability -= 200
		var num := 0
		# 原版 resultOfEvents[609]==0 缺省为 0（未触发时同样成立）
		if ws.completed_event_ids.get("event_609", 0) == 0:
			num = 50
		game.start_war(44, tr(WAR_SIDE1), tr(WAR_SIDE2), 700 - num, 300 + num, 0, 1)
		if ws.wars.size() > 44 and ws.wars[44] != null:
			ws.wars[44].name_war = tr(WAR_NAME)
			ws.wars[44].fortnight_max = 24



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_882_zimbabwe_south_africa_invasion.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_882",
	"num": 882,
	"priority": 88200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_882_zimbabwe_south_africa_invasion.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
