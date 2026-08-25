extends "res://数据脚本/event_script_base.gd"

## 原作 Event401.cs：左翼阵营内的分裂（三选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1211 —— 复杂条件用 evaluate（inflCh 无 ExprNode 字段）。
## 差异：Gosstroy/SubGosstroy→government/sub_government；data.get_data_by_index(179..181) raw index。

const TXT_TITLE := [
	"左翼阵营内的分裂",
]

const TXT_DESC := [
	"意大利腐败丑闻与右翼在议会内的大胜都已成为过去时。如今，撮合左翼共治的政治实验已然走到了崩溃边缘：由于党内就意大利改革前途与如何实践社会主义议程等系列问题存在争议，左翼联盟的领头羊意大利共产党已经走到了十字路口。随着热心于政治妥协，并将“天主教-共产主义”与“历史性妥协”公式发扬光大的总书记恩里科·贝林格在罗马逝世。共产党内部的派系斗争已然逐步走向脱轨。在前天主教民主党与意大利社会党成员大量涌入共产党的背景下，承袭贝林格衣钵的亚历山德拉·纳塔显然力不从心，不足以承接其政治遗产。其被边缘化也不过时间问题。目前的共产党已然形成了两大权力中心：一方自是本就同改良主义政治立场高度亲和，并在建制派倒戈浪潮中势力空前壮大的“改进派”。其领导人乔治·纳波利塔诺已然锁定了党和国家的最高领导人之位，试图在民主主义与现代社会主义的基础上重定义共产主义事业；另一方则是团结在众议院议长彼得罗·英格拉奥周围，面对空前势大的“改进派”不得不抱团取暖的的左派联合（事实上囊括了阿曼多·科苏塔的左翼陶里亚蒂主义，前工人主义者的政治潮流，乃至一部分坚守“意大利社会主义之路”的贝林格政治门生），并要竭尽所能保全其“光荣传统”。目前，共产党党内斗争仍悬而未决，这便提供了借题发挥的好机会。我们当然可以选择扶持其中一个派系，但这将为我们带来多少回报呢？",
]

const TXT_OPT0 := [
	"支持英格拉奥的左翼联合并重振意大利共产主义事业",
]

const TXT_OPT1 := [
	"支持纳波利塔诺对共产党的现代化转向",
]

const TXT_OPT2 := [
	"静观其变",
]

