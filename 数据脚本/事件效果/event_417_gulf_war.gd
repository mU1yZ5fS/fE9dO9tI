extends "res://数据脚本/event_script_base.gd"

## 原作 Event417.cs：我们将走上战场（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1331 —— ExprNode 组合。
## 差异：描述动态由 prepare 按伊拉克是否傀儡科威特拼接；SovietSupportDefender.AmericanSupportDefender→usa_side = GameConstants.WarSide.SIDE1,ussr_side = GameConstants.WarSide.SIDE2。

const TXT_TITLE := [
	"我们将走上战场",
]

const TXT_DESC := [
	"中东战事的爆发再次引爆了石油危机。石油价格的剧烈波动迫使欧佩克国家重新确定石油价格标准，其中，石油生产的大国伊拉克迫切的需要石油来恢复经济，以此振兴国内经济。为了增加商品供应，抑制通货膨胀，恢复在战争期间被严重削弱的生活水平，伊拉克只有一个选择--增加石油收入。正是在这一特殊领域，伊拉克与科威特的冲突埋下了伏笔。科威特也拥有丰厚的石油产量，却不愿遵守欧佩克的产量限制，而是加速增产。伊拉克领导人萨达姆·侯赛因多次在阿拉伯国家领导人的特别会议上指出，科威特不合群的举动对阿拉伯国家的打击不亚于战争。伊拉克领导人还指控科威特通过斜向钻探法盗取属于伊拉克领土的鲁迈拉油田，攫取了本应属于伊拉克的石油资源。科威特埃米尔和石油大臣拒绝就此回复。{0}",
	"在前些天的电视讲话中，“兄弟总统”，伊拉克领导人萨达姆·侯赛因指责海湾国家的统治者，尤其是科威特是帝国主义和犹太复国主义者发动的国际运动的工具，目的是阻止伊拉克的科技进步，使伊拉克人民陷入贫困。十天后，在伊拉克军队沿伊拉克-科威特边境调动的阴影下，欧佩克决定将其石油参考价格提高三美元，并允许各国增加产量，希望这能让伊拉克采取更温和的态度。但在欧佩克发表决议的第三天，伊拉克政府决定入侵并占领科威特。",
]

const TXT_DESC_APPEND := "刚刚结束了卡迪西亚的萨达姆自然不只是希望夺回自己的石油，或者换取科威特让步，而是希望能恢复对科威特的绝对主权。所以，刚刚结束对伊朗的军事行动的伊拉克军队开始调向科威特边境地带，伊拉克空军也频频起飞。"

const TXT_OPT0 := [
	"这就是万战之母吗……",
]

const TXT_R := [
	"科威特王室在伊拉克军队面前毫无缚鸡之力，这真的会让中东更稳定吗？",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1314 := "伊拉克入侵科威特"
const TXT_IDX_1315 := "伊拉克"
const TXT_IDX_1316 := "科威特"

## 原文字符串附录（供自检）
## 我们将走上战场
## 中东战事的爆发再次引爆了石油危机。石油价格的剧烈波动迫使欧佩克国家重新确定石油价格标准，其中，石油生产的大国伊拉克迫切的需要石油来恢复经济，以此振兴国内经济。为了增加商品供应，抑制通货膨胀，恢复在战争期间被严重削弱的生活水平，伊拉克只有一个选择--增加石油收入。正是在这一特殊领域，伊拉克与科威特的冲突埋下了伏笔。科威特也拥有丰厚的石油产量，却不愿遵守欧佩克的产量限制，而是加速增产。伊拉克领导人萨达姆·侯赛因多次在阿拉伯国家领导人的特别会议上指出，科威特不合群的举动对阿拉伯国家的打击不亚于战争。伊拉克领导人还指控科威特通过斜向钻探法盗取属于伊拉克领土的鲁迈拉油田，攫取了本应属于伊拉克的石油资源。科威特埃米尔和石油大臣拒绝就此回复。{0}在前些天的电视讲话中，“兄弟总统”，伊拉克领导人萨达姆·侯赛因指责海湾国家的统治者，尤其是科威特是帝国主义和犹太复国主义者发动的国际运动的工具，目的是阻止伊拉克的科技进步，使伊拉克人民陷入贫困。十天后，在伊拉克军队沿伊拉克-科威特边境调动的阴影下，欧佩克决定将其石油参考价格提高三美元，并允许各国增加产量，希望这能让伊拉克采取更温和的态度。但在欧佩克发表决议的第三天，伊拉克政府决定入侵并占领科威特。
## 刚刚结束了卡迪西亚的萨达姆自然不只是希望夺回自己的石油，或者换取科威特让步，而是希望能恢复对科威特的绝对主权。所以，刚刚结束对伊朗的军事行动的伊拉克军队开始调向科威特边境地带，伊拉克空军也频频起飞。
## 这就是万战之母吗……
## 科威特王室在伊拉克军队面前毫无缚鸡之力，这真的会让中东更稳定吗？

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if world.completed_event_ids.has("event_417"):
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	if d.size() <= W.I_YEAR:
		return false
	if not ((d[W.I_YEAR] >= 1981 and d[W.I_YEAR] < 1983 and d[W.I_MONTH] >= 3) or d[W.I_YEAR] == 1982):
		return false
	var c8 := world.get_country_by_legacy_index(8)
	var c14 := world.get_country_by_legacy_index(14)
	if c8 == null or c14 == null:
		return false
	if not (c8.puppet_of == GameConstants.LegacySlot.IRAQ or c8.has_tag("seato") or c8.has_tag("sento") or c8.has_tag("ovd") or c8.has_tag("okb")):
		return false
	if world.wars.size() > 3 and world.wars[3] != null and world.wars[3].is_going:
		return false
	if c14.sub_government != GameConstants.SubGovernment.LEFT_NATIONALIST:
		return false
	if c14.puppet_of >= 0:
		return false
	if world.wars.size() > 42 and world.wars[42] != null and world.wars[42].is_going:
		return false
	return true

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var iraq := world.get_country_by_legacy_index(8)
	var append_text := TXT_DESC_APPEND if iraq != null and iraq.puppet_of == GameConstants.LegacySlot.IRAQ else ""
	event_def.description = _fmt(TXT_DESC[0], [append_text]) + TXT_DESC[1]

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var iraq := ws.get_country_by_legacy_index(14)
	if iraq != null:
		iraq.set_tag("亲苏", false)
	_add(143, 3)
	GameManager.start_war(28, "伊拉克", "科威特", 600, 400, 0, 1)
	if ws.wars.size() > 28 and ws.wars[28] != null:
		ws.wars[28].name_war = "伊拉克入侵科威特"
		ws.wars[28].fortnight_max = 25
	context["result_text"] = TXT_R[0]
