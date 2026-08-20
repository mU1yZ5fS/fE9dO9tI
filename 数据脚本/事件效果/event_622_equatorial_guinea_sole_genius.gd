extends "res://数据脚本/event_script_base.gd"

## 原作 Event622.cs：赤道几内亚唯一天才（马西埃访问，二选项）。
## 触发：无自动触发点——原版由 DiploButtonScript.cs:2292-2294（this_type 外交按钮）手动 number_event=622。
## 差异：result1 的 event_done[622]=false 在 execute 中 erase；引擎 apply 后会再标记 done（引擎差异）。

const TXT_R0 := "近日，在我们和朝鲜的邀请下，马西埃·恩圭马同志开始对中国和朝鲜进行为期两周的国事访问。在访问路上，马西埃总统参观了中国和朝鲜境内的革命军事博物馆，山西交城县，韶山毛主席故居，长白山（白头山）峰顶，主体思想塔等诸多带有“红色基因”特色的地点和建筑。他拜访了毛泽东主席的纪念馆和纪念碑，亲自送上了插有嘉兰的花环，他还参观了1969年珍宝岛战争纪念碑。在归国前，马西埃高度赞扬了华国锋同志和金日成同志的社会主义建设和个人崇拜。\n回国后，马西埃开始加大了对自己和家族的个人崇拜，自己则成为“赤道几内亚唯一天才”“芳族人民永远的领袖”“当代杰出的共产主义者”“木尼河所培育的最纯洁，最革命，最自然的领袖”，他的三名子女则分别成为交通部部长，体育部部长和教育部部长，关于马西埃曾经为西班牙人做事的经历则被抹去，取而代之的则是马西埃曾一直带领着芳族人民反抗西班牙殖民统治并最终获胜的神化故事。马西埃发动了反对官僚，小资产阶级和反动派的民族纯净运动，让芳族群众大量屠杀知识分子，官僚和所谓“反动派”，全员开始学习并背诵马西埃的语句（尽管这些语句很多都只是马西埃随口说的，而且有很多句子与马西埃原话相差甚远），并开始将芳族视为最革命的民族，誓要将中非地区的芳族聚集区给“收复”回来。\n全球都对这个神奇的奇幻小国所发生的事感到震惊，强烈谴责了马西埃并开始发动提议要禁运赤道几内亚，但是这恰恰表明反革命集团开始气急败坏了，就让他们去反对吧。"
const TXT_R1 := "这真的不是什么好的提议，如果您没有休息好的话，您可以先暂时停止处理公务而不是考虑这些容易败坏我国名誉的决定。"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var eq_guinea := _country(115)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if eq_guinea != null:
				eq_guinea.government = GameConstants.Government.AUTHORITARIAN
				eq_guinea.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
				_leave_alliances(eq_guinea)
				eq_guinea.set_tag("对华贸易", true)
				eq_guinea.set_tag("亲中", true)
			ws.influence_prc += 10
		1:
			context["result_text"] = TXT_R1
			ws.completed_event_ids.erase("event_622")






func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"

func _foreign_minister_name() -> String:
	if ws != null and ws.politics_positions.size() > 2:
		var idx: int = ws.politics_positions[2]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
				and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return "黄华"

func _war_going(war_id: int) -> bool:
	var war := _get_war(war_id)
	return war != null and war.is_going

func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)

func _establish_prosoviet(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲苏", true)
	c.set_tag("亲中", false)
	c.set_tag("亲美", false)

func _start_war(war_id: int, war_name: String, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, tick_time: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	var war := _get_war(war_id)
	if war != null:
		war.name_war = war_name
		war.fortnight_max = tick_time

func _free_puppets(overlord: int) -> void:
	if ws == null:
		return
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			c.puppet_of = GameConstants.LegacySlot.NONE


