extends "res://数据脚本/event_script_base.gd"

## 原作 Event3.cs：舵手逝世三选项。
## 公共效果（三选项均执行）：稳定=100(SET)、覆写 politicians[0]→华国锋、politics_positions[1]=150。
## 分支：opt0/1/2 各自的资源增减 + politicians[1..4] 忠诚循环 + 动态文案。
## 因「覆写政治家」「仅 [1..4] 忠诚」不可声明式 → 全部走自定义脚本（含公共 stability，避免与 .tres 双写）。
## 差异：traits[2]=32 越界特殊特质逐字保留（成就 Set(222) 已接 Achievements，铁人门在模块内）。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))

	# 公共效果（Event3.cs:26-37，三选项均执行；原作 Set(222) 在稳定性覆写之前）
	Achievements.set_achievement(222)  # 原作 Event3.cs:26-29 iron_and_blood → achievements.Set(222)
	d[W.I_STABILITY] = 100
	_install_hua_guofeng()

	if opt == 0:
		d[W.I_THOUGHT_FREEDOM] -= 50
		d[W.I_PEOPLE_SUPPORT] += 20
		_add_loyalty_1_to_4(200)
		context["result_text"] = "在毛主席的死讯公布后，他的遗体在人民大会堂留置一周，以便全国人民向主席道别，追悼会在全国范围内举行。无数中国人来到这里向伟大领袖与导师致以最后的敬意。毛主席的遗体根据他的遗愿被火化，遗骨在三分钟的肃立哀悼和华国锋同志的告别演说后被封入了天安门广场上一座特别建造的纪念碑里。"
	elif opt == 1:
		d[W.I_THOUGHT_FREEDOM] -= 70
		d[W.I_PEOPLE_SUPPORT] += 50
		d[W.I_PARTY_SUPPORT] += 40
		d[W.I_BUDGET] -= 10
		_add_loyalty_1_to_4(-300)
		d[W.I_MAO_MAUSOLEUM] = 10
		context["result_text"] = "在毛主席的死讯公布后，他的遗体在人民大会堂留置一周，以便全国人民向主席道别，追悼会在全国范围内举行。无数中国人来到这里向伟大领袖与导师致以最后的敬意。在时限后，遗体被送往医院，进行特别防腐处理。在三分钟的肃立默哀与华国锋的告别演说后，毛主席正式安息在了天安门前，由治丧委员会特别要求建设的纪念堂里。"
	elif opt == 2:
		d[W.I_THOUGHT_FREEDOM] -= 70
		d[W.I_PEOPLE_SUPPORT] += 50
		d[W.I_PARTY_SUPPORT] -= 40
		_add_loyalty_1_to_4(-500)
		d[W.I_MAO_MAUSOLEUM] = 10
		context["result_text"] = "华国锋决定不直接出面组织毛主席的葬礼，这件事没有被人忽视。在毛主席的死讯公布后，他的遗体在人民大会堂留置一周，以便全国人民向主席道别，追悼会在全国范围内举行。无数中国人来到这里向伟大领袖与导师致以最后的敬意。在时限后，遗体被送往医院，进行特别防腐处理。在三分钟的肃立默哀与华国锋的告别演说后，毛主席正式安息在了天安门前，由治丧委员会特别要求建设的纪念堂里。"


## 覆写 politicians[0]（毛槽）为华国锋（Event3.cs:29-37）
func _install_hua_guofeng() -> void:
	if ws.politicians.is_empty() or ws.politicians[0] == null:
		return
	var p: PoliticianData = ws.politicians[0]
	p.name_display = "华国锋"
	p.name_first = 2
	p.name_last = 2
	var tex := load("uid://cyfeyle661m17")
	if tex != null:
		p.portrait = tex
	p.power = 700
	p.age = d[W.I_YEAR] - 1941   # 原 age=(byte)(data[21]-1941)
	# 改版对齐：华国锋作为普通政客/领导人时，沿用开局 Leader 档案（保守/党务干部/实用主义/谋士），
	# 显式 faction=1=保守派；不能沿用原版 Event3 的 traits（那是毛的 traits 残留，会造成派系/特质错乱）。
	p.trait_personality = 20
	p.trait_alignment = 21
	p.trait_special = 5
	p.trait_background = 16
	p.faction = 1
	ws.leader = p
	ws.leader_politician_index = 0
	if ws.politics_positions.size() > 1:
		ws.politics_positions[1] = 150   # 原 politics_dolshnost[1]=150


## Event3.cs 三选项均对 politics[1..4] 施加相同忠诚增减
func _add_loyalty_1_to_4(delta: int) -> void:
	for i in range(1, 5):
		if i < ws.politicians.size() and ws.politicians[i] != null:
			ws.politicians[i].loyalty += delta
