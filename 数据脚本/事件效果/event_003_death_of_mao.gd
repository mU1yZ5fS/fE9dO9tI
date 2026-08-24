extends "res://数据脚本/event_script_base.gd"

## 原作 Event3.cs：舵手逝世三选项。
## 公共效果（三选项均执行）：稳定=100(SET)、politics[0] 替换为毛远新并按原文覆写字段、
## politics_positions[1]=150。分支：opt0/1/2 各自的资源增减 + politicians[1..4] 忠诚循环 + 动态文案。
## 因「覆写政治家」「仅 [1..4] 忠诚」不可声明式 → 全部走自定义脚本（含公共 stability，避免与 .tres 双写）。
## 差异：ws.leader 保持开局独立华国锋对象（项目结构），不再把政客槽覆写成华国锋造成双显示。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))

	# 公共效果（Event3.cs:26-37，三选项均执行；原作 Set(222) 在稳定性覆写之前）
	Achievements.set_achievement(222)  # 原作 Event3.cs:26-29 iron_and_blood → achievements.Set(222)
	d.stability = 100
	_replace_mao_with_mao_yuanxin()

	if opt == 0:
		d.thought_freedom -= 50
		d.people_support += 20
		_add_loyalty_1_to_4(200)
		context["result_text"] = tr("event.script.event_003_death_of_mao.i0")
	elif opt == 1:
		d.thought_freedom -= 70
		d.people_support += 50
		d.party_support += 40
		d.budget -= 10
		_add_loyalty_1_to_4(-300)
		d.mao_mausoleum = 10
		context["result_text"] = tr("event.script.event_003_death_of_mao.i1")
	elif opt == 2:
		d.thought_freedom -= 70
		d.people_support += 50
		d.party_support -= 40
		_add_loyalty_1_to_4(-500)
		d.mao_mausoleum = 10
		context["result_text"] = tr("event.script.event_003_death_of_mao.i2")


## 毛泽东逝世后的公共处理：移除毛槽、点名补入毛远新，并按 Event3.cs:29-37 原文覆写其档案字段。
## ws.leader 保持开局独立华国锋对象，不指向政客槽，避免“实权领袖 + 政客卡”双显示。
func _replace_mao_with_mao_yuanxin() -> void:
	if ws.politicians.is_empty() or ws.politicians[0] == null:
		return
	# 移除毛泽东槽，固定点名补入毛远新（原版死亡补员后极左派槽由毛远新接任）。
	# 若毛远新已入场/未到年份/池中无人，才回退常规补员规则。
	var mao_yuanxin_already_exists := PoliticianSystem.has_politician("毛远新", 1, 41)
	game.kill_politician(0, "毛远新")
	if ws.politicians.size() > 0 and ws.politicians[0] != null:
		var p: PoliticianData = ws.politicians[0]
		# 防重名：毛远新已在场时不再把 0 号槽覆写成第二个毛远新。
		if not mao_yuanxin_already_exists:
			# Event3.cs:30-37 逐字段覆写。
			PoliticianSystem.apply_historical_profile(
				p, "毛远新", 1, 41,
				GameConstants.PoliticianPersonality.FAR_LEFT,
				GameConstants.PoliticianBackground.MASS_LEADER,
				GameConstants.PoliticianAlignment.HARDLINER,
				GameConstants.PoliticianSpecial.PEOPLES_FRIEND,
				d.year - 1941,
				700, p.loyalty
			)
	# 军委由实权领袖本人担任（原 politics_dolshnost[1]=150）
	if ws.politics_positions.size() > 1:
		ws.politics_positions[1] = WorldFactory.LEADER_POSITION_SENTINEL


## Event3.cs 三选项均对 politics[1..4] 施加相同忠诚增减
func _add_loyalty_1_to_4(delta: int) -> void:
	for i in range(1, 5):
		if i < ws.politicians.size() and ws.politicians[i] != null:
			ws.politicians[i].loyalty += delta



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_003_death_of_mao.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "death_of_mao",
	"num": 3,
	"trigger": [{"t": "DATE_AFTER", "key": "1976.9.9"}],
	"options": [{"fx": [{"t": "SET_FLAG", "key": "mao_dead"}, {"t": "SET_FLAG", "key": "mao_cremated"}, {"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "SET_FLAG", "key": "mao_dead"}, {"t": "SET_FLAG", "key": "mao_mausoleum"}, {"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "SET_FLAG", "key": "mao_dead"}, {"t": "SET_FLAG", "key": "mao_mausoleum"}, {"t": "CUSTOM_SCRIPT"}]}],
}
