extends "res://数据脚本/event_script_base.gd"

## 原作 Event75.cs：伊拉克核问题（以色列“歌剧”行动，四选项）。 ## 触发：TimeScript.cs:10556-10562 —— ##   (月>=8 且 年>=1981 或 年>=1982) 且 (data.iraq_development_sentinel!=9 c8.Vyshi c8.Gosstroy!=0) ##   且 c14.dev==0 && c14.puppetOf<0 && c14.SubGosstroy==10。 ## 选项显隐（prepare 动态改写，原版 SetActive(false) 等价）： ##   原版 summa_3_2 = 执政联盟支持率（data.party_system>7 才计算），Godot 用 factions 复算。 ## 差异：选项0/2/3 的按钮文案与可用条件逐字保留；result2 的 {0}{1} 插领导人姓名。

const TXT_R0 := "event.script.event_075_iraq_nuclear.c0"

const TXT_R1 := "event.script.event_075_iraq_nuclear.c1"

const TXT_R2 := "event.script.event_075_iraq_nuclear.c2"

const TXT_R3 := "event.script.event_075_iraq_nuclear.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var policy_left := (line < 3 and party < 8) or (coal > 66 and party > 7)
	var policy_right := (line > 2 and party < 8) or (coal > 66 and party > 7)
	var done36: bool = world.completed_event_ids.has("iraqi_coalition")
	var result36: int = world.completed_event_ids.get("iraqi_coalition", -1)
	var opt := event_def.options
	if opt.size() < 4:
		return
	# 选项0
	if policy_left and done36 and result36 != 3:
		_enable(opt[0], "我们将谴责空袭，并与侯赛因扩大合作（需要8百万预算）")
	elif done36 and result36 == 3:
		_disable(opt[0], "他不是我们的朋友")
	else:
		_disable(opt[0], "萨达姆·侯赛因——一个独裁者和沙文主义者。我们不需要支持他！")
	# 选项1：恒定可用 _enable(opt[1], "谁在乎？让萨达姆自己给自己擦屁股…") # 选项2
	var industry: int = data.industry if data.size() > W.I_INDUSTRY else 0
	var stage: int = data.reform_stage if data.size() > W.I_REFORM_STAGE else -1
	if industry >= 600 and stage == 0 and done36 and result36 != 3 and policy_left:
		_enable(opt[2], "我们将帮助伊拉克恢复其核计划。让帝国主义战栗吧！（需要15百万元，10特工）")
	elif done36 and result36 == 3:
		_disable(opt[2], "他不是我们的朋友")
	else:
		_disable(opt[2], "给伊拉克核武器？！你想发动第三次世界大战吗？")
	# 选项3
	if policy_right:
		_enable(opt[3], "我们将称许空袭，并谴责侯赛因的军国主义和沙文主义")
	else:
		_disable(opt[3], "我们不能为犹太复国主义者的所作所为辩护！")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var iraq := ws.get_country_by_legacy_index(14)
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_BUDGET, -80)
			_add(W.I_DIPLO, 10)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			if iraq != null:
				iraq.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R0)
		1:
			_add_power(EmpireData.USA, 10)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_PARTY_SUPPORT, 50)
			_add_power(EmpireData.USSR, -10)
			_add(W.I_DIPLO, 80)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -100)
			if iraq != null:
				iraq.set_tag("亲苏", false)
				iraq.set_tag("对华贸易", true)
				iraq.set_tag("亲中", true)
			context["result_text"] = tr(TXT_R2).replace("{0}{1}", _leader_name())
		3:
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_DIPLO, -40)
			ws.influence_prc -= 20
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add_relation(EmpireData.USSR, -150)
			_add_relation(EmpireData.USA, 50)
			if iraq != null:
				iraq.set_tag("对华贸易", false)
			context["result_text"] = tr(TXT_R3)


## 原版 summa_3_2：data.party_system>7 时，保守派 + 结盟且启用的小党，占总席位百分比。
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




func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_075_iraq_nuclear.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_075",
	"num": 75,
	"priority": 7500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_075_iraq_nuclear.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1981.8.1"}, {"t": "ANY", "c": [{"t": "RESOURCE_NOT_EQUALS", "key": "data_117", "v": 9}, {"t": "COUNTRY_HAS_TAG", "key": "亲美", "target": "8"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "government", "target": "8"}]}, {"t": "COUNTRY_FIELD_EQUALS", "key": "development", "target": "14"}, {"t": "COUNTRY_FIELD_AT_MOST", "key": "puppet_of", "v": -1, "target": "14"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 10, "target": "14"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
