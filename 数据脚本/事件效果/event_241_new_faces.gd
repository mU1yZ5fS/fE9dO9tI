extends "res://数据脚本/event_script_base.gd"

## 原作 Event241.cs：新时代，新面孔（陈永贵/孙健/吴桂贤与上海三人组）。
## 触发：TimeScript.cs:10213-10219 —— event_done[240] && !event_done[241]（PREV_EVENT_DONE 建模）。
## 差异：
##  - 原版 KillPerson(num) 后直接覆写同槽 Politic 字段。Godot 先
##    PoliticianSystem.kill_politician（清职+补员），再覆写槽内字段为指定新人。
##  - 原版 traits[0]=0（性格）、traits[3]=24（背景）、traits[1]=7（倾向）、
##    traits[2]=11（特长）→ PoliticianData: trait_personality / trait_background /
##    trait_alignment / trait_special（字段注释见 politician_data.gd:23-26）。
##  - NewPolitician[] 标记仅用于原版 UI 刷新，Godot 未建模，跳过。
##  - party_change[] 仅 UI 摆动数值，跳过。
##  - “找最弱且非 traits[0]==0 的槽”循环：原版 num 从 0 起且不校验 num 本人，
##    逐字保留（本实现用空位/边界保护）。

const TXT_R0 := "华国锋同志亲自任命了三位新的常务委员：来自山西的农民总理陈永贵，河北工人孙健和陕西工人吴桂贤。在盛大的宴席上，华国锋同志亲自向三位新的委员敬上一杯。在委婉的表达了自己的水平欠佳之余，表示希望在将来的治国之途中获得三人的支持。三位草根出身的新面孔表示定不会辜负毛主席留下的既定方针，把革命进行到底。他们已经确定会出席1979的建国三十周年纪念庆典。\n各方对这三位出身简朴的政治家保持观望。但我们和党内左派的关系得到了改善。一部分温和派成员表示了自己的不满。"

const TXT_R1 := "华国锋同志亲自任命了三位新的常务委员：来自山西的农民总理陈永贵，河北工人孙健和陕西工人吴桂贤。在盛大的宴席上，华国锋同志亲自向三位新的委员敬上一杯。在委婉的表达了自己的水平欠佳之余，表示希望在将来的治国之途中获得三人的支持。三位草根出身的新面孔泪流满面，表示定不会辜负毛主席留下的既定方针，把革命进行到底。他们已经确定会出席1979的建国三十周年纪念庆典。\n同时，为了保持和副主席的关系。华国锋还提拔了来自上海的三名革命闯将：徐景贤，马天水和王秀珍。这显著增加了极左派在党内的话语权。华国锋主席也同三人敬了一杯，三人向他表示不会辜负毛主席的期望，会尽力把在上海学习到的经验运用到全国的革命事业里去。这一决策受到了党内极左派，尤其是曾在上海工作的那一批的欢迎，他们在京城的力量又一次得到了增长。\n各方对这三位政治新人保持观望。我们和党内左派的关系得到了改善，但我们和温和派与残留的改革派的关系显著降低了。他们也对上海民兵经验的推广感到担忧。"

const TXT_R2 := "华国锋主席决定按照既定方针办。也就是什么都不做，希望在未来不会酿成什么大灾祸……"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			var idx0 := _find_weakest_non_left_radical()
			if idx0 >= 0:
				PoliticianSystem.kill_politician(idx0)
				_overwrite_politician(idx0, 10, 49, 1914, 0, 24, 7, 11, "陈永贵")
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0:
					p.loyalty += 80
				if p.trait_personality == 20:
					p.loyalty += 100
				elif p.trait_personality == 2:
					p.loyalty -= 100
				elif p.trait_personality == 3:
					p.loyalty -= 150
				elif p.trait_personality == 1:
					p.loyalty -= 50
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			var idx1 := _find_weakest_non_left_radical()
			if idx1 >= 0:
				PoliticianSystem.kill_politician(idx1)
				_overwrite_politician(idx1, 10, 49, 1914, 0, 24, 7, 11, "陈永贵")
			var idx2 := _find_weakest_non_left_radical()
			if idx2 >= 0:
				PoliticianSystem.kill_politician(idx2)
				_overwrite_politician(idx2, 43, 54, 1933, 0, 26, 5, 31, "徐景贤")
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0:
					p.loyalty += 100
				if p.trait_personality == 20:
					p.loyalty += 80
				elif p.trait_personality == 1:
					p.loyalty -= 50
					p.power -= 100
				elif p.trait_personality == 2:
					p.loyalty -= 100
					p.power -= 100
				elif p.trait_personality == 3:
					p.loyalty -= 150
					p.power -= 100
			context["result_text"] = TXT_R1
		2:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 30)
			_add(W.I_THOUGHT_FREEDOM, 30)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0:
					p.loyalty -= 20
				elif p.trait_personality < 2:
					p.loyalty += 100
			context["result_text"] = TXT_R2
	PoliticianSystem.sync_in_power_flags(ws)


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


## Event241.cs：从 0 号槽起步，找 power 最小且 traits[0]!=0 的槽。
func _find_weakest_non_left_radical() -> int:
	var num := 0
	for i in ws.politicians.size():
		var p: PoliticianData = ws.politicians[i]
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		var base: PoliticianData = ws.politicians[num]
		if base == null:
			num = i
			continue
		if p.power < base.power and p.trait_personality != 0:
			num = i
	return num


## kill 后覆写槽位为原版指定政治家（name_1/name_2/traits/power/loyality 逐项对齐）。
func _overwrite_politician(
		index: int, name_first: int, name_last: int, birth_year: int,
		personality: int, background: int, alignment: int, special: int,
		display_name: String
) -> void:
	if index < 0 or index >= ws.politicians.size():
		return
	var p: PoliticianData = ws.politicians[index]
	if p == null:
		return
	var year := ws.date.year if ws.date != null else 1977
	p.name_display = display_name
	p.name_first = name_first
	p.name_last = name_last
	p.age = maxi(0, year - birth_year)
	p.trait_personality = personality
	p.trait_background = background
	p.trait_alignment = alignment
	p.trait_special = special
	p.power = 800
	p.loyalty = 800
	p.portrait = null
	p.is_historical = false
	p.faction = PoliticianSystem.trait_faction_slot(p)
	PoliticianSystem.fill_vacant_faction_leaders()
	PoliticianSystem.sync_in_power_flags(ws)
