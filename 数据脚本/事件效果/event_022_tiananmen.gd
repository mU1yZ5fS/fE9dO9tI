extends "res://数据脚本/event_script_base.gd"

## 原作 Event22.cs：天安门事件（三选项，选项1/2 按 data[88] 动态显隐）。
## 触发：TimeScript.cs:10187 —— (日>=5 且 月>=4 且 年>=1976) || (月>=5 且 年>=1976) || 年>=1977，
##   端口为 DATE_AFTER "1976.4.5"。
## 差异：
##  - 原版按钮 1/2 在 data[88] 不满足时 Destroy(button) 并替换为“人民不想离去！”，
##    端口为 prepare 动态 _disable（enable_condition=RESOURCE_AT_LEAST party_system 99999）。
##  - data[88] 无端口命名键，raw index + 注释。
##  - politics[12].power / loyality：端口 ws.politicians[12]（判空）。

const TXT_OPT0 := "在军警帮助下驱散骚乱"
const TXT_OPT1 := "呼吁所有人离开并驱散其他人"
const TXT_OPT1_DIS := "人民不想离去！"
const TXT_OPT2 := "呼吁所有人离开，拉封锁线直到他们走人"
const TXT_OPT2_DIS := "人民不想离去！"

const TXT_R0 := "晚上，所属北京公安和驻军的单位被部署到了广场，并与抗议人群发生了冲突。由于抗议规模的庞大，许多士兵和警察以及更多的抗议者受伤，一些抗议者丧生。最终，军队成功驱逐了抗议者，超过2000人被逮捕。如此大规模的镇压令人民和国际社会感到失望，但最艰难的时刻似乎已经过去了。在天安门广场所发生的事情被官方定性为一场反革命暴动，邓小平对此应负主要责任。在毛泽东的指示下，政治局撤销了邓小平党内外一切职务，留党察看。此刻，邓小平正在广州，被他的老战友，广州军区司令员许世友所保护。"

const TXT_R1 := "晚上六点半，吴德通过扩音器呼吁人群离开广场，许多人照做了，但还是一千人左右留下。晚上，市警察分队和北京驻防部队进入广场，执行驱散示威人群的任务。尽管使用了暴力手段，但是没有人员死亡，有大约700人被捕。在接下来的几天里，天安门广场继续处于军队和警察的控制之下。看来我们设法用比较不血腥暴力的方法压制住了运动。天安门事件被官方宣布为反革命事件，邓小平对此应负主要责任。在毛泽东的建议下，中共中央政治局免去了邓小平的所有职务，但仍保留他的中共党员资格。邓小平本人此时在广州老战友、广州军区司令员许世友的保护下。"

const TXT_R2 := "晚上六点半，吴德通过扩音器呼吁人群离开广场，许多人照做了，但还是一千人左右留下。晚上，市警察分队和北京驻防部队进入广场，对示威者进行了封锁。在一夜的封锁后，虽然一些示威者离开了，但还有一些人试图突破封锁，他们最终被逮捕了。而那些留下来的人，警察也没有任何异议地将他们逮捕了。抗议活动被以最低限度的武力镇压了。天安门事件被官方宣布为反革命事件，邓小平对此应负主要责任。在毛泽东的建议下，中共中央政治局免去了邓小平的所有职务，但仍保留他的中共党员资格。邓小平本人此时在广州老战友、广州军区司令员许世友的保护下。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var d88 := 0
	if data.size() > 88:
		d88 = data[88]   # 原 data[88]（无端口命名键）
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	if d88 >= 0:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if d88 >= 2:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


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
		d[W.I_PEOPLE_SUPPORT] -= 250
	if d.size() > W.I_THOUGHT_FREEDOM:
		d[W.I_THOUGHT_FREEDOM] -= 200
	if d.size() > W.I_DIPLO:
		d[W.I_DIPLO] += 60
	if d.size() > W.I_PARTY_SUPPORT:
		d[W.I_PARTY_SUPPORT] += 100
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == 0:
			p.loyalty -= 100
		elif p.trait_personality > 0:
			p.loyalty -= 80
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].power -= 100
	context["result_text"] = TXT_R0


# 选项1：呼吁所有人离开并驱散其他人（Event22.cs result 1）
func _opt_disperse(context: Dictionary) -> void:
	if d.size() > W.I_PARTY_SUPPORT:
		d[W.I_PARTY_SUPPORT] += 50
	if d.size() > W.I_PEOPLE_SUPPORT:
		d[W.I_PEOPLE_SUPPORT] -= 50
	if d.size() > W.I_THOUGHT_FREEDOM:
		d[W.I_THOUGHT_FREEDOM] -= 150
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == 0:
			p.loyalty -= 50
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].power += 100
	context["result_text"] = TXT_R1


# 选项2：呼吁所有人离开，拉封锁线直到他们走人（Event22.cs result 2）
func _opt_cordon(context: Dictionary) -> void:
	if d.size() > W.I_THOUGHT_FREEDOM:
		d[W.I_THOUGHT_FREEDOM] -= 100
	if d.size() > W.I_PARTY_SUPPORT:
		d[W.I_PARTY_SUPPORT] -= 50
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == 0:
			p.loyalty += 100
		if p.trait_personality == 20:
			p.loyalty += 80
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].power -= 100
	context["result_text"] = TXT_R2



