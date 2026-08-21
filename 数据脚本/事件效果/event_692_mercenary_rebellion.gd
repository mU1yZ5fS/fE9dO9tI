extends "res://数据脚本/event_script_base.gd"

## 原作 Event692.cs：勿忘1204年，勿忘马基雅维利教诲（雇佣兵叛乱/结局事件，单选项）。
## 触发：QueryDecisions`1 where T.cs:5773 MercenaryRebellion —— MilitaryService++；
##   >=3 且 rng(0..3)==1 → number_event=692。Godot 对应 decision_atoms.mercenary_rebellion 已就位。
## 差异：load_scene_after_click + data.ending_route=14 + LoadScene("Ending")
##   → d.ending_route=14 + game.queue_ending_after_event(14)（项目既有惯例）。

const TXT_DESC_FMT := "{0}{1}同志，自从您放开私人军事承包商，并根据合同制进行军事改革后。我国便基本成为了雇佣兵的乐土：虽说中国确实靠着这种取巧的方式大大缓解了国防压力，并能通过类似美国等移民国家的法子吸收全世界的精华。可任由这些事实上独立于我国国防系统外的客军持续做大真的是治国良策吗？更何况，这些顶着“国家赞助”头衔的安保公司内还不乏有前美国海豹部队、苏联阿尔法小组成员履历的外国老兵油子当干部。谁知道他们究竟是诚心为我国效力，还是做着两头吃的勾当。不论如何，我国的主要领导班子已对此忍无可忍……并坚决要求您对这些组织的主要头目立即采取……\n[color=red]隔WIY@412厉IQUZ&B申F￥M$#G差……\n女士们，先生们：|因为我们有责任在此为自由发声，于是，我们带着百战不殆的铁军来了。不在别处，就在中国的心脏北京。|我们明白中国人民对困乏和饥饿的恐惧，以及对分裂与腐败的憎恶。所有的一切皆出自北京官僚集团与特权阶层的倒行逆施，因为他们总是泯灭人类的爱，因为他们扼杀这一人类创造、快乐和信仰的动力。所以，中国来到了它的历史拐点：要么做出根本性变革，要么没入历史尘埃。而我们将向大家保证，我军会帮助你们克服这些困难。|当然，极端解决办法并非唯一，情况也并非无可挽回：是的，我们是师出有名的仁义之师。只要中国领导层仍表露出改正余地，我们仍将伸出双手拥抱同屋檐下的兄弟。他们可以采取一场行动，扫除潜藏在自身队伍内的机会主义者，毋庸置疑地向全世界证明它准备在革新事业上迈进巨大一步。|{0}{1}阁下，如果你希望和平，如果你希望中国与其亚洲邻国实现繁荣，如果你希望扫除国内的腐败堕落：请正视我们的诉求。|{0}{1}先生，请打开天安门！|{0}{1}先生，请在中南海迎客！[/color]"
const TXT_R0_FMT := "“一个人如果以这种雇佣军队作为基础来确保他的国家，那么他既不会稳固亦不会安全，因为这些雇佣军队是不团结的，怀有野心的，毫无纪律，不讲忠义，在朋友当中则耀武扬威，在敌人面前则表现怯懦。他们既不敬畏上帝，待人亦不讲信义；毁灭之所以迟迟出现只是由于敌人的进攻推迟罢了。”——尼科洛·马基雅维利"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	var leader := "华国锋"
	if ws.leader != null and ws.leader.name_display != "":
		leader = ws.leader.name_display
	event_def.description = TXT_DESC_FMT.replace("{0}{1}", leader)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	var leader := "华国锋"
	if ws.leader != null and ws.leader.name_display != "":
		leader = ws.leader.name_display
	context["result_text"] = TXT_R0_FMT.replace("{0}{1}", leader)
	_set_data(W.I_PARTY_SUPPORT, 0)
	_set_data(W.I_PEOPLE_SUPPORT, 0)
	_set_data(W.I_AGENTS, 0)
	# 原版 load_scene_after_click：点击结果后 data.ending_route=14 并进入 Ending。
	if d.size() > W.I_ENDING_ROUTE:
		d.ending_route = 14
	game.queue_ending_after_event(14)
