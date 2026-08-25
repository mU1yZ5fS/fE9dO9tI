extends "res://数据脚本/event_script_base.gd"

## 原作 Event635.cs：Belice de Guatemala（危地马拉军政府声索伯利兹，三选项）。
## 触发：ReqEventsDLC02.cs:981-984 —— IsAuthoritarianism(149) && BritLost && DATE_AFTER 1983.1.1。
##   IsAuthoritarianism 无单一 ExprNode → trigger_script evaluate。
## 差异：ingamewars[66] 建模说明 WarDef → game.start_war 兜底创建后手工补名；
##   AmericanSupportAttacker→usa_side = GameConstants.WarSide.SIDE2、SovietSupportDefender→ussr_side=2。

const TXT_R0 := "event.script.event_635_belize_de_guatemala_act2.c0"
const TXT_R1 := "event.script.event_635_belize_de_guatemala_act2.c1"
const TXT_R2 := "event.script.event_635_belize_de_guatemala_act2.c2"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var guatemala := ws.get_country_by_legacy_index(149)
	var opt := int(context.get("option_index", -1))
	# 原版 :30：ResultsOfEvents 开头统一置 parts[2]
	if guatemala != null:
		_set_part(guatemala, 2, true)
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_start_war66(600, 400)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_BUDGET, -20)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add_power(EmpireData.USA, 5)
			_start_war66(550, 450)
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_THOUGHT_FREEDOM, -50)
			_add_power(EmpireData.USA, 10)  # 原 :49/:52 两次 +5
			_add(W.I_BUDGET, -20)
			if guatemala != null:
				guatemala.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 80)
			_start_war66(700, 300)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19830101:
		return false
	if not world.get_flag("BritLost"):
		return false
	var guatemala := world.get_country_by_legacy_index(149)
	return guatemala != null and world.is_authoritarian(guatemala)


func _start_war66(infl1: int, infl2: int) -> void:
	# 原版 ingamewars[66]：危地马拉 vs 伯利兹，AmericanSupportAttacker、SovietSupportDefender
	game.start_war(66, "危地马拉", "伯利兹", infl1, infl2, 1, 2)
	if ws.wars.size() > 66 and ws.wars[66] != null:
		ws.wars[66].name_war = "危地马拉统一战争"


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_635_belize_de_guatemala_act2.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_635",
	"num": 635,
	"priority": 63500,
	"notify": false,
	"trigger_script": "res://数据脚本/事件效果/event_635_belize_de_guatemala_act2.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
