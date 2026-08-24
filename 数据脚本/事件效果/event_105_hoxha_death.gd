extends "res://数据脚本/event_script_base.gd"

## 原作 Event105.cs：阿尔巴尼亚的斯大林的终结（霍查逝世，三选项）。 ## 触发：TimeScript.cs:10871-10877 —— ##   ((日>=13 且 月>=4 且 年>=1985) 年>=1986) && data.albania_break==0 ##   && c20.SubGosstroy!=11 && (!c20.isRIM c1.isRIM)。 ## 差异：描述按 event_done[77] 双分支（prepare）；c20.parts[0]/spec 映射。

const TXT_R0 := "event.script.event_105_hoxha_death.c0"

const TXT_R1_A := "event.script.event_105_hoxha_death.c1"

const TXT_R1_B := "event.script.event_105_hoxha_death.c2"

const TXT_R1_C := "event.script.event_105_hoxha_death.c3"

const TXT_R1_EXTRA := "event.script.event_105_hoxha_death.c4"

const TXT_R2 := "event.script.event_105_hoxha_death.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var done77: bool = world.completed_event_ids.has("event_077")
	if done77:
		event_def.description = "来自阿尔巴尼亚的有趣消息：4月11日，阿尔巴尼亚的终身领导人恩维尔·霍查逝世，享年76岁。在这个国家为自己的损失感到悲痛的同时，拉米兹·阿利雅接任了阿尔巴尼亚劳动党中央委员会第一书记的职位，长期以来，他被认为是霍查的继任者，在击败穆罕默德·谢胡的集团中发挥了重要作用。阿利雅欣赏霍查并无条件支持其政策的所有转变，但是，据一些报道，他并不反对与西方和南斯拉夫建立关系，也不反对在国内政治上做出一些让步。一方面，这会影响到我们，另一方面，也不知道它会如何结束。因此，我们可以组织对新统治者的恐怖袭击，当然，如果我们在附近有特工的话。"
	else:
		event_def.description = "新华社1985年4月11日地拉那电：阿尔巴尼亚的终身领导人恩维尔·霍查逝世，享年76岁。在这个国家为自己的损失感到悲痛的同时，拉米兹·阿利雅接任了阿尔巴尼亚劳动党中央委员会第一书记的职位，长期以来，他被认为是霍查的继任者，在PPSh（阿尔巴尼亚劳动党）的早起历程和游击战中立下了汗马功劳。阿利雅欣赏霍查并无条件支持其政策的所有转变，但是，据一些报道，他并不反对与西方和东方集团建立关系，也不反对在国内政治上做出一些让步。一方面，阿尔巴尼亚可能会寻求其他国家的援助而抛弃我们。另一方面，我们也不知道会不会真的这么做。因此，我们可以打打这个不听话小孩的屁股，当然，如果我们在附近有特工的话。"
	var albania := world.get_country_by_legacy_index(20)
	var yugo := world.get_country_by_legacy_index(15)
	var agents := world.agents if world.size() > W.I_AGENTS else 0
	var opt := event_def.options
	_enable(opt[0], "什么都不做")
	if ((yugo != null and yugo.has_tag("对华贸易")) or (albania != null and albania.has_tag("对华贸易"))) and agents >= 60:
		_enable(opt[1], "招募一群科索沃阿尔巴尼亚人并发动一次恐怖袭击（-6特工网络）")
	else:
		_disable(opt[1], "我们的情报机构对此无能为力")
	if albania != null and not albania.has_tag("对华贸易") and not albania.has_tag("亲中"):
		_enable(opt[2], "尝试与新的管理层建立关系（需要3百万预算）")
	else:
		_disable(opt[2], "中阿关系平稳如常")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var albania := ws.get_country_by_legacy_index(20)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if d.size() > W.I_ALBANIA_BREAK:
				d.albania_break = 2
			if albania != null:
				albania.government = GameConstants.Government.SOCIALIST
				albania.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -60)
			ws.influence_prc += 5
			if d.size() > W.I_ALBANIA_BREAK:
				d.albania_break = 3
			var text := ""
			if albania != null and albania.parts.size() > 0 and albania.parts[0]:
				text = tr(TXT_R1_A)
				albania.government = GameConstants.Government.AUTHORITARIAN
				albania.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			elif albania != null and albania.government == GameConstants.Government.SOCIALIST:
				text = tr(TXT_R1_B)
				albania.government = GameConstants.Government.AUTHORITARIAN
				albania.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				if albania.special == 1:
					text += tr(TXT_R1_EXTRA)
					albania.set_tag("balecon", true)
			elif albania != null and albania.government == GameConstants.Government.AUTHORITARIAN:
				text = tr(TXT_R1_C)
				albania.government = GameConstants.Government.AUTHORITARIAN
				albania.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				if albania.special == 1:
					text += tr(TXT_R1_EXTRA)
					albania.set_tag("balecon", true)
			context["result_text"] = text
		2:
			ws.influence_prc += 15
			if albania != null:
				albania.set_tag("对华贸易", true)
				albania.government = GameConstants.Government.SOCIALIST
				albania.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			if d.size() > W.I_ALBANIA_BREAK:
				d.albania_break = 2
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_BUDGET, -30)
			_add_relation(EmpireData.USSR, -50)
			_add_relation(EmpireData.USA, -80)
			context["result_text"] = tr(TXT_R2)






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_105_hoxha_death.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_105",
	"num": 105,
	"priority": 10500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_105_hoxha_death.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1985.4.13"}, {"t": "RESOURCE_EQUALS", "key": "albania_break"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "v": 11, "target": "20"}, {"t": "NOT", "c": [{"t": "ALL", "c": [{"t": "COUNTRY_HAS_TAG", "key": "rim", "target": "20"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "rim", "target": "1"}]}]}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
