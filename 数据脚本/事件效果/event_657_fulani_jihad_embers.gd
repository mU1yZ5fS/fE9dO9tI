extends "res://数据脚本/event_script_base.gd"

## 原作 Event657.cs：富拉尼圣战的余烬（扬塔特斯尼起义，一选项）。
## 触发：TimeScript.cs 11078-11083 —— event_done[655] && c60.prc_power>=100 && c60.内战。
## 差异：
##  - 触发条件用 ExprNode（PREV_EVENT_DONE / COUNTRY_FIELD_AT_LEAST / COUNTRY_FIELD_EQUALS）。
##  - War 79：AmericanSupportDefender.SovietSupportDefender → usa_side=1 / ussr_side=1；
##    无 TickTime → 原版 fortnight_max 默认 999，Godot 覆盖为 999。
##  - 死代码 result 5 测试分支跳过。

const TXT_TITLE := "富拉尼圣战的余烬"
const TXT_DESC := "这是尼日利亚独立以来宗教冲突最为严重的时期。扬塔特斯尼基于经济萧条和失业，在学生运动、失业的无产阶级乃至外国人中吸收了大量的支持者，并已经采取过多次成功的行动，誓要把堕落的西方毒瘤赶出尼日利亚。如今，他们基于北方的宗教保守主义和部分北方部族精英的支持，已经在北方建立了可观的地下网络和根据地，大有把“新富拉尼圣战”输出到全国的势头。尼日利亚军方已经决定对扬塔特斯尼运动进行最终的围剿和镇压。"
const TXT_OPT0 := "把斗争进行到底！"

const TXT_R0 := "扬塔特斯尼先发制人，依托群众基础和地下网络迅速发动起义和进攻，成功占领了北方大部分地区，政府军在北方遭遇了大量损失。在穆萨·阿里·苏莱曼的领导下，扬塔特斯尼开始准备南下反攻尼日利亚政府。第二次尼日利亚内战就这样爆发了。这将是一场烈度不会低于比夫拉战争的内战……尼日利亚将通往何方？"
const TXT_WAR_NAME := "第二次尼日利亚内战"
const TXT_WAR_ATTACKER := "扬塔特斯尼"
const TXT_WAR_DEFENDER := "尼日利亚政府"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.is_empty():
		return
	event_def.title = TXT_TITLE
	event_def.description = TXT_DESC
	_enable(event_def.options[0], TXT_OPT0)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nigeria := ws.get_country_by_legacy_index(60)
	if nigeria != null:
		while nigeria.parts.size() <= 0:
			nigeria.parts.append(false)
		nigeria.parts[0] = true
		nigeria.内战中 = true
		nigeria.set_tag("对华贸易", false)
	GameManager.start_war(79, TXT_WAR_ATTACKER, TXT_WAR_DEFENDER, 400, 600, 1, 1)
	if ws.wars.size() > 79 and ws.wars[79] != null:
		ws.wars[79].name_war = TXT_WAR_NAME
		ws.wars[79].fortnight_max = 999
	context["result_text"] = TXT_R0


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null
