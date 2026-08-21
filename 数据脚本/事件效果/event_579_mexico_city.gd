extends "res://数据脚本/event_script_base.gd"

## 原作 Event579.cs：在那墨西哥城（墨西哥城地震，三选项）。
## 触发：ReqEventForDLC02.cs:804-807 —— (日>=19 且 月>=9 且 年>=1985) || (月>=10 且 年>=1985) || 年>=1986
##   → DATE_AFTER 1985.9.19。
## 差异：
##  - 选项显隐 prepare 动态改写；proprc → 亲中；Vyshi → 亲美；
##  - resultOfEvents[577]/[578] 缺省按原版 int 默认 0；cw → 内战中；
##  - AmericanSupportAttacker.SovietSupportDefender → usa_side = GameConstants.WarSide.SIDE1/ussr_side = GameConstants.WarSide.SIDE2；
##    仅 AmericanSupportAttacker → usa_side = GameConstants.WarSide.SIDE1/ussr_side = GameConstants.WarSide.NONE；TickTime(24) → fortnight_max=24。



const TXT_OPT1_DIS := "我们不能干涉主权国家的内政"
const TXT_OPT2_DIS := "21世纪回不到19世纪。"

const TXT_R0_BASE := "由国家地震局组建的中国地震代表团在12月份访问了墨西哥城。对墨西哥城地震发生的原因以及过程进行了科学的判断和分析，我们得以从墨西哥城地址中得到经验，吸取教训。在12月171日，中国地震代表团团长谢礼立副教授应墨西哥国家电视台的邀请作了长达22分钟的电视直播讲话。转达了中国广大地震科学工作者对墨西哥地震学家和地震工程师以及广大墨西哥人民的慰问……\n因为在地震过程中失败的领导和日益崩溃的救济局势，米格尔·德拉马德里完全失去了人民的一切信任，预计，下一任总统会是"
const TXT_R0_SALINAS := "他的哈佛校友者卡洛斯·萨利纳斯。"
const TXT_R0_CARDENAS := "夸乌特莫克·卡德纳斯。"
const TXT_R0_CLOUTHIER := "曼努埃尔·克卢西耶"
const TXT_R1 := "正是看到了墨西哥政府公信力面临的危机，同时墨西哥政局不稳，派系斗争激烈之际，南方民主共和国的成立，宣告了墨西哥政府的武装部队基本被摧毁。我们决定开始全面支持墨西哥革命。大批中国货轮进入加勒比海，苏联人更是欣喜若狂，他们也开始迅速和我方接触并开始敲定援助事宜。哪怕是不结盟运动都选择了沉默。很快，墨西哥南方解放军发起了对北方革命制度党政府的全面进攻，古巴军人和秘鲁军人一起出现在战场上，甚至连智利人和委内瑞拉人的身影都出现了。\n米格尔·德拉马德里总统决定向北方邻居请求帮助，很快，墨西哥北方局势日益混乱，选举被暂停，一切政治自由都被消灭。革命制度党丢下了一切伪装，开始大量的签署与美加的军事合作条约。国际雇佣兵和美国援助开始进入墨西哥。毒品卡特尔和地方卡西克民团开始大规模出现，据卫星观测，美军以及开始在德克萨斯州边境戒备……此乃大争之世……"
const TXT_R2 := "正是看到了墨西哥政府公信力面临的危机，我们所笼络的网络终于开始起到作用了：在瓜纳华托州突然兴起了“自由墨西哥临时政府”-该州州长只是第一个不满意与PRI控制力减弱的州长，很快吸引到了南方的许多州长的支持，发起反叛。他们指责PRI政府剿匪剿共不力，以无神论荼毒国家多年，将国家的尊严几乎消磨殆尽。一场内战在墨西哥开始了-而新生的“自由墨西哥政府”立刻获得了来自欧洲的法西斯主义者的承认和支持。\n米格尔·德拉马德里总统决定向北方邻居请求帮助，而美国立刻开始封锁海域，以阻止武器流入墨西哥。很快，墨西哥北方局势日益混乱，选举被暂停，一切政治自由都被消灭。革命制度党丢下了一切伪装，开始大量的签署与美加的军事合作条约。国际雇佣兵和美国援助开始进入墨西哥。毒品卡特尔和地方卡西克民团开始大规模出现。"

