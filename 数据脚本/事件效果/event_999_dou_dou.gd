extends "res://数据脚本/event_script_base.gd"

## 原作 Event999.cs：豆豆不能随便投……（民主回卷终局事件）
## 触发：TimeScript.cs:10020-10024 —— data.event999_trigger_sentinel == 999（哨兵值，结果里清零）。
## 差异记录：
##  - 原版 result 3/4/5 为不可达“测试”分支（kolvo_variant=2），按死代码跳过。
##  - party_change[] 仅 UI 摆动数值，Godot 建模说明，跳过（与 event_020 同类约定）。
##  - show_notification=false：沿用现存 101 个事件的统一约定（原版地图标记机制未启用）。
##  - <color> 标签去除：事件 UI Label 未开 bbcode，颜色不渲染，文本逐字保留。
##  - 原版字符间空格排版在 Godot 不再保留（既有约定，下同）。

const TXT_RESULT := "event.script.event_999_dou_dou.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# Event999.cs result 0
			_add(W.I_THOUGHT_FREEDOM, 200)
			_add(W.I_PARTY_SUPPORT, -150)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_CORRUPTION, 100)
		1:
			# Event999.cs result 1
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -50)
			_add(W.I_PEOPLE_SUPPORT, -30)
			_add(W.I_CORRUPTION, 150)
		_:
			return
	# 两个结果共同的体制收束（Event999.cs result 0/1 完全一致，原版重复书写）
	_apply_one_party_reset()
	context["result_text"] = tr(TXT_RESULT)




## Event999.cs：is_party_enabled / is_party_ally / party_number / party_ideology 批量重写。
## Godot：ws.factions[i] 对应原版 party 槽（faction_data.gd 头注：support=party_number、
## ideology=party_ideology、is_enabled=is_party_enabled、is_ally=is_party_ally）。
func _apply_one_party_reset() -> void:
	if ws.factions.size() < 5:
		return
	ws.factions[0].is_enabled = false
	for i in range(1, 5):
		ws.factions[i].is_enabled = true
	ws.factions[0].is_ally = false
	for i in range(2, 5):
		ws.factions[i].is_ally = false
	# 原版：4号=400、3号=500、1号=50、2号=50、0号=0
	ws.factions[4].support = 400
	ws.factions[4].ideology = 400
	ws.factions[3].support = 500
	ws.factions[3].ideology = 500
	ws.factions[1].support = 50
	ws.factions[1].ideology = 50
	ws.factions[2].support = 50
	ws.factions[2].ideology = 50
	ws.factions[0].support = 0
	ws.factions[0].ideology = 0
	# Event999.cs：data.econ_display == 37 时的分支覆盖
	if d.size() > W.I_ECON_DISPLAY and d.econ_display == 37:
		ws.factions[4].support = 700
		ws.factions[4].ideology = 700
		ws.factions[3].support = 200
		ws.factions[3].ideology = 200
		ws.factions[1].support = 50
		ws.factions[1].ideology = 50
		ws.factions[2].support = 50
		ws.factions[2].ideology = 50
		ws.factions[0].support = 0
		ws.factions[0].ideology = 0
	# Event999.cs：data.event999_trigger_sentinel = 0（触发哨兵清零）
	if d.size() > 170:
		d.event999_trigger_sentinel = 0



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_999_dou_dou.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_999",
	"num": 999,
	"priority": 9990,
	"notify": false,
	"trigger": [{"t": "RESOURCE_EQUALS", "key": "data_170", "v": 999}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
