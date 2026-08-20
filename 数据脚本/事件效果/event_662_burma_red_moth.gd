extends "res://数据脚本/event_script_base.gd"

const T_662_0 := "红飞蛾，打破“四切”"
const T_662_1 := "是时候了，主席同志。如你所见，精神原子弹的战术并不完全有效。虽然我方仍能通过派遣知青与提供电台服务的方式支持缅甸革命，可迄今为止，缅甸共产党仍未取得突破性进展。北方的腊戎如同倒刺，使农村包围城市的战术数次折戟。缅军的“四切”战术更使缅甸共产党处境雪上加霜：该党依托的农村地区大都处于极度贫瘠的孤立状态，各反政府武装也都被驱赶到统治核心之外的缅北边境区域各自狗斗；与此同时，缅军还以道路为中心动员民团和正规军，对反抗组织逐个击破，甚至不吝通过制造饥荒与屠杀的方式摧毁其根据地。如果仅靠人力物力支持，还远不足以击破“四切”。毕竟，土地革命战争的经验充分说明了这点：割据的前提是空间机动与根据地建设。只有恢复对伊洛瓦底三角洲与勃固发达地区的根据地与农村游击力量，缅甸共产党才能重新掌握主动权——这意味着我们必须得为一场大规模运动战做准备。当然，除却以军事进攻恢复控制权外，我们还可以通过统一战线的方式聚拢盟友共同击溃缅军：仍在伊洛瓦底三角洲活跃的该国第二大武装克伦民族联盟便是极好的合作伙伴。他们的历史可上溯英属印度时代，以血税换取默许独立的克伦族雇佣兵，并在拒绝《彬龙协议》后同缅甸当局长期交火。不过，和它们做交易必然意味着大步妥协……主席同志，您怎么看？"
const T_662_2 := "我们将继续支持缅共的北部游击运动"
const T_662_3 := "说真的，你还信那一套费力不讨好的兄弟情吗？"
const T_662_4 := "好问题，好就好在相关事宜无需再提"
const T_662_5 := "世界革命靠ABC！"
const T_662_6 := "让我们实现全缅甸各族的大团结，以民族统一战线之名打击“四切”！"
const T_662_7 := "和土司地主们结盟？呸！"
const T_662_8 := "世界革命靠ABC，我们应为此不遗余力。是时候让缅甸同志转向战略进攻了！"
const T_662_9 := "东南亚的雨林使我们举步维艰"
const T_662_10 := "让我们重组缅共，同时恢复伊洛瓦迪游击区！"
const T_662_11 := "红旗派已油尽灯枯，无需输血续命"
const T_662_13 := "红飞蛾，打破“四切”"
const T_662_14 := "即使我们承诺并继续支持缅甸共产党的革命事业，可局势仍未发生根本改观。长期的消耗与贫困战时经济两者共同摧毁着缅共队伍，其主要军事领导人的精气神一日比一日颓废。“四切”战术的封锁只会使其向金三角地区的“传统智慧”靠拢——这就是“特货”贸易、边界走私与军官军阀化现象越加猖獗的原因……"
const T_662_15 := "“错过了知青返城，|错过了大学的校门，|错过了一切不该错过的人生机会，|15年的青春岁月，|我想——|革命是不朽的。”\n显然，会在缅甸留下孤军的可不只有国民党……\n“一切伟大的世界历史事变和人物，可以说都出现两次。”——G·W·F·黑格尔"
const T_662_16 := "我们决定以中介人的身份推进缅甸共产党同克伦民族联盟达成统一战线，要求两位死敌效仿毛泽东主席与蒋介石委员长的经验共商国家大计。而这更为建立一个缅甸版本的大联盟政府铺平了道路：各路反政府武装在中国的物资统筹下统一意见，并通过吸纳缅甸共产党（红旗派）的前盟友若开解放党，克钦独立组织等各路豪杰持续发展壮大！新的“民族团结联盟”使我们能够在缅甸更好站稳脚跟并拓展影响力。当然，这也意味着我们可以通过操纵“民族团结联盟”内的任意一方决定该国未来。时间将证明我们的决策是否正确。\n奈温政府对此气急败坏，决定再次同中国断交并转向完全孤立。与此同时，我们在缅军的队伍内发现了苏联克格勃特工与古巴雇佣军的身影。"
const T_662_17 := "通过渗透泰国边境的但那沙林和南掸邦主干道，我们决定在不计成本的情况下持续派遣知青、老兵、新式装备、以及武装的泰国共产党志愿者穿过国界，并进入缅甸筹备进攻。缅甸共产党就此成功发起战略进攻，夺下了腊戎和东枝两处掸邦重要据点，更在全国掀起了农民游击战高潮！\n奈温政府对此气急败坏，决定再次同中国断交并转向完全孤立。与此同时，我们在缅军的队伍内发现了苏联克格勃特工、美国中情局线人与以色列摩萨德的身影。"
const T_662_18 := "中国政局的剧变与缅甸共产党领导层流亡北京的境况使得我们有建立新生缅共的千载难逢机会——一方面，我们将清洗缅甸共产党的毛派领导层；一方面我们将启动缅甸共产党（红旗派）与缅甸共产党（白旗派）两者的合并工作，并恢复其在城市内的党务工作。通过采纳托洛茨基的世界革命和不断革命论，我们得以更公开地介入缅甸事务。不久后，巴登顶便因军事投机而引咎辞去领导人职务。过去因批判巴登顶“执行刘少奇路线”而不得不在我国寻求庇护的前造反派干部敏拉也宽则成为了新一代缅共的领导人。久经沙场的前缅甸共产党（红旗派）领导人，目前研究托洛茨基思想的德钦梭也在我们的秘密帮助下脱逃，并同自己新组织的队伍并入重组的缅共。与此同时，我们也已不计成本的方式持续派遣知青、老兵、新式装备、以及武装的第四国际志愿者穿过国界，并进入缅甸筹备进攻……希望实现重组与新生的缅共可以一举推翻法西斯主义官僚领导下的伪马克思主义政权！"


