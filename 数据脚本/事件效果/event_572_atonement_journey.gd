extends "res://数据脚本/event_script_base.gd"

## 原作 Event572.cs：赎罪之旅（法国赎罪行动，单选项）。
## 触发：ReqEventForDLC02.cs:1119-1122 —— !event_done[572] && event_done[390]
##   && c21.Gosstroy==1 && flag(任意国家 puppetOf==21) && YugAgree && data.world_political_balance==2。
##   复杂条件（flag 循环 + raw data.world_political_balance）→ trigger_script evaluate。
## 差异：
##  - event_done[572] 由 fire_only_once 覆盖；event_done[390] 在 evaluate 中检查；
##  - YugAgree → ws flag "YugAgree"；data.world_political_balance 无命名键 raw；
##  - relres → ws flag "relres"；isSEV → 标签 sev；Torg → 对华贸易；
##  - LeaveAlliances 用基类 _leave_alliances；JoinECON 只置 econ 标签。




const TXT_TUNISIA := "event.script.event_572_atonement_journey.c0"
const TXT_LIBYA := "event.script.event_572_atonement_journey.c1"
const TXT_CAR := "event.script.event_572_atonement_journey.c2"
const TXT_CAMEROON := "event.script.event_572_atonement_journey.c3"
const TXT_CAMEROON_NAME := "event.script.event_572_atonement_journey.c4"
const TXT_MALI := "event.script.event_572_atonement_journey.c5"
const TXT_GUINEA := "event.script.event_572_atonement_journey.c6"
const TXT_CIV := "event.script.event_572_atonement_journey.c7"
const TXT_TOGO := "event.script.event_572_atonement_journey.c8"
const TXT_BENIN := "event.script.event_572_atonement_journey.c9"
const TXT_GABON := "event.script.event_572_atonement_journey.c10"
const TXT_MADAGASCAR := "event.script.event_572_atonement_journey.c11"
const TXT_TAIL := "event.script.event_572_atonement_journey.c12"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if not world.completed_event_ids.has("event_390"):
		return false
	var c21 := world.get_country_by_legacy_index(21)
	if c21 == null or c21.government != GameConstants.Government.SOCIALIST:
		return false
	var flag := false
	for c in world.countries:
		if c != null and c.puppet_of == GameConstants.LegacySlot.FRANCE:
			flag = true
			break
	if not flag:
		return false
	if not world.get_flag("YugAgree"):
		return false
	if world.size() <= 131 or world.world_political_balance != 2:   # 原 data.world_political_balance（无命名键）
		return false
	return true


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var text := ""
	if ws.get_country_by_legacy_index(55) != null and ws.get_country_by_legacy_index(55).puppet_of == GameConstants.LegacySlot.FRANCE:
		text += tr(TXT_TUNISIA)
	if ws.get_country_by_legacy_index(13) != null and ws.get_country_by_legacy_index(13).puppet_of == GameConstants.LegacySlot.FRANCE:
		text += tr(TXT_LIBYA)
	if ws.get_country_by_legacy_index(65) != null and ws.get_country_by_legacy_index(65).puppet_of == GameConstants.LegacySlot.FRANCE:
		text += tr(TXT_CAR)
	if ws.get_country_by_legacy_index(66) != null and ws.get_country_by_legacy_index(66).puppet_of == GameConstants.LegacySlot.FRANCE:
		text += tr(TXT_CAMEROON)
		var c66 := ws.get_country_by_legacy_index(66)
		if c66 != null:
			c66.chinese_name = tr(TXT_CAMEROON_NAME)
	if ws.get_country_by_legacy_index(58) != null and ws.get_country_by_legacy_index(58).puppet_of == GameConstants.LegacySlot.FRANCE:
		text += tr(TXT_MALI)
	if ws.get_country_by_legacy_index(68) != null and ws.get_country_by_legacy_index(68).puppet_of == GameConstants.LegacySlot.FRANCE:
		text += tr(TXT_GUINEA)
	if ws.get_country_by_legacy_index(64) != null and ws.get_country_by_legacy_index(64).puppet_of == GameConstants.LegacySlot.FRANCE:
		text += tr(TXT_CIV)
	if ws.get_country_by_legacy_index(108) != null and ws.get_country_by_legacy_index(108).puppet_of == GameConstants.LegacySlot.FRANCE:
		text += tr(TXT_TOGO)
	if ws.get_country_by_legacy_index(62) != null and ws.get_country_by_legacy_index(62).puppet_of == GameConstants.LegacySlot.FRANCE:
		text += tr(TXT_BENIN)
	if ws.get_country_by_legacy_index(116) != null and ws.get_country_by_legacy_index(116).puppet_of == GameConstants.LegacySlot.FRANCE:
		text += tr(TXT_GABON)
	if ws.get_country_by_legacy_index(133) != null and ws.get_country_by_legacy_index(133).puppet_of == GameConstants.LegacySlot.FRANCE:
		text += tr(TXT_MADAGASCAR)
	var num := 0
	var china := ws.get_country_by_legacy_index(1)
	for c in ws.countries:
		if c == null:
			continue
		if c.puppet_of == GameConstants.LegacySlot.FRANCE:
			c.puppet_of = GameConstants.LegacySlot.NONE
			_leave_alliances(c)
			c.set_tag("亲苏", true)
			c.government = GameConstants.Government.SOCIALIST
			c.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
			if ws.get_flag("relres") or (china != null and china.has_tag("sev")):
				c.set_tag("对华贸易", true)
			num += 1
	_add_power(EmpireData.USSR, 5 * num)
	text += tr(TXT_TAIL)
	context["result_text"] = text



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_572_atonement_journey.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_572",
	"num": 572,
	"priority": 57200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_572_atonement_journey.gd",
	"trigger_script": "res://数据脚本/事件效果/event_572_atonement_journey.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
