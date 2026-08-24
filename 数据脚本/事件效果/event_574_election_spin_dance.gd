extends "res://数据脚本/event_script_base.gd"

## 原作 Event574.cs：选举：旋转起舞（澳大利亚大选结果，单选项）。 ## 触发：ReqEventForDLC02.cs:784-787 —— (日>=5 且 月>=3 且 年>=1983) (月>=4 且 年>=1983) 年>=1984 ##   → DATE_AFTER 1983.3.5。 ## 差异： ##  - 描述与结果均按 resultOfEvents[573] 分支（缺省按原版 int 默认 0）； ##  - Vyshi → 亲美；Torg → 对华贸易。


const TXT_DESC_R0 := "event.script.event_574_election_spin_dance.c0"
const TXT_DESC_R1 := "event.script.event_574_election_spin_dance.c1"
const TXT_DESC_R2 := "event.script.event_574_election_spin_dance.c2"


const TXT_R0 := "event.script.event_574_election_spin_dance.c3"
const TXT_R1 := "event.script.event_574_election_spin_dance.c4"
const TXT_R2 := "event.script.event_574_election_spin_dance.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var r573 := int(world.completed_event_ids.get("event_573", 0))
	if r573 == 0:
		event_def.description = tr(TXT_DESC_R0)
	elif r573 == 1:
		event_def.description = tr(TXT_DESC_R1)
	else:
		event_def.description = tr(TXT_DESC_R2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c135 := ws.get_country_by_legacy_index(135)
	var r573 := int(ws.completed_event_ids.get("event_573", 0))
	match r573:
		0:
			_add_power(EmpireData.USA, 20)
			context["result_text"] = tr(TXT_R0)
		1:
			if c135 != null:
				c135.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				c135.set_tag("亲美", false)
				c135.set_tag("对华贸易", true)
			_add_power(EmpireData.USA, -10)
			context["result_text"] = tr(TXT_R1)
		_:
			if c135 != null:
				c135.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			context["result_text"] = tr(TXT_R2)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_574_election_spin_dance.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_574",
	"num": 574,
	"priority": 57400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_574_election_spin_dance.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1983.3.5"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
