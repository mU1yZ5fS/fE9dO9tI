extends "res://数据脚本/event_script_base.gd"

## 原作 Event580.cs：哦，我们亲爱的祖国（马达加斯加，四选项）。 ## 触发：ReqEventForDLC02.cs:809-812 —— (月>=5 且 年>=1979) 年>=1980 → DATE_AFTER 1979.5.1。 ## 差异： ##  - 选项显隐 prepare 动态改写；isSEV → sev 标签；Torg → 对华贸易； ##  - data.diplomatic_reputation → W.I_DIPLO；proprc/prosov → 亲中/亲苏；puppetOf → puppet_of。



const TXT_OPT0_DIS := "event.script.event_580_madagascar.c0"
const TXT_OPT1_DIS := "event.script.event_580_madagascar.c1"
const TXT_OPT2_DIS := "event.script.event_580_madagascar.c2"

const TXT_R0 := "event.script.event_580_madagascar.c3"
const TXT_R1 := "event.script.event_580_madagascar.c4"
const TXT_R2 := "event.script.event_580_madagascar.c5"
const TXT_R3 := "event.script.event_580_madagascar.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var china := world.get_country_by_legacy_index(1)
	var c21 := world.get_country_by_legacy_index(21)
	var ussr_rel := world.empires[EmpireData.USSR].relations if world.empires.size() > EmpireData.USSR \
			and world.empires[EmpireData.USSR] != null else 0
	var opt := event_def.options
	if line < 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	var china_sev := china != null and china.has_tag("sev")
	if line < 3 and (china_sev or ussr_rel >= 700):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if data.size() > W.I_DIPLO and data.diplomatic_reputation <= 800 and c21 != null and c21.has_tag("对华贸易"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c133 := ws.get_country_by_legacy_index(133)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -70)
			if c133 != null:
				c133.government = GameConstants.Government.SOCIALIST
				c133.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c133)
				c133.set_tag("亲中", true)
				c133.set_tag("对华贸易", true)
			ws.influence_prc += 20
			_add(W.I_DIPLO, 20)
			context["result_text"] = tr(TXT_R0)
		1:
			if c133 != null:
				c133.government = GameConstants.Government.SOCIALIST
				c133.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c133)
				c133.set_tag("亲苏", true)
				c133.set_tag("对华贸易", true)
				c133.set_tag("sev", true)
			_add(W.I_BUDGET, -30)
			_add(W.I_DIPLO, 10)
			_add_relation(EmpireData.USSR, 150)
			context["result_text"] = tr(TXT_R1)
		2:
			if c133 != null:
				c133.government = GameConstants.Government.LIBERAL
				c133.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				_leave_alliances(c133)
				c133.puppet_of = GameConstants.LegacySlot.FRANCE
				c133.set_tag("对华贸易", true)
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, -300)
			context["result_text"] = tr(TXT_R2)
		3:
			if c133 != null:
				c133.government = GameConstants.Government.REFORMIST
				c133.sub_government = GameConstants.SubGovernment.PRAGMATIST
			context["result_text"] = tr(TXT_R3)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_580_madagascar.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_580",
	"num": 580,
	"priority": 58000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_580_madagascar.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.5.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
