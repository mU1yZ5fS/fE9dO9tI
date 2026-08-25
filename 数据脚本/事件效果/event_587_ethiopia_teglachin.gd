extends "res://数据脚本/event_script_base.gd"

## 原作 Event587.cs：提格拉钦（埃塞俄比亚德尔格内斗，四选项）。
## 触发：TimeScript.cs:10887-10893 —— 日>=3 且 月>=2 且 年>=1977
##   （或月>=3 年>=1977 / 年>=1978）。
## 差异：
##  - 选项按 data.political_line（政治路线）动态显隐；<color> 标签去除（既有约定）；
##  - LeaveAlliances() → 清全部联盟/倾向标签 + puppet_of = GameConstants.LegacySlot.NONE；
##    EstablishGovernment(ProChina) → 亲中 true、亲苏/亲美 false；
##    c41.name = "埃塞俄比亚民主联邦共和国" → chinese_name（既有约定）。



const TXT_OPT0_DIS := "event.script.event_587_ethiopia_teglachin.c0"
const TXT_OPT1_DIS := "event.script.event_587_ethiopia_teglachin.c1"
const TXT_OPT2_DIS := "event.script.event_587_ethiopia_teglachin.c2"

const TXT_R0 := "event.script.event_587_ethiopia_teglachin.c3"

const TXT_R1 := "event.script.event_587_ethiopia_teglachin.c4"

const TXT_R2 := "event.script.event_587_ethiopia_teglachin.c5"

const TXT_R3 := "event.script.event_587_ethiopia_teglachin.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line <= 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line != 0 and line != 4:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line <= 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var ethiopia := ws.get_country_by_legacy_index(41)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			if ethiopia != null:
				ethiopia.government = GameConstants.Government.SOCIALIST
				ethiopia.sub_government = GameConstants.SubGovernment.MAOIST
				_leave_alliances(ethiopia)
				ethiopia.set_tag("对华贸易", true)
				ethiopia.chinese_name = "埃塞俄比亚民主联邦共和国"
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -80)
			if ethiopia != null:
				ethiopia.government = GameConstants.Government.AUTHORITARIAN
				ethiopia.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				_leave_alliances(ethiopia)
				ethiopia.set_tag("亲中", true)
				ethiopia.set_tag("亲苏", false)
				ethiopia.set_tag("亲美", false)
				ethiopia.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 10
			_add(W.I_DIPLO, 5)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_ARMY, -50)
			if ethiopia != null:
				ethiopia.government = GameConstants.Government.AUTHORITARIAN
				ethiopia.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			context["result_text"] = tr(TXT_R2)
		3:
			if ethiopia != null:
				ethiopia.government = GameConstants.Government.AUTHORITARIAN
				ethiopia.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			context["result_text"] = tr(TXT_R3)


## Country.LeaveAlliances() 逐项映射（含原版不常见的联盟标签）。



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_587_ethiopia_teglachin.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_587",
	"num": 587,
	"priority": 58700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_587_ethiopia_teglachin.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1977.2.3"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
