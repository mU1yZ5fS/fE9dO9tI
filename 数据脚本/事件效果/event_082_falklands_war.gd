extends "res://数据脚本/event_script_base.gd"

## 原作 Event82.cs：福克兰群岛战争（单选项，开战）。
## 触发：TimeScript.cs:10676-10682 ——
##   (日>=2 且 月>=4 且 年>=1982 或 年>=1983)
##   && (c71.Gosstroy==0 || c71.SubGosstroy==0 || c71.SubGosstroy>=7)。
## 效果：ingamewars[6] 福克兰群岛战争，阿根廷(400) vs 联合王国(600)，
##   ussr_place=-1、usa_place=1 → Godot ussr_side = GameConstants.WarSide.NONE / usa_side = GameConstants.WarSide.SIDE2；
##   c71.parts[0]=true。

const TXT_RESULT := "4月3日，联合国安理会通过了第502号决议，要求阿根廷军队撤出这些岛屿，但尽管如此，似乎没有人相信英国会胜利。但也许为了再次打击殖民主义的目的，我们应该帮助阿根廷，即使那里当道的是残忍的反共独裁者？"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		if ws.wars.size() <= 6:
			GameManager.start_war(6, "阿根廷", "联合王国", 400, 600, 1, -1)
		var war := ws.wars[6] if ws.wars.size() > 6 else null
		if war != null:
			war.name_war = "福克兰群岛战争"
			war.is_going = true
			war.side1 = "阿根廷"
			war.side2 = "联合王国"
			war.ussr_side = GameConstants.WarSide.NONE
			war.usa_side = GameConstants.WarSide.SIDE2
			war.infl1 = 400
			war.infl2 = 600
		var c71 := ws.get_country_by_legacy_index(71)
		if c71 != null:
			while c71.parts.size() <= 0:
				c71.parts.append(false)
			c71.parts[0] = true
		# 原版 parts[0]=true 表示马岛并入阿根廷地图；Godot 地图按地块归属渲染，
		# 开战即把福克兰群岛（map_regions.json region 3030）转给阿根廷（160）。
		if GameManager != null:
			GameManager.set_map_region_owner([3030], 160)
		context["result_text"] = TXT_RESULT
