extends "res://数据脚本/event_script_base.gd"

## 原作 Event586.cs：红海的十字路口（吉布提局势，三选项）。
## 触发：ReqEventForDLC02.cs:834-837 —— !c42.parts[0] && !c41.parts[1]
##   && ((日>=7 且 月>=10 且 年>=1981) || (月>=11 且 年>=1981) || 年>=1982)。
##   parts 数组不可用 ExprNode 表达 → trigger_script evaluate。
## 差异：
##  - 选项显隐 prepare 动态改写；resultOfEvents[585] 缺省按原版 int 默认 0；
##  - Torg → 对华贸易；proprc → 亲中；prosov → 亲苏；
##  - influencePRC vs empires[1].power → ws.influence_prc vs ws.empires[USSR].power。



const TXT_OPT0_DIS := "我们要是早点干涉就好了……"
const TXT_OPT1_DIS := "爱莫能助啊……"

const TXT_R0 := "我们向古莱德透露了政变的消息，在我们特勤人员和军事观察家的帮助下，政府军击溃并确保了该国北部的稳定。古莱德总统很感谢我们的帮助，他越来的越倒向我国。在最近，他正式宣布把原全国独立联盟，索马里解放阵线，吉布提解放运动，人民解放运动等组织的部分人士和革命军人整合为吉布提人民争取进步同盟。其中揉杂了索马里民族主义，社会主义，市场经济，阶级斗争等各式各样的思想，但我们至少收获了一个盟友。"
const TXT_R1_FAIL := "尽管我们支持了埃塞俄比亚同志推翻帝国主义代理人的方案，甚至还有苏联帮助，他们仍然不过放了几枪几炮就走了。\n真的是，我才不怕打，一听到打我就高兴，吉布提算什么打……"
const TXT_R1_WIN := "我们支持了埃塞俄比亚革命者把共产主义的理想传遍非洲之角的理想。在我们的解放军工兵和埃塞俄比亚战士的帮助下，FRUD的士兵打下了北部的奥博克镇。在巨大的伤亡后，FRUD的士兵攻入了吉布提。法国士兵尽力反抗，无果，只得撤退。新的吉布提人民民主共和国也被建立了起来。FRUD也改组为吉布提工人党，并公开转向"
const TXT_R1_USSR := "苏联的怀抱。"
const TXT_R1_PRC := "我们的怀抱。"
const TXT_R1_END := "共产主义又在一个国家取得了胜利。"
const TXT_R2 := "无聊的地方发生了无聊的事情，他们果然还是没打起来啊。"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var c42 := world.get_country_by_legacy_index(42)
	var c41 := world.get_country_by_legacy_index(41)
	if c42 != null and c42.parts.size() > 0 and c42.parts[0]:
		return false
	if c41 != null and c41.parts.size() > 1 and c41.parts[1]:
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() <= 21:
		return false
	if d.year >= 1982:
		return true
	if d.year >= 1981 and d.month >= 11:
		return true
	if d.year >= 1981 and d.month >= 10 and d.day >= 7:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line != 0 and line != 4:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c106 := ws.get_country_by_legacy_index(106)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if c106 != null:
				c106.government = GameConstants.Government.REFORMIST
				c106.sub_government = GameConstants.SubGovernment.PRAGMATIST
				_leave_alliances(c106)
				c106.set_tag("对华贸易", true)
				c106.set_tag("亲中", true)
				c106.social_stability = 1000
			ws.influence_prc += 20
			_add(W.I_DIPLO, 15)
			context["result_text"] = TXT_R0
		1:
			var r585 := int(ws.completed_event_ids.get("event_585", 0))
			if r585 != 2:
				context["result_text"] = TXT_R1_FAIL
			else:
				var text := TXT_R1_WIN
				if c106 != null:
					_leave_alliances(c106)
				var ussr_power := ws.empires[EmpireData.USSR].power if ws.empires.size() > EmpireData.USSR \
						and ws.empires[EmpireData.USSR] != null else 0
				if ws.influence_prc < ussr_power:
					text += TXT_R1_USSR
					if c106 != null:
						c106.set_tag("亲苏", true)
					_add_power(EmpireData.USSR, 20)
				else:
					text += TXT_R1_PRC
					if c106 != null:
						c106.set_tag("亲中", true)
						c106.social_stability = 1000
					ws.influence_prc += 20
				text += TXT_R1_END
				_add(W.I_ARMY, -50)
				if c106 != null:
					c106.government = GameConstants.Government.AUTHORITARIAN
					c106.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
					c106.set_tag("对华贸易", true)
				_add_relation(EmpireData.USA, -100)
				_add(W.I_DIPLO, 5)
				context["result_text"] = text
		2:
			context["result_text"] = TXT_R2
