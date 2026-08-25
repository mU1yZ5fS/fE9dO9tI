extends "res://数据脚本/event_script_base.gd"

## 原作 Event475.cs：谁是我的敌人？（埃塞俄比亚安排三选项）。
## 触发：ReqEventForDLC02.cs:1444-1446 —— 复合条件（parts 数组）用 trigger_script
##   evaluate(world) 表达；fire_only_once 承担 !event_done[475]。
## 差异：based→有驻军基地；EstablishGovernment(ProChina) 在 Godot 侧以亲中/对华贸易标签近似。

const TXT_R0 := "event.script.event_475_who_is_my_enemy.c0"
const TXT_R1 := "event.script.event_475_who_is_my_enemy.c1"
const TXT_R2 := "event.script.event_475_who_is_my_enemy.c2"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var ethiopia := _country(41)
	var eritrea := _country(99)
	var tigray := _country(100)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add_relation(EmpireData.USSR, 50)
			_add_relation(EmpireData.USA, 50)
			ws.influence_prc += 20
		1:
			context["result_text"] = tr(TXT_R1)
			if ethiopia != null:
				_setup_breakaway(eritrea, ethiopia)
				_setup_breakaway(tigray, ethiopia)
			ws.influence_prc += 10
		2:
			context["result_text"] = tr(TXT_R2)
			if ethiopia != null:
				_setup_breakaway(eritrea, ethiopia)
			ws.influence_prc += 10



func evaluate(world: WorldState) -> bool:

	if world == null:
		return false
	var ethiopia := world.get_country_by_legacy_index(41)
	if ethiopia == null or not ethiopia.has_tag("亲中") or ethiopia.government == GameConstants.Government.REFORMIST:
		return false
	if world.wars.size() <= 24 or world.wars[24] == null:
		return false
	if world.wars[24].infl2 < 900:
		return false
	if ethiopia.has_part(0) or ethiopia.has_part(1):
		return false
	return true



func _setup_breakaway(c: CountryData, ethiopia: CountryData) -> void:
	if c == null or ethiopia == null:
		return
	_set_part(c, 0, true)
	c.government = ethiopia.government
	c.sub_government = ethiopia.sub_government
	c.set_tag("亲中", true)
	c.set_tag("对华贸易", true)
	c.有驻军基地 = true



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
	c.set_part(index, value)

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.has_part(index)

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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_475_who_is_my_enemy.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_475",
	"num": 475,
	"priority": 47500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_475_who_is_my_enemy.gd",
	"trigger_script": "res://数据脚本/事件效果/event_475_who_is_my_enemy.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
