extends "res://数据脚本/event_script_base.gd"

## 原作 Event631.cs：一份爱，一份和平（牙买加政治和解演唱会，五选项）。 ## 触发：ReqEventsDLC02.cs:966-969 —— DATE_AFTER 1978.4.22（原 (1978&&m>=4&&d>=22) (1978&&m>=5) y>=1979）。 ## 差异：原版按条件 Destroy(button[i])；Godot 用 _disable 灰显同义。 ##   cw→内战中、Gosstroy/SubGosstroy→government/sub_government、Torg/proprc→标签、name→chinese_name。

const TXT_OPT0_DIS := "event.script.event_631_one_love_one_peace.c0"
const TXT_OPT4_DIS := "event.script.event_631_one_love_one_peace.c1"
const TXT_R0 := "event.script.event_631_one_love_one_peace.c2"
const TXT_R1 := "event.script.event_631_one_love_one_peace.c3"
const TXT_R2 := "event.script.event_631_one_love_one_peace.c4"
const TXT_R3 := "event.script.event_631_one_love_one_peace.c5"
const TXT_R4 := "event.script.event_631_one_love_one_peace.c6"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 5:
		return
	var jamaica := ws.get_country_by_legacy_index(152)
	var cw := jamaica != null and jamaica.内战中
	var line := _res(W.I_POLITICAL_LINE)
	var rich := _res(W.I_BUDGET) + _res(W.I_RESERVE) >= 2500 \
		and _res(W.I_AGENTS) >= 2500 and _res(W.I_ARMY) >= 2500
	var opt := event_def.options
	if line < 3 and cw:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 1 and cw:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT0_DIS))
	if cw:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT0_DIS))
	_enable(opt[3], event_def.options[3].text)
	if cw and rich:
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], tr(TXT_OPT4_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var jamaica := ws.get_country_by_legacy_index(152)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_BUDGET, -20)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_BUDGET, -20)
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_BUDGET, -20)
		3:
			context["result_text"] = tr(TXT_R3)
		4:
			context["result_text"] = tr(TXT_R4)
			_add(W.I_BUDGET, -2500)
			_add(W.I_AGENTS, -2500)
			_add(W.I_ARMY, -2500)
			if jamaica != null:
				jamaica.government = GameConstants.Government.AUTHORITARIAN
				jamaica.sub_government = GameConstants.SubGovernment.NEOPATRIARCHAL
				_leave_alliances(jamaica)
				jamaica.set_tag("对华贸易", true)
				jamaica.set_tag("亲中", true)
				jamaica.chinese_name = "牙买加阿非利加帝国"



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_631_one_love_one_peace.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_631",
	"num": 631,
	"priority": 63100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_631_one_love_one_peace.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.4.22"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
