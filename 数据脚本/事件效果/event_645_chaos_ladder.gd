extends "res://数据脚本/event_script_base.gd"

## 原作 Event645.cs：混乱即阶梯（罗马尼亚脱离苏东，单选项）。
## 触发：ReqEventsDLC02.cs:94-96 —— c5.SubGosstroy==19 && IndOpp → trigger_script evaluate。
## 差异：ingamewars[76] 建模说明 WarDef → 兜底创建后补名；
##   isSEV/isOVD→sev/ovd 标签；JoinAllOurAlliances(true)→_join_alliances。

const TXT_R0 := "event.script.event_645_chaos_ladder.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	context["result_text"] = tr(TXT_R0)
	# 原版 ingamewars[76]：喀尔巴阡行动，罗马尼亚(300) vs 华沙条约(700)，
	#   AmericanSupportAttacker → usa_side = GameConstants.WarSide.SIDE2、SovietSupportDefender → ussr_side=2
	game.start_war(76, "罗马尼亚", "华沙条约", 300, 700, 1, 2)
	if ws.wars.size() > 76 and ws.wars[76] != null:
		ws.wars[76].name_war = "喀尔巴阡行动"
	_add(W.I_PARTY_SUPPORT, 300)
	_add(W.I_PEOPLE_SUPPORT, 300)
	_add(W.I_THOUGHT_FREEDOM, -200)
	_add(W.I_DIPLO, 150)
	var romania := ws.get_country_by_legacy_index(5)
	if romania != null:
		romania.set_tag("sev", false)
		romania.set_tag("ovd", false)
		_join_alliances(romania)
	_add_relation(EmpireData.USSR, -250)
	_add_power(EmpireData.USSR, -15)
	ws.influence_prc += 15


func evaluate(world: WorldState) -> bool:
	if world == null or not world.ind_opp:
		return false
	var romania := world.get_country_by_legacy_index(5)
	return romania != null and romania.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_645_chaos_ladder.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_645",
	"num": 645,
	"priority": 64500,
	"notify": false,
	"trigger_script": "res://数据脚本/事件效果/event_645_chaos_ladder.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
