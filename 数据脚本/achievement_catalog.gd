# ============================================================================
# AchievementCatalog — 成就 UI 展示数据（端口新增展示层）
# ============================================================================
# 数据来源说明：
#   - 原版（F:\毛的遗产改版逆向工程测试\改版最新完整逆向）没有任何本地成就
#     名称/描述/图标：成就只以 Steam 编号 ACH_n 存在（achievements.cs:90），
#     名称与图标在 Steam 后台，原版游戏内也无成就界面（Steam overlay 显示）。
#   - 用户裁决（2026-08-16）：只展示本端口已接线的成就，名称用 ACH_n 占位，
#     描述由原作 Set 调用点条件逐条译出，不虚构官方名称。
#   - 28 处已接线调用点中 ACH_115/132/141/142 各有两条路径，合并为同一成就，
#     故列表共 24 个唯一成就。
# ============================================================================

class_name AchievementCatalog
extends RefCounted

## 有序列表。title 为 ACH_n 占位（原版无本地名称）；desc 为条件摘要；source 为原作出处。
const LIST: Array[Dictionary] = [
	{
		"number": 90, "title": "ACH_90",
		"desc": "在主爱圣三一事件中支持西莱斯，使玻利维亚由他上台并转向亲中。",
		"source": "Event132.cs:35",
	},
	{
		"number": 91, "title": "ACH_91",
		"desc": "在智利事件中选择武装起义路线，推翻皮诺切特并建立亲中联合政府。",
		"source": "Event134.cs:52",
	},
	{
		"number": 92, "title": "ACH_92",
		"desc": "乌拉圭军政府倒台后，选举由祖马兰（民粹中右翼）上台。",
		"source": "Event137.cs:122",
	},
	{
		"number": 93, "title": "ACH_93",
		"desc": "巴拉圭民主过渡中，由国家机遇党瓦尔加斯（左翼联盟）上台。",
		"source": "Event139.cs:143",
	},
	{
		"number": 94, "title": "ACH_94",
		"desc": "秘鲁事件中，在玻利维亚/巴西/智利至少一国满足激进条件时，让秘鲁爆发光辉道路革命。",
		"source": "Event141.cs:118",
	},
	{
		"number": 95, "title": "ACH_95",
		"desc": "厄瓜多尔第二次选举中，由杜阿尔特的人民力量集中党（左翼联盟）上台。",
		"source": "Event144.cs:109",
	},
	{
		"number": 96, "title": "ACH_96",
		"desc": "哥伦比亚第二次机会中，贝坦库尔连任。",
		"source": "Event146.cs:126",
	},
	{
		"number": 97, "title": "ACH_97",
		"desc": "哥伦比亚第二次机会中，纳瓦罗上台并击败自由党势力。",
		"source": "Event146.cs:158",
	},
	{
		"number": 98, "title": "ACH_98",
		"desc": "委内瑞拉事件中，由查韦斯与委内瑞拉统一社会党上台。",
		"source": "Event148.cs:121",
	},
	{
		"number": 99, "title": "ACH_99",
		"desc": "圭亚那事件中，贾根继续执政并走向合作型市场经济。",
		"source": "Event150.cs:141",
	},
	{
		"number": 100, "title": "ACH_100",
		"desc": "圭亚那事件中，本建立民族毛泽东主义政权。",
		"source": "Event150.cs:155",
	},
	{
		"number": 101, "title": "ACH_101",
		"desc": "苏里南事件中，陈亚先保住政权并建立合作共和国。",
		"source": "Event151.cs:101",
	},
	{
		"number": 112, "title": "ACH_112",
		"desc": "核战后果事件中选择逮捕激进派，向国际社会妥协。",
		"source": "Event303.cs:57",
	},
	{
		"number": 115, "title": "ACH_115",
		"desc": "法国大选第二幕中，让亲中候选人胜出（介入或静观两条路径均可）。",
		"source": "Event385.cs:410,457",
	},
	{
		"number": 121, "title": "ACH_121",
		"desc": "完成历史性妥协事件（任一选项）。",
		"source": "Event393.cs:50",
	},
	{
		"number": 122, "title": "ACH_122",
		"desc": "意大利1979年选举事件中，走舆论造势线使莫罗联盟胜选。",
		"source": "Event394.cs:177",
	},
	{
		"number": 127, "title": "ACH_127",
		"desc": "完成社会主义联盟的勃兴事件（任一选项）。",
		"source": "Event430.cs:54",
	},
	{
		"number": 132, "title": "ACH_132",
		"desc": "完成雅科夫列夫事件；或在推倒这堵墙事件中不选「下次再说」。",
		"source": "Event381.cs:54; Event484.cs:61",
	},
	{
		"number": 136, "title": "ACH_136",
		"desc": "土耳其战败事件中，影响力不低于800且库尔德聚居区全数倒向中国时，建立大库尔德斯坦。",
		"source": "Event372.cs:84",
	},
	{
		"number": 137, "title": "ACH_137",
		"desc": "驴象之争第二幕中让蒙代尔胜选（美国现任领袖非0，且苏联已入北约或我方得分占优）。",
		"source": "Event402.cs:172",
	},
	{
		"number": 138, "title": "ACH_138",
		"desc": "触发北约东扩事件（事件显示时即解锁）。",
		"source": "Event379.cs:19",
	},
	{
		"number": 141, "title": "ACH_141",
		"desc": "完成「雄鹰陨落」与「欧洲日落」两个事件（后触发者在显示时解锁）。",
		"source": "Event421.cs:18; Event422.cs:18",
	},
	{
		"number": 142, "title": "ACH_142",
		"desc": "苏联整顿东欧事件中走开战分支；或新罗曼诺夫帝国事件中走开战分支。",
		"source": "Event377.cs:119; Event388.cs:120",
	},
	{
		"number": 222, "title": "ACH_222",
		"desc": "完成毛主席逝世事件（任一选项）。",
		"source": "Event3.cs:26",
	},
]


## 已解锁计数（UI 标题用）。
static func unlocked_count() -> int:
	var n := 0
	for item in LIST:
		if Achievements.is_unlocked(int(item["number"])):
			n += 1
	return n
