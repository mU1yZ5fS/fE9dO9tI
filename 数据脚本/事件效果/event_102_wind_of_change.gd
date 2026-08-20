extends "res://数据脚本/event_script_base.gd"

## 原作 Event102.cs：变革之风（1985.3.10 契尔年科逝世，三候选竞争：戈尔巴乔夫/罗曼诺夫/格里申）。
## 触发：TimeScript.cs:10859（1985.3.10 后 且 苏 now_leader∈{1,2} 且 !=7 且 !IndOpp）。
## .tres 触发条件用 EMPIRE_LEADER_IS 组合表达（苏 current==1 或 ==2）。
## 支持选项需 relres && 苏关系≥500 && 特工≥100；支持者 support +3。
## 判定（Event102.cs）：leaders[6] 戈尔巴乔夫 / leaders[4] 罗曼诺夫 / leaders[5] 格里申
##  support 比较 → now_leader=6/4/5；戈尔巴乔夫胜 → 苏 power -= 250。
## 差异：
##  - allcountries[15].Gosstroy/SubGosstroy==0 → legacy 15 政体判断
##  - data[89] → I_REFORM_STAGE（前置副作用：==0 时戈尔巴乔夫 -1）
const LDR_GORBACHEV := 6   # leaders[6] = 米哈伊尔·戈尔巴乔夫
const LDR_ROMANOV := 4     # leaders[4] = 格里戈里·罗曼诺夫
const LDR_GRISHIN := 5     # leaders[5] = 维克托·格里申


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if ws.empires.size() <= EmpireData.USSR:
		return
	var ussr: EmpireData = ws.empires[EmpireData.USSR]
	var opt := int(context.get("option_index", -1))

	# 支持效果（Event102.cs ResultsOfEvents 前半）
	match opt:
		0:  # 支持戈尔巴乔夫
			_leader_support(ussr, LDR_GORBACHEV, 3)
			if d.size() > W.I_AGENTS:
				d[W.I_AGENTS] -= 100
		1:  # 支持罗曼诺夫
			_leader_support(ussr, LDR_ROMANOV, 3)
			if d.size() > W.I_AGENTS:
				d[W.I_AGENTS] -= 100
		2:  # 支持格里申
			_leader_support(ussr, LDR_GRISHIN, 3)
			if d.size() > W.I_AGENTS:
				d[W.I_AGENTS] -= 100
		3:  # 不要介入
			pass

	# 无条件副作用（Event102.cs）
	var usa: EmpireData = ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	if usa != null and ussr.power > usa.power:
		_leader_support(ussr, LDR_ROMANOV, 2)
	var c15 := ws.get_country_by_legacy_index(15)
	if c15 != null and c15.government == GameConstants.Government.AUTHORITARIAN and c15.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
		_leader_support(ussr, LDR_GORBACHEV, -1)

	# 判定（Event102.cs ResultsOfEvents 后半）
	var sg: int = _leader_support(ussr, LDR_GORBACHEV)
	var sr: int = _leader_support(ussr, LDR_ROMANOV)
	var sgr: int = _leader_support(ussr, LDR_GRISHIN)
	if sg >= sgr and sg >= sr:
		ussr.current_leader = LDR_GORBACHEV
		ussr.power -= 250
		context["result_text"] = "结果，米哈伊尔·戈尔巴乔夫被选为苏共中央委员会总书记。他惊人地迅速组织了一次代表大会，并通过军机确保政治局成员的顺利交接，而没有让他的对手罗曼诺夫说任何话。在葛罗米柯和温和派的支持下，他以极低的得票率领导了共产党。等待苏联的是什么?"
	elif sr >= sgr and sr >= sg:
		ussr.current_leader = LDR_ROMANOV
		context["result_text"] = "结果，格里戈里·罗曼诺夫被选为苏共中央委员会总书记，他得知契尔年科的死讯后，立即飞往莫斯科，在那里他成功地团结了保守派和温和派人士。有趣的事情等待着苏联。"
	elif sgr + 1 > sr and sgr + 1 > sg:
		ussr.current_leader = LDR_GRISHIN
		context["result_text"] = "结果，维克托·格里申当选为苏共中央委员会总书记。在保守的多数派的支持下，他成功地领导了苏共，这没有任何问题。苏联希望拥有几年的勃列日涅夫式稳定。"
	elif sg > sr:
		ussr.current_leader = LDR_GORBACHEV
		ussr.power -= 250
		context["result_text"] = "尽管有很多争论，结果，米哈伊尔·戈尔巴乔夫被选为苏共中央委员会总书记。他惊人地迅速组织了一次代表大会，并通过军机确保政治局成员的顺利交接，而没有让他的对手罗曼诺夫说任何话。在葛罗米柯和温和派的支持下，他以极低的得票率领导了共产党。等待苏联的是什么?"
	elif sg < sr:
		ussr.current_leader = LDR_ROMANOV
		context["result_text"] = "尽管有很多争论，结果，格里戈里·罗曼诺夫被选为苏共中央委员会总书记，他得知契尔年科的死讯后，立即飞往莫斯科，在那里他成功地团结了保守派和温和派人士。有趣的事情等待着苏联。"
	else:
		ussr.current_leader = LDR_GRISHIN
		context["result_text"] = "尽管有很多争议，结果，维克托·格里申当选为苏共中央委员会总书记。在保守的多数派的支持下，他成功地领导了苏共，这没有任何问题。苏联预期将拥有几年的勃列日涅夫式稳定。"
	context["result_title"] = "变革之风？"


## 读取/修改领导人支持度（越界安全，返回修改后值）
func _leader_support(ussr: EmpireData, idx: int, delta: int = 0) -> int:
	if idx < 0 or idx >= ussr.leaders.size() or ussr.leaders[idx] == null:
		return 0
	if delta != 0:
		ussr.leaders[idx].support += delta
	return ussr.leaders[idx].support
