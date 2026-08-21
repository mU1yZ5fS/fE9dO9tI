extends EventScriptBase

## 伯利兹独立（1981-09-21 起自动触发，Godot 增量事件，原版无对应 C# 事件）。
## 原版 142 号国家开局随英国（world_factory _copy_gs(142, 92) + puppet 92）；
## 本事件按史实让伯利兹独立：脱离英国傀儡、政体沿用英国式社会民主主义，
## 并把地图上英国（200）的伯利兹地块转给伯利兹（80）。

const TXT_RESULT := "1981年9月21日，伯利兹正式独立，成为英联邦内的主权国家。乔治·卡德尔·普赖斯出任首任总理。由于危地马拉长期声称对伯利兹拥有主权，英国承诺在独立后继续驻军保卫伯利兹的安全。\n我们的代表出席了独立庆典，并向这个中美洲的新国家表达了祝贺——伯利兹成为加勒比共同体与不结盟运动的成员，也开启了与整个地区交往的新篇章。"

const BELIZE_REGION_IDS: Array[int] = [2095]
const BELIZE_GWCODE := 80


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var belize := ws.get_country_by_legacy_index(142)
	if belize != null:
		belize.puppet_of = GameConstants.LegacySlot.NONE
		belize.government = GameConstants.Government.LIBERAL
		belize.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
		if GameManager != null:
			game.set_map_region_owner(BELIZE_REGION_IDS, BELIZE_GWCODE)
	context["result_text"] = TXT_RESULT
