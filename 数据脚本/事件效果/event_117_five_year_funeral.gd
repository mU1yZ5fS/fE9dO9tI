extends "res://数据脚本/event_script_base.gd"

## 原作 Event117.cs：五年修葬（1984.2.14 安德罗波夫葬礼，契尔年科继任）。
## 触发：TimeScript.cs:10831（1984.2.9 后 且 苏 now_leader==1 安德罗波夫 且 !IndOpp 且 !=7）。
## .tres 触发条件用 EMPIRE_LEADER_IS("1",1) 表达"安德罗波夫在位"（本次追加的条件类型）。
## 三选项（Event117.cs）：不派代表团(关系-100)/派代表团(关系+100)/领导人亲往(关系+150)；
## 北约时雅科夫列夫(now_leader=7)（allcountries[7].isNATO → 差异：项目用玩家是否加入北约相关 tag 近似，
## 原版 allcountries[7] 为德国；端口无对应 → 按假处理，走契尔年科分支）。
## 差异：allcountries[7].isNATO 端口无对应 → 恒假（契尔年科分支）。
## 选项门槛（Event117.cs VariantsOfEvents，2026-08 复核补齐）：
##   - opt0 仅玩家非苏阵营时可选（原版 isSEV 时 Destroy(button[0])，
##     槽位文案替换为"我们必须去"→ 现作禁用提示，CSV option_0.disabled）；
##   - opt1/opt2 需 relres 标记 或 玩家 has_tag("sev")（原版 relres||isSEV）；
##   - opt0 的关系 -100 原版仅 relres 为真时生效，execute 已改为同条件。

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if ws.empires.size() <= EmpireData.USSR:
		return
	var ussr: EmpireData = ws.empires[EmpireData.USSR]
	var opt := int(context.get("option_index", -1))

	# 选项关系修正（Event117.cs result 0/1/2）
	match opt:
		0:
			# 原版 result_num==0：仅 relres 时 relations-100（Event117.cs）
			if ws.get_flag("relres"):
				ussr.relations = clampi(ussr.relations - 100, 0, 1000)
		1:
			ussr.relations = clampi(ussr.relations + 100, 0, 1000)
		2:
			ussr.relations = clampi(ussr.relations + 150, 0, 1000)

	# 差异：allcountries[7].isNATO → 雅科夫列夫(7)；端口无对应 → 恒走契尔年科(2)
	ussr.current_leader = 2
	context["result_title"] = tr("event.script.event_117_five_year_funeral.i0")
	var tail := "\n 不出所料，康斯坦丁·契尔年科当选为总书记。然而，考虑到他年事已高，他在这个职位上呆不了多久。"
	if opt == 0:
		context["result_text"] = "安德罗波夫的葬礼于1984年2月14日12点在莫斯科红场克里姆林宫附近举行。多国国家元首和政府首脑出席了葬礼及告别仪式。" + tail
	elif opt == 1:
		context["result_text"] = "苏联感谢我们的慰问，并接待了中国代表团。安德罗波夫的葬礼于1984年2月14日12点在莫斯科红场克里姆林宫附近举行。多国国家元首和政府首脑出席了葬礼及告别仪式。" + tail
	else:
		context["result_text"] = "我们的领导人亲自带领中国代表团，并在苏联受到热烈欢迎。安德罗波夫的葬礼于1984年2月14日12点在莫斯科红场克里姆林宫附近举行。多国国家元首和政府首脑出席了葬礼及告别仪式。" + tail



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_117_five_year_funeral.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "five_year_funeral",
	"num": 117,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1984.2.9"}, {"t": "EMPIRE_LEADER_IS", "key": "1", "v": 1}]}],
	"options": [
		{"disabled": true, "cond": {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "sev"}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]},
		{"disabled": true, "cond": {"t": "ANY", "c": [{"t": "HAS_FLAG", "key": "relres"}, {"t": "COUNTRY_HAS_TAG", "key": "sev"}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]},
		{"disabled": true, "cond": {"t": "ANY", "c": [{"t": "HAS_FLAG", "key": "relres"}, {"t": "COUNTRY_HAS_TAG", "key": "sev"}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]},
	],
}
