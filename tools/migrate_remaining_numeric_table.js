const fs = require('fs');
const path = require('path');

const ROOT = process.cwd();
const files = [];
function walk(dir) {
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) {
      if (ent.name === '.godot' || ent.name === '.git') continue;
      walk(p);
    } else if (ent.name.endsWith('.gd')) {
      files.push(p);
    }
  }
}
walk(ROOT);

function transform(s) {
  let out = s;
  // assignment/compound first
  out = out.replace(/(\w+)\.数值表\[([^\]]+)\] \+= ([^\n]+)/g, '$1.add_data_by_index($2, $3)');
  out = out.replace(/(\w+)\.数值表\[([^\]]+)\] -= ([^\n]+)/g, '$1.add_data_by_index($2, -($3))');
  out = out.replace(/(\w+)\.数值表\[([^\]]+)\] = ([^\n]+)/g, '$1.set_data_by_index($2, $3)');
  // append: no longer needed; drop the whole statement
  out = out.replace(/[ \t]*\w+\.数值表\.append\([^)]*\)[ \t]*\r?\n/g, '');
  // resize: drop
  out = out.replace(/[ \t]*\w+\.数值表\.resize\([^)]*\)[ \t]*\r?\n/g, '');
  // remaining reads
  out = out.replace(/(\w+)\.数值表\[([^\]]+)\]/g, '$1.get_data_by_index($2)');
  // remaining .数值表 property references become object
  out = out.replace(/(\w+)\.数值表/g, '$1');
  return out;
}

let changed = 0;
for (const file of files) {
  if (file.includes('数据脚本' + path.sep + 'world_state.gd')) continue;
  const original = fs.readFileSync(file, 'utf8');
  const updated = transform(original);
  if (updated !== original) {
    fs.writeFileSync(file, updated);
    changed++;
    console.log('fixed', path.relative(ROOT, file));
  }
}
console.log('Changed files:', changed);
