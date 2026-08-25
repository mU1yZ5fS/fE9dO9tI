extends "res://数据脚本/event_script_base.gd"

## 原作 Event564.cs：安拉，叙利亚，阿萨德（叙利亚阿萨德，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:764-766 —— (1980.6.1 或 1981+)。
## 差异：load_scene_after_click → EventEngine.enqueue_chain(["event_565"])。

const TXT_OPT1_DIS := "event.script.event_564_allah_syria_asad.c0"
const TXT_R0 := "event.script.event_564_allah_syria_asad.c1"
const TXT_R1 := "event.script.event_564_allah_syria_asad.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var c35 := world.get_country_by_legacy_index(35)
	if c35 != null and c35.内战中 and d.political_line != 2 and not ws.completed_event_ids.has("event_707"):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c35 := ws.get_country_by_legacy_index(35)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			if c35 != null:
				c35.set_tag("对华贸易", false)
				c35.government = GameConstants.Government.AUTHORITARIAN
				c35.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			_add_relation(EmpireData.USSR, -150)
			_add_relation(EmpireData.USA, -150)
			EventEngine.enqueue_chain(["event_565"])
			context["result_text"] = tr(TXT_R1)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_564_allah_syria_asad.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_564",
	"num": 564,
	"priority": 56400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_564_allah_syria_asad.gd",
	"trigger": [{"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1980.6.1"}, {"t": "DATE_AFTER", "key": "1981.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
