extends "res://数据脚本/event_script_base.gd"

## 原作 Event666.cs：轮回的复仇（毛泽东“复活”事件，单选项）。 ## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1572-1577 —— ##   ((data.living_standard<100 && influencePRC<50 && data.ideology>=5 && data.tibet_policy>0 && data.xinjiang_policy>0 ##     && data.hk_macau_status<=0 && data.arunachal_status<=0) MoneyLevel>20) && data.mao_mausoleum==9。 ## 差异：MoneyLevel 为 display-only，世界状态移植说明，其分支跳过并注释； ##   其余条件照抄为 ExprNode。

const TXT_R0 := "event.script.event_666_mao_revenant.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		context["result_text"] = tr(TXT_R0)
		if d.size() > W.I_PARTY_SUPPORT:
			d.party_support = 0
		if d.size() > W.I_PEOPLE_SUPPORT:
			d.people_support = 0
		if d.size() > W.I_AGENTS:
			d.agents = 0
		# 原版 load_scene_after_click：data.ending_route=8 并加载 Ending； # Godot 设 I_ENDING_ROUTE=8 并排队结局（结局界面无 8 时回退 0）。
		if d.size() > W.I_ENDING_ROUTE:
			d.ending_route = 8
		game.queue_ending_after_event(8)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_666_mao_revenant.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_666",
	"num": 666,
	"priority": 66600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_666_mao_revenant.gd",
	"trigger": [{"t": "RESOURCE_AT_MOST", "key": "living", "v": 99}, {"t": "RESOURCE_AT_MOST", "key": "influence_prc", "v": 49}, {"t": "RESOURCE_AT_LEAST", "key": "ideology", "v": 5}, {"t": "RESOURCE_AT_LEAST", "key": "tibet_policy", "v": 1}, {"t": "RESOURCE_AT_LEAST", "key": "xinjiang_policy", "v": 1}, {"t": "RESOURCE_AT_MOST", "key": "hk_macau_status"}, {"t": "RESOURCE_AT_MOST", "key": "arunachal_status"}, {"t": "RESOURCE_EQUALS", "key": "mao_mausoleum", "v": 9}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
