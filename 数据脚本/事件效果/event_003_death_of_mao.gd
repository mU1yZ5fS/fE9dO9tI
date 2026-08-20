extends "res://数据脚本/event_script_base.gd"

## 原作 Event3.cs：舵手逝世三选项。
## 公共效果（三选项均执行）：稳定=100(SET)、politics[0] 替换为毛远新并按原文覆写字段、
## politics_positions[1]=150。分支：opt0/1/2 各自的资源增减 + politicians[1..4] 忠诚循环 + 动态文案。
## 因「覆写政治家」「仅 [1..4] 忠诚」不可声明式 → 全部走自定义脚本（含公共 stability，避免与 .tres 双写）。
## 差异：ws.leader 保持开局独立华国锋对象（项目结构），不再把政客槽覆写成华国锋造成双显示。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))

	# 公共效果（Event3.cs:26-37，三选项均执行；原作 Set(222) 在稳定性覆写之前）
	Achievements.set_achievement(222)  # 原作 Event3.cs:26-29 iron_and_blood → achievements.Set(222)
	d[W.I_STABILITY] = 100
	_replace_mao_with_mao_yuanxin()

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


## 毛泽东逝世后的公共处理：移除毛槽、点名补入毛远新，并按 Event3.cs:29-37 原文覆写其档案字段。
## ws.leader 保持开局独立华国锋对象，不指向政客槽，避免“实权领袖 + 政客卡”双显示。
func _replace_mao_with_mao_yuanxin() -> void:
	if ws.politicians.is_empty() or ws.politicians[0] == null:
		return
	# 移除毛泽东槽，固定点名补入毛远新（原版死亡补员后极左派槽由毛远新接任）。
	# 若毛远新已入场/未到年份/池中无人，才回退常规补员规则。
	GameManager.kill_politician(0, "毛远新")
	if ws.politicians.size() > 0 and ws.politicians[0] != null:
		var p: PoliticianData = ws.politicians[0]
		# Event3.cs:30-37 逐字段覆写：
		p.name_first = 1
		p.name_last = 41
		p.age = d[W.I_YEAR] - 1941
		p.power = 700
		p.trait_personality = GameConstants.PoliticianPersonality.FAR_LEFT    # traits[0]
		p.trait_alignment = GameConstants.PoliticianAlignment.HARDLINER      # traits[1]
		p.trait_special = GameConstants.PoliticianSpecial.PEOPLES_FRIEND       # traits[2]（原版越界值逐字保留）
		p.trait_background = GameConstants.PoliticianBackground.MASS_LEADER    # traits[3]
	# 军委由实权领袖本人担任（原 politics_dolshnost[1]=150）
	if ws.politics_positions.size() > 1:
		ws.politics_positions[1] = WorldFactory.LEADER_POSITION_SENTINEL


## Event3.cs 三选项均对 politics[1..4] 施加相同忠诚增减
func _add_loyalty_1_to_4(delta: int) -> void:
	for i in range(1, 5):
		if i < ws.politicians.size() and ws.politicians[i] != null:
			ws.politicians[i].loyalty += delta
