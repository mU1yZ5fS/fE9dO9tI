extends "res://数据脚本/event_script_base.gd"

## 原作 Event568.cs：阿拉伯湾旗帜飘（阿湾全面战争，单选项）。
## 触发：DiploButtonScript.cs:11552 —— number_event = 568（外交按钮手动触发），无自动触发。
## 差异：
##  - oar → 国家标签 "oar"；proprc → 亲中；
##  - IsSocialism(true) → world.is_socialism(c, true)；IsAuthoritarianism → world.is_authoritarian；
##  - data[143] 无命名键，raw index 143（同 Event114 约定）；
##  - AmericanSupportAttacker → usa_side=0/ussr_side=-1；TickTime(24) → fortnight_max=24。

const TXT_TITLE := "阿拉伯湾旗帜飘"

const TXT_DESC := "随着阿湾人阵在我们的持续支持下在游击战争中获得的优势，尽管君主们都在帝国主义的援助下竭力开展改革，并用发放免费物资贿赂人民，期望以此消解人民的斗争，但他们的算盘并没有如他们的意——整个阿拉伯湾陷入到内乱之中了，在帝国主义的支持下，阿拉伯湾的各个君主国不得不开展全面动员，对阿湾人阵展开全面的战争，而沙特也自然意识到了唇亡齿寒的道理，他们直接向海湾各君主国派出了军队，宣称“将帮助友邦开展维和行动”。阿湾人阵也宣布要基于现有的根据地，开展“全阿拉伯湾的暴动”。阿拉伯湾的革命进入了新的阶段。"

const TXT_OPT0 := "这一次，阿拉伯湾的人民必将斩断锁链！"

const TXT_R0 := "通过阿湾人阵在城市中对海湾国家的各企业中的地下组织，阿湾人阵得以在城市中把来自各地的工人、进步的学生和知识分子团结起来，发起罢工斗争，并利用我们提供的武器与警察和军队开展街垒战；与此同时，农村根据地也开展了全面动员，以进行对敌人的全面进攻。全面的战争开始了，而世界也在注视着这场战争，以及与此息息相关的油价……"

const WAR43_NAME := "阿拉伯湾革命"
const WAR43_SIDE1 := "阿拉伯湾国家政府"
const WAR43_SIDE2 := "阿湾人阵起义军"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var num := 0
	for c in ws.countries:
		if c == null:
			continue
		if ws.is_socialism(c, true) and c.has_tag("oar") and c.原版序号 in [13, 14, 30, 18, 40, 54, 55, 35]:
			num += 30
	for j in range(101, 106):
		if j == 104:
			continue
		var c := ws.get_country_by_legacy_index(j)
		if c != null and c.has_tag("亲中") and (ws.is_authoritarian(c) or c.government == 3):
			c.set_tag("亲中", false)
	var c36 := ws.get_country_by_legacy_index(36)
	if c36 != null and c36.has_tag("亲中"):
		c36.set_tag("亲中", false)
	if d.size() > 143:
		d[143] += 10   # 原 data[143]（无命名键，同 Event114 约定）
	GameManager.start_war(43, WAR43_SIDE1, WAR43_SIDE2, 700 - num, 300 + num, 0, -1)
	if ws.wars.size() > 43 and ws.wars[43] != null:
		ws.wars[43].name_war = WAR43_NAME
		ws.wars[43].fortnight_max = 24
	context["result_text"] = TXT_R0
