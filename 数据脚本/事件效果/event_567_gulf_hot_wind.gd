extends "res://数据脚本/event_script_base.gd"

## 原作 Event567.cs：自由的热风（阿湾人阵重建，二选项）。
## 触发：DiploButtonScript.cs:11533 —— number_event = 567（外交按钮手动触发），无自动触发。
## 差异：
##  - parts[0] → _part(c24, 0)；cw → 内战中；proprc → 亲中；prcpower → prc_power；
##  - resultOfEvents 缺省按原版 int 默认 0 处理；
##  - event_done[567]=false → completed_event_ids.erase("event_567")（引擎随后会重新 _mark_done，
##    此处仅作源码等价标记，与 Event440/883 约定一致）。



const TXT_OPT0_DIS := "event.script.event_567_gulf_hot_wind.c0"

const TXT_R0_A := "event.script.event_567_gulf_hot_wind.c1"
const TXT_R0_MAO := "event.script.event_567_gulf_hot_wind.c2"
const TXT_R0_B := "event.script.event_567_gulf_hot_wind.c3"
const TXT_R0_ELSE := "event.script.event_567_gulf_hot_wind.c4"
const TXT_R1 := "event.script.event_567_gulf_hot_wind.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var china := world.get_country_by_legacy_index(1)
	var c30 := world.get_country_by_legacy_index(30)
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var cond := line <= 2 and china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL \
			or ((china.government == GameConstants.Government.REFORMIST or china.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or china.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST) \
			and c30 != null and c30.government == GameConstants.Government.REFORMIST))
	if cond:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	_enable(opt[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c23 := ws.get_country_by_legacy_index(23)
	var c24 := ws.get_country_by_legacy_index(24)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if _part(c24, 0):
				var text := tr(TXT_R0_A)
				if c24 != null and c24.has_tag("亲中"):
					text += tr(TXT_R0_MAO)
				text += tr(TXT_R0_B)
				if c24 != null:
					c24.内战中 = true
				context["result_text"] = text
			else:
				if c23 != null:
					c23.内战中 = true
				context["result_text"] = tr(TXT_R0_ELSE)
			if c24 != null:
				c24.prc_power = 50
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
		1:
			ws.completed_event_ids.erase("event_567")
			context["result_text"] = tr(TXT_R1)


func _part(c: CountryData, i: int) -> bool:
	return c != null and c.parts.size() > i and c.parts[i]



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_567_gulf_hot_wind.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_567",
	"num": 567,
	"priority": 56700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_567_gulf_hot_wind.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
