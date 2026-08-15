# ============================================================================
# FocusCatalog — 焦点树目录（唯一树 "Start Focus"，7 层 20 焦点）
# ============================================================================
# 对齐原版：
#   - Focuses/USSRFocuses.cs（Assets/Scripts/Focuses/USSRFocuses.cs:9-44）
#   - KGFocus/FocusTree.cs（分层 List<List<Focus>>）
#   - 文本权威源 new_focuses_texts_en.xml（24 条，裁决 2026-08-16 按 xml 修正 key）
#
# 裁决映射（原版代码 key → xml 权威 key）：
#   "President end"            → "The end of the president"
#   "Fall Yemen"               → "The Fall of Yemen"
#   "People"(Historical 分支)  → "State of the whole people"
#   "People"(Agressive 分支)   → "Still developing"
#
# 条件组合语义（Focus.CreateCondition 直译）：
#   默认每个条件与前序 OR；Expr 块内 AND，块结束后整体 OR 进主条件。
#
# 文本约定：xml 逐字中文，字符间空格不保留（事件台账惯例）。
# ============================================================================
class_name FocusCatalog
extends RefCounted

const W = preload("res://数据脚本/world_state.gd")

const TEXTS := {
	"The congress continues": ["大会继续进行", "苏共第二十五次代表大会决定继续资助改良主义共产党，以免失去其在欧洲的影响力。"],
	"New old": ["新与旧", "为回应意大利共产党总书记恩里科·贝林格的声明，即“如果意大利共产党胜选，意大利将留在北约”，苏联决定停止资助欧洲改良主义共产党，并开始与反修正主义者建立联系。"],
	"Correcting wrong": ["修正错误", "在契尔年科同志的影响下，苏共第二十五次代表大会决定恢复反党集团在苏共中的成员身份，以将其平反。这已被欧洲人和持不同政见者称为“再斯大林化”。"],
	"Iron marshal": ["钢铁元帅", "格列奇科死后，以爱国者、创新者和温和军国主义者著称的德米特里·乌斯季诺夫被任命为苏联国防部长。他无疑将继续坚定地维护勃列日涅夫主义。"],
	"New marshal": ["新元帅", "格列奇科死后，谢苗·康斯坦丁诺维奇·库尔科特金被任命为苏联国防部长，他开始在军队内部进行改革：提高官兵生活水平和供给水平；设置更多假期；增加不适合征兵的指标数量，从而缩小军队规模。"],
	"Red marshal": ["红色元帅", "格列奇科死后，谢尔盖·阿赫罗梅耶夫被任命为苏联国防部长，他主张游说增加对军队和军工联合体的拨款，并寻求在军事领域赶超美国：提高坦克、武器产量，强化军事发展等。"],
	"Helsinki group": ["赫尔辛基小组", "勃列日涅夫同志签署了涉及人权的《赫尔辛基协议》后，在未经任何审批的情况下，尤里·奥尔洛夫就领导在苏联成立了所谓赫尔辛基小组，他自称为苏联人权首席检察官。作为一个非法的“检察”小组，当然会遭受到些许管控，克格勃的代表在通知其进行约谈说明情况后，向各工作场所和教育机构发函严查，出乎意料的是，克格勃并未对此高调严惩，一桩国际丑闻得以避免发生。"],
	"Helsinki gang": ["赫尔辛基帮", "尤里·奥尔洛夫领导的赫尔辛基小组甫一成立，便立刻引起了克格勃主席尤里·安德罗波夫的关注，为了避免匈牙利和波兰的情况在苏联重演，他跳过开会讨论，当即做出决定，下令对非法检察人员实施抓捕。在他们被大批逮捕后，以其进行反苏宣传活动和内通美国的罪行名义，这些“检察员”被判间谍罪，刑期从三年到八年不等。"],
	"Death of Biedić": ["比耶迪奇之死", "南斯拉夫联邦执行委员会主席杰马尔·比耶迪奇死于飞机失事。有传言说他是被清算了，因为其反对进一步改革，且支持在联邦内加强波斯尼亚。"],
	"Kremlin hand": ["克里姆林插手", "在苏联特种部队的帮助下，对杰马尔·比耶迪奇的暗杀企图被挫败，这在短时间内稳定了南斯拉夫的局势，也加强了了苏联在其国内的政治影响力。"],
	"The end of the president": ["总书记的末路", "在勃列日涅夫的又一次长假期间，克格勃主席尤里·安德罗波夫策划了场阴谋：他说服政治局其他成员一起向勃列日涅夫转达了波德戈尔内想要罢免列昂尼德·伊里奇的消息，因其认为后者健康状况每况愈下。“——列昂尼德，怎么会这样？”|\"这是党做出的决定，不是我。\""],
	"As it was": ["一切照旧", "安德罗波夫不敢策划阴谋，或是因其担心危及苏维埃联盟，抑或是惧怕失败，结果仍是一切照旧。"],
	"Soviet power": ["苏维埃势力", "安德罗波夫的阴谋失败了，他几乎没有获得政治局的多数支持，政治局多数派不得不竭力阻止行动发生以迫使安停止他的阴谋。然而，安德罗波夫的行径同样也被苏联最高苏维埃主席团主席获知，这让波德戈尔内同志警惕不已。他开始寻找任何机会扩大苏维埃与最高苏维埃的权力，以加强自己作为最高苏维埃主席团主席的权力与安全保障。"],
	"Against the aggressor": ["对抗侵略者", "索马里总统西亚德·巴雷访问苏联，寻求在与埃塞俄比亚的战争中的支持。他与部长会议主席柯西金、部长兼外交委员葛罗米柯的会晤没有成功。苏联谴责索马里政权的侵略，故而美国同意协助巴雷以换取在当地建立海军基地。"],
	"Not aggression": ["不是侵略", "得知巴雷与美国人的秘密谈判后，苏联领导层决定对索马里战争贩子先发制人开启打击：苏联海军封锁了索马里所有港口，摧毁了他们的舰队，并将船只开至索马里控制区域内实施打击，以遏制索马里在该区域内的侵略行为。"],
	"Beat the aggressor": ["击败侵略者", "为了稳定非洲这一地区的局势，克格勃对巴雷和他的马雷坎家族发动政变，押注由副总统萨曼塔、国家安全委员会主席阿卜杜拉和副总理法拉领导的“宪法核心小组”。政变成功，巴雷被捕当场枪杀。新当局签署了停战协议，以换取欧加登人的自治权。马雷汉氏族被击败，苏联恢复了对索马里的所有补给和援助。"],
	"The Fall of Yemen": ["也门乱局", "哈姆迪作为北也门总统，不仅是联邦主义和阿拉伯社会主义的支持者，也呼吁依照这样的原则促进两也门和平统一，但在一次恐怖袭击中，他被总参谋长萨利赫和沙特特勤局暗杀。也门统一落为泡影，南北也门随即开始冷战。"],
	"New Yemen": ["新也门", "以萨利赫参谋长和沙特情报部门为首的反统一阴谋集团被揭发并瓦解，哈姆迪总统获救。未遂的暗杀只会促使两国领导人加速统一谈判。分裂的民族再次团结起来！"],
	"State of the whole people": ["全民国家", "苏联通过了一部新宪法，宣布实现发达的社会主义，建立全民国家，而不是无产阶级专政，这与列宁关于社会主义社会下没有阶级与专政的假设相呼应，也符合苏共历次代表大会的综合决定。"],
	"Still developing": ["仍在发展中", "在听取了著名党员科索拉波夫同志的批评后，苏联新宪法以发展中的社会主义的概念取代了发达的社会主义，从而明确苏联的社会主义仍处于建设阶段。同时，新宪法还设立了一个重大议题，即建设全民国家而非无产阶级专政，以此作为消灭国内除工农之外一切阶级的标志。"],
	"Victory": ["胜利", "勃列日涅夫同志身患重病，已在考虑离任。许多党员担心不已！为了让亲爱的列昂尼德·伊里奇摆脱这些想法，人们应该尽可能多地爱护他、赞美他、为他授勋，以免让自己担心在新统治者的领导下会面临什么变化。"],
	"That's enough": ["已经够了", "为列昂尼德·伊里奇的授勋应当遵循适度原则，他已获得了太多的胜利勋章，这是对伟大胜利的记忆的践踏。这么做的人应受到处罚，并在其党员证上注明。"],
	"Developed": ["发达", "随着苏联宪法的修改，新的俄罗斯联邦宪法更加全面和系统化，以适应社会关系的复杂化。但是，这部宪法增加了人民代表苏维埃和最高委员会选举的任期。"],
	"Soviet": ["苏维埃", "苏联宪法修改后，根据社会关系的复杂化，通过了新的俄罗斯联邦宪法，该宪法更加全面和系统化。但是，新宪法还包括一条关于选民可以罢免人民代表苏维埃和最高委员会代表的试验性条款，前提是该代表被提名罢免的地区居民有足够的签名配额。放在以前，只有更高层的机构才能召回代表。"],
}


