extends "res://数据脚本/event_script_base.gd"

## 原作 Event114.cs：驴象之争（1980 美国大选，卡特 vs 里根）。
## 触发：TimeScript.cs:10824（1980.11 后，fire_only_once）。
## 计分（用户规则）：与修正54“美国国内各党影响力对比”同口径（卡特+1/里根-1 净分），
## 由 ModifierCatalog._us_party_scores 统一计算；民主 > 共和 → 卡特连任(now_leader=1, data.oil_price+=2)；
## 否则里根(now_leader=0, data.oil_price-=2, allcountries[51].SubGosstroy=12)。
## 差异：
##  - OAR → ws flag "oar"；allcountries[15].cw → legacy 15 内战中
##  - allcountries[1]（中国）isASEAN/isSEATO：项目无对应 tag → 按玩家国家 tag 处理
##  - resultOfEvents[46]==2 / event_done[455]：由 _us_party_scores 按原作完整条目计入
##  - allcountries[84].Gosstroy → legacy 84 government；allcountries[8] → legacy 8
##  - allcountries[51].SubGosstroy=12 → legacy 51（美国）sub_government = GameConstants.SubGovernment.NEOLIBERAL

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if ws.empires.size() <= EmpireData.USA:
		return
	var usa: EmpireData = ws.empires[EmpireData.USA]
	var opt := int(context.get("option_index", -1))

	# 用户规则：选举计分与修正54“美国国内各党影响力对比”同口径（卡特+1/里根-1 净分）。
	# 原版 Event114.cs 的 num/num2 计分 + 原版 ModifyButtonScript 修正54 显示共用一套条目；
	# 端口统一走 ModifierCatalog._us_party_scores（含匈牙利危机46、伊朗人质危机455 等完整条目），
	# 民主 > 共和 → 卡特连任；否则里根当选（原版 num2>=num→卡特的胜负方向搞反了）。
	var scores := ModifierCatalog._us_party_scores(ws)
	var dem := int(scores.get("dem", 0))
	var rep := int(scores.get("rep", 0))

	context["result_title"] = "驴象之争"
	if opt == 0 and dem >= rep:
		# 卡特连任
		usa.current_leader = 1
		if d.size() > 143:
			d.oil_price += 2   # 原 data.oil_price（无端口命名键）
		context["result_text"] = "选举结束后，卡特仍设法维持住了权力。他获胜的一个关键因素是他温和的外交政策，尽管受到保守派的批评，但总体上表现良好。美国正在等待民主党执政的第二个四年。"
	elif opt == 0:
		# 里根当选
		usa.current_leader = 0
		if d.size() > 143:
			d.oil_price -= 2
		var usa_country := ws.get_country_by_legacy_index(51)
		if usa_country != null:
			usa_country.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		context["result_text"] = "选举结束后，卡特被里根击败。由于对油价上涨和外交政策失败所导致的通胀和失业率上升感到不满，美国人选择了追随共和党人的民粹主义口号。现在，在里根的领导下，美国正等待着与苏联进行新一轮的积极对抗。"
	else:
		context["result_text"] = "选举结果尚未揭晓。"
