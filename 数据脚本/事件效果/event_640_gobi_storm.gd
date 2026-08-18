extends "res://数据脚本/event_script_base.gd"

## 原作 Event640.cs：打倒社帝马前卒！（中蒙战争，单选项）。
## 触发：DiploButtonScript.cs:12234 —— 外交按钮 1052，selected_country==9，手动触发。
## 差异：ingamewars[69] 已有 war_69 WarDef，仍按 start_war 参数覆盖；
##   usa_place=0（仅 c51.Torg 时）→ WarData.usa_side=0；relres→global_flags。

const TXT_TITLE := "打倒社帝马前卒！"
const TXT_DESC_PRE := "随着苏联的日益式微，是时候处理苏联在东亚地区安插给我们的一棵楔子了。蒙古，这个无耻又邪恶的伪政权，他的诞生就是建立在乘乱谋独上，在我们国内革命陷入危机的时候，蒙古打起了内蒙古的算盘，积极扶持内蒙古人民革命党等“极左”分离主义组织。在八月风暴时妄图借着苏军夺走内蒙。在解放战争中，他们为破坏三区革命的乌斯满匪帮大开绿灯，更别提在中苏论战中毫不动摇的支持苏联。这个无耻之国应该付出代价。随着苏联在东欧的“惨胜”，我们应当更进一步，打碎邪恶帝国在远东的重要支点。而苏联新政府的改革更是创造了这一机会，蒙古的物价遇到了前所未有的飙升，商品极度短缺，俄罗斯驻军的暴行也早已让该国公民厌倦。大量的牧民以探亲戚和“归乡”为由从蒙古一侧逃到我方来寻求庇护。这更说明了我们的正确性。是时候让他们为过去的错误付出代价了。"
const TXT_DESC_TAIL := "同志，是时候了，该让我们一举粉碎邪恶帝国所孕育的弗兰肯斯坦了。"
const TXT_OPT0 := "执行“戈壁风暴”计划吧，我期待很久了"
const TXT_R_PRE := "中央军委一声令下，中国人民解放军发动了对蒙古的袭击。当被问到为何发动军事行动时，国防部发言人如是说到：“在伪政府统治下的蒙古同胞们早就渴望回到中华民族的大家庭里了，而我们的领袖"
const TXT_R_POST := "同志也做好了接纳他们的准备。中国人民解放军将从苏联社会帝国主义手中，解放受尽磨难的蒙古人民。这是中华民族一雪前耻的重要时刻，这是让蒙古人民摆脱苏修枷锁的反帝战争！”\n孱弱的蒙古人民军面对如潮水般的中国人民解放军似乎并不占优，或者说，他们能抵抗都已经是个奇迹了。唯一的希望在于苏军和古巴教官，因为前线的蒙古士兵开始成建制的向解放军投降，乌兰巴托已经近在咫尺了。\n苏联外长强烈谴责了我国针对蒙古的军事行动，他说：“苏联将会以一切代建保卫社会主义蒙古，免遭中国帝国主义的侵略，捍卫蒙古人民来之不易的独立，不论代价如何！”"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	event_def.description = TXT_DESC_PRE + _leader_name() + TXT_DESC_TAIL


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	context["result_text"] = TXT_R_PRE + _leader_name() + TXT_R_POST
	# 原版 ingamewars[69]：中蒙战争，中国(650) vs 蒙古(350)，SovietSupportDefender
	GameManager.start_war(69, "中华人民共和国", "蒙古人民共和国", 650, 350, -1, 2)
	if ws.wars.size() > 69 and ws.wars[69] != null:
		ws.wars[69].name_war = "中蒙战争"
	var usa := ws.get_country_by_legacy_index(51)
	if usa != null and usa.has_tag("对华贸易"):
		if ws.wars.size() > 69 and ws.wars[69] != null:
			ws.wars[69].usa_side = 0
	var mongolia := ws.get_country_by_legacy_index(9)
	if mongolia != null:
		mongolia.set_tag("对华贸易", false)
		mongolia.set_tag("亲苏", true)
	var ussr := ws.get_country_by_legacy_index(7)
	if ussr != null:
		ussr.set_tag("对华贸易", false)
	ws.set_flag("relres", false)
	_add_relation(EmpireData.USSR, -1000)
	_add_power(EmpireData.USSR, -50)
	_add(W.I_PARTY_SUPPORT, 300)
	_add(W.I_ARMY, -800)
	_add(W.I_BUDGET, -200)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
