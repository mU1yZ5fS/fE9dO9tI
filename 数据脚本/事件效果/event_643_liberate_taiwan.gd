extends "res://数据脚本/event_script_base.gd"

## 原作 Event643.cs：解放台湾？（台湾总攻，单选项）。
## 触发：ReqEventsDLC02.cs:89-92 —— c1.SubGosstroy==19 && data.taiwan_status!=2 && !completedDecisions[7]
##   复合条件 → trigger_script evaluate。
## 差异：ingamewars[75] 建模说明 WarDef → 兜底创建后补名。

const TXT_R0 := "event.script.event_643_liberate_taiwan.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	context["result_text"] = tr(TXT_R0)
	# 原版 ingamewars[75]：第三次中国内战，中国(700) vs 中华民国(300)，美苏均支持防守方
	game.start_war(75, "中华人民共和国", "中华民国", 700, 300, 2, 2)
	if ws.wars.size() > 75 and ws.wars[75] != null:
		ws.wars[75].name_war = "第三次中国内战"
	# 金门马祖（澎湖）立即由解放军接管；地图上金门 2917 / 澎湖 3088 归中国 710
	ws.taiwan_islands = 1
	game.set_map_region_owner([2917, 3088], 710)
	_add(W.I_PARTY_SUPPORT, 300)
	_add(W.I_PEOPLE_SUPPORT, 300)
	_add(W.I_THOUGHT_FREEDOM, -200)
	_add(W.I_DIPLO, 150)
	_add(W.I_BUDGET, -50)
	_add(W.I_AGENTS, -100)
	_add(W.I_ARMY, -200)
	_add(W.I_POPULATION, 2)
	_add_relation(EmpireData.USSR, -500)
	_add_power(EmpireData.USSR, -15)
	_add_relation(EmpireData.USA, -500)
	_add_power(EmpireData.USA, -15)
	ws.influence_prc += 15


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var china := world.get_country_by_legacy_index(1)
	if china == null or china.sub_government != GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() <= W.I_TAIWAN_STATUS or d.taiwan_status == 2:
		return false
	return world.decisions == null or world.decisions.completed.size() <= 7 \
		or not world.decisions.completed[7]



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_643_liberate_taiwan.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_643",
	"num": 643,
	"priority": 64300,
	"notify": false,
	"trigger_script": "res://数据脚本/事件效果/event_643_liberate_taiwan.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