static var _trees: Dictionary = {}


static func ensure_built() -> void:
	if not _trees.is_empty():
		return
	_trees["Start Focus"] = _build_start_focus()


static func get_tree(tree_name: String) -> FocusTreeDef:
	ensure_built()
	return _trees.get(tree_name) as FocusTreeDef


static func tree_for_empire(empire: EmpireData) -> FocusTreeDef:
	ensure_built()
	if empire == null or empire.active_focus_tree == "":
		return _trees.get("Start Focus") as FocusTreeDef
	return _trees.get(empire.active_focus_tree) as FocusTreeDef


# ── 内部访问器 ──

static func _ws() -> WorldState:
	return GameManager.world


static func _ussr() -> EmpireData:
	var ws := _ws()
	if ws == null or ws.empires.size() <= EmpireData.USSR:
		return null
	return ws.empires[EmpireData.USSR]


static func _power_of(country: int) -> int:
	# 0=USA 1=USSR 2=China（原版 QueryMajor.Weaker/Stronger 的取值）
	var ws := _ws()
	if country == 2:
		return ws.influence_prc if ws != null else 0
	if ws == null or country < 0 or country >= ws.empires.size() or ws.empires[country] == null:
		return 0
	return ws.empires[country].power


static func _leader_support(politic: int) -> int:
	var e := _ussr()
	if e == null or politic < 0 or politic >= e.leaders.size() or e.leaders[politic] == null:
		return 0
	return e.leaders[politic].support


