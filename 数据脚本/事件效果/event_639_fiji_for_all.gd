extends "res://数据脚本/event_script_base.gd"

## 原作 Event639.cs：为了所有人的斐济（斐济左翼行动，单选项）。
## 触发：DiploButtonScript.cs:12193 —— 外交按钮 1050，selected_country==160，入口扣 200/200 后手动触发。
## 差异：Vyshi→亲美、proprc→亲中、Torg→对华贸易、puppetOf→puppet_of、name→chinese_name。

const TXT_R_OK := "event.script.event_639_fiji_for_all.c0"
const TXT_R_FAIL := "event.script.event_639_fiji_for_all.c1"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var fiji := ws.get_country_by_legacy_index(160)
	var vanuatu := ws.get_country_by_legacy_index(159)
	var new_caledonia := ws.get_country_by_legacy_index(154)
	var australia := ws.get_country_by_legacy_index(135)
	var png := ws.get_country_by_legacy_index(136)
	var angola := ws.get_country_by_legacy_index(123)
	if angola != null:
		angola.prc_power = 600
		angola.sov_power = 300
		angola.usa_power = 100
	var opt := int(context.get("option_index", -1))
	if opt != 0 or fiji == null:
		return
	var vanuatu_ok := vanuatu != null and (ws.is_socialism(vanuatu, true) or vanuatu.government == GameConstants.Government.REFORMIST)
	var nc_ok := new_caledonia != null and new_caledonia.puppet_of < 0
	var aus_ok := australia != null and (ws.is_socialism(australia, true) or australia.government == GameConstants.Government.REFORMIST) \
		and australia.sub_government != GameConstants.SubGovernment.LEFT_CONSERVATIVE
	if vanuatu_ok and nc_ok and aus_ok:
		context["result_text"] = tr(TXT_R_OK)
		_leave_alliances(fiji)
		fiji.set_tag("亲中", true)
		fiji.set_tag("对华贸易", true)
		if australia != null and ws.is_socialism(australia, true) \
				and vanuatu != null and ws.is_socialism(vanuatu, true) \
				and png != null and ws.is_socialism(png, true):
			fiji.government = GameConstants.Government.SOCIALIST
			fiji.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			fiji.chinese_name = "斐济民主共和国"
			return
		fiji.government = GameConstants.Government.REFORMIST
		fiji.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		fiji.chinese_name = "斐济共和国"
		return
	context["result_text"] = tr(TXT_R_FAIL)
	fiji.government = GameConstants.Government.AUTHORITARIAN
	fiji.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
	fiji.chinese_name = "斐济主权民主共和国"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_639_fiji_for_all.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_639",
	"num": 639,
	"priority": 63900,
	"notify": false,
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
