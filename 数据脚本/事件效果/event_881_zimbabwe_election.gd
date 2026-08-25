extends "res://数据脚本/event_script_base.gd"

## 原作 Event881.cs：罗得西亚永不灭亡？（津巴布韦1980大选，单选项四结果分支）。 ## 触发：TimeScript.cs:10731-10737 —— ##   ((日>=18 且 月>=4 且 年>=1980) (月>=5 且 年>=1980) 年>=1981)。 ## 差异： ##  - 非洲国家集合计数逐项移植；resultOf[609] 用 completed_event_ids（缺省-1）； ##    resultOf[88]==0 → num3=114514 大数分支保留。 ##  - load_scene_after_click → 882 链：Godot 用 EventEngine.enqueue_chain(["event_882"]) ##    （882 尚移植说明时入队后自动跳过，链式语义保留）。 ##  - <color> 标签去除。

const TXT_UANC := "event.script.event_881_zimbabwe_election.c0"

const TXT_ZAPU := "event.script.event_881_zimbabwe_election.c1"

const TXT_ZANUPF := "event.script.event_881_zimbabwe_election.c2"

const TXT_MODERATE := "event.script.event_881_zimbabwe_election.c3"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var num := 0
	var num2 := 0
	for c in ws.countries:
		if c == null:
			continue
		var i := c.原版序号
		var in_set := (i >= 52 and i <= 68) or (i >= 106 and i <= 108) \
			or (i >= 112 and i <= 133) or i == 13 or i == 18 or i == 40 \
			or i == 41 or i == 42 or i == 99 or i == 100
		if not in_set or i == 128:
			continue
		if c.has_tag("亲苏"):
			num2 += 1
		if c.government == GameConstants.Government.LIBERAL:
			num += 1
	if ws.completed_event_ids.get("event_609", -1) == 1:
		num2 += 1
	var num3 := 0
	if ws.completed_event_ids.get("event_088", -1) == 0:
		num3 = 114514
	var zimbabwe := ws.get_country_by_legacy_index(127)
	var mozambique := ws.get_country_by_legacy_index(126)
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	if ws.completed_event_ids.get("event_088", -1) == 1 or (num >= 6 and num > num2 and num > num3):
		if zimbabwe != null:
			zimbabwe.name = "津巴布韦共和国"
			zimbabwe.chinese_name = "津巴布韦共和国"
			zimbabwe.government = GameConstants.Government.LIBERAL
			zimbabwe.sub_government = GameConstants.SubGovernment.MODERATE
		if mozambique != null:
			mozambique.level_of_instability -= 50
		context["result_text"] = tr(TXT_UANC)
	elif num2 >= 6 and num2 > num3 and num2 > num:
		if zimbabwe != null:
			zimbabwe.name = "津巴布韦人民共和国"
			zimbabwe.chinese_name = "津巴布韦人民共和国"
			zimbabwe.government = GameConstants.Government.REFORMIST
			zimbabwe.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			zimbabwe.set_tag("亲苏", true)
		if mozambique != null:
			mozambique.level_of_instability += 30
		context["result_text"] = tr(TXT_ZAPU)
	elif num3 != 0:
		if zimbabwe != null:
			zimbabwe.name = "津巴布韦民主人民共和国"
			zimbabwe.chinese_name = "津巴布韦民主人民共和国"
			zimbabwe.government = GameConstants.Government.SOCIALIST
			zimbabwe.sub_government = GameConstants.SubGovernment.MAOIST
			zimbabwe.set_tag("亲中", true)
			zimbabwe.set_tag("对华贸易", true)
			_join_our_alliances(zimbabwe)
			zimbabwe.social_stability = 1000
		if mozambique != null:
			mozambique.level_of_instability += 50
		context["result_text"] = tr(TXT_ZANUPF)
	else:
		if zimbabwe != null:
			zimbabwe.government = GameConstants.Government.REFORMIST
			zimbabwe.sub_government = GameConstants.SubGovernment.PRAGMATIST
			zimbabwe.set_tag("亲中", true)
			zimbabwe.set_tag("对华贸易", true)
			zimbabwe.name = "津巴布韦共和国"
			zimbabwe.chinese_name = "津巴布韦共和国"
		if mozambique != null:
			mozambique.level_of_instability += 30
		context["result_text"] = tr(TXT_MODERATE)
	# 原版 load_scene_after_click → number_event=882：链式触发
	if zimbabwe != null and zimbabwe.sub_government != GameConstants.SubGovernment.MODERATE:
		var c131 := ws.get_country_by_legacy_index(131)
		if c131 != null and c131.sub_government == GameConstants.SubGovernment.NEO_FASCIST \
				and not (ws.wars.size() > 54 and ws.wars[54] != null and ws.wars[54].is_going):
			EventEngine.enqueue_chain(["event_882"])


## Country.cs:42-86 JoinAllOurAlliances 核心联盟跟随逻辑。
func _join_our_alliances(c: CountryData) -> void:
	var player := ws.get_country_by_legacy_index(1)
	if player == null:
		return
	if player.has_tag("okb"):
		c.set_tag("okb", true)
	elif player.has_tag("ovd"):
		c.set_tag("ovd", true)
	elif player.has_tag("seato"):
		c.set_tag("seato", true)
	if player.has_tag("econ"):
		c.set_tag("econ", true)
	elif player.has_tag("sev"):
		c.set_tag("sev", true)
	elif player.has_tag("asean"):
		c.set_tag("asean", true)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_881_zimbabwe_election.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_881",
	"num": 881,
	"priority": 8810,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1980.4.18"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