static func _insider(index: int) -> int:
	var e := _ussr()
	if e == null or index < 0 or index >= e.insiders.size() or e.insiders[index] == null:
		return 0
	return e.insiders[index].influence


# ── 原子（QueryMajor 直译；都是 USSR 视角，China.* 用 country=2）──

static func hist() -> bool:
	var e := _ussr()
	return e != null and e.ai_historical


static func not_hist() -> bool:
	var e := _ussr()
	return e != null and not e.ai_historical


static func agressive() -> bool:
	var e := _ussr()
	return e != null and e.ai_aggressive and not e.ai_historical


static func not_agressive() -> bool:
	var e := _ussr()
	return e != null and not e.ai_aggressive and not e.ai_historical


static func reformost() -> bool:
	var e := _ussr()
	return e != null and e.ai_reformist and not e.ai_historical


static func conservative() -> bool:
	var e := _ussr()
	return e != null and not e.ai_reformist and not e.ai_historical


static func weaker(against: int) -> bool:
	return _power_of(1) < _power_of(against)


static func stronger(against: int) -> bool:
	return _power_of(1) > _power_of(against)


static func china_weaker(against: int) -> bool:
	return _power_of(2) < _power_of(against)


static func china_stronger(against: int) -> bool:
	return _power_of(2) > _power_of(against)


static func p_power_more(politic: int, num: int) -> bool:
	return _leader_support(politic) > num


static func p_power_less(politic: int, num: int) -> bool:
	return _leader_support(politic) < num


static func right_equal(num: int) -> bool:
	return _insider(0) == num


static func left_equal(num: int) -> bool:
	return _insider(1) == num


## 原版 LeftStrongerRight 与 RightStrongerLeft 的 lambda 相同（反编译原文如此），照抄。
static func left_stronger_right() -> bool:
	return _insider(1) > _insider(0)


static func war_ogaden_going() -> bool:
	var ws := _ws()
	return ws != null and ws.wars.size() > 8 and ws.wars[8] != null and ws.wars[8].is_going


# ── 效果原子 ──

static func add_to_right(num: int) -> void:
	var e := _ussr()
	if e != null and e.insiders.size() > 0 and e.insiders[0] != null:
		e.insiders[0].influence += num


static func add_to_left(num: int) -> void:
	var e := _ussr()
	if e != null and e.insiders.size() > 1 and e.insiders[1] != null:
		e.insiders[1].influence += num


static func add_to_politician(politic: int, num: int) -> void:
	var e := _ussr()
	if e != null and politic >= 0 and politic < e.leaders.size() and e.leaders[politic] != null:
		e.leaders[politic].support += num


