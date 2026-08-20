const fs = require('fs');
const path = require('path');

const file = path.join(process.cwd(), '数据脚本', 'world_state.gd');
let src = fs.readFileSync(file, 'utf8');

// 1. Header
src = src.replace(
  '## 顶层游戏状态 — 存档的根对象。\n## 数值表[200] 是唯一权威数据源，EconomyData 只是它的显示视图。',
  '## 顶层游戏状态 — 存档的根对象。\n## 所有玩家数值均为具名字段；EconomyData 是只读显示视图。'
);

// 2. Insert generated named fields before "# ── 时间 ──"
const fields = fs.readFileSync(path.join(process.cwd(), 'tools', 'numeric_table_fields.gd'), 'utf8').trim();
const marker = '\n# ── 时间 ──\n';
if (!src.includes('# ── 数值表：具名字段 ──')) {
  src = src.replace(marker, '\n# ── 数值表：具名字段 ──\n' + fields + '\n' + marker);
}

// 3. Remove old array declaration
src = src.replace(/# ── 数值表：唯一权威数据源 ──?
@export var 数值表: Array[int] = []?
/g, '# ── 数值表已拆分为具名字段（见上方） ──
');
// Remove resize in _init
src = src.replace(/\t数值表\.resize\(200\)\n/g, '');

// 4. Replace numeric table read/write methods
const getDataValue = `func get_data_value(key: String) -> int:
	if key.to_lower() in ["war", "war_state"]:
		return war_state
	if key.to_lower() == "influence_prc":
		return influence_prc
	var idx := get_data_index(key)
	if idx >= 0 and idx < size():
		return get_data_by_index(idx)
	return 0
`;

const setDataValue = `func set_data_value(key: String, value: int) -> void:
	if key.to_lower() in ["war", "war_state"]:
		var old_war := war_state
		war_state = value
		value_changed.emit(-1, old_war, war_state)
		return
	if key.to_lower() == "influence_prc":
		var old_inf := influence_prc
		influence_prc = value
		value_changed.emit(-1, old_inf, influence_prc)
		return
	var idx := get_data_index(key)
	if idx >= 0 and idx < size():
		var old := get_data_by_index(idx)
		if old != value:
			set_data_by_index(idx, value)
			_economy_dirty = true
			value_changed.emit(idx, old, value)
`;

const addDataValue = `func add_data_value(key: String, delta: int) -> void:
	if key.to_lower() in ["war", "war_state"]:
		var old_war := war_state
		war_state += delta
		value_changed.emit(-1, old_war, war_state)
		return
	if key.to_lower() == "influence_prc":
		var old_inf := influence_prc
		influence_prc += delta
		value_changed.emit(-1, old_inf, influence_prc)
		return
	var idx := get_data_index(key)
	if idx >= 0 and idx < size():
		var old := get_data_by_index(idx)
		var new_value := old + delta
		set_data_by_index(idx, new_value)
		_economy_dirty = true
		value_changed.emit(idx, old, new_value)
`;

// Replace old function bodies
src = src.replace(/func get_data_value\(key: String\) -> int:[\s\S]*?\n\nfunc set_data_value/, getDataValue + '\nfunc set_data_value');
src = src.replace(/func set_data_value\(key: String, value: int\) -> void:[\s\S]*?\n\nfunc add_data_value/, setDataValue + '\nfunc add_data_value');
src = src.replace(/func add_data_value\(key: String, delta: int\) -> void:[\s\S]*?\n\n## 具名门面/, addDataValue + '\n\n## 具名门面');

// 5. Add helper methods after add_value (before get_data_value_for_country)
let helperBlock = `
## 动态下标兼容入口：新代码应使用具名字段，这里仅用于尚未迁移完的旧调用。
func get_data_by_index(idx: int) -> int:
	var field: String = FIELD_BY_INDEX.get(idx, "")
	if field == "":
		return 0
	return get(field) as int


func set_data_by_index(idx: int, value: int) -> void:
	var field: String = FIELD_BY_INDEX.get(idx, "")
	if field == "":
		return
	set(field, value)


func add_data_by_index(idx: int, delta: int) -> void:
	set_data_by_index(idx, get_data_by_index(idx) + delta)


func size() -> int:
	return FIELD_NAMES.size()


func _collect_values() -> Array[int]:
	var arr: Array[int] = []
	arr.resize(FIELD_NAMES.size())
	for i in FIELD_NAMES.size():
		arr[i] = get(FIELD_NAMES[i]) as int
	return arr


const FIELD_NAMES: Array[String] = [
`;
// Build field names list
const map = JSON.parse(fs.readFileSync(path.join(process.cwd(), 'tools', 'numeric_table_mapping.json'), 'utf8'));
const names = [];
for (let i = 0; i <= 186; i++) {
  const e = map[String(i)];
  if (e) names.push(`"${e.name}"`);
}
helperBlock += names.join(', ') + '\n]\n\n';
helperBlock += `const FIELD_BY_INDEX := {
`;
for (let i = 0; i <= 186; i++) {
  const e = map[String(i)];
  if (e) helperBlock += `\t${i}: "${e.name}",\n`;
}
helperBlock += `}
`;

src = src.replace(/\n## 指定国家的资源查询。玩家国家走数值表，非玩家国家查 CountryData 字段。/,
  '\n' + helperBlock + '\n## 指定国家的资源查询。玩家国家走具名字段，非玩家国家查 CountryData 字段。');

// 6. Economy sync
src = src.replace(/玩家经济\.sync\(数值表\)/, '玩家经济.sync_from_world(self)');

// 7. Snapshot methods
src = src.replace(/入口快照 = 数值表\.duplicate\(\)/, '入口快照 = _collect_values()');
src = src.replace(/上期变化 = 数值表\.duplicate\(\)/, '上期变化 = _collect_values()');
src = src.replace(/上期变化\[i\] = 数值表\[i\] - 入口快照\[i\]/, '上期变化[i] = get_data_by_index(i) - 入口快照[i]');

fs.writeFileSync(file, src);
console.log('world_state.gd rewritten');
