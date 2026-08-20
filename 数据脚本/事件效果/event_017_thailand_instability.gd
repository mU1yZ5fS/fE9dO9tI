extends "res://数据脚本/event_script_base.gd"

## 原作 Event17.cs：泰国动乱。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10162（日期>=1976.10 且 !event_done[17]）。
##  - TaiCoup=true：端口无对应字段 → 用 flag "tai_coup" 表达（原版影响后续泰国事件链）。
##  - party_change[0]=1f（派系支持缓冲）：端口无等价 → 跳过。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	ws.set_flag("tai_coup", true)
	var opt := int(context.get("option_index", -1))
	_set_thai_govt()
	match opt:
		0:
			_opt_ignore(context)
		1:
			_opt_uprising(context)
		2:
			_opt_condemn(context)


# 泰国政体变更（三个选项共有）：Gosstroy=0 / SubGosstroy=7
func _set_thai_govt() -> void:
	var thai := ws.get_country_by_legacy_index(34)
	if thai != null:
		thai.government = GameConstants.Government.AUTHORITARIAN
		thai.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN


# 选项0：这不关我们的事（Event17.cs result 0）
func _opt_ignore(context: Dictionary) -> void:
	if ws.empires.size() > 0 and ws.empires[0] != null:
		ws.empires[0].power += 5
	context["result_text"] = "在10月6号，警察部队和右翼民兵最终控制了大学，学生们虽然愿意投降，但是随后政府军还是开始了屠杀，据被引用最多的报道，至少有100名学生死于屠杀之中。同一天晚上，军方迫使总理普拉莫吉辞职。在国王的支持下，军方组建了军政府，结束了维持了三年的民主政治。泰国又一次进入了专制的时代，只有北方的游击队活动区域仍在泰国共产党的控制之下。"


# 选项1：派遣武装的泰国共产党部队（Event17.cs result 1：启动战争2「泰国内战」）
func _opt_uprising(context: Dictionary) -> void:
	if d.size() > W.I_AGENTS:
		d.agents -= 40
	if d.size() > W.I_ARMY:
		d.army -= 30
	if ws.empires.size() > 0 and ws.empires[0] != null:
		ws.empires[0].relations -= 100
	var war := ws.wars[2] if ws.wars.size() > 2 else null
	if war != null:
		war.name_war = "泰国内战"
		war.is_going = true
		war.side1 = "共产党"
		war.side2 = "保王党"
		war.usa_side = GameConstants.WarSide.SIDE2
		war.ussr_side = GameConstants.WarSide.SIDE1
		war.infl1 = 300
		war.infl2 = 700
		var thai := ws.get_country_by_legacy_index(34)
		if thai != null and thai.stab == 1:
			war.infl1 += 50
			war.infl2 -= 50
	context["result_text"] = "由于我们的支持和特工组织的努力，泰共和社会党等左派政党以及民主派的各个政党建立了联系，并牵头组织了进步、爱国和民主力量统一阵线。与此同时，一批中国制式武器流通到了罢工工人和抗议学生那里，他们在泰共地下党员的领导下同阵线内其他势力联合起来，击退了政府的镇压队伍。全曼谷以及泰国多个城市都爆发了类似的起义，并随之开始了大规模的交火，并以军队和警察的失败告终。而普拉莫吉总理被军方以“动摇国体，破坏首都治安”而逮捕的消息震惊了全国，大量的学生，工运人士、工人以及其他左派政党和民主派政党聚集在泰国共产党领导的进步、爱国和民主力量统一阵线下，同保守派势力对战。泰国共产党领导的泰国人民解放军在我们和越南的大规模援助下趁此机会开始向全国展开全面攻势。"


# 选项2：谴责泰国的暴行（Event17.cs result 2）
func _opt_condemn(context: Dictionary) -> void:
	if ws.empires.size() > 1 and ws.empires[1] != null:
		ws.empires[1].relations += 20
	if ws.empires.size() > 0 and ws.empires[0] != null:
		ws.empires[0].relations -= 20
		ws.empires[0].power += 5
	ws.influence_prc += 10
	context["result_text"] = "在10月6号，警察部队和右翼民兵最终控制了大学，学生们虽然愿意投降，但是随后政府军还是开始了屠杀，据被引用最多的报道，至少有100名学生死于屠杀之中。同一天晚上，军方迫使总理普拉莫吉辞职。在国王的支持下，军方组建了军政府，结束了三年的民主政治。泰国又一次进入了专制的时代，只有北方的游击队活动区域仍在泰国共产党的控制之下。我们虽然愿意支持他们并谴责军政府的残暴，但我们都明白这已经毫无意义了。"
