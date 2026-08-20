#!/usr/bin/env node
// One-shot codemod: migrate WorldState.数值表 array access to named fields.
// Run from project root: node tools/migrate_numeric_table.js
const fs = require('fs');
const path = require('path');

const ROOT = process.cwd();
const mappingPath = path.join(ROOT, 'tools', 'numeric_table_mapping.json');
const mapping = JSON.parse(fs.readFileSync(mappingPath, 'utf8'));
const indexToName = {};
for (const [idx, info] of Object.entries(mapping)) {
  indexToName[Number(idx)] = info.name;
}

// Parse WorldState constants: I_NAME := value
const wsPath = path.join(ROOT, '数据脚本', 'world_state.gd');
const wsSrc = fs.readFileSync(wsPath, 'utf8');
const constNameByIndex = {};
for (const m of wsSrc.matchAll(/I_([A-Z0-9_]+) := (\d+)/g)) {
  constNameByIndex[Number(m[2])] = m[1];
}
const constToField = {};
for (const [idx, cname] of Object.entries(constNameByIndex)) {
  const field = indexToName[Number(idx)];
  if (field) constToField[cname] = field;
}

const aliases = ['d', 'data', 'dv', 'dd', 'd2', 'dpre'];

function fieldForIndex(idx) {
  return indexToName[idx] || `data_${idx}`;
}

function walk(dir, exts, cb) {
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) {
      if (ent.name === '.godot' || ent.name === '.git') continue;
      walk(p, exts, cb);
    } else if (exts.has(path.extname(ent.name).toLowerCase())) {
      cb(p);
    }
  }
}

function transform(text) {
  let s = text;

  // ---- declarations ----
  const declPatterns = [
    [/var (d|data|dv|dd|d2|dpre): Array\[int\] = (\w+)\.数值表 if (\w+) != null else \[\]/g, 'var $1: WorldState = $2'],
    [/var (d|data|dv|dd|d2|dpre): Array\[int\] = (\w+)\.数值表/g, 'var $1: WorldState = $2'],
    [/var (d|data|dv|dd|d2|dpre) := (\w+)\.数值表/g, 'var $1 := $2'],
    [/var (d|data|dv|dd|d2|dpre): Array\[int\] = 数值表/g, 'var $1: WorldState = self'],
    [/var (d|data|dv|dd|d2|dpre) := 数值表/g, 'var $1 := self'],
  ];
  for (const [re, repl] of declPatterns) {
    s = s.replace(re, repl);
  }

  // ---- typed parameter/local declarations ----
  s = s.replace(/\b(d|data|dv|dd|d2|dpre): Array\[int\]/g, '$1: WorldState');

  // ---- object.数值表[...] ----
  // const access: obj.数值表[W.I_X] or obj.数值表[WorldState.I_X]
  s = s.replace(/(\w+)\.数值表\[(?:W\.|WorldState\.)?I_([A-Z0-9_]+)\]/g, (m, obj, cname) => {
    const field = constToField[cname];
    if (!field) {
      console.error('Missing const field mapping for', cname);
      return m;
    }
    return `${obj}.${field}`;
  });
  // numeric access: obj.数值表[N]
  s = s.replace(/(\w+)\.数值表\[(\d+)\]/g, (m, obj, idx) => `${obj}.${fieldForIndex(Number(idx))}`);

  // ---- bare 数值表[...] inside WorldState ----
  s = s.replace(/(?<![.\w])数值表\[(?:W\.|WorldState\.)?I_([A-Z0-9_]+)\]/g, (m, cname) => {
    const field = constToField[cname];
    if (!field) {
      console.error('Missing const field mapping for', cname);
      return m;
    }
    return field;
  });
  s = s.replace(/(?<![.\w])数值表\[(\d+)\]/g, (m, idx) => fieldForIndex(Number(idx)));

  // ---- .数值表.size() ----
  s = s.replace(/(\w+)\.数值表\.size\(\)/g, '$1.size()');
  s = s.replace(/(?<![.\w])数值表\.size\(\)/g, 'size()');

  // ---- remaining .数值表 property references become the object ----
  // e.g. _update_displays(world.数值表) -> _update_displays(world)
  s = s.replace(/(\w+)\.数值表\b/g, '$1');

  // ---- alias array index access: v[W.I_X] / v[N] ----
  for (const alias of aliases) {
    s = s.replace(new RegExp(`\\b${alias}\\[(?:W\\.|WorldState\\.)?I_([A-Z0-9_]+)\\]`, 'g'), (m, cname) => {
      const field = constToField[cname];
      if (!field) {
        console.error('Missing const field mapping for', cname);
        return m;
      }
      return `${alias}.${field}`;
    });
    s = s.replace(new RegExp(`\\b${alias}\\[(\\d+)\\]`, 'g'), (m, idx) => `${alias}.${fieldForIndex(Number(idx))}`);
  }

  return s;
}

const files = [];
walk(ROOT, new Set(['.gd']), p => files.push(p));
let changed = 0;
for (const file of files) {
  const original = fs.readFileSync(file, 'utf8');
  const updated = transform(original);
  if (updated !== original) {
    fs.writeFileSync(file, updated);
    changed++;
    console.log('migrated', path.relative(ROOT, file));
  }
}
console.log('Changed files:', changed);
