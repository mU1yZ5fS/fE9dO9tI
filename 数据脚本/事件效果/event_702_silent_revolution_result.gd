extends "res://数据脚本/event_script_base.gd"

## 原作 Event702.cs：寂静革命的结果（魁北克公投，单选项）。
## 触发：ReqEventsDLC02.cs:1566-1568 —— DATE_AFTER 1980.5.20 → trigger_script evaluate。
## 差异：计分制复刻；Vyshi→亲美、cw→内战中；parts[0] 用 _set_part。

const TXT_R_FAIL := "虽说在地方层面，大部分法裔魁北克人都同意独立建国，可公投本身还得考虑联邦内的“民意”：相关数据表明，全国有40.44%选民支持魁北克同加拿大完全分离，近六成的国民站到了统一派一方。魁北克民族主义就此遭遇惨败，不得不偃旗息鼓。仰仗和平方式争取主权的所谓“寂静革命”之路也将迎来结束……"
const TXT_R_WIN := "即便特鲁多使尽浑身解数，也无法扭转既成事实：主权派以以50.58%对49.42%的微弱优势取得胜利，并为魁北克独立打开大门。也就在魁北克公示主权宣言的次日，特鲁多便试图以战争权利法案要挟对方退回联邦框架内。然而，这只会导致加拿大国内又一场危机的爆发：面对以和平而非军事手段争取独立的魁人党，引入强制法令只会导致宪政危机并招致不信任案投票。加拿大国内就此再度洗牌，由布赖恩·马尔罗尼领导的进步保守党也借机浑水摸鱼，奇迹般地反将一军。恢复了进步保守党政权……\n而在新独立的魁北克主权国家内，魁人党很快便站稳了脚跟，在国内取得了绝对优势。然而，谁都说不准这个新生政权的前景如何——虽说主张同加拿大断舍离的强硬派与试图同西部邻居维持貌合神离“主权合作”关系的怀柔派正打得不可开交，可绝大多数的政治家们还是识趣得确认了对其他主要政权的基本立场：继续参与北美防空司令部，并转向发展魁法特殊关系。看起来除却将第二把交椅让给高卢鸡外，新生的魁北克和加拿大间并无多大差别。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	var ussr := ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
	var portugal := ws.get_country_by_legacy_index(87)
	var spain := ws.get_country_by_legacy_index(86)
	var quebec := ws.get_country_by_legacy_index(167)
	var china := ws.get_country_by_legacy_index(1)
	var num := 0
	if usa != null and ussr != null and usa.power <= ussr.power:
		num += 1
	if usa != null and usa.power <= 200:
		num += 1
	if usa != null and usa.power <= 0:
		num += 99999
	if spain != null and spain.parts.size() > 1 and spain.parts[0] and spain.parts[1]:
		num += 1
	if portugal != null and portugal.government != GameConstants.Government.LIBERAL:
		num += 1
	if quebec != null and quebec.内战中:
		num += 1
	if ws.result_of_event_num(701) == 1:
		num += 1
	if _res(W.I_TERRITORY) > 21:
		num += 1
	if china != null and china.government == GameConstants.Government.LIBERAL:
		num += 1
	if num < 5:
		context["result_text"] = TXT_R_FAIL
		return
	context["result_text"] = TXT_R_WIN
	if quebec != null:
		_set_part(quebec, 0, true)
		_leave_alliances(quebec)
		quebec.government = GameConstants.Government.LIBERAL
		quebec.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
		quebec.set_tag("亲美", true)
	if MapService.instance != null:
		MapService.instance.sync_map_merges()


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value


func evaluate(world: WorldState) -> bool:
	return world != null and world.date != null and world.date.to_int() >= 19800520
