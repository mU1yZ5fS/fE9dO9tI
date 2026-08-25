extends "res://数据脚本/event_script_base.gd"

## 原作 Event585.cs：法兰西殖民主义的终结（吉布提独立，三选项）。 ## 触发：ReqEventForDLC02.cs:829-832 —— (日>=8 且 月>=5 且 年>=1977) (月>=6 且 年>=1977) 年>=1978 ##   → DATE_AFTER 1977.5.8。 ## 差异： ##  - 选项显隐 prepare 动态改写；name → chinese_name；Torg → 对华贸易； ##  - proprc → 亲中；names1+names2 → _leader_name()； ##  - resultOfEvents 缺省按原版 int 默认 0 处理。



const TXT_OPT1_DIS := "event.script.event_585_french_colonialism_end.c0"
const TXT_OPT2_DIS := "event.script.event_585_french_colonialism_end.c1"

const TXT_R0 := "event.script.event_585_french_colonialism_end.c2"
const TXT_R1_A := "event.script.event_585_french_colonialism_end.c3"
const TXT_R1_B := "event.script.event_585_french_colonialism_end.c4"
const TXT_R2_A := "event.script.event_585_french_colonialism_end.c5"
const TXT_R2_MENGISTU := "event.script.french_colonialism_end.txt_r2_mengistu"
const TXT_R2_BENTI := "event.script.french_colonialism_end.txt_r2_benti"
const TXT_R2_B := "event.script.event_585_french_colonialism_end.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if line <= 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	var ussr_rel := world.empires[EmpireData.USSR].relations if world.empires.size() > EmpireData.USSR \
			and world.empires[EmpireData.USSR] != null else 0
	if ussr_rel <= 700:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c106 := ws.get_country_by_legacy_index(106)
	var c41 := ws.get_country_by_legacy_index(41)
	if c106 != null:
		c106.government = GameConstants.Government.REFORMIST
		c106.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
		c106.chinese_name = "吉布提共和国"
		_leave_alliances(c106)
	# 地图归属必须无条件执行：即使旧存档缺 106 号国，领土也要从法国 220 转给吉布提 522。
	if GameManager != null:
		game.set_map_region_owner([366, 367, 368, 370, 376, 2032], 522)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			var text := tr(TXT_R1_A) + _leader_name() + tr(TXT_R1_B)
			_add(W.I_BUDGET, -20)
			_add(W.I_AGENTS, -20)
			if c106 != null:
				c106.government = GameConstants.Government.SOCIALIST
				c106.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c106)
				c106.set_tag("对华贸易", true)
				c106.set_tag("亲中", true)
				c106.social_stability = 1000
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 10
			_add(W.I_DIPLO, 5)
			context["result_text"] = text
		2:
			var leader := tr(TXT_R2_MENGISTU) if c41 != null and c41.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST else tr(TXT_R2_BENTI)
			var text := tr(TXT_R2_A) + leader + tr(TXT_R2_B)
			if c41 != null:
				c41.set_tag("对华贸易", true)
			context["result_text"] = text


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_585_french_colonialism_end.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_585",
	"num": 585,
	"priority": 58500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_585_french_colonialism_end.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1977.5.8"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
