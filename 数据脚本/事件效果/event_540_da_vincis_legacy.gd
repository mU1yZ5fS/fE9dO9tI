extends "res://数据脚本/event_script_base.gd"

## 原作 Event540.cs：达芬奇的遗产（直升机研发，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:197-199 —— event_done[518]。
## 差异：old_modify_desc[50] → ModifierCatalog.get_def(50) 展示文案。

const TXT_OPT0_DIS := "我们钱不够啊"
const TXT_OPT1_DIS_TRADE := "法国人不会卖给我们东西"
const TXT_OPT1_DIS_MONEY := "我们没有闲钱！"
const TXT_R0 := "随着一纸号令的下达，我们决定研发更好的直升机。在原有型号和观察员的研究下，我们借鉴了美国“黑鹰”直升机和苏联mi-17的经验，得以设计出一款功能和技术都接近的通用直升机，直-12。这是一个大胆的决定，因为我们采用了大量新型技术：例如十一叶片的螺旋桨，内置在尾翼中的螺旋桨等。这将同时作为军队和民用设计。预计可以运载十人左右，尽管运量不高，但这款直升机将大量列装，旨在完全取代旧设计。同时，直12-w也在设计中，这是直12的双座升级版本，具有尾旋翼，从而降低了噪音水平，从而使其能够实现一定程度的声学隐身。排气装置的设计减少了红外线特征。该直升机配备了毫米波火控雷达。与大多数攻击直升机不同的是，它没有机头机枪或机炮。直-12还具有装甲板、弹射座椅和装有前视红外系统及激光测距仪的炮塔。特别设计的头盔型瞄具也在计划中。"
const TXT_R1 := "我们和法国签署了一项协议，我们将在未来采购法国的农产品，而法国将会转让给我们SA365-N1的生产线。很快，哈尔滨飞机制造厂便试飞了第一架直-9，这至少能填补我们在军用和民用的空缺。这款直升机将被大量列装部队，军用的武装款也在设计中。"
const TXT_R2 := "仔细想想，我们的直升机还挺先进的？总比那几个天天摔地上的好，对吧？"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var money := d.budget + d.reserve
	var c21 := world.get_country_by_legacy_index(21)
	if money >= 80:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if c21 != null and c21.has_tag("对华贸易"):
		if money >= 30:
			_enable(opt[1], event_def.options[1].text)
		else:
			_disable(opt[1], TXT_OPT1_DIS_MONEY)
	else:
		_disable(opt[1], TXT_OPT1_DIS_TRADE)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -80)
			_add(W.I_ARMY, 80)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			ws.influence_prc += 20
			_set_mod50("自研直升机：", "军力+0.4，干涉点数+0.2")
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -30)
			_add(W.I_ARMY, 50)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_DIPLO, -20)
			ws.influence_prc += 20
			_set_mod50("法式直升机：", "军力+0.2，干涉点数+0.1")
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2


func _set_mod50(title: String, effect: String) -> void:
	var def := ModifierCatalog.get_def(50)
	if def != null:
		def.name_zh = title
		def.effect_zh = effect