## 原作 Event662.cs：红飞蛾，打破“四切”（缅甸，五选项）。
## 触发：TimeScript.cs:11107-11112 —— allcountries[33].inflCh>=70 || inflCh<40。
## 差异：
##  - inflCh → CountryData.influence_china；ExprNode 暂不支持，触发走 trigger_script（本脚本 evaluate）。
##  - <color=red> 标签剥除。
##  - 死代码 result_num==5 跳过。

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var burma := world.get_country_by_legacy_index(33)
	if burma == null:
		return false
	return burma.influence_china >= 70 or burma.influence_china < 40


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	event_def.title = T_662_0
	event_def.description = T_662_1
	var opt := event_def.options
	var mod6_active := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active
	var mod3_active := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var burma := world.get_country_by_legacy_index(34)
	if mod6_active:
		_enable(opt[0], T_662_2)
	else:
		_disable(opt[0], T_662_3)
	if line > 0 or not mod6_active:
		_enable(opt[1], T_662_4)
	else:
		_disable(opt[1], T_662_5)
	if line > 1:
		_enable(opt[2], T_662_6)
	else:
		_disable(opt[2], T_662_7)
	if mod6_active and world.is_socialism(burma, true) and burma != null and burma.has_tag("亲中"):
		_enable(opt[3], T_662_8)
	else:
		_disable(opt[3], T_662_9)
	if not mod3_active:
		_enable(opt[4], T_662_10)
	else:
		_disable(opt[4], T_662_11)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var burma := ws.get_country_by_legacy_index(33)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if burma != null:
				burma.influence_china -= 30
			context["result_text"] = T_662_14
		1:
			if burma != null:
				burma.influence_china = 0
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, -40)
			context["result_text"] = T_662_15
		2:
			if burma != null:
				burma.set_tag("对华贸易", false)
			_add(W.I_AGENTS, -100)
			context["result_text"] = T_662_16
		3:
			if burma != null:
				burma.set_tag("对华贸易", false)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -200)
			if burma != null:
				burma.influence_china += 10
			context["result_text"] = T_662_17
		4:
			if burma != null:
				burma.set_tag("对华贸易", false)
			_add(W.I_AGENTS, -200)
			_add(W.I_ARMY, -200)
			context["result_text"] = T_662_18



