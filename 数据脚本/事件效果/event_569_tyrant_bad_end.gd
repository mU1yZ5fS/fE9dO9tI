extends "res://数据脚本/event_script_base.gd"

## 原作 Event569.cs：暴君必尝恶果（沙特半岛解放战争，二选项）。
## 触发：DiploButtonScript.cs:11559 —— number_event = 569（外交按钮手动触发），无自动触发。
## 差异：
##  - data[143] 无命名键，raw index 143；
##  - AmericanSupportAttacker → usa_side=0/ussr_side=-1；TickTime(24) → fortnight_max=24；
##  - event_done[569]=false → completed_event_ids.erase("event_569")（同 Event440 约定）。

const TXT_TITLE := "暴君必尝恶果"

const TXT_DESC := "长期以来，阿拉伯半岛的大部分土地都处于沙特阿拉伯王国的控制之下，正如半岛上的各个君主国家一样，沙特阿拉伯与美国保持着“深厚的特殊友谊”（在沙特自由军官组织失败后，沙特阿拉伯请求美国在当地部署了美军基地），通过出售石油赚得盆满钵满，并对异见者进行严厉地镇压。进入冷战时期后，沙特阿拉伯的国内并不太平，国内已经爆发过多次效仿纳赛尔的未遂军事政变；而在1967年后，在左翼浪潮的影响下，阿拉伯半岛人民联盟也进行过短暂的城市游击运动（如向国防部投放炸弹）；受伊朗革命时的伊斯兰主义影响，1979年沙特也发生了两次重大骚乱——卡蒂夫起义和占领麦加大清真寺事件。但地下组织的活动仍然无法打倒沙特的专制君主制度。\n如今，美国已经无力维持其在全球的力量存在，撤走了沙特驻军。流亡阿拉伯湾、也门和约旦等国的沙特左翼人士提出了一个大胆的方案——以约旦、也门和阿拉伯湾为根据地，发起全半岛解放战争，建立统一的社会主义阿拉伯半岛共和国！\n主席同志，我们是否需要支持他们的方案？"

const TXT_OPT0 := "支持阿拉伯人民团结起来解放全半岛人民！"
const TXT_OPT0_DIS := "这太冒险了，革命也不能包办代替……"
const TXT_OPT1 := "还得再等等……"

const TXT_R0 := "我们宣布对沙特阿拉伯进行制裁，并在盟国的帮助下对沙特阿拉伯进行封锁。随着沙特阿拉伯经济陷入困难，物资短缺，工人开始发起罢工，而民众也走上街头，抗议高压的政治环境以及缺乏民主的政治制度。骚乱从卡蒂夫地区开始逐渐向全国扩散，在我们的特工的帮助下，沙特地下左翼开始煽动群众向政府机构发起冲击，并向民众发放武器，组织民兵，筑起街垒与军警对峙。同时，在另一边获得我们援助的约旦、也门和阿拉伯湾的革命政府也已完成军队集结，各国军队与沙特阿拉伯国内的革命民兵共同组成了全阿拉伯半岛革命联军，开始向沙特阿拉伯王国政府发起进攻。阿拉伯半岛最后的革命开始了！"
const TXT_R1 := "现在革命时机并未成熟，我们选择把革命计划放到未来……"

const WAR37_NAME := "全阿拉伯半岛解放战争"
const WAR37_SIDE1 := "沙特阿拉伯"
const WAR37_SIDE2 := "联合阵线"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var china := world.get_country_by_legacy_index(1)
	var c30 := world.get_country_by_legacy_index(30)
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var cond := line <= 2 and china != null and (china.government == 1 or china.sub_government == 0 \
			or ((china.government == 2 or china.sub_government == 10 or china.sub_government == 22) \
			and c30 != null and c30.government == 2))
	if cond:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], TXT_OPT1)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			if d.size() > 143:
				d[143] += 8   # 原 data[143]（无命名键）
			_add(W.I_ARMY, -150)
			GameManager.start_war(37, WAR37_SIDE1, WAR37_SIDE2, 600, 400, 0, -1)
			if ws.wars.size() > 37 and ws.wars[37] != null:
				ws.wars[37].name_war = WAR37_NAME
				ws.wars[37].fortnight_max = 24
			context["result_text"] = TXT_R0
		1:
			ws.completed_event_ids.erase("event_569")
			context["result_text"] = TXT_R1
