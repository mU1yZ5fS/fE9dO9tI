extends "res://数据脚本/event_script_base.gd"

## 原作 Event569.cs：暴君必尝恶果（沙特半岛解放战争，二选项）。
## 触发：DiploButtonScript.cs:11559 —— number_event = 569（外交按钮手动触发），无自动触发。
## 差异：
##  - data.oil_price 无命名键，raw index 143；
##  - AmericanSupportAttacker → usa_side = GameConstants.WarSide.SIDE1/ussr_side = GameConstants.WarSide.NONE；TickTime(24) → fortnight_max=24；
##  - event_done[569]=false → completed_event_ids.erase("event_569")（同 Event440 约定）。



const TXT_OPT0_DIS := "event.script.event_569_tyrant_bad_end.c0"

const TXT_R0 := "event.script.event_569_tyrant_bad_end.c1"
const TXT_R1 := "event.script.event_569_tyrant_bad_end.c2"

const WAR37_NAME := "event.script.event_569_tyrant_bad_end.c3"
const WAR37_SIDE1 := "event.script.event_569_tyrant_bad_end.c4"
const WAR37_SIDE2 := "event.script.event_569_tyrant_bad_end.c5"


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
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			if d.size() > 143:
				d.oil_price += 8   # 原 data.oil_price（无命名键）
			_add(W.I_ARMY, -150)
			game.start_war(37, tr(WAR37_SIDE1), tr(WAR37_SIDE2), 600, 400, 0, -1)
			if ws.wars.size() > 37 and ws.wars[37] != null:
				ws.wars[37].name_war = tr(WAR37_NAME)
				ws.wars[37].fortnight_max = 24
			context["result_text"] = tr(TXT_R0)
		1:
			ws.completed_event_ids.erase("event_569")
			context["result_text"] = tr(TXT_R1)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_569_tyrant_bad_end.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_569",
	"num": 569,
	"priority": 56900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_569_tyrant_bad_end.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
