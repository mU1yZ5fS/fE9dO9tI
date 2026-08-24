extends "res://数据脚本/event_script_base.gd"

## 原作 Event113.cs：南斯拉夫社会主义自治的痛苦（五选项）。
## 触发：TimeScript.cs:10936-10941 ——
##   日期>=1983.2.1 && !c15.eu && c15.SubGosstroy==11 && c20.SubGosstroy!=11。
## 差异：
##  - result 5 为死代码（button_text[5]=""）→ 跳过；
##  - data.yugoslavia_kosovo_chain 无 W.I_* 常量 → 直接 d.yugoslavia_kosovo_chain + 注释；result0/2 的 data.yugoslavia_kosovo_chain 读写是局部 no-op，跳过；
##  - Vyshi→亲美、isSEV→sev、Torg→对华贸易、dev→development。


const TXT_OPT1_DIS := "event.script.event_113_yugoslav_autonomy_pain.c0"
const TXT_OPT2_DIS := "event.script.event_113_yugoslav_autonomy_pain.c1"
const TXT_OPT3_DIS := "event.script.event_113_yugoslav_autonomy_pain.c2"
const TXT_OPT4_DIS := "event.script.event_113_yugoslav_autonomy_pain.c3"

const TXT_R0 := "event.script.event_113_yugoslav_autonomy_pain.c4"
const TXT_R1 := "event.script.event_113_yugoslav_autonomy_pain.c5"
const TXT_R2 := "event.script.event_113_yugoslav_autonomy_pain.c6"
const TXT_R3_DEV1 := "event.script.event_113_yugoslav_autonomy_pain.c7"
const TXT_R3_OTHER := "event.script.event_113_yugoslav_autonomy_pain.c8"
const TXT_R4 := "event.script.event_113_yugoslav_autonomy_pain.c9"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var agents := data.agents if data.size() > W.I_AGENTS else 0
	var coal := _coalition_percent(world)
	var policy_left := (line < 3 and party < 8) or (coal > 66 and party > 7)
	var china := world.get_country_by_legacy_index(1)
	var china_sev := china != null and china.has_tag("sev")
	var relres := world.get_flag("relres")
	var usa := world.get_country_by_legacy_index(51)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if agents >= 50 and policy_left:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if ((world.influence_prc >= 150 and china_sev) or (relres and world.influence_prc >= 250)) and policy_left:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if world.influence_prc >= 300 and agents >= 50 and ((line < 2 and party < 8) or (coal > 66 and party > 7)):
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	if (world.influence_prc >= 200 or (usa != null and usa.development > 0)) and agents >= 50 and ((line >= 3 and party < 8) or (coal > 66 and party > 7)):
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], tr(TXT_OPT4_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var yugoslavia := ws.get_country_by_legacy_index(15)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# 官方版 DLL 反编译（tmp_Event113.cs case 0，data[86]-=1）证实为 ref 真实写入，
			# 旧转储 ptr 模式系反编译伪影，v0.3.3 误判 no-op，已恢复。
			if d.size() > 86:
				d.yugoslavia_kosovo_chain -= 1
			context["result_text"] = tr(TXT_R0)
		1:
			ws.influence_prc += 20
			_add(W.I_AGENTS, -50)
			_add(W.I_DIPLO, -10)
			_add(W.I_BUDGET, -200)
			if d.size() > 86:
				d.yugoslavia_kosovo_chain += 2
			_set_torg_or_agents(yugoslavia)
			context["result_text"] = tr(TXT_R1)
		2:
			_add_relation(EmpireData.USSR, 200)
			_add_relation(EmpireData.USA, -50)
			_add(W.I_DIPLO, -10)
			_add(W.I_PARTY_SUPPORT, 50)
			if yugoslavia != null:
				yugoslavia.set_tag("sev", true)
			_set_torg_or_agents(yugoslavia)
			context["result_text"] = tr(TXT_R2)
		3:
			var dev1: bool = yugoslavia != null and yugoslavia.development == 1
			_add(W.I_AGENTS, -50)
			ws.influence_prc += 20
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_DIPLO, 30)
			_add_power(EmpireData.USSR, 20)
			_add_power(EmpireData.USA, -30)
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, 200)
			if d.size() > 86:
				d.yugoslavia_kosovo_chain += 2
			_set_torg_or_agents(yugoslavia)
			if yugoslavia != null:
				yugoslavia.government = GameConstants.Government.AUTHORITARIAN
				yugoslavia.sub_government = GameConstants.SubGovernment.LEFT_RADICAL if dev1 else 10
			context["result_text"] = tr(TXT_R3_DEV1) if dev1 else tr(TXT_R3_OTHER)
		4:
			_add(W.I_AGENTS, -50)
			_add_power(EmpireData.USA, 20)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_DIPLO, -30)
			_add_power(EmpireData.USSR, -20)
			_add_relation(EmpireData.USA, 200)
			_add_relation(EmpireData.USSR, -250)
			if d.size() > 86:
				d.yugoslavia_kosovo_chain -= 3
			if yugoslavia != null:
				yugoslavia.set_tag("亲美", true)
			context["result_text"] = tr(TXT_R4)


func _set_torg_or_agents(c: CountryData) -> void:
	if c == null:
		return
	if not c.has_tag("对华贸易"):
		c.set_tag("对华贸易", true)
	else:
		_add(W.I_AGENTS, 30)


## 原版 summa_3_2 复算：仅 party_system>7 时计算执政党(1)+盟友席位数 ×100 / 五党总席位数。
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_113_yugoslav_autonomy_pain.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_113",
	"num": 113,
	"priority": 11300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_113_yugoslav_autonomy_pain.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1983.2.1"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "eu", "target": "15"}]}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 11, "target": "15"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "v": 11, "target": "20"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
