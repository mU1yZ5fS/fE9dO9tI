extends "res://数据脚本/event_script_base.gd"

const S_14 := "event.script.event_477_britain_popular_satire.c0"
const S_17 := "event.script.event_477_britain_popular_satire.c1"
const S_22 := "event.script.event_477_britain_popular_satire.c2"
const S_27 := "event.script.event_477_britain_popular_satire.c3"
const S_31 := "event.script.event_477_britain_popular_satire.c4"
const S_34 := "event.script.event_477_britain_popular_satire.c5"
const S_36 := "event.script.event_477_britain_popular_satire.c6"
const S_43 := "event.script.event_477_britain_popular_satire.c7"
const S_44 := "event.script.event_477_britain_popular_satire.c8"
const S_45 := "event.script.event_477_britain_popular_satire.c9"
const S_50 := "event.script.event_477_britain_popular_satire.c10"
const S_53 := "event.script.event_477_britain_popular_satire.c11"
const S_61 := "event.script.event_477_britain_popular_satire.c12"
const S_64 := "event.script.event_477_britain_popular_satire.c13"
const S_68 := "event.script.event_477_britain_popular_satire.c14"
const S_72 := "event.script.event_477_britain_popular_satire.c15"
const S_74 := "event.script.event_477_britain_popular_satire.c16"
const S_82 := "event.script.event_477_britain_popular_satire.c17"


## 原作 Event477.cs：受欢迎的讽刺剧（三选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1479-1481 —— c92.Torg && 日期>=1980.3.1。
## 差异：描述按英国政体动态改写；Torg→对华贸易；IsAuthoritarianism→ws.is_authoritarian。

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null:
		return
	var uk := world.get_country_by_legacy_index(92)
	if uk == null:
		return
	if uk.government == GameConstants.Government.LIBERAL:
		event_def.description = tr(S_17)
	elif uk.government == GameConstants.Government.REFORMIST:
		event_def.description = tr(S_22)
	elif world.is_socialism(uk, true):
		event_def.description = tr(S_27)
	if world.is_authoritarian(uk):
		var text := tr(S_31)
		if uk.sub_government == GameConstants.SubGovernment.NEO_FASCIST or uk.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST or _raw_uk(world) == 9:
			text += tr(S_34)
		event_def.description = text + tr(S_36)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uk := ws.get_country_by_legacy_index(92)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, -50)
			context["result_text"] = tr(S_53)
		1:
			var text := tr(S_61)
			if uk != null and (uk.government == GameConstants.Government.LIBERAL or ws.is_authoritarian(uk)):
				text += tr(S_64)
			elif uk != null and uk.government == GameConstants.Government.REFORMIST:
				text += tr(S_68)
			elif uk != null and ws.is_socialism(uk, true):
				text += tr(S_72)
			text += tr(S_74)
			_add(W.I_BUDGET, -20)
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, 80)
			context["result_text"] = text
		2:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_THOUGHT_FREEDOM, 50)
			context["result_text"] = tr(S_82)


func _raw_uk(world: WorldState) -> int:
	if world == null or world.size() <= 147:
		return 0
	return world.britain_political_route





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_477_britain_popular_satire.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_477",
	"num": 477,
	"priority": 47700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_477_britain_popular_satire.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1980.3.1"}, {"t": "COUNTRY_HAS_TAG", "key": "对华贸易", "target": "92"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
