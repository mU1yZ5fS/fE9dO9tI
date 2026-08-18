extends "res://数据脚本/event_script_base.gd"

## 原作 Event643.cs：解放台湾？（台湾总攻，单选项）。
## 触发：ReqEventsDLC02.cs:89-92 —— c1.SubGosstroy==19 && data[64]!=2 && !completedDecisions[7]
##   复合条件 → trigger_script evaluate。
## 差异：ingamewars[75] 建模说明 WarDef → 兜底创建后补名。

const TXT_TITLE := "解放台湾？"
const TXT_DESC := "华国锋同志，台湾，不仅是我国不可分割的一部分，也是美帝封锁我国的前哨站。尤其是在我国已经接受了先进的红色基因理论后，美国更是下定决心全力武装台湾。原本美国卖给台湾的都是些落后时代的装备，而现在，各式美军现役装备都被以低价卖予台湾。甚至，有些声称奉行“一个中国”政策的国家，也暗中与台湾伪政权有着联系，真不知道他们所说的那个“一个中国”到底是哪个！现在，是时候一劳永逸地解决蒋伪政权了。人民解放军即将完成他们的最大的使命，完成伟大领袖的未竟之业，解放台湾人民！"
const TXT_OPT0 := "打过海峡去，解放全中国！"
const TXT_R0 := "中央一声令下，解放军海军立即包围了台湾岛，断绝了台湾岛与外界的一切联系。金门马祖立刻被福建省的解放军接管，而登岛作战貌似也并不困难。美苏谴责我们破坏台海和平，我们早已对此见怪不怪，甚至我们的联合国代表都能背出来他们谴责我们的台词，况且这只是我们解放自己的领土，又关他们何事呢？"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	context["result_text"] = TXT_R0
	# 原版 ingamewars[75]：第三次中国内战，中国(700) vs 中华民国(300)，美苏均支持防守方
	GameManager.start_war(75, "中华人民共和国", "中华民国", 700, 300, 2, 2)
	if ws.wars.size() > 75 and ws.wars[75] != null:
		ws.wars[75].name_war = "第三次中国内战"
	_add(W.I_PARTY_SUPPORT, 300)
	_add(W.I_PEOPLE_SUPPORT, 300)
	_add(W.I_THOUGHT_FREEDOM, -200)
	_add(W.I_DIPLO, 150)
	_add(W.I_BUDGET, -50)
	_add(W.I_AGENTS, -100)
	_add(W.I_ARMY, -200)
	_add(W.I_POPULATION, 2)
	_add_relation(EmpireData.USSR, -500)
	_add_power(EmpireData.USSR, -15)
	_add_relation(EmpireData.USA, -500)
	_add_power(EmpireData.USA, -15)
	ws.influence_prc += 15


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var china := world.get_country_by_legacy_index(1)
	if china == null or china.sub_government != 19:
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	if d.size() <= W.I_TAIWAN_STATUS or d[W.I_TAIWAN_STATUS] == 2:
		return false
	return world.decisions == null or world.decisions.completed.size() <= 7 \
		or not world.decisions.completed[7]
