extends "res://数据脚本/event_script_base.gd"

## 原作 Event91.cs：仰光爆炸事件 / 墨西哥爆炸案（按 c33 社会主义与否双标题）。
## 触发：TimeScript.cs:10752-10758 ——
##   (日>=9 且 月>=10 且 年>=1983 或 年>=1984) && c46.Gosstroy==0
##   && c46.SubGosstroy==7 && !wars[90].is_going && !c10.parts[0]
##   （c10.parts[0] 未置位时默认 false，端口未建模 → 视为恒真，注释保留）。
## 差异：标题/描述 prepare 动态改写。

const TXT_R0 := "作为对事件的回应，整个“文明世界”都对朝鲜表达了愤怒。我们并未做出官方回应，但在《人民日报》上发表了一篇文章，强烈地谴责了朝鲜的恐怖主义手段。同时，在朝韩边境上，双方都在做出了武装挑衅…"

const TXT_R1 := "作为对事件的回应，整个“文明世界”都对朝鲜表达了愤怒。我们完全支持朝鲜的姿态，将事件称为韩国的挑衅行为，并谴责了韩国。同时，在朝韩边境上，双方都在做出了武装挑衅…"

const TXT_R2 := "作为对事件的回应，整个“文明世界”都对朝鲜表达了愤怒。同时，在朝韩边境上，双方都在做出了武装挑衅…"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null:
		return
	var burma := world.get_country_by_legacy_index(33)
	if burma != null and world.is_socialism(burma, true):
		event_def.title = "墨西哥爆炸案"
		event_def.description = "出于让墨西哥支持汉城奥运会的需要，全斗焕率团前往墨西哥访问。韩国代表团原计划在墨西哥革命纪念塔处献花，但由于交通堵塞，全斗焕的专车延误近半个小时。而在墨西哥总统米格尔·德拉马德里等人等待时，由部分朝鲜特工和地下革命工人党-人民联盟的游击战士组成的敢死队引爆了事先安装在革命纪念塔附近的炸弹。爆炸瞬间杀死了数名墨西哥高官，米格尔·德拉马德里总统由于距离炸弹较远幸免于难，敢死队在爆炸后和总统卫队进行交火试图突围，但是寡不敌众，最终被尽数消灭。\n此次爆炸案后，墨西哥宣布与朝鲜全面断交，韩国和西方阵营则认为此次袭击是朝鲜极权恐怖主义的又一大体现。而根据朝鲜的说法，这些特工均为叛逃分子，非朝鲜官方所为，并声称一切指控均为西方阵营空穴来风的污蔑。"
	else:
		event_def.title = "仰光爆炸事件"
		event_def.description = "根据我们的情报，今天在缅甸首都发生了一起恐怖袭击，目的是刺杀韩国总统全斗焕。由于全斗焕在爆炸发生两分钟后抵达现场，他本人幸免于难，但有17名韩国代表团成员丧生。恐怖分子很快被抓获，经过审问，他们承认自己是朝鲜军队的军官。而朝鲜政府矢口否认与此事有任何牵连，但实际上，这一事件让我们有机会重新挑起朝鲜和韩国之间的对抗。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, -10)
			_add_relation(EmpireData.USA, 100)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_DIPLO, 20)
			_add_relation(EmpireData.USA, -80)
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)
