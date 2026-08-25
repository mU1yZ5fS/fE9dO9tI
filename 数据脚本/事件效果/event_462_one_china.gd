extends "res://数据脚本/event_script_base.gd"

## 原作 Event462.cs：一个中国?（单选项）。
## 触发：GlobalScript.cs:26 的 Decision 链 StartEvent(462)（决议系统移植说明）。
##   按项目约定 trigger_conditions=[]（仅定义，待决策系统接入）。
## 差异：names1/names2 拼接→ws.leader.name_display。

const TXT_R0_P1 := "event.script.event_462_one_china.c0"
const TXT_R0_NIAN := "event.script.event_462_one_china.c1"
const TXT_R0_YUE := "event.script.event_462_one_china.c2"
const TXT_R0_P2 := "event.script.event_462_one_china.c3"
const TXT_R0_P3 := "event.script.event_462_one_china.c4"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var taiwan := _country(38)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var year := str(_res(W.I_YEAR))
			var month := str(_res(W.I_MONTH))
			var day := str(_res(W.I_DAY))
			context["result_text"] = tr(TXT_R0_P1) + year + tr(TXT_R0_NIAN) + month + tr(TXT_R0_YUE) + day + tr(TXT_R0_P2) + _leader_name() + tr(TXT_R0_P3)
			if taiwan != null:
				taiwan.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)


func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)


func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_462_one_china.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_462",
	"num": 462,
	"priority": 46200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_462_one_china.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
