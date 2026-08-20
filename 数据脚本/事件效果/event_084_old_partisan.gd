extends "res://数据脚本/event_script_base.gd"

## 原作 Event84.cs：我们的老游击队员…（1978.10.4 后 且 苏 now_leader==0 勃列日涅夫 且 result[83]==0 或 data.soviet_successor_route==1）。
## 触发：TimeScript.cs:10691。效果（Event84.cs ResultsOfEvents）：
##  - result0（散布谣言）：data.agents-=80、苏 leaders[3](安德罗波夫).support-=2、data.soviet_successor_route=2
##  - result1（黑料）：苏关系>=500 → data.budget-=50、leaders[3].support-=1、data.soviet_successor_route=2；否则仅 data.budget-=50
##  - result2（留到将来）：无效果
## 选项条件：特工>=80 且（路线<3 且 一党制<8，或多党联盟>66%）
const LDR_ANDROPOV := 3   # 苏 leaders[3] = 尤里·安德罗波夫


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	context["result_title"] = "我们的老游击队员…"
	if opt == 0:
		if d.size() > W.I_AGENTS:
			d.agents -= 80
		_leader_support(-2)
		if d.size() > 149:
			d.soviet_successor_route = 2
		context["result_text"] = "14时35分，彼得·马谢罗夫离开白共中央委员会建筑，乘坐GAZ-13“海鸥”轿车前往若季诺，司机是E. 扎伊采夫（60岁）。马谢罗夫坐在副驾驶，后座是安全军官V.F. 切斯诺科夫上校。与现有指示相反的是，没有一辆带有适当颜色和闪光灯的交警车辆引导，而是白色的“伏尔加”汽车，带有扬声器报警装置，但没有闪光灯。在“莫斯科－明斯克”高速公路上，通往斯摩列维奇市附近家禽养殖场的拐弯处，“海鸥”轿车被一辆装载着土豆的自卸卡车GAZ-SAZ-53B撞上，司机是N. 普斯托维特。没人幸存下来－马谢罗夫，他的司机和保镖都当场死亡，卡车司机－在送往医院的路上因为大量失血死亡。苏联总检察长办公室展开了调查，认定案件并非是蓄意谋杀。克格勃不认同这个结论，产生了些冲突。但官方说法仍然是：运土豆的卡车司机有罪。这对我们来说很好。"
	elif opt == 1:
		var ussr: EmpireData = ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
		if d.size() > W.I_BUDGET:
			d.budget -= 50
		if ussr != null and ussr.relations >= 500:
			_leader_support(-1)
			if d.size() > 149:
				d.soviet_successor_route = 2
			context["result_text"] = "我们的特工与白俄罗斯部长会议主席－吉洪·基谢廖夫取得联系，他与对马谢罗夫政策不满的白俄罗斯党员联合起来，我们的特工还给了他关于马谢罗夫的黑料（具体来说，他支持柯西金改革，要求发展能够刺激企业的经济利益的计划体系。这样做的原因是他希望逐步摆脱经济管理的行政和命令方法。同时，在马谢罗夫的倡议下，白俄罗斯举行研讨会讨论国民经济的各种问题，与苏共中央委员会并不一致）。基谢廖夫同时也是苏联部长会议副主席，与米哈伊尔·苏斯洛夫会面，交给了他这些信息。马谢罗夫被召到莫斯科，遭到批判，剥夺了权力，被迫辞职退休。"
		else:
			context["result_text"] = "我们的特工与白俄罗斯部长会议主席－吉洪·基谢廖夫取得联系，他与对马谢罗夫政策不满的白俄罗斯党员联合起来，我们的特工还给了他关于马谢罗夫的黑料（具体来说，他支持柯西金改革，要求发展能够刺激企业的经济利益的计划体系。这样做的原因是他希望逐步摆脱经济管理的行政和命令方法。同时，在马谢罗夫的倡议下，白俄罗斯举行研讨会讨论国民经济的各种问题，与苏共中央委员会并不一致）。但是基谢廖夫不敢把信息交给苏斯洛夫，结果马谢罗夫仍然担任原职。"
	elif opt == 2:
		context["result_text"] = "14时35分，彼得·马谢罗夫离开白共中央委员会建筑，乘坐GAZ-13“海鸥”轿车前往若季诺，司机是E. 扎伊采夫（60岁）。马谢罗夫坐在副驾驶，后座是安全军官V.F. 切斯诺科夫上校。与现有指示相反的是，没有一辆带有适当颜色和闪光灯的交警车辆引导，而是白色的“伏尔加”汽车，带有扬声器报警装置，但没有闪光灯。在“莫斯科－明斯克”高速公路上，通往斯摩列维奇市附近家禽养殖场的拐弯处，“海鸥”轿车被一辆装载着土豆的自卸卡车GAZ-SAZ-53B撞上，司机是N. 普斯托维特。没人幸存下来－马谢罗夫，他的司机和保镖都当场死亡，卡车司机－在送往医院的路上因为大量失血死亡。苏联总检察长办公室与克格勃展开了调查，认定案件并非是蓄意谋杀。调查组最终得出结论：运土豆的卡车司机有罪。"
	else:
		context["result_text"] = ""


## 苏 leaders[3]（安德罗波夫）support 调整
func _leader_support(delta: int) -> void:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		var ussr: EmpireData = ws.empires[EmpireData.USSR]
		if LDR_ANDROPOV < ussr.leaders.size() and ussr.leaders[LDR_ANDROPOV] != null:
			ussr.leaders[LDR_ANDROPOV].support += delta
