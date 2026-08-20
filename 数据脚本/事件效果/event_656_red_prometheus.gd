extends "res://数据脚本/event_script_base.gd"

## 原作 Event656.cs：红色普罗米修斯（尼日利亚人民军战略反攻，一选项）。
## 触发：TimeScript.cs 11071-11077 —— event_done[655] && c60.prc_power>=100
##   && c60.government != GameConstants.Government.REFORMIST && IsSocialism(true) 计数>=5 && !c60.内战。
## 差异：
##  - 触发条件用 ExprNode（PREV_EVENT_DONE / COUNTRY_FIELD_AT_LEAST / COUNTRY_FIELD_NOT_EQUALS / SOCIALIST_COUNT_AT_LEAST / COUNTRY_FIELD_EQUALS）。
##  - War 79：AmericanSupportDefender.SovietSupportDefender → usa_side = GameConstants.WarSide.SIDE2 / ussr_side = GameConstants.WarSide.SIDE2；
##    无 TickTime → 原版 fortnight_max 默认 999，Godot 覆盖为 999。
##  - 死代码 result 5 测试分支跳过。


const TXT_R0 := "依托于城市内的左翼工会网络组织起来的工人赤卫队发动起义，同尼日利亚人民军协调行动，开始进攻大城市。惊恐的尼日利亚国家机器不愿就此坐以待毙，开始宣布紧急状态和总动员，并放权各地部族精英，各个部族也趁机开始武装自己。这将是一场烈度不会低于比夫拉战争的内战……尼日利亚将通往何方？"
const TXT_WAR_NAME := "第二次尼日利亚内战"
const TXT_WAR_ATTACKER := "尼日利亚人民军"
const TXT_WAR_DEFENDER := "尼日利亚政府"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.is_empty():
		return
	_enable(event_def.options[0], event_def.options[0].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nigeria := ws.get_country_by_legacy_index(60)
	if nigeria != null:
		while nigeria.parts.size() <= 0:
			nigeria.parts.append(false)
		nigeria.parts[0] = true
		nigeria.set_tag("对华贸易", false)
	GameManager.start_war(79, TXT_WAR_ATTACKER, TXT_WAR_DEFENDER, 400, 600, 1, 1)
	if ws.wars.size() > 79 and ws.wars[79] != null:
		ws.wars[79].name_war = TXT_WAR_NAME
		ws.wars[79].fortnight_max = 999
	context["result_text"] = TXT_R0


