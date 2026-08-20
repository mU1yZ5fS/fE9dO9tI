extends "res://数据脚本/event_script_base.gd"

const S_14 := "受欢迎的讽刺剧"
const S_17 := "1980年，英国广播公司推出了一档受欢迎的电视节目《是，大臣》。《是，大臣》以一位英国内阁大臣在白厅的办公室为背景，讲述了行政事务大臣吉姆·哈克的执政生涯。他争取的各项改革措施都受到了英国公务员及各种利益团体的掣肘。行政事务部常务次官汉弗莱·阿普比爵士长袖善舞，善于通过复杂官僚程序拖延哈克的改革措施。行政事务大臣首席私人秘书伯纳德·伍利由于在业务上接受哈克的领导，人事上则受汉弗菜管理，因此立场常游走在二人之间。伯纳德经常在讨论过程中插科打诨，但往往在关键时刻给予哈克或汉弗菜意料之外的帮助。\n和一般的电视节目不同，这部剧的特点是他独特的选材。这部剧尖锐的批判了英国官场的黑暗，但又用一种诙谐的手段点破，使人忍俊不禁。\n主席同志，我们是否也该拍部类似的片子？"
const S_22 := "1980年，英国广播公司推出了一档受欢迎的电视节目《是，部长》（原为《是，大臣》）。《是，部长》以一位英国部长在白厅的办公室为背景，讲述了行政部部长吉姆·哈克的执政生涯。他争取的各项改革措施都受到了英国公务员及各种利益团体的掣肘。行政事务部常务次官汉弗莱·阿普比先生长袖善舞，善于通过复杂官僚程序拖延哈克的改革措施。行政事务大臣首席私人秘书伯纳德·伍利由于在业务上接受哈克的领导，人事上则受汉弗菜管理，因此立场常游走在二人之间。伯纳德经常在讨论过程中插科打诨，但往往在关键时刻给予哈克或汉弗菜意料之外的帮助。\n和一般的电视节目不同，这部剧的特点是他独特的选材。这部剧尖锐的批判了英国官场的黑暗，但又用一种诙谐的手段点破，使人忍俊不禁。\n主席同志，我们是否也该拍部类似的片子？"
const S_27 := "1980年，英国广播公司（现为英国人民广播电视台）推出了一档受欢迎的电视节目《是，人民委员》（原为《是，大臣》）。《是，人民委员》以一位英国人民委员在红厅的办公处为背景，讲述了行政人民委员吉姆·哈克的执政生涯。他争取的各项改革措施都受到了大不列颠人民干事及各种“坏分子”的掣肘。行政人民委员处常务次官汉弗莱·阿普比爵士长袖善舞，善于通过复杂官僚程序拖延哈克的改革措施。行政人民委员首席干事伯纳德·伍利由于在业务上接受哈克的领导，人事上则受汉弗菜管理，因此立场常游走在二人之间。伯纳德经常在讨论过程中插科打诨，但往往在关键时刻给予哈克或汉弗菜意料之外的帮助。\n和一般的电视节目不同，这部剧的特点是他独特的选材。这部剧尖锐的批判了英国官场的黑暗，但又用一种诙谐的手段点破，使人忍俊不禁。\n主席同志，我们是否也该拍部类似的片子？"
const S_31 := "1980年，英国广播公司推出了一档受欢迎的电视节目《是，大臣》。《是，大臣》以一位英国部长在白厅的办公室为背景，讲述了行政部（该剧的虚构部门）大臣吉姆·哈克的执政生涯。他所计划的各项有助于国家的政策在部内被低效的公务员系统所针对，在议会里则被自己的“同僚”们所处处排挤。行政事务部常务次官汉弗莱·阿普比先生长袖善舞，善于通过复杂官僚程序拖延哈克的计划。行政事务大臣首席私人秘书伯纳德·伍利由于在业务上接受哈克的领导，人事上则受汉弗菜管理，因此立场常游走在二人之间。伯纳德经常在讨论过程中插科打诨，但往往在关键时刻给予哈克或汉弗菜意料之外的帮助。\n和一般的电视节目不同，这部剧的特点是他独特的选材。这部剧尖锐的批判了英国官僚主义制度的黑暗，但又用一种诙谐的手段点破，使人忍俊不禁。但是该部电视剧的第二部收到了英国政坛大地震的影响，与第一版剧本不同，逐渐转为赤裸裸的政治宣传片，经历了风格的改变。哈克所遭到的针对和排挤开始有意地被画外音渲染为“旧民主体制的不可靠和堕落“。其中新增加了一系列以左翼人士们为原型的反派。如在第二集中出现的本·威尔逊，一个左倾的，喜欢在工人合作社里大口喝茶而在议会上对女王陛下毫无尊敬的工党政客。他在本集内一直试图破坏哈克修建新医院的计划，动员工会发动反对哈克的倡议，甚至在高潮希望推翻君主制并破坏英国的核防御。但最终，哈克凭借汉弗莱和伯纳德的小巧思，设法识破了本的计划。"
const S_34 := "|新首相，“长者”鲍威尔更是绞尽脑子里最后一丝幽默，在他个人的要求下创作了一份剧本，并由他扮演自己。其中，鲍威尔借“首相”一角的口吻，犀利的指出了旧民主体系的低效，猛烈的抨击了布鲁塞尔的官僚们对伦敦事务的指手画脚。在最后，当问及到上任后要出访哪里时，汉弗莱爵士以一贯幽默的口吻回答道：“我想是那个满是魔鬼奴仆的索多玛布鲁塞尔吧？”"
const S_36 := "\n有的评论家认为本片已经完全蜕变成了PJHQ的样板戏，不仅风格遭遇了剧烈地改变，还失去了讽刺的效果。\n主席同志，我们是否也该拍部类似的片子？"
const S_43 := "这是我们该做的事，拨款拍部吧。（需要5百万预算）"
const S_44 := "我们可以引进这部片子（需要2百万预算）"
const S_45 := "拒绝这一提案"
const S_50 := "受欢迎的讽刺剧"
const S_53 := "我们决定拍一部类似的片子。在上海美术电影制片厂和八一电影制片厂的支持下，《新官场现形记》得以上映。我们以一本清末的小说为蓝本，再将这个故事套用了现代化的剧本。人人都看得出这个虚构的国家“大东国”，虚构的集体“东国进步党”都在暗戳戳的讽刺谁——当然是苏联了！\n群众对这一新奇的自我批判方式感到惊讶，很多现实中的事件都可以剧中找到蓝本。例如其中的一起车祸：谢普里亚国的外交官撞伤了一名东国工人。主角在不满之余，却发现了外交的潜规则：谢普里亚只会大力谴责这位外交官，而东国总理将充当和事佬。作为回报，谢普里亚将和东国展开更为深入的合作，并加大力度恢复东国在“世界联邦”的合法地位。正义的主角当然不会坐视不管，他成功的发表了一篇强硬的演说，成功赢得了大量的支持。\n只有党内的一些人对这种行为感到不快，但我们的人民很满意，这也就够了。"
const S_61 := "在我们的牵头合作下，英国方面同意授权我们转播并翻译。在上海美术电影制片厂的辛苦工作下，"
const S_64 := "《是，大臣》"
const S_68 := "《是，部长》"
const S_72 := "《是，人民委员》"
const S_74 := "很快问世了。但这并没能达到我们预期的成功：大多数人对英国政治几乎没有了解，这就导致了许多笑料需要一串长长的注释才能看懂。这很明显不太合适，因此，这部剧只是作为一个茶余饭后的闲谈，仅此而已。\n但作为内参，这部电视剧则获得了不少好评。他们中的不少人完美的看懂了这部剧的笑点，很多人甚至在剧中找到了另一个自己。许多高干子弟也以此为笑料挪揄我们的政府。"
const S_82 := "住嘴！你以为我不知道哪个英国的官僚主义问题最严重吗？"


