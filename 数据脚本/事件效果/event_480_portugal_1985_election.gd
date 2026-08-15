extends "res://数据脚本/event_script_base.gd"

const S_14 := "葡萄牙1985年议会选举"
const S_15 := "社会党和社民党的“中央集团“终于解体了。两党在此前就已多次产生分歧，最后，因为社民党主席卡洛斯·莫塔·平托在1986年总统选举候选人问题上同联盟内大部分人都有分歧，他最终被迫辞职。社民党代表大会任命前财政部长阿尼巴尔·卡瓦科·席尔瓦取代了他的职位，成为该党新的主席。同时，苏亚雷斯总理决定进行部长改组，由鲁伊·马切特接替平托担任国防部长和副总理的职位。由于社民党党内和国家层面的权力更迭，中央集团两党间就继续组建联合政府展开谈判。在谈判失败后，社会民主党的部长们于6月13日向共和国总统提交了辞呈。12天后，社会党因为没能获得议会关于组建少数派政府的信任，马里奥·苏亚雷斯向共和国总统提交了辞呈，安东尼奥·拉马尔霍·埃内亚斯总统宣布将在10月6日提前举行立法选举。"
const S_21 := "接下来将发生什么？"
const S_22 := "我们为什么要陪他们玩选举游戏？"
const S_27 := "葡萄牙1985年议会选举"
const S_30 := "社民党在此次选举取得了历史性的胜利，它获得了29.9%的选票和88个席位，成为了议会第一大党。由阿尔梅达·桑托斯领导的社会党则在全国选举中取得了有史以来最差的成绩，它获得了20.8%的选票，失去了40多个议席。此次选举中最令人惊讶的是民主复兴党的崛起，该党与埃内亚斯总统关系密切，得益于民众对现有政党的幻想破灭，他们赢得了18%的选票和45个席位。共产党领导的联合人民联盟失去了6个席位，获得了15.5%的选票。人民党获得了22个议席和10%的选票。社民党领导人卡瓦科·席尔瓦成为了新的总理，他成功在议会内取得了人民党和民主复兴党的支持，组建了少数派政府。"


## 原作 Event480.cs：葡萄牙1985年议会选举（单选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1489-1491 ——
##   event_done[479] && resultOfEvents[479]==1 && 日期>=1985.10.6。
## 差异：原版 kolvo_variant=1 但写了 button_text[1]，UI 只显示按钮0；
##   button_text[1] 原样保留为 S_22 常量以通过逐字自检，不进入选项。

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_add_power(EmpireData.USA, 50)
	context["result_text"] = S_30


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)
