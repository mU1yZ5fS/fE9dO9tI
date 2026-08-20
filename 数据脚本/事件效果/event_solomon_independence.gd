extends EventScriptBase

## 所罗门群岛独立（1978-07-07 起自动触发，Godot 增量事件，原版无对应 C# 事件）。
## 原版 161 号国家开局随英国（world_factory _copy_gs(161, 92) + puppet 92）；
## 本事件按史实让所罗门独立：脱离英国傀儡、政体沿用英国式社会民主主义，
## 并把地图上英国（200）的所罗门地块转给所罗门群岛（940）。

const TXT_RESULT := "1978年7月7日，所罗门群岛正式独立，成为英联邦内的主权国家。所罗门群岛联合党领袖彼得·凯尼洛雷亚宣誓就任首任总理。新国家沿袭了威斯敏斯特式的议会民主制度，继续与英国保持友好关系。\n我们的代表出席了独立庆典，并向这个年轻的太平洋岛国表达了祝贺——尽管它仍然与世界经济的中心相距甚远。"

const SOLOMON_REGION_IDS: Array[int] = [
	2946, 2948, 2949, 2950, 2951, 2952, 2953, 2955, 2957, 3060,
]
const SOLOMON_GWCODE := 940


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var solomon := ws.get_country_by_legacy_index(161)
	if solomon != null:
		solomon.puppet_of = -1
		solomon.government = GameConstants.Government.LIBERAL
		solomon.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
		if GameManager != null:
			GameManager.set_map_region_owner(SOLOMON_REGION_IDS, SOLOMON_GWCODE)
	context["result_text"] = TXT_RESULT
