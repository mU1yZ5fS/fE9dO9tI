extends "res://数据脚本/event_script_base.gd"

## 原作 Event379.cs：苏修美帝，狼狈为奸（北约东扩，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - SOV_PRC_PartiesConnection → I_COMMUNICATIONS（见 event_435 约定）；
##  - 原版 result2 num7 五项条件逐项移植；Debug.Log 跳过。

const TXT_DIS_BUDGET := "event.script.event_379_nato_expansion.c0"
const TXT_DIS_AGENTS := "event.script.event_379_nato_expansion.c1"
const TXT_DIS_ARMY := "event.script.event_379_nato_expansion.c2"
const TXT_LABEL_BUDGET := "event.script.event_379_nato_expansion.c3"
const TXT_LABEL_AGENTS := "event.script.event_379_nato_expansion.c4"
const TXT_LABEL_ARMY := "event.script.event_379_nato_expansion.c5"
const TXT_R0 := "event.script.event_379_nato_expansion.c6"
const TXT_R1 := "event.script.event_379_nato_expansion.c7"
const TXT_R2 := "event.script.event_379_nato_expansion.c8"
const TXT_R2_FAIL := "event.script.event_379_nato_expansion.c9"
const TXT_WAR_NAME := "event.script.event_379_nato_expansion.c10"
const TXT_WAR_ATT := "event.script.event_379_nato_expansion.c11"
const TXT_WAR_DEF := "event.script.event_379_nato_expansion.c12"
const TXT_POLAND := "event.script.event_379_nato_expansion.c13"
const TXT_HUNGARY := "event.script.event_379_nato_expansion.c14"
const TXT_ROMANIA := "event.script.event_379_nato_expansion.c15"
const TXT_CZECH := "event.script.event_379_nato_expansion.c16"
const TXT_POLAND_NATO := "event.script.event_379_nato_expansion.c17"
const TXT_HUNGARY_NATO := "event.script.event_379_nato_expansion.c18"
const TXT_ROMANIA_NATO := "event.script.event_379_nato_expansion.c19"
const TXT_CZECH_NAME := "event.script.event_379_nato_expansion.c20"
const TXT_YUGO := "event.script.nato_expansion.txt_yugo"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	# 原作 Event379.cs:19-22：TextOfEvents 显示时 iron_and_blood → achievements.Set(138)
	Achievements.set_achievement(138)
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	var poland := world.get_country_by_legacy_index(2)
	var hungary := world.get_country_by_legacy_index(4)
	var romania := world.get_country_by_legacy_index(5)
	var czech := world.get_country_by_legacy_index(3)
	if (poland != null and poland.has_tag("亲中")) or (hungary != null and not hungary.has_tag("亲苏")) 			or (romania != null and romania.has_tag("亲中")) or (czech != null and czech.development > 0) 			and _d(W.I_ARMY) >= 400 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 200 and _d(W.I_AGENTS) >= 150:
		_enable(opt[2], event_def.options[2].text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 30:
		_disable(opt[2], tr(TXT_DIS_BUDGET).format([20]))
	elif _d(W.I_AGENTS) < 150:
		_disable(opt[2], tr(TXT_DIS_AGENTS).format([15]))
	else:
		_disable(opt[2], tr(TXT_DIS_ARMY).format([40]))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_add(W.I_PARTY_SUPPORT, -600)
	var mongolia := ws.get_country_by_legacy_index(9)
	if mongolia != null and mongolia.has_tag("亲中"):
		mongolia.set_tag("亲中", false)
		mongolia.set_tag("nato", true)
		mongolia.set_tag("okb", false)
		mongolia.set_tag("econ", false)
	var yugo := ws.get_country_by_legacy_index(15)
	var china := ws.get_country_by_legacy_index(1)
	var opt := int(context.get("option_index", -1))
	var yugo_txt: String = tr(TXT_YUGO) if (yugo != null and yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and not yugo.has_tag("sev") 			and (china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL))) else ""
	if opt == 0:
		context["result_text"] = tr(TXT_R0).format(["\n", yugo_txt])
		_apply_wp_to_nato()
		_add_power(EmpireData.USA, 150)
		_add_power(EmpireData.USSR, 150)
		_add_relation(EmpireData.USA, -600)
		_add_relation(EmpireData.USSR, -600)
		if yugo != null and yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and not yugo.has_tag("sev") 				and china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			yugo.set_tag("亲中", true)
	elif opt == 1:
		context["result_text"] = tr(TXT_R1).format(["\n", yugo_txt])
		_apply_wp_to_nato()
		_add_power(EmpireData.USA, 150)
		_add_power(EmpireData.USSR, 150)
		_add_relation(EmpireData.USA, -700)
		_add_relation(EmpireData.USSR, -700)
		if yugo != null and yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and not yugo.has_tag("sev") 				and china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			yugo.set_tag("亲中", true)
	else:
		var num := 0
		for c in ws.countries:
			if c != null and c.has_tag("okb"):
				num += 1
		ws.set_flag("relres", false)
		var usa := ws.get_country_by_legacy_index(51)
		if usa != null:
			usa.set_tag("对华贸易", false)
			usa.development = 0
		var num2 := 0
		var num3 := 0
		var num4 := 0
		var num5 := 0
		var num6 := 0
		if poland_c() != null and poland_c().has_tag("亲中"):
			num2 += 1
			num3 += 1
			num4 = 1
		if hungary_c() != null and not hungary_c().has_tag("亲苏"):
			num2 += 1
			num3 += 1
			num6 = 1
		if romania_c() != null and romania_c().has_tag("亲中"):
			num2 += 1
			num3 += 1
			num5 = 1
		if albania_c() != null and albania_c().has_tag("亲中"):
			num2 += 1
		if czech_c() != null and czech_c().development > 0:
			num2 += 1
			num3 += 1
		_add_relation(EmpireData.USA, -700)
		_add_relation(EmpireData.USSR, -700)
		var text2 := ""
		var num7 := 0
		var egypt := ws.get_country_by_legacy_index(30)
		if num2 == 5 and num > 10 and egypt != null and egypt.has_tag("oar") and not egypt.has_tag("亲苏") 				and yugo != null and yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and not yugo.has_tag("sev") 				and china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			_start_war_379(60 * num2, 1000 - 60 * num2)
			for i in range(18):
				var cc := ws.get_country_by_legacy_index(i)
				if cc != null and cc.has_tag("ovd") and (i != 2 or num4 <= 0) and (i != 5 or num5 <= 0) and (i != 4 or num6 <= 0):
					_leave_wp(cc)
					_establish_government(cc, "prosov")
					cc.set_tag("nato", true)
					if ussr_c() != null:
						cc.government = ussr_c().government
						cc.sub_government = ussr_c().sub_government
			for c in ws.countries:
				if c != null and (c.has_tag("亲美") or c.has_tag("nato")):
					c.set_tag("对华贸易", false)
			if poland_c() != null and poland_c().has_tag("亲中"):
				_leave_nato(poland_c())
				poland_c().set_tag("sev", false)
				poland_c().set_tag("对华贸易", true)
				text2 += tr(TXT_POLAND) + "\n"
			if hungary_c() != null and not hungary_c().has_tag("亲苏"):
				_leave_nato(hungary_c())
				hungary_c().set_tag("sev", false)
				hungary_c().set_tag("对华贸易", true)
				text2 += tr(TXT_HUNGARY) + "\n"
			if romania_c() != null and romania_c().has_tag("亲中"):
				_leave_nato(romania_c())
				romania_c().set_tag("对华贸易", true)
				romania_c().set_tag("sev", false)
				text2 += tr(TXT_ROMANIA) + "\n"
			if czech_c() != null and czech_c().development > 0:
				if czech_c().parts.size() < 1:
					czech_c().parts.resize(1)
				czech_c().parts[0] = true
				var slovakia := ws.get_country_by_legacy_index(98)
				if slovakia != null:
					slovakia.set_tag("对华贸易", true)
				czech_c().name = tr(TXT_CZECH_NAME)
				czech_c().chinese_name = tr(TXT_CZECH_NAME)
				if slovakia != null:
					slovakia.set_tag("ovd", true)
				text2 += tr(TXT_CZECH) + "\n"
			if yugo != null:
				yugo.set_tag("亲中", true)
			context["result_text"] = tr(TXT_R2).format(["\n", num3, text2])
			return
		if num2 >= 5:
			num7 += 1
		if num > 10:
			num7 += 1
		if egypt != null and egypt.has_tag("oar") and not egypt.has_tag("亲苏"):
			num7 += 1
		if yugo != null and yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and not yugo.has_tag("sev"):
			num7 += 1
		if china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			num7 += 1
		if poland_c() != null and poland_c().has_tag("亲中"):
			text2 += tr(TXT_POLAND_NATO) + "\n"
		ws.set_flag("relres", false)
		if usa != null:
			usa.set_tag("对华贸易", false)
			usa.development = 0
		if hungary_c() != null and not hungary_c().has_tag("亲苏"):
			text2 += tr(TXT_HUNGARY_NATO) + "\n"
		if romania_c() != null and romania_c().has_tag("亲中"):
			text2 += tr(TXT_ROMANIA_NATO) + "\n"
		for i in range(18):
			var cc := ws.get_country_by_legacy_index(i)
			if cc != null and cc.has_tag("亲中"):
				_add(W.I_INFLUENCE, -80)
			if cc != null and cc.has_tag("ovd"):
				_leave_wp(cc)
				_establish_government(cc, "prosov")
				cc.set_tag("nato", true)
				if ussr_c() != null:
					cc.government = ussr_c().government
					cc.sub_government = ussr_c().sub_government
		for c in ws.countries:
			if c != null and (c.has_tag("亲美") or c.has_tag("nato")):
				c.set_tag("对华贸易", false)
		if yugo != null and yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and not yugo.has_tag("sev") 				and china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			yugo.set_tag("亲中", true)
		context["result_text"] = tr(TXT_R2_FAIL).format(["\n", num3, text2, yugo_txt, num7])


