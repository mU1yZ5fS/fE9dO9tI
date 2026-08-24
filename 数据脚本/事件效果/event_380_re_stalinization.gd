extends "res://数据脚本/event_script_base.gd"

## 原作 Event380.cs：罗曼诺夫宣布实施“再斯大林化”（三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - SOV_PRC_PartiesConnection → I_COMMUNICATIONS（见 event_435 约定）；
##  - 选项全部常开，无 prepare 动态改文案。

const TXT_R0 := "event.script.event_380_re_stalinization.c0"
const TXT_R1 := "event.script.event_380_re_stalinization.c1"
const TXT_R2 := "event.script.event_380_re_stalinization.c2"
const TXT_ALBANIA := "event.script.event_380_re_stalinization.c3"
const TXT_YUGO := "event.script.event_380_re_stalinization.c4"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var albania := ws.get_country_by_legacy_index(20)
	var yugo := ws.get_country_by_legacy_index(15)
	var china := ws.get_country_by_legacy_index(1)
	var mod6: bool = ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	if not ws.get_flag("relres") and (china != null and china.sub_government == GameConstants.SubGovernment.SOVIET_STYLE or mod6):
		d.communications += 100
	var flag_albania := false
	if albania != null and not albania.has_tag("亲中") and albania.government != GameConstants.Government.REFORMIST:
		albania.set_tag("sev", true)
		albania.set_tag("ovd", true)
		albania.set_tag("亲苏", true)
		_add(W.I_INFLUENCE, -15)
		_add_power(EmpireData.USSR, 50)
		flag_albania = true
	var flag_yugo := false
	if yugo != null and yugo.government == GameConstants.Government.AUTHORITARIAN and not yugo.has_tag("fxseu") and not yugo.has_tag("nazimao"):
		yugo.set_tag("sev", true)
		yugo.set_tag("ovd", true)
		yugo.set_tag("亲苏", true)
		if yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
			yugo.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
		_add(W.I_INFLUENCE, -15)
		_add_power(EmpireData.USSR, 50)
		flag_yugo = true
	_add_power(EmpireData.USSR, 10)
	var t_albania: String = tr(TXT_ALBANIA) if flag_albania else ""
	var t_yugo: String = tr(TXT_YUGO) if flag_yugo else ""
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0).format(["\n", t_albania, t_yugo])
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					pol.power += 500
				elif pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					pol.loyalty -= 50
				elif pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
					pol.loyalty -= 200
				elif pol != null:
					pol.loyalty -= 350
			if game.is_faction_leading(0):
				_add(W.I_PARTY_SUPPORT, 300)
			else:
				_add(W.I_PARTY_SUPPORT, -300)
			_add_relation(EmpireData.USSR, 200)
			if china != null and china.has_tag("sev"):
				_add_relation(EmpireData.USSR, 200)
		1:
			context["result_text"] = tr(TXT_R1).format(["\n", t_albania, t_yugo])
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					pol.power -= 500
				elif pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					pol.loyalty += 50
				elif pol != null and pol.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
					pol.loyalty += 200
				elif pol != null:
					pol.loyalty += 350
			if game.is_faction_leading(0):
				_add(W.I_PARTY_SUPPORT, -300)
			else:
				_add(W.I_PARTY_SUPPORT, 150)
		_:
			context["result_text"] = tr(TXT_R2).format(["\n", t_albania, t_yugo])
			if china != null and china.has_tag("sev"):
				_add_relation(EmpireData.USSR, 200)









# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_380_re_stalinization.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_380",
	"num": 380,
	"priority": 38000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_380_re_stalinization.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
