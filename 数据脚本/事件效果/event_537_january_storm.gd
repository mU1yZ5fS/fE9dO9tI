extends "res://数据脚本/event_script_base.gd"

## 原作 Event537.cs：一月风暴（日本社会主义工人党起事，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:307-309 ——
##   event_done[533] && resultOfEvents[533]==0 && !IsAuthoritarianism(86) &&
##   c86.Gosstroy!=3 && !IsAuthoritarianism(87) && c87.Gosstroy!=3 &&
##   c21.SubGosstroy==18 && c92.SubGosstroy==18 && modifies[49].active &&
##   c44.Gosstroy==3 && c44.prcpower>=200 && (1985.1 或 1986+)。
## 差异：IsAuthoritarianism→government == GameConstants.Government.AUTHORITARIAN&&sub_government != GameConstants.SubGovernment.LEFT_RADICAL 复合 ExprNode。

const TXT_OPT0_DIS := "event.script.event_537_january_storm.c0"
const TXT_R0 := "event.script.event_537_january_storm.c1"
const TXT_R1 := "event.script.event_537_january_storm.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	if d.political_line < 2:
		_enable(event_def.options[0], event_def.options[0].text)
	else:
		_disable(event_def.options[0], tr(TXT_OPT0_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c44 := ws.get_country_by_legacy_index(44)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if c44 != null:
				c44.government = GameConstants.Government.SOCIALIST
				c44.sub_government = GameConstants.SubGovernment.TROTSKYIST
				c44.set_tag("亲美", false)
				c44.set_tag("亲中", true)
				c44.set_tag("对华贸易", true)
				c44.name = "日本革命社会主义共和国"
				c44.chinese_name = "日本革命社会主义共和国"
				_join_alliances(c44)
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
			_add(W.I_ARMY, -200)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_DIPLO, 25)
			ws.influence_prc += 80
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_537_january_storm.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_537",
	"num": 537,
	"priority": 53700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_537_january_storm.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_533"}, {"t": "PREV_EVENT_RESULT_IS", "ref": "event_533"}, {"t": "NOT", "c": [{"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "government", "target": "86"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "target": "86"}]}]}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "government", "v": 3, "target": "86"}, {"t": "NOT", "c": [{"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "government", "target": "87"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "target": "87"}]}]}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "government", "v": 3, "target": "87"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 18, "target": "21"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 18, "target": "92"}, {"t": "MODIFIER_ACTIVE", "key": "49"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 3, "target": "44"}, {"t": "COUNTRY_FIELD_AT_LEAST", "key": "prc_power", "v": 200, "target": "44"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1985.1.1"}, {"t": "DATE_AFTER", "key": "1986.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
