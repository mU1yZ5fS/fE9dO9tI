extends "res://数据脚本/event_script_base.gd"

## 原作 Event314.cs：被击落的韩国波音（3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:514-517 —— 日>=1 月>=9 年>=1983 且 苏联(7)非北约 且 朝鲜(10)!parts[0] 且 战争90未进行。
## 差异：isNATO→has_tag("nato")，parts 字段映射 CountryData.parts；文本来自 Events_text_en 索引 126-133。

const TXT_R0 := "中国政府尚未对此事发表正式评论。只有少数代表向遇难者家属表示慰问。很明显，这场灾难严重恶化了当时苏美之间本已恶劣的关系。"
const TXT_R1 := "我们的媒体整体上重复了西方媒体的论点，要求“追究肇事者的责任”。我们还向苏联大使发出了抗议照会，我国驻联合国的代表也呼吁对这场灾难进行国际调查。这些行动得到了西方大国的同情，但引起了对苏联政府的不满。无论如何，苏联开始与美日两国就建立一个跟踪北太平洋上空航运动向的统一系统进行谈判。"
const TXT_R2 := "此次坠机事故责任全在波音机组人员和美国军方，他们数次侵犯了苏联边境。这是中华人民共和国对事故的官方表态。这自然引起了西方媒体及西方国家代表的不满，并大大恶化了我们与西方世界的关系。但另一方面，我们同苏联的关系明显回温：苏联代表向我们表示感谢，并提出在中华人民共和国和苏联空军之间建立直接合作关系，以便在今后对这种情况作出有效反应。"

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world.数值表
	if data.size() <= W.I_YEAR:
		return false
	var date_ok := data[W.I_DAY] >= 1 and data[W.I_MONTH] >= 9 and data[W.I_YEAR] >= 1983
	var ussr := world.get_country_by_legacy_index(7)
	var north_korea := world.get_country_by_legacy_index(10)
	var nato_ok := ussr == null or not ussr.has_tag("nato")
	var parts_ok := north_korea == null or north_korea.parts.size() == 0 or not north_korea.parts[0]
	var war_ok := world.wars.size() <= 90 or world.wars[90] == null or not world.wars[90].is_going
	return date_ok and nato_ok and parts_ok and war_ok

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add_relation(1, -150)
			_add_relation(0, 100)
			context["result_text"] = TXT_R1
		2:
			_add_relation(1, 100)
			_add_relation(0, -150)
			context["result_text"] = TXT_R2

	

