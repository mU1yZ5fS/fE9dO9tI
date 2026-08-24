extends "res://数据脚本/event_script_base.gd"

## 原作 Event703.cs：选举：自愿消费降级（魁北克新国家走向，单选项）。
## 触发：ReqEventsDLC02.cs:1571-1573 —— c167.parts[0] && DATE_AFTER 1984.5.20 → trigger_script。
## 差异：LeaveAlliances→_leave_alliances、Vyshi→亲美、puppetOf→puppet_of、isNATO/isSocEU→标签。

const TXT_R_USA := "event.script.event_703_voluntary_downgrade.c0"
const TXT_R_USA_APPEND := "event.script.event_703_voluntary_downgrade.c1"
const TXT_R_FRANCE := "event.script.event_703_voluntary_downgrade.c2"
const TXT_R_FRANCE_MOD := "event.script.event_703_voluntary_downgrade.c3"
const TXT_R_FRANCE_SUB := "event.script.event_703_voluntary_downgrade.c4"
const TXT_R_SOCDEM := "event.script.event_703_voluntary_downgrade.c5"
const TXT_R_SOCDEM_APPEND := "event.script.event_703_voluntary_downgrade.c6"
const TXT_R_COUP_FMT := "event.script.event_703_voluntary_downgrade.c7"
const TXT_R_EXILE := "event.script.event_703_voluntary_downgrade.c8"
const TXT_R_CANADA := "event.script.event_703_voluntary_downgrade.c9"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	var quebec := ws.get_country_by_legacy_index(167)
	var france := ws.get_country_by_legacy_index(21)
	var spain := ws.get_country_by_legacy_index(86)
	var china := ws.get_country_by_legacy_index(1)
	if usa != null and usa.power > 400:
		context["result_text"] = tr(TXT_R_USA)
		if quebec != null:
			_leave_alliances(quebec)
			quebec.set_tag("亲美", true)
			if ws.get_country_by_legacy_index(51) != null \
					and ws.get_country_by_legacy_index(51).has_tag("nato"):
				quebec.set_tag("nato", true)
		if france != null and france.government < 2:
			context["result_text"] = tr(TXT_R_USA) + tr(TXT_R_USA_APPEND)
		return
	var mod45 := ws.modifiers.size() > 45 and ws.modifiers[45] != null and ws.modifiers[45].is_active
	if mod45 or (france != null and (france.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN or france.sub_government == GameConstants.SubGovernment.NEO_FASCIST)):
		var text := tr(TXT_R_FRANCE)
		if quebec != null:
			_leave_alliances(quebec)
		if mod45:
			text += tr(TXT_R_FRANCE_MOD)
			if quebec != null:
				quebec.government = GameConstants.Government.LIBERAL
				quebec.sub_government = GameConstants.SubGovernment.MODERATE
				quebec.puppet_of = GameConstants.LegacySlot.FRANCE
			context["result_text"] = text
			return
		text += tr(TXT_R_FRANCE_SUB)
		if quebec != null:
			quebec.government = GameConstants.Government.AUTHORITARIAN
			quebec.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			quebec.puppet_of = GameConstants.LegacySlot.FRANCE
		context["result_text"] = text
		return
	if france != null and france.government == GameConstants.Government.REFORMIST:
		var text2 := tr(TXT_R_SOCDEM)
		if quebec != null:
			_leave_alliances(quebec)
			quebec.government = GameConstants.Government.REFORMIST
			quebec.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		if spain != null and spain.has_tag("soc_eu"):
			text2 += tr(TXT_R_SOCDEM_APPEND)
			if quebec != null:
				quebec.set_tag("soc_eu", true)
		context["result_text"] = text2
		return
	if ws.is_socialism(france, true):
		var faction := "和平与民主联盟"
		if france.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST:
			faction = "魁北克共产党"
		elif france.sub_government == GameConstants.SubGovernment.MAOIST:
			faction = "魁北克马列主义党"
		context["result_text"] = tr(TXT_R_COUP_FMT).replace("{0}", faction)
		if quebec != null:
			_leave_alliances(quebec)
			quebec.government = GameConstants.Government.SOCIALIST
			quebec.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			if france.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST:
				quebec.set_tag("亲苏", true)
			elif france.sub_government == GameConstants.SubGovernment.MAOIST:
				quebec.set_tag("亲中", true)
			elif france.sub_government == GameConstants.SubGovernment.TROTSKYIST and china != null and china.sub_government == GameConstants.SubGovernment.TROTSKYIST:
				quebec.set_tag("亲中", true)
		return
	if france != null and (france.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST or france.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST):
		context["result_text"] = tr(TXT_R_EXILE)
		if quebec != null:
			_leave_alliances(quebec)
			quebec.government = GameConstants.Government.REFORMIST
			quebec.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
		return
	context["result_text"] = tr(TXT_R_CANADA)
	if quebec != null:
		_leave_alliances(quebec)
		quebec.government = GameConstants.Government.LIBERAL
		quebec.sub_government = GameConstants.SubGovernment.LIBERAL
		quebec.set_tag("亲美", true)
	if MapService.instance != null:
		MapService.instance.sync_map_merges()


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19840520:
		return false
	var quebec := world.get_country_by_legacy_index(167)
	return quebec != null and quebec.parts.size() > 0 and quebec.parts[0]



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_703_voluntary_downgrade.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_703",
	"num": 703,
	"priority": 70300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_703_voluntary_downgrade.gd",
	"trigger_script": "res://数据脚本/事件效果/event_703_voluntary_downgrade.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
