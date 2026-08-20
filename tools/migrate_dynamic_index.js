const fs = require('fs');
const path = require('path');

const ROOT = process.cwd();
const files = [];
function walk(dir) {
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) {
      if (ent.name === '.godot' || ent.name === '.git' || ent.name === 'tools') continue;
      walk(p);
    } else if (ent.name.endsWith('.gd')) {
      files.push(p);
    }
  }
}
walk(ROOT);

function transform(s) {
  let out = s;
  // For each alias, convert compound/assignment/read.
  for (const alias of ['d', 'data', 'dv', 'dd', 'd2', 'dpre']) {
    const a = `\\b${alias}`;
    out = out.replace(new RegExp(`${a}\\[([^\\]]+)\\] \\+= ([^\\n]+)`, 'g'), `${alias}.add_data_by_index($1, $2)`);
    out = out.replace(new RegExp(`${a}\\[([^\\]]+)\\] -= ([^\\n]+)`, 'g'), `${alias}.add_data_by_index($1, -($2))`);
    out = out.replace(new RegExp(`${a}\\[([^\\]]+)\\] = ([^\\n]+)`, 'g'), `${alias}.set_data_by_index($1, $2)`);
    out = out.replace(new RegExp(`${a}\\[([^\\]]+)\\]`, 'g'), `${alias}.get_data_by_index($1)`);
  }
  return out;
}

let changed = 0;
for (const file of files) {
  const original = fs.readFileSync(file, 'utf8');
  const updated = transform(original);
  if (updated !== original) {
    fs.writeFileSync(file, updated);
    changed++;
    console.log('fixed', path.relative(ROOT, file));
  }
}
console.log('Changed files:', changed);