## 原作 Event477.cs：受欢迎的讽刺剧（三选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1479-1481 —— c92.Torg && 日期>=1980.3.1。
## 差异：描述按英国政体动态改写；Torg→对华贸易；IsAuthoritarianism→ws.is_authoritarian。

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null:
		return
	var uk := world.get_country_by_legacy_index(92)
	if uk == null:
		return
	if uk.government == GameConstants.Government.LIBERAL:
		event_def.description = S_17
	elif uk.government == GameConstants.Government.REFORMIST:
		event_def.description = S_22
	elif world.is_socialism(uk, true):
		event_def.description = S_27
	if world.is_authoritarian(uk):
		var text := S_31
		if uk.sub_government == GameConstants.SubGovernment.NEO_FASCIST or uk.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST or _raw_uk(world) == 9:
			text += S_34
		event_def.description = text + S_36


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uk := ws.get_country_by_legacy_index(92)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, -50)
			context["result_text"] = S_53
		1:
			var text := S_61
			if uk != null and (uk.government == GameConstants.Government.LIBERAL or ws.is_authoritarian(uk)):
				text += S_64
			elif uk != null and uk.government == GameConstants.Government.REFORMIST:
				text += S_68
			elif uk != null and ws.is_socialism(uk, true):
				text += S_72
			text += S_74
			_add(W.I_BUDGET, -20)
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, 80)
			context["result_text"] = text
		2:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_THOUGHT_FREEDOM, 50)
			context["result_text"] = S_82


func _raw_uk(world: WorldState) -> int:
	if world == null or world.size() <= 147:
		return 0
	return world.britain_political_route


