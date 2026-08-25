extends "res://数据脚本/event_script_base.gd"

## 原作 Event114.cs：驴象之争（1980 美国大选，卡特 vs 里根）。
## 触发：TimeScript.cs:10824（1980.11 后，fire_only_once）。
## 计分：与修正54“美国国内各党影响力对比”同口径（ModifierButtonScript num3=共和/
## num4=民主，见 modifier_catalog._us_party_scores 头注的极性判定依据）。
## 由 ModifierCatalog._us_party_scores 统一计算；民主 >= 共和 → 卡特连任
## (now_leader=1, oil_price+=2)；否则里根(now_leader=0, oil_price-=2,
## allcountries[51].SubGosstroy=12)——与原版 Event114.cs:115-128 逐条同向。
## 差异：
##  - OAR → ws flag "oar"；allcountries[15].cw → legacy 15 内战中
##  - allcountries[1]（中国）isASEAN/isSEATO：项目无对应 tag → 按玩家国家 tag 处理
##  - resultOfEvents[46]==2 / event_done[455]：由 _us_party_scores 按原作完整条目计入
##  - allcountries[84].Gosstroy → legacy 84 government；allcountries[8] → legacy 8
##  - allcountries[51].SubGosstroy=12 → legacy 51（美国）sub_government = NEOLIBERAL

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if ws.empires.size() <= EmpireData.USA:
		return
	var usa: EmpireData = ws.empires[EmpireData.USA]
	var opt := int(context.get("option_index", -1))

	# 选举计分与修正54同口径（极性判定依据见 modifier_catalog._us_party_scores 头注）。
	# 民主分 >= 共和分 → 卡特连任，与原版 Event114.cs:115 num2>=num 同向。
	var scores := ModifierCatalog._us_party_scores(ws)
	var dem := int(scores.get("dem", 0))
	var rep := int(scores.get("rep", 0))

	context["result_title"] = tr("event.script.event_114_donkey_elephant.i0")
	if opt == 0 and dem >= rep:
		# 卡特连任
		usa.current_leader = 1
		if d.size() > 143:
			d.oil_price += 2   # 原 data.oil_price（无端口命名键）
		context["result_text"] = tr("event.script.event_114_donkey_elephant.i1")
	elif opt == 0:
		# 里根当选
		usa.current_leader = 0
		if d.size() > 143:
			d.oil_price -= 2
		var usa_country := ws.get_country_by_legacy_index(51)
		if usa_country != null:
			usa_country.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		context["result_text"] = tr("event.script.event_114_donkey_elephant.i2")
	else:
		context["result_text"] = tr("event.script.event_114_donkey_elephant.i3")



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_114_donkey_elephant.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "donkey_elephant",
	"num": 114,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1980.11.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
