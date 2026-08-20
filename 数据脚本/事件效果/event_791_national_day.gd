extends "res://数据脚本/event_script_base.gd"

## 原作 Event791.cs：1979年国庆节（三十年国庆讲话，三选项）。
## 触发：TimeScript.cs:10038-10044 —— (月>=10 且 年>=1979) 或 年>=1980。
## 动态文案钩子 prepare(event_def, world)（挂 display_script）：
##  - 事件描述与结果文案插入当前领导人姓名（原版 names1[name_1]+" "+names2[name_2]）。
##  - 选项0 原版按 (name_1==2&&name_2==2&&data[56]<=1)||(name_1==3&&name_2==3) 销毁按钮；
##    Godot 用 prepare 动态设置 enable_condition（不可达 ExprNode）等价灰显。
## 差异：字符间空格排版不保留；show_notification=false（项目约定）。

const TXT_OPT0_OK := "谈谈对国际共运的希冀"
const TXT_OPT0_OFF := "没人想你讲这些东西"

const TXT_BODY := "主席同志！1979年是中华人民共和国挣脱法西斯主义者的枷锁，从而让人民翻身做主人的第三十年。按照惯例，"
const TXT_BODY2 := "主席应该说点什么。党内的左派希望谈谈对于国际共运的事，温和派希望谈谈对人民的关切并鼓励奋斗。也有党员希望谈谈国际和平，着手修复和别的国家的关系。但是演讲稿毕竟还在您手上，您不妨看看？"

const TXT_R0_OPEN := "在大会上，"
const TXT_R0_SPEECH := "同志说到：“今天，我们站在北京，放眼全球各地，无处不是英勇的民族和革命战士为了自己的未来而斗争。我国一贯，且将永远支持你们！”"
const TXT_R0_PARADE := "主席按下电钮后，军乐队吹响了国歌，五星红旗慢慢的升起，所有人都注视着这一庄严肃穆的时刻。随后便是阅兵式，手持着五六式冲锋枪和六三式自动步枪的解放军战士踏着整齐的步子通过天安门。\n接着是一系列代表各行各业的方阵，工人、农民、医生、教师等，他们身着各自的工作服装，展示着自己的职业精神和技能。巨大的花车也在游行中穿梭，车上装饰着灿烂的花朵和鲜艳的灯饰，各种主题的花车象征着祖国的繁荣和发展。\n观众席上，人们挥舞着国旗和彩旗，欢呼雀跃，为游行队伍加油助威。\n整个游行过程中，天空中不时有飞机编队划过，划出绚丽的彩虹轨迹，三十门五十六响礼炮更是增添了庆典的气氛。人们欢呼雀跃，掌声、欢呼声、歌声此起彼伏，将整个北京都包裹在欢乐与激情中。\n当举着火把的群众绕城一周后，国庆典礼正式结束了。但心中的喜悦和对祖国的热爱却永远留存着。"

const TXT_R1_SPEECH := "同志说到：“我们伟大祖国的建设离不开人民的支持，我在这里代表党中央，向全国的人民献上我的感谢！”"

const TXT_R2_SPEECH := "同志说到：“现在的社会不是对抗，而是合作共赢，只有放下了武器，我们才能更好的拿起锤子，只有这样我们才能更好的建设祖国。我们希望和平与发展，但也绝对不会放弃我们的尊严！”"

const TXT_INTRO := "在国庆的早晨，整个城市都洋溢着喜庆的气氛。大街小巷装饰一新，五彩缤纷的旗帜和花朵装点着每个角落。人们早早地涌向游行路线，带着笑容和期待。\n在"


## 显示前动态钩子（game_manager.gd:494-497 调用 display_script.prepare）
func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var leader_name := _leader_name(world)
	event_def.description = leader_name + TXT_BODY + leader_name + TXT_BODY2
	if event_def.options.size() > 0:
		var opt: EventOption = event_def.options[0]
		if _option0_available(world):
			opt.text = TXT_OPT0_OK
			opt.disabled_text = ""
			opt.enable_condition = null
		else:
			opt.text = TXT_OPT0_OFF
			opt.disabled_text = TXT_OPT0_OFF
			opt.enable_condition = _never_node()


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var leader_name := _leader_name(ws)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, -50)
			_add(W.I_MANPOWER, 200)
			_add(W.I_DIPLO, 50)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			context["result_text"] = \
				TXT_R0_OPEN + leader_name + TXT_R0_SPEECH + "\n" + TXT_INTRO + leader_name + TXT_R0_PARADE
		1:
			_add(W.I_PEOPLE_SUPPORT, 200)
			_add(W.I_THOUGHT_FREEDOM, -100)
			_add(W.I_INDUSTRY, 50)
			_add(W.I_AGRICULTURE, 50)
			_add(W.I_SERVICES, 50)
			context["result_text"] = \
				TXT_R0_OPEN + leader_name + TXT_R1_SPEECH + "\n" + TXT_INTRO + leader_name + TXT_R0_PARADE
		2:
			_add(W.I_PARTY_SUPPORT, 80)
			_add(W.I_PEOPLE_SUPPORT, 80)
			_add(W.I_DIPLO, -100)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, 150)
			context["result_text"] = \
				TXT_R0_OPEN + leader_name + TXT_R2_SPEECH + "\n" + TXT_INTRO + leader_name + TXT_R0_PARADE


func _leader_name(world: WorldState) -> String:
	if world.leader != null and world.leader.name_display != "":
		return world.leader.name_display
	return "华国锋"


## Event791.cs VariantsOfEvents 选项0显隐条件：
## (name_1==2 && name_2==2 && data[56]<=1) || (name_1==3 && name_2==3)
func _option0_available(world: WorldState) -> bool:
	var leader := world.leader
	if leader == null:
		return false
	var political_line := world.数值表[W.I_POLITICAL_LINE] if world.数值表.size() > W.I_POLITICAL_LINE else 1
	return (leader.name_first == 2 and leader.name_last == 2 and political_line <= 1) \
		or (leader.name_first == 3 and leader.name_last == 3)


## 不可达 ExprNode（灰显用，值域取不可能阈值）。
func _never_node() -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	return n




