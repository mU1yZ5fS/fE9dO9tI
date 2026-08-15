extends "res://数据脚本/event_script_base.gd"

## 原作 Event566.cs：和平宫的红色辅士（伊拉克爱国同盟总攻势，单选项）。
## 触发：TimeScript.cs:10564-10570 —— (wars[3].is_going || c14.prcpower>=100)
##   && c14.prcpower>50 && event_done[36] && resultOfEvents[36]==2。
## 效果：ingamewars[42] = War().Name("伊拉克内战").Attacker("复兴党")
##   .Defender("伊拉克爱国同盟").AttackerInfluence(700-num).DefenderInfluence(300+num)
##   .TickTime(24).AmericanSupportAttacker（num = c14.prcpower/10 整数除法）。
## 差异：Godot 用 GameManager.start_war + fortnight_max=24（原版 TickTime(24)）；
##   AmericanSupportAttacker → usa_side=0（攻击方=复兴党）。

const TXT_RESULT := "中东的局势还在持续的恶化……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null:
		return
	var c14 := world.get_country_by_legacy_index(14)
	if c14 != null and c14.prc_power >= 100:
		event_def.description = "随着伊拉克爱国同盟在北部站稳脚跟，伊拉克爱国同盟中央委员会决定发起针对伊拉克核心区域的总攻势，以此彻底解放整个南伊拉克。意识到大事不妙的萨达姆政权立刻开始动员军队，并加强了对解放区的扫荡和轰炸。爱国同盟向南部地方投送了大量《告全伊拉克人民书》和《快快加入爱国卫队》的宣言，呼吁进步青年，学生，农民，工人和军人加入到倒萨军队的行列中。出于反共产主义威胁的务实需要，美国坚定的支持复兴党政权，而苏联则试图置身事外。无论如何，这场战争不是你死就是我亡。"
	else:
		event_def.description = "随着伊拉克深陷于两伊战争的泥潭中，同时在伊拉克库尔德人聚集区确保了解放区。伊拉克爱国同盟中央委员会决定发起针对伊拉克核心区域的总攻势，以此彻底解放整个南伊拉克。意识到大事不妙的萨达姆政权立刻开始动员军队，并加强了对解放区的扫荡和轰炸。爱国同盟向南部地方投送了大量《告全伊拉克人民书》和《快快加入爱国卫队》的宣言，呼吁进步青年，学生，农民，工人和军人加入到倒萨运动的行列中。出于反共产主义威胁的务实需要，美国坚定的支持复兴党政权，而苏联则试图置身事外。无论如何，这场战争不是你死就是我亡。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		var c14 := ws.get_country_by_legacy_index(14)
		var num := 0
		if c14 != null:
			@warning_ignore("integer_division")
			num = c14.prc_power / 10
		GameManager.start_war(
			42, "复兴党", "伊拉克爱国同盟",
			700 - num, 300 + num, 0, -1
		)
		if ws.wars.size() > 42 and ws.wars[42] != null:
			ws.wars[42].name_war = "伊拉克内战"
			ws.wars[42].fortnight_max = 24  # 原版 TickTime(24)
		context["result_text"] = TXT_RESULT
