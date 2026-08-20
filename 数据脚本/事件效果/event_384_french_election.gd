extends "res://数据脚本/event_script_base.gd"

## 原作 Event384.cs：法国选举（五选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - YugAgree → ws.get_flag("YugAgree")；
##  - 描述与选项按 YugAgree 动态改写；result<4 扣除资源后返回对应文本。

const TXT_DESC_YUG := "自上次总统选举以来，法国国内的政治局势发生了显著变化。\n由法国社会党领导人弗朗索瓦·密特朗与法国共产党前领导人乔治·马歇在1972年建立的左翼总纲领联盟已经成了徒有其表的联合。在接下来的选举中，法国左派只能各自为战，且无法提名单一候选人。在这一情况下，法国共产党新任总书记正尝试与社会党及其左翼达成更深入的合作，以追求“共同反对资本主义”的目标促进左翼力量的壮大和团结，以追求社会变革。\n法国右翼一方的局势也并不明朗。由法国民主联盟提名的现任总统瓦莱里·吉斯卡尔·德斯坦，将与身为戴高乐主义者，来自保卫共和联盟的前总理雅克·希拉克对垒。\n现在，是时候让我们寻找最值得支持的棋子了。首位候选人密特朗因其可疑的观点，以及同样阴云密布的过去而并不受左派欢迎。罗兰·勒罗伊领导的法共新任领导层表现出的革新以及与社会党的团结态度也吸引了一部分支持者。\n瓦莱里·吉斯卡尔·德斯坦则在其任期中选择同勃列日涅夫交好，但更倾向于奉行亲美政策，并带领法国完全回归北约。这让他同试图延续戴高乐政策的雅克·希拉克格格不入。\n我们应当支持谁？"
const TXT_OPT1_YUG := "我们选择支持勒罗伊"
const TXT_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_R0 := "我们为弗朗索瓦·密特朗开展竞选活动提供了赞助，让我们瞧瞧法国人有没有把这笔钱花在刀刃上。首轮选举将在四月举行，第二轮选举（如果没有候选人获得超过50%的选票，则进行此轮选举）则被安排在五月。"
const TXT_R1 := "我们为乔治·马歇开展竞选活动提供了赞助，让我们瞧瞧法国人有没有把这笔钱花在刀刃上。首轮选举将在四月举行，第二轮选举（如果没有候选人获得超过50%的选票，则进行此轮选举）则被安排在五月。"
const TXT_R2 := "我们为瓦莱里·吉斯卡尔·德斯坦开展竞选活动提供了赞助，让我们瞧瞧法国人有没有把这笔钱花在刀刃上。首轮选举将在四月举行，第二轮选举（如果没有候选人获得超过50%的选票，则进行此轮选举）则被安排在五月。"
const TXT_R3 := "我们为雅克·希拉克开展竞选活动提供了赞助，让我们瞧瞧法国人有没有把这笔钱花在刀刃上。首轮选举将在四月举行，第二轮选举（如果没有候选人获得超过50%的选票，则进行此轮选举）则被安排在五月。"
const TXT_R4 := "我们决定同选举保持距离。首轮选举将在四月举行，第二轮选举（如果没有候选人获得超过50%的选票，则进行此轮选举）则被安排在五月。"
const TXT_R1_YUG := "我们为罗兰·勒罗伊开展竞选活动提供了赞助，让我们瞧瞧法国人有没有把这笔钱花在刀刃上。首轮选举将在四月举行，第二轮选举（如果没有候选人获得超过50%的选票，则进行此轮选举）则被安排在五月。"


const TXT_LABEL_BUDGET := "预算"
const TXT_LABEL_AGENTS := "特工网络"
const TXT_LABEL_ARMY := "军事实力"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var opt := event_def.options
	if world.get_flag("YugAgree"):
		event_def.description = TXT_DESC_YUG
	_prepare_cost(opt[0], event_def.options[0].text)
	if world.get_flag("YugAgree"):
		_prepare_cost(opt[1], TXT_OPT1_YUG)
	else:
		_prepare_cost(opt[1], event_def.options[1].text)
	_prepare_cost(opt[2], event_def.options[2].text)
	_prepare_cost(opt[3], event_def.options[3].text)
	_enable(opt[4], event_def.options[4].text)


func _prepare_cost(opt: EventOption, text: String) -> void:
	if _d(W.I_AGENTS) >= 50 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 30:
		_enable(opt, text)
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 30:
		_disable(opt, TXT_DIS_BUDGET.format([3]))
	else:
		_disable(opt, TXT_DIS_AGENTS.format([5]))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt < 4:
		_add(W.I_AGENTS, -50)
		_add(W.I_BUDGET, -30)
	if ws.get_flag("YugAgree") and opt == 1:
		context["result_text"] = TXT_R1_YUG
		return
	match opt:
		0: context["result_text"] = TXT_R0
		1: context["result_text"] = TXT_R1
		2: context["result_text"] = TXT_R2
		3: context["result_text"] = TXT_R3
		_: context["result_text"] = TXT_R4




func _d(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0



