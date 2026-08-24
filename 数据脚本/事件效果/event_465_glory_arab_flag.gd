extends "res://数据脚本/event_script_base.gd"

## 原作 Event465.cs：荣耀归你，阿拉伯之旗（单选项）。
## 触发：GlobalScript.cs:40 的 Decision 链 StartEvent(465)（决议系统移植说明）。
##   按项目约定 trigger_conditions=[]（仅定义，待决策系统接入）。
## 差异：parts[0] 写前 resize；oar/isOVD/isSEV/okb/econ/Torg/prosov/Vyshi/proprc→set_tag。

const TXT_R0 := "event.script.event_465_glory_arab_flag.c0"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_DIPLO, 50)
			ws.influence_prc += 100
			_add_relation(EmpireData.USA, -200)
			var morocco := _country(54)
			if morocco != null:
				_set_part(morocco, 0, true)
			_tag(30, "亲中", false)
			for idx in [18, 54, 55]:
				var c := _country(idx)
				if c == null:
					continue
				c.set_tag("亲苏", false)
				c.set_tag("亲美", false)
				c.set_tag("亲中", false)
				c.set_tag("sev", false)
				c.set_tag("ovd", false)
				c.set_tag("okb", false)
				c.set_tag("econ", false)
				c.set_tag("对华贸易", false)
				c.set_tag("oar", false)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_465_glory_arab_flag.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_465",
	"num": 465,
	"priority": 46500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_465_glory_arab_flag.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
