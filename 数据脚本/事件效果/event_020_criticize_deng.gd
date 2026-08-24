extends "res://数据脚本/event_script_base.gd"

## 原作 Event20.cs：批邓反击右倾翻案风。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10175（event_done[19] && !event_done[20] && 日期>=1976.2）。
##    ref_event_id 用端口 event_id "five_no"（event_019）。
##  - data.democracy_movement++（result 2）：官方版 DLL 反编译证实为 ref 真实写入
##    （tmp_Event20.cs case 2，data[88] 自增），旧转储 ptr 模式系反编译伪影，已恢复。
##  - politics[12]（固定索引政治家）：端口 ws.politicians[12] 直访（判空）。
##  - 忠诚循环：原版独立 if/else-if 链（==0 → +X；非0 且 ==20 → +Y；非0 且非20 且 ==2 → -Z），逐字保留。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_opt_do_nothing(context)
		1:
			_opt_join(context)
		2:
			_opt_support(context)


# 选项0：什么也别做（Event20.cs result 0）
func _opt_do_nothing(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 20
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 40
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].power -= 100
	context["result_text"] = tr("event.script.event_020_criticize_deng.i0")


# 选项1：加入对小平的迫害（Event20.cs result 1）
func _opt_join(context: Dictionary) -> void:
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support += 80
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 20
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 30
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty += 50
		if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
			p.loyalty += 30
		elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
			p.loyalty -= 100
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].power -= 130
	context["result_text"] = tr("event.script.event_020_criticize_deng.i1")


# 选项2：支持小平（Event20.cs result 2）
func _opt_support(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support += 20
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support -= 70
	# 官方版 DLL 反编译（tmp_Event20.cs case 2）证实 data[88]++ 为 ref 真实写入。
	if d.size() > 88:
		d.democracy_movement += 1
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 50
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].loyalty += 200
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty -= 100
		elif p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL:
			p.loyalty += 50
		elif p.trait_personality > GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty += 100
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].power -= 80
		ws.politicians[12].loyalty += 250
	context["result_text"] = tr("event.script.event_020_criticize_deng.i2")



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_020_criticize_deng.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "criticize_deng",
	"num": 20,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "five_no"}, {"t": "DATE_AFTER", "key": "1976.2"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
