extends "res://数据脚本/event_script_base.gd"

## 原作 Event495.cs：阿里郎，阿里郎（朝韩和平统一，二选项）。
## 触发：DiploButtonScript.cs:11468 —— this_type==1013 外交按钮手动触发；
##   按项目约定 trigger_conditions=[]（仅定义，待外交入口接入）。
## 差异：
##  - SubGosstroy/Gosstroy → sub_government/government；
##  - name → name/chinese_name；Torg → set_tag("对华贸易", true)；
##  - parts[0] 用 _set_part 置位；LeaveAlliances() → _leave_alliances。




const TXT_R0 := "但是我答应，下次政治局会议的时候一定会提到这件事的…下次一定！"

const TXT_R1_PRE := "朝鲜领导人"
const TXT_R1_KIM := "金日成"
const TXT_R1_JANG := "张成泽"
const TXT_R1_MID := "与韩国领导人"
const TXT_R1_KIMDAE := "金大中"
const TXT_R1_AHN := "安必洙"
const TXT_R1_POST := "在平壤进行和平统一谈判，在我们与朝韩两方的共同努力下，朝韩两个政权将统一为高丽民主联邦共和国，朝韩双方将保留自治，但是均开放党禁，并宣布十年之后将会进行半岛光复以来第一次南北总选举；双方人员自由通行，并着手准备裁军，驻扎在半岛的外国军队及代表也陆续撤出，经济上则允许私人资本进入北方进行投资，对外则改善中美苏日等周边大国的关系，并成功申请汉城奥运会了。阿里郎的歌声最终跨越了停火线。"

const TXT_NAME_UNIFIED := "高丽民主联邦共和国"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var north := ws.get_country_by_legacy_index(10)
	var south := ws.get_country_by_legacy_index(46)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			var text := TXT_R1_PRE
			if north != null and north.sub_government == GameConstants.SubGovernment.PRAGMATIST:
				text += TXT_R1_KIM
			else:
				text += TXT_R1_JANG
			text += TXT_R1_MID
			if south != null and south.government == GameConstants.Government.LIBERAL:
				text += TXT_R1_KIMDAE
			else:
				text += TXT_R1_AHN
			text += TXT_R1_POST
			if north != null:
				_set_part(north, 0, true)
				north.government = GameConstants.Government.REFORMIST
				north.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				north.name = TXT_NAME_UNIFIED
				north.chinese_name = TXT_NAME_UNIFIED
				_leave_alliances(north)
				north.set_tag("对华贸易", true)
			context["result_text"] = text


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value


