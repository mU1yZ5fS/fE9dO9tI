extends "res://数据脚本/event_script_base.gd"

## 原作 Event685.cs：战略武器限制谈判——新人入局（三选项）。
## 触发：ReqEventsDLC02.cs:232-234 —— china.okb && r544∈{1,2} && science[26/22/29]
##   && data.year>1980 && influencePRC>=500 && !china.sev/ovd/asean/seato → trigger_script evaluate。
## 差异：names1/names2 → name_display；{2}=军委主席（politics_positions[1]，<100 用槽内人，否则“其他”）；
##   {0}（结果3）=外交部长（politics_positions[2]，<100 用槽内人，否则领袖）；
##   old_modify_desc[50] 为 display-only 文案，按项目惯例跳过并留原文。

const TXT_DESC_FMT := "event.script.event_685_salt_newcomer.c0"
const TXT_OPT0_DIS := "event.script.event_685_salt_newcomer.c1"
const TXT_OPT1_DIS := "event.script.event_685_salt_newcomer.c2"
# 提取器丢掉了 string.Format 开头的 "{"，见 tmp/event_677_685_fmt.txt Event685 FMT_1/FMT_2。
const TXT_R0_FMT := "event.script.event_685_salt_newcomer.c3"
const TXT_R1_FMT := "event.script.event_685_salt_newcomer.c4"
const TXT_R2_FMT := "event.script.event_685_salt_newcomer.c5"
# 原版 old_modify_desc[50] 追加的 display-only 文案（本版由 ModifierCatalog 静态维护，跳过运行时拼接）：
#   R0: |[color=red]参与SALT机制[/color]|中美关系+0.2，中苏关系+0.2，军事实力-0.4，特勤网络+0.2，思想自由化+0.2，外交声誉高于90.0时：外交声誉-0.2，外交声誉低于50.0时：外交声誉+0.2，核战必定不会赢得胜利
#   R1: |[color=red]参与弱化的SALT机制[/color]|中美关系+0.1，中苏关系+0.1，军事实力-0.2，外交声誉高于90.0时：外交声誉-0.1，外交声誉低于50.0时：外交声誉+0.1
#   R1: |[color=red]军备发展新方针：贯彻质量制胜[/color]|预算-4.0，军力+2.0，人民支持度+1.0，生活水平+0.6，干涉点数+4.0，军武支援效果+2.0，外交声誉+0.1，科技点+10.0
#   R2: |[color=red]自行其是的世界第三极[/color]|中美关系-1，中苏关系-1，外交声誉+0.2


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	event_def.description = tr(TXT_DESC_FMT).replace("{0}{1}", _leader_name(world))
	if event_def.options.size() < 3:
		return
	var opt := event_def.options
	if _res(W.I_POLITICAL_LINE) != 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if _res(W.I_BUDGET) + _res(W.I_RESERVE) >= 150:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var leader := _leader_name(ws)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0_FMT).replace("{0}{1}", leader)
			_set_data(W.I_DIPLO, 700)
			_add(W.I_PARTY_SUPPORT, -50)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, 80)
			_add_power(EmpireData.USA, 20)
			_add_relation(EmpireData.USSR, 80)
			_add_power(EmpireData.USSR, 20)
		1:
			var military := _military_chairman_name(ws)
			context["result_text"] = tr(TXT_R1_FMT).replace("{0}{1}", leader).replace("{2}", military)
			_set_data(W.I_DIPLO, 800)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_BUDGET, -200)
			ws.influence_prc += 50
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, 10)
			_add_relation(EmpireData.USSR, -50)
			_add_power(EmpireData.USSR, 10)
		2:
			var speaker := _foreign_minister_phrase(ws)
			context["result_text"] = tr(TXT_R2_FMT).replace("{0}", speaker)
			_add(W.I_DIPLO, 100)
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, -250)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null:
		return false
	var d2 := world
	if d2.size() <= W.I_YEAR or d2.year <= 1980:
		return false
	var china := world.get_country_by_legacy_index(1)
	if china == null or not china.has_tag("okb") \
			or china.has_tag("sev") or china.has_tag("ovd") \
			or china.has_tag("asean") or china.has_tag("seato"):
		return false
	var r544 := world.result_of_event_num(544)
	if r544 != 1 and r544 != 2:
		return false
	if world.techs == null:
		return false
	for idx in [26, 22, 29]:
		if world.techs.unlocked.size() <= idx or not world.techs.unlocked[idx]:
			return false
	return world.influence_prc >= 500


## 原版 {0}{1} 位置 = names1[name_1] + names2[name_2] → Godot name_display。
func _leader_name(world: WorldState) -> String:
	if world != null and world.leader != null and world.leader.name_display != "":
		return world.leader.name_display
	return "华国锋"


## 原版 politics_dolshnost[1]（军委主席槽）：<100 用槽内政治家，150/200 等哨兵→“其他”。
func _military_chairman_name(world: WorldState) -> String:
	if world != null and world.politics_positions.size() > 1:
		var idx := world.politics_positions[1]
		if idx >= 0 and idx < 100 and idx < world.politicians.size() \
				and world.politicians[idx] != null and world.politicians[idx].name_display != "":
			return "军委主席" + world.politicians[idx].name_display
	return "其他"


## 原版 politics_dolshnost[2]（外交部长槽）：<100 用槽内政治家，否则用领袖。
func _foreign_minister_phrase(world: WorldState) -> String:
	if world != null and world.politics_positions.size() > 2:
		var idx := world.politics_positions[2]
		if idx >= 0 and idx < 100 and idx < world.politicians.size() \
				and world.politicians[idx] != null and world.politicians[idx].name_display != "":
			return "我国外交部长" + world.politicians[idx].name_display + "同志"
	return _leader_name(world) + "同志"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_685_salt_newcomer.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_685",
	"nodesc": true,
	"num": 685,
	"priority": 68500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_685_salt_newcomer.gd",
	"trigger_script": "res://数据脚本/事件效果/event_685_salt_newcomer.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
