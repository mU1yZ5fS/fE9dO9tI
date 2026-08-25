extends "res://数据脚本/event_script_base.gd"

## 原作 Event22.cs：天安门事件（三选项，选项1/2 按 data.democracy_movement 动态显隐）。 ## 触发：TimeScript.cs:10187 —— (日>=5 且 月>=4 且 年>=1976) (月>=5 且 年>=1976) 年>=1977， ##   端口为 DATE_AFTER "1976.4.5"。 ## 差异： ##  - 原版按钮 1/2 在 data.democracy_movement 不满足时 Destroy(button) 并替换为“人民不想离去！”， ##    端口为 prepare 动态 _disable（enable_condition=RESOURCE_AT_LEAST party_system 99999）。 ##  - data.democracy_movement 无端口命名键，raw index + 注释。 ##  - politics[12].power / loyality：端口 ws.politicians[12]（判空）。

const TXT_OPT0 := "event.script.event_022_tiananmen.c0"
const TXT_OPT1 := "event.script.event_022_tiananmen.c1"
const TXT_OPT1_DIS := "event.script.event_022_tiananmen.c2"
const TXT_OPT2 := "event.script.event_022_tiananmen.c3"
const TXT_OPT2_DIS := "event.script.event_022_tiananmen.c4"

const TXT_R0 := "event.script.event_022_tiananmen.c5"

const TXT_R1 := "event.script.event_022_tiananmen.c6"

const TXT_R2 := "event.script.event_022_tiananmen.c7"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var d88 := 0
	if data.size() > 88:
		d88 = data.democracy_movement   # 原 data.democracy_movement（无端口命名键）
	var opt := event_def.options
	_enable(opt[0], tr(TXT_OPT0))
	if d88 >= 0:
		_enable(opt[1], tr(TXT_OPT1))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if d88 >= 2:
		_enable(opt[2], tr(TXT_OPT2))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_opt_repress(context)
		1:
			_opt_disperse(context)
		2:
			_opt_cordon(context)


# 选项0：在军警帮助下驱散骚乱（Event22.cs result 0）
func _opt_repress(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 250
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom -= 200
	if d.size() > W.I_DIPLO:
		d.diplomatic_reputation += 60
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support += 100
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty -= 100
		elif p.trait_personality > GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty -= 80
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].power -= 100
	context["result_text"] = tr(TXT_R0)


# 选项1：呼吁所有人离开并驱散其他人（Event22.cs result 1）
func _opt_disperse(context: Dictionary) -> void:
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support += 50
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 50
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom -= 150
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty -= 50
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].power += 100
	context["result_text"] = tr(TXT_R1)


# 选项2：呼吁所有人离开，拉封锁线直到他们走人（Event22.cs result 2）
func _opt_cordon(context: Dictionary) -> void:
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom -= 100
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support -= 50
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty += 100
		if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
			p.loyalty += 80
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].power -= 100
	context["result_text"] = tr(TXT_R2)






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_022_tiananmen_incident.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_022",
	"num": 22,
	"priority": 2200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_022_tiananmen.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1976.4.5"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
