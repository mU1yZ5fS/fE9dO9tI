extends "res://数据脚本/event_script_base.gd"

## 原作 Event629.cs：你我，咱们，瓦努阿图人（瓦努阿图独立，三选项）。 ## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:956-959 —— ##   日期>=1980.7.30（原 (1980&&m>=7&&d>=30) (1980&&m>=8) y>=1981） ##   且 allcountries[21].SubGosstroy != 19（法国非特定路线）。 ## 差异：原版选项2 Destroy(button[2])；Godot _disable 灰显同义。 ##   Vyshi→亲美、proprc→亲中、Torg→对华贸易、cw→内战中、Gosstroy/SubGosstroy→government/sub_government。

const TXT_OPT0_PASSIVE := "event.script.event_629_vanuatu_independence.c0"
const TXT_OPT0_SUPPORT := "event.script.event_629_vanuatu_independence.c1"
const TXT_R0_STEVENS := "event.script.vanuatu_independence.txt_r0_stevens"
const TXT_R0_LINI := "event.script.vanuatu_independence.txt_r0_lini"
const TXT_R0_MODERATE := "event.script.vanuatu_independence.txt_r0_moderate"
const TXT_R1_STEVENS := "event.script.vanuatu_independence.txt_r1_stevens"
const TXT_R1_LINI := "event.script.vanuatu_independence.txt_r1_lini"
const TXT_R1_MODERATE := "event.script.vanuatu_independence.txt_r1_moderate"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var vanuatu := ws.get_country_by_legacy_index(159)
	var china := ws.get_country_by_legacy_index(1)
	var usa_power := ws.empires[0].power if ws.empires.size() > 0 and ws.empires[0] != null else 0
	var sov_power := ws.empires[1].power if ws.empires.size() > 1 and ws.empires[1] != null else 0
	var passive := (vanuatu != null and vanuatu.level_of_instability <= 0) \
		or ws.is_socialism(china, false) \
		or (sov_power < usa_power and china != null and china.has_tag("asean"))
	var opt := event_def.options
	if passive:
		_enable(opt[0], tr(TXT_OPT0_PASSIVE))
	else:
		_enable(opt[0], tr(TXT_OPT0_SUPPORT))
	_enable(opt[1], event_def.options[1].text)
	_disable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var vanuatu := ws.get_country_by_legacy_index(159)
	var china := ws.get_country_by_legacy_index(1)
	var opt := int(context.get("option_index", -1))
	if vanuatu == null:
		return
	# 原版 :37：ResultsOfEvents 开头统一改名 vanuatu.chinese_name = "瓦努阿图"
	var usa_power := ws.empires[0].power if ws.empires.size() > 0 and ws.empires[0] != null else 0
	var sov_power := ws.empires[1].power if ws.empires.size() > 1 and ws.empires[1] != null else 0
	var stevens := sov_power < usa_power and china != null and china.has_tag("asean")
	var lini := (not stevens) and vanuatu.level_of_instability > 0 and ws.is_socialism(china, true)
	match opt:
		0:
			_apply_result(context, vanuatu, stevens, lini)
		1:
			_apply_result(context, vanuatu, stevens, lini)
			_add(W.I_BUDGET, -30)
			vanuatu.set_tag("对华贸易", true)


## 原版 :40-72 与 :76-108 的公共分支（opt1 额外扣预算+建交）。
func _apply_result(context: Dictionary, vanuatu: CountryData, stevens: bool, lini: bool) -> void:
	if stevens:
		context["result_text"] = tr(TXT_R0_STEVENS) if int(context.get("option_index", -1)) == 0 else tr(TXT_R1_STEVENS)
		vanuatu.government = GameConstants.Government.LIBERAL
		vanuatu.sub_government = GameConstants.SubGovernment.LIBERAL
		_leave_alliances(vanuatu)
		vanuatu.set_tag("亲美", true)
		_add_power(EmpireData.USA, 10)
	elif lini:
		context["result_text"] = tr(TXT_R0_LINI) if int(context.get("option_index", -1)) == 0 else tr(TXT_R1_LINI)
		vanuatu.government = GameConstants.Government.SOCIALIST
		vanuatu.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		_leave_alliances(vanuatu)
		vanuatu.set_tag("亲中", true)
		vanuatu.set_tag("对华贸易", true)
		ws.influence_prc += 10
		_add_power(EmpireData.USA, -10)
		_add_relation(EmpireData.USA, -70)
	else:
		context["result_text"] = tr(TXT_R0_MODERATE) if int(context.get("option_index", -1)) == 0 else tr(TXT_R1_MODERATE)
		vanuatu.government = GameConstants.Government.REFORMIST
		vanuatu.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		_leave_alliances(vanuatu)
		_add_power(EmpireData.USA, -10)
		if vanuatu.内战中:
			vanuatu.set_tag("亲中", true)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_629_vanuatu_independence.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_629",
	"num": 629,
	"priority": 62900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_629_vanuatu_independence.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1980.7.30"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "v": 19, "target": "21"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
