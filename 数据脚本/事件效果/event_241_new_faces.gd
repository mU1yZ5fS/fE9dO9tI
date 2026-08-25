extends "res://数据脚本/event_script_base.gd"

## 原作 Event241.cs：新时代，新面孔（陈永贵/孙健/吴桂贤与上海三人组）。
## 触发：TimeScript.cs:10213-10219 —— event_done[240] && !event_done[241]（PREV_EVENT_DONE 建模）。
## 差异：
##  - 原版 KillPerson(num) 后直接覆写同槽 Politic 字段。Godot 先
##    PoliticianSystem.kill_politician（清职+补员），再覆写槽内字段为指定新人。
##  - 原版 traits[0]=0（性格）、traits[3]=24（背景）、traits[1]=7（倾向）、
##    traits[2]=11（特长）→ PoliticianData: trait_personality / trait_background /
##    trait_alignment / trait_special（字段注释见 politician_data.gd:23-26）。
##  - NewPolitician[] 标记仅用于原版 UI 刷新，Godot 建模说明，跳过。
##  - party_change[] 仅 UI 摆动数值，跳过。
##  - “找最弱且非 traits[0]==0 的槽”循环：原版 num 从 0 起且不校验 num 本人，
##    逐字保留（本实现用空位/边界保护）。

const TXT_R0 := "event.script.event_241_new_faces.c0"

const TXT_R1 := "event.script.event_241_new_faces.c1"

const TXT_R2 := "event.script.event_241_new_faces.c2"


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
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty += 80
				if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
					p.loyalty += 100
				elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
					p.loyalty -= 100
				elif p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL:
					p.loyalty -= 150
				elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty -= 50
			context["result_text"] = tr(TXT_R0)
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
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty += 100
				if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
					p.loyalty += 80
				elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty -= 50
					p.power -= 100
				elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
					p.loyalty -= 100
					p.power -= 100
				elif p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL:
					p.loyalty -= 150
					p.power -= 100
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 30)
			_add(W.I_THOUGHT_FREEDOM, 30)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 20
				elif p.trait_personality < GameConstants.PoliticianPersonality.REFORMIST:
					p.loyalty += 100
			context["result_text"] = tr(TXT_R2)
	PoliticianSystem.sync_in_power_flags(ws)




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
		if p.power < base.power and p.trait_personality != GameConstants.PoliticianPersonality.FAR_LEFT:
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
	# 防重名：预备池可能已把该历史人物补入政坛（如陈永贵），事件再覆写会造成两个同名者。
	if PoliticianSystem.has_politician(display_name, name_first, name_last):
		return
	var p: PoliticianData = ws.politicians[index]
	if p == null:
		return
	var year := ws.date.year if ws.date != null else 1977
	PoliticianSystem.apply_historical_profile(
		p, display_name, name_first, name_last,
		personality, background, alignment, special,
		maxi(0, year - birth_year), 800, 800
	)
	p.is_historical = false
	# 必须先清掉旧 faction，再按新 traits 推导；否则 trait_faction_slot 会直接返回旧派系。
	p.faction = -1
	p.faction = PoliticianSystem.trait_faction_slot(p)
	PoliticianSystem.fill_vacant_faction_leaders()
	PoliticianSystem.sync_in_power_flags(ws)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_241_new_faces.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_241",
	"num": 241,
	"priority": 2410,
	"notify": false,
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_240"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