const WAR46_NAME := "墨西哥-南墨西哥之战"
const WAR46_SIDE1 := "墨西哥合众国政府"
const WAR46_SIDE2 := "墨西哥南方民主共和国"
const WAR47_NAME := "墨西哥内战"
const WAR47_SIDE1 := "墨西哥合众国政府"
const WAR47_SIDE2 := "墨西哥教权派"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var num := 0
	for i in range(71, 84):
		var c := world.get_country_by_legacy_index(i)
		if c != null and c.has_tag("亲中"):
			num += 1
	for c in world.countries:
		if c != null and c.原版序号 >= 138 and c.has_tag("亲中"):
			num += 1
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var c140 := world.get_country_by_legacy_index(140)
	var c1 := world.get_country_by_legacy_index(1)
	var r577 := int(world.completed_event_ids.get("event_577", 0))
	var r578 := int(world.completed_event_ids.get("event_578", 0))
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if line == 0 and num >= 7 and c140 != null and c140.parts.size() > 0 and c140.parts[0] \
			and world.influence_prc >= 1000:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if data.size() > W.I_WAR_SUPPORT and data.war_support >= 700 \
			and c1 != null and c1.sub_government == GameConstants.SubGovernment.NEO_FASCIST and c140 != null and c140.stab == 2 \
			and r577 == 3 and r578 == 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c140 := ws.get_country_by_legacy_index(140)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := TXT_R0_BASE
			if c140 == null or not c140.内战中:
				text += TXT_R0_SALINAS
				if c140 != null:
					c140.government = GameConstants.Government.LIBERAL
					c140.sub_government = GameConstants.SubGovernment.LIBERAL
					c140.set_tag("亲美", true)
			else:
				var r577 := int(ws.completed_event_ids.get("event_577", 0))
				if r577 == 1:
					text += TXT_R0_CARDENAS
					if c140 != null:
						c140.government = GameConstants.Government.REFORMIST
						c140.sub_government = GameConstants.SubGovernment.PRAGMATIST
						c140.set_tag("亲美", false)
				elif r577 == 2:
					text += TXT_R0_CLOUTHIER
					if c140 != null:
						c140.government = GameConstants.Government.LIBERAL
						c140.sub_government = GameConstants.SubGovernment.NEOLIBERAL
						c140.set_tag("亲美", true)
			_add(W.I_DIPLO, -80)
			context["result_text"] = text
		1:
			if c140 != null:
				_set_part(c140, 1, true)
			var c168 := ws.get_country_by_legacy_index(168)
			if c168 != null:
				if c168.parts.size() <= 0:
					c168.parts.resize(1)
				c168.parts[0] = true
				c168.name = "墨西哥南方民主共和国"
				c168.chinese_name = "墨西哥南方民主共和国"
				c168.leave_alliances()
				c168.government = GameConstants.Government.REFORMIST
				c168.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			game.start_war(46, WAR46_SIDE1, WAR46_SIDE2, 500, 500, 0, 1)
			if ws.wars.size() > 46 and ws.wars[46] != null:
				ws.wars[46].name_war = WAR46_NAME
				ws.wars[46].fortnight_max = 24
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			_add(W.I_DIPLO, 80)
			_add_relation(EmpireData.USA, -300)
			context["result_text"] = TXT_R1
		2:
			if c140 != null:
				_set_part(c140, 1, true)
			game.start_war(47, WAR47_SIDE1, WAR47_SIDE2, 800, 200, 0, -1)
			if ws.wars.size() > 47 and ws.wars[47] != null:
				ws.wars[47].name_war = WAR47_NAME
				ws.wars[47].fortnight_max = 24
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, -300)
			context["result_text"] = TXT_R2
	if MapService.instance != null:
		MapService.instance.sync_map_merges()


func _set_part(c: CountryData, i: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= i:
		c.parts.append(false)
	c.parts[i] = value
