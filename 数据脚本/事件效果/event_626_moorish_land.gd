extends "res://数据脚本/event_script_base.gd"

## 原作 Event626.cs：摩尔人的土地（毛里塔尼亚政变，三选项）。 ## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:949-951 —— ##   (1978.7.10 起生效：原 (1978&&m>=7&&d>=10) (1978&&m>=8) y>=1979)。 ## 差异：原版选项0在 data.political_line>=3 时 Destroy(button[0])；Godot 用 _disable 灰显同义。

const TXT_OPT0_DIS := "event.script.event_626_moorish_land.c0"
const TXT_R0 := "event.script.event_626_moorish_land.c1"
const TXT_R1 := "event.script.event_626_moorish_land.c2"
const TXT_R2 := "event.script.event_626_moorish_land.c3"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	# 原版 :21-29：data.political_line<3 显示选项0，否则 Destroy 按钮。
	if _res(W.I_POLITICAL_LINE) < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	_enable(opt[1], event_def.options[1].text)
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(59)  # 毛里塔尼亚
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if c != null:
				c.government = GameConstants.Government.REFORMIST
				c.sub_government = GameConstants.SubGovernment.PRAGMATIST
				_leave_alliances(c)
				c.set_tag("对华贸易", true)
				c.set_tag("亲中", true)
			ws.influence_prc += 10
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -50)
		1:
			context["result_text"] = tr(TXT_R1)
			if c != null:
				c.government = GameConstants.Government.AUTHORITARIAN
				c.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(c)
				c.puppet_of = GameConstants.LegacySlot.FRANCE
				c.set_tag("对华贸易", true)
			_add(W.I_THOUGHT_FREEDOM, -30)
		2:
			context["result_text"] = tr(TXT_R2)
			if c != null:
				c.government = GameConstants.Government.AUTHORITARIAN
				c.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(c)
				c.puppet_of = GameConstants.LegacySlot.FRANCE



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_626_moorish_land.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_626",
	"num": 626,
	"priority": 62600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_626_moorish_land.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.7.10"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
