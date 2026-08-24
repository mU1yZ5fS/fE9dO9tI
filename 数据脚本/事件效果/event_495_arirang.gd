extends "res://数据脚本/event_script_base.gd"

## 原作 Event495.cs：阿里郎，阿里郎（朝韩和平统一，二选项）。
## 触发：DiploButtonScript.cs:11468 —— this_type==1013 外交按钮手动触发；
##   按项目约定 trigger_conditions=[]（仅定义，待外交入口接入）。
## 差异：
##  - SubGosstroy/Gosstroy → sub_government/government；
##  - name → name/chinese_name；Torg → set_tag("对华贸易", true)；
##  - parts[0] 用 _set_part 置位；LeaveAlliances() → _leave_alliances。




const TXT_R0 := "event.script.event_495_arirang.c0"

const TXT_R1_PRE := "event.script.event_495_arirang.c1"
const TXT_R1_KIM := "event.script.event_495_arirang.c2"
const TXT_R1_JANG := "event.script.event_495_arirang.c3"
const TXT_R1_MID := "event.script.event_495_arirang.c4"
const TXT_R1_KIMDAE := "event.script.event_495_arirang.c5"
const TXT_R1_AHN := "event.script.event_495_arirang.c6"
const TXT_R1_POST := "event.script.event_495_arirang.c7"

const TXT_NAME_UNIFIED := "event.script.event_495_arirang.c8"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var north := ws.get_country_by_legacy_index(10)
	var south := ws.get_country_by_legacy_index(46)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			var text := tr(TXT_R1_PRE)
			if north != null and north.sub_government == GameConstants.SubGovernment.PRAGMATIST:
				text += tr(TXT_R1_KIM)
			else:
				text += tr(TXT_R1_JANG)
			text += tr(TXT_R1_MID)
			if south != null and south.government == GameConstants.Government.LIBERAL:
				text += tr(TXT_R1_KIMDAE)
			else:
				text += tr(TXT_R1_AHN)
			text += tr(TXT_R1_POST)
			if north != null:
				_set_part(north, 0, true)
				north.government = GameConstants.Government.REFORMIST
				north.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				north.name = tr(TXT_NAME_UNIFIED)
				north.chinese_name = tr(TXT_NAME_UNIFIED)
				_leave_alliances(north)
				north.set_tag("对华贸易", true)
			context["result_text"] = text


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_495_arirang.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_495",
	"num": 495,
	"priority": 49500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_495_arirang.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
