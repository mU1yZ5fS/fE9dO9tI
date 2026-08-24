extends "res://数据脚本/event_script_base.gd"

## 原作 Event466.cs：团结就是力量（印度纳萨尔派二选项）。
## 触发：ReqEventForDLC02.cs:417-419 —— data.naxalite_power>=700；fire_only_once 承担 !event_done[466]。
## 差异：Awake 的 summa_3_2 计算为派系支持率缓存，事件内未使用，跳过；
##   button_text[5]/result_num==5 为死代码，跳过。

const TXT_R1 := "event.script.event_466_unity_is_strength.c0"
const TXT_R0 := "event.script.event_466_unity_is_strength.c1"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			ws.influence_prc -= 20
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -50)
			_add_relation(EmpireData.USSR, -100)
			ws.influence_prc += 20




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_466_unity_is_strength.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_466",
	"num": 466,
	"priority": 46600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_466_unity_is_strength.gd",
	"trigger": [{"t": "RESOURCE_AT_LEAST", "key": "naxalite_power", "v": 700}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
