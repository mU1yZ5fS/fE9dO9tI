extends "res://数据脚本/event_script_base.gd"

## 原作 Event98.cs：非洲的切·格瓦拉（布基纳法索桑卡拉，四选项）。
## 触发：TimeScript.cs:10815-10821 —— (月>=8 且 年>=1983 或 年>=1984)。
## 差异：
##  - 共同效果先执行：data.africa_coup_route=15；c61 LeaveAlliances、name=布基纳法索
##    （new_events_text[800]）、Gosstroy=2/SubGosstroy=3、三倾向清空、dev=500。
##  - 选项显隐 prepare 动态改写（modifies[41] 激活才可用法国线）。

const TXT_R0 := "event.script.event_098_sankara.c0"

const TXT_R0_EXTRA := "event.script.event_098_sankara.c1"

const TXT_R0_EXTRA2 := "event.script.event_098_sankara.c2"

const TXT_R1 := "event.script.event_098_sankara.c3"

const TXT_R2 := "event.script.event_098_sankara.c4"

const TXT_R3 := "event.script.event_098_sankara.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var opt := event_def.options
	_enable(opt[0], "无视军事政变")
	if line != 0 and line != 4:
		_enable(opt[1], "支持布基纳法索的革新，并推动人民解放委员会内温和派扭转唯意志论实践")
	elif line == 0:
		_disable(opt[1], "天下大乱，局势大好。怎能不乘胜追击！")
	else:
		_disable(opt[1], "没必要玩两害相择取其轻的把戏")
	if world.influence_prc >= 100 and line < 2:
		_enable(opt[2], "支持布基纳法索的革新，并推动人民解放委员会选择更坚决的革命立场")
	else:
		_disable(opt[2], "更强硬的社会主义军政府？难道你打算在西非制造个黑人版奈温？")
	if _mod_active(world, GameConstants.Modifier.HUNTING_CLUB_MEMBER):
		_enable(opt[3], "联系法国人，我们应当给当地畸形的“不断政变”生态画上休止符")
	else:
		_disable(opt[3], "我们鞭长莫及")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	# 共同效果（先于 result 分支）
	if d.size() > 103:
		d.africa_coup_route = 15
	var bf := ws.get_country_by_legacy_index(61)
	if bf != null:
		_leave_alliances(bf)
		bf.name = "布基纳法索"
		bf.chinese_name = "布基纳法索"
		bf.government = GameConstants.Government.REFORMIST
		bf.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		bf.set_tag("对华贸易", false)
		bf.set_tag("亲美", false)
		bf.set_tag("亲中", false)
		bf.set_tag("亲苏", false)
		bf.development = 500
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := tr(TXT_R0)
			if bf != null:
				bf.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				bf.government = GameConstants.Government.SOCIALIST
			var ussr_power := ws.empires[EmpireData.USSR].power if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null else 0
			var china := ws.get_country_by_legacy_index(1)
			if (ussr_power > _usa_power() and ussr_power > ws.influence_prc) \
					or (china != null and (china.has_tag("sev") or china.has_tag("ovd"))):
				text += tr(TXT_R0_EXTRA)
				if bf != null:
					bf.set_tag("亲苏", true)
				_add_power(EmpireData.USSR, 5)
			elif not _mod_active(ws, GameConstants.Modifier.FRENCH_PRESIDENT_MARCHAIS):
				text += tr(TXT_R0_EXTRA2)
			context["result_text"] = text
		1:
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -30)
			ws.influence_prc += 5
			_add_relation(EmpireData.USA, -100)
			_add(W.I_DIPLO, 10)
			if bf != null:
				bf.government = GameConstants.Government.REFORMIST
				bf.sub_government = GameConstants.SubGovernment.PRAGMATIST
				bf.set_tag("对华贸易", true)
				bf.set_tag("亲中", true)
			context["result_text"] = tr(TXT_R1)
		2:
			_add_relation(EmpireData.USSR, 100)
			ws.influence_prc += 15
			_add_relation(EmpireData.USA, -200)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			_add(W.I_DIPLO, 20)
			if bf != null:
				bf.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				bf.government = GameConstants.Government.SOCIALIST
				bf.set_tag("对华贸易", true)
				bf.set_tag("亲中", true)
			context["result_text"] = tr(TXT_R2)
		3:
			ws.influence_prc += 10
			_add_power(EmpireData.USA, 10)
			_add_power(EmpireData.USSR, -10)
			if bf != null:
				bf.puppet_of = GameConstants.LegacySlot.FRANCE
			_add(W.I_AGENTS, -20)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -50)
			if bf != null:
				bf.government = GameConstants.Government.LIBERAL
				bf.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				bf.set_tag("对华贸易", true)
				bf.name = "上沃尔特"
				bf.chinese_name = "上沃尔特"
			context["result_text"] = tr(TXT_R3)



func _mod_active(world: WorldState, index: int) -> bool:
	return index >= 0 and index < world.modifiers.size() \
		and world.modifiers[index] != null and world.modifiers[index].is_active


func _usa_power() -> int:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		return ws.empires[EmpireData.USA].power
	return 0






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_098_sankara.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_098",
	"num": 98,
	"priority": 9800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_098_sankara.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1983.8.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
