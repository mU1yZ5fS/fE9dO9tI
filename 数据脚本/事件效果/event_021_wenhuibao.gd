extends "res://数据脚本/event_script_base.gd"

## 原作 Event21.cs：周恩来的再放送（文汇报“影射”周恩来，三选项）。 ## 触发：TimeScript.cs:10180 —— (日>=25 且 月>=3 且 年>=1976) (月>=4 且 年>=1976) 年>=1977， ##   端口为 DATE_AFTER "1976.3.25"。 ## 差异： ##  - result 2 的 data.democracy_movement = data.democracy_movement - 1：官方版 DLL ##    反编译证实为 ref 真实写入，旧转储 ptr 模式系反编译伪影，已恢复； ##  - result 1 的 data.democracy_movement += 2 为真实效果（保留，raw index + 注释）； ##  - politics[12].loyality += 200：端口 ws.politicians[12].loyalty（判空）。

const TXT_R0 := "event.script.event_021_wenhuibao.c0"

const TXT_R1 := "event.script.event_021_wenhuibao.c1"

const TXT_R2 := "event.script.event_021_wenhuibao.c2"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_opt_do_nothing(context)
		1:
			_opt_contact(context)
		2:
			_opt_support(context)


# 选项0：什么都不做（Event21.cs result 0）
func _opt_do_nothing(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 50
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 50
	context["result_text"] = tr(TXT_R0)


# 选项1：和四人帮联系，说明“影射”的问题（Event21.cs result 1）
func _opt_contact(context: Dictionary) -> void:
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support -= 50
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 30
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 30
	if d.size() > 88:
		d.democracy_movement += 2   # 原 data.democracy_movement（无端口命名键）
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].loyalty += 200   # 原 politics[12].loyality += 200
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty += 50
		elif (p.trait_personality > GameConstants.PoliticianPersonality.FAR_LEFT and p.trait_personality < GameConstants.PoliticianPersonality.REFORMIST) or p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
			p.loyalty += 50
	context["result_text"] = tr(TXT_R1)


# 选项2：支持这篇文章的论点并在媒体上大肆宣扬（Event21.cs result 2）
func _opt_support(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 80
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 70
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support += 50
	# 官方版 DLL 反编译（tmp_Event21.cs:59-63）证实 data[88]-=1 为 ref 真实写入， # 旧转储 ptr 模式系反编译伪影，v0.3.3 误判死代码，已恢复。
	if d.size() > 88:
		d.democracy_movement -= 1
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality > GameConstants.PoliticianPersonality.FAR_LEFT and p.trait_personality < GameConstants.PoliticianPersonality.LIBERAL:
			p.loyalty -= 70
	context["result_text"] = tr(TXT_R2)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_021_wenhuibao_article.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_021",
	"num": 21,
	"priority": 2100,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1976.3.25"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