static func add_modify(num: int) -> void:
	var e := _ussr()
	if e != null and num not in e.modifier_ids:
		e.modifier_ids.append(num)


static func add_influence(num: int) -> void:
	var e := _ussr()
	if e != null:
		e.power += num


static func china_add_influence(num: int) -> void:
	var ws := _ws()
	if ws != null:
		ws.influence_prc += num


static func add_parties_connection(num: int) -> void:
	var ws := _ws()
	if ws != null:
		ws.sov_prc_parties_connection += num


static func declare_ogaden_war() -> void:
	GameManager.start_war(8)


static func ogaden_attacker_influence(value: int) -> void:
	# War.AttackerInfluence(value)：infl1=value, infl2=1000-value（Not aggression 用 30）
	var ws := _ws()
	if ws != null and ws.wars.size() > 8 and ws.wars[8] != null:
		ws.wars[8].infl1 = value
		ws.wars[8].infl2 = 1000 - value


static func end_ogaden_war() -> void:
	var ws := _ws()
	if ws != null and ws.wars.size() > 8 and ws.wars[8] != null:
		ws.wars[8].is_going = false


static func syemen_set_system(system: int) -> void:
	# 原版 QueryMinor country=SYemen → legacy 25（RequestingIniter.cs:50）
	_set_system_by_legacy(_syemen_legacy(), system)


static func yemen_set_system(system: int) -> void:
	# 原版 QueryMinor country=Yemen → legacy 24（RequestingIniter.cs:49）
	_set_system_by_legacy(_yemen_legacy(), system)


static func _set_system_by_legacy(legacy: int, system: int) -> void:
	var ws := _ws()
	if ws == null or legacy < 0:
		return
	var c := ws.get_country_by_legacy_index(legacy)
	if c != null:
		c.government = system


# 也门 legacy 索引出处：KGEvent/RequestingIniter.cs:49-50
#   target.Yemen  = new QueryMinor<T>(target, 24)
#   target.SYemen = new QueryMinor<T>(target, 25)
static func _syemen_legacy() -> int:
	return 25


static func _yemen_legacy() -> int:
	return 24


# ── 树构建 ──

static func _mk(name_key: String, layer: Array, idx: int) -> FocusDef:
	var f := FocusDef.new()
	f.name_key = name_key
	var t: Array = TEXTS.get(name_key, ["", ""])
	f.title = t[0]
	f.desc = t[1]
	f.icon = "none"
	f.time = 75
	f.index_in_layer = idx
	layer.append(f)
	return f


