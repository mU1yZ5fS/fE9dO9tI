extends "res://数据脚本/event_script_base.gd"

## 原作 Event579.cs：在那墨西哥城（墨西哥城地震，三选项）。 ## 触发：ReqEventForDLC02.cs:804-807 —— (日>=19 且 月>=9 且 年>=1985) (月>=10 且 年>=1985) 年>=1986 ##   → DATE_AFTER 1985.9.19。 ## 差异： ##  - 选项显隐 prepare 动态改写；proprc → 亲中；Vyshi → 亲美； ##  - resultOfEvents[577]/[578] 缺省按原版 int 默认 0；cw → 内战中； ##  - AmericanSupportAttacker.SovietSupportDefender → usa_side = GameConstants.WarSide.SIDE1/ussr_side = GameConstants.WarSide.SIDE2； ##    仅 AmericanSupportAttacker → usa_side = GameConstants.WarSide.SIDE1/ussr_side = GameConstants.WarSide.NONE；TickTime(24) → fortnight_max=24。



const TXT_OPT1_DIS := "event.script.event_579_mexico_city.c0"
const TXT_OPT2_DIS := "event.script.event_579_mexico_city.c1"

const TXT_R0_BASE := "event.script.event_579_mexico_city.c2"
const TXT_R0_SALINAS := "event.script.event_579_mexico_city.c3"
const TXT_R0_CARDENAS := "event.script.event_579_mexico_city.c4"
const TXT_R0_CLOUTHIER := "event.script.event_579_mexico_city.c5"
const TXT_R1 := "event.script.event_579_mexico_city.c6"
const TXT_R2 := "event.script.event_579_mexico_city.c7"

const WAR46_NAME := "event.script.event_579_mexico_city.c8"
const WAR46_SIDE1 := "event.script.event_579_mexico_city.c9"
const WAR46_SIDE2 := "event.script.event_579_mexico_city.c10"
const WAR47_NAME := "event.script.event_579_mexico_city.c11"
const WAR47_SIDE1 := "event.script.event_579_mexico_city.c12"
const WAR47_SIDE2 := "event.script.event_579_mexico_city.c13"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var num := 0
	for i in range(71, 84):
		var c := world.get_country_by_legacy_index(i)
		if c != null and c.has_tag("亲中"):
			num += 1
	for c in world.countries:
		if c != null and c.原版序号 >= 138 and c.has_tag("亲中"):
			num += 1
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var c140 := world.get_country_by_legacy_index(140)
	var c1 := world.get_country_by_legacy_index(1)
	var r577 := int(world.completed_event_ids.get("event_577", 0))
	var r578 := int(world.completed_event_ids.get("event_578", 0))
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if line == 0 and num >= 7 and c140 != null and c140.parts.size() > 0 and c140.parts[0] \
			and world.influence_prc >= 1000:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if data.size() > W.I_WAR_SUPPORT and data.war_support >= 700 \
			and c1 != null and c1.sub_government == GameConstants.SubGovernment.NEO_FASCIST and c140 != null and c140.stab == 2 \
			and r577 == 3 and r578 == 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c140 := ws.get_country_by_legacy_index(140)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := tr(TXT_R0_BASE)
			if c140 == null or not c140.内战中:
				text += tr(TXT_R0_SALINAS)
				if c140 != null:
					c140.government = GameConstants.Government.LIBERAL
					c140.sub_government = GameConstants.SubGovernment.LIBERAL
					c140.set_tag("亲美", true)
			else:
				var r577 := int(ws.completed_event_ids.get("event_577", 0))
				if r577 == 1:
					text += tr(TXT_R0_CARDENAS)
					if c140 != null:
						c140.government = GameConstants.Government.REFORMIST
						c140.sub_government = GameConstants.SubGovernment.PRAGMATIST
						c140.set_tag("亲美", false)
				elif r577 == 2:
					text += tr(TXT_R0_CLOUTHIER)
					if c140 != null:
						c140.government = GameConstants.Government.LIBERAL
						c140.sub_government = GameConstants.SubGovernment.NEOLIBERAL
						c140.set_tag("亲美", true)
			_add(W.I_DIPLO, -80)
			context["result_text"] = text
		1:
			if c140 != null:
				_set_part(c140, 1, true)
			var c168 := ws.get_country_by_legacy_index(168)
			if c168 != null:
				if c168.parts.size() <= 0:
					c168.parts.resize(1)
				c168.parts[0] = true
				c168.name = "墨西哥南方民主共和国"
				c168.chinese_name = "墨西哥南方民主共和国"
				c168.leave_alliances()
				# 南墨西哥的政体/子意识形态应由南方解放军中获胜派系决定（对应 c145 的 sub_government）。
				var c145_south := ws.get_country_by_legacy_index(145)
				if c145_south != null:
					c168.government = c145_south.government
					c168.sub_government = c145_south.sub_government
				else:
					c168.government = GameConstants.Government.REFORMIST
					c168.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			game.start_war(46, tr(WAR46_SIDE1), tr(WAR46_SIDE2), 500, 500, 0, 1)
			if ws.wars.size() > 46 and ws.wars[46] != null:
				ws.wars[46].name_war = tr(WAR46_NAME)
				ws.wars[46].fortnight_max = 24
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			_add(W.I_DIPLO, 80)
			_add_relation(EmpireData.USA, -300)
			context["result_text"] = tr(TXT_R1)
		2:
			if c140 != null:
				_set_part(c140, 1, true)
			game.start_war(47, tr(WAR47_SIDE1), tr(WAR47_SIDE2), 800, 200, 0, -1)
			if ws.wars.size() > 47 and ws.wars[47] != null:
				ws.wars[47].name_war = tr(WAR47_NAME)
				ws.wars[47].fortnight_max = 24
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, -300)
			context["result_text"] = tr(TXT_R2)
	if MapService.instance != null:
		MapService.instance.sync_map_merges()


func _set_part(c: CountryData, i: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= i:
		c.parts.append(false)
	c.parts[i] = value



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_579_mexico_city.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_579",
	"num": 579,
	"priority": 57900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_579_mexico_city.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1985.9.19"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
