extends "res://数据脚本/event_script_base.gd"

## 原作 Event538.cs：人民的革命！（日本革命战争，1选项）。
## 触发：无自动触发（DiploButtonScript.cs:11486 外交按钮 number_event=538）。
## 差异：ingamewars[36] → game.start_war + WarData 字段。

const TXT_R0 := "得益于此前所做的准备，日本革命共产党的相当一部分党员已经提前藏匿起来以躲避抓捕。待到行动过后，他们迅速现身并号召民众不要屈服于资产阶级的暴政，立刻行动起来。而我们也根据先前制定好的计划将各类武器、工具分发出去。很快，组织起来的青年学生、工人和农民对各地的监狱进行全面围堵，要求释放被捕人士。警方则直接动用水炮、催泪弹等装备驱散群众。但早已得到装备的民众顶住了冲击并不断压缩警员的活动区域。随后，一批佩戴防毒面具，头戴特质头盔，手持防爆盾与武器的精干人员冲破了警方障碍，冲入牢房并成功营救了被关押的同志们。这次抗争无疑是一个信号，很快，日本革命共产党正式宣布组建日本人民革命阵线，对腐朽的资产阶级政权展开了全面进攻。革命阵线旗下的武装分队也立刻在各地展开武装夺权的行动，这是人民的怒吼！"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c44 := ws.get_country_by_legacy_index(44)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		if c44 != null:
			c44.government = GameConstants.Government.AUTHORITARIAN
			c44.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		game.start_war(36, "日本政府", "日本人民革命阵线", 700, 300, 0, -1)
		if ws.wars.size() > 36 and ws.wars[36] != null:
			ws.wars[36].name_war = "日本革命战争"
			ws.wars[36].fortnight_max = 20
		context["result_text"] = TXT_R0
