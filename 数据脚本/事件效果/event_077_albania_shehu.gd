extends "res://数据脚本/event_script_base.gd"

## 原作 Event77.cs：往脸上吐口水，在下巴上打一拳，头上一颗子弹（谢胡政变）。
## 触发：TimeScript.cs:10606-10612 ——
##   (月>=11 且 年>=1981 或 年>=1982) && data.albania_break<1 && c20.SubGosstroy!=11
##   && !c20.econ && !c20.isRIM（.tres ExprNode 表达）。
## 差异：描述与选项显隐按原版动态改写（prepare）；c20 政体/标签映射为
##   government/sub_government/set_tag("对华贸易"/"亲中")。

const TXT_R0 := "event.script.event_077_albania_shehu.c0"

const TXT_R0_EXTRA := "event.script.event_077_albania_shehu.c1"

const TXT_R1 := "event.script.event_077_albania_shehu.c2"

const TXT_R2 := "event.script.event_077_albania_shehu.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var policy_left := (line < 4 and party < 8) or (coal > 66 and party > 7)
	var albania := world.get_country_by_legacy_index(20)
	var opt := event_def.options
	if policy_left and data.size() > W.I_AGENTS and data.agents >= 80:
		_enable(opt[0], "帮助谢胡组织一场政变（需要8特工网络）")
	else:
		_disable(opt[0], "我们没有足够的资源")
	_enable(opt[1], "这是他们自己的问题")
	var albania_proprc := albania != null and albania.has_tag("亲中")
	var albania_econ := albania != null and albania.has_tag("econ")
	if albania_proprc or (albania_econ and data.size() > W.I_ALBANIA_BREAK and data.albania_break == 0):
		_enable(opt[2], "我们支持霍查")
	else:
		_disable(opt[2], "为什么我们要支持背叛我们的白眼狼霍查？")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var albania := ws.get_country_by_legacy_index(20)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := tr(TXT_R0)
			if albania == null or not albania.has_tag("亲中"):
				text += tr(TXT_R0_EXTRA)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_AGENTS, -80)
			_add(W.I_DIPLO, 10)
			if d.size() > W.I_ALBANIA_BREAK:
				d.albania_break = 1
			_add_relation(EmpireData.USSR, 50)
			if albania != null:
				albania.government = GameConstants.Government.SOCIALIST
				albania.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				albania.set_tag("对华贸易", true)
				albania.set_tag("亲中", true)
			context["result_text"] = text
		1:
			_add_power(EmpireData.USSR, -10)
			ws.influence_prc -= 10
			if albania != null:
				albania.government = GameConstants.Government.AUTHORITARIAN
				albania.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_DIPLO, 20)
			if albania != null:
				albania.government = GameConstants.Government.AUTHORITARIAN
				albania.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
			context["result_text"] = tr(TXT_R2)


## 原版 summa_3_2 复算。
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_077_albania_shehu.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_077",
	"num": 77,
	"priority": 7700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_077_albania_shehu.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1981.11.1"}, {"t": "RESOURCE_AT_MOST", "key": "albania_break"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "v": 11, "target": "20"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "20"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "rim", "target": "20"}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
