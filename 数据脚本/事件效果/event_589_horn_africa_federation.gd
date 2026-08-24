extends "res://数据脚本/event_script_base.gd"

## 原作 Event589.cs：在同一面红旗之下（埃塞俄比亚-索马里联邦，两选项）。 ## 触发：TimeScript.cs:10908-10913 —— 无日期条件： ##   c42.亲中 && c41.亲中 && c42.Gosstroy!=0 && c41.Gosstroy!=0 ##   && modifies[6].is_active && (c1.Gosstroy==1 c1.SubGosstroy==0) ##   && !event_done[403]；parts[0/1/2] 由 CountryData.parts 建模。 ## 差异： ##  - EstablishGovernment(ProChina) → 只设 亲中=true、亲苏/亲美=false（不设 government）； ##  - c41.name = "非洲之角联邦" → chinese_name（既有约定）； ##  - JoinAllOurAlliances(true) → 复制玩家全部 true 标签。



const TXT_R0 := "event.script.event_589_horn_africa_federation.c0"
const TXT_R1 := "event.script.event_589_horn_africa_federation.c1"
const TXT_NAME_ETHIOPIA := "event.script.event_589_horn_africa_federation.c2"
## Godot 地图显示增量：原版用 parts 驱动地图合并，本端口用 map_regions 归属覆盖模拟。 ## 埃塞俄比亚 gwcode=530，索马里 gwcode=520；联邦成立后索马里区域归属 530。
const HORN_FEDERATION_GWCODE := 530
const SOMALIA_REGION_IDS := [30, 31, 32, 33, 34, 35, 45, 46, 1466, 2028, 2029, 2030, 2031, 4115]


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	_enable(event_def.options[0], event_def.options[0].text)
	_enable(event_def.options[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var ethiopia := ws.get_country_by_legacy_index(41)
	var somalia := ws.get_country_by_legacy_index(42)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if ethiopia != null:
				ethiopia.set_part(0, true)
				ethiopia.chinese_name = tr(TXT_NAME_ETHIOPIA)
				# 政体名优先于 chinese_name，必须同步改 gov_names 才能在世界地图/国家面板显示“非洲之角联邦”。 # 原版 name 固定为联邦名，不随政体变化，因此覆盖全部政体名。
				for gn_key in ethiopia.gov_names:
					ethiopia.gov_names[gn_key] = tr(TXT_NAME_ETHIOPIA)
				ethiopia.government = GameConstants.Government.SOCIALIST
				ethiopia.sub_government = GameConstants.SubGovernment.MAOIST
			if somalia != null:
				_leave_alliances(somalia)
			if ethiopia != null:
				_establish_pro_china(ethiopia)
				ethiopia.set_tag("对华贸易", true)
				_join_all_our_alliances(ethiopia)
			# 地图合并：索马里区域并入埃塞俄比亚（联邦）。
			if GameManager != null:
				game.set_map_region_owner(SOMALIA_REGION_IDS, HORN_FEDERATION_GWCODE)
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)


## Country.LeaveAlliances() 逐项映射（含原版不常见的联盟标签）。

func _establish_pro_china(c: CountryData) -> void:
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)


func _join_all_our_alliances(c: CountryData) -> void:
	var player := ws.get_player_country()
	if player == null:
		return
	for tag_key in player.tags:
		if player.tags[tag_key]:
			c.set_tag(tag_key, true)






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_589_horn_africa_federation.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_589",
	"num": 589,
	"priority": 58900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_589_horn_africa_federation.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "42"}, {"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "41"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "government", "target": "42"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "government", "target": "41"}, {"t": "MODIFIER_ACTIVE", "key": "6"}, {"t": "ANY", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 1, "target": "1"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "target": "1"}]}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_403"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
