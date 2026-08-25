extends "res://数据脚本/event_script_base.gd"

## 原作 Event78.cs：永远的总统（菲律宾马科斯选举，三选项）。
## 触发：TimeScript.cs:10614-10620 ——
##   (月>=6 且 年>=1981 或 年>=1982) && !c1.isASEAN && !c47.okb
##   && !c47.isSEV && !c47.econ && IsAuthoritarianism(47)（.tres ExprNode 表达）。
## 差异：选项显隐 prepare 动态改写；data.philippines_maoist_power 直访（菲律宾毛派力量，无命名键）。

const TXT_R0 := "event.script.event_078_philippines_marcos.c0"

const TXT_R1 := "event.script.event_078_philippines_marcos.c1"

const TXT_R2 := "event.script.event_078_philippines_marcos.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var policy_left := (line < 2 and party < 8) or (coal > 66 and party > 7)
	var policy_right := (line > 1 and party < 8) or (coal > 66 and party > 7)
	var opt := event_def.options
	if data.size() > W.I_AGENTS and data.agents >= 100 \
			and data.size() > W.I_ARMY and data.army >= 80 and policy_left:
		_enable(opt[0], "煽动动乱和支持毛派（需要10特工网络，8军事实力）")
	else:
		_disable(opt[0], "这不值得我们为之努力")
	_enable(opt[1], "这不关我们的事。")
	var dip := data.diplomatic_reputation if data.size() > W.I_DIPLO else 0
	if dip < 800 and policy_right:
		_enable(opt[2], "祝贺马科斯获胜，并尝试建立合作关系")
	else:
		_disable(opt[2], "我们不需要和美国傀儡合作")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var philippines := ws.get_country_by_legacy_index(47)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_AGENTS, -100)
			_add(W.I_DIPLO, 20)
			_add_relation(EmpireData.USA, -100)
			if d.size() > 37:
				d.philippines_maoist_power += 300
			if philippines != null:
				philippines.set_tag("对华贸易", false)
			context["result_text"] = tr(TXT_R0)
		1:
			_add_power(EmpireData.USA, 10)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_DIPLO, -10)
			_add_relation(EmpireData.USA, 50)
			if d.size() > 37:
				d.philippines_maoist_power -= 200
			_add_power(EmpireData.USA, 20)
			if philippines != null:
				philippines.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R2)


func _coalition_percent(world: WorldState) -> int:
	var data := world
	if data.size() <= W.I_PARTY_SYSTEM or data.party_system <= 7:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_078_philippines_marcos.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_078",
	"num": 78,
	"priority": 7800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_078_philippines_marcos.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1981.6.1"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "asean", "target": "1"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "okb", "target": "47"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "sev", "target": "47"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "47"}]}, {"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "government", "target": "47"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "target": "47"}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
