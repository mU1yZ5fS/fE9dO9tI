extends "res://数据脚本/event_script_base.gd"

## 原作 Event16.cs：泰国大选。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10155（日期>=1976.4 且 !event_done[16]）。
##  - data.thailand_election_intervention=100（泰国选举干预标志）：端口无命名键 → 数字索引直访。
##  - party_change[0]=0.5f / party_change[2]=1f（派系支持缓冲）：端口无等价 → 跳过。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 1:
		_opt_support_cpt(context)
	elif opt == 2:
		_opt_arms(context)


# 选项1：支持泰国共产党（Event16.cs result 1）
func _opt_support_cpt(context: Dictionary) -> void:
	if d.size() > W.I_AGENTS:
		d.agents -= 20
	if d.size() > W.I_BUDGET:
		d.budget -= 10
	ws.influence_prc += 5
	if d.size() > 41:
		d.thailand_election_intervention = 100   # 原 data.thailand_election_intervention（泰国选举干预标志，无端口命名键）
	context["result_text"] = "我们努力为泰共提供实质性支持同时和各种中左翼积极分子结盟，通过与社会行动党与民主党的关系的回暖，换取了政府停止对游击队军事基地的攻击。1976年的竞选活动伴随着血腥的街头冲突。通过与民主党和泰共的结盟，克立·巴莫的社会行动党获得了大多数的选票。保皇党政府以及官员们对左派的蓬勃发展感到不满，形势正在升温。"


# 选项2：让选举见鬼去吧！（Event16.cs result 2）
func _opt_arms(context: Dictionary) -> void:
	if d.size() > W.I_ARMY:
		d.army -= 20
	ws.influence_prc += 10
	context["result_text"] = "我们通过泰共向游击队援助了更多的武器来无视选举，他们派遣新的军队袭击军事基地。然而，泰共仍然无法控制这个国家哪怕一个地区。1976年的竞选活动伴随着血腥的街头冲突。冲突造成了大约30人死亡。社尼·巴莫所领导的民主党—因为比库克立·巴莫领导社会行动党更右翼—从而获得了大多数选票。右翼国家党领袖邦朋·阿滴列讪成为副总理。"
