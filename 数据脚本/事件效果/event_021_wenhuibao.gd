extends "res://数据脚本/event_script_base.gd"

## 原作 Event21.cs：周恩来的再放送（文汇报“影射”周恩来，三选项）。
## 触发：TimeScript.cs:10180 —— (日>=25 且 月>=3 且 年>=1976) || (月>=4 且 年>=1976) || 年>=1977，
##   端口为 DATE_AFTER "1976.3.25"。
## 差异：
##  - result 2 的 data.democracy_movement = data.democracy_movement - 1：反编译为死代码（ptr 局部赋值未写回），跳过；
##  - result 1 的 data.democracy_movement += 2 为真实效果（保留，raw index + 注释）；
##  - politics[12].loyality += 200：端口 ws.politicians[12].loyalty（判空）。

const TXT_R0 := "这篇文章被认为是对死者的侮辱，也是一场极左分子的压制意识形态运动的开始，在长江流域的一些城市引发了抗议。南京爆发了大规模的抗议活动。尽管我们试图封锁有关抗议的信息，抗议的消息似乎已经传到北京，那里的人们也开始上街抗议。"

const TXT_R1 := "你致电了《文汇报》后台张春桥，委婉地暗示文章可能会被认为“影射”一位故人而引起误会，而他很快就意识到文章的问题，于是紧急要求撤回材料并停止继续出版，但一些地区如南京已经出现了抨击《文汇报》文章的大字报（我们尚且不知道他们是怎么这么快获得最新的《文汇报》的）。但总的来说，因为及时撤回并发布了修改版的文章，这件事并未在全国引起多么大的轰动，一切都在掌握之中，张春桥等人也对你表示了感谢。"

const TXT_R2 := "你总结了这些文件的主旨并开始把它们在上海以外的媒体出版，这当然是党所喜欢的，但不是人民。这篇文章被认为是对死者的侮辱，也是一场极左分子压制意识形态运动的开始，在长江流域的一些城市引发了抗议。南京爆发了大规模的抗议活动。但由于你的“努力”，抗议已经发展到了中国的其他部分，包括北京。幸运的是，局势仍在掌控之中。"


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
	context["result_text"] = TXT_R0


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
	context["result_text"] = TXT_R1


# 选项2：支持这篇文章的论点并在媒体上大肆宣扬（Event21.cs result 2）
func _opt_support(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 80
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 70
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support += 50
	# 原版此处的 data.democracy_movement = data.democracy_movement - 1 只写局部 ptr，未写回数组，属死代码，跳过。
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality > GameConstants.PoliticianPersonality.FAR_LEFT and p.trait_personality < GameConstants.PoliticianPersonality.LIBERAL:
			p.loyalty -= 70
	context["result_text"] = TXT_R2
