extends RefCounted

## Event709 复杂触发钩子（EventDef.trigger_script 调用 evaluate(world) -> bool）。
## 对齐 TimeScript.cs:10572-10578：
##   c14.SubGosstroy==19 && c14.parts[6] && IsAuthoritarianism(101)
##   && c14.puppetOf<0 && data[186]<=4 && !event_done[709]（fire_only_once 承担）
## IsAuthoritarianism = Gosstroy==0 且 SubGosstroy!=0（world_state.is_authoritarian）。


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var iraq := world.get_country_by_legacy_index(14)
	if iraq == null or iraq.sub_government != 19 or iraq.puppet_of >= 0:
		return false
	if iraq.parts.size() <= 6 or not iraq.parts[6]:
		return false
	var saudi := world.get_country_by_legacy_index(101)
	if saudi == null or not world.is_authoritarian(saudi):
		return false
	if world.数值表.size() <= 186 or world.数值表[186] > 4:
		return false
	return true
