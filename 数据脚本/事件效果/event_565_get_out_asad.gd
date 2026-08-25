extends "res://数据脚本/event_script_base.gd"

## 原作 Event565.cs：滚出去，阿萨德（叙利亚内战，3选项）。
## 触发：无自动触发（Event564 结果1 后 EventEngine.enqueue_chain 承接）。

const TXT_OPT0_DIS := "event.script.event_565_get_out_asad.c0"
const TXT_OPT1_DIS := "event.script.event_565_get_out_asad.c1"
const TXT_OPT2_DIS := "event.script.event_565_get_out_asad.c2"
const TXT_R0 := "event.script.event_565_get_out_asad.c3"
const TXT_R1 := "event.script.event_565_get_out_asad.c4"
const TXT_R2 := "event.script.event_565_get_out_asad.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var c8 := world.get_country_by_legacy_index(8)
	if ws.influence_prc >= 500 and d.war_support >= 600 and not ws.modifiers[3].is_active 			and c8 != null and c8.sub_government != GameConstants.SubGovernment.NEOPATRIARCHAL:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if d.political_line <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if d.political_line > 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_start_war41("伊斯兰主义者", 1, 0)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, -150)
			context["result_text"] = tr(TXT_R0)
		1:
			_start_war41("全国民主同盟", -1, 0)
			_add_relation(EmpireData.USSR, -200)
			context["result_text"] = tr(TXT_R1)
		2:
			_start_war41("叙利亚自由联盟", 1, 0)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, -150)
			context["result_text"] = tr(TXT_R2)


func _start_war41(side2: String, usa_side: int, ussr_side: int) -> void:
	game.start_war(41, "叙利亚政府军", side2, 700, 300, usa_side, ussr_side)
	if ws.wars.size() > 41 and ws.wars[41] != null:
		ws.wars[41].name_war = "叙利亚内战"
		ws.wars[41].fortnight_max = 24



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_565_get_out_asad.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_565",
	"num": 565,
	"priority": 56500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_565_get_out_asad.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
