extends "res://数据脚本/event_script_base.gd"

## 原作 Event114.cs：驴象之争（1980 美国大选，卡特 vs 里根）。
## 触发：TimeScript.cs:10824（1980.11 后，fire_only_once）。
## 13 项计分（num=民主党 / num2=共和党），num2>=num → 卡特连任(now_leader=1, data[143]+=2)；
## 否则里根(now_leader=0, data[143]-=2, allcountries[51].SubGosstroy=12)。
## 差异：
##  - OAR → ws flag "oar"；allcountries[15].cw → legacy 15 内战中
##  - allcountries[1]（中国）isASEAN/isSEATO：项目无对应 tag → 差异注释，按假跳过
##  - resultOfEvents[46]==2 / event_done[455]：移植说明事件 → 按假跳过（注释差异）
##  - allcountries[84].Gosstroy → legacy 84 government；allcountries[8] → legacy 8
##  - allcountries[51].SubGosstroy=12 → legacy 51（美国）sub_government=12

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if ws.empires.size() <= EmpireData.USA:
		return
	var usa: EmpireData = ws.empires[EmpireData.USA]
	var ussr: EmpireData = ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
	var opt := int(context.get("option_index", -1))

	var num := 0   # 民主党（卡特）
	var num2 := 0  # 共和党（里根）
	if usa.power > ussr.power:
		num2 += 1
	else:
		num += 1
	if usa.power > ws.influence_prc:
		num2 += 1
	else:
		num += 1
	if ws.influence_prc > ussr.power:
		num2 += 1
	else:
		num += 1
	if ws.get_flag("oar"):
		num += 1
	var c15 := ws.get_country_by_legacy_index(15)
	if c15 != null and c15.内战中:
		num2 += 1
	var player := ws.get_player_country()
	if player != null:
		if player.has_tag("asean"):
			num2 += 1
		if player.has_tag("seato"):
			num2 += 1
	# 差异：resultOfEvents[46]==2（移植说明事件 46）→ num++ 跳过
	var w5 := ws.wars[5] if ws.wars.size() > 5 else null
	if w5 != null and w5.is_going:
		num += 1
	var c84 := ws.get_country_by_legacy_index(84)
	if c84 != null and c84.government == 0:
		num += 1
	else:
		num2 += 1
	var c8 := ws.get_country_by_legacy_index(8)
	if c8 != null and (c8.government == 3 or c8.有驻军基地):
		num2 += 1
	else:
		num += 1
	# 差异：event_done[455]/resultOfEvents[455]（移植说明事件 455）→ 跳过

	context["result_title"] = "驴象之争"
	if opt == 0 and num2 >= num:
		# 卡特连任
		usa.current_leader = 1
		if d.size() > 143:
			d[143] += 2   # 原 data[143]（无端口命名键）
		context["result_text"] = "选举结束后，卡特仍设法维持住了权力。他获胜的一个关键因素是他温和的外交政策，尽管受到保守派的批评，但总体上表现良好。美国正在等待民主党执政的第二个四年。"
	elif opt == 0:
		# 里根当选
		usa.current_leader = 0
		if d.size() > 143:
			d[143] -= 2
		var usa_country := ws.get_country_by_legacy_index(51)
		if usa_country != null:
			usa_country.sub_government = 12
		context["result_text"] = "选举结束后，卡特被里根击败。由于对油价上涨和外交政策失败所导致的通胀和失业率上升感到不满，美国人选择了追随共和党人的民粹主义口号。现在，在里根的领导下，美国正等待着与苏联进行新一轮的积极对抗。"
	else:
		context["result_text"] = "选举结果尚未揭晓。"
