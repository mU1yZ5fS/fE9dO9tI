extends "res://数据脚本/event_script_base.gd"

## 原作 Event89.cs：一个时代的终结（1982.11.10 勃列日涅夫逝世，苏联继任竞争）。
## 触发：TimeScript.cs:10740（1982.11.10 后，fire_only_once）。
## 三候选（Event89.cs 索引语义）：安德罗波夫=leaders[3]、谢尔比茨基=leaders[1]、契尔年科=leaders[2]。
## 安德罗波夫胜 → now_leader=1；谢尔比茨基胜 → now_leader=3；契尔年科胜 → now_leader=2
## （与 modify_choose.cs:154-212 显示分支自洽）。
## 差异：
##  - 前置副作用（TextOfEvents）：data[89]==0 → leaders[3].support-=1；苏 power>美 power → leaders[2].support+=1
##  - 支持选项需 relres && 苏关系≥50 && 特工≥100；安德罗波夫/谢尔比茨基选项另需对应 support 门槛
##  - relres → ws flag "relres"；allcountries[7].Torg → 玩家 has_tag("对华贸易")；
##    allcountries[1].isSEV/isOVD → 玩家 has_tag("sev"/"ovd")
const LDR_ANDROPOV := 3     # leaders[3] = 尤里·安德罗波夫
const LDR_SHCHERBITSKY := 1 # leaders[1] = 弗拉基米尔·谢尔比茨基
const LDR_CHERNENKO := 2    # leaders[2] = 康斯坦丁·契尔年科


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if ws.empires.size() <= EmpireData.USSR:
		return
	var ussr: EmpireData = ws.empires[EmpireData.USSR]
	var opt := int(context.get("option_index", -1))

	# 前置副作用（Event89.cs TextOfEvents）
	if d.size() > W.I_REFORM_STAGE and d[W.I_REFORM_STAGE] == 0:
		_leader_support(ussr, LDR_ANDROPOV, -1)
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		if ussr.power > ws.empires[EmpireData.USA].power:
			_leader_support(ussr, LDR_CHERNENKO, 1)

	# 选项效果（Event89.cs ResultsOfEvents 前半：支持 +2 与附加）
	var num := -1
	match opt:
		0:  # 支持安德罗波夫
			num = LDR_ANDROPOV
		1:  # 支持谢尔比茨基
			num = LDR_SHCHERBITSKY
		2:  # 支持契尔年科
			num = LDR_CHERNENKO
		3:  # 不要介入
			num = -1
	if num >= 0:
		_leader_support(ussr, num, 2)
		if d.size() > W.I_AGENTS:
			d[W.I_AGENTS] -= 100
		if ws.get_flag("relres"):
			_leader_support(ussr, num, 1)
		var player := ws.get_player_country()
		if player != null:
			if player.has_tag("对华贸易") or player.has_tag("sev"):
				_leader_support(ussr, num, 1)
			if player.has_tag("ovd"):
				_leader_support(ussr, num, 1)

	# 判定（Event89.cs ResultsOfEvents 后半：support 比较 → now_leader）
	var s1: int = _leader_support(ussr, LDR_SHCHERBITSKY)
	var s2: int = _leader_support(ussr, LDR_CHERNENKO)
	var s3: int = _leader_support(ussr, LDR_ANDROPOV)
	if s2 >= s3 and s2 >= s1:
		# 契尔年科当选（折衷方案）
		ussr.current_leader = 2
		_leader_support(ussr, 4, 1)  # 罗曼诺夫 +1
		_leader_support(ussr, 5, 1)  # 格里申 +1
		context["result_text"] = "结果，康斯坦丁·契尔年科当选为苏共中央委员会总书记。许多人认为他是一个适宜的折衷方案，可以让联盟避免大规模的变革和动荡，而他似乎会满足他们的期望。"
	elif s1 >= s2 and s1 >= s3:
		# 谢尔比茨基当选
		ussr.current_leader = 3
		context["result_text"] = "结果，弗拉基米尔·谢尔比茨基当选为苏共中央委员会总书记。这并不奇怪——除去了安德罗波夫，在苏斯洛夫的支持和勃列日涅夫的信任下，他成为了这个职位的主要竞争者。苏联似乎在等待数年的稳定。"
	elif s3 >= s2 and s3 >= s1:
		# 安德罗波夫当选（务实而强硬）
		ussr.current_leader = 1
		_leader_support(ussr, 6, 2)  # 戈尔巴乔夫 +2
		context["result_text"] = "结果，尤里·安德罗波夫当选为苏共中央委员会总书记。在领导克格勃的岁月里，他把巨大的权力集中在手中，使他赢得了这场战斗，许多人认为他是一个务实而强硬的领导人，对苏联来说是非常必要的。"
	elif s2 >= s3:
		# 契尔年科当选（次要分支）
		ussr.current_leader = 2
		_leader_support(ussr, 4, 1)
		_leader_support(ussr, 5, 1)
		context["result_text"] = "结果，康斯坦丁·契尔年科当选为苏共中央委员会总书记。许多人认为他是一个适宜的折衷方案，可以让联盟避免大规模的变革和动荡，而他似乎会满足他们的期望。"
	else:
		# 安德罗波夫当选（次要分支）
		ussr.current_leader = 1
		_leader_support(ussr, 6, 2)
		context["result_text"] = "结果，尤里·安德罗波夫当选为苏共中央委员会总书记。在领导克格勃的岁月里，他把巨大的权力集中在手中，使他赢得了这场战斗，许多人认为他是一个务实而强硬的领导人，对苏联来说是非常必要的。"
	context["result_title"] = "一个时代的终结"


## 读取/修改领导人支持度（越界安全，返回修改后值）
func _leader_support(ussr: EmpireData, idx: int, delta: int = 0) -> int:
	if idx < 0 or idx >= ussr.leaders.size() or ussr.leaders[idx] == null:
		return 0
	if delta != 0:
		ussr.leaders[idx].support += delta
	return ussr.leaders[idx].support