static func _build_start_focus() -> FocusTreeDef:
	var tree := FocusTreeDef.new()
	var L1: Array[FocusDef] = []
	var L2: Array[FocusDef] = []
	var L3: Array[FocusDef] = []
	var L4: Array[FocusDef] = []
	var L5: Array[FocusDef] = []
	var L6: Array[FocusDef] = []
	var L7: Array[FocusDef] = []

	# ── 层 1 ──
	var f := _mk("The congress continues", L1, 0)
	f.condition = func() -> bool: return hist() or not_agressive() or reformost()
	f.effects = [func(): add_to_right(1), func(): add_to_politician(3, 1), func(): add_modify(13)]

	f = _mk("New old", L1, 1)
	f.condition = func() -> bool: return agressive()
	f.effects = [func(): add_to_left(1), func(): add_to_politician(3, -2), func(): add_modify(14)]

	f = _mk("Correcting wrong", L1, 2)
	f.condition = func() -> bool: return conservative()
	f.effects = [func(): add_to_left(1), func(): add_to_politician(2, 2), func(): add_to_politician(1, -1),
		func(): add_to_politician(3, -1), func(): add_influence(-15), func(): add_parties_connection(15),
		func(): add_modify(18)]

	# ── 层 2 ──
	f = _mk("Iron marshal", L2, 0)
	f.condition = func() -> bool: return conservative() or (weaker(0) and stronger(2))
	f.effects = [func(): add_to_left(1), func(): add_to_politician(2, 2), func(): add_to_politician(1, 1),
		func(): add_modify(15)]

	f = _mk("New marshal", L2, 1)
	f.condition = func() -> bool: return not_agressive() or (stronger(0) and stronger(2))
	f.effects = [func(): add_to_politician(2, 1), func(): add_modify(16)]

	f = _mk("Red marshal", L2, 2)
	f.condition = func() -> bool: return agressive() or (weaker(0) and weaker(2))
	f.effects = [func(): add_to_left(1), func(): add_to_politician(3, 1), func(): china_add_influence(-10),
		func(): add_modify(17)]

	# ── 层 3 ──
	f = _mk("Helsinki group", L3, 0)
	f.condition = func() -> bool: return hist() or (stronger(2) and stronger(0))
	f.effects = [func(): add_to_right(1), func(): add_to_politician(2, 1), func(): add_influence(-10)]

	f = _mk("Helsinki gang", L3, 1)
	f.condition = func() -> bool: return agressive() or p_power_more(3, 7) or (weaker(2) and weaker(0))
	f.effects = [func(): add_to_left(1), func(): add_to_politician(3, 1), func(): add_to_politician(4, 1)]

	# ── 层 4 ──
	f = _mk("Death of Biedić", L4, 0)
	f.condition = func() -> bool: return hist() or (weaker(0) and weaker(2))
	f.effects = []

	f = _mk("Kremlin hand", L4, 1)
	f.condition = func() -> bool: return agressive() or (stronger(0) and stronger(2))
	f.effects = [func(): add_influence(10), func(): add_to_politician(3, -1), func(): add_to_politician(1, -1)]

	# ── 层 5 ──
	f = _mk("The end of the president", L5, 0)
	f.condition = func() -> bool:
		return hist() or p_power_more(3, 8) or (left_equal(0) and right_equal(2)) or (stronger(0) and stronger(2))
	f.effects = [func(): add_to_right(2), func(): add_to_politician(3, 2), func(): add_to_politician(2, 1)]

	f = _mk("As it was", L5, 1)
	f.condition = func() -> bool: return p_power_less(3, 3) or (weaker(0) and weaker(2))
	f.effects = [func(): add_to_politician(1, 1), func(): add_to_politician(2, -1)]

	f = _mk("Soviet power", L5, 2)
	f.condition = func() -> bool:
		return agressive() or (p_power_more(3, 2) and p_power_less(3, 5)) or (weaker(0) and weaker(2))
	f.effects = [func(): add_to_left(1), func(): add_to_politician(3, -3), func(): add_modify(19)]

	# ── 层 6 ──
	f = _mk("Against the aggressor", L6, 0)
	f.condition = func() -> bool: return hist() or (p_power_more(3, 9) and stronger(0))
	f.effects = [func(): declare_ogaden_war()]

	f = _mk("Not aggression", L6, 1)
	f.condition = func() -> bool: return not_agressive() or (china_weaker(0) and china_weaker(1))
	f.effects = [func(): add_influence(-10), func(): ogaden_attacker_influence(30), func(): declare_ogaden_war()]

	f = _mk("Beat the aggressor", L6, 2)
	f.condition = func() -> bool:
		return (war_ogaden_going() and agressive()) or (war_ogaden_going() and stronger(0) and stronger(2))
	f.effects = [func(): end_ogaden_war()]

	# ── 层 7 ──
	f = _mk("The Fall of Yemen", L7, 0)
	f.condition = func() -> bool: return hist() or weaker(0) or not_agressive()
	f.effects = [func(): syemen_set_system(3)]

	f = _mk("New Yemen", L7, 1)
	f.condition = func() -> bool: return agressive() or (china_stronger(0) and china_stronger(1))
	f.effects = [func(): syemen_set_system(1), func(): yemen_set_system(1), func(): add_influence(10)]

	f = _mk("State of the whole people", L7, 2)
	f.condition = func() -> bool:
		return hist() or (_leader_support(3) + _leader_support(6) + _leader_support(5) + _leader_support(4) > _leader_support(2))
	f.effects = [func(): add_to_right(2), func(): add_to_politician(3, 1), func(): add_to_politician(4, 1),
		func(): add_to_politician(6, 1), func(): add_to_politician(5, 1), func(): add_to_politician(2, 1)]

	f = _mk("Still developing", L7, 3)
	f.condition = func() -> bool:
		return agressive() or left_stronger_right() or (_leader_support(3) + _leader_support(6) + _leader_support(5) + _leader_support(4) < _leader_support(2))
	f.effects = [func(): add_to_left(1), func(): add_to_right(-1), func(): add_to_politician(1, 1),
		func(): add_to_politician(2, 2)]

	tree.layers = [L1, L2, L3, L4, L5, L6, L7]
	return tree
