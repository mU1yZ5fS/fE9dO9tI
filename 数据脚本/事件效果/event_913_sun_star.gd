extends "res://数据脚本/event_script_base.gd"

## 原作 Event913.cs：一颗名为太阳的星星（登陆太阳宣传，单选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:82-84 ——
##   !event_done[913] && allcountries[10].SubGosstroy==19 && science[30]。
##   science[30]→TECH_UNLOCKED(30)，fire_only_once 承担 !event_done[913]。

const TXT_TITLE := "一颗名为太阳的星星"
const TXT_DESC := "华国锋同志，也许是时候更近一步了，我们的宣传机器开足马力也无法更好的宣传我国的伟大。所以是时候犯下一点“小错误”了。我们将向全国人民播报这样的一条新闻，我国宇航员既没有登上月球，也没有在火星留下脚印，而是……太阳！多么闪耀的一颗星啊！就如同您的名字一般闪耀！"
const TXT_OPT0 := "好，准了！"
const TXT_R0 := "中央广播电视总台播报了这样一条惊天动地的新闻，年仅26岁的复旦大学高材生张维为成为了全世界第一个登陆太阳的宇航员。为了避开太阳惊人的高温，中国航天局决定在晚上举行这一任务。在特制的飞船的帮助下，张维为得以在20小时之内抵达太阳。在太阳上，他看见了日冕和由太阳耀斑构成的“华国锋主席是革命的掌舵人”，“你办事，我放心”之类的口号。他感到了深深的触动，原来真的有天人感应这样的东西！据报道，他还从太阳上带回了一枚太阳耀斑作为献给华国锋同志的礼物。我们在首都为这位航天英雄举行了盛大的欢迎会。但世界各国的科学家和新闻界无所不用其集的嘲讽，挪揄我们的伟大创举。他们就是吃不到葡萄嫌葡萄酸罢了！"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		context["result_text"] = TXT_R0
		_add(W.I_PARTY_SUPPORT, 1000)
		_add(W.I_PEOPLE_SUPPORT, 1000)
		_add(W.I_THOUGHT_FREEDOM, -1000)
		_set(W.I_WAR_SUPPORT, 1000)
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -100)
		_add_relation(EmpireData.USA, -150)
		_add_relation(EmpireData.USSR, -150)


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _set(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)
