extends "res://数据脚本/event_script_base.gd"

## 原作 Event435.cs：苏维埃的二号人物（反波德戈尔内行动，1977.1）。
## 触发：TimeScript.cs:10138-10143 —— (月>=1 且 年>=1977) 或 年>=1978。
## 文案：Events_text_en.txt 行 1647-1655（new_events_text[]，0 基索引）。
## 差异：
##  - 选项0（1649 散布情报）原版按 data[9]>=10 且 data[8]+data[36]>=50 显隐按钮，
##    本版用 EventOption.enable_condition + disabled_text（1649/1652）等价建模。
##  - SOV_PRC_PartiesConnection 映射为 I_COMMUNICATIONS（data[30]）：
##    原版 GameStartScript.cs:947 初始化即 `SOV_PRC_PartiesConnection = data[30]`，
##    Godot 外交面板已按 data[30] 建模（国家面板.gd:576-578）。
##  - 苏联领导人索引沿用 world_factory.gd:1162 注释的 USSR leaders 槽位。

const TXT_R0 := "在各类情报纷纷到位后，波德戈尔内立即采取了行动：首先，他在报纸上发表了一篇文章。称赞勃列日涅夫对赫鲁晓夫时代进行拨乱反正，最终实现了从伊里奇到伊里奇的伟大转折。波德戈尔内希望这篇文章能暂时拖延其对手的攻击，毕竟如果他们强行上马，就会背上违背集体领导原则的罪名。与此同时，波德戈尔内开始积极同自己的旧同僚联系，并利用自己的最高苏维埃主席团主席一职发展全新下线。毕竟所有关于改变现状的“建议”，都需要经过（至少是形式上的）他之手。这一局势在1977年初便越加激化，彼时勃列日涅夫已经被送入医院，苏斯洛夫取代了他的职务。安德罗波夫则决定在此时策划反波德戈尔内阴谋。然而计划失败了——波德戈尔内通过积极谈判斡旋，至少消除了许多党内人物的不满。在苏共第二十五次代表大会上，他自己则是第一个支持新宪法草案和削减自己权力的人，这最终让他的敌人无话可说。是的，尽管新宪法削弱了最高苏维埃主席团主席的权力，但目前的局势依然能让波德戈尔内稳如泰山。因此，安德罗波夫、谢尔比茨基与各类“新进干部”的部署被彻底打乱。然而在20世纪80年代，随着波德戈尔内被诊断出的肺癌，让他即将步柯西金心肌梗塞的后尘——1980年10月，柯西金选择因健康原因自愿辞去所有职务。在柯西金去世的两个月后，波德戈尔内也成为了一个多余的人。他因此在苏共第二十六次代表大会上遭遇批判，并不得不选择因健康原因隐退。"

const TXT_R1 := "我们在《人民之报》的专栏上发文炮打波德戈尔内，并将他称为资产阶级民族主义分子、唯意志论分子与“正摧毁斯大林时代遗留下来的苏联社会主义成就”的心胸狭隘小沙皇。于此同时，我们对苏联其他的党政干部手下留情。这使得我们与勃列日涅夫集团的关系得到了改善。"

const TXT_R2 := "波德戈尔内的消息并不灵通——当他得知新宪法将削减自己的权力时刻，波德戈尔内试图竭尽全力反对，但这又加速了他的辞职。在1976年初期，即苏共第二十五届代表大会召开前夕，勃列日涅夫的健康状况急剧恶化，甚至落入了临床死亡的禁地。在得知总书记糟糕的健康情况后，波德戈尔内决定独自前去看望领导。然而主治医师恰佐夫不准许他进入总书记的病房，并宣称勃列日涅夫需要静养。但在勃列日涅夫的核心圈子内，波德戈尔内的这一行为则被看作是对总书记的冒犯。对此，乌克兰共产党中央委员会第一书记谢尔比茨基准备借题发挥。扳倒波德戈尔内。不久后便召开了党的第二十五次代表大会，而医生们则设法使勃列日涅夫恢复了行动能力。可怜波德戈尔内，没想到自己被勃列日涅夫集团给耍了。就在本次代表大会上，他遭到了地区委员会书记们震耳欲聋的批评，他困惑地问向勃列日涅夫：“小列昂尼德，这是怎么回事？”可即便是老谋深算的勃列日涅夫，在此时也故作惊讶：“我自己也不明白，柯利亚，显然。这是人民的意志。”1977年5月24日，苏共中央政治局根据格里戈里·罗曼诺夫的建议，一致决定将波德戈尔内逐出最高苏维埃，仅保留其中央委员会委员之职。1977年6月16日，尼古拉·波德戈尔内选择辞去苏联最高苏维埃主席团主席职务，并最终退休。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# Event435.cs result 0
			_ussr_leader_add(6, -1)
			_ussr_leader_add(4, -1)
			_ussr_leader_add(1, -1)
			_ussr_leader_add(3, -2)
			if d.size() > W.I_BUDGET:
				d[W.I_BUDGET] -= 50
			if d.size() > W.I_AGENTS:
				d[W.I_AGENTS] -= 100
			context["result_text"] = TXT_R0
		1:
			# Event435.cs result 1
			# 原版 SOV_PRC_PartiesConnection += 5（显示 +0.5）。.tres 已通过 ADD_RESOURCE 改 data[30]（I_COMMUNICATIONS），
			# 数据源已统一为 data[30]，无需再同步镜像字段。
			_ussr_leader_add(3, 1)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
				ws.empires[EmpireData.USSR].relations = clampi(ws.empires[EmpireData.USSR].relations + 50, 0, 1000)
			context["result_text"] = TXT_R1
		2:
			# Event435.cs result 2：无效果
			context["result_text"] = TXT_R2


func _ussr_leader_add(index: int, delta: int) -> void:
	if ws.empires.size() <= EmpireData.USSR or ws.empires[EmpireData.USSR] == null:
		return
	var leaders: Array[EmpireLeader] = ws.empires[EmpireData.USSR].leaders
	if index >= 0 and index < leaders.size() and leaders[index] != null:
		leaders[index].support += delta