func _apply_wp_to_nato() -> void:
	for i in range(18):
		var cc := ws.get_country_by_legacy_index(i)
		if cc != null and cc.has_tag("亲中"):
			_add(W.I_INFLUENCE, -80)
		if cc != null and cc.has_tag("ovd"):
			_leave_wp(cc)
			_establish_government(cc, "prosov")
			cc.set_tag("nato", true)
			if ussr_c() != null:
				cc.government = ussr_c().government
				cc.sub_government = ussr_c().sub_government
	for c in ws.countries:
		if c != null and (c.has_tag("亲美") or c.has_tag("nato")):
			c.set_tag("对华贸易", false)


func _start_war_379(infl1: int, infl2: int) -> void:
	game.start_war(17, tr(TXT_WAR_ATT), tr(TXT_WAR_DEF), infl1, infl2, 1, 1)
	if ws.wars.size() > 17 and ws.wars[17] != null:
		ws.wars[17].name_war = tr(TXT_WAR_NAME)
		ws.wars[17].fortnight_max = 20


func poland_c() -> CountryData: return ws.get_country_by_legacy_index(2)
func hungary_c() -> CountryData: return ws.get_country_by_legacy_index(4)
func romania_c() -> CountryData: return ws.get_country_by_legacy_index(5)
func czech_c() -> CountryData: return ws.get_country_by_legacy_index(3)
func albania_c() -> CountryData: return ws.get_country_by_legacy_index(20)
func ussr_c() -> CountryData: return ws.get_country_by_legacy_index(7)


func _leave_wp(c: CountryData) -> void:
	c.set_tag("ovd", false)


func _leave_nato(c: CountryData) -> void:
	c.set_tag("nato", false)


func _establish_government(c: CountryData, kind: String) -> void:
	if kind == "prosov":
		c.set_tag("亲中", false)
		c.set_tag("亲苏", true)
		c.set_tag("亲美", false)




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0










# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_379_nato_expansion.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_379",
	"num": 379,
	"priority": 37900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_379_nato_expansion.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
