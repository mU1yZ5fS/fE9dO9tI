extends "res://数据脚本/event_script_base.gd"

## 原作 Event92.cs：超额完成是荣誉！（五年计划重点，五选项）。
## 触发：TimeScript.cs:10759-10765 —— data[16]<=11 && event_done[38]。
## 效果：data[102]=1..5（五年计划重点），data[8]-=10。
## 注：data[102] 无命名键，直访 d[102]。

const TXT_R := [
	"中国政府决定增加对轻工业和重工业的现代化建设，提高产品质量和装备水平的投入。新五年计划的主要目的是发展工业。",
	"中国政府决定向农业领域的机械化和新技术的引进拨款。新五年计划的主要目的是发展农业。",
	"中国政府决定提高服务业的服务质量，从预算中拨出额外资金。新五年计划的主要目标是实现服务业步入现代化。",
	"中国政府宣布了当前五年计划的经济发展计划，表明需要加快科技进步和引进新的管理国民经济的方法。新五年计划的主要目的是发展科学。",
	"尽管有国家计委的建议，中国政府还是宣布需要国民经济各方面的统一发展，并从国家预算中拨款。",
]


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt >= 0 and opt <= 4:
		if d.size() > 102:
			d[102] = opt + 1
		if d.size() > W.I_BUDGET:
			d[W.I_BUDGET] -= 10
		context["result_text"] = TXT_R[opt]
