extends "res://数据脚本/event_script_base.gd"

## 原作 Event563.cs：“拯救”的悲剧（阿尔及利亚内战，3选项）。
## 触发：无自动触发（DiploButtonScript.cs:11527 外交按钮 number_event=563）。
## 差异：ingamewars[40] → game.start_war。

const TXT_OPT0_DIS := "event.script.event_563_tragedy_of_salvation.c0"
const TXT_OPT1_DIS := "event.script.event_563_tragedy_of_salvation.c1"
const TXT_OPT2_DIS := "event.script.event_563_tragedy_of_salvation.c2"
const TXT_R0 := "event.script.event_563_tragedy_of_salvation.c3"
const TXT_R1 := "event.script.event_563_tragedy_of_salvation.c4"
const TXT_R2 := "event.script.event_563_tragedy_of_salvation.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var line := d.political_line
	if line > 0 and d.religion_policy == 29 and d.war_support >= 700:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line >= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line < 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c40 := ws.get_country_by_legacy_index(40)
	if c40 != null:
		c40.government = GameConstants.Government.AUTHORITARIAN
		c40.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		c40.set_tag("对华贸易", false)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_start_war40("伊斯兰救世阵线", 0, 0)
			_add_relation(EmpireData.USA, -500)
			_add_relation(EmpireData.USSR, -500)
			context["result_text"] = tr(TXT_R0)
		1:
			_start_war40("全国民主联盟", 1, 0)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, -500)
			context["result_text"] = tr(TXT_R1)
		2:
			_start_war40("人民民主爱国阵线", 0, 1)
			_add_relation(EmpireData.USSR, 150)
			_add_relation(EmpireData.USA, -500)
			context["result_text"] = tr(TXT_R2)


func _start_war40(side2: String, usa_side: int, ussr_side: int) -> void:
	game.start_war(40, "FLN", side2, 700, 300, usa_side, ussr_side)
	if ws.wars.size() > 40 and ws.wars[40] != null:
		ws.wars[40].name_war = "阿尔及利亚内战"
		ws.wars[40].fortnight_max = 20



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_563_tragedy_of_salvation.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_563",
	"num": 563,
	"priority": 56300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_563_tragedy_of_salvation.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
