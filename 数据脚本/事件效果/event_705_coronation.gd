extends "res://数据脚本/event_script_base.gd"

## 原作 Event705.cs：冠礼（海地杜瓦利埃称帝，单选项）。
## 触发：DiploButtonScript.cs:10828（type70, c139 且 SubGosstroy!=19）→ 外交互动_批2.gd 已接通。
## 差异：name→chinese_name、soc_stab→social_stability、JoinAllOurAlliances→_join_alliances；
##   load_scene_after_click+number_event=7 → EventEngine.enqueue_chain(["diplomatic_crisis_usa"])。

const TXT_R0 := "event.script.event_705_coronation.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	context["result_text"] = tr(TXT_R0)
	var haiti := ws.get_country_by_legacy_index(139)
	if haiti != null:
		_leave_alliances(haiti)
		haiti.chinese_name = "海地人民帝国"
		haiti.government = GameConstants.Government.AUTHORITARIAN
		haiti.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
		haiti.set_tag("亲中", true)
		haiti.set_tag("对华贸易", true)
		_join_alliances(haiti)
		haiti.social_stability = 1000
	ws.influence_prc += 100
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.empires[EmpireData.USA].relations = 0
	_add_relation(EmpireData.USSR, -300)
	EventEngine.enqueue_chain(["diplomatic_crisis_usa"])



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_705_coronation.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_705",
	"num": 705,
	"priority": 70500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_705_coronation.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
