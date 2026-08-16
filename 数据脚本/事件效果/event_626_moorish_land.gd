extends "res://数据脚本/event_script_base.gd"

## 原作 Event626.cs：摩尔人的土地（毛里塔尼亚政变，三选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:949-951 ——
##   (1978.7.10 起生效：原 (1978&&m>=7&&d>=10)||(1978&&m>=8)||y>=1979)。
## 差异：原版选项0在 data[56]>=3 时 Destroy(button[0])；Godot 用 _disable 灰显同义。

const TXT_TITLE := "摩尔人的土地"
const TXT_DESC := "自毛里塔尼亚于1960年独立以来，莫克塔尔·乌尔德·达达赫总统一直领导着这个国家。他逐渐建立了由毛里塔尼亚人民党领导的一党制政权，该党奉行大毛里塔尼亚民族主义（主张毛里塔尼亚吞并西撒哈拉和马里北部）和伊斯兰社会主义，并采取反殖民主义与反帝国主义的进步外交，疏远法帝国主义。我国同毛里塔尼亚政府开展了大量合作，现在已经成为该国最重要的援助国之一。1975年毛里塔尼亚在和摩洛哥一起瓜分西撒哈拉地区的战争的失利使得毛里塔尼亚陷入了经济危机，这给达达赫总统和人民党政权的权威带来了沉重打击。\n据了解，陆军参谋长穆斯塔法·乌尔德·萨莱克上校已经在他的周围聚集起来一个阴谋圈子，准备向达达赫总统发起军事政变。我们可以通过阻止政变，来让达达赫有机会继续建设社会主义，并和他继续进行合作，不过，继续援助这个奴隶制仍横行的充满沙漠的贫穷国家真的有必要吗？"
const TXT_OPT0 := "帮助达达赫反政变"
const TXT_OPT0_DIS := "达达赫大势已去……"
const TXT_OPT1 := "放任事态发展并和新政府保持关系"
const TXT_OPT2 := "没必要继续关注那个国家"
const TXT_R0 := "由于我们的提醒，达达赫总统得以在我们特工的帮助下组织起仍忠于他的部队逮捕萨莱克阴谋集团，叛变军官因叛国罪被处决。经过我们的斡旋，达达赫政府承认了阿拉伯撒哈拉民主共和国，放弃了对西撒哈拉的领土要求，并与西撒人阵达成了和平协定，毛里塔尼亚的军队撤出了西撒哈拉领土，这使得毛塔和摩洛哥的关系极度恶化了。在我们的援助下，毛里塔尼亚的局势正在缓慢地走向正常化，经济也逐渐走向恢复，达达赫开始更大力度地推进社会改革，并将支持大毛里塔尼亚主义转向支持泛非团结，以促进国内的阿拉伯-柏柏尔文化的摩尔人和南方黑人之间的关系上的平等化和政治上的团结度。作为交换，毛里塔尼亚人民党仿照人民民主国家和阿拉伯的复兴党国家，将支持毛泽东思想的毛里塔尼亚劳动党和此前反对同人民党合作的独立工会组织“进步工人联盟”等左翼反对派合法化，纳入民族进步阵线，阵线内的组织能够合法参与政府；于此同时，人民党也开始进行党领导军队的建设。"
const TXT_R1 := "经过一场不流血的政变，萨利克成功推翻了达达赫总统，组织起民族复兴军事委员会并自任主席。新的军政府开始转向亲法政策并继续维持和摩洛哥的联盟。由于未能良好处理国内问题，军政府很快陷入内部倾轧中。\n1979年8月，达达赫获准流亡法国。在法国，他开始组织反对派政党……\n这些并不能妨碍两国的合作，我们将继续和毛塔新政府保持合作关系。"
const TXT_R2 := "经过一场不流血的政变，萨利克成功推翻了达达赫总统，组织起民族复兴军事委员会并自任主席。新的军政府开始转向亲法政策并继续维持和摩洛哥的联盟。由于未能良好处理国内问题，军政府很快陷入内部倾轧中。\n1979年8月，达达赫获准流亡法国。在法国，他开始组织反对派政党……"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	# 原版 :21-29：data[56]<3 显示选项0，否则 Destroy 按钮。
	if _res(W.I_POLITICAL_LINE) < 3:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], TXT_OPT1)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(59)  # 毛里塔尼亚
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if c != null:
				c.government = 2
				c.sub_government = 15
				_leave_alliances(c)
				c.set_tag("对华贸易", true)
				c.set_tag("亲中", true)
			ws.influence_prc += 10
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -50)
		1:
			context["result_text"] = TXT_R1
			if c != null:
				c.government = 0
				c.sub_government = 7
				_leave_alliances(c)
				c.puppet_of = 21
				c.set_tag("对华贸易", true)
			_add(W.I_THOUGHT_FREEDOM, -30)
		2:
			context["result_text"] = TXT_R2
			if c != null:
				c.government = 0
				c.sub_government = 7
				_leave_alliances(c)
				c.puppet_of = 21
