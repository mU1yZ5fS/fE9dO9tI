extends "res://数据脚本/event_script_base.gd"

## 原作 Event676.cs：再见，老总（朱德逝世，单选项）。
## 触发：TimeScript.cs:10052-10057 —— (日>=6 且 月>=7 且 年>=1976) 或 月>=8。
## 效果：data.army（军力）+89。
## 差异：字符间空格排版不保留；show_notification=false（项目约定）。

const TXT_RESULT := "七月十一日，朱德同志的追悼大会在人民大会堂正式举行。中共中央副主席王洪文同志主持了此次大会，中共中央第一副主席华国锋同志在大会中致辞，表达了对这位“红军之父”“人民的骄傲”的敬重以及其逝去所带来的无比悲痛。值得一提的是，毛主席在病重之时，仍派人送来了花圈。而此时北京阴云密布，细雨连绵。送灵时，从北京医院出口到八宝山的马路两侧，挤满了戴黑纱白花的群众。大家高举横幅，送别这位为人民，为国家操劳一生，伟大的马克思主义者，伟大的无产阶级革命家，政治家，军事家。而朱德的骨灰被安放在八宝山革命公墓礼堂一室，骨灰盒编号101。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		# Event676.cs result 0
		if d.size() > W.I_ARMY:
			d.army += 89
		context["result_text"] = TXT_RESULT