const TXT_R := [
	"早在意共长期推进的改良主义政治实践中扩充势力，并在党内占据重要地位的“改进派”很快便近水楼台。他们不仅借意共特别代表大会重申了该党对于民主主义、世俗主义与人道社会主义忠诚的方式确立了自身的“正统性”。更在贝林格死后借党内群龙无首的境况收编其势力，整合前任领导人的政治门生（如西西里地区议员阿基利·奥凯托，青年运动组织者马西莫·达莱马等）至己方麾下。至此，主持“改进派”政治议程的全权代表乔治·纳波利塔诺已然不可阻挡，注定将在党内拔得头筹。而将党内主张应用至治国理政层面也不过时间问题。当然，总有些事是必须立即完成的——",
	"背靠激进学生运动与新左派的政治底蕴，意大利左翼的政治联合得以坚守“社会主义替代”的政治路线，最终一举建立自身领导权：作为党内左翼代表的彼得罗·英格拉奥便借机找准机会，不仅将原本靠拢阿曼多·科苏塔的前工人主义活动家们合并至己方麾下，更通过扩充活动家队伍在意共的特别代表大会期间持续输送外部压力，最终确立了自身的优势地位。而将党内主张应用至治国理政层面也不过时间问题。当然，总有些事是必须立即完成的——",
	"早在意共长期推进的改良主义政治实践中扩充势力，并在党内占据重要地位的“改进派”很快便近水楼台。他们不仅借意共特别代表大会重申了该党对于民主主义、世俗主义与人道社会主义忠诚的方式确立了自身的“正统性”。更在贝林格死后借党内群龙无首的境况收编其势力，整合前任领导人的政治门生（如西西里地区议员阿基利·奥凯托，青年运动组织者马西莫·达莱马等）至己方麾下。至此，主持“改进派”政治议程的全权代表乔治·纳波利塔诺已然不可阻挡，注定将在党内拔得头筹。而将党内主张应用至治国理政层面也不过时间问题。当然，总有些事是必须立即完成的——",
	"早在意共长期推进的改良主义政治实践中扩充势力，并在党内占据重要地位的“改进派”很快便近水楼台。他们不仅借意共特别代表大会重申了该党对于民主主义、世俗主义与人道社会主义忠诚的方式确立了自身的“正统性”。更在贝林格死后借党内群龙无首的境况收编其势力，整合前任领导人的政治门生（如西西里地区议员阿基利·奥凯托，青年运动组织者马西莫·达莱马等）至己方麾下。至此，主持“改进派”政治议程的全权代表乔治·纳波利塔诺已然不可阻挡，注定将在党内拔得头筹。而将党内主张应用至治国理政层面也不过时间问题。当然，总有些事是必须立即完成的——",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

## 原文字符串附录（供自检）
## 左翼阵营内的分裂
## 意大利腐败丑闻与右翼在议会内的大胜都已成为过去时。如今，撮合左翼共治的政治实验已然走到了崩溃边缘：由于党内就意大利改革前途与如何实践社会主义议程等系列问题存在争议，左翼联盟的领头羊意大利共产党已经走到了十字路口。随着热心于政治妥协，并将“天主教-共产主义”与“历史性妥协”公式发扬光大的总书记恩里科·贝林格在罗马逝世。共产党内部的派系斗争已然逐步走向脱轨。在前天主教民主党与意大利社会党成员大量涌入共产党的背景下，承袭贝林格衣钵的亚历山德拉·纳塔显然力不从心，不足以承接其政治遗产。其被边缘化也不过时间问题。目前的共产党已然形成了两大权力中心：一方自是本就同改良主义政治立场高度亲和，并在建制派倒戈浪潮中势力空前壮大的“改进派”。其领导人乔治·纳波利塔诺已然锁定了党和国家的最高领导人之位，试图在民主主义与现代社会主义的基础上重定义共产主义事业；另一方则是团结在众议院议长彼得罗·英格拉奥周围，面对空前势大的“改进派”不得不抱团取暖的的左派联合（事实上囊括了阿曼多·科苏塔的左翼陶里亚蒂主义，前工人主义者的政治潮流，乃至一部分坚守“意大利社会主义之路”的贝林格政治门生），并要竭尽所能保全其“光荣传统”。目前，共产党党内斗争仍悬而未决，这便提供了借题发挥的好机会。我们当然可以选择扶持其中一个派系，但这将为我们带来多少回报呢？
## 支持英格拉奥的左翼联合并重振意大利共产主义事业
## 支持纳波利塔诺对共产党的现代化转向
## 静观其变
## 早在意共长期推进的改良主义政治实践中扩充势力，并在党内占据重要地位的“改进派”很快便近水楼台。他们不仅借意共特别代表大会重申了该党对于民主主义、世俗主义与人道社会主义忠诚的方式确立了自身的“正统性”。更在贝林格死后借党内群龙无首的境况收编其势力，整合前任领导人的政治门生（如西西里地区议员阿基利·奥凯托，青年运动组织者马西莫·达莱马等）至己方麾下。至此，主持“改进派”政治议程的全权代表乔治·纳波利塔诺已然不可阻挡，注定将在党内拔得头筹。而将党内主张应用至治国理政层面也不过时间问题。当然，总有些事是必须立即完成的——
## 背靠激进学生运动与新左派的政治底蕴，意大利左翼的政治联合得以坚守“社会主义替代”的政治路线，最终一举建立自身领导权：作为党内左翼代表的彼得罗·英格拉奥便借机找准机会，不仅将原本靠拢阿曼多·科苏塔的前工人主义活动家们合并至己方麾下，更通过扩充活动家队伍在意共的特别代表大会期间持续输送外部压力，最终确立了自身的优势地位。而将党内主张应用至治国理政层面也不过时间问题。当然，总有些事是必须立即完成的——

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() <= W.I_YEAR:
		return false
	if world.completed_event_ids.has("event_401"):
		return false
	var italy := world.get_country_by_legacy_index(85)
	if italy == null:
		return false
	if not ((d.year == 1984 and d.month >= 7) or d.year >= 1985):
		return false
	if italy.influence_china <= 0:
		return false
	if italy.sub_government != GameConstants.SubGovernment.LEFT_CONSERVATIVE:
		return false
	if world.completed_event_ids.has("event_556"):
		return false
	if world.completed_event_ids.has("event_396"):
		return false
	return italy.sub_government != GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -50)
		_add(179, 2)
		if _raw(181) >= _raw(179):
			if italy != null:
				italy.government = GameConstants.Government.LIBERAL
				italy.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				italy.set_tag("亲美", false)
			context["result_text"] = TXT_R[0]
		else:
			if italy != null:
				italy.government = GameConstants.Government.REFORMIST
				italy.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				italy.set_tag("亲美", false)
				italy.set_tag("nato", false)
				italy.set_tag("eu", false)
				italy.set_tag("亲中", true)
				italy.set_tag("对华贸易", true)
			context["result_text"] = TXT_R[1]
	elif opt == 1:
		_add(W.I_BUDGET, -30)
		if italy != null:
			italy.government = GameConstants.Government.LIBERAL
			italy.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			italy.set_tag("亲美", false)
			italy.set_tag("eu", false)
			italy.set_tag("对华贸易", true)
			italy.set_tag("亲中", true)
		context["result_text"] = TXT_R[2]
	elif opt == 2:
		if italy != null:
			italy.government = GameConstants.Government.LIBERAL
			italy.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			italy.set_tag("亲美", false)
		context["result_text"] = TXT_R[3]

func _raw(i: int) -> int:
	if d.size() > i:
		return d.get_data_by_index(i)
	return 0



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_401_left_wing_split.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_401",
	"num": 401,
	"priority": 40100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_401_left_wing_split.gd",
	"trigger_script": "res://数据脚本/事件效果/event_401_left_wing_split.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
