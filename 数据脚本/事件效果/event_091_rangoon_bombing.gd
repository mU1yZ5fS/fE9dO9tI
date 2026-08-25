extends "res://数据脚本/event_script_base.gd"

## 原作 Event91.cs：仰光爆炸事件 / 墨西哥爆炸案（按 c33 社会主义与否双标题）。
## 触发：TimeScript.cs:10752-10758 ——
##   (日>=9 且 月>=10 且 年>=1983 或 年>=1984) && c46.Gosstroy==0
##   && c46.SubGosstroy==7 && !wars[90].is_going && !c10.parts[0]
##   （c10.parts[0] 未置位时默认 false，端口建模说明 → 视为恒真，注释保留）。
## 差异：标题/描述 prepare 动态改写。

const TXT_R0 := "event.script.event_091_rangoon_bombing.c0"

const TXT_R1 := "event.script.event_091_rangoon_bombing.c1"

const TXT_R2 := "event.script.event_091_rangoon_bombing.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var burma := world.get_country_by_legacy_index(33)
	if burma != null and world.is_socialism(burma, true):
		event_def.title = "墨西哥爆炸案"
		event_def.description = "出于让墨西哥支持汉城奥运会的需要，全斗焕率团前往墨西哥访问。韩国代表团原计划在墨西哥革命纪念塔处献花，但由于交通堵塞，全斗焕的专车延误近半个小时。而在墨西哥总统米格尔·德拉马德里等人等待时，由部分朝鲜特工和地下革命工人党-人民联盟的游击战士组成的敢死队引爆了事先安装在革命纪念塔附近的炸弹。爆炸瞬间杀死了数名墨西哥高官，米格尔·德拉马德里总统由于距离炸弹较远幸免于难，敢死队在爆炸后和总统卫队进行交火试图突围，但是寡不敌众，最终被尽数消灭。\n此次爆炸案后，墨西哥宣布与朝鲜全面断交，韩国和西方阵营则认为此次袭击是朝鲜极权恐怖主义的又一大体现。而根据朝鲜的说法，这些特工均为叛逃分子，非朝鲜官方所为，并声称一切指控均为西方阵营空穴来风的污蔑。"
	else:
		event_def.title = "仰光爆炸事件"
		event_def.description = "根据我们的情报，今天在缅甸首都发生了一起恐怖袭击，目的是刺杀韩国总统全斗焕。由于全斗焕在爆炸发生两分钟后抵达现场，他本人幸免于难，但有17名韩国代表团成员丧生。恐怖分子很快被抓获，经过审问，他们承认自己是朝鲜军队的军官。而朝鲜政府矢口否认与此事有任何牵连，但实际上，这一事件让我们有机会重新挑起朝鲜和韩国之间的对抗。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, -10)
			_add_relation(EmpireData.USA, 100)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_DIPLO, 20)
			_add_relation(EmpireData.USA, -80)
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)







# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_091_rangoon_bombing.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_091",
	"nodesc": true,
	"num": 91,
	"priority": 9100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_091_rangoon_bombing.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1983.10.9"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "target": "46"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 7, "target": "46"}, {"t": "NOT", "c": [{"t": "WAR_ACTIVE", "v": 90}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
