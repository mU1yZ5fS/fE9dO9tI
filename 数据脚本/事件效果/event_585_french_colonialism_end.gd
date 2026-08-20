extends "res://数据脚本/event_script_base.gd"

## 原作 Event585.cs：法兰西殖民主义的终结（吉布提独立，三选项）。
## 触发：ReqEventForDLC02.cs:829-832 —— (日>=8 且 月>=5 且 年>=1977) || (月>=6 且 年>=1977) || 年>=1978
##   → DATE_AFTER 1977.5.8。
## 差异：
##  - 选项显隐 prepare 动态改写；name → chinese_name；Torg → 对华贸易；
##  - proprc → 亲中；names1+names2 → _leader_name()；
##  - resultOfEvents 缺省按原版 int 默认 0 处理。



const TXT_OPT1_DIS := "我们没有兴趣参与他们的事情"
const TXT_OPT2_DIS := "他们还是太弱小了"

const TXT_R0 := "又一个国家从帝国主义的压迫中解放了出来。"
const TXT_R1_A := "我们承认了吉布提的独立，借助坦桑尼亚经验鼓励哈桑总统建立一个泛左翼的政党——人民革命运动党。该党由联合原全国独立联盟，索马里解放阵线，吉布提解放运动，人民解放运动等组织的部分人士组成。所有议员，政府成员和政界知名人士均为该党成员，所有公民均被号召参加。同时取缔了所有反对党，该党则被宣布为唯一的合法政党。第一次全国代表大会再次确定了古莱德主席等领导人的地位和该党的政策。该党章程规定其目标是“使不利于实现人民福利的各松散的力量统一起来”，“迅速使国家非部族主义化”，“在全国各阶级团结的基础上，从事国家的经济、政治和文化方面的建设。”章程还规定该国和索马里是“同根同源的革命战友，应展开必要的合作，从而实现索马里民族乃至非洲的统一”。他们事实上邀请索马里陆军取代了自己的武装力量，仅仅保留了治安部队。而我们作为幕后推手，自然也得到了一些好处。\n西亚德·巴雷少将非常感谢我们，他在摩加迪沙的群众大会上说到：“"
const TXT_R1_B := "主席是索马里人民的最热忱的革命战友，可以说是大恩人，大救星”。"
const TXT_R2_A := "意识到一个索马里占据主导的非洲之角并不符合我们的均势思想，我们将目光投向了阿法尔人。他们是埃塞人天生的盟友，而埃塞的背后是谁我们都知道。\n在亚丁，外联部的同志设法将三个阿法尔人组织-吉布提修正秩序行动、恢复权利和平等阵线以及吉布提爱国抵抗阵线的合并事宜达成了磋商，组成了FRUD（恢复统一与民主联盟）。"
const TXT_R2_MENGISTU := "海尔·马里亚姆·门格斯图上校"
const TXT_R2_BENTI := "特法里·本蒂"
const TXT_R2_B := "亲切的接见了FRUD的领导人艾哈迈德·迪尼·艾哈迈德。在埃塞和南也门的苏军帮助下，FRUD的武装力量“人民冲锋队”在北部发起了和政府军的战争。而吉布提的新政府指控苏联和我们在背后试图推翻政府，西亚德·巴雷少校自然支持索马里人的政府，但出于同我们和苏联合作的需要，他只得转而指控美帝国主义者。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if line <= 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	var ussr_rel := world.empires[EmpireData.USSR].relations if world.empires.size() > EmpireData.USSR \
			and world.empires[EmpireData.USSR] != null else 0
	if ussr_rel <= 700:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c106 := ws.get_country_by_legacy_index(106)
	var c41 := ws.get_country_by_legacy_index(41)
	if c106 != null:
		c106.government = 2
		c106.sub_government = 8
		c106.chinese_name = "吉布提共和国"
		_leave_alliances(c106)
	# 地图归属必须无条件执行：即使旧存档缺 106 号国，领土也要从法国 220 转给吉布提 522。
	if GameManager != null:
		GameManager.set_map_region_owner([366, 367, 368, 370, 376, 2032], 522)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			var text := TXT_R1_A + _leader_name() + TXT_R1_B
			_add(W.I_BUDGET, -20)
			_add(W.I_AGENTS, -20)
			if c106 != null:
				c106.government = 1
				c106.sub_government = 1
				_leave_alliances(c106)
				c106.set_tag("对华贸易", true)
				c106.set_tag("亲中", true)
				c106.social_stability = 1000
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 10
			_add(W.I_DIPLO, 5)
			context["result_text"] = text
		2:
			var leader := TXT_R2_MENGISTU if c41 != null and c41.sub_government == 10 else TXT_R2_BENTI
			var text := TXT_R2_A + leader + TXT_R2_B
			if c41 != null:
				c41.set_tag("对华贸易", true)
			context["result_text"] = text


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
