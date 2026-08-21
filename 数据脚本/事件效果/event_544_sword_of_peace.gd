extends "res://数据脚本/event_script_base.gd"

## 原作 Event544.cs：和平利剑（核战略，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:222-224 ——
##   science[21] && science[29] && 工业>=1100 && 年>=1984。
## 差异：old_modify_desc[50] → ModifierCatalog.get_def(50)。

const TXT_R0 := "在您的指示下，国防科委继续深化了现有的方略，把原先的640计划继续扩大，并且加大对640-3中的激光反导武器这一具有前瞻性战略武器的投资。在全体技术人员的努力下，代号为“长矛”的激光反导武器原型机最大输出功率达到了恐怖的6吉瓦，而这一武器不久后的量产代表着帝国主义再也不能在中国的领空上猖獗了。"
const TXT_R1 := "国防科委迅速改变了过去的方针，并拟稿了《新一代核武器战略发展计划书》并交给最高领导人和中央军委决断。在得到支持和资金投入后，多个军工院系很快联合攻坚开发了我国的新一代核弹和导弹。很快，更具针对性的小型核武器和非常规的核磁爆弹的实验型相继推出，而高超音速的导弹也初步研究完成。帝国主义者更是寝食难安了！"
const TXT_R2 := "作为这个世界上各国心照不宣的第三极，这两个方案我们完全能同时应付。面对着中央拨来的海量资金，国防科委立马开展设计两套计划并扩充了几乎一倍的人员。原先的640计划被继续扩大，而新一代核武器也得到开发。不久后我们将一手拿着最先进的激光反导武器，一手拿着最先进的核弹导弹，帝国主义凭借着核讹诈耀武扬威的日子不多了！"
const TXT_R3 := "好吧，只能希望这些省下来的钱确实能用在经济建设上……"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_DIPLO, -50)
			_add(W.I_BUDGET, -100)
			_set_mod50("核防御措施：", "军力+0.7，外交声誉-0.5")
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, 150)
			_add(W.I_DIPLO, 30)
			_add(W.I_BUDGET, -150)
			_set_mod50("核威慑措施：", "军力+2.0，美苏关系-0.2")
			context["result_text"] = TXT_R1
		2:
			_add(W.I_PARTY_SUPPORT, 250)
			_add(W.I_PEOPLE_SUPPORT, 250)
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -250)
			_set_mod50("核防御与核威慑措施：", "军力+4.0，美苏关系-0.4，可禁运美苏")
			context["result_text"] = TXT_R2
		3:
			context["result_text"] = TXT_R3


func _set_mod50(title: String, effect: String) -> void:
	var def := ModifierCatalog.get_def(50)
	if def != null:
		def.name_zh = title
		def.effect_zh = effect
