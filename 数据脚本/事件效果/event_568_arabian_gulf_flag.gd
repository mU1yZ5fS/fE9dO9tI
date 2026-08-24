extends "res://数据脚本/event_script_base.gd"

## 原作 Event568.cs：阿拉伯湾旗帜飘（阿湾全面战争，单选项）。
## 触发：DiploButtonScript.cs:11552 —— number_event = 568（外交按钮手动触发），无自动触发。
## 差异：
##  - oar → 国家标签 "oar"；proprc → 亲中；
##  - IsSocialism(true) → world.is_socialism(c, true)；IsAuthoritarianism → world.is_authoritarian；
##  - data.oil_price 无命名键，raw index 143（同 Event114 约定）；
##  - AmericanSupportAttacker → usa_side = GameConstants.WarSide.SIDE1/ussr_side = GameConstants.WarSide.NONE；TickTime(24) → fortnight_max=24。




const TXT_R0 := "event.script.event_568_arabian_gulf_flag.c0"

const WAR43_NAME := "event.script.event_568_arabian_gulf_flag.c1"
const WAR43_SIDE1 := "event.script.event_568_arabian_gulf_flag.c2"
const WAR43_SIDE2 := "event.script.event_568_arabian_gulf_flag.c3"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var num := 0
	for c in ws.countries:
		if c == null:
			continue
		if ws.is_socialism(c, true) and c.has_tag("oar") and c.原版序号 in [13, 14, 30, 18, 40, 54, 55, 35]:
			num += 30
	for j in range(101, 106):
		if j == 104:
			continue
		var c := ws.get_country_by_legacy_index(j)
		if c != null and c.has_tag("亲中") and (ws.is_authoritarian(c) or c.government == GameConstants.Government.LIBERAL):
			c.set_tag("亲中", false)
	var c36 := ws.get_country_by_legacy_index(36)
	if c36 != null and c36.has_tag("亲中"):
		c36.set_tag("亲中", false)
	if d.size() > 143:
		d.oil_price += 10   # 原 data.oil_price（无命名键，同 Event114 约定）
	game.start_war(43, tr(WAR43_SIDE1), tr(WAR43_SIDE2), 700 - num, 300 + num, 0, -1)
	if ws.wars.size() > 43 and ws.wars[43] != null:
		ws.wars[43].name_war = tr(WAR43_NAME)
		ws.wars[43].fortnight_max = 24
	context["result_text"] = tr(TXT_R0)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_568_arabian_gulf_flag.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_568",
	"num": 568,
	"priority": 56800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_568_arabian_gulf_flag.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
