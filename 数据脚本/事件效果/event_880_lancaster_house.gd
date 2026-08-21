extends "res://数据脚本/event_script_base.gd"

## 原作 Event880.cs：兰开斯特宫协议（单选项）。
## 触发：TimeScript.cs:10724-10730 —— (月>=12 且 年>=1979 或 年>=1980)。
## 共同效果：c127.name="南罗得西亚"（先于 result 分支）。
## result1/result2 在 kolvo_variant=1 下不可达，按死代码跳过。

const TXT_RESULT := "《兰开斯特宫协议》将于1979年12月21日签署。卡林顿勋爵和伊恩·吉尔摩爵士代表英国签署了该协议，阿贝尔·穆佐雷瓦和西拉斯·蒙达瓦拉代表津巴布韦罗得西亚政府签署了该协议，罗伯特·穆加贝和约书亚·恩科莫代表爱国阵线签署了该协议。罗伯特·马修斯认为，兰开斯特宫谈判的成功可以通过“战场上的力量平衡明显有利于民族主义者”、国际制裁对罗得西亚经济的影响、“特定的第三方利益模式”以及卡林顿勋爵作为调解人所带来的资源和技能来解释。该协议也被描述为”宪法妥协”。\n虽然该项协议显著降低了国际社会对津巴布韦罗得西亚的观感，但美国仍然拒绝取消制裁。\n根据协议条款，津巴布韦罗得西亚暂时恢复其原南罗得西亚殖民地地位，从而结束了罗得西亚单方面宣布独立所引发的混乱。索姆斯勋爵被任命为总督，拥有完全的行政和立法权。该协议将导致几个月前由内部解决方案创建的津巴布韦罗得西亚这个未被承认的国家的名存实亡。根据停火协议，ZAPU和ZANU的游击队将在英国的监督下在指定的集合地点集合，然后举行选举，选出新政府。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var rhodesia := ws.get_country_by_legacy_index(127)
	if rhodesia != null:
		rhodesia.name = "南罗得西亚"
		rhodesia.chinese_name = "南罗得西亚"
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		context["result_text"] = TXT_RESULT
