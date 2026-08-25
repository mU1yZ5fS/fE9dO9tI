extends "res://数据脚本/event_script_base.gd"

## 原作 Event19.cs：五"不准"。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10169（日期>=1976.2 且 !event_done[19]）。
##  - 原版按钮 0-3 对应 number_otvet 1-4（按钮号+1），端口选项索引 0-3 直接对应。
##  - opt0 的 data.democracy_movement++ / opt2 的 data.democracy_movement--：官方版 DLL
##    反编译证实为 ref 真实写入（tmp_Event19.cs otvet==1 与 ==3），旧转储 ptr 模式系
##    反编译伪影，已恢复；opt3 的 data.democracy_movement += 2 为真实效果（保留）。
##  - data.democracy_movement（无端口命名键）：数字索引直访。
##  - politics[12].loyality += 200：端口 ws.politicians[12] 直访（判空）。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_opt_pass(context)
		1:
			_opt_enforce(context)
		2:
			_opt_criticize(context)
		3:
			_opt_sabotage(context)


# 选项0：让它通过，我们静观其变（Event19.cs number_otvet==1）
func _opt_pass(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 50
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 50
	# 官方版 DLL 反编译（tmp_Event19.cs otvet==1）证实 data[88]++ 为 ref 真实写入。
	if d.size() > 88:
		d.democracy_movement += 1
	context["result_text"] = tr("event.script.event_019_five_no.i0")


# 选项1：严格执行这场运动（Event19.cs number_otvet==2）
func _opt_enforce(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 70
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 50
	if d.size() > W.I_DIPLO:
		d.diplomatic_reputation += 10
	_add_loyalty_by_trait(0, 70)
	context["result_text"] = tr("event.script.event_019_five_no.i1")


# 选项2：严格执行这场运动，并在媒体上批评这种行为（Event19.cs number_otvet==3）
func _opt_criticize(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 100
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 70
	if d.size() > W.I_DIPLO:
		d.diplomatic_reputation += 10
	# 官方版 DLL 反编译（tmp_Event19.cs otvet==3）证实 data[88]-- 为 ref 真实写入。
	if d.size() > 88:
		d.democracy_movement -= 1
	_add_loyalty_by_trait(0, 100)
	context["result_text"] = tr("event.script.event_019_five_no.i2")


# 选项3：轻微地破坏这场运动（Event19.cs number_otvet==4）
func _opt_sabotage(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 10
	if d.size() > 88:
		d.democracy_movement += 2   # 原 data.democracy_movement（无端口命名键）
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support -= 50
	if d.size() > W.I_DIPLO:
		d.diplomatic_reputation -= 10
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].loyalty += 200   # 原 politics[12].loyality += 200
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty -= 70
		elif p.trait_personality >= GameConstants.PoliticianPersonality.MODERATE or p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
			p.loyalty += 50
	context["result_text"] = tr("event.script.event_019_five_no.i3")


## 指定 traits[0]（性格）的政治家忠诚变化
## 注：参数名不用 trait（Godot 4.3+ 保留字），用 trait_id
func _add_loyalty_by_trait(trait_id: int, delta: int) -> void:
	for p in ws.politicians:
		if p != null and p.trait_personality == trait_id:
			p.loyalty += delta



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_five_no.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "five_no",
	"num": 19,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1976.2"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
