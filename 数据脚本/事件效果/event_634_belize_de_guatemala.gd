extends "res://数据脚本/event_script_base.gd"

## 原作 Event634.cs：Belice de Guatemala（革命危地马拉收复伯利兹，单选项）。
## 触发：DiploButtonScript.cs:12130 —— 外交按钮 1032，selected_country==149（危地马拉），
##   入口扣 data.army-=80（在 _def_1032 中已移植），随后 StartEvent(634)。
## 差异：ingamewars[65] 建模说明 WarDef → game.start_war 兜底创建后手工补名。
##   parts[0/2] 写前 resize；Gosstroy→government；SovietSupportAttacker→ussr_side = GameConstants.WarSide.SIDE2。

const TXT_R_ANNEX := "event.script.event_634_belize_de_guatemala.c0"
const TXT_R_WAR := "event.script.event_634_belize_de_guatemala.c1"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var guatemala := ws.get_country_by_legacy_index(149)
	var uk := ws.get_country_by_legacy_index(92)
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	if uk != null and uk.government == GameConstants.Government.SOCIALIST:
		context["result_text"] = tr(TXT_R_ANNEX)
		if guatemala != null:
			guatemala.level_of_instability += 50
			_set_part(guatemala, 0, true)
		ws.influence_prc += 5
		_add_power(EmpireData.USA, -5)
		_add_relation(EmpireData.USA, -50)
		return
	context["result_text"] = tr(TXT_R_WAR)
	if guatemala != null:
		_set_part(guatemala, 2, true)
	_add_relation(EmpireData.USA, -50)
	# 原版 ingamewars[65]=危地马拉统一战争，危地马拉(600) vs 伯利兹(400)，SovietSupportAttacker
	game.start_war(65, "危地马拉", "伯利兹", 600, 400, -1, 1)
	if ws.wars.size() > 65 and ws.wars[65] != null:
		ws.wars[65].name_war = "危地马拉统一战争"


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_634_belize_de_guatemala.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_634",
	"num": 634,
	"priority": 63400,
	"notify": false,
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
