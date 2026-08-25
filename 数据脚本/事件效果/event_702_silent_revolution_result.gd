extends "res://数据脚本/event_script_base.gd"

## 原作 Event702.cs：寂静革命的结果（魁北克公投，单选项）。
## 触发：ReqEventsDLC02.cs:1566-1568 —— DATE_AFTER 1980.5.20 → trigger_script evaluate。
## 差异：计分制复刻；Vyshi→亲美、cw→内战中；parts[0] 用 _set_part。

const TXT_R_FAIL := "event.script.event_702_silent_revolution_result.c0"
const TXT_R_WIN := "event.script.event_702_silent_revolution_result.c1"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	var ussr := ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
	var portugal := ws.get_country_by_legacy_index(87)
	var spain := ws.get_country_by_legacy_index(86)
	var quebec := ws.get_country_by_legacy_index(167)
	var china := ws.get_country_by_legacy_index(1)
	var num := 0
	if usa != null and ussr != null and usa.power <= ussr.power:
		num += 1
	if usa != null and usa.power <= 200:
		num += 1
	if usa != null and usa.power <= 0:
		num += 99999
	if spain != null and spain.parts.size() > 1 and spain.parts[0] and spain.parts[1]:
		num += 1
	if portugal != null and portugal.government != GameConstants.Government.LIBERAL:
		num += 1
	if quebec != null and quebec.内战中:
		num += 1
	if ws.result_of_event_num(701) == 1:
		num += 1
	if _res(W.I_TERRITORY) > 21:
		num += 1
	if china != null and china.government == GameConstants.Government.LIBERAL:
		num += 1
	if num < 5:
		context["result_text"] = tr(TXT_R_FAIL)
		return
	context["result_text"] = tr(TXT_R_WIN)
	if quebec != null:
		_set_part(quebec, 0, true)
		_leave_alliances(quebec)
		quebec.government = GameConstants.Government.LIBERAL
		quebec.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
		quebec.set_tag("亲美", true)
	if MapService.instance != null:
		MapService.instance.sync_map_merges()


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value


func evaluate(world: WorldState) -> bool:
	return world != null and world.date != null and world.date.to_int() >= 19800520



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_702_silent_revolution_result.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_702",
	"num": 702,
	"priority": 70200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_702_silent_revolution_result.gd",
	"trigger_script": "res://数据脚本/事件效果/event_702_silent_revolution_result.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
